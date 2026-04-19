public without sharing class BatchImportParticipantsListController {
    //初始化数据
    @AuraEnabled
    public static InitData getInitData(String id){
        InitData init = new InitData();
        
        Campaign cam=[SELECT Id,Sales_Org__c FROM Campaign WHERE Id =: id];
        //检验导入用户是否是同一sales org
        List<User> impoUserList = [SELECT Id,Sales_Org__c,Delivery_Plant__c FROM User WHERE Id=:System.UserInfo.getUserId()];
        init.userFlag = '0';
        if (cam.Sales_Org__c != impoUserList[0].Sales_Org__c ) {
            init.userFlag = '1';
        }
        //获取模板链接
        List<ContentDistribution> salesLink;
        //获取 数据导入字段配置 对象中配置的字段
        List<ImportDataFieldConf__c> fieldConfs;
        
        
        DataImportTemplate__c fileidSalesOrg ;
        if(cam.Sales_Org__c=='3010' || cam.Sales_Org__c=='3020'){
            fileidSalesOrg= DataImportTemplate__c.getValues('Participants_List_MX');
        }
        if(cam.Sales_Org__c=='5070' || cam.Sales_Org__c=='5130'){
            fileidSalesOrg= DataImportTemplate__c.getValues('Participants_List_AR');
        }
       
        String salesOrgValue = fileidSalesOrg.FileId__c;
        salesLink = [SELECT Id, ContentDownloadUrl, DistributionPublicUrl
                                                          FROM ContentDistribution 
                                                          WHERE ContentDocumentId =: salesOrgValue  LIMIT 1];
        fieldConfs = [SELECT Id, Obj_Name__c, Field_Label_Name__c,RecordType__c  ,
                                                    Field_Api_Name__c,Data_Type__c, If_Need__c 
                                                    FROM ImportDataFieldConf__c 
                                                    WHERE Obj_Name__c = 'Participants_List__c' ];
                
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
            if (curConf.IF_Need__c && (String.isBlank(curConf.RecordType__c) || (String.isNotBlank(curConf.RecordType__c) && recordTypeList.contains(cam.Sales_Org__c)))) {
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
    public static Integer ValiriFailed(List<ValiriFailedSalesTarget> valiriFailedSalesTargets, Participants_List__c salesTar, String failedReason, Map<String, ValiriFailedSalesTarget> inveRepo_inveRepoValiriFail, String execlRowNum){
       
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
    public static InsertSalesTargetResult saveData( String TargetJson,Map<String,String> excelHeaderKeyToLabelMap, List<String> mustFillValueFields,String camId) {
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
       
        if(testList.size()>0){
            for(Object testItem : testList){
                Map<String, Object> sales = (Map<String, Object>) testItem;
            }
        }

        Campaign campaign=[SELECT Id FROM Campaign WHERE Id =: camId];

       
        List<Participants_List__c> insertsList = new List<Participants_List__c>();  
        Integer rowNum = 4;
        Set<String> keySet = new Set<String>();
        Set<String>  vertifyDupilcateData= new Set<String>();
        for(Object testObj : testList) {
            Integer flag = 0;
            Map<String, Object> testMap = (Map<String, Object>)testObj;
            // String testJson = JSON.serialize(testObj);
            Participants_List__c parList = new Participants_List__c();
            parList.Campaign__c=camId;
            //camMember.ContactId='003D5000013N7KwIAK';
            try{
                System.debug('begin: '+ rowNum);
                for(String curField : mustFillValueFields){
                    if(!testMap.containsKey(curField) || String.isBlank(String.valueOf(testMap.get(curField))) ){
                        ValiriFailed(valiriFailedSalesTargets, 
                                parList, '\"' + 
                                    excelHeaderKeyToLabelMap.get(curField) + '\"' + System.label.Sales_Forcast_Imp_Required, 
                                    inveRepo_inveRepoValiriFail,String.valueOf(rowNum));
                    }
                }

                /*if(testMap.get('Name')!=null)
                {
                    if(vertifyDupilcateData.contains(String.valueOf(testMap.get('Name'))))
                    {
                        flag = ValiriFailed(valiriFailedSalesTargets, parList, 'Exist Same  Participant Name '+String.valueOf(testMap.get('Name')), inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
                    }
                    else
                    {
                        vertifyDupilcateData.add(String.valueOf(testMap.get('Name')));
                    }
                }*/
                parList.Name=String.valueOf(testMap.get('Name'));
                parList.Email__c=String.valueOf(testMap.get('Email__c')) ;
                parList.Phone__c=String.valueOf(testMap.get('Phone__c'));
                parList.Company_Name__c=String.valueOf(testMap.get('Company_Name__c'));
                parList.Company_Type__c=String.valueOf(testMap.get('Company_Type__c'));
                parList.Position__c=String.valueOf(testMap.get('Position__c'));
                parList.Crop__c=String.valueOf(testMap.get('Crop__c'));
                parList.Product_Line__c=String.valueOf(testMap.get('Product_Line__c'));
                parList.Preferred_Product_Name__c=String.valueOf(testMap.get('Preferred_Product_Name__c'));
                parList.Sales_rep__c=String.valueOf(testMap.get('Sales_rep__c'));
                parList.Hectares_of_Field__c=String.valueOf(testMap.get('Hectares_of_Field__c'));
                parList.Region__c=String.valueOf(testMap.get('Region__c'));
                parList.Social_Media__c=String.valueOf(testMap.get('Social_Media__c'));
                insertsList.add(parList);


            }catch(Exception e) {
                flag = ValiriFailed(valiriFailedSalesTargets, parList,System.Label.Sales_Forcast_Imp_System_Exception + e.getMessage() + '[' + e.getLineNumber() + ']' , inveRepo_inveRepoValiriFail, String.valueOf(rowNum));   
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
                insert insertsList;
                //Database.upsert(insertsList,Quote_Detail__c.fields.External_Id__c);
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