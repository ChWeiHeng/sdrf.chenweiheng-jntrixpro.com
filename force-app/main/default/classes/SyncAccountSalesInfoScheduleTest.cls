@IsTest
private class SyncAccountSalesInfoScheduleTest {
    static testMethod void testMock(){
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
        csi.Customer__c = a.Id;
        insert csi;
        Datetime d = Datetime.now();
        String minute = d.minute() + 1 + '';
        String sch =  d.second() +  ' ' +   minute +    ' ' +   d.hour() +   ' ' +   d.day() +  ' ' +  d.month() +  ' ? ' + d.year();
        SyncAccountSalesInfoSchedule schup = new SyncAccountSalesInfoSchedule(
            csi.Id
        );
        System.schedule(
        '定时一分钟后SyncAccountSalesInfo' + Datetime.now().getTime(),
        sch,
        schup
        );
    }
}