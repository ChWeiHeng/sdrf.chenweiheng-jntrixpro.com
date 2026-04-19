/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 12-29-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-20-2025   Gerry   Initial Version
**/
public without sharing class DraftContractSyncToBPM {
    public static final String END_POINT = 'CreateContract';
    
    @Future(callout=true)
    public static void submitToBPMFu(
        String Id
    ) {
        submitToBPM(Id,false);
    }
    
    @AuraEnabled
    public static ReturnResult submitToBPM(
        String Id,
        Boolean action
    ){
        ReturnResult returnResult = new ReturnResult();
        returnResult.isSuccess = true;
        
        Boolean isSuccess = true;
        String requestBody = '';
        String responseBodyStr = '';
        String errorMessage = '';
        List<Contracts__c> contractList;
        User u = [SELECT Id,Country__c,BPMCode__c FROM User WHERE Id=:System.UserInfo.getUserId()];
        Boolean notifacation = true;
        try {
            RequestBody request = new RequestBody();
            request.esbinfo = new ReqESInfo();
            request.esbinfo.instid = '';
            ReqContractInfo resultinfo = new ReqContractInfo();
            //获取草稿合同抬头数据
            contractList=
                [SELECT Final_Customer__r.HQ_Email__c,Name,Destination_Port_New__r.Port_Information_Code__c,Loading_Port_New__r.Port_Information_Code__c,Transaction_Mode__c,Contract_Type__c,Final_Customer__c,Export_Country__c,Final_Customer_Payment_Terms__c,Registration__c,Import_Permits__c,Brand_Approval__c,Other_Remarks__c,
                    Trade_Terms__c,Currency__c,Shipment__c,Restrictions__c,Restriction_Reasons__c,Business_Model__c,Sales_Org__c,Delivery_Plant__c,Export_Country__r.Code__c,
                    Reason_of_Negative_Margin__c,BPM_Contrct_Numbder__c,OwnerId,Final_Customer__r.Name,Id,Final_Customer__r.MDG_Customer_Code__c,Customer__r.Name,Customer__r.MDG_Customer_Code__c
                FROM Contracts__c 
                WHERE id = :Id];
            //获取草稿合同明细数据
            List<Contracts_Detail__c> contractItemList=
                [SELECT Tracking_Code__c,Product__c,Product_English_Name__c,Product_Name__c,Packing_Size__c,Unit__c,Qnty__c,Unit_Price__c,Total_Amount__c,HQ_Contract_Unit_Price__c,
                    Packing_cost__c,Pallet_Cost__c,Other_Issue__c,Freight_Cost__c,Total_Freight_Cost__c,Discount_Unit_Price__c,If_Designated_Products__c,id,
                    If_Pallet__c,BU_Sales_Price__c,Earliest_Demand__c,Demand_Time__c,Latest_need__c,Latest_Delivery_Date__c,Commission_Unit_Price__c,
                    Packing_Size_Description__c,Recheck_Margin__c,BPM_Detail_Number__c,Product__r.Chinese_Description__c,Packing_Size__r.Pakcing_Size_Code__c,
                    Packing_Size__r.Package_Specification_Name__c,FOB_Price__c,Product__r.Name,(SELECT Id,Name,Link__c FROM Attachments__r),Target_Arrival_Date__c
                FROM Contracts_Detail__c 
                WHERE Contracts__c = :Id];
            Map<String,String> paymentTermMap = new Map<String,String>();
            List<Payment_Term_Relation__c> ptrList = [SELECT Id,Headquarters_Payment_Term__c FROM Payment_Term_Relation__c WHERE Local_Payment_Term__c=:contractList[0].Final_Customer_Payment_Terms__c];

            Map<String,String> valueMap = Utility.getPicklistValueMap('Contracts__c','Final_Customer_Payment_Terms__c');
            Map<String,String> valueTTMap = Utility.getPicklistValueMap('Contracts__c','Trade_Terms__c');
            ReqContractInfo roi = new ReqContractInfo();
            roi.CONTYPE = contractList[0].Contract_Type__c;//合同类型
            roi.CUSTOMERCODE = contractList[0].Customer__r.MDG_Customer_Code__c;//客户名称
            roi.customerName = contractList[0].Customer__r.Name;//客户编码
            roi.FINALYCUSTOMERCODE = contractList[0].Final_Customer__r.MDG_Customer_Code__c;//最终客户
            roi.finalyCustomerName = contractList[0].Final_Customer__r.Name;//最终客户名称
            roi.EXPORTINGCONTRY = contractList[0].Export_Country__r.Code__c;//出口国
            if(ptrList.size()==0) {
                roi.PAYMENTTERMS = contractList[0].Final_Customer_Payment_Terms__c;//收款协议
                roi.paymentTermsName = valueMap.get(contractList[0].Final_Customer_Payment_Terms__c);//收款协议名称
            }else{
                roi.PAYMENTTERMS = ptrList[0].Headquarters_Payment_Term__c;//收款协议
                roi.paymentTermsName = valueMap.get(ptrList[0].Headquarters_Payment_Term__c);//收款协议名称
            }
            
            roi.TRADETERMS = contractList[0].Trade_Terms__c;//贸易术语
            roi.tradeTermsName = valueTTMap.get(contractList[0].Trade_Terms__c);//贸易术语名称
            roi.CONTRACTCURRENCY = contractList[0].Currency__c;//币种
            roi.SHIPMENT = contractList[0].Shipment__c;//船期
            roi.RESTRICTIONCONDITION = contractList[0].Restrictions__c;//限制条件
            roi.LIMITINGREASON = contractList[0].Restriction_Reasons__c;//限制原因
            roi.REASON = contractList[0].Reason_of_Negative_Margin__c;//毛利为负原因
            roi.CRMID = contractList[0].Id;//CRM ID
            if(contractList[0].Delivery_Plant__c=='5070') {
                roi.userCode = System.Label.BPMUsercode;//CRM ID
            }

            if(contractList[0].Delivery_Plant__c=='3010') {
                roi.userCode = System.Label.MXBPMUsercode;//CRM ID
            }
            if(contractList[0].Delivery_Plant__c=='3011' || contractList[0].Delivery_Plant__c=='3020') {
                roi.userCode = System.Label.MXBPMUsercode;//CRM ID
            }
            roi.loadingPort = contractList[0].Loading_Port_New__r.Port_Information_Code__c;
            roi.portDestination = contractList[0].Destination_Port_New__r.Port_Information_Code__c;
            roi.CRMNO = contractList[0].Name;
            roi.otherRemark = contractList[0].Other_Remarks__c;
            Map<String,String> businessModelMap = Utility.getPicklistValueMap('Contracts__c','Business_Model__c');
            Map<String,String> bearingModelMap = Utility.getPicklistValueMap('Contracts_Detail__c','If_Pallet__c');
            //订单行赋值
            List<ReqContractItemInfo> contractIRList = new List<ReqContractItemInfo>();
            for( Contracts_Detail__c oi : contractItemList ){
                //新建订单行对象
                ReqContractItemInfo reqContractItemInfo = new ReqContractItemInfo();
                reqContractItemInfo.fileData = new List<FileData>();//附件信息
                reqContractItemInfo.productCode = oi.Product__r.Name;//存货编码
                reqContractItemInfo.productCNName = oi.Product__r.Chinese_Description__c;//产品中文描述
                reqContractItemInfo.productEnglishName = oi.Product_English_Name__c;//产品英文名称
                reqContractItemInfo.productName = oi.Product_Name__c;//产品名称（打印）

                reqContractItemInfo.businessModel = businessModelMap.get(contractList[0].Business_Model__c);//业务模式
                reqContractItemInfo.businessModelCode = contractList[0].Business_Model__c;//业务模式编码
                reqContractItemInfo.designatedProduct = oi.If_Designated_Products__c;//指定产品
                reqContractItemInfo.bearing = oi.If_Pallet__c;//是否打托
                reqContractItemInfo.packing = oi.Packing_Size__r.Pakcing_Size_Code__c;//包装规格
                reqContractItemInfo.packingName = oi.Packing_Size__r.Package_Specification_Name__c;//包装规格名称
                reqContractItemInfo.unit = oi.Unit__c;//单位
                reqContractItemInfo.quantity = oi.Qnty__c;//数量
                if(contractList[0].Transaction_Mode__c=='Final Customer') {//直接到客户
                    reqContractItemInfo.unitPrice = oi.BU_Sales_Price__c;
                    reqContractItemInfo.subsidiaryPrice = 0;
                }else{
                    if(oi.HQ_Contract_Unit_Price__c!=null) {
                        reqContractItemInfo.unitPrice = oi.HQ_Contract_Unit_Price__c;//单价
                    }else{
                        // reqContractItemInfo.unitPrice = oi.Unit_Price__c;
                        reqContractItemInfo.unitPrice = 0;
                    }
                    if(oi.BU_Sales_Price__c!=null) {
                        reqContractItemInfo.subsidiaryPrice = oi.BU_Sales_Price__c;//子公司销售价格
                    }else{
                        reqContractItemInfo.subsidiaryPrice = 0;//子公司销售价格
                    }
                }
                
                
                reqContractItemInfo.totalAmount = oi.Total_Amount__c;//总金额
                reqContractItemInfo.earliestDemand = oi.Earliest_Demand__c;//最早需货
                reqContractItemInfo.demandTime = oi.Demand_Time__c;//需货时间
                reqContractItemInfo.latestNeed = oi.Latest_need__c;//最晚需货
                reqContractItemInfo.latestDelivery = oi.Latest_Delivery_Date__c;//合同最晚交期
                reqContractItemInfo.commissionPrice = oi.Commission_Unit_Price__c;//佣金单价
                reqContractItemInfo.packagingCost = oi.Packing_cost__c;//包装成本
                reqContractItemInfo.palletCost = oi.Pallet_Cost__c;//托盘成本
                reqContractItemInfo.benchmarkPrice = oi.FOB_Price__c;//基准价格
                reqContractItemInfo.remark = oi.Other_Issue__c;
                reqContractItemInfo.otherMatters = '';//其他事项
                reqContractItemInfo.totalFreight = oi.Total_Freight_Cost__c;//海运费总成本
                reqContractItemInfo.discountPrice = oi.Discount_Unit_Price__c;//折扣单价
                reqContractItemInfo.packgeDe = oi.Packing_Size_Description__c;//包装规格英文描述
                reqContractItemInfo.heavyNucleus = oi.Recheck_Margin__c;//重核毛利
                reqContractItemInfo.detailId = oi.Id;//CRM 行编码
                reqContractItemInfo.trackingCode = oi.Tracking_Code__c;//跟踪编码
                for (Attachment__c att : oi.Attachments__r) {
                    FileData fd = new FileData();
                    fd.fileName = att.Name;
                    fd.url = att.Link__c;
                    reqContractItemInfo.fileData.add(fd);
                }
                contractIRList.add(reqContractItemInfo);
                reqContractItemInfo.targetArrivalDate = String.valueOf(oi.Target_Arrival_Date__c);//目标到港日
            }
            roi.ITEMS = contractIRList;
            resultinfo = roi;
            request.resultinfo = new List<ReqContractInfo>();
            request.resultinfo.add(resultinfo);
            requestBody = JSON.serialize(request);
            // requestBody = requestBody.replaceAll('null', '""');
            System.debug('requestBody++'+requestBody);
            requestBody = requestBody.replaceAll('null', '""');
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
                    Contracts__c upContract = new Contracts__c();
                    upContract.Id = Id;
                    if (syncReturnData.esbinfo.returnstatus == 'S') {
                        Contracts__c con = contractList[0];
                        // List<Contracts_Detail__c> contractItemUpdateList = new List<Contracts_Detail__c>();
                        // upContract.BPM_Contrct_Numbder__c = syncReturnData.resultinfo.BPMNUMBER;
                        // for (RespContractItemInfo respContractItemInfo : syncReturnData.resultinfo.ITEMS) {
                        //     if (String.isNotBlank(respContractItemInfo.detailId) && respContractItemInfo.detailId != null) {
                        //         Contracts_Detail__c upContractDetail = new Contracts_Detail__c();
                        //         upContractDetail.id = respContractItemInfo.detailId;
                        //         upContractDetail.BPM_Detail_Number__c = respContractItemInfo.BPMDETAILNUMBER;
                        //         contractItemUpdateList.add(upContractDetail);
                        //     }
                        // }
                        upContract.Sync_Status__c = 'Synchronized';
                        upContract.Sync_Failure_Reasons__c = '';
                        // Database.update(contractItemUpdateList);
                        update upContract;
                        //同步BPM后发送邮件
                        String body = '<div>'+System.Label.ContractSyncBPMBody+'</div>';
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        body = body.replaceAll('【合同编号】', con.Name);
                        Integer index = String.valueOf(URL.getOrgDomainUrl()).indexof('=')+1;
                        System.debug('28');
                        String recordURL = String.valueOf(URL.getOrgDomainUrl()).subString(index);
                        System.debug('30');
                        //body = body.replaceAll('【链接】',recordURL.replace(']','')+'/'+con.Id);
                        email.setHtmlBody(body);
                        //email.setSubject(System.Label.Contract_Sync_BPM+con.Name);
                        email.setSubject('New Contract '+con.Final_Customer__r.Name+' '+con.Name);
                        List<String> emailList = new List<String>();
                        if(con.Sales_Org__c=='3010'){ 
                            for(String userEmail:System.Label.MXContractSyncNoticeEmail.split(';'))
                                {if(userEmail != null){emailList.add(userEmail);}
                                }}
                        if(con.Sales_Org__c=='5070'){
                            if(String.isBlank(con.Final_Customer__r.HQ_Email__c)) {
                                for(String userEmail:System.Label.ARContractSyncNoticeEmail.split(';')){
                                    if(userEmail != null){emailList.add(userEmail);}
                                }
                            }else{
                                for(String userEmail:con.Final_Customer__r.HQ_Email__c.split(';')){
                                    if(userEmail != null){emailList.add(userEmail);}
                                }
                            }
                        }  
                        email.setToAddresses(emailList);
                        OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress];
                        if (owea.size() > 0 ) {
                            email.setOrgWideEmailAddressId(owea.get(0).Id);
                            // email.setSenderDisplayName(owea.get(0).DisplayName);
                        }
                        email.setUseSignature(false);
                        email.setBccSender(false);
                        if(!Test.isRunningTest())Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                        notifacation = false;
                    }
                    if(syncReturnData.esbinfo.returnstatus == 'E'){
                        isSuccess = false;
                        errorMessage = syncReturnData.esbinfo.returnmsg;
                        returnResult.isSuccess = false;
                        returnResult.message = syncReturnData.esbinfo.returnmsg;
                        upContract.Sync_Status__c = 'Synchronization error';
                        upContract.Sync_Failure_Reasons__c = syncReturnData.esbinfo.returnmsg;
                        update upContract;
                    }
                }else{
                    returnResult.isSuccess = false;
                    returnResult.message = responseBodyStr;
                    isSuccess = false;
                    errorMessage = responseBodyStr;
                    Contracts__c upContract = new Contracts__c();
                    upContract.Id = Id;
                    returnResult.isSuccess = false;
                    upContract.Sync_Status__c = 'Synchronization error';
                    upContract.Sync_Failure_Reasons__c = null;
                    update upContract;
                    // Utility.notificationUser(contractList[0].OwnerId,Id);
                }
            }else {
                returnResult.isSuccess = false;
                returnResult.message = responseBodyStr;
                isSuccess = false;
                errorMessage = responseBodyStr;
                Contracts__c upContract = new Contracts__c();
                upContract.Id = Id;
                returnResult.isSuccess = false;
                upContract.Sync_Status__c = 'Synchronization error';
                upContract.Sync_Failure_Reasons__c = ''+responseBody.getStatusCode();
                update upContract;
                // Utility.notificationUser(contractList[0].OwnerId,Id);
            }
        } catch (Exception e) {
            // if (contractList.size()>0 && !isClose) {
            //     Utility.notificationUser(contractList[0].OwnerId,Id);
            // }
            System.debug('错误信息'+e.getMessage()+e.getLineNumber());
            returnResult.isSuccess = false;
            returnResult.message = e.getMessage()+e.getLineNumber();
            isSuccess = false;
            errorMessage = e.getMessage()+e.getLineNumber();
            Contracts__c upContract = new Contracts__c();
            upContract.id = Id;
            returnResult.isSuccess = false;
            upContract.Sync_Status__c = 'Synchronization error';
            if((e.getMessage()+e.getLineNumber()).length()>245){
                upContract.Sync_Failure_Reasons__c = (e.getMessage()+e.getLineNumber()).substring(0,244) ;
            }else{
                upContract.Sync_Failure_Reasons__c = e.getMessage()+e.getLineNumber() ;
            }
            
            update upContract;
        }
        if(notifacation && !action) {
            Utility.notificationUser(contractList[0].OwnerId,contractList[0].Id);
        }
        InterfaceUtility.insertInterfaceLog('DraftContractSyncToBPM', 'CRM',
        'BPM', END_POINT, requestBody, isSuccess, false,
        responseBodyStr, errorMessage, 'POST', new List<String>{Id},
        '草稿合同同步BPM', '草稿合同同步BPM');
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
        public RespContractInfo resultinfo;
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
    
    public class RespContractInfo{
        public String crmId;//CRM合同ID
        public String BPMNumber;//BPM合同编号
        public String MSGTY;//消息类型
        public String MSGTX;//消息文本
        public List<RespContractItemInfo> ITEMS;//合同行项目表
    }
    
    public class RespContractItemInfo{
        public String detailId;//CRM 行编码
        public String BPMDetailNumber;//BPM行编码
    }
    
    public class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqContractInfo> resultinfo;
    }
    
    public class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
    }
    
    public class ReqContractInfo{
        public String conType;//合同类型
        public String customerCode;//客户编码
        public String customerName; //客户名称
        public String finalyCustomerName;//最终客户名称
        public String finalyCustomerCode;//最终客户
        public String exportingContry;//出口国
        public String paymentTerms;//收款协议
        public String paymentTermsName;//收款协议名称
        public String tradeTerms;//贸易术语
        public String tradeTermsName;//贸易术语名称
        public String contractCurrency;//币种
        public String shipment;//船期
        public String restrictionCondition;//限制条件
        public String limitingReason;//限制原因
        public String reason;//毛利为负原因
        public String crmId;//CRM ID
        public HeadInclude INCLUDE;//备用字段
        public String userCode;
        public String otherRemark;
        public String loadingPort;
        public String portDestination;
        public String CRMNO;
        public List<ReqContractItemInfo> ITEMS;//合同行项目表
    }
    
    public class HeadInclude{
        public String HEX01;//备用字段
        public String HEX02;//备用字段
        public String HEX03;//备用字段
        public String HEX04;//备用字段
        public String HEX05;//备用字段
        public String HEX06;//备用字段
    }
    
    public class ReqContractItemInfo{
        public String productCode;//存货编码
        public String productCNName;	//产品中文描述
        public String productEnglishName;//产品英文名称
        public String productName;//产品名称（打印）
        public String businessModel;//业务模式
        public String businessModelCode;//业务模式编码
        public String designatedProduct;//指定产品
        public String bearing;//是否打托
        public String packing;//包装规格
        public String packingName;	//包装规则名称
        public String unit;//单位
        public Decimal quantity;//数量
        public Decimal unitPrice;//单价
        public Decimal subsidiaryPrice;//子公司销售价格
        public Decimal totalAmount;//总金额
        public Date earliestDemand;//最早需货
        public Date demandTime;//需货时间
        public Date latestNeed;//最晚需货
        public Date latestDelivery;//合同最晚交期
        public Decimal commissionPrice;//佣金单价
        public Decimal packagingCost;//包装成本
        public Decimal palletCost;//托盘成本
        public Decimal benchmarkPrice;//基准价格
        public String otherMatters;//其他事项
        public Decimal totalFreight;//海运费总成本
        public Decimal discountPrice;//折扣单价
        public String packgeDe;//包装规格英文描述
        public String heavyNucleus;//重核毛利
        public String detailId;//CRM 行编码
        public String trackingCode;//跟踪编码
        public String remark;
        public ItemInclude INCLUDE;
        public List<FileData> fileData;
        public String targetArrivalDate;//目标到港日
    }

    public class FileData{
        public String fileName;
        public String url;
    }
    
    public class ItemInclude{
        public String IEX01;//备用字段
        public String IEX02;//备用字段
        public String IEX03;//备用字段
        public String IEX04;//备用字段
        public String IEX05;//备用字段
        public String IEX06;//备用字段
    }
    
}