/**
 * @description       : OrderItemTriggerHandler测试类
 * @author            : Assistant
 * @group             : 
 * @last modified on  : 03-05-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   01-20-2025   Assistant   Initial Version
**/
@IsTest
private class OrderItemTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void testMethod1() { 
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '5070';
        psi.Delivering_Plant__c = '5070';
        Insert psi;

        List<Product_Name__c> pns = new List<Product_Name__c>();
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'Test';
        pn.Product_Combo__c = false;
        pn.Product_Sales_Info__c = psi.Id; 
        // Insert pn;
        pns.add(pn);

        Product_Name__c comboProductName = new Product_Name__c();
        comboProductName.Name = 'ComboProductName';
        comboProductName.Product_Sales_Info__c = psi.Id;
        comboProductName.Product__c = p.Id;
        comboProductName.Product_Combo__c = true;
        comboProductName.Is_Delete__c = false;
        // insert comboProductName;
        pns.add(comboProductName);
        insert pns;

        Product_Name_Item__c comboItem = new Product_Name_Item__c();
        comboItem.Product_Combo_Name__c = comboProductName.Id;
        comboItem.Product_Name__c = pn.Id;
        comboItem.List_Price__c = 50;
        comboItem.Quantity__c = 2;
        insert comboItem;

        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;

        Product_Inventory__c pi = new Product_Inventory__c();
        pi.Search_Key__c = '12341234'+'-'+'5070'+'-'+'Test';
        pi.Inventory_Quantity__c = 1;
        pi.Product__c = p.Id;
        Insert pi;

        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.customer_TYpe__c = 'Distributor';
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
        csi.Sales_Org__c = '5070';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5070';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Price_Group__c = '02';
        csi.Payment_method__c = 'YPF';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        csi.Acct_Assmt_Grp_Cust__c = '02';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Sales_Org__c = '5070';
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;

        Price_Book_Item__c priceBookItem = new Price_Book_Item__c();
        priceBookItem.Price_Book__c = pb.Id;
        priceBookItem.Product_Name__c = comboProductName.Id;
        priceBookItem.Price__c = 100;
        priceBookItem.Min_Sales_Price__c = 80;
        priceBookItem.Is_Changing__c = false;
        priceBookItem.Status__c = 'Active';
        priceBookItem.Estimation_Cost_Local__c = 50;
        priceBookItem.Estimation_Cost_USD__c = 10;
        insert priceBookItem;
    
        List<Order__c> orders = new List<Order__c>();
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '123';
        order1.SAP_Order_Code2__c = '123';
        order1.Cust_Reference__c = '111';
        //order1.Inco_Location1__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5070';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5070';
        order1.Order_type__c = 'ZARE';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        order1.Interest_Rate__c = 1;
        // order1.Commission_Calculation_Method__c = 'Percent';
        // order1.Commission_Percentage__c = 1;
        // order1.Commission_To__c = a.Id;
        // order1.Commission_Type__c = 'Distributors';
        order1.Status__c = 'Approved';
        order1.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order1;
        orders.add(order1);

        Order__c order2 = new Order__c();
        order2.SAP_Order_Code__c = '1234';
        order2.SAP_Order_Code2__c = '1234';
        order2.Cust_Reference__c = '1114';
        //order2.Inco_Location1__c = '11';
        order2.Customer__c = a.Id;
        order2.Sales_Org__c = '5070';
        order2.Distr_Channel__c = '00';
        order2.Customer_Sales_Info__c = csi.Id;
        order2.Currency__c = 'USD';
        order2.Price_Book__c = pb.Id;
        order2.Deliver_Plant__c = '5070';
        order2.Order_type__c = 'ZARB';
        order2.Customer_Shipping_Address__c = csa.Id;
        order2.Req_Deliv_Date__c = Date.today();
        // order2.Commission_Calculation_Method__c = 'Percent';
        // order2.Commission_Percentage__c = 1;
        // order2.Commission_To__c = a.Id;
        // order2.Commission_Type__c = 'Distributors';
        order2.Status__c = 'Approved';
        order2.Interest_Rate__c = 1;
        order2.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order2;
        orders.add(order2);

        insert orders;

        Invoice__c invoice = new Invoice__c();
        invoice.Name = 'INV-001';
        invoice.Customer__c = order1.Customer__c;
        invoice.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert invoice;

        Billing__c billing = new Billing__c();
        billing.Order__c = order1.Id;
        billing.Invoice__c = invoice.Id;
        billing.Invoice_Quantity__c = 0;
        billing.Billing_Num__c = '0';
        billing.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert billing;
        

        List<Order_Item__c> orderItems = new List<Order_Item__c>();

        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order1.Id;
        orderItem.Invoice_Item__c = billing.Id;
        orderItem.Commodity__c = comboProductName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Quantity__c = 0;
        orderItem.Price__c = 100;
        orderItem.Sales_Unit__c = pu.Id;
        orderItem.SAP_Item_Num__c = '001';
        orderItem.Product_Type__c = 'Free Product';
        orderItem.IsCreate__c = true;
        orderItem.Product_Cost__c = 10;
        orderItem.Product_Type__c = 'Normal Product';
        orderItem.Guide_Price__c = 100;
        orderItem.Price__c = 10;
        orderItem.Delivery_Date__c = Date.today();
        orderItem.SAP_Total_Net__c =  100;
        orderItem.Amount_per_item__c =  10;
        // insert orderItem;
        orderItems.add(orderItem);

        Order_Item__c orderItem2 = new Order_Item__c();
        orderItem2.Order__c = order1.Id;
        orderItem2.Invoice_Item__c = billing.Id;
        orderItem2.Commodity__c = comboProductName.Id;
        orderItem2.Price_Book_Item__c = priceBookItem.Id;
        orderItem2.Quantity__c = 0;
        orderItem2.Price__c = 100;
        orderItem2.Sales_Unit__c = pu.Id;
        orderItem2.SAP_Item_Num__c = '001';
        orderItem2.Product_Type__c = 'Free Product';
        orderItem2.IsCreate__c = true;
        orderItem2.Product_Cost__c = 10;
        orderItem2.Product_Type__c = 'Normal Product';
        orderItem2.Guide_Price__c = 100;
        orderItem2.Price__c = 10;
        // insert orderItem2;
        orderItems.add(orderItem2);
        Test.startTest();
        Order_Item__c orderItem3 = new Order_Item__c();
        orderItem3.Order__c = order2.Id;
        orderItem3.Invoice_Item__c = billing.Id;
        orderItem3.Commodity__c = comboProductName.Id;
        orderItem3.Price_Book_Item__c = priceBookItem.Id;
        orderItem3.Quantity__c = 0;
        orderItem3.Price__c = 100;
        orderItem3.Sales_Unit__c = pu.Id;
        orderItem3.SAP_Item_Num__c = '001';
        orderItem3.Product_Type__c = 'Free Product';
        orderItem3.IsCreate__c = true;
        orderItem3.Product_Cost__c = 10;
        orderItem3.Product_Type__c = 'Normal Product';
        orderItem3.Guide_Price__c = 100;
        orderItem3.Price__c = 10;
        // insert orderItem3;
        orderItems.add(orderItem3);

        insert orderItems;

