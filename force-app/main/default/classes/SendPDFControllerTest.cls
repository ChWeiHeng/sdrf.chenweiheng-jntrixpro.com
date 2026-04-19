/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 12-16-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   09-23-2025   Gerry   Initial Version
**/
@isTest
private  class SendPDFControllerTest {
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
        quote1.Quotation_Type__c = 'HQ_Purchase';
        insert quote1;

        Price_List__c priceList=new Price_List__c();
        priceList.Name=quote1.Name;
        insert priceList;

        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;

        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        //psi.Factory__c = '3010';
        psi.Sales_Organization__c = '3010';
        psi.Distr_Channel__c ='10';
        psi.Delivering_Plant__c = '3010';
        Insert psi;

        Product_Name__c proName=new Product_Name__c();
        proName.Product_Sales_Info__c=psi.Id;
        insert proName;


        Quote_Name_Relationship__c qnr=new Quote_Name_Relationship__c();
        qnr.Quote_Name__c=quote1.Name;
        qnr.Products__c=p.Id;
        insert qnr;

        Quote_Detail__c quoteDetail=new Quote_Detail__c();
        quoteDetail.Quote__c = quote1.Id;
        quoteDetail.BU_Profit_Rate__c=-10;
        quoteDetail.Price_List__c=priceList.Id;
        Insert quoteDetail;

        Order__c order = new Order__c();
        order.Customer__c = a.Id;
        order.Sales_Org__c = '3010';
        order.Distr_Channel__c = '10';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';  
        order.Deliver_Plant__c = '3010';
        order.Quotes__c=quote1.Id;
        order.Business_Model__c = 'B0';
        Insert order;

        Order_Item__c orI = new Order_Item__c();
        orI.Order__c = order.Id;
        orI.Product__c = p.Id;
        orI.Product_Cost__c = 10;
        orI.Price__c=10;
        orI.Quantity__c=10;
        orI.Quote_Detail__c = quoteDetail.Id;
        orI.IsCreate__c=true;
        Insert orI;

