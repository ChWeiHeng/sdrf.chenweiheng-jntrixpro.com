/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 07-31-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-31-2025   Gerry   Initial Version
**/
@isTest
private class CloneQuotationControllerTest {
    
    static testMethod void testMethod1() {
        Quote__c quote = new Quote__c();
        //quote.Name = '报价测试';
        quote.Quotation_Type__c = 'HQ_Purchase';
        insert quote;
        Quote_Detail__c quoteDetail=new Quote_Detail__c();
        quoteDetail.Quote__c = quote.Id;
        quoteDetail.BU_Profit_Rate__c=-10;
        Insert quoteDetail;
        CloneQuotationController.cloneQoute(quote.Id);
        CloneQuotationController.cloneQoute('quote.Id');
    }
    
}