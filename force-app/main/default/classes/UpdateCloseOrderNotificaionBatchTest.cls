@isTest
private class UpdateCloseOrderNotificaionBatchTest {
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
        
        Customer_Sales_Info__c csi1 = new Customer_Sales_Info__c();
        csi1.Sales_Org__c = '5070';
        csi1.Distr_Channel__c = '00';
        csi1.Sales_View_Status__c = 'Approved';
        csi1.Sync_Status__c='Synchronized';
        csi1.Customer__c = a.Id;
        insert csi1;
        
        Customer_Sales_Info__c csi2 = new Customer_Sales_Info__c();
        csi2.Sales_Org__c = '3010';
        csi2.Distr_Channel__c = '10';
        csi2.Sales_View_Status__c = 'Approved';
        csi2.Sync_Status__c='Synchronized';
        csi2.Customer__c = a.Id;
        insert csi2;
        
        
        Customer_Sales_Info__c csi3 = new Customer_Sales_Info__c();
        csi3.Sales_Org__c = '5130';
        csi3.Distr_Channel__c = '00';
        csi3.Sales_View_Status__c = 'Approved';
        csi3.Sync_Status__c='Synchronized';
        csi3.Customer__c = a.Id;
        csi3.Acct_Assmt_Grp_Cust__c = '01';
        insert csi3;
        
        Order__c order = new Order__c();
        order.Customer__c = a.Id;
        order.Sales_Org__c = '3020';
        order.Distr_Channel__c = '10';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';
        order.Deliver_Plant__c = '3020';
        order.NotificationClose__c=true;
        order.Status__c='Approved';
        order.Approve_Date__c=date.today().addDays(31);
        order.Sync_Status__c='Synchronized';
        order.SAP_Order__c=false;
        Insert order;
        Order__c order1 = new Order__c();
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Deliver_Plant__c = '5130';
        order1.NotificationClose__c=true;
        order1.Status__c='Approved';
        order1.Approve_Date__c=date.today().addDays(31);
        order1.Sync_Status__c='Synchronized';
        order1.SAP_Order__c=false;
        Insert order1;
        
        Order__c order2 = new Order__c();
        order2.Customer__c = a.Id;
        order2.Sales_Org__c = '3010';
        order2.Distr_Channel__c = '10';
        order2.Customer_Sales_Info__c = csi.Id;
        order2.Currency__c = 'USD';
        order2.Deliver_Plant__c = '3010';
        order2.NotificationClose__c=true;
        order2.Status__c='Approved';
        order2.Approve_Date__c=date.today().addDays(31);
        order2.Sync_Status__c='Synchronized';
        order2.SAP_Order__c=false;
        Insert order2;
        Order__c order3 = new Order__c();
        order3.Customer__c = a.Id;
        order3.Sales_Org__c = '5070';
        order3.Distr_Channel__c = '00';
        order3.Customer_Sales_Info__c = csi.Id;
        order3.Currency__c = 'USD';
        order3.Deliver_Plant__c = '5070';
        order3.NotificationClose__c=true;
        order3.Status__c='Approved';
        order3.Approve_Date__c=date.today().addDays(31);
        order3.Sync_Status__c='Synchronized';
        order3.SAP_Order__c=false;
        Insert order3;
        test.startTest();
        UpdateCloseOrderNotificaionBatch svo = new UpdateCloseOrderNotificaionBatch();
        Database.executeBatch(svo, 50);
        
        Datetime d = Datetime.now();
        String minute = d.minute() + 1 + '';
        String sch =  d.second() +  ' ' +   minute +    ' ' +   d.hour() +   ' ' +   d.day() +  ' ' +  d.month() +  ' ? ' + d.year();

