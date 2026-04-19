/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 04-04-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-04-2025   Gerry   Initial Version
**/
@IsTest
private class AddOrderItemControllerTest { 

        // 测试initData方法 - 标准订单类型
    @IsTest
    static void testInitDataStandardOrder() {
          Product__c product = new Product__c();
        product.Name = 'TestProduct123';
        product.External_Id__c = 'TestProduct123';
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
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        insert productName;

        Account account = new Account();
        account.Name = 'TestAccount';
        account.Group_Name__c = 'TestGroup';
        account.Customer_Approval_Status__c = 'Approved';
        account.Sync_Status__c = 'Synchronized';
        account.MDG__c = false;
        insert account;
        System.debug('新建时候的状态'+account.Sync_Status__c);
        
        // 创建客户信用信息
        Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        customerCreditInfo.Customer__c = account.Id;
        customerCreditInfo.ExternalId__c = account.Id;
        insert customerCreditInfo;
        
        // 创建客户销售信息
        Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        
        // 创建工厂库存关系
        Plant_Inventory_Relatetions__c plantInventory = new Plant_Inventory_Relatetions__c();
        plantInventory.Delivery_Plant__c = '3020';
        plantInventory.Inventory_Local__c = 'AR05';
        insert plantInventory;

        // 创建标准订单
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZARB';
        order.Interest_Rate__c = 5.0;
        insert order;

        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order.Id;
        orderItem.Commodity__c = productName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Quantity__c = 10;
        orderItem.Price__c = 100;
        orderItem.SAP_Item_Num__c = '001';
        orderItem.isClosed__c = false;
        orderItem.IsCreate__c = true;
        insert orderItem;
        
        Test.startTest();
        AddOrderItemController.Output result = AddOrderItemController.initData(order.Id);
        // AddOrderItemController.testMe();
        Test.stopTest();
        
    }
    
    // 测试initData方法 - ZAR2订单类型
    @IsTest
    static void testInitDataZAR2Order() {
        // 获取测试数据
        Product__c product = new Product__c();
        product.Name = 'TestProduct123';
        product.External_Id__c = 'TestProduct123';
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
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        insert productName;

        Account account = new Account();
        account.Name = 'TestAccount';
        account.Group_Name__c = 'TestGroup';
        account.Customer_Approval_Status__c = 'Approved';
        account.Sync_Status__c = 'Synchronized';
        account.MDG__c = false;
        insert account;
        System.debug('新建时候的状态'+account.Sync_Status__c);
        
        // 创建客户信用信息
        Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        customerCreditInfo.Customer__c = account.Id;
        customerCreditInfo.ExternalId__c = account.Id;
        insert customerCreditInfo;
        
        // 创建客户销售信息
        Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        
        // 创建工厂库存关系
        Plant_Inventory_Relatetions__c plantInventory = new Plant_Inventory_Relatetions__c();
        plantInventory.Delivery_Plant__c = '3020';
        plantInventory.Inventory_Local__c = 'AR05';
        insert plantInventory;
        
        // 创建ZAR2订单
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZARB';
        order.Interest_Rate__c = 5.0;
        insert order;
        
        Test.startTest();
        AddOrderItemController.Output result = AddOrderItemController.initData(order.Id);
        Test.stopTest();
        

    }
    // // 测试initData方法 - 5130工厂订单
    @IsTest
    static void testInitData5130PlantOrder() {
        // 获取测试数据
         Product__c product = new Product__c();
        product.Name = 'TestProduct123';
        product.External_Id__c = 'TestProduct123';
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
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        insert productName;

        Account account = new Account();
        account.Name = 'TestAccount';
        account.Group_Name__c = 'TestGroup';
        account.Customer_Approval_Status__c = 'Approved';
        account.Sync_Status__c = 'Synchronized';
        account.MDG__c = false;
        insert account;
        System.debug('新建时候的状态'+account.Sync_Status__c);
        
        // 创建客户信用信息
        Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        customerCreditInfo.Customer__c = account.Id;
        customerCreditInfo.ExternalId__c = account.Id;
        insert customerCreditInfo;
        
        // 创建客户销售信息
        Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        
        // 创建工厂库存关系
        Plant_Inventory_Relatetions__c plantInventory = new Plant_Inventory_Relatetions__c();
        plantInventory.Delivery_Plant__c = '3020';
        plantInventory.Inventory_Local__c = 'AR05';
        insert plantInventory;
        
        // 创建5130工厂订单
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZARB';
        order.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        // order.is_YPF__c = true;
        insert order;
        
        Test.startTest();
        AddOrderItemController.Output result = AddOrderItemController.initData(order.Id);
        Test.stopTest();
        

    }
  // 测试ZMX6订单类型的搜索功能
    @IsTest
    static void testSearchDataMeZMX6WithSearch() {
        Product__c product = new Product__c();
        product.Name = 'SearchTestProduct';
        product.External_Id__c = 'SearchTestProduct';
        // product.Description_User__c = 'Search Test Product Description';
        insert product;
        
        // 创建产品单位
        Product_Unit__c productUnit = new Product_Unit__c();
        productUnit.Basic_Unit__c = 'L';
        productUnit.Product_Sales_Unit__c = 'L';
        productUnit.Conversion_Coefficient__c = 1;
        productUnit.Product__c = product.Id;
        insert productUnit;
        
        // 创建额外的产品单位来测试循环
        Product_Unit__c productUnit2 = new Product_Unit__c();
        productUnit2.Basic_Unit__c = 'L';
        productUnit2.Product_Sales_Unit__c = 'KG';
        productUnit2.Conversion_Coefficient__c = 0.8;
        productUnit2.Product__c = product.Id;
        insert productUnit2;
        
        // 创建产品销售信息
        Product_Sales_Info__c productSalesInfo = new Product_Sales_Info__c();
        productSalesInfo.Product__c = product.Id;
        productSalesInfo.Status__c = 'On Shelves';
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        productSalesInfo.Distr_Channel__c = '10';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'SearchTestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        
        insert productName;

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
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        
        // 创建ZMX6订单
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '3020';
        order.Distr_Channel__c = '10';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '3020';
        order.Order_type__c = 'ZMX6';
        insert order;
        
        // 添加调试信息
        System.debug('Product__c: ' + product);
        System.debug('Product_Sales_Info__c: ' + productSalesInfo);
        System.debug('Product_Name__c: ' + productName);
        System.debug('Price_Book__c: ' + priceBook);
        System.debug('Price_Book_Item__c: ' + priceBookItem);
        System.debug('Order__c: ' + order);
        
        Test.startTest();
        // 测试搜索功能
        AddOrderItemController.Output result1 = AddOrderItemController.searchDataMe(order.Id, 'SearchTestProduct');
        System.debug('Result1: ' + result1);
        System.debug('Result1 productNameList: ' + result1.productNameList);
        System.debug('Result1 productNameList size: ' + (result1.productNameList != null ? String.valueOf(result1.productNameList.size()) : 'null'));
        
        AddOrderItemController.Output result2 = AddOrderItemController.searchDataMe(order.Id, 'SearchTestProductName');
        System.debug('Result2: ' + result2);
        
        AddOrderItemController.Output result3 = AddOrderItemController.searchDataMe(order.Id, 'Search Test Product Description');
        System.debug('Result3: ' + result3);
        Test.stopTest();


    }
    
