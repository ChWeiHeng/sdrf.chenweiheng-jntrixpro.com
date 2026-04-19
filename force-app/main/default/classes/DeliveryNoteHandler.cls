/**************************************************************************************************
* Name: DeliveryNoteHandler
* Object: Delivery_Note__c
* Purpose:  
* ************************************************************************************************
* History
* --------
* VERSION     AUTHOR              DATE            DETAIL             Description
* 1.0         zach	            2025-7-8         Created
***************************************************************************************************/
public without sharing class DeliveryNoteHandler implements Triggers.Handler{
    public void handle(){
        if (Trigger.isAfter && Trigger.isUpdate){
            updateOrderItem();
        }
        
        if (Trigger.isAfter && Trigger.isInsert){
            updateOrderItem();
        }
    }
    
	/**
	* @Author   Zach
    * @DateTime 2025-7-8
    * @Description  如果发货单的数量或者状态变更，则将Delivery_Note__c的数量汇总到Order_Item__c上
    */
    public static void updateOrderItem(){
        Set<String> itemIdSet = new Set<String>();
        for(Delivery_Note__c note : (List<Delivery_Note__c>)Trigger.new){
            
            Delivery_Note__c oldNote = (Delivery_Note__c)Trigger.oldMap?.get(note.Id);
            if((Trigger.isInsert || (Trigger.isUpdate && (note.Delivery_Cost__c != oldNote.Delivery_Cost__c || note.Delivery_Post_Status__c != oldNote.Delivery_Post_Status__c || note.Delivery_Quantity__c != oldNote.Delivery_Quantity__c || note.Issue_Quantity__c != oldNote.Issue_Quantity__c)))){
     			itemIdSet.add(note.Order_Item__c);
            }

        }
        system.debug(itemIdSet);
        if(itemIdSet.isEmpty()){
            return;
        }
        
        Map<String,Decimal> orderItemDeliveryMap = new Map<String,Decimal>();
        Map<String,Decimal> orderItemIssueMap = new Map<String,Decimal>();
        Map<String,Decimal> deliveryTotalCostMap = new Map<String,Decimal>();//发货单总成本Map
        Map<String,Decimal> deliveryCostMap = new Map<String,Decimal>();//发货单最新成本Map
        for(Delivery_Note__c note : [SELECT Id,Order_Item__c,Delivery_Post_Status__c,Issue_Quantity__c,Delivery_Quantity__c,Delivery_Cost__c FROM Delivery_Note__c WHERE Order_Item__c IN:itemIdSet AND (Delivery_Post_Status__c = 'C' OR Delivery_Post_Status__c='B') order by CreatedDate ]){
            //Delivery_Quantity__c
            if(!orderItemDeliveryMap.containsKey(note.Order_Item__c)){
                orderItemDeliveryMap.put(note.Order_Item__c,0);
            }
            Decimal deliveryQuantity = orderItemDeliveryMap.get(note.Order_Item__c);
            deliveryQuantity += note.Delivery_Quantity__c ?? 0;
			orderItemDeliveryMap.put(note.Order_Item__c,deliveryQuantity);
            
            //Issue_Quantity__c
            if(!orderItemIssueMap.containsKey(note.Order_Item__c)){
                orderItemIssueMap.put(note.Order_Item__c,0);
            }
            Decimal issueQuantity = orderItemIssueMap.get(note.Order_Item__c);
            issueQuantity += note.Issue_Quantity__c ?? 0;
			orderItemIssueMap.put(note.Order_Item__c,issueQuantity);
            
            //发货单成本------start
            if(!deliveryTotalCostMap.containsKey(note.Order_Item__c)){
                deliveryTotalCostMap.put(note.Order_Item__c,0);
            }
            Decimal deliveryCost = deliveryTotalCostMap.get(note.Order_Item__c);
            Decimal cost= (note.Delivery_Quantity__c ?? 0)*(note.Delivery_Cost__c??0);
            deliveryCost += cost;
			deliveryTotalCostMap.put(note.Order_Item__c,deliveryCost);
            deliveryCostMap.put(note.Order_Item__c, note.Delivery_Cost__c);//最新的成本
            //发货单成本------end
        }
        
        system.debug(orderItemDeliveryMap);
        system.debug(orderItemIssueMap);
        List<Order_Item__c> itemList = new List<Order_Item__c>();
        for(Order_Item__c item : [
                                    SELECT 
                                        Id,DN_Post_Date__c,Delivery_Quantity__c,Issue_Quantity__c,Order_Type__c 
                                    FROM 
                                    Order_Item__c 
                                    WHERE 
                                    Id IN:itemIdSet 
                                ]
        ){
            system.debug('item.id===='+item.Id);
            item.Delivery_Quantity__c = orderItemDeliveryMap.get(item.Id) ?? 0;
            item.Delivery_Total_Cost__c = deliveryTotalCostMap.get(item.Id) ?? 0;
            item.Delivery_Unit_Cost__c = deliveryCostMap.get(item.Id) ?? 0;
            if (item.Order_Type__c == 'ZARB') {
                item.Issue_Quantity__c = orderItemIssueMap.get(item.Id) ?? 0;
            }
            
            itemList.add(item);
        }
        update itemList;
    }
}