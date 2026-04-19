trigger AccountTeamTrigger on Account_Team__c (before insert,after update,after insert,before update, after delete,before delete) {
	new Triggers()
	.bind(Triggers.Evt.afterupdate, new AccountTeamTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new AccountTeamTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new AccountTeamTriggerHandler())
    .bind(Triggers.Evt.afterdelete, new AccountTeamTriggerHandler())
    .bind(Triggers.Evt.beforedelete, new AccountTeamTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new AccountTeamTriggerHandler())
    .manage();
}