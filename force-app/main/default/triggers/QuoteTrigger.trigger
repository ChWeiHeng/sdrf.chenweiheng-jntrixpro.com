trigger QuoteTrigger on Quote__c (after update,before insert,before update,after insert) {
    new Triggers()
	.bind(Triggers.Evt.afterupdate, new QuoteTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new QuoteTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new QuoteTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new QuoteTriggerHandler())
    .manage();
}