/**
 * @description       : CRM取回BPM合同
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 09-15-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-26-2025   Gerry   Initial Version
**/
public without sharing class RecallContractFROMBPM {
    public static final String END_POINT = 'RecallContract';

    @AuraEnabled
    public static ReturnResult recallContract(List<String> contractIdList){
        ReturnResult returnResult = new ReturnResult();
        returnResult.isSuccess = true;

        RequestBody request = new RequestBody();
        request.esbinfo = new ReqESInfo();
        request.esbinfo.instid = '';
        String requestBody;//请求报文
        
        Boolean isSuccess = true;
        String responseBodyStr;//返回报文
        String errorMessage;//错误信息
        SavePoint sp;
        try{
            request.esbinfo.requesttime = String.valueof(System.now());
            request.esbinfo.initiatingSystem = 'SF';//发起系统
            request.resultinfo = new List<ReqContractInfo>();
            for (String conId : contractIdList) {
                ReqContractInfo rci = new ReqContractInfo();
                rci.crmId = conId;//CRM合同ID
                request.resultinfo.add(rci);
            }
            requestBody = JSON.serialize(request);
            requestBody = requestBody.replaceAll('null', '""');
            HttpResponse responseBody = InterfaceUtility.send_SAP_POST_Service(requestBody, END_POINT);
            System.debug('responseBody++'+responseBody);
            responseBodyStr = responseBody.getBody();
            System.debug('responseBodyStr===' + responseBodyStr);
            isSuccess = responseBody.getStatusCode() == 200 ? true : false;
            sp = Database.setSavePoint();
            if (isSuccess) {
                ResponseBody syncReturnData = (ResponseBody) JSON.deserialize(responseBodyStr, ResponseBody.class);
                System.debug('responseData===' + syncReturnData);
                if ( syncReturnData.esbinfo != null ) {
                    List<String> unlockList = new List<String>();//需要解锁的合同
                    returnResult.message = syncReturnData.esbinfo.returnmsg;
                    if (syncReturnData.esbinfo.returnstatus == 'S') {
                        List<Contracts__c> conList = new List<Contracts__c>();
                        for (RespContractInfo rci : syncReturnData.resultinfo) {
                            if (rci.MSGTY =='S') {
                                Contracts__c upContract = new Contracts__c();
                                upContract.id = rci.CRMID; //CRMID
                                upContract.Status__c = 'Draft';
                                
                                upContract.CRM_Approval_Status__c = 'Draft';
                                upContract.Sync_Status__c = null;
                                upContract.Recall_Reason__c = null;
                                conList.add(upContract);
                                unlockList.add(rci.CRMID);
                            }else{
                                Contracts__c upContract = new Contracts__c();
                                upContract.id = rci.CRMID; //CRMID
                                upContract.Recall_Reason__c = rci.MSGTX;
                                conList.add(upContract);
                                returnResult.isSuccess = false;
                                returnResult.message = rci.MSGTX;
                            }
                           
                            
                        }

                        if (conList.Size()>0) {
                            update conList;
                        }
                        if (unlockList.size()>0) {
                            for ( String conId : unlockList) {
                                // 解锁记录
                                Approval.UnlockResult unlockResult = Approval.unlock(conId);
                                if (!unlockResult.isSuccess()) {
                                    // 处理解锁失败的情况
                                    throw new CustomException('CRM解锁数据失败');
                                }
                            }
                            
                        }
                    }
                    if(syncReturnData.esbinfo.returnstatus == 'E'){
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
                    returnResult.isSuccess = false;
                    // Utility.notificationUser(contractList[0].OwnerId,Id);
                }
            }else {
                returnResult.isSuccess = false;
                returnResult.message = responseBodyStr;
                isSuccess = false;
                errorMessage = responseBodyStr;
                returnResult.isSuccess = false;
                // Utility.notificationUser(contractList[0].OwnerId,Id);
            }
        } catch (Exception e) {
            // if (contractList.size()>0 && !isClose) {
            //     Utility.notificationUser(contractList[0].OwnerId,Id);
            // }
            if (sp!=null) {
                Database.rollback(sp);
            }
            
            System.debug('错误信息'+e.getMessage()+e.getLineNumber());
            returnResult.isSuccess = false;
            returnResult.message = e.getMessage()+e.getLineNumber();
            isSuccess = false;
            errorMessage = e.getMessage()+e.getLineNumber();
        }
        InterfaceUtility.insertInterfaceLog('RecallContractFROMBPM', 'CRM',
        'BPM', END_POINT, requestBody, isSuccess, false,
        responseBodyStr, errorMessage, 'POST', contractIdList,
        'CRM取回BPM草稿', 'CRM取回BPM草稿');
        return returnResult;
    }

   
    public class ReturnResult {
        @AuraEnabled
        @InvocableVariable(Label='是否成功' Description='是否成功')
        public Boolean isSuccess;
        @AuraEnabled
        @InvocableVariable(Label='返回信息结果' Description='返回信息结果')
        public String message;
    }
    
    public class ResponseBody {
        public RespESInfo esbinfo;
        public List<RespContractInfo> resultinfo;
    }

    public class RespContractInfo{
        public String crmId;//CRM合同ID
        public String MSGTY;//消息类型
        public String MSGTX;//消息文本
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

    public class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqContractInfo> resultinfo;
    }
    
    public class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
        public String initiatingSystem;//发起系统
    }
    
    public class ReqContractInfo{
        public String crmId;//CRM合同ID
    }
}