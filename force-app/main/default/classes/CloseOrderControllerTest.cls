/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-05-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   12-16-2025   Gerry   Initial Version
**/
@IsTest
private class CloseOrderControllerTest {
    static testMethod void testMock(){
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
        csi.Customer__c = a.Id;
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;
    
        Price_Book_Item__c pbi = new Price_Book_Item__c();
        pbi.Price_Book__c = pb.Id;
        pbi.Product_Name__c = pn.Id;
        pbi.Price__c = 1;
        insert pbi;
        Order__c order = new Order__c();
        order.Customer__c = a.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';
        order.Price_Book__c = pb.Id;
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZARB';
        order.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        Insert order;
        Test.startTest();
        Order_Item__c orI = new Order_Item__c();
        orI.Order__c = order.Id;
        orI.Guide_Price__c = -1;
        orI.Price__c = 4;
        orI.SAP_Total_Net__c = 1;
        orI.Commodity__c = pn.Id;
        orI.Price_Book_Item__c = pbi.Id;
        orI.Quantity__c = 1;
        orI.IsCreate__c = true;
        orI.Product_Cost__c = 10;
        orI.New_Price__c = 13;
        orI.New_Quantity__c = 13;
        orI.New_Amount__c = 13;
        orI.New_Delivery_Date__c = Date.today();
        orI.Product_Type__c = 'Normal Product';
        insert orI;
        
        Delivery_Note__c dn = new Delivery_Note__c();
        dn.Order__c = order.Id;
        dn.Order_Item__c = orI.Id;
        dn.Auto_ZARA_Issue_Quantity__c = 10;
        dn.Delivery_Quantity__c = 5;
      //   dn.Remain_Quantity__c = 0;
        dn.Delivery_Post_Date__c = Date.valueOf('2025-3-16');
      //   dn.Stock_Aging_Countdown__c = -10;
        dn.Auto_issue_Consignment__c = false;
        dn.Issue_Quantity__c = 2;
        insert dn;
        Delivery_Note__c dnn = [SELECT Delivery_Quantity__c,Order__c,Order_Item__c,Auto_ZARA_Issue_Quantity__c,Issue_Quantity__c,Delivery_Post_Date__c,Auto_issue_Consignment__c,Remain_Quantity__c 
                                 ,Order__r.Stock_Aging_Limit__c,Order_Item__r.Commodity__r.Name,Order__r.Customer__r.Email__c,Stock_Aging_Countdown__c,Order__r.Customer__r.Name FROM Delivery_Note__c WHERE Id = :dn.Id];
        System.debug('Remain_Quantity__c'+dnn.Remain_Quantity__c);
        CloseOrderController.init(orI.Id);
        CloseOrderController.closeOrder(orI.Id, '03');
        CloseOrderController.init('orI.Id');
        CloseOrderController.closeOrder('orI.Id', '03');
        Test.stopTest();
    }
}