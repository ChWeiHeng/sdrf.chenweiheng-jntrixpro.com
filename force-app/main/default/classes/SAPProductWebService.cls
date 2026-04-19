/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 08-18-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-18-2025   Gerry   Initial Version
**/
@RestResource(urlMapping='/SAPProductWebService')
global without sharing class SAPProductWebService {
    global class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqProductInfo> resultinfo;
    }

    global class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
    }

    global class ReqProductInfo{
        public String matnr;//物料号
        public String werks;//工厂
        public String mtart;//物料类型
        public String ltext_1;//中文描述
        public String ltext_e;//英文描述
        public String ltext_s;//西语描述
        public String ltext_pt;//葡语描述
        public String meins;//基本计量单位
        public String matkl;//物料组
        public String spart;//产品组
        public String mstae;//跨工厂的物料状态
        public String mstde;//有效起始期
        public String brgew;//毛重
        public String ntgew;//重量单位
        public String gewei;//净重
        public String volum;//业务量
        public String voleh;//体积单位
        public String labor;//实验室/办公室
        public String extwg;//外部物料组
        public String normt;//行业标准描述
        public List<SalesInfoRow> salev;//销售视图
        public List<ProductUnitRow> units;//产品单位
        public List<PriceNameRow> princename;//报价名称产品关系
    }


    global class SalesInfoRow{
        public String werks;
        public String vkorg;//销售组织
        public String vtweg;//分销渠道
        public String vrkme;//默认销售单位
        public String dwerk;//交货工厂
        public String ktgrm;//物料科目分配组
        public String mtpos;//项目类别组
        public String prodh;//产品层级
    }

    global class ProductUnitRow{
        public String meinh;//可选单位
        public String meins;//基本单位
        public String umrez;//转换分子
        public String umren;//转换分母
    }

    global class PriceNameRow{
        public String spras;//语言代码
        public String sprastxt;//语言文本
        public String ltext;//报价表名称
    }

    /**
     * SAP 产品主数据单同步接口
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
        ResponseBody response = returnData(respTime, isSuccess, errorMsg);
        InterfaceUtility.insertInterfaceLog('SAPProductWebService', 'SAP', 'CRM',
                '/services/apexrest/receiveDataFromExternal/  requestCode:SAP002', bodyStrJson, isSuccess, false,
                JSON.serialize(response), errorMsg, 'POST', dataIdList, 'Upsert', 'SAP同步产品主数据至CRM'
        );
        return response;
        
    }

    public static void feedbackOrderInfo(List<ReqProductInfo> resultinfo) {
        Map<String,Product__c> proList = new Map<String,Product__c>();
        Map<String,Product_Sales_Info__c> proSalesList = new Map<String,Product_Sales_Info__c>();
        Map<String,Product_Unit__c> proUnitList = new Map<String,Product_Unit__c>();
        Map<String,Quote_Name_Relationship__c> quoteNameRelationList = new Map<String,Quote_Name_Relationship__c>();
        MAP<String,Product_Name__c> proNameList = new MAP<String,Product_Name__c>();
        Set<String> proSAPCodeSet = new Set<String>();
        for(ReqProductInfo rpi : resultinfo){
            proSAPCodeSet.add(rpi.matnr);
        }

        // List<Product__c> productList = [SELECT Id,Name 
        //                                 FROM Product__c 
        //                                 WHERE Name IN: proSAPCodeSet];
        // Map<String,String> proIdNameMap = new Map<String,String>();
        // if (productList.size()>0) {
        //     for(Product__c pr : productList){
        //         proIdNameMap.put(pr.Name,pr.Id);
        //     }
        // }

        for(ReqProductInfo rpi : resultinfo){
            Product__c pr = new Product__c();
            // if (proIdNameMap.size()>0 && proIdNameMap.containsKey(rpi.matnr)) {
            //     pr.Id = proIdNameMap.get(rpi.matnr);
            // }
            pr.Name = rpi.matnr;
            
            pr.Material_Type__c = rpi.mtart;
            pr.Chinese_Description__c = rpi.ltext_1;
            pr.English_Description__c = rpi.ltext_e;
            pr.Spanish_Description__c = rpi.ltext_s;
            pr.Portuguese_Description__c = rpi.ltext_pt;
            pr.Basic_Metering_Unit__c = rpi.meins;
            pr.Material_Group__c = rpi.matkl;
            pr.Division__c = rpi.spart;
            pr.Cross_Factory_Material_Status__c = rpi.mstae;
            pr.Effective_Start__c = rpi.mstde;
            pr.Gross_Weight__c = rpi.brgew;
            pr.Weight_Unit__c = rpi.gewei;
            pr.Net_Weight__c = rpi.ntgew;
            pr.Business_Volume__c = rpi.volum;
            pr.Volumetric_Unit__c = rpi.voleh;
            pr.Laboratory_Office__c = rpi.labor;
            pr.External_Material_Group__c = rpi.extwg;
            pr.Industry_Standard_Description__c = rpi.normt;
            pr.External_Id__c = rpi.matnr;
            if(rpi.units!=null) {
                for (ProductUnitRow pur : rpi.units) {
                    Product_Unit__c pu = new Product_Unit__c();
                    pu.External_Id__c = rpi.matnr+'_'+pur.meinh;
                    pu.Product_Sales_Unit__c = pur.meinh;
                    pu.Basic_Unit__c = pur.meins;
                    pu.Molecule__c = String.isBlank(pur.umrez) ? 0 : Decimal.valueOf(pur.umrez);
                    pu.Denominator__c = String.isBlank(pur.umren) ? 0 : Decimal.valueOf(pur.umren);
                    Product__c prPa = new Product__c();
                    prPa.External_Id__c = rpi.matnr;
                    pu.Product__r = prPa;
                    pu.Conversion_Coefficient__c = pu.Molecule__c/pu.Denominator__c;
                    proUnitList.put(pu.External_Id__c,pu);
                }
            }
            
            if(rpi.princename!=null) {
                for (PriceNameRow pnr : rpi.princename) {
                    Quote_Name_Relationship__c quoteNameRelation= new Quote_Name_Relationship__c();
                    quoteNameRelation.Quote_Name__c =pnr.ltext;
                    quoteNameRelation.Lang_Text__c  =pnr.sprastxt;
                    Product__c prPa = new Product__c();
                    prPa.External_Id__c = rpi.matnr;
                    quoteNameRelation.Products__r = prPa;
                    quoteNameRelation.External_Id__c=rpi.matnr+pnr.spras;
                    quoteNameRelationList.put(quoteNameRelation.External_Id__c,quoteNameRelation);
                }
            }
            if(rpi.salev!=null) {
                for (SalesInfoRow sir : rpi.salev) {
                    Product_Sales_Info__c psi = new Product_Sales_Info__c();
                    if(String.isNotBlank(rpi.mstae) && rpi.mstae=='Z1') {
                        psi.Status__c = 'Off Shelves';
                    }else{
                        psi.Status__c = 'On Shelves';
                    }
                    Product__c prPa = new Product__c();
                    prPa.External_Id__c = rpi.matnr;
                    psi.Factory__c = rpi.werks;
                    psi.External_Id__c = rpi.matnr+'_'+sir.vkorg+'_'+sir.vtweg+'_'+rpi.werks;
                    psi.Sales_Organization__c = sir.vkorg;
                    psi.Distr_Channel__c = sir.vtweg;
                    if (String.isNotBlank(sir.vrkme)) {
                        psi.Default_Sales_Unit__c = sir.vrkme;
                    }else{
                        psi.Default_Sales_Unit__c = pr.Basic_Metering_Unit__c;
                    }
                    
                    Product_Unit__c pu = new Product_Unit__c();
                    if (String.isNotBlank(sir.vrkme)) {
                        pu.External_Id__c = rpi.matnr+'_'+sir.vrkme;
                    }else{
                        pu.External_Id__c = rpi.matnr+'_'+pr.Basic_Metering_Unit__c;
                    }
                    psi.Product_Unit__r = pu;
                    if(String.isNotBlank(sir.dwerk)) {
                        psi.Delivering_Plant__c = sir.dwerk;
                    }else{
                        psi.Delivering_Plant__c = rpi.werks;
                    }
                    
                    psi.Material_Subject_Assign_Group__c = sir.ktgrm;
                    psi.Project_Category_Group__c = sir.mtpos;
                    psi.Product__r = prPa;
                    psi.Product_Group__c = sir.prodh;
                    proSalesList.put(psi.External_Id__c,psi);

                    // Model B产品自动生成商品名
                    if ( psi.Sales_Organization__c == '5070' && psi.Factory__c == '5070' && pr.English_Description__c!=null)                     
                    {
                        Product_Name__c pn = new Product_Name__c();
                        Product_Sales_Info__c proRe = new Product_Sales_Info__c();
                        proRe.External_Id__c = psi.External_Id__c;
                        pn.Product_Sales_Info__r = proRe;
                        pn.Name = pr.English_Description__c;
                        // pn.Material_Code__c+'_'+pn.Sales_Org__c+'_'+pn.Distr_Channel__c+'_'+pn.Plan__c+'_'+pn.Name+'_';
                        pn.External_Id__c = psi.External_Id__c+'_'+pr.English_Description__c+'_';
                        proNameList.put(pn.External_Id__c,pn);
                    }
                }
            }
            

            
            proList.put(pr.External_Id__c,pr);
        }


        if (proList.size() > 0) {
            Database.upsert(proList.values(),Product__c.fields.External_Id__c);
        }
        if (proUnitList.size() > 0) {
            Database.upsert(proUnitList.values(),Product_Unit__c.fields.External_Id__c);
        }
        if (quoteNameRelationList.size() > 0) {
            Database.upsert(quoteNameRelationList.values(),Quote_Name_Relationship__c.fields.External_Id__c);
        }
        if (proSalesList.size() > 0) {
            Database.upsert(proSalesList.values(),Product_Sales_Info__c.fields.External_Id__c);
        }

        if (proNameList.size()>0) {
            Utility.IgnoreAction(true,false,'SAPProductWebService'); 
            Database.upsert(proNameList.values(),Product_Name__c.fields.External_Id__c);
            Utility.IgnoreAction(false,false,'SAPProductWebService'); 
        }
    }

    
    global static ResponseBody returnData(String requestTime,Boolean status,String errorMsg) {
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
        re.resultinfo = new RespCustomerInfo();
        RespCustomerInfo rci = new RespCustomerInfo();
        if (status) {
            rci.msgty = 'S';
            rci.msgtx = '处理成功';
        }else{
            rci.msgty = 'E';
            rci.msgtx = errorMsg;
        }
        re.resultinfo = rci;
        return re;
    }
    global class ResponseBody {
        public RespESInfo esbinfo;
        public RespCustomerInfo resultinfo;
    }

    global class RespCustomerInfo{
        public String msgty;//处理状态
        public String msgtx;//错误信息
        // public List<ErrorData> errorDataList;
    }

    // global class ErrorData {
    //     public String code;//唯一值
    //     public String error;//错误信息
    // }

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
}