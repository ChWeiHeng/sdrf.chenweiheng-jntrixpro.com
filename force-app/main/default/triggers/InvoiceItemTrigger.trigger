trigger InvoiceItemTrigger on Billing__c(before insert,before update) {
    new Triggers()
    .bind(Triggers.Evt.beforeinsert, new InvoiceItemTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new InvoiceItemTriggerHandler())
    .manage();
}