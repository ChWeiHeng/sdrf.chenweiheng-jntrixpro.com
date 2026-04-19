@IsTest
private class GetProductNumberBatchTest {
    static testMethod void testMock(){
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '5130';
        psi.Delivering_Plant__c = '5130';
        Insert psi;
        GetProductNumberBatch svo = new GetProductNumberBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 50);

        System.schedule('Test','0 35 6 * * ? *',New GetProductNumberBatch());
    }
}