trigger MonthlyBudgetTrigger on Monthly_Budget__c (after update,before insert,before update,after insert,after delete) {
    new Triggers()
	.bind(Triggers.Evt.beforeupdate, new MonthlyBudgetTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new MonthlyBudgetTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new MonthlyBudgetTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new MonthlyBudgetTriggerHandler())
    .manage();
}