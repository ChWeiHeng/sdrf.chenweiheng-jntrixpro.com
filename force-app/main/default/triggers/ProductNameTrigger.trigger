/**
 * @description       : 商品名称trigger
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 06-09-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-09-2025   Gerry   Initial Version
**/
trigger ProductNameTrigger on Product_Name__c (before insert,before update,after insert) {
	new Triggers()
	.bind(Triggers.Evt.beforeupdate, new ProductNameTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new ProductNameTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new ProductNameTriggerHandler())
    .manage();
}