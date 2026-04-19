@IsTest
private class CustomerQuotaChangeTriggerHandlerTest {
    static testMethod void testMock(){
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        Insert a;
        
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '3020';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        insert csi;
        
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        
        Customer_Quota_Change__c cqc = new Customer_Quota_Change__c();
        cqc.Customer__c = a.Id;
        cqc.Post_Application_Credit__c = 1;
        cqc.Valid_After_Change_To__c = System.today();
        cqc.Rules__c = 'STANDARD';
        cqc.Risk_Class__c = 'A';
        cqc.Check_Rule__c = 'OV1';
        cqc.Credit_Segment__c = 'Z000';
        cqc.Sinosure_Credit_Limit__c = 1;
        cqc.Local_Credit_Limit__c = 1;
        Insert cqc;
        cqc.Approval_Status__c = 'Approved';
        update cqc;
    }
}