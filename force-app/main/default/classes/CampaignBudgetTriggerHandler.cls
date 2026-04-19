/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 06-16-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-19-2025   Gerry   Initial Version
**/
public without sharing class CampaignBudgetTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isbefore && (Trigger.isinsert || Trigger.isupdate))
        {
            // Set<String> duplicateExterl=new Set<String>();
            // for(Campaign_Budget__c cb:[SELECT Id,ExteralId__c,Sales_Org__c,Year__c FROM Campaign_Budget__c WHERE ExteralId__c != null])
            // { duplicateExterl.add(cb.ExteralId__c);}
            for(Campaign_Budget__c campaignBudget :(List<Campaign_Budget__c>)Trigger.new)
            {
                campaignBudget.ExteralId__c=campaignBudget.Sales_Org__c+'_'+campaignBudget.Plant__c+'_'+campaignBudget.Year__c;
                // if(duplicateExterl != null && duplicateExterl.contains(campaignBudget.ExteralId__c)){
                //     //campaignBudget.addError('Current Company Select Year Exist Same Budget');
                //     campaignBudget.addError(System.Label.SameSameYearBudget);}
            }
        }
}
}