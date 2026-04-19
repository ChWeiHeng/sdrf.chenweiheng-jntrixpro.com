trigger CustomerCreditTrigger on Customer_Credit_Info__c (after insert,after update) {
    new Triggers()
	.bind(Triggers.Evt.afterupdate, new CustomerCreditTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new CustomerCreditTriggerHandler())
    .manage();
}