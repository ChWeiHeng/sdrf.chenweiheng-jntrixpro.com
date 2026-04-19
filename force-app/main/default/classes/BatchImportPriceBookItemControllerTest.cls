/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 06-24-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-24-2025   Gerry   Initial Version
**/
@isTest
private class BatchImportPriceBookItemControllerTest {

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
        u.Country__c = 'MX';
        insert u;

        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Sales_Org__c = '3010';
        pb.Currency__c = 'USD';
        pb.Delivery_Plant__c = '3010';
        insert pb;


        DataImportTemplate__c dit1 = new DataImportTemplate__c();
        dit1.Name = 'Price_Book_Item_MX';
        dit1.FileId__c = c.Id;
        insert dit1;
        DataImportTemplate__c dit2 = new DataImportTemplate__c();
        dit2.Name = 'Price_Book_Item_AR';
        dit2.FileId__c = c.Id;
        insert dit2;
        
        ImportDataFieldConf__c dataConf=new ImportDataFieldConf__c();
        dataConf.RecordType__c='3010;5070';
        dataConf.Obj_Name__c='Price_Book_Item__c';
        
        insert dataConf;

        System.runas(u){
            BatchImportPriceBookItemController.getInitData(pb.Id);
        }
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
        u.Country__c = 'MX';
        insert u;

        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Sales_Org__c = '3010';
        pb.Currency__c = 'USD';
        pb.Delivery_Plant__c = '3010';
        insert pb;
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Sales_Organization__c = '3010';
        psi.Factory__c = '3010';
        psi.Distr_Channel__c = '10';
        insert psi;
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'test';
        pn.Product_Sales_Info__c = psi.Id;
        insert pn;
        

        String json ='[{"Product_Code__c":"12341234","Price__c":"1","Distribution_Channel__c":"10","Product_Name__c":"test"}]';
        Map<String,String> strMap = new Map<String,String>();
        strMap.put('Product_Code__c','Product Code');
        List<String> numValueFieldSet = new List<String>();
        numValueFieldSet.add('Price__c');
        List<String> mustFillValueFields = new List<String>();
        BatchImportPriceBookItemController.saveData(json,strMap,mustFillValueFields,pb.Id,numValueFieldSet);
        mustFillValueFields.add('Sales_rep__c');
        BatchImportPriceBookItemController.saveData(json,strMap,mustFillValueFields,pb.Id,numValueFieldSet);
    }

    static testMethod void testMethod3() {

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
        u.Country__c = 'MX';
        insert u;

        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Sales_Org__c = '3010';
        pb.Currency__c = 'USD';
        pb.Delivery_Plant__c = '3010';
        insert pb;
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Sales_Organization__c = '3010';
        psi.Factory__c = '3010';
        psi.Distr_Channel__c = '10';
        insert psi;
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'test';
        pn.Product_Sales_Info__c = psi.Id;
        insert pn;
        

        String json ='[{"Product_Code__c":"3","Price__c":"1","Distribution_Channel__c":"10","Product_Name__c":"test"}]';
        Map<String,String> strMap = new Map<String,String>();
        strMap.put('Product_Code__c','Product Code');
        List<String> numValueFieldSet = new List<String>();
        numValueFieldSet.add('Price__c');
        List<String> mustFillValueFields = new List<String>();
        BatchImportPriceBookItemController.saveData(json,strMap,mustFillValueFields,pb.Id,numValueFieldSet);
        mustFillValueFields.add('Sales_rep__c');
        BatchImportPriceBookItemController.saveData(json,strMap,mustFillValueFields,pb.Id,numValueFieldSet);
    }

    static testMethod void testMethod4() {

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
        u.Country__c = 'MX';
        insert u;

        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Sales_Org__c = '3010';
        pb.Currency__c = 'USD';
        pb.Delivery_Plant__c = '3010';
        insert pb;
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Sales_Organization__c = '3010';
        psi.Factory__c = '3010';
        psi.Distr_Channel__c = '10';
        insert psi;
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'test';
        pn.Product_Sales_Info__c = psi.Id;
        insert pn;
        

        String json ='[{"Product_Code__c":"3","Price__c":"你好","Distribution_Channel__c":"10","Product_Name__c":"test"}]';
        Map<String,String> strMap = new Map<String,String>();
        strMap.put('Product_Code__c','Product Code');
        List<String> numValueFieldSet = new List<String>();
        numValueFieldSet.add('Price__c');
        List<String> mustFillValueFields = new List<String>();
        BatchImportPriceBookItemController.saveData(json,strMap,mustFillValueFields,pb.Id,numValueFieldSet);
        mustFillValueFields.add('Sales_rep__c');
        BatchImportPriceBookItemController.saveData(json,strMap,mustFillValueFields,pb.Id,numValueFieldSet);
    }

}