        SendPDFController.init('');
		SendPDFController.SendPDF(order.Id);
        

    }
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
        quote1.Quotation_Type__c = 'HQ_Purchase';
        insert quote1;

        Price_List__c priceList=new Price_List__c();
        priceList.Name=quote1.Name;
        insert priceList;

        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;

        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        //psi.Factory__c = '3010';
        psi.Sales_Organization__c = '3010';
        psi.Distr_Channel__c ='10';
        psi.Delivering_Plant__c = '3010';
        Insert psi;

        Product_Name__c proName=new Product_Name__c();
        proName.Product_Sales_Info__c=psi.Id;
        insert proName;


        Quote_Name_Relationship__c qnr=new Quote_Name_Relationship__c();
        qnr.Quote_Name__c=quote1.Name;
        qnr.Products__c=p.Id;
        insert qnr;

        Quote_Detail__c quoteDetail=new Quote_Detail__c();
        quoteDetail.Quote__c = quote1.Id;
        quoteDetail.BU_Profit_Rate__c=-10;
        quoteDetail.Price_List__c=priceList.Id;
        Insert quoteDetail;

        Order__c order = new Order__c();
        order.Customer__c = a.Id;
        order.Sales_Org__c = '3010';
        order.Distr_Channel__c = '10';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';  
        order.Deliver_Plant__c = '3010';
        order.Business_Model__c = 'B0';
        Insert order;

        Order_Item__c orI = new Order_Item__c();
        orI.Order__c = order.Id;
        orI.Product__c = p.Id;
        orI.Product_Cost__c = 10;
        orI.Price__c=10;
        orI.Quantity__c=10;
        orI.Quote_Detail__c = quoteDetail.Id;
        orI.IsCreate__c=true;
        Insert orI;
        
        PDF__c p1 = new PDF__c();
        p1.logo__c = '';
        p1.Adress__c = '';
        p1.Tax__c = '';
        p1.Name = '5070';
        p1.Company_Name__c= '';
        p1.AR_Signature__c= '';
        insert p1;
        
        PDF__c p2 = new PDF__c();
        p2.logo__c = '';
        p2.Adress__c = '';
        p2.Tax__c = '';
        p2.Name = '3010_B';
        p2.Company_Name__c= '';
        p2.AR_Signature__c= '';
        insert p2;
        
        test.startTest();
		SendEmailContract.sendem(order.Id);
        SendEmailContract s = new SendEmailContract();
        test.stopTest();
    }
    static testMethod void testMethod3() {
         
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
        quote1.Quotation_Type__c = 'HQ_Purchase';
        insert quote1;

        Price_List__c priceList=new Price_List__c();
        priceList.Name=quote1.Name;
        insert priceList;

        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;

        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        //psi.Factory__c = '3010';
        psi.Sales_Organization__c = '3010';
        psi.Distr_Channel__c ='10';
        psi.Delivering_Plant__c = '3010';
        Insert psi;

        Product_Name__c proName=new Product_Name__c();
        proName.Product_Sales_Info__c=psi.Id;
        insert proName;


        Quote_Name_Relationship__c qnr=new Quote_Name_Relationship__c();
        qnr.Quote_Name__c=quote1.Name;
        qnr.Products__c=p.Id;
        insert qnr;

        Quote_Detail__c quoteDetail=new Quote_Detail__c();
        quoteDetail.Quote__c = quote1.Id;
        quoteDetail.BU_Profit_Rate__c=-10;
        quoteDetail.Price_List__c=priceList.Id;
        Insert quoteDetail;

        Order__c order = new Order__c();
        order.Customer__c = a.Id;
        order.Sales_Org__c = '3010';
        order.Distr_Channel__c = '10';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';  
        order.Deliver_Plant__c = '3010';
        order.Quotes__c = quote1.Id;
        order.Business_Model__c = 'B0';
        Insert order;

        Order_Item__c orI = new Order_Item__c();
        orI.Order__c = order.Id;
        orI.Product__c = p.Id;
        orI.Product_Cost__c = 10;
        orI.Price__c=10;
        orI.Quantity__c=10;
        orI.Quote_Detail__c = quoteDetail.Id;
        orI.IsCreate__c=true;
        Insert orI;
        
        PDF__c p1 = new PDF__c();
        p1.logo__c = '';
        p1.Adress__c = '';
        p1.Tax__c = '';
        p1.Name = '5070';
        p1.Company_Name__c= '';
        p1.AR_Signature__c= '';
        insert p1;
        
        PDF__c p2 = new PDF__c();
        p2.logo__c = '';
        p2.Adress__c = '';
        p2.Tax__c = '';
        p2.Name = '3010_B';
        p2.Company_Name__c= '';
        p2.AR_Signature__c= '';
        insert p2;
        
        test.startTest();
		SendEmailContract.sendem(order.Id);
        SendEmailContract s = new SendEmailContract();
        test.stopTest();
    }
    static testMethod void testMethod4() {
         
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
        csi.Sales_Org__c = '5070';
        csi.Distr_Channel__c = '00';
        csi.Sales_View_Status__c = 'Approved';
        csi.Sync_Status__c='Synchronized';
        csi.Customer__c = a.Id;
        csi.Division__c = '10';
        csi.Delivering_Plant__c = '5070';
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
        quote1.Quotation_Type__c = 'HQ_Purchase';
        insert quote1;

        Price_List__c priceList=new Price_List__c();
        priceList.Name=quote1.Name;
        insert priceList;

        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;

        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        //psi.Factory__c = '3010';
        psi.Sales_Organization__c = '5070';
        psi.Distr_Channel__c ='00';
        psi.Delivering_Plant__c = '5070';
        Insert psi;

        Product_Name__c proName=new Product_Name__c();
        proName.Product_Sales_Info__c=psi.Id;
        insert proName;


        Quote_Name_Relationship__c qnr=new Quote_Name_Relationship__c();
        qnr.Quote_Name__c=quote1.Name;
        qnr.Products__c=p.Id;
        insert qnr;

        Quote_Detail__c quoteDetail=new Quote_Detail__c();
        quoteDetail.Quote__c = quote1.Id;
        quoteDetail.BU_Profit_Rate__c=-10;
        quoteDetail.Price_List__c=priceList.Id;
        Insert quoteDetail;

        Order__c order = new Order__c();
        order.Customer__c = a.Id;
        order.Sales_Org__c = '5070';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';  
        order.Deliver_Plant__c = '5070';
        order.Quotes__c = quote1.Id;
        order.recordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_B').getRecordTypeId();
        order.Business_Model__c = 'B0';
        Insert order;

        Order_Item__c orI = new Order_Item__c();
        orI.Order__c = order.Id;
        orI.Product__c = p.Id;
        orI.Product_Cost__c = 10;
        orI.Price__c=10;
        orI.Quantity__c=10;
        orI.Quote_Detail__c = quoteDetail.Id;
        orI.IsCreate__c=true;
        Insert orI;
        
        PDF__c p1 = new PDF__c();
        p1.logo__c = '';
        p1.Adress__c = '';
        p1.Tax__c = '';
        p1.Name = '5070';
        p1.Company_Name__c= '';
        p1.AR_Signature__c= '';
        insert p1;
        
        PDF__c p2 = new PDF__c();
        p2.logo__c = '';
        p2.Adress__c = '';
        p2.Tax__c = '';
        p2.Name = '3010_B';
        p2.Company_Name__c= '';
        p2.AR_Signature__c= '';
        insert p2;
        
        test.startTest();
		SendEmailContract.sendem(order.Id);
        SendEmailContract s = new SendEmailContract();
        test.stopTest();
    }

    static testMethod void testMethod5() {
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
        csi.Delivering_Plant__c = '3011';
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
        quote1.Quotation_Type__c = 'HQ_Purchase';
        insert quote1;

        Price_List__c priceList=new Price_List__c();
        priceList.Name=quote1.Name;
        insert priceList;

        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;

        Product_Sales_Info__c psi = new Product_Sales_Info__c();
        psi.Product__c = p.Id;
        //psi.Factory__c = '3010';
        psi.Sales_Organization__c = '3010';
        psi.Distr_Channel__c ='10';
        psi.Delivering_Plant__c = '3010';
        Insert psi;

        Product_Name__c proName=new Product_Name__c();
        proName.Product_Sales_Info__c=psi.Id;
        insert proName;


        Quote_Name_Relationship__c qnr=new Quote_Name_Relationship__c();
        qnr.Quote_Name__c=quote1.Name;
        qnr.Products__c=p.Id;
        insert qnr;

        Quote_Detail__c quoteDetail=new Quote_Detail__c();
        quoteDetail.Quote__c = quote1.Id;
        quoteDetail.BU_Profit_Rate__c=-10;
        quoteDetail.Price_List__c=priceList.Id;
        Insert quoteDetail;

        Order__c order = new Order__c();
        order.Customer__c = a.Id;
        order.Sales_Org__c = '3010';
        order.Distr_Channel__c = '10';
        order.Customer_Sales_Info__c = csi.Id;
        order.Currency__c = 'USD';  
        order.Deliver_Plant__c = '3011';
        order.Business_Model__c = 'C1';
        Insert order;

        Order_Item__c orI = new Order_Item__c();
        orI.Order__c = order.Id;
        orI.Product__c = p.Id;
        orI.Product_Cost__c = 10;
        orI.Price__c=10;
        orI.Quantity__c=10;
        orI.Quote_Detail__c = quoteDetail.Id;
        orI.IsCreate__c=true;
        Insert orI;
        
        PDF__c p1 = new PDF__c();
        p1.logo__c = '';
        p1.Adress__c = '';
        p1.Tax__c = '';
        p1.Name = '3010';
        p1.Company_Name__c= '';
        p1.AR_Signature__c= '';
        insert p1;
        
        PDF__c p2 = new PDF__c();
        p2.logo__c = '';
        p2.Adress__c = '';
        p2.Tax__c = '';
        p2.Name = '3010_B';
        p2.Company_Name__c= '';
        p2.AR_Signature__c= '';
        insert p2;
        
        test.startTest();
		SendEmailContract.sendem(order.Id);
        SendEmailContract sec = new SendEmailContract();
        test.stopTest();
    }
    
}