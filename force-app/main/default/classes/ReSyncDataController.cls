/**************************************************************************************************
 * Name: ReSyncDataController
 * Object: 
 * Purpose: 重新推送数据
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-11         Created             
***************************************************************************************************/
public without sharing class ReSyncDataController {
    @AuraEnabled
    public static Output reSyncDataMe(String recordId) {
        Id recordId1 = Id.valueOf(recordId);
        String type = recordId1.getSObjectType().getDescribe().getName();
        if (type == 'Account') {
            Account acc = [SELECT Id,MDG_Customer_Code__c,Sync_Status__c FROM Account WHERE Id=:recordId];
            if (acc.Sync_Status__c != 'Synchronization Failure') {
                return new Output(false,'can not resync data');
            }
            CustomerInfoSyncToSAP.ReturnResult rr;
            if (acc.MDG_Customer_Code__c == null) {
                rr = CustomerInfoSyncToSAP.submitToSAP(recordId, 'I');
            }else{
                rr = CustomerInfoSyncToSAP.submitToSAP(recordId, 'U');
            }
            if (rr.isSuccess) {
                return new Output(true,'Success');
            }else{
                return new Output(false,rr.message);
            }
        }

        if (type == 'Customer_Sales_Info__c') {
            Customer_Sales_Info__c acc = [SELECT Id,isSync__c FROM Customer_Sales_Info__c WHERE Id=:recordId];
            CustomerSalesInfoSyncToSAP.ReturnResult rr;
            if (!acc.isSync__c) {
                rr = CustomerSalesInfoSyncToSAP.submitToSAP(recordId, 'I');
            }else{
                rr = CustomerSalesInfoSyncToSAP.submitToSAP(recordId, 'U');
            }
            if (rr.isSuccess) {
                return new Output(true,'Success');
            }else{
                return new Output(false,rr.message);
            }
        }

        if (type == 'Customer_Credit_Info__c') {
            CustomerlimitSyncToSAP.ReturnResult rr = CustomerlimitSyncToSAP.submitToSAP(recordId);
            if (rr.isSuccess) {
                return new Output(true,'Success');
            }else{
                return new Output(false,rr.message);
            }
        }

        if (type == 'Order__c') {
            List<Order_Item__c> oiList = [SELECT Id FROM Order_Item__c WHERE Order__c=:recordId AND isClosed__c=false];
            String orderItemId;
            for(Order_Item__c oi : oiList) {
                if(String.isNotBlank(orderItemId)) {
                    orderItemId += ';'+oi.Id;
                }else{
                    orderItemId = oi.Id;
                }
            }
            OrderSyncToSAP.ReturnResult rr = OrderSyncToSAP.submitToSAP(recordId, 'I',false,false,'',orderItemId,false,false);
            if (rr.isSuccess) {
                return new Output(true,'Success');
            }else{
                return new Output(false,rr.message);
            }
        }

        return null;
    }

    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        Output(Boolean isSucess, String errorMsg) {
            
            this.isSucess = isSucess;
            this.errorMsg = errorMsg;
        }
    } 
}