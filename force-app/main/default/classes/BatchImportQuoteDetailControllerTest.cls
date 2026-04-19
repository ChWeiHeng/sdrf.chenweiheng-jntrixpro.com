@isTest
public with sharing class BatchImportQuoteDetailControllerTest {
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

        Quote__c quote1 = new Quote__c();
        quote1.Quotation_Type__c = 'HQ_Purchase';
        insert quote1;


        DataImportTemplate__c dit1 = new DataImportTemplate__c();
        dit1.Name = 'Quote_Detail';
        dit1.FileId__c = c.Id;
        insert dit1;
        
        ImportDataFieldConf__c dataConf=new ImportDataFieldConf__c();
        dataConf.RecordType__c='Tolling;';
        dataConf.Obj_Name__c='Quote_Detail';
        insert dataConf;


        BatchImportQuoteDetailController.getInitData(quote1.Id);
        quote1.Sales_Org__c='3010';
        update quote1;
        BatchImportQuoteDetailController.getInitData(quote1.Id);
    }

    static testMethod void testMethod2() {
        Account acc = new Account();
        acc.Name = 'test';
        acc.Group_Name__c = 'test';
        acc.MDG_Customer_Code__c = '0001006790';
        insert acc;

        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;

        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        insert psi;

        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'test';
        pn.Product_Sales_Info__c = psi.Id;
        insert pn;

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

        Price_List__c priceList=new Price_List__c();
        priceList.Name='test';
        insert priceList;

        Quote__c quote1 = new Quote__c();
        quote1.Quotation_Type__c = 'HQ_Purchase';
        insert quote1;

        String json ='[{"Order_Qnty__c":"10","CIF_90_Days__c":"100","FOB_Price__c":"20","Unit__c":"L","Price_List__c":"test"}]';
        Map<String,String> strMap = new Map<String,String>();
        strMap.put('Order_Qnty__c','Order Qnty');
        strMap.put('CIF_90_Days__c','Quote Price');
        strMap.put('FOB_Price__c','FOB Bulking Price');
        strMap.put('Unit__c','Unit');
        strMap.put('Price_List__c','Quote English Name');
       
        List<String> mustFillValueFields = new List<String>();
        mustFillValueFields.add('Order_Qnty__c');
        BatchImportQuoteDetailController.saveData(json,strMap,mustFillValueFields,quote1.Id);
    }
    static testMethod void testMethod3() {
        Account acc = new Account();
        acc.Name = 'test';
        acc.Group_Name__c = 'test';
        acc.MDG_Customer_Code__c = '0001006790';
        insert acc;

        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;

        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        insert psi;

        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'test';
        pn.Product_Sales_Info__c = psi.Id;
        insert pn;

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

        Price_List__c priceList=new Price_List__c();
        priceList.Name='test';
        insert priceList;
        
        Contract_Processing_Product__c cpp=new Contract_Processing_Product__c();
        cpp.Name='test';
        insert cpp;

        Quote__c quote1 = new Quote__c();
        quote1.Sales_Org__c='5070';
        quote1.Deliver_Plant__c = '5070';
        quote1.Quotation_Type__c = 'Tolling';
        insert quote1;

        String json ='[{"Order_Qnty__c":"10","CIF_90_Days__c":"100","FOB_Price__c":"20","Unit__c":"L","Contract_Processing_Product__c":"test"}]';
        Map<String,String> strMap = new Map<String,String>();
        strMap.put('Order_Qnty__c','Order Qnty');
        strMap.put('CIF_90_Days__c','Quote Price');
        strMap.put('FOB_Price__c','FOB Bulking Price');
        strMap.put('Unit__c','Unit');
        strMap.put('Contract_Processing_Product__c','Tolling Product');
       
        List<String> mustFillValueFields = new List<String>();
        mustFillValueFields.add('Order_Qnty__c');
        BatchImportQuoteDetailController.saveData(json,strMap,mustFillValueFields,quote1.Id);
        json ='[{"Order_Qnty__c":"10","CIF_90_Days__c":"100","FOB_Price__c":"20","Unit__c":"L","Contract_Processing_Product__c":""}]';
        BatchImportQuoteDetailController.saveData(json,strMap,mustFillValueFields,quote1.Id);
        json ='[{"Order_Qnty__c":"10","CIF_90_Days__c":"100","FOB_Price__c":20,"Unit__c":"L","Contract_Processing_Product__c":""}]';
        BatchImportQuoteDetailController.saveData(json,strMap,mustFillValueFields,quote1.Id);
       
    }
}