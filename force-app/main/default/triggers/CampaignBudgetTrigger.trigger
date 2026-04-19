trigger CampaignBudgetTrigger on Campaign_Budget__c  (after update,before insert,before update,after insert,after delete) {
    new Triggers()
	.bind(Triggers.Evt.beforeupdate, new CampaignBudgetTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new CampaignBudgetTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new CampaignBudgetTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new CampaignBudgetTriggerHandler())
    .manage();
}