/**************************************************************************************************
 * Name: EditContractDetailController
 * Object: 
 * Purpose: 编辑合同明细控制类
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Noel             2024-10-24         Created             
***************************************************************************************************/
public without sharing class EditContractDetailController {
    @AuraEnabled
    public static Output initData(String contractId) {
        try {
            system.debug('contractId:'+contractId);
            Contracts__c con = [SELECT Name,Id,Transaction_Mode__c,RecordType.DeveloperName,CRM_Approval_Status__c,Show_Notification__c,Quote__c,Quote__r.Quotation_Type__c,Payment_Term_Cost_Rate__c,Sales_Org__c,Distribution_Channel__c,Delivery_Plant__c,(SELECT Id,Product__c FROM Contracts_Detail__r)  FROM Contracts__c WHERE Id=:contractId];
            Output out = new Output();
            out.paymentTermCostRate=con.Payment_Term_Cost_Rate__c;
            // if (con.CRM_Approval_Status__c =='Approving' || con.CRM_Approval_Status__c=='Approed' || (con.Show_Notification__c && !Test.isRunningTest())) {
            //     out.isSucess = false;
            //     //out.errorMsg = 'can not edit this contract detail';
            //     out.errorMsg =System.Label.EditConDetailStatusError;
            //     return out;
            // }
            if (con.Delivery_Plant__c == '5070') {
                out.isAR = true;
            }else{
                out.isAR = false;
            }
            if(con.RecordType.DeveloperName=='Headquarters')
            {
                out.isHQContract=true;
            }
            else
            {
                out.isHQContract=false;
            }
            if(con.Quote__c != null)
            {
                out.isBaseQuote=true;
            }
            else
            {
                out.isBaseQuote=false;
            }
            if(con.Quote__c == null || con.Transaction_Mode__c == 'Subsidiary')
            {
                out.isEditHqPrice=true;
            }
            else
            {
                out.isEditHqPrice=false;
            }
            if(con.RecordType.DeveloperName=='Sales_Contract')
            {
                out.isSaleContract=true;
            }
            else
            {
                out.isSaleContract=false;
            }
            out.isSucess = true;
            out.conDetailList = new List<ContractDetail>();
            Map<String, String> unitMap = Utility.getPicklistValueMap('Contracts_Detail__c', 'Unit__c');
            Map<String, String> ifDesignatedProductMap = Utility.getPicklistValueMap('Contracts_Detail__c', 'If_Designated_Products__c');
            Map<String, String> ifPalletMap = Utility.getPicklistValueMap('Contracts_Detail__c', 'If_Pallet__c');
            Map<String, String> recheckMarginMap = Utility.getPicklistValueMap('Contracts_Detail__c', 'Recheck_Margin__c');
            
            out.unitMap=unitMap;
            out.ifDesignatedProductMap=ifDesignatedProductMap;
            out.ifPalletMap=ifPalletMap;
            out.recheckMarginMap=recheckMarginMap;
            List<Contracts_Detail__c> conDetailList = [
                                    SELECT 
                                        Unit_Label__c,Tracking_Code__c,Id, Contracts__c,Quote_Detail__r.Quote_Product_Name__c,Quote_Detail__r.Contract_Processing_Product__c,Quote_Detail__c,Quality_Requirement__c,HQ_Contract_Unit_Price__c,Quote_Detail__r.Price_List__c,Quote_Detail__r.Price_List__r.Name,Product__c,Commodity__c,BU_Sales_Price__c,Delivery_Time__c ,Unit__c ,Total_Amount__c,Qnty__c,Discount_Unit_Price__c
                                        ,Product_English_Name__c,Product_Name__c,If_Designated_Products__c,If_Pallet__c,Packing_Size__c,Unit_Price__c,Commission_Unit_Price__c
                                        ,Packing_cost__c,Pallet_Cost__c,FOB_Price__c,Freight_Cost__c,Packing_Size_Description__c,Recheck_Margin__c,Other_Issue__c,Inland_Cost_Including_Insurance__c,Clearance_Cost_Percentage__c
                                        ,(SELECT Link__c,File_Type__c,Size_Kb__c,Name,CreatedDate,Id,Contracts_Detail__c FROM Attachments__r)
                                    FROM 
                                        Contracts_Detail__c 
                                    WHERE Contracts__c   =: contractId];

            Integer index = 0;
            Set<String>  priceListName= new Set<String>();
            Set<String>  productIdSet= new Set<String>();
            Set<String>  proSalesInfoIdSet= new Set<String>();
            for (Contracts_Detail__c conDetail : conDetailList)
            {
                if(conDetail.Quote_Detail__c != null && conDetail.Quote_Detail__r.Price_List__c != null)
                {priceListName.add(conDetail.Quote_Detail__r.Price_List__r.Name);}
                if(conDetail.Quote_Detail__c != null && conDetail.Quote_Detail__r.Price_List__c == null && conDetail.Quote_Detail__r.Contract_Processing_Product__c == null && conDetail.Quote_Detail__r.Quote_Product_Name__c != null)
                {priceListName.add(conDetail.Quote_Detail__r.Quote_Product_Name__c);}
            }
            System.debug('priceListName=>'+priceListName);
            Map<String,List<Quote_Name_Relationship__c>>  quoteNameProductMap= new Map<String,List<Quote_Name_Relationship__c>>();
            Map<String,List<Product_Unit__c>>  proUnitMap= new Map<String,List<Product_Unit__c>>();
            Map<String,List<Product_Name__c>>  proNameMap= new Map<String,List<Product_Name__c>>();
            for(Quote_Name_Relationship__c quoteNameRelation:[SELECT Id, Quote_Name__c, Products__c,Products__r.Name,Products__r.English_Description__c  FROM Quote_Name_Relationship__c WHERE  Quote_Name__c IN: priceListName])
            {
                if(quoteNameProductMap.containsKey(quoteNameRelation.Quote_Name__c.toLowerCase()))
                {
                    quoteNameProductMap.get(quoteNameRelation.Quote_Name__c.toLowerCase()).add(quoteNameRelation);
                }else{
                    quoteNameProductMap.put(quoteNameRelation.Quote_Name__c.toLowerCase(),new List<Quote_Name_Relationship__c>{quoteNameRelation});
                }
                productIdSet.add(quoteNameRelation.Products__c);
            }
            if(con.Quote__c == null)
            {
                for(Contracts_Detail__c cd:conDetailList){
                      if(cd.Product__c != null){productIdSet.add(cd.Product__c);}
                  }
            }
            System.debug('productIdSet=>'+productIdSet);
            System.debug('quoteNameProductMap=>'+quoteNameProductMap);
            
            for(Product_Sales_Info__c proSalesInfo:[SELECT Id, Name, Product__c, Distr_Channel__c, Factory__c, Sales_Organization__c FROM Product_Sales_Info__c WHERE Product__c IN:productIdSet AND Sales_Organization__c =: con.Sales_Org__c AND Distr_Channel__c =: con.Distribution_Channel__c AND Factory__c   =: con.Delivery_Plant__c AND Status__c='On Shelves'])
            {
                proSalesInfoIdSet.add(proSalesInfo.Id);
            }
            System.debug('proSalesInfoIdSet=>'+proSalesInfoIdSet);
            for(Product_Name__c proName:[SELECT Id, Name, Product_Sales_Info__c,Product_Sales_Info__r.Product__c FROM Product_Name__c WHERE Product_Sales_Info__c IN:proSalesInfoIdSet AND Is_Delete__c=false])//添加商品名称删除逻辑
            {
                if(proNameMap.containsKey(proName.Product_Sales_Info__r.Product__c))
                {
                    proNameMap.get(proName.Product_Sales_Info__r.Product__c).add(proName);
                }else{
                    proNameMap.put(proName.Product_Sales_Info__r.Product__c,new List<Product_Name__c>{proName});
                }
            }
            System.debug('proNameMap=>'+proNameMap);
            for(Product_Unit__c proUnit:[SELECT Id, Name, Product_Sales_Unit__c,Product__c FROM Product_Unit__c WHERE Product__c IN:productIdSet])
            {
                if(proUnitMap.containsKey(proUnit.Product__c))
                {
                    proUnitMap.get(proUnit.Product__c).add(proUnit);
                }else{
                    proUnitMap.put(proUnit.Product__c,new List<Product_Unit__c>{proUnit});
                }
            }
            System.debug('proUnitMap=>'+proUnitMap);
            for (Contracts_Detail__c conDetail : conDetailList) {
                ContractDetail cd = new ContractDetail();
                //附件数据结构
                if(conDetail.Attachments__r.size()>0){
                    cd.fileData = conDetail.Attachments__r;
                }else{
                    cd.fileData = new List<Attachment__c>();
                }
                cd.conDetailData = conDetail;
                cd.productEnglishName=conDetail.Quote_Detail__r.Price_List__r.Name;
                if(con.Quote__c != null && con.Quote__r.Quotation_Type__c=='Tolling')
                {cd.productEnglishName=conDetail.Quote_Detail__r.Contract_Processing_Product__r.Name;}
                if(con.Quote__c != null && conDetail.Quote_Detail__r.Price_List__c == null && conDetail.Quote_Detail__r.Contract_Processing_Product__c == null && conDetail.Quote_Detail__r.Quote_Product_Name__c != null)
                { cd.productEnglishName=conDetail.Quote_Detail__r.Quote_Product_Name__c;}
                cd.proList=new List<Option>();
                Option op1 = new Option();
                op1.label = null;
                op1.value = null;
                cd.proList.add(op1);
                cd.proNameList=new List<Option>();
                cd.proUnitList=new List<Option>();
                Option op2 = new Option();
                op2.label = null;
                op2.value = null;
                cd.proNameList.add(op2);
                Option op3 = new Option();
                op3.label = null;
                op3.value = null;
                cd.proUnitList.add(op3);
                if(quoteNameProductMap != null && conDetail.Quote_Detail__c != null && conDetail.Quote_Detail__r.Price_List__c != null && quoteNameProductMap.get(conDetail.Quote_Detail__r.Price_List__r.Name.toLowerCase()) != null)
                {
                for(Quote_Name_Relationship__c quoNameRelation:quoteNameProductMap.get(conDetail.Quote_Detail__r.Price_List__r.Name.toLowerCase()))
                {
                    Option op = new Option(); op.label = quoNameRelation.Products__r.Name+' ['+quoNameRelation.Products__r.English_Description__c+']';op.value = quoNameRelation.Products__c; cd.proList.add(op);
                }}
                if(quoteNameProductMap != null && conDetail.Quote_Detail__c != null && conDetail.Quote_Detail__r.Quote_Product_Name__c != null && conDetail.Quote_Detail__r.Price_List__c == null  && conDetail.Quote_Detail__r.Contract_Processing_Product__c == null && quoteNameProductMap.get(conDetail.Quote_Detail__r.Quote_Product_Name__c.toLowerCase()) != null)
                {
                for(Quote_Name_Relationship__c quoNameRelation:quoteNameProductMap.get(conDetail.Quote_Detail__r.Quote_Product_Name__c.toLowerCase()))
                {
                    Option op = new Option();op.label = quoNameRelation.Products__r.Name+' ['+quoNameRelation.Products__r.English_Description__c+']';op.value = quoNameRelation.Products__c;cd.proList.add(op);
                }}
                if(proNameMap != null && proNameMap.get(conDetail.Product__c) != null)
                {
                for(Product_Name__c proName:proNameMap.get(conDetail.Product__c))
                {
                    Option op = new Option();op.label = proName.Name;op.value = proName.Id;cd.proNameList.add(op);
                }}
                if(proUnitMap != null && proUnitMap.get(conDetail.Product__c) != null)
                {
                for(Product_Unit__c proUnit:proUnitMap.get(conDetail.Product__c))
                {
                    Option op = new Option();op.label = unitMap.get(proUnit.Product_Sales_Unit__c);op.value = proUnit.Product_Sales_Unit__c;cd.proUnitList.add(op);
                }}
                cd.index=index;
                index++;
                // if(conDetail.Discount_Unit_Price__c != null)
                // {
                //     if(conDetail.BU_Sales_Price__c != null)
                //     {
                //         cd.price=conDetail.Discount_Unit_Price__c-conDetail.BU_Sales_Price__c;
                //     }
                //     else
                //     {
                //         cd.price=conDetail.Discount_Unit_Price__c;
                //     }
                // }
                // else
                // {
                //      cd.price=0;
                // }
                out.conDetailList.add(cd);
                index++;
            }

            
            out.errorMsg = '';
            system.debug('out:'+out);
            return out;
        } catch (Exception e) {
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';'+e.getLineNumber();
            return out;
        }
        
    
    }

     @AuraEnabled
    public static Output initOrderData(String orderId,String type) {
        try {
            system.debug('orderId:'+orderId);
            Order__c order = [SELECT Name,Id,Quotes__c,Quotes__r.Quotation_Type__c,Sales_Org__c,Order_type__c,SAP_Order_Code__c,Locked_in_SAP__c,Deliver_Plant__c,Distr_Channel__c FROM Order__c WHERE Id=:orderId];
            Output out = new Output();
            out.errorMsg = '';
            out.isSucess = true;
            if(order.Order_type__c=='ZMX2' || order.Order_type__c=='ZAR2' || (order.Quotes__c != null && order.Quotes__r.Quotation_Type__c=='Tolling'))
            {
                out.isCreateOrderItem=true;
            }
            else
            {
                out.isCreateOrderItem=false;
            }
            //是否为ZAR2订单
            if (order.Order_type__c=='ZAR2') {
                out.isZAR2 = true;
            }else{
                out.isZAR2 = false;
            }

            //墨西哥特殊逻辑-----start
            if (order.Sales_Org__c == '3020' || order.Sales_Org__c == '3010') {
                out.isMX = true;
            }else{
                out.isMX = false;
            }
            //墨西哥特殊逻辑-----end
            if(order.Sales_Org__c=='3010' && type!='Order Change'){out.isProductUsage=true;}
            else{out.isProductUsage=false;}
            out.orderDetailList = new List<OrderDetail>();
            Map<String, String> unitMap = Utility.getPicklistValueMap('Order_Item__c', 'Sales_Unit_Text__c');
            Map<String, String> productUsageMap = Utility.getPicklistValueMap('Order_Item__c', 'Product_Usage__c');
            Map<String, String> productUnitMap = Utility.getPicklistValueMap('Order_Item__c', 'Sales_Unit_Text__c');
              
            out.unitMap=unitMap;
            out.productUsageMap=productUsageMap;
            
            List<Order_Item__c> orderDetailList = [
                                    SELECT 
                                        Toxicity_Classification__c,Id,Name,Original_Product_Cost__c, Order__c,Product_Cost__c,Quote_Price__c,Product_Usage__c,Material_Number__c,Quote_Detail__r.Price_List__c,Quote_Detail__r.Quote_Product_Name__c,Quote_Detail__r.Contract_Processing_Product__c,Quote_Detail__r.Price_List__r.Name,Quote_Detail__r.Packing_Size__c,Quote_Detail__r.Packing_Size__r.Name,Quote_Detail__r.Contract_Processing_Product__r.Name,SAP_Item_Num__c,Quote_Detail__c,Product__c,Commodity__c,Sales_Unit_Text__c,Price__c ,New_Price__c,Quantity__c ,New_Quantity__c,New_Amount__c,Amount_per_item__c,Delivery_Date__c,New_Delivery_Date__c,ETA__c
                                    FROM 
                                        Order_Item__c 
                                    WHERE Order__c   =: orderId];
            if(type=='Order Change')
            {
                orderDetailList = [
                                    SELECT 
                                        Toxicity_Classification__c,Id,Name,Original_Product_Cost__c, Order__c,Product_Cost__c,Quote_Price__c,Product_Usage__c,Material_Number__c,SAP_Item_Num__c,Quote_Detail__c,Quote_Detail__r.Price_List__c,Quote_Detail__r.Quote_Product_Name__c,Quote_Detail__r.Contract_Processing_Product__c,Quote_Detail__r.Price_List__r.Name,Quote_Detail__r.Packing_Size__c,Quote_Detail__r.Packing_Size__r.Name,Quote_Detail__r.Contract_Processing_Product__r.Name,Product__c,Commodity__c,Sales_Unit_Text__c,Price__c ,New_Price__c,Quantity__c ,New_Quantity__c,New_Amount__c,Amount_per_item__c,Delivery_Date__c,New_Delivery_Date__c,ETA__c
                                    FROM 
                                        Order_Item__c 
                                    WHERE Order__c   =: orderId AND (Edit_Status__c =null OR Edit_Status__c='A') AND isClosed__c!=true];
            }
            Integer index = 0;
            /*String orderItemIds='';
            Set<String> changeOrderItemSet=new Set<String>();
            if(type=='Order Change')
            {
            for(Order_Item__c oi:orderDetailList)
            {
                orderItemIds=orderItemIds+oi.Id+';';
            }
            System.debug('orderItemIds=>'+orderItemIds);
            
            OrderSyncToSAP.ReturnResult returnResult=new OrderSyncToSAP.ReturnResult();
            if (order.SAP_Order_Code__c!=null)
            {
                ReturnResult=OrderSyncToSAP.submitToSAP(orderId, 'U',false,false,'zz',orderItemIds,false);
            }
            else
            {
                ReturnResult=OrderSyncToSAP.submitToSAP(orderId, 'I',false,false,'zz',orderItemIds,false);
            }
            System.debug('returnResult=>'+returnResult);
            // returnResult.isSuccess=true;
            // returnResult.item=new List<OrderSyncToSAP.Item>();
            // OrderSyncToSAP.Item item1=new OrderSyncToSAP.Item();
            // OrderSyncToSAP.Item item2=new OrderSyncToSAP.Item();
            // item1.status='A';
            // item1.POSNR='10';
            // item2.status='B';
            // item2.POSNR='20';
            // returnResult.item.add(item1);
            // returnResult.item.add(item2);
            // System.debug('returnResult=>'+returnResult);
            if(!returnResult.isSuccess)
            {
                out.isSucess = false;
                out.errorMsg =returnResult.message;
                return out;
            }
            else
            {   
                order.Locked_in_SAP__c = true;
                update order;
                for(OrderSyncToSAP.Item item:returnResult.item)
                {
                    if(item.status=='A')
                    {
                        changeOrderItemSet.add(item.POSNR);
                    }
                }
                
            }
            system.debug('changeOrderItemSet=>'+changeOrderItemSet);
            }*/
            Set<String>  priceListName= new Set<String>();
            Set<String>  productIdSet= new Set<String>();
            Set<String>  proSalesInfoIdSet= new Set<String>();
            for (Order_Item__c orderDetail : orderDetailList)
            {
                if(orderDetail.Quote_Detail__c != null && orderDetail.Quote_Detail__r.Price_List__c != null)
                {     priceListName.add(orderDetail.Quote_Detail__r.Price_List__r.Name);}
                if(orderDetail.Quote_Detail__c != null && orderDetail.Quote_Detail__r.Price_List__c == null && orderDetail.Quote_Detail__r.Contract_Processing_Product__c == null && orderDetail.Quote_Detail__r.Quote_Product_Name__c != null)
                {     priceListName.add(orderDetail.Quote_Detail__r.Quote_Product_Name__c);}
            }
            System.debug('priceListName=>'+priceListName);
            Map<String,List<Quote_Name_Relationship__c>>  quoteNameProductMap= new Map<String,List<Quote_Name_Relationship__c>>();
            Map<String,List<Product_Name__c>>  proNameMap= new Map<String,List<Product_Name__c>>();
            Map<String,List<Product_Unit__c>>  proUnitMap= new Map<String,List<Product_Unit__c>>();
            for(Quote_Name_Relationship__c quoteNameRelation:[SELECT Id, Quote_Name__c, Products__c,Products__r.Name,Products__r.English_Description__c  FROM Quote_Name_Relationship__c WHERE  Quote_Name__c IN: priceListName])
            {
                if(quoteNameProductMap.containsKey(quoteNameRelation.Quote_Name__c.toLowerCase()))
                {
                    quoteNameProductMap.get(quoteNameRelation.Quote_Name__c.toLowerCase()).add(quoteNameRelation);
                }else{
                    quoteNameProductMap.put(quoteNameRelation.Quote_Name__c.toLowerCase(),new List<Quote_Name_Relationship__c>{quoteNameRelation});
                }
                productIdSet.add(quoteNameRelation.Products__c);
            }
            if(out.isCreateOrderItem)
            {
                for(Order_Item__c oi:orderDetailList){
                      if(oi.Product__c != null){productIdSet.add(oi.Product__c);}
                  }
            }
            System.debug('productIdSet=>'+productIdSet);
            System.debug('quoteNameProductMap=>'+quoteNameProductMap);
            
            for(Product_Sales_Info__c proSalesInfo:[SELECT Id, Name, Product__c, Distr_Channel__c, Factory__c, Sales_Organization__c FROM Product_Sales_Info__c WHERE Product__c IN:productIdSet AND Sales_Organization__c =: order.Sales_Org__c AND Distr_Channel__c =: order.Distr_Channel__c AND Factory__c =: order.Deliver_Plant__c AND Status__c='On Shelves'])
            {
                proSalesInfoIdSet.add(proSalesInfo.Id);
            }
            System.debug('proSalesInfoIdSet=>'+proSalesInfoIdSet);
            for(Product_Name__c proName:[SELECT Id, Name, Product_Sales_Info__c,Product_Sales_Info__r.Product__c FROM Product_Name__c WHERE Product_Sales_Info__c IN:proSalesInfoIdSet AND Is_Delete__c=false])//添加商品名称删除逻辑
            {
                if(proNameMap.containsKey(proName.Product_Sales_Info__r.Product__c))
                {
                    proNameMap.get(proName.Product_Sales_Info__r.Product__c).add(proName);
                }else{
                    proNameMap.put(proName.Product_Sales_Info__r.Product__c,new List<Product_Name__c>{proName});
                }
            }
            System.debug('proNameMap=>'+proNameMap);
            for(Product_Unit__c proUnit:[SELECT Id, Name, Product_Sales_Unit__c,Product__c FROM Product_Unit__c WHERE Product__c IN:productIdSet])
            {
                if(proUnitMap.containsKey(proUnit.Product__c))
                {
                    proUnitMap.get(proUnit.Product__c).add(proUnit);
                }else{
                    proUnitMap.put(proUnit.Product__c,new List<Product_Unit__c>{proUnit});
                }
            }
            //毒性字段选项值
            out.toxicityList = new List<Option>();
            Option opNone = new Option();
            opNone.label = 'None';
            opNone.value = '';
            out.toxicityList.add(opNone);
            Map<String,String> toxicityMap = Utility.getPicklistValueMap('Order_Item__c','Toxicity_Classification__c');
            for (String toxicity : toxicityMap.keySet()) {
                Option op = new Option();
                op.label = toxicityMap.get(toxicity);
                op.value = toxicity;
                out.toxicityList.add(op);
            }
            System.debug('proUnitMap=>'+proUnitMap);
            for (Order_Item__c orderDetail : orderDetailList)
            {
                OrderDetail cd = new OrderDetail();
                cd.ordDetailData = orderDetail;
                cd.productEnglishName=orderDetail.Quote_Detail__r.Price_List__r.Name;
                if(order.Quotes__c != null && order.Quotes__r.Quotation_Type__c=='Tolling')
                { cd.productEnglishName=orderDetail.Quote_Detail__r.Contract_Processing_Product__r.Name;}
                if(order.Quotes__c != null && orderDetail.Quote_Detail__c != null && orderDetail.Quote_Detail__r.Price_List__c == null && orderDetail.Quote_Detail__r.Contract_Processing_Product__c == null && orderDetail.Quote_Detail__r.Quote_Product_Name__c != null)
                {cd.productEnglishName=orderDetail.Quote_Detail__r.Quote_Product_Name__c;}
                cd.packSizeName=orderDetail.Quote_Detail__r.Packing_Size__r.Name;
                cd.proList=new List<Option>();
                Option op1 = new Option();
                op1.label = null;
                op1.value = null;
                cd.proList.add(op1);
                cd.proNameList=new List<Option>();
                Option op2 = new Option();
                op2.label = null;
                op2.value = null;
                cd.proNameList.add(op2);
                cd.proUnitList=new List<Option>();
                Option op3 = new Option();
                op3.label = null;
                op3.value = null;
                cd.proUnitList.add(op3);
                if(quoteNameProductMap != null && orderDetail.Quote_Detail__c != null && orderDetail.Quote_Detail__r.Price_List__c != null && quoteNameProductMap.get(orderDetail.Quote_Detail__r.Price_List__r.Name.toLowerCase()) != null)
                {
                for(Quote_Name_Relationship__c quoNameRelation:quoteNameProductMap.get(orderDetail.Quote_Detail__r.Price_List__r.Name.toLowerCase()))
                {
                    Option op = new Option();op.label = quoNameRelation.Products__r.Name+' ['+quoNameRelation.Products__r.English_Description__c+']';op.value = quoNameRelation.Products__c; cd.proList.add(op);
                }}
                if(quoteNameProductMap != null && orderDetail.Quote_Detail__c != null && orderDetail.Quote_Detail__r.Price_List__c == null && orderDetail.Quote_Detail__r.Contract_Processing_Product__c == null && orderDetail.Quote_Detail__r.Quote_Product_Name__c != null && quoteNameProductMap.get(orderDetail.Quote_Detail__r.Quote_Product_Name__c.toLowerCase()) != null)
                {
                for(Quote_Name_Relationship__c quoNameRelation:quoteNameProductMap.get(orderDetail.Quote_Detail__r.Quote_Product_Name__c.toLowerCase()))
                {
                    Option op = new Option();op.label = quoNameRelation.Products__r.Name+' ['+quoNameRelation.Products__r.English_Description__c+']';op.value = quoNameRelation.Products__c; cd.proList.add(op);
                }}
                if(proNameMap != null && proNameMap.get(orderDetail.Product__c) != null)
                {
                for(Product_Name__c proName:proNameMap.get(orderDetail.Product__c))
                {
                    Option op = new Option();op.label = proName.Name;op.value = proName.Id;cd.proNameList.add(op);
                }}
                if(proUnitMap != null && proUnitMap.get(orderDetail.Product__c) != null)
                {
                for(Product_Unit__c proUnit:proUnitMap.get(orderDetail.Product__c))
                {
                    Option op = new Option();op.label = productUnitMap.get(proUnit.Product_Sales_Unit__c);op.value = proUnit.Product_Sales_Unit__c;cd.proUnitList.add(op);
                }}
                cd.index=index;
                index++;
                out.orderDetailList.add(cd);
                
            }
            system.debug('out:'+out);
            return out;
        } catch (Exception e) {
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';'+e.getLineNumber();
            return out;
        }
        
    
    }


    @AuraEnabled
    public static ProductResult mapProduct(string productId, String contractId,String commodityId) {
        try {
            System.debug('productId' + productId);
            System.debug('contractId' + contractId);
            System.debug('commodityId' + commodityId);
            ProductResult out = new ProductResult();
            out.isSucess = true;
            Contracts__c con = [SELECT Name,Id,Sales_Org__c,Delivery_Plant__c,Distribution_Channel__c  FROM Contracts__c WHERE Id=:contractId];
            if (productId != null) {
                List<Product_Sales_Info__c> productSaleInfoList = [SELECT toLabel(Product__r.Basic_Metering_Unit__c),Id, Name, Product__c, Distr_Channel__c, Factory__c, Sales_Organization__c FROM Product_Sales_Info__c WHERE Product__c = :productId AND Sales_Organization__c =: con.Sales_Org__c AND Distr_Channel__c =: con.Distribution_Channel__c AND Factory__c =: con.Delivery_Plant__c AND Status__c='On Shelves'];
                if (productSaleInfoList==null || productSaleInfoList.size() == 0) {
                    out.isSucess = false;
                    //out.errorMsg = 'Not Find Map Product Sales Info';
                    out.errorMsg = System.Label.EditOrderItemError3;
                    System.debug('out:' + out);
                    return out;
                }else
                {
                     List<Product_Name__c> productNameList = [SELECT Id, Name, Product_Sales_Info__c FROM Product_Name__c WHERE Product_Sales_Info__c = :productSaleInfoList[0].Id AND Id=:commodityId];
                    if (productNameList==null || productNameList.size() == 0) 
                    {
                        out.isSucess = false;
                        //out.errorMsg = 'Product Sales Info Not Find Product Name';
                        out.errorMsg = System.Label.EditOrderItemError2;
                        System.debug('out:' + out);
                        return out;
                    }
                    else
                    {
                        //out.commodityId = productNameList[0].Id;
                        List<Price_Book_Item__c> priceList = [SELECT Id, Name, Product_Name__c,Price__c FROM Price_Book_Item__c WHERE Product_Name__c = :commodityId];
                        if(priceList.size()>0)
                        {
                            out.price = priceList[0].Price__c;
                        }
                        else
                        {
                            out.price = 0;
                        }
                    }
                    out.defaultUnit = productSaleInfoList[0].Product__r.Basic_Metering_Unit__c;
                }

            }
            System.debug('out:' + out);
            return out;
        } catch (Exception e) {
            System.debug('错误信息' + e.getMessage() + e.getLineNumber());
            ProductResult out = new ProductResult(); out.isSucess = false; out.errorMsg = InterfaceUtility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
            System.debug('out:' + out);
            return out;
        }
    }

    /*@AuraEnabled
    public static ProductResult mapOrderProduct(string productId, String orderId,String commodityId) {
        try {
            System.debug('productId' + productId);
            System.debug('orderId' + orderId);
            System.debug('commodityId' + commodityId);
            ProductResult out = new ProductResult();
            out.isSucess = true;
            Order__c order = [SELECT Name,Id,Sales_Org__c,Deliver_Plant__c,Distr_Channel__c FROM Order__c WHERE Id=:orderId];
            if (productId != null) {
                List<Product_Sales_Info__c> productSaleInfoList = [SELECT Id, Name, Product__c, Distr_Channel__c, Delivering_Plant__c, Sales_Organization__c FROM Product_Sales_Info__c WHERE Product__c = :productId AND Sales_Organization__c =: order.Sales_Org__c AND Distr_Channel__c =: order.Distr_Channel__c AND Delivering_Plant__c =: order.Deliver_Plant__c];
                if (productSaleInfoList==null || productSaleInfoList.size() == 0) {
                    out.isSucess = false;
                    out.errorMsg = 'Not Find Map Product Sales Info';
                    System.debug('out:' + out);
                    return out;
                }else
                {
                     List<Product_Name__c> productNameList = [SELECT Id, Name, Product_Sales_Info__c FROM Product_Name__c WHERE Product_Sales_Info__c = :productSaleInfoList[0].Id AND Id=:commodityId];
                    if (productNameList==null || productNameList.size() == 0) 
                    {
                        out.isSucess = false;
                        out.errorMsg = 'Product Sales Info Not Find Product Name';
                        System.debug('out:' + out);
                        return out;
                    }
                    else
                    {
                        //out.commodityId = productNameList[0].Id;
                        List<Price_Book_Item__c> priceList = [SELECT Id, Name, Product_Name__c,Price__c FROM Price_Book_Item__c WHERE Product_Name__c = :commodityId];
                        if(priceList.size()>0)
                        {
                            out.price = priceList[0].Price__c;
                        }
                        else
                        {
                            out.price = 0;
                        }
                    }
                }

            }
            System.debug('out:' + out);
            return out;
        } catch (Exception e) {
            System.debug('错误信息' + e.getMessage() + e.getLineNumber());
            ProductResult out = new ProductResult(); out.isSucess = false; out.errorMsg = InterfaceUtility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
            System.debug('out:' + out);
            return out;
        }
    }*/

    @AuraEnabled
    public static ProductResult vertifyProduct(string productId, String quoteDetailId) {
        try {
            System.debug('productId' + productId);
            System.debug('quoteDetailId' + quoteDetailId);
            ProductResult out = new ProductResult();
            out.isSucess = true;
            Quote_Detail__c quoteDetail = [SELECT Name,Id,Price_List__c ,Price_List__r.Name  FROM Quote_Detail__c WHERE Id=:quoteDetailId];
            if (quoteDetail.Price_List__c != null && quoteDetail.Price_List__r.Name != null) 
            {
                List<Quote_Name_Relationship__c> quoteNameRelationshipList = [SELECT Id, Quote_Name__c, Products__c  FROM Quote_Name_Relationship__c WHERE Products__c = :productId AND Quote_Name__c =: quoteDetail.Price_List__r.Name ];
                if (quoteNameRelationshipList==null || quoteNameRelationshipList.size() == 0) {
                    out.isSucess = false;
                    //out.errorMsg = 'Please Select Quote Name Map Product';
                    out.errorMsg = System.Label.EditOrderItemError1;
                    System.debug('out:' + out);
                    return out;
                }
            }
            System.debug('out:' + out);
            return out;
        } catch (Exception e) {
            System.debug('错误信息' + e.getMessage() + e.getLineNumber());
            ProductResult out = new ProductResult(); out.isSucess = false; out.errorMsg = InterfaceUtility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
            System.debug('out:' + out);
            return out;
        }
    }

    @AuraEnabled
    public static ProductResult vertifyOrderProduct(string productId,String orderId) {
        try {
            System.debug('productId' + productId);
            System.debug('orderId' + orderId);
            ProductResult out = new ProductResult();
            out.isSucess = true;
            out.proNameList=new List<Option>();
            Option op2 = new Option();
            op2.label = null;
            op2.value = null;
            out.proNameList.add(op2);
            out.proUnitList=new List<Option>();
            Option op3 = new Option();
            op3.label = null;
            op3.value = null;
            out.proUnitList.add(op3);
            Order__c order = [SELECT Name,Id,Sales_Org__c,Deliver_Plant__c,Distr_Channel__c FROM Order__c WHERE Id=:orderId];
            if (productId != null) {
                List<Product_Sales_Info__c> productSaleInfoList = [SELECT Id, Name, Product__c, Distr_Channel__c, Factory__c, Sales_Organization__c FROM Product_Sales_Info__c WHERE Product__c = :productId AND Sales_Organization__c =: order.Sales_Org__c AND Distr_Channel__c =: order.Distr_Channel__c AND Factory__c =: order.Deliver_Plant__c AND Status__c='On Shelves'];
                if (productSaleInfoList.size()>0) {
                    for(Product_Name__c proName:[SELECT Id, Name, Product_Sales_Info__c FROM Product_Name__c WHERE Product_Sales_Info__c = :productSaleInfoList[0].Id AND Is_Delete__c=false])//添加商品名称删除逻辑
                    {
                        Option op = new Option();
                        op.label = proName.Name;
                        op.value = proName.Id;
                        out.proNameList.add(op);
                    }
                }
            }
            Map<String, String> productUnitMap = Utility.getPicklistValueMap('Order_Item__c', 'Sales_Unit_Text__c');
            for(Product_Unit__c proUnit:[SELECT Id, Name, Product_Sales_Unit__c,Product__c FROM Product_Unit__c WHERE Product__c =:productId])
            {
                Option op = new Option();op.label = productUnitMap.get(proUnit.Product_Sales_Unit__c);op.value = proUnit.Product_Sales_Unit__c;out.proUnitList.add(op);
            }
            return out;
        } catch (Exception e) {
            System.debug('错误信息' + e.getMessage() + e.getLineNumber());
            ProductResult out = new ProductResult(); out.isSucess = false; out.errorMsg = InterfaceUtility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
            System.debug('out:' + out);
            return out;
        }
    }

    @AuraEnabled
    public static ProductResult getProductName(string productId,String contractId) {
        try {
            System.debug('productId' + productId);
            System.debug('contractId' + contractId);
            ProductResult out = new ProductResult();
            out.isSucess = true;
            out.proNameList=new List<Option>();
            out.proUnitList=new List<Option>();
            Option op2 = new Option();
            op2.label = null;
            op2.value = null;
            out.proNameList.add(op2);
            Option op3 = new Option();
            op3.label = null;
            op3.value = null;
            out.proUnitList.add(op3);
            Contracts__c con = [SELECT Name,Id,Quote__c,Payment_Term_Cost_Rate__c,Sales_Org__c,Distribution_Channel__c,Delivery_Plant__c  FROM Contracts__c WHERE Id=:contractId];
            if (productId != null) {
                Product__c pro = [SELECT Id,toLabel(Basic_Metering_Unit__c) FROM Product__c WHERE Id=:productId];
                out.defaultUnit = pro.Basic_Metering_Unit__c;
                List<Product_Sales_Info__c> productSaleInfoList = [SELECT toLabel(Product__r.Basic_Metering_Unit__c),Id, Name, Product__c, Distr_Channel__c, Factory__c, Sales_Organization__c FROM Product_Sales_Info__c WHERE Product__c = :productId AND Sales_Organization__c =: con.Sales_Org__c AND Distr_Channel__c =: con.Distribution_Channel__c AND Factory__c =: con.Delivery_Plant__c AND Status__c='On Shelves'];
                if (productSaleInfoList.size()>0) {
                    for(Product_Name__c proName:[SELECT Id, Name, Product_Sales_Info__c FROM Product_Name__c WHERE Product_Sales_Info__c = :productSaleInfoList[0].Id AND Is_Delete__c=false])//添加商品名称删除逻辑
                    {
                        Option op = new Option();
                        op.label = proName.Name;
                        op.value = proName.Id;
                        out.proNameList.add(op);
                    }
                    
                }
            }
            Map<String, String> unitMap = Utility.getPicklistValueMap('Contracts_Detail__c', 'Unit__c');
            for(Product_Unit__c proUnit:[SELECT Id, Name, Product_Sales_Unit__c,Product__c FROM Product_Unit__c WHERE Product__c =:productId])
            {
                Option op = new Option();op.label = unitMap.get(proUnit.Product_Sales_Unit__c);op.value = proUnit.Product_Sales_Unit__c;out.proUnitList.add(op);
            }
            System.debug('out=====>'+out);
            return out;
        } catch (Exception e) {
            System.debug('错误信息' + e.getMessage() + e.getLineNumber());
            ProductResult out = new ProductResult(); out.isSucess = false; out.errorMsg = InterfaceUtility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
            System.debug('out:' + out);
            return out;
        }
    }


    @AuraEnabled
    public static Output saveData(List<ContractDetail> conDetailList, List<String> deleteList,List<String> deleteFileList) {
        try {
            System.debug('conDetailList:'+conDetailList);
            Output out = new Output();
            out.isSucess = true;
            if (deleteList.size()>0) {
                Database.delete(deleteList);
            }
            if (deleteFileList.size()>0) {
                Database.delete(deleteFileList);
            }
            Map<String,String> unitMap = Utility.getPicklistLabelMap('Contracts_Detail__c','Unit__c');
            System.debug('conDetailList:'+conDetailList);
            if (conDetailList.size()>0) 
            {
                List<Contracts_Detail__c> upsertConDetailList = new List<Contracts_Detail__c>();
                List<Attachment__c> attachmentList = new List<Attachment__c>();
                String orderId;
                for (ContractDetail  cd: conDetailList) 
                {
                    Contracts_Detail__c conDetail=new Contracts_Detail__c();
                    conDetail=cd.conDetailData;
                    conDetail.Unit__c = unitMap.get(conDetail.Unit_Label__c);
                    //conDetail.Id=null;
                    upsertConDetailList.add(conDetail);
                }
                
                // 先保存Contracts_Detail__c记录
                Database.upsert(upsertConDetailList);
                
                // 为新增的记录创建关联的Attachment__c记录
                for (Integer i = 0; i < conDetailList.size(); i++) {
                    ContractDetail cd = conDetailList[i];
                    Contracts_Detail__c savedConDetail = upsertConDetailList[i];
                    
                    // 如果这是新增记录（没有Id）且有附件数据
                    if (cd.fileData != null && cd.fileData.size() > 0) {
                        for (Attachment__c attachment : cd.fileData) {
                            if (attachment.Id != null) {
                                continue;
                            }
                            // 创建新的Attachment__c记录并关联到Contracts_Detail__c
                            Attachment__c newAttachment = new Attachment__c();
                            newAttachment.Link__c = attachment.Link__c;
                            newAttachment.File_Type__c = attachment.File_Type__c;
                            newAttachment.Size_Kb__c = attachment.Size_Kb__c;
                            newAttachment.Name = attachment.Name;
                            newAttachment.Contracts_Detail__c = savedConDetail.Id; // 关联到Contracts_Detail__c
                            attachmentList.add(newAttachment);
                        }
                    }
                }
                System.debug('attachmentList====>'+attachmentList);
                // 保存Attachment__c记录
                if (attachmentList.size() > 0) {
                    insert attachmentList;
                }
                
                //Database.upsert(upsertConDetailList,Contracts_Detail__c.fields.External_Id__c);
            }
            
            out.errorMsg = '';
            return out;
        } catch (Exception e) {
            Output out = new Output();
            out.isSucess = false;
            //out.errorMsg = e.getMessage()+';Line:'+e.getLineNumber();
            out.errorMsg = e.getMessage().substring(e.getMessage().indexOf(', ')+1);
            return out;
        }
        
    
    }

    @AuraEnabled
    public static Output saveOrderData(
        List<OrderDetail> ordDetailList,
        List<String> deleteList,
        Boolean isOrderChange,
        string orderId
    ) {
        try {
            System.debug('isOrderChange=>'+isOrderChange);
            Set<String>  productIdSet= new Set<String>();
            Map<String,String>  productCodeMap= new Map<String,String>();
            Map<String,Map<String,Decimal>>  proUnitConversionMap= new Map<String,Map<String,Decimal>>();
            for (OrderDetail  cd: ordDetailList) 
            {
                Order_Item__c ordDetail=new Order_Item__c();
                ordDetail=cd.ordDetailData;
                if(ordDetail.Product__c != null){productIdSet.add(ordDetail.Product__c);}
            }
            for(Product__c pro:[SELECT Id,Name,(SELECT Id,Product_Sales_Unit__c,Conversion_Coefficient__c FROM Product_Unit__r) From Product__c WHERE Id IN:productIdSet])
            {
                productCodeMap.put(pro.Id,pro.Name);
                Map<String,Decimal>  unitConversionMap= new Map<String,Decimal>();
                for(Product_Unit__c proUnit:pro.Product_Unit__r)
                {
                    unitConversionMap.put(proUnit.Product_Sales_Unit__c,proUnit.Conversion_Coefficient__c);
                }
                proUnitConversionMap.put(pro.Id,unitConversionMap);
            }
            System.debug('productCodeMap=>'+productCodeMap);
            Order__c order = [SELECT Name,Id,Quotes__c,Quotes__r.Quotation_Type__c,Sales_Org__c,Order_type__c,SAP_Order_Code__c,Locked_in_SAP__c,Deliver_Plant__c,Distr_Channel__c FROM Order__c WHERE Id=:orderId];
            Set<String> orderItemSet = new Set<String>();
            for(Billing__c bill:[SELECT Id, Order__c,Order_Item__c FROM Billing__c WHERE Order__c=:orderId AND Billing_Status__c='C'])
            {
                orderItemSet.add(bill.Order_Item__c);
            }
            System.debug('orderItemSet=>'+orderItemSet);
            Output out = new Output();
            out.isSucess = true;
            if (deleteList.size()>0) {
                Database.delete(deleteList);
            }
            System.debug('ordDetailList:'+ordDetailList);
            Integer index=0;
            if (ordDetailList.size()>0) 
            {
                List<Order_Item__c> upsertOrdDetailList = new List<Order_Item__c>();
                for (OrderDetail  cd: ordDetailList) 
                {
                    Order_Item__c ordDetail=new Order_Item__c();
                    ordDetail=cd.ordDetailData;
                    if(!isOrderChange)
                    {
                        ordDetail.SAP_Item_Num__c=String.valueOf((index+1)*10);
                        index++;
                        ordDetail.IsCreate__c =true;
                        ordDetail.Material_Number__c=productCodeMap.get(ordDetail.Product__c);
                        if(proUnitConversionMap.get(ordDetail.Product__c) != null && proUnitConversionMap.get(ordDetail.Product__c).get(ordDetail.Sales_Unit_Text__c) != null && ordDetail.Original_Product_Cost__c != null){
                            ordDetail.Product_Cost__c = (ordDetail.Original_Product_Cost__c * proUnitConversionMap.get(ordDetail.Product__c).get(ordDetail.Sales_Unit_Text__c)).setScale(3);
                        }else{
                            ordDetail.Product_Cost__c=ordDetail.Original_Product_Cost__c;
                        }
                    }
                    // if(ordDetail.SAP_Item_Num__c != null)
                    // {
                    //     ordDetail.SAP_Item_Num__c=String.valueOf(ordDetail.SAP_Item_Num__c);
                    // }
                    if(isOrderChange && orderItemSet != null && orderItemSet.contains(ordDetail.Id) && ordDetail.New_Amount__c != null && ordDetail.New_Amount__c != ordDetail.Amount_per_item__c)
                    {
                         out.isSucess = false;
                         //out.errorMsg = ordDetail.Name+':Order Item  Have Invoice Status C  Billing No Change Amount';
                         out.errorMsg = ordDetail.Name+System.Label.OrderItemInvoiceStatusVertify;
                         return out;
                    }
                    // if(!isOrderChange && order.Quotes__c != null && order.Quotes__r.Quotation_Type__c=='Tolling')
                    // {
                    //     String vertifyIndex;
                    //     if(vertifyIndex != null && vertifyIndex[0] != 'Z')
                    //     {

                    //     }
                    // }
                    upsertOrdDetailList.add(ordDetail);
                }
                Database.upsert(upsertOrdDetailList);
                // if(isOrderChange)
                // {
                //     Order__c updateOrder=new Order__c();
                //     updateOrder.Id=orderId;
                //     updateOrder.Change_Status__c='Approving';
                //     update updateOrder;
                // }
                
                if(isOrderChange) {
                    Order__c updateOrder=new Order__c();
                    updateOrder.Id=orderId;
                    updateOrder.Order_Change__c = true;
                    updateOrder.Change_Status__c = 'Draft';
                    update updateOrder;
                }
                
            }
            out.errorMsg = '';
            return out;
        } catch (Exception e) {
            Output out = new Output();
            out.isSucess = false;
            //out.errorMsg = e.getMessage()+';Line:'+e.getLineNumber();
            System.debug('errorMsg:'+e.getMessage()+';Line:'+e.getLineNumber());
            out.errorMsg = e.getMessage().substring(e.getMessage().indexOf(', ')+1);
            return out;
        }
        
    
    }

    // /**
    //  * 处理文件上传并关联到Contracts_Detail__c记录
    //  * @param contractDetailId Contracts_Detail__c记录的ID
    //  * @param contentDocumentId ContentDocument的ID
    //  * @param contentVersionId ContentVersion的ID
    //  * @return Output 处理结果
    //  */
    // @AuraEnabled
    // public static Output handleFileUpload(String contractDetailId, String contentDocumentId, String contentVersionId) {
    //     Output out = new Output();
    //     try {
    //         // 创建ContentDocumentLink来关联文件到Contracts_Detail__c记录
    //         ContentDocumentLink cdl = new ContentDocumentLink();
    //         cdl.ContentDocumentId = contentDocumentId;
    //         cdl.LinkedEntityId = contractDetailId;
    //         cdl.ShareType = 'V'; // View权限
            
    //         insert cdl;
            
    //         out.isSucess = true;
    //         out.errorMsg = '';
            
    //     } catch (Exception e) {
    //         out.isSucess = false;
    //         out.errorMsg = e.getMessage();
    //     }
        
    //     return out;
    // }
    
    // /**
    //  * 获取Contracts_Detail__c记录关联的附件列表
    //  * @param contractDetailId Contracts_Detail__c记录的ID
    //  * @return List<ContentDocument> 附件列表
    //  */
    // @AuraEnabled(cacheable=true)
    // public static List<ContentDocument> getAttachments(String contractDetailId) {
    //     List<ContentDocumentLink> cdlList = [
    //         SELECT ContentDocumentId 
    //         FROM ContentDocumentLink 
    //         WHERE LinkedEntityId = :contractDetailId
    //     ];
        
    //     Set<Id> contentDocumentIds = new Set<Id>();
    //     for (ContentDocumentLink cdl : cdlList) {
    //         contentDocumentIds.add(cdl.ContentDocumentId);
    //     }
        
    //     List<ContentDocument> documents = [
    //         SELECT Id, Title, FileType, ContentSize, CreatedDate 
    //         FROM ContentDocument 
    //         WHERE Id IN :contentDocumentIds
    //         ORDER BY CreatedDate DESC
    //     ];
        
    //     return documents;
    // }

    // /**
    //  * 新增Contracts_Detail__c记录并关联附件
    //  * @param contractId 合同ID
    //  * @param contractDetailData 合同明细数据
    //  * @param attachmentData 附件数据列表
    //  * @return Output 处理结果
    //  */
    // @AuraEnabled
    // public static Output createContractDetailWithAttachments(String contractId, Contracts_Detail__c contractDetailData, List<Map<String, Object>> attachmentData) {
    //     Output out = new Output();
    //     Savepoint sp = Database.setSavepoint();
        
    //     try {
    //         // 1. 创建Contracts_Detail__c记录
    //         contractDetailData.Contracts__c = contractId;
    //         insert contractDetailData;
            
    //         // 2. 处理附件关联
    //         if (attachmentData != null && attachmentData.size() > 0) {
    //             List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                
    //             for (Map<String, Object> attachment : attachmentData) {
    //                 String contentDocumentId = (String) attachment.get('contentDocumentId');
    //                 String contentVersionId = (String) attachment.get('contentVersionId');
                    
    //                 if (String.isNotBlank(contentDocumentId)) {
    //                     ContentDocumentLink cdl = new ContentDocumentLink();
    //                     cdl.ContentDocumentId = contentDocumentId;
    //                     cdl.LinkedEntityId = contractDetailData.Id;
    //                     cdl.ShareType = 'V'; // View权限
    //                     cdlList.add(cdl);
    //                 }
    //             }
                
    //             if (cdlList.size() > 0) {
    //                 insert cdlList;
    //             }
    //         }
            
    //         out.isSucess = true;
    //         out.errorMsg = '';
            
    //     } catch (Exception e) {
    //         Database.rollback(sp);
    //         out.isSucess = false;
    //         out.errorMsg = e.getMessage() + ' at line ' + e.getLineNumber();
    //     }
        
    //     return out;
    // }

    public class Output{
        @AuraEnabled
        public Boolean isAR {get;set;}

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public Boolean isBaseQuote {get;set;}

        @AuraEnabled
        public Boolean isEditHqPrice {get;set;}

        @AuraEnabled
        public Boolean isProductUsage {get;set;}
        

        @AuraEnabled
        public String errorMsg {get;set;}

         @AuraEnabled
        public Decimal paymentTermCostRate {get;set;}

        @AuraEnabled
        public Boolean isHQContract {get;set;}

        @AuraEnabled
        public Boolean isCreateOrderItem {get;set;}

        @AuraEnabled
        public List<Option> toxicityList {get;set;}

        @AuraEnabled
        public Boolean isZAR2 {get;set;}

        @AuraEnabled
        public Boolean isMX {get;set;}

        @AuraEnabled
        public Boolean isSaleContract {get;set;}

        @AuraEnabled
        public Map<String,String> unitMap {get; set;}

        @AuraEnabled
        public Map<String,String> productUsageMap {get; set;}

        @AuraEnabled
        public Map<String,String> ifDesignatedProductMap {get; set;}

        @AuraEnabled
        public Map<String,String> ifPalletMap {get; set;}

        @AuraEnabled
        public Map<String,String> recheckMarginMap {get; set;}
        

        @AuraEnabled
        public List<ContractDetail> conDetailList {get;set;}

        @AuraEnabled
        public List<OrderDetail> orderDetailList {get;set;}

        
       

    }

    public class ProductResult{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        @AuraEnabled
        public String commodityId {get;set;}


        @AuraEnabled
        public Decimal price {get;set;}

        @AuraEnabled
        public String productCode {get;set;}

        @AuraEnabled
        public List<Option> proNameList {get;set;}

         @AuraEnabled
        public List<Option> proUnitList {get;set;}

        @AuraEnabled
        public String defaultUnit {get;set;}//产品默认单位

        
       

    }


     public class ContractDetail {

        @AuraEnabled
        public Contracts_Detail__c conDetailData {get;set;}

        @AuraEnabled
        public Decimal price {get;set;}

        @AuraEnabled
        public Integer index {get;set;}

        @AuraEnabled
        public String productEnglishName {get;set;}

        @AuraEnabled
        public String packSizeName {get;set;}

        @AuraEnabled
        public List<Option> proList {get;set;}

        @AuraEnabled
        public List<Option> proNameList {get;set;}

        @AuraEnabled
        public List<Option> proUnitList {get;set;}

        @AuraEnabled
        public List<Attachment__c> fileData {get;set;}
    
    }

     public class OrderDetail {

        @AuraEnabled
        public Order_Item__c ordDetailData {get;set;}

        @AuraEnabled
        public Integer index {get;set;}

        @AuraEnabled
        public String productEnglishName {get;set;}

        @AuraEnabled
        public String packSizeName {get;set;}

        @AuraEnabled
        public List<Option> proList {get;set;}

        @AuraEnabled
        public List<Option> proNameList {get;set;}

        @AuraEnabled
        public List<Option> proUnitList {get;set;}
    
    }

    public class Option {
        @AuraEnabled
        public String label {get;set;}

        @AuraEnabled
        public String value {get;set;}
    }

}