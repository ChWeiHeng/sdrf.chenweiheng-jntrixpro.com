trigger ProductSalesInfoTrigger on Product_Sales_Info__c (before insert) {
	new Triggers()
        .bind(Triggers.Evt.beforeInsert,new ProductSalesInfoHandler())
        .manage();
}