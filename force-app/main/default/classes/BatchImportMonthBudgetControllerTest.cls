@isTest
public with sharing class BatchImportMonthBudgetControllerTest {
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

        Campaign_Budget__c cam = new Campaign_Budget__c();
        insert cam;


        DataImportTemplate__c dit1 = new DataImportTemplate__c();
        dit1.Name = 'Monthly_Budget';
        dit1.FileId__c = c.Id;
        insert dit1;
        
        ImportDataFieldConf__c dataConf=new ImportDataFieldConf__c();
        dataConf.Obj_Name__c='Monthly_Budget';
        insert dataConf;


        BatchImportMonthBudgetController.getInitData(cam.Id);
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
        insert u;


        Campaign_Budget__c cam = new Campaign_Budget__c();
        cam.Budgeted_Amount__c=2000;
        cam.ExteralId__c='test1233e11';
        insert cam;

        String json ='[{"Month_1_Amount":"100","Month_2_Amount":"100","Month_3_Amount":"100","Month_4_Amount":"100","Month_5_Amount":"100","Month_6_Amount":"100","Month_7_Amount":"100","Month_8_Amount":"100","Month_9_Amount":"100","Month_10_Amount":"100","Month_11_Amount":"100","Month_12_Amount":"100","Sales_Rep__c":"bisfnewuser@testorg.com"}]';
        Map<String,String> strMap = new Map<String,String>();
        strMap.put('Month_1_Amount','Month_1');
        strMap.put('Month_2_Amount','Month_2');
        strMap.put('Month_3_Amount','Month_3');
        strMap.put('Month_4_Amount','Month_4');
        strMap.put('Month_5_Amount','Month_5');
        strMap.put('Month_6_Amount','Month_6');
        strMap.put('Month_7_Amount','Month_7');
        strMap.put('Month_8_Amount','Month_8');
        strMap.put('Month_9_Amount','Month_9');
        strMap.put('Month_10_Amount','Month_10');
        strMap.put('Month_11_Amount','Month_11');
        strMap.put('Month_12_Amount','Month_12');
        strMap.put('Sales_Rep__c','Sales Rep Username');
       
        List<String> mustFillValueFields = new List<String>();
        BatchImportMonthBudgetController.saveData(json,strMap,mustFillValueFields,cam.Id);
        mustFillValueFields.add('Month_1_Amount');
        json ='[{"Month_1_Amount":"100","Month_2_Amount":"10000","Month_3_Amount":"100","Month_4_Amount":"100","Month_5_Amount":"100","Month_6_Amount":"100","Month_7_Amount":"100","Month_8_Amount":"100","Month_9_Amount":"100","Month_10_Amount":"100","Month_11_Amount":"100","Month_12_Amount":"100","Sales_Rep__c":"bisfnewuser@testorg.com"}]';
        BatchImportMonthBudgetController.saveData(json,strMap,mustFillValueFields,cam.Id);
    }
}