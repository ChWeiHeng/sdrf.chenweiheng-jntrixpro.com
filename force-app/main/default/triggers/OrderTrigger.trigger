/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 08-28-2025
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-28-2025   Gerry   Initial Version
**/
trigger OrderTrigger on Order__c (after update,before insert,before update,after insert,before delete) {
    new Triggers()
        .bind(Triggers.Evt.afterupdate, new OrderTriggerHandler())
        .bind(Triggers.Evt.beforeupdate, new OrderTriggerHandler())
        .bind(Triggers.Evt.beforeinsert, new OrderTriggerHandler())
        .bind(Triggers.Evt.afterinsert, new OrderTriggerHandler())
        .bind(Triggers.Evt.beforedelete,new OrderTriggerHandler())
        .manage();
}