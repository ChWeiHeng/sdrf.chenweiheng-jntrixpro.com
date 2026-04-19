@isTest
public with sharing class BatchImportParticipantsListTest {
    static testMethod void testMethod1() {
        ContentVersion contentVersion = new ContentVersion(
                    Title = 'Penguins',
                    PathOnClient = 'Penguins.jpg',
                    VersionData = Blob.valueOf('Test Content'),
                    IsMajorVersion = true
            );
        insert contentVersion;
        ContentVersion c = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        ContentDistribution cdl = new ContentDistribution();
        cdl.ContentVersionId = contentVersion.Id;
        cdl.Name = 'PublicShare';
        cdl.PreferencesAllowViewInBrowser = true;
        cdl.PreferencesLinkLatestVersion = true;
        cdl.PreferencesNotifyOnVisit = false;
        cdl.PreferencesPasswordRequired = false;
        cdl.PreferencesAllowOriginalDownload = true;
        cdl.PreferencesNotifyRndtnComplete = false;
        insert cdl;

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
        u.Sales_Org__c='3010';
        u.Delivery_Plant__c='3010';
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


        DataImportTemplate__c dit1 = new DataImportTemplate__c();
        dit1.Name = 'Participants_List_MX';
        dit1.FileId__c = c.Id;
        insert dit1;
        
        ImportDataFieldConf__c dataConf=new ImportDataFieldConf__c();
        dataConf.RecordType__c='3010;5070';
        dataConf.Obj_Name__c='Participants_List__c';
        insert dataConf;


        BatchImportParticipantsListController.getInitData(cam.Id);
    }

    static testMethod void testMethod2() {

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
        u.Sales_Org__c='3010';
        u.Delivery_Plant__c='3010';
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

        String json ='[{"Name":"testname","Position__c":"test"}]';
        Map<String,String> strMap = new Map<String,String>();
        strMap.put('Name','Name');
        strMap.put('Position__c','Position');
       
        List<String> mustFillValueFields = new List<String>();
        BatchImportParticipantsListController.saveData(json,strMap,mustFillValueFields,cam.Id);
        mustFillValueFields.add('Sales_rep__c');
        BatchImportParticipantsListController.saveData(json,strMap,mustFillValueFields,cam.Id);
    }
}