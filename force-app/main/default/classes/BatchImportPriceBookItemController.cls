/**
 * @description       : 批量导入价格书项目
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 02-27-2026
 * @last modified by  : Niko
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-11-2025   Gerry   Initial Version
**/
public without sharing class BatchImportPriceBookItemController {
    //初始化数据
    @AuraEnabled
    public static InitData getInitData(String id){
        InitData init = new InitData();
        System.debug('测试逻辑1');
        Price_Book__c pb =[SELECT Id,Sales_Org__c,Delivery_Plant__c FROM Price_Book__c WHERE Id =: id];
        System.debug('测试逻辑2');
        //检验导入用户是否是同一sales org
        List<User> impoUserList = [SELECT Id,Sales_Org__c,Delivery_Plant__c,Country__c	 FROM User WHERE Id=:System.UserInfo.getUserId()];
        init.userFlag = '0';
        if (pb.Sales_Org__c != impoUserList[0].Sales_Org__c && pb.Delivery_Plant__c != impoUserList[0].Delivery_Plant__c) {
            init.userFlag = '1';
        }
        //获取模板链接
        List<ContentDistribution> salesLink;
        //获取 数据导入字段配置 对象中配置的字段
        List<ImportDataFieldConf__c> fieldConfs;
        
        String templateName = 'Price_Book_Item_'+impoUserList[0].Country__c;
        
        DataImportTemplate__c fileidSalesOrg = DataImportTemplate__c.getValues(templateName);
        String salesOrgValue = fileidSalesOrg.FileId__c;
        salesLink = [SELECT Id, ContentDownloadUrl, DistributionPublicUrl
                                                          FROM ContentDistribution 
                                                          WHERE ContentDocumentId =: salesOrgValue  LIMIT 1];
        fieldConfs = [SELECT Id, Obj_Name__c, Field_Label_Name__c,RecordType__c  ,
                                                    Field_Api_Name__c,Data_Type__c, If_Need__c 
                                                    FROM ImportDataFieldConf__c 
                                                    WHERE Obj_Name__c = 'Price_Book_Item__c' ];
                
        if (!Test.isRunningTest()) {
            init.salesDownloadLink = salesLink[0].ContentDownloadUrl;
        }
        
        System.debug('fieldConfs===》'+fieldConfs);
        // 字段Label和API对应关系
        Map<String,String> excelHeaderMap = new Map<String, String>();
        // API和字段Label对应关系 
        Map<String,String> excelHeaderKeyToLabelMap = new Map<String, String>();
        Set<String> mustFillValueFields = new Set<String>(); // 在配置表中勾选了必填的字段API
        Set<String> numValueFieldSet = new Set<String>();//数字类型字段
        for(ImportDataFieldConf__c curConf : fieldConfs){
            excelHeaderMap.put(curConf.Field_Label_Name__c, curConf.Field_Api_Name__c);
            excelHeaderKeyToLabelMap.put(curConf.Field_Api_Name__c, curConf.Field_Label_Name__c);
            List<String> recordTypeList = new List<String>();
            if (String.isNotBlank(curConf.RecordType__c)) {
                    String objectRecordType = curConf.RecordType__c;
                    recordTypeList = objectRecordType.split(';');
            }
            //设置必填字段
            if (curConf.IF_Need__c ){
                mustFillValueFields.add(curConf.Field_Api_Name__c);
            }
            if (curConf.Data_Type__c == 'Integer' || curConf.Data_Type__c == 'Decimal' || curConf.Data_Type__c == '币种') {
                numValueFieldSet.add(curConf.Field_Api_Name__c);	
            }
        }   
        init.excelHeaderMap = excelHeaderMap;
        init.excelHeaderKeyToLabelMap = excelHeaderKeyToLabelMap;    
        init.mustFillValueFields = mustFillValueFields;
        init.numValueFieldSet = numValueFieldSet;
        System.debug('查看必填字段==》'+mustFillValueFields);
        return init;
    }

    //构造验证失败得返回值
    public static Integer ValiriFailed(List<ValiriFailedSalesTarget> valiriFailedSalesTargets, String failedReason, Map<String, ValiriFailedSalesTarget> inveRepo_inveRepoValiriFail, String execlRowNum){
       
        if(inveRepo_inveRepoValiriFail.containsKey(execlRowNum)){
            ValiriFailedSalesTarget valiriFailed = inveRepo_inveRepoValiriFail.get(execlRowNum);
            valiriFailed.FailedReason = valiriFailed.FailedReason + '; ' + failedReason;
        }else{
            ValiriFailedSalesTarget valiriFailed = new ValiriFailedSalesTarget();
            valiriFailed.Name = '';
            valiriFailed.FailedReason = failedReason;
            valiriFailed.execlNum = execlRowNum;
            valiriFailedSalesTargets.add(valiriFailed);
            inveRepo_inveRepoValiriFail.put(execlRowNum, valiriFailed);
          
        }
        return 1;
    }

    //保存数据至Salesforce
    @AuraEnabled
    public static InsertSalesTargetResult saveData( String TargetJson,Map<String,String> excelHeaderKeyToLabelMap, List<String> mustFillValueFields,String priceBookId,List<String> numValueFieldSet) {
        Decimal maxRow;
        //回滚
        System.savepoint sp = Database.setSavepoint();
        try {
            /*if(!Test.isRunningTest()){
                TargetJson = '[' + TargetJson.substring(TargetJson.indexOf(',{')+1); // 去掉execl表头
            }*/
            Price_Book__c pb = [SELECT Id,Sales_Org__c,Delivery_Plant__c FROM Price_Book__c WHERE Id=:priceBookId];
            String targetSubStr = '},'; 
            Integer count = 0; 
            Integer index = TargetJson.indexOf(targetSubStr); 
            while(index != -1) { 
                count++; index = TargetJson.indexOf(targetSubStr, index + 1); 
            } 
            System.debug('子字符串 "' + targetSubStr + '" 出现的次数: ' + count);
            System.debug('TargetJson===>'+TargetJson);
            
            if (!Test.isRunningTest()) {
                DataImportTemplate__c fileidMaxRow = DataImportTemplate__c.getValues('MaxRow');
                String maxRowValue = fileidMaxRow.FileId__c;
                maxRow = Decimal.valueOf(maxRowValue);
            }else{
                maxRow = 100;
            }

            //超出最大导入数量  
            if(count > maxRow){
                InsertSalesTargetResult insertResult = new InsertSalesTargetResult();
                insertResult.lResult = 'tooManyRecord';
                // insertResult.valiriFailedSalesTarget = valiriFailedSalesTargets;
                insertResult.successValiAmount = 0;
                insertResult.failedValiAmount = 0;
                insertResult.successInsertAmount = 0;
                insertResult.excelMaxRow = maxRow;
                return insertResult;     
            }

            List<ValiriFailedSalesTarget> valiriFailedSalesTargets = new List<ValiriFailedSalesTarget>(); // 存储验证失败的
            Map<String, ValiriFailedSalesTarget> inveRepo_inveRepoValiriFail = new Map<String, ValiriFailedSalesTarget>(); 
            
            System.debug('验证失败的前台返回数据===》'+mustFillValueFields+'    Size()===>'+mustFillValueFields.size());   //size = 49
            

            // Integer  num = 0;
            List<Object> testList = (List<Object>)JSON.deserializeUntyped(TargetJson);
            System.debug('testList==>'+testList);
        
            if(testList.size()>0){
                for(Object testItem : testList){
                    Map<String, Object> sales = (Map<String, Object>) testItem;
                }
            }

            List<Price_Book_Item__c> updateList = new List<Price_Book_Item__c>();  
            Integer rowNum = 2;
            Set<String> keySet = new Set<String>();
            Set<String>  vertifyDupilcateData= new Set<String>();
            Boolean isMx = false;
            if (pb.Sales_Org__c.startsWith('3')) {
                isMx = true;
            }
            Boolean isAU = false;
            if (pb.Sales_Org__c == '2100') {
                isAU = true;
            }
            System.debug('isMx==>'+isMx+'isAU==>'+isAU);
            Map<Integer, Object> needUpdateMap = new Map<Integer, Object>();
            // 校验必填以及字段类型
            for(Object testObj : testList) {
                Boolean flag = true;
                Map<String, Object> testMap = (Map<String, Object>)testObj;
                System.debug('begin: '+ rowNum);
                for(String curField : mustFillValueFields){
                    if (curField == 'Min_Sales_Price__c' && isMx) {
                        continue;
                    }
                    if (curField == 'Estimation_Cost_USD__c' && isMx) {
                        continue;
                    }
                    if (curField == 'Estimation_Cost_USD__c' && isAU) {
                        continue;
                    }
                    if (curField == 'Estimation_Cost_Local__c' && isMx) {
                        continue;
                    }
                    if(!testMap.containsKey(curField) || String.isBlank(String.valueOf(testMap.get(curField))) ){
                        ValiriFailed(
                            valiriFailedSalesTargets, 
                            '\"' + excelHeaderKeyToLabelMap.get(curField) + '\"' + System.label.Sales_Forcast_Imp_Required, 
                            inveRepo_inveRepoValiriFail,String.valueOf(rowNum)
                        );
                        flag = false;
                    }
                }

                for(String curField : numValueFieldSet){
                    if (!testMap.containsKey(curField) || String.isBlank(String.valueOf(testMap.get(curField)))) {
                        // 为空的处理
                    } else {
                        Object value = testMap.get(curField);
                        Boolean isNumber = false;
                        try {
                            Decimal d = Decimal.valueOf(String.valueOf(value));
                            isNumber = true;
                        } catch (Exception e) {
                            isNumber = false;
                        }
                        if (!isNumber) {
                            ValiriFailed(
                                valiriFailedSalesTargets,
                                '\"' + excelHeaderKeyToLabelMap.get(curField) + '\"' + System.label.ValueNumber, 
                                inveRepo_inveRepoValiriFail,String.valueOf(rowNum)
                            );
                            flag = false;
                        } 
                    }
                }
                
                if (flag) {
                    needUpdateMap.put(rowNum,testObj);
                }
                
                rowNum = rowNum + 1;
            } 

            Set<String> accountSet = new Set<String>();
            for (Integer key : needUpdateMap.keySet()) {
                Map<String, Object> testMap = (Map<String, Object>)needUpdateMap.get(key);
                if (testMap.containsKey('Customer__c') && testMap.get('Customer__c')!=null) {
                    accountSet.add(String.valueOf(testMap.get('Customer__c')));
                }
            }

            Map<String,String> accMap= new Map<String,String>();//查询客户
            for (Account acc : [SELECT Id,MDG_Customer_Code__c FROM Account WHERE MDG_Customer_Code__c IN:accountSet]) {
                accMap.put(acc.MDG_Customer_Code__c, acc.Id);
            }
            Set<String> productNameExSet = new Set<String>();
            for (Integer key : needUpdateMap.keySet()) {
                Map<String, Object> testMap = (Map<String, Object>)needUpdateMap.get(key);
                if (testMap.containsKey('Customer__c') && testMap.get('Customer__c')!=null && accMap.get(String.valueOf(testMap.get('Customer__c')))!=null) {
                    productNameExSet.add(String.valueOf(testMap.get('Product_Code__c'))+'_'+Pb.Sales_Org__c+'_'+String.valueOf(testMap.get('Distribution_Channel__c'))+'_'+Pb.Delivery_Plant__c+'_'+String.valueOf(testMap.get('Product_Name__c'))+'_'+accMap.get(String.valueOf(testMap.get('Customer__c'))));
                }else{
                    productNameExSet.add(String.valueOf(testMap.get('Product_Code__c'))+'_'+Pb.Sales_Org__c+'_'+String.valueOf(testMap.get('Distribution_Channel__c'))+'_'+Pb.Delivery_Plant__c+'_'+String.valueOf(testMap.get('Product_Name__c'))+'_');
                    
                }
            }
            System.debug('productNameExSet====>'+productNameExSet);
            //查询商品名信息
            Map<String,String> productNameMap = new Map<String,String>();
            for (Product_Name__c pn : [SELECT Id,External_Id__c FROM Product_Name__c WHERE External_Id__c IN:productNameExSet AND Is_Delete__c=false]) {
                productNameMap.put(pn.External_Id__c, pn.Id);
            }

            //数据赋值
            String productNameKey;
            Map<String,Integer> duplicateMap = new Map<String,Integer>();
            for (Integer key : needUpdateMap.keySet()) {
                Map<String, Object> testMap = (Map<String, Object>)needUpdateMap.get(key);
                Price_Book_Item__c pn = new Price_Book_Item__c();
                pn.Price_Book__c = pb.Id;
                if (testMap.containsKey('Customer__c') && testMap.get('Customer__c')!=null  && accMap.get(String.valueOf(testMap.get('Customer__c')))!=null) {
                    productNameKey = String.valueOf(testMap.get('Product_Code__c'))+'_'+Pb.Sales_Org__c+'_'+String.valueOf(testMap.get('Distribution_Channel__c'))+'_'+Pb.Delivery_Plant__c+'_'+String.valueOf(testMap.get('Product_Name__c'))+'_'+accMap.get(String.valueOf(testMap.get('Customer__c')));
                }else{
                    productNameKey = String.valueOf(testMap.get('Product_Code__c'))+'_'+Pb.Sales_Org__c+'_'+String.valueOf(testMap.get('Distribution_Channel__c'))+'_'+Pb.Delivery_Plant__c+'_'+String.valueOf(testMap.get('Product_Name__c'))+'_';
                    System.debug('productNameKey====>'+productNameKey);
                }
                pn.Product_Name__c = productNameMap.get(productNameKey);
                if (pn.Product_Name__c==null) {
                    ValiriFailed(
                        valiriFailedSalesTargets, 
                        System.label.ProductNotFind, 
                        inveRepo_inveRepoValiriFail,String.valueOf(key)
                    );
                    continue;
                }
                if (duplicateMap.containsKey(productNameKey)) {
                    ValiriFailed(
                        valiriFailedSalesTargets, 
                        System.label.ProductDuplicate+duplicateMap.get(productNameKey),
                        inveRepo_inveRepoValiriFail,String.valueOf(key)
                    );
                    continue;
                }else{
                    duplicateMap.put(productNameKey,key);
                }
                pn.Price__c = Decimal.valueOf(String.valueOf(testMap.get('Price__c')));
                if (testMap.get('Min_Sales_Price__c')!=null) {
                    pn.Min_Sales_Price__c = Decimal.valueOf(String.valueOf(testMap.get('Min_Sales_Price__c')));
                }
                if (testMap.get('Portfolio_Segmentation__c')!=null) {
                    pn.Portfolio_Segmentation__c = String.valueOf(testMap.get('Portfolio_Segmentation__c'));
                }else{
                    pn.Portfolio_Segmentation__c = null;
                }

                if (testMap.get('Estimation_Cost_Local__c')!=null) {
                    pn.Estimation_Cost_Local__c = Decimal.valueOf(String.valueOf(testMap.get('Estimation_Cost_Local__c')));
                }else{
                    pn.Estimation_Cost_Local__c = null;
                }

                if (testMap.get('Estimation_Cost_USD__c')!=null) {
                    pn.Estimation_Cost_USD__c = Decimal.valueOf(String.valueOf(testMap.get('Estimation_Cost_USD__c')));
                }else{
                    pn.Estimation_Cost_USD__c = null;
                }

                pn.External_Id__c = pn.Price_Book__c+''+pn.Product_Name__c;
                pn.Status__c = String.valueOf(testMap.get('Status__c'));
                updateList.add(pn);
            }
            
            
        
            InsertSalesTargetResult insertResult = new InsertSalesTargetResult();
            System.debug('valiriFailedSalesTargets==>'+valiriFailedSalesTargets);
            //存在验证失败的数据
            if(valiriFailedSalesTargets.size() > 0){
                insertResult.valiriFailedSalesTarget = valiriFailedSalesTargets;   //存在验证失败的数据
                System.debug('存在验证失败的数据： insertResult.valiriFailedSalesTarget===>'+ insertResult.valiriFailedSalesTarget+'  size() '+insertResult.valiriFailedSalesTarget.size());
                insertResult.lResult = 'Failed';
                if(testList.size()>0){
                    insertResult.successValiAmount = testList.size() - valiriFailedSalesTargets.size();
                }else {
                    insertResult.successValiAmount = 0 ;
                }
                
                insertResult.failedValiAmount = valiriFailedSalesTargets.size();
                insertResult.successInsertAmount = 0;
            }else{
                System.debug('updateList==>'+updateList);
                //插入数据
                Database.Upsert(updateList,Price_Book_Item__c.fields.External_Id__c);
                //Database.upsert(updateList,Quote_Detail__c.fields.External_Id__c);
                //Database.upsert(updateList);
                System.debug('updateList.size()==>'+updateList.size());
                insertResult.lResult = 'Success';
                insertResult.successValiAmount = updateList.size();
                insertResult.failedValiAmount = 0;
                insertResult.successInsertAmount = updateList.size();    
            }
            return insertResult;   

        } catch (Exception e) {
            System.debug('LineNumber:' + e.getLineNumber() + 'Message:' + e.getMessage());
            Database.rollback(sp);
            InsertSalesTargetResult insertResult = new InsertSalesTargetResult();
            insertResult.lResult = 'Error';
            insertResult.successValiAmount = 0;
            insertResult.failedValiAmount = 0;
            insertResult.successInsertAmount = 0;
            insertResult.excelMaxRow = maxRow;
            insertResult.errMsg = 'LineNumber:' + e.getLineNumber() + 'Message:' + e.getMessage();
            return insertResult; 
        }
    }

    //初始化数据
    public class InitData {
        //销售目标模板下载链接
        @AuraEnabled public String salesDownloadLink{get; set;}
        //字段Label和API对应关系
        @AuraEnabled public Map<String, String> excelHeaderMap{get; set;}
        //API和字段Label对应关系
        @AuraEnabled public Map<String, String> excelHeaderKeyToLabelMap{get; set;}
        //必填字段
        @AuraEnabled public Set<String> mustFillValueFields{get;set;}

        //数字类型
        @AuraEnabled public Set<String> numValueFieldSet{get;set;}
        //检验user是否能导入这个销售预测
        @AuraEnabled public String userFlag{get; set;}
        
    } 
    // 验证失败的数据
    public class ValiriFailedSalesTarget {
        @AuraEnabled public String execlNum{get; set;}  // Execl行数
        @AuraEnabled public String Name{get; set;}     //  销售目标名称
        @AuraEnabled public String FailedReason{get; set;}  // 失败原因
    }
    // 执行插入数据的返回值
    public class InsertSalesTargetResult {
        @AuraEnabled public List<ValiriFailedSalesTarget> valiriFailedSalesTarget;
        @AuraEnabled public String lResult{get; set;}
        @AuraEnabled public String errMsg{get; set;}
        @AuraEnabled public Decimal excelMaxRow{get; set;}
        @AuraEnabled public Integer successValiAmount{get; set;}
        @AuraEnabled public Integer failedValiAmount{get; set;}
        @AuraEnabled public Integer successInsertAmount{get; set;}
    }
}