/**
 * @description       : 创建free Order控制类
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 04-16-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   03-02-2026   Gerry   Initial Version
**/
public without sharing class CreateFreeOrderController {

    @AuraEnabled
    public static Output createFreeOrder(String recordId) {
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        Savepoint sp = Database.setSavepoint();
        try {
            Campaign ca = [SELECT OwnerId,Ship_To__c,Approval_Status__c,Id,Sales_Org__c,Delivery_Plant__c,Customer_Lookup__c,Distribution_Channel__c FROM Campaign WHERE Id =:recordId];
            if (ca.Approval_Status__c != 'Approved') {
                out.isSucess = false;
                out.errorMsg = 'The campaign is not approved.';
                return out;
            }
            Order__c order = new Order__c();
            order.Sales_Org__c = ca.Sales_Org__c;
            order.Deliver_Plant__c = ca.Delivery_Plant__c;
            order.Business_Model__c = 'C0';
            order.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
            order.Campaign__c = recordId;
            order.Status__c = 'Draft';
            order.Order_type__c = 'ZFD';
            order.Customer__c = ca.Customer_Lookup__c;
            order.Currency__c = 'USD';
            order.Distr_Channel__c = ca.Distribution_Channel__c;
            order.Ship_To__c = ca.Ship_To__c;
            order.OwnerId = ca.OwnerId;
            order.Terms_Of_Payment__c = 'AR01';
            Database.insert(order);
            out.newRecordId = order.Id;
            List<Order_Item__c> oiList = new List<Order_Item__c>();
            Integer itemNum = 10;
            for (Campaign_Product__c cp : [
                                            SELECT 
                                                Id,Product_Name__c,Quantity__c,Product_Name__r.Product__r.Name,Product_Name__r.Name,Product_Unit_Lookup__c,
                                                Delivery_Date__c,Unit__c
                                            FROM 
                                                Campaign_Product__c 
                                            WHERE Campaign__c = :recordId
                                            AND Product_Name__r.Product__r.Name != null
                                            AND Product_Name__r.Name != null
            ]) {
                Order_Item__c oi = new Order_Item__c();
                oi.Order__c = order.Id;
                oi.Commodity__c = cp.Product_Name__c;
                oi.Campaign_Product__c = cp.Id;
                oi.IsCreate__c = TRUE;
                oi.Quantity__c = cp.Quantity__c;
                oi.Material_Number__c = cp.Product_Name__r.Product__r.Name;
                oi.Product_Type__c = 'Free Product';
                oi.Product_Name_Text__c = cp.Product_Name__r.Name;
                oi.SAP_Item_Num__c = String.valueOf(itemNum);
                oi.Material_Description__c = cp.Product_Name__r.Name;
                oi.Price__c = 0;
                oi.Sales_Unit__c = cp.Product_Unit_Lookup__c;
                oi.Sales_Unit_Text__c = cp.Unit__c;
                oi.Delivery_Date__c = cp.Delivery_Date__c;
                itemNum += 10;
                oiList.add(oi);
            }
            if (oiList.size()>0) {
                Database.insert(oiList);
            }
            order.Status__c = 'Approved';
            update order;//触发sap同步
        } catch (Exception e) {
            System.debug('error:'+e.getMessage()+';Line:'+e.getLineNumber());
            Database.rollback(sp); 
            out.isSucess = false; 
            out.errorMsg = e.getMessage();
        }
        return out;
        
    }
    public class Output{
        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        @AuraEnabled
        public String returnUrl {get;set;}

        @AuraEnabled
        public String newRecordId {get;set;}
    }
}