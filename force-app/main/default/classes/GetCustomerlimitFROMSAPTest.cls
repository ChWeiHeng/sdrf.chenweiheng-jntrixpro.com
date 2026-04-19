/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 07-03-2025
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-03-2025   Gerry   Initial Version
**/
@IsTest
private class GetCustomerlimitFROMSAPTest {
    static testMethod void testMock(){
        
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.MDG_Customer_Code__c = '1234';
        Insert a;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(a.MDG_Customer_Code__c,200));
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        System.Test.startTest();
        GetCustomerlimitFROMSAP.submitToSAP(new List<String>{a.MDG_Customer_Code__c}, '','');
        System.Test.stopTest();
    }

    static testMethod void testMock1(){
        
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.MDG_Customer_Code__c = '1234';
        Insert a;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(a.MDG_Customer_Code__c,500));
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        System.Test.startTest();
        GetCustomerlimitFROMSAP.submitToSAP(new List<String>{a.MDG_Customer_Code__c}, '','');
        System.Test.stopTest();
    }

    static testMethod void testMock2(){
        
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.MDG_Customer_Code__c = '1234';
        Insert a;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.CustomerInfoSyncToSapErr());
        test.startTest();
        GetCustomerlimitFROMSAP.submitToSAP(new List<String>{a.MDG_Customer_Code__c}, '','');
        test.stopTest();
    }

    static testMethod void testMock3(){
        
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        a.MDG_Customer_Code__c = '1234';
        Insert a;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        Test.setMock(HttpCalloutMock.class, new TestHttpMock.GetCustomerlimitFROMSAPW());
        test.startTest();
        GetCustomerlimitFROMSAP.submitToSAP(new List<String>{a.MDG_Customer_Code__c}, '','');
        test.stopTest();
    }

    private class MockHttpResponse implements HttpCalloutMock {
        String partner1;
        Integer status1;
        public MockHttpResponse(String partner,Integer status) {
            partner1 = partner;
            status1 = status;
        }
        public HttpResponse respond(HttpRequest req) {
            // 创建一个虚拟的HTTPResponse对象
            HttpResponse res = new HttpResponse();
            res.setStatusCode(status1);
            res.setBody('{"esbinfo":{"instid":"U2FwU2FsZXNNdWxlRVNCL1NhcFNhbGVzQXZhQ3JlTGltaXRGbG93MjAyNC0wNi0wNSAxNDoxMzo0Ny4yODg=","requesttime":"2024-06-05 03:13:46","responsetime":"2024-06-05 14:13:47.000","returnstatus":"S","returncode":"S001","returnmsg":"Success","attr1":"","attr2":"","attr3":""},"resultinfo":[{"partner":"'+partner1+'","amount":"-69083.61","currency":"USD","limit_valid_date":"3999-12-31","zsfyq":"X","exch_rate":"1.00000","msgty":"S","msgtx":"Success","hex01":"","hex02":"","hex03":"","hex04":"","hex05":"","hex06":"","items":[]}]}');
            return res;
        }
    }
}