@isTest
private class LockOrderLWCControllerTest {
	static testMethod void testMethod1() {
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
        csi.Sales_Org__c = '3020';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        insert csi;
        
        Order__c order = new Order__c();
        order.Customer__c = a.Id;
        order.Sales_Org__c = '3020';
        order.Distr_Channel__c = '10';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';
        order.Deliver_Plant__c = '3020';
        Insert order;
        test.startTest();
        LockOrderLWCController.lockOrder(order.Id);
        test.stopTest();
	 }
    
}