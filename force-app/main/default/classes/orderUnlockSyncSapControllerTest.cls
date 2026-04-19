@isTest
private class orderUnlockSyncSapControllerTest {
	static testMethod void testMethod1() {
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
        // Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        // csi.Sales_Org__c = '3010';
        // csi.Distr_Channel__c = '10';
        // csi.Sales_View_Status__c = 'Approved';
        // csi.Sync_Status__c='Synchronized';
        // csi.Customer__c = a.Id;
        // csi.Division__c = '10';
        // csi.Delivering_Plant__c = '3010';
        // //csi.Terms_Of_Payment__c = 'AR01';
        // //csi.Sales_District__c = 'ZAR00';
        // // csi.Inco_Location1__c = '11';
        // // csi.Sales_Office__c = 'AGR1';
        // // csi.Sales_Group__c = 'AG1';
        // //csi.Price_Group__c = '02';
        // //csi.Payment_method__c = 'Z1';
        // //csi.Business_Model__c = 'C0';
        // csi.Incoterms__c = '';
        // insert csi;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '5070';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c = 'Synchronized';
        csi.Customer__c = a.Id;
        csi.Acct_Assmt_Grp_Cust__c = '01';
        csi.Payment_method__c = 'YPF';
        insert csi;

        

        

       
        // Order__c order = new Order__c();
        // order.Customer__c = a.Id;
        // order.Sales_Org__c = '3010';
        // order.Distr_Channel__c = '10';
        // order.Customer_Sales_Info__c = csi.Id;
        // order.Currency__c = 'USD';  
        // order.Deliver_Plant__c = '3010';
        // order.Business_Model__c = 'B0';
        // Insert order;

        Order__c order1 = new Order__c();
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5070';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Deliver_Plant__c = '5070';
        order1.Order_type__c = 'ZAR1';
        order1.Status__c = 'Approved';
        order1.Sync_Status__c = 'Synchronized';
        order1.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
        order1.Cust_Reference__c = '12';
        insert order1;

        // Order_Item__c oi=new Order_Item__c();
        // oi.Order__c=order.Id;
        // oi.New_Price__c=10;
        // oi.New_Quantity__c=10;
        // oi.New_Amount__c=100;
        // oi.isClosed__c=false;
        // oi.New_Price__c=10;
        // oi.New_Quantity__c=10;
        // oi.New_Amount__c=100;
        // oi.isClosed__c=false;
        // oi.Product_Cost__c = 10;
        // oi.Price__c=10;
        // oi.Quantity__c=10;
        // insert oi;

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

        orderUnlockSyncSapController.Output op1 = orderUnlockSyncSapController.init(String.valueOf(order1.Id));
        orderUnlockSyncSapController.Output op2 = orderUnlockSyncSapController.updateData(String.valueOf(order1.Id), false);
        orderUnlockSyncSapController.Output op3 = orderUnlockSyncSapController.syncSap(String.valueOf(order1.Id), false, false);
		//orderUnlockSyncSapController.syncSap('',false,false);
	}

    
}