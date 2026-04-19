@RestResource(urlMapping='/SAPPackageDataWebService')
global without sharing class SAPPackageDataWebService {
    global class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqPackageData> resultinfo;
    }

    global class ReqESInfo {
        public String instid;// 接口编号
        public String requesttime;// 请求时间
    }

    global class ReqPackageData {
        public String zbzgg;//包装规格代码
        public String zbzggms;//包装规格描述
        public String zbzxs;//包装形式
        public String zdef1;//每包装单位货物重量（千克/升）
        public String zdef2;//每包装单位包装物重量（以千克计算）
        public HeadInclude INCLUDE;//备用字段
    }

    global class HeadInclude{
        public String HEX01;//备用字段
        public String HEX02;//备用字段
        public String HEX03;//备用字段
        public String HEX04;//备用字段
        public String HEX05;//备用字段
        public String HEX06;//备用字段
    }

    global class ResponseBody {
        public RespESInfo esbinfo;
        public List<RespCustomerInfo> resultinfo;
    }

    global class RespCustomerInfo{
        public String zbzgg;//包装规格代码
        public String msgty;//处理状态
        public String msgtx;//错误信息
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

    /**
     * SAP 包装规格数据同步至 CRM
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
        String errorMsg = '';
        Boolean isSuccess = true;
        Savepoint sp = Database.setSavepoint();
        RequestBody reqBody;
        try {
            System.debug('bodyStrJson1==' + bodyStrJson);
            reqBody = (RequestBody) JSON.deserialize(bodyStrJson, RequestBody.class);
            feedbackOrderInfo(reqBody.resultinfo);
            // respTime = reqBody.esbinfo.requesttime;
        } catch (Exception e) {
            Database.rollback(sp);
            errorMsg = InterfaceUtility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
            // System.debug('出现错误：' + reqBody.message);
            isSuccess = false;
            // respTime = String.valueOf(Datetime.now());
        }

        ResponseBody response = returnData(reqBody.resultinfo, respTime, isSuccess, errorMsg);
        InterfaceUtility.insertInterfaceLog('SAPPackageDataWebService', 'SAP', 'CRM',
                '/services/apexrest/collectionDetailsFromExternal/  requestCode:SAP002', bodyStrJson, isSuccess, false,
                JSON.serialize(response), errorMsg, 'POST', dataIdList, 'Upsert', 'SAP包装规格数据同步至CRM'
        );
        return response;
    }

    public static void feedbackOrderInfo(List<ReqPackageData> resultinfoList) {
        List<Package_Data__c> pdList = new List<Package_Data__c>();
        for(ReqPackageData resultinfo : resultinfoList) {
            Package_Data__c upPackageData = new Package_Data__c();
            upPackageData.Name = resultinfo.zbzggms;
            upPackageData.Pakcing_Size_Code__c = resultinfo.zbzgg; //包装规则代码
            upPackageData.Package_Specification_Name__c = resultinfo.zbzggms; //包装规格描述
            upPackageData.Packing_Form__c = resultinfo.zbzxs; //包装形式
            upPackageData.Weight_Of_Goods_Per_Packing_Unit__c = String.valueOf(resultinfo.zdef1) == null ? 0 : Decimal.valueof(String.valueOf(resultinfo.zdef1)); //每包装单位货物重量
            upPackageData.Weight_Per_Unit_Of_Packaging__c = String.valueOf(resultinfo.zdef2) == null ? 0 : Decimal.valueof(String.valueOf(resultinfo.zdef2)); //每单位包装物重量
            pdList.add(upPackageData);
        }
        
        Database.upsert(pdList,Package_Data__c.fields.Pakcing_Size_Code__c, true);
    }

    global static ResponseBody returnData(List<ReqPackageData> resultinfo,String requestTime,Boolean status,String errorMsg) {
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
        re.resultinfo = new List<RespCustomerInfo>();
        RespCustomerInfo rci = new RespCustomerInfo();
        if (status) {
            rci.msgty = 'S';
            rci.msgtx = '处理成功';
        }else{
            rci.msgty = 'E';
            rci.msgtx = errorMsg;
        }
        // rci.zbzgg = resultinfo.zbzgg;
        re.resultinfo.add(rci);
        return re;
    }
}