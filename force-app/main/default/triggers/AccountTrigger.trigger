/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 07-18-2025
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-18-2025   Gerry   Initial Version
**/
trigger AccountTrigger on Account (after update,after insert,before insert,before update) {
    new Triggers()
	.bind(Triggers.Evt.afterupdate, new AccountTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new AccountTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new AccountTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new AccountTriggerHandler())
    .manage();
}