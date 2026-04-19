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
private class ChangeCustomerSalesInfoLWCControllerTest {
    static testMethod void testMethod1() {
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
        Tax_Category_Master_Data__c tcmd = new Tax_Category_Master_Data__c();
        tcmd.Country_Code__c = '11';
        tcmd.Country_District__c = '11';
        tcmd.Name = '11';
        tcmd.Tax_Category_Name__c = '11';
        insert tcmd;
        Customer_Tax_Category__c ctc = new Customer_Tax_Category__c();
        ctc.Tax_Category_Type__c = 'J1AU';
        ctc.Tax_Category__c = '1-Responsable IVA';
        ctc.Tax_Category_Master_Data__c = tcmd.Id;
        ctc.Sales_View__c = csi.Id;
        insert ctc;
        ChangeCustomerSalesInfoLWCController.changeData(csi.Id);
    }
}