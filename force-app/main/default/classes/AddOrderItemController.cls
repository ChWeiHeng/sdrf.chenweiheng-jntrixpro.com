/**************************************************************************************************
 * Name: NotificationService
 * Object: 
 * Purpose: 添加产品控制类
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-14         Created             
***************************************************************************************************/
public without sharing class AddOrderItemController {
    @AuraEnabled
    public static Output initData(String orderRecordId) {
        try {
            Output out = new Output();
            Order__c order = [SELECT Order_Reason__c,Campaign__c,Sales_Org__c,is_YPF__c,Interest_Rate__c,Contract__c,Deliver_Plant__c,Id,Currency__c,Order_type__c,Price_Book__r.Status__c,Customer_Sales_Info__r.Payment_method__c,Auto_Issue_Consignment__c FROM Order__c WHERE Id=:orderRecordId];
            // if(order.Price_Book__r.Status__c != 'Approved') {
            //     Output out = new Output();
            //     out.isSucess = false;
            //     out.errorMsg = 'Price book is not Approved';
            //     return out;
            // }
            //credit note debit note是否来源于发票-----start
            if (
                (order.Order_type__c == 'ZMX3' || order.Order_type__c == 'ZMX4') &&
                order.Order_Reason__c == 'MX1'
            ) {
                out.isFROMInvoice = true;
            }else{
                out.isFROMInvoice = false;
            }
            //credit note debit note是否来源于发票-----end
            if (order.Order_type__c == 'ZARL') {
                out.isZFD = true;
            }else{
                out.isZFD = false;
            }
            if (order.Order_type__c == 'ZARL' && order.Campaign__c != null) {
                out.isNotShowSearch = true;
            }else{
                out.isNotShowSearch = false;
            }
            //unitPrice 需要含账期的订单类型 ----start
            if (
                order.Deliver_Plant__c=='5130' && 
                (
                    order.Order_type__c == 'ZARE' || 
                    order.Order_type__c == 'ZAR1'  
                )
            ) {
                out.needPaymentTerm = false;//暂时不需要这个功能
            }else{
                out.needPaymentTerm = false;
            }

            //unitPrice 需要含账期的订单类型 ----end

            //是否为credit note,debit note------start
            if (order.Order_type__c == 'ZMX3' || order.Order_type__c == 'ZMX4') {
                out.isCreditNote = true;
            }else{
                out.isCreditNote = false;
            }
            //是否为credit note，debit note------end


            //墨西哥特殊逻辑-----start
            if (order.Sales_Org__c == '3020' || order.Sales_Org__c == '3010') {
                out.isMX = true;
            }else{
                out.isMX = false;
            }
            //墨西哥特殊逻辑-----end

            
            if (order.Order_type__c == 'ZAR2') {
                out.isZAR2 = true;
            }else{
                out.isZAR2 = false;
            }
            if (order.Order_type__c == 'ZARF') {
                out.isZARF = true;
            }else{
                out.isZARF = false;
            }
            if (order.Deliver_Plant__c=='5130') {//是否显示佣金
                out.showCommission = true;
            }else{
                out.showCommission = false;
            }
            if (order.Deliver_Plant__c=='5130' || order.is_YPF__c || order.Deliver_Plant__c == '3011' || order.Deliver_Plant__c == '3020') {//是否显示cash price
                out.showCashPrice = true;
            }else{
                out.showCashPrice = false;
            }
            out.interestRate = order.Interest_Rate__c;
            out.inventoryList = new List<Option>();
            Map<String,String> inMap = Utility.getPicklistValueMap('Plant_Inventory_Relatetions__c','Inventory_Local__c');
            for (Plant_Inventory_Relatetions__c dp : [SELECT Id,Inventory_Local__c FROM Plant_Inventory_Relatetions__c WHERE Delivery_Plant__c=:order.Deliver_Plant__c]) {
                Option op = new Option();
                op.label = inMap.get(dp.Inventory_Local__c);
                op.value = dp.Inventory_Local__c;
                out.inventoryList.add(op);
            }

            //毒性字段选项值
            out.toxicityList = new List<Option>();
            Option opNone = new Option();
            opNone.label = 'None';
            opNone.value = '';
            out.toxicityList.add(opNone);
            Map<String,String> toxicityMap = Utility.getPicklistValueMap('Order_Item__c','Toxicity_Classification__c');
            for (String toxicity : toxicityMap.keySet()) {
                Option op = new Option();
                op.label = toxicityMap.get(toxicity);
                op.value = toxicity;
                out.toxicityList.add(op);
            }
            if(order.Contract__c != null) {
                out.action = true;
            }else{
                out.action = false;
            }
            out.isSucess = true;
            out.orderItemList = new List<OrderItem>();
            out.cuCode = order.Currency__c;
            out.isYPF = (order.Order_type__c == 'ZARA' || order.Order_type__c == 'ZARB' || order.Order_type__c == 'ZARE' || order.Order_type__c == 'ZARF') && (order.Customer_Sales_Info__r.Payment_method__c == 'YPF' || order.Deliver_Plant__c == '5130');
            //illion 20250829 Mass Edit Auto生成的ZAR1订单不允许新建订单明细
            out.isAutoZAR1 = (order.Auto_Issue_Consignment__c && order.Order_type__c == 'ZAR1');

            if (order.Order_type__c == 'ZARE' || order.Order_type__c == 'ZARA' || order.Order_type__c=='ZARF') {
                out.isConsignmentShipment = true;
            }else{
                out.isConsignmentShipment = false;
            }
            User u = [SELECT Id,Country__c FROM User WHERE Id=:System.UserInfo.getUserId()];
            if (u.Country__c == 'MX') {
                out.showProductusage = true;
            }else{
                out.showProductusage = false;
            }
            if (order.Deliver_Plant__c == '3020') {
                out.cornReq = true;
            }else{
                out.cornReq = false;
            }
            
            List<Order_Item__c> orderItemList = [
                                    SELECT 
                                        Invoice_Amount_Number__c,
                                        FECHA_DE_PAGO__c,
                                        FECHA_DE_VENCIMIENTO__c,
                                        Reference_Order_Item__c,
                                        Toxicity_Classification__c,
                                        Delivery_Note_Number__c,
                                        ZARE_Order_Number__c,
                                        Product_Combo_Name__c,
                                        Invoice_Item_Number__c,
                                        Invoice_Item__c,
                                        Cash_Price__c,
                                        Commission_Calculation_Method__c,
                                        Commission_Rate__c,
                                        Commission_Amount__c,
                                        Margin_Rate__c,
                                        Margin__c,
                                        Product_Cost__c,
                                        Id, 
                                        Amount_per_item__c,
                                        Commodity__c,
                                        Delivery_Date__c,
                                        Material_Number__c,
                                        Price__c,
                                        Quantity__c,
                                        Sales_Unit__c,
                                        Commodity__r.Product__r.Name,
                                        Order__r.Currency__c,
                                        SAP_Item_Num__c,
                                        Basic_Number__c,
                                        Material_Description__c,
                                        Price_Book_Item__c,
                                        Crop__c,
                                        Product_Usage__c,
                                        Depend_On_Item__c,Inventory_Location__c,Product_Type__c,
                                        Original_Product_Cost__c
                                    FROM 
                                        Order_Item__c 
                                    WHERE Order__c =: orderRecordId order by SAP_Item_Num__c];

            Set<String> commodityIdSet = new Set<String>();
            for (Order_Item__c orderItem : orderItemList) {
                commodityIdSet.add(orderItem.Commodity__r.Product__c);
                // out.cuCode = orderItem.Order__r.Currency__c;
            }

            Map<String,List<Product_Unit__c>> proUnitMap = getMap(commodityIdSet);
            system.debug(proUnitMap);
            Integer index = 1;
            for (Order_Item__c orderItem : orderItemList) {
                OrderItem oi = new OrderItem();
                //是否显示比例
                if (orderItem.Commission_Calculation_Method__c == 'Percent') {
                    oi.showPercentage = true;
                    oi.showCommissionAmount = false;
                }else if(orderItem.Commission_Calculation_Method__c == 'Amount'){
                    oi.showCommissionAmount = true;
                    oi.showPercentage = false;
                }else{
                    oi.showCommissionAmount = false;
                    oi.showPercentage = false;
                }
                oi.orderItemData = orderItem;
                oi.orderItemData.Price__c = orderItem.Price__c;
                oi.orderItemData.Amount_per_item__c = (orderItem.Price__c??0)*(orderItem.Quantity__c??0);
                
                oi.opList = new List<Option>();
                
                oi.indexNum = orderItem.SAP_Item_Num__c;
                oi.basicQuantity = orderItem.Basic_Number__c;
                if (proUnitMap.containsKey(orderItem.Commodity__r.Product__c)) {

                    for (Product_Unit__c proUnit : proUnitMap.get(orderItem.Commodity__r.Product__c)) {
                        Option op = new Option();
                        op.label = proUnit.Product_Sales_Unit__c;
                        op.value = proUnit.Id;
                        oi.opList.add(op);
                    }
                }
                out.orderItemList.add(oi);
                index++;
            }
            Output search = searchDataMe(orderRecordId,'');
            if (!search.isSucess) {
                out.isSucess = false;
                out.errorMsg = search.errorMsg;
                return out;
            }
            out.productNameList = search.productNameList;
            out.errorMsg = '';
            return out;
        } catch (Exception e) {
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';'+e.getLineNumber();
            return out;
        }
        
    
    }

    public static Map<String,List<Product_Unit__c>> getMap(Set<String> commodityIdSet) {
        System.debug('commodityIdSet====='+commodityIdSet);
        Map<String,List<Product_Unit__c>> proUnitMap = new Map<String,List<Product_Unit__c>>();
        for (Product_Unit__c variable : [SELECT TOLabel(Product_Sales_Unit__c),Id,Name,Product__c,Conversion_Coefficient__c FROM Product_Unit__c WHERE Product__c IN:commodityIdSet ]) {
            if (proUnitMap.containsKey(variable.Product__c)) {
                proUnitMap.get(variable.Product__c).add(variable);
            }else{
                proUnitMap.put(variable.Product__c, new List<Product_Unit__c>{variable});
            }
        }
        return proUnitMap;
    }

    @AuraEnabled
    public static Output searchDataMe(String orderRecordId,String searchData) {
        try {
            Output out = new Output();
            out.isSucess = true;
            Order__c order = [SELECT Order_Reason__c,RecordType_Name__c,Reference_Order__c, Invoice__c,Price_Book__c,Currency__c,Sales_Org__c,Deliver_Plant__c,Order_type__c,Id,Customer__c,Customer_Sales_Info__r.Sales_Org__c FROM Order__c WHERE Id=:orderRecordId];
            out.productNameList = new List<ProductName>();
            if (
                order.Order_type__c == 'ZARA' || 
                order.Order_type__c=='ZARE'
            ) {
                String accId = order.Customer__c;
                String org = order.Sales_Org__c;
                String currencyCode = order.Currency__c;
                String price = order.Price_Book__c;
                String query;
                if (order.Order_type__c == 'ZARA' || order.Order_type__c == 'ZARE') {
                    query = 
                                'SELECT '+
                                    'Id,(SELECT Id FROM Delivery_Note__r WHERE Remain_Quantity__c>0),Remain_Quantity__c,Issue_Quantity__c,'+
                                    'Commodity__c,Commodity__r.Product_Sales_Info__r.Cost_Local__c,Commodity__r.Product_Sales_Info__r.Cost_USD__c,'+
                                    'Price__c,Commodity__r.Product__r.Description_User__c,Commodity__r.Product_Combo__c,Order__r.Order_type__c,'+
                                    'Sales_Unit__c,Commodity__r.Product__r.Name,'+
                                    'Commodity__r.Name,TOLabel(Sales_Unit__r.Product_Sales_Unit__c),'+
                                    'Quantity__c,Used_Number__c,Basic_Number__c,Order__r.SAP_Order_Code__c,Order__r.CreatedDate,Price_Book_Item__c,Delivery_Quantity__c,isClosed__c '+
                                'FROM '+
                                    'Order_Item__c  '+
                                'WHERE '+
                                        'Order__r.Customer__c=:accId AND Order__r.Order_type__c=\'ZARB\' AND Order__r.Status__c=\'Approved\' AND Order__r.Price_Book__c=:price AND (isClosed__c=false OR (isClosed__c=true AND Delivery_Quantity__c!=null AND Delivery_Quantity__c!=0)) AND Order__r.Created_Year__c  >2024 ';
                }
                // if (order.Order_type__c == 'ZARF') {
                //     query = 
                //                 'SELECT '+
                //                     'Id,(SELECT Id FROM Delivery_Note__r WHERE Issue_Quantity__c>0),Remain_Quantity__c,Issue_Quantity__c,'+
                //                     'Commodity__c,Commodity__r.Product_Sales_Info__r.Cost_Local__c,Commodity__r.Product_Sales_Info__r.Cost_USD__c,'+
                //                     'Price__c,Commodity__r.Product__r.Description_User__c,Commodity__r.Product_Combo__c,Order__r.Order_type__c,'+
                //                     'Sales_Unit__c,Commodity__r.Product__r.Name,'+
                //                     'Commodity__r.Name,TOLabel(Sales_Unit__r.Product_Sales_Unit__c),'+
                //                     'Quantity__c,Used_Number__c,Basic_Number__c,Order__r.SAP_Order_Code__c,Order__r.CreatedDate,Price_Book_Item__c,Delivery_Quantity__c,isClosed__c '+
                //                 'FROM '+
                //                     'Order_Item__c  '+
                //                 'WHERE '+
                //                         'Order__r.Customer__c=:accId AND Order__r.Order_type__c=\'ZARB\' AND Order__r.Status__c=\'Approved\' AND Order__r.Price_Book__c=:price AND (isClosed__c=false OR (isClosed__c=true AND Delivery_Quantity__c!=null AND Delivery_Quantity__c!=0)) AND Order__r.Created_Year__c  >2024 ';
                // }
                if (String.isNotBlank(searchData)) {
                    query += ' AND (Commodity__r.Name=:searchData OR Commodity__r.Product__r.Name=:searchData';
                    String likeQuery = '%'+searchData+'%';
                    query += '  OR Commodity__r.Product__r.Description_User__c Like: likeQuery)';
                }

                Set<String> commodityId = new Set<String>();
                Set<String> oiIdSet = new Set<String>();
                for (Order_Item__c oi : Database.query(query)) {
                    commodityId.add(oi.Commodity__c);
                    oiIdSet.add(oi.Id);
                }
                Map<Id,Boolean> placeOrderMap = new Map<Id,Boolean>();
                for (Order_Item__c oi : [SELECT Id,Commodity__c FROM Order_Item__c WHERE Commodity__c IN:commodityId AND Order__r.Order_type__c!='ZARB' AND Order__r.Customer__c=:accId AND Order__r.Status__c='Approved']) {
                    placeOrderMap.put(oi.Commodity__c, true);
                }

                //没有关闭的寄售发货订单
                Map<String,Decimal> inventoryQuanMap = new Map<String,Decimal>();
                for (AggregateResult agg : [
                                            SELECT 
                                                Depend_On_Item__c depend,
                                                SUM(Quantity__c) usedNum
                                            FROM 
                                                Order_Item__c 
                                            WHERE 
                                                Depend_On_Item__c IN:oiIdSet
                                                AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARE' AND isClosed__c=false
                                                Group by Depend_On_Item__c
                ]) {
                    inventoryQuanMap.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
                }

                //关闭的寄售发货订单
                Map<String,Decimal> inventoryQuanMap1 = new Map<String,Decimal>();
                for (AggregateResult agg1 : [
                                            SELECT 
                                                Depend_On_Item__c depend,
                                                SUM(Delivery_Quantity__c) usedNum
                                            FROM 
                                                Order_Item__c 
                                            WHERE 
                                                Depend_On_Item__c IN:oiIdSet
                                                AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARE' AND isClosed__c=true
                                                Group by Depend_On_Item__c
                ]) {
                    inventoryQuanMap1.put((String)agg1.get('depend'), (Decimal)agg1.get('usedNum'));
                }

                //没有关闭的寄售退货
                Map<String,Decimal> addQuanMap = new Map<String,Decimal>();
                for (AggregateResult agg2 : [
                                            SELECT 
                                                Depend_On_Item__c depend,
                                                SUM(Quantity__c) usedNum
                                            FROM 
                                                Order_Item__c 
                                            WHERE 
                                                Depend_On_Item__c IN:oiIdSet
                                                AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARF' AND isClosed__c=false
                                                Group by Depend_On_Item__c
                ]) {
                    addQuanMap.put((String)agg2.get('depend'), (Decimal)agg2.get('usedNum'));
                }

                //关闭的寄售退货
                Map<String,Decimal> addQuanMap1 = new Map<String,Decimal>();
                                    for (AggregateResult agg3 : [
                                            SELECT 
                                                Depend_On_Item__c depend,
                                                SUM(Delivery_Quantity__c) usedNum
                                            FROM 
                                                Order_Item__c 
                                            WHERE 
                                                Depend_On_Item__c IN:oiIdSet
                                                AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARF' AND isClosed__c=true
                                                Group by Depend_On_Item__c
                ]) {
                    addQuanMap1.put((String)agg3.get('depend'), (Decimal)agg3.get('usedNum'));
                }
                //没有关闭的寄售退回
                Map<String,Decimal> retrunQuanMap = new Map<String,Decimal>();
                for (AggregateResult agg4 : [
                                            SELECT 
                                                Depend_On_Item__c depend,
                                                SUM(Quantity__c) usedNum
                                            FROM 
                                                Order_Item__c 
                                            WHERE 
                                                Depend_On_Item__c IN:oiIdSet
                                                AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARA' AND isClosed__c=false
                                                Group by Depend_On_Item__c
                ]) {
                    retrunQuanMap.put((String)agg4.get('depend'), (Decimal)agg4.get('usedNum'));
                }

                //关闭的寄售退回
                Map<String,Decimal> retrunQuanMap1 = new Map<String,Decimal>();
                for (AggregateResult agg5 : [
                                            SELECT 
                                                Depend_On_Item__c depend,
                                                SUM(Delivery_Quantity__c) usedNum
                                            FROM 
                                                Order_Item__c 
                                            WHERE 
                                                Depend_On_Item__c IN:oiIdSet
                                                AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARA' AND isClosed__c=true
                                                Group by Depend_On_Item__c
                ]) {
                    retrunQuanMap1.put((String)agg5.get('depend'), (Decimal)agg5.get('usedNum'));
                }

                Map<String,Decimal> approvingNumMap = new Map<String,Decimal>();
                for (AggregateResult agg6 : [
                                            SELECT 
                                                Depend_On_Item__c depend,
                                                SUM(Quantity__c) usedNum
                                            FROM 
                                                Order_Item__c 
                                            WHERE 
                                                Depend_On_Item__c IN:oiIdSet
                                                AND (Order__r.Status__c='Approving' OR (Order__r.Status__c='Approved' AND Order__r.Sync_Status__c!='Synchronized'))
                                                Group by Depend_On_Item__c
                ]) {
                    approvingNumMap.put((String)agg6.get('depend'), (Decimal)agg6.get('usedNum'));
                }
                    List<Order_Item__c> orderList = Database.query(query);
                System.debug('orderLis===>'+orderList.size());
                for (Order_Item__c oi : orderList) {
                    if (oi.Delivery_Note__r.size()==0 && !System.Test.isRunningTest() ) {//排除没有余量的 订单行
                        continue;
                    }
                    Decimal addNum = addQuanMap.get(oi.Id)==null? 0:addQuanMap.get(oi.Id);
                    Decimal retrunNum = retrunQuanMap.get(oi.Id)==null? 0:retrunQuanMap.get(oi.Id);
                    Decimal usedNum = inventoryQuanMap.get(oi.Id)==null? 0:inventoryQuanMap.get(oi.Id);
                    ProductName pn = new ProductName();
                    pn.materialCode = oi.Commodity__r.Product__r.Name;
                    pn.productDescription = oi.Commodity__r.Product__r.Description_User__c;
                    pn.oldCode = oi.Order__r.SAP_Order_Code__c;
                    pn.createDate = String.valueOf(Date.valueOf(oi.Order__r.CreatedDate));
                    if(oi.isClosed__c){
                        pn.quantity = String.valueOf(oi.Delivery_Quantity__c);
                    }else{
                        pn.quantity = String.valueOf(oi.Quantity__c);
                    }
                    
                    pn.addNum = String.valueOf(addNum);
                    pn.retrunNum = String.valueOf(retrunNum);
                    pn.usedNum = String.valueOf(usedNum);
                    pn.productName = oi.Commodity__r.Name;
                    pn.productNameId = oi.Commodity__c;
                    pn.priceBookItem = oi.Price_Book_Item__c;
                    pn.Price = oi.Price__c;
                    if (order.Currency__c == 'USD') {
                        pn.Cost = oi.Commodity__r.Product_Sales_Info__r.Cost_USD__c;
                    }else{
                        pn.Cost = oi.Commodity__r.Product_Sales_Info__r.Cost_Local__c;
                    }
                    if(placeOrderMap.get(oi.Commodity__c)!=null) {
                        pn.placeOrder = true;
                    }else{
                        pn.placeOrder = false;
                    }
                    Decimal usedNum1 = inventoryQuanMap1.get(oi.Id)==null? 0:inventoryQuanMap1.get(oi.Id);
                    Decimal addNum1 = addQuanMap1.get(oi.Id)==null? 0:addQuanMap1.get(oi.Id);
                    Decimal retrunNum1 = retrunQuanMap1.get(oi.Id)==null? 0:retrunQuanMap1.get(oi.Id);
                    if (oi.Used_Number__c==null) {//历史数据处理
                        pn.availableInventory = Decimal.valueOf(pn.quantity)+addNum+addNum1-retrunNum-usedNum-usedNum1-retrunNum1;
                    }else{
                        pn.availableInventory = Decimal.valueOf(pn.quantity)+addNum+addNum1-retrunNum-usedNum-oi.Used_Number__c-usedNum1-retrunNum1;
                    }

                    //库存字段赋值逻辑更新----start
                    if (order.Order_type__c == 'ZARE' || order.Order_type__c == 'ZARA') {
                        pn.availableInventory = oi.Remain_Quantity__c;
                    }else{
                        pn.availableInventory = oi.Issue_Quantity__c;
                    }
                    //库存字段赋值逻辑更新----end
                    
                    pn.salesUnit = oi.Sales_Unit__c;
                    pn.salesUnitName = oi.Sales_Unit__r.Product_Sales_Unit__c;
                    pn.orderItemId = oi.Id;
                    if (approvingNumMap.get(oi.ID)!=null) {
                        pn.approvingInventory = approvingNumMap.get(oi.ID);
                    }else{
                        pn.approvingInventory = 0;
                    }
                    pn.opList = new List<Option>();
                    Option op = new Option();
                    op.label = oi.Sales_Unit__r.Product_Sales_Unit__c;
                    op.value = oi.Sales_Unit__c;
                    pn.opList.add(op);
                    if (oi.Commodity__r.Product_Combo__c == false || 
                        (oi.Commodity__r.Product_Combo__c == true && oi.Order__r.Order_type__c == 'ZAR1')) {
                        out.productNameList.add(pn);
                    }
                    pn.salesUnitValue = oi.Sales_Unit__c;
                }
            
            }else if (order.Order_type__c == 'ZMX6') {
                String currencyCode = order.Currency__c;
                String price = order.Price_Book__c;
                    System.debug('order.Id ===> ' + order.Id);
                    System.debug('order.Currency__c ===> ' + order.Currency__c);
                    System.debug('order.Price_Book__c ===> ' + order.Price_Book__c);
                    System.debug('order.Order_type__c ===> ' + order.Order_type__c);

                String query = 
                                'SELECT '+
                                    'Id,Price__c,'+
                                    'Product_Name__r.Id,Product_Name__r.Product_Sales_Info__r.Cost_Local__c,Product_Name__r.Product_Sales_Info__r.Cost_USD__c,'+
                                    'Product_Name__r.Distr_Channel__c,'+
                                    'Product_Name__r.Product__r.Name,'+
                                    'Product_Name__r.Name,Product_Name__r.Product__r.Description_User__c, '+
                                    'Product_Name__r.Product__c,Product_Name__r.Product__r.Basic_Metering_Unit__c,TOLabel(Product_Name__r.Product_Sales_Info__r.Default_Sales_Unit__c) '+
                                'FROM '+
                                    'Price_Book_Item__c  '+
                                'WHERE '+
                                        'Product_Name__r.Product_Sales_Info__r.Status__c=\'On Shelves\' AND Price_Book__c=:price AND Is_Changing__c=false AND Product_Name__r.Is_Delete__c=false AND Status__c=\'Active\'';//添加商品名称删除逻辑 price book item 状态为active
                                        
                if (String.isNotBlank(searchData)) {
                    query += ' AND (Product_Name__r.Name=:searchData OR Product_Name__r.Product__r.Name=:searchData';
                    String likeQuery = '%'+searchData+'%';
                    query += '  OR Product_Name__r.Product__r.Description_User__c Like: likeQuery)';
                }
                System.debug('query=======>'+query);
                Set<String> commodityIdSet = new Set<String>();
                Set<String> commodityId = new Set<String>();
                Set<String> searchKeySet = new Set<String>();
                List<Price_Book_Item__c> proNameList = Database.query(query);
                System.debug('proNameList=======>'+proNameList);
                for (Price_Book_Item__c proName : proNameList) {
                    commodityIdSet.add(proName.Product_Name__r.Product__c);
                }
                Map<String,List<Product_Unit__c>> proUnitMap = getMap(commodityIdSet);
                for (Price_Book_Item__c proName : proNameList) {
                    ProductName pn = new ProductName();
                    pn.materialCode = proName.Product_Name__r.Product__r.Name;
                    pn.productDescription = proName.Product_Name__r.Product__r.Description_User__c;
                    pn.productName = proName.Product_Name__r.Name;
                    pn.productNameId = proName.Product_Name__r.Id;
                    pn.priceBookItem = proName.Id;
                    pn.Price = proName.Price__c;
                    if (order.Currency__c == 'USD') {
                        pn.Cost = proName.Product_Name__r.Product_Sales_Info__r.Cost_USD__c;
                    }else{
                        pn.Cost = proName.Product_Name__r.Product_Sales_Info__r.Cost_Local__c;
                    }
                    pn.salesUnitName = proName.Product_Name__r.Product_Sales_Info__r.Default_Sales_Unit__c;
                    pn.availableInventory = 9999999;
                    pn.approvingInventory = 0;
                    pn.placeOrder = false;
                    pn.opList = new List<Option>();
                    if (proUnitMap.get(proName.Product_Name__r.Product__c)!=null) {
                        for (Product_Unit__c proUnit : proUnitMap.get(proName.Product_Name__r.Product__c)) {
                            Option op = new Option();
                            op.label = proUnit.Product_Sales_Unit__c;
                            op.value = proUnit.Id;
                            pn.opList.add(op);
                            if (pn.salesUnitName == proUnit.Product_Sales_Unit__c) {
                                pn.salesUnitValue = proUnit.Id;
                            }
                        }
                    }
                    out.productNameList.add(pn);
                }
            }else if(order.Order_type__c == 'ZAR2') {
                String invoiceId = order.Invoice__c;
                String query = 
                                'SELECT '+
                                    'Reference_Order__c,Reference_Order_Item__c,Id,Order_Item__r.Sales_Unit_Text__c,'+
                                    'Order_Item__r.Commodity__c,Order_Item__r.Commodity__r.Product_Sales_Info__r.Cost_Local__c,Order_Item__r.Commodity__r.Product_Sales_Info__r.Cost_USD__c,'+
                                    'Order_Item__r.Price__c,Order_Item__r.Commodity__r.Product__r.Description_User__c,Order_Item__r.Commodity__r.Product_Combo__c,Order__r.Order_type__c,'+
                                    'Order_Item__r.Sales_Unit__c,Order_Item__r.Commodity__r.Product__r.Name,'+
                                    'Order_Item__r.Commodity__r.Name,TOLabel(Order_Item__r.Sales_Unit__r.Product_Sales_Unit__c),'+
                                    'Invoice_Quantity__c,Order_Item__r.Used_Number__c,Order_Item__r.Basic_Number__c,Order_Item__r.Order__r.SAP_Order_Code__c,Order_Item__r.Order__r.CreatedDate,Order_Item__r.Price_Book_Item__c,Order_Item__r.Delivery_Quantity__c,Order_Item__r.isClosed__c '+
                                'FROM '+
                                    'Billing__c  '+
                                'WHERE '+
                                        'Invoice__c=:invoiceId AND Billing_Status__c=\'C\'';
                if (String.isNotBlank(searchData)) {
                    query += ' AND (Order_Item__r.Commodity__r.Name=:searchData OR Order_Item__r.Commodity__r.Product__r.Name=:searchData';
                    String likeQuery = '%'+searchData+'%';
                    query += '  OR Order_Item__r.Commodity__r.Product__r.Description_User__c Like: likeQuery)';
                }
                System.debug('query=======>'+query);
                List<Billing__c> billingList = Database.query(query);
                System.debug('billingList====>'+billingList);
                Set<String> invoiceItemIdSet = new Set<String>();
                for (Billing__c oi : billingList) {
                    invoiceItemIdSet.add(oi.Id);
                }

                //没有关闭的退货
                Map<String,Decimal> invoiceUseMap = new Map<String,Decimal>();
                for (AggregateResult agg : [
                                            SELECT 
                                                Invoice_Item__c depend,
                                                SUM(Quantity__c) usedNum
                                            FROM 
                                                Order_Item__c 
                                            WHERE 
                                                Invoice_Item__c IN:invoiceItemIdSet
                                                AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZAR2' AND isClosed__c=false
                                                Group by Invoice_Item__c
                ]) {
                    invoiceUseMap.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
                }

                //关闭的退货
                Map<String,Decimal> invoiceUseMap1 = new Map<String,Decimal>();
                for (AggregateResult agg : [
                                            SELECT 
                                                Invoice_Item__c depend,
                                                SUM(Delivery_Quantity__c) usedNum
                                            FROM 
                                                Order_Item__c 
                                            WHERE 
                                                Invoice_Item__c IN:invoiceItemIdSet
                                                AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZAR2' AND isClosed__c=true
                                                Group by Invoice_Item__c
                ]) {
                    invoiceUseMap1.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
                }

                //审批中的退货
                Map<String,Decimal> invoiceApprovingMap = new Map<String,Decimal>();
                for (AggregateResult agg : [
                                            SELECT 
                                                Invoice_Item__c depend,
                                                SUM(Quantity__c) usedNum
                                            FROM 
                                                Order_Item__c 
                                            WHERE 
                                                Invoice_Item__c IN:invoiceItemIdSet
                                                AND Order__r.Status__c='Approving' AND Order__r.Order_type__c='ZAR2'
                                                Group by Invoice_Item__c
                ]) {
                    invoiceApprovingMap.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
                }
                for (Billing__c oi : billingList) {
                    ProductName pn = new ProductName();
                    pn.invoiceItemNumber = oi.Reference_Order__c+'-'+oi.Reference_Order_Item__c;
                    pn.materialCode = oi.Order_Item__r.Commodity__r.Product__r.Name;
                    pn.productDescription = oi.Order_Item__r.Commodity__r.Product__r.Description_User__c;
                    pn.productName = oi.Order_Item__r.Commodity__r.Name;
                    pn.productNameId = oi.Order_Item__r.Commodity__c;
                    pn.Price = oi.Order_Item__r.Price__c;
                    if (order.Currency__c == 'USD') {
                        pn.Cost = oi.Order_Item__r.Commodity__r.Product_Sales_Info__r.Cost_USD__c;
                    }else{
                        pn.Cost = oi.Order_Item__r.Commodity__r.Product_Sales_Info__r.Cost_Local__c;
                    }
                    pn.priceBookItem = oi.Order_Item__r.Price_Book_Item__c;
                    pn.invoiceItemId = oi.Id;
                    pn.salesUnitName = oi.Order_Item__r.Sales_Unit_Text__c;
                    pn.salesUnit = oi.Order_Item__r.Sales_Unit__c;
                    Decimal usedNum = invoiceUseMap.get(oi.Id)==null? 0:invoiceUseMap.get(oi.Id);
                    Decimal usedNum1 = invoiceUseMap1.get(oi.Id)==null? 0:invoiceUseMap1.get(oi.Id);
                    pn.approvingInventory = invoiceApprovingMap.get(oi.Id)==null? 0:invoiceApprovingMap.get(oi.Id);
                    pn.availableInventory = oi.Invoice_Quantity__c-usedNum-usedNum1-pn.approvingInventory;

                    pn.opList = new List<Option>();
                    Option op = new Option();
                    op.label = oi.Order_Item__r.Sales_Unit__r.Product_Sales_Unit__c;
                    op.value = oi.Order_Item__r.Sales_Unit__c;
                    pn.opList.add(op);
                    pn.salesUnitValue = oi.Order_Item__r.Sales_Unit__c;
                    out.productNameList.add(pn);
                }
                
            }else if(order.Order_type__c=='ZARF'){
                String accId = order.Customer__c;
                String org = order.Sales_Org__c;
                String currencyCode = order.Currency__c;
                String price = order.Price_Book__c;
                String query;
                
                    query = 
                            'SELECT '+
                                'Id,Order__c,Order_Item__c,Delivery_Quantity__c,External_Id__c,Order_Item__r.Delivery_Note__c,'+
                                'Order_Item__r.Commodity__c,Order_Item__r.Commodity__r.Product_Sales_Info__r.Cost_Local__c,Order_Item__r.Commodity__r.Product_Sales_Info__r.Cost_USD__c,'+
                                'Order_Item__r.Price__c,Order_Item__r.Commodity__r.Product__r.Description_User__c,Order_Item__r.Commodity__r.Product_Combo__c,Order_Item__r.Order__r.Order_type__c,'+
                                'Order_Item__r.Sales_Unit__c,Order_Item__r.Commodity__r.Product__r.Name,'+
                                'Order_Item__r.Commodity__r.Name,TOLabel(Order_Item__r.Sales_Unit__r.Product_Sales_Unit__c),'+
                                'Order_Item__r.Quantity__c,Order_Item__r.Used_Number__c,Order_Item__r.Basic_Number__c,Order_Item__r.Order__r.SAP_Order_Code__c,Order_Item__r.Order__r.CreatedDate,Order_Item__r.Price_Book_Item__c,Order_Item__r.Delivery_Quantity__c,Order_Item__r.isClosed__c '+
                            'FROM '+
                                'Delivery_Note__c  '+
                            'WHERE '+
                                    'Order__r.Customer__c=:accId AND Order__r.Order_type__c=\'ZARE\' AND Order__r.Status__c=\'Approved\' AND Order__r.Price_Book__c=:price AND Order__r.Created_Year__c  >2024 AND (Delivery_Post_Status__c=\'C\' OR Delivery_Post_Status__c=\'B\') AND Delivery_Quantity__c!=0 AND Remain_Quantity__c!=0 ';
                if (String.isNotBlank(searchData)) {
                    query += ' AND (Material_Code__c=:searchData';
                    String likeQuery = '%'+searchData+'%';
                    query += '  OR Order_Item__r.Commodity__r.Product__r.Description_User__c Like: likeQuery) order by Delivery_Quantity__c';
                }
            
                
                
                List<Delivery_Note__c> orderList = Database.query(query);
                Set<String> commodityId = new Set<String>();
                Set<String> deliveryNoteId = new Set<String>();
                for (Delivery_Note__c oi : orderList) {
                    commodityId.add(oi.Order_Item__r.Commodity__c);
                    deliveryNoteId.add(oi.Id);
                }
                Map<Id,Boolean> placeOrderMap = new Map<Id,Boolean>();
                for (Order_Item__c oi : [SELECT Id,Commodity__c FROM Order_Item__c WHERE Commodity__c IN:commodityId AND Order__r.Order_type__c!='ZARB' AND Order__r.Customer__c=:accId AND Order__r.Status__c='Approved']) {
                    placeOrderMap.put(oi.Commodity__c, true);
                }
                
                SubmitOrderController.CalculateOutput approvingCo = SubmitOrderController.getZARFApprovingQuantity(deliveryNoteId);
                Map<String,Decimal> approvingNumMap = approvingCo.approvingNumMap;

                SubmitOrderController.CalculateOutput availableCo = SubmitOrderController.getZAREAvailableQuanity(deliveryNoteId);
                Map<String,Decimal> usedMap = availableCo.usedMap;
                Map<String,Decimal> usedMap1 = availableCo.usedMap1;
                System.debug('orderLis===>'+orderList.size());
                for (Delivery_Note__c oi : orderList) {
                  
                    Decimal usedNum = (usedMap.get(oi.Id) ?? 0) + (usedMap1.get(oi.Id) ?? 0);
                    ProductName pn = new ProductName();
                    pn.materialCode = oi.Order_Item__r.Commodity__r.Product__r.Name;
                    pn.productDescription = oi.Order_Item__r.Commodity__r.Product__r.Description_User__c;
                    pn.oldCode = oi.Order_Item__r.Order__r.SAP_Order_Code__c;
                    pn.createDate = String.valueOf(Date.valueOf(oi.Order_Item__r.Order__r.CreatedDate));
                    pn.deliveryNoteNumber = oi.External_Id__c;
                    if(placeOrderMap.get(oi.Order_Item__r.Commodity__c)!=null) {
                        pn.placeOrder = true;
                    }else{
                        pn.placeOrder = false;
                    }

                    pn.productName = oi.Order_Item__r.Commodity__r.Name;
                    pn.productNameId = oi.Order_Item__r.Commodity__c;
                    pn.priceBookItem = oi.Order_Item__r.Price_Book_Item__c;
                    pn.Price = oi.Order_Item__r.Price__c;
                    if (order.Currency__c == 'USD') {
                        pn.Cost = oi.Order_Item__r.Commodity__r.Product_Sales_Info__r.Cost_USD__c;
                    }else{
                        pn.Cost = oi.Order_Item__r.Commodity__r.Product_Sales_Info__r.Cost_Local__c;
                    }
                    
                    
                    
                    
                    pn.salesUnit = oi.Order_Item__r.Sales_Unit__c;
                    pn.salesUnitName = oi.Order_Item__r.Sales_Unit__r.Product_Sales_Unit__c;
                    pn.orderItemId = oi.Order_Item__r.Id;
                    pn.approvingInventory = approvingNumMap.get(oi.ID) ?? 0;

                    pn.availableInventory = oi.Delivery_Quantity__c - usedNum;

                    pn.opList = new List<Option>();
                    pn.deliveryNoteId = oi.Order_Item__r.Delivery_Note__c;
                    pn.zareDeliveryNoteId = oi.Id;
                    Option op = new Option();
                    op.label = oi.Order_Item__r.Sales_Unit__r.Product_Sales_Unit__c;
                    op.value = oi.Order_Item__r.Sales_Unit__c;
                    pn.opList.add(op);
                    pn.salesUnitValue = oi.Order_Item__r.Sales_Unit__c;
                    if (oi.Order_Item__r.Commodity__r.Product_Combo__c == false || 
                        (oi.Order_Item__r.Commodity__r.Product_Combo__c == true && oi.Order_Item__r.Order__r.Order_type__c == 'ZAR1')) {
                        out.productNameList.add(pn);
                    }
                }
            }else if(order.Order_type__c == 'ZMX3' || order.Order_type__c == 'ZMX4'){
                //如果有参考订单
                if (order.Reference_Order__c != null && order.Order_Reason__c != 'MX1') {
                    String query;
                    String referenceOrder = order.Reference_Order__c;
                    query = 
                                'SELECT '+
                                    'Id,Remain_Quantity__c,Issue_Quantity__c,Amount_per_item__c,Order__r.Currency__c,'+
                                    'Commodity__c,Commodity__r.Product_Sales_Info__r.Cost_Local__c,Commodity__r.Product_Sales_Info__r.Cost_USD__c,'+
                                    'Price__c,Commodity__r.Product__r.Description_User__c,Commodity__r.Product_Combo__c,Order__r.Order_type__c,'+
                                    'Sales_Unit__c,Commodity__r.Product__r.Name,'+
                                    'Commodity__r.Name,TOLabel(Sales_Unit__r.Product_Sales_Unit__c),'+
                                    'Quantity__c,Used_Number__c,Basic_Number__c,Order__r.SAP_Order_Code__c,Order__r.CreatedDate,Price_Book_Item__c,Delivery_Quantity__c,isClosed__c '+
                                'FROM '+
                                    'Order_Item__c  '+
                                'WHERE '+
                                        'Order__c=:referenceOrder AND Order__r.Status__c=\'Approved\' AND (isClosed__c=false OR (isClosed__c=true AND Delivery_Quantity__c!=null AND Delivery_Quantity__c!=0)) AND  Product_Type__c=\'Normal Product\' AND Delivery_Quantity__c>0';
                    if (String.isNotBlank(searchData)) {
                        query += ' AND (Commodity__r.Name=:searchData OR Commodity__r.Product__r.Name=:searchData';
                        String likeQuery = '%'+searchData+'%';
                        query += '  OR Commodity__r.Product__r.Description_User__c Like: likeQuery)';
                    }
                    List<Order_Item__c> oiList = Database.query(query);
                    for (Order_Item__c oi : oiList) {
                        
                        ProductName pn = new ProductName();
                        pn.materialCode = oi.Commodity__r.Product__r.Name;
                        pn.productDescription = oi.Commodity__r.Product__r.Description_User__c;
                        pn.oldCode = oi.Order__r.SAP_Order_Code__c;
                        pn.createDate = String.valueOf(Date.valueOf(oi.Order__r.CreatedDate));
                        if(oi.isClosed__c){
                            pn.quantity = String.valueOf(oi.Delivery_Quantity__c);
                        }else{
                            pn.quantity = String.valueOf(oi.Quantity__c);
                        }
                        pn.amount = String.valueOf(oi.Amount_per_item__c);
                        pn.amountCurrency = oi.Order__r.Currency__c; 
                        
                        pn.productName = oi.Commodity__r.Name;
                        pn.productNameId = oi.Commodity__c;
                        pn.priceBookItem = oi.Price_Book_Item__c;
                        pn.Price = oi.Price__c;
                        pn.refeOrderItemId = oi.Id;
                        if (order.Currency__c == 'USD') {
                            pn.Cost = oi.Commodity__r.Product_Sales_Info__r.Cost_USD__c;
                        }else{
                            pn.Cost = oi.Commodity__r.Product_Sales_Info__r.Cost_Local__c;
                        }
                        pn.salesUnit = oi.Sales_Unit__c;
                        pn.salesUnitName = oi.Sales_Unit__r.Product_Sales_Unit__c;
                        pn.orderItemId = oi.Id;
                        pn.opList = new List<Option>();
                        Option op = new Option();
                        op.label = oi.Sales_Unit__r.Product_Sales_Unit__c;
                        op.value = oi.Sales_Unit__c;
                        pn.opList.add(op);
                        out.productNameList.add(pn);
                        pn.salesUnitValue = oi.Sales_Unit__c;
                    }

                }else if (order.Invoice__c != null && order.Order_Reason__c == 'MX1') {//参考发票
                    String invoiceId = order.Invoice__c;
                    String query = 
                                    'SELECT '+
                                        'Collection_Transaction_Currency__c,Collection_Base_Currency__c,Collection_Base_Amount__c,Collection_Transaction_Amount__c,FECHA_DE_VENCIMIENTO__c,SAP_Total_Amount__c,Reference_Order__c,Reference_Order_Item__c,Id,Order_Item__r.Sales_Unit_Text__c,Order_Item__c,'+
                                        'Order_Item__r.Commodity__c,Order_Item__r.Commodity__r.Product_Sales_Info__r.Cost_Local__c,Order_Item__r.Commodity__r.Product_Sales_Info__r.Cost_USD__c,'+
                                        'Order_Item__r.Price__c,Order_Item__r.Commodity__r.Product__r.Description_User__c,Order_Item__r.Commodity__r.Product_Combo__c,Order__r.Order_type__c,'+
                                        'Order_Item__r.Sales_Unit__c,Order_Item__r.Commodity__r.Product__r.Name,'+
                                        'Order_Item__r.Commodity__r.Name,TOLabel(Order_Item__r.Sales_Unit__r.Product_Sales_Unit__c),'+
                                        'Invoice_Quantity__c,Order_Item__r.Used_Number__c,Order_Item__r.Basic_Number__c,Order_Item__r.Order__r.SAP_Order_Code__c,Order_Item__r.Order__r.CreatedDate,Order_Item__r.Price_Book_Item__c,Order_Item__r.Delivery_Quantity__c,Order_Item__r.isClosed__c '+
                                    'FROM '+
                                        'Billing__c  '+
                                    'WHERE '+
                                            'Invoice__c=:invoiceId AND Billing_Status__c=\'C\'';
                    if (String.isNotBlank(searchData)) {
                        query += ' AND (Order_Item__r.Commodity__r.Name=:searchData OR Order_Item__r.Commodity__r.Product__r.Name=:searchData';
                        String likeQuery = '%'+searchData+'%';
                        query += '  OR Order_Item__r.Commodity__r.Product__r.Description_User__c Like: likeQuery)';
                    }
                    System.debug('query=======>'+query);
                    List<Billing__c> billingList = Database.query(query);
                    System.debug('billingList====>'+billingList);
                    Set<String> invoiceItemIdSet = new Set<String>();
                    for (Billing__c oi : billingList) {
                        invoiceItemIdSet.add(oi.Id);
                    }

                    
                    for (Billing__c oi : billingList) {
                        ProductName pn = new ProductName();
                        pn.invoiceItemNumber = oi.Reference_Order__c+'-'+oi.Reference_Order_Item__c;
                        pn.materialCode = oi.Order_Item__r.Commodity__r.Product__r.Name;
                        pn.productDescription = oi.Order_Item__r.Commodity__r.Product__r.Description_User__c;
                        pn.productName = oi.Order_Item__r.Commodity__r.Name;
                        pn.productNameId = oi.Order_Item__r.Commodity__c;
                        pn.Price = oi.Order_Item__r.Price__c;
                        if (order.Currency__c == 'USD') {
                            pn.Cost = oi.Order_Item__r.Commodity__r.Product_Sales_Info__r.Cost_USD__c;
                        }else{
                            pn.Cost = oi.Order_Item__r.Commodity__r.Product_Sales_Info__r.Cost_Local__c;
                        }
                        pn.FECHA_DE_PAGO = String.valueOf(oi.FECHA_DE_VENCIMIENTO__c);
                        pn.priceBookItem = oi.Order_Item__r.Price_Book_Item__c;
                        pn.invoiceItemId = oi.Id;
                        pn.refeOrderItemId = oi.Order_Item__c;
                        pn.salesUnitName = oi.Order_Item__r.Sales_Unit_Text__c;
                        pn.salesUnit = oi.Order_Item__r.Sales_Unit__c;
                        // Decimal usedNum = invoiceUseMap.get(oi.Id)==null? 0:invoiceUseMap.get(oi.Id);
                        // Decimal usedNum1 = invoiceUseMap1.get(oi.Id)==null? 0:invoiceUseMap1.get(oi.Id);
                        pn.approvingInventory = 9999;
                        pn.availableInventory = 9999;
                        pn.quantity = String.valueOf(oi.Invoice_Quantity__c);
                        // }else{
                            // pn.quantity = String.valueOf(oi.Quantity__c);
                        // }
                        if (order.Currency__c == oi.Collection_Base_Currency__c) {
                            pn.amount = String.valueOf(oi.Collection_Base_Amount__c);
                        }

                        if (order.Currency__c == oi.Collection_Transaction_Currency__c) {
                            pn.amount = String.valueOf(oi.Collection_Transaction_Amount__c);
                        }

                        pn.opList = new List<Option>();
                        Option op = new Option();
                        op.label = oi.Order_Item__r.Sales_Unit__r.Product_Sales_Unit__c;
                        op.value = oi.Order_Item__r.Sales_Unit__c;
                        pn.opList.add(op);
                        pn.salesUnitValue = oi.Order_Item__r.Sales_Unit__c;
                        out.productNameList.add(pn);
                    }
                }else {//没有参考订单号&参考发票
                    String org = order.Sales_Org__c;
                    String dp = order.Deliver_Plant__c;
                    String query = 
                                'SELECT '+
                                    'Id,'+
                                    'Distr_Channel__c,Product__r.Description_User__c,Product_Sales_Info__r.Cost_Local__c,Product_Sales_Info__r.Cost_USD__c,'+
                                    'Product__r.Name,'+
                                    'Name,Product_Combo__c,Product_Sales_Info__r.Product_Unit__c,Product_Sales_Info__r.Product_Unit__r.Product_Sales_Unit__c, '+
                                    'Product__c,Product__r.Basic_Metering_Unit__c,TOLabel(Product_Sales_Info__r.Default_Sales_Unit__c) '+
                                'FROM '+
                                    'Product_Name__c  '+
                                'WHERE (Customer__c =:accId OR Customer__c =null) AND '+
                                        'Product_Sales_Info__r.Status__c=\'On Shelves\' AND Is_Delete__c=false AND '+//添加商品名删除逻辑,price book item状态为Active
                                        'Product_Sales_Info__r.Sales_Organization__c =:org AND Product_Sales_Info__r.Factory__c=:dp AND Product_Sales_Info__r.Product__r.Virtual_Prodcut__c=true ';
                    if (String.isNotBlank(searchData)) {
                        query += ' AND (Name=:searchData OR Product__r.Name=:searchData';
                        String likeQuery = '%'+searchData+'%';
                        query += '  OR Product__r.Description_User__c Like: likeQuery)';
                    }
                    List<Product_Name__c> pnList = Database.query(query);
                    for (Product_Name__c oi : pnList) {
                        
                        ProductName pn = new ProductName();
                        pn.materialCode = oi.Product__r.Name;
                        pn.productDescription = oi.Product__r.Description_User__c;
                        // pn.oldCode = oi.Order__r.SAP_Order_Code__c;
                        // pn.createDate = String.valueOf(Date.valueOf(oi.Order__r.CreatedDate));
                        // if(oi.isClosed__c){
                        pn.quantity = '9999';
                        // }else{
                            // pn.quantity = String.valueOf(oi.Quantity__c);
                        // }
                        pn.amount = '9999';
                        pn.amountCurrency = order.Currency__c; 
                        
                        pn.productName = oi.Name;
                        pn.productNameId = oi.Id;
                        pn.availableInventory = 9999;
                        pn.approvingInventory = 0;
                        // pn.priceBookItem = oi.Price_Book_Item__c;
                        pn.Price = 9999;
                        // if (order.Currency__c == 'USD') {
                        //     pn.Cost = oi.Commodity__r.Product_Sales_Info__r.Cost_USD__c;
                        // }else{
                        pn.Cost = 0;
                        // }
                        pn.salesUnit = oi.Product_Sales_Info__r.Product_Unit__c;
                        pn.salesUnitName = oi.Product_Sales_Info__r.Product_Unit__r.Product_Sales_Unit__c;
                        // pn.orderItemId = oi.Id;
                        pn.opList = new List<Option>();
                        Option op = new Option();
                        op.label = oi.Product_Sales_Info__r.Product_Unit__r.Product_Sales_Unit__c;
                        op.value = oi.Product_Sales_Info__r.Product_Unit__c;
                        pn.opList.add(op);
                        out.productNameList.add(pn);
                        pn.salesUnitValue = oi.Product_Sales_Info__r.Product_Unit__c;
                    }
                }
                
            }else if (order.Order_type__c == 'ZMX2' && order.RecordType_Name__c=='Model_C') {
                String query;
                String referenceOrder = order.Reference_Order__c;
                query = 
                        'SELECT '+
                            'Sales_Unit_Text__c,SAP_Item_Num__c,Id,Remain_Quantity__c,Issue_Quantity__c,Amount_per_item__c,Order__r.Currency__c,'+
                            'Commodity__c,Commodity__r.Product_Sales_Info__r.Cost_Local__c,Commodity__r.Product_Sales_Info__r.Cost_USD__c,'+
                            'Price__c,Commodity__r.Product__r.Description_User__c,Commodity__r.Product_Combo__c,Order__r.Order_type__c,'+
                            'Sales_Unit__c,Commodity__r.Product__r.Name,'+
                            'Commodity__r.Name,TOLabel(Sales_Unit__r.Product_Sales_Unit__c),'+
                            'Quantity__c,Used_Number__c,Basic_Number__c,Order__r.SAP_Order_Code__c,Order__r.CreatedDate,Price_Book_Item__c,Delivery_Quantity__c,isClosed__c '+
                        'FROM '+
                            'Order_Item__c  '+
                        'WHERE '+
                                'Order__c=:referenceOrder AND Order__r.Status__c=\'Approved\' AND (isClosed__c=false OR (isClosed__c=true AND Delivery_Quantity__c!=null AND Delivery_Quantity__c!=0)) AND  Product_Type__c=\'Normal Product\' AND Delivery_Quantity__c>0';
                if (String.isNotBlank(searchData)) {
                    query += ' AND (Commodity__r.Name=:searchData OR Commodity__r.Product__r.Name=:searchData';
                    String likeQuery = '%'+searchData+'%';
                    query += '  OR Commodity__r.Product__r.Description_User__c Like: likeQuery)';
                }
                List<Order_Item__c> oiList = Database.query(query);
                System.debug('oiList====>'+oiList);
                Set<String> orderItemIdSet = new Set<String>();
                for (Order_Item__c oi : oiList) {
                    orderItemIdSet.add(oi.Id);
                }

                //没有关闭的退货
                Map<String,Decimal> orderItemUseMap = new Map<String,Decimal>();
                for (AggregateResult agg : [
                                            SELECT 
                                                Reference_Order_Item__c depend,
                                                SUM(Quantity__c) usedNum
                                            FROM 
                                                Order_Item__c 
                                            WHERE 
                                                Reference_Order_Item__c IN:orderItemIdSet
                                                AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZMX2' AND isClosed__c=false
                                                Group by Reference_Order_Item__c
                ]) {
                    orderItemUseMap.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
                }

                //关闭的退货
                Map<String,Decimal> orderItemUseMap1 = new Map<String,Decimal>();
                for (AggregateResult agg : [
                                            SELECT 
                                                Reference_Order_Item__c depend,
                                                SUM(Delivery_Quantity__c) usedNum
                                            FROM 
                                                Order_Item__c 
                                            WHERE 
                                                Reference_Order_Item__c IN:orderItemIdSet
                                                AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZMX2' AND isClosed__c=true
                                                Group by Reference_Order_Item__c
                ]) {
                    orderItemUseMap1.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
                }

                //审批中的退货
                Map<String,Decimal> orderItemApprovingMap = new Map<String,Decimal>();
                for (AggregateResult agg : [
                                            SELECT 
                                                Reference_Order_Item__c depend,
                                                SUM(Quantity__c) usedNum
                                            FROM 
                                                Order_Item__c 
                                            WHERE 
                                                Reference_Order_Item__c IN:orderItemIdSet
                                                AND Order__r.Status__c='Approving' AND Order__r.Order_type__c='ZMX2'
                                                Group by Reference_Order_Item__c
                ]) {
                    orderItemApprovingMap.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
                }
                for (Order_Item__c oi : oiList) {
                    ProductName pn = new ProductName();
                    pn.orderItemNumber = oi.Order__r.SAP_Order_Code__c+'-'+oi.SAP_Item_Num__c;
                    pn.materialCode = oi.Commodity__r.Product__r.Name;
                    pn.productDescription = oi.Commodity__r.Product__r.Description_User__c;
                    pn.productName = oi.Commodity__r.Name;
                    pn.productNameId = oi.Commodity__c;
                    pn.Price = oi.Price__c;
                    if (order.Currency__c == 'USD') {
                        pn.Cost = oi.Commodity__r.Product_Sales_Info__r.Cost_USD__c;
                    }else{
                        pn.Cost = oi.Commodity__r.Product_Sales_Info__r.Cost_Local__c;
                    }
                    pn.priceBookItem = oi.Price_Book_Item__c;
                    pn.refeOrderItemId = oi.Id;
                    pn.salesUnitName = oi.Sales_Unit_Text__c;
                    pn.salesUnit = oi.Sales_Unit__c;
                    Decimal usedNum = orderItemUseMap.get(oi.Id)==null? 0:orderItemUseMap.get(oi.Id);
                    Decimal usedNum1 = orderItemUseMap1.get(oi.Id)==null? 0:orderItemUseMap1.get(oi.Id);
                    pn.approvingInventory = orderItemApprovingMap.get(oi.Id)==null? 0:orderItemApprovingMap.get(oi.Id);
                    pn.availableInventory = oi.Delivery_Quantity__c-usedNum-usedNum1-pn.approvingInventory;

                    pn.opList = new List<Option>();
                    Option op = new Option();
                    op.label = oi.Sales_Unit__r.Product_Sales_Unit__c;
                    op.value = oi.Sales_Unit__c;
                    pn.opList.add(op);
                    pn.salesUnitValue = oi.Sales_Unit__c;
                    out.productNameList.add(pn);
                }
            }
            else{
                String accId = order.Customer__c;
                String org = order.Sales_Org__c;
                String dp = order.Deliver_Plant__c;
                String currencyCode = order.Currency__c;
                String price = order.Price_Book__c;
                String query = 
                                'SELECT '+
                                    'Id,Price__c,'+
                                    'Product_Name__r.Id,'+
                                    'Product_Name__r.Distr_Channel__c,Product_Name__r.Product__r.Description_User__c,Product_Name__r.Product_Sales_Info__r.Cost_Local__c,Product_Name__r.Product_Sales_Info__r.Cost_USD__c,'+
                                    'Product_Name__r.Product__r.Name,'+
                                    'Product_Name__r.Name,Product_Name__r.Product_Combo__c, '+
                                    'Product_Name__r.Product__c,Product_Name__r.Product__r.Basic_Metering_Unit__c,TOLabel(Product_Name__r.Product_Sales_Info__r.Default_Sales_Unit__c) '+
                                'FROM '+
                                    'Price_Book_Item__c  '+
                                'WHERE (Product_Name__r.Customer__c =:accId OR Product_Name__r.Customer__c =null) AND '+
                                        'Product_Name__r.Product_Sales_Info__r.Status__c=\'On Shelves\' AND Product_Name__r.Is_Delete__c=false AND Status__c=\'Active\' AND '+//添加商品名删除逻辑,price book item状态为Active
                                        'Product_Name__r.Product_Sales_Info__r.Sales_Organization__c =:org AND Product_Name__r.Product_Sales_Info__r.Factory__c=:dp AND Price_Book__c=:price AND Is_Changing__c=false ';
                if (String.isNotBlank(searchData)) {
                    query += ' AND (Product_Name__r.Name=:searchData OR Product_Name__r.Product__r.Name=:searchData';
                    String likeQuery = '%'+searchData+'%';
                    query += '  OR Product_Name__r.Product__r.Description_User__c Like: likeQuery)';
                }
                System.debug('query=======>'+query);
                Set<String> commodityIdSet = new Set<String>();
                Set<String> commodityId = new Set<String>();
                Set<String> searchKeySet = new Set<String>();
                // System.debug('data=====>'+Database.query(query));
                    for (Price_Book_Item__c proName : Database.query(query)) {
                    commodityIdSet.add(proName.Product_Name__r.Product__c);
                    commodityId.add(proName.Product_Name__r.Id);
                    searchKeySet.add(proName.Product_Name__r.Product__r.Name+'-'+dp+'-'+proName.Product_Name__r.Name);
                
                }
                Map<String,Decimal> inventoryQuanMap = new Map<String,Decimal>();
                for (AggregateResult agg : [SELECT SUM(Inventory_Quantity__c) num,Search_Key__c pname FROM Product_Inventory__c WHERE Search_Key__c IN:searchKeySet  AND Inventory_Quantity__c!=null Group by Search_Key__c]) {
                    inventoryQuanMap.put((String)agg.get('pname'), (Decimal)agg.get('num'));
                }

                Map<String,Decimal> approvingNumMap = new Map<String,Decimal>();
                for (AggregateResult agg : [
                    SELECT 
                        SUM(Basic_Number__c) bn,
                        Commodity__c com
                    FROM 
                        Order_Item__c 
                    WHERE 
                        Commodity__c IN:commodityId AND 
                        (
                            Order__r.Order_type__c='ZAR1' OR
                            Order__r.Order_type__c='ZMX1'
                        ) AND
                        (Order__r.Status__c='Approving')
                        Group by Commodity__c
                ]) {
                    approvingNumMap.put((String)agg.get('com'), (Decimal)agg.get('bn'));
                }
                Map<Id,Boolean> placeOrderMap = new Map<Id,Boolean>();
                for (Order_Item__c oi : [SELECT Id,Commodity__c FROM Order_Item__c WHERE Commodity__c IN:commodityId AND Order__r.Order_type__c!='ZARB' AND Order__r.Customer__c=:accId AND Order__r.Status__c='Approved']) {
                    placeOrderMap.put(oi.Commodity__c, true);
                }
                System.debug('inventoryQuanMap'+inventoryQuanMap);
                System.debug('approvingNumMap'+approvingNumMap);
                Map<String,List<Product_Unit__c>> proUnitMap = getMap(commodityIdSet);
                for (Price_Book_Item__c proName : Database.query(query)) {
                    if (order.Order_type__c == 'ZARB' && String.isNotBlank(System.Label.ZARBContinueProduct)) {
                        If(System.Label.ZARBContinueProduct.contains(proName.Product_Name__r.Product__r.Name)){
                            continue;
                        }
                    }
                    ProductName pn = new ProductName();
                    pn.materialCode = proName.Product_Name__r.Product__r.Name;
                    pn.productDescription = proName.Product_Name__r.Product__r.Description_User__c;
                    pn.productName = proName.Product_Name__r.Name;
                    pn.productNameId = proName.Product_Name__r.Id;
                    pn.Price = proName.Price__c;
                    if (order.Currency__c == 'USD') {
                        pn.Cost = proName.Product_Name__r.Product_Sales_Info__r.Cost_USD__c;
                    }else{
                        pn.Cost = proName.Product_Name__r.Product_Sales_Info__r.Cost_Local__c;
                    }
                    pn.priceBookItem = proName.Id;
                    pn.salesUnitName = proName.Product_Name__r.Product_Sales_Info__r.Default_Sales_Unit__c;
                    pn.availableInventory = inventoryQuanMap.get(proName.Product_Name__r.Product__r.Name+'-'+dp+'-'+proName.Product_Name__r.Name)==null? 0:inventoryQuanMap.get(proName.Product_Name__r.Product__r.Name+'-'+dp+'-'+proName.Product_Name__r.Name);

                    pn.approvingInventory = approvingNumMap.get(proName.Product_Name__r.Id)==null? 0:approvingNumMap.get(proName.Product_Name__r.Id);
                    if(placeOrderMap.get(proName.Id)!=null) {
                        pn.placeOrder = true;
                    }else{
                        pn.placeOrder = false;
                    }
                    pn.opList = new List<Option>();
                    if (proUnitMap.get(proName.Product_Name__r.Product__c)!=null) {
                        for (Product_Unit__c proUnit : proUnitMap.get(proName.Product_Name__r.Product__c)) {
                            Option op = new Option();
                            op.label = proUnit.Product_Sales_Unit__c;
                            op.value = proUnit.Id;
                            pn.opList.add(op);
                            if (pn.salesUnitName == proUnit.Product_Sales_Unit__c) {
                                pn.salesUnitValue = proUnit.Id;
                            }
                        }
                    }
                    if (proName.Product_Name__r.Product_Combo__c == false || 
                        (proName.Product_Name__r.Product_Combo__c == true && order.Order_type__c == 'ZAR1')) {
                        out.productNameList.add(pn);
                    }
                }
            }
            System.debug('out====>'+out);
            out.errorMsg = '';
            return out;
        } catch (Exception e) {
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';'+e.getLineNumber();
            System.debug('out====>'+out);
            return out;
        }
    }

    @AuraEnabled
    public static Output saveData(
        List<OrderItem> orderItemListData,
        List<String> deleteList
    ) {
        SavePoint sp = Database.setSavePoint();
        try {
            Output out = new Output();
            out.isSucess = true;
            if (deleteList.size()>0) {
                Database.delete(deleteList);
            }
            System.debug('orderItemListData:'+orderItemListData);
            if (orderItemListData.size()>0) {
                List<Order_Item__c> oiList = new List<Order_Item__c>();
                Set<String> productId = new Set<String>();
                Set<String> unitId = new Set<String>();
                Set<String> priceItemId = new Set<String>();
                Set<String> dependOnItemId = new Set<String>();
                String orderId;
                
                Decimal commissionAmount = 0;
                for (OrderItem oi : orderItemListData) {
                    productId.add(oi.orderItemData.Commodity__c);
                    unitId.add(oi.orderItemData.Sales_Unit__c);
                    priceItemId.add(oi.orderItemData.Price_Book_Item__c);
                    dependOnItemId.add(oi.orderItemData.Depend_On_Item__c);
                    orderId = oi.orderItemData.Order__c;
                    commissionAmount += oi.orderItemData.Commission_Amount__c==null? 0:oi.orderItemData.Commission_Amount__c;
                }
                Order__c order = [SELECT Interest_Rate__c,Price_Book__c,Currency__c,Sales_Org__c,Deliver_Plant__c,Order_type__c,Id,Customer__c,Customer_Sales_Info__r.Sales_Org__c,Commission_Percentage__c,Auto_Issue_Consignment__c FROM Order__c WHERE Id=:orderId];
                
                

                if (order.Deliver_Plant__c=='5130') {
                    if (commissionAmount!=0) {
                        Order__c orderUpdate = new Order__c();
                        orderUpdate.Id = orderId;
                        orderUpdate.Commission_Amount_New__c = commissionAmount;
                        orderUpdate.Commission_Calculation_Method__c = 'Amount';
                        update orderUpdate;
                    }else{//没有佣金时清空
                        Order__c orderUpdate = new Order__c();
                        orderUpdate.Id = orderId;
                        orderUpdate.Commission_Amount_New__c = null;
                        orderUpdate.Commission_Calculation_Method__c = null;
                        orderUpdate.Commission_Type__c = null;
                        orderUpdate.Commission_To__c = null;
                        orderUpdate.Commission_Percentage__c = null;
                        update orderUpdate;
                    }
                }
                
                Map<String,Decimal> priceItemMap = new Map<String,Decimal>();
                Map<String,Decimal> minZARBPriceMap = new Map<String,Decimal>();
                System.debug('dependOnItemId==>'+dependOnItemId);
                for (Order_Item__c oi : [SELECT Id,Price__c,Min_Sales_Price__c FROM Order_Item__c WHERE Id IN:dependOnItemId]) {
                    priceItemMap.put(oi.Id, oi.Price__c);
                    minZARBPriceMap.put(oi.Id,oi.Min_Sales_Price__c);
                }
                System.debug('priceItemMap===>'+priceItemMap);
                Map<String,Product_Name__c> marCodeMap = new Map<String,Product_Name__c>();
                for (Product_Name__c pn : [SELECT Product_Sales_Info__r.Cost_Local__c,Product_Sales_Info__r.Cost_USD__c,Id,Name,Product__r.Name,Product__r.Description_User__c,Product_Sales_Info__r.Product_Unit__r.Conversion_Coefficient__c FROM Product_Name__c WHERE Id IN:productId]) {
                    marCodeMap.put(pn.Id, pn);
                }

                Map<String,Product_Unit__c> unitMap = new Map<String,Product_Unit__c>();
                for (Product_Unit__c pn : [SELECT Product_Sales_Unit__c,Id,Conversion_Coefficient__c FROM Product_Unit__c WHERE Id IN:unitId]) {
                    unitMap.put(pn.Id, pn);
                }
                Map<String,Decimal> priceMap = new Map<String,Decimal>();
                Map<String,Decimal> minPriceMap = new Map<String,Decimal>();
                Map<String,Decimal> usdCostMap = new Map<String,Decimal>();
                Map<String,Decimal> usdLocalMap = new Map<String,Decimal>();
                for (Price_Book_Item__c pn : [SELECT Estimation_Cost_Local__c,Estimation_Cost_USD__c,Id,Price__c,Min_Sales_Price__c FROM Price_Book_Item__c WHERE Id IN:priceItemId]) {
                    priceMap.put(pn.Id, pn.Price__c);
                    minPriceMap.put(pn.Id, pn.Min_Sales_Price__c);
                    usdCostMap.put(pn.Id,pn.Estimation_Cost_USD__c);
                    usdLocalMap.put(pn.Id,pn.Estimation_Cost_Local__c);
                }
                for (OrderItem oi : orderItemListData) {
                    System.debug('priceMap====>'+priceMap);
                    System.debug('1====>'+priceMap.get(oi.orderItemData.Price_Book_Item__c));
                    System.debug('2====>'+marCodeMap.get(oi.orderItemData.Commodity__c).Product_Sales_Info__r.Product_Unit__r.Conversion_Coefficient__c);
                    System.debug('3====>'+unitMap.get(oi.orderItemData.Sales_Unit__c).Conversion_Coefficient__c);
                    //单价计算 添加佣金逻辑 start
                    // oi.orderItemData.Unit_Price_w_o_tax__c = oi.orderItemData.Price__c;
                    // if(order.Commission_Percentage__c!=null) {
                    //     oi.orderItemData.Price__c = (oi.orderItemData.Unit_Price_w_o_tax__c*(1+order.Commission_Percentage__c/100)).setScale(2);
                    // }else{
                    //     oi.orderItemData.Price__c = oi.orderItemData.Unit_Price_w_o_tax__c;
                    // }
                    //单价计算 添加佣金逻辑 end
                    if (
                        order.Order_type__c == 'ZARA' || 
                        order.Order_type__c=='ZARE' || 
                        order.Order_type__c=='ZARF'
                    ) {
                        System.debug('逻辑运行');
                        System.debug('oi.orderItemData.Depend_On_Item__c'+oi.orderItemData.Depend_On_Item__c);
                        oi.orderItemData.Guide_Price__c = priceItemMap.get(oi.orderItemData.Depend_On_Item__c);
                        oi.orderItemData.Min_Sales_Price__c = minZARBPriceMap.get(oi.orderItemData.Depend_On_Item__c);
                    }else{
                        //2024.07.02 Chervin增加条件，历史数据没有价格手册条目
                        if(String.isNotBlank(oi.orderItemData.Price_Book_Item__c)){
                            system.debug(priceMap.get(oi.orderItemData.Price_Book_Item__c));
                            system.debug(marCodeMap.get(oi.orderItemData.Commodity__c).Product_Sales_Info__r.Product_Unit__r.Conversion_Coefficient__c);
                            system.debug(unitMap.get(oi.orderItemData.Sales_Unit__c).Conversion_Coefficient__c);
                            if(marCodeMap.get(oi.orderItemData.Commodity__c).Product_Sales_Info__r.Product_Unit__r.Conversion_Coefficient__c <> null){
                                oi.orderItemData.Guide_Price__c = (priceMap.get(oi.orderItemData.Price_Book_Item__c)/marCodeMap.get(oi.orderItemData.Commodity__c).Product_Sales_Info__r.Product_Unit__r.Conversion_Coefficient__c)*unitMap.get(oi.orderItemData.Sales_Unit__c).Conversion_Coefficient__c;
                                if (order.Interest_Rate__c != null && (order.Sales_Org__c == '5130' || order.Sales_Org__c =='5070')) {//AR、ypf Guide Price增加账期成本
                                    oi.orderItemData.Guide_Price__c = oi.orderItemData.Guide_Price__c*order.Interest_Rate__c;
                                }
                            }
                            if(minPriceMap.get(oi.orderItemData.Price_Book_Item__c) != null && marCodeMap.get(oi.orderItemData.Commodity__c).Product_Sales_Info__r.Product_Unit__r.Conversion_Coefficient__c <> null){
                                oi.orderItemData.Min_Sales_Price__c = (minPriceMap.get(oi.orderItemData.Price_Book_Item__c)/marCodeMap.get(oi.orderItemData.Commodity__c).Product_Sales_Info__r.Product_Unit__r.Conversion_Coefficient__c)*unitMap.get(oi.orderItemData.Sales_Unit__c).Conversion_Coefficient__c;  
                                if (order.Interest_Rate__c != null && (order.Sales_Org__c == '5130' || order.Sales_Org__c =='5070')) {//AR、ypf min price增加账期成本
                                    oi.orderItemData.Min_Sales_Price__c = oi.orderItemData.Min_Sales_Price__c*order.Interest_Rate__c;
                                }
                            }                   
                        }
                    }
                    if(oi.orderItemData.Guide_Price__c!=null) {
                        oi.orderItemData.Guide_Price__c = oi.orderItemData.Guide_Price__c.setScale(2);
                    }
                    
                    
                    oi.orderItemData.Material_Number__c = marCodeMap.get(oi.orderItemData.Commodity__c).Product__r.Name;
                    oi.orderItemData.Material_Description__c = marCodeMap.get(oi.orderItemData.Commodity__c).Name;
                    oi.orderItemData.Sales_Unit_Text__c = unitMap.get(oi.orderItemData.Sales_Unit__c).Product_Sales_Unit__c;
                    oi.orderItemData.Amount_per_item__c = (oi.orderItemData.Price__c*oi.orderItemData.Quantity__c).setScale(2);

                    if(oi.orderItemData.Product_Type__c=='Free Product' && order.Order_type__c != 'ZARL'){
                        oi.orderItemData.Price__c=0.01;
                        
                    }
                    if(order.Order_type__c == 'ZARL'){
                        oi.orderItemData.Price__c=0;
                        oi.orderItemData.Amount_per_item__c = 0;
                    }
                    
                    if (order.Currency__c == 'USD') {
                        oi.orderItemData.Original_Product_Cost__c = marCodeMap.get(oi.orderItemData.Commodity__c).Product_Sales_Info__r.Cost_USD__c;
                    }else{
                        oi.orderItemData.Original_Product_Cost__c = marCodeMap.get(oi.orderItemData.Commodity__c).Product_Sales_Info__r.Cost_Local__c;
                    }
                    if(oi.orderItemData.Original_Product_Cost__c!=null && unitMap.get(oi.orderItemData.Sales_Unit__c) != null && unitMap.get(oi.orderItemData.Sales_Unit__c).Conversion_Coefficient__c != null) {
                        oi.orderItemData.Product_Cost__c = (oi.orderItemData.Original_Product_Cost__c * unitMap.get(oi.orderItemData.Sales_Unit__c).Conversion_Coefficient__c).setScale(2);
                    }else if(oi.orderItemData.Product_Cost__c!=null){
                        oi.orderItemData.Product_Cost__c=oi.orderItemData.Product_Cost__c.setScale(2);
                    }
                    if (order.Interest_Rate__c != null && (order.Sales_Org__c == '5130' || order.Sales_Org__c =='5070') && oi.orderItemData.Product_Cost__c <> null) {//AR、ypf Guide Price增加账期成本
                        oi.orderItemData.Product_Cost__c *= order.Interest_Rate__c;
                    }
                    //测算成本赋值 -start
                    if (order.Currency__c == 'USD') {
                        oi.orderItemData.Unit_Estimate_Cost__c = usdCostMap.get(oi.orderItemData.Price_Book_Item__c);
                    }else{
                        oi.orderItemData.Unit_Estimate_Cost__c = usdLocalMap.get(oi.orderItemData.Price_Book_Item__c);
                    }
                    if(oi.orderItemData.Unit_Estimate_Cost__c!=null && unitMap.get(oi.orderItemData.Sales_Unit__c) != null && unitMap.get(oi.orderItemData.Sales_Unit__c).Conversion_Coefficient__c != null) {
                        oi.orderItemData.Unit_Estimate_Cost__c = (oi.orderItemData.Unit_Estimate_Cost__c * unitMap.get(oi.orderItemData.Sales_Unit__c).Conversion_Coefficient__c).setScale(2);
                    }else if(oi.orderItemData.Unit_Estimate_Cost__c!=null){
                        oi.orderItemData.Unit_Estimate_Cost__c = oi.orderItemData.Unit_Estimate_Cost__c.setScale(2);
                    }
                    if (oi.orderItemData.Unit_Estimate_Cost__c <> null && order.Interest_Rate__c != null && (order.Sales_Org__c == '5130' || order.Sales_Org__c =='5070')) {//AR、ypf Guide Price增加账期成本
                        oi.orderItemData.Unit_Estimate_Cost__c *= order.Interest_Rate__c;
                    }
                    //测算成本赋值 -end
                    if(oi.orderItemData.Price__c !=null && oi.orderItemData.Product_Cost__c !=null && oi.orderItemData.Price__c != 0) {
                        if (order.Deliver_Plant__c == '3011' || order.Deliver_Plant__c == '3020') {
                            if (oi.orderItemData.Cash_Price__c != null) {
                                System.debug('进入逻辑');
                                oi.orderItemData.Margin__c = (oi.orderItemData.Cash_Price__c-oi.orderItemData.Product_Cost__c).setScale(2);
                                System.debug('oi.orderItemData.Margin__c====>'+oi.orderItemData.Margin__c);
                                oi.orderItemData.Margin_Rate__c = ((oi.orderItemData.Cash_Price__c-oi.orderItemData.Product_Cost__c)/oi.orderItemData.Cash_Price__c*100).setScale(2);
                            }else{
                                oi.orderItemData.Margin__c = (oi.orderItemData.Price__c-oi.orderItemData.Product_Cost__c).setScale(2);
                                oi.orderItemData.Margin_Rate__c = ((oi.orderItemData.Price__c-oi.orderItemData.Product_Cost__c)/oi.orderItemData.Price__c*100).setScale(2);
                            }
                        }else{
                            oi.orderItemData.Margin__c = (oi.orderItemData.Price__c-oi.orderItemData.Product_Cost__c).setScale(2);
                            oi.orderItemData.Margin_Rate__c = ((oi.orderItemData.Price__c-oi.orderItemData.Product_Cost__c)/oi.orderItemData.Price__c*100).setScale(2);
                        }
                        
                    }else{
                        oi.orderItemData.Margin__c = null;
                        oi.orderItemData.Margin_Rate__c = null;
                    }
                    if(oi.orderItemData.Product_Type__c=='Free Product'){
                        oi.orderItemData.Margin__c = null;
                        oi.orderItemData.Margin_Rate__c = null;
                    }
                    oi.orderItemData.IsCreate__c = true;
                    system.debug(oi.orderItemData.Sales_Unit__c);
                    oiList.add(oi.orderItemData);


                }

                if(order.Order_type__c == 'ZAR1' && order.Auto_Issue_Consignment__c && (order.Sales_Org__c == '5130' || order.Sales_Org__c == '5070')){
                    //添加标识不让roll-up字段更新导致重新进Order Trigger触发Order修改的验证报错
                    Utility.isBypassValidationRule = TRUE;
                }
                System.debug('oiList====>'+oiList);
                Database.upsert(oiList);
                //ZARF订单校验 ----start
                if (order.Order_type__c == 'ZARF') {
                    SubmitOrderController.Output outZAREQuantity = SubmitOrderController.zareQuantityEnough(order.Id);
                    if (!outZAREQuantity.isSucess) {
                        out.isSucess = false;
                        out.errorMsg = outZAREQuantity.errorMsg;
                        Database.rollback(sp);
                        return out;
                    }
                }
                //ZARF订单校验 ----end
            }
            
            out.errorMsg = '';
            return out;
        } catch (Exception e) {
            Database.rollback(sp);
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';Line:'+e.getLineNumber();
            return out;
        }
        
    
    }
    //2025-7-7 wyh 新增 用于校验产品包  ---start
    /*@AuraEnabled 
    public static Output checkiscombo (String productnameId){
        Output out = new Output();
        List<ProductName> productNameList = new List<ProductName>();
        Product_Name__c productname = [SELECT Id,Product_Combo__c FROM Product_Name__c WHERE Id =:productnameId ];
        if(productname.Product_Combo__c != null && productname.Product_Combo__c == True){
            List<Product_Name_Item__c> productNameItemList = [SELECT Id
                                                                    ,Product_Name__c
                                                                    ,Product_Name__r.Name
                                                                    ,Product_Name__r.Product__c
                                                                    ,List_Price__c
                                                              FROM Product_Name_Item__c 
                                                              WHERE Product_Combo_Name__c =: productnameId
                                                            ];
            for(Product_Name_Item__c item : productNameItemList){
                ProductName pn = new ProductName();
                pn.productNameId = item.Product_Name__c;
                pn.productName = item.Product_Name__r.Name;
                pn.Price = item.List_Price__c;
                productNameList.add(pn);
            }
        }
        out.productNameList = productNameList;
        return out;
    }*/
    //2025-7-7 wyh 新增 用于校验产品包  ---end
    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public List<Option> inventoryList {get;set;}

        @AuraEnabled
        public List<Option> toxicityList {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        @AuraEnabled
        public List<OrderItem> orderItemList {get;set;}

        @AuraEnabled
        public List<ProductName> productNameList {get;set;}

        @AuraEnabled
        public String cuCode {get;set;}

        @AuraEnabled
        public Boolean isConsignmentShipment {get;set;}

        @AuraEnabled
        public Boolean showProductusage {get;set;}
        
        @AuraEnabled
        public Boolean cornReq{get;set;}

        @AuraEnabled
        public Boolean action{get;set;}

        @AuraEnabled
        public Boolean showCommission {get;set;}//是否显示佣金

        @AuraEnabled
        public Boolean isZAR2 {get;set;}//是否阿根廷退货

        @AuraEnabled
        public Boolean isZARF {get;set;}

        @AuraEnabled
        public Boolean showCashPrice {get;set;}//是否显示现金价格
        
        @AuraEnabled
        public Boolean isYPF {get;set;}//是否是YPF
        
        @AuraEnabled
        public Decimal interestRate {get;set;}//折扣

        @AuraEnabled
        public Boolean isAutoZAR1 {get;set;}//是否是Mass Edit生成的Auto ZAR1

        @AuraEnabled
        public Boolean needPaymentTerm {get;set;}//单价是否需要含账期

        @AuraEnabled
        public Boolean isCreditNote {get;set;}//是否为credit note

        @AuraEnabled
        public Boolean isMX {get;set;}//是否是墨西哥

        @AuraEnabled
        public Boolean isZFD {get;set;}//是否是ZFD

        @AuraEnabled
        public Boolean isFROMInvoice {get;set;}//是否是来着发票

        @AuraEnabled
        public Boolean isNotShowSearch {get;set;}//是否不显示搜索
    }

    public class OrderItem {
        @AuraEnabled
        public String indexNum {get;set;}

        @AuraEnabled
        public Order_Item__c orderItemData {get;set;}

        @AuraEnabled
        public List<Option> opList {get;set;}

        @AuraEnabled
        public Decimal basicQuantity {get;set;}
        
        @AuraEnabled
        public Boolean showPercentage {get;set;}

        @AuraEnabled
        public Boolean showCommissionAmount {get;set;}
    }

    public class Option {
        @AuraEnabled
        public String label {get;set;}

        @AuraEnabled
        public String value {get;set;}
    }

    public class ProductName{
        @AuraEnabled
        public String deliveryNoteNumber {get;set;}

        @AuraEnabled
        public String oldCode {get;set;}
        @AuraEnabled
        public String createDate {get;set;}
        @AuraEnabled
        public String quantity {get;set;}
        @AuraEnabled
        public String addNum {get;set;}
        @AuraEnabled
        public String retrunNum {get;set;}
        @AuraEnabled
        public String usedNum {get;set;}

        @AuraEnabled
        public String materialCode {get;set;}

        @AuraEnabled
        public String orderItemNumber {get;set;}//订单行编号
        @AuraEnabled
        public String productDescription {get;set;}

      

        @AuraEnabled
        public String amount {get;set;}//原始订单金额

        @AuraEnabled
        public String dueDays {get;set;}//发票duedays

        @AuraEnabled
        public String amountCurrency {get;set;}//原始订单币种

        @AuraEnabled
        public String productName {get;set;}

        @AuraEnabled
        public Decimal Price {get;set;}

        @AuraEnabled
        public Decimal cost {get;set;}

        @AuraEnabled
        public Decimal availableInventory {get;set;}

        @AuraEnabled
        public String invoiceItemId {get;set;}//发票Id

        @AuraEnabled
        public String invoiceItemNumber {get;set;}//发票号

        @AuraEnabled
        public Decimal approvingInventory {get;set;}

        @AuraEnabled
        public String productNameId {get;set;}

        @AuraEnabled
        public String priceBookItem {get;set;}

        @AuraEnabled
        public String FECHA_DE_PAGO {get;set;}

        @AuraEnabled
        public String refeOrderItemId {get;set;}

        @AuraEnabled
        public String deliveryNoteId {get; set;}

        @AuraEnabled
        public String zareDeliveryNoteId {get;set;}

        @AuraEnabled
        public List<Option> opList {get;set;}

        @AuraEnabled
        public String salesUnit {get;set;}

        @AuraEnabled
        public String orderItemId {get;set;}

        @AuraEnabled
        public Boolean placeOrder {get;set;}

        @AuraEnabled
        public String salesUnitName  {get;set;}

        @AuraEnabled
        public String salesUnitValue {get;set;}
    }
}