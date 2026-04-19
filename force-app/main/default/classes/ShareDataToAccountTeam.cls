/**************************************************************************************************
 * Name: ShareDataToAccountTeam
 * Object: 
 * Purpose: 共享数据到客户小组
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-08-20         Created             
***************************************************************************************************/
public without sharing class ShareDataToAccountTeam {
    public static void shareData(String obejctTyp,String recordId,String accId,String fieldType,String ownerData) {
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
        orderQuery = orderQuery+field+',Sales_Rep_Delivery_Plant__c FROM Account_Team__c WHERE Customer__c=:accId AND Sales_Rep__r.IsActive=true';
        List<Account_Team__c> atList = Database.Query(orderQuery);
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        List<SObject> shareList = new List<SObject>();
        String objectName;
        String deliveryPlant;
        String queryDeliveryPlant='SELECT Id,OwnerId,';
        if(obejctTyp=='Customer_Sales_Info__c' || obejctTyp=='Order__c' || obejctTyp=='Contracts__c'  || obejctTyp=='Invoice__c' || obejctTyp=='Quote__c')
        {
            if(obejctTyp=='Customer_Sales_Info__c'){
                queryDeliveryPlant=queryDeliveryPlant+'Delivering_Plant__c FROM '+obejctTyp+' WHERE Id =: recordId';
            }
            if(obejctTyp=='Order__c' || obejctTyp=='Quote__c'){
                queryDeliveryPlant=queryDeliveryPlant+'Deliver_Plant__c FROM '+obejctTyp+' WHERE Id =: recordId';
            }
            if(obejctTyp=='Contracts__c'){
                queryDeliveryPlant=queryDeliveryPlant+'Delivery_Plant__c FROM '+obejctTyp+' WHERE Id =: recordId';
            }
            if(obejctTyp=='Invoice__c'){
                queryDeliveryPlant=queryDeliveryPlant+'Delivery_Plant__c FROM '+obejctTyp+' WHERE Order__c =: recordId';
            }
            //queryDeliveryPlant=queryDeliveryPlant+' AND Id=:recordId';
            System.debug('queryDeliveryPlant=>'+queryDeliveryPlant);
            List<SObject> deliveryPlantList=Database.Query(queryDeliveryPlant);
            for (SObject sb : deliveryPlantList) {
                if(obejctTyp=='Customer_Sales_Info__c'){
                    deliveryPlant=String.valueOf(sb.get('Delivering_Plant__c'));
                }
                if(obejctTyp=='Order__c' || obejctTyp=='Quote__c'){
                    deliveryPlant=String.valueOf(sb.get('Deliver_Plant__c'));
                }
                if(obejctTyp=='Contracts__c'){
                    deliveryPlant=String.valueOf(sb.get('Delivery_Plant__c'));
                }
                if(obejctTyp=='Invoice__c'){
                    deliveryPlant=String.valueOf(sb.get('Delivery_Plant__c'));
                }
                ownerData=String.valueOf(sb.get('OwnerId'));
                System.debug('deliveryPlant:'+deliveryPlant);
                System.debug('ownerData:'+ownerData);

        if (obejctTyp.contains('_')) {
            objectName = obejctTyp.replace('__c', '__share');
        }else{
            objectName = obejctTyp+'Share';
        }
        for (Account_Team__c at : atList) {
            //system.debug('ownerData:'+ownerData);
            system.debug('at.Sales_Rep__c:'+at.Sales_Rep__c);
            if (ownerData == at.Sales_Rep__c) {
                continue;
            }
            if (String.valueOf(at.get(fieldType))=='Private') {
                    continue;
            }
            if (deliveryPlant != null && deliveryPlant != at.Sales_Rep_Delivery_Plant__c) {
                continue;
            }
            SObject sharingObject = globalDescribe.get(objectName).newSObject();
            if (obejctTyp == 'Account') {
                sharingObject.put('AccountId', recordId);
                sharingObject.put('AccountAccessLevel', String.valueOf(at.get(fieldType)));
                sharingObject.put('OpportunityAccessLevel', 'None');
            }else if(obejctTyp == 'Contact') {
                sharingObject.put('ContactId', recordId);
                sharingObject.put('ContactAccessLevel', String.valueOf(at.get(fieldType)));
            }else{
                sharingObject.put('AccessLevel', String.valueOf(at.get(fieldType)));
                sharingObject.put('ParentId',sb.get('Id'));
            }
            
            
            sharingObject.put('RowCause','Manual');
            sharingObject.put('UserOrGroupId',at.Sales_Rep__c);
            shareList.add(sharingObject);
            System.debug('shareList=>'+shareList);
        }}}
        if (shareList.size()>0) {
            Database.upsert(shareList);
        }
        
    }
}