        Delivery_Note__c dn = new Delivery_Note__c();
        dn.Order__c = order2.Id;
        dn.Order_Item__c = orderItem3.Id;
        dn.Auto_ZARA_Issue_Quantity__c = 10;
        dn.Delivery_Quantity__c = 5;
        dn.Delivery_Post_Date__c = Date.today();
        dn.Auto_issue_Consignment__c = false;
        dn.Issue_Quantity__c = 2;
        dn.Delivery_Post_Status__c = 'C';
        insert dn;

        
        orderItem.Quantity__c =  1;
        orderItem.isClosed__c =  true;
        try {
            update orderItem;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testMethod2() { 
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '5070';
        psi.Delivering_Plant__c = '5070';
        Insert psi;

        List<Product_Name__c> pns = new List<Product_Name__c>();
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'Test';
        pn.Product_Combo__c = false;
        pn.Product_Sales_Info__c = psi.Id; 
        // Insert pn;
        pns.add(pn);

        Product_Name__c comboProductName = new Product_Name__c();
        comboProductName.Name = 'ComboProductName';
        comboProductName.Product_Sales_Info__c = psi.Id;
        comboProductName.Product__c = p.Id;
        comboProductName.Product_Combo__c = true;
        comboProductName.Is_Delete__c = false;
        // insert comboProductName;
        pns.add(comboProductName);
        insert pns;

        Product_Name_Item__c comboItem = new Product_Name_Item__c();
        comboItem.Product_Combo_Name__c = comboProductName.Id;
        comboItem.Product_Name__c = pn.Id;
        comboItem.List_Price__c = 50;
        comboItem.Quantity__c = 2;
        insert comboItem;

        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;

        Product_Inventory__c pi = new Product_Inventory__c();
        pi.Search_Key__c = '12341234'+'-'+'5070'+'-'+'Test';
        pi.Inventory_Quantity__c = 1;
        pi.Product__c = p.Id;
        Insert pi;

        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.customer_TYpe__c = 'Distributor';
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
        csi.Sales_Org__c = '5070';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5070';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Price_Group__c = '02';
        csi.Payment_method__c = 'YPF';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        csi.Acct_Assmt_Grp_Cust__c = '02';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Sales_Org__c = '5070';
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;

        Price_Book_Item__c priceBookItem = new Price_Book_Item__c();
        priceBookItem.Price_Book__c = pb.Id;
        priceBookItem.Product_Name__c = comboProductName.Id;
        priceBookItem.Price__c = 100;
        priceBookItem.Min_Sales_Price__c = 80;
        priceBookItem.Is_Changing__c = false;
        priceBookItem.Status__c = 'Active';
        priceBookItem.Estimation_Cost_Local__c = 50;
        priceBookItem.Estimation_Cost_USD__c = 10;
        insert priceBookItem;
        Test.startTest();
        List<Order__c> orders = new List<Order__c>();
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '123';
        order1.SAP_Order_Code2__c = '123';
        order1.Cust_Reference__c = '111';
        //order1.Inco_Location1__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5070';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5070';
        order1.Order_type__c = 'ZARE';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        order1.Interest_Rate__c = 1;
        // order1.Commission_Calculation_Method__c = 'Percent';
        // order1.Commission_Percentage__c = 1;
        // order1.Commission_To__c = a.Id;
        // order1.Commission_Type__c = 'Distributors';
        order1.Status__c = 'Approved';
        order1.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order1;
        orders.add(order1);

        Order__c order2 = new Order__c();
        order2.SAP_Order_Code__c = '1234';
        order2.SAP_Order_Code2__c = '1234';
        order2.Cust_Reference__c = '1114';
        //order2.Inco_Location1__c = '11';
        order2.Customer__c = a.Id;
        order2.Sales_Org__c = '5070';
        order2.Distr_Channel__c = '00';
        order2.Customer_Sales_Info__c = csi.Id;
        order2.Currency__c = 'USD';
        order2.Price_Book__c = pb.Id;
        order2.Deliver_Plant__c = '5070';
        order2.Order_type__c = 'ZARB';
        order2.Customer_Shipping_Address__c = csa.Id;
        order2.Req_Deliv_Date__c = Date.today();
        // order2.Commission_Calculation_Method__c = 'Percent';
        // order2.Commission_Percentage__c = 1;
        // order2.Commission_To__c = a.Id;
        // order2.Commission_Type__c = 'Distributors';
        order2.Status__c = 'Approved';
        order2.Interest_Rate__c = 1;
        order2.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order2;
        orders.add(order2);

        insert orders;

        Invoice__c invoice = new Invoice__c();
        invoice.Name = 'INV-001';
        invoice.Customer__c = order1.Customer__c;
        invoice.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert invoice;

        Billing__c billing = new Billing__c();
        billing.Order__c = order1.Id;
        billing.Invoice__c = invoice.Id;
        billing.Invoice_Quantity__c = 0;
        billing.Billing_Num__c = '0';
        billing.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert billing;
        

        List<Order_Item__c> orderItems = new List<Order_Item__c>();

        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order1.Id;
        orderItem.Invoice_Item__c = billing.Id;
        orderItem.Commodity__c = comboProductName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Quantity__c = 0;
        orderItem.Price__c = 100;
        orderItem.Sales_Unit__c = pu.Id;
        orderItem.SAP_Item_Num__c = '001';
        orderItem.Product_Type__c = 'Free Product';
        orderItem.IsCreate__c = true;
        orderItem.Product_Cost__c = 10;
        orderItem.Product_Type__c = 'Normal Product';
        orderItem.Guide_Price__c = 100;
        orderItem.Price__c = 10;
        orderItem.Delivery_Date__c = Date.today();
        orderItem.SAP_Total_Net__c =  100;
        orderItem.Amount_per_item__c =  10;
        // insert orderItem;
        orderItems.add(orderItem);

        Order_Item__c orderItem2 = new Order_Item__c();
        orderItem2.Order__c = order1.Id;
        orderItem2.Invoice_Item__c = billing.Id;
        orderItem2.Commodity__c = comboProductName.Id;
        orderItem2.Price_Book_Item__c = priceBookItem.Id;
        orderItem2.Quantity__c = 0;
        orderItem2.Price__c = 100;
        orderItem2.Sales_Unit__c = pu.Id;
        orderItem2.SAP_Item_Num__c = '001';
        orderItem2.Product_Type__c = 'Free Product';
        orderItem2.IsCreate__c = true;
        orderItem2.Product_Cost__c = 10;
        orderItem2.Product_Type__c = 'Normal Product';
        orderItem2.Guide_Price__c = 100;
        orderItem2.Price__c = 10;
        // insert orderItem2;
        orderItems.add(orderItem2);

        Order_Item__c orderItem3 = new Order_Item__c();
        orderItem3.Order__c = order2.Id;
        orderItem3.Invoice_Item__c = billing.Id;
        orderItem3.Commodity__c = comboProductName.Id;
        orderItem3.Price_Book_Item__c = priceBookItem.Id;
        orderItem3.Quantity__c = 0;
        orderItem3.Price__c = 100;
        orderItem3.Sales_Unit__c = pu.Id;
        orderItem3.SAP_Item_Num__c = '001';
        orderItem3.Product_Type__c = 'Free Product';
        orderItem3.IsCreate__c = true;
        orderItem3.Product_Cost__c = 10;
        orderItem3.Product_Type__c = 'Normal Product';
        orderItem3.Guide_Price__c = 100;
        orderItem3.Price__c = 10;
        // insert orderItem3;
        orderItems.add(orderItem3);

        insert orderItems;

        Delivery_Note__c dn = new Delivery_Note__c();
        dn.Order__c = order2.Id;
        dn.Order_Item__c = orderItem3.Id;
        dn.Auto_ZARA_Issue_Quantity__c = 10;
        dn.Delivery_Quantity__c = 5;
        dn.Delivery_Post_Date__c = Date.today();
        dn.Auto_issue_Consignment__c = false;
        dn.Issue_Quantity__c = 2;
        dn.Delivery_Post_Status__c = 'C';
        insert dn;

        
        orderItem.Quantity__c =  5;
        orderItem.isClosed__c =  true;
        try {
            update orderItem;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testMethod3() { 
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '5070';
        psi.Delivering_Plant__c = '5070';
        Insert psi;

        List<Product_Name__c> pns = new List<Product_Name__c>();
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'Test';
        pn.Product_Combo__c = false;
        pn.Product_Sales_Info__c = psi.Id; 
        // Insert pn;
        pns.add(pn);

        Product_Name__c comboProductName = new Product_Name__c();
        comboProductName.Name = 'ComboProductName';
        comboProductName.Product_Sales_Info__c = psi.Id;
        comboProductName.Product__c = p.Id;
        comboProductName.Product_Combo__c = true;
        comboProductName.Is_Delete__c = false;
        // insert comboProductName;
        pns.add(comboProductName);
        insert pns;

        Product_Name_Item__c comboItem = new Product_Name_Item__c();
        comboItem.Product_Combo_Name__c = comboProductName.Id;
        comboItem.Product_Name__c = pn.Id;
        comboItem.List_Price__c = 50;
        comboItem.Quantity__c = 2;
        insert comboItem;

        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;

        Product_Inventory__c pi = new Product_Inventory__c();
        pi.Search_Key__c = '12341234'+'-'+'5070'+'-'+'Test';
        pi.Inventory_Quantity__c = 1;
        pi.Product__c = p.Id;
        Insert pi;

        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.customer_TYpe__c = 'Distributor';
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
        csi.Sales_Org__c = '5070';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5070';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Price_Group__c = '02';
        csi.Payment_method__c = 'YPF';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        csi.Acct_Assmt_Grp_Cust__c = '02';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Sales_Org__c = '5070';
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;

        Price_Book_Item__c priceBookItem = new Price_Book_Item__c();
        priceBookItem.Price_Book__c = pb.Id;
        priceBookItem.Product_Name__c = comboProductName.Id;
        priceBookItem.Price__c = 100;
        priceBookItem.Min_Sales_Price__c = 80;
        priceBookItem.Is_Changing__c = false;
        priceBookItem.Status__c = 'Active';
        priceBookItem.Estimation_Cost_Local__c = 50;
        priceBookItem.Estimation_Cost_USD__c = 10;
        insert priceBookItem;
    
        List<Order__c> orders = new List<Order__c>();
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '123';
        order1.SAP_Order_Code2__c = '123';
        order1.Cust_Reference__c = '111';
        //order1.Inco_Location1__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5070';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5070';
        order1.Order_type__c = 'ZARE';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        // order1.Commission_Calculation_Method__c = 'Percent';
        // order1.Commission_Percentage__c = 1;
        // order1.Commission_To__c = a.Id;
        // order1.Commission_Type__c = 'Distributors';
        order1.Interest_Rate__c = 1;
        order1.Status__c = 'Approved';
        order1.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order1;
        orders.add(order1);
        System.Test.startTest();
        Order__c order2 = new Order__c();
        order2.SAP_Order_Code__c = '1234';
        order2.SAP_Order_Code2__c = '1234';
        order2.Cust_Reference__c = '1114';
        //order2.Inco_Location1__c = '11';
        order2.Customer__c = a.Id;
        order2.Sales_Org__c = '5070';
        order2.Distr_Channel__c = '00';
        order2.Customer_Sales_Info__c = csi.Id;
        order2.Currency__c = 'USD';
        order2.Price_Book__c = pb.Id;
        order2.Deliver_Plant__c = '5070';
        order2.Order_type__c = 'ZARB';
        order2.Customer_Shipping_Address__c = csa.Id;
        order2.Req_Deliv_Date__c = Date.today();
        // order2.Commission_Calculation_Method__c = 'Percent';
        // order2.Commission_Percentage__c = 1;
        // order2.Commission_To__c = a.Id;
        // order2.Commission_Type__c = 'Distributors';
        order2.Status__c = 'Approved';
        order2.Interest_Rate__c = 1;
        order2.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order2;
        orders.add(order2);

        insert orders;

        Invoice__c invoice = new Invoice__c();
        invoice.Name = 'INV-001';
        invoice.Customer__c = order1.Customer__c;
        invoice.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert invoice;

        Billing__c billing = new Billing__c();
        billing.Order__c = order1.Id;
        billing.Invoice__c = invoice.Id;
        billing.Invoice_Quantity__c = 0;
        billing.Billing_Num__c = '0';
        billing.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert billing;
        

        List<Order_Item__c> orderItems = new List<Order_Item__c>();

        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order1.Id;
        orderItem.Invoice_Item__c = billing.Id;
        orderItem.Commodity__c = comboProductName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Quantity__c = 0;
        orderItem.Price__c = 100;
        orderItem.Sales_Unit__c = pu.Id;
        orderItem.SAP_Item_Num__c = '001';
        orderItem.Product_Type__c = 'Free Product';
        orderItem.IsCreate__c = true;
        orderItem.Product_Cost__c = 10;
        orderItem.Product_Type__c = 'Normal Product';
        orderItem.Guide_Price__c = 100;
        orderItem.Delivery_Date__c = Date.today();
        orderItem.SAP_Total_Net__c =  100;
        orderItem.Amount_per_item__c =  10;
        // insert orderItem;
        orderItems.add(orderItem);

        Order_Item__c orderItem2 = new Order_Item__c();
        orderItem2.Order__c = order1.Id;
        orderItem2.Invoice_Item__c = billing.Id;
        orderItem2.Commodity__c = comboProductName.Id;
        orderItem2.Price_Book_Item__c = priceBookItem.Id;
        orderItem2.Quantity__c = 0;
        orderItem2.Price__c = 100;
        orderItem2.Sales_Unit__c = pu.Id;
        orderItem2.SAP_Item_Num__c = '001';
        orderItem2.Product_Type__c = 'Free Product';
        orderItem2.IsCreate__c = true;
        orderItem2.Product_Cost__c = 10;
        orderItem2.Product_Type__c = 'Normal Product';
        orderItem2.Guide_Price__c = 100;
        // insert orderItem2;
        orderItems.add(orderItem2);

        Order_Item__c orderItem3 = new Order_Item__c();
        orderItem3.Order__c = order2.Id;
        orderItem3.Invoice_Item__c = billing.Id;
        orderItem3.Commodity__c = comboProductName.Id;
        orderItem3.Price_Book_Item__c = priceBookItem.Id;
        orderItem3.Quantity__c = 12;
        orderItem3.Price__c = 100;
        orderItem3.Sales_Unit__c = pu.Id;
        orderItem3.SAP_Item_Num__c = '001';
        orderItem3.Product_Type__c = 'Free Product';
        orderItem3.IsCreate__c = true;
        orderItem3.Product_Cost__c = 10;
        orderItem3.Product_Type__c = 'Normal Product';
        orderItem3.Guide_Price__c = 100;
        // insert orderItem3;
        orderItems.add(orderItem3);

        insert orderItems;

        Delivery_Note__c dn = new Delivery_Note__c();
        dn.Order__c = order2.Id;
        dn.Order_Item__c = orderItem3.Id;
        dn.Delivery_Quantity__c = 5;
        dn.Delivery_Post_Date__c = Date.today();
        dn.Auto_issue_Consignment__c = false;
        dn.Issue_Quantity__c = 7;
        dn.Auto_ZARA_Issue_Quantity__c = 2;
        dn.Delivery_Post_Status__c = 'C';
        insert dn;

        
        orderItem.Quantity__c =  10;
        orderItem.isClosed__c =  true;
        orderItem.Depend_On_Item__c = orderItem3.Id;
        try {
            update orderItem;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testMethod4() { 
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '5070';
        psi.Delivering_Plant__c = '5070';
        Insert psi;

        List<Product_Name__c> pns = new List<Product_Name__c>();
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'Test';
        pn.Product_Combo__c = false;
        pn.Product_Sales_Info__c = psi.Id; 
        // Insert pn;
        pns.add(pn);

        Product_Name__c comboProductName = new Product_Name__c();
        comboProductName.Name = 'ComboProductName';
        comboProductName.Product_Sales_Info__c = psi.Id;
        comboProductName.Product__c = p.Id;
        comboProductName.Product_Combo__c = true;
        comboProductName.Is_Delete__c = false;
        // insert comboProductName;
        pns.add(comboProductName);
        insert pns;

        Product_Name_Item__c comboItem = new Product_Name_Item__c();
        comboItem.Product_Combo_Name__c = comboProductName.Id;
        comboItem.Product_Name__c = pn.Id;
        comboItem.List_Price__c = 50;
        comboItem.Quantity__c = 2;
        insert comboItem;

        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;

        Product_Inventory__c pi = new Product_Inventory__c();
        pi.Search_Key__c = '12341234'+'-'+'5070'+'-'+'Test';
        pi.Inventory_Quantity__c = 1;
        pi.Product__c = p.Id;
        Insert pi;

        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.customer_TYpe__c = 'Distributor';
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
        csi.Sales_Org__c = '5070';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5070';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Price_Group__c = '02';
        csi.Payment_method__c = 'YPF';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        csi.Acct_Assmt_Grp_Cust__c = '02';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Sales_Org__c = '5070';
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;

        Price_Book_Item__c priceBookItem = new Price_Book_Item__c();
        priceBookItem.Price_Book__c = pb.Id;
        priceBookItem.Product_Name__c = comboProductName.Id;
        priceBookItem.Price__c = 100;
        priceBookItem.Min_Sales_Price__c = 80;
        priceBookItem.Is_Changing__c = false;
        priceBookItem.Status__c = 'Active';
        priceBookItem.Estimation_Cost_Local__c = 50;
        priceBookItem.Estimation_Cost_USD__c = 10;
        insert priceBookItem;
    
        List<Order__c> orders = new List<Order__c>();
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '123';
        order1.SAP_Order_Code2__c = '123';
        order1.Cust_Reference__c = '111';
        //order1.Inco_Location1__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5070';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5070';
        order1.Order_type__c = 'ZARE';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        // order1.Commission_Calculation_Method__c = 'Percent';
        // order1.Commission_Percentage__c = 1;
        // order1.Commission_To__c = a.Id;
        // order1.Commission_Type__c = 'Distributors';
        order1.Status__c = 'Approving';
        order1.Interest_Rate__c = 1;
        order1.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order1;
        orders.add(order1);

        Order__c order2 = new Order__c();
        order2.SAP_Order_Code__c = '1234';
        order2.SAP_Order_Code2__c = '1234';
        order2.Cust_Reference__c = '1114';
        //order2.Inco_Location1__c = '11';
        order2.Customer__c = a.Id;
        order2.Sales_Org__c = '5070';
        order2.Distr_Channel__c = '00';
        order2.Customer_Sales_Info__c = csi.Id;
        order2.Currency__c = 'USD';
        order2.Price_Book__c = pb.Id;
        order2.Deliver_Plant__c = '5070';
        order2.Order_type__c = 'ZARF';
        order2.Order_Reason__c = '001';
        order2.Customer_Shipping_Address__c = csa.Id;
        order2.Req_Deliv_Date__c = Date.today();
        // order2.Commission_Calculation_Method__c = 'Percent';
        // order2.Commission_Percentage__c = 1;
        // order2.Commission_To__c = a.Id;
        // order2.Commission_Type__c = 'Distributors';
        order2.Status__c = 'Approving';
        order2.Interest_Rate__c = 1;
        order2.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order2;
        orders.add(order2);

        Test.startTest();
        insert orders;

        Invoice__c invoice = new Invoice__c();
        invoice.Name = 'INV-001';
        invoice.Customer__c = order1.Customer__c;
        invoice.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert invoice;

        Billing__c billing = new Billing__c();
        billing.Order__c = order1.Id;
        billing.Invoice__c = invoice.Id;
        billing.Invoice_Quantity__c = 0;
        billing.Billing_Num__c = '0';
        billing.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert billing;
        

        List<Order_Item__c> orderItems = new List<Order_Item__c>();

        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order1.Id;
        orderItem.Invoice_Item__c = billing.Id;
        orderItem.Commodity__c = comboProductName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Quantity__c = 0;
        orderItem.Price__c = 100;
        orderItem.Sales_Unit__c = pu.Id;
        orderItem.SAP_Item_Num__c = '001';
        orderItem.Product_Type__c = 'Free Product';
        orderItem.IsCreate__c = true;
        orderItem.Product_Cost__c = 10;
        orderItem.Product_Type__c = 'Normal Product';
        orderItem.Guide_Price__c = 100;
        orderItem.Delivery_Date__c = Date.today();
        orderItem.SAP_Total_Net__c =  100;
        orderItem.Amount_per_item__c =  10;
        // insert orderItem;
        orderItems.add(orderItem);

        Order_Item__c orderItem2 = new Order_Item__c();
        orderItem2.Order__c = order1.Id;
        orderItem2.Invoice_Item__c = billing.Id;
        orderItem2.Commodity__c = comboProductName.Id;
        orderItem2.Price_Book_Item__c = priceBookItem.Id;
        orderItem2.Quantity__c = 0;
        orderItem2.Price__c = 100;
        orderItem2.Sales_Unit__c = pu.Id;
        orderItem2.SAP_Item_Num__c = '001';
        orderItem2.Product_Type__c = 'Free Product';
        orderItem2.IsCreate__c = true;
        orderItem2.Product_Cost__c = 10;
        orderItem2.Product_Type__c = 'Normal Product';
        orderItem2.Guide_Price__c = 100;
        // insert orderItem2;
        orderItems.add(orderItem2);

        Order_Item__c orderItem3 = new Order_Item__c();
        orderItem3.Order__c = order2.Id;
        orderItem3.Invoice_Item__c = billing.Id;
        orderItem3.Commodity__c = comboProductName.Id;
        orderItem3.Price_Book_Item__c = priceBookItem.Id;
        orderItem3.Quantity__c = 12;
        orderItem3.Price__c = 100;
        orderItem3.Sales_Unit__c = pu.Id;
        orderItem3.SAP_Item_Num__c = '001';
        orderItem3.Product_Type__c = 'Free Product';
        orderItem3.IsCreate__c = true;
        orderItem3.Product_Cost__c = 10;
        orderItem3.Product_Type__c = 'Normal Product';
        orderItem3.Guide_Price__c = 100;
        // insert orderItem3;
        orderItems.add(orderItem3);

        insert orderItems;

        Delivery_Note__c dn = new Delivery_Note__c();
        dn.Order__c = order2.Id;
        dn.Order_Item__c = orderItem3.Id;
        dn.Delivery_Quantity__c = 5;
        dn.Delivery_Post_Date__c = Date.today();
        dn.Auto_issue_Consignment__c = false;
        dn.Issue_Quantity__c = 7;
        dn.Auto_ZARA_Issue_Quantity__c = 2;
        dn.Delivery_Post_Status__c = 'C';
        insert dn;

        
        // orderItem.Quantity__c =  10;
        // orderItem.isClosed__c =  true;
        // orderItem.Depend_On_Item__c = orderItem3.Id;

        try {
            // update orderItem;
            Map<Id,Order__c> orderNewMap = new Map<Id,Order__c>();
            orderNewMap.put(order2.Id, order2);
            OrderItemTriggerHandler.validateApprovingOrder(orderNewMap);

            OrderItemTriggerHandler.splitZAREToZARB(new Set<Id>{orderItem.Id, orderItem2.Id, orderItem3.Id},'5070',false,true);

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testMethod5() { 
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '5070';
        psi.Delivering_Plant__c = '5070';
        Insert psi;

        List<Product_Name__c> pns = new List<Product_Name__c>();
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'Test';
        pn.Product_Combo__c = false;
        pn.Product_Sales_Info__c = psi.Id; 
        // Insert pn;
        pns.add(pn);

        Product_Name__c comboProductName = new Product_Name__c();
        comboProductName.Name = 'ComboProductName';
        comboProductName.Product_Sales_Info__c = psi.Id;
        comboProductName.Product__c = p.Id;
        comboProductName.Product_Combo__c = true;
        comboProductName.Is_Delete__c = false;
        // insert comboProductName;
        pns.add(comboProductName);
        insert pns;

        Product_Name_Item__c comboItem = new Product_Name_Item__c();
        comboItem.Product_Combo_Name__c = comboProductName.Id;
        comboItem.Product_Name__c = pn.Id;
        comboItem.List_Price__c = 50;
        comboItem.Quantity__c = 2;
        insert comboItem;

        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;

        Product_Inventory__c pi = new Product_Inventory__c();
        pi.Search_Key__c = '12341234'+'-'+'5070'+'-'+'Test';
        pi.Inventory_Quantity__c = 1;
        pi.Product__c = p.Id;
        Insert pi;

        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.customer_TYpe__c = 'Distributor';
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
        csi.Sales_Org__c = '5070';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5070';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Price_Group__c = '02';
        csi.Payment_method__c = 'YPF';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        csi.Acct_Assmt_Grp_Cust__c = '02';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Sales_Org__c = '5070';
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;

        Price_Book_Item__c priceBookItem = new Price_Book_Item__c();
        priceBookItem.Price_Book__c = pb.Id;
        priceBookItem.Product_Name__c = comboProductName.Id;
        priceBookItem.Price__c = 100;
        priceBookItem.Min_Sales_Price__c = 80;
        priceBookItem.Is_Changing__c = false;
        priceBookItem.Status__c = 'Active';
        priceBookItem.Estimation_Cost_Local__c = 50;
        priceBookItem.Estimation_Cost_USD__c = 10;
        insert priceBookItem;
    
        List<Order__c> orders = new List<Order__c>();
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '123';
        order1.SAP_Order_Code2__c = '123';
        order1.Cust_Reference__c = '111';
        //order1.Inco_Location1__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5070';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5070';
        order1.Order_type__c = 'ZARE';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        // order1.Commission_Calculation_Method__c = 'Percent';
        // order1.Commission_Percentage__c = 1;
        // order1.Commission_To__c = a.Id;
        // order1.Commission_Type__c = 'Distributors';
        order1.Status__c = 'Approved';
        order1.Interest_Rate__c = 1;
        order1.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order1;
        orders.add(order1);

        Order__c order2 = new Order__c();
        order2.SAP_Order_Code__c = '1234';
        order2.SAP_Order_Code2__c = '1234';
        order2.Cust_Reference__c = '1114';
        //order2.Inco_Location1__c = '11';
        order2.Customer__c = a.Id;
        order2.Sales_Org__c = '5070';
        order2.Distr_Channel__c = '00';
        order2.Customer_Sales_Info__c = csi.Id;
        order2.Currency__c = 'USD';
        order2.Price_Book__c = pb.Id;
        order2.Deliver_Plant__c = '5070';
        order2.Order_type__c = 'ZARB';
        order2.Order_Reason__c = '001';
        order2.Customer_Shipping_Address__c = csa.Id;
        order2.Req_Deliv_Date__c = Date.today();
        // order2.Commission_Calculation_Method__c = 'Percent';
        // order2.Commission_Percentage__c = 1;
        // order2.Commission_To__c = a.Id;
        // order2.Commission_Type__c = 'Distributors';
        order2.Status__c = 'Approved';
        order2.Interest_Rate__c = 1;
        order2.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order2;
        orders.add(order2);

        insert orders;

        Invoice__c invoice = new Invoice__c();
        invoice.Name = 'INV-001';
        invoice.Customer__c = order1.Customer__c;
        invoice.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert invoice;

        Billing__c billing = new Billing__c();
        billing.Order__c = order1.Id;
        billing.Invoice__c = invoice.Id;
        billing.Invoice_Quantity__c = 0;
        billing.Billing_Num__c = '0';
        billing.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert billing;
        
        Test.startTest();
        List<Order_Item__c> orderItems = new List<Order_Item__c>();

        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order1.Id;
        orderItem.Invoice_Item__c = billing.Id;
        orderItem.Commodity__c = comboProductName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Quantity__c = 0;
        orderItem.Price__c = 100;
        orderItem.Sales_Unit__c = pu.Id;
        orderItem.SAP_Item_Num__c = '001';
        orderItem.Product_Type__c = 'Free Product';
        orderItem.IsCreate__c = true;
        orderItem.Product_Cost__c = 10;
        orderItem.Product_Type__c = 'Normal Product';
        orderItem.Guide_Price__c = 100;
        orderItem.Delivery_Date__c = Date.today();
        orderItem.SAP_Total_Net__c =  100;
        orderItem.Amount_per_item__c =  10;
        // insert orderItem;
        orderItems.add(orderItem);

        Order_Item__c orderItem2 = new Order_Item__c();
        orderItem2.Order__c = order1.Id;
        orderItem2.Invoice_Item__c = billing.Id;
        orderItem2.Commodity__c = comboProductName.Id;
        orderItem2.Price_Book_Item__c = priceBookItem.Id;
        orderItem2.Quantity__c = 10;
        orderItem2.Price__c = 100;
        orderItem2.Sales_Unit__c = pu.Id;
        orderItem2.SAP_Item_Num__c = '001';
        orderItem2.Product_Type__c = 'Free Product';
        orderItem2.IsCreate__c = true;
        orderItem2.Product_Cost__c = 10;
        orderItem2.Product_Type__c = 'Normal Product';
        orderItem2.Guide_Price__c = 100;
        // insert orderItem2;
        orderItems.add(orderItem2);

        Order_Item__c orderItem3 = new Order_Item__c();
        orderItem3.Order__c = order2.Id;
        orderItem3.Invoice_Item__c = billing.Id;
        orderItem3.Commodity__c = comboProductName.Id;
        orderItem3.Price_Book_Item__c = priceBookItem.Id;
        orderItem3.Quantity__c = 12;
        orderItem3.Price__c = 100;
        orderItem3.Sales_Unit__c = pu.Id;
        orderItem3.SAP_Item_Num__c = '001';
        orderItem3.Product_Type__c = 'Free Product';
        orderItem3.IsCreate__c = true;
        orderItem3.Product_Cost__c = 10;
        orderItem3.Product_Type__c = 'Normal Product';
        orderItem3.Guide_Price__c = 100;
        // insert orderItem3;
        orderItems.add(orderItem3);

        insert orderItems;

        
        // orderItem.Quantity__c =  10;
        // orderItem.isClosed__c =  true;
        orderItem.Depend_On_Item__c = orderItem3.Id;
        orderItem2.Depend_On_Item__c = orderItem3.Id;
        try {
            update new List<Order_Item__c>{orderItem, orderItem2};

            Delivery_Note__c dn = new Delivery_Note__c();
            dn.Order__c = order2.Id;
            dn.Order_Item__c = orderItem3.Id;
            dn.Delivery_Quantity__c = 11;
            dn.Delivery_Post_Date__c = Date.today();
            dn.Auto_issue_Consignment__c = false;
            dn.Issue_Quantity__c = 7;
            dn.Auto_ZARA_Issue_Quantity__c = 2;
            dn.Delivery_Post_Status__c = 'C';
            insert dn;
            
            OrderItemTriggerHandler.splitZAREToZARB(new Set<Id>{orderItem.Id, orderItem2.Id, orderItem3.Id},'5070',false,true);

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testMethod6() { 
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '5070';
        psi.Delivering_Plant__c = '5070';
        Insert psi;

        List<Product_Name__c> pns = new List<Product_Name__c>();
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'Test';
        pn.Product_Combo__c = false;
        pn.Product_Sales_Info__c = psi.Id; 
        // Insert pn;
        pns.add(pn);

        Product_Name__c comboProductName = new Product_Name__c();
        comboProductName.Name = 'ComboProductName';
        comboProductName.Product_Sales_Info__c = psi.Id;
        comboProductName.Product__c = p.Id;
        comboProductName.Product_Combo__c = true;
        comboProductName.Is_Delete__c = false;
        // insert comboProductName;
        pns.add(comboProductName);
        insert pns;

        Product_Name_Item__c comboItem = new Product_Name_Item__c();
        comboItem.Product_Combo_Name__c = comboProductName.Id;
        comboItem.Product_Name__c = pn.Id;
        comboItem.List_Price__c = 50;
        comboItem.Quantity__c = 2;
        insert comboItem;

        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;

        Product_Inventory__c pi = new Product_Inventory__c();
        pi.Search_Key__c = '12341234'+'-'+'5070'+'-'+'Test';
        pi.Inventory_Quantity__c = 1;
        pi.Product__c = p.Id;
        Insert pi;

        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.customer_TYpe__c = 'Distributor';
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
        csi.Sales_Org__c = '5070';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5070';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Price_Group__c = '02';
        csi.Payment_method__c = 'YPF';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        csi.Acct_Assmt_Grp_Cust__c = '02';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Sales_Org__c = '5070';
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;

        Price_Book_Item__c priceBookItem = new Price_Book_Item__c();
        priceBookItem.Price_Book__c = pb.Id;
        priceBookItem.Product_Name__c = comboProductName.Id;
        priceBookItem.Price__c = 100;
        priceBookItem.Min_Sales_Price__c = 80;
        priceBookItem.Is_Changing__c = false;
        priceBookItem.Status__c = 'Active';
        priceBookItem.Estimation_Cost_Local__c = 50;
        priceBookItem.Estimation_Cost_USD__c = 10;
        insert priceBookItem;
    
        List<Order__c> orders = new List<Order__c>();
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '123';
        order1.SAP_Order_Code2__c = '123';
        order1.Cust_Reference__c = '111';
        //order1.Inco_Location1__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5070';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5070';
        order1.Order_type__c = 'ZARE';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        // order1.Commission_Calculation_Method__c = 'Percent';
        // order1.Commission_Percentage__c = 1;
        // order1.Commission_To__c = a.Id;
        // order1.Commission_Type__c = 'Distributors';
        order1.Status__c = 'Approved';
        order1.Interest_Rate__c = 1;
        order1.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order1;
        orders.add(order1);

        Order__c order2 = new Order__c();
        order2.SAP_Order_Code__c = '1234';
        order2.SAP_Order_Code2__c = '1234';
        order2.Cust_Reference__c = '1114';
        //order2.Inco_Location1__c = '11';
        order2.Customer__c = a.Id;
        order2.Sales_Org__c = '5070';
        order2.Distr_Channel__c = '00';
        order2.Customer_Sales_Info__c = csi.Id;
        order2.Currency__c = 'USD';
        order2.Price_Book__c = pb.Id;
        order2.Deliver_Plant__c = '5070';
        order2.Order_type__c = 'ZARF';
        order2.Order_Reason__c = '001';
        order2.Customer_Shipping_Address__c = csa.Id;
        order2.Req_Deliv_Date__c = Date.today();
        order2.Interest_Rate__c = 1;
        // order2.Commission_Calculation_Method__c = 'Percent';
        // order2.Commission_Percentage__c = 1;
        // order2.Commission_To__c = a.Id;
        // order2.Commission_Type__c = 'Distributors';
        order2.Status__c = 'Approved';
        order2.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order2;
        orders.add(order2);

        insert orders;

        Invoice__c invoice = new Invoice__c();
        invoice.Name = 'INV-001';
        invoice.Customer__c = order1.Customer__c;
        invoice.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert invoice;

        Billing__c billing = new Billing__c();
        billing.Order__c = order1.Id;
        billing.Invoice__c = invoice.Id;
        billing.Invoice_Quantity__c = 0;
        billing.Billing_Num__c = '0';
        billing.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert billing;
        
        Test.startTest();
        List<Order_Item__c> orderItems = new List<Order_Item__c>();

        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order1.Id;
        orderItem.Invoice_Item__c = billing.Id;
        orderItem.Commodity__c = comboProductName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Quantity__c = 0;
        orderItem.Price__c = 100;
        orderItem.Sales_Unit__c = pu.Id;
        orderItem.SAP_Item_Num__c = '001';
        orderItem.Product_Type__c = 'Free Product';
        orderItem.IsCreate__c = true;
        orderItem.Product_Cost__c = 10;
        orderItem.Product_Type__c = 'Normal Product';
        orderItem.Guide_Price__c = 100;
        orderItem.Delivery_Date__c = Date.today();
        orderItem.SAP_Total_Net__c =  100;
        orderItem.Amount_per_item__c =  10;
        // insert orderItem;
        orderItems.add(orderItem);

        Order_Item__c orderItem2 = new Order_Item__c();
        orderItem2.Order__c = order1.Id;
        orderItem2.Invoice_Item__c = billing.Id;
        orderItem2.Commodity__c = comboProductName.Id;
        orderItem2.Price_Book_Item__c = priceBookItem.Id;
        orderItem2.Quantity__c = 10;
        orderItem2.Price__c = 100;
        orderItem2.Sales_Unit__c = pu.Id;
        orderItem2.SAP_Item_Num__c = '001';
        orderItem2.Product_Type__c = 'Free Product';
        orderItem2.IsCreate__c = true;
        orderItem2.Product_Cost__c = 10;
        orderItem2.Product_Type__c = 'Normal Product';
        orderItem2.Guide_Price__c = 100;
        // insert orderItem2;
        orderItems.add(orderItem2);

        Order_Item__c orderItem3 = new Order_Item__c();
        orderItem3.Order__c = order2.Id;
        orderItem3.Invoice_Item__c = billing.Id;
        orderItem3.Commodity__c = comboProductName.Id;
        orderItem3.Price_Book_Item__c = priceBookItem.Id;
        orderItem3.Quantity__c = 12;
        orderItem3.Price__c = 100;
        orderItem3.Sales_Unit__c = pu.Id;
        orderItem3.SAP_Item_Num__c = '001';
        orderItem3.Product_Type__c = 'Free Product';
        orderItem3.IsCreate__c = true;
        orderItem3.Product_Cost__c = 10;
        orderItem3.Product_Type__c = 'Normal Product';
        orderItem3.Guide_Price__c = 100;
        // insert orderItem3;
        orderItems.add(orderItem3);

        insert orderItems;

        
        try {
            
            Map<Id,Order_Item__c> oiNewMap = new Map<Id,Order_Item__c>();
            oiNewMap.put(orderItem.Id,orderItem);
            oiNewMap.put(orderItem2.Id,orderItem2);

            Set<Id> idSet = new Set<Id>();

            Map<Id,Order__c> orderNewMap = new Map<Id,Order__c>();
            orderNewMap.put(order1.Id,order1);
            orderNewMap.put(order2.Id,order2);

            Set<Id> idOrderSet = new Set<Id>{order1.Id,order2.Id};
            OrderItemTriggerHandler.validateRemainQty(oiNewMap, idSet, orderNewMap, idOrderSet);

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    // 测试数据设置方法
    // private static void setupTestData() {
        // 创建产品
        // Product__c product = new Product__c();
        // product.Name = 'TestProduct123';
        // product.External_Id__c = 'TestProduct123';
        // // product.Description_User__c = 'Test Product Description';
        // product.Basic_Metering_Unit__c = 'L';
        // insert product;
        
        // // 创建产品单位
        // Product_Unit__c productUnit = new Product_Unit__c();
        // productUnit.Basic_Unit__c = 'L';
        // productUnit.Product_Sales_Unit__c = 'L';
        // productUnit.Conversion_Coefficient__c = 1;
        // productUnit.Product__c = product.Id;
        // insert productUnit;
        
        // // 创建产品销售信息
        // Product_Sales_Info__c productSalesInfo = new Product_Sales_Info__c();
        // productSalesInfo.Product__c = product.Id;
        // productSalesInfo.Status__c = 'On Shelves';
        // productSalesInfo.Sales_Organization__c = '5070';
        // productSalesInfo.Delivering_Plant__c = '5070';
        // productSalesInfo.Factory__c = '5070';
        // productSalesInfo.Product_Unit__c = productUnit.Id;
        // productSalesInfo.Cost_Local__c = 50;
        // productSalesInfo.Cost_USD__c = 10;
        // productSalesInfo.Default_Sales_Unit__c = 'L';
        // productSalesInfo.Distr_Channel__c = '00';
        // insert productSalesInfo;
        
        // // 创建产品名称
        // Product_Name__c productName = new Product_Name__c();
        // productName.Name = 'TestProductName';
        // productName.Product_Sales_Info__c = productSalesInfo.Id;
        // productName.Product__c = product.Id;
        // productName.Product_Combo__c = false;
        // productName.Is_Delete__c = false;
        // insert productName;

        // // 创建账户
        // Account account = new Account();
        // account.Name = 'TestAccount';
        // account.Group_Name__c = 'TestGroup';
        // account.Customer_Approval_Status__c = 'Approved';
        // account.Sync_Status__c = 'Synchronized';
        // account.MDG__c = false;
        // insert account;
        
        // // 创建客户信用信息
        // Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        // customerCreditInfo.Customer__c = account.Id;
        // customerCreditInfo.ExternalId__c = account.Id;
        // insert customerCreditInfo;
        
        // // 创建客户销售信息
        // Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        // customerSalesInfo.Sales_Org__c = '5070';
        // customerSalesInfo.Distr_Channel__c = '00';
        // customerSalesInfo.Sales_View_Status__c = 'Approved';
        // customerSalesInfo.Sync_Status__c = 'Synchronized';
        // customerSalesInfo.Customer__c = account.Id;
        // customerSalesInfo.Payment_method__c = 'YPF';
        // insert customerSalesInfo;
        
        // // 创建价格手册
        // Price_Book__c priceBook = new Price_Book__c();
        // priceBook.Name = 'TestPriceBook';
        // priceBook.Sales_Org__c = '5070';
        // priceBook.Currency__c = 'USD';
        // priceBook.Status__c = 'Approved';
        // insert priceBook;
        
        // // 创建价格手册项目
        // Price_Book_Item__c priceBookItem = new Price_Book_Item__c();
        // priceBookItem.Price_Book__c = priceBook.Id;
        // priceBookItem.Product_Name__c = productName.Id;
        // priceBookItem.Price__c = 100;
        // priceBookItem.Min_Sales_Price__c = 80;
        // priceBookItem.Is_Changing__c = false;
        // priceBookItem.Status__c = 'Active';
        // priceBookItem.Estimation_Cost_Local__c = 50;
        // priceBookItem.Estimation_Cost_USD__c = 10;
        // insert priceBookItem;
        
        // // 创建订单
        // Order__c order = new Order__c();
        // order.Customer__c = account.Id;
        // order.Sales_Org__c = '5070';
        // order.Distr_Channel__c = '00';
        // order.Customer_Sales_Info__c = customerSalesInfo.Id;
        // order.Currency__c = 'USD';
        // order.Price_Book__c = priceBook.Id;
        // order.Deliver_Plant__c = '5070';
        // order.Order_type__c = 'ZARE';
        // order.Status__c = 'Draft';
        // order.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order;

        // Order__c order2 = new Order__c();
        // order2.Customer__c = account.Id;
        // order2.Sales_Org__c = '5070';
        // order2.Distr_Channel__c = '00';
        // order2.Customer_Sales_Info__c = customerSalesInfo.Id;
        // order2.Currency__c = 'USD';
        // order2.Price_Book__c = priceBook.Id;
        // order2.Deliver_Plant__c = '5070';
        // order2.Order_type__c = 'ZARF';
        // order2.Status__c = 'Draft';
        // order2.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order2;

        // Order__c order3 = new Order__c();
        // order3.Customer__c = account.Id;
        // order3.Sales_Org__c = '5130';
        // order3.Distr_Channel__c = '10';
        // order3.Customer_Sales_Info__c = customerSalesInfo.Id;
        // order3.Currency__c = 'USD';
        // order3.Price_Book__c = priceBook.Id;
        // order3.Deliver_Plant__c = '5130';
        // order3.Order_type__c = 'ZARE';
        // order3.Status__c = 'Draft';
        // order3.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order3;

        //  Order__c order4 = new Order__c();
        // order4.Customer__c = account.Id;
        // order4.Sales_Org__c = '5130';
        // order4.Distr_Channel__c = '10';
        // order4.Customer_Sales_Info__c = customerSalesInfo.Id;
        // order4.Currency__c = 'USD';
        // order4.Price_Book__c = priceBook.Id;
        // order4.Deliver_Plant__c = '5130';
        // order4.Order_type__c = 'ZARF';
        // order4.Status__c = 'Draft';
        // order4.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order4;

        // Order__c order5 = new Order__c();
        // order5.Customer__c = account.Id;
        // order5.Sales_Org__c = '5070';
        // order5.Distr_Channel__c = '00';
        // order5.Customer_Sales_Info__c = customerSalesInfo.Id;
        // order5.Currency__c = 'USD';
        // order5.Price_Book__c = priceBook.Id;
        // order5.Deliver_Plant__c = '5070';
        // order5.Order_type__c = 'ZARA';
        // order5.Status__c = 'Approving';
        // order5.Auto_issue_Consignment__c = true;
        // order5.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order5;

        // Order__c order6 = new Order__c();
        // order6.Customer__c = account.Id;
        // order6.Sales_Org__c = '5070';
        // order6.Distr_Channel__c = '00';
        // order6.Customer_Sales_Info__c = customerSalesInfo.Id;
        // order6.Currency__c = 'USD';
        // order6.Price_Book__c = priceBook.Id;
        // order6.Deliver_Plant__c = '5070';
        // order6.Order_type__c = 'ZARA';
        // order6.Status__c = 'Approving';
        // order6.Auto_issue_Consignment__c = false;
        // order6.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order6;

        // Order__c order7 = new Order__c();
        // order7.Customer__c = account.Id;
        // order7.Sales_Org__c = '5130';
        // order7.Distr_Channel__c = '10';
        // order7.Customer_Sales_Info__c = customerSalesInfo.Id;
        // order7.Currency__c = 'USD';
        // order7.Price_Book__c = priceBook.Id;
        // order7.Deliver_Plant__c = '5130';
        // order7.Order_type__c = 'ZARA';
        // order7.Status__c = 'Approving';
        // order7.Auto_issue_Consignment__c = false;
        // order7.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order7;

        // Order__c order8 = new Order__c();
        // order8.Customer__c = account.Id;
        // order8.Sales_Org__c = '5130';
        // order8.Distr_Channel__c = '10';
        // order8.Customer_Sales_Info__c = customerSalesInfo.Id;
        // order8.Currency__c = 'USD';
        // order8.Price_Book__c = priceBook.Id;
        // order8.Deliver_Plant__c = '5130';
        // order8.Order_type__c = 'ZARA';
        // order8.Status__c = 'Approving';
        // order8.Auto_issue_Consignment__c = false;
        // order8.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order8;
        
        // // 创建订单项目
        // Order_Item__c orderItem = new Order_Item__c();
        // orderItem.Order__c = order.Id;
        // orderItem.Commodity__c = productName.Id;
        // orderItem.Price_Book_Item__c = priceBookItem.Id;
        // orderItem.Quantity__c = 5;
        // orderItem.Price__c = 100;
        // orderItem.Sales_Unit__c = productUnit.Id;
        // orderItem.SAP_Item_Num__c = '001';
        // orderItem.Product_Type__c = 'Free Product';
        // orderItem.IsCreate__c = true;
        // insert orderItem;

        // Order_Item__c orderItem2 = new Order_Item__c();
        // orderItem2.Order__c = order2.Id;
        // orderItem2.Commodity__c = productName.Id;
        // orderItem2.Price_Book_Item__c = priceBookItem.Id;
        // orderItem2.Quantity__c = 5;
        // orderItem2.Price__c = 100;
        // orderItem2.Sales_Unit__c = productUnit.Id;
        // orderItem2.SAP_Item_Num__c = '001';
        // orderItem2.Product_Type__c = 'Free Product';
        // orderItem2.IsCreate__c = true;
        // insert orderItem2;

        // Order_Item__c orderItem3 = new Order_Item__c();
        // orderItem3.Order__c = order3.Id;
        // orderItem3.Commodity__c = productName.Id;
        // orderItem3.Price_Book_Item__c = priceBookItem.Id;
        // orderItem3.Quantity__c = 5;
        // orderItem3.Price__c = 100;
        // orderItem3.Sales_Unit__c = productUnit.Id;
        // orderItem3.SAP_Item_Num__c = '001';
        // orderItem3.Product_Type__c = 'Free Product';
        // orderItem3.IsCreate__c = true;
        // insert orderItem3;

        // Order_Item__c orderItem4 = new Order_Item__c();
        // orderItem4.Order__c = order4.Id;
        // orderItem4.Commodity__c = productName.Id;
        // orderItem4.Price_Book_Item__c = priceBookItem.Id;
        // orderItem4.Quantity__c = 5;
        // orderItem4.Price__c = 100;
        // orderItem4.Sales_Unit__c = productUnit.Id;
        // orderItem4.SAP_Item_Num__c = '001';
        // orderItem4.Product_Type__c = 'Free Product';
        // orderItem4.IsCreate__c = true;
        // insert orderItem4;

        // Order_Item__c orderItem5 = new Order_Item__c();
        // orderItem5.Order__c = order5.Id;
        // orderItem5.Commodity__c = productName.Id;
        // orderItem5.Price_Book_Item__c = priceBookItem.Id;
        // orderItem5.Quantity__c = 5;
        // orderItem5.Price__c = 100;
        // orderItem5.Sales_Unit__c = productUnit.Id;
        // orderItem5.SAP_Item_Num__c = '001';
        // orderItem5.Product_Type__c = 'Free Product';
        // orderItem5.IsCreate__c = true;
        // insert orderItem5;

        // Order_Item__c orderItem6 = new Order_Item__c();
        // orderItem6.Order__c = order6.Id;
        // orderItem6.Commodity__c = productName.Id;
        // orderItem6.Price_Book_Item__c = priceBookItem.Id;
        // orderItem6.Quantity__c = 5;
        // orderItem6.Price__c = 100;
        // orderItem6.Sales_Unit__c = productUnit.Id;
        // orderItem6.SAP_Item_Num__c = '001';
        // orderItem6.Product_Type__c = 'Free Product';
        // orderItem6.IsCreate__c = true;
        // insert orderItem6;

        // Order_Item__c orderItem7 = new Order_Item__c();
        // orderItem7.Order__c = order7.Id;
        // orderItem7.Commodity__c = productName.Id;
        // orderItem7.Price_Book_Item__c = priceBookItem.Id;
        // orderItem7.Quantity__c = 5;
        // orderItem7.Price__c = 100;
        // orderItem7.Sales_Unit__c = productUnit.Id;
        // orderItem7.SAP_Item_Num__c = '001';
        // orderItem7.Product_Type__c = 'Free Product';
        // orderItem7.IsCreate__c = true;
        // insert orderItem7;

        // Order_Item__c orderItem8 = new Order_Item__c();
        // orderItem8.Order__c = order8.Id;
        // orderItem8.Commodity__c = productName.Id;
        // orderItem8.Price_Book_Item__c = priceBookItem.Id;
        // orderItem8.Quantity__c = 5;
        // orderItem8.Price__c = 100;
        // orderItem8.Sales_Unit__c = productUnit.Id;
        // orderItem8.SAP_Item_Num__c = '001';
        // orderItem8.Product_Type__c = 'Free Product';
        // orderItem8.IsCreate__c = true;
        // insert orderItem8;
    // }

    static testMethod void test1() {

        Product__c product = new Product__c();
        product.Name = 'TestProduct123';
        product.External_Id__c = 'TestProduct123';
        // product.Description_User__c = 'Test Product Description';
        product.Basic_Metering_Unit__c = 'L';
        insert product;
        
        // 创建产品单位
        Product_Unit__c productUnit = new Product_Unit__c();
        productUnit.Basic_Unit__c = 'L';
        productUnit.Product_Sales_Unit__c = 'L';
        productUnit.Conversion_Coefficient__c = 1;
        productUnit.Product__c = product.Id;
        insert productUnit;
        
        // 创建产品销售信息
        Product_Sales_Info__c productSalesInfo = new Product_Sales_Info__c();
        productSalesInfo.Product__c = product.Id;
        productSalesInfo.Status__c = 'On Shelves';
        productSalesInfo.Sales_Organization__c = '5070';
        productSalesInfo.Delivering_Plant__c = '5070';
        productSalesInfo.Factory__c = '5070';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        productSalesInfo.Distr_Channel__c = '00';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        insert productName;

        // 创建账户
        Account account = new Account();
        account.Name = 'TestAccount';
        account.Group_Name__c = 'TestGroup';
        account.Customer_Approval_Status__c = 'Approved';
        account.Sync_Status__c = 'Synchronized';
        account.MDG__c = false;
        insert account;
        
        // 创建客户信用信息
        Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        customerCreditInfo.Customer__c = account.Id;
        customerCreditInfo.ExternalId__c = account.Id;
        insert customerCreditInfo;
        
        // 创建客户销售信息
        Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        customerSalesInfo.Sales_Org__c = '5070';
        customerSalesInfo.Distr_Channel__c = '00';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '5070';
        priceBook.Currency__c = 'USD';
        priceBook.Status__c = 'Approved';
        insert priceBook;
        
        // 创建价格手册项目
        Price_Book_Item__c priceBookItem = new Price_Book_Item__c();
        priceBookItem.Price_Book__c = priceBook.Id;
        priceBookItem.Product_Name__c = productName.Id;
        priceBookItem.Price__c = 100;
        priceBookItem.Min_Sales_Price__c = 80;
        priceBookItem.Is_Changing__c = false;
        priceBookItem.Status__c = 'Active';
        priceBookItem.Estimation_Cost_Local__c = 50;
        priceBookItem.Estimation_Cost_USD__c = 10;
        insert priceBookItem;
        
        // 创建订单
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '5070';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '5070';
        order.Order_type__c = 'ZARE';
        order.Status__c = 'Draft';
        order.Interest_Rate__c = 1;
        order.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order;

        Order__c order2 = new Order__c();
        order2.Customer__c = account.Id;
        order2.Sales_Org__c = '5070';
        order2.Distr_Channel__c = '00';
        order2.Customer_Sales_Info__c = customerSalesInfo.Id;
        order2.Currency__c = 'USD';
        order2.Price_Book__c = priceBook.Id;
        order2.Deliver_Plant__c = '5070';
        order2.Order_type__c = 'ZARF';
        order2.Status__c = 'Draft';
        order2.Order_Reason__c = '001';
        order2.Interest_Rate__c = 1;
        order2.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order2;

        Order__c order3 = new Order__c();
        order3.Customer__c = account.Id;
        order3.Sales_Org__c = '5130';
        order3.Distr_Channel__c = '00';
        order3.Customer_Sales_Info__c = customerSalesInfo.Id;
        order3.Currency__c = 'USD';
        order3.Price_Book__c = priceBook.Id;
        order3.Deliver_Plant__c = '5130';
        order3.Order_type__c = 'ZARE';
        order3.Status__c = 'Draft';
        order3.Interest_Rate__c = 1;
        order3.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order3;

         Order__c order4 = new Order__c();
        order4.Customer__c = account.Id;
        order4.Sales_Org__c = '5130';
        order4.Distr_Channel__c = '00';
        order4.Customer_Sales_Info__c = customerSalesInfo.Id;
        order4.Currency__c = 'USD';
        order4.Price_Book__c = priceBook.Id;
        order4.Deliver_Plant__c = '5130';
        order4.Order_type__c = 'ZARF';
        order4.Order_Reason__c = '001';
        order4.Status__c = 'Draft';
        order4.Interest_Rate__c = 1;
        order4.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order4;

        Order__c order5 = new Order__c();
        order5.Customer__c = account.Id;
        order5.Sales_Org__c = '5070';
        order5.Distr_Channel__c = '00';
        order5.Customer_Sales_Info__c = customerSalesInfo.Id;
        order5.Currency__c = 'USD';
        order5.Price_Book__c = priceBook.Id;
        order5.Deliver_Plant__c = '5070';
        order5.Order_type__c = 'ZARA';
        order5.Status__c = 'Approving';
        order5.Order_Reason__c = '01';
        order5.Auto_issue_Consignment__c = true;
        order5.Interest_Rate__c = 1;
        order5.RecordTypeId = Utility.modelCRecordTypeId;
        // insert order5;

        Order__c order6 = new Order__c();
        order6.Customer__c = account.Id;
        order6.Sales_Org__c = '5070';
        order6.Distr_Channel__c = '00';
        order6.Customer_Sales_Info__c = customerSalesInfo.Id;
        order6.Currency__c = 'USD';
        order6.Price_Book__c = priceBook.Id;
        order6.Deliver_Plant__c = '5070';
        order6.Order_type__c = 'ZARA';
        order6.Status__c = 'Approving';
        order6.Auto_issue_Consignment__c = false;
        order6.RecordTypeId = Utility.modelCRecordTypeId;
        order6.Order_Reason__c = '01';
        order6.Interest_Rate__c = 1;
        // insert order6;

        Order__c order7 = new Order__c();
        order7.Customer__c = account.Id;
        order7.Sales_Org__c = '5130';
        order7.Distr_Channel__c = '00';
        order7.Customer_Sales_Info__c = customerSalesInfo.Id;
        order7.Currency__c = 'USD';
        order7.Price_Book__c = priceBook.Id;
        order7.Deliver_Plant__c = '5130';
        order7.Order_type__c = 'ZARA';
        order7.Status__c = 'Approving';
        order7.Order_Reason__c = '01';
        order7.Auto_issue_Consignment__c = false;
        order7.RecordTypeId = Utility.modelCRecordTypeId;
        order7.Interest_Rate__c = 1;
        // insert order7;

        Order__c order8 = new Order__c();
        order8.Customer__c = account.Id;
        order8.Sales_Org__c = '5130';
        order8.Distr_Channel__c = '00';
        order8.Customer_Sales_Info__c = customerSalesInfo.Id;
        order8.Currency__c = 'USD';
        order8.Price_Book__c = priceBook.Id;
        order8.Deliver_Plant__c = '5130';
        order8.Order_type__c = 'ZARA';
        order8.Status__c = 'Approving';
        order8.Order_Reason__c = '01';
        order8.Auto_issue_Consignment__c = false;
        order8.RecordTypeId = Utility.modelCRecordTypeId;
        order8.Interest_Rate__c = 1;
        // insert order8;
        List<Order__c> ordList = new List<Order__c>{order,order2,order3,order4,order5,order6,order7,order8};
        Database.insert(ordList,false);

        
        // 创建订单项目
        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order.Id;
        orderItem.Commodity__c = productName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Quantity__c = 5;
        orderItem.Price__c = 100;
        orderItem.Sales_Unit__c = productUnit.Id;
        orderItem.SAP_Item_Num__c = '001';
        orderItem.Product_Type__c = 'Free Product';
        orderItem.IsCreate__c = true;
        // insert orderItem;

        Order_Item__c orderItem2 = new Order_Item__c();
        orderItem2.Order__c = order2.Id;
        orderItem2.Commodity__c = productName.Id;
        orderItem2.Price_Book_Item__c = priceBookItem.Id;
        orderItem2.Quantity__c = 5;
        orderItem2.Price__c = 100;
        orderItem2.Sales_Unit__c = productUnit.Id;
        orderItem2.SAP_Item_Num__c = '001';
        orderItem2.Product_Type__c = 'Free Product';
        orderItem2.IsCreate__c = true;
        // insert orderItem2;

        Order_Item__c orderItem3 = new Order_Item__c();
        orderItem3.Order__c = order3.Id;
        orderItem3.Commodity__c = productName.Id;
        orderItem3.Price_Book_Item__c = priceBookItem.Id;
        orderItem3.Quantity__c = 5;
        orderItem3.Price__c = 100;
        orderItem3.Sales_Unit__c = productUnit.Id;
        orderItem3.SAP_Item_Num__c = '001';
        orderItem3.Product_Type__c = 'Free Product';
        orderItem3.IsCreate__c = true;
        // insert orderItem3;

        Order_Item__c orderItem4 = new Order_Item__c();
        orderItem4.Order__c = order4.Id;
        orderItem4.Commodity__c = productName.Id;
        orderItem4.Price_Book_Item__c = priceBookItem.Id;
        orderItem4.Quantity__c = 5;
        orderItem4.Price__c = 100;
        orderItem4.Sales_Unit__c = productUnit.Id;
        orderItem4.SAP_Item_Num__c = '001';
        orderItem4.Product_Type__c = 'Free Product';
        orderItem4.IsCreate__c = true;
        // insert orderItem4;
        Test.startTest();
        Order_Item__c orderItem5 = new Order_Item__c();
        orderItem5.Order__c = order5.Id;
        orderItem5.Commodity__c = productName.Id;
        orderItem5.Price_Book_Item__c = priceBookItem.Id;
        orderItem5.Quantity__c = 5;
        orderItem5.Price__c = 100;
        orderItem5.Sales_Unit__c = productUnit.Id;
        orderItem5.SAP_Item_Num__c = '001';
        orderItem5.Product_Type__c = 'Free Product';
        orderItem5.IsCreate__c = true;
        // insert orderItem5;

        Order_Item__c orderItem6 = new Order_Item__c();
        orderItem6.Order__c = order6.Id;
        orderItem6.Commodity__c = productName.Id;
        orderItem6.Price_Book_Item__c = priceBookItem.Id;
        orderItem6.Quantity__c = 5;
        orderItem6.Price__c = 100;
        orderItem6.Sales_Unit__c = productUnit.Id;
        orderItem6.SAP_Item_Num__c = '001';
        orderItem6.Product_Type__c = 'Free Product';
        orderItem6.IsCreate__c = true;
        // insert orderItem6;

        Order_Item__c orderItem7 = new Order_Item__c();
        orderItem7.Order__c = order7.Id;
        orderItem7.Commodity__c = productName.Id;
        orderItem7.Price_Book_Item__c = priceBookItem.Id;
        orderItem7.Quantity__c = 5;
        orderItem7.Price__c = 100;
        orderItem7.Sales_Unit__c = productUnit.Id;
        orderItem7.SAP_Item_Num__c = '001';
        orderItem7.Product_Type__c = 'Free Product';
        orderItem7.IsCreate__c = true;
        // insert orderItem7;

        Order_Item__c orderItem8 = new Order_Item__c();
        orderItem8.Order__c = order8.Id;
        orderItem8.Commodity__c = productName.Id;
        orderItem8.Price_Book_Item__c = priceBookItem.Id;
        orderItem8.Quantity__c = 5;
        orderItem8.Price__c = 100;
        orderItem8.Sales_Unit__c = productUnit.Id;
        orderItem8.SAP_Item_Num__c = '001';
        orderItem8.Product_Type__c = 'Free Product';
        orderItem8.IsCreate__c = true;
        // insert orderItem8;

        List<Order_Item__c> ordItemList = new List<Order_Item__c>{orderItem,orderItem2,orderItem3,orderItem4,orderItem5,orderItem6,orderItem7,orderItem8};
        Database.insert(ordItemList,false);


        Set<Id> recordIdList = new Set<Id>();
        recordIdList.add(orderItem.Id);
        recordIdList.add(orderItem2.Id);
        recordIdList.add(orderItem3.Id);
        recordIdList.add(orderItem4.Id);
        recordIdList.add(orderItem5.Id);
        recordIdList.add(orderItem6.Id);
        recordIdList.add(orderItem7.Id);
        recordIdList.add(orderItem8.Id);
        recordIdList.add(order.Id);
        recordIdList.add(order2.Id);
        recordIdList.add(order3.Id);
        recordIdList.add(order4.Id);
        recordIdList.add(order5.Id);
        recordIdList.add(order6.Id);
        recordIdList.add(order7.Id);
        recordIdList.add(order8.Id);
        // List<Order_Item__c> recordIdList1 = [SELECT Id FROM Order_Item__c];
        // List<Order__c> recordIdList2 = [SELECT Id FROM Order__c];
        // System.debug('Order_Item__c====recordIdList1===='+recordIdList1.size());
        // System.debug('Order__c====recordIdList2===='+recordIdList2.size());
        // for(Order_Item__c item1 : recordIdList1){
        //         recordIdList.add(item1.Id);
        // }
        // for(Order__c item2 : recordIdList2){
        //         recordIdList.add(item2.Id);
        // }
        System.debug('综合====recordIdList===='+recordIdList.size());
        OrderItemTriggerHandler.splitToZARB(recordIdList,true);
        OrderItemTriggerHandler.splitZAREToZARB(recordIdList,'5130',false,false);
        OrderItemTriggerHandler.splitZAREToZARB(recordIdList,'5130',true,true);
        OrderItemTriggerHandler.splitZAREToZARB(recordIdList,'5070',false,false);
        OrderItemTriggerHandler.splitZAREToZARB(recordIdList,'5070',true,true);
        Test.stopTest();
    }
}