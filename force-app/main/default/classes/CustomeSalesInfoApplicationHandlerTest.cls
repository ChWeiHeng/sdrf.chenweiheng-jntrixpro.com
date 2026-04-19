/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 07-31-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-31-2025   Gerry   Initial Version
**/
@isTest
private class CustomeSalesInfoApplicationHandlerTest {
    static testMethod void testMock2(){
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.MDG_Customer_Code__c = '1234';
        Insert a;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '3010';
        csi.Delivering_Plant__c = '3010';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Approved';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c='02';
        insert csi;
        Customer_Sales_Info_Change_Application__c c = new Customer_Sales_Info_Change_Application__c();
        c.Sales_Org__c = '3010';
        c.Delivery_Plant__c = '3010';
        c.Customer_Sales_Info__c = csi.Id;
        c.New_Payment_term__c = 'G001';
        c.New_Customer_Group__c = 'YPF';
        c.New_Shipping_Conditions__c = '01';
        c.New_Currency__c = 'MXN';
        c.New_Account_Assessment__c = '01';
        insert c;

        c.Approve_Status__c = 'Approved';
        update c;
    }
}