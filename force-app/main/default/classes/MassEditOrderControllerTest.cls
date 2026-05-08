/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-08-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-08-2026   Gerry   Initial Version
**/
@isTest
public  class MassEditOrderControllerTest {
    
    @TestSetup
    static void setupTestData(){
        // Create test data in @TestSetup to avoid repeated SOQL queries
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
    }
    
    static testMethod void testMethod1(){
        // Query test data from @TestSetup
        Account a = [SELECT Id FROM Account WHERE MDG_Customer_Code__c = '111' LIMIT 1];
        Customer_Sales_Info__c csi = [SELECT Id FROM Customer_Sales_Info__c WHERE Customer__c = :a.Id LIMIT 1];
        
        // Use Test.startTest() to reset governor limits before creating Order
        Test.startTest();
        
        Order__c order1 = new Order__c();
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5070';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Deliver_Plant__c = '5070';
        order1.Order_type__c = 'ZARA';
        order1.Status__c = 'Draft';
        order1.Sync_Status__c = 'Synchronized';
        order1.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order1.Cust_Reference__c = '12';
        order1.Stock_Aging_Limit__c= '60';
        order1.Auto_Issue_Consignment__c = true;
        order1.SAP_Order__c = false;
        order1.Order_Reason__c = '101'; // Required field for ZARA orders
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

        List<Utility.returnValue> termList = new List<Utility.returnValue>();
        termList.add(new Utility.returnValue('Net30','30'));
        termList.add(new Utility.returnValue('Net60','60'));
        Utility.returnValue rv = new Utility.returnValue('Net30','30');

        List<Utility.returnValue> rvList = new List<Utility.returnValue>{ rv };
        Map<String, List<Utility.returnValue>> termMap = new Map<String, List<Utility.returnValue>>{
            '1' => rvList
        };

        MassEditOrderController.OrderData od = new MassEditOrderController.OrderData(order1, termMap, 1);
        od.order = order1;
        od.orderUrl = '/' + order1.Id;
        od.index = 1;
        od.termList = termList;
        od.isAutoCreate = true;
        od.isSelect = true;

        MassEditOrderController.initData();
        
        List<MassEditOrderController.OrderData> dataList = new List<MassEditOrderController.OrderData>();
        dataList.add(od);
        String selectListStr = JSON.serialize(dataList);
        
        // Call the main method that triggers the Order update
        Map<String, Object> result = MassEditOrderController.saveData(selectListStr);
        
        // Test.stopTest() ensures all async operations complete and resets limits
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Test cloneItem separately with a new test context
        MassEditOrderController.cloneItem(new Map<String,Order__c>{'1' => order1});
    }
}