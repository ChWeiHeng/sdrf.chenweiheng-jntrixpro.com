/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-05-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   01-22-2026   Gerry   Initial Version
**/
@isTest
private class OrderSyncToSAPTest {
    static testMethod void testMethod1() {
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
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
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
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5130';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Price_Group__c = '02';
        csi.Payment_method__c = 'YPF';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;
    
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '123';
        order1.SAP_Order_Code2__c = '123';
        order1.Cust_Reference__c = '111';
        // order1.Inco_Location1__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARB';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        order1.Customer__c = a.Id;
        Insert order1;
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Delivery_Date__c = System.today();
        orI1.SAP_Item_Num__c = '11';
        orI1.Quantity__c = 10;
        orI1.Material_Number__c = '11';
        orI1.Sales_Unit__c = pu.Id;
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = pn.Id;
        orI1.Price__c = 10;
        orI1.Gross_Weight__c = '11';
        orI1.Net_Weight__c = '11';
        orI1.External_Id__c = '123123';
        orI1.External_Id2__c = '123123';
        orI1.IsCreate__c = true;
        Insert orI1;
        OrderSyncToSAP.submitToSAP(order1.Id,'I',true,true,'111',String.valueOf(orI1.Id),false,false);
    }

    static testMethod void testMethod2() {
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
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
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
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5130';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        csi.Acct_Assmt_Grp_Cust__c = '01';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Price_Group__c = '02';
        csi.Payment_method__c = 'YPF';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;
    
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '123';
        order1.SAP_Order_Code2__c = '123';
        order1.Cust_Reference__c = '111';
        // order1.Inco_Location1__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARB';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        order1.Customer__c = a.Id;
        Insert order1;
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Delivery_Date__c = System.today();
        orI1.SAP_Item_Num__c = '11';
        orI1.Quantity__c = 10;
        orI1.Material_Number__c = '11';
        orI1.Sales_Unit__c = pu.Id;
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = pn.Id;
        orI1.Price__c = 10;
        orI1.Gross_Weight__c = '11';
        orI1.Net_Weight__c = '11';
        orI1.External_Id__c = '123123';
        orI1.External_Id2__c = '123123';
        orI1.IsCreate__c = true;
        Insert orI1;
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.CustomerInfoSyncToSapErr());
        test.startTest();
        OrderSyncToSAP.submitToSAP(order1.Id,'U',true,true,'111',String.valueOf(orI1.Id),false,false);
        test.stopTest();
        
    }

    static testMethod void testMethod3() {
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
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
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
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5130';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Price_Group__c = '02';
        csi.Payment_method__c = 'YPF';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;
    
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '123';
        order1.SAP_Order_Code2__c = '123';
        order1.Cust_Reference__c = '111';
        // order1.Inco_Location1__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARB';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        order1.Customer__c = a.Id;
        Insert order1;
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Delivery_Date__c = System.today();
        orI1.SAP_Item_Num__c = '11';
        orI1.Quantity__c = 10;
        orI1.Material_Number__c = '11';
        orI1.Sales_Unit__c = pu.Id;
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = pn.Id;
        orI1.Price__c = 10;
        orI1.Gross_Weight__c = '11';
        orI1.Net_Weight__c = '11';
        orI1.External_Id__c = '123123';
        orI1.External_Id2__c = '123123';
        orI1.IsCreate__c = true;
        Insert orI1;
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.CustomerInfoSyncToSap());
        test.startTest();
        OrderSyncToSAP.submitToSAP(order1.Id,'I',true,true,'111',String.valueOf(orI1.Id),false,false);
        test.stopTest();
        
    }

    static testMethod void testMethod4() {
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
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
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
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5130';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Price_Group__c = '02';
        csi.Payment_method__c = 'YPF';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;
    
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '123';
        order1.SAP_Order_Code2__c = '123';
        order1.Cust_Reference__c = '111';
        // order1.Inco_Location1__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARB';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        order1.Customer__c = a.Id;
        Insert order1;
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Delivery_Date__c = System.today();
        orI1.SAP_Item_Num__c = '11';
        orI1.Quantity__c = 10;
        orI1.Material_Number__c = '11';
        orI1.Sales_Unit__c = pu.Id;
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = pn.Id;
        orI1.Price__c = 10;
        orI1.Gross_Weight__c = '11';
        orI1.Net_Weight__c = '11';
        orI1.External_Id__c = '123123';
        orI1.External_Id2__c = '123123';
        orI1.IsCreate__c = true;
        Insert orI1;
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.OrderSyncToSAPNull());
        test.startTest();
        OrderSyncToSAP.submitToSAP(order1.Id,'I',true,true,'111',String.valueOf(orI1.Id),false,false);
        test.stopTest();
        
    }


    static testMethod void testMethod5() {
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
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
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
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5130';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Price_Group__c = '02';
        csi.Payment_method__c = 'YPF';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;
    
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '123';
        order1.SAP_Order_Code2__c = '123';
        order1.Cust_Reference__c = '111';
        // order1.Inco_Location1__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARB';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        order1.Customer__c = a.Id;
        Insert order1;
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Delivery_Date__c = System.today();
        orI1.SAP_Item_Num__c = '11';
        orI1.Quantity__c = 10;
        orI1.Material_Number__c = '11';
        orI1.Sales_Unit__c = pu.Id;
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = pn.Id;
        orI1.Price__c = 10;
        orI1.Gross_Weight__c = '11';
        orI1.Net_Weight__c = '11';
        orI1.External_Id__c = '123123';
        orI1.External_Id2__c = '123123';
        orI1.IsCreate__c = true;
        Insert orI1;
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.OrderSyncToSAP500());
        test.startTest();
        OrderSyncToSAP.submitToSAP(order1.Id,'I',true,true,'111',String.valueOf(orI1.Id),true,false);
        test.stopTest();
        
    }
    static testMethod void testMethod6() {
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
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
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
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5130';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Price_Group__c = '02';
        csi.Payment_method__c = 'YPF';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;
    
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '123';
        order1.SAP_Order_Code2__c = '123';
        order1.Cust_Reference__c = '111';
        // order1.Inco_Location1__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARB';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        order1.Customer__c = a.Id;
        order1.Change_Status__c='Approved';
        order1.Order_Change__c=true;
        Insert order1;
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Delivery_Date__c = System.today();
        orI1.SAP_Item_Num__c = '11';
        orI1.Quantity__c = 10;
        orI1.Material_Number__c = '11';
        orI1.Sales_Unit__c = pu.Id;
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = pn.Id;
        orI1.Price__c = 10;
        orI1.Gross_Weight__c = '11';
        orI1.Net_Weight__c = '11';
        orI1.External_Id__c = '123123';
        orI1.External_Id2__c = '123123';
        orI1.IsCreate__c = true;
        Insert orI1;
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.OrderSyncToSAPSucesssNull());
        test.startTest();
        OrderSyncToSAP.submitToSAP(order1.Id,'U',true,true,'111',String.valueOf(orI1.Id),true,false);
        OrderSyncToSAP.submitToSAPFu(order1.Id,'U',true,true,'111',true,'');
        test.stopTest();
        
    }
    
    @IsTest
    static void testZARAOrderWithAutoIssueConsignment() {
        // 创建测试数据
        Product__c p = new Product__c();
        p.Name = 'ZARATest';
        p.External_Id__c = 'ZARATest';
        insert p;
        
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '3020';
        psi.Delivering_Plant__c = '3020';
        Insert psi;
        
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'ZARATest';
        pn.Product_Sales_Info__c = psi.Id; 
        Insert pn;
        
        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;
        
        Account a = new Account();
        a.Name = 'ZARATest';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = 'ZARA111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
        Insert a;

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
        csi.Sales_Org__c = '3020';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '3020';
        csi.Terms_Of_Payment__c = 'G001';
        csi.Sales_District__c = 'ZMX00';
        csi.Price_Group__c = '01';
        // csi.Payment_method__c = 'YPF';
        csi.Business_Model__c = 'C0';
        insert csi;
        
        Price_Book__c pb = new Price_Book__c();
        pb.Name = 'ZARATest';
        pb.Currency__c = 'USD';
        insert pb;
        
        // 创建源订单（ZARB）
        Order__c sourceOrder = new Order__c();
        sourceOrder.SAP_Order_Code__c = 'ZARB001';
        sourceOrder.Customer__c = a.Id;
        sourceOrder.Sales_Org__c = '3020';
        sourceOrder.Distr_Channel__c = '10';
        sourceOrder.Customer_Sales_Info__c = csi.Id;
        sourceOrder.Currency__c = 'USD';
        sourceOrder.Price_Book__c = pb.Id;
        sourceOrder.Deliver_Plant__c = '3020';
        sourceOrder.Order_type__c = 'ZMX1';
        sourceOrder.Sync_Status__c = 'Synchronized';
        Insert sourceOrder;
        
        // 创建ZARA订单
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = 'ZARA001';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '3020';
        order1.Distr_Channel__c = '10';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '3020';
        order1.Order_type__c = 'ZMX1';
        order1.Auto_Issue_Consignment__c = true;
        order1.DN_Post_Date__c = Date.today();
        order1.Source_Order__c = sourceOrder.Id;
        order1.Sync_Status__c = 'Synchronized';
        Insert order1;
        
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Delivery_Date__c = System.today();
        orI1.SAP_Item_Num__c = '10';
        orI1.Quantity__c = 10;
        orI1.Material_Number__c = 'ZARATest';
        orI1.Sales_Unit__c = pu.Id;
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = pn.Id;
        orI1.Price__c = 10;
        orI1.Gross_Weight__c = '10';
        orI1.Net_Weight__c = '10';
        orI1.Inventory_Location__c = 'PROD';
        orI1.Product_Usage__c = 'Crop using';
        orI1.IsCreate__c = true;
        orI1.Cash_Price__c = 1;
        orI1.Product_Cost__c = 1;
        Insert orI1;
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.OrderSyncToSAPSuccess());
        test.startTest();
        OrderSyncToSAP.submitToSAP(order1.Id,'I',false,false,'',String.valueOf(orI1.Id),false,false);
        test.stopTest();
    }
    
    // @IsTest
    // static void testZAR2ReturnOrder() {
    //     // 创建测试数据
    //     Product__c p = new Product__c();
    //     p.Name = 'ZAR2Test';
    //     p.External_Id__c = 'ZAR2Test';
    //     insert p;
        
    //     Product_Sales_Info__c psi = new Product_Sales_Info__c();
    //     psi.Product__c = p.Id;
    //     psi.Status__c = 'On Shelves';
    //     psi.Sales_Organization__c = '3010';
    //     psi.Delivering_Plant__c = '3010';
    //     Insert psi;
        
    //     Product_Name__c pn = new Product_Name__c();
    //     pn.Name = 'ZAR2Test';
    //     pn.Product_Sales_Info__c = psi.Id; 
    //     Insert pn;
        
    //     Product_Unit__c pu = new Product_Unit__c();
    //     pu.Basic_Unit__c = 'L';
    //     pu.Product_Sales_Unit__c = 'L';
    //     pu.Conversion_Coefficient__c = 1;
    //     pu.Product__c = p.Id;
    //     insert pu;
        
    //     Account a = new Account();
    //     a.Name = 'ZAR2Test';
    //     a.Group_Name__c = 'test';
    //     a.MDG_Customer_Code__c = 'ZAR2111';
    //     a.Customer_Approval_Status__c = 'Approved';
    //     a.Sync_Status__c = 'Synchronized';
    //     a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
    //     Insert a;
        
    //     Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
    //     csi.Sales_Org__c = '3010';
    //     csi.Distr_Channel__c = '10';
    //     csi.Sales_View_Status__c = 'Approved';
    //     csi.Sync_Status__c='Synchronized';
    //     csi.Customer__c = a.Id;
    //     csi.Division__c = '10';
    //     csi.Delivering_Plant__c = '3010';
    //     csi.Terms_Of_Payment__c = 'G001';
    //     csi.Sales_District__c = 'ZMX02';
    //     csi.Price_Group__c = '01';
    //     // csi.Payment_method__c = 'Z1';
    //     csi.Business_Model__c = 'C0';
    //     insert csi;

    //     Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
    //     cci.Customer__c = a.Id;
    //     cci.Rules__c = 'STANDARD';
    //     cci.Risk_Class__c = 'A';
    //     cci.Check_Rule__c = 'OV1';
    //     cci.Credit_Segment__c = 'Z000';
    //     cci.Valid_Until__c = Date.today();
    //     cci.Sinosure_Credit_Limit__c = 2;
    //     cci.Local_Credit_Limit__c = 2;
    //     cci.Actual_Credit_limit__c = 2;
    //     cci.Sync_Status__c = 'Synchronized';
    //     cci.Remaining_Credit__c = 2;
    //     cci.ExternalId__c = '1111';
    //     insert cci;
        
    //     Price_Book__c pb = new Price_Book__c();
    //     pb.Name = 'ZAR2Test';
    //     pb.Currency__c = 'USD';
    //     pb.Sales_Org__c = '5070';
    //     insert pb;

    //     Customer_Shipping_Address__c csa = new Customer_Shipping_Address__c();
    //     csa.Customer__c = a.Id;
    //     csa.Direction__c = '111';
    //     insert csa;

    //     Order__c order6 = new Order__c();
    //     order6.SAP_Order_Code__c = '123';
    //     order6.SAP_Order_Code2__c = '123';
    //     order6.Cust_Reference__c = '111';
    //     //order1.Inco_Location1__c = '11';
    //     order6.Customer__c = a.Id;
    //     order6.Sales_Org__c = '5070';
    //     order6.Distr_Channel__c = '00';
    //     order6.Customer_Sales_Info__c = csi.Id;
    //     order6.Currency__c = 'USD';
    //     order6.Price_Book__c = pb.Id;
    //     order6.Deliver_Plant__c = '5070';
    //     order6.Order_type__c = 'ZARE';
    //     order6.Customer_Shipping_Address__c = csa.Id;
    //     order6.Req_Deliv_Date__c = Date.today();
    //     // order1.Commission_Calculation_Method__c = 'Percent';
    //     // order1.Commission_Percentage__c = 1;
    //     // order1.Commission_To__c = a.Id;
    //     // order1.Commission_Type__c = 'Distributors';
    //     order6.Status__c = 'Approved';
    //     order6.RecordTypeId = Utility.modelCRecordTypeId;
    //     insert order6;



    //     // 创建发票
    //     Invoice__c invoice = new Invoice__c();
    //     invoice.Name = 'INV-001';
    //     invoice.Customer__c = order6.Customer__c;
    //     invoice.External_Id__c = 'Test'+ Datetime.now().getTime();
    //     insert invoice;
        

        
    //     // 创建ZAR2订单
    //     Order__c order1 = new Order__c();
    //     order1.SAP_Order_Code__c = 'ZAR2001';
    //     order1.Customer__c = a.Id;
    //     order1.Sales_Org__c = '3010';
    //     order1.Distr_Channel__c = '10';
    //     order1.Customer_Sales_Info__c = csi.Id;
    //     order1.Currency__c = 'USD';
    //     order1.Price_Book__c = pb.Id;
    //     order1.Deliver_Plant__c = '3010';
    //     order1.Order_type__c = 'ZMX1';
    //     order1.Invoice__c = invoice.Id;
    //     order1.Sync_Status__c = 'Synchronized';
    //     Insert order1;


        
    //     Order_Item__c orI1 = new Order_Item__c();
    //     orI1.Delivery_Date__c = System.today();
    //     orI1.SAP_Item_Num__c = '10';
    //     orI1.Quantity__c = 10;
    //     orI1.Material_Number__c = 'ZAR2Test';
    //     orI1.Sales_Unit__c = pu.Id;
    //     orI1.Order__c = order1.Id;
    //     orI1.Commodity__c = pn.Id;
    //     orI1.Price__c = 10;
    //     orI1.Gross_Weight__c = '10';
    //     orI1.Net_Weight__c = '10';
    //     orI1.Inventory_Location__c = 'PROD';
    //     orI1.Product_Usage__c = 'Test Usage';
    //     Insert orI1;
        
    //     Test.setMock(HttpCalloutMock.class, new TestHttpMock.OrderSyncToSAPSuccess());
    //     test.startTest();
    //     OrderSyncToSAP.submitToSAP(order1.Id,'I',false,false,'',String.valueOf(orI1.Id),false,false);
    //     test.stopTest();
    // }
    
    @IsTest
    static void testZARAOrderWithAutoIssueConsignmentSuccess() {
        // 测试 ZARA 订单 Auto_Issue_Consignment = true 且 Sync_Status != 'Synchronization error' 的情况
        Product__c p = new Product__c();
        p.Name = 'ZARASuccessTest';
        p.External_Id__c = 'ZARASuccessTest';
        insert p;
        
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '3020';
        psi.Delivering_Plant__c = '3020';
        Insert psi;
        
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'ZARASuccessTest';
        pn.Product_Sales_Info__c = psi.Id; 
        Insert pn;
        
        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;
        
        Account a = new Account();
        a.Name = 'ZARASuccessTest';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = 'ZARAS111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
        a.Customer_Type__c = 'Distributor';
        Insert a;

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
        csi.Sales_Org__c = '3020';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '3020';
        csi.Terms_Of_Payment__c = 'G001';
        csi.Sales_District__c = 'ZMX00';
        csi.Price_Group__c = '01';
        csi.Business_Model__c = 'C0';
        insert csi;
        
        Price_Book__c pb = new Price_Book__c();
        pb.Name = 'ZARASuccessTest';
        pb.Currency__c = 'USD';
        insert pb;
        
        // 创建源订单（ZARB）
        Order__c sourceOrder = new Order__c();
        sourceOrder.SAP_Order_Code__c = 'ZARB002';
        sourceOrder.Customer__c = a.Id;
        sourceOrder.Sales_Org__c = '3020';
        sourceOrder.Distr_Channel__c = '10';
        sourceOrder.Customer_Sales_Info__c = csi.Id;
        sourceOrder.Currency__c = 'USD';
        sourceOrder.Price_Book__c = pb.Id;
        sourceOrder.Deliver_Plant__c = '3020';
        sourceOrder.Order_type__c = 'ZMX1';
        sourceOrder.Sync_Status__c = 'Synchronized';
        Insert sourceOrder;
        
        // 创建ZARA订单 - Sync_Status != 'Synchronization error'
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = 'ZARA002';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARA';
        order1.Auto_Issue_Consignment__c = true;
        order1.DN_Post_Date__c = Date.today();
        order1.Source_Order__c = sourceOrder.Id;
        order1.Sync_Status__c = 'Synchronized'; // 不是 'Synchronization error'
        order1.Commission_To__c = a.Id; // 添加佣金对象
        order1.Order_Reason__c = '01';
        Insert order1;
        
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Delivery_Date__c = System.today();
        orI1.SAP_Item_Num__c = '10';
        orI1.Quantity__c = 10;
        orI1.Material_Number__c = 'ZARASuccessTest';
        orI1.Sales_Unit__c = pu.Id;
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = pn.Id;
        orI1.Price__c = 10;
        orI1.Gross_Weight__c = '10';
        orI1.Net_Weight__c = '10';
        orI1.Inventory_Location__c = 'PROD';
        orI1.Product_Usage__c = 'Crop using';
        orI1.IsCreate__c = true;
        Insert orI1;
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.OrderSyncToSAPSuccess());
        test.startTest();
        OrderSyncToSAP.submitToSAP(order1.Id,'I',false,false,'',String.valueOf(orI1.Id),false,false);
        test.stopTest();
    }
    
    @IsTest
    static void testZARAOrderWithAutoIssueConsignmentError() {
        // 测试 ZARA 订单 Auto_Issue_Consignment = true 且 Sync_Status == 'Synchronization error' 的情况
        Product__c p = new Product__c();
        p.Name = 'ZARAErrorTest';
        p.External_Id__c = 'ZARAErrorTest';
        insert p;
        
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '3020';
        psi.Delivering_Plant__c = '3020';
        Insert psi;
        
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'ZARAErrorTest';
        pn.Product_Sales_Info__c = psi.Id; 
        Insert pn;
        
        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;
        
        Account a = new Account();
        a.Name = 'ZARAErrorTest';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = 'ZARAE111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
        a.Customer_Type__c = 'Distributor';
        Insert a;

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
        csi.Sales_Org__c = '3020';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '3020';
        csi.Terms_Of_Payment__c = 'G001';
        csi.Sales_District__c = 'ZMX00';
        csi.Price_Group__c = '01';
        csi.Business_Model__c = 'C0';
        insert csi;
        
        Price_Book__c pb = new Price_Book__c();
        pb.Name = 'ZARAErrorTest';
        pb.Currency__c = 'USD';
        insert pb;
        
        // 创建源订单（ZARB）
        Order__c sourceOrder = new Order__c();
        sourceOrder.SAP_Order_Code__c = 'ZARB003';
        sourceOrder.Customer__c = a.Id;
        sourceOrder.Sales_Org__c = '3020';
        sourceOrder.Distr_Channel__c = '10';
        sourceOrder.Customer_Sales_Info__c = csi.Id;
        sourceOrder.Currency__c = 'USD';
        sourceOrder.Price_Book__c = pb.Id;
        sourceOrder.Deliver_Plant__c = '3020';
        sourceOrder.Order_type__c = 'ZMX1';
        sourceOrder.Sync_Status__c = 'Synchronized';
        Insert sourceOrder;
        
        // 创建ZARA订单 - Sync_Status == 'Synchronization error'
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = 'ZARA003';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARA';
        order1.Auto_Issue_Consignment__c = true;
        order1.DN_Post_Date__c = Date.today();
        order1.Source_Order__c = sourceOrder.Id;
        order1.Sync_Status__c = 'Synchronization error'; // 设置为 'Synchronization error'
        order1.Commission_To__c = a.Id; // 添加佣金对象
        order1.Order_Reason__c = '01';
        Insert order1;
        
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Delivery_Date__c = System.today();
        orI1.SAP_Item_Num__c = '10';
        orI1.Quantity__c = 10;
        orI1.Material_Number__c = 'ZARAErrorTest';
        orI1.Sales_Unit__c = pu.Id;
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = pn.Id;
        orI1.Price__c = 10;
        orI1.Gross_Weight__c = '10';
        orI1.Net_Weight__c = '10';
        orI1.Inventory_Location__c = 'PROD';
        orI1.Product_Usage__c = 'Crop using';
        orI1.IsCreate__c = true;
        Insert orI1;
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.OrderSyncToSAPSuccess());
        test.startTest();
        OrderSyncToSAP.submitToSAP(order1.Id,'I',false,false,'',String.valueOf(orI1.Id),false,false);
        test.stopTest();
    }
    
    @IsTest
    static void testZARADebug() {
        // 调试测试方法 - 简化版本
        Product__c p = new Product__c();
        p.Name = 'ZARADebug';
        p.External_Id__c = 'ZARADebug';
        insert p;
        
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '3020';
        psi.Delivering_Plant__c = '3020';
        Insert psi;
        
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'ZARADebug';
        pn.Product_Sales_Info__c = psi.Id; 
        Insert pn;
        
        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;
        
        Account a = new Account();
        a.Name = 'ZARADebug';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = 'ZARAD111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
        a.Customer_Type__c = 'Distributor';
        Insert a;

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
        csi.Sales_Org__c = '3020';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '3020';
        csi.Terms_Of_Payment__c = 'G001';
        csi.Sales_District__c = 'ZMX00';
        csi.Price_Group__c = '01';
        csi.Business_Model__c = 'C0';
        insert csi;
        
        Price_Book__c pb = new Price_Book__c();
        pb.Name = 'ZARADebug';
        pb.Currency__c = 'USD';
        insert pb;
        
        // 创建源订单（ZARB）
        Order__c sourceOrder = new Order__c();
        sourceOrder.SAP_Order_Code__c = 'ZARB004';
        sourceOrder.Customer__c = a.Id;
        sourceOrder.Sales_Org__c = '5130';
        sourceOrder.Distr_Channel__c = '00';
        sourceOrder.Customer_Sales_Info__c = csi.Id;
        sourceOrder.Currency__c = 'USD';
        sourceOrder.Price_Book__c = pb.Id;
        sourceOrder.Deliver_Plant__c = '5130';
        sourceOrder.Order_type__c = 'ZARB';
        sourceOrder.Sync_Status__c = 'Synchronized';
        Insert sourceOrder;
        
        // 创建ZARA订单 - 确保所有必要字段都设置
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = 'ZARA004';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARA';
        order1.Auto_Issue_Consignment__c = true;
        order1.DN_Post_Date__c = Date.today();
        order1.Source_Order__c = sourceOrder.Id;
        order1.Sync_Status__c = 'Synchronization error';
        order1.Commission_To__c = a.Id;
        order1.Commission_Percentage__c = 5;
        order1.Commission_Amount_New__c = 100;
        order1.Order_Reason__c = '01';
        Insert order1;
        
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Delivery_Date__c = System.today();
        orI1.SAP_Item_Num__c = '10';
        orI1.Quantity__c = 10;
        orI1.Material_Number__c = 'ZARADebug';
        orI1.Sales_Unit__c = pu.Id;
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = pn.Id;
        orI1.Price__c = 10;
        orI1.Gross_Weight__c = '10';
        orI1.Net_Weight__c = '10';
        orI1.Inventory_Location__c = 'PROD';
        orI1.Product_Usage__c = 'Crop using';
        orI1.IsCreate__c = true;
        Insert orI1;
        
        // 使用一个简单的 mock 来避免复杂的响应处理
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.OrderSyncToSAPSuccess());
        test.startTest();
        
        // 添加调试信息
        System.debug('Order Type: ' + order1.Order_type__c);
        System.debug('Auto Issue Consignment: ' + order1.Auto_Issue_Consignment__c);
        System.debug('Sync Status: ' + order1.Sync_Status__c);
        System.debug('DN Post Date: ' + order1.DN_Post_Date__c);
        System.debug('Source Order: ' + order1.Source_Order__c);
        System.debug('Commission To: ' + order1.Commission_To__c);
        
        OrderSyncToSAP.submitToSAP(order1.Id,'I',false,false,'',String.valueOf(orI1.Id),false,false);
        test.stopTest();
    }
    
}