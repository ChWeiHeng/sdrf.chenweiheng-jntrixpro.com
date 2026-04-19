@isTest
private class CaseTriggerHandlerTest {
    static testMethod void testMethod1() {
        Profile prof = [SELECT Id FROM Profile WHERE Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema' LIMIT 1]; 
        User u = new User();
        u.LastName = 'test';
        u.Username = 'bisfnewuser@testorg.com';
        u.Alias = 'newUser';
        u.Email='bisfnewuser@testorg.com';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.ProfileId = prof.Id;
        u.Sales_Org__c='3010';
        u.Delivery_Plant__c='3010';
        u.TimeZoneSidKey='America/Los_Angeles';
        insert u;
        
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        
        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;
        
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '5130';
        psi.Delivering_Plant__c = '5130';
        psi.Product_Unit__c=pu.Id;
        Insert psi;
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'Test';
        pn.Product_Sales_Info__c = psi.Id; 
        Insert pn;
        
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
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c = '01';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;
    
        Price_Book_Item__c pbi = new Price_Book_Item__c();
        pbi.Price_Book__c = pb.Id;
        pbi.Product_Name__c = pn.Id;
        pbi.Price__c = 1;
        insert pbi;
        
        Product_Unit__c proUnit=new Product_Unit__c();
        proUnit.Product__c=p.Id;
        proUnit.Conversion_Coefficient__c=1;
        insert proUnit;
        
        Order__c order = new Order__c();
        order.Customer__c = a.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = pb.Id;
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZARE';
        Insert order;
        Order_Item__c orI = new Order_Item__c();
        orI.Order__c = order.Id;
        orI.Commodity__c = pn.Id;
        orI.Price_Book_Item__c = pbi.Id;
        orI.Quantity__c = 1;
        ori.Unit_Price_w_o_tax__c = 1;
        ori.IsCreate__c=true;
        insert orI;



        Case caseRecord=new Case();
        caseRecord.Order_Item__c=orI.Id;
        insert caseRecord;

    }
}