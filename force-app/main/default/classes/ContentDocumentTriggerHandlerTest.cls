/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 02-12-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-28-2025   Gerry   Initial Version
**/
@isTest
private class ContentDocumentTriggerHandlerTest {
      static testMethod void testMethod2() {
       
        
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        Insert a;

        Customer_Shipping_Address__c csa = new Customer_Shipping_Address__c();
        csa.Customer__c = a.Id;
        csa.Direction__c = '111';
        insert csa;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.Rules__c = 'STANDARD';
        cci.Risk_Class__c = 'A';
        cci.Check_Rule__c = 'OV1';
        cci.Credit_Segment__c = 'Z000';
        cci.Valid_Until__c = Date.today();
        cci.Sinosure_Credit_Limit__c = 2;
        cci.Local_Credit_Limit__c = 2;
        cci.Actual_Credit_limit__c = 2;
        cci.Sync_Status__c = 'Synchronized';
        cci.Remaining_Credit__c = 2;
        cci.ExternalId__c = '1111';
        insert cci;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '3010';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '3010';
        //csi.Terms_Of_Payment__c = 'AR01';
        //csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        //csi.Price_Group__c = '02';
        //csi.Payment_method__c = 'Z1';
        //csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        insert csi;

        

        

       
        Order__c order = new Order__c();
        order.Customer__c = a.Id;
        order.Sales_Org__c = '3010';
        order.Distr_Channel__c = '10';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';  
        order.Deliver_Plant__c = '3011';
        order.Business_Model__c = 'C1';
        Insert order;
          
        ContentVersion contentVersion = new ContentVersion(
                                        Title = 'Penguins',
                                        PathOnClient = 'Penguins.jpg',
                                        VersionData = Blob.valueOf('Test Content'),
                                        IsMajorVersion = true
		        );
		insert contentVersion;    
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
        u.TimeZoneSidKey='America/Los_Angeles';
        u.Sales_Org__c='3010';
        u.Delivery_Plant__c='3010';
        insert u;
        Test.startTest();
        Campaign_Budget__c camBud = new Campaign_Budget__c();
        camBud.Sales_Org__c='3010';
        camBud.Plant__c='3010';
        camBud.Year__c=String.valueOf(date.today().Year());
        camBud.Budgeted_Amount__c=10000;
        //camBud.ExteralId__c='testuser_2025_1';
        insert camBud;

        Monthly_Budget__c mb=new Monthly_Budget__c();
        mb.Campaign_Budget__c=camBud.Id;
        mb.Budgeted_Amount__c=1000;
        mb.Month__c=String.valueOf(date.today().Month());
        mb.Sales_Rep__c=u.Id;
        insert mb;

        Campaign cam = new Campaign();
        cam.Date__c=date.today();
        cam.OwnerId=u.Id;
        cam.Name='test';
        cam.recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Offline_Campaign').getRecordTypeId();
        insert cam;
    	ContentVersion c = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id=:contentVersion.Id];
    	ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = cam.Id;
        cdl.ContentDocumentId = c.ContentDocumentId;
        insert cdl;
          
        ContentDocumentLink cd2 = new ContentDocumentLink();
        cd2.LinkedEntityId = a.Id;
        cd2.ContentDocumentId = c.ContentDocumentId;
        insert cd2;
        
        delete cd2;
        ContentDocument cd = new ContentDocument();
        cd.id = c.ContentDocumentId; 
        delete cd;
        Test.stopTest(); 
    }

    static testMethod void testMethod3() {
       
        
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        Insert a;

        Customer_Shipping_Address__c csa = new Customer_Shipping_Address__c();
        csa.Customer__c = a.Id;
        csa.Direction__c = '111';
        insert csa;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.Rules__c = 'STANDARD';
        cci.Risk_Class__c = 'A';
        cci.Check_Rule__c = 'OV1';
        cci.Credit_Segment__c = 'Z000';
        cci.Valid_Until__c = Date.today();
        cci.Sinosure_Credit_Limit__c = 2;
        cci.Local_Credit_Limit__c = 2;
        cci.Actual_Credit_limit__c = 2;
        cci.Sync_Status__c = 'Synchronized';
        cci.Remaining_Credit__c = 2;
        cci.ExternalId__c = '1111';
        insert cci;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '3010';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '3010';
        //csi.Terms_Of_Payment__c = 'AR01';
        //csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        //csi.Price_Group__c = '02';
        //csi.Payment_method__c = 'Z1';
        //csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        insert csi;

        

        

       
        Order__c order = new Order__c();
        order.Customer__c = a.Id;
        order.Sales_Org__c = '3010';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';  
        order.Deliver_Plant__c = '3011';
        order.Business_Model__c = 'C1';
        Insert order;
          
        ContentVersion contentVersion = new ContentVersion(
                                        Title = 'Penguins',
                                        PathOnClient = 'Penguins.jpg',
                                        VersionData = Blob.valueOf('Test Content'),
                                        IsMajorVersion = true
		        );
		insert contentVersion;    
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
        u.TimeZoneSidKey='America/Los_Angeles';
        u.Sales_Org__c='3010';
        u.Delivery_Plant__c='3010';
        insert u;
        Test.startTest();
        Campaign_Budget__c camBud = new Campaign_Budget__c();
        camBud.Sales_Org__c='3010';
        camBud.Plant__c='3010';
        camBud.Year__c=String.valueOf(date.today().Year());
        camBud.Budgeted_Amount__c=10000;
        //camBud.ExteralId__c='testuser_2025_1';
        insert camBud;

        Monthly_Budget__c mb=new Monthly_Budget__c();
        mb.Campaign_Budget__c=camBud.Id;
        mb.Budgeted_Amount__c=1000;
        mb.Month__c=String.valueOf(date.today().Month());
        mb.Sales_Rep__c=u.Id;
        insert mb;

        DeliveryNumber__c dn = new DeliveryNumber__c();
        dn.Delivery_Post_Status__c = 'C';
        dn.Order__c = order.Id;
        Insert dn;
    	ContentVersion c = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id=:contentVersion.Id];
    	ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = dn.Id;
        cdl.ContentDocumentId = c.ContentDocumentId;
        
        insert cdl;
          
        ContentDocumentLink cd2 = new ContentDocumentLink();
        cd2.LinkedEntityId = a.Id;
        cd2.ContentDocumentId = c.ContentDocumentId;
        insert cd2;
        
        delete cd2;
        ContentDocument cd = new ContentDocument();
        cd.id = c.ContentDocumentId; 
        delete cd; 
        Test.stopTest();
    }
}