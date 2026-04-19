/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 04-07-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-07-2026   Gerry   Initial Version
**/
global without sharing class CloseOrderBatch implements Database.Batchable<sObject>,Database.Stateful{
    public String query;
    global Boolean flag;
    global String errorMsg;
    global Datetime startTime;
    global List<String> orderItemNumberList;
    global CloseOrderBatch(String orderItemNumber) {
        this.startTime = System.now();
        this.orderItemNumberList = orderItemNumber.split(',');
        this.flag = true;
        this.query = 'SELECT Id FROM Order_Item__c WHERE Name IN:orderItemNumberList';
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Order_Item__c> orderList) {
        for (Order_Item__c oi : orderList) {
            CloseOrderController.Output out = CloseOrderController.init(oi.Id);
            if (!out.isSucess) {
                this.flag = false;
                this.errorMsg = out.errorMsg;
                continue;
            }
            CloseOrderController.closeOrder(oi.Id, '01');
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}