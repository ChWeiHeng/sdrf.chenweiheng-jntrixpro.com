/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 10-15-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   09-01-2025   Gerry   Initial Version
**/
@isTest
private class RejectedOrderBatchTest {
    
    static testMethod void testMethod1() {
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '3020';
        psi.Delivering_Plant__c = '3020';
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
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Sales_Org__c = '3020';
        pb.Currency__c = 'USD';
        insert pb;

        Price_Book_Item__c pbi = new Price_Book_Item__c();
        pbi.Price_Book__c = pb.Id;
        pbi.Product_Name__c = pn.Id;
        pbi.Price__c = 1;
        
        insert pbi;
        pbi.Is_Changing__c=false;
        update pbi;
        Order__c order = new Order__c();
        order.Customer__c = a.Id;
        order.Sales_Org__c = '3020';
        order.Distr_Channel__c = '10';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = pb.Id;
        order.Deliver_Plant__c = '3020';
        Insert order;
        Order_Item__c orI = new Order_Item__c();
        orI.Order__c = order.Id;
        orI.Commodity__c = pn.Id;
        orI.Price_Book_Item__c = pbi.Id;
        ori.Unit_Price_w_o_tax__c = 1;
        orI.IsCreate__c=true;
        Insert orI;
        RejectedOrderBatch svo = new RejectedOrderBatch();
        svo.setApproveal('11','5130');

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 10);

        System.schedule('Test','0 35 6 * * ? *',New RejectedOrderBatch());
    }
}