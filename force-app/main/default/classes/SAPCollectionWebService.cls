@RestResource(urlMapping='/SAPCollectionWebService')
global without sharing class SAPCollectionWebService {
    public class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqOrderInfo> resultinfo;
    }
    
    public class ReqESInfo {
        public String instid; // 接口编号
        public String requesttime; // 请求时间
    }

    public class ReqOrderInfo {
        public String KUNNR; // 客户编码
        public String BUKRS; // 公司代码
        public String GJAHR; // 会计年度
        public String BELNR; // 会计凭证
        public String BUZEI; // 凭证行号
        public String H_BLART; // 凭证类型
        public String H_WAERS; // 凭证货币
        public String RFCCUR; // 本位币
        public String KURSF; // 汇率
        public String H_BUDAT; // 过账日期
        public String SHKZG; // 借贷方
        public String WRBTR; // 凭证货币金额
        public String DMBTR; // 本位币金额
        public String PRCTR; // 利润中心
        public String HKONT; // 会计科目
    }
    /**
     * SAP 收集明细同步接口
     * @param bodyStrJson bodyStrJson
     * 
     * @return ResponseBody
     */
    @HttpPost
    global static SAPProductWebService.ResponseBody doPost() {
        String respTime = String.valueOf(Datetime.now());
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String bodyStrJson = req.requestBody.toString();
        System.debug('Received body: ' + bodyStrJson);
        List<String> dataIdList = new List<String>();
        Boolean isSuccess = true;
        Savepoint sp = Database.setSavepoint();
        String errorMsg;
        try {
            System.debug('bodyStrJson1==' + bodyStrJson);
            RequestBody reqBody = (RequestBody) JSON.deserialize(bodyStrJson, RequestBody.class);
            feedbackOrderInfo(reqBody.resultinfo);
        } catch (Exception e) {
            Database.rollback(sp);
            errorMsg = InterfaceUtility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
            isSuccess = false;
        }
        SAPProductWebService.ResponseBody response = SAPProductWebService.returnData(respTime, isSuccess, errorMsg);
        InterfaceUtility.insertInterfaceLog('SAPCollectionWebService', 'SAP', 'CRM',
                '/services/apexrest/collectionDetailsFromExternal/  requestCode:SAP001', bodyStrJson, isSuccess, false,
                JSON.serialize(response), errorMsg, 'POST', dataIdList, 'Upsert', 'SAP同步回款信息至CRM'
        );
        return response;
    }
    public static void feedbackOrderInfo(List<ReqOrderInfo> resultinfo) {
        List<Collection_Details__c> collectionDetailsList = new List<Collection_Details__c>();   
        Set<String> customerIdSet = new Set<String>();
        Map<String,String> customeMap = new Map<String,String>();
        Set<String> salesOrgSet = new Set<String>();

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
        for (Customer_Sales_Info__c csi : [
                                            SELECT 
                                                Id ,
                                                Customer__r.MDG_Customer_Code__c,
                                                Sales_Org__c
                                            FROM 
                                                Customer_Sales_Info__c 
                                            WHERE 
                                                Customer__r.MDG_Customer_Code__c IN:customerIdSet AND
                                                Sales_Org__c IN:salesOrgSet
        ]) {
            salesInfoMap.put(csi.Customer__r.MDG_Customer_Code__c+'-'+csi.Sales_Org__c, csi.Id);
        } 
        for (ReqOrderInfo reqOrder : resultinfo) {
            //System.debug('Processing ReqOrderInfo: ' + reqOrder);
            Collection_Details__c collectionDetail = new Collection_Details__c();
            if (customeMap.size()>0 && customeMap.containsKey(reqOrder.KUNNR)) { // 客户编码
                collectionDetail.Customer__c = customeMap.get(reqOrder.KUNNR);
            }
            collectionDetail.Company_Code__c = reqOrder.BUKRS; // 公司代码
            collectionDetail.Fiscal_Year__c = reqOrder.GJAHR; // 会计年度
            collectionDetail.Document_Number__c = reqOrder.BELNR; // 会计凭证
            collectionDetail.Posting_Item__c = reqOrder.BUZEI; // 凭证行号
            collectionDetail.Document_Type__c = reqOrder.H_BLART; // 凭证类型
            collectionDetail.Document_Currency__c = reqOrder.H_WAERS; // 凭证货币
            collectionDetail.Local_Currency__c = reqOrder.RFCCUR; // 本位币
            if (reqOrder.kursf!=null) {
                collectionDetail.Exchange_Rate__C = String.isBlank(reqOrder.KURSF) ? 0 : Decimal.valueOf(reqOrder.KURSF); //汇率
            }else{
                collectionDetail.Exchange_Rate__C = null; //汇率
            }
            collectionDetail.Posting_Date__c = Date.valueOf(reqOrder.H_BUDAT); // 过账日期
            collectionDetail.Debit_Credit__c = reqOrder.SHKZG; // 借贷方
            collectionDetail.Document_Amount__c = String.isBlank(reqOrder.WRBTR) ? 0 : Decimal.valueOf(reqOrder.WRBTR); //凭证货币金额
            collectionDetail.Local_Amount__c =  String.isBlank(reqOrder.DMBTR) ? 0 : Decimal.valueOf(reqOrder.DMBTR); //本位币金额
            collectionDetail.Profit_Center__c = reqOrder.PRCTR; // 利润中心
            collectionDetail.Account_Number__c = reqOrder.HKONT; // 会计科目
            collectionDetail.External_Id__c =  reqOrder.BUKRS + reqOrder.GJAHR + reqOrder.BELNR + reqOrder.BUZEI;//reqOrder.KUNNR +
            if(salesInfoMap.containskey(reqOrder.KUNNR+'-'+reqOrder.BUKRS)){
                collectionDetail.Customer_Sales_Info__c = salesInfoMap.get(reqOrder.KUNNR+'-'+reqOrder.BUKRS);
            }else{
                throw new CustomException(reqOrder.KUNNR+'-'+reqOrder.BUKRS+'不存在！');
            }      
            collectionDetailsList.add(collectionDetail);
        }
        if (collectionDetailsList.size() > 0) {
            Database.upsert(collectionDetailsList, Collection_Details__c.fields.External_Id__c, true);
        }
    }

}