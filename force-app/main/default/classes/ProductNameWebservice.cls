/**
 * @description       : 商品名称同步到CRM
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 10-24-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-20-2025   Gerry   Initial Version
**/

@RestResource(urlMapping='/ProductNameWebservice')
global without sharing class ProductNameWebservice {
    global class RequestBody {
        public ReqESInfo esbinfo;
        public List<ProductName> resultinfo;
    }
    
    global class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
    }
    
    global class ProductName{
        public String mandt;//客户端
        public String zname;//商品名称
        public String matnr;//产品编码
        public String vkorg;//销售组织
        public String vtweg;//分销渠道
        public String werks;//工厂
        public String kunnr;//客户
        public String loekz;//删除标记
    }
    global class ResponseBody {
        public RespESInfo esbinfo;
        public List<ProductNameReturn> resultinfo;
    }
    
    global class ProductNameReturn{
        public String zname;//商品名称
        public String matnr;//产品编码
        public String vkorg;//销售组织
        public String vtweg;//分销渠道
        public String werks;//工厂
        public String kunnr;//客户
        public String msgtx;//消息文本 
        public String msgty;//消息类型 S:成功 E:失败
    }
    global class RespESInfo{
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
        
        response.esbinfo.returnstatus = 'S';
        response.esbinfo.returncode = 'S001';
        response.esbinfo.returnmsg = '';
        response.esbinfo.attr1 = 'SAP';
        response.esbinfo.attr2 = 'SFCRM';
        response.resultinfo = new List<ProductNameReturn>();
        try {
            System.debug('bodyStrJson1==' + bodyStrJson);
            RequestBody reqBody = (RequestBody) JSON.deserialize(bodyStrJson, RequestBody.class);
            List<Product_Name__c> pnList = new List<Product_Name__c>();

            Set<String> accIdSet = new Set<String>();
            for(ProductName pnData : reqBody.resultinfo) {//获取客户mdg code
                if(String.isNotBlank(pnData.kunnr)) {
                    accIdSet.add(pnData.kunnr);
                }
                
            }

            Map<String,String> accMap = new Map<String,String>();
            if(accIdSet.size()>0) {
                for(Account acc  : [SELECT Id, MDG_Customer_Code__c FROM Account WHERE MDG_Customer_Code__c IN :accIdSet]) {
                    accMap.put(acc.MDG_Customer_Code__c, acc.Id);
                }
            }
            

            Map<Integer, ProductName> indexToProductName = new Map<Integer, ProductName>();
            Integer index = 0;
            for(ProductName pnData : reqBody.resultinfo) {
                Product_Name__c pn = new Product_Name__c();
                
                pn.Customer__c = accMap.get(pnData.kunnr);
                pn.Name = pnData.zname;
                if(String.isNotBlank(pnData.kunnr)) {
                    pn.External_Id__c = pnData.matnr+'_'+pnData.vkorg+'_'+pnData.vtweg+'_'+pnData.werks+'_'+ pnData.zname+'_'+accMap.get(pnData.kunnr);
                }else{
                    pn.External_Id__c = pnData.matnr+'_'+pnData.vkorg+'_'+pnData.vtweg+'_'+pnData.werks+'_'+ pnData.zname+'_';
                }
                Product_Sales_Info__c psi = new Product_Sales_Info__c();
                psi.External_Id__c = pnData.matnr+'_'+pnData.vkorg+'_'+pnData.vtweg+'_'+pnData.werks;
                pn.Product_Sales_Info__r = psi;
                if(String.isNotBlank(pnData.loekz)) {//删除标记
                    pn.Is_Delete__c = true;
                }else{
                    pn.Is_Delete__c = false;
                }
                //illion 20250805 start
                pn.Product_Combo__c = false;
                //illion 20250805 end
                pnList.add(pn);
                indexToProductName.put(index, pnData);
                index++;
            }
            System.debug('pnList====>'+pnList);
            if(pnList.size()>0) {
                Database.UpsertResult[] resultList = Database.upsert(pnList,Product_Name__c.fields.External_Id__c,false);
                for(Integer i = 0; i < resultList.size(); i++) {//部分功能处理
                    Database.UpsertResult result = resultList[i];
                    ProductName originalData = indexToProductName.get(i);
                    ProductNameReturn returnData = new ProductNameReturn();
                    returnData.matnr = convertNull(originalData.matnr);
                    returnData.vkorg = convertNull(originalData.vkorg);
                    returnData.vtweg = convertNull(originalData.vtweg);
                    returnData.werks = convertNull(originalData.werks);
                    returnData.kunnr = convertNull(originalData.kunnr);
                    returnData.zname = convertNull(originalData.zname);
                    
                    if(!result.isSuccess()) {
                        isPartSuccess = true;
                        for(Database.Error error : result.getErrors()) {
                            errorMsg = error.getMessage();
                        }
                        errorMsg = translateError(errorMsg);
                        errorMsg = errorMsg+' ['+returnData.matnr+']['+returnData.vkorg+']['+returnData.vtweg+']';
                        returnData.msgty = 'E';
                        returnData.msgtx = errorMsg;
                        response.esbinfo.returnstatus = 'E';
                        response.esbinfo.returncode = 'E001';
                    } else {
                        returnData.msgty = 'S';
                        returnData.msgtx = 'Success';
                    }
                    response.resultinfo.add(returnData);
                }
            }
        } catch (Exception e) {
            Database.rollback(sp);
            errorMsg = InterfaceUtility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
            isSuccess = false;
            response.esbinfo.returnstatus = 'E';
            response.esbinfo.returncode = 'E001';
            response.esbinfo.returnmsg = errorMsg;
        }
        InterfaceUtility.insertInterfaceLog('ProductNameWebservice', 'SAP', 'CRM',
        'ProductNameWebservice', bodyStrJson, isSuccess, isPartSuccess,
        JSON.serialize(response), errorMsg, 'POST', dataIdList, 'Upsert', 'SAP商品名称同步到CRM'
            );
        response.esbinfo.responsetime = String.valueOf(System.now());
        return response;
    }

    //转换'' to 0
    private static String convertNull(String str) {
        String strConvert;
        if(str == null) {
            strConvert = '';
        }else{
            strConvert = str;
        } 
        return strConvert;
    }

    public static String translateError(String errorMsg) {
        if (errorMsg.contains('field External_Id__c in entity Product_Sales_Info__c')) {
            return 'Product Sales View is not extended for the';
        }else{
            return errorMsg;
        }
    }
}