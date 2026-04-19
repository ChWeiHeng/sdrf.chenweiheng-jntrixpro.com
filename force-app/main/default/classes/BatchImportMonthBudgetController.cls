public without sharing class BatchImportMonthBudgetController {
    //初始化数据
    @AuraEnabled
    public static InitData getInitData(String id){
        InitData init = new InitData();
        
        /*Quote__c quote=[SELECT Id,Payment_Term_Cost_Rate__c,Sales_Org__c,Quotation_Type__c,Is_Retrograde__c FROM Quote__c WHERE Id =: id];
        //检验导入用户是否是同一sales org
        List<User> impoUserList = [SELECT Id,Sales_Org__c,Delivery_Plant__c FROM User WHERE Id=:System.UserInfo.getUserId()];
        init.userFlag = '0';
        if (quote.Sales_Org__c != impoUserList[0].Sales_Org__c ) {
            init.userFlag = '1';
        }*/
        //获取模板链接
        List<ContentDistribution> salesLink;
        //获取 数据导入字段配置 对象中配置的字段
        List<ImportDataFieldConf__c> fieldConfs;
        
        
        DataImportTemplate__c fileidSalesOrg ;
        fileidSalesOrg= DataImportTemplate__c.getValues('Monthly_Budget');
       
        String salesOrgValue = fileidSalesOrg.FileId__c;
        salesLink = [SELECT Id, ContentDownloadUrl, DistributionPublicUrl
                                                          FROM ContentDistribution 
                                                          WHERE ContentDocumentId =: salesOrgValue  LIMIT 1];
        fieldConfs = [SELECT Id, Obj_Name__c, Field_Label_Name__c,RecordType__c  ,
                                                    Field_Api_Name__c,Data_Type__c, If_Need__c 
                                                    FROM ImportDataFieldConf__c 
                                                    WHERE Obj_Name__c = 'Monthly_Budget' ];
                
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
            if (curConf.IF_Need__c ) {
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
    public static Integer ValiriFailed(List<ValiriFailedSalesTarget> valiriFailedSalesTargets, Monthly_Budget__c salesTar, String failedReason, Map<String, ValiriFailedSalesTarget> inveRepo_inveRepoValiriFail, String execlRowNum){
       
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
    public static InsertSalesTargetResult saveData( String TargetJson,Map<String,String> excelHeaderKeyToLabelMap, List<String> mustFillValueFields,String recordId) {
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
        Set<String> userNameSet  =  new Set<String>();    //用户名称
       
        if(testList.size()>0){
            for(Object testItem : testList){
                Map<String, Object> sales = (Map<String, Object>) testItem;
                if(String.valueOf(sales.get('Sales_Rep__c')) != null)
                {
                    userNameSet.add(String.valueOf(sales.get('Sales_Rep__c')));
                }
            }
        }
        Campaign_Budget__c cb=[SELECT Id,Budgeted_Amount__c,Name FROM Campaign_Budget__c WHERE Id=:recordId];
        Decimal yearBudget=cb.Budgeted_Amount__c;
        Decimal sumYearBudget=0;
        System.debug('yearBudget====》'+yearBudget);

        //校验用户是否存在
        List<User> userList = [SELECT Id, Name,Username FROM User WHERE Username IN:userNameSet];
        System.debug('userList====》'+userList);
        Map<String,User> userNameMap  =new Map<String,User>();
        if(userList.size()>0){
            for(User user : userList){
                userNameMap.put(user.Username,user);
            }
        }

        List<Monthly_Budget__c> insertsList = new List<Monthly_Budget__c>();  
        Integer rowNum = 3;
        Set<String> keySet = new Set<String>();
        Set<String>  vertifyDupilcateData= new Set<String>();
        for(Object testObj : testList) {
            Integer flag = 0;
            Map<String, Object> testMap = (Map<String, Object>)testObj;
            Monthly_Budget__c mb1List = new Monthly_Budget__c();
            // String testJson = JSON.serialize(testObj);
            try{
                System.debug('begin: '+ rowNum);
                for(String curField : mustFillValueFields){
                    if(!testMap.containsKey(curField) || String.isBlank(String.valueOf(testMap.get(curField))) ){
                        ValiriFailed(valiriFailedSalesTargets, 
                                mb1List, '\"' + 
                                    excelHeaderKeyToLabelMap.get(curField) + '\"' + System.label.Sales_Forcast_Imp_Required, 
                                    inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                    }
                }

                if(testMap.get('Sales_Rep__c')!=null && userNameMap.get(String.valueOf(testMap.get('Sales_Rep__c')))==null ){
                    system.debug('user not exist: ' + testMap.get('Sales_Rep__c') + ' ' + userNameMap.get(String.valueOf(testMap.get('Sales_Rep__c'))));
                    flag = ValiriFailed(valiriFailedSalesTargets, mb1List,'user not exist: ' + testMap.get('Sales_Rep__c') , inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                }


                if(testMap.get('Sales_Rep__c')!=null)
                {
                    if(vertifyDupilcateData.contains(String.valueOf(testMap.get('Sales_Rep__c'))))
                    {
                        flag = ValiriFailed(valiriFailedSalesTargets, mb1List, 'Exist Same  Sales Rep '+String.valueOf(testMap.get('Name')), inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                    }
                    else
                    {
                        vertifyDupilcateData.add(String.valueOf(testMap.get('Sales_Rep__c')));
                    }
                }
                String userId=userNameMap.get(String.valueOf(testMap.get('Sales_Rep__c'))).Id;
                mb1List.Campaign_Budget__c	=recordId;
                mb1List.Sales_Rep__c=userId;
                mb1List.Month__c='1';
                mb1List.Budgeted_Amount__c=Decimal.valueOf(String.valueOf(testMap.get('Month_1_Amount')));
                sumYearBudget=sumYearBudget+mb1List.Budgeted_Amount__c;
                mb1List.ExteralId__c=mb1List.Campaign_Budget__c+'_'+mb1List.Sales_Rep__c+'_'+mb1List.Month__c;
                mb1List.Is_Import__c=true;
                insertsList.add(mb1List);

                Monthly_Budget__c mb2List = new Monthly_Budget__c();
                mb2List.Campaign_Budget__c	=recordId;
                mb2List.Sales_Rep__c=userId;
                mb2List.Month__c='2';
                mb2List.Budgeted_Amount__c=Decimal.valueOf(String.valueOf(testMap.get('Month_2_Amount')));
                sumYearBudget=sumYearBudget+mb2List.Budgeted_Amount__c;
                mb2List.ExteralId__c=mb2List.Campaign_Budget__c+'_'+mb2List.Sales_Rep__c+'_'+mb2List.Month__c;
                mb2List.Is_Import__c=true;
                insertsList.add(mb2List);

                Monthly_Budget__c mb3List = new Monthly_Budget__c();
                mb3List.Campaign_Budget__c	=recordId;
                mb3List.Sales_Rep__c=userId;
                mb3List.Month__c='3';
                mb3List.Budgeted_Amount__c=Decimal.valueOf(String.valueOf(testMap.get('Month_3_Amount')));
                sumYearBudget=sumYearBudget+mb3List.Budgeted_Amount__c;
                mb3List.ExteralId__c=mb3List.Campaign_Budget__c+'_'+mb3List.Sales_Rep__c+'_'+mb3List.Month__c;
                mb3List.Is_Import__c=true;
                insertsList.add(mb3List);

                Monthly_Budget__c mb4List = new Monthly_Budget__c();
                mb4List.Campaign_Budget__c	=recordId;
                mb4List.Sales_Rep__c=userId;
                mb4List.Month__c='4';
                mb4List.Budgeted_Amount__c=Decimal.valueOf(String.valueOf(testMap.get('Month_4_Amount')));
                sumYearBudget=sumYearBudget+mb4List.Budgeted_Amount__c;
                mb4List.ExteralId__c=mb4List.Campaign_Budget__c+'_'+mb4List.Sales_Rep__c+'_'+mb4List.Month__c;
                mb4List.Is_Import__c=true;
                insertsList.add(mb4List);

                Monthly_Budget__c mb5List = new Monthly_Budget__c();
                mb5List.Campaign_Budget__c	=recordId;
                mb5List.Sales_Rep__c=userId;
                mb5List.Month__c='5';
                mb5List.Budgeted_Amount__c=Decimal.valueOf(String.valueOf(testMap.get('Month_5_Amount')));
                sumYearBudget=sumYearBudget+mb5List.Budgeted_Amount__c;
                mb5List.ExteralId__c=mb5List.Campaign_Budget__c+'_'+mb5List.Sales_Rep__c+'_'+mb5List.Month__c;
                mb5List.Is_Import__c=true;
                insertsList.add(mb5List);

                Monthly_Budget__c mb6List = new Monthly_Budget__c();
                mb6List.Campaign_Budget__c	=recordId;
                mb6List.Sales_Rep__c=userId;
                mb6List.Month__c='6';
                mb6List.Budgeted_Amount__c=Decimal.valueOf(String.valueOf(testMap.get('Month_6_Amount')));
                sumYearBudget=sumYearBudget+mb6List.Budgeted_Amount__c;
                mb6List.ExteralId__c=mb6List.Campaign_Budget__c+'_'+mb6List.Sales_Rep__c+'_'+mb6List.Month__c;
                mb6List.Is_Import__c=true;
                insertsList.add(mb6List);

                Monthly_Budget__c mb7List = new Monthly_Budget__c();
                mb7List.Campaign_Budget__c	=recordId;
                mb7List.Sales_Rep__c=userId;
                mb7List.Month__c='7';
                mb7List.Budgeted_Amount__c=Decimal.valueOf(String.valueOf(testMap.get('Month_7_Amount')));
                sumYearBudget=sumYearBudget+mb7List.Budgeted_Amount__c;
                mb7List.ExteralId__c=mb7List.Campaign_Budget__c+'_'+mb7List.Sales_Rep__c+'_'+mb7List.Month__c;
                mb7List.Is_Import__c=true;
                insertsList.add(mb7List);

                Monthly_Budget__c mb8List = new Monthly_Budget__c();
                mb8List.Campaign_Budget__c	=recordId;
                mb8List.Sales_Rep__c=userId;
                mb8List.Month__c='8';
                mb8List.Budgeted_Amount__c=Decimal.valueOf(String.valueOf(testMap.get('Month_8_Amount')));
                sumYearBudget=sumYearBudget+mb8List.Budgeted_Amount__c;
                mb8List.ExteralId__c=mb8List.Campaign_Budget__c+'_'+mb8List.Sales_Rep__c+'_'+mb8List.Month__c;
                mb8List.Is_Import__c=true;
                insertsList.add(mb8List);

                Monthly_Budget__c mb9List = new Monthly_Budget__c();
                mb9List.Campaign_Budget__c	=recordId;
                mb9List.Sales_Rep__c=userId;
                mb9List.Month__c='9';
                mb9List.Budgeted_Amount__c=Decimal.valueOf(String.valueOf(testMap.get('Month_9_Amount')));
                sumYearBudget=sumYearBudget+mb9List.Budgeted_Amount__c;
                mb9List.ExteralId__c=mb9List.Campaign_Budget__c+'_'+mb9List.Sales_Rep__c+'_'+mb9List.Month__c;
                mb9List.Is_Import__c=true;
                insertsList.add(mb9List);

                Monthly_Budget__c mb10List = new Monthly_Budget__c();
                mb10List.Campaign_Budget__c	=recordId;
                mb10List.Sales_Rep__c=userId;
                mb10List.Month__c='10';
                mb10List.Budgeted_Amount__c=Decimal.valueOf(String.valueOf(testMap.get('Month_10_Amount')));
                sumYearBudget=sumYearBudget+mb10List.Budgeted_Amount__c;
                mb10List.ExteralId__c=mb10List.Campaign_Budget__c+'_'+mb10List.Sales_Rep__c+'_'+mb10List.Month__c;
                mb10List.Is_Import__c=true;
                insertsList.add(mb10List);

                Monthly_Budget__c mb11List = new Monthly_Budget__c();
                mb11List.Campaign_Budget__c	=recordId;
                mb11List.Sales_Rep__c=userId;
                mb11List.Month__c='11';
                mb11List.Budgeted_Amount__c=Decimal.valueOf(String.valueOf(testMap.get('Month_11_Amount')));
                sumYearBudget=sumYearBudget+mb11List.Budgeted_Amount__c;
                mb11List.ExteralId__c=mb11List.Campaign_Budget__c+'_'+mb11List.Sales_Rep__c+'_'+mb11List.Month__c;
                mb11List.Is_Import__c=true;
                insertsList.add(mb11List);

                Monthly_Budget__c mb12List = new Monthly_Budget__c();
                mb12List.Campaign_Budget__c	=recordId;
                mb12List.Sales_Rep__c=userId;
                mb12List.Month__c='12';
                mb12List.Budgeted_Amount__c=Decimal.valueOf(String.valueOf(testMap.get('Month_12_Amount')));
                sumYearBudget=sumYearBudget+mb12List.Budgeted_Amount__c;
                mb12List.ExteralId__c=mb12List.Campaign_Budget__c+'_'+mb12List.Sales_Rep__c+'_'+mb12List.Month__c;
                mb12List.Is_Import__c=true;
                insertsList.add(mb12List);
                if(sumYearBudget>yearBudget){
                    flag = ValiriFailed(valiriFailedSalesTargets, mb1List,'Year Budget:'+yearBudget+ ' Month Total Budget  Greater Year Budget', inveRepo_inveRepoValiriFail, String.valueOf(rowNum));  
                }



            }catch(Exception e) {
                flag = ValiriFailed(valiriFailedSalesTargets, mb1List,System.Label.Sales_Forcast_Imp_System_Exception + e.getMessage().substring(e.getMessage().indexOf(', ')+1), inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
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
                System.debug('insertsList==>'+insertsList);
                //插入数据
                //insert insertsList;
                Database.upsert(insertsList,Monthly_Budget__c.fields.ExteralId__c);
                //Database.upsert(insertsList);
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
            //insertResult.errMsg = 'LineNumber:' + e.getLineNumber() + 'Message:' + e.getMessage();
            insertResult.errMsg =e.getMessage().substring(e.getMessage().indexOf(', ')+1);
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