/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-05-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-20-2025   Gerry   Initial Version
**/
@isTest
private class CloneOrderControllerTest {
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
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        Insert a;
        Customer_Shipping_Address__c csa = new Customer_Shipping_Address__c();
        csa.Customer__c = a.Id;
        csa.Direction__c = '111';

        insert csa;
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
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5130';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Price_Group__c = '02';
        // csi.Payment_method__c = 'Z1';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        csi.Acct_Assmt_Grp_Cust__c='01';
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;
        Test.startTest();
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '123';
        order1.SAP_Order_Code2__c = '123';
        order1.Cust_Reference__c = '111';
        //order1.Inco_Location1__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARB';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        order1.Customer__c = a.Id;
        Insert order1;
        order1.Status__c = 'Approved';
        update order1;

        order1.Status__c = 'Rejected';
        update order1;
        
        CloneOrderController.init(order1.Id);
        CloneOrderController.cloneOrder(order1.Id, 'ZARE');
        Test.stopTest();

    }
}