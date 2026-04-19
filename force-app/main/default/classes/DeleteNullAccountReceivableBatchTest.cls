/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 11-04-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   11-04-2025   Gerry   Initial Version
**/
@isTest
private class DeleteNullAccountReceivableBatchTest {
    static testMethod void testMethod1() {
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '5130';
        psi.Delivering_Plant__c = '5130';
        Insert psi;
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'Test';
        pn.Product_Sales_Info__c = psi.Id; 
        Insert pn;
        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;
        Product_Inventory__c pi = new Product_Inventory__c();
        pi.Search_Key__c = '12341234'+'-'+'5130'+'-'+'Test';
        pi.Inventory_Quantity__c = 1;
        pi.Product__c = p.Id;
        Insert pi;
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '123';
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
        insert csi;
        Account_Receivable__C ar = new Account_Receivable__C();
        ar.Customer_Sales_Info__c = csi.Id;
        ar.Amount_in_Local_Crcy__C = 0;
        ar.ExternalId__c = '1';
        insert ar;
        DeleteNullAccountReceivableBatch svo = new DeleteNullAccountReceivableBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 100);
        System.schedule('Test','0 35 6 * * ? *',New DeleteNullAccountReceivableBatch());
        DeleteNullInventory soib = new DeleteNullInventory(System.now());
        Database.executeBatch(soib,100);
    }
}