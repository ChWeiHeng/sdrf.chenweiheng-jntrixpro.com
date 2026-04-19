@isTest
private class PriceListDataBatchTest {
	static testMethod void testMethod1() {

        Price_List__c priceList=new Price_List__c();
        priceList.Is_Delete__c=false;
        insert priceList;
        

        PriceListDataBatch svo = new PriceListDataBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 100);
        System.schedule('Test','0 35 6 * * ? *',New PriceListDataBatch());
	 }
    
}