public without sharing class TaskTriggerHandler implements Triggers.Handler{
    public void handle() {
        /*if (Trigger.isAfter && Trigger.isDelete){
            Set<String>  accVisitSet= new Set<String>();
            Map<String, Task> ownIdTaskMap = new Map<String, Task>();
            Map<String, String> accVisitMap = new Map<String, String>();
            for(Task recordItem :(List<Task>)Trigger.old) {
            if(recordItem.WhatId.getSobjectType() == Schema.Account_Visit__c.getSObjectType()) {
                ownIdTaskMap.put(recordItem.OwnerId, recordItem);
                accVisitSet.add(recordItem.WhatId);
            }}
            for(Account_Visit__c cv:[SELECT Id,OwnerId FROM Account_Visit__c  WHERE Id IN:accVisitSet]){
                accVisitMap.put(cv.Id,cv.OwnerId);
            }
            system.debug('accVisitMap=>'+accVisitMap);
            Set<String> userIdSet=new Set<String>();
            Set<String> accVisitIdSet=new Set<String>();
            if (ownIdTaskMap.size() > 0) {
            for (String ownerId : ownIdTaskMap.keySet()) {
                Task task = ownIdTaskMap.get(ownerId);
                if(accVisitMap.get(task.WhatId) != null && accVisitMap.get(task.WhatId)==task.ownerId)
                {
                    continue;
                }
                userIdSet.add(task.ownerId);
                accVisitIdSet.add(task.WhatId);
            }
            system.debug('userIdSet=>'+userIdSet);
            system.debug('accVisitIdSet=>'+accVisitIdSet);
            List<Account_Visit__Share> deleteAccVisitShare=[SELECT Id FROM Account_Visit__Share WHERE UserOrGroupId IN: userIdSet AND ParentId IN: accVisitIdSet];
            if (deleteAccVisitShare.size() > 0) {
                delete deleteAccVisitShare;
            }
            }
        }*/
        if (Trigger.isbefore && Trigger.isDelete){
            for(Task recordItem :(List<Task>)Trigger.old) {
            if(recordItem.WhatId != null && recordItem.WhatId.getSobjectType() == Schema.Account_Visit__c.getSObjectType()) {
                system.debug('operate user:'+System.UserInfo.getUserId());
                system.debug('create user:'+recordItem.CreatedById);
                if(System.UserInfo.getUserId() != recordItem.CreatedById){
                     //at.adderror('Only CreatedBy Can Del Data');
                     recordItem.adderror(System.Label.AccVisitTaskDelError);
                }
        }
    }}
        if (Trigger.isbefore && Trigger.isUpdate){
            Map<Id,Task> oldMap = (Map<Id,Task>)Trigger.oldMap;
            for(Task recordItem :(List<Task>)Trigger.new) {
            if(recordItem.WhatId != null && recordItem.WhatId.getSobjectType() == Schema.Account_Visit__c.getSObjectType()) {
                if(System.UserInfo.getUserId() == oldMap.get(recordItem.Id).OwnerId && oldMap.get(recordItem.Id).OwnerId != recordItem.CreatedById &&(
                        oldMap.get(recordItem.Id).Content__c != recordItem.Content__c
                     || oldMap.get(recordItem.Id).Comment__c != recordItem.Comment__c
                     || oldMap.get(recordItem.Id).Priority != recordItem.Priority
                     || oldMap.get(recordItem.Id).OwnerId != recordItem.OwnerId
                     || oldMap.get(recordItem.Id).ActivityDate != recordItem.ActivityDate
                     || oldMap.get(recordItem.Id).WhatId	 != recordItem.WhatId	
                     || oldMap.get(recordItem.Id).IsReminderSet	 != recordItem.IsReminderSet	
                     
                ))
                {
                     //at.adderror('Assigned To Only Update Status Or Results');
                     recordItem.adderror(System.Label.AccVisitTaskUpdateError);
                }
            }
        }}
        if (Trigger.isbefore && Trigger.isInsert){
            User u = [SELECT Id,Profile.Name,Delivery_Plant__c FROM User WHERE Id=:System.UserInfo.getUserId()];
                for(Task recordItem :(List<Task>)Trigger.new) {
                    if(recordItem.WhatId != null && recordItem.WhatId.getSobjectType() == Schema.Account_Visit__c.getSObjectType()){
                    if (u.Delivery_Plant__c != recordItem.Owner_Delivery_Plant__c && !System.Test.isRunningTest()) {
                        //at.adderror('Cannot insert across factories data');
                        recordItem.adderror(System.Label.AccVisitTaskInsertError);
                    }
                }
            }
        }
            
        /*if (Trigger.isbefore && (Trigger.isUpdate || Trigger.isInsert)){
            Map<Id,Task> oldMap = (Map<Id,Task>)Trigger.oldMap;
            Set<String>  accVisitSet= new Set<String>();
            Set<String>  taskOwnerSet= new Set<String>();
            for(Task recordItem :(List<Task>)Trigger.new) {
                if(Trigger.isInsert || (Trigger.isUpdate && oldMap != null && oldMap.get(recordItem.Id).ownerId != recordItem.ownerId)){
                if(recordItem.WhatId.getSobjectType() == Schema.Account_Visit__c.getSObjectType()){
                    accVisitSet.add(recordItem.WhatId);
                    taskOwnerSet.add(recordItem.ownerId);
                }}
            }
            Set<String>  taskExteralIdSet= new Set<String>();
            for(Task task:[SELECT Id,WhatId,OwnerId FROM Task  WHERE WhatId IN:accVisitSet AND OwnerId IN:taskOwnerSet]){
                taskExteralIdSet.add(task.WhatId+'_'+task.OwnerId);
            }
            system.debug('taskExteralIdSet=>'+taskExteralIdSet);
            for(Task recordItem :(List<Task>)Trigger.new) {
                if(recordItem.WhatId.getSobjectType() == Schema.Account_Visit__c.getSObjectType()){
                    if(taskExteralIdSet != null && taskExteralIdSet.contains(recordItem.WhatId+'_'+recordItem.ownerId)){
                        recordItem.addError(System.Label.ExistSameTask);
                    }
                }
            }
            system.debug('accVisitSet=>'+accVisitSet);
        }*/
        if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert))
        {
            Set<String>  accVisitSet= new Set<String>();
            Map<String,String>  accVisitOwner= new Map<String,String>();
            for(Task recordItem :(List<Task>)Trigger.new) {
            if(recordItem.WhatId != null && recordItem.WhatId.getSobjectType() == Schema.Account_Visit__c.getSObjectType()){
                accVisitSet.add(recordItem.WhatId);
            }}
            for(Account_Visit__c av:[SELECT Id,OwnerId FROM Account_Visit__c WHERE Id IN:accVisitSet]){
                accVisitOwner.put(av.Id,av.OwnerId);
            }
            Map<Id,Task> oldMap = (Map<Id,Task>)Trigger.oldMap;
            Map<String, Set<String>> accVisitUserMap = new Map<String, Set<String>>();
            //Map<String, Set<String>> accVisitUserDelMap = new Map<String, Set<String>>();
            for(Task recordItem :(List<Task>)Trigger.new) {
            if(recordItem.WhatId != null && recordItem.WhatId.getSobjectType() == Schema.Account_Visit__c.getSObjectType()) {
                if(accVisitOwner.get(recordItem.WhatId) != null && accVisitOwner.get(recordItem.WhatId)==recordItem.OwnerId)
                {
                    continue;
                }
                Set<String> userSet=new Set<String>();
                //Set<String> userDelSet=new Set<String>();
                if(accVisitUserMap.get(recordItem.WhatId) != null){
                    userSet=accVisitUserMap.get(recordItem.WhatId);
                }else{
                    
                }
                userSet.add(recordItem.OwnerId);
                accVisitUserMap.put(recordItem.WhatId, userSet);

                /*if(oldMap != null){
                Task oldtask=oldMap.get(recordItem.Id);
                if(accVisitOwner.get(oldtask.WhatId) != null && accVisitOwner.get(oldtask.WhatId)==oldtask.OwnerId)
                {
                    continue;
                }
                if(accVisitUserDelMap.get(oldtask.WhatId) != null){
                    userDelSet=accVisitUserDelMap.get(oldtask.WhatId);
                }else{
                    
                }
                userDelSet.add(oldtask.OwnerId);
                accVisitUserDelMap.put(recordItem.WhatId, userDelSet);
                }*/
            }}
        system.debug('accVisitUserMap=>'+accVisitUserMap);
        //system.debug('accVisitUserDelMap=>'+accVisitUserDelMap);
        List<Account_Visit__Share> accountVisitShareList = new List<Account_Visit__Share>();
        for (String accVisitId : accVisitUserMap.keySet()) {
                Set<String> userInsertSet = accVisitUserMap.get(accVisitId);
                for(String userId:userInsertSet){
                    Account_Visit__Share accountVisitShare = new Account_Visit__Share();
                    accountVisitShare.ParentId = accVisitId;
                    accountVisitShare.UserOrGroupId = userId;
                    accountVisitShare.AccessLevel = 'Read';
                    accountVisitShare.RowCause = 'Manual';
                    accountVisitShareList.add(accountVisitShare);
                }
            }
            // Set<String>  userDelSet= new Set<String>();
            // for (String accVisitId : accVisitUserDelMap.keySet()) {
            //     userDelSet.addAll(accVisitUserDelMap.get(accVisitId));
            // }
            system.debug('accountVisitShareList=>'+accountVisitShareList);
            /*List<Account_Visit__Share> deleteAccVisitShare=[SELECT Id FROM Account_Visit__Share WHERE UserOrGroupId IN: userDelSet AND ParentId IN: accVisitUserDelMap.keySet()];
            system.debug('deleteAccVisitShare=>'+deleteAccVisitShare);
            if (deleteAccVisitShare.size() > 0) {
                delete deleteAccVisitShare;
            }*/
            if (accountVisitShareList.size() > 0) {
                upsert accountVisitShareList;
            }
        }

    }
}