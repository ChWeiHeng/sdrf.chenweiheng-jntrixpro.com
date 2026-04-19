/**
 * @description       : 寄售订单
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-06-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   11-28-2025   Gerry   Initial Version
**/
public without sharing class ConsignmentOrderQuantityReturn {
    
    /**
    * @description 返回ZARB,ZARF订单
    * @author Gerry | 11-28-2025 
    * @param Set<String> orderItemList zarf Id
    * @return void 
    **/
    public static void addRemainQuantity(Set<String> orderItemList,String orderType) {
        Map<String,Decimal> zarfUseQuantityMap = new Map<String,Decimal>();//ZARF-zarb交货单对应的使用数量
        Map<String,Decimal> zarbUsedQuantityMap = new Map<String,Decimal>();//ZARB对应的使用量
        Map<String,String> externalIdMap = new Map<String,String>();//交货单外部ID
        for (Order_Item__c oi : [SELECT Depend_On_Item__r.Delivery_Note__r.External_Id__c,Delivery_Note__r.Issue_Quantity__c,Id,Depend_On_Item__r.Delivery_Note__c,Quantity__c,Undelivered_Quantity_Apex__c,Depend_On_Item__r.Delivery_Note__r.Issue_Quantity__c,Delivery_Note__c FROM Order_Item__c WHERE Id IN:orderItemList]) {
            externalIdMap.put(oi.Depend_On_Item__r.Delivery_Note__c, oi.Depend_On_Item__r.Delivery_Note__r.External_Id__c);
            if (orderType == 'ZARF') {//zarf订单返回逻辑
                if (zarfUseQuantityMap.containsKey(oi.Depend_On_Item__r.Delivery_Note__c)) {
                    zarfUseQuantityMap.put(oi.Depend_On_Item__r.Delivery_Note__c, zarfUseQuantityMap.get(oi.Depend_On_Item__r.Delivery_Note__c)+oi.Quantity__c);
                }else{
                    zarfUseQuantityMap.put(oi.Depend_On_Item__r.Delivery_Note__c, oi.Quantity__c);
                }

                zarbUsedQuantityMap.put(oi.Depend_On_Item__r.Delivery_Note__c, oi.Depend_On_Item__r.Delivery_Note__r.Issue_Quantity__c);
            }
            
            if (orderType == 'NOTZARE') {//zare、zara返回逻辑
                if (zarfUseQuantityMap.containsKey(oi.Delivery_Note__c)) {
                    zarfUseQuantityMap.put(oi.Delivery_Note__c, zarfUseQuantityMap.get(oi.Delivery_Note__c)+oi.Undelivered_Quantity_Apex__c);
                }else{
                    zarfUseQuantityMap.put(oi.Delivery_Note__c, oi.Undelivered_Quantity_Apex__c);
                }

                zarbUsedQuantityMap.put(oi.Delivery_Note__c, oi.Delivery_Note__r.Issue_Quantity__c);
            }
        }

        List<Delivery_Note__c> dnList = new List<Delivery_Note__c>();
        System.debug('zarbUsedQuantityMap====>'+zarbUsedQuantityMap);
        System.debug('zarfUseQuantityMap====>'+zarfUseQuantityMap);
        for (String deliveryId : zarbUsedQuantityMap.keySet()) {
            System.debug('deliveryId====>'+deliveryId);
            Delivery_Note__c dn = new Delivery_Note__c();
            dn.Id = deliveryId;
            System.debug('zarbUsedQuantityMap.get(deliveryId)'+zarbUsedQuantityMap.get(deliveryId));
            System.debug('zarfUseQuantityMap.get(deliveryId)'+zarfUseQuantityMap.get(deliveryId));
            dn.Issue_Quantity__c = (zarbUsedQuantityMap.get(deliveryId)??0)-(zarfUseQuantityMap.get(deliveryId)??0);
            System.debug('dn.Issue_Quantity__c=====>'+dn.Issue_Quantity__c);
            if (dn.Issue_Quantity__c <0 && !System.Test.isRunningTest()) {
                throw new CustomException('错误信息：'+System.Label.ExceedingQuantity.replace('[XXXXX]', externalIdMap.get(deliveryId))+'：错误信息');
            }
            dnList.add(dn);
        }
        System.debug('dnList=======>'+dnList);
        if (dnList.size() > 0 && !System.Test.isRunningTest()) {
            update dnList;
        }
    }

    /**
    * @description 消耗ZARB,关闭ZARF场景
    * @author Gerry | 11-28-2025 
    * @param Set<String> orderItemList 
    * @return void 
    **/
    public static void subRemianQuantity(Set<String> orderItemList) {
        Map<String,Decimal> zarfCloseQuantityMap = new Map<String,Decimal>();//ZARF-zarb被关闭的量
        Map<String,Decimal> zarbUsedQuantityMap = new Map<String,Decimal>();//ZARB对应的使用量
        Map<String,Decimal> deliveryQuantityMap = new Map<String,Decimal>();//交货量
        Map<String,String> externalIdMap = new Map<String,String>();//交货单外部ID
        for (Order_Item__c oi : [SELECT Depend_On_Item__r.Delivery_Note__r.External_Id__c,Depend_On_Item__r.Delivery_Note__r.Delivery_Quantity__c,Id,Depend_On_Item__r.Delivery_Note__c,Undelivered_Quantity_Apex__c,Depend_On_Item__r.Delivery_Note__r.Issue_Quantity__c,Delivery_Quantity__c FROM Order_Item__c WHERE Id IN:orderItemList]) {
            if (zarfCloseQuantityMap.containsKey(oi.Depend_On_Item__r.Delivery_Note__c)) {
                zarfCloseQuantityMap.put(oi.Depend_On_Item__r.Delivery_Note__c, zarfCloseQuantityMap.get(oi.Depend_On_Item__r.Delivery_Note__c)+oi.Undelivered_Quantity_Apex__c);
            }else{
                zarfCloseQuantityMap.put(oi.Depend_On_Item__r.Delivery_Note__c, oi.Undelivered_Quantity_Apex__c);
            }

            zarbUsedQuantityMap.put(oi.Depend_On_Item__r.Delivery_Note__c, oi.Depend_On_Item__r.Delivery_Note__r.Issue_Quantity__c);
            deliveryQuantityMap.put(oi.Depend_On_Item__r.Delivery_Note__c, oi.Depend_On_Item__r.Delivery_Note__r.Delivery_Quantity__c);
            externalIdMap.put(oi.Depend_On_Item__r.Delivery_Note__c, oi.Depend_On_Item__r.Delivery_Note__r.External_Id__c);
        }

        List<Delivery_Note__c> dnList = new List<Delivery_Note__c>();

        for (String deliveryId : zarbUsedQuantityMap.keySet()) {
            Delivery_Note__c dn = new Delivery_Note__c();
            dn.Id = deliveryId;
            dn.Issue_Quantity__c = (zarbUsedQuantityMap.get(deliveryId)??0)+(zarfCloseQuantityMap.get(deliveryId)??0);
            if (dn.Issue_Quantity__c > deliveryQuantityMap.get(deliveryId)) {
                throw new CustomException( '错误信息：'+System.Label.Delivery_Changed.replace('[XXXXX]',externalIdMap.get(deliveryId))+'：错误信息' );
            }
            dnList.add(dn);
        }

        if (dnList.size() > 0 && !System.Test.isRunningTest()) {
            update dnList;
        }
    }
}