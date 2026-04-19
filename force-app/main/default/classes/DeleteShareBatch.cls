/**************************************************************************************************
 * Name: DeleteShareBatch
 * Object: 
 * Purpose: 删除共享数据
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-08-20         Created             
***************************************************************************************************/
global without sharing class DeleteShareBatch implements Database.Batchable<sObject>,Database.Stateful{
    global String query;
    global String userId;
    global Map<String, Schema.SObjectType> globalDescribe;
    global String obejctTyp;
    global String field;
    global Integer index;
    global String recordId;//客户Id
    global String errorMsg;
    global Boolean flag;
    global Datetime startTime;
    public DeleteShareBatch(String recordId,String userId,Integer index) {
        this.index = index;
        this.startTime = System.now();
        this.flag = true;
        DeleteShare__c ds = [SELECT id,Index__c,SQL__c FROM DeleteShare__c WHERE Index__c=:index];
        this.query = ds.SQL__c;
        this.recordId = recordId;
        this.userId = userId;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> orderList) {
        System.savepoint sp = Database.setSavepoint();
        try {
            Database.delete(orderList);
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage()+e.getLineNumber());
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        Integer indexNext = this.index+1;
        List<DeleteShare__c> sdq = [SELECT Id FROM DeleteShare__c WHERE Index__c=:indexNext];
        Utility.setBatchInfo('DeleteShareBatch:['+this.index+']'+this.recordId+':'+this.userId, this.flag, this.startTime, this.errorMsg);
        if (sdq.size()>0) {
            Database.executeBatch(new DeleteShareBatch(this.recordId,this.userId,indexNext), 100);
        }

    }
}