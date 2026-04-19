/**
 * @description       : SubmitOrderController测试类
 * @author            : Assistant
 * @group             : 
 * @last modified on  : 12-12-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   01-20-2025   Assistant   Initial Version
**/
@IsTest
private class SubmitOrderControllerTest {

    @IsTest
    static void testSubmitOrder1() { 
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'synchronized';
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
        csi.Sales_Org__c = '5070';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c = 'Synchronized';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Payment_method__c = 'YPF';
        insert csi;

        Order__c order1 = new Order__c();
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5070';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Deliver_Plant__c = '5070';
        order1.Order_type__c = 'ZAR2';
        order1.Order_Reason__c = '001';
        order1.Status__c = 'Approved';
        order1.Sync_Status__c = 'Synchronized';
        order1.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order1.Cust_Reference__c = '12';
        order1.Stock_Aging_Limit__c= '60';
        order1.SAP_Order__c = true;
        insert order1;

        Test.startTest();
        SubmitOrderController.init(order1.Id);
        Test.stopTest();
    }

    @IsTest
    static void testSubmitOrder2() { 
        Account a = new Account();
        a.Name = 'Test';
        a.Customer_Type__c = 'Distributor';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'synchronized';
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
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c = 'Synchronized';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Payment_method__c = 'YPF';
        insert csi;

        List<Order__c> orders = new List<Order__c>();
        Order__c order = new Order__c();
        order.Commission_Type__c = 'Distributors';
        order.Commission_Calculation_Method__c = 'Amount';
        order.Commission_To__c = a.Id;
        order.Customer__c = a.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZARB';
        order.Status__c = 'Approved';
        order.Sync_Status__c = 'Synchronized';
        order.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order.Cust_Reference__c = '12';
        order.Stock_Aging_Limit__c= '60';
        order.SAP_Order__c = true;
        orders.add(order);

        insert orders;

        SubmitOrderController.init(order.Id);
        Test.startTest();

        order.Commission_To__c = null;
        update order;
        
        SubmitOrderController.Output output = SubmitOrderController.init(order.Id);

        Test.stopTest();
    }
    
    @IsTest
    static void testSubmitOrder3() { 
        Account a = new Account();
        a.Name = 'Test';
        a.Customer_Type__c = 'Distributor';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'synchronized';
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
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c = 'Synchronized';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Payment_method__c = 'YPF';
        insert csi;

        List<Order__c> orders = new List<Order__c>();
        Order__c order = new Order__c();
        order.Commission_Type__c = 'Distributors';
        order.Commission_Calculation_Method__c = 'Amount';
        order.Commission_To__c = a.Id;
        order.Customer__c = a.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZARB';
        order.Status__c = 'Approved';
        order.Sync_Status__c = 'Synchronized';
        order.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order.Cust_Reference__c = '12';
        order.Stock_Aging_Limit__c= '60';
        order.SAP_Order__c = true;
        // insert order;
        orders.add(order);

        insert orders;


        Product__c product = new Product__c();
        product.Name = 'TestProduct';
        product.External_Id__c = 'TestProduct';
        insert product;
        
        Product_Unit__c productUnit = new Product_Unit__c();
        productUnit.Basic_Unit__c = 'L';
        productUnit.Product_Sales_Unit__c = 'L';
        productUnit.Conversion_Coefficient__c = 1;
        productUnit.Product__c = product.Id;
        insert productUnit;

        Invoice__c invoice = new Invoice__c();
        invoice.Name = 'INV-001';
        invoice.Customer__c = order.Customer__c;
        invoice.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert invoice;

        Billing__c billing = new Billing__c();
        billing.Order__c = order.Id;
        billing.Invoice__c = invoice.Id;
        billing.Invoice_Quantity__c = 0;
        billing.Billing_Num__c = '0';
        billing.External_Id__c = 'Test'+ Datetime.now().getTime();
        insert billing;

        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order.Id;
        orderItem.Invoice_Item__c = billing.Id;
        // orderItem.Commodity__c = productName.Id;
        // orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Quantity__c = 5;
        orderItem.Price__c = 100;
        orderItem.Sales_Unit__c = productUnit.Id;
        orderItem.SAP_Item_Num__c = '001';
        orderItem.Product_Type__c = 'Free Product';
        orderItem.IsCreate__c = true;
        insert orderItem;

        Test.startTest();
        SubmitOrderController.Output output = SubmitOrderController.init(order.Id);
        SubmitOrderController.submitDataMe(order.Id, output);

        SubmitOrderController.invoice(order.Id);

        Test.stopTest();
    }
    
