/**************************************************************************************************
 * Name: SendEmailContract
 * Object: 
 * Purpose: 发送合同邮件功能类
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Noel             2024-10-29         Created             
***************************************************************************************************/
public without sharing class SendEmailContract {
   public final Order__c order {get;set;} 
    public final List<Order_Item__c> orderItem {get;set;}
    public final String imageUrl {get;set;}
    public final String imageSignature {get;set;} 
    public final String companyName {get;set;} 
    public final String companyAddress {get;set;}
    public final String tel {get;set;}
    public final String INCOTERM {get;set;} 
    public final List<String> specialClause {get;set;} 
    public final String tax {get;set;} 
    public final String PDFRight {get;set;} 
    public final String PDFLeft {get;set;}
    public final Boolean IsSales {get;set;} 
    public final Boolean IsAR {get;set;} 
    public final String FileDate {get;set;}
    public final String TermsOfPayment {get;set;}
    public final Boolean IsModelC {get;set;}
    public SendEmailContract() {
        if (System.Test.isRunningTest()) {
            order = [
                    SELECT 
                        CreatedDate_Text__c,Remark__c,Total_Tax__c,Total_Amount_Tax__c,
                        Sales_Org__c,
                        Total_Amount__c,
                        Customer_Address__c,
                        Customer__r.Name,
                        Name,File_Date__c,
                        Approve_Date__c,
                        Customer__r.MDG_Customer_Code__c,
                        Customer__r.Tax_Number__c,
                        Customer_Shipping_Address__r.Direction__c,Deliver_Plant__c,SAP_Order_Code__c,
                        Inco_Location1__c,Incoterms__c,Cust_Reference__c,Currency__c,Terms_Of_Payment__c,CreatedDate,Quotes__c,Quotes__r.Quotation_Type__c 
                    FROM 
                        Order__c
                ];
        }else{
            order = [
                    SELECT 
                        CreatedDate_Text__c,Remark__c,Total_Tax__c,Total_Amount_Tax__c,
                        Sales_Org__c,
                        Total_Amount__c,
                        Customer_Address__c,
                        Customer__r.Name,
                        Name,File_Date__c,
                        Approve_Date__c,
                        Customer__r.MDG_Customer_Code__c,
                        Customer__r.Tax_Number__c,
                        Customer_Shipping_Address__r.Direction__c,Deliver_Plant__c,SAP_Order_Code__c,
                        Shipping_Address_Text__c,Inco_Location1__c,Incoterms__c,Cust_Reference__c,Currency__c,Terms_Of_Payment__c,CreatedDate,Quotes__c,Quotes__r.Quotation_Type__c
                    FROM 
                        Order__c
                    WHERE Id = :ApexPages.currentPage().getParameters().get('id')
                ];
        }

        if (order.Sales_Org__c == '3010' && order.Deliver_Plant__c == '3011') {
            IsModelC = true;
        }else{
            IsModelC = false;
        }

        if(order.File_Date__c != null)
        {
            FileDate=string.valueOf(order.File_Date__c);
        }
        if (order.Sales_Org__c == '5070')
        {
            IsAR=true;
        }else{
            IsAR=false;
        }

        system.debug('IsAR=>'+IsAR);
        Map<String, String> paymentMap =Utility.getPicklistValueMap('Order__c', 'Terms_Of_Payment__c');
        Map<String, String> proUsage =Utility.getPicklistValueMap('Order_Item__c', 'Product_Usage__c');
        if(paymentMap.get(order.Terms_Of_Payment__c) != null && paymentMap.get(order.Terms_Of_Payment__c).length()>4)
        {
            TermsOfPayment=paymentMap.get(order.Terms_Of_Payment__c).substring(4);
        }else{
            TermsOfPayment=paymentMap.get(order.Terms_Of_Payment__c);
        }
        
        //if(TermsOfPayment != null && TermsOfPayment.length()>4){TermsOfPayment=TermsOfPayment.substring(4);}
        system.debug('TermsOfPayment'+TermsOfPayment);
        //order.Remark__c = spliteStringToList(order.Remark__c);
        PDF__c pdf;
        Boolean flag = false;
        if (order.Sales_Org__c == '5070') {
            pdf = PDF__c.getValues('5070');
            flag = true;
        }
        if (order.Sales_Org__c == '3010' && order.Deliver_Plant__c == '3010') {
            pdf = PDF__c.getValues('3010_B');
            flag = true;
        }

        if (order.Sales_Org__c == '3010' && order.Deliver_Plant__c == '3011') {
            pdf = PDF__c.getValues('3010');
            flag = true;
        }
        // first = order.Incoterms__c==null?'':order.Incoterms__c;
        //INCOTERM = first+','+order.Inco_Location1__c==null?'':order.Inco_Location1__c;
        if(flag) {
            companyName = pdf.Company_Name__c;
            imageUrl = pdf.logo__c;
            tel=pdf.Tel__c;
            if(IsAR)
            {
                imageSignature= pdf.AR_Signature__c;
            }else{
                imageSignature= pdf.MX_Signature__c;
            }
            
            companyAddress = pdf.Adress__c;
            tax = pdf.Tax__c;
        }
        system.debug('imageSignature=>'+imageSignature);
        
        PDFRight = System.Label.PDFRight;
        PDFLeft = System.Label.PDFLeft;
         if(order.Quotes__c != null && order.Quotes__r.Quotation_Type__c=='HQ_Purchase' && order.Sales_Org__c=='3010')
        {
            IsSales=true;
            specialClause = System.Label.Special_Clause_Contract4.split(';');
            if(order.Incoterms__c=='CIF')
            {
                specialClause.addALL(System.Label.Special_Clause_Contract5.split(';'));
            }
            if(order.Incoterms__c=='DAP')
            {
                specialClause.addALL(System.Label.Special_Clause_Contract6.split(';'));
            }
            if(order.Incoterms__c=='DDP')
            {
                specialClause.addALL(System.Label.Special_Clause_Contract7.split(';'));
            }
            
        }else if(order.Quotes__c != null && order.Quotes__r.Quotation_Type__c=='HQ_Purchase' && order.Sales_Org__c=='5070'){
            IsSales=true;
            specialClause = System.Label.Special_Clause_Contract8.split(';');
            //String replaceFileDate=System.Label.Special_Clause_Contract9;
            //replaceFileDate = replaceFileDate.replaceAll('FileDate', FileDate);
            specialClause.addALL(System.Label.Special_Clause_Contract9.split(';'));
        } else if(order.Quotes__c != null && order.Quotes__r.Quotation_Type__c=='Tolling' && order.Sales_Org__c=='5070'){
            IsSales=false;
            //specialClause = System.Label.Special_Clause_Contract.split(';');
            specialClause=System.Label.Special_Clause_Contract1.split(';');
            //specialClause.addALL(System.Label.Special_Clause_Contract2.split(';'));
            //String replaceFileDate=System.Label.Special_Clause_Contract3;
            //String replaceCompanyName=System.Label.Special_Clause_Contract2;
            //replaceFileDate = replaceFileDate.replaceAll('FileDate', FileDate);
            //replaceCompanyName = replaceCompanyName.replaceAll('CompanyName', companyName);
            specialClause.addALL(System.Label.Special_Clause_Contract2.split(';'));
            specialClause.addALL(System.Label.Special_Clause_Contract3.split(';'));
        }else if (order.Quotes__c == null && order.Sales_Org__c=='3010' && order.Deliver_Plant__c == '3011') {
            IsSales=false;
            //specialClause = System.Label.Special_Clause_Contract.split(';');
            specialClause=System.Label.MXMODELCPLUS.split(';');
            if(order.Incoterms__c=='CIF')
            {
                specialClause.add(System.Label.Special_Clause_Contract5_Model_C.replace('3.','4.'));
            }
            if(order.Incoterms__c=='DAP')
            {
                specialClause.add(System.Label.Special_Clause_Contract6_Model_C.replace('3.','4.'));
            }
            if(order.Incoterms__c=='DDP')
            {
                specialClause.add(System.Label.Special_Clause_Contract7_Model_C.replace('3.','4.'));
            }
        }
        orderItem = [SELECT Commodity__r.Product_Sales_Info__r.Product__r.Spanish_Description__c,
                            Name,Id,Amount_per_item__c,SAP_Total_Tax__c,Sales_Unit_Text__c,Delivery_Date_Text__c,
                            Commodity__c,
                            Commodity__r.Name,
                            Delivery_Date__c,
                            Delivery_Quantity__c,
                            isClosed__c,
                            Material_Number__c,
                            Price__c,
                            OPTAX__c,
                            IEPS__c,
                            Quantity__c,
                            Sales_Unit__c,
                            Commodity__r.Product__r.Name,
                            Order__r.Currency__c,
                            SAP_Item_Num__c,
                            Basic_Number__c,
                            Material_Description__c,
                            Price_Book_Item__c,
                            Crop__c,
                            Product__r.Name,
                            Product_Description__c,
                            Product_Usage__c,
                            Inventory_Location__c,
                            Depend_On_Item__c,
                            Guide_Price__c,Quote_Detail__r.Packing_Size__r.Name,Quote_Detail__r.Quote_Product_Name__c,
                            Price_Rate_User__c,ETA__c FROM Order_Item__c
                   WHERE Order__c = :ApexPages.currentPage().getParameters().get('id') AND (isClosed__c=false OR (isClosed__c=true AND Delivery_Quantity__c != 0 AND Delivery_Quantity__c != null)) ];
        for (Order_Item__c oi : orderItem) {
            oi.Product_Usage__c=proUsage.get(oi.Product_Usage__c);
            if(oi.isClosed__c && oi.Delivery_Quantity__c != 0 && oi.Delivery_Quantity__c != null)
            {
                oi.Quantity__c=oi.Delivery_Quantity__c;
            }
            //oi.Material_Number__c = oi.Material_Number__c.subString(6);
        }
    }

    public static void sendemTiming(String orderId) {
        SendEmailContract.sendem(orderId);
    }

    @Future(callout=true)
    public static void sendem(String orderId) {
        Order__c order = [SELECT Id,Name,Owner.Email,Sales_Org__c,Deliver_Plant__c  FROM Order__c WHERE Id=:orderId];
        List<String> emailCCList = new List<String>{order.Owner.Email};
        
        // Define the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

        // Reference the attachment page and pass in the account ID
        PageReference pdf;
        pdf =  Page.attachmentPDFContracts;
        
        
        pdf.getParameters().put('id',orderId); 
        pdf.setRedirect(true);

        // Take the PDF content
        Blob b;
        if (!System.Test.isRunningTest()) {
             b = pdf.getContent();
        }
       

        // Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(order.Name+'Order.pdf');
        if (!System.Test.isRunningTest()) {
            efa.setBody(b);
        }

        
        if (order.Sales_Org__c == '3010' && order.Deliver_Plant__c == '3011') {
            email.setSubject(order.Name+System.Label.EmailSubject);
            email.setPlainTextBody(System.Label.EmailBody);
        }else{
            email.setSubject(order.Name+System.Label.EmailSubjectContract);
            email.setPlainTextBody(System.Label.EmailBodyContract);
        }
        
        // email.setToAddresses(emailList);
        email.setToAddresses(emailCCList);
        // email.setCcAddresses(emailCCList);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        // OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'rb@crm.com'];
        // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // if ( owea.size() > 0 ) {
        //     email.setOrgWideEmailAddressId(owea.get(0).Id);
        // }
        // Sends the email
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress];
        if (owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        if (!System.Test.isRunningTest()) {
            Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        }
        
		System.debug('已经发送邮件');
        // return null;
    }

    /*自动换行控制*/
    /*public String spliteStringToList(String s){
        // s = s.trim();
        // 
        String res = '';
        if (s == null) {
            
            return '';
        }

        // s = s.replaceAll(' ', '');
        for(Integer i=0;i<s.length();i++){
            if (String.isBlank(res)) {
                res+= s.Substring(i,i+1);
            }else{
                res+= '<wbr/>'+s.Substring(i,i+1);
            }
        }
        return res;
    }*/
}