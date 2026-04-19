public without sharing class InvoiceTriggerHandler implements Triggers.Handler{
    public void handle() {
        // 共享数据到客户小组
        if (Trigger.isAfter && (Trigger.isinsert || Trigger.isupdate)) {
            Set<String> orderSet = new Set<String>();
            for (Invoice__c order : (List<Invoice__c>)Trigger.new) {
                orderSet.add(order.Order__c);
            }
            Map<String,String> customerMap = new Map<String,String>();
            for (Order__c ord : [SELECT Customer__c FROM Order__c WHERE Id IN:orderSet]) {
                customerMap.put(ord.Id, ord.Customer__c);
            }
            List<String> orderIdList = new List<String>();
            for (Invoice__c order : (List<Invoice__c>)Trigger.new) {
                
                if (order.Order__c != null) {
                    orderIdList.add(order.Id);
                }
                
            }
            if(!System.isBatch() && !System.isFuture()) {
                Database.executeBatch(new ShareBillBatch(orderIdList),1);
            }
        }
    }
}