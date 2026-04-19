/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @start time        : 08-01-2025
 * @last modified by  : Gerry
**/
public without sharing class OrderImportController {

    @AuraEnabled
    public static List<OrderAndItemData> InitData(String Data) {
        System.debug('Received OrderData: ' + Data);
        List<OrderAndItemData> inputData = (List<OrderAndItemData>)JSON.deserialize(Data, List<OrderAndItemData>.class);

        Set<String> customerSet = new Set<String>();
        Set<String> productCodeSet = new Set<String>();
        Set<String> productnameSet = new Set<String>();

        for (OrderAndItemData item : inputData) {
            if (String.isNotBlank(item.shipTo)) {
                item.shipTo = item.shipTo.trim();
                customerSet.add(item.shipTo);
            }
            if (String.isNotBlank(item.productCode)) {
                item.productCode = item.productCode.trim();
                productCodeSet.add(item.productCode);
            }
            if (String.isNotBlank(item.ypfproductName)) {
                item.ypfproductName = item.ypfproductName.trim();
                productnameSet.add(item.ypfproductName);
            }
            if (String.isNotBlank(item.customer)) {
                system.debug('item.customer===='+item.customer);
                item.customer = item.customer.trim();
                customerSet.add(item.customer);
            }
        }

        Map<String, String> customerMap = new Map<String, String>();
        for (Account acc : [
            SELECT Id, MDG_Customer_Code__c
            FROM Account
            WHERE MDG_Customer_Code__c IN :customerSet
        ]) {
            customerMap.put(acc.MDG_Customer_Code__c, acc.Id);
        }

        system.debug('customerMap===='+customerMap);
        system.debug('productnameSet===='+productnameSet);
        system.debug('productCodeSet===='+productCodeSet);
        
        Map<String, String> productnameMap = new Map<String, String>();
        Map<String, String> salesunitMap = new Map<String, String>();
        Map<String, String> productInfoMap = new Map<String, String>();
        Set<String> comboIdSet = new Set<String>();
        
        for (Product_Name__c productname : [
            SELECT Id,Name,Product__r.Name,Product_Sales_Info__r.Default_Sales_Unit__c,Product__c,Product_Combo__c,
            (SELECT Id,Quantity__c,List_Price__c,Product_Name__c FROM Product_Combo_Item__r)
            FROM Product_Name__c
            WHERE Name IN :productnameSet AND Product__r.Name IN :productCodeSet
        ]) {
            productnameMap.put(productname.Name+'_'+productname.Product__r.Name, productname.Id);
            salesunitMap.put(productname.Name+'_'+productname.Product__r.Name, productname.Product_Sales_Info__r.Default_Sales_Unit__c);
            productInfoMap.put(productname.Id,productname.Product__c);
            if(productname.Product_Combo__c){
                comboIdSet.add(productname.Id);
            }
        }
        
        //产品包的价格手册
        /*Map<String,Decimal> priceMap = new Map<String,Decimal>();
        for(Price_Book_Item__c pbi : [SELECT Id,Product_Name__c,Price_Book__r.Sales_Org__c,Price_Book__r.Delivery_Plant__c,Price__c FROM Price_Book_Item__c WHERE Product_Name__c IN:comboIdSet AND Price__c != NULL AND Price_Book__r.Sales_Org__c = '5070']){ 
            priceMap.put(pbi.Product_Name__c,pbi.Price__c);
        }*/
        
        Map<String,Product_Unit__c> productUnitMap = OrderItemTriggerHandler.getSalesUnitMap(new Set<String>(productInfoMap.values()));
        
        system.debug('productnameMap===='+productnameMap);
        // 3. 填充数据
        for (OrderAndItemData item : inputData) {
            item.salesOrg = '5070 RAAR';
            item.deliveryPlant = '5070';
            item.distributionChannel = '00 General Channel';
            item.customerId = customerMap.get(item.customer);
            system.debug('customerId===='+item.customerId);
            item.shipToId = customerMap.get(item.shipTo);
            item.productName = item.ypfproductName;
            item.productNameId = productnameMap.get(item.ypfproductName+'_'+ item.productCode);
            item.salesUnit = salesunitMap.get(item.ypfproductName+'_'+ item.productCode);
            item.productUnit = productUnitMap.get(item.salesUnit + '-' + productInfoMap.get(item.productNameId))?.Id;
            item.salesUnitCoefficient = productUnitMap.get(item.salesUnit + '-' + productInfoMap.get(item.productNameId))?.Conversion_Coefficient__c;
            //illion 20250828 取消校验
            /*item.unitPriceCheck = TRUE;
            if(comboIdSet.contains(item.productNameId)){
                item.unitPriceCheck = priceMap.get(item.productNameId) == Decimal.valueOf(item.unitPrice);
            }*/
			
            system.debug('item.ypfproductName_item.productCode===='+item.ypfproductName+'_'+ item.productCode);
            system.debug('productnameId===='+item.productNameId);
            system.debug(item.productUnit);
            system.debug(item.salesUnitCoefficient);
            if(String.isnotblank(item.pricingDate)){
                Integer excelSerial = Integer.valueOf(item.pricingDate);
                    Date baseDate = Date.newInstance(1900, 1, 1);
                    Date realDate = baseDate.addDays(excelSerial - 2);
                    item.pricingDate = String.valueOf(realDate); 
            }
            if(String.isnotblank(item.deliveryDate)){
                Integer excelSerial2 = Integer.valueOf(item.deliveryDate);
                    Date baseDate2 = Date.newInstance(1900, 1, 1);
                    Date realDate2 = baseDate2.addDays(excelSerial2 - 2);
                    item.deliveryDate = String.valueOf(realDate2); 
            }
        }
        System.debug('测试一下标签'+System.Label.OrderLabe25);

        return inputData;
    }


    // // GetInventory 方法，用于处理库存查询
    // @AuraEnabled
    // public static Map<String, String> GetInventory(String procodeList) {
    //     Map<String, String> result = new Map<String, String>();

    //     // 将传递的 procodeList 字符串通过 ";" 分隔成数组
    //     List<String> procodeArray = procodeList.split(';');
    //     System.debug('Received procodeArray: ' + procodeArray);

    //     // 遍历每个 procode 进行库存查询
    //     for (String procode : procodeArray) {
    //         if (String.isNotBlank(procode)) {
    //             result.put(procode, '100');  // 假设库存为 100
    //             System.debug('Setting inventory for Procode ' + procode + ': 100');
    //         }
    //     }

    //     // 返回库存查询结果
    //     return result;
    // }
    
    @AuraEnabled
    public static ResponseWrapper saveOrderData(String OrderData) {
        ResponseWrapper response = new ResponseWrapper();
        response.success = '1';
        List<ErrorDetail> errors = new List<ErrorDetail>();
        System.debug('Received OrderData: ' + OrderData);
        //回滚
        System.savepoint sp = Database.setSavepoint();
        try {
            // 使用正确的类型进行反序列化
            List<OrderAndItemData> saveData = (List<OrderAndItemData>)JSON.deserialize(OrderData, List<OrderAndItemData>.class);
            System.debug('Deserialized OrderData: ' + saveData);
            
            // 用于存储订单和订单项的集合
            List<Order__c> ordersToInsert = new List<Order__c>();
            List<Order_Item__c> orderItemsToInsert = new List<Order_Item__c>();
            
            Map<String,String> addnamemap = new Map<String,String>();
            // 用于跟踪订单错误、订单ID和分组数据
            Map<String, String> orderErrorMap = new Map<String, String>();
            Map<String,Product_Name__c> marCodeMap = new Map<String,Product_Name__c>();
            Map<String, Order__c> orderIdMap = new Map<String, Order__c>();
            Map<String, List<OrderAndItemData>> orderGroupMap = new Map<String, List<OrderAndItemData>>();
            Set<String> processedOrderKeys = new Set<String>();

            // 第一步：根据新条件对订单数据进行分组
            for (OrderAndItemData data : saveData) {
                // 生成订单分组键：Customer's PO、Order Type、Ship To、Customer、Pricing Date、Currency、Payment Term
                String orderKey = generateOrderKey(data);
                System.debug('orderKey:'+orderKey);
                
                // 将数据添加到对应的分组中
                if (!orderGroupMap.containsKey(orderKey)) {
                    orderGroupMap.put(orderKey, new List<OrderAndItemData>());
                }
                orderGroupMap.get(orderKey).add(data);
                System.debug('orderGroupMap:'+orderGroupMap);
                //addnamemap.put(data.shipaddress,null);
                marCodeMap.put(data.productNameId,null);
            }
            for (Product_Name__c pn : [SELECT Product_Sales_Info__r.Cost_Local__c,Product_Sales_Info__r.Cost_USD__c,Id,Name,Product__r.Name,Product__r.Description_User__c,Product_Sales_Info__r.Product_Unit__r.Conversion_Coefficient__c FROM Product_Name__c WHERE Id IN:marCodeMap.keySet()]) {
                marCodeMap.put(pn.Id, pn);
            }
            //List<Customer_Shipping_Address__c> shipaddlist = [SELECT Id,Direction__c From Customer_Shipping_Address__c WHERE Direction__c IN: addnamemap.keySet()];
            //List<Customer_Shipping_Address__c> newShipAddList = new List<Customer_Shipping_Address__c>();

            // 把已有地址查出来填入 addnamemap
            /*for(Customer_Shipping_Address__c item : shipaddlist){
                addnamemap.put(item.Direction__c, item.Id);
            }*/

            /*for(OrderAndItemData data : saveData){
                if(addnamemap.get(data.shipaddress) == null){
                    Customer_Shipping_Address__c newShipAdd = new Customer_Shipping_Address__c(
                        Direction__c = data.shipaddress,Customer__c = data.customerId
                    );
                    newShipAddList.add(newShipAdd);
                }
            }*/

            // 插入新建地址
            /*if(!newShipAddList.isEmpty()){
                insert newShipAddList;
                // 将新插入的记录更新进 addnamemap
                for(Customer_Shipping_Address__c item : newShipAddList){
                    addnamemap.put(item.Direction__c, item.Id);
                }
            }*/

            List<Price_Book__c> ypfpricebooklist  = [SELECT Id FROM Price_Book__c WHERE Sales_Org__c = '5070'];  
            List<Price_Book_Item__c> ypfpricebookitemlist = [SELECT Id,Product_Name__c,Price__c,Min_Sales_Price__c FROM Price_Book_Item__c WHERE Price_Book__r.Sales_Org__c = '5070'];
            Map<String,String> pricebookitemmap = new Map<String,String>();
            Map<String,Decimal> pricebookitempricemap = new Map<String,Decimal>();
            Map<String,Decimal> minPriceMap = new Map<String,Decimal>();
            for(Price_Book_Item__c item : ypfpricebookitemlist){
                pricebookitemmap.put(item.Product_Name__c,item.Id);
                pricebookitempricemap.put(item.Product_Name__c,item.Price__c);
                minPriceMap.put(item.Product_Name__c, item.Min_Sales_Price__c);
            }

            Map<String,Decimal> interestRateMap = new Map<String,Decimal>();//账期成本
            for (Intereste_Rate__c ir : [SELECT Id,Delivery_Plant__c,Payment_Rate__r.Name,Rate__c FROM Intereste_Rate__c WHERE Delivery_Plant__c ='5070']) {
                interestRateMap.put(ir.Delivery_Plant__c+'_'+ir.Payment_Rate__r.Name, ir.Rate__c);
            }


            // 第二步：处理每个订单分组，准备插入订单和订单项
            for (String orderKey : orderGroupMap.keySet()) {
                List<OrderAndItemData> groupData = orderGroupMap.get(orderKey);
                OrderAndItemData firstItem = groupData[0]; // 使用组内第一个数据作为参考
                System.debug('这是firstItem:'+firstItem);
                
                if(firstItem.productNameId == null){
                    orderErrorMap.put(orderKey,System.Label.NotMatchProductName);
                    continue;
                }
                // 创建订单记录
                Order__c order = new Order__c(
                    Cust_Reference__c = firstItem.customerPO,
                    Sales_Org__c = '5070',
                    Business_Model__c = 'C0',
                    Price_Book__c = ypfpricebooklist[0].Id,
                    Deliver_Plant__c = '5070',
                    Distr_Channel__c = '00',  
                    DN_Post_Date__c = Date.valueOf(firstItem.deliveryDate),
                    Customer__c = firstItem.customerId,  
                    Ship_To__c = firstItem.shipToId, 
                    Order_type__c = firstItem.orderType,
                    Pricing_Date__c = Date.valueOf(firstItem.pricingDate),
                    Currency__c = firstItem.currencys,
                    Terms_Of_Payment__c = firstItem.paymentTerm,
                    Stock_Aging_Limit__c = firstItem.stockLimit,
                    //Customer_Shipping_Address__c = addnamemap.get(firstItem.shipaddress),
                    RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId(),
                    Distrubutor_Exchange_Rate__c = firstItem.distrubutorExchangeRate                       
                );
                if(Test.isRunningTest()) {
                        order.Order_Reason__c = '001';
                    }
                ordersToInsert.add(order);
                processedOrderKeys.add(orderKey);
                system.debug('order.Cust_Reference__c===='+order.Cust_Reference__c);
            }
            List<Order__c> UpdateorderList = new List<Order__c>();
            // 第三步：插入订单记录
            if (!ordersToInsert.isEmpty()) {
                Database.SaveResult[] results = Database.insert(ordersToInsert, false);
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess() ) {
                        Order__c failedOrder = ordersToInsert[i];
                        for (Database.Error err : results[i].getErrors()) {
                            system.debug(err.getMessage());
                            // 找到对应的订单键
                            String orderKey = null;
                            for (String key : processedOrderKeys) {
                                OrderAndItemData data = orderGroupMap.get(key)[0];
                                if (data.customerPO == failedOrder.Cust_Reference__c) {
                                    orderKey = key;
                                    break;
                                }
                            }
                            if (orderKey != null) {
                                orderErrorMap.put(orderKey, err.getMessage());
                            }
                        }
                    } else {
                        // 记录成功插入的订单ID和对应的订单键
                        Order__c order = ordersToInsert[i];
                        String orderKey = null;
                        for (String key : processedOrderKeys) {
                            OrderAndItemData data = orderGroupMap.get(key)[0];
                            if (data.customerPO == order.Cust_Reference__c && data.orderType == order.Order_type__c && data.shipToId == order.Ship_To__c &&
                               Date.valueOf(data.pricingDate) == order.Pricing_Date__c && data.currencys == order.Currency__c && data.paymentTerm == order.Terms_Of_Payment__c) {
                                orderKey = key;
                                break;
                            }
                        }
                        if (orderKey != null) {
                            orderIdMap.put(orderKey, order);
                        }
                        if(order.Order_type__c == 'ZARE'){
                            order.Status__c = 'Approved';
                        }
                        order.Is_Import__c = true;
                        UpdateorderList.add(order);
                    }
                }
            }
			system.debug(orderIdMap);
            // 第四步：为每个分组创建订单项并关联订单
            for (String orderKey : orderGroupMap.keySet()) {
                List<OrderAndItemData> groupData = orderGroupMap.get(orderKey);
                
                // 检查订单是否插入成功
                if (orderErrorMap.containsKey(orderKey)) {
                    // 订单插入失败，记录错误
                    for (OrderAndItemData data : groupData) {
                        ErrorDetail ed = createErrorDetail(data, 'Order Insert Error: ' + orderErrorMap.get(orderKey));
                        errors.add(ed);
                        response.success = '2';
                    }
                    continue;
                }
                
                // 订单插入成功，获取订单ID
                Id orderId = orderIdMap.get(orderKey).Id;
                if (orderId == null ) {
                    // 找不到订单ID，记录错误
                    for (OrderAndItemData data : groupData) {
                        ErrorDetail ed = createErrorDetail(data, 'Order ID not found');
                        errors.add(ed);
                        response.success = '2';
                    }
                    continue;
                }
                Map<String,Integer> sapnummap = new Map<String,Integer> ();
                Decimal interestRate = 1;
                // 为组内每个数据创建订单项
                for (OrderAndItemData data : groupData) {
                    system.debug('data.productNameId===='+data.productNameId);
                    system.debug('data.customerPO + data.productCode===='+data.customerPO + '-' + data.productCode);
                    system.debug('marCodeMap.get(data.productNameId)'+marCodeMap.get(data.productNameId));
                    system.debug(data.productUnit);
                    system.debug(data.salesUnitCoefficient);
                    interestRate = interestRateMap.get('5070_'+orderIdMap.get(orderKey).Terms_Of_Payment__c)==null? 1:interestRateMap.get('5070_'+orderIdMap.get(orderKey).Terms_Of_Payment__c);
                    Order_Item__c item = new Order_Item__c(
                        YPF_External_ID__c = data.customerPO + '-' + data.productCode,
                        Commodity__c = data.productNameId,
                        // Commodity__c = data.productName,
                        // Product__c = data.
                        Quantity__c = Decimal.valueOf(data.orderItemQty),
                        Price__c = data.unitPrice <> null ? Decimal.valueOf(data.unitPrice) : pricebookitempricemap.get(data.productNameId),
                        Inventory_Location__c = data.invLocation,
                        Crop__c = data.crop,
                        IsCreate__c = true,
                        Delivery_Date__c = Date.valueOf(data.deliveryDate),
                        Sales_Unit_Text__c = data.salesUnit,
                        Sales_Unit__c = data.productUnit,
                        Price_Book_Item__c  = pricebookitemmap.get(data.productNameId),
                        Material_Number__c = marCodeMap.get(data.productNameId)?.Product__r.Name,
                        Material_Description__c = marCodeMap.get(data.productNameId)?.Name,
                        Guide_Price__c = pricebookitempricemap.get(data.productNameId)*interestRate
                        // Amount_per_item__c = Decimal.valueOf(data.itemAmount)
                    );
                    if (minPriceMap.get(data.productNameId)!=null) {
                        item.Min_Sales_Price__c = minPriceMap.get(data.productNameId)*interestRate;
                    }
                    
                    if(item.Price__c != NULL && item.Quantity__c != NULL){
                        item.Amount_per_item__c = item.Price__c * item.Quantity__c;
                    }
                    System.debug('data.currencys====>'+data.currencys);
                    if (data.currencys == 'USD') {
                        item.Original_Product_Cost__c = marCodeMap.get(item.Commodity__c)?.Product_Sales_Info__r.Cost_USD__c;
                    }else{
                        item.Original_Product_Cost__c = marCodeMap.get(item.Commodity__c)?.Product_Sales_Info__r.Cost_Local__c;
                    }
                    if(item.Original_Product_Cost__c!=null && data.salesUnitCoefficient != null ) {
                        item.Product_Cost__c = (item.Original_Product_Cost__c * data.salesUnitCoefficient*interestRate).setScale(2);
                    }else if(item.Product_Cost__c!=null){
                        item.Product_Cost__c=(item.Product_Cost__c*interestRate).setScale(2);
                    }

                    if(item.Price__c !=null && item.Product_Cost__c !=null) {
                        item.Margin__c = (item.Price__c-item.Product_Cost__c).setScale(2);
                        item.Margin_Rate__c = ((item.Price__c-item.Product_Cost__c)/item.Price__c*100).setScale(2);
                    }else{
                        item.Margin__c = null;
                        item.Margin_Rate__c = null;
                    }

                    item.Order__c = orderId;
                    if (sapnummap.containsKey(orderId)) {
                        item.SAP_Item_Num__c = String.valueOf(sapnummap.get(orderId) + 10);
                        sapnummap.put(orderId,Integer.valueOf(item.SAP_Item_Num__c));
                    }else {
                        item.SAP_Item_Num__c = '10';
                        sapnummap.put(orderId,Integer.valueOf(item.SAP_Item_Num__c));
                    }
                    if (pricebookitemmap.containsKey(data.productNameId)) {
                        item.Price_Book_Item__c = pricebookitemmap.get(data.productNameId);
                    }

                    orderItemsToInsert.add(item);
                }
            }
            Set<Id> updateorderitemidset = new Set<Id>();
            // 第五步：插入订单项
            if (!orderItemsToInsert.isEmpty()) {
                Database.SaveResult[] itemResults = Database.insert(orderItemsToInsert, false);
                for (Integer i = 0; i < itemResults.size(); i++) {
                    if (!itemResults[i].isSuccess()) {
                        Order_Item__c failedItem = orderItemsToInsert[i];
                        
                        // 找到对应的订单键
                        String orderKey = null;
                        for (String key : orderGroupMap.keySet()) {
                            for (OrderAndItemData data : orderGroupMap.get(key)) {
                                if (data.customerPO + '-' + data.productCode == failedItem.YPF_External_ID__c) {
                                    orderKey = key;
                                    break;
                                }
                            }
                            if (orderKey != null) break;
                        }
                        
                        if (orderKey != null) {
                            OrderAndItemData data = orderGroupMap.get(orderKey)[0]; // 使用组内第一个数据创建错误详情
                            for (Database.Error err : itemResults[i].getErrors()) {
                                system.debug(err.getMessage());
                                ErrorDetail ed = createErrorDetail(data, 'Order Item Insert Error: ' + err.getMessage());
                                errors.add(ed);
                                response.success = '2';
                            }
                        }
                    }else {
                        updateorderitemidset.add(orderItemsToInsert[i].Id);
                    }
                }
            }
            Utility.getUnitEstimateCost(updateorderitemidset);
            Update UpdateorderList;
            response.errors = errors;
        } catch (Exception e) {
            Database.rollback(sp);
            response.success = '3';
            response.errorMsg = showErrorMessage(e.getMessage());
            System.debug('Exception in saveOrderData: ' + e.getMessage() + ' ' + e.getStackTraceString() + ' at line ' + e.getLineNumber());
        }

        return response;
    }

    public static String showErrorMessage(String errorMessage){
        if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            List<String> parts = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
            if (parts.size() > 1) {
                return parts[1].replaceAll(': \\[\\s*\\]$', '');
            }
        }else if(errorMessage.contains('NO_APPLICABLE_PROCESS')){
            List<String> parts = errorMessage.split('NO_APPLICABLE_PROCESS, ');
            if (parts.size() > 1) {
                return parts[1].replaceAll(': \\[\\s*\\]$', '');
            }
        }
        return errorMessage;
    }

    // 生成订单分组键的辅助方法
    private static String generateOrderKey(OrderAndItemData data) {
        // 组合多个字段作为分组键，确保相同条件的订单被分到同一组
        return data.customerPO + '|' + 
            data.orderType + '|' + 
            data.shipTo + '|' + 
            data.customer + '|' + 
            data.pricingDate + '|' + 
            data.currencys + '|' + 
            data.paymentTerm;
    }


    public class ResponseWrapper {
        @AuraEnabled
        public String success{get;set;}
        @AuraEnabled
        public List<ErrorDetail> errors{get;set;}
        @AuraEnabled
        public String errorMsg{get;set;} 
    }

    public class ErrorDetail {
        @AuraEnabled public String customerPO { get; set; }
        @AuraEnabled public String salesOrg { get; set; }
        @AuraEnabled public String deliveryPlant { get; set; }
        @AuraEnabled public String distributionChannel { get; set; }
        @AuraEnabled public String businessModel { get; set; }
        @AuraEnabled public String orderType { get; set; }
        @AuraEnabled public String customer { get; set; }
        @AuraEnabled public String shipTo { get; set; }
        @AuraEnabled public String pricingDate { get; set; }
        @AuraEnabled public String currencys { get; set; }
        @AuraEnabled public String paymentTerm { get; set; }
        @AuraEnabled public Decimal distrubutorExchangeRate{get;set;}//ZARE新增税率
        //@AuraEnabled public String shipaddress { get; set; }
        @AuraEnabled public String productCode { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public String orderItemQty { get; set; }
        @AuraEnabled public String unitPrice { get; set; }
        @AuraEnabled public String deliveryDate { get; set; }
        @AuraEnabled public String invLocation { get; set; }
        @AuraEnabled public String crop { get; set; }
        @AuraEnabled public String message { get; set; }
    }
    
    // // 每一个订单（主表）及其子项列表
    // public class OrderWrapper {
    //     @AuraEnabled public String customerPO { get; set; }
    //     @AuraEnabled public String salesOrg { get; set; }
    //     @AuraEnabled public String deliveryPlant { get; set; }
    //     @AuraEnabled public String distributionChannel { get; set; }
    //     @AuraEnabled public String businessModel { get; set; }
    //     @AuraEnabled public String orderType { get; set; }
    //     @AuraEnabled public String customer { get; set; }
    //     @AuraEnabled public String shipTo { get; set; }
    //     @AuraEnabled public String pricingDate { get; set; }
    //     @AuraEnabled public String currencys { get; set; }
    //     @AuraEnabled public String paymentTerm { get; set; }
    //     @AuraEnabled public String shipaddress { get; set; }

    //     // 子项列表
    //     @AuraEnabled public List<OrderItemWrapper> itemList { get; set; }
    // }

    // // 每一个订单项（子表）
    // public class OrderItemWrapper {
    //     @AuraEnabled public String productCode { get; set; }
    //     @AuraEnabled public String productName { get; set; }
    //     @AuraEnabled public String productNameId { get; set; }
    //     @AuraEnabled public String orderItemQty { get; set; }
    //     @AuraEnabled public String unitPrice { get; set; }
    //     @AuraEnabled public String deliveryDate { get; set; }
    //     @AuraEnabled public String invLocation { get; set; }
    //     @AuraEnabled public String crop { get; set; }
    //     @AuraEnabled public String salesUnit { get; set; }
    // }
    public class OrderAndItemData{
        @AuraEnabled
        public String customerPO{get;set;}
        @AuraEnabled
        public String salesOrg{get;set;}
        @AuraEnabled
        public String deliveryPlant{get;set;}
        @AuraEnabled
        public String  distributionChannel{get;set;}
        @AuraEnabled
        public String orderType{get;set;}
        @AuraEnabled
        public String  customer{get;set;}
        @AuraEnabled
        public String  customerId{get;set;}
        @AuraEnabled
        public String shipTo{get;set;}
        @AuraEnabled
        public String shipToId{get;set;}
        @AuraEnabled
        public String pricingDate{get;set;}
        @AuraEnabled
        public String currencys{get;set;}
        @AuraEnabled
        public String paymentTerm{get;set;}
        @AuraEnabled
        public Decimal distrubutorExchangeRate{get;set;}//ZARE新增税率
        //@AuraEnabled
        //public String shipaddress{get;set;}        
        @AuraEnabled
        public String productCode{get;set;}
        @AuraEnabled
        public String ypfproductName{get;set;}
        @AuraEnabled
        public String productName{get;set;}
        @AuraEnabled
        public String productNameId{get;set;}
        @AuraEnabled
        public String orderItemQty{get;set;}
        @AuraEnabled
        public String unitPrice{get;set;}
        @AuraEnabled
        public String deliveryDate{get;set;}
        @AuraEnabled
        public String invLocation{get;set;}
        @AuraEnabled
        public String crop{get;set;}
        @AuraEnabled
        public String salesUnit{get;set;}
        @AuraEnabled
        public String productUnit{get;set;}
        @AuraEnabled
        public String stockLimit{get;set;}
        @AuraEnabled
        public Decimal salesUnitCoefficient{get;set;}
        //@AuraEnabled
        //public Boolean unitPriceCheck{get;set;}
        
    }
    private static ErrorDetail createErrorDetail(OrderAndItemData data, String message) {
        ErrorDetail ed = new ErrorDetail();
        ed.customerPO = data.customerPO;
        ed.salesOrg = data.salesOrg;
        ed.deliveryPlant = data.deliveryPlant;
        ed.distributionChannel = data.distributionChannel;
        ed.orderType = data.orderType;
        ed.customer = data.customer;
        ed.shipTo = data.shipTo;
        ed.pricingDate = data.pricingDate;
        ed.currencys = data.currencys;
        ed.paymentTerm = data.paymentTerm;
        ed.distrubutorExchangeRate = data.distrubutorExchangeRate;
        //ed.shipaddress = data.shipaddress;
        ed.productCode = data.productCode;
        ed.productName = data.productName;
        ed.orderItemQty = data.orderItemQty;
        ed.unitPrice = data.unitPrice;
        ed.deliveryDate = data.deliveryDate;
        ed.invLocation = data.invLocation;
        ed.crop = data.crop;
        ed.message = message;
        return ed;
    }
}