    // 测试ZAR1订单类型（普通订单）
    static void testSearchDataMeZAR1() {
        Product__c product = new Product__c();
        product.Name = 'ZAR1TestProduct';
        product.External_Id__c = 'ZAR1TestProduct';
        // product.Description_User__c = 'ZAR1 Test Product Description';
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
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        productSalesInfo.Distr_Channel__c = '10';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'ZAR1TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        
        insert productName;

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
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        
        // 创建产品库存
        Product_Inventory__c productInventory = new Product_Inventory__c();
        productInventory.Search_Key__c = 'ZAR1TestProduct-3020-ZAR1TestProductName';
        productInventory.Inventory_Quantity__c = 100;
        productInventory.Product__c = product.Id;
        insert productInventory;
        
        // 创建ZAR1订单
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '3020';
        order.Distr_Channel__c = '10';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '3020';
        order.Order_type__c = 'ZAR1';
        insert order;
        
        Test.startTest();
        AddOrderItemController.Output result = AddOrderItemController.searchDataMe(order.Id, '');
        Test.stopTest();
        
        // 验证结果
        
        // 验证产品信息
        AddOrderItemController.ProductName productResult = result.productNameList[0];

    }

    
    // 测试saveData方法
    static void testSaveData() {
        Product__c product = new Product__c();
        product.Name = 'SaveTestProduct';
        product.External_Id__c = 'SaveTestProduct';
        // product.Description_User__c = 'Save Test Product Description';
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
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        productSalesInfo.Distr_Channel__c = '10';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'SaveTestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        
        insert productName;

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
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        order.Sales_Org__c = '3020';
        order.Distr_Channel__c = '10';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '3020';
        order.Order_type__c = 'ZAR1';
        insert order;
        
        // 创建订单项目
        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order.Id;
        orderItem.Commodity__c = productName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Sales_Unit__c = productUnit.Id;
        orderItem.Quantity__c = 10;
        orderItem.Price__c = 100;
        orderItem.Commission_Amount__c = 50;
        orderItem.Commission_Calculation_Method__c = 'Amount';
        orderItem.Product_Type__c = 'Standard';
        insert orderItem;
        
        Test.startTest();
        
        // 创建OrderItem包装器
        List<AddOrderItemController.OrderItem> orderItemList = new List<AddOrderItemController.OrderItem>();
        AddOrderItemController.OrderItem orderItemWrapper = new AddOrderItemController.OrderItem();
        orderItemWrapper.orderItemData = orderItem;
        orderItemWrapper.indexNum = '1';
        orderItemWrapper.basicQuantity = 10;
        orderItemWrapper.showPercentage = false;
        orderItemWrapper.showCommissionAmount = true;
        orderItemList.add(orderItemWrapper);
        
        // 测试保存数据
        List<String> deleteList = new List<String>();
        AddOrderItemController.Output result = AddOrderItemController.saveData(orderItemList, deleteList);
        
        Test.stopTest();
        
        // 验证结果

        
        // 验证订单项目是否被正确更新
        Order_Item__c updatedOrderItem = [SELECT Id, Material_Number__c, Material_Description__c, 
                                        Sales_Unit_Text__c, Amount_per_item__c, Product_Cost__c,
                                        Margin__c, Margin_Rate__c, IsCreate__c
                                        FROM Order_Item__c WHERE Id = :orderItem.Id];

    }
    
    // 测试异常情况
    static void testExceptionHandling() {
        Test.startTest();
        
        // 测试空订单ID
        AddOrderItemController.Output result1 = AddOrderItemController.initData('');

        
        // 测试无效订单ID
        AddOrderItemController.Output result2 = AddOrderItemController.initData('001000000000000');


        
        // 测试空搜索
        AddOrderItemController.Output result3 = AddOrderItemController.searchDataMe('', '');

        
        Test.stopTest();
    }
    
