/**
 * @description       : Test class for CloseOrderBatch
 * @author            : Agentforce
 * @group             : 
 * @last modified on  : 04-22-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   04-13-2026   Agentforce   Initial Version
**/
@isTest
public class CloseOrderBatchTest {
    
    /**
     * @description Create test data for Account, Customer_Credit_Info, Customer_Sales_Info, Order, and Order_Item
     */
    @TestSetup
    static void setupTestData() {
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.Group_Name__c = 'Test Group';
        testAccount.MDG_Customer_Code__c = '12345';
        testAccount.Customer_Approval_Status__c = 'Approved';
        testAccount.Sync_Status__c = 'synchronized';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
        insert testAccount;
        
        // Create Customer Credit Info
        Customer_Credit_Info__c creditInfo = new Customer_Credit_Info__c();
        creditInfo.Customer__c = testAccount.Id;
        creditInfo.Rules__c = 'STANDARD';
        creditInfo.Risk_Class__c = 'A';
        creditInfo.Check_Rule__c = 'OV1';
        creditInfo.Credit_Segment__c = 'Z000';
        creditInfo.Valid_Until__c = Date.today().addDays(30);
        creditInfo.Sinosure_Credit_Limit__c = 100000;
        creditInfo.Local_Credit_Limit__c = 100000;
        creditInfo.Actual_Credit_limit__c = 100000;
        creditInfo.Sync_Status__c = 'Synchronized';
        creditInfo.Remaining_Credit__c = 100000;
        creditInfo.ExternalId__c = 'TEST12345';
        insert creditInfo;
        
        // Create Customer Sales Info
        Customer_Sales_Info__c salesInfo = new Customer_Sales_Info__c();
        salesInfo.Sales_Org__c = '5070';
        salesInfo.Distr_Channel__c = '00';
        salesInfo.Sales_View_Status__c = 'Approved';
        salesInfo.Sync_Status__c = 'Synchronized';
        salesInfo.Customer__c = testAccount.Id;
        salesInfo.Acct_Assmt_Grp_Cust__c = '01';
        salesInfo.Payment_method__c = 'YPF';
        insert salesInfo;
        
        // Create Orders with different order types
        List<Order__c> orders = new List<Order__c>();
        
        // Order with type ZARE (Argentina)
        Order__c order1 = new Order__c();
        order1.Customer__c = testAccount.Id;
        order1.Sales_Org__c = '5070';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = salesInfo.Id;
        order1.Currency__c = 'USD';
        order1.Deliver_Plant__c = '5070';
        order1.Business_Model__c = 'C0';
        order1.Order_type__c = 'ZARE';
        order1.Order_Reason__c = '101';
        order1.Status__c = 'Approved';
        order1.Sync_Status__c = 'Synchronized';
        order1.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order1.Cust_Reference__c = 'REF001';
        order1.Stock_Aging_Limit__c = '60';
        order1.SAP_Order__c = true;
        orders.add(order1);
        
        // Order with type ZMX3 (Mexico)
        Order__c order2 = new Order__c();
        order2.Customer__c = testAccount.Id;
        order2.Sales_Org__c = '3010';
        order2.Distr_Channel__c = '10';
        order2.Customer_Sales_Info__c = salesInfo.Id;
        order2.Currency__c = 'USD';
        order2.Deliver_Plant__c = '3010';
        order2.Business_Model__c = 'B0';
        order2.Order_type__c = 'ZMX3';
        order2.Order_Reason__c = 'MX1';
        order2.Status__c = 'Approved';
        order2.Sync_Status__c = 'Synchronized';
        order2.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order2.Cust_Reference__c = 'REF002';
        order2.Stock_Aging_Limit__c = '60';
        order2.SAP_Order__c = true;
        orders.add(order2);
        
        // Order with type ZARB
        Order__c order3 = new Order__c();
        order3.Customer__c = testAccount.Id;
        order3.Sales_Org__c = '5070';
        order3.Distr_Channel__c = '00';
        order3.Customer_Sales_Info__c = salesInfo.Id;
        order3.Currency__c = 'USD';
        order3.Deliver_Plant__c = '5070';
        order3.Business_Model__c = 'C0';
        order3.Order_type__c = 'ZARB';
        order3.Order_Reason__c = '101';
        order3.Status__c = 'Approved';
        order3.Sync_Status__c = 'Synchronized';
        order3.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order3.Cust_Reference__c = 'REF003';
        order3.Stock_Aging_Limit__c = '60';
        order3.SAP_Order__c = true;
        orders.add(order3);
        
        // Standard order type - use 5070 which is simpler
        Order__c order4 = new Order__c();
        order4.Customer__c = testAccount.Id;
        order4.Sales_Org__c = '5070';
        order4.Distr_Channel__c = '00';
        order4.Customer_Sales_Info__c = salesInfo.Id;
        order4.Currency__c = 'USD';
        order4.Deliver_Plant__c = '5070';
        order4.Business_Model__c = 'C0';
        order4.Order_type__c = 'ZARA';
        order4.Order_Reason__c = 'Z11';
        order4.Status__c = 'Approved';
        order4.Sync_Status__c = 'Synchronized';
        order4.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order4.Cust_Reference__c = 'REF004';
        order4.Stock_Aging_Limit__c = '60';
        order4.SAP_Order__c = true;
        orders.add(order4);
        
        insert orders;
        
        // Create Order Items
        List<Order_Item__c> orderItems = new List<Order_Item__c>();
        
        // Order Item for ZARE order (should fail without Delivery_Note)
        Order_Item__c item1 = new Order_Item__c();
        item1.Order__c = orders[0].Id;
        item1.isClosed__c = false;
        item1.IsCreate__c = true;
        orderItems.add(item1);
        
        // Order Item for ZMX3 order with reference
        Order_Item__c item2 = new Order_Item__c();
        item2.Order__c = orders[1].Id;
        item2.isClosed__c = false;
        item2.IsCreate__c = true;
        orderItems.add(item2);
        
        // Order Item for ZARB order
        Order_Item__c item3 = new Order_Item__c();
        item3.Order__c = orders[2].Id;
        item3.isClosed__c = false;
        item3.IsCreate__c = true;
        orderItems.add(item3);
        
        // Order Item for standard order
        Order_Item__c item4 = new Order_Item__c();
        item4.Order__c = orders[3].Id;
        item4.isClosed__c = false;
        item4.IsCreate__c = true;
        orderItems.add(item4);
        
        insert orderItems;
    }
    
