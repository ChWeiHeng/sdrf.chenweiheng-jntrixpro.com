/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 11-20-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   11-20-2025   Gerry   Initial Version
**/
@IsTest
private class SetApprovingOrderQuantityBatchTest {
    @IsTest
    static void testMethod1() {
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

        // 创建产品库存
        Product_Inventory__c productInventory = new Product_Inventory__c();
        productInventory.Search_Key__c = 'ZAR1TestProduct-3020-ZAR1TestProductName';
        productInventory.Inventory_Quantity__c = 100;
        productInventory.Product__c = product.Id;
        productInventory.Plant__c = '5130';
        productInventory.Product_Name_Text__c = productName.Name;
        insert productInventory;

        Account acc = new Account();
        acc.Name = 'Test';
        acc.Group_Name__c = 'Test';
        Insert acc;

        Order__c order = new Order__c();
        order.Customer__c = acc.Id;
        order.Sales_Org__c = '5130';
        order.Deliver_Plant__c = '5130';
        order.Status__c = 'Approving';
        Insert order;

        Order_Item__c oi = new Order_Item__c();
        oi.Commodity__c = productName.Id;
        oi.Material_Number__c = product.Name;
        oi.Order__c = order.Id;
        oi.IsCreate__c = true;
        Insert oi;

        Database.executeBatch(New SetApprovingOrderQuantityBatch(),1);
    }
}