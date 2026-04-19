/**
 * @description       : 客户审批通知，每天运行一次。超24小时
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 12-11-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   12-11-2025   Gerry   Initial Version
**/
global without sharing class NotificationFinanceCustomerUpdateBatch implements Database.Batchable<sObject>,Database.Stateful{
    public String query;
    public String filedStr;
    public String type;
    public Date closeDate;
    global Boolean flag;
    global String errorMsg;
    global Datetime startTime;
    global NotificationFinanceCustomerUpdateBatch() {
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT Id,Finance_User__r.Email FROM Customer_Update__c WHERE Finance_Approved__c=false AND Finance_Start_Approve__c!=null AND Approve_Status__c=\'Approving\' AND PendingDays__c>=1';
    }

    global void execute(SchedulableContext sc) {
        NotificationFinanceCustomerUpdateBatch svo = new NotificationFinanceCustomerUpdateBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 5);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Customer_Update__c> cuList) {
        try {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for (Customer_Update__c cu : cuList) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String body = System.Label.CustomerUpdateNotification;
                Integer index = String.valueOf(URL.getOrgDomainUrl()).indexof('=')+1;
                String recordURL = String.valueOf(URL.getOrgDomainUrl()).subString(index);
                body += recordURL.replace(']','')+'/'+cu.Id;
                email.setPlainTextBody(body);
                email.setSubject(System.Label.CustomerApprovalNotification);
                email.setToAddresses(new List<String>{cu.Finance_User__r.Email});
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress];
                if (owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                emails.add(email);
            } 
            if(!Test.isRunningTest())Messaging.sendEmail(emails);
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('NotificationFinanceCustomerUpdateBatch', this.flag, this.startTime, this.errorMsg);
    }
}