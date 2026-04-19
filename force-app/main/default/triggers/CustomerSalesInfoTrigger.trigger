trigger CustomerSalesInfoTrigger on Customer_Sales_Info__c (after insert,before insert,before Update,after Update) {
    new Triggers()
	.bind(Triggers.Evt.afterinsert, new CustomerSalesInfoTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new CustomerSalesInfoTriggerHandler())
    .bind(Triggers.Evt.beforeUpdate, new CustomerSalesInfoTriggerHandler())
    .bind(Triggers.Evt.afterUpdate, new CustomerSalesInfoTriggerHandler())
    .manage();
}