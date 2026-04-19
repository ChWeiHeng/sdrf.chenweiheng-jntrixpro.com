/**************************************************************************************************
 * Name: CloneOrderController
 * Object: 
 * Purpose: 合同提交
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-10-12         Created             
***************************************************************************************************/
public without sharing class SubmitContractController {
    @AuraEnabled
    public static Output submitContract(String conRecordId) {
        try {
            Contracts__c con = [SELECT Final_Customer__r.HQ_Email__c,Id,Name,Sales_Org__c,CRM_Approval_Status__c,Status__c,Final_Customer__c,Final_Customer__r.Name,RecordType.DeveloperName,(SELECT Id,Product__c FROM Contracts_Detail__r) FROM Contracts__c WHERE Id=:conRecordId]; 
            if (con.CRM_Approval_Status__c !='Approved' || con.Status__c!='Draft') {
                Output out = new Output();
                out.isSucess = false;
                //out.errorMsg = 'Can not submit this contract';
                out.errorMsg =System.Label.SubmitContractStatusError;
                return out;
            }
            for(Contracts_Detail__c cd:con.Contracts_Detail__r)
            {
                if(cd.Product__c==null){
                    Output out = new Output();out.isSucess = false; out.errorMsg = System.Label.SupplementaryProductCode;return out;
                }
            }
            DraftContractSyncToBPM.ReturnResult rr = DraftContractSyncToBPM.submitToBPM(conRecordId,true);
            // //同步BPM后发送邮件
            // String body = '<div>'+System.Label.ContractSyncBPMBody+'</div>';
            // Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // body = body.replaceAll('【合同编号】', con.Name);
            // Integer index = String.valueOf(URL.getOrgDomainUrl()).indexof('=')+1;
            // System.debug('28');
            // String recordURL = String.valueOf(URL.getOrgDomainUrl()).subString(index);
            // System.debug('30');
            // //body = body.replaceAll('【链接】',recordURL.replace(']','')+'/'+con.Id);
            // email.setHtmlBody(body);
            // //email.setSubject(System.Label.Contract_Sync_BPM+con.Name);
            // email.setSubject('New Contract '+con.Final_Customer__r.Name+' '+con.Name);
            // List<String> emailList = new List<String>();
            // if(con.Sales_Org__c=='3010'){ 
            //     for(String userEmail:System.Label.MXContractSyncNoticeEmail.split(';'))
            //         {if(userEmail != null){emailList.add(userEmail);}
            //         }}
            // if(con.Sales_Org__c=='5070'){
            //     if(String.isBlank(con.Final_Customer__r.HQ_Email__c)) {
            //         for(String userEmail:System.Label.ARContractSyncNoticeEmail.split(';')){
            //             if(userEmail != null){emailList.add(userEmail);}
            //         }
            //     }else{
            //          for(String userEmail:con.Final_Customer__r.HQ_Email__c.split(';')){
            //             if(userEmail != null){emailList.add(userEmail);}
            //         }
            //     }
            // }  
            // email.setToAddresses(emailList);
            // OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress];
            // if (owea.size() > 0 ) {
            //     email.setOrgWideEmailAddressId(owea.get(0).Id);
            //     // email.setSenderDisplayName(owea.get(0).DisplayName);
            // }
            // email.setUseSignature(false);
            // email.setBccSender(false);
            // if(!Test.isRunningTest())Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            System.debug('49');
            Output out = new Output();
            out.isSucess = rr.isSuccess;
            out.errorMsg = rr.message;
            return out;
        } catch (Exception e) {
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = e.getMessage()+'Line:'+e.getLineNumber();
            return out;
        }
        
    }

    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}
    }

}