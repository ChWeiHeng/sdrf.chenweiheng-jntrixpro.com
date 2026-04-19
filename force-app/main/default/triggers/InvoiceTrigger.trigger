trigger InvoiceTrigger on Invoice__c (after insert,before insert,before Update,after Update) {
	new Triggers()
	.bind(Triggers.Evt.afterinsert, new InvoiceTriggerHandler())
    .bind(Triggers.Evt.afterUpdate, new InvoiceTriggerHandler())
    .manage();
}