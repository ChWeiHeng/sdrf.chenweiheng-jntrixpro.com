/**
 * @description       : 修改业务员时触发
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 04-09-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-09-2026   Gerry   Initial Version
**/
public without sharing class ChangeOrderSalesReqToSAP {
    public static final String END_POINT = 'CreateOrder';

    @Future(callout=true)
    public static void syncReqToSAP(String Id) {

        Boolean isSuccess = true;
        Boolean isYPF = false;
        String requestBody = '';
        String responseBodyStr = '';
        String errorMessage = '';
        Order__c order = [SELECT Id,SAP_Order_Code__c,OwnerId FROM Order__c WHERE Id = :Id];
        try {
            OrderSyncToSAP.RequestBody request = new OrderSyncToSAP.RequestBody();
            request.esbinfo = new OrderSyncToSAP.ReqESInfo();
            request.esbinfo.instid = 'GSD005';
            request.esbinfo.attr1 = 'SFCRM';//预留字段 SFCRM
            request.esbinfo.attr2 = 'SAP';//预留字段 SAP
            request.resultinfo = new List<OrderSyncToSAP.ReqOrderInfo>();
            
            User u = [SELECT Id,Country__c,Employee_Code__c  FROM User WHERE Id=:order.OwnerId];
            OrderSyncToSAP.ReqOrderInfo roi = new OrderSyncToSAP.ReqOrderInfo();
            roi.OPERATION_TYPE = 'SD005_002';
            roi.OPERATION_TYPE_T = '变更';
            roi.VBELN = order.SAP_Order_Code__c;
            roi.ZYWY = u.Employee_Code__c;
            request.resultinfo.add(roi);
            requestBody = JSON.serialize(request);
            System.debug('requestBody++'+requestBody);
            requestBody = requestBody.replaceAll('null', '""');
            HttpResponse responseBody = InterfaceUtility.send_SAP_POST_Service(requestBody, END_POINT);
            System.debug('responseBody++'+responseBody);
            responseBodyStr = responseBody.getBody();
            System.debug('responseBodyStr===' + responseBodyStr);
            // responseBodyStr = '{"esbinfo":{"instid":"U2FwU2FsZXNNdWxlRVNCL1NhcFNhbGVzU2FsZU9yZGVyU3ZjQ29uZmlnRmxvdzIwMjQtMTEtMTcgMjI6MjM6MzMuMTY2","requesttime":"","responsetime":"2024-11-17 22:23:33.000","returnstatus":"S","returncode":"S001","returnmsg":"Sales order updated successfully","attr1":"0000046659","attr2":"","attr3":""},"resultinfo":[{"bstkd":"O-2411-003294|1111","vbeln":"0000046659","vbeln2":"","kunnr":"0001003223","vkorg":"3010","vtweg":"10","spart":"10","msgty":"S","msgtx":"Sales orders0000046659Created successfully","iex01":"","iex02":"","iex03":"","iex04":"","iex05":"","iex06":"","items":[{"status":"A","posnr":"10","taxamount":"","netwr":"11.00","ieps":"","optax":""}]}]}';
            isSuccess = responseBody.getStatusCode() == 200 ? true : false;
            if (isSuccess) {
                OrderSyncToSAP.ResponseBody syncReturnData = (OrderSyncToSAP.ResponseBody) JSON.deserialize(responseBodyStr, OrderSyncToSAP.ResponseBody.class);
                System.debug('responseData===' + syncReturnData);
                if ( syncReturnData.esbinfo != null ) {
                    Order__c upOrder = new Order__c();
                    upOrder.Id = Id;
                    if (syncReturnData.esbinfo.returnstatus == 'S') {
                        
                        upOrder.Sync_Status__c = 'Synchronized';
                        upOrder.Sync_Failure_Reasons__c = '';
                        isSuccess = true;
                        update upOrder;
                    }
                    if(syncReturnData.esbinfo.returnstatus == 'E'){
                        
                        isSuccess = false;
                        upOrder.Sync_Status__c = 'Synchronization error';
                        upOrder.Sync_Failure_Reasons__c = syncReturnData.resultinfo[0].MSGTX;
                        update upOrder;
                    }
                }else{
                    
                    Order__c upOrder = new Order__c();
                    upOrder.Id = Id;
                    isSuccess = false;
                    upOrder.Sync_Status__c = 'Synchronization error';
                    upOrder.Sync_Failure_Reasons__c = null;
                    update upOrder;
                    Utility.notificationUser(order.OwnerId,Id);
                }
                
            } else {
                Order__c upOrder = new Order__c();
                upOrder.Id = Id;
                isSuccess = false;
                upOrder.Sync_Status__c = 'Synchronization error';
                upOrder.Sync_Failure_Reasons__c = ''+responseBody.getStatusCode();
                update upOrder;
                Utility.notificationUser(order.OwnerId,Id);
            }
        } catch (Exception e) {
            /*if(isReprocess)isReprocess = false;
            system.debug('isReprocess===='+isReprocess);*/
            Utility.notificationUser(order.OwnerId,Id);
            
            Order__c upOrder = new Order__c();
            upOrder.Id = Id;
            isSuccess = false;
            upOrder.Sync_Status__c = 'Synchronization error';
            upOrder.Sync_Failure_Reasons__c = e.getMessage()+e.getLineNumber();
            update upOrder;
        }
        InterfaceUtility.insertInterfaceLog('OrderSyncToSAP', 'CRM',
                    'SAP', END_POINT, requestBody, isSuccess, false,
                    responseBodyStr, errorMessage, 'POST', new List<String>{Id},
                    '订单同步SAP', 'CRM同步订单至SAP');
    }
}