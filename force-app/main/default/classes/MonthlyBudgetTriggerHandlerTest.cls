@isTest
public with sharing class MonthlyBudgetTriggerHandlerTest {
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
        u.TimeZoneSidKey='America/Los_Angeles';
        insert u;
        
        Campaign_Budget__c cam = new Campaign_Budget__c();
        cam.Budgeted_Amount__c=10000;
        cam.ExteralId__c='testuser_2025_1';
        insert cam;

        Monthly_Budget__c mb=new Monthly_Budget__c();
        mb.Campaign_Budget__c=cam.Id;
        mb.Budgeted_Amount__c=1000;
        mb.Month__c='1';
        mb.Sales_Rep__c=u.Id;
        insert mb;

        mb.Budgeted_Amount__c=1500;
        update mb;
    }
}