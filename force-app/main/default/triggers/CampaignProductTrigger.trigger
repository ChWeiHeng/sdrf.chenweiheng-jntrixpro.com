trigger CampaignProductTrigger on Campaign_Product__c (after update,before insert,before update,after insert) {
    new Triggers()
	.bind(Triggers.Evt.afterupdate, new CampaignProductTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new CampaignProductTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new CampaignProductTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new CampaignProductTriggerHandler())
    .manage();
}