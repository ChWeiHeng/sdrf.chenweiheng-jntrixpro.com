/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 12-25-2025
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   12-25-2025   Gerry   Initial Version
**/
public without sharing class CloneShipToAccountCustomer {
    @AuraEnabled
    public static Output confirmClone(String recordId){
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        Savepoint sp = Database.setSavepoint();
        try {
            ObjectClone.ResponseParam rp = ObjectClone.cloneObjectSingle(recordId, true, null,'Customer_Sales_Info__c',System.Label.CloneSaleInfoRemoveField);
            if (rp.code) {
                Map<Id, Id> oldToNewIdMap = rp.oldIdToNewId;
                System.debug(oldToNewIdMap);
                if (oldToNewIdMap != null && oldToNewIdMap.get(recordId) != null) {
                    out.returnUrl = new PageReference('/' + oldToNewIdMap.get(recordId)).getUrl();
                }
            } else {
                Database.rollback(sp); out.isSucess = false; out.errorMsg = rp.message;
            }

        } catch (Exception e) {
            Database.rollback(sp); out.isSucess = false; out.errorMsg = e.getMessage();
        }

        return out;
    }
    @AuraEnabled
    public static Output init(String recordId){
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        
        try {
            List<Customer_Sales_Info__c> csiList=[SELECT Id,Can_Submit__c,Customer__c,Customer__r.MDG_Customer_Code__c,isSync__c FROM Customer_Sales_Info__c WHERE Customer__c =:recordId AND (Sales_Org__c='5130' OR Sales_Org__c='5070')];
            for(Customer_Sales_Info__c csi:csiList){
                if(!csi.Can_Submit__c){
                    out.isSucess = false; out.errorMsg = System.Label.CopyCustomerVertifySumbit;return out;
                }
            }
        } catch (Exception e) {
             out.isSucess = false; out.errorMsg = e.getMessage();
        }

        return out;
    }
    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        @AuraEnabled
        public String returnUrl {get;set;}

       
    }
}