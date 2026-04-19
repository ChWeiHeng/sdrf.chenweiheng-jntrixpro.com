@IsTest
private class CustomNotificationFromApexTest {
    static testMethod void testMock(){
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
        Set<String> adminSet = new Set<String>();
        adminSet.add(System.UserInfo.getUserId());
        CustomNotificationFromApex.notifyUsers(
            notificationType, 
            adminSet, //发送通知给谁
            p.Id, //通知点击后跳转到什么数据上
            '取证信息同步验证平台系统失败', //标题
            '请点击查看取证信息'//内容
        );
    }
}