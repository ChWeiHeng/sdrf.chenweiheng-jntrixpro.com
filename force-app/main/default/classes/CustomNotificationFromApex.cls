/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 2022-04-22
 * @last modified by  : Gerry
**/
public without sharing class CustomNotificationFromApex {
	/*
	Name: getNotificationTypeFlowAction
	Author: Gerry 
	Create Date: 2022-04-22
	Function: 发送自定义消息
	Params:
		String message : 通知内容
		String contactId : 联系人Id
	Return:
		HTTPResponse
	*/ 
	// @InvocableMethod(label='获取自定义通知类型Id')   
	// public static List<String> getNotificationTypeFlowAction(List<Input> inputList) {
	// 	List<String> outputList = new List<String>();
	// 	for(Input inputItem : inputList) {
	// 		String outputItem = getNotificationType(inputItem.developerName).Id;
	// 		outputList.add(outputItem);
	// 	}
	// 	return outputList;
	// }
    // public static CustomNotificationType getNotificationType(String developerName) {
    //     return [
    //         SELECT 
    //             Id,
    //             DeveloperName 
    //         FROM CustomNotificationType 
    //         WHERE
    //             DeveloperName =: developerName];
    // }
    public static void notifyUsers(CustomNotificationType notificationType, Set<String> recipientsIds, String targetId,String title,String body) {
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle(title);
        notification.setBody(body);

        //Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        // Actually send the notification
        notification.send(recipientsIds);
     }

    // public class Input {
    //     @AuraEnabled
    //     @InvocableVariable(label='通知消息DeveloperName' description='通知消息DeveloperName' required=true)
    //     public String developerName;
    // }

    // CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
    // Set<String> adminSet = new Set<String>();
    // adminSet.addAll('005D600000C0PlCIAV');
    // CustomNotificationFromApex.notifyUsers(
    //     notificationType, 
    //     adminSet, //发送通知给谁
    //     voeList[0].Id, //通知点击后跳转到什么数据上
    //     '取证信息同步验证平台系统失败', //标题
    //     '请点击查看取证信息'//内容
    // );
}