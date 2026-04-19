trigger AccountVisitTrigger on Account_Visit__c (after update,before insert,before update,after insert) {
    new Triggers()
	.bind(Triggers.Evt.afterupdate, new AccountVisitTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new AccountVisitTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new AccountVisitTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new AccountVisitTriggerHandler())
    .manage();
}