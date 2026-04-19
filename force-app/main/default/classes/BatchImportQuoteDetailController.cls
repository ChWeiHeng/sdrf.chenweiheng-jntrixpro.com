/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 07-15-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-14-2025   Gerry   Initial Version
**/
public without sharing class BatchImportQuoteDetailController {
    //初始化数据
    @AuraEnabled
    public static InitData getInitData(String id){
        InitData init = new InitData();
        
        Quote__c quote=[SELECT Id,Payment_Term_Cost_Rate__c,Sales_Org__c,Quotation_Type__c,Is_Retrograde__c FROM Quote__c WHERE Id =: id];
        //检验导入用户是否是同一sales org
        List<User> impoUserList = [SELECT Id,Sales_Org__c,Delivery_Plant__c FROM User WHERE Id=:System.UserInfo.getUserId()];
        init.userFlag = '0';
        if (quote.Sales_Org__c != impoUserList[0].Sales_Org__c ) {
            init.userFlag = '1';
        }
        //获取模板链接
        List<ContentDistribution> salesLink;
        //获取 数据导入字段配置 对象中配置的字段
        List<ImportDataFieldConf__c> fieldConfs;
        
        
        DataImportTemplate__c fileidSalesOrg ;
        if(quote.Quotation_Type__c=='HQ_Purchase')
        {
            fileidSalesOrg= DataImportTemplate__c.getValues('Quote_Detail');
        }
        else
        {
            fileidSalesOrg= DataImportTemplate__c.getValues('Quote_Detail_Process');
        }
        String salesOrgValue = fileidSalesOrg.FileId__c;
        salesLink = [SELECT Id, ContentDownloadUrl, DistributionPublicUrl
                                                          FROM ContentDistribution 
                                                          WHERE ContentDocumentId =: salesOrgValue  LIMIT 1];
        fieldConfs = [SELECT Id, Obj_Name__c, Field_Label_Name__c,RecordType__c  ,
                                                    Field_Api_Name__c,Data_Type__c, If_Need__c 
                                                    FROM ImportDataFieldConf__c 
                                                    WHERE Obj_Name__c = 'Quote_Detail' ];
                
        if (!Test.isRunningTest()) {
            init.salesDownloadLink = salesLink[0].ContentDownloadUrl;
        }
        
        System.debug('fieldConfs===》'+fieldConfs);
        // 字段Label和API对应关系
        Map<String,String> excelHeaderMap = new Map<String, String>();
        // API和字段Label对应关系 
        Map<String,String> excelHeaderKeyToLabelMap = new Map<String, String>();
        Set<String> mustFillValueFields = new Set<String>(); // 在配置表中勾选了必填的字段API

        for(ImportDataFieldConf__c curConf : fieldConfs){
            excelHeaderMap.put(curConf.Field_Label_Name__c, curConf.Field_Api_Name__c);
            excelHeaderKeyToLabelMap.put(curConf.Field_Api_Name__c, curConf.Field_Label_Name__c);
            List<String> recordTypeList = new List<String>();
            if (String.isNotBlank(curConf.RecordType__c)) {
                    String objectRecordType = curConf.RecordType__c;
                    recordTypeList = objectRecordType.split(';');
            }
            //设置必填字段
            if (curConf.IF_Need__c && (String.isBlank(curConf.RecordType__c) || (String.isNotBlank(curConf.RecordType__c) && recordTypeList.contains(quote.Quotation_Type__c) && !quote.Is_Retrograde__c))) {
                    mustFillValueFields.add(curConf.Field_Api_Name__c);
                }
        }   
        init.excelHeaderMap = excelHeaderMap;
        init.excelHeaderKeyToLabelMap = excelHeaderKeyToLabelMap;    
        init.mustFillValueFields = mustFillValueFields;
        System.debug('查看必填字段==》'+mustFillValueFields);
        return init;
    }

    //构造验证失败得返回值
    public static Integer ValiriFailed(List<ValiriFailedSalesTarget> valiriFailedSalesTargets, Quote_Detail__c salesTar, String failedReason, Map<String, ValiriFailedSalesTarget> inveRepo_inveRepoValiriFail, String execlRowNum){
       
        if(inveRepo_inveRepoValiriFail.containsKey(execlRowNum)){
            ValiriFailedSalesTarget valiriFailed = inveRepo_inveRepoValiriFail.get(execlRowNum);
            valiriFailed.FailedReason = valiriFailed.FailedReason + '; ' + failedReason;
        }else{
            ValiriFailedSalesTarget valiriFailed = new ValiriFailedSalesTarget();
            valiriFailed.Name = String.valueOf(salesTar.Name);
            valiriFailed.FailedReason = failedReason;
            valiriFailed.execlNum = execlRowNum;
            valiriFailedSalesTargets.add(valiriFailed);
            inveRepo_inveRepoValiriFail.put(execlRowNum, valiriFailed);
          
        }
        return 1;
    }

    //保存数据至Salesforce
    @AuraEnabled
    public static InsertSalesTargetResult saveData( String TargetJson,Map<String,String> excelHeaderKeyToLabelMap, List<String> mustFillValueFields,String quoteId) {
        /*if(!Test.isRunningTest()){
            TargetJson = '[' + TargetJson.substring(TargetJson.indexOf(',{')+1); // 去掉execl表头
        }*/

        String targetSubStr = '},'; 
        Integer count = 0; 
        Integer index = TargetJson.indexOf(targetSubStr); 
        while(index != -1) { 
            count++; index = TargetJson.indexOf(targetSubStr, index + 1); 
        } 
        System.debug('子字符串 "' + targetSubStr + '" 出现的次数: ' + count);
        System.debug('TargetJson===>'+TargetJson);
        Decimal maxRow;
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
        Set<String> proNameSet  =  new Set<String>();    //产品名称
        Set<String> contractProNameSet  =  new Set<String>();    //代加工产品名称
        Set<String> packSizeSet  =  new Set<String>();    //包装大小
        if(testList.size()>0){
            for(Object testItem : testList){
                Map<String, Object> sales = (Map<String, Object>) testItem;
                if(String.valueOf(sales.get('Price_List__c')) != null)
                {
                    proNameSet.add(String.valueOf(sales.get('Price_List__c')));
                }
                if(String.valueOf(sales.get('Contract_Processing_Product__c')) != null)
                {
                    contractProNameSet.add(String.valueOf(sales.get('Contract_Processing_Product__c')));
                }
                if(String.valueOf(sales.get('Packing_Size__c')) != null)
                {
                    packSizeSet.add(String.valueOf(sales.get('Packing_Size__c')));
                }
            }
        }
        system.debug('proNameSet: ' + proNameSet);
        system.debug('contractProNameSet: ' + contractProNameSet);
        system.debug('packSizeSet: ' + packSizeSet);

        Quote__c quote=[SELECT Id,Payment_Term_Cost_Rate__c,Quotation_Type__c FROM Quote__c WHERE Id =: quoteId];

        //校验产品是否存在
        List<Price_List__c> proNameList = [SELECT Id, Name,FOB_Price__c,Unit__c FROM Price_List__c WHERE Name IN:proNameSet];
        System.debug('proNameList====》'+proNameList);
        Map<String,Price_List__c> proNameMap  =new Map<String,Price_List__c>();
        if(proNameList.size()>0){
            for(Price_List__c proName : proNameList){
                proNameMap.put(proName.Name,proName);
            }
        }

        //校验代加工产品是否存在
        List<Contract_Processing_Product__c> contractProNameList = [SELECT Id, Name FROM Contract_Processing_Product__c WHERE Name IN:contractProNameSet];
        System.debug('contractProNameList====》'+contractProNameList);
        Map<String,Contract_Processing_Product__c> contractpProNameMap  =new Map<String,Contract_Processing_Product__c>();
        if(contractProNameList.size()>0){
            for(Contract_Processing_Product__c contractProName : contractProNameList){
                contractpProNameMap.put(contractProName.Name,contractProName);
            }
        }

        //校验包装是否存在
        List<Package_Data__c> packageDataList = [SELECT Id, Name FROM Package_Data__c  WHERE Name IN:packSizeSet];
        System.debug('packageDataList====》'+packageDataList);
        Map<String,String> packageDataMap  =new Map<String,String>();
        if(packageDataList.size()>0){
            for(Package_Data__c packData : packageDataList){
                packageDataMap.put(packData.Name,packData.Id);
            }
        }
        //List<Sales_Forcast__c> upsertSalesTar = new List<Sales_Forcast__c>();
        List<Quote_Detail__c> insertsList = new List<Quote_Detail__c>();  
        Integer rowNum = 3;
        Set<String> keySet = new Set<String>();
        Set<String>  vertifyDupilcateData= new Set<String>();
        for(Object testObj : testList) {
            Integer flag = 0;
            Map<String, Object> testMap = (Map<String, Object>)testObj;
            // String testJson = JSON.serialize(testObj);
            Quote_Detail__c quoteDetail = new Quote_Detail__c();
            quoteDetail.Quote__c=quoteId;
            try{
                System.debug('begin: '+ rowNum);
                for(String curField : mustFillValueFields){
                    if(!testMap.containsKey(curField) || String.isBlank(String.valueOf(testMap.get(curField))) ){
                        ValiriFailed(valiriFailedSalesTargets, 
                                quoteDetail, '\"' + 
                                    excelHeaderKeyToLabelMap.get(curField) + '\"' + System.label.Sales_Forcast_Imp_Required, 
                                    inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                    }
                }

                System.debug('proNameMap----'+proNameMap);
                System.debug('contractpProNameMap----'+contractpProNameMap);
                System.debug('packageDataMap----'+packageDataMap);
                if((quote.Quotation_Type__c=='HQ_Purchase') && ((testMap.get('Price_List__c')!=null && testMap.get('Quote_Product_Name__c')!=null) || (testMap.get('Price_List__c')==null && testMap.get('Quote_Product_Name__c')==null))){
                    flag = ValiriFailed(valiriFailedSalesTargets, quoteDetail, 'Product Name OR Quote Product Name only Select One,Not Both Write OR Not Write', inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                }
                else{
                if(testMap.get('Price_List__c')!=null && proNameMap.get(String.valueOf(testMap.get('Price_List__c')))==null ){
                    system.debug('product name not exist: ' + testMap.get('Price_List__c') + ' ' + proNameMap.get(String.valueOf(testMap.get('Price_List__c'))));
                    flag = ValiriFailed(valiriFailedSalesTargets, quoteDetail, System.label.Sales_Forcast_Imp_Pro_Name, inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                }
                if(testMap.get('Contract_Processing_Product__c')!=null && contractpProNameMap.get(String.valueOf(testMap.get('Contract_Processing_Product__c')))==null ){
                    system.debug('contract processing product name not exist: ' + testMap.get('Contract_Processing_Product__c') + ' ' + contractpProNameMap.get(String.valueOf(testMap.get('Contract Processing Product Name'))));
                    flag = ValiriFailed(valiriFailedSalesTargets, quoteDetail, 'contract processing product name not exist', inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                }
                if(testMap.get('Packing_Size__c')!=null && String.isBlank(packageDataMap.get(String.valueOf(testMap.get('Packing_Size__c')))) ){
                    system.debug('package size name not exist: ' + testMap.get('Packing_Size__c') + 'package size name not exist' + packageDataMap.get(String.valueOf(testMap.get('Packing_Size__c'))));
                    flag = ValiriFailed(valiriFailedSalesTargets, quoteDetail, 'package size name not exist: ', inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                }
                /*if(testMap.get('Contract_Processing_Product__c')!=null)
                {
                    if(vertifyDupilcateData.contains(String.valueOf(testMap.get('Contract_Processing_Product__c'))))
                    {
                        flag = ValiriFailed(valiriFailedSalesTargets, quoteDetail, 'Exist Same Contract Processing Product Name '+String.valueOf(testMap.get('Contract_Processing_Product__c')), inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                    }
                    else
                    {
                        vertifyDupilcateData.add(String.valueOf(testMap.get('Contract_Processing_Product__c')));
                    }
                    
                }
                if(testMap.get('Price_List__c')!=null)
                {
                    if(vertifyDupilcateData.contains(String.valueOf(testMap.get('Price_List__c'))))
                    {
                        flag = ValiriFailed(valiriFailedSalesTargets, quoteDetail, 'Exist Same  Product Name '+String.valueOf(testMap.get('Price_List__c')), inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                    }
                    else
                    {
                        vertifyDupilcateData.add(String.valueOf(testMap.get('Price_List__c')));
                        quoteDetail.Is_Hand_Add__c=true;
                    }
                }
                if(testMap.get('Quote_Product_Name__c')!=null)
                {
                    if(vertifyDupilcateData.contains(String.valueOf(testMap.get('Quote_Product_Name__c'))))
                    {
                        flag = ValiriFailed(valiriFailedSalesTargets, quoteDetail, 'Exist Same  Quote Product Name '+String.valueOf(testMap.get('Quote_Product_Name__c')), inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                    }
                    else
                    {
                        vertifyDupilcateData.add(String.valueOf(testMap.get('Quote_Product_Name__c')));
                        quoteDetail.Is_Hand_Add__c=true;
                    }
                }*/
                quoteDetail.CIF_90_Days__c=String.valueOf(testMap.get('CIF_90_Days__c')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('CIF_90_Days__c')));
                quoteDetail.Commission__c=String.valueOf(testMap.get('Commission__c')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Commission__c')));
                quoteDetail.Freight_Cost__c=String.valueOf(testMap.get('Freight_Cost__c')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Freight_Cost__c')));
                quoteDetail.Packing_Cost__c=String.valueOf(testMap.get('Packing_Cost__c')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Packing_Cost__c')));
                quoteDetail.Pallet__c=String.valueOf(testMap.get('Pallet__c')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Pallet__c')));
                quoteDetail.Order_Qnty__c=String.valueOf(testMap.get('Order_Qnty__c')) == null ? 0 : Integer.valueof(String.valueOf(testMap.get('Order_Qnty__c')));
                quoteDetail.Clearance_Cost_Percentage__c=String.valueOf(testMap.get('Clearance_Cost_Percentage__c')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Clearance_Cost_Percentage__c')))*100;
                quoteDetail.Payment_Terms__c=quote.Payment_Term_Cost_Rate__c;
                quoteDetail.Cost__c=String.valueOf(testMap.get('Cost__c')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Cost__c')));
                quoteDetail.Process_Cost__c=String.valueOf(testMap.get('Process_Cost__c')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Process_Cost__c')));
                quoteDetail.Inland_Cost_Including_Insurance__c=String.valueOf(testMap.get('Inland_Cost_Including_Insurance__c')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Inland_Cost_Including_Insurance__c')));
                quoteDetail.Unit__c=String.valueOf(testMap.get('Unit__c'));
                
                if(testMap.get('Packing_Size__c') != null && packageDataMap.get(String.valueOf(testMap.get('Packing_Size__c'))) != null)
                {
                    quoteDetail.Packing_Size__c=packageDataMap.get(String.valueOf(testMap.get('Packing_Size__c')));
                }
                if(quote.Quotation_Type__c=='HQ_Purchase' )
                {
                    //基于Price List报价时,FOB Price 自动带出
                    if(testMap.get('Price_List__c')!=null && testMap.get('Quote_Product_Name__c')==null)
                    {
                        quoteDetail.FOB_Price__c=proNameMap.get(String.valueOf(testMap.get('Price_List__c'))) == null ? 0 : proNameMap.get(String.valueOf(testMap.get('Price_List__c'))).FOB_Price__c;
                        quoteDetail.Unit__c=proNameMap.get(String.valueOf(testMap.get('Price_List__c'))) == null ? null : proNameMap.get(String.valueOf(testMap.get('Price_List__c'))).Unit__c;
                        
                    }
                    else
                    {
                        quoteDetail.FOB_Price__c=Decimal.valueOf(String.valueOf(testMap.get('FOB_Price__c')));
                    }
                    if(testMap.get('Price_List__c') != null && proNameMap.get(String.valueOf(testMap.get('Price_List__c'))) != null)
                    {
                        quoteDetail.Price_List__c=proNameMap.get(String.valueOf(testMap.get('Price_List__c'))).Id;
                        quoteDetail.Quote_Product_Name__c=proNameMap.get(String.valueOf(testMap.get('Price_List__c'))).Name;
                    }
                    if(testMap.get('Quote_Product_Name__c') != null)
                    {
                        quoteDetail.Quote_Product_Name__c=String.valueOf(testMap.get('Quote_Product_Name__c'));
                    }
                    quoteDetail.Is_Hand_Add__c=true;
                    /*if(quoteDetail.Price_List__c != null)
                    {
                        quoteDetail.External_Id__c=quoteId+'_'+quoteDetail.Price_List__c;
                    }
                    if(quoteDetail.Price_List__c == null && quoteDetail.Quote_Product_Name__c != null)
                    {
                        quoteDetail.External_Id__c=quoteId+'_'+quoteDetail.Quote_Product_Name__c;
                    }*/
                    
                     
                }
                else
                {       
                    if(testMap.get('Contract_Processing_Product__c') != null && contractpProNameMap.get(String.valueOf(testMap.get('Contract_Processing_Product__c'))) != null)
                    {
                        quoteDetail.Contract_Processing_Product__c=contractpProNameMap.get(String.valueOf(testMap.get('Contract_Processing_Product__c'))).Id;
                        quoteDetail.Quote_Product_Name__c=contractpProNameMap.get(String.valueOf(testMap.get('Contract_Processing_Product__c'))).Name;
                    }
                    
                }
                setData(quoteDetail,quote.Quotation_Type__c);
                insertsList.add(quoteDetail);
            }


            }catch(Exception e) {
                flag = ValiriFailed(valiriFailedSalesTargets, quoteDetail,System.Label.Sales_Forcast_Imp_System_Exception + e.getMessage() + '[' + e.getLineNumber() + ']' , inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
            }

            System.debug(rowNum);
            System.debug(testMap);
            System.debug(valiriFailedSalesTargets);
            rowNum = rowNum + 1;
        } 
        
        
        
        //回滚
        System.savepoint sp = Database.setSavepoint();
        try {
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
                List<Quote_Detail__c> delQuoteDetail=[SELECT Id FROM Quote_Detail__c WHERE Quote__c=:quoteId];
                if(delQuoteDetail.size()>0)
                {
                    Database.delete(delQuoteDetail);
                }
                System.debug('insertsList==>'+insertsList);
                //插入数据
                Database.upsert(insertsList);
                //Database.upsert(insertsList,Quote_Detail__c.fields.External_Id__c);
                System.debug('insertsList.size()==>'+insertsList.size());
                insertResult.lResult = 'Success';
                insertResult.successValiAmount = insertsList.size();
                insertResult.failedValiAmount = 0;
                insertResult.successInsertAmount = insertsList.size();    
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

    //计算逻辑
    public static void setData(Quote_Detail__c quoteDetail,String quoteTyep) {
        Decimal sumCost=0;
        if (quoteTyep=='HQ_Purchase') {
            if(quoteDetail.FOB_Price__c != null)
            {
                sumCost=sumCost+quoteDetail.FOB_Price__c;
            }
            if(quoteDetail.Packing_Cost__c != null)
            {
                sumCost=sumCost+quoteDetail.Packing_Cost__c;
            }
            if(quoteDetail.Pallet__c != null)
            {
                sumCost=sumCost+quoteDetail.Pallet__c;
            }
            if(quoteDetail.Freight_Cost__c != null)
            {
                sumCost=sumCost+quoteDetail.Freight_Cost__c;
            }
            if(quoteDetail.Commission__c != null)
            {
                sumCost=sumCost+quoteDetail.Commission__c;
            }
            System.debug('sumCost----'+sumCost);
            quoteDetail.CIF_90_Days_Without_Margin__c=sumCost.setScale(5);
            if(quoteDetail.CIF_90_Days_Without_Margin__c != null && quoteDetail.Payment_Terms__c != null)
            {
                quoteDetail.CIF_90_Days_Without_Margin__c=(quoteDetail.CIF_90_Days_Without_Margin__c*quoteDetail.Payment_Terms__c).setScale(5);
            }
            if(quoteDetail.CIF_90_Days_Without_Margin__c != null && quoteDetail.Clearance_Cost_Percentage__c != null)
            {
                quoteDetail.CIF_90_Days_Without_Margin__c=(quoteDetail.CIF_90_Days_Without_Margin__c*(1+quoteDetail.Clearance_Cost_Percentage__c/100)).setScale(5);
            }
            if(quoteDetail.CIF_90_Days_Without_Margin__c != null && quoteDetail.Inland_Cost_Including_Insurance__c != null && quoteDetail.Payment_Terms__c != null)
            {
                quoteDetail.CIF_90_Days_Without_Margin__c=(quoteDetail.CIF_90_Days_Without_Margin__c+(quoteDetail.Inland_Cost_Including_Insurance__c*quoteDetail.Payment_Terms__c)).setScale(5);
            }
            if(quoteDetail.Commission__c != null && quoteDetail.FOB_Price__c != null && quoteDetail.FOB_Price__c != 0)
            {
                quoteDetail.Commission_Percent__c=(100*(quoteDetail.Commission__c/quoteDetail.FOB_Price__c)).setScale(2);
            }
            else
            {
                quoteDetail.Commission_Percent__c=null;
            }
            if(quoteDetail.Commission__c != null && quoteDetail.CIF_90_Days_Without_Margin__c != null)
            {
                quoteDetail.CIF_Price_Include_Commission__c=(quoteDetail.Commission__c+quoteDetail.CIF_90_Days_Without_Margin__c).setScale(5);
            }
            else
            {
                quoteDetail.CIF_Price_Include_Commission__c=null;
            }
        }else{
            //quoteDetail.External_Id__c=quoteId+'_'+quoteDetail.Contract_Processing_Product__c;
            if(quoteDetail.Packing_Cost__c != null)
            {
                sumCost=sumCost+quoteDetail.Packing_Cost__c;
            }
            if(quoteDetail.Cost__c != null)
            {
                sumCost=sumCost+quoteDetail.Cost__c;
            }
            if(quoteDetail.Process_Cost__c != null)
            {
                sumCost=sumCost+quoteDetail.Process_Cost__c;
            }
            System.debug('sumCost----'+sumCost);
            quoteDetail.CIF_90_Days_Without_Margin__c=sumCost.setScale(5);
            if(quoteDetail.CIF_90_Days_Without_Margin__c != null && quoteDetail.Payment_Terms__c != null)
            {
                quoteDetail.CIF_90_Days_Without_Margin__c=(quoteDetail.CIF_90_Days_Without_Margin__c*quoteDetail.Payment_Terms__c).setScale(5);
            }
        }
        


        if(quoteDetail.CIF_90_Days_Without_Margin__c != null && quoteDetail.CIF_90_Days__c != null)
        {
            quoteDetail.BU_Profit_Rate__c=(100*(quoteDetail.CIF_90_Days__c-quoteDetail.CIF_90_Days_Without_Margin__c)/quoteDetail.CIF_90_Days__c).setScale(5);
        }
        else
        {
            quoteDetail.BU_Profit_Rate__c=null;
        }
        if(quoteDetail.CIF_90_Days_Without_Margin__c  != null && quoteDetail.Order_Qnty__c != null)
        {
            quoteDetail.Item_Cost__c=(quoteDetail.CIF_90_Days_Without_Margin__c*quoteDetail.Order_Qnty__c).setScale(5);
        }
        else
        {
            quoteDetail.Item_Cost__c=null;
        }
        if(quoteDetail.CIF_90_Days__c != null && quoteDetail.Order_Qnty__c != null)
        {
            quoteDetail.Item_Price__c=(quoteDetail.CIF_90_Days__c*quoteDetail.Order_Qnty__c).setScale(5);
        }
        else
        {
            quoteDetail.Item_Price__c=null;
        }
        if(quoteDetail.CIF_90_Days__c != null && quoteDetail.CIF_90_Days_Without_Margin__c != null)
        {
            quoteDetail.Gross_Margin__c=quoteDetail.CIF_90_Days__c-quoteDetail.CIF_90_Days_Without_Margin__c;
        }
        else
        {
            quoteDetail.Gross_Margin__c=null;
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