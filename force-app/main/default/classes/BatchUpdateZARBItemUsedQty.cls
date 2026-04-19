//illion 20250826 仅用于期初数据的刷新
global without sharing class BatchUpdateZARBItemUsedQty implements Database.Batchable<sObject>,Schedulable,Database.Stateful {
	public Set<String> zarbIdSet = new Set<String>();
	public String errorMsg;
    public Datetime startTime;
    public Boolean flag = TRUE;

	global BatchUpdateZARBItemUsedQty(){
        
    }

    global BatchUpdateZARBItemUsedQty(Set<String> zarbIdSet){
        this.zarbIdSet = zarbIdSet;
    }

	global Database.QueryLocator start(Database.BatchableContext bc){
        startTime = System.now();
        String sql = 
	                    'SELECT '+
	                        'Id,'+
	                        'Commodity__c,Commodity__r.Product_Sales_Info__r.Cost_Local__c,Commodity__r.Product_Sales_Info__r.Cost_USD__c,'+
	                        'Price__c,Commodity__r.Product__r.Description_User__c,Order__r.Order_type__c,'+
	                        'Sales_Unit__c,Commodity__r.Product__r.Name,'+
	                        'Commodity__r.Name,TOLabel(Sales_Unit__r.Product_Sales_Unit__c),'+
	                        'Quantity__c,Used_Number__c,Basic_Number__c,Order__r.SAP_Order_Code__c,Order__r.CreatedDate,Price_Book_Item__c,Delivery_Quantity__c,isClosed__c '+
	                    'FROM '+
	                        'Order_Item__c  '+
	                    'WHERE '+
	                            'Order__r.Order_type__c=\'ZARB\' AND Order__r.Status__c=\'Approved\'';

	    system.debug(zarbIdSet);
        if(zarbIdSet != NULL && !zarbIdSet.isEmpty()){
            sql += ' AND Order__c IN:zarbIdSet';
        }
        
        return Database.getQueryLocator(sql);  
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new BatchUpdateZARBItemUsedQty());
    }
    
    global void execute(Database.BatchableContext BC,List<Order_Item__c> itemList){
        system.debug('itemList===='+itemList);
        Set<String> oiIdSet = new Set<String>();
        for(Order_Item__c oi : itemList){
        	oiIdSet.add(oi.Id);
        }

        try{
            //Approving/Approved ZARE
            Map<String,Decimal> inventoryZAREMap = new Map<String,Decimal>();
            //Approving/Approved ZARA
            Map<String,Decimal> inventoryZARAMap = new Map<String,Decimal>();
            //Approved ZARF
            Map<String,Decimal> inventoryZARFMap = new Map<String,Decimal>();
            for (AggregateResult agg1 : [
                                        SELECT 
                                            Depend_On_Item__c depend,
                                            SUM(Quantity__c) usedNum
                                        FROM 
                                            Order_Item__c 
                                        WHERE 
                                            Depend_On_Item__c IN:oiIdSet
                                            AND (Order__r.Status__c='Approved' OR Order__r.Status__c='Approving') AND Order__r.Order_type__c='ZARE' AND isClosed__c = false
                                            Group by Depend_On_Item__c
            ]) {
                inventoryZAREMap.put((String)agg1.get('depend'), (Decimal)agg1.get('usedNum'));
            }

            for (AggregateResult agg2 : [
                                        SELECT 
                                            Depend_On_Item__c depend,
                                            SUM(Quantity__c) usedNum
                                        FROM 
                                            Order_Item__c 
                                        WHERE 
                                            Depend_On_Item__c IN:oiIdSet
                                            AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARF' AND isClosed__c = false
                                            Group by Depend_On_Item__c
            ]) {
                inventoryZARFMap.put((String)agg2.get('depend'), (Decimal)agg2.get('usedNum'));
        	}

            for (AggregateResult agg3 : [
                                        SELECT 
                                            Depend_On_Item__c depend,
                                            SUM(Quantity__c) usedNum
                                        FROM 
                                            Order_Item__c 
                                        WHERE 
                                            Depend_On_Item__c IN:oiIdSet
                                            AND (Order__r.Status__c='Approved' OR Order__r.Status__c='Approving') AND Order__r.Order_type__c='ZARA' AND isClosed__c = false
                                            Group by Depend_On_Item__c
            ]) {
                inventoryZARAMap.put((String)agg3.get('depend'), (Decimal)agg3.get('usedNum'));
            }

            for(Order_Item__c oi : itemList){
            	Decimal zara = inventoryZARAMap.get(oi.Id)==null? 0:inventoryZARAMap.get(oi.Id);
            	Decimal zare = inventoryZAREMap.get(oi.Id)==null? 0:inventoryZAREMap.get(oi.Id);
            	Decimal zarf = inventoryZARFMap.get(oi.Id)==null? 0:inventoryZARFMap.get(oi.Id);
            	system.debug('zara===='+zara+'zare===='+zare+'zarf===='+zarf);
            	oi.ZARB_Used_Quantity_Test_Only__c = (zara + zare -zarf);
            }

            update itemList;

        }catch (Exception e) {
            flag = FALSE;
            errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }
    
    global void finish(Database.BatchableContext bc) {
		Utility.setBatchInfo('BatchUpdateZARBItemUsedQty', flag, startTime, errorMsg);
    }
}