public without sharing class CustomerCreditTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            Map<Id,Customer_Credit_Info__c> oldMap = (Map<Id,Customer_Credit_Info__c>)Trigger.oldMap;
            for (Customer_Credit_Info__c csi : (List<Customer_Credit_Info__c>)Trigger.new) {
                if (Trigger.isUpdate && csi.Remaining_Credit__c!=oldMap.get(csi.Id).Remaining_Credit__c) {
                    continue;
                }
                if (System.isBatch() || System.isFuture()) {
                    continue;
                }
                if (Trigger.isUpdate) {
                    if (
                        oldMap.get(csi.Id).Actual_Credit_limit__c!=csi.Actual_Credit_limit__c ||
                        oldMap.get(csi.Id).Check_Rule__c!=csi.Check_Rule__c ||
                        oldMap.get(csi.Id).Credit_Segment__c!=csi.Credit_Segment__c ||
                        oldMap.get(csi.Id).Risk_Class__c!=csi.Risk_Class__c ||
                        oldMap.get(csi.Id).Rules__c!=csi.Rules__c ||
                        oldMap.get(csi.Id).Valid_Until__c!=csi.Valid_Until__c 
                    ) {
                        if (!Test.isRunningTest()) {
                            CustomerlimitSyncToSAP.submitToSAPFutrue(csi.Id);
                        }
                    }
                }else{
                    if (!Test.isRunningTest()) {
                            CustomerlimitSyncToSAP.submitToSAPFutrue(csi.Id);
                        }
                }
            }
        }
    }
}