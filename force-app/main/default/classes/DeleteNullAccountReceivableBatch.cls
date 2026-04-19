/**************************************************************************************************
 * Name: DeleteNullAccountReceivableBatch
 * Object: 
 * Purpose: 删除为0的应收账款
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-20         Created             
***************************************************************************************************/
global without sharing class DeleteNullAccountReceivableBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    public String query;
    public String filedStr;
    public String type;
    public Date closeDate;
    global Boolean flag;
    global String errorMsg;
    global Datetime startTime;
    global DeleteNullAccountReceivableBatch() {
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT Id FROM Account_Receivable__C WHERE Amount_in_Local_Crcy__C=0';
    }

    global void execute(SchedulableContext sc) {
        DeleteNullAccountReceivableBatch svo = new DeleteNullAccountReceivableBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 100);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account_Receivable__C> orderList) {
        try {
            Database.delete(orderList);
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        // DeleteNullInventory soib = new DeleteNullInventory();
        // Database.executeBatch(soib,100);
        Utility.setBatchInfo('DeleteNullAccountReceivableBatch', this.flag, this.startTime, this.errorMsg);
    }
}