trigger BankInfoTrigger on Bank_Info__c (after insert,after update) {
	new Triggers()
	.bind(Triggers.Evt.afterinsert, new BankInfoTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new BankInfoTriggerHandler())
    .manage();
}