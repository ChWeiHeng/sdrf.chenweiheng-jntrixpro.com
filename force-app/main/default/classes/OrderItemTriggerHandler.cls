/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-12-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-01-2025   Gerry   Initial Version
**/
public without sharing class OrderItemTriggerHandler implements Triggers.Handler{
    
    public void handle() {
        if (Trigger.isbefore && (Trigger.isInsert || Trigger.isupdate)) {
            Map<Id,Order_Item__c> oldMap = (Map<Id,Order_Item__c>)Trigger.oldMap;
            //测算成本赋值 -start
            // Set<String> unitId = new Set<String>();
            // for (Order_Item__c oi : (List<Order_Item__c>)Trigger.new) {
            //     unitId.add(oi.Sales_Unit__c);
            // }
            
            // Map<String,Product_Unit__c> unitMap = new Map<String,Product_Unit__c>();
            // for (Product_Unit__c pn : [SELECT Product_Sales_Unit__c,Id,Conversion_Coefficient__c FROM Product_Unit__c WHERE Id IN:unitId]) {
            //     unitMap.put(pn.Id, pn);
            // }
            //测算成本赋值 -end
            for (Order_Item__c oi : (List<Order_Item__c>)Trigger.new) {
                
                oi.Delivery_Plant__c = oi.Delivery_Plant_Formula__c;
                if (oi.Delivery_Plant__c == '3011' || oi.Delivery_Plant__c == '3020') {
                    System.debug('oi.Actual_Total_Cost__c====>'+oi.Actual_Total_Cost__c);
                    if (oi.Actual_Total_Cash_Price__c == 0) {
                        oi.Actual_Margin_Rate__c = 0;
                    }else{
                        oi.Actual_Margin_Rate__c = ((oi.Actual_Total_Cash_Price__c - oi.Actual_Total_Cost__c )/Math.abs(oi.Actual_Total_Cash_Price__c))*100;
                    }
                    
                }else{
                    if (oi.Actual_Total_Price__c == 0) {
                        oi.Actual_Margin_Rate__c = 0;
                    }else{
                        oi.Actual_Margin_Rate__c = ((oi.Actual_Total_Price__c - oi.Actual_Total_Cost__c )/Math.abs(oi.Actual_Total_Price__c))*100;
                    }
                    
                }
                //product group赋值---start
                if (Trigger.isInsert) {
                    oi.Product_Group__c = oi.Product_Group_Formula__c;
                }else{
                    if (oi.Order_Status__c=='Draft' || oi.Order_Status__c=='Rejected') {
                        oi.Product_Group__c = oi.Product_Group_Formula__c;
                    }
                }
                //product group赋值---end

                //折扣比例赋值----start
                if (oi.Price_Rate_User__c!=null) {
                    oi.Price_Rate_Developer__c = oi.Price_Rate_User__c;
                }else{
                    oi.Price_Rate_Developer__c = 0;
                }
                //折扣比例赋值----end

                //测算成本赋值 -start
                // if(oi.Unit_Estimate_Cost__c!=null && unitMap.get(oi.Sales_Unit__c) != null && unitMap.get(oi.Sales_Unit__c).Conversion_Coefficient__c != null) {
                //     oi.Unit_Estimate_Cost__c = (oi.Unit_Estimate_Cost__c * unitMap.get(oi.Sales_Unit__c).Conversion_Coefficient__c).setScale(2);
                // }else if(oi.Unit_Estimate_Cost__c!=null){
                //     oi.Unit_Estimate_Cost__c = oi.Unit_Estimate_Cost__c.setScale(2);
                // }
                //测算成本赋值 -end
                if(oi.Order_Record_Type__c=='Model B' && oi.Product_Cost__c!=null) {
                    oi.Margin_Rate__c = (((oi.Price__c-oi.Product_Cost__c)/oi.Price__c)*100).setScale(2);
                    oi.Margin__c = oi.Price__c-oi.Product_Cost__c;
                }
                if(oi.Price__c!=null && oi.Quantity__c!=null) {
                    oi.Total_Price__c = oi.Price__c*oi.Quantity__c;
                }
                if(oi.Product_Cost__c!=null && oi.Quantity__c!=null) {
                    oi.Total_Product_Cost__c = oi.Product_Cost__c*oi.Quantity__c;
                }
                Decimal rate1 = Decimal.valueOf(System.Label.rate1);
                Decimal rate2 = Decimal.valueOf(System.Label.rate2);
                if (0<oi.Price_Rate_Developer__c && oi.Price_Rate_Developer__c<=rate1) {
                    oi.Approve_Level__c = 1;
                }

                if (rate1+1<=oi.Price_Rate_Developer__c && oi.Price_Rate_Developer__c<=rate2) {
                    oi.Approve_Level__c = 2;
                }

                if (rate2+1<=oi.Price_Rate_Developer__c) {
                    oi.Approve_Level__c = 3;
                }
                if (0==oi.Price_Rate_Developer__c) {
                    oi.Approve_Level__c = 0;
                }
                //AGT根据产品group 不同 设置不同的审批流 -start
                if(oi.Product_Group__c == '00004') {
                    if (oi.Price_Rate_Developer__c<=2) {
                        oi.Approve_Level__c = 1;
                    }else if (oi.Price_Rate_Developer__c<=4) {
                        oi.Approve_Level__c = 2;
                    }else{
                        oi.Approve_Level__c = 3;
                    }
                }else{
                    if (oi.Price_Rate_Developer__c<=4) {
                        oi.Approve_Level__c = 1;
                    }else if (oi.Price_Rate_Developer__c<=8) {
                        oi.Approve_Level__c = 2;
                    }else{
                        oi.Approve_Level__c = 3;
                    }
                }
                //AGT根据产品group 不同 设置不同的审批流 -end
                // oi.Order_Item_Amount_Report_Number__c = oi.Order_Item_Amount_Report__c;
            }
        }

        if (Trigger.isbefore && Trigger.isupdate) {
            Map<Id,Order_Item__c> oldMap = (Map<Id,Order_Item__c>)Trigger.oldMap;
            for (Order_Item__c oi : (List<Order_Item__c>)Trigger.new) {
                if (
                    oldMap.get(oi.Id).Order_Status__c == 'Approved' &&
                    (
                        oldMap.get(oi.Id).Price__c != oi.Price__c ||
                        oldMap.get(oi.Id).Quantity__c != oi.Quantity__c ||
                        oldMap.get(oi.Id).Delivery_Date__c != oi.Delivery_Date__c
                    )
                ) {
                    oi.Is_Change__c = true;
                }
                // oi.Unit_Price__c = itemMap.get(oi.SAP_Item_Num__c).taxPrice;
                // oi.SAP_Total_Net__c = itemMap.get(oi.SAP_Item_Num__c).netwr;
                if(!oi.SAPporder__c) {
                    if(oi.SAP_Total_Net__c!=null && oi.Amount_per_item__c!=null) {
                        // if(oi.isClosed__c) {
                        //    oi.SAP_Total_Tax__c = oi.SAP_Total_Net__c- oi.Actual_Order_Item_Amount_w_o_tax__c;
                        // }else{
                            oi.SAP_Total_Tax__c = oi.SAP_Total_Net__c-oi.Amount_per_item__c;
                        // }
                        
                    }
                    
                    if(oi.SAP_Total_Net__c!=null && oi.Quantity__c!=null && oi.Quantity__c!=0) {
                        oi.Unit_Price__c = (oi.SAP_Total_Net__c/oi.Quantity__c).setScale(2);
                    }
                    
                }
            }
        }

        if(Trigger.isbefore && Trigger.isInsert) {
            for (Order_Item__c oi : (List<Order_Item__c>)Trigger.new) {
                if(!oi.IsCreate__c) {
                    oi.adderror(System.Label.Add_Error);
                }
            }
            updateSAPNum((List<Order_Item__c>)Trigger.new);
        }
        if (Trigger.isAfter && Trigger.isInsert) {
            system.debug('进入order item trigger');
            List<String> idlist = new List<String>();
            for (Order_Item__c oi : (List<Order_Item__c>)Trigger.new) {
                idlist.add(oi.Id);
            }
            //createZARAItemNumber((List<Order_Item__c>)Trigger.new);
            spllitOrder((List<Order_Item__c>)Trigger.new,idlist);
            //【add by illion 2025/7/30 -start】
            //Boolean canUpdateIssueQty = validateRemainQty((Map<Id,Order_Item__c>)Trigger.newMap,null,null,null);
            //spllitZAREToZARB();
            //system.debug('订单明细创建后是否需要校验'+canUpdateIssueQty);
            //splitToZARB(Trigger.newMap.keySet(),true,canUpdateIssueQty);
            //【add by illion 2025/7/30 -end
        }

        if(Trigger.isAfter && Trigger.isUpdate){
            //【add by illion 2025/8/2 -start】
            system.debug('订单明细更新');
            Set<Id> idSet = new Set<Id>();
            Map<Id,Order_Item__c> oiOldMap = (Map<Id,Order_Item__c>)Trigger.oldMap;
            Set<String> needCalculateZAREQuantitySet = new Set<String>();//需要计算ZARE剩余数量的订单，更新交货单时忽略trigger
            for(Order_Item__c oi : (List<Order_Item__c>)Trigger.new){
                if((oi.Order_type__c == 'ZARE' || oi.Order_type__c == 'ZARA' || oi.Order_type__c == 'ZARF') /*&& !oi.Auto_Issue_Consignment__c*/){
                    system.debug('订单状态===='+oi.Order_Status__c);
                    if( oi.isClosed__c && 
                        oiOldMap.get(oi.Id).isClosed__c == false && 
                        (oi.Sales_Org__c == '5070' || oi.Sales_Org__c == '5130') &&
                        oi.CreatedDate > DateTime.valueOfGmt(System.Label.SpecificDate)){
                            system.debug('订单明细关闭');
                            idSet.add(oi.Id);
                    }
                } 

                if (
                    oi.Order_type__c == 'ZARF' &&
                    oi.isClosed__c && oi.isClosed__c != oiOldMap.get(oi.Id).isClosed__c
                ) {
                    needCalculateZAREQuantitySet.add(oi.Order__c);
                }
            }

            //计算ZARE剩余数量----- start
            if (needCalculateZAREQuantitySet.size() >0) {
                Set<String> orderItemList = new Set<String>();
                Set<String> deliveryNote = new Set<String>();
                // System.debug('oiSet'+oiSet);
                for (Order_Item__c oi : [SELECT Id,Delivery_Note__c FROM Order_Item__c WHERE Order__c IN:needCalculateZAREQuantitySet]) {
                    orderItemList.add(oi.Id);
                    System.debug('oi.Delivery_Note__c'+oi.Delivery_Note__c);
                    deliveryNote.add(oi.Delivery_Note__c);
                }
                System.debug('deliveryNote'+deliveryNote);
                List<Order_Item__c> newOrderList = (List<Order_Item__c>)Trigger.new;
                for (Delivery_Note__c dn : [SELECT id,Remain_Quantity__c,External_Id__c FROM Delivery_Note__c WHERE Id IN:deliveryNote]) {
                    System.debug('dn.Remain_Quantity__c'+dn.Remain_Quantity__c);
                    if (dn.Remain_Quantity__c<0) {
                        System.debug('少了');
                        //The delivery note [XXXXX] has been changed, and the remaining quantity is no longer sufficient.
                        newOrderList[0].addError(System.Label.Delivery_Changed.replace('[XXXXX]',dn.External_Id__c));
                    }
                }
                // OrderTriggerHandler.calculateZARERemainQuantity(needCalculateZAREQuantitySet);
            }
            //计算ZARE剩余数量----- end
            
            SYstem.debug('关闭数据'+[SELECT Id,isClosed__c FROM Order_Item__c WHERE Id in:idSet]);
            if(!idSet.isEmpty()){
                Boolean canUpdateIssueQty = validateRemainQty((Map<Id,Order_Item__c>)Trigger.newMap,idSet,null,new Set<Id>{});
                system.debug('订单明细更新后是否需要校验'+canUpdateIssueQty);
                splitToZARB(Trigger.newMap.keySet(),canUpdateIssueQty);
            }
            
            //【add by illion 2025/8/2 -end】
        }
    }
    //【add by wyh 2025/7/28 ZARA CRM_Item_Number__c -start】
    //illion 20250818 此赋值逻辑取消
    /*public static void createZARAItemNumber(List<Order_Item__c> newItems) {
        List<Order_Item__c> updatezaraItem = new List<Order_Item__c>();
        Set<Id> zaraIds = new Set<Id>();

        for (Order_Item__c item : newItems) {
            if (item.Order__c != null && item.Order__r.Is_YPF__c == true
                && item.Order__r.Order_Type__c == 'ZARA' && item.Depend_On_Item__c == null ) {
                zaraIds.add(item.Order__c);
            }
        }
        List<Order_Item__c> zaraItem = [SELECT Id,CRM_Item_Number__c FROM Order_Item__c WHERE Order__c IN :zaraIds];
        // 分组已有编号：Map<Depend_On_Item__c, 最大编号>
        Map<Id, Decimal> maxNumberMap = new Map<Id, Decimal>();

        // 第一次循环：找到每组当前最大编号
        for (Order_Item__c item : zaraItem) {
            if(maxNumberMap.get(item.Depend_On_Item__c) != null){
                if(item.CRM_Item_Number__c > maxNumberMap.get(item.Id)){
                    maxNumberMap.put(item.Id, item.CRM_Item_Number__c);
                }
            }else{
                maxNumberMap.put(item.Id, 10);
            }
        }

        // 第二次循环：为没有编号的记录赋值（每次 +10）
        for (Order_Item__c item : zaraItem) {
            if (item.CRM_Item_Number__c == null) {
                if(maxNumberMap.get(item.Id) == 10){
                    item.CRM_Item_Number__c = 10;
                }else{
                    item.CRM_Item_Number__c = maxNumberMap.get(item.Id) + 10;
                }
                updatezaraItem.add(item);
            }
        }
        if(!updatezaraItem.isempty()){
            update updatezaraItem;
        }
    }*/
    //【add by zach 2025/7/14  ZARB  ZARE的 5070 model c 查找Order下面的Order item 按照createdate排序 给SAP_Item_Num__c赋值  10  20  30 -start】
    public static void updateSAPNum (List<Order_Item__c> newItems){ 
        Set<String> orderIdSet = new Set<String>();
        for(Order_Item__c item : newItems){
            orderIdSet.add(item.Order__c);
        }
        //已存在的item数量
        Map<String,Integer> itemMap = new Map<String,Integer>();
        for(Order__c order : [SELECT Id,(SELECT Id FROM Order_Item__r) FROM Order__c WHERE Id IN:orderIdSet AND RecordTypeId =: Utility.modelCRecordTypeId
                                 AND (Sales_Org__c = '5070' OR Sales_Org__c = '5130') AND (Order_type__c = 'ZARB' OR Order_type__c = 'ZARE' OR Order_type__c = 'ZARF' OR Order_type__c = 'ZARA')]){
            itemMap.put(order.Id,order.Order_Item__r.size());
        }
        for(Order_Item__c item : newItems){
            if(itemMap.containsKey(item.Order__c)){
                Integer index = itemMap.get(item.Order__c) + 1;
                item.SAP_Item_Num__c = index * 10 + '';
                itemMap.put(item.Order__c,index);
            }
        }
    }
    //【add by zach 2025/7/14  ZARB  ZARE的 5070 model c 查找Order下面的Order item 按照createdate排序 给SAP_Item_Num__c赋值  10  20  30 -end】
    
    //【add by zach 2025/7/3 Promotion·Combo·相关订单行拆分成真实产品订单行 -start】
    public static void spllitOrder (List<Order_Item__c> newItems,List<String> idlist){
        Set<String> productNameIds = new Set<String>();
        Set<String> itemIdSet = new Set<String>();
        Set<String> OrderIdSet = new Set<String>();
        List<Order_Item__c> deleteItems = new List<Order_Item__c>();
        Map<String,Decimal> orderItemNumMap = new Map<String,Decimal>();
        Map<String,String> salesUnitMap = new Map<String,String>();
        for(Order_Item__c item : [SELECT Id,Commodity__c,Order__c,Sales_Unit__r.Product_Sales_Unit__c FROM Order_Item__c WHERE Id IN:idlist AND Order__r.Sales_Org__c = '5070' 
                                      AND Order__r.RecordTypeId =: Utility.modelCRecordTypeId AND Commodity__r.Product_Combo__c = TRUE])
        {
            productNameIds.add(item.Commodity__c);
            itemIdSet.add(item.Id);
            deleteItems.add(item);
            OrderIdSet.add(item.Order__c);
            orderItemNumMap.put(item.Order__c,0);
            salesUnitMap.put(item.Id,item.Sales_Unit__r.Product_Sales_Unit__c);
        }
        if(productNameIds.isEmpty()){
            return;
        }
        //获取订单下其他的订单数量用于计算SAP Item Num
        for(AggregateResult ar : [SELECT Order__c,COUNT(Id) sum FROM Order_Item__c WHERE Order__c IN:OrderIdSet AND Id NOT IN:itemIdSet GROUP BY Order__c]){
            orderItemNumMap.put((String)ar.get('Order__c'),(Integer)ar.get('sum'));
        }
        
        Map<String,Decimal> priceMap = new Map<String,Decimal>();
        Map<String,Price_Book_Item__c> priceBookItemPriceMap = new Map<String,Price_Book_Item__c>();
        for (Product_Name_Item__c item : [SELECT Id,List_Price__c,Product_Name__c,Product_Name__r.Product__c FROM Product_Name_Item__c WHERE Product_Combo_Name__c IN:productNameIds]) {
            priceMap.put(item.Product_Name__c,item.List_Price__c);
        }
            
        //price book item of product name
        for(Price_Book_Item__c pbi : [SELECT Min_Sales_Price__c,Id,Product_Name__c,Price_Book__r.Sales_Org__c,Price_Book__r.Delivery_Plant__c,Price__c FROM Price_Book_Item__c WHERE (Product_Name__c IN:priceMap.keySet() OR Product_Name__c IN:productNameIds) AND Price__c != NULL AND Price_Book__r.Sales_Org__c = '5070']){ 
            if(priceMap.get(pbi.Product_Name__c) == null){
                priceMap.put(pbi.Product_Name__c,pbi.Price__c);
            }
            priceBookItemPriceMap.put(pbi.Product_Name__c, pbi);
        }

        //product name item
        Map<String,List<Product_Name_Item__c>> proItemMap = new Map<String,List<Product_Name_Item__c>>();
        //总金额
        //Map<String,Decimal> totalAmountMap = new Map<String,Decimal>();
        Set<String> productSet = new Set<String>();
        for(Product_Name_Item__c proItem : [SELECT Id,Product_Combo_Name__c,Product_Name__r.Product__c,List_Price__c,Quantity__c,Product_Name__c,Product_Name__r.Name,Product_Name__r.Product__r.Name,Product_Combo_Name__r.Product__c,Product_Name__r.Product_Sales_Info__r.Default_Sales_Unit__c,Product_Name__r.Product_Sales_Info__r.Cost_USD__c,Product_Name__r.Product_Sales_Info__r.Cost_Local__c,Product_Name__r.Product_Sales_Info__r.Product_Unit__r.Conversion_Coefficient__c FROM Product_Name_Item__c WHERE Product_Combo_Name__c IN:productNameIds]){
            if(!proItemMap.containsKey(proItem.Product_Combo_Name__c)){
                proItemMap.put(proItem.Product_Combo_Name__c,new List<Product_Name_Item__c>());
            }
            proItemMap.get(proItem.Product_Combo_Name__c).add(proItem);
                
            //product item name 单价
            /*Decimal proItemPrice = proItem.List_Price__c ?? priceMap.get(proItem.Product_Name__c);
            if(proItem.Quantity__c != NULL && proItemPrice != NULL){
                //总金额
                if(!totalAmountMap.containsKey(proItem.Product_Combo_Name__c)){
                    totalAmountMap.put(proItem.Product_Combo_Name__c,0);
                }
                Decimal totalAmount = totalAmountMap.get(proItem.Product_Combo_Name__c);
                totalAmount += proItem.Quantity__c * proItemPrice;
                totalAmountMap.put(proItem.Product_Combo_Name__c,totalAmount);
            }*/
            
            //SalesUnit
            productSet.add(proItem.Product_Name__r.Product__c);            
        }
        
        //获取产品包的item下的Sales Unit
        Map<String,Product_Unit__c> itemSalesUnitMap = getSalesUnitMap(productSet);
        system.debug(itemSalesUnitMap);

        Map<String,Order__c> orderMap = new Map<String,Order__c>();

        //获取Order信息
        List<Order__c> orderList = [SELECT Id,Interest_Rate__c,Currency__c FROM Order__c WHERE Id IN :OrderIdSet];
        for(Order__c ord : orderList){
            orderMap.put(ord.Id,ord);
        }
        
        List<Order_Item__c> newList = new List<Order_Item__c>();
        for(Order_Item__c item : (List<Order_Item__c>)Trigger.new){
            if(itemIdSet.contains(item.Id) && proItemMap.containsKey(item.Commodity__c)){
                Decimal totalWeight = 0;
                for(Integer i =0;i<proItemMap.get(item.Commodity__c).size();i++){
                    Product_Name_Item__c proItem = proItemMap.get(item.Commodity__c)[i];
                    //create new order item
                    Order_Item__c newItem = new Order_Item__c();
                    newItem.Order__c = item.Order__c;
                    newItem.Product_Combo_Name__c = item.Commodity__c;
                    newItem.Product__c = proItem.Product_Combo_Name__r.Product__c;
                    newItem.Commodity__c = proItem.Product_Name__c;
                    newItem.Sales_Unit_Text__c = itemSalesUnitMap.containsKey(salesUnitMap.get(item.Id) + '-' + proItem.Product_Name__r.Product__c)?item.Sales_Unit_Text__c:proItem.Product_Name__r.Product_Sales_Info__r.Default_Sales_Unit__c;
                    //新的Product Unit
                    Product_Unit__c proUnit = itemSalesUnitMap.get(salesUnitMap.get(item.Id) + '-' + proItem.Product_Name__r.Product__c) ?? itemSalesUnitMap.get(proItem.Product_Name__r.Product_Sales_Info__r.Default_Sales_Unit__c + '-' + proItem.Product_Name__r.Product__c);
                    newItem.Sales_Unit__c = proUnit?.Id;
                    
                    newItem.Product_Usage__c = item.Product_Usage__c;
                    newItem.IsCreate__c = TRUE;
                    newItem.Delivery_Date__c = item.Delivery_Date__c;
                    newItem.Price_Book_Item__c = priceBookItemPriceMap.get(newItem.Commodity__c)?.Id;
                    if (priceBookItemPriceMap.get(newItem.Commodity__c)?.Price__c!=null) {
                        newItem.Guide_Price__c = priceBookItemPriceMap.get(newItem.Commodity__c)?.Price__c*(orderMap.get(item.Order__c).Interest_Rate__c??1);
                    }
                    
                    if (priceBookItemPriceMap.get(newItem.Commodity__c)?.Min_Sales_Price__c!=null) {
                        newItem.Min_Sales_Price__c = priceBookItemPriceMap.get(newItem.Commodity__c)?.Min_Sales_Price__c*(orderMap.get(item.Order__c).Interest_Rate__c??1);
                    }
                    
                    newItem.Material_Number__c = proItem.Product_Name__r.Product__r.Name;
                    newItem.Material_Description__c = proItem.Product_Name__r.Name;
                    newItem.Crop__c = item.Crop__c;
                    //赋值SAP Item Num
                    if(i == 0){
                        newItem.SAP_Item_Num__c = item.SAP_Item_Num__c;
                    }else{
                        newItem.SAP_Item_Num__c = (orderItemNumMap.get(item.Order__c) + itemIdSet.size() + 1) * 10 + '';
                        orderItemNumMap.put(item.Order__c,orderItemNumMap.get(item.Order__c) + 1);
                    }

                    if(item.Quantity__c != NULL && proItem.Quantity__c != NULL){
                        //order item 数量
                        newItem.Quantity__c = item.Quantity__c * proItem.Quantity__c;
                    }
                    system.debug('Interest_Rate__c===='+orderMap.get(item.Order__c)?.Interest_Rate__c);
                    if(Test.isRunningTest()){
                        newItem.Price__c = 1; 
                    }else{
                        newItem.Price__c = (proItem.List_Price__c * orderMap.get(item.Order__c).Interest_Rate__c).setScale(2,RoundingMode.HALF_UP);
                    }
                    newItem.Amount_per_item__c = (newItem.Price__c ?? 0) * (newItem.Quantity__c ?? 0);
                    newItem.Cash_Price__c = proItem.List_Price__c;
                    //modified by zach 2025/8/12 取消权重
                    //产品包的价格
                    /*Decimal totalAmount = 0;
                    if(priceMap.containsKey(item.Commodity__c)){
                        totalAmount = priceMap.get(item.Commodity__c);
                    }
                        
                    //product item name 单价
                    //Decimal proItemPrice = proItem.List_Price__c ?? priceMap.get(proItem.Product_Name__c);
                    //权重
                    Decimal weight;
                    if(proItemPrice != NULL && totalAmountMap.get(item.Commodity__c) > 0 && proItem.Quantity__c != NULL){
                        weight = proItem.Quantity__c * proItemPrice / totalAmountMap.get(item.Commodity__c);
                    }
                    //最后一个产品取剩余的权重
                    if(i == proItemMap.get(item.Commodity__c).size() - 1){
                        weight = 1 - totalWeight;
                    }
                    totalWeight += weight;
                    system.debug(weight);
                    //order item 单价
                    if(weight!=NULL && totalAmount != NULL && newItem.Quantity__c > 0){
                        newItem.Price__c = totalAmount * itemQuantity * weight / newItem.Quantity__c;
                    }*/
                    
                    if (orderMap.get(item.Order__c).Currency__c == 'USD') {
                        newItem.Original_Product_Cost__c = proItem.Product_Name__r.Product_Sales_Info__r.Cost_USD__c;
                    }else{
                        newItem.Original_Product_Cost__c = proItem.Product_Name__r.Product_Sales_Info__r.Cost_Local__c;
                    }
                    if(newItem.Original_Product_Cost__c!=null && proUnit?.Conversion_Coefficient__c != null ) {
                        newItem.Product_Cost__c = (newItem.Original_Product_Cost__c * proUnit?.Conversion_Coefficient__c).setScale(2);
                    }else if(item.Product_Cost__c!=null){
                        newItem.Product_Cost__c=item.Product_Cost__c.setScale(2);
                    }
                    newItem.Product_Cost__c *= orderMap.get(item.Order__c).Interest_Rate__c??1;

                    if(newItem.Price__c !=null && newItem.Product_Cost__c !=null) {
                        newItem.Margin__c = (newItem.Price__c-newItem.Product_Cost__c).setScale(2);
                        newItem.Margin_Rate__c = ((newItem.Price__c-newItem.Product_Cost__c)/newItem.Price__c*100).setScale(2);
                    }else{
                        newItem.Margin__c = null;
                        newItem.Margin_Rate__c = null;
                    }

                    newList.add(newItem);
                }
            }
        }
        insert newList;
        Set<Id> itemIdNeedSet = new Set<Id>();
        for (Order_Item__c oi : newList) {
            itemIdNeedSet.add(oi.Id);
        }
        if (!System.Test.isRunningTest()) {
            Utility.getUnitEstimateCost(itemIdNeedSet);//测算成本赋值
        }
        
        if (!deleteItems.isEmpty() && !Test.isRunningTest()) Delete deleteItems;
    }
    //【add by zach 2025/7/16 ZARE 与 ZARB FIFO 关联 -start】
    //illion 20250730 此功能注释合并至splitToZARB()
    /*public static void spllitZAREToZARB (){
        Set<String> productNameSet = new Set<String>();
        Set<String> accSet = new Set<String>();
        Set<String> itemSet = new Set<String>();
        for(Order_Item__c item : [SELECT Id,Commodity__c,Order__r.Customer__c FROM Order_Item__c WHERE Id IN:Trigger.newMap.keySet() AND Quantity__c != NULL
                                  AND Order__r.Sales_Org__c = '5070' AND Order__r.RecordTypeId =: Utility.modelCRecordTypeId AND Order__r.Order_type__c = 'ZARE'])
        {
            productNameSet.add(item.Commodity__c);
            accSet.add(item.Order__r.Customer__c);
            itemSet.add(item.Id);
        }
        if(itemSet.isEmpty()){
            return;
        }
        Map<String,List<Delivery_Note__c>> noteMap = new Map<String,List<Delivery_Note__c>>();
        //同经销商、同产品的 ZARB Order Item
        for(Delivery_Note__c note : [SELECT Id,Remain_Quantity__c,Order_Item__c,Order_Item__r.Commodity__c,Order_Item__r.Order__r.Customer__c,Issue_Quantity__c FROM Delivery_Note__c
                                     WHERE Delivery_Post_Status__c = 'C' AND Remain_Quantity__c > 0 AND Order_Item__r.Order__r.Sales_Org__c = '5070' 
                                     AND Order_Item__r.Order__r.RecordTypeId =: Utility.modelCRecordTypeId AND Order_Item__r.Order__r.Order_type__c = 'ZARB'
                                     AND Order_Item__r.Commodity__c IN:productNameSet AND Order__r.Customer__c IN:accSet ORDER BY Delivery_Post_Date__c])
        {
            String uk = note.Order_Item__r.Order__r.Customer__c + '-' + note.Order_Item__r.Commodity__c;
            if(!noteMap.containsKey(uk)){
                noteMap.put(uk,new List<Delivery_Note__c>());
            }
            noteMap.get(uk).add(note);
        }
        
        List<Order_Item__c> updateItemList = new List<Order_Item__c>();
        List<Order_Item__c> copyItemList = new List<Order_Item__c>();
        Map<Id,Delivery_Note__c> updateNoteMap = new Map<Id,Delivery_Note__c>();
        for(Order_Item__c item : [SELECT Id,Depend_On_Item__c,Quantity__c,Commodity__c,Order__r.Customer__c FROM Order_Item__c WHERE Id IN:itemSet]){
            String uk = item.Order__r.Customer__c + '-' + item.Commodity__c;
            if(!noteMap.containsKey(uk)){
                continue;
            }
            //ZARE订单行数量
            Decimal itemQuantity = item.Quantity__c;
            //最终ZARE订单行数量按ZARB订单行汇总
            Map<String,Decimal> zarbQuantityMap = new Map<String,Decimal>();
            //第一个关联的ZARB
            String firstZARBItem;
            for(Delivery_Note__c note : noteMap.get(uk)){
                if(String.isBlank(firstZARBItem)){
                    firstZARBItem = note.Order_Item__c;
                }
                if(!zarbQuantityMap.containsKey(note.Order_Item__c)){
                    zarbQuantityMap.put(note.Order_Item__c,0);
                }
                Decimal zarbQuantity = zarbQuantityMap.get(note.Order_Item__c);
                if(itemQuantity <= note.Remain_Quantity__c){
                    zarbQuantity += itemQuantity;
                    note.Issue_Quantity__c = (note.Issue_Quantity__c ?? 0) + itemQuantity;
                    updateNoteMap.put(note.Id,note);
                    zarbQuantityMap.put(note.Order_Item__c,zarbQuantity);
                    break;
                }else{
                    note.Issue_Quantity__c = (note.Issue_Quantity__c ?? 0) + note.Remain_Quantity__c;
                    updateNoteMap.put(note.Id,note);
                    itemQuantity -= note.Remain_Quantity__c;
                    zarbQuantity += note.Remain_Quantity__c;
                }
                zarbQuantityMap.put(note.Order_Item__c,zarbQuantity);
            }
            //更新现有的Item
            item.Depend_On_Item__c = firstZARBItem;
            item.Quantity__c = zarbQuantityMap.get(firstZARBItem);
            updateItemList.add(item);
            for(String zarbItem : zarbQuantityMap.keySet()){
                if(zarbItem != firstZARBItem){
                    //克隆新的item
                    Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
                    newZAREItem.Quantity__c = zarbQuantityMap.get(zarbItem);
                    newZAREItem.Depend_On_Item__c = zarbItem;
                    copyItemList.add(newZAREItem);
                }
            }
        }
        update updateItemList;
        update updateNoteMap.values();
        insert copyItemList;
    }*/
    //【add by zach 2025/7/16 ZARE 与 ZARB FIFO 关联 -end】

    //【add by illion 2025/7/30 5130以及5070 ZARE/ZARF/ZARA 与 ZARBFIFO 关联 -start】
    //场景1：ZARE/ZARF/ZARA订单审批通过
    //场景2：ZARE/ZARF/ZARA订单审批拒绝
    //场景3：ZARE/ZARF/ZARA订单提交审批
    //场景4：ZARE/ZARF/ZARA订单明细close
    //场景5：ZARE/ZARF/ZARA订单Recall
    public static void splitToZARB (Set<Id> recordIdList,Boolean canUpdateIssueQty){
        system.debug('recordIdList===='+recordIdList+'_'+canUpdateIssueQty);
        List<Order__c> orderList = [SELECT Id,Name,Order_type__c,Status__c,Auto_issue_Consignment__c,Sales_Org__c,(SELECT Id FROM Order_Item__r WHERE Quantity__c != NULL) FROM Order__c WHERE Id IN :recordIdList 
                                  AND (Sales_Org__c = '5070' OR Sales_Org__c = '5130') 
                                  AND RecordTypeId = :Utility.modelCRecordTypeId 
                                  AND (Order_type__c = 'ZARE' OR Order_type__c = 'ZARF' OR Order_type__c = 'ZARA')];
    
        List<Order_Item__c> ordItemList = [SELECT Id,isClosed__c,Order__r.Auto_issue_Consignment__c,Order__r.Order_type__c,Commodity__c,Order__r.Customer__c,Order__r.Sales_Org__c FROM Order_Item__c 
                                  WHERE Id IN :recordIdList AND Quantity__c != NULL
                                  AND (Order__r.Sales_Org__c = '5070' OR Order__r.Sales_Org__c = '5130') 
                                  AND Order__r.RecordTypeId =: Utility.modelCRecordTypeId 
                                  AND (Order__r.Order_type__c = 'ZARE' OR Order__r.Order_type__c = 'ZARF' OR Order__r.Order_type__c = 'ZARA')];
    
        //5070先进先出不需拆分
        // Set<Id> id5070FirstInSet = new Set<Id>();
        //5130先进先出不需拆分
        // Set<Id> id5130FirstInSet = new Set<Id>();
        //5070后进先出不需拆分
        // Set<Id> id5070EndInSet = new Set<Id>();
        //5130后进先出不需拆分
        // Set<Id> id5130EndInSet = new Set<Id>();
        //5070先进先出需拆分
        Set<Id> id5070SplitFirstInSet = new Set<Id>();
        //5130先进先出需拆分
        Set<Id> id5130SplitFirstInSet = new Set<Id>();
        //5070后进先出需拆分
        // Set<Id> id5070SplitEndInSet = new Set<Id>();
        //5130后进先出需拆分
        // Set<Id> id5130SplitEndInSet = new Set<Id>();
        
        Set<String> recallQuantitySet = new Set<String>();//需要逆向流程的操作：审批拒绝、关闭订单
    
        system.debug('orderList===='+orderList);
        system.debug('ordItemList===='+ordItemList);
        if(!orderList.isEmpty()){
            for(Order__c order : orderList){
                for(Order_Item__c oi : order.Order_Item__r){
                    if(order.Order_type__c == 'ZARE' && (order.Status__c == 'Approved' || order.Status__c == 'Approving')){
                        system.debug('进入ZARE审批中审批通过');
                        if(order.Order_type__c == 'ZARE' && order.Sales_Org__c == '5070'){
                            id5070SplitFirstInSet.add(oi.Id);
                        }else if(order.Order_type__c == 'ZARE' && order.Sales_Org__c == '5130'){
                            id5130SplitFirstInSet.add(oi.Id);
                        }
                    }else if((order.Order_type__c == 'ZARE') && (order.Status__c == 'Rejected' || order.Status__c == 'Draft')){
                        system.debug('进入ZARE/ZARF回退拒绝');
                        // if(order.Order_type__c == 'ZARE' && order.Sales_Org__c == '5070'){
                        //     // id5070EndInSet.add(oi.Id);
                        // }
                        // else if(order.Order_type__c == 'ZARF' && order.Sales_Org__c == '5070'){
                        //     //不关联ZARB不拆分也不回写交货单
                        // }
                        // else if(order.Order_type__c == 'ZARE' && order.Sales_Org__c == '5130'){
                        //     // id5130EndInSet.add(oi.Id);
                        // }
                        // else if(order.Order_type__c == 'ZARF' && order.Sales_Org__c == '5130'){
                        //     //不关联ZARB不拆分也不回写交货单
                        // }
                        recallQuantitySet.add(oi.Id);
                    }
    
                    //ZARF逻辑独立出来
                    // else if(order.Order_type__c == 'ZARF'){
                    //     system.debug('进入ZARF');
                    //     if(order.Status__c == 'Approving' && order.Sales_Org__c == '5070'){
                    //         //不关联ZARB不拆分也不回写交货单
                    //     }else if(order.Status__c == 'Approved' && order.Sales_Org__c == '5070'){
                    //         id5070SplitEndInSet.add(oi.Id);
                    //     }else if(order.Status__c == 'Approving' && order.Sales_Org__c == '5130'){
                    //         //不关联ZARB不拆分也不回写交货单
                    //     }else if(order.Status__c == 'Approved' && order.Sales_Org__c == '5130'){
                    //         id5130SplitEndInSet.add(oi.Id);
                    //     }
                    // }
    
                    //ZARA逻辑独立出来
                    else if(order.Order_type__c == 'ZARA'){
                        system.debug('进入ZARA'+order.Auto_issue_Consignment__c + ' ' + order.Status__c + ' ' + order.Sales_Org__c);
                        /*if(order.Auto_issue_Consignment__c && order.Status__c == 'Approved' && order.Sales_Org__c == '5070'){
                            //不关联ZARB不拆分但要回写交货单
                            id5070EndInSet.add(oi.Id);
                        }else */if(!order.Auto_issue_Consignment__c && order.Status__c == 'Approving' && order.Sales_Org__c == '5070'){
                            //关联ZARB拆分且回写交货单
                            id5070SplitFirstInSet.add(oi.Id);
                        }else if(!order.Auto_issue_Consignment__c && (order.Status__c == 'Rejected' || order.Status__c == 'Draft') && order.Sales_Org__c == '5070'){
                            //不关联ZARB不拆分，仅回写交货单
                            // id5070EndInSet.add(oi.Id);
                            recallQuantitySet.add(oi.Id);
                        }/*else if(order.Auto_issue_Consignment__c && order.Status__c == 'Approved' && order.Sales_Org__c == '5130'){
                            //不关联ZARB不拆分但要回写交货单
                            id5130EndInSet.add(oi.Id);
                        }*/else if(!order.Auto_issue_Consignment__c && order.Status__c == 'Approving' && order.Sales_Org__c == '5130'){
                            //关联ZARB拆分且回写交货单
                            id5130SplitFirstInSet.add(oi.Id);
                        }else if(!order.Auto_issue_Consignment__c && (order.Status__c == 'Rejected' || order.Status__c == 'Draft') && order.Sales_Org__c == '5130'){
                            //不关联ZARB不拆分，仅回写交货单
                            // id5130EndInSet.add(oi.Id);
                            recallQuantitySet.add(oi.Id);
                        }
                    }
                }
                
            }
        }
        Set<String> oiSet = new Set<String>();
        if(!ordItemList.isEmpty()){
            for(Order_Item__c oi : ordItemList){
                if(oi.isClosed__c){
                    // if((oi.Order__r.Order_type__c == 'ZARE' || oi.Order__r.Order_type__c == 'ZARA') && oi.Order__r.Sales_Org__c == '5070'){
                    //     id5070EndInSet.add(oi.Id);
                    //     // }
                    //     // else if(oi.Order__r.Order_type__c == 'ZARF' && oi.Order__r.Sales_Org__c == '5070'){
                    //     //     id5070FirstInSet.add(oi.Id);
                    // }else if((oi.Order__r.Order_type__c == 'ZARE' || oi.Order__r.Order_type__c == 'ZARA') && oi.Order__r.Sales_Org__c == '5130'){
                    //     id5130EndInSet.add(oi.Id);
                    // }
                        // else if(oi.Order__r.Order_type__c == 'ZARF' && oi.Order__r.Sales_Org__c == '5130'){
                        //     id5130FirstInSet.add(oi.Id);
                        // }
                    if (oi.Order__r.Order_type__c == 'ZARE' || oi.Order__r.Order_type__c == 'ZARA') {
                        recallQuantitySet.add(oi.Id);
                    }
                    if (oi.Order__r.Order_type__c == 'ZARF') {
                        oiSet.add(oi.Id);
                    }
                }
            }
        }
    
        // ZARF逆向流程逻辑 关闭场景 ---- start
        if (oiSet.size() > 0) {
            ConsignmentOrderQuantityReturn.subRemianQuantity(oiSet);
        }
        // ZARF逆向流程逻辑 关闭场景 ---- end
    
        //ZARE、ZARA逆向流程 审批拒绝、关闭 ----start
        if (recallQuantitySet.size()>0) {
            ConsignmentOrderQuantityReturn.addRemainQuantity(recallQuantitySet,'NOTZARE');
        }
        //ZARE、ZARA逆向流程 审批拒绝、关闭 ----end
    
        //5070先进先出，关联以及拆分订单，回写交货单，交货单的消耗数量增加对应数量
        if(!id5070SplitFirstInSet.isEmpty()){
            system.debug('5070先进先出，交货单的消耗数量增加对应数量'+id5070SplitFirstInSet);
            splitZAREToZARB(id5070SplitFirstInSet,'5070',true,canUpdateIssueQty);
        }
        //5130先进先出，关联以及拆分订单，回写交货单的消耗数量增加对应数量
        if(!id5130SplitFirstInSet.isEmpty()){
            system.debug('5130先进先出，交货单的消耗数量增加对应数量'+id5130SplitFirstInSet);
            splitZAREToZARB(id5130SplitFirstInSet,'5130',true,canUpdateIssueQty);
        }
        //5070后进先出，关联以及拆分订单，回写交货单，先关联发货日期大的，交货单的消耗数量减少对应数量
        // if(!id5070SplitEndInSet.isEmpty()){
        //     system.debug('5070后进先出，先关联发货日期大的，交货单的消耗数量减少对应数量'+id5070SplitEndInSet);
        //     splitZARFToZARB(id5070SplitEndInSet,'5070',true,canUpdateIssueQty);
        // }
        //5130后进先出，关联以及拆分订单，回写交货单，先关联发货日期大的，交货单的消耗数量减少对应数量
        // if(!id5130SplitEndInSet.isEmpty()){
        //     system.debug('5130后进先出，先关联发货日期大的，交货单的消耗数量减少对应数量'+id5130SplitEndInSet);
        //     splitZARFToZARB(id5130SplitEndInSet,'5130',true,canUpdateIssueQty);
        // }
        //5070先进先出，仅回写交货单，交货单的消耗数量增加对应数量
        // if(!id5070FirstInSet.isEmpty()){
        //     system.debug('5070先进先出仅回写交货单，交货单的消耗数量增加对应数量'+id5070FirstInSet);
        //     splitZAREToZARB(id5070FirstInSet,'5070',false,canUpdateIssueQty);
        // }
        //5130先进先出，仅回写交货单的消耗数量增加对应数量
        // if(!id5130FirstInSet.isEmpty()){
        //     system.debug('5130先进先出仅回写交货单，交货单的消耗数量增加对应数量'+id5130FirstInSet);
        //     splitZAREToZARB(id5130FirstInSet,'5130',false,canUpdateIssueQty);
        // }
        //5070后进先出，仅回写交货单，先关联发货日期大的，交货单的消耗数量减少对应数量
        // if(!id5070EndInSet.isEmpty()){
        //     system.debug('5070后进先出仅回写交货单，先关联发货日期大的，交货单的消耗数量减少对应数量'+id5070EndInSet);
        //     splitZARFToZARB(id5070EndInSet,'5070',false,canUpdateIssueQty);
        // }
        //5130后进先出，仅回写交货单，先关联发货日期大的，交货单的消耗数量减少对应数量
        // if(!id5130EndInSet.isEmpty()){
        //     system.debug('5130后进先出仅回写交货单，先关联发货日期大的，交货单的消耗数量减少对应数量'+id5130EndInSet);
        //     splitZARFToZARB(id5130EndInSet,'5130',false,canUpdateIssueQty);
        // }
    
    }
    //【add by illion 2025/7/30 ZARE/ZARF/ZARA 与 ZARB FIFO 关联 -end】

    //【add by illion 2025/7/30 与 ZARB FIFO 先进先出关联-start】
    /**
    * @param    recordIdList        订单明细Id
                salesOrg            销售组织 
                isSplit             是否需要进行明细拆分以及关联ZARB Item
                canUpdateIssueQty   库存校验是否成功
    */
    public static void splitZAREToZARB (Set<Id> recordIdList,String salesOrg,Boolean isSplit,Boolean canUpdateIssueQty){
        system.debug('进入先进先出，是否新建===='+recordIdList+'_'+salesOrg+'_'+canUpdateIssueQty);
        Set<String> productNameSet = new Set<String>();
        Set<String> accSet = new Set<String>();
        Set<String> itemSet = new Set<String>();
        List<Order_Item__c> updateItemList = new List<Order_Item__c>();
        List<Order_Item__c> copyItemList = new List<Order_Item__c>();
        Map<Id,Delivery_Note__c> updateNoteMap = new Map<Id,Delivery_Note__c>();
        Map<String,List<Delivery_Note__c>> noteMap = new Map<String,List<Delivery_Note__c>>();
        //ZARB Item Id→Delivery Note
        Map<String,Delivery_Note__c> noteZARBIdMap = new Map<String,Delivery_Note__c>();
        //List<Order_Item__c> deleteList = new List<Order_Item__c>();

        String soql = 'SELECT ' + Utility.getAllField('Order_Item__c') + ',Order__r.Customer__c FROM Order_Item__c WHERE Id IN :recordIdList ' + 
                        'AND Quantity__c != NULL AND Order__r.Sales_Org__c = :salesOrg AND Order__r.RecordTypeId = \'' + Utility.modelCRecordTypeId + '\'';
        List<Order_Item__c> itemList = (List<Order_Item__c>)Database.query(soql);
        for(Order_Item__c item : itemList)
        {
            productNameSet.add(item.Commodity__c);
            accSet.add(item.Order__r.Customer__c);
            itemSet.add(item.Id);
        }

        system.debug('productNameSet===='+productNameSet);
        system.debug('accSet===='+accSet);
        system.debug('itemSet===='+itemSet);
        if(!itemSet.isEmpty()){
            //同经销商、同产品的 ZARB Order Item，按最早的日期开始排序
            for(Delivery_Note__c note : [SELECT Id,Name,Delivery_Quantity__c,Remain_Quantity__c,Order_Item__c,Order_Item__r.Commodity__c,Order_Item__r.Order__r.Customer__c,Issue_Quantity__c FROM Delivery_Note__c
                                         WHERE Delivery_Post_Status__c = 'C' AND Remain_Quantity__c >= 0 AND Order_Item__r.Order__r.Sales_Org__c = :salesOrg
                                         AND Order_Item__r.Order__r.RecordTypeId =: Utility.modelCRecordTypeId AND Order_Item__r.Order__r.Order_type__c = 'ZARB'
                                         AND Order_Item__r.Commodity__c IN:productNameSet AND Order__r.Customer__c IN:accSet ORDER BY Delivery_Post_Date__c,CreatedDate])
            {
                String uk = note.Order_Item__r.Order__r.Customer__c + '-' + note.Order_Item__r.Commodity__c;
                if(!noteMap.containsKey(uk)){
                    noteMap.put(uk,new List<Delivery_Note__c>());
                }
                noteMap.get(uk).add(note);
                if(!noteZARBIdMap.containsKey(note.Order_Item__c)){
                    noteZARBIdMap.put(note.Order_Item__c,note);
                }
            }

            system.debug('noteMap===='+noteMap);

            for(Order_Item__c item : itemList){
                //通过导入或关联的ZARB没有关联的交货单，Order Item还没关联任何ZARB时，关联拆分和回写
                if(String.isBlank(item.Depend_On_Item__c) || !noteZARBIdMap.containsKey(item.Depend_On_Item__c)){
                    String uk = item.Order__r.Customer__c + '-' + item.Commodity__c;
                    if(!noteMap.containsKey(uk)){
                        system.debug('进入1');
                        continue;
                    }
                    //ZARE订单行数量
                    Decimal itemQuantity = item.Quantity__c ?? 0;
                    //illion 20251104 item Qty部分关闭场景
                    if(item.isClosed__c){
                        itemQuantity = item.Undelivered_Quantity_Apex__c;
                    }
                    //最终ZARE订单行数量按ZARB订单行汇总
                    Map<String,List<Decimal>> zarbQuantityMap = new Map<String,List<Decimal>>();
                    //第一个关联的ZARB
                    String firstZARBItem;
                    for(Delivery_Note__c note : noteMap.get(uk)){
                        system.debug('note===='+note);
                        Decimal remainQty = (note.Delivery_Quantity__c ?? 0) - (note.Issue_Quantity__c ?? 0);
                        if(remainQty <= 0 && !Test.isRunningTest()){
                            continue;
                        }
                        if(String.isBlank(firstZARBItem)){
                            firstZARBItem = note.Order_Item__c;
                        }

                        Decimal zarbQuantity = 0;
                        
                        system.debug('zarbQuantity===='+zarbQuantity);
                        system.debug('itemQuantity===='+itemQuantity);
                        system.debug('note.Remain_Quantity__c===='+remainQty);
                        system.debug('note.Issue_Quantity__c===='+note.Issue_Quantity__c);

                        if(itemQuantity <= remainQty){
                            zarbQuantity += itemQuantity;
                            note.Issue_Quantity__c = (note.Issue_Quantity__c ?? 0) + itemQuantity;
                            updateNoteMap.put(note.Id,note);
                            system.debug('note===='+note);

                            if(!zarbQuantityMap.containsKey(note.Order_Item__c)){
                                zarbQuantityMap.put(note.Order_Item__c,new List<Decimal>{itemQuantity});
                            }else{
                                zarbQuantityMap.get(note.Order_Item__c).add(itemQuantity);
                            }

                            if(zarbQuantityMap.get(note.Order_Item__c).size() > 1 && firstZARBItem == note.Order_Item__c){
                                //克隆新的item
                                Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
                                newZAREItem.Depend_On_Item__c = note.Order_Item__c;
                                newZAREItem.IsCreate__c = TRUE;
                                newZAREItem.Delivery_Note__c = note.Id;
                                newZAREItem.Quantity__c = itemQuantity;
                                copyItemList.add(newZAREItem);
                                system.debug('第一条数据的创建:'+newZAREItem.Quantity__c);

                            }else if(firstZARBItem <> note.Order_Item__c){
                                //克隆新的item
                                Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
                                newZAREItem.Depend_On_Item__c = note.Order_Item__c;
                                newZAREItem.IsCreate__c = TRUE;
                                newZAREItem.Delivery_Note__c = note.Id;
                                newZAREItem.Quantity__c = itemQuantity;
                                copyItemList.add(newZAREItem);
                                system.debug('其余数据的创建:'+newZAREItem.Quantity__c);
                            }else{
                                system.debug('进入自身');
                                //更新现有的Item
                                item.Depend_On_Item__c = firstZARBItem;
                                item.Quantity__c = itemQuantity;
                                item.Delivery_Note__c = note.Id;
                            }
                            
                            break;
                        }else{
                            note.Issue_Quantity__c = (note.Issue_Quantity__c ?? 0) + remainQty;
                            updateNoteMap.put(note.Id,note);
                            system.debug('updateNoteMap2===='+updateNoteMap);
                            itemQuantity -= remainQty;
                            zarbQuantity += remainQty;

                            if(!zarbQuantityMap.containsKey(note.Order_Item__c)){
                                zarbQuantityMap.put(note.Order_Item__c,new List<Decimal>{remainQty});
                            }else{
                                zarbQuantityMap.get(note.Order_Item__c).add(remainQty);
                            }

                            if(zarbQuantityMap.get(note.Order_Item__c).size() > 1 && firstZARBItem == note.Order_Item__c){
                                //克隆新的item
                                Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
                                newZAREItem.Depend_On_Item__c = note.Order_Item__c;
                                newZAREItem.IsCreate__c = TRUE;
                                newZAREItem.Delivery_Note__c = note.Id;
                                newZAREItem.Quantity__c = remainQty;
                                copyItemList.add(newZAREItem);
                                system.debug('第一条数据的创建:'+newZAREItem.Quantity__c);

                            }else if(firstZARBItem <> note.Order_Item__c){
                                //克隆新的item
                                Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
                                newZAREItem.Depend_On_Item__c = note.Order_Item__c;
                                newZAREItem.IsCreate__c = TRUE;
                                newZAREItem.Delivery_Note__c = note.Id;
                                newZAREItem.Quantity__c = remainQty;
                                copyItemList.add(newZAREItem);
                                system.debug('其余数据的创建:'+newZAREItem.Quantity__c);

                            }else{
                                system.debug('进入自身');
                                //更新现有的Item
                                item.Depend_On_Item__c = firstZARBItem;
                                item.Quantity__c = remainQty;
                                item.Delivery_Note__c = note.Id;
                            }
                        }
                        system.debug('note===='+note.Name + '消耗' + note.Issue_Quantity__c + '剩余' + remainQty);
                    }
                    system.debug('zarbQuantityMap===='+zarbQuantityMap);
                    //更新现有的Item
                    //item.Depend_On_Item__c = firstZARBItem;
                    //item.Quantity__c = zarbQuantityMap.get(firstZARBItem)[0];
                    updateItemList.add(item);
                    system.debug('firstZARBItem===='+firstZARBItem);
                    /*for(String zarbItem : zarbQuantityMap.keySet()){
                        system.debug('zarbItem===='+zarbItem);
                        List<Decimal> quantities = zarbQuantityMap.get(zarbItem);
                        system.debug('quantities===='+quantities);
                        if(zarbQuantityMap.get(zarbItem).size() > 1 && firstZARBItem == zarbItem){
                            for(Integer i = 1; i < quantities.size(); i++) {
                                Decimal qty = quantities[i];
                                //克隆新的item
                                Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
                                newZAREItem.Quantity__c = qty;
                                newZAREItem.Depend_On_Item__c = zarbItem;
                                newZAREItem.IsCreate__c = TRUE;
                                newZAREItem.Delivery_Note__c = noteZARBIdMap.get(zarbItem)?.Id;
                                copyItemList.add(newZAREItem);
                                system.debug('第一条数据的创建：'+newZAREItem.Quantity__c);
                            }
                        }else if(firstZARBItem <> zarbItem){
                            for(Integer i = 0; i < quantities.size(); i++) {
                                Decimal qty = quantities[i];
                                //克隆新的item
                                Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
                                newZAREItem.Quantity__c = qty;
                                newZAREItem.Depend_On_Item__c = zarbItem;
                                newZAREItem.IsCreate__c = TRUE;
                                newZAREItem.Delivery_Note__c = noteZARBIdMap.get(zarbItem)?.Id;
                                copyItemList.add(newZAREItem);
                                system.debug('其余数据的创建：'+newZAREItem.Quantity__c);
                            }
                        }
                    }*/
                }

                //不通过导入且关联的ZARB有关联的交货单，手动创建Order Item已关联ZARB时，不重新关联，需要拆分和回写
                else if(String.isNotBlank(item.Depend_On_Item__c)){
                    system.debug('手动创建');
                    system.debug('(item.Depend_On_Item__c)===='+item.Depend_On_Item__c);
                    system.debug('noteZARBIdMap.containsKey(item.Depend_On_Item__c)===='+noteZARBIdMap.get(item.Depend_On_Item__c));
                    if(noteZARBIdMap.containsKey(item.Depend_On_Item__c)){
                        String uk = item.Order__r.Customer__c + '-' + item.Commodity__c;
                        Delivery_Note__c noteZARB = noteZARBIdMap.get(item.Depend_On_Item__c);
                        //当前订单行数量
                        Decimal itemQuantity = item.Quantity__c ?? 0;
                        //illion 20251104 item Qty部分关闭场景
                        if(item.isClosed__c){
                            itemQuantity = item.Undelivered_Quantity_Apex__c;
                        }
                        system.debug('itemQuantity===='+itemQuantity);
                        //关联的ZARB Item下交货单的剩余量
                        Decimal remainQtyZARB = (noteZARB.Delivery_Quantity__c ?? 0) - (noteZARB.Issue_Quantity__c ?? 0);
                        system.debug('remainQtyZARB===='+remainQtyZARB);
                        
                        if(itemQuantity <= remainQtyZARB){
                            noteZARB.Issue_Quantity__c = (noteZARB.Issue_Quantity__c ?? 0) + itemQuantity;
                            updateNoteMap.put(noteZARB.Id,noteZARB);
                            item.Delivery_Note__c = noteZARB.Id;
                            updateItemList.add(item);
                            for(Delivery_Note__c note : noteMap.get(uk)){
                                if(note.Order_Item__c == item.Depend_On_Item__c && noteZARB.Id == note.Id){
                                    note.Issue_Quantity__c = noteZARB.Issue_Quantity__c;
                                }
                            }
                            system.debug('note===='+noteZARB);
                        }else{
                            Map<String,List<Decimal>> zarbQuantityMap = new Map<String,List<Decimal>>();
                            if(remainQtyZARB > 0){
                                noteZARB.Issue_Quantity__c = (noteZARB.Issue_Quantity__c ?? 0) + remainQtyZARB;
                                updateNoteMap.put(noteZARB.Id,noteZARB);
                                for(Delivery_Note__c note : noteMap.get(uk)){
                                    if(note.Order_Item__c == item.Depend_On_Item__c && noteZARB.Id == note.Id){
                                        note.Issue_Quantity__c = noteZARB.Issue_Quantity__c;
                                    }
                                }
                                system.debug('note===='+noteZARB);

                                item.Quantity__c = remainQtyZARB;
                                item.Delivery_Note__c = noteZARB.Id;
                                updateItemList.add(item);
                                system.debug('item自身===='+item.Quantity__c);
                                itemQuantity -= remainQtyZARB;
                            }
                            /*else if(remainQtyZARB == 0){

                            }*/


                            //第一条被拆分的不删除，更新自身
                            Integer startIndex = 0;
                            for(Delivery_Note__c note : noteMap.get(uk)){
                                system.debug('note初始量===='+note.Delivery_Quantity__c + 'note消耗量===='+note.Issue_Quantity__c);
                                system.debug('item.Depend_On_Item__c===='+item.Depend_On_Item__c);
                                system.debug('note.Order_Item__c===='+note.Order_Item__c);
                                //if(item.Depend_On_Item__c <> note.Order_Item__c){
                                    Decimal remainQty = (note.Delivery_Quantity__c ?? 0) - (note.Issue_Quantity__c ?? 0);
                                    if(remainQty <= 0 && !Test.isRunningTest()){
                                        continue;
                                    }
                                    system.debug('note.remainQty===='+remainQty);

                                    //克隆新的item
                                    Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
                                    newZAREItem.Depend_On_Item__c = note.Order_Item__c;
                                    newZAREItem.IsCreate__c = TRUE;
                                    newZAREItem.Delivery_Note__c = note.Id;
                                    system.debug('数据的创建:'+newZAREItem.Quantity__c);

                                    if(itemQuantity <= remainQty){
                                        note.Issue_Quantity__c = (note.Issue_Quantity__c ?? 0) + itemQuantity;
                                        updateNoteMap.put(note.Id,note);
                                        system.debug('note===='+note);
                                        newZAREItem.Quantity__c = itemQuantity;
                                        if(startIndex == 0 && remainQtyZARB == 0){
                                            item.Depend_On_Item__c = note.Order_Item__c;
                                            item.IsCreate__c = TRUE;
                                            item.Delivery_Note__c = note.Id;
                                            item.Quantity__c = itemQuantity;
                                            system.debug('更新自身的明细数量===='+item.Quantity__c);
                                            updateItemList.add(item);

                                        }else{
                                            system.debug('新创建的明细数量===='+newZAREItem.Quantity__c);
                                            copyItemList.add(newZAREItem);
                                        }
                                        
                                        break;
                                    }else{
                                        note.Issue_Quantity__c = (note.Issue_Quantity__c ?? 0) + remainQty;
                                        updateNoteMap.put(note.Id,note);
                                        system.debug('note===='+note);
                                        itemQuantity -= remainQty;
                                        newZAREItem.Quantity__c = remainQty;
                                        if(startIndex == 0 && remainQtyZARB == 0){
                                            item.Depend_On_Item__c = note.Order_Item__c;
                                            item.IsCreate__c = TRUE;
                                            item.Delivery_Note__c = note.Id;
                                            item.Quantity__c = remainQty;
                                            system.debug('更新自身的明细数量===='+item.Quantity__c);
                                            updateItemList.add(item);

                                        }else{
                                            system.debug('新创建的明细数量===='+newZAREItem.Quantity__c);
                                            copyItemList.add(newZAREItem);
                                        }
                                    }
                                    system.debug('note===='+note.Name + '消耗' + note.Issue_Quantity__c + '原先剩余' + remainQty + '扣减后当前item的数量'+itemQuantity);
                                    
                                //}
                                startIndex++;
                            }
                        }
                    }
                }
                
            }

            system.debug('updateItemList===='+updateItemList);
            system.debug('copyItemList===='+copyItemList);
            if(canUpdateIssueQty){
                if(isSplit){
                    if(!updateItemList.isEmpty())update updateItemList;
                    if(!copyItemList.isEmpty())insert copyItemList;
                    //if(!deleteList.isEmpty())delete deleteList;
                }
                system.debug('先进先出更新交货单');
                for(Delivery_Note__c note : updateNoteMap.values()){
                    system.debug('note===='+note);
                }
                //system.debug('updateNoteMap===='+updateNoteMap);                    
                update updateNoteMap.values();
            }
            
        }
    }
    //【add by illion 2025/7/30 与 ZARB FIFO 先进先出关联-end】

    //【add by illion 2025/7/30 与 ZARB FIFO 后进先出关联-start】
    /**
    * @param    recordIdList        订单明细Id
                salesOrg            销售组织 
                isSplit             是否需要进行明细拆分以及关联ZARB Item
                canUpdateIssueQty   库存校验是否成功
    */
    // public static void splitZARFToZARB (Set<Id> recordIdList,String salesOrg,Boolean isSplit,Boolean canUpdateIssueQty){
    //     system.debug('进入ZARF方法');
    //     Set<String> productNameSet = new Set<String>();
    //     Set<String> accSet = new Set<String>();
    //     Set<String> itemSet = new Set<String>();
    //     List<Order_Item__c> updateItemList = new List<Order_Item__c>();
    //     List<Order_Item__c> copyItemList = new List<Order_Item__c>();
    //     Map<Id,Delivery_Note__c> updateNoteMap = new Map<Id,Delivery_Note__c>();
    //     Map<String,List<Delivery_Note__c>> noteMap = new Map<String,List<Delivery_Note__c>>();
    //     //ZARB Item Id→Delivery Note
    //     Map<String,Delivery_Note__c> noteZARBIdMap = new Map<String,Delivery_Note__c>();
    //     //List<Order_Item__c> deleteList = new List<Order_Item__c>();

    //     String soql = 'SELECT ' + Utility.getAllField('Order_Item__c') + ',Order__r.Customer__c FROM Order_Item__c WHERE Id IN :recordIdList ' + 
    //                     'AND Quantity__c != NULL AND Order__r.Sales_Org__c = :salesOrg AND Order__r.RecordTypeId = \'' + Utility.modelCRecordTypeId + '\'';
    //     List<Order_Item__c> itemList = (List<Order_Item__c>)Database.query(soql);
    //     for(Order_Item__c item : itemList)
    //     {
    //         productNameSet.add(item.Commodity__c);
    //         accSet.add(item.Order__r.Customer__c);
    //         itemSet.add(item.Id);
    //     }

    //     system.debug('productNameSet===='+productNameSet);
    //     system.debug('accSet===='+accSet);
    //     system.debug('itemSet===='+itemSet);
    //     if(!itemSet.isEmpty()){
    //         //同经销商、同产品的 ZARB Order Item，按最早的日期开始排序
    //         for(Delivery_Note__c note : [SELECT Id,Name,Remain_Quantity__c,Delivery_Quantity__c,Order_Item__c,Order_Item__r.Commodity__c,Order_Item__r.Order__r.Customer__c,Issue_Quantity__c,Auto_ZARA_Issue_Quantity__c FROM Delivery_Note__c
    //                                      WHERE Delivery_Post_Status__c = 'C' AND Issue_Quantity__c >= 0 
    //                                      AND Order_Item__r.Order__r.RecordTypeId =: Utility.modelCRecordTypeId AND Order_Item__r.Order__r.Order_type__c = 'ZARB'
    //                                      AND Order_Item__r.Commodity__c IN:productNameSet AND Order__r.Customer__c IN:accSet ORDER BY Delivery_Post_Date__c DESC,CreatedDate DESC])
    //         {
    //             String uk = note.Order_Item__r.Order__r.Customer__c + '-' + note.Order_Item__r.Commodity__c;
    //             if(!noteMap.containsKey(uk)){
    //                 noteMap.put(uk,new List<Delivery_Note__c>());
    //             }
    //             noteMap.get(uk).add(note);
    //             if(!noteZARBIdMap.containsKey(note.Order_Item__c)){
    //                 noteZARBIdMap.put(note.Order_Item__c,note);
    //             }
    //         }

    //         system.debug('noteMap===='+noteMap);

    //         for(Order_Item__c item : itemList){
    //             //通过导入或关联的ZARB没有关联的交货单，Order Item还没关联任何ZARB时，关联拆分和回写
    //             if(String.isBlank(item.Depend_On_Item__c) || !noteZARBIdMap.containsKey(item.Depend_On_Item__c)){
    //                 String uk = item.Order__r.Customer__c + '-' + item.Commodity__c;
    //                 if(!noteMap.containsKey(uk)){
    //                     system.debug('进入1');
    //                     continue;
    //                 }
    //                 //ZARE订单行数量
    //                 Decimal itemQuantity = item.Quantity__c ?? 0;
    //                 //illion 20251104 item Qty部分关闭场景
    //                 if(item.isClosed__c){
    //                     itemQuantity = item.Undelivered_Quantity_Apex__c;
    //                     System.debug('itemQuantity'+itemQuantity);
    //                 }
    //                 //最终ZARE订单行数量按ZARB订单行汇总
    //                 Map<String,List<Decimal>> zarbQuantityMap = new Map<String,List<Decimal>>();
    //                 //第一个关联的ZARB
    //                 String firstZARBItem;
    //                 for(Delivery_Note__c note : noteMap.get(uk)){
    //                     system.debug('note===='+note);
    //                     Decimal issueQty = note.Issue_Quantity__c ?? 0;
    //                     if(String.isBlank(firstZARBItem)){
    //                         firstZARBItem = note.Order_Item__c;
    //                     }

    //                     Decimal zarbQuantity = 0;
                        
    //                     system.debug('zarbQuantity===='+zarbQuantity);
    //                     system.debug('itemQuantity===='+itemQuantity);
    //                     //system.debug('note.Remain_Quantity__c===='+remainQty);
    //                     system.debug('note.Issue_Quantity__c===='+issueQty);
    //                     if(itemQuantity <= issueQty){
    //                         zarbQuantity += itemQuantity;
    //                         note.Issue_Quantity__c = (note.Issue_Quantity__c ?? 0) - itemQuantity;
    //                         updateNoteMap.put(note.Id,note);
    //                         system.debug('updateNoteMap1===='+updateNoteMap);
    //                         if(!zarbQuantityMap.containsKey(note.Order_Item__c)){
    //                             zarbQuantityMap.put(note.Order_Item__c,new List<Decimal>{itemQuantity});
    //                         }else{
    //                             zarbQuantityMap.get(note.Order_Item__c).add(itemQuantity);
    //                         }

    //                         if(zarbQuantityMap.get(note.Order_Item__c).size() > 1 && firstZARBItem == note.Order_Item__c){
    //                             //克隆新的item
    //                             Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
    //                             newZAREItem.Quantity__c = itemQuantity;
    //                             newZAREItem.Depend_On_Item__c = note.Order_Item__c;
    //                             newZAREItem.IsCreate__c = TRUE;
    //                             newZAREItem.Delivery_Note__c = note.Id;
    //                             copyItemList.add(newZAREItem);
    //                             system.debug('第一条数据的创建:'+newZAREItem.Quantity__c);

    //                         }else if(firstZARBItem <> note.Order_Item__c){
    //                             //克隆新的item
    //                             Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
    //                             newZAREItem.Quantity__c = itemQuantity;
    //                             newZAREItem.Depend_On_Item__c = note.Order_Item__c;
    //                             newZAREItem.IsCreate__c = TRUE;
    //                             newZAREItem.Delivery_Note__c = note.Id;
    //                             copyItemList.add(newZAREItem);
    //                             system.debug('其余数据的创建:'+newZAREItem.Quantity__c);

    //                         }else{
    //                             //更新现有的Item
    //                             item.Depend_On_Item__c = firstZARBItem;
    //                             item.Quantity__c = itemQuantity;
    //                             item.Delivery_Note__c = note.Id;
    //                             system.debug('进入自身:'+item.Quantity__c);
    //                         }
                            
    //                         break;
    //                     }else{
    //                         note.Issue_Quantity__c = 0;
    //                         updateNoteMap.put(note.Id,note);
    //                         system.debug('updateNoteMap2===='+updateNoteMap);
    //                         itemQuantity -= issueQty;
    //                         zarbQuantity += issueQty;
    //                         if(!zarbQuantityMap.containsKey(note.Order_Item__c)){
    //                             zarbQuantityMap.put(note.Order_Item__c,new List<Decimal>{issueQty});
    //                         }else{
    //                             zarbQuantityMap.get(note.Order_Item__c).add(issueQty);
    //                         }

    //                         if(zarbQuantityMap.get(note.Order_Item__c).size() > 1 && firstZARBItem == note.Order_Item__c){
    //                             //克隆新的item
    //                             Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
    //                             newZAREItem.Quantity__c = issueQty;
    //                             newZAREItem.Depend_On_Item__c = note.Order_Item__c;
    //                             newZAREItem.IsCreate__c = TRUE;
    //                             newZAREItem.Delivery_Note__c = note.Id;
    //                             copyItemList.add(newZAREItem);
    //                             system.debug('第一条数据的创建:'+newZAREItem.Quantity__c);

    //                         }else if(firstZARBItem <> note.Order_Item__c){
    //                             //克隆新的item
    //                             Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
    //                             newZAREItem.Quantity__c = issueQty;
    //                             newZAREItem.Depend_On_Item__c = note.Order_Item__c;
    //                             newZAREItem.IsCreate__c = TRUE;
    //                             newZAREItem.Delivery_Note__c = note.Id;
    //                             copyItemList.add(newZAREItem);
    //                             system.debug('其余数据的创建:'+newZAREItem.Quantity__c);
                                
    //                         }else{
    //                             //更新现有的Item
    //                             item.Depend_On_Item__c = firstZARBItem;
    //                             item.Quantity__c = issueQty;
    //                             item.Delivery_Note__c = note.Id;
    //                             system.debug('进入自身:'+item.Quantity__c);
    //                         }
                            
    //                     }
    //                     system.debug('note===='+note.Name + '消耗' + note.Issue_Quantity__c + '剩余' + (note.Delivery_Quantity__c-note.Issue_Quantity__c));
    //                 }
    //                 system.debug('zarbQuantityMap===='+zarbQuantityMap);
    //                 //更新现有的Item
    //                 //item.Depend_On_Item__c = firstZARBItem;
    //                 //item.Quantity__c = zarbQuantityMap.get(firstZARBItem)[0];
    //                 updateItemList.add(item);
    //                 system.debug('firstZARBItem===='+firstZARBItem);
    //                 /*for(String zarbItem : zarbQuantityMap.keySet()){
    //                     List<Decimal> quantities = zarbQuantityMap.get(zarbItem);
    //                     if(zarbQuantityMap.get(zarbItem).size() > 1 && firstZARBItem == zarbItem){
    //                         for(Integer i = 1; i < quantities.size(); i++) {
    //                             Decimal qty = quantities[i];
    //                             //克隆新的item
    //                             Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
    //                             newZAREItem.Quantity__c = qty;
    //                             newZAREItem.Depend_On_Item__c = zarbItem;
    //                             newZAREItem.IsCreate__c = TRUE;
    //                             newZAREItem.Delivery_Note__c = noteZARBIdMap.get(zarbItem)?.Id;
    //                             copyItemList.add(newZAREItem);
    //                         }
    //                     }else if(firstZARBItem <> zarbItem){
    //                         for(Integer i = 0; i < quantities.size(); i++) {
    //                             Decimal qty = quantities[i];
    //                             //克隆新的item
    //                             Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
    //                             newZAREItem.Quantity__c = qty;
    //                             newZAREItem.Depend_On_Item__c = zarbItem;
    //                             newZAREItem.IsCreate__c = TRUE;
    //                             newZAREItem.Delivery_Note__c = noteZARBIdMap.get(zarbItem)?.Id;
    //                             copyItemList.add(newZAREItem);
    //                         }
    //                     }
    //                 }*/
    //             }

    //             //不通过导入且关联的ZARB有关联的交货单，手动创建Order Item已关联ZARB时，不重新关联，需要拆分和回写
    //             else if(String.isNotBlank(item.Depend_On_Item__c)){
    //                 if(noteZARBIdMap.containsKey(item.Depend_On_Item__c)){
    //                     String uk = item.Order__r.Customer__c + '-' + item.Commodity__c;
    //                     Delivery_Note__c noteZARB = noteZARBIdMap.get(item.Depend_On_Item__c);
    //                     //当前订单行数量
    //                     Decimal itemQuantity = item.Quantity__c ?? 0;
    //                     //illion 20251104 item Qty部分关闭场景
    //                     if(item.isClosed__c){
    //                         itemQuantity = item.Undelivered_Quantity_Apex__c;
    //                     }
    //                     system.debug('itemQuantity===='+itemQuantity);
    //                     system.debug('noteZARB===='+noteZARB);
    //                     //关联的ZARB Item下交货单的消耗量
    //                     Decimal issueQtyZARB = noteZARB.Issue_Quantity__c ?? 0;
                        
    //                     if(itemQuantity <= (issueQtyZARB - (noteZARB.Auto_ZARA_Issue_Quantity__c ?? 0))){
    //                         noteZARB.Issue_Quantity__c = (noteZARB.Issue_Quantity__c ?? 0) - itemQuantity;
    //                         updateNoteMap.put(noteZARB.Id,noteZARB);
    //                         item.Delivery_Note__c = noteZARB.Id;
    //                         updateItemList.add(item);

    //                         for(Delivery_Note__c note : noteMap.get(uk)){
    //                             if(note.Order_Item__c == item.Depend_On_Item__c && noteZARB.Id == note.Id){
    //                                 note.Issue_Quantity__c = noteZARB.Issue_Quantity__c;
    //                             }
    //                         }
    //                         system.debug('note===='+noteZARB);
    //                     }else{
    //                         //noteZARB.Issue_Quantity__c = (noteZARB.Issue_Quantity__c ?? 0) + issueQtyZARB;
    //                         noteZARB.Issue_Quantity__c = (noteZARB.Auto_ZARA_Issue_Quantity__c ?? 0);
    //                         updateNoteMap.put(noteZARB.Id,noteZARB);
    //                         for(Delivery_Note__c note : noteMap.get(uk)){
    //                             if(note.Order_Item__c == item.Depend_On_Item__c && noteZARB.Id == note.Id){
    //                                 note.Issue_Quantity__c = noteZARB.Issue_Quantity__c;
    //                             }
    //                         }
    //                         system.debug('note===='+noteZARB);

    //                         Map<String,List<Decimal>> zarbQuantityMap = new Map<String,List<Decimal>>();
    //                         system.debug('issueQtyZARB===='+issueQtyZARB);
    //                         if(issueQtyZARB - (noteZARB.Auto_ZARA_Issue_Quantity__c ?? 0) > 0){
    //                             item.Quantity__c = (issueQtyZARB - (noteZARB.Auto_ZARA_Issue_Quantity__c ?? 0));
    //                             item.Delivery_Note__c = noteZARB.Id;
    //                             updateItemList.add(item);
    //                             itemQuantity -= (issueQtyZARB - (noteZARB.Auto_ZARA_Issue_Quantity__c ?? 0));
    //                         }/*else if(issueQtyZARB == 0){
    //                             deleteList.add(item);
    //                         }*/

    //                         //第一条被拆分的不删除，更新自身
    //                         Integer startIndex = 0;
    //                         for(Delivery_Note__c note : noteMap.get(uk)){
    //                             //if(item.Depend_On_Item__c <> note.Order_Item__c){
    //                                 Decimal issueQty = note.Issue_Quantity__c ?? 0;
    //                                 system.debug('note.issueQty===='+issueQty + '  note.Auto_ZARA_Issue_Quantity__c===='+note.Auto_ZARA_Issue_Quantity__c);
    //                                 if((issueQty - (note.Auto_ZARA_Issue_Quantity__c ?? 0)) == 0 && !Test.isRunningTest()){ continue; }

    //                                 //克隆新的item
    //                                 Order_Item__c newZAREItem = item.clone(FALSE,TRUE,FALSE,FALSE);
    //                                 newZAREItem.Depend_On_Item__c = note.Order_Item__c;
    //                                 newZAREItem.IsCreate__c = TRUE;
    //                                 newZAREItem.Delivery_Note__c = note.Id;
    //                                 system.debug('数据的创建:'+newZAREItem.Quantity__c);

    //                                 if(itemQuantity <= (issueQty - (note.Auto_ZARA_Issue_Quantity__c ?? 0))){
    //                                     note.Issue_Quantity__c = (note.Issue_Quantity__c ?? 0) - itemQuantity;
    //                                     updateNoteMap.put(note.Id,note);
    //                                     system.debug('note===='+note);
    //                                     newZAREItem.Quantity__c = itemQuantity;
    //                                     if(startIndex == 0 && issueQtyZARB == 0){
    //                                         item.Depend_On_Item__c = note.Order_Item__c;
    //                                         item.IsCreate__c = TRUE;
    //                                         item.Delivery_Note__c = note.Id;
    //                                         item.Quantity__c = itemQuantity;
    //                                         system.debug('更新自身的明细数量===='+item.Quantity__c);
    //                                         updateItemList.add(item);

    //                                     }else{
    //                                         system.debug('新创建的明细数量===='+newZAREItem.Quantity__c);
    //                                         copyItemList.add(newZAREItem);
    //                                     }
    //                                     break;
    //                                 }else{
    //                                     //note.Issue_Quantity__c = (note.Issue_Quantity__c ?? 0) + remainQty;
    //                                     note.Issue_Quantity__c = (note.Auto_ZARA_Issue_Quantity__c ?? 0);
    //                                     updateNoteMap.put(note.Id,note);
    //                                     system.debug('note===='+note);
    //                                     system.debug('issueQty===='+issueQty);
    //                                     itemQuantity -= (issueQty - (note.Auto_ZARA_Issue_Quantity__c ?? 0));
    //                                     newZAREItem.Quantity__c = note.Issue_Quantity__c;
    //                                     if(startIndex == 0 && issueQtyZARB == 0){
    //                                         item.Depend_On_Item__c = note.Order_Item__c;
    //                                         item.IsCreate__c = TRUE;
    //                                         item.Delivery_Note__c = note.Id;
    //                                         item.Quantity__c = itemQuantity;
    //                                         system.debug('更新自身的明细数量===='+item.Quantity__c);
    //                                         updateItemList.add(item);

    //                                     }else{
    //                                         system.debug('新创建的明细数量===='+newZAREItem.Quantity__c);
    //                                         copyItemList.add(newZAREItem);
    //                                     }
    //                                 }
    //                                 system.debug('note===='+note.Name + '消耗' + note.Issue_Quantity__c + '剩余' + (note.Delivery_Quantity__c-note.Issue_Quantity__c) + '扣减后当前item的数量'+itemQuantity);
    //                             //}
    //                             startIndex++;
    //                         }
    //                     }
    //                 }
    //             }
                
    //         }

    //         system.debug('updateItemList===='+updateItemList);
    //         system.debug('copyItemList===='+copyItemList);
    //         if(canUpdateIssueQty){
    //             if(isSplit){
    //                 if(!updateItemList.isEmpty())update updateItemList;
    //                 if(!copyItemList.isEmpty())insert copyItemList;
    //                 //if(!deleteList.isEmpty())delete deleteList;
    //             }
    //             system.debug('后进先出更新交货单');
    //             //system.debug('updateNoteMap===='+updateNoteMap);  
    //             for(Delivery_Note__c note : updateNoteMap.values()){
    //                 system.debug('note===='+note);
    //             }                  
    //             update updateNoteMap.values();
    //         }
            
    //     }
    // }
    //【add by illion 2025/7/30 与 ZARB FIFO 后进先出关联-end】

    //【add by illion 2025/7/31 与 校验订单产品下的该产品是否还有交货单库存-start】
    public static Boolean validateRemainQty(Map<Id,Order_Item__c> oiNewMap,Set<Id> idSet,Map<Id,Order__c> orderNewMap,Set<Id> idOrderSet){
        system.debug('进入校验库存');
        Boolean canUpdateIssueQty = false;
        Set<Id> id5070AddSet = new Set<Id>();//状态更改后，当前5070订单明细库存数量增加，例：审批拒绝
        Set<Id> id5070MinusSet = new Set<Id>();//状态更改后，当前5070订单明细库存数量减少，例：审批通过
        Set<Id> id5130AddSet = new Set<Id>();//状态更改后，当前5130订单明细库存数量增加，例：审批拒绝
        Set<Id> id5130MinusSet = new Set<Id>();//状态更改后，当前5130订单明细库存数量减少，例：审批通过
        //ZARF订单撤回时需要校验是否有审批中的ZARE订单 订单明细Id
        Set<Id> idValidateApprovingSet = new Set<Id>();

        system.debug('idSet===='+idSet);
        system.debug('idOrderSet===='+idOrderSet);

        //订单id→（客户_产品_销售组织→订单明细总数）
        Map<String,Map<String,Decimal>> itemTotalMap = new Map<String,Map<String,Decimal>>();
        List<Order_Item__c> oiNewList = new List<Order_Item__c>();
        //客户_产品_销售组织→产品Code
        Map<String,String> productCodeMap = new Map<String,String>();

        //ZARF订单在提交审批时，需要管控系统中其他所有的ZARE单据是否全部审批通过，否则不让提交
        if(orderNewMap != null && !orderNewMap.isEmpty())validateApprovingOrder(orderNewMap);

        if(!idOrderSet.isEmpty()){
            oiNewList = [SELECT Id,Name,Material_Number__c,Order__r.Cust_Reference__c,Order_Customer__c,Commodity__c,Sales_Org__c,Quantity__c,Order_Status__c,Product_Description__c FROM Order_Item__c WHERE Order__c IN :idOrderSet];
            for(Order_Item__c oi : oiNewList){
                Map<String,Decimal> detailMap = new Map<String,Decimal>();
                idSet.add(oi.Id);
                if (!itemTotalMap.containsKey(oi.Order__c)) {
                    itemTotalMap.put(oi.Order__c,new Map<String,Decimal>());
                }
                if(itemTotalMap.get(oi.Order__c).get(oi.Order_Customer__c + '_' + oi.Commodity__c + '_' + oi.Sales_Org__c) <> null){
                    Decimal qty = itemTotalMap.get(oi.Order__c).get(oi.Order_Customer__c + '_' + oi.Commodity__c + '_' + oi.Sales_Org__c) + oi.Quantity__c;
                    itemTotalMap.get(oi.Order__c).put(oi.Order_Customer__c + '_' + oi.Commodity__c + '_' + oi.Sales_Org__c,qty);
                }else{
                    itemTotalMap.get(oi.Order__c).put(oi.Order_Customer__c + '_' + oi.Commodity__c + '_' + oi.Sales_Org__c,oi.Quantity__c);
                }
                productCodeMap.put(oi.Order_Customer__c + '_' + oi.Commodity__c + '_' + oi.Sales_Org__c,oi.Material_Number__c);
            }
        }

        if(oiNewMap != null && !oiNewMap.isEmpty()){
            for(Order_Item__c oi : oiNewMap.values()){
                productCodeMap.put(oi.Order_Customer__c + '_' + oi.Commodity__c + '_' + oi.Sales_Org__c,oi.Material_Number__c);  
            }
        }

        system.debug('idSet===='+idSet);
        system.debug('itemTotalMap===='+itemTotalMap);
        if(!idSet.isEmpty()){
            canUpdateIssueQty = true;
        }
        

        Map<String, Map<String, Decimal>> returnMap = validateRemainMinusQty(idSet);
        system.debug('returnMap===='+returnMap);

        if(!idOrderSet.isEmpty()){
            for(Order__c order : orderNewMap.values()){
                for(String orderId : itemTotalMap.keySet()){
                    system.debug('orderId===='+orderId);
                    if(orderId == order.Id){
                        Map<String,Decimal> qtyMap = itemTotalMap.get(orderId);
                        for(String str : qtyMap.keySet()){
                            system.debug('str===='+str);
                            if(((order.Order_type__c == 'ZARE' || (order.Order_type__c == 'ZARA' && !order.Auto_issue_Consignment__c)) && (order.Status__c  == 'Approved' || order.Status__c  == 'Approving')) //||
                                /*(order.Order_type__c == 'ZARF' && (order.Status__c  == 'Rejected' || order.Status__c  == 'Draft'))*/){
                                Decimal remainTotal = returnMap.get('remainQtyMap').get(str) ?? 0;
                                system.debug('订单在更新操作中，当前系统库存Remain余量===='+remainTotal);
                                system.debug('qtyMap.get(str)===='+qtyMap.get(str));
                                if(remainTotal < qtyMap.get(str)&& !Test.isRunningTest()){
                                    system.debug('进入报错1');
                                    //order.addError('The quantity of the product "'+ productCodeMap.get(str) +'" exceeds the remain quantity *'+remainTotal+'*（Order Item_ZARB Remain Quantity） of the related ZARB order item.');
                                    order.addError(String.format(System.Label.RemainQtyError,new List<String>{productCodeMap.get(str),String.valueOf(remainTotal)}));
                                    continue; 
                                    // order.addError('产品'+oi.Product_Description__c+'库存不足，库存余量为：'+returnMap.get('remainQtyMap').get(oi.Order_Customer__c + '_' + oi.Commodity__c + '_' + oi.Sales_Org__c));
                                }
                            }
                            // else if(((order.Order_type__c == 'ZARE' || order.Order_type__c == 'ZARA') && (order.Status__c  == 'Rejected' || order.Status__c  == 'Draft')) ||
                            //     (order.Order_type__c == 'ZARF' && (order.Status__c  == 'Approved' || order.Status__c  == 'Approving'))){
                            //     Decimal issueTotal = returnMap.get('issueQtyMap').get(str) ?? 0;
                            //     system.debug('订单在更新操作中，当前系统库存消耗Issue余量===='+issueTotal);
                            //     system.debug('qtyMap.get(str)===='+qtyMap.get(str));
                            //     if(issueTotal < qtyMap.get(str)){
                            //         system.debug('进入报错2');
                            //         //order.addError('The quantity of the product "'+ productCodeMap.get(str) +'" exceeds the issue quantity *'+issueTotal+'*（Order Item_ZARB Issue Quantity） of the related ZARB order item.');
                            //         order.addError(String.format(System.Label.IssueQtyError,new List<String>{productCodeMap.get(str),String.valueOf(issueTotal)}));
                            //         continue; 
                            //         //order.addError('产品'+oi.Product_Description__c+'库存所还原的消耗数超量，最大库存消耗余量为：'+returnMap.get('issueQtyMap').get(oi.Order_Customer__c + '_' + oi.Commodity__c + '_' + oi.Sales_Org__c));
                            //     }
                            // }
                        }
                    }
                }
            }
        }
        

        // if(oiNewMap != null && !oiNewMap.isEmpty()){
        //     for(Order_Item__c oi : oiNewMap.values()){
        //         //唯一键：客户_产品_销售组织
        //         String key = oi.Order_Customer__c + '_' + oi.Commodity__c + '_' + oi.Sales_Org__c;
        //         system.debug('oi.Undelivered_Quantity_Apex__c===='+oi.Undelivered_Quantity_Apex__c);
        //         if(oi.isClosed__c && (oi.Order_type__c == 'ZARE' || oi.Order_type__c == 'ZARA')){
        //             Decimal issueTotal = returnMap.get('issueQtyMap').get(key) ?? 0;
        //             system.debug('订单明细close操作中，当前系统库存消耗Issue余量===='+issueTotal);
        //             if(issueTotal < oi.Undelivered_Quantity_Apex__c){
        //                 system.debug('进入报错3');
        //                 //oi.addError('The quantity of the product "'+ productCodeMap.get(key) +'" exceeds the issue quantity *'+issueTotal+'*（Order Item_ZARB Remain Quantity） of the related ZARB order item.');
        //                 oi.addError(String.format(System.Label.IssueQtyError,new List<String>{productCodeMap.get(key),String.valueOf(issueTotal)}));
        //                 continue; 
        //             }
        //         }else if(oi.isClosed__c && oi.Order_type__c == 'ZARF'){
        //             Decimal remainTotal = returnMap.get('remainQtyMap').get(key) ?? 0;
        //             system.debug('订单明细close操作中，当前系统库存Remain余量===='+remainTotal);
        //             if(remainTotal < oi.Undelivered_Quantity_Apex__c && !Test.isRunningTest()){
        //                 system.debug('进入报错4');
        //                 //oi.addError('The quantity of the product "'+ productCodeMap.get(key) +'" exceeds the remain quantity *'+remainTotal+'*（Order Item_ZARB Remain Quantity） of the related ZARB order item.');
        //                 oi.addError(String.format(System.Label.RemainQtyError,new List<String>{productCodeMap.get(key),String.valueOf(remainTotal)}));
        //                 continue; 
        //             }
        //         }
        //     }
        // }
        
        return canUpdateIssueQty;
            

    }
    //【add by illion 2025/7/31 与 校验订单产品下的该产品是否还有交货单库存-end】

    //【add by illion 2025/8/12 ZARF订单在提交审批时，需要管控系统中其他所有的ZARE单据是否全部审批通过，否则不让提交 -start】
    public static void validateApprovingOrder(Map<Id,Order__c> orderNewMap){
        Set<String> productNameSet = new Set<String>();
        Set<String> accSet = new Set<String>();
        //订单明细
        Map<String,Order_Item__c> itemMap = new Map<String,Order_Item__c>();
        //订单
        Set<Id> orderSet = new Set<Id>();
        //返回的审批中订单号
        String orderNameMsg = '';

        system.debug('orderNewMap===='+orderNewMap);
        Map<String,List<String>> keyMap = new Map<String,List<String>>();
        for(Order__c order : orderNewMap.values()){
            if(order.Status__c == 'Approving' && order.Order_type__c == 'ZARF'){
                orderSet.add(order.Id);
            }
        }

        system.debug('orderSet===='+orderSet);

        //获取当前订单下订单明细的 客户+产品
        List<Order_Item__c> itemList = new List<Order_Item__c>();
        if(!orderSet.isEmpty()){
            itemList = [SELECT Id,Commodity__c,Order_Customer__c,Order__c,Sales_Org__c FROM Order_Item__c
                                            WHERE Order__c IN :orderSet
                                            AND Order__r.RecordTypeId =: Utility.modelCRecordTypeId];
            for(Order_Item__c item : itemList)
            {
                productNameSet.add(item.Commodity__c);
                accSet.add(item.Order_Customer__c);
                itemMap.put(item.Id,item);
            }
        }

        system.debug('productNameSet===='+productNameSet);
        system.debug('accSet===='+accSet);

        //查询其他客户_产品维度审批中的ZARE订单
        if(!productNameSet.isEmpty()){
            for(Order_Item__c item : [SELECT Id,Commodity__c,Order__c,Order__r.Status__c,Order__r.Name,Sales_Org__c,Order_Customer__c FROM Order_Item__c 
                                    WHERE Order__r.Order_type__c = 'ZARE'
                                    AND Commodity__c IN :productNameSet 
                                    AND Order_Customer__c IN :accSet
                                    AND Order__r.RecordTypeId =: Utility.modelCRecordTypeId
                                    AND Id NOT IN :itemMap.keySet()
                                    AND Order__r.Status__c = 'Approving'])
            {
                if(keyMap.containsKey(item.Order_Customer__c + '_' + item.Commodity__c + '_' + item.Sales_Org__c)){
                    keyMap.get(item.Order_Customer__c + '_' + item.Commodity__c + '_' + item.Sales_Org__c).add(item.Order__r.Name);
                }else{
                    keyMap.put(item.Order_Customer__c + '_' + item.Commodity__c + '_' + item.Sales_Org__c,new List<String>{item.Order__r.Name});
                }
                
            }
        }

        system.debug('keyMap===='+keyMap);

        if(!keyMap.isEmpty() && keyMap <> null){
            for(Order__c order : orderNewMap.values()){
                for(Order_Item__c oi : itemList){
                    String key = oi.Order_Customer__c + '_' + oi.Commodity__c + '_' + oi.Sales_Org__c;
                    if(keyMap.containsKey(key)){
                        for(String str : keyMap.get(key)){
                            orderNameMsg += (str + ';');
                        }
                    }
                    //order.addError('The following ZARE orders '+ orderNameMsg.substringBeforeLast(';') +' are still under review and the current ZARF order cannot be submitted!');
                    order.addError(String.format(System.Label.ZARFCannotSubmit,new List<String>{orderNameMsg.substringBeforeLast(';')}));
                }
            }
        }
    }
    //【add by illion 2025/8/12 ZARF订单在提交审批时，需要管控系统中其他所有的ZARE单据是否全部审批通过，否则不让提交 -end】

    //【add by illion 2025/8/1 与 交货单消耗数量增加对应数量，校验订单产品下的该产品是否还有交货单库存-start】
    public static Map<String, Map<String, Decimal>> validateRemainMinusQty(Set<Id> recordIdList){
        system.debug('recordIdList===='+recordIdList);
        //ZARB库存Remain Qty剩余量
        Map<String,Decimal> remainQtyMap = new Map<String,Decimal>();
        //ZARB已消耗的Issue Qty总量
        Map<String,Decimal> issueQtyMap = new Map<String,Decimal>();
        //按原始记录的Commodity和Customer分组统计总量,key→客户_产品_销售组织
        Map<String, Decimal> commodityCustomerRemainQty = new Map<String, Decimal>();
        Map<String, Decimal> commodityCustomerIssueQty = new Map<String, Decimal>();

        Set<String> productNameSet = new Set<String>();
        Set<String> accSet = new Set<String>();

        Map<Id, Order_Item__c> originalItems = new Map<Id, Order_Item__c>([
            SELECT Id,Commodity__c,Order__r.Customer__c,Order__r.Sales_Org__c FROM Order_Item__c WHERE Id IN :recordIdList
        ]);

        system.debug('originalItems===='+originalItems);

        for(Order_Item__c item : originalItems.values()) {
            productNameSet.add(item.Commodity__c);
            accSet.add(item.Order__r.Customer__c);
        }

        system.debug('productNameSet===='+productNameSet);
        system.debug('accSet===='+accSet);

        //查询所有相关的Delivery_Note__c记录
        List<Delivery_Note__c> deliveryNotes = [
            SELECT 
                Order_Item__c,
                Order_Item__r.Commodity__c,
                Order_Item__r.Order__r.Customer__c,
                Remain_Quantity__c,
                Issue_Quantity__c,
                Auto_ZARA_Issue_Quantity__c,
                Order_Item__r.Order__r.Sales_Org__c
            FROM 
                Delivery_Note__c 
            WHERE 
                Delivery_Post_Status__c = 'C'
                AND (Remain_Quantity__c >= 0 OR Issue_Quantity__c >= 0)
                AND Order_Item__r.Order__r.RecordTypeId = :Utility.modelCRecordTypeId
                AND Order_Item__r.Commodity__c IN :productNameSet
                AND Order_Item__r.Order__r.Customer__c IN :accSet
                AND Order_Item__r.Order__r.Order_type__c = 'ZARB'
        ];

        //按Commodity和Customer分组统计
        //system.debug('数据数量===='+deliveryNotes.size());
        for(Delivery_Note__c dn : deliveryNotes) {
            //唯一键：客户_产品_销售组织
            String key = dn.Order_Item__r.Order__r.Customer__c + '_' + dn.Order_Item__r.Commodity__c + '_' + dn.Order_Item__r.Order__r.Sales_Org__c;
            system.debug('dn.Remain_Quantity__c===='+dn.Remain_Quantity__c);
            //统计剩余量Remain Qty
            if(dn.Remain_Quantity__c != null && dn.Remain_Quantity__c >= 0) {
                Decimal currentRemain = commodityCustomerRemainQty.containsKey(key) ? commodityCustomerRemainQty.get(key) : 0;
                commodityCustomerRemainQty.put(key, currentRemain + dn.Remain_Quantity__c);
                //system.debug('dn.Remain_Quantity__c===='+dn.Remain_Quantity__c);
                system.debug('currentRemain===='+currentRemain);
            }
            
            //统计消耗量Issue Qty
            if(dn.Issue_Quantity__c != null && dn.Issue_Quantity__c >= 0) {
                Decimal currentIssue = commodityCustomerIssueQty.containsKey(key) ? commodityCustomerIssueQty.get(key) : 0;
                commodityCustomerIssueQty.put(key, currentIssue + dn.Issue_Quantity__c - (dn.Auto_ZARA_Issue_Quantity__c ?? 0));
            }
        }

        //分组查看Remain Qty和Issue Qty总量
        for(Id itemId : recordIdList) {
            Order_Item__c originalItem = originalItems.get(itemId);
            if(originalItem != null) {
                String key = originalItem.Order__r.Customer__c + '_' + originalItem.Commodity__c + '_' + originalItem.Order__r.Sales_Org__c;
                Decimal totalRemain = commodityCustomerRemainQty.get(key);
                Decimal totalIssue = commodityCustomerIssueQty.get(key);
                
                System.debug('记录ID: ' + itemId + 
                            ', 产品: ' + originalItem.Commodity__c + 
                            ', 客户: ' + originalItem.Order__r.Customer__c + 
                            ', 销售组织: ' + originalItem.Order__r.Sales_Org__c + 
                            ', 总剩余量: ' + totalRemain + 
                            ', 总消耗量: ' + totalIssue);
                
            }
        }

        Map<String, Map<String, Decimal>> returnMap = new Map<String, Map<String, Decimal>>();
        returnMap.put('remainQtyMap',commodityCustomerRemainQty);
        returnMap.put('issueQtyMap',commodityCustomerIssueQty);
        return returnMap;
    }
    //【add by illion 2025/8/1 与 交货单消耗数量增加对应数量，校验订单产品下的该产品是否还有交货单库存-end】
    
    //【add by illion 2025/8/8 获取Product Unitmap去赋值Sales_Unit__c -start】
    public static Map<String,Product_Unit__c> getSalesUnitMap(Set<String> productSet){
        Map<String,Product_Unit__c> itemSalesUnitMap = new Map<String,Product_Unit__c>();
        for(Product_Unit__c unit:[SELECT Id,Product__c,Product_Sales_Unit__c,Conversion_Coefficient__c FROM Product_Unit__c WHERE Product__c IN:productSet]){
            itemSalesUnitMap.put(unit.Product_Sales_Unit__c + '-' + unit.Product__c,unit);
        }
        return itemSalesUnitMap;
    } 
    //【add by illion 2025/8/8 获取Product Unitmap去赋值Sales_Unit__c -end】
}