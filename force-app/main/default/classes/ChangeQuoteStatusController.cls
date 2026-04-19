public without sharing class ChangeQuoteStatusController {
    @AuraEnabled
    public static Output changeStatus(String quoteId, Boolean currentStatus) {
        System.debug('currentStatus=>'+currentStatus);
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try {
            Quote__c quote=new Quote__c();
            quote.Id=quoteId;
            quote.Is_Customer_Confirmed__c=currentStatus;
            update quote;
        } catch (Exception e) {
        	
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';'+e.getLineNumber();
            return out;
        }
        return out;
        
    }

    @AuraEnabled
    public static Output init(String quoteId) {
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try{
        Quote__c quote = [SELECT Id,Sales_Org__c,Quotation_Type__c,Approval_Status__c,Is_Customer_Confirmed__c FROM Quote__c WHERE Id=:quoteId];
        
        out.currentStatus=quote.Is_Customer_Confirmed__c;
        } catch (Exception e) {
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';'+e.getLineNumber();
           
        }
        return out;
    }

    
    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        @AuraEnabled
        public Boolean currentStatus {get;set;}
        
        
    }
}