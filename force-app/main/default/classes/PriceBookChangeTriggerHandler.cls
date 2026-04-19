/**
 * @description       : 价格手册trigger
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 06-10-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-09-2025   Gerry   Initial Version
**/
public without sharing class PriceBookChangeTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isAfter && (Trigger.isUpdate)) {
            List<Price_Book_Item__c> pbiList = new List<Price_Book_Item__c>();
            Map<Id,Price_Book__c> oldMap = (Map<Id,Price_Book__c>)Trigger.oldMap;
            Set<String> pbIdSet = new Set<String>();
            for (Price_Book__c pbd : (List<Price_Book__c>)Trigger.New) {
                if(pbd.Status__c == 'Approved' && oldMap.get(pbd.Id).Status__c != pbd.Status__c) {
                    pbIdSet.add(pbd.Id);
                }
            }

            for(Price_Book_Item__c pbi : [SELECT Id,Is_Changing__c FROM Price_Book_Item__c WHERE Price_Book__c IN:pbIdSet AND Is_Changing__c=true]) {
                pbi.Is_Changing__c = false;
                pbiList.add(pbi);
            }
            if(pbiList.size()>0) {
                Database.Update(pbiList);
            }
        }

        if (Trigger.isBefore && (Trigger.isUpdate)) {
            List<Price_Book_Item__c> pbiList = new List<Price_Book_Item__c>();
            Map<Id,Price_Book__c> oldMap = (Map<Id,Price_Book__c>)Trigger.oldMap;
            Set<String> pbIdSet = new Set<String>();
            for (Price_Book__c pbd : (List<Price_Book__c>)Trigger.New) {
                if(pbd.Status__c == 'Approving' && oldMap.get(pbd.Id).Status__c != pbd.Status__c && pbd.No_Price_Item_Count__c != 0) {
                    //Some price book item does not have price,can't submit
                    pbd.addError(System.Label.PriceBookNoPrice);
                }
            }
        }

    }
}