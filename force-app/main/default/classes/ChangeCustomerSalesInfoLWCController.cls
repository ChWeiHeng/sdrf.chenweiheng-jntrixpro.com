/**
 * @description       : 修改客户销售视图控制类
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 07-04-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-01-2025   Gerry   Initial Version
**/
public without sharing class ChangeCustomerSalesInfoLWCController {
    @AuraEnabled
    public static Output changeData(String customerSalesInfoId) {
        System.savepoint sp = Database.setSavepoint();
        try {
            Customer_Sales_Info__c csi = [SELECT Acct_Assmt_Grp_Cust__c,Sales_Org__c,Delivering_Plant__c,Id,Currency__c,Shipping_Conditions__c,Terms_Of_Payment__c,Payment_method__c FROM Customer_Sales_Info__c WHERE Id=:customerSalesInfoId];
            Customer_Sales_Info_Change_Application__c scica = new Customer_Sales_Info_Change_Application__c();
            scica.Customer_Sales_Info__c = customerSalesInfoId;
            scica.Delivery_Plant__c = csi.Delivering_Plant__c;
            scica.Sales_Org__c = csi.Sales_Org__c;
            scica.Old_Currency__c = csi.Currency__c;
            scica.Old_Customer_Group__c = csi.Payment_method__c;
            scica.Old_Payment_term__c = csi.Terms_Of_Payment__c;
            scica.Old_Shipping_Conditions__c = csi.Shipping_Conditions__c;
            scica.Old_Account_Assessment__c = csi.Acct_Assmt_Grp_Cust__c;
            scica.New_Account_Assessment__c = null;
            Database.insert(scica);
            if (csi.Sales_Org__c!='5130' && csi.Sales_Org__c!='5070') {
                List<Customer_Tax_Category_Application__c> ctcaList = new List<Customer_Tax_Category_Application__c>();
                for(Customer_Tax_Category__c ctc : [
                    SELECT 
                        Id,
                        Tax_Category__c,
                        Tax_Category_Master_Data__c,
                        Tax_Category_Type__c 
                    FROM Customer_Tax_Category__c WHERE Sales_View__c=:customerSalesInfoId]
                ){
                    Customer_Tax_Category_Application__c ctca = new Customer_Tax_Category_Application__c();
                    ctca.Customer_Tax_Category__c = ctc.Id;
                    ctca.Customer_Sales_Info_Change_Application__c = scica.Id;
                    ctca.Old_Tax_Category__c = ctc.Tax_Category__c;
                    ctca.Tax_Category_Type__c = ctc.Tax_Category_Type__c;
                    ctcaList.add(ctca);
                }
                Database.insert(ctcaList);
            }
            Output out = new Output();
            out.isSucess = true;
            out.errorMsg = 'Successful';
            out.newRecordId = scica.Id;
            return out;
        } catch (Exception e) {
            Database.rollback(sp);
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = e.getMessage()+'Line:'+e.getLineNumber();
            return out;
        }
        
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