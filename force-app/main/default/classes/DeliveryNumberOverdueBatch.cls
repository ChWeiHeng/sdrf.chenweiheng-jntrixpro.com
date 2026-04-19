/**
 * @description       : The function is used to send notice to the Delivery Number owner who haven't upload invoice over 20 days
 * @author            : Niko
 * @group             : 
 * @last modified on  : 01-27-2026
 * @last modified by  : Gerry
**/

global without sharing class DeliveryNumberOverdueBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
    public String query;
    global String errorMsg;
    global Datetime startTime;
    global Boolean flag;

    public DeliveryNumberOverdueBatch() {
        this.query = 'SELECT Id, Name, Is_Invoice_Uploaded__c, Over_20days__c,Order__r.Deliver_Plant__c FROM DeliveryNumber__c WHERE Delivery_Post_Status__c=\'C\' AND Is_Invoice_Uploaded__c = false AND Over_20days__c = true AND (Order__r.Deliver_Plant__c=\'3010\' OR Order__r.Deliver_Plant__c=\'3020\' OR Order__r.Deliver_Plant__c=\'3011\')';
        this.startTime = System.now();
        this.flag = true;
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new DeliveryNumberOverdueBatch(), 20);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<DeliveryNumber__c> dnList) {
        try {
            CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
            Map<String,Set<String>> ownerMap = new Map<String,Set<String>>();
            ownerMap.put('3010', new Set<String>());
            ownerMap.put('3020', new Set<String>());
            for (GroupMember gm : [SELECT Id,UserOrGroupId,Group.DeveloperName FROm GroupMember WHERE Group.DeveloperName ='MX_Logistics3010' OR Group.DeveloperName ='MX_Logistics3020']) {
                if (gm.Group.DeveloperName == 'MX_Logistics3010') {
                    ownerMap.get('3010').add(gm.UserOrGroupId);
                } 
                if (gm.Group.DeveloperName == 'MX_Logistics3020'){
                    ownerMap.get('3020').add(gm.UserOrGroupId);
                }
            }
            for (DeliveryNumber__c dn : dnList) {
                String NOTICE_SUBJECT = System.label.DeliveryAttachment+' ' + dn.Name;
                String noticeBody = System.Label.DeliveryAttachmentBody.replace('[xx]',dn.Name);
                Set<String> notificationSet = new Set<String>();
                if (dn.Order__r.Deliver_Plant__c == '3010' || dn.Order__r.Deliver_Plant__c == '3011') {
                    notificationSet.addAll(ownerMap.get('3010'));
                }
                if (dn.Order__r.Deliver_Plant__c == '3020') {
                    notificationSet.addAll(ownerMap.get('3020'));
                }
                CustomNotificationFromApex.notifyUsers(
                    notificationType,
                    notificationSet,
                    dn.Id,
                    NOTICE_SUBJECT,
                    noticeBody
                );
            }
        }catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('DeliveryNumberOverdueBatch', this.flag, this.startTime, this.errorMsg);
    }
}