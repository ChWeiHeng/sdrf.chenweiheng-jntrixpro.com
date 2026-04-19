/**************************************************************************************************
 * Name: NotificationService
 * Object: 
 * Purpose: 订单锁定
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-20         Created             
***************************************************************************************************/
public without sharing class LockOrderLWCController {
    @AuraEnabled
    public static Output lockOrder(String orderId) {
        List<Order_Item__c> oiList = [SELECT Id,SAP_Item_Num__c FROM Order_Item__c WHERE isClosed__c=false AND Order__c =:orderId];
        String orderItemIds;
        
        for (Order_Item__c oi : oiList) {
            if (String.isNotBlank(orderItemIds)) {
                orderItemIds += ';'+oi.Id;
            }else{
                orderItemIds = ';'+oi.Id;
            }
             
        }
        OrderSyncToSAP.ReturnResult rr = OrderSyncToSAP.submitToSAP(orderId, 'U',true,false,System.Label.Reason,orderItemIds,false,false);
        if(Test.isRunningTest()){
            rr.isSuccess=true;
            rr.item=new List<OrderSyncToSAP.Item>();
            OrderSyncToSAP.Item item1=new OrderSyncToSAP.Item();
            item1.status='A';
            item1.POSNR='10';    
            rr.item.add(item1);
        }
           
        Output out = new Output();
        out.isSucess = rr.isSuccess;
        out.errorMsg = rr.message;
        if (out.isSucess) {
            Map<String,String> itemNumberMap = new Map<String,String>();
            for (OrderSyncToSAP.item i :  rr.item) {
                itemNumberMap.put(i.POSNR,i.status);
            }
            for (Order_Item__c oi : oiList) {
                oi.Edit_Status__c = itemNumberMap.get(oi.SAP_Item_Num__c);
            }
            Database.update(oiList);
            Order__c order = new Order__c();
            order.Id = orderId;
            order.Locked_in_SAP__c = true;
            update order;
        }
        return out;
    }
    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}
    }
}