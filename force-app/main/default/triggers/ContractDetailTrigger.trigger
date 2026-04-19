trigger ContractDetailTrigger on Contracts_Detail__c  (after update,before insert,before update,after insert) {
    new Triggers()
	.bind(Triggers.Evt.afterupdate, new ContractDetailTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new ContractDetailTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new ContractDetailTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new ContractDetailTriggerHandler())
    .manage();
}