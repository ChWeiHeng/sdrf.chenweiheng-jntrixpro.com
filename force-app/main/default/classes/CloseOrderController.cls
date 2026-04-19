/**************************************************************************************************
 * Name: NotificationService
 * Object: 
 * Purpose: 订单关闭
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-20         Created             
***************************************************************************************************/
public without sharing class CloseOrderController {
    @AuraEnabled
    public static Output closeOrder(String orderRecordId,String reasonText) {
        SavePoint sp;
        try {
            Order_Item__c oi = [SELECT Id,Order__c,Order__r.Reference_Order__c,(SELECT Id FROM Delivery_Note__r),Order__r.Order_type__c,Delivery_Note__c FROM Order_Item__c WHERE ID =:orderRecordId];
            // if (oi.Delivery_Note__r!=null && oi.Delivery_Note__r.size()>0) {
            //     Output out = new Output();            out.isSucess = false;            out.errorMsg = 'Can not close the order item';            return out;
            // }
            
            if (
                (oi.Order__r.Order_type__c == 'ZARE' || oi.Order__r.Order_type__c == 'ZARA' || oi.Order__r.Order_type__c == 'ZARF') &&
                oi.Delivery_Note__c==null
            ) {
                Output out = new Output();            
                out.isSucess = false;            
                out.errorMsg = 'Please contact the administrator to delete this order.';            
                return out;
            }
            
            OrderSyncToSAP.ReturnResult rr = OrderSyncToSAP.submitToSAP(oi.Order__c, 'U',true,false,reasonText,orderRecordId,true,false);
            sp = Database.setSavePoint();
            if (rr.isSuccess || System.Test.isRunningTest()) {
                Output out = new Output();
                out.isSucess = true;
                Order_Item__c ord = new Order_Item__c();
                ord.Id = orderRecordId;
                ord.isClosed__c = true;
                ord.Closure_Reason__c = reasonText;
                update ord;
                if ((oi.Order__r.Order_type__c == 'ZMX3' || oi.Order__r.Order_type__c == 'ZMX4' || oi.Order__r.Order_type__c == 'ZMX2') && oi.Order__r.Reference_Order__c!=null) {//墨西哥相关逆向订单
                    SubmitOrderController.calculateZMX1Rate(oi.Order__c, false);
                }
                return out;
            }else{
                Database.rollback(sp);
                Output out = new Output();            out.isSucess = false;            out.errorMsg = rr.message;     return out;
            }
        } catch (Exception e) {
            if (sp!=null) {
                Database.rollback(sp);
            }
            
            Output out = new Output();            
            out.isSucess = false;        
            System.debug('e.getMessage()====>'+e.getMessage());    
            out.errorMsg = Utility.getCustomMessage(e.getMessage(), False);            
            return out;
        }
        
    }

    @AuraEnabled
    public static Output init(String orderRecordId) {
        SavePoint sp = Database.setSavepoint();
        try {
            Output out = new Output();
            out.isSucess = true;
            out.optionList = new List<Option>();
            List<Utility.PicklistItem> valueMap = Utility.getPicklistValueList('Order_Item__c', 'Closure_Reason__c');
            Order_Item__c ord = new Order_Item__c();
            ord.Id = orderRecordId;
            ord.isClosed__c = true;
            update ord;
            for (Utility.PicklistItem pi : valueMap) {
                Option op = new Option();
                op.Label = pi.label;
                op.Value = pi.value;
                out.optionList.add(op);
            }
            System.debug('out.optionList=====>'+out.optionList);
            Database.rollback(sp);
            return out;
        } catch (Exception e) {
            Database.rollback(sp);
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = Utility.getCustomMessage(e.getMessage(), false); 
            return out;
        }
    }

    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        @AuraEnabled
        public List<Option> optionList {get;set;}
    }

    public class Option {
        @AuraEnabled
        public String label {get;set;}

        @AuraEnabled
        public String value {get;set;}
    }
}