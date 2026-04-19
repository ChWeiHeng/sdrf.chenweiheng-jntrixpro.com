@IsTest
private class  CustomerSalesInfoSyncToSAPControllerTest {
    static testMethod void testMock(){
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        Insert a;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Acct_Assmt_Grp_Cust__c='01';
        csi.Customer__c = a.Id;
        insert csi;
        CustomerSalesInfoSyncToSAPController.confirmSync(a.Id);
        CustomerSalesInfoSyncToSAPController.init(a.Id);
        CustomerSalesInfoSyncToSAPController.confirmSync('');
    }
}