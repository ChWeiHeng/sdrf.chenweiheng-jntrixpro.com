/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 02-13-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-01-2025   Gerry   Initial Version
**/
public without sharing class CustomerSalesInfoSyncToSAP {

    

    @Future(callout=true)
    public static void submitToSAPFutrue(String Id,String type){
        submitToSAP(Id,type);
    }

    @AuraEnabled
    public static ReturnResult submitToSAP(String Id,String type){
        String END_POINT;
        if (type=='I') {
            END_POINT = 'CustomerSalesInfoNEW';
        }
        if(type=='U') {
            END_POINT = 'CustomerSalesInfoUpdate';
        }
        ReturnResult returnResult = new ReturnResult();
        returnResult.isSuccess = true;

        Boolean isSuccess = true;
        String requestBody = '';
        String responseBodyStr = '';
        String errorMessage = '';
        List<Customer_Sales_Info__c> accList;
        try{
            RequestBody request = new RequestBody();
            request.esbinfo = new ReqESInfo();
            request.esbinfo.attr1 = 'SFCRM';
            request.esbinfo.attr2 = 'SAP';
            List<ReqCustomerSalesInfo> resultinfoList = new List<ReqCustomerSalesInfo>();
            //获取客户销售信息
            accList=[SELECT Id,Name,Customer__r.MDG_Customer_Code__c,
                        Sales_Org__c,Distr_Channel__c,Customer__c,
                        Division__c,Sales_District__c,Sales_Office__c,
                        Sales_Group__c,Currency__c,Price_Group__c,Cust_Pric_Procedure__c,
                        Delivering_Plant__c,Shipping_Conditions__c,Terms_Of_Payment__c,
                        Acct_Assmt_Grp_Cust__c,Incoterms__c,Inco_Location1__c,Payment_method__c 
                        ,Business_model__c,Customer__r.Customer_Group__c,Reconciliation_Account__c,OwnerId   ,Is_Freeze__c,isSync__c
                    FROM 
                        Customer_Sales_Info__c 
                    WHERE Id =:Id];
            String customerId = accList[0].Customer__c;
            //获取客户税收类别
            List<Customer_Tax_Category__c> cusTaxList=[SELECT Id,Country_District__c,
                                        Tax_Category__c,Tax_Category_Name__c,Tax_Category_Master_Data__r.Name,Tax_Category_Master_Data__r.Country_Code__c 
                                        FROM Customer_Tax_Category__c 
                                        WHERE Sales_View__c =: Id];

            // //获取客户财务视图
            // List<Customer_Financial_Info__c> cusFicList=[SELECT Id,Customer__r.MDG_Customer_Code__c,
            //                             Company_Code__c,Reconciliation_Account__c  
            //                             FROM Customer_Financial_Info__c 
            //                             WHERE Customer__c =: customerId];
            
            //获取客户税号类别
            List<Customer_Tax_Number_Category__c> cusTaxNumList=[SELECT Id,Customer__r.MDG_Customer_Code__c,
                                        Tax_Number_Master_Data__r.Code__c,Long_Tax_Number__c   
                                        FROM Customer_Tax_Number_Category__c 
                                        WHERE Customer__c =: customerId];
            
            ReqCustomerSalesInfo rcsi = new ReqCustomerSalesInfo();
            rcsi.partner = accList[0].Customer__r.MDG_Customer_Code__c;
            rcsi.ktokk = accList[0].Customer__r.Customer_Group__c;
            rcsi.flucu01 = new List<salesInfo>();
            salesInfo si = new salesInfo();
            si.kunnr = accList[0].Customer__r.MDG_Customer_Code__c;
            si.vkorg = accList[0].Sales_Org__c;
            si.vtweg = accList[0].Distr_Channel__c;
            si.spart = accList[0].Division__c;
            si.bzirk = accList[0].Sales_District__c;
            // si.kdgrp = accList[0].Customer__r.Customer_Group__c;
            si.kdgrp = '';
            si.kvgr1 = accList[0].Payment_method__c;
            si.kvgr3 = accList[0].Business_model__c;
            si.vkbur = accList[0].Sales_Office__c;
            si.vkgrp = accList[0].Sales_Group__c;
            si.waers = accList[0].Currency__c;
            si.konda = accList[0].Price_Group__c;
            si.kalks = accList[0].Cust_Pric_Procedure__c;
            si.vwerk = accList[0].Delivering_Plant__c;
            si.vsbed = accList[0].Shipping_Conditions__c;
            si.zterm = accList[0].Terms_Of_Payment__c;
            si.ktgrd = accList[0].Acct_Assmt_Grp_Cust__c;
            si.inco1 = accList[0].Incoterms__c;
            si.inco2_L = accList[0].Inco_Location1__c;
            if(accList[0].Is_Freeze__c=='00') {
                si.AUFSD = '';
            }else{
                si.AUFSD = accList[0].Is_Freeze__c;
            }
            
            si.TAXKDS = new List<TaxRow>();
            
            //客户税收类别赋值
            if (
                !accList[0].isSync__c ||
                accList[0].Sales_Org__c=='3010' ||
                accList[0].Sales_Org__c=='3020' ||
                accList[0].Sales_Org__c=='2100'
            ) {
                List<TaxRow> taxList = new List<TaxRow>();
                for(Customer_Tax_Category__c ctc : cusTaxList){
                    TaxRow tr = new TaxRow();
                    tr.aland = ctc.Tax_Category_Master_Data__r.Country_Code__c;
                    tr.taxkd = ctc.Tax_Category__c;
                    tr.taxkd = tr.taxkd.substring(0,tr.taxkd.indexof('-'));
                    tr.tatyp = ctc.Tax_Category_Master_Data__r.Name;
                    taxList.add(tr);
                }
                si.TAXKDS = taxList;
            }
            
            rcsi.flucu01.add(si);
            rcsi.flucu00 = new List<FinancialRow>();
            //客户财务信息赋值
            List<FinancialRow> ficList = new List<FinancialRow>();
            // for(Customer_Financial_Info__c cfi : cusFicList){
            FinancialRow fr = new FinancialRow();
            fr.kunnr = accList[0].Customer__r.MDG_Customer_Code__c;
            fr.bukrs = accList[0].Sales_Org__c;
            fr.akont = accList[0].Reconciliation_Account__c;
            ficList.add(fr);
            // }
            rcsi.flucu00 = ficList;

            rcsi.taxnums = new List<TaxNumberRow>();
            //客户税号类别赋值
            List<TaxNumberRow> tnrList = new List<TaxNumberRow>();
            for(Customer_Tax_Number_Category__c ctnc : cusTaxNumList){
                TaxNumberRow tnr = new TaxNumberRow();
                tnr.partner = ctnc.Customer__r.MDG_Customer_Code__c;
                tnr.taxtype = ctnc.Tax_Number_Master_Data__r.Code__c;
                tnr.taxnumxl = ctnc.Long_Tax_Number__c;
                tnrList.add(tnr);
            }
            rcsi.taxnums = tnrList;

            resultinfoList.add(rcsi);
            request.resultinfo = resultinfoList;
            requestBody = JSON.serialize(request);
            requestBody = requestBody.replaceAll('null', '\"\"');
            System.debug('requestBody++'+requestBody);
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
                    Customer_Sales_Info__c upcsi = new Customer_Sales_Info__c();
                    upcsi.Id = Id;
                    if (syncReturnData.esbinfo.returnstatus == 'S') {
                        upcsi.Sync_Status__c = 'Synchronized';
                        upcsi.Sync_Failure_Reasons__c = '';
                        upcsi.isSync__c = true;
                    }
                    if(syncReturnData.esbinfo.returnstatus == 'E'){
                        upcsi.Sync_Status__c = 'Synchronization Failure';
                        upcsi.Sync_Failure_Reasons__c = syncReturnData.resultinfo[0].msgtx;
                        isSuccess = false;
                        errorMessage = syncReturnData.esbinfo.returnmsg;
                        returnResult.isSuccess = false;
                        returnResult.message = syncReturnData.esbinfo.returnmsg;
                        Utility.notificationUser(accList[0].OwnerId,Id);
                    }
                    update upcsi;
                }else{
                    returnResult.isSuccess = false;
                    returnResult.message = responseBodyStr;
                    isSuccess = false;
                    errorMessage = responseBodyStr;
                    Customer_Sales_Info__c upcsi = new Customer_Sales_Info__c();
                    upcsi.Id = Id;
                    upcsi.Sync_Status__c = 'Synchronization Failure';
                    upcsi.Sync_Failure_Reasons__c = 'null';
                    update upcsi;
                    Utility.notificationUser(accList[0].OwnerId,Id);
                }
                
            } else {
                returnResult.isSuccess = false;
                returnResult.message = responseBodyStr;
                isSuccess = false;
                errorMessage = responseBodyStr;
                Customer_Sales_Info__c upcsi = new Customer_Sales_Info__c();
                upcsi.Id = Id;
                upcsi.Sync_Status__c = 'Synchronization Failure';
                upcsi.Sync_Failure_Reasons__c = ''+responseBody.getStatusCode();
                update upcsi;
                Utility.notificationUser(accList[0].OwnerId,Id);
            }

        }
        catch (Exception e) {
            if (accList.size()>0) {
                Utility.notificationUser(accList[0].OwnerId,Id);
            }
            Customer_Sales_Info__c upcsi = new Customer_Sales_Info__c();
            upcsi.Id = Id;
            upcsi.Sync_Status__c = 'Synchronization Failure';
            upcsi.Sync_Failure_Reasons__c = e.getMessage()+e.getLineNumber();
            update upcsi;
            System.debug('错误信息'+e.getMessage()+e.getLineNumber());
            returnResult.isSuccess = false;
            returnResult.message = e.getMessage()+e.getLineNumber();
            isSuccess = false;
            errorMessage = e.getMessage()+e.getLineNumber();
        }
        InterfaceUtility.insertInterfaceLog('CustomerSalesInfoSyncToSAP', 'CRM',
                    'SAP', END_POINT, requestBody, isSuccess, false,
                    responseBodyStr, errorMessage, 'POST', new List<String>{Id},
                    '客户销售视图同步SAP', 'CRM同步客户销售视图至SAP');
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
        public String msgty;//处理状态
        public String msgtx;//错误信息
    }

    public class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqCustomerSalesInfo> resultinfo;

    }

    public class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
        public String attr1;//发送方
        public String attr2;//接受方

    }
    public class ReqCustomerSalesInfo {
        public String ktokk;
        public String partner;
        public List<FinancialRow> flucu00;
        public List<TaxNumberRow> taxnums;
        public List<salesInfo> flucu01;
    }
    public class salesInfo{
        public String kunnr;//客户编码
        public String vkorg;//销售组织
        public String vtweg;//分销渠道
        public String spart;//产品组
        public String bzirk;//销售地区
        public String kdgrp;//客户组
        public String kvgr1;//客户组1
        public String kvgr3;//客户组3
        public String vkbur;//销售部门
        public String vkgrp;//销售组
        public String waers;//币种
        public String konda;//价格组
        public String kalks;//Cust.Price.过程
        public String vwerk;//交货工厂
        public String vsbed;//装运条件
        public String zterm;//付款条件
        public String ktgrd;//客户科目分配组
        public String inco1;//国际贸易条款
        public String inco2_L;//国贸条款位置 1
        public String AUFSD;//冻结
        public List<TaxRow> TAXKDS;//税收类别
    }

    public class TaxRow{
        public String aland;//国家代码
        public String tatyp;//税分类
        public String taxkd;//税收类别编码
    }

    public class FinancialRow{
        public String kunnr;//客户编码
        public String bukrs;//公司代码
        public String akont;//统驭科目
    }

    public class TaxNumberRow{
        public String partner;//客户编码
        public String taxtype;//税号类别
        public String taxnumxl;//长税号
    }
}