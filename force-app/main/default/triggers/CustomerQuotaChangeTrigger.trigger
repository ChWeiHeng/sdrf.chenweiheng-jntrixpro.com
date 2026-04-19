trigger CustomerQuotaChangeTrigger on Customer_Quota_Change__c (after insert, after Update,before insert) {
    new Triggers()
	.bind(Triggers.Evt.afterinsert, new CustomerQuotaChangeTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new CustomerQuotaChangeTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new CustomerQuotaChangeTriggerHandler())
    .manage();
}