public without sharing class CompanyDynamicsTriggerHandler  implements Triggers.Handler{
    public void handle() {
        // 共享数据到客户小组
        if (Trigger.isAfter && (Trigger.isinsert || Trigger.isupdate)) {
            for (Company_Dynamics__c order : (List<Company_Dynamics__c>)Trigger.new) {
                ShareDataToAccountTeam.shareData('Company_Dynamics__c', order.Id, order.Customer__c, 'Company_Dynamics__c',order.OwnerId);
            }
        }
    }
}