        System.schedule(
        '定时一分钟后Test' + Datetime.now().getTime(),
        sch,
        svo
        );
        test.stopTest();
	 }
    static testMethod void testMethod2() {
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
        
        Customer_Sales_Info__c csi1 = new Customer_Sales_Info__c();
        csi1.Sales_Org__c = '5070';
        csi1.Distr_Channel__c = '00';
        csi1.Sales_View_Status__c = 'Approved';
        csi1.Sync_Status__c='Synchronized';
        csi1.Customer__c = a.Id;
        insert csi1;
        
       
        Order__c order3 = new Order__c();
        order3.Customer__c = a.Id;
        order3.Sales_Org__c = '5070';
        order3.Distr_Channel__c = '00';
        order3.Customer_Sales_Info__c = csi1.Id;
        order3.Currency__c = 'USD';
        order3.Deliver_Plant__c = '5070';
        order3.NotificationClose__c=true;
        order3.Status__c='Approved';
        order3.Approve_Date__c=date.today().addDays(31);
        order3.Sync_Status__c='Synchronized';
        order3.SAP_Order__c=false;
        Insert order3;
        test.startTest();
        UpdateCloseOrderNotificaionBatch svo = new UpdateCloseOrderNotificaionBatch();
        Database.executeBatch(svo, 50);
        
        Datetime d = Datetime.now();
        String minute = d.minute() + 1 + '';
        String sch =  d.second() +  ' ' +   minute +    ' ' +   d.hour() +   ' ' +   d.day() +  ' ' +  d.month() +  ' ? ' + d.year();

        System.schedule(
        '定时一分钟后Test' + Datetime.now().getTime(),
        sch,
        svo
        );
        test.stopTest();
	 }
    static testMethod void testMethod3() {
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
       
        
        Customer_Sales_Info__c csi2 = new Customer_Sales_Info__c();
        csi2.Sales_Org__c = '3010';
        csi2.Distr_Channel__c = '10';
        csi2.Sales_View_Status__c = 'Approved';
        csi2.Sync_Status__c='Synchronized';
        csi2.Customer__c = a.Id;
        insert csi2;
        
        
       
        
       
        Order__c order2 = new Order__c();
        order2.Customer__c = a.Id;
        order2.Sales_Org__c = '3010';
        order2.Distr_Channel__c = '10';
        order2.Customer_Sales_Info__c = csi2.Id;
        order2.Currency__c = 'USD';
        order2.Deliver_Plant__c = '3010';
        order2.NotificationClose__c=true;
        order2.Status__c='Approved';
        order2.Approve_Date__c=date.today().addDays(31);
        order2.Sync_Status__c='Synchronized';
        order2.SAP_Order__c=false;
        Insert order2;
       
        test.startTest();
        UpdateCloseOrderNotificaionBatch svo = new UpdateCloseOrderNotificaionBatch();
        Database.executeBatch(svo, 50);
        
        Datetime d = Datetime.now();
        String minute = d.minute() + 1 + '';
        String sch =  d.second() +  ' ' +   minute +    ' ' +   d.hour() +   ' ' +   d.day() +  ' ' +  d.month() +  ' ? ' + d.year();

        System.schedule(
        '定时一分钟后Test' + Datetime.now().getTime(),
        sch,
        svo
        );
        test.stopTest();
	 }
    static testMethod void testMethod4() {
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
        
        
        Customer_Sales_Info__c csi3 = new Customer_Sales_Info__c();
        csi3.Sales_Org__c = '5130';
        csi3.Distr_Channel__c = '00';
        csi3.Sales_View_Status__c = 'Approved';
        csi3.Sync_Status__c='Synchronized';
        csi3.Customer__c = a.Id;
        csi3.Acct_Assmt_Grp_Cust__c = '01';
        insert csi3;
        
        
        Order__c order1 = new Order__c();
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '5130';
        order1.Distr_Channel__c = '00';
        order1.Customer_Sales_Info__c = csi3.Id;
        order1.Currency__c = 'USD';
        order1.Deliver_Plant__c = '5130';
        order1.NotificationClose__c=true;
        order1.Status__c='Approved';
        order1.Approve_Date__c=date.today().addDays(31);
        order1.Sync_Status__c='Synchronized';
        order1.SAP_Order__c=false;
        Insert order1;
        
       
        test.startTest();
        UpdateCloseOrderNotificaionBatch svo = new UpdateCloseOrderNotificaionBatch();
        Database.executeBatch(svo, 50);
        
        Datetime d = Datetime.now();
        String minute = d.minute() + 1 + '';
        String sch =  d.second() +  ' ' +   minute +    ' ' +   d.hour() +   ' ' +   d.day() +  ' ' +  d.month() +  ' ? ' + d.year();

        System.schedule(
        '定时一分钟后Test' + Datetime.now().getTime(),
        sch,
        svo
        );
        test.stopTest();
	 }
    
}