    // 测试佣金计算（5130工厂）
    static void testCommissionCalculation() {
        Product__c product = new Product__c();
        product.Name = 'CommissionTestProduct';
        product.External_Id__c = 'CommissionTestProduct';
        // product.Description_User__c = 'Commission Test Product Description';
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
        productSalesInfo.Sales_Organization__c = '5130';
        productSalesInfo.Delivering_Plant__c = '5130';
        productSalesInfo.Factory__c = '5130';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        productSalesInfo.Distr_Channel__c = '00';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'CommissionTestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        
        insert productName;

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
        customerSalesInfo.Sales_Org__c = '5130';
        customerSalesInfo.Distr_Channel__c = '00';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '5130';
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
        
        // 创建订单（5130工厂）
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZAR1';
        insert order;
        
        // 创建订单项目
        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order.Id;
        orderItem.Commodity__c = productName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Sales_Unit__c = productUnit.Id;
        orderItem.Quantity__c = 10;
        orderItem.Price__c = 100;
        orderItem.Commission_Amount__c = 100;
        orderItem.Commission_Calculation_Method__c = 'Amount';
        orderItem.Product_Type__c = 'Standard';
        insert orderItem;
        
        Test.startTest();
        
        // 创建OrderItem包装器
        List<AddOrderItemController.OrderItem> orderItemList = new List<AddOrderItemController.OrderItem>();
        AddOrderItemController.OrderItem orderItemWrapper = new AddOrderItemController.OrderItem();
        orderItemWrapper.orderItemData = orderItem;
        orderItemWrapper.indexNum = '1';
        orderItemWrapper.basicQuantity = 10;
        orderItemWrapper.showPercentage = false;
        orderItemWrapper.showCommissionAmount = true;
        orderItemList.add(orderItemWrapper);
        
        // 测试保存数据
        List<String> deleteList = new List<String>();
        AddOrderItemController.Output result = AddOrderItemController.saveData(orderItemList, deleteList);
        
        Test.stopTest();
        
        // 验证结果

        
        // 验证订单佣金信息是否被正确更新
        Order__c updatedOrder = [SELECT Id, Commission_Amount_New__c, Commission_Calculation_Method__c
                                FROM Order__c WHERE Id = :order.Id];

    }
    
    // // 测试searchDataMe方法 - 寄售订单类型
    @IsTest
    static void testSearchDataMeConsignment() {
        // 获取测试数据
        Product__c product = new Product__c();
        product.Name = 'TestProduct123';
        product.External_Id__c = 'TestProduct123';
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
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        insert productName;

        Account account = new Account();
        account.Name = 'TestAccount';
        account.Group_Name__c = 'TestGroup';
        account.Customer_Approval_Status__c = 'Approved';
        account.Sync_Status__c = 'Synchronized';
        account.MDG__c = false;
        insert account;
        System.debug('新建时候的状态'+account.Sync_Status__c);
        
        // 创建客户信用信息
        Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        customerCreditInfo.Customer__c = account.Id;
        customerCreditInfo.ExternalId__c = account.Id;
        insert customerCreditInfo;
        
        // 创建客户销售信息
        Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        
        // 创建工厂库存关系
        Plant_Inventory_Relatetions__c plantInventory = new Plant_Inventory_Relatetions__c();
        plantInventory.Delivery_Plant__c = '3020';
        plantInventory.Inventory_Local__c = 'AR05';
        insert plantInventory;
        
        // 创建ZARB订单（寄售基础订单）
        Order__c orderZARB = new Order__c();
        orderZARB.Customer__c = account.Id;
        orderZARB.Sales_Org__c = '5130';
        orderZARB.Distr_Channel__c = '00';
        orderZARB.Customer_Sales_Info__c = customerSalesInfo.Id;
        orderZARB.Currency__c = 'USD';
        orderZARB.Price_Book__c = priceBook.Id;
        orderZARB.Deliver_Plant__c = '5130';
        orderZARB.Order_type__c = 'ZARB';
        orderZARB.Status__c = 'Approved';
        insert orderZARB;
        Test.startTest();
        // 创建订单项目
        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = orderZARB.Id;
        orderItem.Commodity__c = productName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Quantity__c = 10;
        orderItem.Price__c = 100;
        orderItem.SAP_Item_Num__c = '001';
        orderItem.isClosed__c = false;
        orderItem.IsCreate__c = true;
        insert orderItem;

        
        // 创建ZARE订单（寄售发货订单）
        Order__c orderZARE = new Order__c();
        orderZARE.Customer__c = account.Id;
        orderZARE.Sales_Org__c = '5130';
        orderZARE.Distr_Channel__c = '00';
        orderZARE.Customer_Sales_Info__c = customerSalesInfo.Id;
        orderZARE.Currency__c = 'USD';
        orderZARE.Price_Book__c = priceBook.Id;
        orderZARE.Deliver_Plant__c = '5130';
        orderZARE.Order_type__c = 'ZARE';
        insert orderZARE;
        
        
        AddOrderItemController.Output result = AddOrderItemController.searchDataMe(orderZARE.Id, '');
        Test.stopTest();
        

    }
    
