/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-26-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-12-2025   Gerry   Initial Version
**/
@isTest
private class SAPOrderWebServiceTest {
    static testMethod void testMethod1() {
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        psi.Status__c = 'On Shelves';
        psi.Sales_Organization__c = '3010';
        psi.Delivering_Plant__c = '3010';
        psi.External_Id__c = '11111';
        Insert psi;
        Product_Name__c pn = new Product_Name__c();
        pn.Name = 'Test';
        pn.Product_Sales_Info__c = psi.Id; 
        Insert pn;
        Product_Unit__c pu = new Product_Unit__c();
        pu.Basic_Unit__c = 'L';
        pu.Product_Sales_Unit__c = 'L';
        pu.Conversion_Coefficient__c = 1;
        pu.Product__c = p.Id;
        insert pu;
        Product_Inventory__c pi = new Product_Inventory__c();
        pi.Search_Key__c = '12341234'+'-'+'5130'+'-'+'Test';
        pi.Inventory_Quantity__c = 1;
        pi.Product__c = p.Id;
        Insert pi;
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '123';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        Insert a;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.ExternalId__c = a.Id;
        insert cci;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '3010';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        insert csi;
        Price_Book__c pb = new Price_Book__c();
        pb.Name = '111';
        pb.Currency__c = 'USD';
        pb.Sales_Org__c = '5130';
        insert pb;
        Test.startTest();
        Order__c order1 = new Order__c();
        order1.SAP_Order_Code__c = '11';
        order1.SAP_Order_Code2__c = '11';
        order1.Customer__c = a.Id;
        order1.Sales_Org__c = '3010';
        order1.Distr_Channel__c = '10';
        order1.Customer_Sales_Info__c = csi.Id;
        order1.Currency__c = 'USD';
        order1.Price_Book__c = pb.Id;
        order1.Deliver_Plant__c = '3010';
        //order1.Order_type__c = 'ZARB';
        order1.Status__c = 'Approved';
        order1.Sync_Status__c = 'Synchronized';
        order1.Business_Model__c = 'B0';
        Insert order1;
        List<SAPOrderWebService.ReqOrderInfo> rbList = new List<SAPOrderWebService.ReqOrderInfo>();
        SAPOrderWebService.ReqOrderInfo rb = new SAPOrderWebService.ReqOrderInfo();
        rb.VBELN = '11';
        rb.BSTNK = '22';
        rb.KUNNR = '123';
        rb.VKORG = '5130';
        rb.VTWEG = '00';
        rb.AUART = 'ZAR1';
        rb.AUGRU = '001';
        rb.ERNAM = '11';
        rb.INCO1 = '11';
        rb.INCO2_L = '11';
        rb.ERDAT = '2020-06-11';
        rb.ERZET = '11';
        rb.WAERK = 'USD';
        List<SAPOrderWebService.OrderItemRow> brList = new List<SAPOrderWebService.OrderItemRow>();
        SAPOrderWebService.OrderItemRow br = new SAPOrderWebService.OrderItemRow();
        br.POSNR = '222';
        br.MATNR = '10';
        br.ARKTX = '10';
        br.WERKS = '3010';
        br.LGORT = 'GEN';
        br.VRKME = 'L';
        br.WMENG = 10;
        br.MWSBP = 10;
        br.NETWR = 10;
        br.AMOUNT = 10;
        brList.add(br);
        rb.ITEMS = brList;
        rbList.add(rb);
        SAPOrderWebService.feedbackOrderInfo(rbList);
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/SAPOrderWebService';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String requestContent = '{"esbinfo":{},"resultinfo":{}}';
        request.requestBody = Blob.valueOf(requestContent);
        RestContext.request = request;
        
        SAPOrderWebService.doPost();
        Test.stopTest();
        // String requestTime,Boolean status,String errorMsg,List<ReturnData> ReturnDataList
        SAPOrderWebService.returnData('',true,'error',new List<SAPOrderWebService.ReturnData>());
    }
}