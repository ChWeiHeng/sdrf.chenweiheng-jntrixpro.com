@isTest
global class MainBusinessIncomeWebServiceTest {
    static testMethod void testMethod1() { 
        List<MainBusinessIncomeWebService.ReqMainBusinessIncomeInfo> reqInfoList = new List<MainBusinessIncomeWebService.ReqMainBusinessIncomeInfo>();
        MainBusinessIncomeWebService.ReqMainBusinessIncomeInfo reqInfo = new MainBusinessIncomeWebService.ReqMainBusinessIncomeInfo();
        reqInfo.bukrs='111';
        reqInfo.h_budat=String.valueOf(Datetime.now());
        reqInfo.dmbtr='1000';
        reqInfo.wrbtr='1000';
        reqInfo.usdsl='1000';
        reqInfo.kursf='1';
        reqInfo.zuonr = '1';
        reqInfo.matnr = '2';
        MainBusinessIncomeWebService.HeadInclude headClude=new MainBusinessIncomeWebService.HeadInclude();
        headClude.hex01='111';
        reqInfo.include=headClude;
       
        reqInfoList.add(reqInfo);
        MainBusinessIncomeWebService.feedbackMainBusinessIncomeInfo(reqInfoList);

	 }
    static testMethod void testMethod2() {
       

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/MainBusinessIncomeWebService';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String requestContent = '{"esbinfo":{"instid":"1111"},"resultinfo":[{"bukrs":"111","gjahr":"111","include":{"hex01":"111"}}]}';
        request.requestBody = Blob.valueOf(requestContent);
        RestContext.request = request;
        test.startTest();
        MainBusinessIncomeWebService.doPost();
        test.stopTest();
	 }
}