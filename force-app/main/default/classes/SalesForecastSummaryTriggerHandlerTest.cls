@isTest
private class SalesForecastSummaryTriggerHandlerTest {
    static testMethod void testMethod1() {
        Sales_Forecast_Summary__c sfs = new Sales_Forecast_Summary__c();
        sfs.Year__c = '2024';
        sfs.Status__c = 'Draft';
        sfs.Sales_Org__c = '5130';
        insert sfs;
        sfs.Status__c = 'Approved';
        update sfs;
    }
}