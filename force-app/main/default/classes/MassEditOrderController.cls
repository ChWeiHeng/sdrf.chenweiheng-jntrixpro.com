/**************************************************************************************************
* Name: MassEditOrderController
* Object: Order__c
* Purpose: 批量编辑订单
* ************************************************************************************************
* History
* --------
* VERSION     AUTHOR              DATE            DETAIL             Description
* 1.0         zach	           2025-07-02         Created
***************************************************************************************************/
public without sharing class MassEditOrderController {
	/**
    * 获取 ZARA 订单数据
    * @Author   Zach
    * @DateTime 2025-07-02
    * @param
    * @return  页面数据的Map
    */
	@AuraEnabled
    public static Map<String, Object> initData(){
        Map<String, Object> returnMap = new Map<String, Object>();
        //校验权限
        List<PermissionSetAssignment> psaList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'ZAR1_Auto_Create_Permission'];
        if(psaList.isEmpty()){
            returnMap.put(System.Label.OrderLabe21, Label.no_access);
            return returnMap;
        }
        
		List<OrderData> dataList = new List<OrderData>();
        //peyment term 和 payment method 的依赖选项列表值
        Map<String,List<Utility.returnValue>> termMap = Utility.getDependentOptionsImpl('Order__c','Deliver_Plant__c','Terms_Of_Payment__c');
        //Map<String,List<Utility.returnValue>> methodMap = Utility.getDependentOptionsImpl('Order__c','Sales_Org__c','Payment_Method__c');
        
        String orderSoql = Utility.getAllFieldSoql('Order__c') + ' WHERE Order_type__c = \'ZARA\' AND Status__c != \'Approved\' AND Auto_Issue_Consignment__c = TRUE ' + 
                            ' AND (Sales_Org__c = \'5070\' OR Sales_Org__c = \'5130\') AND Deliver_Plant__c != NULL AND RecordType.DeveloperName = \'Model_C\' AND OwnerId =\'' + UserInfo.getUserId() + '\'';
        for(Order__c order : (List<Order__c>)Database.query(orderSoql)){
            dataList.add(new OrderData(order,termMap,dataList.size() + 1));
        }        
   
        returnMap.put('dataList', dataList);
        //returnMap.put('translateMap', Utility.getFieldLabelTranslateMap('Order__c'));
       
        return returnMap;
    }

    /**
    * 保存ZARA 并生成ZAR1
    * @Author   Zach
    * @DateTime 2025-07-04
    * @param
    * @return  页面数据的Map
    */
	@AuraEnabled
    public static Map<String, Object> saveData(String selectListStr){
        Savepoint sp = Database.setSavepoint();
        try{
            List<OrderData> dataList = (List<OrderData>)JSON.deserialize(selectListStr, List<OrderData>.class);
            List<Order__c> zaraDataList = new List<Order__c>();
            Map<String,Order__c> zar1DataMap = new Map<String,Order__c>();
            for(OrderData data : dataList){
                Order__c order = data.order;
                if(data.isAutoCreate){
                    system.debug(order);
                    Order__c zar1Order = order.clone(FALSE,TRUE,FALSE,FALSE);
                    zar1Order.Order_type__c = 'ZAR1';
                    zar1Order.Source_Order__c = order.Id;
                    zar1Order.Status__c = 'Draft';
                    order.Status__c = 'Approved';
                    zar1DataMap.put(order.Id,zar1Order);
                }
                zaraDataList.add(order);
            }
            Utility.isBypassValidationRule = TRUE;
            if(!zar1DataMap.isEmpty()){
                insert zar1DataMap.values();
                cloneItem(zar1DataMap);
            }

            for(Order__c order : zaraDataList){
                if(zar1DataMap.containsKey(order.Id)){
                    order.ZAR1_Order__c = zar1DataMap.get(order.Id).Id;
                }
            }
            System.debug('zaraDataList===='+zaraDataList.size());
			update zaraDataList;
            //ZAR1同步SAP
            /*List<BatchOrderSyncToSap.BatchData> batchDataList = new List<BatchOrderSyncToSap.BatchData>();
            Map<Id,Order__c> orderMap = new Map<Id,Order__c>(zar1DataMap.values());
            for(Order__c order : [SELECT Id,(SELECT Id FROM Order_Item__r) FROM Order__c WHERE Id IN:orderMap.keySet()]){
                String itemIdStr = '';
                for(Order_Item__c item : order.Order_Item__r) {
                    itemIdStr += item.Id + ';';
                }
                itemIdStr.removeEnd(';');
                batchDataList.add(new BatchOrderSyncToSap.BatchData(order.Id, 'I',false,false,'',false,itemIdStr));
            }
            if(!batchDataList.isEmpty()){
                Database.executeBatch(new BatchOrderSyncToSap(JSON.serialize(batchDataList)),1);
            }*/
        }catch(Exception e){
            Database.rollback(sp);
            Map<String, Object> returnMap = new Map<String, Object>();
            returnMap.put('error',Utility.getCustomMessage(e.getMessage(),FALSE));
            return returnMap;
        }
        return initData();
    }
    
    /**
    * 克隆order item
    * @Author   Zach
    * @DateTime 2025-07-04
    * @param
    * @return  
    */
    public static void cloneItem(Map<String,Order__c> newOrderMap){
        Set<String> orderIdSet = newOrderMap.keySet();
        String orderItemSoql = Utility.getAllFieldSoql('Order_Item__c') + ' WHERE Order__c IN :orderIdSet';
        List<Order_Item__c> zar1ItemList = new List<Order_Item__c>();
        for(Order_Item__c item : (List<Order_Item__c>)Database.query(orderItemSoql)){
            Order_Item__c zar1Item = item.clone(FALSE,TRUE,FALSE,FALSE);
            zar1Item.Order__c = newOrderMap.get(item.Order__c)?.Id;
            zar1Item.Depend_On_Item__c = item.Id;
            zar1Item.IsCreate__c = TRUE;
            zar1ItemList.add(zar1Item);
        }
        insert zar1ItemList;        
    }
    
    public class OrderData{
        @AuraEnabled public Order__c order;//订单
        @AuraEnabled public String orderUrl;//订单
        @AuraEnabled public Integer index;//序号
        @AuraEnabled public List<Utility.returnValue> termList;//可选的Payment term
        //@AuraEnabled public List<Utility.returnValue> methodList;//可选的Payment method
        @AuraEnabled public Boolean isAutoCreate;//是否自动创建
        @AuraEnabled public Boolean isSelect;
        
        public OrderData(Order__c order,Map<String,List<Utility.returnValue>> termMap,Integer index){
            this.order = order;
            this.orderUrl = Utility.ordUrl + '/lightning/r/Order__c/' + order.Id + '/view';
            this.termList = termMap.get(order.Deliver_Plant__c)??new List<Utility.returnValue>();
            //this.methodList = methodMap.get(order.Sales_Org__c)??new List<Utility.returnValue>();
            this.isAutoCreate = FALSE;
            this.index = index;
            this.isSelect = FALSE;
        }
    }
}