trigger CustomerTaxCategoryTrigger on Customer_Tax_Category__c (after update) {
	new Triggers()
    .bind(Triggers.Evt.afterupdate, new CustomerTaxCategoryTriggerHandler())
    .manage();
}