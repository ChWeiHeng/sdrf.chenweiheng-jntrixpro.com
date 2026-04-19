/**************************************************************************************************
 * Name: SubmitOrderController
 * Object: 
 * Purpose: 销售数据batch
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-20         Created             
***************************************************************************************************/
global without sharing class SalesOrderDataBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    public String query;
    public String filedStr;
    public String type;
    public Date closeDate;
    global Boolean flag;
    global String errorMsg;
    global Datetime startTime;
    global SalesOrderDataBatch() {
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT Id,Delivery_Quantity__c,Collection_Transaction_Amount__c FROM Order_Item__c WHERE Order__r.Status__c=\'Approved\'';
    }

    global void execute(SchedulableContext sc) {
        SalesOrderDataBatch svo = new SalesOrderDataBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 100);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order_Item__c> orderList) {
        try {
            Set<String> orderIdSet = new Set<String>();
            for (Order_Item__c ord : orderList) {
                orderIdSet.add(ord.Id);
            }
            Map<Id,Order_Item__c> updateOrderItemMap = new Map<Id,Order_Item__c>();
            Map<Id,Order_Item__c> updateOrderItemInvoiceMap = new Map<Id,Order_Item__c>();
            for (AggregateResult agg : [SELECT Order_Item__c oi,SUM(Delivery_Quantity__c) dq FROM Delivery_Note__c WHERE Order_Item__c IN:orderIdSet AND (Delivery_Post_Status__c='C' OR Delivery_Post_Status__c='B') group by Order_Item__c ]){
                Order_Item__c oi = new Order_Item__c();
                oi.Id = (String)agg.get('oi');
                oi.Delivery_Quantity__c = (Decimal)agg.get('dq');
                
                updateOrderItemMap.put(oi.Id, oi);
            }
            for (AggregateResult agg : [SELECT Order_Item__c oi,SUM(Invoice_Quantity__c) quNum FROM Billing__c WHERE Order_Item__c IN:orderIdSet AND Billing_Status__c='C' group by Order_Item__c ]){
                // if (updateOrderItemMap.get((String)agg.get('oi'))!=null) {
                //     updateOrderItemMap.get((String)agg.get('oi')).Bill_Quantity__c = (Decimal)agg.get('quNum');
                // }else{
                    Order_Item__c oi = new Order_Item__c();
                    oi.Id = (String)agg.get('oi');
                    // oi.Collection_Transaction_Amount__c = (Decimal)agg.get('sta');
                    oi.Bill_Quantity__c = (Decimal)agg.get('quNum');
                    updateOrderItemInvoiceMap.put(oi.Id, oi);
                // }
                
            }

            Map<Id,Order_Item__c> updateOrderItemTransactionMap = new Map<Id,Order_Item__c>();
            Set<String> billIdSet = new Set<String>();
            for (Billing__c bi : [SELECT Id,Collection_Transaction_Amount__c,Billing_Num__c,Order__c,Order_Item__c FROM Billing__c WHERE Order_Item__c IN:orderIdSet AND Billing_Status__c='C']) {
                if (billIdSet.contains(bi.Billing_Num__c)) {
                    continue;
                }
                if (!updateOrderItemTransactionMap.containskey(bi.Order_Item__c)) {
                    Order_Item__c oi = new Order_Item__c();
                    oi.Id = bi.Order_Item__c;
                    oi.Collection_Transaction_Amount__c = bi.Collection_Transaction_Amount__c;
                    updateOrderItemTransactionMap.put(oi.Id, oi);
                }else{
                    if (updateOrderItemTransactionMap.get(bi.Order_Item__c).Collection_Transaction_Amount__c==null) {
                        updateOrderItemTransactionMap.get(bi.Order_Item__c).Collection_Transaction_Amount__c = 0;
                    }
                    updateOrderItemTransactionMap.get(bi.Order_Item__c).Collection_Transaction_Amount__c += bi.Collection_Transaction_Amount__c==null?0:bi.Collection_Transaction_Amount__c;
                }
                billIdSet.add(bi.Billing_Num__c);
            }
            for(Order_Item__c ord : orderList) {
                if(updateOrderItemMap.get(ord.Id)!=null) {
                    ord.Delivery_Quantity__c = updateOrderItemMap.get(ord.Id).Delivery_Quantity__c;
                }else{
                    ord.Delivery_Quantity__c = 0;
                }
                if(updateOrderItemInvoiceMap.get(ord.Id)!=null) {
                    ord.Bill_Quantity__c = updateOrderItemInvoiceMap.get(ord.Id).Bill_Quantity__c;
                }else{
                    ord.Bill_Quantity__c = 0;
                }
                if(updateOrderItemTransactionMap.get(ord.Id)!=null) {
                    ord.Collection_Transaction_Amount__c = updateOrderItemTransactionMap.get(ord.Id).Collection_Transaction_Amount__c;
                }else{
                    ord.Collection_Transaction_Amount__c = 0;
                }
               
            }
            Utility.IgnoreAction(true,false,'SalesOrderDataBatch'); 
            Update orderList;
            Utility.IgnoreAction(false,false,'SalesOrderDataBatch'); 
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        SalesOrderInvoiceBatch soib = new SalesOrderInvoiceBatch();
        Database.executeBatch(soib,100);
        Utility.setBatchInfo('SalesOrderDataBatch', this.flag, this.startTime, this.errorMsg);
    }
}