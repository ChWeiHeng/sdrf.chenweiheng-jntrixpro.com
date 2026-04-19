trigger SalesForecastSummaryTrigger on Sales_Forecast_Summary__c(before update) {
    new Triggers()
	.bind(Triggers.Evt.beforeupdate, new SalesForecastSummaryTriggerHandler())
    .manage();
}