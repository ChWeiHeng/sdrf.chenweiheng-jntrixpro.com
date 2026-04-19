/**************************************************************************************************
 * Name: SendPDFController
 * Object: 
 * Purpose: Mode1 B订单发送PDF
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0           noel            2024-11-11         Created             
***************************************************************************************************/
public without sharing class SendPDFController {
    @AuraEnabled
    public static Output SendPDF(String orderId) {
        system.debug('orderId:'+orderId);
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try {
            SendEmailContract.sendem(orderId);
        } catch (Exception e) { out.isSucess = false; out.errorMsg = e.getMessage()+';'+e.getLineNumber();}
        return out;
        
    }

    @AuraEnabled
    public static Output init(String orderId) {
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try{
        } catch (Exception e) {out.isSucess = false; out.errorMsg = e.getMessage()+';'+e.getLineNumber();}
        return out;
    }

    
    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

       
    }

}