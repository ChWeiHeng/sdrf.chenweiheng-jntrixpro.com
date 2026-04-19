/**************************************************************************************************
 * Name: ViewSAPInventoryLWCController
 * Object: 
 * Purpose: 提交审批控制类
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-18         Created             
***************************************************************************************************/
public without sharing class ViewSAPInventoryLWCController {
    // @AuraEnabled
    // public Static Output init(String orderId) {
    //     try {
    //         Map<String,String > vaeluMap = Utility.getPicklistValueMap('Product_Inventory__c','Storage_Location__c');
    //         Set<Id> productSalesIdSet = new Set<Id>();
    //         Set<String> proIdSet = new Set<String>();
    //         Set<String> plantSet = new Set<String>();
    //         for (Order_Item__c oi : [SELECT Id,Commodity__r.Product_Sales_Info__c,Commodity__c,Order__r.Deliver_Plant__c FROM Order_Item__c WHERE Order__c =:orderId]) {
    //             productSalesIdSet.add(oi.Commodity__r.Product_Sales_Info__c);
    //             proIdSet.add(oi.Commodity__c);
    //             plantSet.add(oi.Order__r.Deliver_Plant__c);
    //         }
    //         List<Id> idList = new List<Id>();
    //         idList.addAll(productSalesIdSet);
            
    //         ProductSalesInfoSyncToSAP.ReturnResult reslut;
    //         //【modified by zach 修改ZARE以外的订单页面上Quantity的数量逻辑（CLABS - ZAVIN - 所有order为审批中的order item总数（包含自身）2025/8/6 -start】
  	// 		//查询的库存
    //         Map<String,Decimal> inventoryMap = new Map<String,Decimal>();询的库存
    //         Map<String,Decimal> inventoryMap = new Map<String,Decimal>();
    //         //所有order为审批中的order item总数（包含自身）
    //         Map<String,Decimal> proQuantityMap = ProductSalesInfoSyncToSAP.getApprovingQuantity(proIdSet,plantSet);
    //         //【modified by zach 修改ZARE以外的订单页面上Quantity的数量逻辑（CLABS - ZAVIN - 所有order为审批中的order item总数（包含自身）2025/8/6 -end】
            
    //         if (!System.Test.isRunningTest()) {
    //             reslut = ProductSalesInfoSyncToSAP.submitToSAP(idList);
    //             inventoryMap = reslut.returnMap;
    //             system.debug(inventoryMap);
    //         }else{
    //             reslut = new ProductSalesInfoSyncToSAP.ReturnResult();
    //             reslut.isSuccess = true;
    //             reslut.message = 'Success';
    //         }
    //         if (!reslut.isSuccess) {
    //             Output out = new Output();
    //             out.isSucess = false;
    //             out.errorMsg = reslut.message;
    //             System.debug('out.errorMsg===>'+out.errorMsg);
    //             if (!reslut.message.contains('No Data Found')) {
    //                 return out;
    //             }
                
                
    //         }
    //         Output out = new Output();
    //         out.isSucess = true;
    //         out.orderItemList = new List<OrderInfo>();
    //         Order__c orInof = [SELECT Id,Order_type__c,Deliver_Plant__c,Customer__c FROM Order__c WHERE Id=:orderId];
    //         List<Order_Item__c> orItemList = [SELECT Sales_Unit__r.Conversion_Coefficient__c,Order__r.Deliver_Plant__c,Quantity__c,Default_Unit_Quantity__c,TOLabel(Commodity__r.Product_Sales_Info__r.Default_Sales_Unit__c),Commodity__r.Product__r.Basic_Metering_Unit__c,Id,Commodity__r.Name,Commodity__r.Product__r.Name,Commodity__r.Product_Sales_Info__r.Product__r.English_Description__c,TOLabel(Sales_Unit__r.Product_Sales_Unit__c) FROM Order_Item__c WHERE Order__c=:orderId];
    //         Map<String,Decimal> inventoryQuanMap = new Map<String,Decimal>();

    //         //Limbo 查询当前审批中的订单，获取其下订单行对应产品数量
    //         Map<String,Decimal> orderItemAppQuanMap = new Map<String,Decimal>();

    //         if (orInof.Order_type__c=='ZARE') {
    //             Set<String> searchKeySet = new Set<String>();
    //             Map<String,String> unitMap = new Map<String,String>();
    //             Map<String,Decimal> rateMap = new Map<String,Decimal>();
    //             Set<String> nameSet = new Set<String>();
    //             for (Order_Item__c orItem : orItemList) {
    //                 rateMap.put(orItem.Commodity__r.Name, orItem.Sales_Unit__r.Conversion_Coefficient__c);
    //                 searchKeySet.add(orItem.Commodity__r.Product__r.Name+'-'+orItem.Order__r.Deliver_Plant__c+'-'+orItem.Commodity__r.Name+'-'+orInof.Customer__c);
    //                 unitMap.put(orItem.Commodity__r.Name, orItem.Commodity__r.Product_Sales_Info__r.Default_Sales_Unit__c);
    //                 nameSet.add(orItem.Commodity__r.Name);
    //             }

    //             //limbo 查询当前审批中的订单，获取其下订单行对应产品数量
    //             for(Order_Item__c orItem : [SELECT ID,Quantity__c,Commodity__r.Product__r.Name,Order__r.Deliver_Plant__c,Commodity__r.Name,Order__r.Customer__c FROM Order_Item__c WHERE Commodity__r.Name IN: nameSet and Order__r.Deliver_Plant__c =: orInof.Deliver_Plant__c AND Order__R.Status__c = 'Approving']){
    //                 if(!orderItemAppQuanMap.containsKey(orItem.Commodity__r.Name) ){
    //                     orderItemAppQuanMap.put(orItem.Commodity__r.Name, orItem.Quantity__c);
    //                 }else{
    //                     orderItemAppQuanMap.put(orItem.Commodity__r.Name, orItem.Quantity__c +  orderItemAppQuanMap.get(orItem.Commodity__r.Name));
    //                 }
    //             }

    //             // Integer index = 1;
    //             // for (AggregateResult agg : [SELECT SUM(Consign_Inventory_Quantity__c) num,Search_Key__c pname FROM Product_Inventory__c WHERE Search_Key__c IN:searchKeySet  AND Consign_Inventory_Quantity__c!=null Group by Search_Key__c]) {
    //             //     inventoryQuanMap.put((String)agg.get('pname'), (Decimal)agg.get('num'));
    //             // }
    //             Map<String,OrderInfo> orderInfoMap = new Map<String,OrderInfo>();
    //             Set<String> existData = new Set<String>();
    //             System.debug('searchKeySet'+searchKeySet);
    //             for (Product_Inventory__c pi : [SELECT Sales_Unit_Inventory__c,Default_Unit__c,Product_Name_Text__c,Storage_Location__c,Consign_Inventory_Quantity__c,Search_Key__c,Product__r.Name,Available_Quantity__c FROM Product_Inventory__c WHERE Search_Key__c IN:searchKeySet  AND Consign_Inventory_Quantity__c!=null]) {
    //                 System.debug('进入查询逻辑');
    //                 OrderInfo oi = new OrderInfo();

    //                 //LIMBO-07-31 相同产品不同仓库地址的订单行放在一起，数量相加
    //                 // if (orderInfoMap.containsKey(pi.Product_Name_Text__c+'-'+pi.Storage_Location__c)) {
    //                 //     oi = orderInfoMap.get(pi.Product_Name_Text__c+'-'+pi.Storage_Location__c);
    //                 //     Decimal number1 = (pi.Consign_Inventory_Quantity__c==null? 0:pi.Consign_Inventory_Quantity__c);
    //                 //     oi.Quantity = oi.Quantity+number1;

    //                 //     Decimal number2 = (pi.Sales_Unit_Inventory__c==null? 0:pi.Sales_Unit_Inventory__c);
    //                 //     oi.salesQuantity = oi.salesQuantity+number2;
    //                 // }else{
    //                 //     oi.Quantity = pi.Consign_Inventory_Quantity__c==null? 0:pi.Consign_Inventory_Quantity__c;
    //                 //     orderInfoMap.put(pi.Product_Name_Text__c+'-'+pi.Storage_Location__c, oi);
    //                 //     oi.salesQuantity = pi.Sales_Unit_Inventory__c==null? 0:pi.Sales_Unit_Inventory__c;
    //                 // }

    //                 if (orderInfoMap.containsKey(pi.Product_Name_Text__c)) {
    //                     oi = orderInfoMap.get(pi.Product_Name_Text__c);
    //                     Decimal number1 = (pi.Consign_Inventory_Quantity__c==null? 0:pi.Consign_Inventory_Quantity__c);
    //                     Decimal number3 = (pi.Available_Quantity__c==null? 0:pi.Available_Quantity__c);
    //                     oi.Quantity = oi.Quantity+number1 - number3;

    //                     Decimal number2 = (pi.Sales_Unit_Inventory__c==null? 0:pi.Sales_Unit_Inventory__c);
    //                     oi.salesQuantity = oi.salesQuantity+number2;
    //                 }else{
    //                     Decimal number1 = (pi.Consign_Inventory_Quantity__c==null? 0:pi.Consign_Inventory_Quantity__c);
    //                     Decimal number3 = (pi.Available_Quantity__c==null? 0:pi.Available_Quantity__c);
    //                     oi.Quantity = number1 - number3;
    //                     orderInfoMap.put(pi.Product_Name_Text__c, oi);
    //                     oi.salesQuantity = pi.Sales_Unit_Inventory__c==null? 0:pi.Sales_Unit_Inventory__c;
    //                 }

    //                 // oi.index = String.valueOf(index);
    //                 oi.productName = pi.Product_Name_Text__c;
    //                 // oi.salesUnit = unitMap.get(oi.productName);
    //                 oi.salesUnit = unitMap.get(oi.productName);
    //                 oi.defaultUnit = pi.Default_Unit__c;
    //                 // oi.Quantity = pi.Consign_Inventory_Quantity__c==null? 0:pi.Consign_Inventory_Quantity__c;
    //                 oi.address = (vaeluMap.get(pi.Storage_Location__c)==null?'':vaeluMap.get(pi.Storage_Location__c));
    //                 // out.orderItemList.add(oi);
    //                 // index++;
    //                 existData.add(pi.Product_Name_Text__c);
    //             }

    //             System.debug('orderInfoMap'+orderInfoMap);

    //             Integer index = 1;
    //             for (OrderInfo oi : orderInfoMap.values()) {
    //                 // if (rateMap.get(oi.productName)!=null) {
    //                 //     oi.Quantity = oi.Quantity/rateMap.get(oi.productName).setScale(2);
    //                 // }else{
                    
    //                 //limbo 0731 增加减去订单行明细数量的逻辑
    //                 if(orderItemAppQuanMap.containsKey(oi.productName)){
    //                     Decimal appQuantity = orderItemAppQuanMap.get(oi.productName);
    //                     oi.Quantity = oi.quantity - orderItemAppQuanMap.get(oi.productName);
    //                 }else{
    //                     oi.Quantity = oi.Quantity;
    //                 }
                        
    //                 // }
    //                 oi.index = String.valueOf(index);
    //                 out.orderItemList.add(oi);
    //                 index++;
    //             }
    //             for (String key : nameSet) {
    //                 if (!existData.contains(key)) {
    //                     OrderInfo oi = new OrderInfo();
    //                     oi.Quantity = 0;
    //                     oi.index = String.valueOf(index);
    //                     oi.productName = key;
    //                     out.orderItemList.add(oi);
    //                     oi.salesUnit = '/';
    //                     oi.address = '/';
    //                     oi.defaultUnit = '/';
    //                     oi.salesQuantity = 0;
    //                     index++;
    //                 }
    //             }
    //         }else{
    //             Map<String,Decimal> searchKeyMap = new Map<String,Decimal>();
    //             Map<String,String> unitMap = new Map<String,String>();
    //             Map<String,Decimal> rateMap = new Map<String,Decimal>();
    //             Set<String> nameSet = new Set<String>();
    //             for (Order_Item__c orItem : orItemList) {
    //                 rateMap.put(orItem.Commodity__r.Name, orItem.Sales_Unit__r.Conversion_Coefficient__c);
    //                 searchKeyMap.put(orItem.Commodity__r.Product__r.Name+'-'+orItem.Order__r.Deliver_Plant__c+'-'+orItem.Commodity__r.Name,orItem.Default_Unit_Quantity__c);
    //                 unitMap.put(orItem.Commodity__r.Name, orItem.Commodity__r.Product_Sales_Info__r.Default_Sales_Unit__c);
    //                 nameSet.add(orItem.Commodity__r.Name);
    //             }
                

    //             //limbo 查询当前审批中的订单，获取其下订单行对应产品数量
    //             /*for(Order_Item__c orItem : [SELECT ID,Quantity__c,Commodity__r.Product__r.Name,Order__r.Deliver_Plant__c,Commodity__r.Name,Order__r.Customer__c FROM Order_Item__c WHERE Commodity__r.Name IN: nameSet and Order__r.Deliver_Plant__c =:  orInof.Deliver_Plant__c AND Order__R.Status__c = 'Approving']){
    //                 if(!orderItemAppQuanMap.containsKey(orItem.Commodity__r.Name) ){
    //                     orderItemAppQuanMap.put(orItem.Commodity__r.Name, orItem.Quantity__c);
    //                 }else{
    //                     orderItemAppQuanMap.put(orItem.Commodity__r.Name, orItem.Quantity__c +  orderItemAppQuanMap.get(orItem.Commodity__r.Name));
    //                 }
    //             }*/

    //             System.debug('searchKeyMap===>'+searchKeyMap);
    //             Map<String,OrderInfo> orderInfoMap = new Map<String,OrderInfo>();
    //             Set<String> existData = new Set<String>();
    //             for (Product_Inventory__c pi : [SELECT Sales_Unit_Inventory__c,Default_Unit__c,Inventory_Quantity__c,Product_Name_Text__c,Storage_Location__c,Consign_Inventory_Quantity__c,Search_Key__c,Product__r.Name,Available_Quantity__c FROM Product_Inventory__c WHERE Search_Key__c IN:searchKeyMap.keySet()  AND Inventory_Quantity__c!=null]) {
    //                 OrderInfo oi = new OrderInfo();

    //                 //LIMBO-07-31 相同产品不同仓库地址的订单行放在一起，数量相加
    //                 // if (orderInfoMap.containsKey(pi.Product_Name_Text__c+'-'+pi.Storage_Location__c)) {
                        
    //                 //     oi = orderInfoMap.get(pi.Product_Name_Text__c+'-'+pi.Storage_Location__c);
    //                 //     Decimal number1 = (pi.Inventory_Quantity__c==null? 0:pi.Inventory_Quantity__c);
    //                 //     oi.Quantity = oi.Quantity+number1;
    //                 //     Decimal number2 = (pi.Sales_Unit_Inventory__c==null? 0:pi.Sales_Unit_Inventory__c);
    //                 //     oi.salesQuantity = oi.salesQuantity+number2;
    //                 // }else{
    //                 //     oi.Quantity = pi.Inventory_Quantity__c==null? 0:pi.Inventory_Quantity__c;
    //                 //     orderInfoMap.put(pi.Product_Name_Text__c+'-'+pi.Storage_Location__c, oi);
    //                 //     oi.salesQuantity = pi.Sales_Unit_Inventory__c==null? 0:pi.Sales_Unit_Inventory__c;
    //                 // }

    //                 if (orderInfoMap.containsKey(pi.Product_Name_Text__c)) {
                        
    //                     oi = orderInfoMap.get(pi.Product_Name_Text__c);
    //                     Decimal number1 = (pi.Inventory_Quantity__c==null? 0:pi.Inventory_Quantity__c);
    //                     Decimal number3 = (pi.Available_Quantity__c==null? 0:pi.Available_Quantity__c);
    //                     oi.Quantity = oi.Quantity+number1-number3;
    //                     Decimal number2 = (pi.Sales_Unit_Inventory__c==null? 0:pi.Sales_Unit_Inventory__c);
    //                     oi.salesQuantity = oi.salesQuantity+number2;
    //                 }else{
    //                     Decimal number1 = (pi.Inventory_Quantity__c==null? 0:pi.Inventory_Quantity__c);
    //                     Decimal number3 = (pi.Available_Quantity__c==null? 0:pi.Available_Quantity__c);
    //                     oi.Quantity = number1 - number3;
    //                     orderInfoMap.put(pi.Product_Name_Text__c, oi);
    //                     oi.salesQuantity = pi.Sales_Unit_Inventory__c==null? 0:pi.Sales_Unit_Inventory__c;
    //                 }

    //                 // oi.index = String.valueOf(index);
    //                 oi.productName = pi.Product_Name_Text__c;
    //                 oi.salesUnit = unitMap.get(oi.productName);
    //                 oi.defaultUnit = pi.Default_Unit__c;
    //                 // oi.Quantity = String.valueOf(pi.Inventory_Quantity__c==null? 0:pi.Inventory_Quantity__c);
    //                 oi.address = (vaeluMap.get(pi.Storage_Location__c)==null?'':vaeluMap.get(pi.Storage_Location__c));
    //                 // out.orderItemList.add(oi);
    //                 existData.add(pi.Product_Name_Text__c);
    //                 //【modified by zach 修改ZARE以外的订单页面上Quantity的数量逻辑（CLABS - ZAVIN - 所有order为审批中的order item总数（包含自身）2025/8/6 -start】
    //                 system.debug(inventoryMap.get(pi.Search_Key__c) );
    //                 system.debug(proQuantityMap.get(pi.Search_Key__c) );
    //                 oi.Quantity = (inventoryMap.get(pi.Search_Key__c) ?? 0) - (proQuantityMap.get(pi.Search_Key__c) ?? 0);
    //                 //【modified by zach 修改ZARE以外的订单页面上Quantity的数量逻辑（CLABS - ZAVIN - 所有order为审批中的order item总数（包含自身）2025/8/6 -end】
    //             }
    //             Integer index = 1;
    //             System.debug('rateMap======>'+rateMap);

    //             System.debug('orderInfoMap'+orderInfoMap);

    //             for (OrderInfo oi : orderInfoMap.values()) {
    //                 System.debug('oi.productName=====>'+oi.productName);
    //                 System.debug('rateMap.get(oi.productName)'+rateMap.get(oi.productName));
    //                 // if (rateMap.get(oi.productName)!=null) {
    //                 //     oi.Quantity = (oi.Quantity/rateMap.get(oi.productName)).setScale(2);
    //                 // }else{
                    
    //                 //【modified by zach 审批中的订单已经减去，避免重复减 2025/8/14 -start】
    //                 //limbo 0731 增加减去订单行明细数量的逻辑
    //                 /*if(orderItemAppQuanMap.containsKey(oi.productName)){
    //                         Decimal appQuantity = orderItemAppQuanMap.get(oi.productName);
    //                         oi.Quantity = oi.quantity - orderItemAppQuanMap.get(oi.productName);
    //                     }else{
    //                         oi.Quantity = oi.Quantity;
    //                     }
    //                 }*/
    //                 //
                    
    //                 oi.index = String.valueOf(index);
    //                 out.orderItemList.add(oi);
    //                 index++;
    //             }
    //             System.debug('nameSet====>'+nameSet);
    //             System.debug('existData===>'+existData);
    //             for (String key : nameSet) {
    //                 if (!existData.contains(key)) {
    //                     OrderInfo oi = new OrderInfo();
    //                     oi.Quantity = 0;
    //                     oi.index = String.valueOf(index);
    //                     oi.productName = key;
    //                     oi.salesUnit = '/';
    //                     oi.address = '/';
    //                     oi.defaultUnit = '/';
    //                     oi.salesQuantity = 0;
    //                     out.orderItemList.add(oi);
    //                     index++;
    //                 }
    //             }
    //             // for (AggregateResult agg : [SELECT SUM(Inventory_Quantity__c) num,Search_Key__c pname FROM Product_Inventory__c WHERE Search_Key__c IN:searchKeySet  AND Inventory_Quantity__c!=null Group by Search_Key__c]) {
    //             //     inventoryQuanMap.put((String)agg.get('pname'), (Decimal)agg.get('num'));
    //             // }
    //             // for (String key : searchKeySet) {
    //             //     OrderInfo oi = new OrderInfo();
    //             //     oi.index = String.valueOf(index);
    //             //     oi.productName = key.substring(0,key.indexOf('-'));
    //             //     oi.salesUnit = unitMap.get(oi.productName);
    //             //     oi.Quantity = String.valueOf(inventoryQuanMap.get(key)==null? 0:inventoryQuanMap.get(key));
    //             //     out.orderItemList.add(oi);
    //             //     index++;
    //             // }
    //         }
    //         return out;
    //     } catch (Exception e) {
    //         Output out = new Output();
    //         out.isSucess = false;
    //         out.errorMsg = e.getMessage()+';'+e.getLineNumber();
    //         return out;
    //     }
        
    // }
    @AuraEnabled
    public Static Output init(String orderId) {
        Map<String,String> unitMap = new Map<String,String>();
        Output out = new Output();
        out.isSucess = true;
        out.orderItemList = new List<OrderInfo>();
        Map<String,Decimal> actualInventoryMap = new Map<String,Decimal>();//实际库存
        Map<String,Decimal> openOrderMap = new Map<String,Decimal>();//open order 数量
        Map<String,Decimal> deliveryOrderMap = new Map<String,Decimal>();//交货单占用 数量
        Map<String,Decimal> inventoryMap = new Map<String,Decimal>();//交货单占用 数量
        Map<String,String> productNameMap = new Map<String,String>();//商品名Map
        Map<String,Boolean> isConMap = new Map<String,Boolean>();//是否寄售库存
        Set<Id> productSalesIdSet = new Set<Id>();
        Set<String> proIdSet = new Set<String>();
        Set<String> plantSet = new Set<String>();
        for (Order_Item__c oi : [SELECT Commodity__r.Product_Sales_Info__r.Product__r.Basic_Metering_Unit__c,Commodity__r.Product_Sales_Info__r.Product__r.Name,Commodity__r.Product_Sales_Info__r.Default_Sales_Unit__c,Commodity__r.Name,Id,Commodity__r.Product_Sales_Info__c,Commodity__c,Order__r.Deliver_Plant__c FROM Order_Item__c WHERE Order__c =:orderId]) {
            productSalesIdSet.add(oi.Commodity__r.Product_Sales_Info__c);
            proIdSet.add(oi.Commodity__c);
            plantSet.add(oi.Order__r.Deliver_Plant__c);
            unitMap.put(oi.Commodity__r.Product_Sales_Info__r.Product__r.Name, oi.Commodity__r.Product_Sales_Info__r.Product__r.Basic_Metering_Unit__c);
        }

        Map<String,Decimal> approvingQuantityMap = ProductSalesInfoSyncToSAP.getApprovingQuantity(proIdSet,plantSet);//审批中库存
        System.debug('approvingQuantityMap'+approvingQuantityMap);
        List<Id> idList = new List<Id>();
        idList.addAll(productSalesIdSet);
        ProductSalesInfoSyncToSAP.ReturnResult reslut;
        if (!System.Test.isRunningTest()) {
            reslut = ProductSalesInfoSyncToSAP.submitToSAP(idList);
            actualInventoryMap = reslut.returnMap;
            openOrderMap = reslut.openOrderMap;
            deliveryOrderMap = reslut.deliveryOrderMap;
            inventoryMap = reslut.inventoryMap;
            productNameMap = reslut.productNameMap;
            isConMap = reslut.isConMap;
            system.debug(inventoryMap);
        }else{
            reslut = new ProductSalesInfoSyncToSAP.ReturnResult();
            reslut.isSuccess = true;
            reslut.message = 'Success';
            reslut.returnMap = new Map<String,Decimal>();
            reslut.returnMap.put('key-key-key', 1);
            actualInventoryMap = reslut.returnMap;
        }
        if (!reslut.isSuccess) {
            out.isSucess = false;
            out.errorMsg = reslut.message;
            System.debug('out.errorMsg===>'+out.errorMsg);
            if (!reslut.message.contains('No Data Found')) {
                return out;
            }
        }
        Integer index = 1;
        System.debug('actualInventoryMap'+actualInventoryMap);
        for (String key : actualInventoryMap.keySet()) {
            OrderInfo oi = new OrderInfo();
            oi.index = String.valueOf(index);
            List<String> keyList = key.split('-');
            
            if (!System.Test.isRunningTest() && isConMap.get(key)) {
                continue;
            }
            System.debug('key'+key);
            oi.productCode = keyList[0];
            oi.productName = productNameMap.get(key);
           
            oi.salesUnit = unitMap.get(oi.productCode);
            oi.Quantity = inventoryMap.get(key);
            oi.actualQuantity = actualInventoryMap.get(key);
            // if (oi.actualQuantity == 0) {
            //     continue;
            // }
            oi.openOrder = openOrderMap.get(key);
            oi.approvingOrder = approvingQuantityMap.get(key) ?? 0;
            oi.deliveryOrder = deliveryOrderMap.get(key);
            oi.actualQuantity = oi.actualQuantity-oi.approvingOrder;
            if (oi.actualQuantity == 0) {
                continue;
            }
            out.orderItemList.add(oi);
            index++;
        }
        return out;
    }
    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        @AuraEnabled
        public List<OrderInfo> orderItemList {get;set;}
    }

    public class OrderInfo {

        @AuraEnabled
        public String productName {get;set;}

        @AuraEnabled
        public String index {get;set;}
        
        @AuraEnabled
        public String salesUnit {get;set;}

        @AuraEnabled
        public String defaultUnit {get;set;}

        @AuraEnabled
        public Decimal Quantity  {get;set;}

        @AuraEnabled
        public Decimal actualQuantity {get;set;}

        @AuraEnabled
        public Decimal salesQuantity  {get;set;}

        @AuraEnabled
        public String address {get;set;}

        @AuraEnabled
        public Decimal openOrder {get;set;}

        @AuraEnabled
        public Decimal approvingOrder {get;set;}

        @AuraEnabled
        public Decimal deliveryOrder {get;set;}

        @AuraEnabled
        public String productCode {get;set;}

        // @AuraEnabled
        // public String inventoryAging {get;set;}
    }
}