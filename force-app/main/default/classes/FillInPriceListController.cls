/**************************************************************************************************
 * Name: NotificationService
 * Object: 
 * Purpose: 订单关闭
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-20         Created             
***************************************************************************************************/
public without sharing class FillInPriceListController {
    @AuraEnabled
    public static Output setValue(String quoteDetailId,String priceListValue) {
        Quote_Detail__c qd = new Quote_Detail__c();
        qd.Id = quoteDetailId;
        qd.Price_List__c = priceListValue;
        Database.update(qd);
        Output out = new Output();
        out.isSucess = true;
        return out;
    }

    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}
    }
}