/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-28-2025
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-28-2025   Gerry   Initial Version
**/
@isTest
public with sharing class CampaignTriggerHandlerTest {
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
        
        Campaign_Budget__c camBud = new Campaign_Budget__c();
        camBud.Sales_Org__c='3010';
        camBud.Plant__c='3010';
        camBud.Year__c=String.valueOf(date.today().Year());
        camBud.Budgeted_Amount__c=10000;
        //camBud.ExteralId__c='testuser_2025_1';
        insert camBud;

        Monthly_Budget__c mb=new Monthly_Budget__c();
        mb.Campaign_Budget__c=camBud.Id;
        mb.Budgeted_Amount__c=1000;
        mb.Month__c=String.valueOf(date.today().Month());
        mb.Sales_Rep__c=u.Id;
        insert mb;

        Campaign cam = new Campaign();
        cam.Date__c=date.today();
        cam.OwnerId=u.Id;
        cam.Name='test';
        cam.recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Offline_Campaign').getRecordTypeId();
        insert cam;
        
        Campaign cam1 = new Campaign();
        cam1.Date__c=date.today();
        cam1.OwnerId=u.Id;
        cam1.Name='test';
        cam1.recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Online_Campaign').getRecordTypeId();
        insert cam1;
        
        cam.Approval_Status__c = 'Approved';
        update cam;
        cam1.Approval_Status__c = 'Approved';
        update cam1;
        cam1.MKT_Approval__c = 'Approving';
        update cam1;
    }
}