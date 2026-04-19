/**************************************************************************************************
 * Name: FOBNotificationBatch
 * Object: 
 * Purpose: 定时FOB价格变动通知
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-10-20         Created             
***************************************************************************************************/

global class FOBNotificationSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        notification();
    }

    global static void notification() {
        List<Price_List__c> plList = [SELECT Id FROM Price_List__c WHERE Change_Date__c >= TODAY];
        if (plList.size()>0) {
            CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
            List<String> emailCCList = new List<String>();
            Set<String> adminSet = new Set<String>();
            for (User u : [SELECT Id,Email FROM User WHERE ((Delivery_Plant__c ='5070' OR Delivery_Plant__c ='3010')) OR id='005D5000004L319IAC']) {
                emailCCList.add(u.Email);
                adminSet.add(u.Id);
            }

            List<ListView> lvList = [SELECT Id,Name FROM ListView WHERE SobjectType ='Price_List__c' AND Name='Change List'];
            CustomNotificationFromApex.notifyUsers(
                notificationType, 
                adminSet, //发送通知给谁
                plList[0].Id, //通知点击后跳转到什么数据上
                System.Label.FOBNotificationSubject, //标题
                System.Label.FOBNotificationBody//内容
            );

            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

            email.setPlainTextBody(System.Label.FOBNotificationBody);
            email.setSubject(order.Name+System.Label.FOBNotificationSubject);
            email.setToAddresses(emailCCList);
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress];
            if (owea.size() > 0 ) {
                 email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            if (!System.Test.isRunningTest()) {
                Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
            }
        }
    }
}