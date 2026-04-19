/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 09-05-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-18-2025   Gerry   Initial Version
**/
@isTest
private class OrderItemLWCControllerTest {
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
        // csi.Division__c = '10';
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
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Sales_Org__c = '5130';
        pb.Name = '111';
        pb.Currency__c = 'USD';
        insert pb;
        Price_Book_Item__c pbi = new Price_Book_Item__c();
        pbi.Price_Book__c = pb.Id;
        pbi.Product_Name__c = pn.Id;
        pbi.Price__c = 1;
        insert pbi;
    
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
        order1.Order_type__c = 'ZAR1';
        order1.Customer_Shipping_Address__c = csa.Id;
        order1.Req_Deliv_Date__c = Date.today();
        order1.Customer__c = a.Id;
        order1.Max_Overdue_Days__c = 0;
        order1.Customer_Credit_Line__c = 1;
        order1.Rate__c = 1;
        order1.Actual_available_Credit_Limit__c = 1;
        Insert order1;
        Order_Item__c orI = new Order_Item__c();
        orI.Order__c = order1.Id;
        orI.Commodity__c = pn.Id;
        orI.Price_Book_Item__c = pbi.Id;
        orI.Guide_Price__c  =1;
        orI.Amount_per_item__c = 1;
        orI.IsCreate__c = true;
        orI.Quantity__c = 1;
        orI.Price__c = 1;
        orI.Delivery_Quantity__c = 1;
        Insert orI;
        System.debug([SELECT Id,Margin_Rate__c,Amount_Rate__c,Total_Margin__c,Payment_Term_Longer__c,Ultra_Credit__c,Over_Credit_Line_Percent__c,Customer_Credit_Line__c,Exceeded_Credit_Limit_USD__c,Order_Amount_USD__c ,Actual_available_Credit_Limit__c,Max_Overdue_Days__c FROM Order__c WHERE Id =:order1.Id]);
        Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
        psr.objectId = order1.Id;//对象Id
        psr.setSubmitterId(UserInfo.getUserId());//提交人
        psr.comments = '111';//备注
        // Approval.ProcessResult result = Approval.process(psr);
        // ProcessInstanceWorkitem pi1 = [SELECT Id,ProcessInstance.TargetObjectId FROm ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId=:order1.Id];
        OrderItemLWCController.init('');
    }
