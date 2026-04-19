/**************************************************************************************************
 * Name: ProductSalesInfoSyncToSAP
 * Object: 
 * Purpose: 库存数量后去
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-18         Created    
 * 2.0           Wyh              2025-07-04         Modified         
***************************************************************************************************/
public without sharing class ProductSalesInfoSyncToSAP {
    public static final String END_POINT = 'productNumber';



    @AuraEnabled
    public static ReturnResult submitToSAP(List<String> Ids){
        System.debug('Ids========>'+Ids);
        ReturnResult returnResult = new ReturnResult();
        returnResult.isSuccess = true;
        Boolean isSuccess = true;
        String requestBody = '';
        String responseBodyStr = '';
        String errorMessage = '';
        Savepoint sp; 
        try{
            RequestBody request = new RequestBody();
            request.esbinfo = new ReqESInfo();
            request.esbinfo.requesttime = String.valueOf(Datetime.now());
            Set<String> idSet = new Set<String>(Ids);
            List<ReqProSalesInfo> resultinfoList = new List<ReqProSalesInfo>();
            //获取产品销售视图
            List<Product_Sales_Info__c> psiList=[SELECT Id,Factory__c,Product__r.Name   
                                        FROM Product_Sales_Info__c 
                                        WHERE Id IN: idSet];
            for(Product_Sales_Info__c psi : psiList){
                ReqProSalesInfo rpsi = new ReqProSalesInfo();
                rpsi.MATNR = psi.Product__r.Name;
                rpsi.WERKS = psi.Factory__c;
                resultinfoList.add(rpsi);
            }
            
            request.resultinfo = resultinfoList;

            requestBody = JSON.serialize(request);
            requestBody = requestBody.replaceAll('null', '""');
            System.debug('requestBody++'+requestBody);
            HttpResponse responseBody = InterfaceUtility.send_SAP_POST_Service(requestBody, END_POINT);
            System.debug('responseBody++'+responseBody);
            responseBodyStr = responseBody.getBody();
            // responseBodyStr = '{"esbinfo":{"instid":"U2FwU2FsZXNNdWxlRVNCL1NhcFNhbGVzSW52ZW50b3J5SW5mb1N5bmNTdmNDb25maWdGbG93MjAyNS0wNC0zMCAwMzozNDozMS45MTM=","requesttime":"2025-04-29 13:34:31","responsetime":"2025-04-30 03:34:31.000","returnstatus":"W","returncode":"W001","returnmsg":"No data found","attr1":"","attr2":"","attr3":""},"resultinfo":[]}';
            System.debug('responseBodyStr===' + responseBodyStr);
            isSuccess = responseBody.getStatusCode() == 200 ? true : false;
            sp = Database.setSavepoint();
            if (isSuccess) {
                ResponseBody syncReturnData = (ResponseBody) JSON.deserialize(responseBodyStr, ResponseBody.class);
                System.debug('responseData===' + syncReturnData);
                if ( syncReturnData.esbinfo != null &&  syncReturnData.resultinfo.size() > 0) {
                    if (syncReturnData.esbinfo.returnstatus == 'S') {
                        returnResult.message = syncReturnData.esbinfo.returnmsg;
                        Map<String,String> proMap = new Map<String,String>();
                        Map<String,String> proDescMap = new Map<String,String>();
                        Map<String,String> accMap = new Map<String,String>();
                        Set<String> accMapSet = new Set<String>();
                        for(RespProSalesInfo rpsi : syncReturnData.resultinfo){
                            proMap.put(rpsi.MATNR,'');
                            if (String.isNotBlank(rpsi.KUNNR)) {
                                accMapSet.add(rpsi.KUNNR);
                            }
                        }
                        List<Product__c> proList = [SELECT Id,Name,English_Description__c
                                                    FROM Product__c 
                                                    WHERE Name IN: proMap.keyset()];
                        List<Account> accList = [SELECT Id,MDG_Customer_Code__c 
                                                    FROM Account 
                                                    WHERE MDG_Customer_Code__c IN:accMapSet];
                        
                        for(Product__c pro : proList){
                            proMap.put(pro.Name,pro.Id);
                            proDescMap.put(pro.Name,pro.English_Description__c);
                        }
                        for(Account acc : accList){
                            accMap.put(acc.MDG_Customer_Code__c,acc.Id);
                        }
                        Map<String,Decimal> returnMap = new Map<String,Decimal>();
                        Map<String,Decimal> zavinMap = new Map<String,Decimal>();//open Order Map
                        Map<String,Decimal> omengMap = new Map<String,Decimal>();//交货单占用Map
                        Map<String,Decimal> inventoryMap = new Map<String,Decimal>();//在库库存Map
                        Map<String,String> productNameMap = new Map<String,String>();//商品名Map
                        Map<String,Boolean> isConMap = new Map<String,Boolean>();//是否寄售库存
                        List<Product_Inventory__c> inventoryList = new List<Product_Inventory__c>();
                        Map<String,String> pilist = new Map<String,String>();
                        for(RespProSalesInfo rpsi : syncReturnData.resultinfo){
                            Product_Inventory__c upProInv = new Product_Inventory__c();
                            upProInv.External_Id__c = rpsi.LGORT+rpsi.MATNR+rpsi.CHARG+rpsi.WERKS+rpsi.KUNNR;
                            pilist.put(upProInv.External_Id__c,upProInv.External_Id__c);
                            upProInv.Currency__c = rpsi.KTOPL;
                            if (String.isNotBlank(rpsi.VERPR)) {
                                upProInv.Unit_Cost__c = Decimal.valueOf(rpsi.VERPR.trim());
                            }else{
                                upProInv.Unit_Cost__c = null;
                            }
                            if (String.isNotBlank(rpsi.VMKUM)) {
                                upProInv.USD_Cost__c = Decimal.valueOf(rpsi.VMKUM.trim());
                            }else{
                                upProInv.USD_Cost__c = null;
                            }

                            if (String.isNotBlank(rpsi.hsdat)) {
                                upProInv.Production_Date__c = Date.valueOf(rpsi.hsdat);
                            }else{
                                upProInv.Production_Date__c = null;
                            }

                            if (String.isNotBlank(rpsi.vfdat)) {
                                upProInv.To_Date__c = Date.valueOf(rpsi.vfdat);
                            }else{
                                upProInv.To_Date__c = null;
                            }
                            
                            upProInv.Default_Unit__c = rpsi.MEINS;
                            upProInv.Sales_Unit__c = rpsi.VRKME;
                            // upProInv.Storage_Location__c = rpsi.WERKS+'-'+rpsi.LGORT;
                            upProInv.Storage_Location__c = rpsi.LGORT;
                            if (proMap.containsKey(rpsi.MATNR)) {
                                String productId = proMap.get(rpsi.MATNR);
                                if (String.isNotBlank(productId)) {
                                    upProInv.Product__c = productId;
                                }
                            }
                            upProInv.Batch_Number__c = rpsi.CHARG;
                            upProInv.Plant__c = rpsi.WERKS;
                            upProInv.Product_Name_Text__c = rpsi.ATWRT;
                            if(String.isBlank(upProInv.Product_Name_Text__c) && upProInv.Plant__c=='5070')
                            {
                                upProInv.Product_Name_Text__c=proDescMap.get(rpsi.MATNR);
                            }
                            
                            if (String.isNotBlank(rpsi.CSPEM.trim())) {
                                upProInv.Frozen__c = Decimal.valueOf(rpsi.CSPEM.trim());
                            }else{
                                upProInv.Frozen__c = null;
                            }
                            if (String.isNotBlank(rpsi.CINSM.trim())) {
                                upProInv.Checking__c = Decimal.valueOf(rpsi.CINSM.trim());
                            }else{
                                upProInv.Checking__c = null;
                            }
                            if (String.isNotBlank(rpsi.CRETM.trim())) {
                                upProInv.Return__c = Decimal.valueOf(rpsi.CRETM.trim());
                            }else{
                                upProInv.Return__c = null;
                            }
                            
                            if(String.isNotBlank(rpsi.LWEDT)){
                                upProInv.Inventory_Age__c = Decimal.valueOf(rpsi.LWEDT.trim());
                            }else{
                                upProInv.Inventory_Age__c = null;
                            }
                            if (accMap.containsKey(rpsi.KUNNR) ) {
                                upProInv.Customer__c = accMap.get(rpsi.KUNNR);
                            }else{
                                upProInv.Customer__c = null;
                            }
                            if (upProInv.Customer__c==null) {
                                
                                upProInv.Search_Key__c = rpsi.MATNR+'-'+upProInv.Plant__c+'-'+upProInv.Product_Name_Text__c;
                                isConMap.put(upProInv.Search_Key__c, false);
                            }else{
                                upProInv.Search_Key__c = rpsi.MATNR+'-'+upProInv.Plant__c+'-'+upProInv.Product_Name_Text__c+'-'+upProInv.Customer__c;
                                isConMap.put(upProInv.Search_Key__c, true);
                            }
                            productNameMap.put(upProInv.Search_Key__c, upProInv.Product_Name_Text__c);
                            Boolean isUpdate = false;
                            if (String.isNotBlank(rpsi.KULAB) && Decimal.valueOf(rpsi.KULAB.trim()) > 0) {
                                upProInv.Consign_Inventory_Quantity__c = Decimal.valueOf(rpsi.KULAB.trim());
                                isUpdate = true;
                            }else{
                                upProInv.Consign_Inventory_Quantity__c = null;
                            }
                            Decimal clabs = 0;
                            if (String.isNotBlank(rpsi.CLABS) && Decimal.valueOf(rpsi.CLABS.trim()) > 0) {
                                upProInv.Inventory_Quantity__c = Decimal.valueOf(rpsi.CLABS.trim());
                                isUpdate = true;
                                clabs = Decimal.valueOf(rpsi.CLABS.trim());
                            }else{
                                upProInv.Inventory_Quantity__c = null;
                            }

                            if (String.isNotBlank(rpsi.KWMENG) && Decimal.valueOf(rpsi.KWMENG.trim()) > 0) {
                                upProInv.Sales_Unit_Inventory__c = Decimal.valueOf(rpsi.KWMENG.trim());
                                isUpdate = true;
                            }else{
                                upProInv.Sales_Unit_Inventory__c = null;
                            }
                            //2025-07-04 wyh 新增参数可以用库存 ZAVIN
                            Decimal zavin = 0;
                            if (String.isNotBlank(rpsi.ZAVIN) && Decimal.valueOf(rpsi.ZAVIN.trim()) > 0) {
                                upProInv.Available_Quantity__c = Decimal.valueOf(rpsi.ZAVIN.trim());
                                zavin = Decimal.valueOf(rpsi.ZAVIN.trim());
                                // isUpdate = true;
                            }else{
                                upProInv.Available_Quantity__c = 0;
                            }
                            //【modified by zach 修改校验的库存逻辑(clabs - OMENG - ZAVIN) 2025-08-06 -start】
                            //returnMap.put(upProInv.Search_Key__c,upProInv.Available_Quantity__c);
                            //OMENG
                            Decimal omeng = 0;
                            if (String.isNotBlank(rpsi.OMENG) && Decimal.valueOf(rpsi.OMENG.trim()) > 0) {
                                upProInv.DN_Used_Quantity__c = Decimal.valueOf(rpsi.OMENG.trim());
                                omeng = Decimal.valueOf(rpsi.OMENG.trim());
                                // isUpdate = true;
                            }else{
                                upProInv.DN_Used_Quantity__c = NULL;
                            }
                            if (!omengMap.containsKey(upProInv.Search_Key__c)) {
                                omengMap.put(upProInv.Search_Key__c,0);
                            }
                            omengMap.put(upProInv.Search_Key__c,omengMap.get(upProInv.Search_Key__c)+omeng);

                            if (!inventoryMap.containsKey(upProInv.Search_Key__c)) {
                                inventoryMap.put(upProInv.Search_Key__c, 0);
                            }
                            if (upProInv.Inventory_Quantity__c!=null) {
                                inventoryMap.put(upProInv.Search_Key__c,inventoryMap.get(upProInv.Search_Key__c)+upProInv.Inventory_Quantity__c);
                            }
                            
                            //汇总clabs - OMENG
                            if(!returnMap.containsKey(upProInv.Search_Key__c)){
                                returnMap.put(upProInv.Search_Key__c,0);
                            }
                            Decimal total = returnMap.get(upProInv.Search_Key__c);
                            total += clabs - omeng;
                            returnMap.put(upProInv.Search_Key__c,total);
                            
                            zavinMap.put(upProInv.Search_Key__c,zavin);
                            //【modified by zach 修改校验的库存逻辑(clabs - OMENG - ZAVIN) 2025-08-06 -end】
                            upProInv.Product_Description__c = rpsi.MAKTX;
                            if (isUpdate) {
                                inventoryList.add(upProInv);
                            }
                        }
                        returnResult.openOrderMap = zavinMap;
                        returnResult.deliveryOrderMap = omengMap;
                        returnResult.inventoryMap = inventoryMap;
                        System.debug('inventoryList====>'+inventoryList.size());
                        if (!inventoryList.isEmpty()) {
                            for(Product_Inventory__c inv : inventoryList){
                                system.debug(inv.Search_Key__c);
                                system.debug(inv.Inventory_Quantity__c);
                                system.debug(inv.Available_Quantity__c);
                            }
                            Database.upsert(inventoryList,Product_Inventory__c.fields.External_Id__c, true);
                        }   
                        //【modified by zach 修改校验的库存逻辑(clabs - OMENG - ZAVIN) 2025-08-06 -start】
                        for(String searchKey : returnMap.keySet()){
                            returnMap.put(searchKey,returnMap.get(searchKey) - zavinMap.get(searchKey));
                        }
                        //【modified by zach 修改校验的库存逻辑(clabs - OMENG - ZAVIN) 2025-08-06 -end】
                        returnResult.returnMap = returnMap;
                        returnResult.productNameMap = productNameMap;
                        returnResult.isConMap = isConMap;
                    }
                    if(syncReturnData.esbinfo.returnstatus == 'E'){
                        isSuccess = false;
                        errorMessage = syncReturnData.esbinfo.returnmsg;
                        returnResult.isSuccess = false;
                        returnResult.message = syncReturnData.esbinfo.returnmsg;
                    }
                    if(syncReturnData.esbinfo.returnstatus == 'W'){
                        isSuccess = true;
                        errorMessage = '';
                        returnResult.isSuccess = false;
                        returnResult.message = 'No Data Found';
                    }
                    
                }else{
                    if(syncReturnData.esbinfo.returnstatus == 'W'){
                        isSuccess = true;
                        errorMessage = '';
                        returnResult.isSuccess = false;
                        returnResult.message = 'No Data Found';
                    }else{
                        returnResult.isSuccess = false;
                        returnResult.message = syncReturnData.esbinfo.returnmsg;
                        isSuccess = false;
                        errorMessage = responseBodyStr;
                    }
                }
                
            } else {
                returnResult.isSuccess = false;
                returnResult.message = String.valueOf(responseBody.getStatusCode());
                isSuccess = false;
                errorMessage = responseBodyStr;
            }

        }
        catch (Exception e) {
            if (sp != null) {
                Database.rollback(sp);
            }
            System.debug('错误信息'+e.getMessage()+'行数：'+e.getLineNumber());
            returnResult.isSuccess = false;
            returnResult.message = e.getMessage()+e.getLineNumber();
            isSuccess = false;
            errorMessage = e.getMessage()+e.getLineNumber();
        }
        InterfaceUtility.insertInterfaceLog('ProductSalesInfoSyncToSAP', 'CRM',
                    'SAP', END_POINT, requestBody, isSuccess, false,
                    responseBodyStr, errorMessage, 'POST', Ids,
                    '查询产品库存信息', 'CRM查询SAP库存信息');
        return returnResult;
    }
    
    //校验库存通用方法
    public static void checkInventory(List<String> orderIdList){
        Set<String> proIdSet = new Set<String>();
        Set<String> plantSet = new Set<String>();
        List<Id> proInfoIdList = new List<Id>();
        //订单
        List<Order_Item__c> itemList = [SELECT Id,Commodity__c,Commodity__r.Product_Sales_Info__c,SAP_Remain_Stock__c,Order__c,Order__r.Deliver_Plant__c,
                                        Order__r.Customer__c,Commodity__r.Product_Combo__c,Quantity__c,Commodity__r.Product__r.Name,Commodity__r.Name,Default_Unit_Quantity__c
                                        FROM Order_Item__c WHERE Order__c IN:orderIdList];
        for(Order_Item__c item : itemList){
            proIdSet.add(item.Commodity__c);
            plantSet.add(item.Order__r.Deliver_Plant__c);
            proInfoIdList.add(item.Commodity__r.Product_Sales_Info__c);
        }
        
        //product name需要校验的库存唯一键(不含客户)map
        Map<String,Set<String>> ukMap = new Map<String,Set<String>>();
        //产品包下的产品数量
        Map<String,Decimal> ukProItemQuantityMap = new Map<String,Decimal>();
        for(Product_Name__c pro :[SELECT Id,Product_Sales_Info__c,Product_Combo__c,Product__r.Name,Name,(SELECT Id,Product_Name__r.Product_Sales_Info__c,
                                 Product_Name__r.Name,Product_Name__r.Product__r.Name,Quantity__c FROM Product_Combo_Item__r WHERE Quantity__c > 0) 
                                 FROM Product_Name__c WHERE Id IN:proIdSet]){
            if(pro.Product_Combo__c){
                for(Product_Name_Item__c proItem : pro.Product_Combo_Item__r){
                    proInfoIdList.add(proItem.Product_Name__r.Product_Sales_Info__c);
                    String uk = proItem.Product_Name__r.Product__r.Name + '-5070-' + proItem.Product_Name__r.Name;
                    if(!ukMap.containsKey(pro.Id)){
                        ukMap.put(pro.Id,new Set<String>());
                    }
                    ukMap.get(pro.Id).add(uk);
                    ukProItemQuantityMap.put(uk,proItem.Quantity__c);
                }
            }else{
                proInfoIdList.add(pro.Product_Sales_Info__c);
                String uk = pro.Product__r.Name + '-5070-' + pro.Name;
                ukMap.put(pro.Id,new Set<String>{uk});
            }           
        }
        
        //获取库存
        Map<String,Decimal> inventoryMap = submitToSAP(proInfoIdList).returnMap ?? new Map<String,Decimal>();
        system.debug('inventoryMap');
        system.debug(inventoryMap);
        //审批中产品的数量
        Map<String,Decimal> proQuantityMap = getApprovingQuantity(proIdSet,plantSet);
        system.debug('proQuantityMap');
        system.debug(proQuantityMap);
        
        //校验
        Set<String> errorOrderIdSet = new Set<String>();
        for(Order_Item__c item : itemList){
            String uk = item.Commodity__r.Product__r.Name + '-' + item.Order__r.Deliver_Plant__c + '-' + item.Commodity__r.Name;
            system.debug(uk);
            system.debug(inventoryMap.get(uk));
            system.debug(proQuantityMap.get(uk));
            Decimal inventory = (inventoryMap.get(uk) ?? 0) - (proQuantityMap.get(uk) ?? 0);
            if(item.Default_Unit_Quantity__c == NULL || item.Default_Unit_Quantity__c > inventory){
                errorOrderIdSet.add(item.Order__c);
            }
            //除去当前产品数量，存剩余库存
            item.SAP_Remain_Stock__c = inventory;
            system.debug(item.SAP_Remain_Stock__c);    
        }   
        
        //更新
        List<Order__c> errorOrderList = new List<Order__c>();
        for(Order__c order :[SELECT Id,Is_Meet_the_inventory__c FROM Order__c WHERE Id IN:orderIdList]){
            if(errorOrderIdSet.contains(order.Id)){
                order.Is_Meet_the_inventory__c = FALSE;
                errorOrderList.add(order);
            }
        }
        
        update itemList;
        update errorOrderList;
    }
    
    //获取审批中的所有订单并按照唯一键汇总数量
    public static Map<String,Decimal> getApprovingQuantity(Set<String> proIdSet,Set<String> plantSet){
        Set<String> approvingProIdSet = new Set<String>();
        //审批中订单行的数据
        Map<String,Decimal> orderItemQuantityMap = new Map<String,Decimal>();
        List<Order_Item__c> approvingList = [SELECT Id,Commodity__c,Quantity__c,Commodity__r.Product__r.Name,Order__r.Deliver_Plant__c,Commodity__r.Name,Default_Unit_Quantity__c 
                                             FROM Order_Item__c WHERE Order__r.Deliver_Plant__c IN:plantSet AND Order__r.Status__c = 'Approving' AND Commodity__c IN:proIdSet];
        
        //审批中产品的数量
        Map<String,Decimal> proQuantityMap = new Map<String,Decimal>();
        for(Order_Item__c item : approvingList){
            String uk = item.Commodity__r.Product__r.Name + '-' + item.Order__r.Deliver_Plant__c + '-' + item.Commodity__r.Name;
            if(!proQuantityMap.containsKey(uk)){
                proQuantityMap.put(uk,0);
            }
            Decimal quantity = proQuantityMap.get(uk);
            quantity += item.Default_Unit_Quantity__c ?? 0;
            proQuantityMap.put(uk,quantity);   
        }
        system.debug(proQuantityMap);
        return proQuantityMap;
    }

    //ZARB订单校验库存
    /*@future(callout=true)
    public static void checkInventoryBeforeSubmit(List<String> orderIdList,String comments){
        checkInventory(orderIdList);
        //提交审批
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        for(Order__c order :[SELECT Id,Is_Meet_the_inventory__c FROM Order__c WHERE Id IN:orderIdList]){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(order.Id);
            req.comments = comments;//备注
            requests.add(req);
        }
        Approval.process(requests, FALSE);
    }*/

    public class ReturnResult {
        @InvocableVariable(Label='是否成功' Description='是否成功')
        public Boolean isSuccess;
        @InvocableVariable(Label='返回信息结果' Description='返回信息结果')
        public String message;
        public Map<String,Decimal> returnMap;

        public Map<String,Boolean> isConMap;

        public Map<String,String> productNameMap;

        public Map<String,Decimal> openOrderMap;

        public Map<String,Decimal> deliveryOrderMap;

        public Map<String,Decimal> inventoryMap;
    }
    //2025-07-04 wyh 新增用于导入判断库存数量
    public class Inventory {
        @AuraEnabled public Decimal AvailableQuantity;
        @AuraEnabled public String SearchKey;
    }
    public class ResponseBody {
      public RespESInfo esbinfo;
      public List<RespProSalesInfo> resultinfo;
    }

    public class RespESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
        public String responsetime;//返回时间
        public String returnstatus;//接口状态
        public String returncode;//接口状态码
        public String returnmsg;//接口消息
    }

    public class RespProSalesInfo{
        public String code;//处理状态
        public String message;//错误信息
        public String ATWRT;//商品名称
        public String KTOPL;//币种
        public String VERPR;//单位成本
        public String VMKUM;//美元成本
        public String MEINS;//基本计量单位
        public String LGORT;//非限制库存数量地点
        public String MATNR;//物料号
        public String CHARG;//批次号
        public String WERKS;//工厂
        public String CLABS;//可以销售的数量
        public String CSPEM;//已冻结
        public String CINSM;//在检
        public String CRETM;//退货
        public String LWEDT;//库龄
        public String KUNNR;//客户
        public String KULAB;//寄售库存
        public String VRKME;//销售单位
        public String KWMENG;//销售单位数量
        public String MAKTX;//销售单位数量
        //2025-07-04 wyh 新增参数可以用库存 ZAVIN
        public String ZAVIN;//可用库存
        public String OMENG;//交货单占用
        public String hsdat;//生产日期
        public String vfdat;//到期日期
    }
    
    public class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqProSalesInfo> resultinfo;
    }

    public class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
    }

    public class ReqProSalesInfo{
        public String MATNR;//物料号
        public String WERKS;//工厂
    }

}