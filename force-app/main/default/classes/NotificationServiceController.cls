/**************************************************************************************************
 * Name: NotificationService
 * Object: 
 * Purpose: 通知商服
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-11         Created             
***************************************************************************************************/
public without sharing class NotificationServiceController {
    
    @AuraEnabled
    public static Output notification(String accountRecordId) {
        CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
        Set<String> adminSet = new Set<String>();
        User u = [SELECT Id,Email,Sales_Org__c,Name,Country__c,Delivery_Plant__c FROM User WHERE Id=:System.UserInfo.getUserId()];
        if (u.Sales_Org__c == '3020' && u.Delivery_Plant__c == '3020') {//mx C
            adminSet.add(System.Label.MXFI);
        }
        if (u.Sales_Org__c == '3010' && u.Delivery_Plant__c == '3011') {//mx C+
            adminSet.add(System.Label.MXFIRAMX);
        }

        if (u.Sales_Org__c == '3010' && u.Delivery_Plant__c == '3010') {//mx B
            List<String> userList = System.Label.MX_B.split(';');
            adminSet.addAll(userList);
        }

        if (u.Sales_Org__c == '5130' && u.Delivery_Plant__c == '5130') {
            adminSet.add(System.Label.ARFI);
        }
        if (u.Sales_Org__c == '5070' && u.Delivery_Plant__c == '5070') {
            List<String> userList = System.Label.ARFI_B.split(';');
            adminSet.addAll(userList);
        }

        if (u.Sales_Org__c == '2100') {
            List<String> userList = System.Label.AUFI.split(';');
            adminSet.addAll(userList);
        }
        Account acc = [SELECT Id,Name FROM Account WHERE ID=:accountRecordId];
        CustomNotificationFromApex.notifyUsers(
            notificationType, 
            adminSet, //发送通知给谁
            accountRecordId, //通知点击后跳转到什么数据上
            System.Label.NotficationServiceTitle, //标题
            acc.Name+System.Label.NotficationService//内容
        );
        List<User> u1List = [SELECT Id,Email,Sales_Org__c,Name,Country__c FROM User WHERE Id IN:adminSet];
        List<String> userList = new List<String>();
        for(User uinfo : u1List) {
            userList.add(uinfo.Email);
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String body = System.Label.NotficationServiceBody;//'Sales staff request credit investigation in XXXX,please finish as soon as possible.Thanks'
        body = body.replaceAll('【提交人信息】', u.Country__c+'-'+u.Sales_Org__c+'-'+u.Name);
        body = body.replaceAll('【提交日期】', String.valueOf(Date.today()));
        body = body.replaceAll('【客户名称】', acc.Name);
        Integer index = String.valueOf(URL.getOrgDomainUrl()).indexof('=')+1;
        String recordURL = String.valueOf(URL.getOrgDomainUrl()).subString(index);
        body = body.replaceAll('【链接】',recordURL.replace(']','')+'/'+accountRecordId);
        email.setPlainTextBody(body);
        email.setSubject(System.Label.NotficationServiceTitle);
        email.setToAddresses(userList);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress];
        if (owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        // OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'rb@crm.com'];
        // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // if ( owea.size() > 0 ) {
        //     email.setOrgWideEmailAddressId(owea.get(0).Id);
        // }
        if(!Test.isRunningTest())Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = '';
        return out;
    }

    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}
    } 
}