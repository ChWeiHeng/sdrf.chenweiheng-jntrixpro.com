/**************************************************************************************************
 * Name: GetProductNumberBatch
 * Object: 
 * Purpose: 定时通知订单关闭
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-10-20         Created             
***************************************************************************************************/
global without sharing class CloseOrderNotificaionBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful,Schedulable {
    public String query;
    global String errorMsg;
    global Datetime startTime;
    global Boolean flag;
    global CloseOrderNotificaionBatch() {
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT OwnerId,SAP_Order_Code__c,Id,Status__c,Approve_Date__c,SAP_Order__c,Sales_Org__c,Deliver_Plant__c FROM Order__c WHERE Status__c=\'Approved\' AND Delivery_Amount__c=0 AND Sync_Status__c=\'Synchronized\' AND SAP_Order__c=false';
    }

    global void execute(SchedulableContext sc) {
        CloseOrderNotificaionBatch svo = new CloseOrderNotificaionBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 50);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order__c> orList) {
        try {
            CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
            List<Order__c> updateList = new List<Order__c>();
            for (Order__c order : orList) {
                Integer days = Date.today().daysBetween(order.Approve_Date__c);
                Boolean flag = false;
                if (order.Sales_Org__c == '3020' && order.Deliver_Plant__c == '3020') {//mx C
                    Integer dayDefault = Integer.valueOf(System.Label.MXFIDays);
                    if (days>dayDefault) {
                        flag = true;
                    }
                }
                if (order.Sales_Org__c == '3010' && order.Deliver_Plant__c == '3011') {//mx C+
                    Integer dayDefault = Integer.valueOf(System.Label.MXFIRAMXDays);
                    if (days>dayDefault) {
                        flag = true;
                    }
                }

                if (order.Sales_Org__c == '3010' && order.Deliver_Plant__c == '3010') {//mx B
                    Integer dayDefault = Integer.valueOf(System.Label.MXFIRAMXDays);
                    if (days>dayDefault) {
                        flag = true;
                    }
                }

                if (order.Sales_Org__c == '5130' && order.Deliver_Plant__c == '5130') {
                    Integer dayDefault = Integer.valueOf(System.Label.ARFI_BDays);
                    if (days>dayDefault) {
                        flag = true;
                    }
                }
                if (order.Sales_Org__c == '5070' && order.Deliver_Plant__c == '5070') {
                    Integer dayDefault = Integer.valueOf(System.Label.ARFI_BDays);
                    if (days>dayDefault) {
                        flag = true;
                    }
                }
                if (flag) {
                    CustomNotificationFromApex.notifyUsers(
                        notificationType, 
                        new Set<String>{order.OwnerId}, //发送通知给谁
                        order.Id, //通知点击后跳转到什么数据上
                        System.Label.NotficationOrderTitle, //标题
                        '['+order.SAP_Order_Code__c+']'+System.Label.NotficationOrderBody//内容
                    );
                    order.NotificationClose__c = true;
                    updateList.add(order);
                }
            }
            Utility.IgnoreAction(true,false,'CloseOrderNotificaionBatch'); 
            Database.Update(updateList);
            Utility.IgnoreAction(false,false,'CloseOrderNotificaionBatch'); 
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('CloseOrderNotificaionBatch', this.flag, this.startTime, this.errorMsg);
        
    }
}