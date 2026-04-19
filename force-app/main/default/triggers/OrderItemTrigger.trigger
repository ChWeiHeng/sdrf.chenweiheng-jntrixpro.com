/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 10-30-2025
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   10-30-2025   Gerry   Initial Version
**/
trigger OrderItemTrigger on Order_Item__c (before insert,after insert,before update,after update) {
	new Triggers()
		.bind(Triggers.Evt.beforeupdate, new OrderItemTriggerHandler())
    	.bind(Triggers.Evt.beforeinsert, new OrderItemTriggerHandler())
        .bind(Triggers.Evt.afterinsert, new OrderItemTriggerHandler())
        .bind(Triggers.Evt.afterupdate, new OrderItemTriggerHandler())
    	.manage();
}