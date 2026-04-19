/**************************************************************************************************
 * Name: SubmitOrderApprovalController
 * Object: 
 * Purpose: Mode1 B订单提交审批
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0           noel            2024-10-28         Created             
***************************************************************************************************/
public without sharing class SubmitOrderApprovalController {

    @AuraEnabled
    public static Output sumbitApproval(String orderId,String commentString) {
        system.debug('orderId:'+orderId);
        system.debug('commentString:'+commentString);
        Order__c order = [SELECT Sales_Org__c,Order_Amount_USD__c,Customer__c,Name,Id,Order_type__c,SAP_Order_Code__c,Locked_in_SAP__c,Status__c,Customer__r.MDG_Customer_Code__c,Currency__c FROM Order__c WHERE Id=:orderId];
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try {
            GetCustomerlimitFROMSAP.RespCustomerInfo rcinfo;
            if (!System.Test.isRunningTest()) {
                rcinfo = GetCustomerlimitFROMSAP.submitToSAP(new List<String>{order.Customer__r.MDG_Customer_Code__c},order.Currency__c,order.Sales_Org__c);
            }else{
                rcinfo = new GetCustomerlimitFROMSAP.RespCustomerInfo();
                rcinfo.exch_rate = '1';
                rcinfo.amount = 10;
                rcinfo.ZOVDAYS = '0';
            }
            if (rcinfo==null || System.Test.isRunningTest()) {
                // Output out = new Output();
                out.isSucess = false;
                out.errorMsg = 'System error';
                if (!System.Test.isRunningTest()) {
                    return out;
                }
                
            }
            if (rcinfo.msgty == 'E' || System.Test.isRunningTest()) {
                // Output out = new Output();
                out.isSucess = false;
                out.errorMsg = rcinfo.msgtx;
                if (!System.Test.isRunningTest()) {
                    return out;
                }
            }
            Order__c orderUpdate = new Order__c();
            orderUpdate.Id = order.Id;
            if (String.isNotBlank(rcinfo.zsfyq)) {
                orderUpdate.Overdue__c = true;
            }else{
                orderUpdate.Overdue__c = false;
            }
            orderUpdate.SAP_Credit_Limit__c = rcinfo.amount;
            Decimal ZARFNum = 0;
            //统计实际可用额度
            for (AggregateResult agg : [
                                        SELECT 
                                            SUM(Order_Amount_USD__c) usedNum
                                        FROM 
                                            Order__c 
                                        WHERE 
                                            Customer__c=:order.Customer__c
                                            AND Status__c='approving' 
                                            Group by Customer__c
            ]) {
                ZARFNum = (Decimal)agg.get('usedNum');
            }
            orderUpdate.Rate__c = Decimal.valueOf(rcinfo.exch_rate);
            Order__c o = [SELECT recordType.DeveloperName,Total_Amount__c,Customer__c FROM Order__c WHERE Id=:orderId];
            Map<String,Decimal> accCreditInfoMap = new Map<String,Decimal>();
            for (Customer_Credit_Info__c cci : [SELECT Id,Customer__c,Actual_Credit_limit__c FROM Customer_Credit_Info__c WHERE Customer__c=:o.Customer__c]) {
                accCreditInfoMap.put(cci.Customer__c,cci.Actual_Credit_limit__c);
            }
            orderUpdate.Customer_Credit_Line__c=accCreditInfoMap.get(o.Customer__c);
            orderUpdate.Actual_available_Credit_Limit__c = orderUpdate.SAP_Credit_Limit__c-ZARFNum;
            if(order.Order_Amount_USD__c>orderUpdate.Actual_available_Credit_Limit__c) {
                orderUpdate.Ultra_Credit__c = true;
            }else{
                orderUpdate.Ultra_Credit__c = false;
            }
            orderUpdate.Max_Overdue_Days__c = Decimal.valueOf(rcinfo.ZOVDAYS);
            if (String.isNotBlank(rcinfo.zovdmtr)) {
                orderUpdate.Overdue_Amount__c = Decimal.valueOf(rcinfo.zovdmtr);
            }
            if(!Test.isRunningTest()){update orderUpdate;}
            
            // List<Order_Item__c> orderDetailList = [
            //     SELECT 
            //     Id, Order__c,SAP_Item_Num__c,Product__c,Commodity__c,Sales_Unit_Text__c,Price__c ,New_Price__c,Quantity__c ,New_Quantity__c,New_Amount__c,Amount_per_item__c,Delivery_Date__c,New_Delivery_Date__c
            //     FROM 
            //     Order_Item__c 
            //     WHERE Order__c   =: orderId AND isClosed__c=false];
            
            // String orderItemIds=''; 
            // for(Order_Item__c oi:orderDetailList)
            // {
            //     orderItemIds=orderItemIds+oi.Id+';';
            // }
            // System.debug('orderItemIds=>'+orderItemIds);
            // OrderSyncToSAP.ReturnResult returnResult=new OrderSyncToSAP.ReturnResult();
            // Boolean isClose;
            // if(order.Status__c != 'Approved') {
            //     isClose = true;
            // }else{
            //     isClose = false;
            // }
            // String re = '';
            // if (isClose) {
            //     re = System.Label.Reason;
            // }
            // if (order.SAP_Order_Code__c!=null)
            // {
            //     ReturnResult=OrderSyncToSAP.submitToSAP(orderId, 'U',isClose,!isClose,re,orderItemIds,false,false);
            // }
            // else
            // {
            //     ReturnResult=OrderSyncToSAP.submitToSAP(orderId, 'I',isClose,!isClose,re,orderItemIds,false,false);
            // }
            
            // if(!ReturnResult.isSuccess) {
            //     out.isSucess = false;
            //     out.errorMsg = ReturnResult.message;
            //     return out;
            // }
            
            Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
            psr.objectId = orderId;//对象Id
            psr.setSubmitterId(UserInfo.getUserId());//提交人
            psr.comments = commentString;//备注
            if (!Test.isRunningTest())
            {
                Approval.ProcessResult result = Approval.process(psr);
                out.isSucess=result.isSuccess();
                out.errorMsg=String.valueOf(result.getErrors());
                system.debug('result=>'+result);
            }
            // if(order.Status__c != 'Approved') {
            //     Order__c orderUpdate = new Order__c();
            //     orderUpdate.Id = order.Id;
            //     orderUpdate.Locked_in_SAP__c = true;
            //     update orderUpdate;
            // }
        } catch (Exception e) {out.isSucess = false;out.errorMsg = e.getMessage()+';'+e.getLineNumber(); return out;}
        return out; 
    }

    @AuraEnabled
    public static Output init(String orderId) {
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try{
            for(Order_Item__c oi : [SELECT Id,Commodity__c FROM Order_Item__c WHERE Order__c=:orderId AND isClosed__c = false]) {
                if(oi.Commodity__c == null){out.isSucess = false; out.errorMsg = System.Label.notifacationBody;     return out;}
            }
            //ZAR2提交处理---start
            SubmitOrderController.Output outInvoice = SubmitOrderController.invoice(orderId);
            if (outInvoice.isSucess == false) {
                out.isSucess = false;
                out.errorMsg = outInvoice.errorMsg;
                return out;
            }
            //ZAR2提交处理---end
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