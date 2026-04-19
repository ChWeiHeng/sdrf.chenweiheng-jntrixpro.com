/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-05-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-12-2025   Gerry   Initial Version
**/
public without sharing class OrderSyncToSAP {
    public static final String END_POINT = 'CreateOrder';

    @Future(callout=true)
    public static void submitToSAPFu(
        String Id,
        String changeType,
        Boolean isClose,
        Boolean isbeforceClose,
        String reasonText,
        Boolean isRealClose,
        String orderItemId/*,
        Boolean isReprocess*///当前是否为重处理
    ) {
        submitToSAP(Id,changeType,isClose,isbeforceClose,reasonText,orderItemId,isRealClose,false/*,isReprocess*/);
    }

    @AuraEnabled
    public static ReturnResult submitToSAP(
        String Id,//订单ID
        String changeType,//创建还是更新
        Boolean isClose,//关闭 的时候传
        Boolean isbeforceClose,//重新打开 的时候传
        String reasonText,//关闭原有,关闭时必填
        String orderItemId,//订单行ID 用分号 分隔
        Boolean isRealClose,//是否真正关闭  false
        Boolean change/*,
        Boolean isReprocess*///当前是否为重处理
    ){
        ReturnResult returnResult = new ReturnResult();
        returnResult.isSuccess = true;

        Boolean isSuccess = true;
        Boolean isYPF = false;
        String requestBody = '';
        String responseBodyStr = '';
        String errorMessage = '';
        List<Order__c> orderList;
        
        try{
            RequestBody request = new RequestBody();
            request.esbinfo = new ReqESInfo();
            request.esbinfo.instid = 'GSD005';
            request.esbinfo.attr1 = 'SFCRM';//预留字段 SFCRM
            request.esbinfo.attr2 = 'SAP';//预留字段 SAP
            List<ReqOrderInfo> resultinfoList = new List<ReqOrderInfo>();
            //获取订单信息
            orderList=[SELECT Distrubutor_Exchange_Rate__c,Invoice__r.Name,Profit_Center__c,Id,Name,SAP_Order_Code__c,Cust_Reference__c,Incoterms__c,DN_Post_Date__c,
                            Customer__r.MDG_Customer_Code__c,CreatedDate,Currency__c,Ship_To__r.MDG_Customer_Code__c,
                            Order_type__c,CreatedBy.Name,Inco_Location1__c,Payment_Method__c,Ship_To__r.Shipping_Address__c,
                            E_Document_MX__c,Source_Order__r.SAP_Order_Code__c,Auto_Issue_Consignment__c,Sync_Status__c,
                            Customer_Sales_Info__r.Sales_Org__c,
                            Customer_Sales_Info__r.Distr_Channel__c,
                            Customer_Sales_Info__r.Division__c,
                            Customer_Sales_Info__r.Terms_Of_Payment__c,
                            Customer_Sales_Info__r.Sales_District__c,
                            Customer_Sales_Info__r.Inco_Location1__c,
                            Customer_Sales_Info__r.Sales_Office__c,
                            Customer_Sales_Info__r.Sales_Group__c,
                            Customer__r.Customer_Group__c,Commission_Percentage__c,Commission_Amount_New__c,Commission_To__r.MDG_Customer_Code__c,
                            Customer_Sales_Info__r.Price_Group__c,
                            Customer_Shipping_Address__r.Direction__c,Locked_in_SAP__c,
                            Order_Reason__c,Customer_Sales_Info__r.Payment_method__c,Order_Change__c,Change_Status__c,
                            Customer_Sales_Info__r.Business_model__c,OwnerId,Req_Deliv_Date__c,RecordType_Name__c,
                            Sales_Org__c,Distr_Channel__c,Terms_Of_Payment__c,Sales_District__c,Sales_Office__c,Sales_Group__c,Business_Model__c
                        FROM Order__c 
                        WHERE Id =:Id];
            User u = [SELECT Id,Country__c,Employee_Code__c  FROM User WHERE Id=:orderList[0].OwnerId];
            //获取订单行
            List<Order_Item__c> orderItemList=[SELECT Delivery_Note__r.Batch__c,Toxicity_Classification__c,Product_Usage__c,SAP_Item_Num__c,Delivery_Date__c,Id,Quantity__c,Material_Number__c,Sales_Unit__r.Product_Sales_Unit__c,Sales_Unit_Text__c,
                                        Commodity__r.Name,Order__r.Customer_Sales_Info__r.Country_Code_Text__c,Inventory_Location__c,New_Price__c,New_Quantity__c,New_Delivery_Date__c,Depend_On_Item__r.SAP_Item_Num__c,
                                        Price__c,Order__r.Deliver_Plant__c,Gross_Weight__c,Net_Weight__c,Amount_per_item__c ,Unit_Price__c  ,SAP_Total_Net__c,SAP_Total_Tax__c
                                        FROM Order_Item__c 
                                        WHERE Order__c =: Id];

            //获取订单行最小日期
            List<Order_Item__c> orderItemDateList=[SELECT Delivery_Date__c   
                                        FROM Order_Item__c 
                                        WHERE Order__c =: Id ORDER BY Delivery_Date__c ASC Limit 1];
            
            ReqOrderInfo roi = new ReqOrderInfo();
            roi.KURRF = orderList[0].Distrubutor_Exchange_Rate__c;//zare汇率
            // if (orderList[0].RecordType_Name__c == 'Model_C' ) {
                roi.ZYWY = u.Employee_Code__c;//业务员
            // }
            
            roi.OPERATION_TYPE = '编辑';
            if (changeType == 'I') {//新增
                roi.OPERATION_TYPE = 'ZSD005_001';
                roi.OPERATION_TYPE_T='新增';
                // roi.OPERATION_TYPE = '新建';
                // 当Auto-issue Consignment? = true的ZARA订单同步时，OPERATION_TYPE=ZSD005_004；订单头新增传参：ZARB的SAP订单号VBELN_RE，Reprocess重处理标识；订单头新增传参：WADAT_IST发货过账日期 illion 20250716 start
                if(orderList[0].Order_type__c == 'ZARA' && orderList[0].Auto_Issue_Consignment__c){
                    roi.OPERATION_TYPE = 'ZSD005_004';
                    roi.OPERATION_TYPE_T='自动创建ZARA';
                }
                // 当Auto-issue Consignment? = true的ZARA订单同步时，OPERATION_TYPE=ZSD005_004；订单头新增传参：ZARB的SAP订单号VBELN_RE，Reprocess重处理标识；订单头新增传参：WADAT_IST发货过账日期 illion 20250716 end
            }
            if (changeType == 'U') {//变更
                roi.OPERATION_TYPE = 'ZSD005_002';
                roi.OPERATION_TYPE_T='变更';
            }
            //订单字段赋值
            if (changeType=='U') {
                roi.VBELN = orderList[0].SAP_Order_Code__c;
            }

            if (changeType=='I' && orderList[0].SAP_Order_Code__c!=null) {
                roi.VBELN = orderList[0].SAP_Order_Code__c;
            }

            if (isClose) {
                roi.ZCZLX = 'Suspend';
            }

            if (isbeforceClose ) {
                if(!change) {
                    roi.ZCZLX = 'Release pause';
                }else{
                    roi.ZCZLX = 'Release suspension and change';
                }
                
            }
            if(String.isNotBlank(orderList[0].Cust_Reference__c)){
                roi.BSTKD = orderList[0].Name+'|'+orderList[0].Cust_Reference__c;
            }else{
                roi.BSTKD = orderList[0].Name;
            }  
            if (orderList[0].RecordType_Name__c == 'Model_C') {
                roi.zzcomsamt = orderList[0].Commission_Amount_New__c;
            }
            
            roi.zzcomsto = orderList[0].Commission_To__r.MDG_Customer_Code__c;
            if (orderList[0].Commission_Percentage__c!=null) {
                roi.zzcomsperct = orderList[0].Commission_Percentage__c/100;
            }
            if (orderItemDateList[0].Delivery_Date__c != null) {
                roi.BSTDK = String.valueOf(orderItemDateList[0].Delivery_Date__c).replaceAll('-', '');
                roi.VDATU = String.valueOf(orderItemDateList[0].Delivery_Date__c).replaceAll('-', '');
            }
            
            roi.KUNNR = orderList[0].Customer__r.MDG_Customer_Code__c;
            if(orderList[0].Ship_To__r.MDG_Customer_Code__c!=null) {
                roi.KUNAG = orderList[0].Ship_To__r.MDG_Customer_Code__c;
            }else{
                roi.KUNAG = orderList[0].Customer__r.MDG_Customer_Code__c;
            }
            
            roi.AUDAT = String.valueOf(Date.valueOf(orderList[0].CreatedDate)).replaceAll('-', '');
            roi.WAERK = orderList[0].Currency__c;
            roi.AUART = orderList[0].Order_type__c;
            roi.VSNMR_V = orderList[0].CreatedBy.Name;
            roi.INCO1 = orderList[0].Incoterms__c;
            roi.INCO2L = orderList[0].Inco_Location1__c;
            if(orderList[0].Customer_Shipping_Address__r.Direction__c!=null) {
                roi.ZZADDRESS = orderList[0].Customer_Shipping_Address__r.Direction__c;
            }else{
                roi.ZZADDRESS = orderList[0].Ship_To__r.Shipping_Address__c;
            }
            
            roi.AUGRU = orderList[0].Order_Reason__c;
            
            
            
            //销售视图字段赋值
            roi.VKORG = orderList[0].Sales_Org__c;
            roi.VTWEG = orderList[0].Distr_Channel__c;
            roi.SPART = orderList[0].Customer_Sales_Info__r.Division__c;
            roi.ZTERM = orderList[0].Terms_Of_Payment__c;
            roi.BZIRK = orderList[0].Sales_District__c;
            roi.VKBUR = orderList[0].Sales_Office__c;
            roi.VKGRP = orderList[0].Sales_Group__c;
            //roi.KDGRP = orderList[0].Customer__r.Customer_Group__c;
            roi.KONDA = orderList[0].Customer_Sales_Info__r.Price_Group__c;
            roi.KVGR1 = orderList[0].Customer_Sales_Info__r.Payment_method__c;
            roi.KVGR3 = orderList[0].Business_Model__c; 
            roi.ZLSCH = orderList[0].Payment_Method__c;
            roi.EDOCUMENT_MX = orderList[0].E_Document_MX__c;
            //订单头新增字段赋值 illion 20250717 start
            if(orderList[0].Order_type__c == 'ZARA' && orderList[0].Auto_Issue_Consignment__c && orderList[0].Sync_Status__c != 'Synchronization error'){
                Date d = orderList[0].DN_Post_Date__c;
                String year = String.valueOf(d.year());
                String month = d.month() < 10 ? '0' + String.valueOf(d.month()) : String.valueOf(d.month());
                String day = d.day() < 10 ? '0' + String.valueOf(d.day()) : String.valueOf(d.day());
                roi.WADAT_IST = year + month + day;
                roi.VBELN_RE = orderList[0].SAP_Order_Code__c;
                roi.VBELN_ZARB = orderList[0].Source_Order__r.SAP_Order_Code__c;
                roi.VBELN = '';
                roi.Reprocess = 'N';
                isYPF = true;
            }else if(orderList[0].Order_type__c == 'ZARA' && orderList[0].Auto_Issue_Consignment__c && orderList[0].Sync_Status__c == 'Synchronization error'){
                Date d = orderList[0].DN_Post_Date__c;
                String year = String.valueOf(d.year());
                String month = d.month() < 10 ? '0' + String.valueOf(d.month()) : String.valueOf(d.month());
                String day = d.day() < 10 ? '0' + String.valueOf(d.day()) : String.valueOf(d.day());
                roi.WADAT_IST = year + month + day;
                roi.VBELN_RE = orderList[0].SAP_Order_Code__c;
                roi.VBELN_ZARB = orderList[0].Source_Order__r.SAP_Order_Code__c;
                roi.VBELN = '';
                roi.Reprocess = 'Y';
                isYPF = true;
            }
            //订单头新增字段赋值 illion 20250717 end
            //退货订单关联发票----Start
            if (orderList[0].Order_type__c == 'ZAR2') {
                roi.VBELN_ZARB = orderList[0].Invoice__r.Name;
            }
            //退货订单关联发票----End
            //订单行赋值
            List<OrderItemRow> orderIRList = new List<OrderItemRow>();
            List<String> orderUpdateItemList = orderItemId.split(';');
            for(Order_Item__c oi : orderItemList){
                if(orderUpdateItemList.size()>0) {//关闭时如果不在关闭行则跳过
                    if(!orderUpdateItemList.contains(oi.Id)) {
                        continue;
                    }
                }
                OrderItemRow oir = new OrderItemRow();
                oir.taxm2 = oi.Toxicity_Classification__c;
                if (oir.taxm2 == '4') {//sap给出来的特俗逻辑转换
                    oir.taxm2 = '3';
                }
                oir.MATNR = oi.Material_Number__c;
                // if(isbeforceClose) {
                //     oir.LFIMG = oi.Old_Quantity__c+''; 
                // }else{
                if(orderList[0].Change_Status__c == 'Approved' && orderList[0].Order_Change__c){
                    if(oi.New_Quantity__c!=null) {
                        oir.LFIMG = oi.New_Quantity__c+'';
                    }else{
                        oir.LFIMG = oi.Quantity__c+'';
                    }
                    
                }else{
                    if (orderList[0].Order_type__c == 'ZMX3' || orderList[0].Order_type__c == 'ZMX4') {//借贷项订单字段
                        oir.ZMENG = oi.Quantity__c+'';
                    }else{
                        oir.LFIMG = oi.Quantity__c+'';
                    }
                    
                }

                //寄售订单给zarb批次
                if (orderList[0].Order_type__c == 'ZARA' || orderList[0].Order_type__c == 'ZARF' || orderList[0].Order_type__c == 'ZARE') {
                    oir.CHARG = oi.Delivery_Note__r.Batch__c;
                }
                    
                // }
                
                oir.VRKME = oi.Sales_Unit_Text__c;
                oir.KPEIN = '1';
                if (String.isNotBlank(reasonText) && orderUpdateItemList.contains(oi.Id) && isClose) {
                    oir.ABGRU = reasonText;
                }else{
                    oir.ABGRU = '';
                }
                oir.ZZNAME = oi.Commodity__r.Name;
                if (orderList[0].Sales_Org__c == '3010' || orderList[0].Sales_Org__c == '3020') {
                    // if(isbeforceClose) {
                    //     oir.ZPMX = oi.Old_Price__c+'';
                    // }else{
                    if(orderList[0].Change_Status__c == 'Approved' && orderList[0].Order_Change__c){
                        if(oi.New_Price__c!=null) {
                            oir.ZPMX = oi.New_Price__c+'';
                        }else{
                            oir.ZPMX = oi.Price__c+'';
                        }
                        
                    }else{
                        oir.ZPMX = oi.Price__c+'';
                    }
                        
                    // }
                    
                }
                if (orderList[0].Sales_Org__c == '5130' || orderList[0].Sales_Org__c == '5070') {
                    // if(isbeforceClose) {
                    //     oir.ZPMX = oi.Old_Price__c+'';
                    // }else{
                    if(orderList[0].Change_Status__c == 'Approved' && orderList[0].Order_Change__c){
                        if(oi.New_Price__c!=null) {
                            oir.ZP08 = oi.New_Price__c+'';
                        }else{
                            oir.ZP08 = oi.Price__c+'';
                        }
                        
                    }else{
                        oir.ZP08 = oi.Price__c+'';
                    }
                    // }
                    
                }
                oir.WERKS = oi.Order__r.Deliver_Plant__c;
                // oir.LGORT = oi.Inventory_Location__c.split('-')[1];
                oir.LGORT = oi.Inventory_Location__c;
                // if(isbeforceClose) {
                //     oir.ETDAT = String.valueOf(oi.Old_Delivery_Date__c).replaceAll('-', '');
                // }else{
                if(orderList[0].Change_Status__c == 'Approved' && orderList[0].Order_Change__c){
                    if(oi.New_Delivery_Date__c!=null) {
                        oir.ETDAT = String.valueOf(oi.New_Delivery_Date__c).replaceAll('-', '');
                    }else{
                        oir.ETDAT = String.valueOf(oi.Delivery_Date__c).replaceAll('-', '');
                    }
                    
                }else{
                    if (oi.Delivery_Date__c != null) {
                        oir.ETDAT = String.valueOf(oi.Delivery_Date__c).replaceAll('-', '');
                    }
                    
                }
                // }
                
                oir.BRGEW = oi.Gross_Weight__c;
                oir.NTGEW = oi.Net_Weight__c;
                oir.PRCTR = orderList[0].Profit_Center__c;
                oir.GEWEI = 'KG';
                oir.ZPROUS = oi.Product_Usage__c;
                if(isYPF){
                    //oir.POSNR = String.valueOf(oi.CRM_Item_Number__c);
                    //oir.POSNR_ZARB = oi.SAP_Item_Num__c;
                    oir.POSNR = oi.SAP_Item_Num__c;
                    oir.POSNR_ZARB = oi.Depend_On_Item__r.SAP_Item_Num__c;
                }else{
                    oir.POSNR_ZARB = '';
                    oir.POSNR = oi.SAP_Item_Num__c;
                }
                orderIRList.add(oir);
            }
            roi.ITEMS = orderIRList;

            resultinfoList.add(roi);
            request.resultinfo = resultinfoList;

            requestBody = JSON.serialize(request);
            // requestBody = requestBody.replaceAll('null', '""');
            System.debug('requestBody++'+requestBody);
            requestBody = requestBody.replaceAll('null', '""');
            HttpResponse responseBody = InterfaceUtility.send_SAP_POST_Service(requestBody, END_POINT);
            System.debug('responseBody++'+responseBody);
            responseBodyStr = responseBody.getBody();
            System.debug('responseBodyStr===' + responseBodyStr);
            // responseBodyStr = '{"esbinfo":{"instid":"U2FwU2FsZXNNdWxlRVNCL1NhcFNhbGVzU2FsZU9yZGVyU3ZjQ29uZmlnRmxvdzIwMjQtMTEtMTcgMjI6MjM6MzMuMTY2","requesttime":"","responsetime":"2024-11-17 22:23:33.000","returnstatus":"S","returncode":"S001","returnmsg":"Sales order updated successfully","attr1":"0000046659","attr2":"","attr3":""},"resultinfo":[{"bstkd":"O-2411-003294|1111","vbeln":"0000046659","vbeln2":"","kunnr":"0001003223","vkorg":"3010","vtweg":"10","spart":"10","msgty":"S","msgtx":"Sales orders0000046659Created successfully","iex01":"","iex02":"","iex03":"","iex04":"","iex05":"","iex06":"","items":[{"status":"A","posnr":"10","taxamount":"","netwr":"11.00","ieps":"","optax":""}]}]}';
            isSuccess = responseBody.getStatusCode() == 200 ? true : false;
            if (isSuccess) {
                ResponseBody syncReturnData = (ResponseBody) JSON.deserialize(responseBodyStr, ResponseBody.class);
                System.debug('responseData===' + syncReturnData);
                if ( syncReturnData.esbinfo != null ) {
                    returnResult.message = syncReturnData.esbinfo.returnmsg;
                    returnResult.item = syncReturnData.resultinfo[0].ITEMS;
                    Order__c upOrder = new Order__c();
                    upOrder.Id = Id;
                    if (syncReturnData.esbinfo.returnstatus == 'S') {
                        //if(isReprocess)isReprocess = false;
                        List<Order_Item__c> orderItemUpdateList = new List<Order_Item__c>();
                        upOrder.SAP_Order_Code__c = syncReturnData.resultinfo[0].VBELN;
                        if (syncReturnData.resultinfo[0].VBELN2 != null) {
                            upOrder.SAP_Order_Code2__c = syncReturnData.resultinfo[0].VBELN2;
                        }
                        Map<String,Item> itemMap = new Map<String,Item>();
                        for (Item item : syncReturnData.resultinfo[0].ITEMS) {
                            itemMap.Put(item.POSNR,item);
                        }
                        for (Order_Item__c oi : orderItemList) {
                            oi.External_Id__c = upOrder.SAP_Order_Code__c+'_'+oi.SAP_Item_Num__c;
                            // oi.Unit_Price__c = itemMap.get(oi.SAP_Item_Num__c).taxPrice;
                            if(!isRealClose && itemMap.get(oi.SAP_Item_Num__c)!=null) {
                                if(String.isNotBlank(itemMap.get(oi.SAP_Item_Num__c).netwr)) {
                                    oi.SAP_Total_Net__c = Decimal.valueOf(itemMap.get(oi.SAP_Item_Num__c).netwr);
                                }else{
                                    oi.SAP_Total_Net__c = null;

                                }
                                if(String.isNotBlank(itemMap.get(oi.SAP_Item_Num__c).ieps)) {
                                    oi.IEPS__c = Decimal.valueOf(itemMap.get(oi.SAP_Item_Num__c).ieps);
                                }else{
                                    oi.IEPS__c = null;
                                }

                                if(String.isNotBlank(itemMap.get(oi.SAP_Item_Num__c).optax)) {
                                    oi.OPTAX__c = Decimal.valueOf(itemMap.get(oi.SAP_Item_Num__c).optax);
                                }else{
                                    oi.OPTAX__c = null;
                                }
                            }

                            
                            // oi.SAP_Total_Tax__c = itemMap.get(oi.SAP_Item_Num__c).netwr-oi.Amount_per_item__c;
                            // oi.Unit_Price__c = (itemMap.get(oi.SAP_Item_Num__c).netwr/oi.Quantity__c).setScale(2);
                            if (String.isNotBlank(syncReturnData.resultinfo[0].VBELN2) && syncReturnData.resultinfo[0].VBELN2 != null) {
                                oi.External_Id2__c = upOrder.SAP_Order_Code2__c+'_'+oi.SAP_Item_Num__c;
                            }
                            orderItemUpdateList.add(oi);
                        }
                        upOrder.Sync_Status__c = 'Synchronized';
                        upOrder.Sync_Failure_Reasons__c = '';
                        if (roi.ZCZLX == 'Suspend' && isRealClose) {//如果是真的关闭才进行关闭流程设置
                            
                            List<Order_Item__c> oiList = new List<Order_Item__c>();
                            for(String orderId : orderUpdateItemList) {
                                Order_Item__c oi = new Order_Item__c();
                                oi.Id = orderId;
                                oi.isClosed__c = true;
                                oi.Closure_Reason__c = reasonText;
                                oiList.add(oi);
                            }
                            
                            update oiList;
                        }

                        if (roi.ZCZLX == 'Release suspension and change') {
                            List<Order_Item__c> oiList = new List<Order_Item__c>();
                            for(String orderId : orderUpdateItemList) {
                                Order_Item__c oi = new Order_Item__c();
                                oi.Id = orderId;
                                oi.isClosed__c = false;
                                oi.Closure_Reason__c = '';
                                oiList.add(oi);
                            }
                            
                            update oiList;
                        }

                        // if (roi.ZCZLX == '解除暂停') {
                        //     upOrder.isClosed__c = false;
                        // }
                        Database.upsert(orderItemUpdateList);
                        update upOrder;
                    }
                    if(syncReturnData.esbinfo.returnstatus == 'E'){
                        //进行重处理 illion 20250717 starts
                        /*system.debug('isReprocess===='+isReprocess);
                        if(orderList[0].Order_type__c == 'ZARA' && orderList[0].Auto_Issue_Consignment__c && syncReturnData.resultinfo[0].MSGTY == 'E'){
                            isReprocess = isReprocess ? false : true;
                            system.debug('isReprocess===='+isReprocess);
                        }*/
                        
                        //进行重处理 illion 20250717 end
                        isSuccess = false;
                        errorMessage = syncReturnData.esbinfo.returnmsg;
                        returnResult.isSuccess = false;
                        returnResult.message = syncReturnData.esbinfo.returnmsg;
                        upOrder.Sync_Status__c = 'Synchronization error';
                        upOrder.Sync_Failure_Reasons__c = syncReturnData.resultinfo[0].MSGTX;
                        if (syncReturnData.resultinfo[0].VBELN != null) {
                            upOrder.Id = Id;
                            upOrder.SAP_Order_Code__c = syncReturnData.resultinfo[0].VBELN;
                        }
                        if (!isClose && !isbeforceClose) {
                            Utility.notificationUser(orderList[0].OwnerId,Id);
                            update upOrder;
                        }
                    }
                    // if (!isClose) {
                    //     update upOrder;
                    // }
                }else{
                    /*if(isReprocess)isReprocess = false;
                    system.debug('isReprocess===='+isReprocess);*/
                    returnResult.isSuccess = false;
                    returnResult.message = responseBodyStr;
                    isSuccess = false;
                    errorMessage = responseBodyStr;
                    Order__c upOrder = new Order__c();
                    upOrder.Id = Id;
                    returnResult.isSuccess = false;
                    upOrder.Sync_Status__c = 'Synchronization error';
                    upOrder.Sync_Failure_Reasons__c = null;
                    if (!isClose && !isbeforceClose) {
                        update upOrder;
                        Utility.notificationUser(orderList[0].OwnerId,Id);
                    }
                }
                
            } else {
                /*if(isReprocess)isReprocess = false;
                system.debug('isReprocess===='+isReprocess);*/
                returnResult.isSuccess = false;
                returnResult.message = responseBodyStr;
                isSuccess = false;
                errorMessage = responseBodyStr;
                Order__c upOrder = new Order__c();
                upOrder.Id = Id;
                returnResult.isSuccess = false;
                upOrder.Sync_Status__c = 'Synchronization error';
                upOrder.Sync_Failure_Reasons__c = ''+responseBody.getStatusCode();
                if (!isClose && !isbeforceClose) {
                    update upOrder;
                    Utility.notificationUser(orderList[0].OwnerId,Id);
                }
            }

        }
        catch (Exception e) {
            /*if(isReprocess)isReprocess = false;
            system.debug('isReprocess===='+isReprocess);*/
            if (orderList.size()>0 && !isClose && !isbeforceClose) {
                Utility.notificationUser(orderList[0].OwnerId,Id);
            }
            System.debug('错误信息'+e.getMessage()+' '+e.getStackTraceString() + ' ' + e.getLineNumber());
            returnResult.isSuccess = false;
            returnResult.message = e.getMessage()+e.getLineNumber();
            isSuccess = false;
            errorMessage = e.getMessage()+e.getLineNumber();
            Order__c upOrder = new Order__c();
            upOrder.Id = Id;
            returnResult.isSuccess = false;
            upOrder.Sync_Status__c = 'Synchronization error';
            upOrder.Sync_Failure_Reasons__c = e.getMessage()+e.getLineNumber();
            if (!isClose && !isbeforceClose) {
                update upOrder;
            }
        }
        InterfaceUtility.insertInterfaceLog('OrderSyncToSAP', 'CRM',
                    'SAP', END_POINT, requestBody, isSuccess, false,
                    responseBodyStr, errorMessage, 'POST', new List<String>{Id},
                    '订单同步SAP', 'CRM同步订单至SAP');
        //重处理的订单需要重新推送 illion 20250717 start
        //system.debug('isReprocess===='+isReprocess);
        // if(isReprocess){
        //     Datetime nowTime = Datetime.now();
        //     nowTime = nowTime.addSeconds(10);
        //     String scheduleName = '订单接口在 '+nowTime.format('yyyy-MM-dd HH:mm:ss')+String.valueOf(nowTime.millisecond())+' 推送SAP';
        //     String cronExp = nowTime.second()+' '+nowTime.minute()+' '+nowTime.hour()+' '+nowTime.day()+' '+nowTime.month()+' ? '+nowTime.year();
        //     List<String> recordIds = new List<String>();
        //     recordIds.add(Id);
        //     System.schedule(scheduleName,cronExp, new ScheduableSync(recordIds,orderItemId));
        //     //submitToSAP(Id,'I',false,false,'',orderItemId,false,false);
        //     //OrderSyncToSAP.submitToSAPFu(Id, 'I',false,false,'',false,orderItemId);
        // }
        //重处理的订单需要重新推送 illion 20250717 end
        return returnResult;
    }

    public class ReturnResult {
        @InvocableVariable(Label='是否成功' Description='是否成功')
        public Boolean isSuccess;
        @InvocableVariable(Label='返回信息结果' Description='返回信息结果')
        public String message;
        @InvocableVariable(Label='返回数据' Description='返回数据')
        public List<Item> item;
    }

    public class ResponseBody {
      public RespESInfo esbinfo;
      public List<RespOrderInfo> resultinfo;
    }

    public class RespESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
        public String responsetime;//返回时间
        public String returnstatus;//接口状态
        public String returncode;//接口状态码
        public String returnmsg;//接口消息
        public String attr1;//预留字段 SFCRM
        public String attr2;//预留字段 SAP
        public String attr3;//预留字段
    }

    public class RespOrderInfo{
        public String BSTKD;//需货单号 
        public String VBELN;//SAP订单号
        public String KUNNR;//客户编号
        public String VKORG;//销售组织 
        public String VTWEG;//分销渠道
        public String SPART;//产品组 
        public String MSGTY;//消息类型
        public String MSGTX;//消息文本
        public String VBELN2;//寄售订单号
        public List<Item> items;
    }

    public class Item {
        public String status;
        public String posnr;
        public String taxPrice; //含税单价
        public String netwr;    //含税总额
        public String ieps; //墨西哥IEPS税
        public String optax;//墨西哥销项税
    }

    public class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqOrderInfo> resultinfo;
    }

    public class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
        public String attr1;//预留字段 SFCRM
        public String attr2;//预留字段 SAP
    }

    public class ReqOrderInfo{
        public String OPERATION_TYPE;//接口操作类型 SD005_001：新增，SD005_002：变更，SD005_003：再次交付承诺
        public String OPERATION_TYPE_T;//接口操作类型描述
        public String VBELN;//SAP订单号
        public String BSTKD;//客户参考 
        public String BSTDK;//客户参考日期
        public String KUNNR;//客户编号
        public String KUNAG;//Ship To
        public String VKORG;//销售组织 
        public String VTWEG;//分销渠道
        public String SPART;//产品组
        public String AUDAT;//凭证日期
        public String WAERK;//SD 凭证货币
        public String AUART;//销售凭证类型 
        public String ZTERM;//付款条件代码
        public String BZIRK;//销售地区 
        public String INCO1;//国际贸易条款（第 1 部分） 
        public String INCO2L;//国际贸易条款位置 2
        public String VKBUR;//销售办事处
        public String VKGRP;//销售组
        public String KVGR1;//客户组 1
        public String KVGR3;//客户组 3
        public String VSNMR_V;//销售单据版本编号 
        public String KDGRP;//客户组 
        public String KONDA;//客户价格组 
        public String ZCZLX;//对销售订单的操作类型
        public String ZZADDRESS;//地址备注
        public String AUGRU;//订单原因
        public String ZLSCH;//付款方式
        public String EDOCUMENT_MX;//电票备注
        public Include INCLUDE;//备用字段
        public String VDATU;//交货日期
        public Decimal zzcomsamt;// 佣金
        public String zzcomsto;//   佣金对象
        public Decimal zzcomsperct;//   佣金比例
        //YPF新增参数
        public String WADAT_IST;//交货单的发货过账日期
        public String VBELN_RE;//ZARA销售订单号
        public String VBELN_ZARB;//ZARB销售订单号
        public String Reprocess;//重处理标识 Y/N 默认为N
        public List<OrderItemRow> ITEMS;//销售订单行项目表 

        //ZARE新增税率
        public Decimal KURRF;//汇率

        public String ZYWY;//业务员编码
    }

    public class Include{
        public String HEX01;//备用字段
        public String HEX02;//备用字段
        public String HEX03;//备用字段
        public String HEX04;//备用字段
        public String HEX05;//备用字段
        public String HEX06;//备用字段
    }

    public class OrderItemRow{
        public String MATNR;//物料编号
        public String LFIMG;//实际已交货量（按销售单位）
        public String ZMENG;//借贷项订单数量字段
        public String CHARG;//寄售订单批次
        public String VRKME;//销售单位
        public String ZPMX;//不含税单价(墨西哥字段)
        public String ZP08;//不含税单价(阿根廷字段)
        public String KPEIN;//价格单位
        public String WERKS;//交货工厂
        public String LGORT;//库位
        public String ETDAT;//交货日期
        public String BRGEW;//毛重
        public String NTGEW;//净重
        public String PRCTR;//利润中心
        public String GEWEI;//重量单位
        public String ZZNAME;//产品名称
        public String POSNR;//行编码
        public String taxm2;//毒性分类
        
        public String POSNR_ZARB;//行编码
        public String IEX01;//备用字段
        public String IEX02;//备用字段
        public String IEX03;//备用字段
        public String IEX04;//备用字段
        public String IEX05;//备用字段
        public String IEX06;//备用字段
        public String ABGRU;
        public String ZPROUS;
    }

}