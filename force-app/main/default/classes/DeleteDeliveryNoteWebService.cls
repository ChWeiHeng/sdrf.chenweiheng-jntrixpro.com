/**
 * @description       : 删除交货单接口
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 10-30-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-03-2025   Gerry   Initial Version
**/
@RestResource(urlMapping='/DeleteDeliveryNoteWebService')
global without sharing class DeleteDeliveryNoteWebService {
    global class RequestBody {
        public ReqESInfo esbinfo;
        public List<DeliveryData> resultinfo;
    }
    
    global class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
    }
    
    global class DeliveryData{
        public String source;//交货单号
        public String deleteflag;//是否删除
    }
    global class ResponseBody {
        public RespESInfo esbinfo;
        public List<DeliveryDataReturn> resultinfo;
    }
    
    global class DeliveryDataReturn{
        public String source;//交货单号
        public String msgtx;//消息文本 
        public String msgty;//消息类型 S:成功 E:失败
    }
    global class RespESInfo{
        public String instid;
        public String requesttime;//请求时间
        public String responsetime;//返回时间
        public String returnstatus;//接口状态
        public String returncode;//接口状态码
        public String returnmsg;//接口消息
        public String attr1;//预留字段
        public String attr2;//预留字段
    }
    
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

        ResponseBody response = new ResponseBody();
        response.esbinfo = new RespESInfo();
        response.esbinfo.requesttime = respTime;    
        response.esbinfo.instid = 'SD084';
        response.esbinfo.returnstatus = 'S';
        response.esbinfo.returncode = 'S001';
        response.esbinfo.returnmsg = '成功';
        response.esbinfo.attr1 = 'SAP';
        response.esbinfo.attr2 = 'SFCRM';
        response.resultinfo = new List<DeliveryDataReturn>();
        RequestBody reqBody;
        Set<String> sameDelivery = new Set<String>();//同样的 错误的交货单
        try {
            System.debug('bodyStrJson1==' + bodyStrJson);
            reqBody = (RequestBody) JSON.deserialize(bodyStrJson, RequestBody.class);
            List<Delivery_Note__c> dnData = new List<Delivery_Note__c>();

            Set<String> deliveryCodeSet = new Set<String>();
            for(DeliveryData ddr : reqBody.resultinfo) {//获取客户mdg code
                if(String.isNotBlank(ddr.source) && String.isNotBlank(ddr.deleteflag)) {
                    deliveryCodeSet.add(ddr.source);
                }
            }

            Map<String,String> sourceMap = new Map<String,String>();

            Set<String> resultSet = new Set<String>();//已经处理结果的数据

            
            //需要考虑 一个发货单号对应多行的情况
            for (Delivery_Note__c dn : [SELECT Issue_Quantity__c,Id,Delivery_Post_Status__c,Delivery_Note_Num__c,(SELECT Id,Name FROM Order_Item__r) FROM Delivery_Note__c WHERE Delivery_Note_Num__c IN :deliveryCodeSet ]) {
                if (sameDelivery.contains(dn.Delivery_Note_Num__c)) {
                    continue;
                }
                if (!(dn.Issue_Quantity__c == null || dn.Issue_Quantity__c == 0)) {
                    isPartSuccess = true;
                    response.esbinfo.returnstatus = 'E';
                    response.esbinfo.returncode = 'E001';
                    response.esbinfo.returnmsg = '失败';
                    DeliveryDataReturn ddr = new DeliveryDataReturn();
                    ddr.source = dn.Delivery_Note_Num__c;
                    String orderItemNumber = '[';
                    for (Order_Item__c oi : dn.Order_Item__r) {
                        orderItemNumber += oi.Name;
                    }
                    orderItemNumber += ']';
                    ddr.msgtx = System.Label.DeleteDeliveryError.replace('xxx',orderItemNumber);
                    ddr.msgty = 'E';
                    response.resultinfo.add(ddr);
                    resultSet.add(ddr.source);
                    sameDelivery.add(ddr.source);
                    continue;
                }
                Delivery_Note__c dnUpdate = new Delivery_Note__c();
                dnUpdate.Id = dn.Id;
                dnUpdate.Delivery_Post_Status__c = 'Delete';
                dnData.add(dnUpdate);
                sourceMap.put(dn.Id, dn.Delivery_Note_Num__c);
            }

            List<Delivery_Note__c> dnActualData = new List<Delivery_Note__c>();
            for (Delivery_Note__c dnUpdate : dnData) {
                if (sameDelivery.contains(sourceMap.get(dnUpdate.Id))) {
                    continue;
                }
                dnActualData.add(dnUpdate);
            }
            if(dnActualData.size() > 0) {
                List<Database.SaveResult> resultList = Database.update(dnActualData);
                // Decimal a;
                // System.debug(a*1);
                // for (Database.SaveResult ur : resultList) {
                //     if (!ur.isSuccess()) {
                //         response.esbinfo.returnstatus = 'E';
                //         response.esbinfo.returncode = 'E001';
                //         String errorStr='';
                //         for(Database.Error errorStrItem : ur.getErrors()) {
                //             errorStr = errorStr + errorStrItem.getMessage();
                //         }
                //         DeliveryDataReturn ddr = new DeliveryDataReturn();
                //         ddr.source = sourceMap.get(ur.getId());
                //         ddr.msgtx = errorStr;
                //         ddr.msgty = 'E';
                //         resultSet.add(ddr.source);
                //         response.resultinfo.add(ddr);
                //     }else{
                //         DeliveryDataReturn ddr = new DeliveryDataReturn();
                //         ddr.source = sourceMap.get(ur.getId());
                //         ddr.msgtx = '成功';
                //         ddr.msgty = 'S';
                //         resultSet.add(ddr.source);
                //         response.resultinfo.add(ddr);
                //     }
                // }
            }
            for (DeliveryData dd : reqBody.resultinfo) {
                if (resultSet.contains(dd.source)) {
                    continue;
                }
                DeliveryDataReturn ddr = new DeliveryDataReturn();
                ddr.source = dd.source;
                ddr.msgtx = '成功';
                ddr.msgty = 'S';
                response.resultinfo.add(ddr);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            errorMsg = InterfaceUtility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
            isSuccess = false;
            response.esbinfo.returnstatus = 'E';
            response.esbinfo.returncode = 'E001';
            response.esbinfo.returnmsg = errorMsg;
            // response.resultinfo = new List<DeliveryDataReturn>();
            for (DeliveryData dd : reqBody.resultinfo) {
                if (sameDelivery.contains(dd.source)) {
                    continue;
                }
                DeliveryDataReturn ddr = new DeliveryDataReturn();
                ddr.source = dd.source;
                ddr.msgtx = errorMsg;
                ddr.msgty = 'E';
                response.resultinfo.add(ddr);
            }
        }
        response.esbinfo.responsetime = String.valueOf(System.now());
        InterfaceUtility.insertInterfaceLog('DeleteDeliveryNoteWebService', 'SAP', 'CRM',
        'DeleteDeliveryNoteWebService', bodyStrJson, isSuccess, isPartSuccess,
        JSON.serialize(response), errorMsg, 'POST', dataIdList, 'Update', 'SAP交货单删除同步到CRM'
            );
        
        return response;
    }
}