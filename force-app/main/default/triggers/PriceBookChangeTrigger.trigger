/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 06-09-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-09-2025   Gerry   Initial Version
**/
trigger PriceBookChangeTrigger on Price_Book__c (after update,before update) {
	new Triggers()
	.bind(Triggers.Evt.afterupdate, new PriceBookChangeTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new PriceBookChangeTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new PriceBookChangeTriggerHandler())
    .manage();
}