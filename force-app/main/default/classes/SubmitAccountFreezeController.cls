public without sharing class SubmitAccountFreezeController {
    @AuraEnabled
    public static Output sumbitApproval(String customerSaleInfoId,String commentString,Boolean isFreeze) {
        system.debug('customerSaleInfoId:'+customerSaleInfoId);
        system.debug('commentString:'+commentString);
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try {
            Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
            psr.objectId = customerSaleInfoId;//对象Id
            psr.setSubmitterId(UserInfo.getUserId());//提交人
            psr.comments = commentString;//备注
            if (!Test.isRunningTest())
            {
                Approval.ProcessResult result = Approval.process(psr);
                out.isSucess=result.isSuccess();
                out.errorMsg=String.valueOf(result.getErrors());
                system.debug('result=>'+result);
            }
            if(out.isSucess){
                Customer_Sales_Info__c customerSaleInfo = new Customer_Sales_Info__c();
                customerSaleInfo.Id = customerSaleInfoId;
                if(isFreeze){
                    customerSaleInfo.Apply_Type__c='Freeze';
                }else{
                    customerSaleInfo.Apply_Type__c='UnFreeze';
                }
                update customerSaleInfo;
            }
            

            //    
        } catch (Exception e) {out.isSucess = false;out.errorMsg = e.getMessage()+';'+e.getLineNumber(); return out;}
        return out; 
    }

    @AuraEnabled
    public static Output initFreeze(String customerSaleInfoId) {
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try{
            Customer_Sales_Info__c customerSaleInfo=[SELECT Id,Customer__c,Sales_Org__c,Is_Freeze__c FROM Customer_Sales_Info__c WHERE Id=:customerSaleInfoId];
            System.debug('customerSaleInfo=>'+customerSaleInfo);
            if(customerSaleInfo.Is_Freeze__c != '00'){
                out.isSucess = false;out.errorMsg = System.Label.FreezeInitNoticeError;return out;
            }
            List<Quote__c> quoteList=[SELECT Id FROM  Quote__c	WHERE Customer__c=:customerSaleInfo.Customer__c	 AND Sales_Org__c=:customerSaleInfo.Sales_Org__c AND Approval_Status__c='Approving'];
            List<Contracts__c> conList=[SELECT Id FROM  Contracts__c	WHERE Final_Customer__c	=:customerSaleInfo.Customer__c	 AND Sales_Org__c=:customerSaleInfo.Sales_Org__c AND CRM_Approval_Status__c='Approving'];
            List<Order__c> orderList=[SELECT Id FROM  Order__c	WHERE Customer__c=:customerSaleInfo.Customer__c	 AND Sales_Org__c=:customerSaleInfo.Sales_Org__c AND Status__c='Approving'];
            if(quoteList.size()>0 || conList.size()>0 || orderList.size()>0){
                out.isSucess = false;out.errorMsg = System.Label.FreezeNoticeError;return out;
            }

        } catch (Exception e) {out.isSucess = false;out.errorMsg = e.getMessage()+';'+e.getLineNumber();}
        return out;
    }

    @AuraEnabled
    public static Output initUnFreeze(String customerSaleInfoId) {
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try{
            Customer_Sales_Info__c customerSaleInfo=[SELECT Id,Customer__c,Sales_Org__c,Is_Freeze__c FROM Customer_Sales_Info__c WHERE Id=:customerSaleInfoId];
            System.debug('customerSaleInfo=>'+customerSaleInfo);
            if(customerSaleInfo.Is_Freeze__c != '01'){
                out.isSucess = false;out.errorMsg = System.Label.UnFreezeInitNoticeError;return out;
            }

        } catch (Exception e) {out.isSucess = false;out.errorMsg = e.getMessage()+';'+e.getLineNumber();}
        return out;
    }

    
    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

       
    }

}