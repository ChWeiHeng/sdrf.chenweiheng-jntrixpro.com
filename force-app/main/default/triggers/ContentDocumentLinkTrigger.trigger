trigger ContentDocumentLinkTrigger on ContentDocumentLink (after update,before insert,before update,after insert) {
    new Triggers()
    .bind(Triggers.Evt.beforeinsert, new ContentDocumentLinkTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new ContentDocumentLinkTriggerHandler())
    .manage();
}