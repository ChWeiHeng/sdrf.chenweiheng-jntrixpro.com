@RestResource(urlMapping='/MainBusinessIncomeWebService')
global without sharing class MainBusinessIncomeWebService {
    public class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqMainBusinessIncomeInfo> resultinfo;
    }
    
    public class ReqESInfo {
        public String instid; // 接口编号
        public String requesttime; // 请求时间
        public String attr1;//发送方系统
        public String attr2;//接收方系统
    }
    
    public class ReqMainBusinessIncomeInfo {
        public String bukrs; //公司代码
        public String gjahr; //年度
        public String belnr; //凭证号
        public String h_budat; //过账日期
        public String h_blart; //凭证类型
        public String buzet; //过账时间
        public String xblnr; //凭证参考
        public String bktxt; //抬头文本
        public String xreversed; //冲销状态
        public String stblg; //冲销凭证
        public String stjah; //冲销年度
        public String buzei;//SAP 凭证行号
        public String hkont;//科目
        public String sgtxt;//行文本
        public String shkzg;//借贷标识
        public String h_waers;//凭证货币
        public String wrbtr;//凭证货币金额
        public String rfccur;//本位货币
        public String dmbtr;//本位币金额
        public String matnr;//物料号
        public String kunnr;//客户
        public String zuonr;//发票号
        public String awitem;//发票行号
        public String prctr;//利润中旬
        public String kursf;//美元汇率
        public String usdsl;//美元金额
        public HeadInclude include;
    }
    
    public class HeadInclude{
        public String hex01;//备用字段
        public String hex02;//备用字段
        public String hex03;//备用字段
        public String hex04;//备用字段
        public String hex05;//备用字段
        public String hex06;//备用字段
    }
    
    
    /**
     * SAP 主营业务收入接口同步
     * @param bodyStrJson bodyStrJson
     *
     * @return ResponseBody
     */
    @HttpPost
    global static SAPReceivableWebService.ResponseBody doPost() {
        String respTime = String.valueOf(Datetime.now());
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String bodyStrJson = req.requestBody.toString();
        System.debug('Received body: ' + bodyStrJson);
        List<String> dataIdList = new List<String>();
        Boolean isSuccess = true;
        Boolean isPartSuccess = false;
        List<SAPReceivableWebService.ReturnData> returnDataList = new List<SAPReceivableWebService.ReturnData>();
        Savepoint sp = Database.setSavepoint();
        String errorMsg;
        try {
            System.debug('bodyStrJson1==' + bodyStrJson);
            RequestBody reqBody = (RequestBody) JSON.deserialize(bodyStrJson, RequestBody.class);
            SAPReceivableWebService.Output out = feedbackMainBusinessIncomeInfo(reqBody.resultinfo);
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
        SAPReceivableWebService.ResponseBody response = SAPReceivableWebService.returnData(respTime, isSuccess, errorMsg, returnDataList);
        InterfaceUtility.insertInterfaceLog('MainBusinessIncomeWebService', 'SAP', 'CRM',
        '/services/apexrest/collectionDetailsFromExternal/  requestCode:SAP001', bodyStrJson, isSuccess, isPartSuccess,
        JSON.serialize(response), errorMsg, 'POST', dataIdList, 'Upsert', 'SAP同步主营业务收入至CRM'
            );
        return response;
    }
    public static SAPReceivableWebService.Output feedbackMainBusinessIncomeInfo(List<ReqMainBusinessIncomeInfo> resultinfoList) {
        Map<String, Main_Business_Income__c> upMainBusinessIncomeMap = new Map<String, Main_Business_Income__c>();
        List<Main_Business_Income_Detail__c> mainBusinessIncomeDetailsList = new List<Main_Business_Income_Detail__c>();
        Map<Integer,Main_Business_Income__c> mainBusinessIncomeMap = new Map<Integer,Main_Business_Income__c>();
        Map<String,Main_Business_Income__c> mainBusinessIncomeMapAll = new Map<String,Main_Business_Income__c>();
        Map<String,List<Main_Business_Income_Detail__c>> mainBusinessIncomeMapColl = new Map<String,List<Main_Business_Income_Detail__c>>();
        Set<String> invoiceSet = new Set<String>();
        Main_Business_Income__c mainIncomeTmp;
        Integer mainBusinessIndex = 0;
        Boolean isPartSuccess = false;
        for (ReqMainBusinessIncomeInfo resultinfo : resultinfoList) {
            if(String.isnotBlank(resultinfo.zuonr)) {
                invoiceSet.add(resultinfo.zuonr);
            }
        }
        Map<String,Invoice__c> invoiceMap = new Map<String,Invoice__c>();
        for(Invoice__c inv : [SELECT Id,External_Id__c,OwnerId FROM Invoice__c WHERE External_Id__c IN:invoiceSet AND Owner.isactive=true]) {
            invoiceMap.put(inv.External_Id__c,inv);
        }
        for (ReqMainBusinessIncomeInfo resultinfo : resultinfoList) {
            Main_Business_Income__c upMainBusinessIncome = new Main_Business_Income__c();
            upMainBusinessIncome.Unique_Code__c = resultinfo.bukrs + resultinfo.gjahr + resultinfo.belnr ; //唯一标识
            upMainBusinessIncome.Annual__c = resultinfo.gjahr; //年度
            upMainBusinessIncome.Company_Code__c = resultinfo.bukrs; //公司代码
            upMainBusinessIncome.Header_Text__c = resultinfo.bktxt; //抬头文本
            upMainBusinessIncome.Post_Date__c = Date.valueOf( resultinfo.h_budat ); //过账日期
            upMainBusinessIncome.Voucher_Type__c = resultinfo.h_blart;//凭证类型
            upMainBusinessIncome.Post_Time__c = resultinfo.buzet; //过账时间
            upMainBusinessIncome.Reference__c = resultinfo.xblnr; //凭证参考
            upMainBusinessIncome.Voucher_Number__c = resultinfo.belnr; //凭证编号
            upMainBusinessIncome.Write_off_Status__c = resultinfo.xreversed; //冲销状态
            upMainBusinessIncome.Write_off_Voucher__c = resultinfo.stblg; //冲销凭证
            upMainBusinessIncome.Write_off_Annual__c = resultinfo.stjah;//冲销年度
            
            //数据owner赋值
            if(invoiceMap.get(resultinfo.zuonr)!=null) {
                upMainBusinessIncome.OwnerId = invoiceMap.get(resultinfo.zuonr).OwnerId;
            }
            upMainBusinessIncomeMap.put(upMainBusinessIncome.Unique_Code__c, upMainBusinessIncome);
            // for (resultinfo resultinfo : resultinfo.items) {
                Main_Business_Income_Detail__c collectionDetail = new Main_Business_Income_Detail__c();
                //CRM 行编码
                Main_Business_Income__c  mbi = new Main_Business_Income__c();
                mbi.Unique_Code__c = resultinfo.bukrs + resultinfo.gjahr + resultinfo.belnr ;
                collectionDetail.Main_Bussiness_Income__r = mbi;
                
                collectionDetail.Unique_Code__c = resultinfo.bukrs + resultinfo.gjahr + resultinfo.belnr + resultinfo.buzei; //唯一标识
                collectionDetail.Account_Number__c = resultinfo.hkont;//科目
                collectionDetail.Credit__c = resultinfo.shkzg;//借贷标识
                // collectionDetail.Customer__c = resultinfo.kunnr;//客户
                Account acc = new Account();
                acc.MDG_Customer_Code__c = resultinfo.kunnr;
                collectionDetail.Customer__r = acc; //最终客户
                collectionDetail.Functional_Currency__c = resultinfo.rfccur;//本币币种
                collectionDetail.Functional_Currency_Amount__c = Decimal.valueOf(resultinfo.dmbtr);//本币金额
                // collectionDetail.Invoice__c = resultinfo.zuonr;//发票号
                if(String.isnotBlank(resultinfo.zuonr)) {
                    Invoice__c inv = new Invoice__c();
                    inv.External_Id__c = resultinfo.zuonr;
                    collectionDetail.Invoice__r = inv;
                    
                    // collectionDetail.Invoice_Item__c = resultinfo.awitem;//发票行项目
                    Billing__c billing = new Billing__c();
                    billing.External_Id__c = resultinfo.zuonr + resultinfo.awitem;
                    collectionDetail.Invoice_Item__r = billing;
                }
                
                
                collectionDetail.Item_Text__c = resultinfo.sgtxt;//行文本
                collectionDetail.Original_Currency__c = resultinfo.h_waers;//原币币种
                collectionDetail.Original_Currency_Amount__c = Decimal.valueOf(resultinfo.wrbtr);//原币金额
                // collectionDetail.Product__c = resultinfo.matnr;//物料编码
                if(String.isnotBlank(resultinfo.matnr)) {
                    Product__c product = new Product__c();
                    product.External_Id__c = resultinfo.matnr;
                    collectionDetail.Product__r = product;
                }
                collectionDetail.Profit_Center__c = resultinfo.prctr;//利润中旬
                collectionDetail.USD_Amount__c = Decimal.valueOf(resultinfo.usdsl);//美元金额
                collectionDetail.USD_Exchange_Rate__c = Decimal.valueOf(resultinfo.kursf);//美元汇率
                collectionDetail.Voucher_Item_Number__c = resultinfo.buzei;//凭证行项目
                
                mainBusinessIncomeDetailsList.add(collectionDetail);
                
                if(mainBusinessIncomeMapColl.get(upMainBusinessIncome.Unique_Code__c)!=null) {
                    List<Main_Business_Income_Detail__c> list_tmp = mainBusinessIncomeMapColl.get(upMainBusinessIncome.Unique_Code__c);
                    list_tmp.add(collectionDetail);
                    mainBusinessIncomeMapColl.put(upMainBusinessIncome.Unique_Code__c,list_tmp);
                }else {
                    List<Main_Business_Income_Detail__c> list_new = new List<Main_Business_Income_Detail__c>();
                    list_new.add(collectionDetail);
                    mainBusinessIncomeMapColl.put(upMainBusinessIncome.Unique_Code__c,list_new);
                }
                // mainBusinessIncomeMap.put(mainBusinessIndex,upMainBusinessIncome);
                // mainBusinessIncomeMapAll.put(upMainBusinessIncome.Unique_Code__c,upMainBusinessIncome);
                if(!mainBusinessIncomeMapAll.containskey(upMainBusinessIncome.Unique_Code__c)) {
                    mainBusinessIncomeMap.put(mainBusinessIndex,upMainBusinessIncome);
                    mainBusinessIncomeMapAll.put(upMainBusinessIncome.Unique_Code__c,upMainBusinessIncome);
                    mainBusinessIndex++;
                }
                
            // }
            
        }
        // if (upMainBusinessIncomeMap.size() > 0 && !Test.isRunningTest()) {
            //     Database.upsert(upMainBusinessIncomeMap.values(), Main_Business_Income__c.Unique_Code__c, true);
        // }
        SAPReceivableWebService.Output out = new SAPReceivableWebService.Output();
        out.ReturnDataList = new List<SAPReceivableWebService.ReturnData>();
        SAPReceivableWebService.ReturnData returnDataMsg;
        String errorStr = '';
        String code = '';
        Integer index = 0;
        Integer resultIndex = 0;
        if (mainBusinessIncomeMap.size() > 0) {
            List<Database.UpsertResult> resultListHead = Database.upsert(mainBusinessIncomeMap.values(),Main_Business_Income__c.Unique_Code__c, false);
            for(Integer i=0;i<resultListHead.size();i++) {
                Database.UpsertResult resultHead = resultListHead[resultIndex];
                if(!resultHead.isSuccess()) {
                    errorStr = '';
                    for(Database.Error errorStrItem : resultHead.getErrors()) {
                        errorStr = errorStr + errorStrItem.getMessage();
                    }
                    mainIncomeTmp = mainBusinessIncomeMap.get(resultIndex);
                    List<Main_Business_Income_Detail__c> lll = mainBusinessIncomeMapColl.get(mainIncomeTmp.Unique_Code__c);
                    // if(lll!=null){
                        for (Main_Business_Income_Detail__c mainIncomeTmpItemTmp : lll) {
                            returnDataMsg = new SAPReceivableWebService.ReturnData();
                            returnDataMsg.bukrs = mainIncomeTmp.Company_Code__c;//公司代码
                            returnDataMsg.gjahr = mainIncomeTmp.Annual__c;//会计年度
                            returnDataMsg.belnr = mainIncomeTmp.Voucher_Number__c;//会计凭证
                            returnDataMsg.buzei = mainIncomeTmpItemTmp.Voucher_Item_Number__c;//凭证行号
                            returnDataMsg.msgty = 'E';
                            returnDataMsg.msgtx = errorStr;
                            out.ReturnDataList.add(returnDataMsg);
                        }
                        mainBusinessIncomeMapColl.remove(mainIncomeTmp.Unique_Code__c);
                    // }
                    isPartSuccess = true;
                }
                resultIndex++;
            }
        }
        
        Map<Integer,Main_Business_Income__c> mainBusinessIncomeFinal = new Map<Integer,Main_Business_Income__c>();
        Map<Integer,Main_Business_Income_Detail__c> mainBusinessIncomeItemFinal = new Map<Integer,Main_Business_Income_Detail__c>();
        Integer mainBusinessIncomeFinalIndex = 0;
        if (mainBusinessIncomeMapColl.size() > 0) {
            for(String key : mainBusinessIncomeMapColl.keySet()) {
                List<Main_Business_Income_Detail__c> mainBusinessIncomeListFina = mainBusinessIncomeMapColl.get(key);
                for (Main_Business_Income_Detail__c mainBusinessIncomeFina : mainBusinessIncomeListFina) {
                    mainBusinessIncomeItemFinal.put(mainBusinessIncomeFinalIndex,mainBusinessIncomeFina);
                    mainBusinessIncomeFinalIndex++;
                }
            }
        }
        
        // mainBusinessIncomeMap
        // if (mainBusinessIncomeDetailsList.size() > 0 && !Test.isRunningTest()) {
            //     Database.upsert(mainBusinessIncomeDetailsList, Main_Business_Income_Detail__c.Unique_Code__c, true);
        // }
        Integer resultDetailIndex = 0;
        Main_Business_Income__c mainBusinessIncomeAll;
        Main_Business_Income_Detail__c mainIncomeItemTmp;
        if (mainBusinessIncomeItemFinal.size() > 0 || Test.isRunningTest()) {
            List<Database.UpsertResult> resultListItem = Database.upsert(mainBusinessIncomeItemFinal.values(),Main_Business_Income_Detail__c.Unique_Code__c, false);
            resultDetailIndex = 0;
            for(Integer i=0;i<resultListItem.size();i++) {
                Database.UpsertResult resultItem = resultListItem[resultDetailIndex];
                returnDataMsg = new SAPReceivableWebService.ReturnData();
                errorStr = '';
                code = '';
                index = 0;
                mainBusinessIncomeAll = new Main_Business_Income__c();
                if(!resultItem.isSuccess()) {
                    for(Database.Error errorStrItem : resultItem.getErrors()) {
                        errorStr = errorStr + errorStrItem.getMessage();
                    }
                    mainIncomeItemTmp = mainBusinessIncomeItemFinal.get(resultDetailIndex);
                    mainBusinessIncomeAll = mainBusinessIncomeMapAll.get(mainIncomeItemTmp.Main_Bussiness_Income__r.Unique_Code__c);
                    returnDataMsg.bukrs = mainBusinessIncomeAll.Company_Code__c;//公司代码
                    returnDataMsg.gjahr = mainBusinessIncomeAll.Annual__c;//会计年度
                    returnDataMsg.belnr = mainBusinessIncomeAll.Voucher_Number__c;//会计凭证
                    returnDataMsg.buzei = mainIncomeItemTmp.Voucher_Item_Number__c;//凭证行号
                    returnDataMsg.msgty = 'E';
                    returnDataMsg.msgtx = errorStr;
                    out.ReturnDataList.add(returnDataMsg);
                    isPartSuccess = true;
                } else {
                    mainIncomeItemTmp = mainBusinessIncomeItemFinal.get(resultDetailIndex);
                    mainBusinessIncomeAll = mainBusinessIncomeMapAll.get(mainIncomeItemTmp.Main_Bussiness_Income__r.Unique_Code__c);
                    returnDataMsg.bukrs = mainBusinessIncomeAll.Company_Code__c;//公司代码
                    returnDataMsg.gjahr = mainBusinessIncomeAll.Annual__c;//会计年度
                    returnDataMsg.belnr = mainBusinessIncomeAll.Voucher_Number__c;//会计凭证
                    returnDataMsg.buzei = mainIncomeItemTmp.Voucher_Item_Number__c;//凭证行号
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
    }
}