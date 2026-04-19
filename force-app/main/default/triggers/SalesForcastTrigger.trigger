/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-26-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-26-2025   Gerry   Initial Version
**/
trigger SalesForcastTrigger on Sales_Forcast__c(before insert,before update) {
    new Triggers()
    .bind(Triggers.Evt.beforeinsert, new SalesForcastTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new SalesForcastTriggerHandler())
    .manage();
}