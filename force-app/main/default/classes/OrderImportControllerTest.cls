@isTest
public  class OrderImportControllerTest {

    static testMethod void testMethod1() {
       Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.AccountNumber = 'PO123456';
        Insert a; 

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

        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Sales_Org__c = '5070';
        pb.Currency__c = 'USD';
        insert pb;

        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;



   Map<String, Object> itemMap = new Map<String, Object>{
    'customerPO' => 'PO123456',
    'salesOrg' => '5070',
    'deliveryPlant' => 'PlantA',
    'distributionChannel' => 'DC01',
    'orderType' => 'ZARA',
    'customer' => a.Name,
    'customerId' => a.Id,
    'shipTo' => 'Sunon Branch',
    'shipToId' => a.Id,
    'pricingDate' => '45284',
    'currencys' => 'USD',
    'paymentTerm' => 'Net30',
    'productCode' => '12341234',
    'ypfproductName' => 'YPF Widget',
    'productName' => 'Widget A',
    'productNameId' => pn.Id,  
    'orderItemQty' => 10,
    'unitPrice' => 50,
    'deliveryDate' => '45284',
    'invLocation' => 'LOC01',
    'crop' => 'CropA',
    'salesUnit' => 'PCS',
    'productUnit' => pu.Id,
    'stockLimit' => 100,
    'salesUnitCoefficient' => 1.0,
    'unitPriceCheck' => true
};
    String data = JSON.serialize(new List<Map<String,Object>>{itemMap});
     OrderImportController.InitData(data);
     OrderImportController.saveOrderData(data);

    }
        static testMethod void testMethod2() {
       Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.AccountNumber = 'PO123456';
        Insert a; 

        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '3020';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        insert csi;

         Contact shipToContact = new Contact(
            LastName = 'ShipTo',
            AccountId = a.Id
        );
        insert shipToContact;

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

        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Sales_Org__c = '5070';
        pb.Currency__c = 'USD';
        insert pb;

        
        Price_Book_Item__c pbi = new Price_Book_Item__c();
        pbi.Price_Book__c = pb.Id;
        pbi.Product_Name__c = pn.Id;
        pbi.Price__c = 1;
        insert pbi;


        // Order__c order1 = new Order__c();
        // order1.Customer__c = a.Id;
        // order1.Sales_Org__c = '5070';
        // order1.Distr_Channel__c = '00';
        // order1.Customer_Sales_Info__c = csi.Id;
        // order1.Currency__c = 'USD';
        // order1.Deliver_Plant__c = '5070';
        // order1.Order_type__c = 'ZARB';
        // order1.Status__c = 'Approved';
        // order1.Sync_Status__c = 'Synchronized';
        // order1.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        // order1.Cust_Reference__c = '12';
        // order1.Stock_Aging_Limit__c= '60';
        // order1.SAP_Order__c = true;
        // insert order1;

        // Order_Item__c orI1 = new Order_Item__c();
        // orI1.Order__c = order1.Id;
        // orI1.Guide_Price__c = -1;
        // orI1.Price__c = 4;
        // orI1.SAP_Total_Net__c = 1;
        // orI1.Quantity__c = 1;
        // orI1.IsCreate__c = true;
        // orI1.Product_Cost__c = 10;
        // orI1.New_Price__c = 13;
        // orI1.New_Quantity__c = 13;
        // orI1.New_Amount__c = 13;
        // orI1.New_Delivery_Date__c = Date.today();
        // orI1.Product_Type__c = 'Normal Product';
        // insert orI1;



   Map<String, Object> itemMap = new Map<String, Object>{
    'customerPO' => 'PO123456',
    'salesOrg' => '5070',
    'deliveryPlant' => 'PlantA',
    'distributionChannel' => 'DC01',
    'orderType' => 'ZARA',
    'customer' => a.Name,
    'customerId' => a.Id,
    'shipTo' => 'Sunon Branch',
    'shipToId' => a.Id,
    'pricingDate' => '2025-8-20',
    'currencys' => 'USD',
    'paymentTerm' => 'AR01',
    'productCode' => '12341234',
    'ypfproductName' => 'YPF Widget',
    'productName' => 'Widget A',
    'productNameId' => pn.Id,  
    'orderItemQty' => 10,
    'unitPrice' => 50,
    'deliveryDate' => '2025-8-24',
    'invLocation' => 'LOC01',
    'crop' => 'CropA',
    'salesUnit' => 'PCS',
    'productUnit' => 'UnitA',
    'stockLimit' => 100,
    'salesUnitCoefficient' => 1.0,
    'unitPriceCheck' => true
};
    String data = JSON.serialize(new List<Map<String,Object>>{itemMap});
     OrderImportController.saveOrderData(data);

    }
    static testMethod void testMethod3() {


        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.customer_TYpe__c = 'Distributor';
        Insert a;


         Contact shipToContact = new Contact(
            LastName = 'ShipTo',
            AccountId = a.Id
        );
        insert shipToContact;


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
        pi.Search_Key__c = '12341234'+'-'+'5070'+'-'+'Test';
        pi.Inventory_Quantity__c = 1;
        pi.Product__c = p.Id;
        Insert pi;

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
    
        // Order__c order1 = new Order__c();
        // order1.SAP_Order_Code__c = '123';
        // order1.SAP_Order_Code2__c = '123';
        // order1.Cust_Reference__c = '111';
        // //order1.Inco_Location1__c = '11';
        // order1.Customer__c = a.Id;
        // order1.Sales_Org__c = '5070';
        // order1.Distr_Channel__c = '00';
        // order1.Customer_Sales_Info__c = csi.Id;
        // order1.Currency__c = 'USD';
        // order1.Price_Book__c = pb.Id;
        // order1.Deliver_Plant__c = '5070';
        // order1.Order_type__c = 'ZARB';
        // order1.Customer_Shipping_Address__c = csa.Id;
        // order1.Req_Deliv_Date__c = Date.today();
        // order1.Customer__c = a.Id;
        // order1.Commission_Calculation_Method__c = 'Percent';
        // order1.Commission_Percentage__c = 1;
        // order1.Commission_To__c = a.Id;
        // order1.Commission_Type__c = 'Distributors';
        // order1.SAP_Order__c = false;
        // order1.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        // Insert order1;

        Order__c order1 = new Order__c();
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5070';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Deliver_Plant__c = '5070';
        order1.Order_type__c = 'ZARB';
        order1.Status__c = 'Approved';
        order1.Sync_Status__c = 'Synchronized';
        order1.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order1.Cust_Reference__c = '12';
        order1.Stock_Aging_Limit__c= '60';
        order1.SAP_Order__c = true;
        insert order1;
        order1.Status__c = 'Approved';
        // update order1;
        //       Contact shipToContact = new Contact(
        //     LastName = 'ShipTo',
        //     AccountId = a.Id
        // );
        // insert shipToContact;

        // Product_Sales_Info__c psi = new Product_Sales_Info__c();
        // psi.Distr_Channel__c = '00';
        // insert psi;

        // Product__c p = new Product__c();
        // p.Name = '12341234';
        // p.External_Id__c = '12341234';
        // insert p;

        // Product_Name__c pn = new Product_Name__c();
        // pn.Name = 'Test Combo';
        // pn.Product_Sales_Info__c = psi.Id;
        // pn.Product__c = p.Id;
        // pn.Product_Combo__c = TRUE;
        // insert pn;

        Product_Name__c pn2 = new Product_Name__c();
        pn2.Name = 'Test Combo2';
        pn2.Product_Sales_Info__c = psi.Id;
        pn2.Product__c = p.Id;
        pn2.Product_Combo__c = false;
        insert pn2;

        // Price_Book__c pb = new Price_Book__c();
        // pb.Name = '111';
        // pb.Sales_Org__c = '5070';
        // pb.Currency__c = 'USD';
        // insert pb;

        
        Price_Book_Item__c pbi = new Price_Book_Item__c();
        pbi.Price_Book__c = pb.Id;
        pbi.Product_Name__c = pn.Id;
        pbi.Price__c = 1;
        insert pbi;


    Map<String, Object> itemMap = new Map<String, Object>{
    'customerPO' => 'PO123456',
    'salesOrg' => '5070',
    'deliveryPlant' => 'PlantA',
    'distributionChannel' => 'DC01',
    'orderType' => 'ZARA',
    'customer' => a.Name,
    'customerId' => a.Id,
    'shipTo' => 'Sunon Branch',
    'shipToId' => a.Id,
    'pricingDate' => '2025-8-20',
    'currencys' => 'USD',
    'paymentTerm' => 'AR01',
    'productCode' => '12341234',
    'ypfproductName' => 'YPF Widget',
    'productName' => 'Widget A',
    'productNameId' => pn.Id,  
    'orderItemQty' => 10,
    'unitPrice' => 50,
    'deliveryDate' => '2025-8-24',
    'invLocation' => 'LOC01',
    'crop' => 'CropA',
    'salesUnit' => 'PCS',
    'productUnit' => pu.Id,
    'stockLimit' => 100,
    'salesUnitCoefficient' => 1.0,
    'unitPriceCheck' => true
};
    String data = JSON.serialize(new List<Map<String,Object>>{itemMap});
     OrderImportController.saveOrderData(data);
}
}