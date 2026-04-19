global without sharing class ShareBillBatch implements Database.Batchable<sObject>,Database.Stateful{
    public String query;
    public List<String> orderIdList;
    global String errorMsg;
    global Datetime startTime;
    global Boolean flag;
    public ShareBillBatch(List<String> orderIdList) {
        this.startTime = System.now();
        this.flag = true;
        this.orderIdList = orderIdList;
        this.query = 'SELECT Id,Order__r.Customer__c,OwnerId FROM Invoice__c WHERE Id IN:orderIdList';
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Invoice__c> orderList) {
        try {
            for (Invoice__c order : orderList) {
                ShareDataToAccountTeam.shareData('Invoice__c', order.Id, order.Order__r.Customer__c, 'Invoice__c',order.OwnerId);
            }
        }catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('ShareBillBatch', this.flag, this.startTime, this.errorMsg);
    }
}