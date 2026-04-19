/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 09-15-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   09-09-2025   Gerry   Initial Version
**/
@isTest
private class RecallContractFROMBPMTest {


    @IsTest
    static void testRecallContractFROMBPM() {
        // Create a test contract
        Contracts__c testContract = new Contracts__c(Status__c = 'Draft', CRM_Approval_Status__c = 'Draft', Sync_Status__c = null, Recall_Reason__c = null);
        insert testContract;

        // Create a test contract ID list
        List<String> contractIdList = new List<String>();
        contractIdList.add(testContract.Id);

        // Set the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.MockHttpResponse(testContract.Id));
        System.test.startTest();
        // Call the recallContract method
        RecallContractFROMBPM.recallContract(contractIdList);
        // RecallContractFROMBPM.testme();
        System.Test.stopTest();
    }

    

    @IsTest
    static void testRecallContractFROMBPM2() {
        // Create a test contract
        Contracts__c testContract = new Contracts__c(Status__c = 'Draft', CRM_Approval_Status__c = 'Draft', Sync_Status__c = null, Recall_Reason__c = null);
        insert testContract;

        // Create a test contract ID list
        List<String> contractIdList = new List<String>();
        contractIdList.add(testContract.Id);

        // Set the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.MockHttpResponse1(testContract.Id));
        System.test.startTest();
        // Call the recallContract method
        RecallContractFROMBPM.recallContract(contractIdList);

        System.Test.stopTest();
    }

    @IsTest
    static void testRecallContractFROMBPM1() {
        // Create a test contract
        Contracts__c testContract = new Contracts__c(Status__c = 'Draft', CRM_Approval_Status__c = 'Draft', Sync_Status__c = null, Recall_Reason__c = null);
        insert testContract;

        // Create a test contract ID list
        List<String> contractIdList = new List<String>();
        contractIdList.add(testContract.Id);

        // Set the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.CustomerInfoSyncToSap());
        System.test.startTest();
        // Call the recallContract method
        RecallContractFROMBPM.recallContract(contractIdList);

        System.Test.stopTest();
    }

    @IsTest
    static void testRecallContractFROMBPM2_1() {
        // Create a test contract
        Contracts__c testContract = new Contracts__c(Status__c = 'Draft', CRM_Approval_Status__c = 'Draft', Sync_Status__c = null, Recall_Reason__c = null);
        insert testContract;

        // Create a test contract ID list
        List<String> contractIdList = new List<String>();
        contractIdList.add(testContract.Id);

        // Set the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.HttpCalloutMock500(testContract.Id));
        System.test.startTest();
        // Call the recallContract method
        RecallContractFROMBPM.recallContract(contractIdList);

        System.Test.stopTest();
    }

    

    @IsTest
    static void testRecallContractFROMBPM3() {
        // Create a test contract
        Contracts__c testContract = new Contracts__c(Status__c = 'Draft', CRM_Approval_Status__c = 'Draft', Sync_Status__c = null, Recall_Reason__c = null);
        insert testContract;

        // Create a test contract ID list
        List<String> contractIdList = new List<String>();
        contractIdList.add(testContract.Id);

        // Set the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.HttpCalloutMocke(testContract.Id));
        System.test.startTest();
        // Call the recallContract method
        RecallContractFROMBPM.recallContract(contractIdList);

        System.Test.stopTest();
    }

   
    @IsTest
    static void testRecallContractFROMBPM4() {
        // Create a test contract
        Contracts__c testContract = new Contracts__c(Status__c = 'Draft', CRM_Approval_Status__c = 'Draft', Sync_Status__c = null, Recall_Reason__c = null);
        insert testContract;

        // Create a test contract ID list
        List<String> contractIdList = new List<String>();
        contractIdList.add(testContract.Id);

        // Set the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.HttpCalloutMocke1(testContract.Id));
        System.test.startTest();
        // Call the recallContract method
        RecallContractFROMBPM.recallContract(contractIdList);

        System.Test.stopTest();
    }

    
}