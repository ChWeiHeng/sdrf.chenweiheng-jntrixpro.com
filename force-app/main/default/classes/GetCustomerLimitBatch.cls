/**************************************************************************************************
 * Name: GetCustomerLimitBatch
 * Object: 
 * Purpose: 定时拉取客户剩余信用额度
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-20         Created             
***************************************************************************************************/
global without sharing class GetCustomerLimitBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful,Schedulable {
    public String query;
    global String errorMsg;
    global Datetime startTime;
    global Boolean flag;
    global GetCustomerLimitBatch() {
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT Id,MDG_Customer_Code__c FROM Account WHERE CreditNumber__c>0 AND MDG_Customer_Code__c!=null';
    }

    global void execute(SchedulableContext sc) {
        GetCustomerLimitBatch svo = new GetCustomerLimitBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 50);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accList) {
        try {
            List<String> orderIdSet = new List<String>();
            for (Account acc : accList) {
                orderIdSet.add(acc.MDG_Customer_Code__c);
            }
            GetCustomerlimitFROMSAP.submitToSAP(orderIdSet,'USD','');
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('GetCustomerLimitBatch', this.flag, this.startTime, this.errorMsg);
    }
}