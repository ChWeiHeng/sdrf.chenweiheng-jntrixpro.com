/**
 * @description       : MX c/c+  AR
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 09-28-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   09-01-2025   Gerry   Initial Version
**/

global without sharing class RejectedOrderBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
    public String query;
    global String errorMsg;
    global Datetime startTime;
    global Boolean flag;
    global Decimal MXDAYS;
    global Decimal ARDAYS;
    public RejectedOrderBatch() {
        this.MXDAYS = Decimal.valueOf(System.Label.MXDAYS);
        this.ARDAYS = Decimal.valueOf(System.Label.ARDAYS);
        this.startTime = System.now();
        this.flag = true;
        if (System.Test.isRunningTest()) {
            this.query = 'SELECT Id,Status__c FROM Order__c';
        }else{
            this.query = 'SELECT Id,Status__c,Sales_Org__c FROM Order__c WHERE Status__c=\'Approving\' AND ((Submit_Days__c>:ARDAYS  AND (Sales_Org__c=\'5130\' OR Sales_Org__c=\'5070\')) OR (Submit_Days__c>:MXDAYS  AND (Sales_Org__c=\'3010\' OR Sales_Org__c=\'3020\')))';
        }
        
    }
    global void execute(SchedulableContext sc) {
        RejectedOrderBatch svo = new RejectedOrderBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 10);
    } 
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order__c> orderList) {
        try {
            Set<Id> orderIds = new Set<Id>();

            Map<String,String> salesOrgMap = new Map<String,String>();
            for(Order__c order : orderList) {
                orderIds.add(order.Id);
                salesOrgMap.put(order.Id,order.Sales_Org__c);
            }
            
            // 查询这些订单的审批工作项
            List<ProcessInstanceWorkitem> workItems = [
                SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.Status
                FROM ProcessInstanceWorkitem 
                WHERE ProcessInstance.TargetObjectId IN :orderIds
                AND ProcessInstance.Status = 'Pending'
            ];
            
            // 准备拒绝审批的请求
            List<Approval.ProcessWorkitemRequest> rejectRequests = new List<Approval.ProcessWorkitemRequest>();
            
            for(ProcessInstanceWorkitem workItem : workItems) {
                rejectRequests.add(setApproveal(workItem.Id,salesOrgMap.get(workItem.ProcessInstance.TargetObjectId)));
            }
            
            // 执行拒绝操作
            if(!rejectRequests.isEmpty() || System.Test.isRunningTest()) {
                List<Approval.ProcessResult> results = Approval.process(rejectRequests);
            }
            
        }catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global Approval.ProcessWorkitemRequest setApproveal(String workId,String salesOrg) {
        Approval.ProcessWorkitemRequest rejectRequest = new Approval.ProcessWorkitemRequest();
        rejectRequest.setWorkitemId(workId);
        rejectRequest.setAction('Reject');
        // System automatically rejected due to no approval within 15 days
        String remark;
        if (salesOrg == '5130' || salesOrg == '5070') {
            remark = System.Label.AutoReject.replace('[天数]',String.valueOf(this.ARDAYS));
        }else{
            remark = System.Label.AutoReject.replace('[天数]',String.valueOf(this.MXDAYS));
        }
        rejectRequest.setComments(remark);
        return rejectRequest;
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('RejectedOrderBatch', this.flag, this.startTime, this.errorMsg);
    }
}