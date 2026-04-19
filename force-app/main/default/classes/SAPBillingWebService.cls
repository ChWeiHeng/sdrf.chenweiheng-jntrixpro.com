/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 04-02-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-02-2026   Gerry   Initial Version
**/
@RestResource(urlMapping='/SAPBillingWebService')
global without sharing class SAPBillingWebService {
    global class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqBillingInfo> resultinfo;
    }
    
    global class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
    }
    
    global class ReqBillingInfo{
        public String VBELN;//销售发票号
        public String FKART;//开票类型
        public String RFBSK;//开票状态
        public String BELNR;//会计凭证号
        public String ERDAT;//开票日期
        public String ERZET;//开票时间
        public String ERNAM;//开票人
        public String WAERK;//币种
        public String WRBTR;//回款交易币金额
        public String WAERK1;//回款交易币币种
        public String DMBTR;//回款本位币金额
        public String RFCCUR;//回款本位币币种
        public String SFAKN; //冲销发票号
        public String docnum; //点票号
        public String NETDT;//到期日期
        public List<BillingRow> ITEMS;
    }
    
    
    global class BillingRow{
        public String POSNR;//销售发票行号
        public Decimal FKIMG;//发票数量
        public Decimal AMOUNT;//含税合计
        public Decimal NETWR;//净值合计
        public Decimal MWSBP;//税额合计
        public Decimal AMOUNT_CONV;
        public Decimal NETWR_CONV;
        public Decimal MWSBP_CONV;
        public String AUBEL;//参考订单号
        public String AUPOS;//参考订单行号
        public String VGBEL;//参考交货单
        public String VGPOS;//参考交货单行号
        public String MATNR;//物料编码
        public String ARKTX; //物料描述
        
    }
    
    /**
     * SAP开票信息同步接口
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
        Boolean isPartSuccess = true;
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
            isSuccess = false;
        }
        SAPOrderWebService.ResponseBody response = SAPOrderWebService.returnData(respTime, isSuccess, errorMsg, returnDataList);
        InterfaceUtility.insertInterfaceLog('SAPBillingWebService', 'SAP', 'CRM',
        '/services/apexrest/receiveDataFromExternal/  requestCode:SAP003', bodyStrJson, isSuccess, isPartSuccess,
        JSON.serialize(response), errorMsg, 'POST', dataIdList, 'Upsert', 'SAP同步发票至CRM'
            );
        
        return response;
    }
    
    public static SAPOrderWebService.Output feedbackOrderInfo(List<ReqBillingInfo> resultinfo) {
        List<Billing__c> billList = new List<Billing__c>();
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Integer,Billing__c> billListMap = new Map<Integer,Billing__c>();
        Map<Integer,List<Billing__c>> billListMapColl = new Map<Integer,List<Billing__c>>();
        Map<Integer,Billing__c> billListMapFina = new Map<Integer,Billing__c>();
        Map<Integer,Invoice__c> invoiceListMap = new Map<Integer,Invoice__c>();
        Boolean isPartSuccess = false;
        Set<String> orderItemSet = new Set<String>();
        Set<String> deliverySet = new Set<String>();
        Set<String> orderSet = new Set<String>();
        Set<String> billExSet = new Set<String>();
        for(ReqBillingInfo rbi : resultinfo){
            for (BillingRow br : rbi.ITEMS) {
                orderItemSet.add(br.AUBEL+'_'+br.AUPOS);
                deliverySet.add(br.VGBEL+'_'+br.VGPOS);
                orderSet.add(br.AUBEL);
                billExSet.add(rbi.VBELN+br.POSNR);
            }
        }
        //已经被取消的单子
        Map<String,Billing__c> billMap = new Map<String,Billing__c>();
        for (Billing__c bill : [SELECT Id,External_Id__c FROM Billing__c WHERE External_Id__c IN:billExSet AND Billing_Status__c='E']) {
            billMap.put(bill.External_Id__c,bill);
        }
        List<Order_Item__c> oiList = [SELECT Id,External_Id__c,External_Id2__c 
                                        FROM Order_Item__c 
                                        WHERE External_Id__c IN: orderItemSet OR External_Id2__c IN: orderItemSet];
        Map<String,String> oiMap = new Map<String,String>();
        if (oiList.size()>0) {
            for(Order_Item__c o : oiList){
                oiMap.put(o.External_Id__c,o.Id);
                if (o.External_Id2__c!=null) {
                    oiMap.put(o.External_Id2__c,o.Id);
                }
            }
        }
        
        Map<String,Order__c> orMap = new Map<String,Order__c>();
        for (Order__c order : [SELECT Owner.IsActive,OwnerId,Id,SAP_Order_Code__c,SAP_Order_Code2__c,Sales_Org__c FROM Order__c WHERE SAP_Order_Code__c IN:orderSet OR SAP_Order_Code2__c IN:orderSet]) {
            orMap.put(order.SAP_Order_Code__c, order);
            if (order.SAP_Order_Code2__c!=null) {
                orMap.put(order.SAP_Order_Code2__c, order);
            }
        }
        
        List<Delivery_Note__c> dnList = [SELECT Id,External_Id__c 
                                        FROM Delivery_Note__c 
                                        WHERE External_Id__c IN: deliverySet];
        Map<String,String> dnMap = new Map<String,String>();
        if (oiList.size()>0) {
            for(Delivery_Note__c dn : dnList){
                dnMap.put(dn.External_Id__c,dn.Id);
            }
        }
        
        Set<String> cancelBillSet = new Set<String>();
        
        for(ReqBillingInfo rbi : resultinfo){
            cancelBillSet.add(rbi.SFAKN);
        }
        
        SAPOrderWebService.Output out = new SAPOrderWebService.Output();
        out.ReturnDataList = new List<SAPOrderWebService.ReturnData>();
        SAPOrderWebService.ReturnData returnDataMsgTmp;
        
        Map<String,String> cancelBillMap = new Map<String,String>();
        List<Billing__c> reverseBillList = [SELECT Id,Billing_Num__c FROM Billing__c WHERE Billing_Num__c IN: cancelBillSet];
        for(Billing__c bi : reverseBillList){
            cancelBillMap.put(bi.Billing_Num__c,bi.Id);
        }
        Integer billIndex = 0;
        Integer invoiceIndex = 0;
        for(ReqBillingInfo rbi : resultinfo){
            List<Billing__c> billListTmp = new List<Billing__c>();
            Boolean flag = false;
            String AUBEL;
            for (BillingRow br : rbi.ITEMS) {
                AUBEL = br.AUBEL;
                Billing__c bill = new Billing__c();
                //头部分
                bill.Billing_Num__c = rbi.VBELN;
                bill.Billing_Type__c = rbi.FKART;
                if (billMap.get(rbi.VBELN+br.POSNR)!=null) {//如果是已经取消的发票则
                    bill.Billing_Status__c = 'E';
                    flag = true;
                }else{
                    bill.Billing_Status__c = rbi.RFBSK;
                }
                //到期日期
                bill.FECHA_DE_VENCIMIENTO__c = Date.valueOf(rbi.NETDT);
                
                bill.Accounting_Document_Number__c = rbi.BELNR;
                bill.Invoice_Date__c = Date.valueOf(rbi.ERDAT);
                bill.Invoice_Time__c = rbi.ERZET;
                bill.Drawer__c = rbi.ERNAM;
                bill.Currency__c = rbi.WAERK;
                if (String.isNotBlank(rbi.WRBTR)) {
                    bill.Collection_Transaction_Amount__c = Decimal.valueOf(rbi.WRBTR);
                }else{
                    bill.Collection_Transaction_Amount__c = null;
                }
                
                bill.Collection_Transaction_Currency__c  = rbi.WAERK1;
                bill.Collection_Base_Amount__c = rbi.DMBTR;
                bill.Collection_Base_Currency__c = rbi.RFCCUR;
                //ITEMS部分
                bill.Billing_Item_Num__c = br.POSNR;
                bill.Invoice_Quantity__c = br.FKIMG;
                bill.SAP_Total_Amount__c = br.AMOUNT;
                bill.SAP_Total_Tax__c = br.MWSBP;
                bill.SAP_Total_Net__c = br.NETWR;
                bill.Reference_Order__c = br.AUBEL;
                bill.Reference_Order_Item__c = br.AUPOS;
                bill.Reference_Delivery_Num__c = br.VGBEL;
                bill.Reference_Delivery_Item_Num__c = br.VGPOS;
                bill.Delivery_Note__c = dnMap.get(br.VGBEL+'_'+br.VGPOS);
                bill.Order_Item__c = oiMap.get(br.AUBEL+'_'+br.AUPOS);
                if (orMap.containsKey(br.AUBEL)) {
                    bill.Order__c = orMap.get(br.AUBEL).Id;
                }else{
                    returnDataMsgTmp = new SAPOrderWebService.ReturnData();
                    returnDataMsgTmp.vbeln = rbi.VBELN;
                    returnDataMsgTmp.posnr = br.POSNR;
                    returnDataMsgTmp.msgty = 'E';
                    returnDataMsgTmp.msgtx = br.AUBEL+'不存在！';
                    out.ReturnDataList.add(returnDataMsgTmp);
                    isPartSuccess = true;
                    continue;
                }
                
                bill.External_Id__c = rbi.VBELN+br.POSNR;
                bill.Material_Code__c = br.MATNR;//物料编码
                bill.Description__c = br.ARKTX; //物料描述
                // bill.OwnerId = orMap.get(br.AUBEL).OwnerId;
                bill.SAP_Total_Amount_USD__c = br.AMOUNT_CONV;
                bill.SAP_Total_Net_UDS__c = br.NETWR_CONV;
                bill.SAP_Total_Tax_USD__c = br.MWSBP_CONV;
                if (String.isNotBlank(rbi.SFAKN)) {
                    // Billing__c billRela = new Billing__c();
                    // billRela.External_Id__c = rbi.SFAKN+br.POSNR;
                    bill.Reverse_Billing__c = cancelBillMap.get(rbi.SFAKN);
                    bill.Reverse_Invoice_Number__c = rbi.SFAKN;
                    bill.Billing_Status__c = 'E';
                    flag = true;
                }
                Invoice__c inv = new Invoice__c();
                inv.External_Id__c = rbi.VBELN;
                bill.Invoice__r = inv;
                billList.add(bill);
                billListTmp.add(bill);
                billListMap.put(billIndex,bill);
                billIndex++;
            }
            if (!orMap.containsKey(AUBEL)) {
                continue;
            }
            Invoice__c inv = new Invoice__c();
            inv.Order__c = orMap.get(AUBEL).Id;
            inv.Sales_Org__c = orMap.get(AUBEL).Sales_Org__c;	//2024/11.05 增加sales org赋值
            if(orMap.get(AUBEL).Owner.IsActive) {
                inv.OwnerId = orMap.get(AUBEL).OwnerId;
            }
            
            inv.External_Id__c = rbi.VBELN;
            inv.Name = rbi.VBELN;
            inv.Ticket_Number__c =  rbi.docnum;
            inv.Invoice_Type__c = rbi.FKART;
            inv.Invoice_Status__c = rbi.RFBSK;
            if (flag) {
                inv.Invoice_Status__c = 'E';
            }
            inv.Accounting_Document_Number__c = rbi.BELNR;
            inv.Invoice_Date__c = Date.valueOf(rbi.ERDAT);
            inv.Invoice_Time__c = rbi.ERZET;
            inv.Drawer__c = rbi.ERNAM;
            inv.Transaction_Currency__c = rbi.WAERK;
            if (String.isNotBlank(rbi.WRBTR)) {
                inv.Collection_Transaction_Amount__c = Decimal.valueOf(rbi.WRBTR);
            }else{
                inv.Collection_Transaction_Amount__c = null;
            }
            
            inv.Collection_Transaction_Currency__c  = rbi.WAERK1;
            if (String.isNotBlank(rbi.DMBTR)) {
                inv.Collection_Base_Amount__c = Decimal.valueOf(rbi.DMBTR);
            }
            
            inv.Collection_Base_Currency__c = rbi.RFCCUR;
            invoiceList.add(inv);
            invoiceListMap.put(invoiceIndex,inv);
            billListMapColl.put(invoiceIndex,billListTmp);
            invoiceIndex++;
        }
        
        
        // if (invoiceList.size() >0) {
            //     Database.upsert(invoiceList,Invoice__c.fields.External_Id__c, true);
        // }
        String errorStr = '';
        String code = '';
        Integer index = 0;
        Integer resultIndex = 0;
        SAPOrderWebService.ReturnData returnDataMsg;
        if (invoiceListMap.size() > 0) {
            resultIndex = 0;
            List<Database.UpsertResult> resultListHead = Database.upsert(invoiceListMap.values(),Invoice__c.fields.External_Id__c, false);
            for(Integer i=0;i<resultListHead.size();i++) {
                Database.UpsertResult resultHead = resultListHead[resultIndex];
                if(!resultHead.isSuccess()) {
                    errorStr = '';
                    for(Database.Error errorStrItem : resultHead.getErrors()) {
                        errorStr = errorStr + errorStrItem.getMessage();
                    }
                    for (Billing__c billTmp : billListMapColl.get(resultIndex)) {
                        returnDataMsg = new SAPOrderWebService.ReturnData();
                        returnDataMsg.vbeln = billTmp.Billing_Num__c;
                        returnDataMsg.posnr = billTmp.Billing_Item_Num__c;
                        returnDataMsg.msgty = 'E';
                        returnDataMsg.msgtx = errorStr;
                        out.ReturnDataList.add(returnDataMsg);
                    }
                    billListMapColl.remove(resultIndex);
                    isPartSuccess = true;
                }
                resultIndex++;
            }
        }
        
        // if (billList.size() > 0) {
            //     Database.upsert(billList,Billing__c.fields.External_Id__c, true);
        // }
        Integer billTmpFinaIndex = 0;
        if (billListMapColl.size() > 0) {
            for(Integer key : billListMapColl.keySet()) {
                List<Billing__c> billingTmp = billListMapColl.get(key);
                for (Billing__c billTmp : billingTmp) {
                    billListMapFina.put(billTmpFinaIndex,billTmp);
                    billTmpFinaIndex++;
                }
            }
            // for (List<Billing__c> billingTmp : billListMapColl) {
                //     for (Billing__c billTmp : billingTmp) {
                    //         billListMapFina.put(billTmpFinaIndex,billTmp);
                    //         billTmpFinaIndex++;
                //     }
            // }
        }
        Integer resultDetailIndex = 0;
        if (billListMapFina.size() > 0) {
            List<Database.UpsertResult> resultListItem = Database.upsert(billListMapFina.values(),Billing__c.fields.External_Id__c, false);
            resultDetailIndex = 0;
            for(Integer i=0;i<resultListItem.size();i++) {
                Database.UpsertResult resultItem = resultListItem[resultDetailIndex];
                errorStr = '';
                code = '';
                index = 0;
                if(!resultItem.isSuccess()) {
                    for(Database.Error errorStrItem : resultItem.getErrors()) {
                        errorStr = errorStr + errorStrItem.getMessage();
                    }
                    // code = billListMapFina.get(resultDetailIndex).External_Id__c;
                    // index = code.indexOf('_');
                    returnDataMsg = new SAPOrderWebService.ReturnData();
                    returnDataMsg.vbeln = billListMapFina.get(resultDetailIndex).Billing_Num__c;
                    returnDataMsg.posnr = billListMapFina.get(resultDetailIndex).Billing_Item_Num__c;
                    returnDataMsg.msgty = 'E';
                    returnDataMsg.msgtx = errorStr;
                    out.ReturnDataList.add(returnDataMsg);
                    isPartSuccess = true;
                } else {
                    // code = billListMapFina.get(resultDetailIndex).External_Id__c;
                    // index = code.indexOf('_');
                    returnDataMsg = new SAPOrderWebService.ReturnData();
                    returnDataMsg.vbeln = billListMapFina.get(resultDetailIndex).Billing_Num__c;
                    returnDataMsg.posnr = billListMapFina.get(resultDetailIndex).Billing_Item_Num__c;
                    returnDataMsg.msgty = 'S';
                    returnDataMsg.msgtx = 'The data is successfully written!';
                    out.ReturnDataList.add(returnDataMsg);
                }
                resultDetailIndex++;
            }
        }
        out.isSuccess = true;
        out.isPartSuccess = isPartSuccess;
        
        if (cancelBillSet.size()>0) {
            List<Billing__c> cancelBillList = [SELECT Id,Billing_Num__c,Invoice__c FROM Billing__c WHERE Billing_Num__c IN: cancelBillSet];
            List<Billing__c> upCancelBillList = new List<Billing__c>();
            Map<String,Invoice__c> inMap = new Map<String,Invoice__c>();
            Map<String,String> relationMap = new Map<String,String>();
            for(Billing__c bi : cancelBillList){
                relationMap.put(bi.Billing_Num__c,bi.Id);
                Billing__c upBill = new Billing__c();
                upBill.Id = bi.Id;
                upBill.Billing_Status__c = 'E';
                upCancelBillList.add(upBill);
                if (!inMap.containsKey(bi.Invoice__c)) {
                    Invoice__c inv = new Invoice__c();
                    inv.Id = bi.Invoice__c;
                    inv.Invoice_Status__c = 'E';
                    inMap.put(bi.Invoice__c,inv);
                }
            }
            if (inMap.size()>0) {
                update inMap.values();
            }
            if (upCancelBillList.size()>0) {
                update upCancelBillList;
            }
            List<Billing__c> billNeedUpdate = new List<Billing__c>();
            for(Billing__c bill : billList) {
                if(bill.Reverse_Invoice_Number__c!=null && bill.Reverse_Billing__c==null) {
                    bill.Reverse_Billing__c = relationMap.get(bill.Reverse_Invoice_Number__c);
                    billNeedUpdate.add(bill);
                }
            }
            if(billNeedUpdate.size()>0) {
                update billNeedUpdate;
            }
        }
        
        return out;
        
    }
}