    @IsTest
    static void testSubmitOrder4() { 
        Account a = new Account();
        a.Name = 'Test';
        a.Customer_Type__c = 'Distributor';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'synchronized';
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
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c = 'Synchronized';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Payment_method__c = 'YPF';
        insert csi;

        List<Order__c> orders = new List<Order__c>();
        Order__c order = new Order__c();
        order.Commission_Type__c = 'Distributors';
        order.Commission_Calculation_Method__c = 'Amount';
        order.Commission_To__c = a.Id;
        order.Customer__c = a.Id;
        order.Sales_Org__c = '3010';
        order.Distr_Channel__c = '10';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';
        order.Deliver_Plant__c = '3010';
        order.Status__c = 'Approved';
        order.Sync_Status__c = 'Synchronized';
        order.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order.Cust_Reference__c = '12';
        order.Stock_Aging_Limit__c= '60';
        order.SAP_Order__c = true;
        order.Order_type__c = 'ZMX6';
        order.Business_Model__c = 'B0';
        order.Rate__c = 1;
        insert order;

        Order__c order1 = new Order__c();
        order1.Commission_Type__c = 'Distributors';
        order1.Commission_Calculation_Method__c = 'Amount';
        order1.Commission_To__c = a.Id;
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '3010';
        order1.Distr_Channel__c = '10';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Deliver_Plant__c = '3010';
        order1.Status__c = 'Approved';
        order1.Sync_Status__c = 'Synchronized';
        order1.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order1.Cust_Reference__c = '12';
        order1.Stock_Aging_Limit__c= '60';
        order1.SAP_Order__c = true;
        order1.Down_Payment__c = order.Id;
        order1.Order_type__c = 'ZMX1';
        order1.Business_Model__c = 'B0';
        order1.Rate__c = 1;
        insert order1;
        
        Test.startTest();
        SubmitOrderController.Output output = SubmitOrderController.init(order1.Id);

        Test.stopTest();
    }

    @IsTest
    static void testCheck(){
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
        a.Email__c = '333@emali.com';
        Insert a;
        System.debug('RecordTypeId: '+a.RecordTypeId);
        System.debug('Sync_Status__c: '+a.Sync_Status__c);

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
        csi.Sync_Status__c = 'Synchronized';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Payment_method__c = 'YPF';
        insert csi;

        Order__c order1 = new Order__c();
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARE';
        order1.Status__c = 'Approved';
        order1.Sync_Status__c = 'Synchronized';
        order1.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order1.Cust_Reference__c = '12';
        order1.Stock_Aging_Limit__c= '60';
        order1.SAP_Order__c = true;
        insert order1;
        Order__c order2 = new Order__c();
        order2.Customer__c = a.Id;
        order2.Sales_Org__c = '5130';
        order2.Distr_Channel__c = '00';
        order2.Customer_Sales_Info__c = csi.Id;
        order2.Currency__c = 'USD';
        order2.Deliver_Plant__c = '5130';
        order2.Order_type__c = 'ZARF';
        order2.Status__c = 'Approved';
        order2.Sync_Status__c = 'Synchronized';
        order2.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order2.Cust_Reference__c = '12';
        order2.Stock_Aging_Limit__c= '60';
        order2.SAP_Order__c = true;
        order2.Order_Reason__c = '001';
        insert order2;
        Test.startTest();
        
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Order__c = order1.Id;
        orI1.Guide_Price__c = -1;
        orI1.Price__c = 4;
        orI1.SAP_Total_Net__c = 1;
        orI1.Quantity__c = 1;
        orI1.IsCreate__c = true;
        orI1.Product_Cost__c = 10;
        orI1.New_Price__c = 13;
        orI1.New_Quantity__c = 13;
        orI1.New_Amount__c = 13;
        orI1.New_Delivery_Date__c = Date.today();
        orI1.Product_Type__c = 'Normal Product';
        insert orI1;


        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Distr_Channel__c = '00';
        insert psi;

        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;

        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'Test Combo';
        pn.Product_Sales_Info__c = psi.Id;
        pn.Product__c = p.Id;
        pn.Product_Combo__c = TRUE;
        insert pn;

        Product_Name__c pn2 = new Product_Name__c();
        pn2.Name = 'Test Combo2';
        pn2.Product_Sales_Info__c = psi.Id;
        pn2.Product__c = p.Id;
        pn2.Product_Combo__c = false;
        insert pn2;

        orI1.Commodity__c = pn.Id;
        update orI1;

        Product_Name_Item__c pci = new Product_Name_Item__c();
        pci.Product_Combo_Name__c = pn.Id;
        pci.Product_Name__c = pn2.Id; 
        insert pci;

        Delivery_Note__c dn = new Delivery_Note__c();
        dn.Order__c = order1.Id;
        dn.Order_Item__c = orI1.Id;
        dn.Auto_ZARA_Issue_Quantity__c = 10;
        dn.Delivery_Quantity__c = 5;
      //   dn.Remain_Quantity__c = 0;
        dn.Delivery_Post_Date__c = Date.valueOf('2025-3-16');
      //   dn.Stock_Aging_Countdown__c = -10;
        dn.Auto_issue_Consignment__c = false;
        dn.Issue_Quantity__c = 2;
        dn.Delivery_Post_Status__c = 'C';
        insert dn;
        Order_Item__c orI2 = new Order_Item__c();
        orI2.Order__c = order2.Id;
        orI2.Guide_Price__c = -1;
        orI2.Price__c = 4;
        orI2.SAP_Total_Net__c = 1;
        orI2.Quantity__c = 1;
        orI2.IsCreate__c = true;
        orI2.Product_Cost__c = 10;
        orI2.New_Price__c = 13;
        orI2.New_Quantity__c = 13;
        orI2.New_Amount__c = 13;
        orI2.New_Delivery_Date__c = Date.today();
        orI2.Product_Type__c = 'Normal Product';
        orI2.ZARE_Delivery_Note__c = dn.Id;
        insert orI2;
        
        SubmitOrderController.zareQuantityEnough(order2.Id);
        Test.stopTest();
    }
}