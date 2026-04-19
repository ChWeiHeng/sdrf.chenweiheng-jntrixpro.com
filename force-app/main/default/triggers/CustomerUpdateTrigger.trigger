/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 12-10-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   12-09-2025   Gerry   Initial Version
**/
trigger CustomerUpdateTrigger on Customer_Update__c (after update, before insert) {
    new Triggers()
    .bind(Triggers.Evt.afterupdate, new CustomerUpdateTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new CustomerUpdateTriggerHandler())
    .manage();
}