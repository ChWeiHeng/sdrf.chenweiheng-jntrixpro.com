@IsTest
private class CompanyDynamicsTriggerHandlerTest {
    static testMethod void testMock(){
        Account acc = new Account();
        acc.Name = 'test acc';
        acc.Group_Name__c = '001D600001n4hjPIAQ';
        acc.Customer_Approval_Status__c = 'Approved';
        acc.Sync_Status__c = 'Synchronized';
        acc.MDG__c = false;
        insert acc;
        Company_Dynamics__c sc = new Company_Dynamics__c();
        sc.Customer__c = acc.id;
        insert sc;
    }
}