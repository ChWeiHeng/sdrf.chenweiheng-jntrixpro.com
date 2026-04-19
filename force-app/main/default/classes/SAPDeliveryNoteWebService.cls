/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 04-07-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   11-20-2025   Gerry   Initial Version
**/
@RestResource(urlMapping='/SAPDeliveryNoteWebService')
global without sharing class SAPDeliveryNoteWebService {
    global class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqDeliveryNoteInfo> resultinfo;
    }
    
    global class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
    }
    
    global class ReqDeliveryNoteInfo{
        public String VBELN;//交货单号
        public String LFART;//交货类型
        public String ERNAM;//交货单创建人
        public String ERDAT;//交货单创建日期
        public String ERZET;//交货单创建时间
        public Date wadat_ist;//发货过账日期
        public String WBSTK;//发货过账状态
        public String PDSTK;//POD状态
        public List<DeliveryNoteRow> ITEMS;
    }
    
    
    global class DeliveryNoteRow{
        public String VRKME1;//交货单位
        public Decimal ZQCOV;//交货数量(订单单位)
        public String POSNR;//交货单行号
        public Decimal LFIMG;//交货数量(交货单单位)
        public String WERKS;//工厂
        public String LGORT;//库存地点
        public String CHARG;//批次
        public String VGBEL;//参考订单号
        public String VGPOS;//参考订单行号
        public String MATNR;//物料编码
        public String ARKTX; //物料描述
        public String ZDELIVERY_COST;//发货成本
    }
    
    /**
     * SAP发货单同步接口
     * @param bodyStrJson bodyStrJson
     *
     * @return ResponseBody
     */
    @HttpPost
    global static SAPOrderWebService.ResponseBody doPost() {
        String respTime = String.valueOf(Datetime.now());
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String bodyStrJson = req.requestBody.toString();
        
        List<String> dataIdList = new List<String>();
        List<SAPOrderWebService.ReturnData> returnDataList = new List<SAPOrderWebService.ReturnData>();
        
        Boolean isSuccess = true;
        Boolean isPartSuccess = false;
        Savepoint sp = Database.setSavepoint();
        
        String errorMsg;
        try {
            System.debug('bodyStrJson1==' + bodyStrJson);
            RequestBody reqBody = (RequestBody) JSON.deserialize(bodyStrJson, RequestBody.class);
            SAPOrderWebService.Output out = feedbackOrderInfo(reqBody.resultinfo);
            isSuccess = out.isSuccess;
            isPartSuccess = out.isPartSuccess;
            errorMsg = out.error;
            returnDataList = out.ReturnDataList;
        } catch (Exception e) {
            Database.rollback(sp);
            errorMsg = InterfaceUtility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
            // System.debug('出现错误：' + respBody.message);
            isSuccess = false;
        }
        SAPOrderWebService.ResponseBody response = SAPOrderWebService.returnData(respTime, isSuccess, errorMsg, returnDataList);
        InterfaceUtility.insertInterfaceLog('SAPDeliveryNoteWebService', 'SAP', 'CRM',
        '/services/apexrest/receiveDataFromExternal/  requestCode:SAP003', bodyStrJson, isSuccess, isPartSuccess,
        JSON.serialize(response), errorMsg, 'POST', dataIdList, 'Upsert', 'SAP同步发货单至CRM'
            );
        
        return response;
    }
    
    public static SAPOrderWebService.Output feedbackOrderInfo(List<ReqDeliveryNoteInfo> resultinfo) {
        Boolean isPartSuccess = false;
        List<Delivery_Note__c> deliveryNoteList = new List<Delivery_Note__c>();
        Map<Integer,Delivery_Note__c> deliveryNoteMap = new Map<Integer,Delivery_Note__c>();
        SAPOrderWebService.Output out = new SAPOrderWebService.Output();
        out.ReturnDataList = new List<SAPOrderWebService.ReturnData>();
        SAPOrderWebService.ReturnData returnDataMsgTmp;
        Integer deliveryNoteIndex = 0;
        Set<String> orderItemSet = new Set<String>();
        set<String> orderSet = new Set<String>();
        for(ReqDeliveryNoteInfo rdni : resultinfo){
            for (DeliveryNoteRow dnr : rdni.ITEMS) {
                orderItemSet.add(dnr.VGBEL+'_'+dnr.VGPOS);
                orderSet.add(dnr.VGBEL);
            }
        }
        List<Order_Item__c> oiList = [SELECT Id,External_Id__c,Order__c,External_Id2__c,Price__c 
                                        FROM Order_Item__c 
                                        WHERE External_Id__c IN: orderItemSet OR External_Id2__c IN: orderItemSet];
        Map<String,Order_Item__c> oiMap = new Map<String,Order_Item__c>();
        if (oiList.size()>0) {
            for(Order_Item__c o : oiList){
                oiMap.put(o.External_Id__c,o);
                if (o.External_Id2__c!=null) {
                    oiMap.put(o.External_Id2__c,o);
                }
            }
        }
        
        Map<String,Order__c> orMap = new Map<String,Order__c>();
        for (Order__c order : [SELECT Id,SAP_Order_Code__c,SAP_Order_Code2__c FROM Order__c WHERE SAP_Order_Code__c IN:orderSet OR SAP_Order_Code2__c IN:orderSet]) {
            orMap.put(order.SAP_Order_Code__c, order);
            if (order.SAP_Order_Code2__c!=null) {
                orMap.put(order.SAP_Order_Code2__c,order);
            }
        }
        List<DeliveryNumber__c> dnPaInserList = new List<DeliveryNumber__c>();
        for(ReqDeliveryNoteInfo rdni : resultinfo){
            String orderCode = '';
            Boolean flag = false;
            for (DeliveryNoteRow dnr : rdni.ITEMS) {
                orderCode = dnr.VGBEL;
                Delivery_Note__c dn = new Delivery_Note__c();
                DeliveryNumber__c dnRe = new DeliveryNumber__c();
                dnRe.External_Id__c = rdni.VBELN;
                dn.Delivery_Number__r = dnre;
                //头部分
                dn.Delivery_Note_Num__c = rdni.VBELN;
                dn.Delivery_Category__c = rdni.LFART;
                dn.Creator_Delivery__c = rdni.ERNAM;
                dn.Creator_Delivery_Date__c = rdni.ERDAT;
                dn.Creator_Delivery_Time__c = rdni.ERZET;
                dn.Delivery_Post_Date__c = Date.valueOf(rdni.wadat_ist);
                dn.Delivery_Post_Status__c = rdni.WBSTK;
                dn.POD_Status__c = rdni.PDSTK;
                dn.External_Id__c = rdni.VBELN+'_'+dnr.POSNR;

                
                
                //ITEMS部分
                dn.Delivery_Note_Item_Num__c = dnr.POSNR;
                if (dn.Delivery_Post_Status__c == 'A') {
                    dn.Delivery_Quantity__c = 0;
                    dn.Delivery_Quantity_Delivery_Unit__c = 0;
                }else{
                    dn.Delivery_Quantity__c = dnr.ZQCOV;
                    dn.Delivery_Quantity_Delivery_Unit__c = dnr.LFIMG;
                }
                dn.SAP_Delivery_Quantity__c = dnr.ZQCOV;
                dn.SAP_Delivery_Quantity_Delivery_Unit__c = dnr.LFIMG;
                dn.Delivery_Unit__c = dnr.VRKME1;
                dn.Plant__c = dnr.WERKS;
                
                // dn.Storage_Location__c = dnr.WERKS+'-'+dnr.LGORT;
                dn.Storage_Location__c = dnr.LGORT;
                dn.Batch__c = dnr.CHARG;
                dn.Reference_Order__c = dnr.VGBEL;
                dn.Reference_Order_Item__c = dnr.VGPOS;
                if (oiMap.containsKey(dnr.VGBEL+'_'+dnr.VGPOS)) {
                    dn.Order_Item__c = oiMap.get(dnr.VGBEL+'_'+dnr.VGPOS).Id;
                }else{
                    returnDataMsgTmp = new SAPOrderWebService.ReturnData();
                    returnDataMsgTmp.vbeln = rdni.VBELN;
                    returnDataMsgTmp.posnr = dnr.POSNR;
                    returnDataMsgTmp.msgty = 'E';
                    returnDataMsgTmp.msgtx = dnr.VGBEL+'_'+dnr.VGPOS+'不存在！';
                    out.ReturnDataList.add(returnDataMsgTmp);
                    isPartSuccess = true;
                    
                    continue;
                }
                
                if (orMap.containsKey(dnr.VGBEL)) {
                    dn.Order__c = orMap.get(dnr.VGBEL).Id;
                }else{
                    returnDataMsgTmp = new SAPOrderWebService.ReturnData();
                    returnDataMsgTmp.vbeln = rdni.VBELN;
                    returnDataMsgTmp.posnr = dnr.POSNR;
                    returnDataMsgTmp.msgty = 'E';
                    returnDataMsgTmp.msgtx = dnr.VGBEL+'不存在！';
                    out.ReturnDataList.add(returnDataMsgTmp);
                    isPartSuccess = true;
                    
                    continue;
                }
                if(dn.Delivery_Quantity__c==null) {
                    returnDataMsgTmp = new SAPOrderWebService.ReturnData();
                    returnDataMsgTmp.vbeln = rdni.VBELN;
                    returnDataMsgTmp.posnr = dnr.POSNR;
                    returnDataMsgTmp.msgty = 'E';
                    returnDataMsgTmp.msgtx = rdni.VBELN+'_'+dnr.POSNR+'没有传数量';
                    out.ReturnDataList.add(returnDataMsgTmp);
                    isPartSuccess = true;
                    
                    continue;
                }
                
                if (oiMap.containsKey(dnr.VGBEL+'_'+dnr.VGPOS) && oiMap.get(dnr.VGBEL+'_'+dnr.VGPOS).Price__c != null) {
                    dn.Delivery_Amount__c = dn.Delivery_Quantity__c*oiMap.get(dnr.VGBEL+'_'+dnr.VGPOS).Price__c;
                }
                deliveryNoteList.add(dn);
                dn.Material_Code__c = dnr.MATNR;//物料编码
                dn.Description__c = dnr.ARKTX; //物料描述
                deliveryNoteMap.put(deliveryNoteIndex,dn);
                deliveryNoteIndex++;
                if (String.isNotBlank(dnr.ZDELIVERY_COST)) {
                    dn.Delivery_Cost__c = Decimal.valueOf(dnr.ZDELIVERY_COST);//发货成本
                }
                
                flag = true;
            }
            if (flag) {
                DeliveryNumber__c dnPa = new DeliveryNumber__c();
                dnPa.Delivery_Note_Num__c = rdni.VBELN;
                dnPa.Delivery_Category__c = rdni.LFART;
                dnPa.Creator_Delivery__c = rdni.ERNAM;
                dnPa.Creator_Delivery_Date__c = Date.valueOf(rdni.ERDAT);
                dnPa.Creator_Delivery_Time__c = rdni.ERZET;
                dnPa.Delivery_Post_Date__c = Date.valueOf(rdni.wadat_ist);
                dnPa.Delivery_Post_Status__c = rdni.WBSTK;
                dnPa.POD_Status__c = rdni.PDSTK;
                dnPa.External_Id__c = rdni.VBELN;
                dnPa.Order__c = orMap.get(orderCode).Id;
                dnPaInserList.add(dnPa);
            }
            
        }
        
        // if (deliveryNoteList.size() > 0) {
            // Database.upsert(deliveryNoteList,Delivery_Note__c.fields.External_Id__c, true);
        // }
        SAPOrderWebService.ReturnData returnDataMsg;
        String errorStr = '';
        String code = '';
        Integer index = 0;
        Integer resultIndex = 0;
        if (dnPaInserList.size() > 0) {
            Database.upsert(dnPaInserList,DeliveryNumber__c.fields.External_Id__c);
        }
        if (deliveryNoteMap.size() > 0) {
            resultIndex = 0;
            List<Database.UpsertResult> resultList = Database.upsert(deliveryNoteMap.values(),Delivery_Note__c.fields.External_Id__c, false);
            for(Integer i=0;i<resultList.size();i++) {
                Database.UpsertResult result = resultList[resultIndex];
                returnDataMsg = new SAPOrderWebService.ReturnData();
                errorStr = '';
                code = '';
                index = 0;
                if(!result.isSuccess()) {
                    for(Database.Error errorStrItem : result.getErrors()) {
                        errorStr = errorStr + errorStrItem.getMessage();
                    }
                    code = deliveryNoteMap.get(resultIndex).External_Id__c;
                    index = code.indexOf('_');
                    returnDataMsg.vbeln = code.substring(0,index);
                    returnDataMsg.posnr = code.substring(index + 1);
                    returnDataMsg.msgty = 'E';
                    returnDataMsg.msgtx = errorStr;
                    out.ReturnDataList.add(returnDataMsg);
                    isPartSuccess = true;
                } else {
                    code = deliveryNoteMap.get(resultIndex).External_Id__c;
                    index = code.indexOf('_');
                    returnDataMsg.vbeln = code.substring(0,index);
                    returnDataMsg.posnr = code.substring(index + 1);
                    returnDataMsg.msgty = 'S';
                    returnDataMsg.msgtx = 'The data is successfully written!';
                    out.ReturnDataList.add(returnDataMsg);
                }
                resultIndex++;
            }
        }
        out.isSuccess = true;
        out.isPartSuccess = isPartSuccess;
        return out;
    }
}