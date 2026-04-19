/*
* Name: SalesVirtualForecastDataBatch
* Date: 2024-08-23
* Creator: gerry
* Description: 删除记录虚拟客户销量
* History: 
*------------------------------------------------
* Version    Last Modified By     Desription
* v1         Gerry              Create
*------------------------------------------------*/
global without sharing class DeleteSalesVirtualForecastDataBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    String month = '';
    String year = '';
    public String query;
    global Boolean flag;
    global String errorMsg;
    global Datetime startTime;
    global Boolean runCu;
    global DeleteSalesVirtualForecastDataBatch(String year, String month, Boolean runCu) {
        this.month = month;
        this.year = year;
        this.runCu = runCu;
        this.flag = true;
    }

    global DeleteSalesVirtualForecastDataBatch() {
        this.runCu = false;
        this.startTime = System.now();
        this.flag = true;
        Date day = System.today();
        if (day.Day() == 1 || Test.isRunningTest()) {
            if (day.Month() == 1) {
                Integer yeraInt = day.Year() - 1;
                this.year = yeraInt + '';
                this.month = '12';
            }else{
                Integer monthInt = day.Month() - 1;
                this.month = monthInt + '';
                this.year = day.Year() + '';
            }
        }else{
            this.month = day.Month() + '';
            this.year = day.Year() + '';
        }
        if (Test.isRunningTest()) {
            this.month = '1';
            this.year = '2024';
        }
        //this.query = 'SELECT Id,Year__c,Month__c,Product_Name__c,Customer__c,External_Id__c,OwnerId FROM Sales_Forcast__c WHERE Month__c =:month AND Year__c =:year AND Sales_Forecast_Summary__r.Status__c=\'Approved\'';
        System.debug('this.month==>'+this.month);
        System.debug('this.year==>'+this.year);
        System.debug('this.query==>'+this.query);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        this.query = 'SELECT Sales_Forecast_Summary__r.Sales_Org__c,Id,Year__c,Month__c,Product_Name__c,Customer__c,External_Id__c,OwnerId FROM Sales_Forcast__c WHERE Month__c =:month AND Year__c =:year AND Sales_Forecast_Summary__r.Status__c=\'Approved\' AND Customer__r.Virtual_customer__c=true';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sales_Forcast__c> salesForList) {
        try {
            
            for (Sales_Forcast__c sf : salesForList) {
                sf.Monthly_Actual_USD__c = 0;
                sf.Monthly_Actual_Local_Currency__c = 0;
            }
            Update salesForList;
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('DeleteSalesVirtualForecastDataBatch', this.flag, this.startTime, this.errorMsg);
        if(this.runCu) {
            SalesVirtualForecastDataBatch svo = new SalesVirtualForecastDataBatch( this.year, this.month);

            // 每次执行多少条数据，最大200
            String jobId = Database.executeBatch(svo, 100);
        }else{
            SalesVirtualForecastDataBatch svo = new SalesVirtualForecastDataBatch();

            // 每次执行多少条数据，最大200
            String jobId = Database.executeBatch(svo, 100);
        }
        
    }
}