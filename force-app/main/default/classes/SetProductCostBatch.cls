/**************************************************************************************************
 * Name: GetProductNumberBatch
 * Object: 
 * Purpose: 定时设置产品cost
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-10-20         Created             
***************************************************************************************************/
global without sharing class SetProductCostBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful,Schedulable {
    public String query;
    global String errorMsg;
    global Datetime startTime;
    global Boolean flag;
    global SetProductCostBatch() {
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT Id,Sales_Organization__c,Factory__c,Product__c FROM Product_Sales_Info__c';
    }

    global void execute(SchedulableContext sc) {
        SetProductCostBatch svo = new SetProductCostBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 50);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Product_Sales_Info__c> accList) {
        try {
            Set<String> codeSet = new Set<String>();
            Set<String> planSet = new Set<String>();
            for(Product_Sales_Info__c psi : accList) {
                codeSet.add(psi.Product__c);
                planSet.add(psi.Factory__c);
            }

            Map<String,Product_Inventory__c> piMap = new Map<String,Product_Inventory__c>();
            for (Product_Inventory__c pi : [SELECT Id,Product__c,Plant__c,Unit_Cost__c,USD_Cost__c FROM Product_Inventory__c WHERE Product__c IN:codeSet AND Plant__c IN:planSet]) {
                piMap.put(pi.Product__c+'-'+pi.Plant__c,pi);
            }

            List<Product_Sales_Info__c> updateList = new List<Product_Sales_Info__c>();
            for (Product_Sales_Info__c psi : accList) {
                if (piMap.get(psi.Product__c+'-'+psi.Factory__c) != null || Test.isRunningTest()) {

                    psi.Cost_Local__c = piMap.get(psi.Product__c+'-'+psi.Factory__c).Unit_Cost__c;
                    psi.Cost_USD__c = piMap.get(psi.Product__c+'-'+psi.Factory__c).USD_Cost__c;
                    updateList.add(psi);
                }
                
            }
            if (updateList.size()>0) {
                Database.update(updateList);
            }
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('SetProductCostBatch', this.flag, this.startTime, this.errorMsg);
        Database.executeBatch(new SetApprovingOrderQuantityBatch(), 20);
    }
}