    // 测试saveData方法 - 带佣金计算
    @IsTest
    static void testSaveDataWithCommission() {
        // 获取测试数据
         Product__c product = new Product__c();
        product.Name = 'TestProduct123';
        product.External_Id__c = 'TestProduct123';
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
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        insert productName;

        Account account = new Account();
        account.Name = 'TestAccount';
        account.Group_Name__c = 'TestGroup';
        account.Customer_Approval_Status__c = 'Approved';
        account.Sync_Status__c = 'Synchronized';
        account.MDG__c = false;
        insert account;
        System.debug('新建时候的状态'+account.Sync_Status__c);
        
        // 创建客户信用信息
        Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        customerCreditInfo.Customer__c = account.Id;
        customerCreditInfo.ExternalId__c = account.Id;
        insert customerCreditInfo;
        
        // 创建客户销售信息
        Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        
        // 创建工厂库存关系
        Plant_Inventory_Relatetions__c plantInventory = new Plant_Inventory_Relatetions__c();
        plantInventory.Delivery_Plant__c = '3020';
        plantInventory.Inventory_Local__c = 'AR05';
        insert plantInventory;
        
        // 创建5130工厂订单
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZARB';
        insert order;
        
        // 创建订单项目
        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order.Id;
        orderItem.Commodity__c = productName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Quantity__c = 5;
        orderItem.Price__c = 100;
        orderItem.Sales_Unit__c = productUnit.Id;
        orderItem.SAP_Item_Num__c = '001';
        orderItem.Commission_Calculation_Method__c = 'Amount';
        orderItem.Commission_Amount__c = 50;
        orderItem.Product_Type__c = 'Normal Product';
        orderItem.IsCreate__c = true;
        insert orderItem;
        
        Test.startTest();
        
        // 创建OrderItem对象
        List<AddOrderItemController.OrderItem> orderItemList = new List<AddOrderItemController.OrderItem>();
        AddOrderItemController.OrderItem oi = new AddOrderItemController.OrderItem();
        oi.orderItemData = orderItem;
        oi.indexNum = '001';
        oi.basicQuantity = 5;
        oi.showPercentage = false;
        oi.showCommissionAmount = true;
        orderItemList.add(oi);
        
        List<String> deleteList = new List<String>();
        
        AddOrderItemController.Output result = AddOrderItemController.saveData(orderItemList, deleteList);
        
        Test.stopTest();
        

        
        // 验证订单佣金是否被更新
        Order__c updatedOrder = [SELECT Id, Commission_Amount_New__c, Commission_Calculation_Method__c 
                                FROM Order__c WHERE Id = :order.Id];

    }
    
    // 测试saveData方法 - 删除订单项目
    @IsTest
    static void testSaveDataWithDelete() {
        // 获取测试数据
        Product__c product = new Product__c();
        product.Name = 'TestProduct123';
        product.External_Id__c = 'TestProduct123';
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
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        insert productName;

        Account account = new Account();
        account.Name = 'TestAccount';
        account.Group_Name__c = 'TestGroup';
        account.Customer_Approval_Status__c = 'Approved';
        account.Sync_Status__c = 'Synchronized';
        account.MDG__c = false;
        insert account;
        System.debug('新建时候的状态'+account.Sync_Status__c);
        
        // 创建客户信用信息
        Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        customerCreditInfo.Customer__c = account.Id;
        customerCreditInfo.ExternalId__c = account.Id;
        insert customerCreditInfo;
        
        // 创建客户销售信息
        Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        
        // 创建工厂库存关系
        Plant_Inventory_Relatetions__c plantInventory = new Plant_Inventory_Relatetions__c();
        plantInventory.Delivery_Plant__c = '3020';
        plantInventory.Inventory_Local__c = 'AR05';
        insert plantInventory;
        
        // 创建订单
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZARB';
        order.Interest_Rate__c = 5.0;
        insert order;
        
        // 创建订单项目
        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order.Id;
        orderItem.Commodity__c = productName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Quantity__c = 5;
        orderItem.Price__c = 100;
        orderItem.Sales_Unit__c = productUnit.Id;
        orderItem.SAP_Item_Num__c = '001';
        orderItem.IsCreate__c = true;
        insert orderItem;
        
        Test.startTest();
        
        List<AddOrderItemController.OrderItem> orderItemList = new List<AddOrderItemController.OrderItem>();
        List<String> deleteList = new List<String>{orderItem.Id};
        
        AddOrderItemController.Output result = AddOrderItemController.saveData(orderItemList, deleteList);
        
        Test.stopTest();
        
        // 验证结果

        
        // 验证订单项目是否被删除
        List<Order_Item__c> remainingOrderItems = [SELECT Id FROM Order_Item__c WHERE Id = :orderItem.Id];

    }
    
    // 测试异常情况
    // @IsTest
    // static void testExceptionHandling() {
    //     Test.startTest();
    //     AddOrderItemController.Output result = AddOrderItemController.initData('');
    //     Test.stopTest();
        
    //     // 验证异常处理
    //     System.assertNotEquals(null, result, '结果不应为空');
    //     System.assertEquals(false, result.isSucess, '应该失败');
    //     System.assertNotEquals('', result.errorMsg, '错误信息不应为空');
    // }
    
    // 测试getMap方法
    @IsTest
    static void testGetMap() {
        // 获取测试数据
         Product__c product = new Product__c();
        product.Name = 'TestProduct123';
        product.External_Id__c = 'TestProduct123';
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
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        insert productName;
        
        Test.startTest();
        Set<String> commodityIdSet = new Set<String>{productName.Product__c};
        Map<String, List<Product_Unit__c>> result = AddOrderItemController.getMap(commodityIdSet);
        Test.stopTest();
        
        // 验证结果

    }
    
