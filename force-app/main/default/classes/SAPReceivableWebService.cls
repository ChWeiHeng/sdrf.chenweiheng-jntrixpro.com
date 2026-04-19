/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-31-2026
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   03-31-2026   Gerry   Initial Version
**/
@RestResource(urlMapping='/SAPReceivableWebService')
global without sharing class SAPReceivableWebService {
    public class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqOrderInfo> resultinfo;
    }
    public class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
    }
    public class ReqOrderInfo{
        public String KUNNR; //客户编码
        public String BUKRS; //公司代码
        public String GJAHR; //会计年度
        public String BELNR; //会计凭证
        public String BUZEI; //凭证行号
        public String H_BLART; //凭证类型
        public String H_WAERS; //凭证货币
        public String RFCCUR; //本位币
        public String KURSF; //汇率
        public String H_BUDAT; //过账日期
        public String SHKZG; //借贷方
        public String WRBTR; //凭证货币金额
        public String DMBTR; //本位币金额
        public String ZFBDT; //付款基准日期
        public String ZTERM; //付款条件
        public String NETDT; //到期日期
        public String ZYQTS; //逾期天数
        public String ZUONR; //发票号
        public String PRCTR; //利润中心
        public String HKONT; //会计科目
        public String VBELV; //销售订单
        public String AUART; //销售订单类型
        public String VKORG; //销售组织
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
        public String bukrs;//公司代码
        public String gjahr;//会计年度
        public String belnr;//会计凭证
        public String buzei;//凭证行号
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
    public class Output {
        public String error;
        public Boolean isSuccess;
        public Boolean isPartSuccess;
        public List<ReturnData> ReturnDataList;
    }
    /**
     * SAP 应收账款同步接口
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
        Boolean isSuccess = true;
        Boolean isPartSuccess = false;
        Savepoint sp = Database.setSavepoint();
        String errorMsg;
        List<ReturnData> returnDataList = new List<ReturnData>();
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
            errorMsg = InterfaceUtility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
            isSuccess = false;
            isPartSuccess = false;
        }
        ResponseBody response = returnData(respTime, isSuccess, errorMsg, returnDataList);
        InterfaceUtility.insertInterfaceLog('SAPReceivableWebService', 'SAP', 'CRM',
        '/services/apexrest/receiveD ataFromExternal/  requestCode:SAP001', bodyStrJson, isSuccess, isPartSuccess,
        JSON.serialize(response), errorMsg, 'POST', dataIdList, 'Upsert', 'SAP同步应收账款至CRM'
            );
        return response;
    }
    public static Output feedbackOrderInfo(List<ReqOrderInfo> resultinfo) { //返回
        List<Account_Receivable__C> AccountReceivableList = new List<Account_Receivable__C>();
        Map<Integer,Account_Receivable__C> AccountReceivableMap = new Map<Integer,Account_Receivable__C>();
        Output out = new Output();
        out.ReturnDataList = new List<ReturnData>();
        ReturnData returnDataMsgTmp;
        Boolean isPartSuccess = false;
        Integer accountReceivableIndex = 0;
        Set<String> customerIdSet = new Set<String>();
        Map<String,String> customeMap = new Map<String,String>();
        Set<String> salesOrgSet = new Set<String>();
        Account_Receivable__C accountReceivableMapResult;
        ReturnData returnDataMsg;
        for (ReqOrderInfo reqOrder : resultinfo) {
            customerIdSet.add(reqOrder.KUNNR);
            salesOrgSet.add(reqOrder.BUKRS);
        }
        List<Account> accList = [
            SELECT          
                ID,MDG_Customer_Code__c
                FROM Account
            WHERE  MDG_Customer_Code__c IN: customerIdSet];
        if (accList.size()>0) {
            for(Account acc : accList){
                customeMap.put(acc.MDG_Customer_Code__c,acc.Id);
            }
        }
        Map<String,String> salesInfoMap = new Map<String,String>();
        Map<String,Customer_Sales_Info__c> csiMap = new Map<String,Customer_Sales_Info__c>();
        for (Customer_Sales_Info__c csi : [
                                            SELECT 
                                                Id ,
                                                Customer__r.MDG_Customer_Code__c,
                                                Sales_Org__c,
                                                OwnerId,Owner.IsActive
                                            FROM 
                                                Customer_Sales_Info__c 
                                            WHERE 
                                                Customer__r.MDG_Customer_Code__c IN:customerIdSet AND
                                                Sales_Org__c IN:salesOrgSet
        ]) {
            salesInfoMap.put(csi.Customer__r.MDG_Customer_Code__c+'-'+csi.Sales_Org__c, csi.Id);
            csiMap.put(csi.Customer__r.MDG_Customer_Code__c+'-'+csi.Sales_Org__c,csi);
        }
        
        Set<String> invoiceSet = new Set<String>();
        for (ReqOrderInfo reqOrder : resultinfo) {
            
            If(String.isNotBlank(reqOrder.ZUONR)) {
                invoiceSet.add(reqOrder.ZUONR);
            }
        }
        
        Map<String,String> invoiceMap = new Map<String,String>();
        for(Invoice__c invoice : [SELECT Id,OwnerId,External_Id__c FROM Invoice__c WHERE External_Id__c IN:invoiceSet AND Owner.IsActive =true]) {
            invoiceMap.put(invoice.External_Id__c,invoice.OwnerId);
        }
        
        for (ReqOrderInfo reqOrder : resultinfo) {
            Account_Receivable__C AccountReceivable = new Account_Receivable__C();
            if (customeMap.size()>0 && customeMap.containsKey(reqOrder.KUNNR)) {
                AccountReceivable.Customer__c = customeMap.get(reqOrder.KUNNR);
            }
            AccountReceivable.Company_Code__C = reqOrder.BUKRS;  //公司代码
            AccountReceivable.Fiscal_Year__C = reqOrder.GJAHR; //会计年度
            AccountReceivable.Document_Number__C = reqOrder.BELNR; //会计凭证
            AccountReceivable.Posting_Item__C = reqOrder.BUZEI; //凭证行号
            AccountReceivable.Document_Type__C = reqOrder.H_BLART; //凭证类型
            AccountReceivable.Document_Currency__C = reqOrder.H_WAERS; //凭证货币
            AccountReceivable.Local_Currency__C = reqOrder.RFCCUR; //本位币
            if (reqOrder.kursf!=null) {
                AccountReceivable.Exchange_Rate__C = String.isBlank(reqOrder.KURSF) ? 0 : Decimal.valueOf(reqOrder.KURSF); //汇率
            }else{
                AccountReceivable.Exchange_Rate__C = null; //汇率
            }
            AccountReceivable.Posting_Date__C = Date.valueOf(reqOrder.H_BUDAT); //过账日期
            AccountReceivable.Debit_Credit__C = reqOrder.SHKZG; //借贷方
            AccountReceivable.Amount_in_Trans_Crcy__C = String.isBlank(reqOrder.WRBTR) ? 0 : Decimal.valueOf(reqOrder.WRBTR); //凭证货币金额
            AccountReceivable.Amount_in_Local_Crcy__C =  String.isBlank(reqOrder.DMBTR) ? 0 : Decimal.valueOf(reqOrder.DMBTR); //本位币金额 这里必须要，得把原有单子修改成0
            if(String.isBlank(reqOrder.ZFBDT)) {
                returnDataMsgTmp = new ReturnData();
                returnDataMsgTmp.bukrs = reqOrder.bukrs;//公司代码
                returnDataMsgTmp.gjahr = reqOrder.gjahr;//会计年度
                returnDataMsgTmp.belnr = reqOrder.belnr;//会计凭证
                returnDataMsgTmp.buzei = reqOrder.buzei;//凭证行号
                returnDataMsgTmp.msgty = 'E';
                returnDataMsgTmp.msgtx = '凭证号：'+reqOrder.BELNR+'付款基准日期没有传！';
                out.ReturnDataList.add(returnDataMsgTmp);
                isPartSuccess = true;
                continue;
            }
            AccountReceivable.Baseline_Date__C = Date.valueOf(reqOrder.ZFBDT); //付款基准日期
            AccountReceivable.Payment_Terms__c = reqOrder.ZTERM; //付款条件
            AccountReceivable.Due_On__C = Date.valueOf(reqOrder.NETDT); //到期日期
            AccountReceivable.Overdue_Days__C = String.isBlank(reqOrder.ZYQTS) ? 0 : Decimal.valueOf(reqOrder.ZYQTS.trim()); //逾期天数
            AccountReceivable.Invoice_Number__C = reqOrder.ZUONR; //发票号
            If(String.isNotBlank(reqOrder.ZUONR)) {
                Invoice__c inv = new Invoice__c();
                inv.External_Id__c = reqOrder.ZUONR;
                AccountReceivable.Invoice__r = inv;
                if(invoiceMap.get(reqOrder.ZUONR)!=null) {
                    AccountReceivable.OwnerId = invoiceMap.get(reqOrder.ZUONR);
                }
                
            }
            if(AccountReceivable.OwnerId==null) {
                Customer_Sales_Info__c csi = csiMap.get(reqOrder.KUNNR+'-'+reqOrder.BUKRS);
                if(csi!=null && csi.Owner.IsActive) {
                    AccountReceivable.OwnerId = csi.OwnerId;
                }
            }
            AccountReceivable.Profit_Center__C = reqOrder.PRCTR; //利润中心
            AccountReceivable.Account_Number__C = reqOrder.HKONT; //会计科目
            AccountReceivable.Sales_Order_Number__C = reqOrder.VBELV; //销售订单
            AccountReceivable.Sales_Order_Type__C = reqOrder.AUART; //销售订单类型
            AccountReceivable.Sales_Org__c = reqOrder.VKORG; //销售组织
            AccountReceivable.ExternalId__c = reqOrder.KUNNR + reqOrder.BUKRS + reqOrder.GJAHR + reqOrder.BELNR + reqOrder.BUZEI;
            
            // if(salesInfoMap.containskey(reqOrder.KUNNR+'-'+reqOrder.BUKRS)){
                AccountReceivable.Customer_Sales_Info__c = salesInfoMap.get(reqOrder.KUNNR+'-'+reqOrder.BUKRS);
            // }else{
                //     throw new CustomException(reqOrder.KUNNR+'-'+reqOrder.BUKRS+'不存在！');
            // }
            
            // AccountReceivableList.add(AccountReceivable);
            AccountReceivableMap.put(accountReceivableIndex,AccountReceivable);
            accountReceivableIndex++;
        }
        String errorStr = '';
        Integer resultIndex = 0;
        if (AccountReceivableMap.size() > 0) {
            List<Database.UpsertResult> resultList = Database.upsert(AccountReceivableMap.values(),Account_Receivable__C.fields.ExternalId__c, false);
            // Database.upsert(AccountReceivableList,Account_Receivable__C.fields.ExternalId__c, true);
            for(Integer i=0;i<resultList.size();i++) {
                Database.UpsertResult result = resultList[resultIndex];
                returnDataMsg = new ReturnData();
                errorStr = '';
                accountReceivableMapResult = new Account_Receivable__C();
                accountReceivableMapResult = AccountReceivableMap.get(resultIndex);
                if(!result.isSuccess()) {
                    for(Database.Error errorStrItem : result.getErrors()) {
                        errorStr = errorStr + errorStrItem.getMessage();
                    }
                    returnDataMsg.bukrs = accountReceivableMapResult.Company_Code__C;//公司代码
                    returnDataMsg.gjahr = accountReceivableMapResult.Fiscal_Year__C;//会计年度
                    returnDataMsg.belnr = accountReceivableMapResult.Document_Number__C;//会计凭证
                    returnDataMsg.buzei = accountReceivableMapResult.Posting_Item__C;//凭证行号
                    returnDataMsg.msgty = 'E';
                    returnDataMsg.msgtx = errorStr;
                    out.ReturnDataList.add(returnDataMsg);
                    isPartSuccess = true;
                } else {
                    returnDataMsg.bukrs = accountReceivableMapResult.Company_Code__C;//公司代码
                    returnDataMsg.gjahr = accountReceivableMapResult.Fiscal_Year__C;//会计年度
                    returnDataMsg.belnr = accountReceivableMapResult.Document_Number__C;//会计凭证
                    returnDataMsg.buzei = accountReceivableMapResult.Posting_Item__C;//凭证行号
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
}