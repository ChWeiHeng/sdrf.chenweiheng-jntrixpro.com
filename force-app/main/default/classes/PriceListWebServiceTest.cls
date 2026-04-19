@isTest
private class PriceListWebServiceTest {
	static testMethod void testMethod1() {
        
        PriceListWebService.RequestBody pr = new PriceListWebService.RequestBody();

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/PriceListWebService';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String requestContent = '{"esbinfo":{},"resultinfo":{"NO":"111","body":[{"PRODUCTLIST":"Test"}]}}';
        request.requestBody = Blob.valueOf(requestContent);
        RestContext.request = request;

        test.startTest();
        PriceListWebService.doPost();
        test.stopTest();
	 }
    
}