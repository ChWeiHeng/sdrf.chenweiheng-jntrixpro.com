@isTest
private class BPMContractWebServiceTest {
    static testMethod void testMethod1() {
        Contracts__c con=new Contracts__c();
        insert con;
        
        
        BPMContractWebService.ReqContractInfo rb = new BPMContractWebService.ReqContractInfo();
        rb.CRMID = con.Id;
        rb.BPMNumber = '111';
        rb.businessContractTime=String.valueOf(Datetime.now());
        
        List<BPMContractWebService.ReqContractItemInfo> conDetailList=new List<BPMContractWebService.ReqContractItemInfo>();
        BPMContractWebService.ReqContractItemInfo conDetail=new BPMContractWebService.ReqContractItemInfo();
        conDetail.productName='111';
        conDetail.earliestDemand=String.valueOf(Datetime.now());
        conDetail.demandTime=String.valueOf(Datetime.now());
        conDetail.latestNeed=String.valueOf(Datetime.now());
        conDetail.latestDelivery=String.valueOf(Datetime.now());
        conDetailList.add(conDetail);
        rb.ITEMS=conDetailList;
       
        BPMContractWebService.feedbackContractInfo(rb);

	 }
    static testMethod void testMethod2() {
       

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/BPMContractWebService';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String requestContent = '{"esbinfo":{"instid":"1111"},"resultinfo":[{"CRMID":"con.Id","BPMNumber":"111","ITEMS":[{"productName":"111"}]}]}';
        request.requestBody = Blob.valueOf(requestContent);
        RestContext.request = request;

        test.startTest();
        BPMContractWebService.doPost();
        test.stopTest();
	 }
}