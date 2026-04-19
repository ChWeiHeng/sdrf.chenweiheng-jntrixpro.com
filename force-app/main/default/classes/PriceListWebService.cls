@RestResource(urlMapping='/PriceListWebService')
global without sharing class PriceListWebService {
    public class RequestBody {
        public ReqESInfo esbinfo;
        public ReqOrderInfo resultinfo;
    }
    public class ReqESInfo{
        public String instid;//接口编号
        public String requesttime;//请求时间
    }

    public class ReqOrderInfo {
        public String NO;
        public List<BodyObject> body;
    }

    public class BodyObject{
        public String unit;
        public String recordId;//	明细ID，唯一		NUMBER
        public String HXZF;//	活性组分编码		VARCHAR2(20)
        public String PRODUCTLIST;//	英文产品名称		VARCHAR2(200)
        public String PRODUCTCODE;//	产品编码		VARCHAR2(50)
        public String PRODUCTNAME;//	产品名称		VARCHAR2(200)
        public String BUSINESSMODEL;//	商业模式		VARCHAR2(200)
        public Decimal GROSSPROFIT;//	正常毛利		NUMBER(10,2)
        public Decimal ADJUSTEDGROSSMARGIN;//	调整后毛利		NUMBER(10,2)
        
        public String REGULARDELIVERYTIME;//	标准交货周期		VARCHAR2(20)
        public Decimal THREEWEEKSBASICPRICE;//	前3周基准价		NUMBER(18,8)
        
        public Decimal TWOWEEKSBASICPRICE;//	前2周基准价		NUMBER(18,8)
        public Decimal ONEWEEKSBASICPRICE;//	前1周基准价		NUMBER(18,8)
        public Decimal LASTWEEKPRICE;//	原药上周价格		NUMBER(18,8)
        public String COST;//	技术或配方交易成本
        public Decimal FORMULARMBCOST;//	人民币成本		NUMBER(18,8)
        public Decimal FORMULABASICPRICE;//	基准价格		NUMBER(18,8)
        public Decimal BASICPRICE;//	基准价格		NUMBER(18,8)
        public String  OPERATIONHELPER;//	操作指引		VARCHAR2(2000)
        
        public String  PURDEPINFO;//	市场行情
        
        public Date UPDATEDATE;//	更新日期		DATE
        public String  RESPONSIBLE;//	业务员		VARCHAR2(20)
        public String  RESPONSIBLEACCOUNT;//	业务员账号		VARCHAR2(20)
        public String  PRODUCTOVERVIEW;//	产品回顾		VARCHAR2(2000)
        public Decimal THISWEEKOTHERCOST;//	本周其他费用		NUMBER(18,2)
        public Decimal LASTWEEKOTHERCOST;//	上周其他费用		NUMBER(18,2)
        public Decimal DIFF;//	其他费用差值		NUMBER(18,2)
        public String check;
        public String IndianOrigin;
    }
    @HttpPost
    global static SAPProductWebService.ResponseBody doPost() {
        String respTime = String.valueOf(Datetime.now());
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String bodyStrJson = req.requestBody.toString();
        List<String> dataIdList = new List<String>();
        Boolean isSuccess = true;
        Savepoint sp = Database.setSavepoint();
        String errorMsg;
        try {
            System.debug('bodyStrJson1==' + bodyStrJson);
            RequestBody reqBody = (RequestBody) JSON.deserialize(bodyStrJson, RequestBody.class);
            List<Price_List__c> plList = new List<Price_List__c>();
            for (BodyObject ri : reqBody.resultinfo.body) {
                Price_List__c pl = new Price_List__c();
                pl.is_delete__c = false;
                pl.Versions__c = reqBody.resultinfo.NO;
                // if(ri.PRODUCTLIST.length()>80){
                //     pl.Name = ri.PRODUCTLIST.substring(0, 79);
                // }else{
                    pl.Name = ri.PRODUCTLIST;
                // }
                
                
                pl.Last_Week_Price__c = ri.ONEWEEKSBASICPRICE;
                pl.FOB_Price__c = ri.BASICPRICE;
                pl.Unit__c = ri.unit;
                pl.Currency__c = 'USD';
                pl.BMP_Created__c = ri.RESPONSIBLE;
                pl.External_Id__c = ri.PRODUCTLIST;

                pl.Group__c = ri.HXZF;//	活性组分编码		VARCHAR2(20)
                pl.Product_Code__c = ri.PRODUCTCODE;//	产品编码		VARCHAR2(50)
                pl.Product_Name__c = ri.PRODUCTNAME;//	产品名称		VARCHAR2(200)
                pl.Business_Model__c = ri.BUSINESSMODEL;//	商业模式		VARCHAR2(200)
                pl.Gross_Profit__c = ri.GROSSPROFIT;//	正常毛利		NUMBER(10,2)
                pl.Adjustedgross_Margin__c = ri.ADJUSTEDGROSSMARGIN;//	调整后毛利		NUMBER(10,2)

                pl.Regular_Delivery_Time__c = ri.REGULARDELIVERYTIME;//	标准交货周期		VARCHAR2(20)
                pl.Three_Weeks_Basic_Price__c = ri.THREEWEEKSBASICPRICE;//	前3周基准价		NUMBER(18,8)

                pl.Two_Weeks_Basic_Price__c = ri.TWOWEEKSBASICPRICE;//	前2周基准价		NUMBER(18,8)
                pl.Last_Week_Price_Materiel__c = ri.LASTWEEKPRICE;//	原药上周价格		NUMBER(18,8)
                // if(String.isBlank(ri.COST)) {
                //     pl.Cost__c = null;//	技术或配方交易成本
                // }else{
                    pl.Cost__c = ri.COST;//	技术或配方交易成本
                // }
                
                pl.Formula_RMB_Cost__c = ri.FORMULARMBCOST;//	人民币成本		NUMBER(18,8)
                pl.Formula_Basic_Price__c = ri.FORMULABASICPRICE;//	基准价格		NUMBER(18,8)
                pl.Operation_Helper__c = ri.OPERATIONHELPER;//	操作指引		VARCHAR2(2000)

                pl.Purdep_Info__c = ri.PURDEPINFO;//	市场行情

                pl.Update_Date__c = ri.UPDATEDATE;//	更新日期		DATE
                pl.Responsible__c = ri.RESPONSIBLE;//	业务员		VARCHAR2(20)
                pl.Responsible_Account__c = ri.RESPONSIBLEACCOUNT;//	业务员账号		VARCHAR2(20)
                pl.Product_over_view__c = ri.PRODUCTOVERVIEW;//	产品回顾		VARCHAR2(2000)
                pl.This_Week_Other_Cost__c = ri.THISWEEKOTHERCOST;//	本周其他费用		NUMBER(18,2)
                pl.Last_Week_Other_Cost__c = ri.LASTWEEKOTHERCOST;//	上周其他费用		NUMBER(18,2)
                pl.DIFF__c = ri.DIFF;//	其他费用差值		NUMBER(18,2)
                pl.Check__c = ri.Check;
                pl.Indian_Origin__c = ri.IndianOrigin;
                plList.add(pl);
            }
            if (plList.size()>0) {
                Database.upsert(plList,Price_List__c.fields.External_Id__c);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            errorMsg = InterfaceUtility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
            isSuccess = false;
        }
        SAPProductWebService.ResponseBody response = SAPProductWebService.returnData(respTime, isSuccess, errorMsg);
        InterfaceUtility.insertInterfaceLog('PriceListWebService', 'BPM', 'CRM',
                '/services/apexrest/receiveD ataFromExternal/  requestCode:SAP001', bodyStrJson, isSuccess, false,
                JSON.serialize(response), errorMsg, 'POST', dataIdList, 'Upsert', 'BPM同步price list至CRM'
        );
        return response;
    }
}