/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 06-06-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-05-2025   Gerry   Initial Version
**/
@isTest
private class ApprovalHistoryControllerTest {


@IsTest
    static void testGetApprovalHistory() {
        // 创建测试数据
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Group_Name__c = 'test';
        acc.Customer_Approval_Status__c = 'draft';
        acc.Sync_Status__c = 'Synchronized';
        acc.MDG_Customer_Code__c = '1234';
        Insert acc;

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(acc.Id);
        req.setSubmitterId(UserInfo.getUserId());//提交人
        Approval.ProcessResult result = Approval.process(req);
        System.debug('result===>'+result);

        // 调用方法
        List<ApprovalHistoryController.ApprovalHistory> histories = ApprovalHistoryController.getApprovalHistory(acc.Id);

        
    }
}