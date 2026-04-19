@isTest
private class CustomerCreditTriggerHandlerTest {
    static testMethod void testMethod1() {
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        Insert a;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        cci.Remaining_Credit__c = 10;
        update cci;
        cci.Actual_Credit_limit__c = 10;
        update cci;
        cci.Check_Rule__c = 'OV';
        update cci;
        cci.Credit_Segment__c = 'Z000';
        update cci;
        cci.Risk_Class__c = 'A';
        update cci;
        cci.Rules__c = 'STANDARD';
        update cci;
        cci.Valid_Until__c = Date.today();
        update cci;
    }
}