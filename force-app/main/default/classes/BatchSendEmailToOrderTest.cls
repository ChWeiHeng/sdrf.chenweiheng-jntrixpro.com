/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-09-2026
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   03-09-2026   Gerry   Initial Version
**/
@isTest
public class BatchSendEmailToOrderTest {
   static testMethod void testMethod1() {

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
        Test.startTest();
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
        insert dn;
        Delivery_Note__c dnn = [SELECT Delivery_Quantity__c,Order__c,Order_Item__c,Auto_ZARA_Issue_Quantity__c,Issue_Quantity__c,Delivery_Post_Date__c,Auto_issue_Consignment__c,Remain_Quantity__c,Order__r.Customer__r.Owner.Email 
                                 ,Order__r.Stock_Aging_Limit__c,Order_Item__r.Commodity__r.Name,Order__r.Customer__r.Email__c,Stock_Aging_Countdown__c,Order__r.Customer__r.Name,Order__r.Sales_Org__c FROM Delivery_Note__c WHERE Id = :dn.Id];
        System.debug('Remain_Quantity__c'+dnn.Remain_Quantity__c);

        Map<String, List<String>> proNameMap = new Map<String, List<String>>();
        proNameMap.put(String.valueOf(pn.Id), new List<String>{String.valueOf(pn.Id),'ProductName2'});
        Messaging.SingleEmailMessage email = BatchSendEmailToOrder.getOrderEmail(dnn, proNameMap);
        Utility.Table table = BatchSendEmailToOrder.getDefaultTable(new List<String>{'123'});
        
        Database.executeBatch(new BatchSendEmailToOrder(false), 1);      
        BatchSendEmailToOrder.generateZaraData(new List<Delivery_Note__c>{dnn},false);
        BatchSendEmailToOrder.getProductName(new Set<String> {String.valueOf(pn.Id)});
        Test.stopTest();
      //   BatchSendEmailToOrder.Messaging.SingleEmailMessage(dn,false);

   }
}