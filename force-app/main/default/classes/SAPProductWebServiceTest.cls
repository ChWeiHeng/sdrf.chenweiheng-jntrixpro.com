@isTest
private class SAPProductWebServiceTest {
    static testMethod void testMethod1() {
        
        List<SAPProductWebService.ReqProductInfo> rbList = new List<SAPProductWebService.ReqProductInfo>();
        SAPProductWebService.ReqProductInfo rb = new SAPProductWebService.ReqProductInfo();
        rb.matnr = '11';
        rb.mtart = 'Z002';
        rb.ltext_1 = '123';
        rb.ltext_e = '5130';
        rb.ltext_s = '00';
        rb.ltext_pt = 'ZAR1';
        rb.meins = 'L';
        rb.matkl = '20';
        rb.spart = '10';
        rb.mstae = '11';
        rb.mstde = '111';
        rb.brgew = '11';
        rb.ntgew = 'USD';
        rb.gewei = 'L';
        rb.volum = 'USD';
        rb.voleh = 'L';
        rb.labor = '001';
        rb.extwg = 'USD';
        rb.normt = 'USD';
        List<SAPProductWebService.SalesInfoRow> brList = new List<SAPProductWebService.SalesInfoRow>();
        SAPProductWebService.SalesInfoRow br = new SAPProductWebService.SalesInfoRow();
        br.werks = '3010';
        br.vkorg = '3010';
        br.vtweg = '00';
        br.vrkme = 'L';
        br.dwerk = '3010';
        br.ktgrm = '01';
        br.mtpos = 'NORM';
        brList.add(br);
        List<SAPProductWebService.ProductUnitRow> puList = new List<SAPProductWebService.ProductUnitRow>();
        SAPProductWebService.ProductUnitRow pu = new SAPProductWebService.ProductUnitRow();
        pu.meinh = 'L';
        pu.meins = '10';
        pu.umrez = '10';
        pu.umren = '10';
        puList.add(pu);
        List<SAPProductWebService.PriceNameRow> pnList = new List<SAPProductWebService.PriceNameRow>();
        SAPProductWebService.PriceNameRow pn = new SAPProductWebService.PriceNameRow();
        pn.ltext = 'test';
        pn.sprastxt = '10';
        pnList.add(pn);
        rb.salev = brList;
        rb.units = puList;
        rb.princename=pnList;
        rbList.add(rb);
        SAPProductWebService.feedbackOrderInfo(rbList);
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/SAPProductWebService';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String requestContent = '{"esbinfo":{},"resultinfo":{}}';
        request.requestBody = Blob.valueOf(requestContent);
        RestContext.request = request;
        Test.startTest();
        SAPProductWebService.doPost();
        Test.stopTest();
    }
}