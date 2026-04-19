/**
 * @description       : 客户基本信息同步
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 11-17-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-25-2025   Gerry   Initial Version
**/
public without sharing class CustomerInfoSyncToSAP {

    public static final String END_POINT = 'CustomerInfo';
    @Future(callout=true)
    public static void submitToSAPFu(String Id,String changeType) {
        submitToSAP(Id,changeType);
    }
    @AuraEnabled
    public static ReturnResult submitToSAP(String Id,String changeType){
        ReturnResult returnResult = new ReturnResult();
        returnResult.isSuccess = true;

        Boolean isSuccess = true;
        String requestBody = '';
        String responseBodyStr = '';
        String errorMessage = '';
        List<Account> accList;
        try{
            RequestBody request = new RequestBody();
            request.esbinfo = new ReqESInfo();
            request.esbinfo.instid = 'GMDG011';
            request.esbinfo.attr2 = 'SFCRM';
            request.esbinfo.requesttime = String.valueOf(System.now());
            List<ReqCustomerInfo> resultinfoList = new List<ReqCustomerInfo>();
            //获取客户
            accList=[SELECT MDG_Customer_Code__c,Customer_Group__c,Id,Name,Language__c,Owner.Name,RecordType.DeveloperName,
                        Customer_Short_Name__c,Group_Name__c,Tax_Identification__c,
                        Tax_Number__c,Continent__c,Region__c,Country__r.Code__c,
                        Province_State__c,City__c,District__c,Postal_Code__c,
                        SAP_Customer_Type__c,SAP_Customer_Name__c,Contact_Name__c,
                        Telephone__c,Email__c,Fax  ,Province_State__r.Name ,Province_State__r.Code__c,Street__c,OwnerId,Sinosure_Customer_Code__c
                    FROM 
                        Account 
                    WHERE Id =:Id];
            //获取银行信息
            List<Bank_Info__c> bankList=[SELECT Bank_Name__c,Id,C_R__c,Bank_Key__c,Bank_Acct__c,Account_Holder__c,
                                        Control_Key__c,External_Id__c 
                                        FROM Bank_Info__c 
                                        WHERE Customer__c =:Id];
            ReqCustomerInfo rci = new ReqCustomerInfo();
            if (changeType == 'U') {
                rci.maintype = 'BP2P1';
                rci.partner = accList[0].MDG_Customer_Code__c;
            }
            if (changeType == 'I') {
                rci.maintype = 'BP1P1';
            }
            rci.usmdcreqtext = accList[0].Id + accList[0].Owner.Name;
            rci.langu = accList[0].Language__c;
            rci.butype = '2';
            rci.bugroup = accList[0].Customer_Group__c;
            rci.nameorg1 = accList[0].Name;
            rci.busort1 = accList[0].Customer_Short_Name__c;
            rci.nameorg3 = accList[0].Group_Name__c;
            rci.type = accList[0].Tax_Identification__c;
            rci.idnumber = accList[0].Tax_Number__c;
            rci.zzcontt = accList[0].Continent__c;
            rci.zzregin = accList[0].Region__c;
            rci.country = accList[0].Country__r.Code__c;
            rci.region = accList[0].Province_State__r.Code__c;
            rci.city1 = accList[0].City__c;
            rci.street = accList[0].Street__c;
            rci.postcode1 = accList[0].Postal_Code__c;
            rci.rltyp = 'CU';
            rci.zzcudis = accList[0].SAP_Customer_Type__c;
            // rci.zname2 = accList[0].SAP_Customer_Name__c;
            rci.nameco = accList[0].Contact_Name__c;
            rci.telnumber1 = accList[0].Telephone__c;
            rci.smtpaddr = accList[0].Email__c;
            // rci.zname2 = accList[0].SAP_Customer_Name__c;
            rci.faxnumber = accList[0].Fax;
            rci.ZZXBCODE = accList[0].Sinosure_Customer_Code__c;
            List<BankRow> bankRowList = new List<BankRow>();
            for(Bank_Info__c bi : bankList){
                BankRow br = new BankRow();
                br.banks = bi.C_R__c;
                br.bankl = bi.Bank_Key__c;
                br.banka = bi.Bank_Name__c;
                br.bankn = bi.Bank_Acct__c;
                br.koinh = bi.Account_Holder__c;
                br.accname = bi.Control_Key__c;
                br.bkext = bi.External_Id__c;
                bankRowList.add(br);
            }
            rci.banks = bankRowList;
            resultinfoList.add(rci);
            request.resultinfo = resultinfoList;

            requestBody = JSON.serialize(request);
            requestBody = requestBody.replaceAll('null', '\"\"');
            System.debug('requestBody++'+requestBody);
            HttpResponse responseBody = InterfaceUtility.send_SAP_POST_Service(requestBody, END_POINT);
            System.debug('responseBody++'+responseBody);
            responseBodyStr = responseBody.getBody();
            System.debug('responseBodyStr===' + responseBodyStr);
            isSuccess = responseBody.getStatusCode() == 200 ? true : false;
            if (isSuccess) {
                ResponseBody syncReturnData = (ResponseBody) JSON.deserialize(responseBodyStr, ResponseBody.class);
                System.debug('responseData===' + syncReturnData);
                if ( syncReturnData.esbinfo != null ) {
                    returnResult.message = syncReturnData.esbinfo.returnmsg;
                    Account upAcc = new Account();
                    upAcc.Id = Id;
                    if (syncReturnData.esbinfo.returnstatus == 'S') {
                        upAcc.MDG_Customer_Code__c = syncReturnData.resultinfo[0].partner;
                        upAcc.Sync_Status__c = 'Synchronized';
                        upAcc.Sync_Failure_Reasons__c = '';
                        upAcc.SAP_Customer_Name__c = accList[0].Name;
                    }
                    if(syncReturnData.esbinfo.returnstatus == 'E'){
                        if (changeType == 'I' && String.isNotBlank(syncReturnData.resultinfo[0].partner)) {
                            upAcc.MDG_Customer_Code__c = syncReturnData.resultinfo[0].partner;
                            upAcc.Sync_Status__c = 'Synchronized';
                            upAcc.Sync_Failure_Reasons__c = '';
                            upAcc.MDG__c = true;
                            upAcc.SAP_Customer_Name__c = syncReturnData.resultinfo[0].nameorg1;
                        }else{
                            returnResult.isSuccess = false;
                            upAcc.Sync_Status__c = 'Synchronization Failure';
                            upAcc.Sync_Failure_Reasons__c = syncReturnData.esbinfo.returnmsg;
                            isSuccess = false;
                            errorMessage = syncReturnData.esbinfo.returnmsg;
                            returnResult.isSuccess = false;
                            returnResult.message = syncReturnData.esbinfo.returnmsg;
                            Utility.notificationUser(accList[0].OwnerId,Id);
                            upAcc.SAP_Customer_Name__c = accList[0].Name;
                        }
                    }
                    update upAcc;
                }else{
                    returnResult.isSuccess = false;
                    returnResult.message = responseBodyStr;
                    isSuccess = false;
                    errorMessage = responseBodyStr;
                    Utility.notificationUser(accList[0].OwnerId,Id);
                }
                
            } else {
                returnResult.isSuccess = false;
                returnResult.message = responseBodyStr;
                isSuccess = false;
                errorMessage = responseBodyStr;
                Account upAcc = new Account();
                upAcc.Id = Id;
                upAcc.Sync_Status__c = 'Synchronization Failure';
                upAcc.Sync_Failure_Reasons__c = ''+responseBody.getStatusCode();
                upAcc.SAP_Customer_Name__c = accList[0].Name;
                update upAcc;
                Utility.notificationUser(accList[0].OwnerId,Id);
            }

        }
        catch (Exception e) {
            if (accList.size()>0) {
                Utility.notificationUser(accList[0].OwnerId,Id);
            }
            Account upAcc = new Account();
            upAcc.Id = Id;
            upAcc.Sync_Status__c = 'Synchronization Failure';
            upAcc.Sync_Failure_Reasons__c = e.getMessage()+e.getLineNumber();
            upAcc.SAP_Customer_Name__c = accList[0].Name;
            update upAcc;
            System.debug('错误信息'+e.getMessage()+e.getLineNumber());
            returnResult.isSuccess = false;
            returnResult.message = e.getMessage()+e.getLineNumber();
            isSuccess = false;
            errorMessage = e.getMessage()+e.getLineNumber();
        }
        InterfaceUtility.insertInterfaceLog('CustomerInfoSyncToSAP', 'CRM',
                    'SAP', END_POINT, requestBody, isSuccess, false,
                    responseBodyStr, errorMessage, 'POST', new List<String>{Id},
                    '客户基本信息同步SAP', 'CRM同步客户基本信息至SAP');
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

    public class RespCustomerInfo{
        public String usmdcrequest;//MDG流程编码
        public String partner;//业务伙伴编码
        public String nameorg1;//业务伙伴名称
        
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
        public String partner;
        public String maintype;//维护标识
        public String usmdcreqtext;//流程说明
        public String langu;//业务伙伴语言
        public String butype;//业务伙伴类别
        public String bugroup;//业务伙伴分组
        public String nameorg1;//业务伙伴名称
        public String busort1;//业务伙伴简称
        public String nameorg3;//业务伙伴所属集团
        public String type;//唯一性属性类别
        public String idnumber;//唯一性识别属性
        public String zzcontt;//业务伙伴所属大洲
        public String zzregin;//业务伙伴所属大区
        public String country;//业务伙伴注册国家
        public String region;//业务伙伴注册地区
        public String city1;//业务伙伴注册城市
        public String street;//业务伙伴注册详细地址
        public String postcode1;//业务伙伴邮编
        public String rltyp;//业务伙伴角色
        public String zzcudis;//客户类型
        public String zname2;//客户全称
        public String district;//区域
        public String housenumber;//门牌号
        public String nameco;//客户联系人
        public String telnumber1;//客户联系人电话
        public String smtpaddr;//客户联系人邮箱
        public String faxnumber;//客户联系人传真
        public String ZZXBCODE;//中信保客户编码
        public String iex01;//预留字段1
        public String iex02;//预留字段2
        public String iex03;//预留字段3
        public String iex04;//预留字段4
        public String iex05;//预留字段5
        public String iex06;//预留字段6
        public List<BankRow> banks;
    }

    public class BankRow{
        public String banks;//银行国家
        public String bankl;//银行代码
        public String banka;//银行名称
        public String bankn;//银行账号
        public String koinh;//账户持有人
        public String accname;//付款类型
        public String bkext;//外部标识
        public String iex01;//预留字段1
        public String iex02;//预留字段2
        public String iex03;//预留字段3
        public String iex04;//预留字段4
        public String iex05;//预留字段5
        public String iex06;//预留字段6
    }

}