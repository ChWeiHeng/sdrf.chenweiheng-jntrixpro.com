/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-27-2025
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-27-2025   Gerry   Initial Version
**/
trigger ContentDocumentTrigger on ContentDocument (after update,before insert,before update,after insert,before delete) {
    new Triggers()
    .bind(Triggers.Evt.beforedelete, new ContentDocumentTriggerHandler())
    .manage();
}