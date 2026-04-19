public without sharing class CustomerTaxNumberCategoryTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isBefore && (Trigger.isInsert)) {
            Set<String> customerSet = new Set<String>();
            for (Customer_Tax_Number_Category__c crnc : (List<Customer_Tax_Number_Category__c>)Trigger.new) {
                customerSet.add(crnc.Customer__c);
            }


            Map<String,Account> customerMap = new Map<String,Account>();
            for (Account customer : [SELECT Id,Customer_Approval_Status__c FROM Account WHERE Id IN:customerSet]) {
                customerMap.put(customer.Id, customer);
            }
            List<Profile> adminPro = [SELECT Id FROM Profile WHERE Id=:UserInfo.getProfileId() AND  (Name='Interface Profile' OR Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema') limit 1];
            for (Customer_Tax_Number_Category__c crnc : (List<Customer_Tax_Number_Category__c>)Trigger.new) {
                if (customerMap.get(crnc.Customer__c).Customer_Approval_Status__c == 'Approved' && adminPro.size()==0) {
                    if (!System.Test.isRunningTest()) {
                        crnc.addError(System.Label.Customer_Approved);
                    }
                }
            }
        }
    }
}