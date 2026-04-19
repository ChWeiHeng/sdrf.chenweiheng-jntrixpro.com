/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-26-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-11-2025   Gerry   Initial Version
**/
@RestResource(urlMapping='/SAPOrderWebService')
global without sharing class SAPOrderWebService {
    
    public class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqOrderInfo> resultinfo;
    }
    
    public class Output {
        public String error;
        public Boolean isSuccess;
        public Boolean isPartSuccess;
        public List<ReturnData> ReturnDataList;
    }
    
    public class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
    }
    
    public class ReqOrderInfo{
        public String VBELN;//SAP订单号
        public String BSTNK;//客户参考号
        public String KUNNR_SHIP;//ship to
        public String KUNNR;//客户编号
        public String VKORG;//销售组织
        public String VTWEG;//分销渠道
        public String AUART;//销售凭证类型
        public String AUGRU;//订单原因
        public String ERNAM;//销售订单创建人
        public String INCO1;//国际贸易条款（第 1 部分）
        public String INCO2_L;//国际贸易条款位置 2
        public String ERDAT;//销售订单创建日期
        public String ERZET;//销售订单创建时间
        public String WAERK;//币种
        public String ZTERM;//付款条件
        public Decimal KURSK;//汇率
        public String SPART;//产品组
        public String bname;//合同号
        public String kvgr3;//业务模式
        public String ZCKG;//出口国
        public List<OrderItemRow> ITEMS;//销售订单行项目表
    }
    
    
    public class OrderItemRow{
        public String POSNR;//销售订单行号
        public String MATNR;//物料编码
        public String ARKTX;//物料描述
        public String WERKS;//交货工厂
        public String LGORT;//库存地点
        public String VRKME;//销售单位
        public Decimal WMENG;//订单数量
        public Decimal MWSBP;//税额合计
        public Decimal NETWR;//净值合计
        public Decimal AMOUNT;//含税合计
        public String EDATU;//客户参考日期
        public String PRCTR;//利润中心
        public Decimal BRGEW;//毛重
        public Decimal NTGEW;//净重
        public String ABGRU;//拒绝原因
        public String zzname;//商品名
    }
    
    /**
     * SAP 非常规订单同步接口
     * @param bodyStrJson bodyStrJson
     *
     * @return ResponseBody
     */
    @HttpPost
    global static ResponseBody doPost() {
        String respTime = String.valueOf(Datetime.now());
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String bodyStrJson = req.requestBody.toString();
        List<String> dataIdList = new List<String>();
        List<ReturnData> returnDataList = new List<ReturnData>();
        
        Boolean isSuccess = true;
        Boolean isPartSuccess = false;
        Savepoint sp = Database.setSavepoint();
        String errorMsg;
        try {
            System.debug('bodyStrJson1==' + bodyStrJson);
            RequestBody reqBody = (RequestBody) JSON.deserialize(bodyStrJson, RequestBody.class);
            Output out = feedbackOrderInfo(reqBody.resultinfo);
            isSuccess = out.isSuccess;
            isPartSuccess = out.isPartSuccess;
            errorMsg = out.error;
            returnDataList = out.ReturnDataList;
        } catch (Exception e) {
            Database.rollback(sp);
            errorMsg = e.getMessage() + '[' + e.getLineNumber() + ']';
            isSuccess = false;
            isPartSuccess = false;
        }
        ResponseBody response = returnData(respTime, isSuccess, errorMsg, returnDataList);
        InterfaceUtility.insertInterfaceLog('SAPOrderWebService', 'SAP', 'CRM',
        '/services/apexrest/receiveDataFromExternal/  requestCode:SAP001', bodyStrJson, isSuccess, isPartSuccess,
        JSON.serialize(response), errorMsg, 'POST', dataIdList, 'Upsert', 'SAP同步订单至CRM'
            );
        
        return response;
    }
    
    public static Output feedbackOrderInfo(List<ReqOrderInfo> resultinfo) {
        Boolean isPartSuccess = false;
        Map<Integer,Order__c> orderMap = new Map<Integer,Order__c>();
        Map<Integer,Order_Item__c> orderItemMap = new Map<Integer,Order_Item__c>();
        
        Map<Integer,List<Order_Item__c>> orderItemMapColl = new Map<Integer,List<Order_Item__c>>();
        Set<String> customerIdSet = new Set<String>();
        Set<String> contractSet = new Set<String>();
        Set<String> productNameSet = new Set<String>();
        Map<String,Boolean> customeMap = new Map<String,Boolean>();
        Set<String> salesOrgSet = new Set<String>();
        Set<String> salesPlantSet = new Set<String>();
        Map<String,String> countryMap = new Map<String,String>();
        for(Country_Province_Master_Data__c cpmd : [SELECT Id,Code__c FROM Country_Province_Master_Data__c WHERE RecordType.DeveloperName='Country']) {
            countryMap.put(cpmd.Code__c,cpmd.Id);
        }
        for (ReqOrderInfo reqOrder : resultinfo) {
            customerIdSet.add(reqOrder.KUNNR);
            contractSet.add(reqOrder.bname);
            salesOrgSet.add(reqOrder.VKORG);
            String plan;
            for(OrderItemRow oir : reqOrder.ITEMS){
                productNameSet.add(oir.MATNR+'_'+reqOrder.VKORG+'_'+reqOrder.VTWEG+'_'+oir.WERKS+'_'+oir.zzname+'_');
                plan = oir.WERKS;
            }
            salesPlantSet.add(plan);
        }
        List<Account> accList = [SELECT Id,MDG_Customer_Code__c,Is_YPF__c
                                    FROM Account 
                                    WHERE MDG_Customer_Code__c IN: customerIdSet];
        Map<String,String> ownerMap = new Map<String,String>();
        for(Customer_Sales_Info__c csi : [SELECT Id,Customer__r.MDG_Customer_Code__c,Sales_Org__c,Delivering_Plant__c,OwnerId FROM Customer_Sales_Info__c WHERE Customer__r.MDG_Customer_Code__c IN:customerIdSet AND Sales_Org__c IN:salesOrgSet AND Delivering_Plant__c IN:salesPlantSet AND Owner.IsActive =true]) {
            ownerMap.put(csi.Customer__r.MDG_Customer_Code__c+'_'+csi.Sales_Org__c+'_'+csi.Delivering_Plant__c,csi.OwnerId);
        }
        if (accList.size()>0) {
            for(Account acc : accList){
                customeMap.put(acc.MDG_Customer_Code__c,acc.Is_YPF__c);
            }
        }
        
        Map<String,Contracts__c> conMap = new Map<String,Contracts__c>();
        for (Contracts__c con : [SELECT Id,BPM_Contrct_Numbder__c,OwnerId FROM Contracts__c WHERE BPM_Contrct_Numbder__c IN:contractSet AND Owner.IsActive =true]) {
            conMap.put(con.BPM_Contrct_Numbder__c,con);
        }
        
        Map<String,String> pnMap = new Map<String,String>();
        for (Product_Name__c pn : [SELECT Id,External_Id__c FROM Product_Name__c WHERE External_Id__c IN:productNameSet]) {
            pnMap.put(pn.External_Id__c,pn.Id);
        }

        Map<String,Contracts_Detail__c> cdMpa = new Map<String,Contracts_Detail__c>();
        for(Contracts_Detail__c cd : [SELECT Contracts__c,Product__r.Name,Id,Unit_Price__c,BU_Sales_Price__c FROM Contracts_Detail__c WHERE Contracts__r.BPM_Contrct_Numbder__c IN:conMap.keySet()  AND Unit_Price__c!=null]) {
            cdMpa.put(cd.Contracts__c+'_'+cd.Product__r.Name,cd);
        }
        
        Boolean flag = false;
        String error = '';
        Integer orderIndex = 0;
        Integer orderDetailIndex = 0;
        for (ReqOrderInfo reqOrder : resultinfo) {
            List<Order_Item__c> orderItemList = new List<Order_Item__c>();
            Order__c order = new Order__c();
            order.Exporting_Country__c = countryMap.get(reqOrder.ZCKG);
            order.BPM_Contrcat_Numbder__c = reqOrder.bname;
            order.SAP_Order__c = true;
            order.SAP_Order_Code__c = reqOrder.VBELN;
            //增加ship to
            if (String.isNotBlank(reqOrder.KUNNR_SHIP)) {
                Account acc = new Account();
                acc.MDG_Customer_Code__c = reqOrder.KUNNR_SHIP;
                order.Ship_To__r = acc;
            }
            
            order.Cust_Reference__c = reqOrder.BSTNK;
            // if (customeMap.size()>0 && customeMap.containsKey(reqOrder.KUNNR)) {
                Account acc = new Account();
                acc.MDG_Customer_Code__c = reqOrder.KUNNR;
                order.Customer__r = acc;
            // }
            // if(customeMap.get(reqOrder.KUNNR)==null) {
                //     error += ';'+reqOrder.KUNNR;
                //     flag = true;
            // }
            order.Sales_Org__c = reqOrder.VKORG;
            order.Distr_Channel__c = reqOrder.VTWEG;
            order.Order_type__c = reqOrder.AUART;
            order.Order_Reason__c = reqOrder.AUGRU;
            order.Currency__c = reqOrder.WAERK;
            order.Inco_Location1__c = reqOrder.INCO1;
            // order.Inco_Location2__c = reqOrder.INCO2_L;
            order.SAP_Order_Code__c = reqOrder.VBELN;
            order.SAP_Order_Code__c = reqOrder.VBELN;
            order.SAP_Created_By__c = reqOrder.ERNAM;
            order.SAP_Created_Date__c = reqOrder.ERDAT;
            order.Approve_Date__c = String.isNotBlank(reqOrder.ERDAT) ? Date.valueOf(reqOrder.ERDAT) : null;
            order.SAP_Created_Time__c = reqOrder.ERZET;
            order.Terms_Of_Payment__c = reqOrder.ZTERM;
            order.Rate__c = reqOrder.KURSK;
            order.Sync_Status__c = 'Synchronized';
            order.Status__c = 'Approved';
            String plan;
            for(OrderItemRow oir : reqOrder.ITEMS){
                order.Profit_Center__c = oir.PRCTR;
                
                Order_Item__c oi = new Order_Item__c();
                if (String.isNotBlank(reqOrder.bname) && conMap.get(reqOrder.bname)!=null) {
                    if(cdMpa.get(conMap.get(reqOrder.bname).Id+'_'+oir.MATNR)!=null) {
                        Decimal salesPrice = cdMpa.get(conMap.get(reqOrder.bname).Id+'_'+oir.MATNR).BU_Sales_Price__c;
                        Decimal cost = cdMpa.get(conMap.get(reqOrder.bname).Id+'_'+oir.MATNR).Unit_Price__c;
                        if(salesPrice!=null && cost!=null) {
                            oi.Product_Cost__c = cdMpa.get(conMap.get(reqOrder.bname).Id+'_'+oir.MATNR).Unit_Price__c;
                            if( salesPrice!=0) {
                                oi.Margin_Rate__c = ((salesPrice-cost)/salesPrice*100).setScale(2);
                            }
                            oi.Margin__c = salesPrice-cost;
                        }
                        
                    }
                    
                }
                oi.IsCreate__c = true;
                if (String.isNotBlank(oir.ABGRU)) {
                    // order.Status__c = 'Close';
                    oi.isClosed__c = true;
                    oi.Closure_Reason__c = oir.ABGRU;
                }
                oi.Commodity__c = pnMap.get(oir.MATNR+'_'+reqOrder.VKORG+'_'+reqOrder.VTWEG+'_'+oir.WERKS+'_'+oir.zzname+'_');
                oi.Product_Name_Text__c = oir.zzname;
                oi.External_Id__c = reqOrder.VBELN+'_'+oir.POSNR;
                oi.Material_Number__c = oir.MATNR;
                oi.Material_Description__c = oir.ARKTX;
                oi.Factory__c = oir.WERKS;
                plan = oir.WERKS;
                //oi.Inventory_Location__c = oir.WERKS+'-'+oir.LGORT;
		        oi.Inventory_Location__c = oir.LGORT;
                oi.Sales_Unit_Text__c = oir.VRKME;
                oi.Quantity__c = oir.WMENG;
                oi.Amount_per_item__c = oir.NETWR;
                oi.SAP_Total_Tax__c = oir.MWSBP;
                oi.SAP_Total_Net__c = oir.Amount;
                oi.SAP_Item_Num__c = oir.POSNR;
                oi.Delivery_Date__c = String.isNotBlank(oir.EDATU) ? Date.valueOf(oir.EDATU) : null;
                oi.Gross_Weight__c = oir.BRGEW + '';
                oi.Net_Weight__c = oir.NTGEW + '';
                if (oir.WMENG != 0 && oir.WMENG!=null) {
                    oi.Price__c = (oir.NETWR/oir.WMENG).setScale(2);
                }else{
                    oi.Price__c = 0;
                }
                
                Order__c orderRele = new Order__c();
                orderRele.SAP_Order_Code__c = reqOrder.VBELN;
                oi.Order__r = orderRele;
                orderItemMap.put(orderDetailIndex,oi);
                orderItemList.add(oi);
                orderDetailIndex++;
            }
            order.Deliver_Plant__c = plan;
            order.Business_Model__c = reqOrder.kvgr3;

            if (order.Sales_Org__c.startsWith('1') || order.Sales_Org__c.startsWith('2')) {
                order.recordtypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_B').getRecordTypeId();
                if (String.isblank(order.Business_Model__c)) {
                    order.Business_Model__c = 'B0';
                }
            }else{
                order.recordtypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
                if (order.Sales_Org__c == '3020' && order.Deliver_Plant__c == '3020') {//mx C
                    if (String.isblank(order.Business_Model__c)) {
                        order.Business_Model__c = 'C0';
                    }
                }
                if (order.Sales_Org__c == '3010' && order.Deliver_Plant__c == '3011') {//mx C+
                    if (String.isblank(order.Business_Model__c)) {
                        order.Business_Model__c = 'C1';
                    }
                }
                
                if (order.Sales_Org__c == '3010' && order.Deliver_Plant__c == '3010') {//mx B
                    order.recordtypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_B').getRecordTypeId();
                    if (String.isblank(order.Business_Model__c)) {
                        order.Business_Model__c = 'B0';
                    }
                }
                
                if (order.Sales_Org__c == '5130' && order.Deliver_Plant__c == '5130') {
                    if (String.isblank(order.Business_Model__c)) {
                        order.Business_Model__c = 'C0';
                    }
                    
                }
                if (order.Sales_Org__c == '5070' && order.Deliver_Plant__c == '5070' && customeMap.get(reqOrder.KUNNR)!=null && !customeMap.get(reqOrder.KUNNR)) {
                    order.recordtypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_B').getRecordTypeId();
                    if (String.isblank(order.Business_Model__c)) {
                        order.Business_Model__c = 'B0';
                    }
                }

                if (order.Sales_Org__c == '5070' && order.Deliver_Plant__c == '5070' && customeMap.get(reqOrder.KUNNR)!=null && customeMap.get(reqOrder.KUNNR)) {
                    if (String.isblank(order.Business_Model__c)) {
                        order.Business_Model__c = 'C0';
                    }
                }
            }
            
            if(ownerMap.get(reqOrder.KUNNR+'_'+reqOrder.VKORG+'_'+plan)!=null) {
                order.ownerId = ownerMap.get(reqOrder.KUNNR+'_'+reqOrder.VKORG+'_'+plan);
            }
            
            if (String.isNotBlank(reqOrder.bname) && conMap.get(reqOrder.bname)!=null) {
                order.Contract__c = conMap.get(reqOrder.bname).Id;
                order.OwnerId = conMap.get(reqOrder.bname).OwnerId;
            }
            
            orderMap.put(orderIndex,order);
            orderItemMapColl.put(orderIndex,orderItemList);
            orderIndex++;
        }
        
        
        
        // if(!flag) {
            Output out = new Output();
            out.ReturnDataList = new List<ReturnData>();
            ReturnData returnDataMsg;
            String errorStr = '';
            String code = '';
            Integer index = 0;
            Integer resultIndex = 0;
            if (orderMap.size() > 0) {
                resultIndex = 0;
                List<Database.UpsertResult> resultListHead = Database.upsert(orderMap.values(),Order__c.fields.SAP_Order_Code__c, false);
                for(Integer i=0;i<resultListHead.size();i++) {
                    Database.UpsertResult resultHead = resultListHead[resultIndex];
                    if(!resultHead.isSuccess()) {
                        errorStr = '';
                        for(Database.Error errorStrItem : resultHead.getErrors()) {
                            errorStr = errorStr + errorStrItem.getMessage();
                        }
                        for (Order_Item__c orderItemTmp : orderItemMapColl.get(resultIndex)) {
                            returnDataMsg = new ReturnData();
                            returnDataMsg.vbeln = orderMap.get(resultIndex).SAP_Order_Code__c;
                            returnDataMsg.posnr = orderItemTmp.SAP_Item_Num__c;
                            returnDataMsg.msgty = 'E';
                            returnDataMsg.msgtx = errorStr;
                            out.ReturnDataList.add(returnDataMsg);
                        }
                        orderItemMapColl.remove(resultIndex);
                        isPartSuccess = true;
                    }
                    resultIndex++;
                }
                
            }
            Map<Integer,Order_Item__c> orderItemFinal = new Map<Integer,Order_Item__c>();
            Integer orderItemFinalIndex = 0;
            if (orderItemMapColl.size() > 0) {
                for(Integer key : orderItemMapColl.keySet()) {
                    List<Order_Item__c> OrderTmpListFina = orderItemMapColl.get(key);
                    for (Order_Item__c OrderTmpFina : OrderTmpListFina) {
                        orderItemFinal.put(orderItemFinalIndex,OrderTmpFina);
                        orderItemFinalIndex++;
                    }
                } 
                // (List<Order_Item__c> OrderTmpListFina : orderItemMapColl) {
                //     for (Order_Item__c OrderTmpFina : OrderTmpListFina) {
                //         orderItemFinal.put(orderItemFinalIndex,OrderTmpFina);
                //         orderItemFinalIndex++;
                //     }
                // }
            }
            Integer resultDetailIndex = 0;
            if (orderItemFinal.size() > 0) {
                List<Database.UpsertResult> resultListItem = Database.upsert(orderItemFinal.values(),Order_Item__c.fields.External_Id__c, false);
                resultDetailIndex = 0;
                for(Integer i=0;i<resultListItem.size();i++) {
                    Database.UpsertResult resultItem = resultListItem[resultDetailIndex];
                    returnDataMsg = new ReturnData();
                    errorStr = '';
                    code = '';
                    index = 0;
                    if(!resultItem.isSuccess()) {
                        for(Database.Error errorStrItem : resultItem.getErrors()) {
                            errorStr = errorStr + errorStrItem.getMessage();
                        }
                        code = orderItemFinal.get(resultDetailIndex).External_Id__c;
                        index = code.indexOf('_');
                        returnDataMsg.vbeln = code.substring(0,index);
                        returnDataMsg.posnr = code.substring(index + 1);
                        returnDataMsg.msgty = 'E';
                        returnDataMsg.msgtx = errorStr;
                        out.ReturnDataList.add(returnDataMsg);
                        isPartSuccess = true;
                    } else {
                        code = orderItemFinal.get(resultDetailIndex).External_Id__c;
                        index = code.indexOf('_');
                        returnDataMsg.vbeln = code.substring(0,index);
                        returnDataMsg.posnr = code.substring(index + 1);
                        returnDataMsg.msgty = 'S';
                        returnDataMsg.msgtx = 'The data is successfully written!';
                        out.ReturnDataList.add(returnDataMsg);
                    }
                    resultDetailIndex++;
                }
            }
            out.isSuccess = true;
            out.isPartSuccess = isPartSuccess;
            return out;
        // }else{
            //     Output out = new Output();
            //     out.ErrorDataList = new List<SAPProductWebService.ErrorData>();
            //     out.isSuccess = false;
            //     out.error = error;
            //     return out;
        // }
        
    }
    
    global static ResponseBody returnData(String requestTime,Boolean status,String errorMsg,List<ReturnData> ReturnDataList) {
        ResponseBody re = new ResponseBody();
        re.esbinfo = new RespESInfo();
        re.esbinfo.requesttime = requestTime;//请求时间
        re.esbinfo.responsetime = String.valueOf(Datetime.now());//返回时间
        if (!status) {
            re.esbinfo.returnstatus = 'E';//接口状态
            re.esbinfo.returncode = 'E001';//接口状态码
            re.esbinfo.returnmsg = errorMsg;//接口消息
        }else{
            re.esbinfo.returnstatus = 'S';//接口状态
            re.esbinfo.returncode = 'S001';//接口状态码
        }
        re.resultinfo = new RespCustomerInfo();
        RespCustomerInfo rci = new RespCustomerInfo();
        if (status) {
            rci.msgty = 'S';
            rci.msgtx = '处理成功';
        }else{
            rci.msgty = 'E';
            rci.msgtx = errorMsg;
        }
        rci.returnDataList = ReturnDataList;
        re.resultinfo = rci;
        return re;
    }
    
    global class ResponseBody {
        public RespESInfo esbinfo;
        public RespCustomerInfo resultinfo;
    }
    
    global class RespCustomerInfo{
        public String msgty;//处理状态
        public String msgtx;//错误信息
        public List<ReturnData> returnDataList;
    }
    
    global class ReturnData {
        public String vbeln;//销售凭证
        public String posnr;//销售凭证项目
        public String msgty;//消息类型
        public String msgtx;//消息文本
    }
    
    global class RespESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
        public String responsetime;//返回时间
        public String returnstatus;//接口状态
        public String returncode;//接口状态码
        public String returnmsg;//接口消息
        public String attr1;//预留字段
        public String attr2;//预留字段
        public String attr3;//预留字段
    }
}