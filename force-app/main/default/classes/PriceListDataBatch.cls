global without sharing class PriceListDataBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    public String query='SELECT Id,LastModifiedDate FROM Price_List__c WHERE Is_Delete__c=false';
    global void execute(SchedulableContext sc) {
        PriceListDataBatch svo = new PriceListDataBatch();

        // 每次执行多少条数据，最大100
        String jobId = Database.executeBatch(svo, 100);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Price_List__c> plList) {
    	List<Price_List__c> needUpdatePriceList=new List<Price_List__c>();
        try {
            for (Price_List__c pl : plList){
            	Date currentDay=Date.today();
            	Date modifyDate=Date.valueOf(pl.LastModifiedDate);
            	System.debug('currentDay:'+currentDay);
            	System.debug('modifyDate:'+modifyDate);
            	if(modifyDate<currentDay){
            		Price_List__c needUpdatePrice = new Price_List__c();needUpdatePrice.Id=pl.Id;
                    needUpdatePrice.Is_Delete__c=true;needUpdatePriceList.add(needUpdatePrice);
            	}  }
            if(needUpdatePriceList.size()>0){Database.update(needUpdatePriceList);}
        } catch (Exception e) {
            System.debug('PriceListDataBatch=>'+e.getMessage()+';行数：'+e.getLineNumber());
        }
        
    }

    global void finish(Database.BatchableContext BC) {
    }
}