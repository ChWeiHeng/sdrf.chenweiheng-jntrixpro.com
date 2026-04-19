trigger DeliveryNoteTrigger on Delivery_Note__c (after insert,after update) {
	new Triggers()
        .bind(Triggers.Evt.afterInsert,new DeliveryNoteHandler())
        .bind(Triggers.Evt.afterUpdate,new DeliveryNoteHandler())
        .manage();
}