//     @isTest
// static void testMethodNonOrderObject() {
    // Profile prof = [SELECT Id FROM Profile WHERE Name like '%Sales Rep%'  LIMIT 1]; 
    // // 创建 Account 记录
    // Account a = new Account();
    // a.Name = 'Test';
    // a.Group_Name__c = 'test';
    // a.MDG_Customer_Code__c = '111';
    // a.Customer_Approval_Status__c = 'Approved';
    // a.Sync_Status__c = 'Synchronized';
    // insert a;
    // User u = new User();
    // u.LastName = 'test';
    // u.Username = 'testuserbisfc@testorg.com';
    // u.Alias = 'newUser';
    // u.Email='testuserbisfc@testorg.com';
    // u.EmailEncodingKey='UTF-8';
    // u.LanguageLocaleKey='en_US';
    // u.LocaleSidKey='en_US';
    // u.ProfileId = prof.Id;
    // u.TimeZoneSidKey='America/Los_Angeles';
    // User currentUser = [SELECT Id,Sales_Org__c,Delivery_Plant__c FROM User WHERE id=:System.UserInfo.getUserId()];
    // u.Sales_Org__c = currentUser.Sales_Org__c;
    // u.Delivery_Plant__c = currentUser.Delivery_Plant__c;
    // insert u;
    // Product__c p = new Product__c();
    // p.Name = '12341234';
    // p.External_Id__c = '12341234';
    // insert p;
    // Product_Sales_Info__c psi = new Product_Sales_Info__c();
    // psi.Product__c = p.Id;
    // psi.Status__c = 'On Shelves';
    // psi.Sales_Organization__c = '5130';
    // psi.Delivering_Plant__c = '5130';
    // Insert psi;
    // Product_Name__c pn = new Product_Name__c();
    // pn.Name = 'Test';
    // pn.Product_Sales_Info__c = psi.Id; 
    // Insert pn;
    // Product_Unit__c pu = new Product_Unit__c();
    // pu.Basic_Unit__c = 'L';
    // pu.Product_Sales_Unit__c = 'L';
    // pu.Conversion_Coefficient__c = 1;
    // pu.Product__c = p.Id;
    // insert pu;
    // Product_Inventory__c pi = new Product_Inventory__c();
    // pi.Search_Key__c = '12341234'+'-'+'5130'+'-'+'Test';
    // pi.Inventory_Quantity__c = 1;
    // pi.Product__c = p.Id;
    // Insert pi;
    // // Account a = new Account();
    // // a.Name = 'Test';
    // // a.Group_Name__c = 'test';
    // // a.MDG_Customer_Code__c = '111';
    // // a.Customer_Approval_Status__c = 'Approved';
    // // a.Sync_Status__c = 'Synchronized';
    // // Insert a;
    // Customer_Shipping_Address__c csa = new Customer_Shipping_Address__c();
    // csa.Customer__c = a.Id;
    // csa.Direction__c = '111';

    // insert csa;
    // Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
    // cci.Customer__c = a.Id;
    // cci.Rules__c = 'STANDARD';
    // cci.Risk_Class__c = 'A';
    // cci.Check_Rule__c = 'OV1';
    // cci.Credit_Segment__c = 'Z000';
    // cci.Valid_Until__c = Date.today();
    // cci.Sinosure_Credit_Limit__c = 2;
    // cci.Local_Credit_Limit__c = 2;
    // cci.Actual_Credit_limit__c = 2;
    // cci.Sync_Status__c = 'Synchronized';
    // cci.Remaining_Credit__c = 2;
    // cci.ExternalId__c = '1111';
    // insert cci;
    // Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
    // csi.Sales_Org__c = '5130';
    // csi.Distr_Channel__c = '00';
    // csi.Sales_View_Status__c = 'Approved';
    // csi.Sync_Status__c='Synchronized';
    // csi.Customer__c = a.Id;
    // csi.Division__c = '10';
    // csi.Delivering_Plant__c = '5130';
    // csi.Terms_Of_Payment__c = 'AR01';
    // csi.Sales_District__c = 'ZAR00';
    // // csi.Inco_Location1__c = '11';
    // // csi.Sales_Office__c = 'AGR1';
    // // csi.Sales_Group__c = 'AG1';
    // csi.Price_Group__c = '02';
    // // csi.Payment_method__c = 'Z1';
    // csi.Business_Model__c = 'C0';
    // csi.Incoterms__c = '';
    // insert csi;
    // Price_Book__c pb = new Price_Book__c();
    // pb.Sales_Org__c = '5130';
    // pb.Name = '111';
    // pb.Currency__c = 'USD';
    // insert pb;
    // Price_Book_Item__c pbi = new Price_Book_Item__c();
    // pbi.Price_Book__c = pb.Id;
    // pbi.Product_Name__c = pn.Id;
    // pbi.Price__c = 1;
    // insert pbi;
    // Invoice__c inv = new Invoice__c();
    //     inv.External_Id__c = '1';
    //     Insert inv;
    // Order__c order1 = new Order__c();
    // order1.SAP_Order_Code__c = '123';
    // order1.SAP_Order_Code2__c = '123';
    // order1.Cust_Reference__c = '111';
    // //order1.Inco_Location1__c = '11';
    // order1.Customer__c = a.Id;
    // order1.Sales_Org__c = '5070';
    // order1.Distr_Channel__c = '00';
    // order1.Customer_Sales_Info__c = csi.Id;
    // order1.Currency__c = 'USD';
    // order1.Price_Book__c = pb.Id;
    // order1.Deliver_Plant__c = '5070';
    // order1.Order_type__c = 'ZAR2';
    // order1.Customer_Shipping_Address__c = csa.Id;
    // order1.Req_Deliv_Date__c = Date.today();
    // order1.Customer__c = a.Id;
    // order1.Max_Overdue_Days__c = 0;
    // order1.Customer_Credit_Line__c = 1;
    // order1.Rate__c = 1;
    // order1.Invoice__c = inv.Id;
    // order1.Order_Reason__c = '001';
    // order1.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_B').getRecordTypeId();
    // order1.Actual_available_Credit_Limit__c = 1;
    // Insert order1;
    // Campaign cam = new Campaign();
    // cam.Date__c=date.today();
    // cam.OwnerId=u.Id;
    // cam.Approval_Status__c = 'Draft';
    // cam.Delivery_Plant__c = '5130';
    // cam.Name='test';
    // cam.recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Offline_Campaign').getRecordTypeId();
    // insert cam;
//     Account a = new Account();
//     a.Name = 'Test';
//     a.Group_Name__c = 'test';
//     a.MDG_Customer_Code__c = '111';
//     a.Customer_Approval_Status__c = 'Approved';
//     a.Sync_Status__c = 'Synchronized';
//     insert a;
//     Customer_Sales_Info__c csi2 = new Customer_Sales_Info__c();
//     csi2.Sales_Org__c = '5130';
//     csi2.Distr_Channel__c = '00';
//     csi2.Delivering_Plant__c = '5130';
//     csi2.Sales_View_Status__c = 'Draft';
//     csi2.Customer__c = a.Id;
//     csi2.Acct_Assmt_Grp_Cust__c='01';
//     insert csi2;

//     Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
//     psr.objectId = csi2.Id;//对象Id
//     psr.setSubmitterId(UserInfo.getUserId());//提交人
//     psr.comments = '111';//备注
//     Approval.ProcessResult result = Approval.process(psr);
//     ProcessInstanceWorkitem pi1 = [SELECT Id,ProcessInstance.TargetObjectId FROm ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId=:csi2.Id];
//     OrderItemLWCController.init(pi1.Id);
// }
}