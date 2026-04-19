@IsTest
private  class QuoteTriggerHandlerTest {
	static testMethod void testMock(){
		Quote__c quote=new Quote__c();
        quote.Quotation_Type__c='HQ_Purchase';
		insert quote;
        Quote_Detail__c quoteDetail=new Quote_Detail__c();
        quoteDetail.Quote__c = quote.Id;
        quoteDetail.BU_Profit_Rate__c=-10;
        //quoteDetail.Price_List__c=priceList.Id;
        Insert quoteDetail;
        
        quote.Approval_Status__c='Approved';
		update quote;
	}
    
}