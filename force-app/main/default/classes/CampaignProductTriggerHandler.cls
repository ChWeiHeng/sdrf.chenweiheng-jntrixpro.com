public without sharing class CampaignProductTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isbefore && Trigger.isinsert)
        {
            for(Campaign_Product__c campaignProduct :(List<Campaign_Product__c>)Trigger.new)
            { 
                if(campaignProduct.Status__c=='Approved'){
                    //campaignProduct.addError('Campaign Approved Not Insert Campaign Product');
                    campaignProduct.addError(System.Label.CampaignProductInsertError);}
            }
        }
        if (Trigger.isbefore && Trigger.isupdate)
        {
            for(Campaign_Product__c campaignProduct :(List<Campaign_Product__c>)Trigger.new)
            {
                if(campaignProduct.Status__c=='Approved'){
                    //campaignProduct.addError('Campaign Approved Not Update Campaign Product');
                    campaignProduct.addError(System.Label.CampaignProductUpdateError);}
            }
        }
}
}