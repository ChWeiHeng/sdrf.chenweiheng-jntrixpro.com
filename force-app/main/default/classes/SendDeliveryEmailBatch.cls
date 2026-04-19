/**************************************************************************************************
 * Name: SendDeliveryEmailBatch
 * Object: 
 * Purpose: 发送发货信息
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-20         Created             
***************************************************************************************************/
global without sharing class SendDeliveryEmailBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    public String query;
    public String filedStr;
    public String type;
    public Date closeDate;
    global Boolean flag;
    global String errorMsg;
    global Datetime startTime;
    global SendDeliveryEmailBatch() {
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT Id FROM Order__c WHERE Status__c=\'Approved\' AND Sync_Status__c=\'Synchronized\'';
    }

    global void execute(SchedulableContext sc) {
        SendDeliveryEmailBatch svo = new SendDeliveryEmailBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 100);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order__c> orderList) {
        try {
            Set<String> orderIdSet = new Set<String>();
            for (Order__c order : orderList) {
                orderIdSet.add(order.Id);
            }
            for (Order__c order : [SELECT Id,(SELECT Order__r.Name,Order__r.Email__c,Delivery_Quantity__c,Id,Order__r.Customer__r.Name,Order__r.Customer_Shipping_Address__r.Direction__c,Delivery_Note_Num__c,Delivery_Note_Item_Num__c,Order_Item__r.Commodity__r.Name,Order_Item__r.Sales_Unit_Text__c,Order_Item__r.Material_Number__c FROM Delivery_Note1__r WHERE Is_Note__c=false AND (Delivery_Post_Status__c='C' OR Delivery_Post_Status__c='B')) FROM Order__c WHERE Id IN:orderIdSet]) {
                if (order.Delivery_Note1__r != null && order.Delivery_Note1__r.size()>0) {
                    SendEmailDeliveryOrder.sendEmail(order.Delivery_Note1__r);
                }
            }
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('SendDeliveryEmailBatch', this.flag, this.startTime, this.errorMsg);
    }
}