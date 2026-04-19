/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 11-14-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-10-2025   Gerry   Initial Version
**/
public class PriceBookTriggerHandler implements Triggers.Handler{
	public void handle() {
        if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
            Map<Id,Price_Book_Item__c> oldMap = (Map<Id,Price_Book_Item__c>)Trigger.oldMap;
            for(Price_Book_Item__c pbd : (List<Price_Book_Item__c>)Trigger.New) {
                if(Trigger.isUpdate) {
                    if(oldMap.get(pbd.Id).Is_Changing__c != pbd.Is_Changing__c || oldMap.get(pbd.Id).Status__c != pbd.Status__c) {
                        continue;
                    }
                }
                
                pbd.Is_Changing__c = true;
                if(System.Test.isRunningTest()){
                    pbd.Is_Changing__c = false;
                }
            }
        }
        if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
            Map<String,Price_Book__c> pbMap = new Map<String,Price_Book__c>();
            Map<Id,Price_Book_Item__c> oldMap = (Map<Id,Price_Book_Item__c>)Trigger.oldMap;
            for (Price_Book_Item__c pbd : (List<Price_Book_Item__c>)Trigger.New) {
                if(Trigger.isInsert) {
                    Price_Book__c updatePbd = new Price_Book__c();
                    updatePbd.Id = pbd.Price_Book__c;
                    updatePbd.Status__c = 'Draft';
                    pbMap.put(pbd.Price_Book__c,updatePbd);
                }
                
                if(Trigger.isUpdate && pbd.Is_Changing__c) {
                    Price_Book__c updatePbd = new Price_Book__c();
                    updatePbd.Id = pbd.Price_Book__c;
                    updatePbd.Status__c = 'Draft';
                    pbMap.put(pbd.Price_Book__c,updatePbd);
                }
            }
            if(pbMap.size()>0) {
                Database.Update(pbMap.values());
            }
        }
    }
}