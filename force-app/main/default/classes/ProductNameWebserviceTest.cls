/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-20-2025
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-20-2025   Gerry   Initial Version
**/
@isTest
private class ProductNameWebserviceTest {

    @IsTest
    static void testDoPost() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ProductNameWebservice/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"resultinfo":[{"Material":"000000000000000000","Material_Text":"Test Material"}]}');
        RestContext.request = req;
        RestContext.response = res;
        ProductNameWebservice.doPost();
        Test.stopTest();
    }

    @IsTest
    static void testDoPost2() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ProductNameWebservice/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"invalidJson" ');
        RestContext.request = req;
        RestContext.response = res;
        ProductNameWebservice.doPost();
        Test.stopTest();
    }
}