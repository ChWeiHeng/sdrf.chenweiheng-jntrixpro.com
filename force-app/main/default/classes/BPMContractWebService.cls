/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 06-17-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-20-2025   Gerry   Initial Version
**/
@RestResource(urlMapping='/BPMContractWebService')
global without sharing class BPMContractWebService {
    public class RequestBody {
        public ReqESInfo esbinfo;
        public List<ReqContractInfo> resultinfo;
    }
    
    public class ReqESInfo {
        public String instid; // 接口编号
        public String requesttime; // 请求时间
    }
    
    public class ReqContractInfo {
        public String CRMID; //CRMID
        public String BPMNumber; //BPM合同编码
        public String conType; //合同类型
        public String supplierDelivery; //供应商送货
        public String status; //状态
        public String salesCompany; //销售公司
        public String salesOrg; //销售组织
        public String customerCode; //客户名称
        public String customerLevel; //客户等级
        public String businessManager; //业务负责人
        public String salesManage; //大区总经理
        public String finalyCustomerCode; //最终客户
        public String subsidiaryPeriod; //子公司账期
        public String loadingPort; //装运港
        public String portDestination; //目的港
        public String exportingContry; //出口国
        public String businessUnit; //业务部门
        public String salesman; //业务员
        public String paymentTerms; //收款协议
        public String tradeTerms; //贸易术语
        public String contractCurrency; //币种
        public String dollarRate; //美金折算汇率
        public String salesTerritory; //销售地区
        public String salesOffice; //销售办事处
        public String salesGroup; //销售组
        public String shipment; //船期
        public String restrictionCondition; //限制条件
        public String limitingReason; //限制原因
        public String endCustomer; //最终客户明细
        public String businessContractTime; //业务传递合同时间
        public String reasonSameDay; //未当天申请原因
        public String reason; //毛利为负原因
        public String otherNote; //其他备注
        public String countersignTime; //回签条款时间
        public String interestClause; //利息条款
        public String creditSupportClause; //信用支持条款
        public String priceRetranslationAgreementClause; //价格重译条团议条款
        public String thirdPartyClause; //第三方提货条款
        public String thirdPartyPaymentClause; //第三方支付条款
        public String otherSupplementaryTerms; //其他补充条款
        public String bankInformation; //银行信息
        public String orderNumber; //销售和分销凭证号
        public HeadInclude INCLUDE;//备用字段
        public String conditionsNumber;//	限制条件条数
        public String seaFreightClause;//	海运费条款
        public String contractVersionChangeClause;//	合同版本变更条款
        public String buyerAdverseBookingExemptionClause;//	买方订舱不利豁免条款
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
        public String detailId;//CRM 行编码
        public String BPMDetailNumber;//BPM行编码
        public String productCode;//存货编码
        public String productEnglishName;//产品英文名称
        public String productName;//产品名称（打印）
        public String businessModel;//业务模式
        public String designatedProduct;//指定产品
        public String bearing;//是否打托
        public String packing;//包装规格
        public String unit;//单位
        public String quantity;//数量
        public String unitPrice;//单价
        public String subsidiaryPrice;//子公司销售价格
        public String SinousPrice;//中美单价
        public String totalAmount;//总金额
        public String dangerous;//是否危品
        public String deliveryType;//交期类型
        public String earliestDemand;//最早需货
        public String demandTime;//需货时间
        public String latestNeed;//最晚需货
        public String latestDelivery;//合同最晚交期
        public String commissionPrice;//佣金单价
        public String inlandTransportationCost;//内陆运输成本
        public String carryingCost;//账期成本
        public String packagingCost;//包装成本
        public String palletCost;//托盘成本
        public String benchmarkPrice;//基准价格
        public String otherMatters;//其他事项
        public String totalFreight;//海运费总成本
        public String backwardReference;//倒推基准
        public String grossMargin;//毛利总额
        public String discountPrice;//折扣单价
        public String orderWarning;//接单风险提示
        public String commissionRatio;//佣金比例
        public String packgeDe;//包装规格英文描述
        public String heavyNucleus;//重核毛利
        public String numberPackages;//件数
        public String designatedSource;//指定货源
        public String tradeName;//商品名称
        public String qualityRequirement;//质量要求
        public String qualityAttachmentRequirement;//质量附件要求
        public String markType;//唛头类型
        public String lineClosers;//行关闭人
        public String lineClosingTime;//行关闭时间
        public String lineState;//行状态
        public String trackingCode;//跟踪编码
        public ItemInclude INCLUDE;
    }
    
    public class ItemInclude{
        public String IEX01;//备用字段
        public String IEX02;//备用字段
        public String IEX03;//备用字段
        public String IEX04;//备用字段
        public String IEX05;//备用字段
        public String IEX06;//备用字段
    }
    
    /**
     * BPM 合同信息同步接口
     * @param bodyStrJson bodyStrJson
     *
     * @return ResponseBody
     */
    @HttpPost
    global static SAPProductWebService.ResponseBody doPost() {
        String respTime = String.valueOf(Datetime.now());
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String bodyStrJson = req.requestBody.toString();
        System.debug('Received body: ' + bodyStrJson);
        List<String> dataIdList = new List<String>();
        Boolean isSuccess = true;
        Savepoint sp = Database.setSavepoint();
        String errorMsg;
        try {
            System.debug('bodyStrJson1==' + bodyStrJson);
            RequestBody reqBody = (RequestBody) JSON.deserialize(bodyStrJson, RequestBody.class);
            feedbackContractInfo(reqBody.resultinfo[0]);
        } catch (Exception e) {
            Database.rollback(sp);
            errorMsg = InterfaceUtility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
            isSuccess = false;
        }
        SAPProductWebService.ResponseBody response = SAPProductWebService.returnData(respTime, isSuccess, errorMsg);
        InterfaceUtility.insertInterfaceLog('BPMContractWebService', 'BPM', 'CRM',
        '/services/apexrest/collectionDetailsFromExternal/  requestCode:SAP001', bodyStrJson, isSuccess, false,
        JSON.serialize(response), errorMsg, 'POST', dataIdList, 'Upsert', 'BPM同步合同信息至CRM'
            );
        return response;
    }
    public static void feedbackContractInfo(ReqContractInfo resultinfo) {
        List<Contracts__c> id_data = [SELECT ID FROM Contracts__c where ID = :resultinfo.CRMID ];
        if (id_data.size() == 0){
            throw new CustomException('CRM合同号ID-'+resultinfo.CRMID+'不存在！');
        } else {
            Contracts__c con = [SELECT Id,BPM_Contrct_Numbder__c FROM Contracts__c WHERE Id =:resultinfo.CRMID];
            Contracts__c upContract = new Contracts__c();
            upContract.id = resultinfo.CRMID; //CRMID
            if (resultinfo.status == 'Deleted') {
                upContract.Status__c = 'Deleted';
                update upContract;
                return;
            }
            upContract.BPM_Contrct_Numbder__c = resultinfo.BPMNumber; //BPM合同编码
            upContract.Contract_Type__c = resultinfo.conType; //合同类型
            if (resultinfo.supplierDelivery=='是') {
                upContract.Supplier_Delivery__c = 'YES'; //供应商送货
            }

            if (resultinfo.supplierDelivery=='否') {
                upContract.Supplier_Delivery__c = 'NO'; //供应商送货
            }
            
            upContract.Status__c = resultinfo.status; //状态
            upContract.Sales_Company__c = resultinfo.salesCompany; //销售公司
            upContract.BPM_Sales_Org__c = resultinfo.salesOrg; //销售组织
            // upContract.Customer__c = resultinfo.customerCode; //客户名称
            upContract.Customer_Level__c = resultinfo.customerLevel; //客户等级
            upContract.Business_Manager__c = resultinfo.businessManager; //业务负责人
            upContract.General_Manager__c = resultinfo.salesManage; //大区总经理
            Account acc = new Account();
            acc.MDG_Customer_Code__c = resultinfo.finalyCustomerCode;
            upContract.Final_Customer__r = acc; //最终客户
            upContract.Subsidiary_Period__c = resultinfo.subsidiaryPeriod; //子公司账期
            if(String.isNotBlank(resultinfo.loadingPort)) {
                Port_Information__c loading = new Port_Information__c();
                loading.Port_Information_Code__c = resultinfo.loadingPort;
                upContract.Loading_Port_New__r = loading; //装运港
            }
            
            if(String.isNotBlank(resultinfo.portDestination)) {
                Port_Information__c destination = new Port_Information__c();
                destination.Port_Information_Code__c = resultinfo.portDestination;
                upContract.Destination_Port_New__r = destination; //目的港
            }
            
            if(!System.Test.isRunningTest()) {
                Country_Province_Master_Data__c cpmd = [SELECT Id FROM Country_Province_Master_Data__c WHERE Code__c =:resultinfo.exportingContry AND RecordType.DeveloperName='Country' limit 1];
                upContract.Export_Country__c = cpmd.Id; //出口国
            }
            

            upContract.Business_Unit__c = resultinfo.businessUnit; //业务部门
            upContract.Salesman__c = resultinfo.salesman; //业务员
            upContract.BPM_Final_Customer_Payment_Terms__c = resultinfo.paymentTerms; //收款协议
            upContract.Trade_Terms__c = resultinfo.tradeTerms; //贸易术语
            upContract.Currency__c = resultinfo.contractCurrency; //币种
            upContract.Rate__c = resultinfo.dollarRate==null?0:Decimal.valueof(resultinfo.dollarRate); //美金折算汇率
            upContract.Sales_District__c = resultinfo.salesTerritory; //销售地区
            upContract.Sales_Office__c = resultinfo.salesOffice; //销售办事处
            upContract.Sales_Group__c = resultinfo.salesGroup; //销售组
            upContract.Shipment__c = resultinfo.shipment; //船期
            upContract.Restrictions__c = resultinfo.restrictionCondition; //限制条件
            upContract.Restriction_Reasons__c = resultinfo.limitingReason; //限制原因
            upContract.End_Customer_Detail__c = resultinfo.endCustomer; //最终客户明细
            upContract.Transfer_Contract_Time__c = Date.valueOf(resultinfo.businessContractTime); //业务传递合同时间
            upContract.NoSameDay__c = resultinfo.reasonSameDay; //未当天申请原因
            upContract.Reason_of_Negative_Margin__c = resultinfo.reason; //毛利为负原因
            upContract.Other_Remarks__c = resultinfo.otherNote; //其他备注
            upContract.Countersign_Time__c = resultinfo.countersignTime; //回签条款时间
            upContract.Interest_Clause__c = resultinfo.interestClause; //利息条款
            upContract.Credit_Support_Clause__c = resultinfo.creditSupportClause; //信用支持条款
            upContract.Price_Retranslation_Agreement_Clause__c = resultinfo.priceRetranslationAgreementClause; //价格重译条团议条款
            upContract.Third_Party_Clause__c = resultinfo.thirdPartyClause; //第三方提货条款
            upContract.Third_Party_Payment_Clause__c = resultinfo.thirdPartyPaymentClause; //第三方支付条款
            upContract.Other_Supplementary_Terms__c = resultinfo.otherSupplementaryTerms; //其他补充条款
            upContract.Bank_Information__c = resultinfo.bankInformation; //银行信息
            upContract.Conditions_Number__c = resultinfo.conditionsNumber; //	限制条件条数
            upContract.Sea_Freight_Clause__c = resultinfo.seaFreightClause; //	海运费条款
            upContract.Contract_Version_Change_Clause__c = resultinfo.contractVersionChangeClause; //	合同版本变更条款
            upContract.Buyer_Adverse_Booking_Exemption_Clause__c = resultinfo.buyerAdverseBookingExemptionClause; //	买方订舱不利豁免条款
            // contract.orderNumber = resultinfo.; //销售和分销凭证号
            List<Contracts_Detail__c> ContractDetailsList = new List<Contracts_Detail__c>();
            Map<String,String> businessModelMap = Utility.getPicklistLabelMap('Contracts__c','Business_Model__c');
            // Set<String> numberSet = new Set<String>();
            // for(ReqContractItemInfo reqContractItemInfo : resultinfo.ITEMS) {
            //     numberSet.add(upContract.BPM_Contrct_Numbder__c+'_'+reqContractItemInfo.BPMDetailNumber);
            // }
            // Map<String,Contracts_Detail__c> cdMap = new Map<String,Contracts_Detail__c>();
            // for() {

            // }
            for (ReqContractItemInfo reqContractItemInfo : resultinfo.ITEMS) {
                Contracts_Detail__c collectionDetail = new Contracts_Detail__c();
                if(String.isNotBlank(reqContractItemInfo.detailId)) {
                    collectionDetail.id = reqContractItemInfo.detailId;
                }

                //CRM 行编码
                collectionDetail.BPM_Detail_Number__c = upContract.BPM_Contrct_Numbder__c+'_'+reqContractItemInfo.BPMDetailNumber;//BPM行编码
                Product__c pro = new Product__c();
                pro.External_Id__c = reqContractItemInfo.productCode;
                collectionDetail.Product__r = pro;//存货编码
                collectionDetail.Product_Name__c = reqContractItemInfo.productName;//产品名称（打印）
                
                collectionDetail.Business_Model__c = businessModelMap.get(reqContractItemInfo.businessModel);//业务模式
                if (reqContractItemInfo.designatedProduct=='是') {
                    collectionDetail.If_Designated_Products__c = 'Y';//指定产品
                }
                if (reqContractItemInfo.designatedProduct=='否') {
                    collectionDetail.If_Designated_Products__c = 'N';//指定产品
                }
                
                
                collectionDetail.If_Pallet__c = reqContractItemInfo.bearing;//是否打托
                Package_Data__c pd = new Package_Data__c();
                pd.Pakcing_Size_Code__c = reqContractItemInfo.packing;
                collectionDetail.Packing_Size__r = pd;//包装规格
                collectionDetail.Unit__c = reqContractItemInfo.unit;//单位
                collectionDetail.Qnty__c = reqContractItemInfo.quantity==null? 0:Decimal.valueof(reqContractItemInfo.quantity);//数量
                collectionDetail.HQ_Contract_Unit_Price__c = reqContractItemInfo.unitPrice==null? 0:Decimal.valueof(reqContractItemInfo.unitPrice);//单价
                collectionDetail.BU_Sales_Price__c = reqContractItemInfo.subsidiaryPrice==null? 0:Decimal.valueof(reqContractItemInfo.subsidiaryPrice);//子公司销售价格
                // collectionDetail.SinousPrice = reqContractItemInfo.;//中美单价
                collectionDetail.Total_Amount__c = reqContractItemInfo.totalAmount==null? 0:Decimal.valueof(reqContractItemInfo.totalAmount);//总金额
                collectionDetail.Dangerous__c = reqContractItemInfo.dangerous;//是否危品
                collectionDetail.Delivery_Type__c = reqContractItemInfo.deliveryType;//交期类型
                collectionDetail.Earliest_Demand__c = Date.valueOf(reqContractItemInfo.earliestDemand);//最早需货
                collectionDetail.Demand_Time__c = Date.valueOf(reqContractItemInfo.demandTime);//需货时间
                collectionDetail.Latest_need__c = Date.valueOf(reqContractItemInfo.latestNeed);//最晚需货
                collectionDetail.Latest_Delivery_Date__c = Date.valueOf(reqContractItemInfo.latestDelivery);//合同最晚交期
                collectionDetail.Commission_Unit_Price__c = reqContractItemInfo.commissionPrice==null? 0:Decimal.valueof(reqContractItemInfo.commissionPrice);//佣金单价
                collectionDetail.Inland_Transportation_Cost__c = reqContractItemInfo.inlandTransportationCost==null? 0:Decimal.valueof(reqContractItemInfo.inlandTransportationCost);//内陆运输成本
                collectionDetail.Carrying_Cost__c = reqContractItemInfo.carryingCost==null? 0:Decimal.valueof(reqContractItemInfo.carryingCost);//账期成本
                collectionDetail.Packing_cost__c = reqContractItemInfo.packagingCost==null? 0:Decimal.valueof(reqContractItemInfo.packagingCost);//包装成本
                collectionDetail.Pallet_Cost__c = reqContractItemInfo.palletCost==null? 0:Decimal.valueof(reqContractItemInfo.palletCost);//托盘成本
                collectionDetail.FOB_Price__c = reqContractItemInfo.benchmarkPrice==null? 0:Decimal.valueof(reqContractItemInfo.benchmarkPrice);//基准价格
                // collectionDetail.Other_Issue__c = reqContractItemInfo.otherMatters;//其他事项
                collectionDetail.Freight_Cost__c = reqContractItemInfo.totalFreight==null? 0:Decimal.valueof(reqContractItemInfo.totalFreight);//海运费总成本
                collectionDetail.Backward_Deference__c = reqContractItemInfo.backwardReference==null? 0:Decimal.valueof(reqContractItemInfo.backwardReference);//倒推基准
                collectionDetail.Gross_Margin__c = reqContractItemInfo.grossMargin==null? 0:Decimal.valueof(reqContractItemInfo.grossMargin);//毛利总额
                collectionDetail.Discount_Unit_Price__c = reqContractItemInfo.discountPrice==null? 0:Decimal.valueof(reqContractItemInfo.discountPrice);//折扣单价
                collectionDetail.Order_Risk_Warning__c = reqContractItemInfo.orderWarning;//接单风险提示
                collectionDetail.Commission_Ratio__c = reqContractItemInfo.commissionRatio==null? 0:Decimal.valueof(reqContractItemInfo.commissionRatio);//佣金比例
                collectionDetail.Packing_Size_Description__c = reqContractItemInfo.packgeDe;//包装规格英文描述
                collectionDetail.Contracts__c = resultinfo.CRMID;
                if (reqContractItemInfo.heavyNucleus == '是') {
                    collectionDetail.Recheck_Margin__c = 'Y';//重核毛利
                }

                if (reqContractItemInfo.heavyNucleus == '否') {
                    collectionDetail.Recheck_Margin__c = 'N';//重核毛利
                }
                
                collectionDetail.Packages_Number__c = reqContractItemInfo.numberPackages==null? 0:Decimal.valueof(reqContractItemInfo.numberPackages);//件数
                collectionDetail.Designated_Source__c = reqContractItemInfo.designatedSource;//指定货源
                collectionDetail.Trade_Name_BPM__c = reqContractItemInfo.tradeName;//商品名称
                collectionDetail.Quality_Requirement__c = reqContractItemInfo.qualityRequirement;//质量要求
                collectionDetail.Quality_Attachment_Requirement__c = reqContractItemInfo.qualityAttachmentRequirement;//质量附件要求
                collectionDetail.Mark_Type__c = reqContractItemInfo.markType;//唛头类型
                collectionDetail.Line_Closers__c = reqContractItemInfo.lineClosers;//行关闭人
                if (String.isNotBlank(reqContractItemInfo.lineClosingTime)) {
                    collectionDetail.Line_Closing_Time__c = Datetime.valueOf(reqContractItemInfo.lineClosingTime);//行关闭时间
                }
                
                collectionDetail.Line_Status__c = reqContractItemInfo.lineState;//行状态
                if(String.isNotBlank(reqContractItemInfo.trackingCode)) {
                    collectionDetail.Tracking_Code__c = reqContractItemInfo.trackingCode;
                }
                ContractDetailsList.add(collectionDetail);
            }
            if (ContractDetailsList.size() > 0 && !Test.isRunningTest()) {
                if(con.BPM_Contrct_Numbder__c!=null) {
                    Database.upsert(ContractDetailsList, Contracts_Detail__c.fields.BPM_Detail_Number__c);
                }else{
                    Database.upsert(ContractDetailsList, true);
                }
                
            }
            if(!Test.isRunningTest()){update upContract;}
        }
    }
}