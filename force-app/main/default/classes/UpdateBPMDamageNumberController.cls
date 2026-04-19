/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-30-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   03-30-2026   Gerry   Initial Version
**/
public without sharing class UpdateBPMDamageNumberController {

    @AuraEnabled
    public Static Output updateNumber(String orderId,String damageNumber) {
        Output out = new Output();
        try {
            Order__c order = new Order__c();
            order.Id = orderId;
            order.BPM_Damage_Assessment_Number__c = damageNumber;
            update order;
            out.isSucess = true;
            return out;
        } catch (Exception e) {
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';'+e.getLineNumber();
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