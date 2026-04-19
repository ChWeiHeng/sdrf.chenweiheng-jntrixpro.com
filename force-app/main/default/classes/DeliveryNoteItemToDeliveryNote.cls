/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 01-23-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   01-23-2026   Gerry   Initial Version
**/
global without sharing class DeliveryNoteItemToDeliveryNote implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    public String query;
    global String errorMsg;
    global Datetime startTime;
    global Boolean flag;
    global DeliveryNoteItemToDeliveryNote() {
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT Id,Delivery_Note_Num__c FROM Delivery_Note__c';
    }
 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Delivery_Note__c> dnList) {
        try {
            
            for (Delivery_Note__c dn : dnList) {
                DeliveryNumber__c dnPa = new DeliveryNumber__c();
                dnPa.External_Id__c = dn.Delivery_Note_Num__c;
                dn.Delivery_Number__r = dnPa;
            }
            if (dnList.size()>0) {
                Database.upsert(dnList);
            }
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('DeliveryNoteItemToDeliveryNote', this.flag, this.startTime, this.errorMsg);
    }
}