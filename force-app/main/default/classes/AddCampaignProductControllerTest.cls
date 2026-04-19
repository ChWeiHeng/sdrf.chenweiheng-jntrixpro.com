/**************************************************************************************************
 * Name: AddCampaignProductControllerTest
 * Object: Campaign_Product__c
 * Purpose: Test class for AddCampaignProductController
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Agentforce        2026-04-15         Created             
***************************************************************************************************/
@isTest
private class AddCampaignProductControllerTest {
    
    @testSetup
    static void setup() {
        // Create test Campaign
        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            Sales_Org__c = '5130',
            IsActive = true
        );
        insert testCampaign;
        
        // Create test Product
        Product__c testProduct = new Product__c(
            Name = 'TEST001'
        );
        insert testProduct;
        
        // Create test Product Sales Info
        Product_Sales_Info__c testProductSalesInfo = new Product_Sales_Info__c(
            Product__c = testProduct.Id,
            Sales_Organization__c = '5130',
            Status__c = 'On Shelves',
            Default_Sales_Unit__c = 'KG'
        );
        insert testProductSalesInfo;
        
        // Create test Product Name
        Product_Name__c testProductName = new Product_Name__c(
            Name = 'Test Product Name',
            Product__c = testProduct.Id,
            Product_Sales_Info__c = testProductSalesInfo.Id,
            Is_Delete__c = false
        );
        insert testProductName;
        
        // Create test Product Unit
        Product_Unit__c testProductUnit = new Product_Unit__c(
            Product__c = testProduct.Id,
            Product_Sales_Unit__c = 'KG',
            Conversion_Coefficient__c = 1
        );
        insert testProductUnit;
    }
    
    @isTest
    static void testInitData() {
        Campaign testCampaign = [SELECT Id FROM Campaign LIMIT 1];
        
        Test.startTest();
        AddCampaignProductController.Output result = AddCampaignProductController.initData(testCampaign.Id);
        Test.stopTest();
        
        System.assertEquals(true, result.isSucess, 'Should be successful');
        System.assertNotEquals(null, result.productNameList, 'Product list should not be null');
        System.assertEquals(1, result.productNameList.size(), 'Should return one product');
    }
    
    @isTest
    static void testInitDataWithExistingProducts() {
        Campaign testCampaign = [SELECT Id FROM Campaign LIMIT 1];
        Product_Name__c testProductName = [SELECT Id FROM Product_Name__c LIMIT 1];
        
        // Create existing campaign product
        Campaign_Product__c existingProduct = new Campaign_Product__c(
            Campaign__c = testCampaign.Id,
            Product_Name__c = testProductName.Id,
            Quantity__c = 5,
            Unit__c = 'KG',
            Delivery_Date__c = Date.today()
        );
        insert existingProduct;
        
        Test.startTest();
        AddCampaignProductController.Output result = AddCampaignProductController.initData(testCampaign.Id);
        Test.stopTest();
        
        System.assertEquals(true, result.isSucess, 'Should be successful');
        System.assertEquals(1, result.campaignProductList.size(), 'Should return one existing product');
    }
    
    @isTest
    static void testSearchDataMe() {
        Campaign testCampaign = [SELECT Id FROM Campaign LIMIT 1];
        
        Test.startTest();
        AddCampaignProductController.Output result = AddCampaignProductController.searchDataMe(testCampaign.Id, 'Test');
        Test.stopTest();
        
        System.assertEquals(true, result.isSucess, 'Should be successful');
        System.assertEquals(1, result.productNameList.size(), 'Should return one product');
    }
    
    @isTest
    static void testSearchDataMeEmpty() {
        Campaign testCampaign = [SELECT Id FROM Campaign LIMIT 1];
        
        Test.startTest();
        AddCampaignProductController.Output result = AddCampaignProductController.searchDataMe(testCampaign.Id, '');
        Test.stopTest();
        
        System.assertEquals(true, result.isSucess, 'Should be successful');
        System.assertEquals(1, result.productNameList.size(), 'Should return one product');
    }
    
    @isTest
    static void testSaveData() {
        Campaign testCampaign = [SELECT Id FROM Campaign LIMIT 1];
        Product_Name__c testProductName = [SELECT Id FROM Product_Name__c LIMIT 1];
        
        // Create campaign product data
        AddCampaignProductController.CampaignProduct cp = new AddCampaignProductController.CampaignProduct();
        cp.indexNum = '10';
        cp.campaignProductData = new Campaign_Product__c(
            Campaign__c = testCampaign.Id,
            Product_Name__c = testProductName.Id,
            Quantity__c = 10,
            Unit__c = 'KG',
            Delivery_Date__c = Date.today()
        );
        cp.opList = new List<AddCampaignProductController.Option>();
        
        List<AddCampaignProductController.CampaignProduct> campaignProductList = new List<AddCampaignProductController.CampaignProduct>{cp};
        List<String> deleteList = new List<String>();
        
        Test.startTest();
        AddCampaignProductController.Output result = AddCampaignProductController.saveData(campaignProductList, deleteList);
        Test.stopTest();
        
        System.assertEquals(true, result.isSucess, 'Should be successful');
        
        List<Campaign_Product__c> savedProducts = [
            SELECT Id, Quantity__c, Unit__c 
            FROM Campaign_Product__c 
            WHERE Campaign__c = :testCampaign.Id
        ];
        System.assertEquals(1, savedProducts.size(), 'Should create one campaign product');
        System.assertEquals(10, savedProducts[0].Quantity__c, 'Quantity should match');
        System.assertEquals('KG', savedProducts[0].Unit__c, 'Unit should match');
    }
    
    @isTest
    static void testSaveDataWithDelete() {
        Campaign testCampaign = [SELECT Id FROM Campaign LIMIT 1];
        Product_Name__c testProductName = [SELECT Id FROM Product_Name__c LIMIT 1];
        
        // Create existing campaign product
        Campaign_Product__c existingProduct = new Campaign_Product__c(
            Campaign__c = testCampaign.Id,
            Product_Name__c = testProductName.Id,
            Quantity__c = 5,
            Unit__c = 'KG',
            Delivery_Date__c = Date.today()
        );
        insert existingProduct;
        
        List<AddCampaignProductController.CampaignProduct> campaignProductList = new List<AddCampaignProductController.CampaignProduct>();
        List<String> deleteList = new List<String>{existingProduct.Id};
        
        Test.startTest();
        AddCampaignProductController.Output result = AddCampaignProductController.saveData(campaignProductList, deleteList);
        Test.stopTest();
        
        System.assertEquals(true, result.isSucess, 'Should be successful');
        
        List<Campaign_Product__c> remainingProducts = [
            SELECT Id 
            FROM Campaign_Product__c 
            WHERE Campaign__c = :testCampaign.Id
        ];
        System.assertEquals(0, remainingProducts.size(), 'Product should be deleted');
    }
    
    @isTest
    static void testErrorHandling() {
        Test.startTest();
        AddCampaignProductController.Output result = AddCampaignProductController.initData(null);
        Test.stopTest();
        
        System.assertEquals(false, result.isSucess, 'Should fail');
        System.assertNotEquals(null, result.errorMsg, 'Error message should be present');
    }
}