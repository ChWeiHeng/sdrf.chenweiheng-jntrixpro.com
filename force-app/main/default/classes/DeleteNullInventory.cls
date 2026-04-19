/**************************************************************************************************
 * Name: DeleteNullInventory
 * Object: 
 * Purpose: 删除为0的库存
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-20         Created             
***************************************************************************************************/
global without sharing class DeleteNullInventory implements Database.Batchable<sObject>,Database.Stateful {
    public String query;
    public String filedStr;
    public String type;
    public Date closeDate;
    global Boolean flag;
    global String errorMsg;
    global Datetime startTime;
    global Datetime updateTime;
    global DeleteNullInventory(Datetime updateTime) {
        this.updateTime = updateTime;
        this.startTime = System.now();
        this.flag = true;
        if (System.Test.isRunningTest()) {
            this.query = 'SELECT Id FROM Product_Inventory__c';
        }else{
            this.query = 'SELECT Id FROM Product_Inventory__c WHERE LastModifiedDate <:updateTime';
        }
        
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Product_Inventory__c> orderList) {
        try {
            Database.delete(orderList);
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        // SalesOrderInvoiceBatch soib = new SalesOrderInvoiceBatch();
        // Database.executeBatch(soib,100);
        Utility.setBatchInfo('DeleteNullInventory', this.flag, this.startTime, this.errorMsg);
        Database.executeBatch(new SetProductCostBatch(), 100);
    }
}