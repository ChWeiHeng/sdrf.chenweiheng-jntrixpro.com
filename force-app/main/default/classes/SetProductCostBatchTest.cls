@IsTest
private class SetProductCostBatchTest {
    static testMethod void ww () {
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
        test.startTest();
        SetProductCostBatch svo = new SetProductCostBatch();
        Database.executeBatch(svo, 50);
        // 每次执行多少条数据，最大200
        //String jobId = Database.executeBatch(svo, 50);
         Datetime d = Datetime.now();
        String minute = d.minute() + 1 + '';
        String sch =  d.second() +  ' ' +   minute +    ' ' +   d.hour() +   ' ' +   d.day() +  ' ' +  d.month() +  ' ? ' + d.year();

        System.schedule(
        '定时一分钟后Test111' + Datetime.now().getTime(),
        sch,
        svo
        );
        test.stopTest();
    }
    
}