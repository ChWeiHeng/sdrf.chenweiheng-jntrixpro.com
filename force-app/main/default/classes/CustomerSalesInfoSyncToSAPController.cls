public without sharing class CustomerSalesInfoSyncToSAPController {
    @AuraEnabled
    public static Output confirmSync(String recordId){
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = System.Label.ShipToSapSuccessInfo;
        Savepoint sp = Database.setSavepoint();
        try {
            Account acc=[SELECT Id,Customer_Approval_Status__c FROM Account WHERE Id=:recordId];
            acc.Customer_Approval_Status__c='Approved';
            List<Customer_Sales_Info__c> csiList=[SELECT Id,Sales_View_Status__c FROM Customer_Sales_Info__c WHERE Customer__c =:recordId];
            for(Customer_Sales_Info__c csi:csiList){
                // csi.Sales_View_Status__c='Approved';
            }
            update acc;
            // update csiList;
            /*for(Customer_Sales_Info__c csi:csiList){
                if(csi.Customer__c != null && csi.Customer__r.MDG_Customer_Code__c != null) {
                    if(!csi.isSync__c) {
                        CustomerSalesInfoSyncToSAP.submitToSAPFutrue(csi.Id,'I');
                    }else{
                        CustomerSalesInfoSyncToSAP.submitToSAPFutrue(csi.Id,'U');
                    }
                }else{
                    Datetime d = Datetime.now();
                    String minute = d.minute() + 1 + '';
                    String sch =  d.second() +  ' ' +   minute +    ' ' +   d.hour() +   ' ' +   d.day() +  ' ' +  d.month() +  ' ? ' + d.year();
                    SyncAccountSalesInfoSchedule schup = new SyncAccountSalesInfoSchedule(
                        csi.Id
                    );
                    System.schedule(
                    '定时一分钟后SyncAccountSalesInfo' + Datetime.now().getTime(),
                    sch,
                    schup
                    );
                }
            }*/

        } catch (Exception e) {
            Database.rollback(sp); 
             out.isSucess = false; out.errorMsg = e.getMessage();
        }

        return out;
    }
    @AuraEnabled
    public static Output init(String recordId){
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        
        try {
            List<Customer_Sales_Info__c> csiList=[SELECT Id,Can_Submit__c,Customer__c,Customer__r.MDG_Customer_Code__c,isSync__c FROM Customer_Sales_Info__c WHERE Customer__c =:recordId];
            for(Customer_Sales_Info__c csi:csiList){
                if(!csi.Can_Submit__c){
                    out.isSucess = false; out.errorMsg = System.Label.CopyCustomerVertifySumbit;return out;
                }
            }
            Account acc=[SELECT Id,Customer_Approval_Status__c,City__c FROM Account WHERE Id=:recordId];
            if(acc.Customer_Approval_Status__c=='Approved') {
                out.isSucess = false; out.errorMsg = System.Label.cannotSubmit;return out;
            }
            if(acc.City__c==null) {
                out.isSucess = false; out.errorMsg = System.Label.CustomerAddressRequired;return out;
            }
            
        } catch (Exception e) {
             out.isSucess = false; out.errorMsg = e.getMessage();
        }

        return out;
    }
    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        @AuraEnabled
        public String returnUrl {get;set;}

       
    }
}