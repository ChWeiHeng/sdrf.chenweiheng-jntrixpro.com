/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 06-06-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-15-2025   Gerry   Initial Version
**/
public without sharing class BatchImportSalesForecastController {
    //初始化数据
    @AuraEnabled
    public static InitData getInitData(String id){
        InitData init = new InitData();
        
        List<Sales_Forecast_Summary__c> statusList = [SELECT Delivery_Plant__c,Id,Status__c,Sales_Org__c FROM Sales_Forecast_Summary__c WHERE Id =: id];
        //检验导入用户是否是同一sales org
        List<User> impoUserList = [SELECT Id,Sales_Org__c,Delivery_Plant__c,Email FROM User WHERE Id=:System.UserInfo.getUserId()];
        init.userFlag = '0';
        if (
            impoUserList[0].Email != 'marvin_sun@rainbowagro.com'  && impoUserList[0].Email != 'marvin_sun@rainbowagro.com.rbdev' && 
            (
                statusList[0].Sales_Org__c != impoUserList[0].Sales_Org__c || 
                statusList[0].Delivery_Plant__c != impoUserList[0].Delivery_Plant__c
            )
        ) {
            init.userFlag = '1';
        }
        //获取模板链接
        List<ContentDistribution> salesLink;
        //获取 数据导入字段配置 对象中配置的字段
        List<ImportDataFieldConf__c> fieldConfs;
        
        if (statusList[0].Status__c == 'Approved') {
            DataImportTemplate__c fileidSalesOrg = DataImportTemplate__c.getValues('Sales_Forcast_Rolling');
            String salesOrgValue = fileidSalesOrg.FileId__c;
            salesLink = [SELECT Id, ContentDownloadUrl, DistributionPublicUrl
                                                          FROM ContentDistribution 
                                                          WHERE ContentDocumentId =: salesOrgValue  LIMIT 1];
            init.salesType = 'Rolling';
            fieldConfs = [SELECT Id, Obj_Name__c, Field_Label_Name__c,  
                                                    Field_Api_Name__c,Data_Type__c, If_Need__c 
                                                    FROM ImportDataFieldConf__c 
                                                    WHERE Obj_Name__c = 'Sales_Forcast_Rolling __c' ];
        }else{
            DataImportTemplate__c fileidSalesOrg = DataImportTemplate__c.getValues('Sales_Forcast');
            String salesOrgValue = fileidSalesOrg.FileId__c;
            salesLink = [SELECT Id, ContentDownloadUrl, DistributionPublicUrl
                                                          FROM ContentDistribution 
                                                          WHERE ContentDocumentId =: salesOrgValue  LIMIT 1];
            init.salesType = 'Annual';
            fieldConfs = [SELECT Id, Obj_Name__c, Field_Label_Name__c,  
                                                    Field_Api_Name__c,Data_Type__c, If_Need__c 
                                                    FROM ImportDataFieldConf__c 
                                                    WHERE Obj_Name__c = 'Sales_Forcast__c' ];
        }
        
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
            //设置必填字段
            if(curConf.If_Need__c == true){
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
    public static Integer ValiriFailed(List<ValiriFailedSalesTarget> valiriFailedSalesTargets, Sales_Forcast__c salesTar, String failedReason, Map<String, ValiriFailedSalesTarget> inveRepo_inveRepoValiriFail, String execlRowNum){
       
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
    public static InsertSalesTargetResult saveData( String TargetJson,Map<String,String> excelHeaderKeyToLabelMap, List<String> mustFillValueFields,String salesId,String type) {
        if(!Test.isRunningTest()){
            TargetJson = '[' + TargetJson.substring(TargetJson.indexOf(',{')+1); // 去掉execl表头
        }

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
        List<Sales_Forcast__c> insertsList = new List<Sales_Forcast__c>();   //销售预测 数据插入

        // Integer  num = 0;
        List<Object> testList = (List<Object>)JSON.deserializeUntyped(TargetJson);
        System.debug('testList==>'+testList);
        Set<String> AccoNumList  = new Set<String>();     //客户编码
        Set<String> proNameNumList  =  new Set<String>();    //商品名
        Set<String> userEmailList  =  new Set<String>();    //商品名
        if(testList.size()>0){
            for(Object testItem : testList){
                Map<String, Object> sales = (Map<String, Object>) testItem;
                AccoNumList.add(String.valueOf(sales.get('Customer__c')));
                proNameNumList.add(String.valueOf(sales.get('Product_Name__c')));
                userEmailList.add(String.valueOf(sales.get('Owner_Email')));
            }
        }
		system.debug('proNameNumList: ' + proNameNumList);
        
        //取年份
        List<Sales_Forecast_Summary__c> sfYearList = [SELECT Id,Year__c,Sales_Org__c,Status__c,Delivery_Plant__c FROM Sales_Forecast_Summary__c WHERE Id =: salesId];
        String year = sfYearList[0].Year__c;
        String sfStatus = sfYearList[0].Status__c;
        String slaesOrg = sfYearList[0].Sales_Org__c;
        String plan = sfYearList[0].Delivery_Plant__c;
        //校验客户是否存在
        List<Account> accList = [SELECT id,MDG_Customer_Code__c,Virtual_customer__c FROM Account WHERE MDG_Customer_Code__c IN:AccoNumList];
        System.debug('accList====》'+accList);
        Map<String,String> accMap  =new Map<String,String>();
        Map<String,Boolean> accVirtualMap  =new Map<String,Boolean>();
        if(accList.size()>0){
            for(Account acc : accList){
                accMap.put(acc.MDG_Customer_Code__c,acc.Id);
                accVirtualMap.put(acc.MDG_Customer_Code__c,acc.Virtual_customer__c);
            }
        }

        //如果是滚动校验是否导入客户存在于数据中
        // Map<String,String> accExistMap = new Map<String,String>();
        // if (sfStatus == 'Approved') {
        //     List<Sales_Forcast__c> sfList = [SELECT id,Customer__r.MDG_Customer_Code__c FROM Sales_Forcast__c WHERE Customer__r.MDG_Customer_Code__c IN:AccoNumList];
            
        //     if(sfList.size()>0){
        //         for(Sales_Forcast__c acc : sfList){
        //             accExistMap.put(acc.Customer__r.MDG_Customer_Code__c,acc.Id);
        //         }
        //     }
        // }

        //校验商品名是否存在
        List<Product_Name__c> proNameList = [SELECT Id, Name FROM Product_Name__c WHERE Name IN:proNameNumList AND Product_Sales_Info__r.Status__c='On Shelves' AND Is_Delete__c=false];//添加商品名称删除逻辑
        System.debug('proNameList====》'+proNameList);
        Map<String,String> proNameMap  =new Map<String,String>();
        if(proNameList.size()>0){
            for(Product_Name__c proName : proNameList){
                proNameMap.put(proName.Name,proName.Id);
            }
        }

        //校验用户是否存在
        List<User> userList = [SELECT Id, Username,Sales_Org__c FROM User WHERE Username IN:userEmailList];
        System.debug('userList====》'+userList);
        Map<String,String> userMap  =new Map<String,String>();
        if(userList.size()>0){
            for(User u : userList){
                userMap.put(u.Username,u.Id);
            }
        }
        List<Sales_Forcast__c> upsertSalesTar = new List<Sales_Forcast__c>();
        Integer rowNum = 4;
        Set<String> keySet = new Set<String>();
        for(Object testObj : testList) {
            Integer flag = 0;
            Map<String, Object> testMap = (Map<String, Object>)testObj;
            // String testJson = JSON.serialize(testObj);
            Sales_Forcast__c sales = new Sales_Forcast__c();
            try{
                System.debug('begin: '+ rowNum);
                for(String curField : mustFillValueFields){
                    //如果是虚拟客户用户可以不填写
                    // if (curField == 'Owner_Email' && testMap.get('Customer__c')!=null && accVirtualMap.get(String.valueOf(testMap.get('Customer__c')))) {
                    //     continue;
                    // }
                    if(!testMap.containsKey(curField) || String.isBlank(String.valueOf(testMap.get(curField))) ){
                        ValiriFailed(valiriFailedSalesTargets, 
                                sales, '\"' + 
                                    excelHeaderKeyToLabelMap.get(curField) + '\"' + System.label.Sales_Forcast_Imp_Required, 
                                    inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                    }
                }
                if (type=='Annual') {
                    if(String.valueOf(testMap.get('Target_1_USD'))!=null){
                        if(!String.valueOf(testMap.get('Target_1_USD')).contains('.')){
                            if(!isNumber(String.valueOf(testMap.get('Target_1_USD')))){    
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_Jan, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }
                        }else {
                            if(!isNumber(String.valueOf(testMap.get('Target_1_USD')))){
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_Jan, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }  
                        }
                    }
                    if(String.valueOf(testMap.get('Target_2_USD'))!=null){
                        if(!isNumber(String.valueOf(testMap.get('Target_2_USD')))){
                            if(!isNumber(String.valueOf(testMap.get('Target_2_USD')))){              
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_February, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }
                        }else {
                            if(!isNumber(String.valueOf(testMap.get('Target_2_USD')))){
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_February, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }  
                        }
                    }
                    if(String.valueOf(testMap.get('Target_3_USD'))!=null){
                        if(!String.valueOf(testMap.get('Target_3_USD')).contains('.')){
                            if(!isNumber(String.valueOf(testMap.get('Target_3_USD')))){              
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_March, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }
                        }else {
                            if(!isNumber(String.valueOf(testMap.get('Target_3_USD')))){
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_March, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }  
                        }
                    }
                    if(String.valueOf(testMap.get('Target_4_USD'))!=null){
                        if(!String.valueOf(testMap.get('Target_4_USD')).contains('.')){
                            if(!isNumber(String.valueOf(testMap.get('Target_4_USD')))){              
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_April, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }
                        }else {
                            if(!isNumber(String.valueOf(testMap.get('Target_4_USD')))){
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_April, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }  
                        }
                    }
                    if(String.valueOf(testMap.get('Target_5_USD'))!=null){
                        if(!String.valueOf(testMap.get('Target_5_USD')).contains('.')){
                            if(!isNumber(String.valueOf(testMap.get('Target_5_USD')))){              
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_May, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }
                        }else {
                            if(!isNumber(String.valueOf(testMap.get('Target_5_USD')))){
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_May, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }  
                        }
                    }
                    if(String.valueOf(testMap.get('Target_6_USD'))!=null){
                        if(!String.valueOf(testMap.get('Target_6_USD')).contains('.')){
                            if(!isNumber(String.valueOf(testMap.get('Target_6_USD')))){              
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_June, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }
                        }else {
                            if(!isNumber(String.valueOf(testMap.get('Target_6_USD')))){
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_June, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }  
                        }
                    }
                    if(String.valueOf(testMap.get('Target_7_USD'))!=null){
                        if(!String.valueOf(testMap.get('Target_7_USD')).contains('.')){
                            if(!isNumber(String.valueOf(testMap.get('Target_7_USD')))){              
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_July, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }
                        }else {
                            if(!isNumber(String.valueOf(testMap.get('Target_7_USD')))){
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_July, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }  
                        }
                    }
                    if(String.valueOf(testMap.get('Target_8_USD'))!=null){
                        if(!String.valueOf(testMap.get('Target_8_USD')).contains('.')){
                            if(!isNumber(String.valueOf(testMap.get('Target_8_USD')))){              
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_August, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }
                        }else {
                            if(!isNumber(String.valueOf(testMap.get('Target_8_USD')))){
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_August, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }  
                        }
                    }
                    if(String.valueOf(testMap.get('Target_9_USD'))!=null){
                        if(!String.valueOf(testMap.get('Target_9_USD')).contains('.')){
                            if(!isNumber(String.valueOf(testMap.get('Target_9_USD')))){              
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_September, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }
                        }else {
                            if(!isNumber(String.valueOf(testMap.get('Target_9_USD')))){
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_September, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }  
                        }
                    }
                    if(String.valueOf(testMap.get('Target_10_USD'))!=null){
                        if(!String.valueOf(testMap.get('Target_10_USD')).contains('.')){
                            if(!isNumber(String.valueOf(testMap.get('Target_10_USD')))){              
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_October, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }
                        }else {
                            if(!isNumber(String.valueOf(testMap.get('Target_10_USD')))){
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_October, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }  
                        }
                    }
                    if(String.valueOf(testMap.get('Target_11_USD'))!=null){
                        if(!String.valueOf(testMap.get('Target_11_USD')).contains('.')){
                            if(!isNumber(String.valueOf(testMap.get('Target_11_USD')))){              
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_November, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }
                        }else {
                            if(!isNumber(String.valueOf(testMap.get('Target_11_USD')))){
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_November, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }  
                        }
                    }
                    if(String.valueOf(testMap.get('Target_12_USD'))!=null){
                        if(!String.valueOf(testMap.get('Target_12_USD')).contains('.')){
                            if(!isNumber(String.valueOf(testMap.get('Target_12_USD')))){              
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_December, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }
                        }else {
                            if(!isNumber(String.valueOf(testMap.get('Target_12_USD')))){
                                flag = ValiriFailed(valiriFailedSalesTargets, sales , System.Label.Sales_Forcast_Imp_December, inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                            }  
                        }
                    }
                }
                
                System.debug('accMap----'+accMap);
                System.debug('proNameMap----'+proNameMap);
                System.debug('userMap----'+userMap);
                if(testMap.get('Customer__c')!=null && String.isBlank(accMap.get(String.valueOf(testMap.get('Customer__c')))) ){
                    flag = ValiriFailed(valiriFailedSalesTargets, sales, System.label.Sales_Forcast_Imp_Customer, inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                }

                //滚动预测校验数据是否存在于数据中
                // if(sfStatus == 'Approved' && testMap.get('Customer__c')!=null && String.isBlank(accExistMap.get(String.valueOf(testMap.get('Customer__c')))) ){
                //     flag = ValiriFailed(valiriFailedSalesTargets, sales, System.label.Rolling_Not_Customer, inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                // }

                if(testMap.get('Product_Name__c')!=null && String.isBlank(proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))) ){
                    system.debug('product name not exist: ' + testMap.get('Product_Name__c') + ' ' + proNameMap.get(String.valueOf(testMap.get('Product_Name__c'))));
                    flag = ValiriFailed(valiriFailedSalesTargets, sales, System.label.Sales_Forcast_Imp_Pro_Name, inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                }
                System.debug('testMap.get----'+testMap.get('Owner_Email'));
                System.debug('userMap.getSv----'+String.valueOf(testMap.get('Owner_Email')));
                System.debug('userMap.getSv----'+userMap.get(String.valueOf(testMap.get('Owner_Email'))));
                if(testMap.get('Owner_Email')!=null && String.isBlank(userMap.get(String.valueOf(testMap.get('Owner_Email')))) ){
                    flag = ValiriFailed(valiriFailedSalesTargets, sales, System.label.Sales_Forcast_Imp_User, inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                }
                Sales_Forcast__c sales1 = new Sales_Forcast__c();
                Sales_Forcast__c sales2 = new Sales_Forcast__c();
                Sales_Forcast__c sales3 = new Sales_Forcast__c();
                Sales_Forcast__c sales4 = new Sales_Forcast__c();
                Sales_Forcast__c sales5 = new Sales_Forcast__c();
                Sales_Forcast__c sales6 = new Sales_Forcast__c();
                Sales_Forcast__c sales7 = new Sales_Forcast__c();
                Sales_Forcast__c sales8 = new Sales_Forcast__c();
                Sales_Forcast__c sales9 = new Sales_Forcast__c();
                Sales_Forcast__c sales10 = new Sales_Forcast__c();
                Sales_Forcast__c sales11 = new Sales_Forcast__c();
                Sales_Forcast__c sales12 = new Sales_Forcast__c();

                Decimal peiceUsd = String.valueOf(testMap.get('Price_USD__c')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Price_USD__c')));
                Decimal peiceLocal = String.valueOf(testMap.get('Price_Local__c')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Price_Local__c')));

                String sfRecordId = Schema.SObjectType.Sales_Forcast__c.getRecordTypeInfosByDeveloperName().get('Detail_Sales_Forecast').getRecordTypeId();
                

                String key = year+proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))+
                                        accMap.get(String.valueOf(testMap.get('Customer__c')))+
                                        userMap.get(String.valueOf(testMap.get('Owner_Email')));
                if (keySet.contains(key)) {
                    flag = ValiriFailed(valiriFailedSalesTargets, sales, System.label.Sales_Forcast_Imp_Repeat, inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                }else{
                    keySet.add(key);
                }
                
                sales1.Month__c = '1';
                sales1.Quarter__c = 'Q1';
                sales1.Year__c = year;
                sales1.Customer__c = accMap.get(String.valueOf(testMap.get('Customer__c')));
                sales1.Product_Name__c = proNameMap.get(String.valueOf(testMap.get('Product_Name__c')));
                if (testMap.get('Customer__c')!=null && accVirtualMap.get(String.valueOf(testMap.get('Customer__c')))) {
                    setOwnerData(userMap,String.valueOf(testMap.get('Owner_Email')),sales1,slaesOrg,plan);
                }else{
                    sales1.OwnerId = userMap.get(String.valueOf(testMap.get('Owner_Email')));
                }
                
                sales1.Sales_Forecast_Summary__c = salesId;
                sales1.RecordTypeId = sfRecordId;
                sales1.External_Id__c = year+'1'+proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))+
                                        accMap.get(String.valueOf(testMap.get('Customer__c')))+
                                        sales1.OwnerId;
                sales2.Month__c = '2';
                sales2.Quarter__c = 'Q1';
                sales2.Year__c = year;
                sales2.Customer__c = accMap.get(String.valueOf(testMap.get('Customer__c')));
                sales2.Product_Name__c = proNameMap.get(String.valueOf(testMap.get('Product_Name__c')));
                if (testMap.get('Customer__c')!=null && accVirtualMap.get(String.valueOf(testMap.get('Customer__c')))) {
                    setOwnerData(userMap,String.valueOf(testMap.get('Owner_Email')),sales2,slaesOrg,plan);
                }else{
                    sales2.OwnerId = userMap.get(String.valueOf(testMap.get('Owner_Email')));
                }
                sales2.Sales_Forecast_Summary__c = salesId;
                sales2.RecordTypeId = sfRecordId;
                sales2.External_Id__c = year+'2'+proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))+
                                        accMap.get(String.valueOf(testMap.get('Customer__c')))+
                                        sales2.OwnerId;
                sales3.Month__c = '3';
                sales3.Quarter__c = 'Q1';
                sales3.Year__c = year;
                sales3.Customer__c = accMap.get(String.valueOf(testMap.get('Customer__c')));
                sales3.Product_Name__c = proNameMap.get(String.valueOf(testMap.get('Product_Name__c')));
                if (testMap.get('Customer__c')!=null && accVirtualMap.get(String.valueOf(testMap.get('Customer__c')))) {
                    setOwnerData(userMap,String.valueOf(testMap.get('Owner_Email')),sales3,slaesOrg,plan);
                }else{
                    sales3.OwnerId = userMap.get(String.valueOf(testMap.get('Owner_Email')));
                }
                sales3.Sales_Forecast_Summary__c = salesId;
                sales3.RecordTypeId = sfRecordId;
                sales3.External_Id__c = year+'3'+proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))+
                                        accMap.get(String.valueOf(testMap.get('Customer__c')))+
                                        sales3.OwnerId;
                sales4.Month__c = '4';
                sales4.Quarter__c = 'Q2';
                sales4.Year__c = year;
                sales4.Customer__c = accMap.get(String.valueOf(testMap.get('Customer__c')));
                sales4.Product_Name__c = proNameMap.get(String.valueOf(testMap.get('Product_Name__c')));
                if (testMap.get('Customer__c')!=null && accVirtualMap.get(String.valueOf(testMap.get('Customer__c')))) {
                    setOwnerData(userMap,String.valueOf(testMap.get('Owner_Email')),sales4,slaesOrg,plan);
                }else{
                    sales4.OwnerId = userMap.get(String.valueOf(testMap.get('Owner_Email')));
                }
                sales4.Sales_Forecast_Summary__c = salesId;
                sales4.RecordTypeId = sfRecordId;
                sales4.External_Id__c = year+'4'+proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))+
                                        accMap.get(String.valueOf(testMap.get('Customer__c')))+
                                        sales4.OwnerId;
                sales5.Month__c = '5';
                sales5.Quarter__c = 'Q2';
                sales5.Year__c = year;
                sales5.Customer__c = accMap.get(String.valueOf(testMap.get('Customer__c')));
                sales5.Product_Name__c = proNameMap.get(String.valueOf(testMap.get('Product_Name__c')));
                if (testMap.get('Customer__c')!=null && accVirtualMap.get(String.valueOf(testMap.get('Customer__c')))) {
                    setOwnerData(userMap,String.valueOf(testMap.get('Owner_Email')),sales5,slaesOrg,plan);
                }else{
                    sales5.OwnerId = userMap.get(String.valueOf(testMap.get('Owner_Email')));
                }
                sales5.Sales_Forecast_Summary__c = salesId;
                sales5.RecordTypeId = sfRecordId;
                sales5.External_Id__c = year+'5'+proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))+
                                        accMap.get(String.valueOf(testMap.get('Customer__c')))+
                                        sales5.OwnerId;
                sales6.Month__c = '6';
                sales6.Quarter__c = 'Q2';
                sales6.Year__c = year;
                sales6.Customer__c = accMap.get(String.valueOf(testMap.get('Customer__c')));
                sales6.Product_Name__c = proNameMap.get(String.valueOf(testMap.get('Product_Name__c')));
                if (testMap.get('Customer__c')!=null && accVirtualMap.get(String.valueOf(testMap.get('Customer__c')))) {
                    setOwnerData(userMap,String.valueOf(testMap.get('Owner_Email')),sales6,slaesOrg,plan);
                }else{
                    sales6.OwnerId = userMap.get(String.valueOf(testMap.get('Owner_Email')));
                }
                sales6.Sales_Forecast_Summary__c = salesId;
                sales6.RecordTypeId = sfRecordId;
                sales6.External_Id__c = year+'6'+proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))+
                                        accMap.get(String.valueOf(testMap.get('Customer__c')))+
                                        sales6.OwnerId;
                sales7.Month__c = '7';
                sales7.Quarter__c = 'Q3';
                sales7.Year__c = year;
                sales7.Customer__c = accMap.get(String.valueOf(testMap.get('Customer__c')));
                sales7.Product_Name__c = proNameMap.get(String.valueOf(testMap.get('Product_Name__c')));
                if (testMap.get('Customer__c')!=null && accVirtualMap.get(String.valueOf(testMap.get('Customer__c')))) {
                    setOwnerData(userMap,String.valueOf(testMap.get('Owner_Email')),sales7,slaesOrg,plan);
                }else{
                    sales7.OwnerId = userMap.get(String.valueOf(testMap.get('Owner_Email')));
                }
                sales7.Sales_Forecast_Summary__c = salesId;
                sales7.RecordTypeId = sfRecordId;
                sales7.External_Id__c = year+'7'+proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))+
                                        accMap.get(String.valueOf(testMap.get('Customer__c')))+
                                        sales7.OwnerId;
                sales8.Month__c = '8';
                sales8.Quarter__c = 'Q3';
                sales8.Year__c = year;
                sales8.Customer__c = accMap.get(String.valueOf(testMap.get('Customer__c')));
                sales8.Product_Name__c = proNameMap.get(String.valueOf(testMap.get('Product_Name__c')));
                if (testMap.get('Customer__c')!=null && accVirtualMap.get(String.valueOf(testMap.get('Customer__c')))) {
                    setOwnerData(userMap,String.valueOf(testMap.get('Owner_Email')),sales8,slaesOrg,plan);
                }else{
                    sales8.OwnerId = userMap.get(String.valueOf(testMap.get('Owner_Email')));
                }
                sales8.Sales_Forecast_Summary__c = salesId;
                sales8.RecordTypeId = sfRecordId;
                sales8.External_Id__c = year+'8'+proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))+
                                        accMap.get(String.valueOf(testMap.get('Customer__c')))+
                                        sales8.OwnerId;
                sales9.Month__c = '9';
                sales9.Quarter__c = 'Q3';
                sales9.Year__c = year;
                sales9.Customer__c = accMap.get(String.valueOf(testMap.get('Customer__c')));
                sales9.Product_Name__c = proNameMap.get(String.valueOf(testMap.get('Product_Name__c')));
                if (testMap.get('Customer__c')!=null && accVirtualMap.get(String.valueOf(testMap.get('Customer__c')))) {
                    setOwnerData(userMap,String.valueOf(testMap.get('Owner_Email')),sales9,slaesOrg,plan);
                }else{
                    sales9.OwnerId = userMap.get(String.valueOf(testMap.get('Owner_Email')));
                }
                sales9.Sales_Forecast_Summary__c = salesId;
                sales9.RecordTypeId = sfRecordId;
                sales9.External_Id__c = year+'9'+proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))+
                                        accMap.get(String.valueOf(testMap.get('Customer__c')))+
                                        sales9.OwnerId;
                sales10.Month__c = '10';
                sales10.Quarter__c = 'Q4';
                sales10.Year__c = year;
                sales10.Customer__c = accMap.get(String.valueOf(testMap.get('Customer__c')));
                sales10.Product_Name__c = proNameMap.get(String.valueOf(testMap.get('Product_Name__c')));
                if (testMap.get('Customer__c')!=null && accVirtualMap.get(String.valueOf(testMap.get('Customer__c')))) {
                    setOwnerData(userMap,String.valueOf(testMap.get('Owner_Email')),sales10,slaesOrg,plan);
                }else{
                    sales10.OwnerId = userMap.get(String.valueOf(testMap.get('Owner_Email')));
                }
                sales10.Sales_Forecast_Summary__c = salesId;
                sales10.RecordTypeId = sfRecordId;
                sales10.External_Id__c = year+'10'+proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))+
                                        accMap.get(String.valueOf(testMap.get('Customer__c')))+
                                        sales10.OwnerId;
                sales11.Month__c = '11';
                sales11.Quarter__c = 'Q4';
                sales11.Year__c = year;
                sales11.Customer__c = accMap.get(String.valueOf(testMap.get('Customer__c')));
                sales11.Product_Name__c = proNameMap.get(String.valueOf(testMap.get('Product_Name__c')));
                if (testMap.get('Customer__c')!=null && accVirtualMap.get(String.valueOf(testMap.get('Customer__c')))) {
                    setOwnerData(userMap,String.valueOf(testMap.get('Owner_Email')),sales11,slaesOrg,plan);
                }else{
                    sales11.OwnerId = userMap.get(String.valueOf(testMap.get('Owner_Email')));
                }
                sales11.Sales_Forecast_Summary__c = salesId;
                sales11.RecordTypeId = sfRecordId;
                sales11.External_Id__c = year+'11'+proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))+
                                        accMap.get(String.valueOf(testMap.get('Customer__c')))+
                                        sales11.OwnerId;
                sales12.Month__c = '12';
                sales12.Quarter__c = 'Q4';
                sales12.Year__c = year;
                sales12.Customer__c = accMap.get(String.valueOf(testMap.get('Customer__c')));
                sales12.Product_Name__c = proNameMap.get(String.valueOf(testMap.get('Product_Name__c')));
                if (testMap.get('Customer__c')!=null && accVirtualMap.get(String.valueOf(testMap.get('Customer__c')))) {
                    setOwnerData(userMap,String.valueOf(testMap.get('Owner_Email')),sales12,slaesOrg,plan);
                }else{
                    sales12.OwnerId = userMap.get(String.valueOf(testMap.get('Owner_Email')));
                }
                sales12.Sales_Forecast_Summary__c = salesId;
                sales12.RecordTypeId = sfRecordId;
                sales12.External_Id__c = year+'12'+proNameMap.get(String.valueOf(testMap.get('Product_Name__c')))+
                                        accMap.get(String.valueOf(testMap.get('Customer__c')))+
                                        sales12.OwnerId;
                
                if (type=='Annual') {
                    if(testMap.get('Target_1_USD')!=null) {
                        sales1.Monthly_Forecast_USD__c = Decimal.valueof(String.valueOf(testMap.get('Target_1_USD')));
                    }
                    
                    sales1.Monthly_Forecast_Local_Curreny__c = String.valueOf(testMap.get('Target_1_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Target_1_Local')));
                    sales1.Volumn_USD__c = String.valueOf(testMap.get('Volumn_1_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_1_USD')));
                    sales1.Volumn_Local__c = String.valueOf(testMap.get('Volumn_1_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_1_Local')));
                    sales1.Price_USD__c = peiceUsd;
                    sales1.Price_Local__c = peiceLocal;

                    if(testMap.get('Target_2_USD')!=null) {
                        sales2.Monthly_Forecast_USD__c = Decimal.valueof(String.valueOf(testMap.get('Target_2_USD')));
                    }
                    
                    sales2.Monthly_Forecast_Local_Curreny__c = String.valueOf(testMap.get('Target_2_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Target_2_Local')));
                    sales2.Volumn_USD__c = String.valueOf(testMap.get('Volumn_2_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_2_USD')));
                    sales2.Volumn_Local__c = String.valueOf(testMap.get('Volumn_2_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_2_Local')));
                    sales2.Price_USD__c = peiceUsd;
                    sales2.Price_Local__c = peiceLocal;

                    if (testMap.get('Target_3_USD')!=null) {
                        sales3.Monthly_Forecast_USD__c = Decimal.valueof(String.valueOf(testMap.get('Target_3_USD')));
                    }
                    
                    sales3.Monthly_Forecast_Local_Curreny__c = String.valueOf(testMap.get('Target_3_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Target_3_Local')));
                    sales3.Volumn_USD__c = String.valueOf(testMap.get('Volumn_3_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_3_USD')));
                    sales3.Volumn_Local__c = String.valueOf(testMap.get('Volumn_3_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_3_Local')));
                    sales3.Price_USD__c = peiceUsd;
                    sales3.Price_Local__c = peiceLocal;

                    if (testMap.get('Target_4_USD')!=null) {
                         sales4.Monthly_Forecast_USD__c = Decimal.valueof(String.valueOf(testMap.get('Target_4_USD')));
                    }
                   
                    sales4.Monthly_Forecast_Local_Curreny__c = String.valueOf(testMap.get('Target_4_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Target_4_Local')));
                    sales4.Volumn_USD__c = String.valueOf(testMap.get('Volumn_4_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_4_USD')));
                    sales4.Volumn_Local__c = String.valueOf(testMap.get('Volumn_4_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_4_Local')));
                    sales4.Price_USD__c = peiceUsd;
                    sales4.Price_Local__c = peiceLocal;
                    
                    if (testMap.get('Target_5_USD')!=null) {
                        sales5.Monthly_Forecast_USD__c = Decimal.valueof(String.valueOf(testMap.get('Target_5_USD')));
                    }
                    
                    sales5.Monthly_Forecast_Local_Curreny__c = String.valueOf(testMap.get('Target_5_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Target_5_Local')));
                    sales5.Volumn_USD__c = String.valueOf(testMap.get('Volumn_5_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_5_USD')));
                    sales5.Volumn_Local__c = String.valueOf(testMap.get('Volumn_5_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_5_Local')));
                    sales5.Price_USD__c = peiceUsd;
                    sales5.Price_Local__c = peiceLocal;

                    if (testMap.get('Target_6_USD')!=null) {
                        sales6.Monthly_Forecast_USD__c = Decimal.valueof(String.valueOf(testMap.get('Target_6_USD')));
                    }
                    
                    sales6.Monthly_Forecast_Local_Curreny__c = String.valueOf(testMap.get('Target_6_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Target_6_Local')));
                    sales6.Volumn_USD__c = String.valueOf(testMap.get('Volumn_6_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_6_USD')));
                    sales6.Volumn_Local__c = String.valueOf(testMap.get('Volumn_6_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_6_Local')));
                    sales6.Price_USD__c = peiceUsd;
                    sales6.Price_Local__c = peiceLocal;

                    if (testMap.get('Target_7_USD')!=null) {
                        sales7.Monthly_Forecast_USD__c = Decimal.valueof(String.valueOf(testMap.get('Target_7_USD')));
                    }
                    
                    sales7.Monthly_Forecast_Local_Curreny__c = String.valueOf(testMap.get('Target_7_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Target_7_Local')));
                    sales7.Volumn_USD__c = String.valueOf(testMap.get('Volumn_7_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_7_USD')));
                    sales7.Volumn_Local__c = String.valueOf(testMap.get('Volumn_7_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_7_Local')));
                    sales7.Price_USD__c = peiceUsd;
                    sales7.Price_Local__c = peiceLocal;

                    if (testMap.get('Target_8_USD')!=null) {
                        sales8.Monthly_Forecast_USD__c = Decimal.valueof(String.valueOf(testMap.get('Target_8_USD')));
                    }
                    
                    sales8.Monthly_Forecast_Local_Curreny__c = String.valueOf(testMap.get('Target_8_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Target_8_Local')));
                    sales8.Volumn_USD__c = String.valueOf(testMap.get('Volumn_8_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_8_USD')));
                    sales8.Volumn_Local__c = String.valueOf(testMap.get('Volumn_8_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_8_Local')));
                    sales8.Price_USD__c = peiceUsd;
                    sales8.Price_Local__c = peiceLocal;

                    if (testMap.get('Target_9_USD')!=null) {
                        sales9.Monthly_Forecast_USD__c = Decimal.valueof(String.valueOf(testMap.get('Target_9_USD')));
                    }
                    
                    sales9.Monthly_Forecast_Local_Curreny__c = String.valueOf(testMap.get('Target_9_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Target_9_Local')));
                    sales9.Volumn_USD__c = String.valueOf(testMap.get('Volumn_9_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_9_USD')));
                    sales9.Volumn_Local__c = String.valueOf(testMap.get('Volumn_9_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_9_Local')));
                    sales9.Price_USD__c = peiceUsd;
                    sales9.Price_Local__c = peiceLocal;

                    if (testMap.get('Target_10_USD')!=null) {
                        sales10.Monthly_Forecast_USD__c = Decimal.valueof(String.valueOf(testMap.get('Target_10_USD')));
                    }
                    
                    sales10.Monthly_Forecast_Local_Curreny__c = String.valueOf(testMap.get('Target_10_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Target_10_Local')));
                    sales10.Volumn_USD__c = String.valueOf(testMap.get('Volumn_10_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_10_USD')));
                    sales10.Volumn_Local__c = String.valueOf(testMap.get('Volumn_10_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_10_Local')));
                    sales10.Price_USD__c = peiceUsd;
                    sales10.Price_Local__c = peiceLocal;

                    if (testMap.get('Target_11_USD')!=null) {
                        sales11.Monthly_Forecast_USD__c = Decimal.valueof(String.valueOf(testMap.get('Target_11_USD')));
                    }
                    
                    sales11.Monthly_Forecast_Local_Curreny__c = String.valueOf(testMap.get('Target_11_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Target_11_Local')));
                    sales11.Volumn_USD__c = String.valueOf(testMap.get('Volumn_11_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_11_USD')));
                    sales11.Volumn_Local__c = String.valueOf(testMap.get('Volumn_11_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_11_Local')));
                    sales11.Price_USD__c = peiceUsd;
                    sales11.Price_Local__c = peiceLocal;

                    if (testMap.get('Target_12_USD')!=null) {
                        sales12.Monthly_Forecast_USD__c = Decimal.valueof(String.valueOf(testMap.get('Target_12_USD')));
                    }
                    
                    sales12.Monthly_Forecast_Local_Curreny__c = String.valueOf(testMap.get('Target_12_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Target_12_Local')));
                    sales12.Volumn_USD__c = String.valueOf(testMap.get('Volumn_12_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_12_USD')));
                    sales12.Volumn_Local__c = String.valueOf(testMap.get('Volumn_12_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_12_Local')));
                    sales12.Price_USD__c = peiceUsd;
                    sales12.Price_Local__c = peiceLocal;
                    upsertSalesTar.add(sales1);
                    upsertSalesTar.add(sales2);
                    upsertSalesTar.add(sales3);
                    upsertSalesTar.add(sales4);
                    upsertSalesTar.add(sales5);
                    upsertSalesTar.add(sales6);
                    upsertSalesTar.add(sales7);
                    upsertSalesTar.add(sales8);
                    upsertSalesTar.add(sales9);
                    upsertSalesTar.add(sales10);
                    upsertSalesTar.add(sales11);
                    upsertSalesTar.add(sales12);
                }else{
                    Integer newMonth = Date.today().Month();
                    if (newMonth == 1 && (String.valueOf(testMap.get('Rolling_1_USD')) != null || String.valueOf(testMap.get('Rolling_1_Local')) != null)) {
                        sales1.Rolling_Monthly_Forecast_USD__c = String.valueOf(testMap.get('Rolling_1_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_1_USD')));
                        sales1.Rolling_Monthly_Forecast_Local_Currency__c = String.valueOf(testMap.get('Rolling_1_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_1_Local')));
                        sales1.Rolling_Volumn_USD__c = String.valueOf(testMap.get('Volumn_1_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_1_USD')));
                        sales1.Rolling_Volumn_Local__c = String.valueOf(testMap.get('Volumn_1_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_1_Local')));
                        sales1.Rolling_Price_USD__c = peiceUsd;
                        sales1.Rolling_Price_Local__c = peiceLocal;
                        upsertSalesTar.add(sales1);
                    }
                    if (newMonth <= 2 && (String.valueOf(testMap.get('Rolling_2_USD')) != null || String.valueOf(testMap.get('Rolling_2_Local')) != null)) {
                        sales2.Rolling_Monthly_Forecast_USD__c = String.valueOf(testMap.get('Rolling_2_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_2_USD')));
                        sales2.Rolling_Monthly_Forecast_Local_Currency__c = String.valueOf(testMap.get('Rolling_2_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_2_Local')));
                        sales2.Rolling_Volumn_USD__c = String.valueOf(testMap.get('Volumn_2_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_2_USD')));
                        sales2.Rolling_Volumn_Local__c = String.valueOf(testMap.get('Volumn_2_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_2_Local')));
                        sales2.Rolling_Price_USD__c = peiceUsd;
                        sales2.Rolling_Price_Local__c = peiceLocal;
                        upsertSalesTar.add(sales2);
                    }
                    if (newMonth <= 3 && (String.valueOf(testMap.get('Rolling_3_USD')) != null || String.valueOf(testMap.get('Rolling_3_Local')) != null)) {
                        sales3.Rolling_Monthly_Forecast_USD__c = String.valueOf(testMap.get('Rolling_3_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_3_USD')));
                        sales3.Rolling_Monthly_Forecast_Local_Currency__c = String.valueOf(testMap.get('Rolling_3_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_3_Local')));
                        sales3.Rolling_Volumn_USD__c = String.valueOf(testMap.get('Volumn_3_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_3_USD')));
                        sales3.Rolling_Volumn_Local__c = String.valueOf(testMap.get('Volumn_3_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_3_Local')));
                        sales3.Rolling_Price_USD__c = peiceUsd;
                        sales3.Rolling_Price_Local__c = peiceLocal;
                        upsertSalesTar.add(sales3);
                    }
                    if (newMonth <= 4 && (String.valueOf(testMap.get('Rolling_4_USD')) != null || String.valueOf(testMap.get('Rolling_4_Local')) != null)) {
                        sales4.Rolling_Monthly_Forecast_USD__c = String.valueOf(testMap.get('Rolling_4_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_4_USD')));
                        sales4.Rolling_Monthly_Forecast_Local_Currency__c = String.valueOf(testMap.get('Rolling_4_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_4_Local')));
                        sales4.Rolling_Volumn_USD__c = String.valueOf(testMap.get('Volumn_4_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_4_USD')));
                        sales4.Rolling_Volumn_Local__c = String.valueOf(testMap.get('Volumn_4_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_4_Local')));
                        sales4.Rolling_Price_USD__c = peiceUsd;
                        sales4.Rolling_Price_Local__c = peiceLocal;
                        upsertSalesTar.add(sales4);
                    }
                    if (newMonth <= 5 && (String.valueOf(testMap.get('Rolling_5_USD')) != null || String.valueOf(testMap.get('Rolling_5_Local')) != null)) {
                        sales5.Rolling_Monthly_Forecast_USD__c = String.valueOf(testMap.get('Rolling_5_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_5_USD')));
                        sales5.Rolling_Monthly_Forecast_Local_Currency__c = String.valueOf(testMap.get('Rolling_5_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_5_Local')));
                        sales5.Rolling_Volumn_USD__c = String.valueOf(testMap.get('Volumn_5_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_5_USD')));
                        sales5.Rolling_Volumn_Local__c = String.valueOf(testMap.get('Volumn_5_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_5_Local')));
                        sales5.Rolling_Price_USD__c = peiceUsd;
                        sales5.Rolling_Price_Local__c = peiceLocal;
                        upsertSalesTar.add(sales5);
                    }
                    if (newMonth <= 6 && (String.valueOf(testMap.get('Rolling_6_USD')) != null || String.valueOf(testMap.get('Rolling_6_Local')) != null)) {
                        sales6.Rolling_Monthly_Forecast_USD__c = String.valueOf(testMap.get('Rolling_6_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_6_USD')));
                        sales6.Rolling_Monthly_Forecast_Local_Currency__c = String.valueOf(testMap.get('Rolling_6_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_6_Local')));
                        sales6.Rolling_Volumn_USD__c = String.valueOf(testMap.get('Volumn_6_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_6_USD')));
                        sales6.Rolling_Volumn_Local__c = String.valueOf(testMap.get('Volumn_6_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_6_Local')));
                        sales6.Rolling_Price_USD__c = peiceUsd;
                        sales6.Rolling_Price_Local__c = peiceLocal;
                        upsertSalesTar.add(sales6);
                    }
                    if (newMonth <= 7 && (String.valueOf(testMap.get('Rolling_7_USD')) != null || String.valueOf(testMap.get('Rolling_7_Local')) != null)) {
                        sales7.Rolling_Monthly_Forecast_USD__c = String.valueOf(testMap.get('Rolling_7_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_7_USD')));
                        sales7.Rolling_Monthly_Forecast_Local_Currency__c = String.valueOf(testMap.get('Rolling_7_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_7_Local')));
                        sales7.Rolling_Volumn_USD__c = String.valueOf(testMap.get('Volumn_7_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_7_USD')));
                        sales7.Rolling_Volumn_Local__c = String.valueOf(testMap.get('Volumn_7_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_7_Local')));
                        sales7.Rolling_Price_USD__c = peiceUsd;
                        sales7.Rolling_Price_Local__c = peiceLocal;
                        upsertSalesTar.add(sales7);
                    }
                    if (newMonth <= 8 && (String.valueOf(testMap.get('Rolling_8_USD')) != null || String.valueOf(testMap.get('Rolling_8_Local')) != null)) {
                        sales8.Rolling_Monthly_Forecast_USD__c = String.valueOf(testMap.get('Rolling_8_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_8_USD')));
                        sales8.Rolling_Monthly_Forecast_Local_Currency__c = String.valueOf(testMap.get('Rolling_8_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_8_Local')));
                        sales8.Rolling_Volumn_USD__c = String.valueOf(testMap.get('Volumn_8_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_8_USD')));
                        sales8.Rolling_Volumn_Local__c = String.valueOf(testMap.get('Volumn_8_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_8_Local')));
                        sales8.Rolling_Price_USD__c = peiceUsd;
                        sales8.Rolling_Price_Local__c = peiceLocal;
                        upsertSalesTar.add(sales8);
                    }
                    if (newMonth <= 9 && (String.valueOf(testMap.get('Rolling_9_USD')) != null || String.valueOf(testMap.get('Rolling_9_Local')) != null)) {
                        sales9.Rolling_Monthly_Forecast_USD__c = String.valueOf(testMap.get('Rolling_9_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_9_USD')));
                        sales9.Rolling_Monthly_Forecast_Local_Currency__c = String.valueOf(testMap.get('Rolling_9_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_9_Local')));
                        sales9.Rolling_Volumn_USD__c = String.valueOf(testMap.get('Volumn_9_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_9_USD')));
                        sales9.Rolling_Volumn_Local__c = String.valueOf(testMap.get('Volumn_9_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_9_Local')));
                        sales9.Rolling_Price_USD__c = peiceUsd;
                        sales9.Rolling_Price_Local__c = peiceLocal;
                        upsertSalesTar.add(sales9);
                    }
                    if (newMonth <= 10 && (String.valueOf(testMap.get('Rolling_10_USD')) != null || String.valueOf(testMap.get('Rolling_10_Local')) != null)) {
                        sales10.Rolling_Monthly_Forecast_USD__c = String.valueOf(testMap.get('Rolling_10_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_10_USD')));
                        sales10.Rolling_Monthly_Forecast_Local_Currency__c = String.valueOf(testMap.get('Rolling_10_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_10_Local')));
                        sales10.Rolling_Volumn_USD__c = String.valueOf(testMap.get('Volumn_10_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_10_USD')));
                        sales10.Rolling_Volumn_Local__c = String.valueOf(testMap.get('Volumn_10_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_10_Local')));
                        sales10.Rolling_Price_USD__c = peiceUsd;
                        sales10.Rolling_Price_Local__c = peiceLocal;
                        upsertSalesTar.add(sales10);
                    }
                    if (newMonth <= 11 && (String.valueOf(testMap.get('Rolling_11_USD')) != null || String.valueOf(testMap.get('Rolling_11_Local')) != null)) {
                        sales11.Rolling_Monthly_Forecast_USD__c = String.valueOf(testMap.get('Rolling_11_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_11_USD')));
                        sales11.Rolling_Monthly_Forecast_Local_Currency__c = String.valueOf(testMap.get('Rolling_11_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_11_Local')));
                        sales11.Rolling_Volumn_USD__c = String.valueOf(testMap.get('Volumn_11_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_11_USD')));
                        sales11.Rolling_Volumn_Local__c = String.valueOf(testMap.get('Volumn_11_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_11_Local')));
                        sales11.Rolling_Price_USD__c = peiceUsd;
                        sales11.Rolling_Price_Local__c = peiceLocal;
                        upsertSalesTar.add(sales11);
                    }
                    if (newMonth <= 12 && (String.valueOf(testMap.get('Rolling_12_USD')) != null || String.valueOf(testMap.get('Rolling_12_Local')) != null)) {
                        sales12.Rolling_Monthly_Forecast_USD__c = String.valueOf(testMap.get('Rolling_12_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_12_USD')));
                        sales12.Rolling_Monthly_Forecast_Local_Currency__c = String.valueOf(testMap.get('Rolling_12_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Rolling_12_Local')));
                        sales12.Rolling_Volumn_USD__c = String.valueOf(testMap.get('Volumn_12_USD')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_12_USD')));
                        sales12.Rolling_Volumn_Local__c = String.valueOf(testMap.get('Volumn_12_Local')) == null ? 0 : Decimal.valueof(String.valueOf(testMap.get('Volumn_12_Local')));
                        sales12.Rolling_Price_USD__c = peiceUsd;
                        sales12.Rolling_Price_Local__c = peiceLocal;
                        upsertSalesTar.add(sales12);
                    }
                    
                }


            }catch(Exception e) {
                flag = ValiriFailed(valiriFailedSalesTargets, sales,System.Label.Sales_Forcast_Imp_System_Exception + e.getMessage() + '[' + e.getLineNumber() + ']' , inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
            }

            System.debug(rowNum);
            System.debug(testMap);
            System.debug(valiriFailedSalesTargets);
            rowNum = rowNum + 1;
        }

        //滚动预测是否存在于年度目标中
        if (sfStatus == 'Approved') {
            System.debug('upsertSalesTar:'+upsertSalesTar);
            Set<String> exIdSet = new Set<String>();
            for (Sales_Forcast__c sf : upsertSalesTar) {
                exIdSet.add(sf.External_Id__c);
            }

            Map<String,Sales_Forcast__c> sfMap = new Map<String,Sales_Forcast__c>();
            for (Sales_Forcast__c sf : [SELECT Id,External_Id__c FROM Sales_Forcast__c WHERE External_Id__c IN:exIdSet]) {
                sfMap.put(sf.External_Id__c,sf);
            }
            Integer indexNum  = 4;
            Set<String> sfSet = new Set<String>();
            for (Sales_Forcast__c sf : upsertSalesTar) {
                if (sfSet.contains(sf.Customer__c+''+sf.Product_Name__c+sf.OwnerId)) {
                    continue;
                }else{
                    
                    sfSet.add(sf.Customer__c+''+sf.Product_Name__c+sf.OwnerId);
                    if (sfMap.get(sf.External_Id__c) == null) {
                        ValiriFailed(valiriFailedSalesTargets, sf , System.label.Rolling_Not_Customer, inveRepo_inveRepoValiriFail,String.valueOf(indexNum));
                    }
                    indexNum = indexNum+1;
                }
            }
            
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
                System.debug('upsertSalesTar==>'+upsertSalesTar);
                //插入数据
                //upsert upsertSalesTar;
                Database.upsert(upsertSalesTar,Sales_Forcast__c.fields.External_Id__c);
                System.debug('upsertSalesTar.size()==>'+upsertSalesTar.size());
                insertResult.lResult = 'Success';
                insertResult.successValiAmount = upsertSalesTar.size();
                insertResult.failedValiAmount = 0;
                insertResult.successInsertAmount = upsertSalesTar.size();    
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
        //年度或滚动
        @AuraEnabled public String salesType{get; set;}
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
    //解析
    public Class JSonData{
        @AuraEnabled public String Ids;
    }

    public static void setOwnerData(Map<String,String> userMap,String onwerText,Sales_Forcast__c sales,String slaesOrg,String plan) {
        if (userMap.get(onwerText)!=null) {
            sales.OwnerId = userMap.get(onwerText);
        }else{
            if (slaesOrg == '5130') {
                sales.OwnerId = System.Label.User5130;
            }
            if (slaesOrg == '3010' && plan=='3011') {
                sales.OwnerId = System.Label.User3010;
            }
            if (slaesOrg == '3010' && plan=='3010') {
                sales.OwnerId = System.Label.User3010B;
            }
            if (slaesOrg == '5070' && plan=='5070') {
                sales.OwnerId = System.Label.User5070B;
            }
            if (slaesOrg == '3020') {
                sales.OwnerId = System.Label.User3020;
            }
        }
    }

    public static Boolean isNumber(String text) {
        try {
            Decimal.valueOf(text);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}