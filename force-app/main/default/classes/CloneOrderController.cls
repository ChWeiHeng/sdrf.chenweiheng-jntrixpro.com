/**************************************************************************************************
 * Name: CloneOrderController
 * Object: 
 * Purpose: 订单复制
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-08-12         Created             
***************************************************************************************************/
public without sharing class CloneOrderController {
    @AuraEnabled
    public static Output cloneOrder(String orderRecordId,String orderType) {
        System.savepoint sp = Database.setSavepoint();
        try {
            
            List<Schema.FieldSetMember> fieldSetMembers = SObjectType.Order__c.FieldSets.clone_field.getFields();
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
            orderQuery = orderQuery+field+',RecordTypeId FROM Order__c WHERE Id=:orderRecordId';
            Order__c ord = Database.query(orderQuery);
            Order__c newOrder = ord.clone();
            newOrder.Status__c = 'Draft';
            if (orderType == 'ZARE') {
                newOrder.Order_type__c = orderType;
            }
            newOrder.Is_Copy_Order__c = true;
            newOrder.OwnerID = System.UserInfo.getUserId();
            insert newOrder;

            List<Order_Item__c> newOiList = new List<Order_Item__c>();
            List<Schema.FieldSetMember> fieldSetMembersOrderItem = SObjectType.Order_Item__c.FieldSets.Clone_Field.getFields();
            // 拼接需要复制得字段
            String orderQueryOrderItem = 'SELECT Id,';
            String fieldItem = '';
            for (Schema.FieldSetMember f : fieldSetMembersOrderItem) {
                if (String.isNotBlank(fieldItem)) {
                    fieldItem += ','+f.getFieldPath();
                }else{
                    fieldItem += f.getFieldPath();
                }
            }
            orderQueryOrderItem = orderQueryOrderItem+fieldItem+' FROM Order_Item__c WHERE Order__c=:orderRecordId';
            System.debug('orderQueryOrderItem:'+orderQueryOrderItem);
            for (Order_Item__c oi : Database.query(orderQueryOrderItem)) {
                Order_Item__c newoi = oi.clone();
                newoi.IsCreate__c = true;
                newoi.Order__c = newOrder.Id;
                if (orderType == 'ZARE') {
                    newoi.Depend_On_Item__c = oi.Id;
                    newoi.Guide_Price__c = oi.Price__c;
                }
                newOiList.add(newoi);
            }
            insert newOiList;
            Output out = new Output();
            out.isSucess = true;
            out.errorMsg = 'Clone Successful';
            out.newRecordId = newOrder.Id;
            return out;
        } catch (Exception e) {
            Database.rollback(sp);
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = e.getMessage()+'Line:'+e.getLineNumber();
            return out;
        }
        
    }

    @AuraEnabled
    public static Output init(String orderRecordId) {
        Order__c order = [SELECT Id,Order_type__c FROM Order__c WHERE Id=:orderRecordId];
        Output out = new Output();
        out.isSucess = true;
        if (order.Order_type__c == 'ZARB') {
            out.showOption = true;
            out.optionList = new List<Option>();
            Option op = new Option();
            op.Label = 'ZARB Fill Up Consig. Arg';
            op.Value = 'ZARB';
            out.optionList.add(op);
            Option op1 = new Option();
            op1.Label = 'ZARE Issue Consig. Arg';
            op1.Value = 'ZARE';
            out.optionList.add(op1);
            System.debug('out.optionList=====>'+out.optionList);
        }
        
        return out;
    }
    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}
        
        @AuraEnabled
        public String newRecordId {get;set;}

        @AuraEnabled
        public List<Option> optionList {get;set;}

        @AuraEnabled
        public Boolean showOption {get;set;}
    }

    public class Option {
        @AuraEnabled
        public String label {get;set;}

        @AuraEnabled
        public String value {get;set;}
    }
}