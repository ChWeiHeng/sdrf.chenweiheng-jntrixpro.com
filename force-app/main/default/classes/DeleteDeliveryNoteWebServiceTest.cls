/**
 * @description       : 删除交货单接口测试类
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 10-30-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-03-2025   Gerry   Initial Version
**/
@isTest
private class DeleteDeliveryNoteWebServiceTest {
    
    @IsTest
    static void testDoPost() {
        Profile prof = [SELECT Id FROM Profile WHERE Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema' LIMIT 1]; 
        User u = new User();
        u.LastName = 'test';
        u.Username = 'sfnewuser@testorg.com';
        u.Alias = 'newUser';
        u.Email='sfnewuser@testorg.com';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.ProfileId = prof.Id;
        u.TimeZoneSidKey='America/Los_Angeles';
        insert u;
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
        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;
        Product_Inventory__c pi = new Product_Inventory__c();
        pi.Search_Key__c = '12341234'+'-'+'5130'+'-'+'Test';
        pi.Inventory_Quantity__c = 1;
        pi.Product__c = p.Id;
        Insert pi;
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        Insert a;
        Account_Team__c at=new Account_Team__c();
        at.Customer__c=a.Id;
        at.Shared_Performance__c=true;
        at.Sales_Rep__c=u.Id;
        insert at;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Customer__c = a.Id;
        csi.Sync_Status__c = 'Synchronized';
        csi.Acct_Assmt_Grp_Cust__c='01';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Sales_Org__c = '5130';
        pb.Delivery_Plant__c = '5130';
        pb.Currency__c = 'USD';
        insert pb;
    
        Price_Book_Item__c pbi = new Price_Book_Item__c();
        pbi.Price_Book__c = pb.Id;
        pbi.Product_Name__c = pn.Id;
        pbi.Price__c = 1;
        insert pbi;
        Order__c order1 = new Order__c();
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARB';
        order1.Status__c = 'Approved';
        order1.Sync_Status__c = 'Synchronized';
        order1.OwnerId = u.Id;
        Insert order1;
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = pn.Id;
        orI1.Price_Book_Item__c = pbi.Id;
        orI1.Quantity__c = 1;
        orI1.IsCreate__c=true;
        Insert orI1;
        Delivery_Note__c dn = new Delivery_Note__c();
        dn.Delivery_Post_Status__c = 'C';
        dn.Order_Item__c = orI1.Id;
        dn.Delivery_Quantity__c = 1;
        dn.Order__c = order1.Id;
        dn.Delivery_Note_Num__c = 'TEst';
        
        Insert dn;
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ProductNameWebservice/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"resultinfo":[{"source":"TEst","deleteflag":"X"}]}');
        RestContext.request = req;
        RestContext.response = res;
        DeleteDeliveryNoteWebService.doPost();
        Test.stopTest();
    }

    
    @IsTest
    static void testDoPost1() {
        Profile prof = [SELECT Id FROM Profile WHERE Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema' LIMIT 1]; 
        User u = new User();
        u.LastName = 'test';
        u.Username = 'sfnewuser@testorg.com';
        u.Alias = 'newUser';
        u.Email='sfnewuser@testorg.com';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.ProfileId = prof.Id;
        u.TimeZoneSidKey='America/Los_Angeles';
        insert u;
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
        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;
        Product_Inventory__c pi = new Product_Inventory__c();
        pi.Search_Key__c = '12341234'+'-'+'5130'+'-'+'Test';
        pi.Inventory_Quantity__c = 1;
        pi.Product__c = p.Id;
        Insert pi;
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        Insert a;
        Account_Team__c at=new Account_Team__c();
        at.Customer__c=a.Id;
        at.Shared_Performance__c=true;
        at.Sales_Rep__c=u.Id;
        insert at;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Customer__c = a.Id;
        csi.Sync_Status__c = 'Synchronized';
        csi.Acct_Assmt_Grp_Cust__c='01';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Sales_Org__c = '5130';
        pb.Delivery_Plant__c = '5130';
        pb.Currency__c = 'USD';
        insert pb;
    
        Price_Book_Item__c pbi = new Price_Book_Item__c();
        pbi.Price_Book__c = pb.Id;
        pbi.Product_Name__c = pn.Id;
        pbi.Price__c = 1;
        insert pbi;
        Order__c order1 = new Order__c();
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARB';
        order1.Status__c = 'Approved';
        order1.Sync_Status__c = 'Synchronized';
        order1.OwnerId = u.Id;
        Insert order1;
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = pn.Id;
        orI1.Price_Book_Item__c = pbi.Id;
        orI1.Quantity__c = 1;
        orI1.IsCreate__c=true;
        Insert orI1;
        Delivery_Note__c dn = new Delivery_Note__c();
        dn.Delivery_Post_Status__c = 'C';
        dn.Order_Item__c = orI1.Id;
        dn.Delivery_Quantity__c = 1;
        dn.Order__c = order1.Id;
        dn.Delivery_Note_Num__c = 'TEst';
        dn.Issue_Quantity__c = 1;
        Insert dn;
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ProductNameWebservice/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"resultinfo":[{"source":"TEst","deleteflag":"X"}]}');
        RestContext.request = req;
        RestContext.response = res;
        DeleteDeliveryNoteWebService.doPost();
        Test.stopTest();
    }
}