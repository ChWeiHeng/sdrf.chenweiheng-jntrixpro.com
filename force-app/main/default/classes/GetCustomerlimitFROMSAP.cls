/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 10-23-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-25-2025   Gerry   Initial Version
**/
public without sharing class GetCustomerlimitFROMSAP {//客户使用额度查询

    public static final String END_POINT = 'getLimit';

    @AuraEnabled

    public static RespCustomerInfo submitToSAP(List<String> customerCodeList,String WAERS,String BUKRS){
        List<String> recordIdList = new List<String>();
        System.debug('WAERS'+WAERS);
        ResponseBody syncReturnData = null;
        ReturnResult returnResult = new ReturnResult();

        returnResult.isSuccess = true;

        Boolean isSuccess = true;

        String requestBody = '';

        String responseBodyStr = '';

        String errorMessage = '';

        try{

            RequestBody request = new RequestBody();

            request.esbinfo = new ReqESInfo();
            request.esbinfo.requesttime = String.valueOf(Datetime.now());
            request.esbinfo.instid = 'GSD004';
            List<ReqCustomerInfo> resultinfoList = new List<ReqCustomerInfo>();

            //获取客户

            List<Customer_Credit_Info__c> accList = [ SELECT Id,Name,

                                                        Rules__C,

                                                        Risk_Class__C,

                                                        Check_Rule__C,

                                                        Credit_Segment__C,

                                                        Valid_Until__C,

                                                        Customer__C,

                                                        Sinosure_Credit_Limit__C,

                                                        Local_Credit_Limit__C,

                                                        Actual_Credit_limit__C,

                                                        Sync_Status__C,

                                                        Remaining_Credit__C,
                                                        Customer__r.MDG_Customer_Code__c

                                                    FROM 
                                                        Customer_Credit_Info__c

                                                    WHERE 
                                                        Customer__r.MDG_Customer_Code__c IN:customerCodeList
                                                    ];

        Map<String,String> cciMap = new Map<String,String>();
        for (Customer_Credit_Info__c cci : accList) {
            recordIdList.add(cci.Id);
            ReqCustomerInfo rci = new ReqCustomerInfo();
            cciMap.put(cci.Customer__r.MDG_Customer_Code__c, cci.Id);
            rci.partner = cci.Customer__r.MDG_Customer_Code__c;
            rci.creditSegment = accList[0].credit_Segment__c;
            if (String.isNotBlank(WAERS)) {
                System.debug('进入销售逻辑');
                rci.WAERS = WAERS;
            }
            if (String.isNotBlank(BUKRS)) {
                rci.BUKRS = BUKRS;
            }
            resultinfoList.add(rci);
        }
        



        

        request.resultinfo = resultinfoList;

        requestBody = JSON.serialize(request);



        System.debug('requestBody++'+requestBody);

        HttpResponse responseBody = InterfaceUtility.send_SAP_POST_Service(requestBody, END_POINT);

        System.debug('responseBody++'+responseBody);

        responseBodyStr = responseBody.getBody();

        System.debug('responseBodyStr===' + responseBodyStr);



        isSuccess = responseBody.getStatusCode() == 200 ? true : false;



            if (isSuccess) {

                syncReturnData = (ResponseBody) JSON.deserialize(responseBodyStr, ResponseBody.class);

                System.debug('responseData===' + syncReturnData);

                if ( syncReturnData.esbinfo != null ) {

                    returnResult.message = syncReturnData.esbinfo.returnmsg;

                    

                    if (syncReturnData.esbinfo.returnstatus == 'S') {

                        List<Customer_Credit_Info__c> updateList = new List<Customer_Credit_Info__c>();
                        for (RespCustomerInfo rci : syncReturnData.resultinfo) {
                            Customer_Credit_Info__c upAcc = new Customer_Credit_Info__c();
                            upAcc.Id = cciMap.get(rci.partner);
                            upAcc.Remaining_Credit__C = rci.amount;
                            if (String.isNotBlank(rci.zsfyq)) {
                                upAcc.Overdue__c = true;
                            }else{
                                upAcc.Overdue__c = false;
                            }
                            updateList.add(upAcc);
                        }
                        update updateList;
                    }

                    if(syncReturnData.esbinfo.returnstatus == 'E'){
                        isSuccess = false;
                        errorMessage = syncReturnData.esbinfo.returnmsg;
                        returnResult.isSuccess = false;
                        returnResult.message = syncReturnData.esbinfo.returnmsg;
                    }

                    if(syncReturnData.esbinfo.returnstatus == 'W'){
                        isSuccess = false;
                        errorMessage = syncReturnData.esbinfo.returnmsg;
                        returnResult.isSuccess = false;
                        returnResult.message = syncReturnData.esbinfo.returnmsg;
                    }

                }else{

                    returnResult.isSuccess = false;
                    returnResult.message = responseBodyStr;
                    isSuccess = false;
                    errorMessage = responseBodyStr;

                }


            } else {
                returnResult.isSuccess = false;
                returnResult.message = responseBodyStr;
                isSuccess = false;
                errorMessage = responseBodyStr;

            }
        }

        catch (Exception e) {

            System.debug('错误信息'+e.getMessage()+'行数：'+e.getLineNumber());

            returnResult.isSuccess = false;

            returnResult.message = e.getMessage()+e.getLineNumber();

            isSuccess = false;

            errorMessage = e.getMessage()+e.getLineNumber();

        }

        InterfaceUtility.insertInterfaceLog('GetCustomerlimitFROMSAP', 'CRM',

                    'SAP', END_POINT, requestBody, isSuccess, false,

                    responseBodyStr, errorMessage, 'POST', recordIdList,

                    '客户额度信息查询', 'CRM查询SAP信用额度余额');

        // if (isSuccess) {
            // return null;
            if (syncReturnData!=null && syncReturnData.resultinfo!=null) {
                if (syncReturnData.resultinfo.size()>0) {
                    // syncReturnData.resultinfo[0].zovdmtr = '5000';
                    return syncReturnData.resultinfo[0];
                }else{
                    RespCustomerInfo r = new RespCustomerInfo();
                    r.msgty = 'E';
                    r.msgtx = 'No result';
                    return r;
                }
            }else{
                RespCustomerInfo r = new RespCustomerInfo();
                r.msgty = 'E';
                r.msgtx = 'No result';
                return r;
            }
            
            
        // }else{
        //     return null;
        // }
        

    }



    public class ReturnResult {

        @InvocableVariable(Label='是否成功' Description='是否成功')

        public Boolean isSuccess;

        @InvocableVariable(Label='返回信息结果' Description='返回信息结果')

        public String message;

    }



    public class ResponseBody {

      public RespESInfo esbinfo;

      public List<RespCustomerInfo> resultinfo;

    }



    public class RespESInfo{

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



    public class RespCustomerInfo{  //响应信息 resultinfo



        public String partner;  //业务伙伴编码

        public Decimal amount;   //剩余额度

        public String WAERS; //币种

        public String zsfyq;//是否逾期

        public String exch_rate;//汇率

        public String ZOVDAYS;//最大逾期天数

        public String zovdmtr;//逾期金额

        public String msgty;

        public String msgtx;
    }



    public class RequestBody {

        public ReqESInfo esbinfo;

        public List<ReqCustomerInfo> resultinfo;

        public String iex01;//预留字段1

        public String iex02;//预留字段2

        public String iex03;//预留字段3

        public String iex04;//预留字段4

        public String iex05;//预留字段5

        public String iex06;//预留字段6

    }



    public class ReqESInfo{

        public String instid;//接口编号

        public String requesttime;//请求时间

        public String attr1;//预留字段

        public String attr2;//预留字段

        public String attr3;//预留字段

    }



    public class ReqCustomerInfo{

        public String partner;//客户编码

        public String creditSegment;//信用段

        public String WAERS;//币种

        public String BUKRS;//销售组织

        public String iex01;//预留字段1

        public String iex02;//预留字段2

        public String iex03;//预留字段3

        public String iex04;//预留字段4

        public String iex05;//预留字段5

        public String iex06;//预留字段6

    }

}