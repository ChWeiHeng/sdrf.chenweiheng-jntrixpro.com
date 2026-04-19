/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 09-23-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   09-23-2025   Gerry   Initial Version
**/
@isTest
private class EmailInventoryBatchTest {
    static testMethod void testMethod1() {
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
        customerSalesInfo.Sales_Org__c = '5130';
        // customerSalesInfo.Distr_Channel__c = '10';
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

        Delivery_Note__c dn = new Delivery_Note__c();
        dn.Order__c = order.Id;
        dn.Auto_ZARA_Issue_Quantity__c = 10;
        dn.Delivery_Quantity__c = 5;
      //   dn.Remain_Quantity__c = 0;
        dn.Delivery_Post_Date__c = Date.valueOf('2025-3-16');
      //   dn.Stock_Aging_Countdown__c = -10;
        dn.Auto_issue_Consignment__c = false;
        dn.Delivery_Post_Status__c = 'C';
        dn.Issue_Quantity__c = 2;
        insert dn;

        EmailInventoryBatch svo = new EmailInventoryBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 5);
    }
}