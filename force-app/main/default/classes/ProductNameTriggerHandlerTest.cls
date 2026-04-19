/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 06-12-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-12-2025   Gerry   Initial Version
**/
@isTest
private class ProductNameTriggerHandlerTest {
    static testMethod void testMethod1() {
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '5130';
        psi.Factory__c = '5130';
        Insert psi;
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        Insert a;
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Sales_Org__c = '5130';
        pb.Delivery_Plant__c = '5130';
        pb.Currency__c = 'USD';
        insert pb;
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'Test';
        pn.Product_Sales_Info__c = psi.Id; 
        Insert pn;
        pn.Customer__c = a.Id;
        update pn;
    }
}