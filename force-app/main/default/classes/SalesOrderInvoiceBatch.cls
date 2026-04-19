/**************************************************************************************************
 * Name: SalesOrderInvoiceBatch
 * Object: 
 * Purpose: 销售发票数据
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-20         Created             
***************************  ************************************************************************/
global without sharing class SalesOrderInvoiceBatch implements Database.Batchable<sObject>,Database.Stateful {
    public String query;
    public String filedStr;
    public String type;
    public Date closeDate;
    global String errorMsg;
    global Datetime startTime;
    global Boolean flag;
    global SalesOrderInvoiceBatch() {
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT Id,Amount_of_refund__c,Invoice_Amount__c,Invoice_Amount_Net__c FROM Order__c WHERE Status__c=\'Approved\'';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order__c> orderList) {
        try {
            Set<String> orderIdSet = new Set<String>();
            for (Order__c ord : orderList) {
                orderIdSet.add(ord.Id);
            }
            Map<String,Order__c> orMap = new Map<String,Order__c>();
            for (AggregateResult agg : [SELECT Order__c oi,SUM(SAP_Total_Amount__c) sta,SUM(SAP_Total_Net__c) staNet FROM Billing__c WHERE Order__c IN:orderIdSet AND Billing_Status__c='C' group by Order__c]){
                Order__c orData = new Order__c();
                orData.Id = (String)agg.get('oi');
                orData.Invoice_Amount__c = (Decimal)agg.get('sta');
                orData.Invoice_Amount_Net__c = (Decimal)agg.get('staNet');
                orData.Amount_of_refund__c = 0;
                orMap.put(orData.Id, orData);
            }

            Map<String,Order__c> orAmountMap = new Map<String,Order__c>();
            Set<String> billIdSet = new Set<String>();
            for (Billing__c bi : [SELECT Id,Collection_Transaction_Amount__c,Billing_Num__c,Order__c FROM Billing__c WHERE Order__c IN:orderIdSet AND Billing_Status__c='C']) {
                if (billIdSet.contains(bi.Billing_Num__c)) {
                    continue;
                }
                if (bi.Collection_Transaction_Amount__c!=null) {
                    if(orAmountMap.containsKey(bi.order__c)) {
                        orAmountMap.get(bi.order__c).Amount_of_refund__c += bi.Collection_Transaction_Amount__c;
                    }else{
                        Order__c orData = new Order__c();
                        orData.Amount_of_refund__c = bi.Collection_Transaction_Amount__c;
                        orAmountMap.put(bi.order__c,orData);
                    }
                    
                    billIdSet.add(bi.Billing_Num__c);
                    // orAmountMap.put(bi.order__c,orData);
                }
            }
            for (Order__c orData : orderList) {
                if(orMap.get(orData.Id)!=null) {
                    orData.Invoice_Amount__c = orMap.get(orData.Id).Invoice_Amount__c;
                    orData.Invoice_Amount_Net__c = orMap.get(orData.Id).Invoice_Amount_Net__c;
                }else{
                    orData.Invoice_Amount__c = 0;
                    orData.Invoice_Amount_Net__c = 0;
                }
                if(orAmountMap.get(orData.Id)!=null) {
                    orData.Amount_of_refund__c = orAmountMap.get(orData.Id).Amount_of_refund__c;
                }else{
                    orData.Amount_of_refund__c = 0;
                }
                
            }
            Utility.IgnoreAction(true,false,'SalesOrderInvoiceBatch'); 
            Database.update(orderList);   
            Utility.IgnoreAction(false,false,'SalesOrderInvoiceBatch'); 
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('SalesOrderInvoiceBatch', this.flag, this.startTime, this.errorMsg);
        SalesFillUpOrderBatch svo = new SalesFillUpOrderBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 100);
    }
}