/**************************************************************************************************
 * Name: CreateContractLWCController
 * Object: 
 * Purpose: 通过报价创建合同
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0           noel            2024-10-28         Created             
***************************************************************************************************/
public without sharing class orderUnlockSyncSapController {
    @AuraEnabled
    public static Output syncSap(String orderId,Boolean flag,Boolean change) {
        system.debug('orderId:'+orderId);
        Order__c order = [SELECT Name,Id,Order_type__c,SAP_Order_Code__c,Locked_in_SAP__c,SAP_Update_Status__c  FROM Order__c WHERE Id=:orderId];
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try {
            List<Order_Item__c> orderDetailList = [
                                    SELECT 
                                        Id, Order__c,SAP_Item_Num__c,Product__c,Commodity__c,Sales_Unit_Text__c,Price__c ,New_Price__c,Quantity__c ,New_Quantity__c,New_Amount__c,Amount_per_item__c,Delivery_Date__c,New_Delivery_Date__c
                                    FROM 
                                        Order_Item__c 
                                    WHERE Order__c   =: orderId AND isClosed__c=false];

            String orderItemIds=''; 
            for(Order_Item__c oi:orderDetailList)
            {
                orderItemIds=orderItemIds+oi.Id+';';
            }
            System.debug('orderItemIds=>'+orderItemIds);
            OrderSyncToSAP.ReturnResult returnResult=new OrderSyncToSAP.ReturnResult();
            Boolean isClose = flag;
            String re = '';
            if (isClose) {
                re = System.Label.Reason;
            }

            // if (order.SAP_Update_Status__c == 'Fail') { //失败了 需要重推
            //     isClose = false;
            // }
            if (order.SAP_Order_Code__c!=null)
            {
                ReturnResult=OrderSyncToSAP.submitToSAP(orderId, 'U',isClose,!isClose,re,orderItemIds,false,change);
            }
            else
            {
                ReturnResult=OrderSyncToSAP.submitToSAP(orderId, 'I',isClose,!isClose,re,orderItemIds,false,change);
            }
            
            out.isSucess = returnResult.isSuccess;
            out.errorMsg =returnResult.message;
        } catch (Exception e) {
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';'+e.getLineNumber();
            return out;
        }
        return out;
        
    }

    @AuraEnabled
    public static Output updateData(String orderId,Boolean locked) {
        system.debug('orderId:'+orderId);
        Order__c order = [SELECT Name,Id,Order_type__c,SAP_Order_Code__c,Locked_in_SAP__c,SAP_Update_Status__c  FROM Order__c WHERE Id=:orderId];
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        order.Locked_in_SAP__c = locked;
        order.Order_Change__c = false;
        update order;
        List<Order_Item__c> needUpdateOrderItemList=new List<Order_Item__c>();
        for(Order_Item__c orderItem:[
                                    SELECT 
                                        Id,Order__c,
                                        New_Amount__c,New_Delivery_Date__c,
                                        New_Quantity__c,New_Price__c 
                                    FROM 
                                        Order_Item__c 
                                    WHERE Order__c =:orderId
        ]){
        
            Order_Item__c oi=new Order_Item__c();
            oi.Id=orderItem.Id;
            if(orderItem.New_Price__c != null)
            {
                oi.Price__c=orderItem.New_Price__c;
                oi.New_Price__c=null;
            }
            if(orderItem.New_Quantity__c != null)
            {
                oi.Quantity__c=orderItem.New_Quantity__c;
                oi.New_Quantity__c=null;
            }
            if(orderItem.New_Amount__c != null)
            {
                oi.Amount_per_item__c=orderItem.New_Amount__c;
                oi.New_Amount__c=null;
            }
            if(orderItem.New_Delivery_Date__c != null)
            {
                oi.Delivery_Date__c=orderItem.New_Delivery_Date__c;
                oi.New_Delivery_Date__c=null;
            }
            needUpdateOrderItemList.add(oi);
        }
        System.debug('needUpdateOrderItemList=>'+needUpdateOrderItemList);
        if(needUpdateOrderItemList.size()>0)
        {
            Database.update(needUpdateOrderItemList);
        }
        return out;
    }



    @AuraEnabled
    public static Output init(String orderId) {
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try{
            Order__c order = [SELECT Id,Status__c,Sync_Status__c FROM Order__c WHERE Id =:orderId];
            if(order.Sync_Status__c=='Synchronized') {
                out.isLock = false;
            }else{
                out.isLock = true;
            }
            
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
        public Boolean isLock {get;set;}
       
    }

}