/**
 * @description       : 客户
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 12-10-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   12-09-2025   Gerry   Initial Version
**/
public without sharing class CustomerUpdateTriggerHandler implements Triggers.Handler{
    public void handle(){
        if (Trigger.isAfter && Trigger.isUpdate) {
            Map<Id,Customer_Update__c> oldMap = (Map<Id,Customer_Update__c>)Trigger.oldMap;
            List<Account> accUpdateList = new List<Account>();
            for (Customer_Update__c cu : (List<Customer_Update__c>)Trigger.new) {
                if (cu.Approve_Status__c == 'Approved' && cu.Approve_Status__c <> oldMap.get(cu.Id).Approve_Status__c) {
                    Account acc = new Account();
                    acc.Id = cu.Customer__c;

                    if (String.isNotBlank(cu.New_Customer_Name__c) && String.isNotEmpty(cu.New_Customer_Name__c)) {
                        acc.Name = cu.New_Customer_Name__c;
                    }
                    accUpdateList.add(acc);
                }
            }

            if (accUpdateList.size()>0) {
                Utility.isPassTriggerLogic = TRUE;//跳过校验逻辑
                Database.update(accUpdateList);
            }
        }

        if (Trigger.isbefore && Trigger.isInsert) {
            List<Account> accUpdateList = new List<Account>();
            Set<String> OwnerId = new Set<String>();
            Map<String,String> financeMap = new Map<String,String>();
            for(Finance__mdt fin : [SELECT Delivery_Pant__c,Finance__c FROM Finance__mdt]){
                financeMap.put(fin.Delivery_Pant__c, fin.Finance__c);
            }
            for (Customer_Update__c cu : (List<Customer_Update__c>)Trigger.new) {
                cu.Finance_User__c = financeMap.get(cu.Owner_Plant__c);
            }
        }
    }
}