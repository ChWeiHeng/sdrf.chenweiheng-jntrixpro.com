/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-28-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-27-2025   Gerry   Initial Version
**/
public without sharing class ContentDocumentTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isbefore && Trigger.isdelete) {
            System.debug('删除逻辑');
            Set<String> cdIdSet = new Set<String>();
            Set<Id> linkedEntityIdSet = new Set<Id>();
            ContentDocument cdlAdderror;
            for (ContentDocument cdl : (List<ContentDocument>)Trigger.old) {
                cdIdSet.add(cdl.Id);
                cdlAdderror = cdl;
                
            }
            for (ContentDocumentLink cdl : [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN:cdIdSet]) {
                if (cdl.LinkedEntityId.getSobjectType() == Schema.Campaign.getSobjectType()){
                    linkedEntityIdSet.add(cdl.LinkedEntityId);
                }
            }
            if (linkedEntityIdSet.size()>0) {
                for (Campaign ca : [SELECT Id,MKT_Approval__c FROM Campaign WHERE id in:linkedEntityIdSet]) {
                    if (ca.MKT_Approval__c == 'Approved' || ca.MKT_Approval__c == 'Approving') {
                        cdlAdderror.adderror('can\'t delete this record after approval or in approving');
                    }
                }
            }
            
        }

    }
}