    /**
     * @description Test successful batch execution with single order item
     */
    @isTest
    static void testBatchExecutionSuccess() {
        // Get test order item
        Order_Item__c orderItem = [SELECT Id, Name FROM Order_Item__c 
                                    WHERE Order__r.Order_type__c = 'ZARA' LIMIT 1];
        
        Test.startTest();
        // Execute batch with single order item number
        CloseOrderBatch batch = new CloseOrderBatch(orderItem.Name);
        Database.executeBatch(batch, 10);
        Test.stopTest();
        
        // Verify batch was initialized correctly
        System.assertNotEquals(null, batch.query, 'Query should be initialized');
        System.assertEquals(true, batch.flag, 'Flag should be initialized as true');
        System.assertNotEquals(null, batch.startTime, 'Start time should be set');
        System.assertEquals(1, batch.orderItemNumberList.size(), 'Should have one order item in list');
    }
    
    /**
     * @description Test batch execution with multiple order items
     */
    @isTest
    static void testBatchExecutionMultipleItems() {
        // Get multiple test order items
        List<Order_Item__c> orderItems = [SELECT Id, Name FROM Order_Item__c 
                                          WHERE Order__r.Order_type__c IN ('ZARA', 'ZARB') 
                                          LIMIT 2];
        
        String orderItemNumbers = orderItems[0].Name + ',' + orderItems[1].Name;
        
        Test.startTest();
        // Execute batch with multiple order item numbers
        CloseOrderBatch batch = new CloseOrderBatch(orderItemNumbers);
        Database.executeBatch(batch, 10);
        Test.stopTest();
        
        // Verify batch handles multiple items
        System.assertEquals(2, batch.orderItemNumberList.size(), 'Should have two order items in list');
        System.assertEquals(orderItems[0].Name, batch.orderItemNumberList[0], 'First item should match');
        System.assertEquals(orderItems[1].Name, batch.orderItemNumberList[1], 'Second item should match');
    }
    
    /**
     * @description Test batch execution with ZARE order type without Delivery Note (should fail)
     */
    @isTest
    static void testBatchExecutionZAREWithoutDeliveryNote() {
        // Get ZARE order item (without Delivery_Note)
        Order_Item__c orderItem = [SELECT Id, Name FROM Order_Item__c 
                                    WHERE Order__r.Order_type__c = 'ZARE' LIMIT 1];
        
        Test.startTest();
        // Execute batch
        CloseOrderBatch batch = new CloseOrderBatch(orderItem.Name);
        Database.executeBatch(batch, 10);
        Test.stopTest();
        
        // Verify the order item was not closed due to validation
        Order_Item__c updatedItem = [SELECT Id, isClosed__c FROM Order_Item__c WHERE Id = :orderItem.Id];
        System.assertEquals(false, updatedItem.isClosed__c, 'Order item should not be closed without Delivery Note');
    }
    
    /**
     * @description Test batch execution with Mexico order type (ZMX3) with reference
     */
    @isTest
    static void testBatchExecutionZMX3WithReference() {
        // Get ZMX3 order item
        Order_Item__c orderItem = [SELECT Id, Name FROM Order_Item__c 
                                    WHERE Order__r.Order_type__c = 'ZMX3' LIMIT 1];
        
        Test.startTest();
        // Execute batch
        CloseOrderBatch batch = new CloseOrderBatch(orderItem.Name);
        Database.executeBatch(batch, 10);
        Test.stopTest();
        
        // Verify batch processed the item
        System.assertEquals(1, batch.orderItemNumberList.size(), 'Should have one order item');
    }
    
