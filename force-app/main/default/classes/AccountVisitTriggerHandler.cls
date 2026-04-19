/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-30-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-27-2025   Gerry   Initial Version
**/
public without sharing class AccountVisitTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isAfter && Trigger.isInsert)
        {
            List<Event> eventList = new List<Event>();
            for (Account_Visit__c accVisit : (List<Account_Visit__c>)Trigger.new)
            {
                Event event=new Event();
                event.Subject = accVisit.Name+' Customer Visit';
                event.OwnerId = accVisit.OwnerId;
                event.WhatId = accVisit.Id;
                event.StartDateTime = accVisit.Start_Date__c;
                event.EndDateTime = accVisit.Finish_Date__c;
                event.ReminderDateTime=accVisit.Start_Date__c-Integer.valueOf(system.label.AccountVisitRemindDay);
                event.IsReminderSet = true;
                eventList.add(event);
                if(accVisit.Comment__c != null)
                {
                     //accVisit.adderror('Only  Creator Leader Can Edit Comment');
                     accVisit.adderror(System.Label.AccVisitInsertUpdateError);
                }
            }
            if (eventList.size() > 0 && !Test.isRunningTest()) 
            {
                System.debug('eventList==>' + eventList);
                insert eventList;
            }
                //审批结果通知
                /*if(quote.Approval_Status__c == 'Approved' && quote.Approval_Status__c!=oldMap.get(quote.Id).Approval_Status__c) {
                    Utility.notificationUserTitle(uSet,quote.Id,System.Label.Quote_Approved_Title,System.Label.Quote_Approved_Title+quote.Name);
                }*/
        }
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        {
            Map<Id,Account_Visit__c> oldMap = (Map<Id,Account_Visit__c>)Trigger.oldMap;
            Set<String> salesOrgSet = new Set<String>();
            Set<String> plantSet = new Set<String>();
            Set<String> yearSet = new Set<String>();
            for (Account_Visit__c accVisit : (List<Account_Visit__c>)Trigger.new)
            {   
                accVisit.Start_Date__c = Datetime.newInstance(accVisit.Visit_Date__c.Year(), accVisit.visit_Date__c.month(), accVisit.visit_Date__c.day(), 8, 0,0 );
                accVisit.Finish_Date__c = Datetime.newInstance(accVisit.Visit_Date__c.Year(), accVisit.visit_Date__c.month(), accVisit.visit_Date__c.day(), 23, 59,59 );
                salesOrgSet.add(accVisit.Sales_Org__c);
                plantSet.add(accVisit.Plant__c);
                yearSet.add(String.valueOf(accVisit.Start_Date__c.Year()));
                
            }
            Map<String,String>  salesForMap= new Map<String,String>();
            for(Sales_Forecast_Summary__c sfs:[SELECT Id,Sales_Org__c,Delivery_Plant__c,Year__c FROM Sales_Forecast_Summary__c WHERE Sales_Org__c  IN:salesOrgSet AND Delivery_Plant__c IN:plantSet AND Year__c IN:yearSet])
            {
                salesForMap.put(sfs.Sales_Org__c+'_'+sfs.Delivery_Plant__c+'_'+sfs.Year__c,sfs.Id);
            }
            System.debug('salesForMap==>' + salesForMap);
            for (Account_Visit__c accVisit : (List<Account_Visit__c>)Trigger.new)
            {
                String salesForString=accVisit.Sales_Org__c+'_'+accVisit.Plant__c+'_'+accVisit.Start_Date__c.Year();
                if(salesForMap.get(salesForString) != null){
                    accVisit.Sales_Forecast__c=salesForMap.get(salesForString);
                }else{
                    //accVisit.addError('No Map Sales Forecast');
                   // accVisit.addError(System.Label.NoMapSalesForecastError);
                }
                if(Trigger.isUpdate && accVisit.Manager__c !=System.UserInfo.getUserId() && oldMap.get(accVisit.Id).Comment__c != accVisit.Comment__c)
                {
                     //accVisit.adderror('Only  Creator Leader Can Edit Comment');
                     accVisit.adderror(System.Label.AccVisitInsertUpdateError);
                }
            }
        }
        if (Trigger.isAfter && Trigger.isupdate)
        {
            Map<Id,Account_Visit__c> oldMap = (Map<Id,Account_Visit__c>)Trigger.oldMap;
            CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
            for (Account_Visit__c accVisit : (List<Account_Visit__c>)Trigger.new)
            {
                if(oldMap.get(accVisit.Id).Comment__c != accVisit.Comment__c || System.Test.isRunningTest())
                {
                    CustomNotificationFromApex.notifyUsers(
                    notificationType, 
                    new Set<String>{accVisit.OwnerId}, //发送通知给谁
                    accVisit.Id, //通知点击后跳转到什么数据上
                    'Account Visist Comment Adjust', //标题
                    'Account Visist '+accVisit.Name+' '+System.Label.CustometVisitCommentNotice                    //内容
                    );
                }
            }
            
        }

        // if(Trigger.isbefore && Trigger.isupdate) {//校验是否有附件

        //     Set<String> recordIds = new Set<String>();
        //     Set<String> accIds = new Set<String>();
        //     Map<Id,Account_Visit__c> oldMap = (Map<Id,Account_Visit__c>)Trigger.oldMap;
        //     for (Account_Visit__c accVisit : (List<Account_Visit__c>)Trigger.new){
        //         if (accVisit.Visit_Status__c=='Completed' && oldMap.get(accVisit.Id).Visit_Status__c!=accVisit.Visit_Status__c) {
        //             List<ContentDocumentLink> cdl = [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:accVisit.Id];
        //             if(cdl.size()==0){
        //                 // Please confirm whether to upload the attachment
        //                 accVisit.addError(System.Label.VisitFileError);
        //             }
        //         }
        //     }
        // }
    }
}