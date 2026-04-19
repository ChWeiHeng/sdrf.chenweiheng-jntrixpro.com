trigger CustomerTaxNumberCategoryTrigger on Customer_Tax_Number_Category__c (before insert) {
	new Triggers()
	.bind(Triggers.Evt.beforeinsert, new CustomerTaxNumberCategoryTriggerHandler())
    .manage();
}