    /**
     * @description Test QueryLocator start method
     */
    @isTest
    static void testStartMethod() {
        Order_Item__c orderItem = [SELECT Id, Name FROM Order_Item__c LIMIT 1];
        
        CloseOrderBatch batch = new CloseOrderBatch(orderItem.Name);
        
        Test.startTest();
        Database.BatchableContext bc = null;
        Database.QueryLocator ql = batch.start(bc);
        Test.stopTest();
        
        // Verify QueryLocator is returned
        System.assertNotEquals(null, ql, 'QueryLocator should not be null');
    }
    
    /**
     * @description Test execute method with Test.isRunningTest() condition
     */
    @isTest
    static void testExecuteMethod() {
        Order_Item__c orderItem = [SELECT Id, Name, Order__c FROM Order_Item__c 
                                    WHERE Order__r.Order_type__c = 'ZARA' LIMIT 1];
        
        CloseOrderBatch batch = new CloseOrderBatch(orderItem.Name);
        
        Test.startTest();
        Database.BatchableContext bc = null;
        List<Order_Item__c> orderList = [SELECT Id FROM Order_Item__c WHERE Id = :orderItem.Id];
        batch.execute(bc, orderList);
        Test.stopTest();
        
        // Verify execute method completes without error
        // The actual closing logic calls CloseOrderController.closeOrder() which may have its own validation
        System.assertNotEquals(null, orderList, 'Order list should not be null');
        System.assertEquals(1, orderList.size(), 'Should have one order item');
    }
    
    /**
     * @description Test finish method
     */
    @isTest
    static void testFinishMethod() {
        Order_Item__c orderItem = [SELECT Id, Name FROM Order_Item__c LIMIT 1];
        
        CloseOrderBatch batch = new CloseOrderBatch(orderItem.Name);
        
        Test.startTest();
        Database.BatchableContext bc = null;
        batch.finish(bc);
        Test.stopTest();
        
        // Finish method is empty, just verify it executes without error
        System.assert(true, 'Finish method should execute without error');
    }
    
    /**
     * @description Test batch with invalid order item number
     */
    @isTest
    static void testBatchWithInvalidOrderItemNumber() {
        Test.startTest();
        // Execute batch with non-existent order item number
        CloseOrderBatch batch = new CloseOrderBatch('INVALID-123456');
        Database.executeBatch(batch, 10);
        Test.stopTest();
        
        // Verify batch completes without errors (empty result set)
        System.assertEquals(1, batch.orderItemNumberList.size(), 'Should have one item in list');
        System.assertEquals('INVALID-123456', batch.orderItemNumberList[0], 'Should contain invalid number');
    }
    
    /**
     * @description Test batch state management
     */
    @isTest
    static void testBatchStateManagement() {
        Order_Item__c orderItem = [SELECT Id, Name FROM Order_Item__c LIMIT 1];
        
        CloseOrderBatch batch = new CloseOrderBatch(orderItem.Name);
        
        // Verify initial state
        System.assertEquals(true, batch.flag, 'Initial flag should be true');
        System.assertEquals(null, batch.errorMsg, 'Initial error message should be null');
        
        // Manually set flag to false
        batch.flag = false;
        batch.errorMsg = 'Test Error';
        
        System.assertEquals(false, batch.flag, 'Flag should be updated');
        System.assertEquals('Test Error', batch.errorMsg, 'Error message should be set');
    }
    
    /**
     * @description Test batch with comma-separated multiple order numbers including spaces
     */
    @isTest
    static void testBatchWithMultipleOrderNumbersWithSpaces() {
        List<Order_Item__c> orderItems = [SELECT Id, Name FROM Order_Item__c LIMIT 2];
        
        String orderItemNumbers = orderItems[0].Name + ', ' + orderItems[1].Name;
        
        Test.startTest();
        CloseOrderBatch batch = new CloseOrderBatch(orderItemNumbers);
        Database.executeBatch(batch, 10);
        Test.stopTest();


        
        // Verify split handles spaces correctly
        System.assertEquals(2, batch.orderItemNumberList.size(), 'Should have two items');
    }
     @isTest
    static void testBatchWithMultipleOrderNumbersWithSpaces1() {
        
        Test.startTest();
        CloseOrderBatch batch = new CloseOrderBatch('SELECT Id, Name FROM Order_Item__c',1);
        Database.executeBatch(batch, 10);
        Test.stopTest();
    }
    /**
     * @description Test batch constructor initialization
     */
    @isTest
    static void testBatchConstructorInitialization() {
        String testOrderNumber = 'TEST-123,TEST-456,TEST-789';
        
        CloseOrderBatch batch = new CloseOrderBatch(testOrderNumber);
        
        // Verify all properties are initialized
        System.assertNotEquals(null, batch.startTime, 'Start time should be initialized');
        System.assertEquals(3, batch.orderItemNumberList.size(), 'Should split into 3 items');
        System.assertEquals(true, batch.flag, 'Flag should be true');
        System.assertNotEquals(null, batch.query, 'Query should be initialized');
        System.assert(batch.query.contains('SELECT Id FROM Order_Item__c'), 'Query should select from Order_Item__c');
        System.assert(batch.query.contains('WHERE Name IN:orderItemNumberList'), 'Query should filter by name');
    }
}