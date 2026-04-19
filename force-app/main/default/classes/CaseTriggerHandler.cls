public with sharing class CaseTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            Set<String> orderItemSet = new Set<String>();
            for(Case ca : (List<Case>)Trigger.new) {
                orderItemSet.add(ca.Order_Item__c);
            }

            Map<String,Order_Item__c> oiMap = new Map<String,Order_Item__c>();
            for(Order_Item__c oi : [SELECT Id, Order__c, Order__r.Customer__c FROM Order_Item__c WHERE Id IN :orderItemSet]) {
                oiMap.put(oi.Id, oi);
            }

            // 更新Case中的订单和客户字段
            for(Case ca : (List<Case>)Trigger.new) {
                if(oiMap.containsKey(ca.Order_Item__c)) {
                    Order_Item__c oi = oiMap.get(ca.Order_Item__c);
                    ca.Order_Number__c = oi.Order__c; // 赋值订单       
                    ca.AccountId = oi.Order__r.Customer__c; // 赋值客户
                }
            }
        }
    }
}