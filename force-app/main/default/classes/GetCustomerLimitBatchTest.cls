@IsTest
private class GetCustomerLimitBatchTest {
    static testMethod void testMock(){
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.MDG_Customer_Code__c = '1234';
        Insert a;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        GetCustomerLimitBatch svo = new GetCustomerLimitBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 50);

        // 每次执行多少条数据，最大200
        System.schedule('Test','0 35 6 * * ? *',New GetCustomerLimitBatch());
    }
}