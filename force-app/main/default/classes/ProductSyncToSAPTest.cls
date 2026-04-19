@isTest
private class ProductSyncToSAPTest {
    static testMethod void testMethod1() {
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.Material_Type__c = 'Z002';
        p.Chinese_Description__c = '11';
        p.English_Description__c = '11';
        p.Spanish_Description__c = '11';
        p.Portuguese_Description__c = '11';
        p.Basic_Metering_Unit__c = 'L';
        p.Material_Group__c = '20';
        p.Division__c = '10';
        p.Cross_Factory_Material_Status__c = '11';
        p.Effective_Start__c = '11';
        p.Gross_Weight__c = '11';
        p.Weight_Unit__c = 'KG';
        p.Net_Weight__c = '11';
        p.Business_Volume__c = '11';
        p.Volumetric_Unit__c = 'L';
        p.Laboratory_Office__c = '001';
        p.External_Material_Group__c = '11';
        p.Industry_Standard_Description__c = '11';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Sales_Organization__c = '3010';
        psi.Distr_Channel__c = '00';
        psi.Default_Sales_Unit__c = 'L';
        psi.Delivering_Plant__c = '3010';
        psi.Material_Subject_Assign_Group__c = '01';
        psi.Project_Category_Group__c = 'NORM';
        psi.Product__c = p.Id;
        insert psi;
        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = '11';
        pu.Molecule__c = 10;
        pu.Denominator__c = 10;
        pu.Product__c = p.Id;
        insert pu;
        ProductSyncToSAP.submitToSAP(p.Id);
    }

    static testMethod void testMethod2() {
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.Material_Type__c = 'Z002';
        p.Chinese_Description__c = '11';
        p.English_Description__c = '11';
        p.Spanish_Description__c = '11';
        p.Portuguese_Description__c = '11';
        p.Basic_Metering_Unit__c = 'L';
        p.Material_Group__c = '20';
        p.Division__c = '10';
        p.Cross_Factory_Material_Status__c = '11';
        p.Effective_Start__c = '11';
        p.Gross_Weight__c = '11';
        p.Weight_Unit__c = 'KG';
        p.Net_Weight__c = '11';
        p.Business_Volume__c = '11';
        p.Volumetric_Unit__c = 'L';
        p.Laboratory_Office__c = '001';
        p.External_Material_Group__c = '11';
        p.Industry_Standard_Description__c = '11';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Sales_Organization__c = '3010';
        psi.Distr_Channel__c = '00';
        psi.Default_Sales_Unit__c = 'L';
        psi.Delivering_Plant__c = '3010';
        psi.Material_Subject_Assign_Group__c = '01';
        psi.Project_Category_Group__c = 'NORM';
        psi.Product__c = p.Id;
        insert psi;
        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = '11';
        pu.Molecule__c = 10;
        pu.Denominator__c = 10;
        pu.Product__c = p.Id;
        insert pu;
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.ProductSalesInfoSyncToSAP());
        test.startTest();
        ProductSyncToSAP.submitToSAP(p.Id);
        test.stopTest();
        
    }
}