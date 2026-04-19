@IsTest 
public with sharing class ShareAccountDataBatchtest {
    static testMethod void testMock(){
        Account acc = new Account();
        acc.Name = 'test acc';
        acc.Group_Name__c = '001D600001n4hjPIAQ';
        acc.Customer_Approval_Status__c = 'Approved';
        acc.Sync_Status__c = 'Synchronized';
        acc.MDG__c = false;
        insert acc;
        Profile prof = [SELECT Id FROM Profile WHERE Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema' LIMIT 1]; 
        User u = new User();
        u.LastName = 'test';
        u.Username = 'testuserbisfc@testorg.com';
        u.Alias = 'newUser';
        u.Email='testuserbisfc@testorg.com';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.ProfileId = prof.Id;
        u.TimeZoneSidKey='America/Los_Angeles';
        insert u;
        Account_Team__c at = new Account_Team__c();
        at.Customer__c = acc.Id;
        at.Sales_Rep__c = u.Id;
        insert at;
        at.Account_Share__c = 'read';
        update at;
        DeleteShare__c sd = new DeleteShare__c();
        sd.Name = 'Account';
        sd.Index__c  =1;
        sd.Sql__c = 'SELECT Id FROM AccountShare WHERE AccountId=:recordId AND UserOrGroupId=:userId AND Account.OwnerId !=:userId';
        insert sd;
        delete at;
    }

    static testMethod void testMock1(){
        Account acc = new Account();
        acc.Name = 'test acc';
        acc.Group_Name__c = '001D600001n4hjPIAQ';
        acc.Customer_Approval_Status__c = 'Approved';
        acc.Sync_Status__c = 'Synchronized';
        acc.MDG__c = false;
        insert acc;
        Profile prof = [SELECT Id FROM Profile WHERE Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema' LIMIT 1]; 
        User u = new User();
        u.LastName = 'test';
        u.Username = 'testuserbisfc@testorg.com';
        u.Alias = 'newUser';
        u.Email='testuserbisfc@testorg.com';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.ProfileId = prof.Id;
        u.TimeZoneSidKey='America/Los_Angeles';
        insert u;
        Account_Team__c at = new Account_Team__c();
        at.Customer__c = acc.Id;
        at.Sales_Rep__c = u.Id;
        insert at;
        ShareDataQuery__c sdq = new ShareDataQuery__c();
        sdq.Name = '1';
        sdq.Sql__c = 'SELECT Id,OwnerId FROM Account WHERE Id=:recordId';
        sdq.Object__c = 'Account';
        sdq.Field__c = 'Account_Share__c';
        sdq.Index__c = 1;
        insert sdq;
        Database.executeBatch(new ShareAccountDataBatch(at.Id,at.Customer__c,1), 100);
    }

    static testMethod void testMock2(){
        Account acc = new Account();
        acc.Name = 'test acc';
        acc.Group_Name__c = '001D600001n4hjPIAQ';
        acc.Customer_Approval_Status__c = 'Approved';
        acc.Sync_Status__c = 'Synchronized';
        acc.MDG__c = false;
        insert acc;
        Profile prof = [SELECT Id FROM Profile WHERE Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema' LIMIT 1]; 
        User u = new User();
        u.LastName = 'test';
        u.Username = 'testuserbisfc@testorg.com';
        u.Alias = 'newUser';
        u.Email='testuserbisfc@testorg.com';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.ProfileId = prof.Id;
        u.TimeZoneSidKey='America/Los_Angeles';
        insert u;
        Account_Team__c at = new Account_Team__c();
        at.Customer__c = acc.Id;
        at.Sales_Rep__c = u.Id;
        insert at;
        ShareDataQuery__c sdq = new ShareDataQuery__c();
        sdq.Name = '1';
        sdq.Sql__c = 'SELECT Id,OwnerId FROM Account WHERE Id=:recordId';
        sdq.Object__c = 'Account';
        sdq.Field__c = 'Account_Share__c';
        sdq.Index__c = 1;
        insert sdq;
        // Database.executeBatch(new ShareAccountDataBatch(at.Id,at.Customer__c,1), 100);
        AccountShare as1 = new AccountShare();
        as1.AccountId = acc.Id;
        as1.AccountAccessLevel = 'read';
        as1.OpportunityAccessLevel = 'None';
        as1.UserOrGroupId = u.Id;
        as1.RowCause = 'Manual';
        insert as1;
        Test.startTest();
        DeleteShare__c sd = new DeleteShare__c();
        sd.Name = 'Account';
        sd.Index__c  =1;
        sd.Sql__c = 'SELECT Id FROM AccountShare WHERE AccountId=:recordId AND UserOrGroupId=:userId AND Account.OwnerId !=:userId';
        insert sd;
        delete at;
        Test.stopTest();
    }
}