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
global without sharing class GenerateDeliveryNoteBatch  implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    public String query;
    global String errorMsg;
    global Datetime startTime;
    global Boolean flag;
    global GenerateDeliveryNoteBatch() {
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT Order__c,Delivery_Note_Num__c,Delivery_Category__c,Creator_Delivery__c,Creator_Delivery_Date__c,Creator_Delivery_Time__c,Delivery_Post_Date__c,Delivery_Post_Status__c,POD_Status__c FROM Delivery_Note__c';
    }
 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Delivery_Note__c> dnList) {
        try {
            Map<String,DeliveryNumber__c> dnPaInserList = new Map<String,DeliveryNumber__c>();
            for (Delivery_Note__c dn : dnList) {
                DeliveryNumber__c dnPa = new DeliveryNumber__c();
                dnPa.Delivery_Note_Num__c = dn.Delivery_Note_Num__c;
                dnPa.Delivery_Category__c = dn.Delivery_Category__c;
                dnPa.Creator_Delivery__c = dn.Creator_Delivery__c;
                if (dn.Creator_Delivery_Date__c != null) {
                    dnPa.Creator_Delivery_Date__c = Date.valueOf(dn.Creator_Delivery_Date__c);
                }
                
                dnPa.Creator_Delivery_Time__c = dn.Creator_Delivery_Time__c;
                dnPa.Delivery_Post_Date__c = dn.Delivery_Post_Date__c;
                dnPa.Delivery_Post_Status__c = dn.Delivery_Post_Status__c;
                dnPa.POD_Status__c = dn.POD_Status__c;
                dnPa.External_Id__c = dn.Delivery_Note_Num__c;
                dnPa.Order__c = dn.Order__c;
                dnPaInserList.put(dnPa.External_Id__c,dnPa);
            }
            if (dnPaInserList.size()>0) {
                Database.upsert(dnPaInserList.values(),DeliveryNumber__c.External_Id__c);
            }
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('GenerateDeliveryNoteBatch', this.flag, this.startTime, this.errorMsg);
        DeliveryNoteItemToDeliveryNote svo = new DeliveryNoteItemToDeliveryNote();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 100);
    }
}