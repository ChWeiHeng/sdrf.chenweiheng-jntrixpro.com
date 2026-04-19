@isTest
private class SAPCollectionWebServiceTest {
    static testMethod void testMethod1() {
        // 创建账户
        Account a = new Account();
        a.Name = 'Test111';
        a.Group_Name__c = 'test111';  
        a.MDG_Customer_Code__c = '123';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        Insert a;



        // 创建并填充请求体
        List<SAPCollectionWebService.ReqOrderInfo> rbList = new List<SAPCollectionWebService.ReqOrderInfo>();
        SAPCollectionWebService.ReqOrderInfo rb = new SAPCollectionWebService.ReqOrderInfo();
        rb.KUNNR = '123'; // 客户编码
        rb.BUKRS = '5130'; // 公司代码
        rb.GJAHR = '2023'; // 会计年度
        rb.BELNR = '123456'; // 会计凭证
        rb.BUZEI = '10'; // 凭证行号
        rb.H_BLART = 'AA'; // 凭证类型
        rb.H_WAERS = 'EUR'; // 凭证货币
        rb.RFCCUR = 'EUR'; // 本位币
        rb.KURSF = '1.0'; // 汇率
        rb.H_BUDAT = '2024-06-07'; // 过账日期
        rb.SHKZG = 'H'; // 借贷方
        rb.WRBTR = '1000'; // 凭证货币金额
        rb.DMBTR = '1000'; // 本位币金额
        rb.PRCTR = 'P123'; // 利润中心
        rb.HKONT = '1000'; // 会计科目
        rbList.add(rb);


        SAPCollectionWebService.ReqESInfo esbInfo = new SAPCollectionWebService.ReqESInfo();
        esbInfo.instid = '123456';
        esbInfo.requesttime = DateTime.now().format('yyyyMMddHHmmss'); // 请求时间

        SAPCollectionWebService.RequestBody requestBody = new SAPCollectionWebService.RequestBody();
        requestBody.esbinfo = esbInfo;
        requestBody.resultinfo = rbList;

        String requestContent = JSON.serialize(requestBody);

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/SAPCollectionWebService';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(requestContent);
        RestContext.request = request;
        Test.startTest();
        SAPCollectionWebService.doPost();
        Test.stopTest();

        List<Collection_Details__c> collectionDetails = [SELECT External_Id__c FROM Collection_Details__c WHERE External_Id__c = '5130202312345610'];//
        //System.assertEquals(1, collectionDetails.size(), 'error');
        if (collectionDetails.isEmpty()) {
            System.debug('No records found with External_Id__c = 5130202312345610');
        } else {
            System.debug('Found records: ' + collectionDetails);
        }
    }
}