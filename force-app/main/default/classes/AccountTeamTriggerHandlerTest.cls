/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 12-16-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-27-2025   Gerry   Initial Version
**/
@IsTest
private class AccountTeamTriggerHandlerTest {
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
        User currentUser = [SELECT Id,Sales_Org__c,Delivery_Plant__c FROM User WHERE id=:System.UserInfo.getUserId()];
        u.Sales_Org__c = currentUser.Sales_Org__c;
        u.Delivery_Plant__c = currentUser.Delivery_Plant__c;
        insert u;
        Date day = System.today();
        String year = String.valueOf(day.Year());

        Sales_Forecast_Summary__c sfs1 = new Sales_Forecast_Summary__c();
        sfs1.Year__c = year;
        sfs1.Sales_Org__c = '5130';
        sfs1.Status__c = 'Draft';
        insert sfs1;

        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        insert psi;
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'test';
        pn.Product_Sales_Info__c = psi.Id;
        insert pn;

        Sales_Forcast__c sf1= new Sales_Forcast__c();
        sf1.Customer__c = a.Id;
        sf1.Product_Name__c = pn.Id;
        sf1.Sales_Forecast_Summary__c = sfs1.Id;
        sf1.Month__c = '1';
        sf1.Year__c = year;
        sf1.Monthly_Actual_USD__c = 1;
        insert sf1;

        Account_Team__c at = new Account_Team__c();
        at.Customer__c = a.Id;
        at.Sales_Rep__c = u.Id;
        insert at;
        update at;
        delete at;
    }
}