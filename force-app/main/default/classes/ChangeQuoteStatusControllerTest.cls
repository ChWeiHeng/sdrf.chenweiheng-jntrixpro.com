@isTest
private class ChangeQuoteStatusControllerTest {
	static testMethod void testMethod1()
	{
		Quote__c quote1 = new Quote__c();
        quote1.Quotation_Type__c = 'HQ_Purchase';
        insert quote1;

		ChangeQuoteStatusController.init(quote1.Id);
		ChangeQuoteStatusController.init('');
		ChangeQuoteStatusController.changeStatus(quote1.Id,true);
		ChangeQuoteStatusController.changeStatus('',true);
	}
    
}