public without sharing class closeEscComplaintController {
    @AuraEnabled
    public static Output confirmSave(String comId, String status,String cancellReason,String isResolve) {
        System.debug('comId=>'+comId);
        SavePoint sp = Database.setSavepoint();
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try {
            Case needCase=new Case();
            needCase.Id=comId;
            needCase.Status=status;
            if(needCase.Status == 'Closed'){
                needCase.Resolved__c=isResolve;
            }else if(needCase.Status=='Cancel'){
                needCase.Cancel_Reason__c=cancellReason;
            }
            update needCase;
        } catch (Exception e) {
            if(sp != null)
            {
                Database.rollback(sp);
            }
            out.isSucess = false;
            system.debug('185Line'+e.getMessage()+e.getLineNumber());
            out.errorMsg = e.getMessage().substring(e.getMessage().indexOf(', ')+1);
            return out;
        }
        return out;
        
    }

    @AuraEnabled
    public static Output init(String comId) {
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        out.optionList = new List<Option>();
        out.optionList1 = new List<Option>();
        Option op5 = new Option();
        op5.label = '';
        op5.value = '';
        out.optionList.add(op5);
        Option op6 = new Option();
        op6.label = '';
        op6.value = '';
        out.optionList1.add(op6);
        try{
        Case caseRecord = [SELECT Id,Resolved__c,Cancel_Reason__c,Status,Approve_Status__c FROM Case WHERE Id=:comId];
        if(caseRecord.Status == 'Closed') {
            out.isSucess = false;
            out.errorMsg = System.Label.ComplaintClose;
            return out;
        }
        if(caseRecord.Status == 'Cancel') {
            out.isSucess = false;
            out.errorMsg = System.Label.ComplaintCancel;
            return out;
        }
        if(caseRecord.Approve_Status__c == 'Approving') {
            out.isSucess = false;
            out.errorMsg = System.Label.ComplaintApproving;
            return out;
        }
        if(caseRecord.Approve_Status__c=='Approved'){
        Option op = new Option();
        op.label = 'Closed';
        op.value = 'Closed';
        out.optionList.add(op);
        }

        Option op1 = new Option();
        op1.label = 'Cancel';
        op1.value = 'Cancel';
        out.optionList.add(op1);

        Option op2 = new Option();
        op2.label = 'YES';
        op2.value = 'YES';
        out.optionList1.add(op2);

        Option op3 = new Option();
        op3.label = 'NO';
        op3.value = 'NO';
        out.optionList1.add(op3);
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
        public List<Option> optionList {get;set;}

        @AuraEnabled
        public List<Option> optionList1 {get;set;}
    }

    public class Option {
        @AuraEnabled
        public String label {get;set;}

        @AuraEnabled
        public String value {get;set;}
    }
}