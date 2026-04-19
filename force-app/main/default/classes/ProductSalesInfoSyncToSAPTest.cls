/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 10-16-2025
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   10-16-2025   Gerry   Initial Version
**/
@isTest
private class ProductSalesInfoSyncToSAPTest {
    static testMethod void testMethod1() {
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '1111';
        insert a;
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Factory__c = '3010';
        psi.Sales_Organization__c = '3020';
        psi.Delivering_Plant__c = '3020';
        Insert psi;
        List<String> ids = new List<String>();
        ids.add(psi.Id);
        ProductSalesInfoSyncToSAP.submitToSAP(ids);
    }

    static testMethod void testMethod2() {
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Factory__c = '3010';
        psi.Sales_Organization__c = '3020';
        psi.Delivering_Plant__c = '3020';
        Insert psi;
        List<String> ids = new List<String>();
        ids.add(psi.Id);
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.ProductSalesInfoSyncToSAP());
        test.startTest();
        ProductSalesInfoSyncToSAP.submitToSAP(ids);
        test.stopTest();
        
    }

    static testMethod void testMethod3() {
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Factory__c = '3010';
        psi.Sales_Organization__c = '3020';
        psi.Delivering_Plant__c = '3020';
        Insert psi;
        List<String> ids = new List<String>();
        ids.add(psi.Id);
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.ProductSalesInfoSyncToSAPE());
        test.startTest();
        ProductSalesInfoSyncToSAP.submitToSAP(ids);
        test.stopTest();
        
    }

    static testMethod void testMethod4() {
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Factory__c = '3010';
        psi.Sales_Organization__c = '3020';
        psi.Delivering_Plant__c = '3020';
        Insert psi;
        List<String> ids = new List<String>();
        ids.add(psi.Id);
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.ProductSalesInfoSyncToSAPW());
        test.startTest();
        ProductSalesInfoSyncToSAP.submitToSAP(ids);
        test.stopTest();
        
    }
    
    // 新增测试方法：测试returnstatus为'W'且resultinfo为空的情况
    static testMethod void testMethod4_1() {
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Factory__c = '3010';
        psi.Sales_Organization__c = '3020';
        psi.Delivering_Plant__c = '3020';
        Insert psi;
        List<String> ids = new List<String>();
        ids.add(psi.Id);
        
        // 设置Mock返回returnstatus为'W'且resultinfo为空的情况
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.ProductSalesInfoSyncToSAPWEmpty());
        test.startTest();
        ProductSalesInfoSyncToSAP.submitToSAP(ids);
        test.stopTest();
    }
    
    // 新增测试方法：测试returnstatus不为'W'且resultinfo为空的情况
    static testMethod void testMethod4_2() {
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Factory__c = '3010';
        psi.Sales_Organization__c = '3020';
        psi.Delivering_Plant__c = '3020';
        Insert psi;
        List<String> ids = new List<String>();
        ids.add(psi.Id);
        
        // 设置Mock返回returnstatus不为'W'且resultinfo为空的情况
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.ProductSalesInfoSyncToSAPOtherEmpty());
        test.startTest();
        ProductSalesInfoSyncToSAP.submitToSAP(ids);
        test.stopTest();
    }
    
    static testMethod void testMethod5() {
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
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
        order1.Order_type__c = 'ZARB';
        order1.Status__c = 'Approved';
        order1.Sync_Status__c = 'Synchronized';
        order1.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order1.Cust_Reference__c = '12';
        order1.Stock_Aging_Limit__c= '60';
        order1.SAP_Order__c = true;
        insert order1;

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
        ProductSalesInfoSyncToSAP.checkInventory(new List<String>{orI1.Id});
    }
    
    // 新增测试方法：测试产品包（Product_Combo__c = true）的情况
    static testMethod void testMethod6() {
        // 创建账户
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
        Insert a;

        // 创建客户信用信息
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

        // 创建客户销售信息
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '5070';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c = 'Synchronized';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Payment_method__c = 'YPF';
        insert csi;

        // 创建产品包中的子产品1
        Product__c subProduct1 = new Product__c();
        subProduct1.Name = 'SUB_PRODUCT_001';
        subProduct1.External_Id__c = 'SUB_PRODUCT_001';
        insert subProduct1;
        
        Product_Sales_Info__c subProductSalesInfo1 = new Product_Sales_Info__c();
        subProductSalesInfo1.Product__c = subProduct1.Id;
        subProductSalesInfo1.Factory__c = '5070';
        subProductSalesInfo1.Sales_Organization__c = '5070';
        subProductSalesInfo1.Delivering_Plant__c = '5070';
        insert subProductSalesInfo1;
        
        Product_Name__c subProductName1 = new Product_Name__c();
        subProductName1.Name = 'SubProductName1';
        subProductName1.Product_Sales_Info__c = subProductSalesInfo1.Id;
        subProductName1.Product__c = subProduct1.Id;
        subProductName1.Product_Combo__c = false;
        subProductName1.Is_Delete__c = false;
        insert subProductName1;

        // 创建产品包中的子产品2
        Product__c subProduct2 = new Product__c();
        subProduct2.Name = 'SUB_PRODUCT_002';
        subProduct2.External_Id__c = 'SUB_PRODUCT_002';
        insert subProduct2;
        
        Product_Sales_Info__c subProductSalesInfo2 = new Product_Sales_Info__c();
        subProductSalesInfo2.Product__c = subProduct2.Id;
        subProductSalesInfo2.Factory__c = '5070';
        subProductSalesInfo2.Sales_Organization__c = '5070';
        subProductSalesInfo2.Delivering_Plant__c = '5070';
        insert subProductSalesInfo2;
        
        Product_Name__c subProductName2 = new Product_Name__c();
        subProductName2.Name = 'SubProductName2';
        subProductName2.Product_Sales_Info__c = subProductSalesInfo2.Id;
        subProductName2.Product__c = subProduct2.Id;
        subProductName2.Product_Combo__c = false;
        subProductName2.Is_Delete__c = false;
        insert subProductName2;

        // 创建产品包
        Product__c comboProduct = new Product__c();
        comboProduct.Name = 'COMBO_PRODUCT_001';
        comboProduct.External_Id__c = 'COMBO_PRODUCT_001';
        insert comboProduct;
        
        Product_Sales_Info__c comboProductSalesInfo = new Product_Sales_Info__c();
        comboProductSalesInfo.Product__c = comboProduct.Id;
        comboProductSalesInfo.Factory__c = '5070';
        comboProductSalesInfo.Sales_Organization__c = '5070';
        comboProductSalesInfo.Delivering_Plant__c = '5070';
        insert comboProductSalesInfo;
        
        Product_Name__c comboProductName = new Product_Name__c();
        comboProductName.Name = 'ComboProductName';
        comboProductName.Product_Sales_Info__c = comboProductSalesInfo.Id;
        comboProductName.Product__c = comboProduct.Id;
        comboProductName.Product_Combo__c = true; // 设置为产品包
        comboProductName.Is_Delete__c = false;
        insert comboProductName;

        // 创建产品包项目
        Product_Name_Item__c comboItem1 = new Product_Name_Item__c();
        comboItem1.Product_Combo_Name__c = comboProductName.Id;
        comboItem1.Product_Name__c = subProductName1.Id;
        comboItem1.List_Price__c = 50;
        comboItem1.Quantity__c = 2; // 数量大于0
        insert comboItem1;
        
        Product_Name_Item__c comboItem2 = new Product_Name_Item__c();
        comboItem2.Product_Combo_Name__c = comboProductName.Id;
        comboItem2.Product_Name__c = subProductName2.Id;
        comboItem2.List_Price__c = 30;
        comboItem2.Quantity__c = 1; // 数量大于0
        insert comboItem2;
        System.Test.startTest();
        // 创建订单
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

        // 创建订单项目（使用产品包）
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = comboProductName.Id; // 使用产品包
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
        
        // 测试checkInventory方法
        ProductSalesInfoSyncToSAP.checkInventory(new List<String>{order1.Id});
        System.Test.stopTest();
    }
    
    // 新增测试方法：测试非产品包（Product_Combo__c = false）的情况
    static testMethod void testMethod7() {
        // 创建账户
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
        Insert a;

        // 创建客户信用信息
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

        // 创建客户销售信息
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '5070';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c = 'Synchronized';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Payment_method__c = 'YPF';
        insert csi;

        // 创建普通产品（非产品包）
        Product__c normalProduct = new Product__c();
        normalProduct.Name = 'NORMAL_PRODUCT_001';
        normalProduct.External_Id__c = 'NORMAL_PRODUCT_001';
        insert normalProduct;
        
        Product_Sales_Info__c normalProductSalesInfo = new Product_Sales_Info__c();
        normalProductSalesInfo.Product__c = normalProduct.Id;
        normalProductSalesInfo.Factory__c = '5070';
        normalProductSalesInfo.Sales_Organization__c = '5070';
        normalProductSalesInfo.Delivering_Plant__c = '5070';
        insert normalProductSalesInfo;
        
        Product_Name__c normalProductName = new Product_Name__c();
        normalProductName.Name = 'NormalProductName';
        normalProductName.Product_Sales_Info__c = normalProductSalesInfo.Id;
        normalProductName.Product__c = normalProduct.Id;
        normalProductName.Product_Combo__c = false; // 设置为非产品包
        normalProductName.Is_Delete__c = false;
        insert normalProductName;

        // 创建订单
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

        // 创建订单项目（使用普通产品）
        Order_Item__c orI1 = new Order_Item__c();
        orI1.Order__c = order1.Id;
        orI1.Commodity__c = normalProductName.Id; // 使用普通产品
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
        
        // 测试checkInventory方法
        ProductSalesInfoSyncToSAP.checkInventory(new List<String>{order1.Id});
    }
}