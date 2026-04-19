@isTest
private class FillInPriceListControllerTest {
	 static testMethod void testMethod1() {
	 	Quote__c quote1 = new Quote__c();
        //quote1.Name = '报价测试';
        quote1.Quotation_Type__c = 'HQ_Purchase';
        insert quote1;

        Quote_Detail__c quoteDetail=new Quote_Detail__c();
        quoteDetail.Quote__c = quote1.Id;
        quoteDetail.BU_Profit_Rate__c=-10;
        Insert quoteDetail;

        Price_List__c priceList=new Price_List__c();
        priceList.Name=quote1.Name;
        insert priceList;

        FillInPriceListController.setValue(quoteDetail.Id,priceList.Id);
	 }
    
}