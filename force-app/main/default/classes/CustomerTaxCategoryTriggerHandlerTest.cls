@IsTest
private class CustomerTaxCategoryTriggerHandlerTest {
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
        csi.Customer__c = a.Id;
        csi.isSync__c = true;
        insert csi;
        Customer_Tax_Category__c d = new Customer_Tax_Category__c();
        d.Sales_View__c = csi.Id;
        insert d;
        d.Tax_Category_Type__c = 'J1AU';
        d.Tax_Category__c = '1-Responsable IVA';
        Update d;
    }
}