/**************************************************************************************************
 * Name: ShareAccountDataBatch
 * Object: 
 * Purpose: 共享客户相关数据
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-08-20         Created             
***************************************************************************************************/
global without sharing class ShareAccountDataBatch implements Database.Batchable<sObject>,Database.Stateful{
    global String query;
    global String atRecordId;
    global Map<String, Schema.SObjectType> globalDescribe;
    global String obejctTyp;
    global String field;
    global Integer index;
    global String recordId;//客户Id
    global String errorMsg;
    global Boolean flag;
    global Datetime startTime;
    global ShareAccountDataBatch(String atRecordId,String recordId,Integer index) {
        this.index = index;
        this.startTime = System.now();
        this.flag = true;
        this.atRecordId = atRecordId;
        this.globalDescribe = Schema.getGlobalDescribe();
        this.recordId = recordId;
        ShareDataQuery__c sdq = [SELECT Id,Object__c,Sql__c,Field__c FROM ShareDataQuery__c WHERE Index__c=:index];
        this.query = sdq.Sql__c;
        this.obejctTyp = sdq.Object__c;
        this.field = sdq.Field__c;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> orderList) {
        System.savepoint sp = Database.setSavepoint();
        try {
            List<SObject> shareList = new List<SObject>();
            String objectName;
            if (this.obejctTyp.contains('_')) {
                objectName = this.obejctTyp.replace('__c', '__share');
            }else{
                objectName = this.obejctTyp+'Share';
            }
            List<Schema.FieldSetMember> fieldSetMembers = SObjectType.Account_Team__c.FieldSets.All_Filed.getFields();
            // 拼接需要复制得字段
            String orderQuery = 'SELECT ';
            String field = '';
            for (Schema.FieldSetMember f : fieldSetMembers) {
                if (String.isNotBlank(field)) {
                    field += ','+f.getFieldPath();
                }else{
                    field += f.getFieldPath();
                }
            }
            String atId = this.atRecordId;
            orderQuery = orderQuery+field+',Sales_Rep_Delivery_Plant__c FROM Account_Team__c WHERE Id=:atId AND Sales_Rep__r.IsActive=true';
            Account_Team__c at = Database.Query(orderQuery);
            for (SObject sb : orderList) {
                if (sb.get('OwnerId') == at.Sales_Rep__c) {
                    continue;
                }
                if (String.valueOf(at.get(this.field))=='Private') {
                    continue;
                }
                if (this.obejctTyp=='Customer_Sales_Info__c' && sb.get('Delivering_Plant__c') != null && sb.get('Delivering_Plant__c') != at.Sales_Rep_Delivery_Plant__c) {
                    continue;
                }
                if (this.obejctTyp=='Contracts__c' && sb.get('Delivery_Plant__c') != null && sb.get('Delivery_Plant__c') != at.Sales_Rep_Delivery_Plant__c) {
                    continue;
                }
                if ((this.obejctTyp=='Order__c' || this.obejctTyp=='Quote__c') && sb.get('Deliver_Plant__c') != null && sb.get('Deliver_Plant__c') != at.Sales_Rep_Delivery_Plant__c) {
                    continue;
                }
                if (this.obejctTyp=='Invoice__c'  && sb.get('Delivery_Plant__c') != null && sb.get('Delivery_Plant__c') != at.Sales_Rep_Delivery_Plant__c) {
                    continue;
                }
                SObject sharingObject = globalDescribe.get(objectName).newSObject();
                if (this.obejctTyp == 'Account') {
                    sharingObject.put('AccountId', sb.get('Id'));
                    sharingObject.put('AccountAccessLevel', String.valueOf(at.get(this.field)));
                    sharingObject.put('OpportunityAccessLevel', 'None');
                }else if(this.obejctTyp == 'Contact') {
                    sharingObject.put('ContactId', sb.get('Id'));
                    sharingObject.put('ContactAccessLevel', String.valueOf(at.get(this.field)));
                }else{
                    sharingObject.put('AccessLevel', String.valueOf(at.get(this.field)));
                    sharingObject.put('ParentId',sb.get('Id'));
                }
                
                
                sharingObject.put('RowCause','Manual');
                
                sharingObject.put('UserOrGroupId',at.Sales_Rep__c);
                shareList.add(sharingObject);
            }
            System.debug(shareList);
            Database.upsert(shareList);
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage()+e.getLineNumber());
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        Integer indexNext = this.index+1;
        List<ShareDataQuery__c> sdq = [SELECT Id,Object__c,Sql__c,Field__c FROM ShareDataQuery__c WHERE Index__c=:indexNext];
        Utility.setBatchInfo('ShareAccountDataBatch:'+this.atRecordId+':'+this.obejctTyp, this.flag, this.startTime, this.errorMsg);
        if (sdq.size()>0) {
            Database.executeBatch(new ShareAccountDataBatch(this.atRecordId,this.recordId,indexNext), 100);
        }else{
            Account_Team__c at = new Account_Team__c();
            at.Is_Ruuning__c = false;
            at.Id = this.atRecordId;
            Update at;
        }

    }
}