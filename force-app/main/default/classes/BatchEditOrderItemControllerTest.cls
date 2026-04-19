/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 04-13-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-13-2026   Gerry   Initial Version
**/
@isTest
private class BatchEditOrderItemControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        // Create test Order
        Order__c testOrder = new Order__c(
            Customer__c = testAccount.Id,
            Pricing_Date__c = Date.today()
        );
        insert testOrder;
        
        // Create test Product
        Product__c testProduct = new Product__c(
            Name = 'Test Product'
        );
        insert testProduct;
        
        // Create test Product Unit
        Product_Unit__c testUnit = new Product_Unit__c();
        insert testUnit;
        
        // Create test Order Items
        List<Order_Item__c> orderItems = new List<Order_Item__c>();
        for (Integer i = 0; i < 5; i++) {
            orderItems.add(new Order_Item__c(
                Order__c = testOrder.Id,
                Product__c = testProduct.Id,
                Sales_Unit__c = testUnit.Id,
                Quantity__c = 10 + i,
                Price__c = 100.00 + (i * 10)
            ));
        }
        insert orderItems;
    }
    
    @isTest
    static void testGetOrderItems() {
        // Get test Order
        Order__c testOrder = [SELECT Id FROM Order__c LIMIT 1];
        
        Test.startTest();
        List<Order_Item__c> items = BatchEditOrderItemController.getOrderItems(testOrder.Id);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(5, items.size(), 'Should return 5 order items');
        System.assertNotEquals(null, items[0].Product__c, 'Product should not be null');
        System.assertNotEquals(null, items[0].Sales_Unit__c, 'Sales Unit should not be null');
    }
    
    @isTest
    static void testGetOrderItemsWithInvalidId() {
        Test.startTest();
        try {
            List<Order_Item__c> items = BatchEditOrderItemController.getOrderItems(null);
            System.assert(false, 'Should throw exception for null order ID');
        } catch (Exception e) {
            System.assert(true, 'Exception expected for null order ID');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSearchProducts() {
        Test.startTest();
        List<Product__c> products = BatchEditOrderItemController.searchProducts('Test');
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, products.size(), 'Should return 1 product');
        System.assertEquals('Test Product', products[0].Name, 'Product name should match');
    }
    
    @isTest
    static void testSearchProductsNoResults() {
        Test.startTest();
        List<Product__c> products = BatchEditOrderItemController.searchProducts('NonExistent');
        Test.stopTest();
        
        // Verify results
        System.assertEquals(0, products.size(), 'Should return no products');
    }
    
    @isTest
    static void testSearchProductUnits() {
        Test.startTest();
        List<Product_Unit__c> units = BatchEditOrderItemController.searchProductUnits('Test');
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, units.size(), 'Should return 1 unit');
        System.assertEquals('Test Unit', units[0].Name, 'Unit name should match');
    }
    
    @isTest
    static void testSaveOrderItems() {
        // Get test Order Items
        List<Order_Item__c> items = [SELECT Id, Quantity__c, Price__c FROM Order_Item__c LIMIT 3];
        
        // Modify the items
        for (Order_Item__c item : items) {
            item.Quantity__c = 50;
            item.Price__c = 200.00;
        }
        
        Test.startTest();
        String result = BatchEditOrderItemController.saveOrderItems(items);
        Test.stopTest();
        
        // Verify results
        System.assert(result.contains('Successfully'), 'Should return success message');
        System.assert(result.contains('3'), 'Should mention 3 items saved');
        
        // Verify database changes
        List<Order_Item__c> updatedItems = [
            SELECT Id, Quantity__c, Price__c, Total_Price__c 
            FROM Order_Item__c 
            WHERE Id IN :items
        ];
        
        for (Order_Item__c item : updatedItems) {
            System.assertEquals(50, item.Quantity__c, 'Quantity should be updated to 50');
            System.assertEquals(200.00, item.Price__c, 'Price should be updated to 200.00');
            System.assertEquals(10000.00, item.Total_Price__c, 'Total Price should be calculated as 10000.00');
        }
    }
    
    @isTest
    static void testSaveOrderItemsWithEmptyList() {
        Test.startTest();
        try {
            String result = BatchEditOrderItemController.saveOrderItems(new List<Order_Item__c>());
            System.assert(false, 'Should throw exception for empty list');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('No order items'), 'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSaveOrderItemsWithNull() {
        Test.startTest();
        try {
            String result = BatchEditOrderItemController.saveOrderItems(null);
            System.assert(false, 'Should throw exception for null list');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('No order items'), 'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSaveOrderItemsCalculatesTotalPrice() {
        // Get test Order Item
        Order_Item__c item = [SELECT Id, Quantity__c, Price__c FROM Order_Item__c LIMIT 1];
        
        // Set quantity and price
        item.Quantity__c = 25;
        item.Price__c = 50.50;
        
        Test.startTest();
        String result = BatchEditOrderItemController.saveOrderItems(new List<Order_Item__c>{ item });
        Test.stopTest();
        
        // Verify Total_Price__c is calculated correctly
        Order_Item__c updatedItem = [
            SELECT Id, Quantity__c, Price__c, Total_Price__c 
            FROM Order_Item__c 
            WHERE Id = :item.Id
        ];
        
        System.assertEquals(1262.50, updatedItem.Total_Price__c, 'Total Price should be 25 * 50.50 = 1262.50');
    }
}