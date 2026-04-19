trigger CampaignTrigger on Campaign(after update,before insert,before update,after insert,after delete) {
    new Triggers()
	.bind(Triggers.Evt.beforeupdate, new CampaignTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new CampaignTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new CampaignTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new CampaignTriggerHandler())
    .manage();
}