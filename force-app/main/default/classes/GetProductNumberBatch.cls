/**************************************************************************************************
 * Name: GetProductNumberBatch
 * Object: 
 * Purpose: 定时拉取库存
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-20         Created             
***************************************************************************************************/
global without sharing class GetProductNumberBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful,Schedulable {
    public String query;
    global String errorMsg;
    global Datetime startTime;
    global Boolean flag;
    global List<String> orgList;
    global GetProductNumberBatch() {
        orgList = System.Label.ORGLabel.split(';');
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT Id FROM Product_Sales_Info__c WHERE Sales_Organization__c IN:orgList';
    }

    global void execute(SchedulableContext sc) {
        GetProductNumberBatch svo = new GetProductNumberBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 50);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Product_Sales_Info__c> accList) {
        try {
            List<String> orderIdSet = new List<String>();
            for (Product_Sales_Info__c acc : accList) {
                orderIdSet.add(acc.Id);
            }
            ProductSalesInfoSyncToSAP.submitToSAP(orderIdSet);
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('GetProductNumberBatch', this.flag, this.startTime, this.errorMsg);
        DeleteNullInventory soib = new DeleteNullInventory(this.startTime);
        Database.executeBatch(soib,100);
        // Database.executeBatch(new SetProductCostBatch(), 100);
    }
}