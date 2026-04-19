public without sharing class ProductSyncToSAP {
    public static final String END_POINT = '';

    @AuraEnabled
    public static ReturnResult submitToSAP(String Id){
        ReturnResult returnResult = new ReturnResult();
        returnResult.isSuccess = true;

        Boolean isSuccess = true;
        String requestBody = '';
        String responseBodyStr = '';
        String errorMessage = '';
        
        try{
            RequestBody request = new RequestBody();
            request.esbinfo = new ReqESInfo();
            List<ReqProductInfo> resultinfoList = new List<ReqProductInfo>();
            //获取产品信息
            List<Product__c> proList=[SELECT Id,Name,Material_Type__c,Chinese_Description__c,
                                        English_Description__c,Spanish_Description__c,Portuguese_Description__c,
                                        Basic_Metering_Unit__c,Material_Group__c,Division__c,
                                        Cross_Factory_Material_Status__c,Effective_Start__c,Gross_Weight__c,
                                        Weight_Unit__c,Net_Weight__c,Business_Volume__c,Volumetric_Unit__c,
                                        Laboratory_Office__c,External_Material_Group__c,Industry_Standard_Description__c      
                                        FROM Product__c 
                                        WHERE Id =:Id];
            //获取产品销售视图类别
            List<Product_Sales_Info__c> proSalesInfoList=[SELECT Id,Sales_Organization__c,
                                        Distr_Channel__c,Default_Sales_Unit__c,Delivering_Plant__c,
                                        Material_Subject_Assign_Group__c,Project_Category_Group__c  
                                        FROM Product_Sales_Info__c 
                                        WHERE Product__c =: Id];

            //获取产品单位
            List<Product_Unit__c> proUnitList=[SELECT Id,Name,Basic_Unit__c,Molecule__c,Denominator__c     
                                        FROM Product_Unit__c 
                                        WHERE Product__c =: Id];
            
            
            ReqProductInfo rpi = new ReqProductInfo();
            rpi.matnr = proList[0].Name;
            rpi.mtart = proList[0].Material_Type__c;
            rpi.ltext_zh = proList[0].Chinese_Description__c;
            rpi.ltext_en = proList[0].English_Description__c;
            rpi.ltext_es = proList[0].Spanish_Description__c;
            rpi.ltext_pt = proList[0].Portuguese_Description__c;
            rpi.meins = proList[0].Basic_Metering_Unit__c;
            rpi.matkl = proList[0].Material_Group__c;
            rpi.spart = proList[0].Division__c;
            rpi.mstae = proList[0].Cross_Factory_Material_Status__c;
            rpi.mstde = proList[0].Effective_Start__c;
            rpi.brgew = proList[0].Gross_Weight__c;
            rpi.ntgew = proList[0].Weight_Unit__c;
            rpi.gewei = proList[0].Net_Weight__c;
            rpi.volum = proList[0].Business_Volume__c;
            rpi.voleh = proList[0].Volumetric_Unit__c;
            rpi.labor = proList[0].Laboratory_Office__c;
            rpi.extwg = proList[0].External_Material_Group__c;
            rpi.normt = proList[0].Industry_Standard_Description__c;
            

            //产品销售视图赋值
            List<SalesInfoRow> salesInfoList = new List<SalesInfoRow>();
            for(Product_Sales_Info__c psi : proSalesInfoList){
                SalesInfoRow sir = new SalesInfoRow();
                sir.vkorg = psi.Sales_Organization__c;
                sir.vtweg = psi.Distr_Channel__c;
                sir.vrkme = psi.Default_Sales_Unit__c;
                sir.dwerk = psi.Delivering_Plant__c;
                sir.ktgrm = psi.Material_Subject_Assign_Group__c;
                sir.mtpos = psi.Project_Category_Group__c;
                salesInfoList.add(sir);
            }
            rpi.salesInfo = salesInfoList;

            //产品单位赋值
            List<ProductUnitRow> pUnitList = new List<ProductUnitRow>();
            for(Product_Unit__c pu : proUnitList){
                ProductUnitRow pur = new ProductUnitRow();
                pur.meinh = pu.Name;
                pur.meins = pu.Basic_Unit__c;
                pur.umrez = pu.Molecule__c+'';
                pur.umren = pu.Denominator__c+'';
                pUnitList.add(pur);
            }
            rpi.productUnit = pUnitList;


            resultinfoList.add(rpi);
            request.resultinfo = resultinfoList;

            requestBody = JSON.serialize(request);
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
                    if(syncReturnData.esbinfo.returnstatus == 'E'){
                        returnResult.isSuccess = false;
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
            System.debug('错误信息'+e.getMessage()+e.getLineNumber());
            returnResult.isSuccess = false;
            returnResult.message = e.getMessage()+e.getLineNumber();
            isSuccess = false;
            errorMessage = e.getMessage()+e.getLineNumber();
        }
        InterfaceUtility.insertInterfaceLog('ProductSyncToSAP', 'CRM',
                    'SAP', END_POINT, requestBody, isSuccess, false,
                    responseBodyStr, errorMessage, 'POST', new List<String>{Id},
                    '产品主数据同步SAP', '产品主数据同步SAP');
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
        public List<ReqProductInfo> resultinfo;
    }

    public class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
    }

    public class ReqProductInfo{
        public String matnr;//物料号
        public String mtart;//物料类型
        public String ltext_zh;//中文描述
        public String ltext_en;//英文描述
        public String ltext_es;//西语描述
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
        public List<SalesInfoRow> salesInfo;//销售视图
        public List<ProductUnitRow> productUnit;//产品单位
    }

    public class SalesInfoRow{
        public String vkorg;//销售组织
        public String vtweg;//分销渠道
        public String vrkme;//默认销售单位
        public String dwerk;//交货工厂
        public String ktgrm;//物料科目分配组
        public String mtpos;//项目类别组
    }

    public class ProductUnitRow{
        public String meinh;//可选单位
        public String meins;//基本单位
        public String umrez;//转换分子
        public String umren;//转换分母
    }


}