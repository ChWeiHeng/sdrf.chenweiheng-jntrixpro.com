public without sharing class SalesForecastSummaryTriggerHandler implements Triggers.Handler {
    public void handle() {
        if (Trigger.isbefore && (Trigger.isUpdate)) {
            String sfsId = '';
            Map<Id,Sales_Forecast_Summary__c> oldMap = (Map<Id,Sales_Forecast_Summary__c>)Trigger.oldMap;
            for (Sales_Forecast_Summary__c sfs : (List<Sales_Forecast_Summary__c>)Trigger.new) {
                if (sfs.Status__c == 'Approved' && oldMap.get(sfs.Id).Status__c!=sfs.Status__c) {
                    sfsId = sfs.Id;
                }
                
            }
            Decimal totalForecastAmount = 0;
            if (String.isNotBlank(sfsId)) {
                List<Sales_Forcast__c> sfList = [SELECT Id,Monthly_Forecast_USD__c FROM Sales_Forcast__c WHERE Sales_Forecast_Summary__c =: sfsId];
                for (Sales_Forcast__c sf : sfList) {
                    if (sf.Monthly_Forecast_USD__c!=null) {
                        totalForecastAmount += sf.Monthly_Forecast_USD__c;
                    }
                    
                }
            }
            if (totalForecastAmount > 0) {
                for (Sales_Forecast_Summary__c sfs : (List<Sales_Forecast_Summary__c>)Trigger.new) {
                    sfs.Total_Forecast_Amount_USD__c = totalForecastAmount;
                }
            }
            
            
            
        }
    }
}