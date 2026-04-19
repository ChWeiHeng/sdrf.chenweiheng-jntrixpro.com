public without sharing class CustomerTaxCategoryTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isAfter && Trigger.isUpdate) {
            for (Customer_Tax_Category__c ctc : (List<Customer_Tax_Category__c>)Trigger.new) {
                if(
                    ctc.Is_Sync__c &&

                    ((Customer_Tax_Category__c)Trigger.oldMap.get(ctc.Id)).Tax_Category__c != ctc.Tax_Category__c 
                    && !System.isBatch() && !System.isFuture()
                ) {
                    CustomerSalesInfoSyncToSAP.submitToSAPFutrue(ctc.Sales_View__c,'U');
                }
            }
        }
    }
}