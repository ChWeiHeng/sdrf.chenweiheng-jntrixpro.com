@isTest
private  class CreateContractLWCControllerTest {
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
        csi.Sales_Org__c = '3010';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '3010';
        //csi.Terms_Of_Payment__c = 'AR01';
        //csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        //csi.Price_Group__c = '02';
        //csi.Payment_method__c = 'Z1';
        //csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        insert csi;

        
   
	    Quote__c quote1 = new Quote__c();
        //quote1.Quotation_Type__c = 'HQ_Purchase';
        quote1.Customer__c = a.Id;
        quote1.Sales_Org__c = '3010';
        quote1.Distr_Channel__c = '10';
        quote1.Currency__c = 'USD';  
        quote1.Deliver_Plant__c = '3010';
        insert quote1;

        Price_List__c priceList=new Price_List__c();
        priceList.Name=quote1.Name;
        insert priceList;

        Quote_Detail__c quoteDetail=new Quote_Detail__c();
        quoteDetail.Quote__c = quote1.Id;
        quoteDetail.BU_Profit_Rate__c=-10;
        quoteDetail.Price_List__c=priceList.Id;
        Insert quoteDetail;

	    CreateContractLWCController.init(quote1.Id);
        CreateContractLWCController.createContract(quote1.Id,'Headquarters','');
        CreateContractLWCController.createContract(quote1.Id,'order',null);
    }
    static testMethod void testMethod2() {

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
        csi.Sales_Org__c = '3010';
        csi.Distr_Channel__c = '10';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '3010';
        //csi.Terms_Of_Payment__c = 'AR01';
        //csi.Sales_District__c = 'ZAR00';
        // csi.Inco_Location1__c = '11';
        // csi.Sales_Office__c = 'AGR1';
        // csi.Sales_Group__c = 'AG1';
        //csi.Price_Group__c = '02';
        //csi.Payment_method__c = 'Z1';
        //csi.Business_Model__c = 'C0';
        csi.Incoterms__c = '';
        insert csi;

        
   
	    Quote__c quote1 = new Quote__c();
        //quote1.Quotation_Type__c = 'HQ_Purchase';
        quote1.Customer__c = a.Id;
        quote1.Sales_Org__c = '3010';
        quote1.Distr_Channel__c = '10';
        quote1.Currency__c = 'USD';  
        quote1.Deliver_Plant__c = '3010';
        insert quote1;
        
        Quote__c quote2 = new Quote__c();
        quote2.Sales_Org__c = '5070';
        quote2.Deliver_Plant__c = '5070';
        //quote2.Quotation_Type__c = 'HQ_Purchase';
        insert quote2;
        
        Quote__c quote3 = new Quote__c();
        quote3.Sales_Org__c = '5070';
        quote3.Deliver_Plant__c = '5070';
        //quote3.Quotation_Type__c = 'Tolling';
        insert quote3;

        Price_List__c priceList=new Price_List__c();
        priceList.Name=quote1.Name;
        insert priceList;

        Quote_Detail__c quoteDetail=new Quote_Detail__c();
        quoteDetail.Quote__c = quote1.Id;
        quoteDetail.BU_Profit_Rate__c=-10;
        //quoteDetail.Price_List__c=priceList.Id;
        Insert quoteDetail;

	    CreateContractLWCController.init(quote1.Id);
        CreateContractLWCController.init(quote2.Id);
        CreateContractLWCController.init(quote3.Id);
        CreateContractLWCController.init('');
        CreateContractLWCController.createContract(quote1.Id,'Subsidiary','');
        CreateContractLWCController.createContract(quote1.Id,'order',null);
    }
}