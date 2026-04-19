public without sharing class BankInfoTriggerHandler implements Triggers.Handler{
    public static void handle() {
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            Set<String> customerIdSet = new Set<String>();
            for (Bank_Info__c bi : (List<Bank_Info__c>)Trigger.new) {
                customerIdSet.add(bi.Customer__c);
            }
            System.debug(customerIdSet);
            Map<String,Account> accMap = new Map<String,Account>([SELECT Id,Customer_Approval_Status__c,MDG__c,Sync_Status__c  FROM Account WHERE Id IN:customerIdSet]);
            
            for (Bank_Info__c bi : (List<Bank_Info__c>)Trigger.new) {
                if (
                    accMap.get(bi.Customer__c).Customer_Approval_Status__c == 'Approved' && 
                    accMap.get(bi.Customer__c).Sync_Status__c == 'Synchronized'  && 
                    !accMap.get(bi.Customer__c).MDG__c && ! System.isBatch() && !System.isFuture()
                ) {
                    CustomerInfoSyncToSAP.submitToSAPFu(bi.Customer__c,'U');
                }
            }
        }
    }
}