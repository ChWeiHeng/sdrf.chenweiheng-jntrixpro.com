@isTest
private class AccountVisitSubmitControllerTest {
    static testMethod void testMethod1() {

        Profile prof = [SELECT Id FROM Profile WHERE Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema' LIMIT 1]; 
        User u = new User();
        u.LastName = 'test';
        u.Username = 'bisfnewuser@testorg.com';
        u.Alias = 'newUser';
        u.Email='bisfnewuser@testorg.com';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.ProfileId = prof.Id;
        u.Sales_Org__c='3010';
        u.Delivery_Plant__c='3010';
        u.TimeZoneSidKey='America/Los_Angeles';
        insert u;

        User u1 = new User();
        u1.LastName = 'test';
        u1.Username = 'biser@testorg.com';
        u1.Alias = 'newUser';
        u1.Email='bisfner@testorg.com';
        u1.EmailEncodingKey='UTF-8';
        u1.LanguageLocaleKey='en_US';
        u1.LocaleSidKey='en_US';
        u1.ProfileId = prof.Id;
        u1.Sales_Org__c='3010';
        u1.Delivery_Plant__c='3010';
        u1.TimeZoneSidKey='America/Los_Angeles';
        u1.ManagerId=u.Id;
        insert u1;

        Sales_Forecast_Summary__c sfs=new Sales_Forecast_Summary__c();
        sfs.Sales_Org__c='3010';
        sfs.Delivery_Plant__c='3010';
        sfs.Year__c=String.valueOf(date.today().Year());
        insert sfs;

        Account_Visit__c av=new Account_Visit__c();
        av.Start_Date__c=date.today();
        av.OwnerId=u1.Id;
        av.Sales_Org__c='3010';
        av.Plant__c='3010';
        insert av;
        AccountVisitSubmitController.init(av.Id);
        AccountVisitSubmitController.init('111');
        AccountVisitSubmitController.NoticeManage(av.Id);
    }
}