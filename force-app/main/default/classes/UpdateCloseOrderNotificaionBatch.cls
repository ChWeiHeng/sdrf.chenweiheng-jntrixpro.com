/**************************************************************************************************
 * Name: UpdateCloseOrderNotificaionBatch
 * Object: 
 * Purpose: 刷新通知数据
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-10-20         Created             
***************************************************************************************************/
global without sharing class UpdateCloseOrderNotificaionBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful,Schedulable {
    public String query;
    global String errorMsg;
    global Datetime startTime;
    global Boolean flag;
    global UpdateCloseOrderNotificaionBatch() {
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT Id,NotificationClose__c FROM Order__c WHERE NotificationClose__c=true';
    }

    global void execute(SchedulableContext sc) {
        UpdateCloseOrderNotificaionBatch svo = new UpdateCloseOrderNotificaionBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 50);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order__c> orList) {
        
        try {
            List<Order__c> updateList = new List<Order__c>();
            for (Order__c order : orList) {
                order.NotificationClose__c = false;
                updateList.add(order);
            }
            Database.Update(updateList);
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('CloseOrderNotificaionBatch', this.flag, this.startTime, this.errorMsg);
        CloseOrderNotificaionBatch svo = new CloseOrderNotificaionBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 50);
    }
}