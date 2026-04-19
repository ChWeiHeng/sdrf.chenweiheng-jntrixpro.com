global without sharing class ShareOrderBatch implements Database.Batchable<sObject>,Database.Stateful{
    public String query;
    public List<String> orderIdList;
    global String errorMsg;
    global Datetime startTime;
    global Boolean flag;
    public ShareOrderBatch(List<String> orderIdList) {
        this.startTime = System.now();
        this.flag = true;
        this.orderIdList = orderIdList;
        this.query = 'SELECT Id,Customer__c,OwnerId FROM Order__c WHERE Id IN:orderIdList';
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order__c> orderList) {
        try {
            for (Order__c order : orderList) {
                ShareDataToAccountTeam.shareData('Order__c', order.Id, order.Customer__c, 'Order__c',order.OwnerId);
            }
        }catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('ShareOrderBatch', this.flag, this.startTime, this.errorMsg);
    }
}