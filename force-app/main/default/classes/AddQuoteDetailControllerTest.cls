@isTest
private class AddQuoteDetailControllerTest {
    static testMethod void testMethod1() {
       
        
        Account a = new Account();
        a.Name = 'Test';
        a.Group_Name__c = 'test';
        a.MDG_Customer_Code__c = '111';
        a.Customer_Approval_Status__c = 'Approved';
        a.Sync_Status__c = 'Synchronized';
        Insert a;

        Customer_Shipping_Address__c csa = new Customer_Shipping_Address__c();
        csa.Customer__c = a.Id;
        csa.Direction__c = '111';
        insert csa;
        Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
        cci.Customer__c = a.Id;
        cci.Rules__c = 'STANDARD';
        cci.Risk_Class__c = 'A';
        cci.Check_Rule__c = 'OV1';
        cci.Credit_Segment__c = 'Z000';
        cci.Valid_Until__c = Date.today();
        cci.Sinosure_Credit_Limit__c = 2;
        cci.Local_Credit_Limit__c = 2;
        cci.Actual_Credit_limit__c = 2;
        cci.Sync_Status__c = 'Synchronized';
        cci.Remaining_Credit__c = 2;
        cci.ExternalId__c = '1111';
        insert cci;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Acct_Assmt_Grp_Cust__c='01';
        csi.Sales_View_Status__c = 'Approved';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5130';
        csi.Terms_Of_Payment__c = 'AR01';
        csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        csi.Price_Group__c = '02';
        csi.Payment_method__c = 'Z1';
        csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        insert csi;

        Quote__c quote = new Quote__c();
        //quote.Name = '报价测试';
        quote.Quotation_Type__c = 'HQ_Purchase';
        insert quote;

        

        Quote__c quote1 = new Quote__c();
        //quote1.Name = '报价测试';
        quote1.Quotation_Type__c = 'HQ_Purchase';
        insert quote1;

        Quote_Detail__c quoteDetail=new Quote_Detail__c();
        quoteDetail.Quote__c = quote.Id;
        quoteDetail.BU_Profit_Rate__c=-10;
        Insert quoteDetail;

        Price_List__c priceList=new Price_List__c();
        priceList.Name=quote.Name;
        insert priceList;

        Contract_Processing_Product__c cpp=new Contract_Processing_Product__c();
        cpp.Name=quote.Name;
        insert cpp;
   
        AddQuoteDetailController.initData(quote.Id);
        AddQuoteDetailController.initData('');
        AddQuoteDetailController.searchDataMe('',true);
        AddQuoteDetailController.searchDataMe('',false);
        List<AddQuoteDetailController.QuoteDetail> quoteDetailList=new List<AddQuoteDetailController.QuoteDetail>();
        AddQuoteDetailController.QuoteDetail qd=new AddQuoteDetailController.QuoteDetail();
        qd.quoteDetailData=quoteDetail;
        quoteDetailList.add(qd);
        AddQuoteDetailController.saveData(quoteDetailList,new List<String>{quote1.Id});

        quote.Approval_Status__c='Approved';
        update quote;
    }
}