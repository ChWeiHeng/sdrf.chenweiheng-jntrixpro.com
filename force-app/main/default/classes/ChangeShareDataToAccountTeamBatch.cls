global without sharing class ChangeShareDataToAccountTeamBatch implements Database.Batchable<sObject>,Database.Stateful{
    global String query;
    global String obejctTyp;
    global String recordId;
    global String accId;
    global String fieldType;
    global String ownerData; 
    global String beforeDeliveryPlant;
    global String shareObject;  
    global ChangeShareDataToAccountTeamBatch(String obejctTyp,String recordId,String accId,String fieldType,String ownerData,String beforeDeliveryPlant,String shareObject) {
        this.obejctTyp = obejctTyp;
        this.recordId = recordId;
        this.accId = accId;
        this.fieldType = fieldType;
        this.ownerData = ownerData;
        this.beforeDeliveryPlant = beforeDeliveryPlant;
        this.shareObject = shareObject;
        this.query = 'SELECT Id,UserOrGroupId FROM '+shareObject+' WHERE  ' ;
        if(obejctTyp=='Customer_Sales_Info__c'){
                this.query=this.query+'ParentId=:recordId';
            }
        if(obejctTyp=='Order__c' || obejctTyp=='Quote__c'){
                this.query=this.query+'ParentId=:recordId';
            }
        if(obejctTyp=='Contracts__c'){
                this.query=this.query+'ParentId=:recordId';
            }
        if(obejctTyp=='Invoice__c'){
                this.query=this.query+'Parent.Order__c=:recordId';
            }

        system.debug('this.query=>'+this.query);

    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> shareDeleteList) {
        System.savepoint sp = Database.setSavepoint();
        try {
            Set<String>  userSet= new Set<String>();
            for(Account_Team__c accTeam:[SELECT Id,Sales_Rep_Delivery_Plant__c,Sales_Rep__c FROM Account_Team__c WHERE Customer__c=:this.accId AND Sales_Rep_Delivery_Plant__c=:this.beforeDeliveryPlant])
            {
                userSet.add(accTeam.Sales_Rep__c);
            }
            System.debug('userSet=>'+userSet);
            List<SObject> needDelShareList = new List<SObject>();
            for(SObject sb:shareDeleteList)
            {
                String userId=String.valueOf(sb.get('UserOrGroupId'));
                if (userSet != null && userSet.contains(userId)  && userId != this.ownerData) {
                    needDelShareList.add(sb);
                }
            }
            System.debug('needDelShareList=>'+needDelShareList);
            if (needDelShareList.size() > 0) {
                delete needDelShareList;
            }
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage()+e.getLineNumber());
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        ShareDataToAccountTeam.shareData(this.obejctTyp, this.recordId, this.accId,this.fieldType,this.ownerData);

    }
}