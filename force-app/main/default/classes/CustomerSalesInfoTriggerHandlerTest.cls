/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 11-11-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   09-04-2025   Gerry   Initial Version
**/
@IsTest
private class CustomerSalesInfoTriggerHandlerTest {
    static testMethod void testMock(){
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        Insert a;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Draft';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c='01';
        insert csi;
        csi.Sales_View_Status__c = 'Approved';
        Update csi;
    }

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
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c='01';
        insert csi;
        csi.Sales_View_Status__c = 'Approved';
        Update csi;
        Profile prof = [SELECT Id FROM Profile WHERE Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema' LIMIT 1]; 
        User u = new User();
        u.LastName = 'test';
        u.Username = 'testuserbisfc@testorg.com';
        u.Alias = 'newUser';
        u.Email='testuserbisfc@testorg.com';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.ProfileId = prof.Id;
        u.TimeZoneSidKey='America/Los_Angeles';
        insert u;
        Account_Team__c at = new Account_Team__c();
        at.Customer__c = a.Id;
        at.Sales_Rep__c = u.Id;
        insert at;
        delete at;
    }

    static testMethod void testMock3(){
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema' LIMIT 1]; 
        User u = new User();
        u.LastName = 'test';
        u.Username = '123@testorg.com';
        u.Alias = 'newUser';
        u.Email='222@testorg.com';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        u.Sales_Org__c = '3020';
        u.Delivery_Plant__c='3020';
        u.LocaleSidKey='en_US';
        u.ProfileId = prof.Id;
        u.TimeZoneSidKey='America/Los_Angeles';
        insert u;
        
        User u1 = new User();
        u1.LastName = 'test1';
        u1.Username = 'test1123@testorg.com';
        u1.Alias = 'newUser1';
        u1.Email='sfc@testorg.com';
        u1.EmailEncodingKey='UTF-8';
        u1.LanguageLocaleKey='en_US';
        u1.LocaleSidKey='en_US';
        u1.ProfileId = prof.Id;
        u1.Sales_Org__c = '3020';
        u1.Delivery_Plant__c='3020';
        u1.TimeZoneSidKey='America/Los_Angeles';
        insert u1;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
        
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.MDG_Customer_Code__c = '1234';
        a.OwnerId = u1.Id;
        Insert a;
        
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '5130';
        psi.Delivering_Plant__c = '5130';
        Insert psi;
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'Test';
        pn.Product_Sales_Info__c = psi.Id; 
        Insert pn;
        
        Sales_Forecast_Summary__c sfs = new Sales_Forecast_Summary__c();
        sfs.Year__c = String.valueOf(date.today().Year());
        sfs.Sales_Org__c = '5130';
        sfs.Status__c = 'Approved';
        insert sfs;
        Sales_Forcast__c sf1= new Sales_Forcast__c();
        sf1.Customer__c = a.Id;
        sf1.Product_Name__c = pn.Id;
        sf1.Sales_Forecast_Summary__c = sfs.Id;
        sf1.Month__c = '1';
        sf1.Year__c = String.valueOf(date.today().Year());
        sf1.Monthly_Actual_USD__c = 1;
        sf1.OwnerId = UserInfo.getUserId();
        //sf1.External_Id__c = '2024'+'1'+pn.Id + a.Id + u.Id;
        //sf1.External_Id__c = '2024'+'1'+pn.Id + System.Label.Acc5130 + u.Id;
        // insert sf1;
        
        Account_Team__c at = new Account_Team__c();
        at.Customer__c = a.Id;
        at.Sales_Rep__c = u.Id;
        at.Shared_Performance__c=true;
        insert at;
        update at;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '3010';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Draft';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c='01';
        insert csi;
        csi.Sales_View_Status__c = 'Approved';
        csi.Delivering_Plant__c = '3010';
        Update csi;
        }}
}