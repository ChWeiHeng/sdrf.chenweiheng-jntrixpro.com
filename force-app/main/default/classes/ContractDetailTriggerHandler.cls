public without sharing class ContractDetailTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isbefore &&  (Trigger.isinsert || Trigger.isupdate))
        {
            for (Contracts_Detail__c conDetail : (List<Contracts_Detail__c>)Trigger.new) 
            {
                if(conDetail.Product__c==null){
                    conDetail.Product_Code_Vertify__c=true;
                }else{
                    conDetail.Product_Code_Vertify__c=false;
                }
            }
        }
    }}