trigger TaskTrigger on Task  (after update,before insert,before update,after insert,after delete,before delete) {
    new Triggers()
	.bind(Triggers.Evt.afterupdate, new TaskTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new TaskTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new TaskTriggerHandler())
    .bind(Triggers.Evt.beforedelete, new TaskTriggerHandler())
    .bind(Triggers.Evt.afterdelete, new TaskTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new TaskTriggerHandler())
    .manage();
}