/**
 * @description       : 审批历史控制类
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 06-06-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-05-2025   Gerry   Initial Version
**/
public without sharing class ApprovalHistoryController {
    @AuraEnabled(cacheable=true)
    public static List<ApprovalHistory> getApprovalHistory(String recordId) {
        if (!Test.isRunningTest()) {
            ProcessInstanceWorkitem pi = [SELECT Id,ProcessInstance.TargetObjectId FROm ProcessInstanceWorkitem WHERE Id=:recordId];
            String type = pi.ProcessInstance.TargetObjectId.getSObjectType().getDescribe().getName();
            System.debug('type:'+type);
            System.debug('oderId:'+pi.ProcessInstance.TargetObjectId);
            recordId = pi.ProcessInstance.TargetObjectId;
        }
        
        List<ApprovalHistory> histories = new List<ApprovalHistory>();
        
        // 查询审批实例及步骤
        List<ProcessInstance> instances = [
            SELECT Id, TargetObjectId, Status, CreatedDate,
                (SELECT Id, StepStatus, Comments, Actor.Name, 
                 OriginalActor.Name, CreatedDate, ProcessNode.Name 
                 FROM StepsAndWorkitems 
                 ORDER BY CreatedDate DESC,StepStatus desc)
            FROM ProcessInstance 
            WHERE TargetObjectId = :recordId
            ORDER BY CreatedDate DESC
        ];
        
        // 构建返回数据
        for (ProcessInstance instance : instances) {
            for (ProcessInstanceHistory step : instance.StepsAndWorkitems) {
                ApprovalHistory history = new ApprovalHistory();
                history.stepName = step.ProcessNode.Name;
                history.status = step.StepStatus;
                history.comments = step.Comments;
                history.actor = step.Actor.Name;
                history.originalActor = step.OriginalActor?.Name; // 安全访问
                history.createdDate = step.CreatedDate;
                histories.add(history);
            }
        }
        return histories;
    }
    
    // 审批历史数据结构
    public class ApprovalHistory {
        @AuraEnabled public String stepName;
        @AuraEnabled public String status;
        @AuraEnabled public String comments;
        @AuraEnabled public String actor;
        @AuraEnabled public String originalActor;
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public String icon;
        @AuraEnabled public String statusClass;
    }
}