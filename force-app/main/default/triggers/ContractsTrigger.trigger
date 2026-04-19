trigger ContractsTrigger on Contracts__c (after update,before insert,before update,after insert) {
    new Triggers()
	.bind(Triggers.Evt.afterupdate, new ContractsTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new ContractsTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new ContractsTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new ContractsTriggerHandler())
    .manage();
}