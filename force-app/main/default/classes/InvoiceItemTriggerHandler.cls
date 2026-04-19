/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-26-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-26-2025   Gerry   Initial Version
**/
public without sharing class InvoiceItemTriggerHandler implements Triggers.Handler {
    public void handle() {
        //赋值月份主数据
        if(Trigger.isbefore && (Trigger.isupdate || Trigger.isInsert)) {
            Map<String,String> monthIdMap = new Map<String,String>();
            for (Month_Data__c md : [SELECT Id,Name FROM Month_Data__c]) {
                monthIdMap.put(md.Name, md.ID);
            }
            for (Billing__c bi : (List<Billing__c>)Trigger.new) {
                bi.Month_Data__c = monthIdMap.get(bi.Invoice_Date_Month__c);
            }
        }
    }
}