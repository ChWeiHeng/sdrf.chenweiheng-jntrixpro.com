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
private class CustomerSalesInfoSyncToSAPTest {
    static testMethod void testMethod1() {
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '1111';
        a.Customer_Group__c = 'Z001';
        insert a;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5130';
        csi.Sales_District__c = 'ZAR00';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Currency__c = 'USD';
        csi.Price_Group__c = '02';
        csi.Cust_Pric_Procedure__c = '01';
        csi.Delivering_Plant__c = '5130';
        csi.Shipping_Conditions__c = '01';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Acct_Assmt_Grp_Cust__c = '01';
        // csi.Inco_Location1__c = '11';
        // csi.Payment_method__c = 'Z1';
        csi.Business_Model__c = 'C0';
        csi.Reconciliation_Account__c = '1122020000';
        csi.Sales_View_Status__c = 'Approved';
        csi.Customer__c = a.Id;
        csi.Incoterms__c = '';
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
        Tax_Number_Master_Data__c tnmd = new Tax_Number_Master_Data__c();
        tnmd.Code__c = '11';
        tnmd.Name = '11';
        insert tnmd;
        Customer_Tax_Number_Category__c ctnc = new Customer_Tax_Number_Category__c();
        ctnc.Customer__c = a.Id;
        ctnc.Long_Tax_Number__c = '11';
        ctnc.Tax_Number_Master_Data__c = tnmd.Id;
        insert ctnc;
        CustomerSalesInfoSyncToSAP.submitToSAPFutrue(csi.Id,'I');
    }

    static testMethod void testMethod2() {
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '1111';
        a.Customer_Group__c = 'Z001';
        insert a;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5130';
        csi.Sales_District__c = 'ZAR00';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Currency__c = 'USD';
        csi.Price_Group__c = '02';
        csi.Cust_Pric_Procedure__c = '01';
        csi.Delivering_Plant__c = '5130';
        csi.Shipping_Conditions__c = '01';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Acct_Assmt_Grp_Cust__c = '01';
        // csi.Inco_Location1__c = '11';
        // csi.Payment_method__c = 'Z1';
        csi.Business_Model__c = 'C0';
        csi.Reconciliation_Account__c = '1122020000';
        csi.Sales_View_Status__c = 'Approved';
        csi.Customer__c = a.Id;
        csi.Incoterms__c = '';
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
        Tax_Number_Master_Data__c tnmd = new Tax_Number_Master_Data__c();
        tnmd.Code__c = '11';
        tnmd.Name = '11';
        insert tnmd;
        Customer_Tax_Number_Category__c ctnc = new Customer_Tax_Number_Category__c();
        ctnc.Customer__c = a.Id;
        ctnc.Long_Tax_Number__c = '11';
        ctnc.Tax_Number_Master_Data__c = tnmd.Id;
        insert ctnc;
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.CustomerInfoSyncToSap());
        test.startTest();
        CustomerSalesInfoSyncToSAP.submitToSAPFutrue(csi.Id,'I');
        test.stopTest();
        
    }
}