public without sharing class CustomerlimitSyncToSAP {  //客户额度同步

    public static final String END_POINT = 'creditLimit';







    @Future(callout=true)

    public static void submitToSAPFutrue(String Id){

        submitToSAP(Id);

    }



    @AuraEnabled





    public static ReturnResult submitToSAP(String Id){

        ReturnResult returnResult = new ReturnResult();

        returnResult.isSuccess = true;

        Boolean isSuccess = true;

        String requestBody = '';

        String responseBodyStr = '';

        String errorMessage = '';
        List<Customer_Credit_Info__c> limitList;
        try{

            RequestBody request = new RequestBody();

            request.esbinfo = new ReqESInfo();
            request.esbinfo.instid = 'GSD003';

            List<ReqCustomerlimit> resultinfoList = new List<ReqCustomerlimit>();

            //获取额度信息

            limitList=[

                SELECT Id,Name,

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
                Customer__r.MDG_Customer_Code__c,Customer__r.OwnerId

             FROM Customer_Credit_Info__c

             WHERE Id =:Id];



            ReqCustomerlimit rci = new ReqCustomerlimit();

            rci.partner = limitList[0].Customer__r.MDG_Customer_Code__c; //客户编码

            rci.limitrule = limitList[0].Rules__C; //客户额度编码         

            rci.riskclass = limitList[0].Risk_Class__C; //风险类

            rci.checkrule = limitList[0].Check_Rule__c; //规则

            rci.creditsgmnt = limitList[0].Credit_Segment__C; //信用段

            rci.creditlimit = String.valueOf(limitList[0].Actual_Credit_limit__C); //额度

            rci.valid_date = String.valueOf(limitList[0].Valid_Until__C); //有效期
            rci.valid_date = rci.valid_date.replaceAll('-', '');


            resultinfoList.add(rci);

            request.resultinfo = resultinfoList;



            requestBody = JSON.serialize(request);

            System.debug('requestBody++'+requestBody);



            HttpResponse responseBody = InterfaceUtility.send_SAP_POST_Service(requestBody, END_POINT);

            System.debug('responseBody++'+responseBody);



            responseBodyStr = responseBody.getBody();

            System.debug('responseBodyStr===' + responseBodyStr);

            

            //判断状态

            isSuccess = responseBody.getStatusCode() == 200 ? true : false;

            if (isSuccess) {

                ResponseBody syncReturnData = (ResponseBody) JSON.deserialize(responseBodyStr, ResponseBody.class);

                System.debug('responseData===' + syncReturnData);

                if ( syncReturnData.esbinfo != null ) {

                    returnResult.message = syncReturnData.esbinfo.returnmsg;

                    Customer_Credit_Info__c upcsi = new Customer_Credit_Info__c();

                    upcsi.Id = Id;

                    if (syncReturnData.esbinfo.returnstatus == 'S') {

                        upcsi.Sync_Status__c = 'Synchronized';
                        upcsi.Sync_Failure_Reasons__c = '';
                    }

                    if(syncReturnData.esbinfo.returnstatus == 'E'){
                        isSuccess = false;
                        errorMessage = syncReturnData.esbinfo.returnmsg;
                        returnResult.isSuccess = false;
                        returnResult.message = syncReturnData.esbinfo.returnmsg;
                        upcsi.Sync_Status__c = 'Synchronization Failure';

                        upcsi.Sync_Failure_Reasons__c = syncReturnData.esbinfo.returnmsg;
                        Utility.notificationUser(limitList[0].Customer__r.OwnerId,Id);
                    }

                    update upcsi;

                }else{

                    returnResult.isSuccess = false;

                    returnResult.message = responseBodyStr;

                    isSuccess = false;

                    errorMessage = responseBodyStr;
                    Utility.notificationUser(limitList[0].Customer__r.OwnerId,Id);

                }

            } 

            else {

                    returnResult.isSuccess = false;

                    returnResult.message = responseBodyStr;

                    isSuccess = false;

                    errorMessage = responseBodyStr;
                    Utility.notificationUser(limitList[0].Customer__r.OwnerId,Id);

            }

        }

        catch (Exception e) {
            if (limitList.size()>0) {
                Utility.notificationUser(limitList[0].Customer__r.OwnerId,Id);
            }
            System.debug('错误信息'+e.getMessage()+e.getLineNumber());

            returnResult.isSuccess = false;

            returnResult.message = e.getMessage()+e.getLineNumber();

            isSuccess = false;

            errorMessage = e.getMessage()+e.getLineNumber();

        }

        InterfaceUtility.insertInterfaceLog('CustomerlimitSyncToSAP', 'CRM',

                    'SAP', END_POINT, requestBody, isSuccess, false,

                    responseBodyStr, errorMessage, 'POST', new List<String>{Id},

                    '客户额度信息同步SAP', 'CRM同步信用额度至SAP');

        return returnResult;

    }



    public class ReturnResult {

        @InvocableVariable(Label='是否成功' Description='是否成功')

        public Boolean isSuccess;

        @InvocableVariable(Label='返回信息结果' Description='返回信息结果')

        public String message;

    }

    public class ResponseBody {

        public RespESInfo esbinfo;

        public List<RespCustomerInfo> resultinfo;//?

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

    public class RespCustomerInfo{

        public String usmdcrequest;//MDG流程编码

        public String partner;//业务伙伴编码

        public String nameorg1;//业务伙伴名称

        

    }

    public class RequestBody {

        public ReqESInfo esbinfo;

        public List<ReqCustomerlimit> resultinfo;

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

    public class ReqCustomerlimit{

        public String partner;    //客户编码

        public String limitrule;  //规则

        public String riskclass;  //风险类

        public String checkrule;  //检查规则

        public String creditsgmnt;//信用段

        public String creditlimit;//额度

        public String valid_date; //有效至

        public String iex01;//预留字段1

        public String iex02;//预留字段2

        public String iex03;//预留字段3

        public String iex04;//预留字段4

        public String iex05;//预留字段5

        public String iex06;//预留字段6

    }

}