trigger CaseTrigger on Case (before insert,after update,after insert,before update, after delete,before delete) {
	new Triggers()
    .bind(Triggers.Evt.beforeupdate, new CaseTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new CaseTriggerHandler())
    .manage();

}