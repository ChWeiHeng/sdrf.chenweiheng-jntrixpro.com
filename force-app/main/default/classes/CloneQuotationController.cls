/**
 * @description       : 报价复制控制类
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 07-16-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-14-2025   Gerry   Initial Version
**/
public without sharing class CloneQuotationController {
    @AuraEnabled
    public static Output cloneQoute(String quoteRecordId) {
        System.savepoint sp = Database.setSavepoint();
        try {
            
            ObjectClone.ResponseParam rp = ObjectClone.cloneObjectSingle(quoteRecordId, true, null,'Quote_Detail__c',System.Label.CloneQuoteDetailRemoveField);
            if (rp.code) {
                Output out = new Output();
                Map<Id, Id> oldToNewIdMap = rp.oldIdToNewId;
                System.debug(oldToNewIdMap);
                Quote__c quo = new Quote__c();
                quo.Id = oldToNewIdMap.get(quoteRecordId);
                quo.Old_Quotation__c = quoteRecordId;//关联原有报价
                quo.Approval_Status__c = 'Draft';
                quo.Is_Customer_Confirmed__c = false;
                quo.Approval_Time__c = null;
                quo.OwnerId = System.UserInfo.getUserId();
                update quo;

                //成本重新计算
                List<Quote_Detail__c> qdList = new List<Quote_Detail__c>();
                for (Quote_Detail__c qd : [SELECT Process_Cost__c,Cost__c,Order_Qnty__c,CIF_90_Days__c,Inland_Cost_Including_Insurance__c,Clearance_Cost_Percentage__c,Quote_Detail__c.Commission__c,Quote_Detail__c.Freight_Cost__c,Quote_Detail__c.Pallet__c,Quote_Detail__c.Packing_Cost__c,Quote__r.Quotation_Type__c,Payment_Terms__c,FOB_Price__c,Price_List__c,Id,Quote__r.Payment_Term_Cost_Rate__c,Price_List__r.Unit__c,Price_List__r.FOB_Price__c FROM Quote_Detail__c WHERE Quote__c=:quo.Id]) {
                    System.debug('进入逻辑');
                    if (qd.Price_List__c!=null) {//fob重新赋值
                        qd.FOB_Price__c = qd.Price_List__r.FOB_Price__c;
                        qd.Unit__c = qd.Price_List__r.Unit__c;
                    }
                    qd.Payment_Terms__c = qd.Quote__r.Payment_Term_Cost_Rate__c;
                    BatchImportQuoteDetailController.setData(qd,qd.Quote__r.Quotation_Type__c);
                    qdList.add(qd);
                }
                if (qdList.size()>0) {
                    Database.update(qdList);
                }
                
                out.isSucess = true;
                out.errorMsg = 'Clone Successful';
                out.newRecordId = oldToNewIdMap.get(quoteRecordId);
                return out;
            } else {
                Database.rollback(sp);
                Output out = new Output();
                out.isSucess = false;
                out.errorMsg = rp.message;
                return out;
            }
        } catch (Exception e) {
            Database.rollback(sp);
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
        
        @AuraEnabled
        public String newRecordId {get;set;}
    }
}