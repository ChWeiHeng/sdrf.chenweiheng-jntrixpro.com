trigger CompanyDynamicsTrigger on Company_Dynamics__c (after insert,before insert,before Update,after Update) {
	new Triggers()
	.bind(Triggers.Evt.afterinsert, new CompanyDynamicsTriggerHandler())
    .bind(Triggers.Evt.afterUpdate, new CompanyDynamicsTriggerHandler())
    .manage();
}