    // // 测试墨西哥用户场景
    @IsTest
    static void testMexicanUser() {
        // 获取测试数据
        Product__c product = new Product__c();
        product.Name = 'TestProduct123';
        product.External_Id__c = 'TestProduct123';
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
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        insert productName;

        Account account = new Account();
        account.Name = 'TestAccount';
        account.Group_Name__c = 'TestGroup';
        account.Customer_Approval_Status__c = 'Approved';
        account.Sync_Status__c = 'Synchronized';
        account.MDG__c = false;
        insert account;
        System.debug('新建时候的状态'+account.Sync_Status__c);
        
        // 创建客户信用信息
        Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        customerCreditInfo.Customer__c = account.Id;
        customerCreditInfo.ExternalId__c = account.Id;
        insert customerCreditInfo;
        
        // 创建客户销售信息
        Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        
        // 创建工厂库存关系
        Plant_Inventory_Relatetions__c plantInventory = new Plant_Inventory_Relatetions__c();
        plantInventory.Delivery_Plant__c = '3020';
        plantInventory.Inventory_Local__c = 'AR05';
        insert plantInventory;
        
        // 创建墨西哥用户
        User mexicanUser = new User();
        mexicanUser.FirstName = 'Test';
        mexicanUser.LastName = 'MexicanUser';
        mexicanUser.Email = 'test.mexican@test.com';
        mexicanUser.Username = 'test.mexican@test.com.test';
        mexicanUser.Alias = 'tmex';
        mexicanUser.TimeZoneSidKey = 'America/Los_Angeles';
        mexicanUser.LocaleSidKey = 'en_US';
        mexicanUser.EmailEncodingKey = 'UTF-8';
        mexicanUser.ProfileId = [SELECT Id FROM Profile WHERE Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema' LIMIT 1].Id;
        mexicanUser.LanguageLocaleKey = 'en_US';
        mexicanUser.Country__c = 'MX';
        insert mexicanUser;
        
        // 创建订单
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZARB';
        order.Interest_Rate__c = 5.0;
        insert order;

        
        Test.startTest();
        System.runAs(mexicanUser) {
            AddOrderItemController.Output result = AddOrderItemController.initData(order.Id);
            
            // 验证墨西哥用户特定功能
            // System.assertEquals(true, result.showProductusage, '墨西哥用户应该显示产品用途');
        }
        Test.stopTest();
    }
    
    // 测试免费产品场景
    @IsTest
    static void testFreeProduct() {
        // 获取测试数据
        Product__c product = new Product__c();
        product.Name = 'TestProduct123';
        product.External_Id__c = 'TestProduct123';
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
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        insert productName;

        Account account = new Account();
        account.Name = 'TestAccount';
        account.Group_Name__c = 'TestGroup';
        account.Customer_Approval_Status__c = 'Approved';
        account.Sync_Status__c = 'Synchronized';
        account.MDG__c = false;
        insert account;
        System.debug('新建时候的状态'+account.Sync_Status__c);
        
        // 创建客户信用信息
        Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        customerCreditInfo.Customer__c = account.Id;
        customerCreditInfo.ExternalId__c = account.Id;
        insert customerCreditInfo;
        
        // 创建客户销售信息
        Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        
        // 创建工厂库存关系
        Plant_Inventory_Relatetions__c plantInventory = new Plant_Inventory_Relatetions__c();
        plantInventory.Delivery_Plant__c = '3020';
        plantInventory.Inventory_Local__c = 'AR05';
        insert plantInventory;
        
        // 创建订单
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZARB';
        order.Interest_Rate__c = 5.0;
        insert order;
        
        // 创建免费产品订单项目
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
        insert orderItem;
        
        Test.startTest();
        
        // 创建OrderItem对象
        List<AddOrderItemController.OrderItem> orderItemList = new List<AddOrderItemController.OrderItem>();
        AddOrderItemController.OrderItem oi = new AddOrderItemController.OrderItem();
        oi.orderItemData = orderItem;
        oi.indexNum = '001';
        oi.basicQuantity = 5;
        orderItemList.add(oi);
        
        List<String> deleteList = new List<String>();
        
        AddOrderItemController.Output result = AddOrderItemController.saveData(orderItemList, deleteList);
        
        Test.stopTest();
    }

 // 测试searchDataMe方法 - 标准搜索
    @IsTest
    static void testSearchDataMeNormalProduct() {
        Account account = new Account();
        account.Name = 'TestAccount';
        account.Group_Name__c = 'TestGroup';
        account.Customer_Approval_Status__c = 'Approved';
        account.Sync_Status__c = 'Synchronized';
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
        account.MDG__c = false;
        insert account;
        System.debug('新建时候的状态'+account.Sync_Status__c);

        // 获取测试数据
        Product__c product = new Product__c();
        product.Name = 'TestProduct123';
        product.External_Id__c = 'TestProduct123';
        insert product;
        
        // 创建产品单位
        Product_Unit__c productUnit = new Product_Unit__c();
        productUnit.Basic_Unit__c = 'L';
        productUnit.Product_Sales_Unit__c = 'L';
        productUnit.Conversion_Coefficient__c = 1;
        productUnit.Product__c = product.Id;
        productUnit.Molecule__c = 10;
        productUnit.Denominator__c = 10;
        insert productUnit;
        
        // 创建产品销售信息
        Product_Sales_Info__c productSalesInfo = new Product_Sales_Info__c();
        productSalesInfo.Product__c = product.Id;
        productSalesInfo.Status__c = 'On Shelves';
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        productName.Customer__c = account.Id;
        insert productName;


        
        // 创建客户信用信息
        Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        customerCreditInfo.Customer__c = account.Id;
        customerCreditInfo.ExternalId__c = account.Id;
        insert customerCreditInfo;
        
        // 创建客户销售信息
        Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        
        System.debug(priceBookItem.Is_Changing__c);
        System.debug(priceBookItem.Status__c);


        // 创建工厂库存关系
        Plant_Inventory_Relatetions__c plantInventory = new Plant_Inventory_Relatetions__c();
        plantInventory.Delivery_Plant__c = '3020';
        plantInventory.Inventory_Local__c = 'AR05';
        insert plantInventory;
        
        // 创建订单
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '3020';
        order.Distr_Channel__c = '10';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '3020';
        order.Order_type__c = 'ZMX6';
        order.Interest_Rate__c = 5.0;
        insert order;

        String orderRecordId = order.Id;
        Order__c order9 = [SELECT Invoice__c,Price_Book__c,Currency__c,Sales_Org__c,Deliver_Plant__c,Order_type__c,Id,Customer__c,Customer_Sales_Info__r.Sales_Org__c FROM Order__c WHERE Id=:orderRecordId];
        String accId = order9.Customer__c;
        String org = order9.Sales_Org__c;
        String currencyCode = order9.Currency__c;
        String price = order9.Price_Book__c;
        
        Test.startTest();
        AddOrderItemController.Output result = AddOrderItemController.searchDataMe(order.Id, '');
        // AddOrderItemController.Output resultWithSearch = AddOrderItemController.searchDataMe(order.Id, 'Test');
        Test.stopTest();
        
}
    @IsTest
    static void testSearchDataZAR2() {
        Account account = new Account();
        account.Name = 'TestAccount';
        account.Group_Name__c = 'TestGroup';
        account.Customer_Approval_Status__c = 'Approved';
        account.Sync_Status__c = 'Synchronized';
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
        account.MDG__c = false;
        insert account;
        System.debug('新建时候的状态'+account.Sync_Status__c);

        // 获取测试数据
        Product__c product = new Product__c();
        product.Name = 'TestProduct123';
        product.External_Id__c = 'TestProduct123';
        insert product;
        
        // 创建产品单位
        Product_Unit__c productUnit = new Product_Unit__c();
        productUnit.Basic_Unit__c = 'L';
        productUnit.Product_Sales_Unit__c = 'L';
        productUnit.Conversion_Coefficient__c = 1;
        productUnit.Product__c = product.Id;
        productUnit.Molecule__c = 10;
        productUnit.Denominator__c = 10;
        insert productUnit;
        
        // 创建产品销售信息
        Product_Sales_Info__c productSalesInfo = new Product_Sales_Info__c();
        productSalesInfo.Product__c = product.Id;
        productSalesInfo.Status__c = 'On Shelves';
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        productName.Customer__c = account.Id;
        insert productName;


        
        // 创建客户信用信息
        Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        customerCreditInfo.Customer__c = account.Id;
        customerCreditInfo.ExternalId__c = account.Id;
        insert customerCreditInfo;
        
        // 创建客户销售信息
        Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        
        System.debug(priceBookItem.Is_Changing__c);
        System.debug(priceBookItem.Status__c);


        // 创建工厂库存关系
        Plant_Inventory_Relatetions__c plantInventory = new Plant_Inventory_Relatetions__c();
        plantInventory.Delivery_Plant__c = '3020';
        plantInventory.Inventory_Local__c = 'AR05';
        insert plantInventory;

        Invoice__c inv = new Invoice__c();
        inv.External_Id__c = '1';
        Insert inv;
        
        // 创建订单
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZAR2';
        order.Interest_Rate__c = 5.0;
        order.Invoice__c = inv.Id;
        order.Order_Reason__c = '001';
        insert order;



        Billing__c bill = new Billing__c();
        bill.Billing_Status__c = 'C';
        bill.Billing_Num__c = '1234';
        bill.Invoice_Date__c = Date.valueOf('2024-01-02');
        bill.SAP_Total_Net__c = 10;
        bill.SAP_Total_Net_UDS__c = 10;
        bill.SAP_Total_Amount__c = 0;
        bill.Collection_Transaction_Amount__c = 0;
        bill.Invoice__c = inv.Id;
        Insert bill;

        String orderRecordId = order.Id;
        
        Test.startTest();
        AddOrderItemController.Output result = AddOrderItemController.searchDataMe(order.Id, '');
        // AddOrderItemController.Output resultWithSearch = AddOrderItemController.searchDataMe(order.Id, 'Test');
        Test.stopTest();
        
}
    @IsTest
    static void testSearchDataZARF() {
        Account account = new Account();
        account.Name = 'TestAccount';
        account.Group_Name__c = 'TestGroup';
        account.Customer_Approval_Status__c = 'Approved';
        account.Sync_Status__c = 'Synchronized';
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
        account.MDG__c = false;
        insert account;
        System.debug('新建时候的状态'+account.Sync_Status__c);

        // 获取测试数据
        Product__c product = new Product__c();
        product.Name = 'TestProduct123';
        product.External_Id__c = 'TestProduct123';
        insert product;
        
        // 创建产品单位
        Product_Unit__c productUnit = new Product_Unit__c();
        productUnit.Basic_Unit__c = 'L';
        productUnit.Product_Sales_Unit__c = 'L';
        productUnit.Conversion_Coefficient__c = 1;
        productUnit.Product__c = product.Id;
        productUnit.Molecule__c = 10;
        productUnit.Denominator__c = 10;
        insert productUnit;
        
        // 创建产品销售信息
        Product_Sales_Info__c productSalesInfo = new Product_Sales_Info__c();
        productSalesInfo.Product__c = product.Id;
        productSalesInfo.Status__c = 'On Shelves';
        productSalesInfo.Sales_Organization__c = '3020';
        productSalesInfo.Delivering_Plant__c = '3020';
        productSalesInfo.Factory__c = '3020';
        productSalesInfo.Product_Unit__c = productUnit.Id;
        productSalesInfo.Cost_Local__c = 50;
        productSalesInfo.Cost_USD__c = 10;
        productSalesInfo.Default_Sales_Unit__c = 'L';
        insert productSalesInfo;
        
        // 创建产品名称
        Product_Name__c productName = new Product_Name__c();
        productName.Name = 'TestProductName';
        productName.Product_Sales_Info__c = productSalesInfo.Id;
        productName.Product__c = product.Id;
        productName.Product_Combo__c = false;
        productName.Is_Delete__c = false;
        productName.Customer__c = account.Id;
        insert productName;


        
        // 创建客户信用信息
        Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        customerCreditInfo.Customer__c = account.Id;
        customerCreditInfo.ExternalId__c = account.Id;
        insert customerCreditInfo;
        
        // 创建客户销售信息
        Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        
        // 创建价格手册
        Price_Book__c priceBook = new Price_Book__c();
        priceBook.Name = 'TestPriceBook';
        priceBook.Sales_Org__c = '3020';
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
        
        System.debug(priceBookItem.Is_Changing__c);
        System.debug(priceBookItem.Status__c);


        // 创建工厂库存关系
        Plant_Inventory_Relatetions__c plantInventory = new Plant_Inventory_Relatetions__c();
        plantInventory.Delivery_Plant__c = '3020';
        plantInventory.Inventory_Local__c = 'AR05';
        insert plantInventory;

        Invoice__c inv = new Invoice__c();
        inv.External_Id__c = '1';
        Insert inv;
        
        // 创建订单
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = priceBook.Id;
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZARF';
        order.Interest_Rate__c = 5.0;
        order.Order_Reason__c = '001';
        order.Status__c = 'Approved';
        Test.startTest();
        insert order;

        Order__c order2 = new Order__c();
        order2.Customer__c = account.Id;
        order2.Sales_Org__c = '5130';
        order2.Distr_Channel__c = '00';
        order2.Customer_Sales_Info__c = customerSalesInfo.Id;
        order2.Currency__c = 'USD';
        order2.Price_Book__c = priceBook.Id;
        order2.Deliver_Plant__c = '5130';
        order2.Order_type__c = 'ZARB';
        order2.Interest_Rate__c = 5.0;
        order2.Order_Reason__c = '001';
        order2.Status__c = 'Approved';
        insert order2;

        Order__c order3 = new Order__c();
        order3.Customer__c = account.Id;
        order3.Sales_Org__c = '5130';
        order3.Distr_Channel__c = '00';
        order3.Customer_Sales_Info__c = customerSalesInfo.Id;
        order3.Currency__c = 'USD';
        order3.Price_Book__c = priceBook.Id;
        order3.Deliver_Plant__c = '5130';
        order3.Order_type__c = 'ZARE';
        order3.Interest_Rate__c = 5.0;
        order3.Order_Reason__c = '001';
        order3.Status__c = 'Approved';
        insert order3;

        Billing__c bill = new Billing__c();
        bill.Billing_Status__c = 'C';
        bill.Billing_Num__c = '1234';
        bill.Invoice_Date__c = Date.valueOf('2024-01-02');
        bill.SAP_Total_Net__c = 10;
        bill.SAP_Total_Net_UDS__c = 10;
        bill.SAP_Total_Amount__c = 0;
        bill.Collection_Transaction_Amount__c = 0;
        bill.Invoice__c = inv.Id;
        Insert bill;

        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order.Id;
        orderItem.Invoice_Item__c = bill.Id;
        orderItem.Commodity__c = productName.Id;
        orderItem.Price_Book_Item__c = priceBookItem.Id;
        orderItem.Quantity__c = 0;
        orderItem.Price__c = 100;
        orderItem.Sales_Unit__c = productUnit.Id;
        orderItem.SAP_Item_Num__c = '001';
        orderItem.Product_Type__c = 'Free Product';
        orderItem.IsCreate__c = true;
        orderItem.isClosed__c=false;
        orderItem.Product_Cost__c = 10;
        orderItem.Product_Type__c = 'Normal Product';
        orderItem.Guide_Price__c = 100;
        orderItem.Price__c = 10;
        orderItem.Delivery_Date__c = Date.today();
        orderItem.SAP_Total_Net__c =  100;
        orderItem.Amount_per_item__c =  10;
        insert orderItem;

        Order_Item__c orderItem2 = new Order_Item__c();
        orderItem2.Order__c = order2.Id;
        orderItem2.Invoice_Item__c = bill.Id;
        orderItem2.Commodity__c = productName.Id;
        orderItem2.Price_Book_Item__c = priceBookItem.Id;
        orderItem2.Quantity__c = 0;
        orderItem2.Price__c = 100;
        orderItem2.Sales_Unit__c = productUnit.Id;
        orderItem2.SAP_Item_Num__c = '001';
        orderItem2.Product_Type__c = 'Free Product';
        orderItem2.IsCreate__c = true;
        orderItem2.isClosed__c = false;
        orderItem2.Product_Cost__c = 10;
        orderItem2.Product_Type__c = 'Normal Product';
        orderItem2.Guide_Price__c = 100;
        orderItem2.Price__c = 10;
        orderItem2.Delivery_Date__c = Date.today();
        orderItem2.SAP_Total_Net__c = 100;
        orderItem2.Amount_per_item__c = 10;
        orderItem2.Depend_On_Item__c = orderItem.Id;
        insert orderItem2;

        Order_Item__c orderItem3 = new Order_Item__c();
        orderItem3.Order__c = order.Id;
        orderItem3.Invoice_Item__c = bill.Id;
        orderItem3.Commodity__c = productName.Id;
        orderItem3.Price_Book_Item__c = priceBookItem.Id;
        orderItem3.Quantity__c = 0;
        orderItem3.Price__c = 100;
        orderItem3.Sales_Unit__c = productUnit.Id;
        orderItem3.SAP_Item_Num__c = '001';
        orderItem3.Product_Type__c = 'Free Product';
        orderItem3.IsCreate__c = true;
        orderItem3.isClosed__c = false;
        orderItem3.Product_Cost__c = 10;
        orderItem3.Product_Type__c = 'Normal Product';
        orderItem3.Guide_Price__c = 100;
        orderItem3.Price__c = 10;
        orderItem3.Delivery_Date__c = Date.today();
        orderItem3.SAP_Total_Net__c = 100;
        orderItem3.Amount_per_item__c = 10;
        orderItem3.Depend_On_Item__c = orderItem2.Id;
        insert orderItem3;


            System.debug('Id = ' + orderItem.Id);
            System.debug('Commodity__c = ' + orderItem.Commodity__c);
            System.debug('Cost_Local = ' + orderItem.Commodity__r.Product_Sales_Info__r.Cost_Local__c);
            System.debug('Cost_USD = ' + orderItem.Commodity__r.Product_Sales_Info__r.Cost_USD__c);
            System.debug('Price = ' + orderItem.Price__c);
            System.debug('Product_Description = ' + orderItem.Commodity__r.Product__r.Description_User__c);
            System.debug('Product_Combo = ' + orderItem.Commodity__r.Product_Combo__c);
            System.debug('Order_Type = ' + orderItem.Order__r.Order_type__c);
            System.debug('Sales_Unit = ' + orderItem.Sales_Unit__c);
            System.debug('Product_Name = ' + orderItem.Commodity__r.Product__r.Name);
            System.debug('Commodity_Name = ' + orderItem.Commodity__r.Name);
            System.debug('Quantity = ' + orderItem.Quantity__c);
            System.debug('Used_Number = ' + orderItem.Used_Number__c);
            System.debug('Basic_Number = ' + orderItem.Basic_Number__c);
            System.debug('SAP_Order_Code = ' + orderItem.Order__r.SAP_Order_Code__c);
            System.debug('Order_CreatedDate = ' + orderItem.Order__r.CreatedDate);
            System.debug('Price_Book_Item = ' + orderItem.Price_Book_Item__c);
            System.debug('Delivery_Quantity = ' + orderItem.Delivery_Quantity__c);
            System.debug('IsClosed = ' + orderItem.isClosed__c);

        Order_Item__c  orderItem99 = [
                        SELECT Id,
                            Order__c,
                            Order__r.Price_Book__c,
                            Order__r.Customer__c
                        FROM Order_Item__c
                        WHERE Id = :orderItem.Id Limit 1
                    ];

            String price = orderItem99.Order__r.Price_Book__c;
            String accId = orderItem99.Order__r.Customer__c;

            System.debug('orderItem.Order__c = ' + orderItem99.Order__c);
            System.debug('price = ' + price);
            System.debug('accId = ' + accId);
            String query = 
                            'SELECT '+
                                    'Id,'+
                                    'Commodity__c,Commodity__r.Product_Sales_Info__r.Cost_Local__c,Commodity__r.Product_Sales_Info__r.Cost_USD__c,'+
                                    'Price__c,Commodity__r.Product__r.Description_User__c,Commodity__r.Product_Combo__c,Order__r.Order_type__c,'+
                                    'Sales_Unit__c,Commodity__r.Product__r.Name,'+
                                    'Commodity__r.Name,TOLabel(Sales_Unit__r.Product_Sales_Unit__c),'+
                                    'Quantity__c,Used_Number__c,Basic_Number__c,Order__r.SAP_Order_Code__c,Order__r.CreatedDate,Price_Book_Item__c,Delivery_Quantity__c,isClosed__c '+
                                'FROM '+
                                    'Order_Item__c  '+
                                'WHERE '+
                                        'Order__r.Customer__c=\'' + accId + '\' AND Order__r.Order_type__c=\'ZARB\' AND Order__r.Status__c=\'Approved\' AND Order__r.Price_Book__c=\'' + price + '\' AND (isClosed__c=false OR (isClosed__c=true AND Delivery_Quantity__c!=null AND Delivery_Quantity__c!=0))';

        List<Order_Item__c> oi = Database.query(query);
        Order_Item__c test111 = oi[0];
        String orderRecordId = order.Id;
        
        //Test.startTest();
        AddOrderItemController.Output result = AddOrderItemController.searchDataMe(order.Id, '');
        AddOrderItemController.Output resultWithSearch = AddOrderItemController.searchDataMe(order.Id, 'Test');
        Test.stopTest();
        
    }
    @IsTest
    static void testSearchZARF() {
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
        System.Test.startTest();
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
        AddOrderItemController.Output result = AddOrderItemController.searchDataMe(order2.Id, '');
        System.Test.stopTest();
    }
}