@isTest
public  class BatchOrderSyncToSapTest {
    static testMethod void test1(){
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

        BatchOrderSyncToSap.BatchData bd = new BatchOrderSyncToSap.BatchData(
            order1.Id,
            '1',
            true,
            true,
            'Test Reason',
            true,
            '1'
        );

        List<BatchOrderSyncToSap.BatchData> dataList = new List<BatchOrderSyncToSap.BatchData>{ bd };
        String dataJsonStr = JSON.serialize(dataList);

        Test.startTest();
        Database.executeBatch(new BatchOrderSyncToSap(dataJsonStr), 1);
        Test.stopTest();
        
    }
}