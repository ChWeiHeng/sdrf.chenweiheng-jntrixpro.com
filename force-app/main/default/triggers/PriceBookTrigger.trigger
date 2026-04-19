trigger PriceBookTrigger on Price_Book_Item__c (after insert,after update,before insert,before update) {
	new Triggers()
	.bind(Triggers.Evt.afterupdate, new PriceBookTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new PriceBookTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new PriceBookTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new PriceBookTriggerHandler())
    .manage();
}