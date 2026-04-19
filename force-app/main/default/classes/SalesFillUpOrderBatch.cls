/**************************************************************************************************
 * Name: SalesOrderInvoiceBatch
 * Object: 
 * Purpose: 销售发票数据
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-20         Created             
***************************************************************************************************/
global without sharing class SalesFillUpOrderBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    public String query;
    public String filedStr;
    public String type;
    public Date closeDate;
    global String errorMsg;
    global Datetime startTime;
    global Boolean flag;
    global SalesFillUpOrderBatch() {
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT Id,Delivery_Quantity__c,Collection_Transaction_Amount__c FROM Order_Item__c WHERE Order__r.Status__c=\'Approved\' AND Order__r.Order_type__c=\'ZARB\' ';
    }

    global void execute(SchedulableContext sc) {
        SalesFillUpOrderBatch svo = new SalesFillUpOrderBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 100);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order_Item__c> orderList) {
        try {
            Set<String> orderItemIdSet = new Set<String>();
            for (Order_Item__c ord : orderList) {
                orderItemIdSet.add(ord.Id);
            }
            Set<String> zareIdSet = new Set<String>();
            Map<String,List<String>> ZARBToZAREMap = new Map<String,List<String>>();
            for (Order_Item__c oi : [SELECT Id,Depend_On_Item__c FROM Order_Item__c WHERE Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARE' AND Depend_On_Item__c IN:orderItemIdSet]) {
                zareIdSet.add(oi.Id);
                if (ZARBToZAREMap.containsKey(oi.Depend_On_Item__c)) {
                    ZARBToZAREMap.get(oi.Depend_On_Item__c).add(oi.Id);
                }else{
                    ZARBToZAREMap.put(oi.Depend_On_Item__c, new List<String>{oi.Id});
                }
            }
            System.debug('ZARBToZAREMap'+ZARBToZAREMap);
            System.debug('zareIdSet'+zareIdSet);
            //没有关闭
            Map<String,Decimal> inventoryQuanMap = new Map<String,Decimal>();
            for (AggregateResult agg : [
                                        SELECT 
                                            Depend_On_Item__c depend,
                                            SUM(Quantity__c) usedNum
                                        FROM 
                                            Order_Item__c 
                                        WHERE 
                                            Depend_On_Item__c IN:orderItemIdSet
                                            AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARE' AND isClosed__c=false
                                            Group by Depend_On_Item__c
            ]) {
                inventoryQuanMap.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
            }

            //关闭的
            Map<String,Decimal> inventoryQuanMap1 = new Map<String,Decimal>();
            for (AggregateResult agg : [
                                        SELECT 
                                            Depend_On_Item__c depend,
                                            SUM(Delivery_Quantity__c) usedNum
                                        FROM 
                                            Order_Item__c 
                                        WHERE 
                                            Depend_On_Item__c IN:orderItemIdSet
                                            AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARE' AND isClosed__c=true
                                            Group by Depend_On_Item__c
            ]) {
                inventoryQuanMap1.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
            }

            //没有关闭的
            Map<String,Decimal> addQuanMap = new Map<String,Decimal>();
            for (AggregateResult agg : [
                                        SELECT 
                                            Depend_On_Item__c depend,
                                            SUM(Quantity__c) usedNum
                                        FROM 
                                            Order_Item__c 
                                        WHERE 
                                            Depend_On_Item__c IN:zareIdSet
                                            AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARF' AND isClosed__c=false
                                            Group by Depend_On_Item__c
            ]) {
                addQuanMap.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
            }

            //关闭的
            Map<String,Decimal> addQuanMap1 = new Map<String,Decimal>();
            for (AggregateResult agg : [
                                        SELECT 
                                            Depend_On_Item__c depend,
                                            SUM(Delivery_Quantity__c) usedNum
                                        FROM 
                                            Order_Item__c 
                                        WHERE 
                                            Depend_On_Item__c IN:zareIdSet
                                            AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARF' AND isClosed__c=true
                                            Group by Depend_On_Item__c
            ]) {
                addQuanMap1.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
            }

            //没有关闭的
            Map<String,Decimal> retrunQuanMap = new Map<String,Decimal>();
            for (AggregateResult agg : [
                                        SELECT 
                                            Depend_On_Item__c depend,
                                            SUM(Quantity__c) usedNum
                                        FROM 
                                            Order_Item__c 
                                        WHERE 
                                            Depend_On_Item__c IN:orderItemIdSet
                                            AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARA' AND isClosed__c=false
                                            Group by Depend_On_Item__c
            ]) {
                retrunQuanMap.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
            }

            //关闭的
            Map<String,Decimal> retrunQuanMap1 = new Map<String,Decimal>();
            for (AggregateResult agg : [
                                        SELECT 
                                            Depend_On_Item__c depend,
                                            SUM(Delivery_Quantity__c) usedNum
                                        FROM 
                                            Order_Item__c 
                                        WHERE 
                                            Depend_On_Item__c IN:orderItemIdSet
                                            AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARA' AND isClosed__c=true
                                            Group by Depend_On_Item__c
            ]) {
                retrunQuanMap1.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
            }

            Map<String,Decimal> approvingNumMap = new Map<String,Decimal>();
            for (AggregateResult agg : [
                                        SELECT 
                                            Depend_On_Item__c depend,
                                            SUM(Quantity__c) usedNum
                                        FROM 
                                            Order_Item__c 
                                        WHERE 
                                            Depend_On_Item__c IN:orderItemIdSet
                                            AND (Order__r.Status__c='Approving' OR (Order__r.Status__c='Approved' AND Order__r.Sync_Status__c!='Synchronized'))
                                            Group by Depend_On_Item__c
            ]) {
                approvingNumMap.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
            }

            List<Order_Item__c> updateOrderList = new List<Order_Item__c>();
            System.debug('addQuanMap'+addQuanMap);
            System.debug('addQuanMap1'+addQuanMap1);
            for (Order_Item__c ord : orderList) {
                Decimal addNum = 0;
                if (ZARBToZAREMap.get(ord.Id) != null) {
                    for (String zareId : ZARBToZAREMap.get(ord.Id)) {
                        addNum += (addQuanMap.get(zareId)??0);
                    }
                }
                
                Decimal retrunNum = retrunQuanMap.get(ord.Id)==null? 0:retrunQuanMap.get(ord.Id);
                Decimal usedNum = inventoryQuanMap.get(ord.Id)==null? 0:inventoryQuanMap.get(ord.Id);

                Decimal addNum1 = 0;
                if (ZARBToZAREMap.get(ord.Id) != null) {
                    for (String zareId : ZARBToZAREMap.get(ord.Id)) {
                        addNum1 += (addQuanMap1.get(zareId)??0);
                    }
                }
                
                Decimal retrunNum1 = retrunQuanMap1.get(ord.Id)==null? 0:retrunQuanMap1.get(ord.Id);
                Decimal usedNum1 = inventoryQuanMap1.get(ord.Id)==null? 0:inventoryQuanMap1.get(ord.Id);
                Order_Item__c oiUpdate = new Order_Item__c();
                oiUpdate.id = ord.Id;
                oiUpdate.Fill_UP_Send_Back__c = addNum+addNum1;
                oiUpdate.Fill_UP_Return_Goods__c = retrunNum+retrunNum1;
                oiUpdate.Fill_UP_Used_Num__c = usedNum+usedNum1;
                updateOrderList.add(oiUpdate);
            }   

            Database.update(updateOrderList);
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('SalesFillUpOrderBatch', this.flag, this.startTime, this.errorMsg);
    }
}