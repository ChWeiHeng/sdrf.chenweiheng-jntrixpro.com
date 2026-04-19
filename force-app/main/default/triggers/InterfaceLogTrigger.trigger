trigger InterfaceLogTrigger on Interface_Log__c(after insert) {
    new Triggers()
	.bind(Triggers.Evt.afterinsert, new InterfaceLogTriggerHandler())
    .manage();
}