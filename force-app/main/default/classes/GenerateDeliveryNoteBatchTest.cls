/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 02-04-2026
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   02-04-2026   Gerry   Initial Version
**/
@isTest
private class GenerateDeliveryNoteBatchTest {
    static testMethod void testMethod1() {
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'synchronized';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId();
        a.Email__c = '333@emali.com';
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
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c = 'Synchronized';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Payment_method__c = 'YPF';
        insert csi;

        Order__c order1 = new Order__c();
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Deliver_Plant__c = '5130';
        order1.Order_type__c = 'ZARE';
        order1.Status__c = 'Approved';
        order1.Sync_Status__c = 'Synchronized';
        order1.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order1.Cust_Reference__c = '12';
        order1.Stock_Aging_Limit__c= '60';
        order1.SAP_Order__c = true;
        insert order1;
        Order__c order2 = new Order__c();
        order2.Customer__c = a.Id;
        order2.Sales_Org__c = '5130';
        order2.Distr_Channel__c = '00';
        order2.Customer_Sales_Info__c = csi.Id;
        order2.Currency__c = 'USD';
        order2.Deliver_Plant__c = '5130';
        order2.Order_type__c = 'ZARF';
        order2.Status__c = 'Approved';
        order2.Sync_Status__c = 'Synchronized';
        order2.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order2.Cust_Reference__c = '12';
        order2.Stock_Aging_Limit__c= '60';
        order2.SAP_Order__c = true;
        order2.Order_Reason__c = '001';
        insert order2;
        System.Test.startTest();
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


        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Distr_Channel__c = '00';
        insert psi;

        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;

        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'Test Combo';
        pn.Product_Sales_Info__c = psi.Id;
        pn.Product__c = p.Id;
        pn.Product_Combo__c = TRUE;
        insert pn;

        Product_Name__c pn2 = new Product_Name__c();
        pn2.Name = 'Test Combo2';
        pn2.Product_Sales_Info__c = psi.Id;
        pn2.Product__c = p.Id;
        pn2.Product_Combo__c = false;
        insert pn2;

        orI1.Commodity__c = pn.Id;
        update orI1;

        Product_Name_Item__c pci = new Product_Name_Item__c();
        pci.Product_Combo_Name__c = pn.Id;
        pci.Product_Name__c = pn2.Id; 
        insert pci;

        Delivery_Note__c dn = new Delivery_Note__c();
        dn.Order__c = order1.Id;
        dn.Order_Item__c = orI1.Id;
        dn.Auto_ZARA_Issue_Quantity__c = 10;
        dn.Delivery_Quantity__c = 5;
      //   dn.Remain_Quantity__c = 0;
        dn.Delivery_Post_Date__c = Date.valueOf('2025-3-16');
      //   dn.Stock_Aging_Countdown__c = -10;
        dn.Auto_issue_Consignment__c = false;
        dn.Issue_Quantity__c = 2;
        dn.Delivery_Post_Status__c = 'C';
        insert dn;
        GenerateDeliveryNoteBatch svo = new GenerateDeliveryNoteBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 100);
    }
}