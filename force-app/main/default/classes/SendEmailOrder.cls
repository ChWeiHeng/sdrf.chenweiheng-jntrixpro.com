/**************************************************************************************************
 * Name: SendEmailOrder
 * Object: 
 * Purpose: 发送订单邮件功能类
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-08-14         Created             
***************************************************************************************************/
public without sharing class SendEmailOrder {
    public final Order__c order {get;set;} 
    public final List<Order_Item__c> orderItem {get;set;}
    public final String imageUrl {get;set;} 
    public final String companyName {get;set;} 
    public final String companyAddress {get;set;} 
    public final String INCOTERM {get;set;} 
    public final List<String> specialClause {get;set;} 
    public final String tax {get;set;} 
    public final String PDFRight {get;set;} 
    public final String PDFLeft {get;set;} 
    public SendEmailOrder() {
        
        specialClause = System.Label.Special_Clause.split(';');
        if (System.Test.isRunningTest()) {
            order = [
                    SELECT 
                        CreatedDate_Text__c,Remark__c,Total_Tax__c,Total_Amount_Tax__c,
                        Sales_Org__c,
                        Total_Amount__c,
                        Customer__r.Name,
                        Name,
                        Approve_Date__c,
                        Customer__r.MDG_Customer_Code__c,
                        Customer__r.Tax_Number__c,
                        Customer_Shipping_Address__r.Direction__c,Deliver_Plant__c,
                        Inco_Location1__c,Incoterms__c,Cust_Reference__c,Currency__c,Terms_Of_Payment__c,CreatedDate 
                    FROM 
                        Order__c
                ];
        }else{
            order = [
                    SELECT 
                        CreatedDate_Text__c,Remark__c,Total_Tax__c,Total_Amount_Tax__c,
                        Sales_Org__c,
                        Total_Amount__c,
                        Customer__r.Name,
                        Name,
                        Approve_Date__c,
                        Customer__r.MDG_Customer_Code__c,
                        Customer__r.Tax_Number__c,
                        Customer_Shipping_Address__r.Direction__c,Deliver_Plant__c,
                        Shipping_Address_Text__c,Inco_Location1__c,Incoterms__c,Cust_Reference__c,Currency__c,Terms_Of_Payment__c,CreatedDate 
                    FROM 
                        Order__c
                    WHERE Id = :ApexPages.currentPage().getParameters().get('id')
                ];
        }
        
        order.Remark__c = spliteStringToList(order.Remark__c);
        PDF__c pdf;
        Boolean flag = false;
        if (order.Sales_Org__c == '3010' && order.Deliver_Plant__c == '3011') {
            pdf = PDF__c.getValues('3010');
            flag = true;
        }
        if (order.Sales_Org__c == '3020' && order.Deliver_Plant__c == '3020') {
            pdf = PDF__c.getValues('3020');
            flag = true;
        }
        if (order.Sales_Org__c == '5130' && order.Deliver_Plant__c == '5130') {
            pdf = PDF__c.getValues('5130');
            flag = true;
        }

        String first = order.Incoterms__c==null?'':order.Incoterms__c;
        INCOTERM = first+','+order.Inco_Location1__c==null?'':order.Inco_Location1__c;
        if(flag) {
            companyName = pdf.Company_Name__c;
            imageUrl = pdf.logo__c;
            companyAddress = pdf.Adress__c;
            tax = pdf.Tax__c;
        }
        
        PDFRight = System.Label.PDFRight;
        PDFLeft = System.Label.PDFLeft;
        orderItem = [SELECT Name,Id,Amount_per_item__c,SAP_Total_Tax__c,Sales_Unit_Text__c,Delivery_Date_Text__c,
                            Commodity__c,
                            Delivery_Date__c,
                            Material_Number__c,
                            Price__c,
                            Quantity__c,
                            Sales_Unit__c,
                            Commodity__r.Product__r.Name,
                            Order__r.Currency__c,
                            SAP_Item_Num__c,
                            Basic_Number__c,
                            Material_Description__c,
                            Price_Book_Item__c,
                            Crop__c,
                            Product_Usage__c,
                            Depend_On_Item__c,
                            Guide_Price__c,
                            Price_Rate_User__c FROM Order_Item__c
                   WHERE Order__c = :ApexPages.currentPage().getParameters().get('id')];
        for (Order_Item__c oi : orderItem) {
            oi.Material_Number__c = oi.Material_Number__c.subString(6);
        }
    }

    @Future(callout=true)
    public static void sendem(String orderId) {
        Order__c order = [SELECT Id,Name,User_Country__c,Email__c,Owner.Email,Sales_Org__c,Deliver_Plant__c  FROM Order__c WHERE Id=:orderId];
        //Model B订单直接返回 不发送PDF start
        if (order.Sales_Org__c == '5070' && order.Deliver_Plant__c == '5070') {
            return;
        }
        if (order.Sales_Org__c == '3010' && order.Deliver_Plant__c == '3010') {
            return;
        }
        //Model B订单直接返回 不发送PDF end
        
        // if (order.Email__c == null) {
        //     return;
        // }
        // List<String> emailList = new List<String>();
        // emailList.addall(order.Email__c.split(';'));
        List<String> emailCCList = new List<String>{order.Owner.Email};
        
        // Define the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

        // Reference the attachment page and pass in the account ID
        PageReference pdf;
        pdf =  Page.attachmentPDFMX;
        
        
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

        email.setPlainTextBody(System.Label.EmailBody);
        email.setSubject(order.Name+System.Label.EmailSubject);
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
    public String spliteStringToList(String s){
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
    }
}