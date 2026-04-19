/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-27-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-27-2025   Gerry   Initial Version
**/
public without sharing class QuoteTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isBefore && (Trigger.isupdate || Trigger.isinsert)) {
            //List<Profile> adminPro = [SELECT Id FROM Profile WHERE Id=:UserInfo.getProfileId() AND  (Name='Interface Profile' OR Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema') limit 1];
            Set<String> paymentTermSet = new Set<String>();
            List<Quote__c> quoteList = (List<Quote__c>)Trigger.new;
            for (Quote__c quote : quoteList) 
            {
                if(quote.Payment_Term__c != null)
                {
                    paymentTermSet.add(quote.Payment_Term__c);
                }
            }
            Map<String,Payment_Rate__c> paymentRateMap = new Map<String,Payment_Rate__c>();
            for(Payment_Rate__c payRate:[SELECT Id,Name,Payment_Term_Cost_Rate__c FROM Payment_Rate__c WHERE Name IN:paymentTermSet])
            {
                paymentRateMap.put(payRate.Name,payRate);
            }
            for (Quote__c quote : (List<Quote__c>)Trigger.new) 
            {
                if(quote.Approval_Status__c=='Draft')
                {       
                    if (paymentRateMap.get(quote.Payment_Term__c) == null) 
                    {
                        //quote.addError('Quote Payment_Term Not Map Payment_Rate__c Data');
                        quote.Payment_Term_Cost_Rate__c =1;
                    }
                    else
                    {
                        quote.Payment_Term_Cost_Rate__c = paymentRateMap.get(quote.Payment_Term__c).Payment_Term_Cost_Rate__c;
                    }
                }
            }
            
        }
        
        if (Trigger.isBefore && Trigger.isupdate) {
            Map<Id,Quote__c> oldMap = (Map<Id,Quote__c>)Trigger.oldMap;
            for (Quote__c quote : (List<Quote__c>)Trigger.new) {
                if (oldMap.get(quote.Id).Status__c == 'Confirmed' && quote.Status__c != 'Canceled' && oldMap.get(quote.Id).Status__c!=quote.Status__c) {
                    //quote.addError('Status__c Is Comfirmed,Not Change Status__c');
                    quote.addError(System.Label.QuoteChangeStatusError);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isinsert) {
            Set<String> accSet = new Set<String>();
            Set<String> salesOrgSet = new Set<String>();
            Set<String> accSalesOrgSet = new Set<String>();
            for (Quote__c quote : (List<Quote__c>)Trigger.new) {
                accSet.add(quote.Customer__c);
                salesOrgSet.add(quote.Sales_Org__c);
            }
            for(Customer_Sales_Info__c csi :[SELECT Id,Customer__c,Sales_Org__c FROM Customer_Sales_Info__c WHERE Customer__c IN:accSet AND Sales_Org__c IN:salesOrgSet AND Is_Freeze__c='01'])
            {
                accSalesOrgSet.add(csi.Customer__c+'_'+csi.Sales_Org__c);
            }
            System.debug('accSalesOrgSet=>'+accSalesOrgSet);
            for (Quote__c quote : (List<Quote__c>)Trigger.new) {
                if (accSalesOrgSet != null && accSalesOrgSet.contains(quote.Customer__c+'_'+quote.Sales_Org__c)) {
                    quote.addError(System.Label.AccFreezeError);
                }
            }
        }
        if (Trigger.isAfter && Trigger.isInsert) 
        {
            // 共享数据到客户小组
            for (Quote__c quote : (List<Quote__c>)Trigger.new) {
                ShareDataToAccountTeam.shareData('Quote__c', quote.Id, quote.Customer__c, 'Quote__c',quote.OwnerId);
            }
        }
        if (Trigger.isAfter && Trigger.isupdate)
        {
            Map<Id,Quote__c> oldMap = (Map<Id,Quote__c>)Trigger.oldMap;
            for (Quote__c quote : (List<Quote__c>)Trigger.new) {
                Set<String> uSet = new Set<String>();
                uSet.add(quote.OwnerId);
                if (quote.Quotation_Type__c=='HQ_Purchase' && quote.Is_Approval__c>0 && quote.Approval_Status__c=='Approved' && oldMap.get(quote.Id).Approval_Status__c != quote.Approval_Status__c) 
                {
                    String body = '<div>'+System.Label.QuoteApprovalBody+'<br/><br/><br/>'+System.Label.QuoteApprovalBodyLocal+'</div>';
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    body = body.replaceAll('【报价单号】', quote.Name);
                    Integer index = String.valueOf(URL.getOrgDomainUrl()).indexof('=')+1;
                    String recordURL = String.valueOf(URL.getOrgDomainUrl()).subString(index);
                    body = body.replaceAll('【链接】',recordURL.replace(']','')+'/'+quote.Id);
                    email.setHtmlBody(body);
                    email.setSubject(System.Label.Quote_Approval_Title+quote.Name);
                    List<String> emailList = new List<String>();
                    for(String userEmail:System.Label.QuoteApprovalNoticeEmail.split(';'))
                    {
                        if(userEmail != null)
                        {
                            emailList.add(userEmail);
                        }
                    }
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress];
                    if (owea.size() > 0 ) {
                           email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    email.setToAddresses(emailList);
                    //if(!Test.isRunningTest())Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                }
                //审批结果通知
                if(quote.Approval_Status__c == 'Approved' && quote.Approval_Status__c!=oldMap.get(quote.Id).Approval_Status__c) {
                    Utility.notificationUserTitle(uSet,quote.Id,System.Label.Quote_Approved_Title,System.Label.Quote_Approved_Title+quote.Name);
                }
                
                if(quote.Approval_Status__c == 'Rejected' && quote.Approval_Status__c!=oldMap.get(quote.Id).Approval_Status__c) {
                    Utility.notificationUserTitle(uSet,quote.Id,System.Label.Quote_Rejected_Title,System.Label.Quote_Rejected_Title+quote.Name);
                }

                //报价为3020时并且没有负毛利时知会lary
                if(
                    quote.Approval_Status__c == 'Approved' && 
                    quote.Approval_Status__c!=oldMap.get(quote.Id).Approval_Status__c && 
                    (quote.Customer_MDG_Code__c == '0000003020' || quote.Customer_MDG_Code__c == '0000003011') &&
                    quote.Is_Approval__c == 0
                ) {
                    Set<String> lary = new Set<String>();
                    User u = [SELECT Id FROM User WHERE Username='laryfan@rainbowagro.com.rbdev' OR Username='laryfan@rainbowagro.com' limit 1];
                    lary.add(u.Id);
                    Utility.notificationUserTitle(lary,quote.Id,System.Label.BTOCTitle,System.Label.BTOCBody+quote.Name);
                }
            }
            for (Quote__c quote : (List<Quote__c>)Trigger.new) {
                if(oldMap.get(quote.Id).Deliver_Plant__c !=quote.Deliver_Plant__c) {
                    system.debug('变更工厂');
                Database.executeBatch(new ChangeShareDataToAccountTeamBatch('Quote__c', quote.Id, quote.Customer__c, 'Quote__c',quote.OwnerId,oldMap.get(quote.Id).Deliver_Plant__c,'Quote__share'));
                }}
        }

    }
}