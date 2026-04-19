/**************************************************************************************************
 * Name:Utility
 * Purpose:公共方法类
 * Author: Gerry
 * Create Date: 2024-05-07
***************************************************************************************************/
public class Utility {
	public static String modelCRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_C').getRecordTypeId();
    public static String ordUrl = URL.getOrgDomainURL().toExternalForm();
    public static Boolean isBypassValidationRule = FALSE;//是否跳过验证规则 add by zach 2025/8/19
    public static Boolean isBypassAutoValidationSplit = FALSE;//是否跳过自动开票先进先出逻辑 illion
    public static Boolean isPassTriggerLogic = FALSE;//跳过部分trigger逻辑

    
    public class PicklistItem{
        public String value;
        public String label;
    }
    /**
     方法名: getPicklistValueMap
     功能说明: 根据对象名，字段名获取picklist字段选项value=>label的Map映射
     参数说明: String objectName,String fieldName
     返回值: map<String,string >
     作者: Gerry
     日期: 2024-05-07
    */
    public static map<String,string > getPicklistValueMap(String objectName,String fieldName){ 
        Map<String,String> picklistMap = new Map<String,String>();
       
        Schema.SObjectType targetSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = targetSobjectType.getDescribe(); 
        
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistEntries = fieldMap.get(fieldName).getDescribe().getPickListValues(); 
        
        for(Schema.PicklistEntry a : picklistEntries){
            picklistMap.put(a.getValue(),a.getLabel());
        }
        return picklistMap;
    }
    /**
     方法名: getPicklistValueList
     功能说明: 根据对象名，字段名获取picklist字段选项list
     参数说明: String objectName,String fieldName
     返回值: List<PicklistItem>
     作者: Gerry
     日期: 2024-05-07
    */
    public static List<PicklistItem> getPicklistValueList(String objectName,String fieldName){ 
        List<PicklistItem> picklistValueList = new List<PicklistItem>();
       
        Schema.SObjectType targetSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = targetSobjectType.getDescribe(); 
        
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistEntries = fieldMap.get(fieldName).getDescribe().getPickListValues(); 
        
        for(Schema.PicklistEntry entry : picklistEntries){
            PicklistItem item = new PicklistItem();
            item.value = entry.getValue();
            item.label = entry.getLabel();
            picklistValueList.add(item);
        }
        return picklistValueList;
    }

    /**
     方法名: getPicklistValueMap
     功能说明: 根据对象名，字段名获取picklist字段选项value=>label的Map映射
     参数说明: String objectName,String fieldName
     返回值: map<String,string >
     作者: Gerry
     日期: 2024-05-07
    */
    public static map<String,string > getPicklistLabelMap(String objectName,String fieldName){ 
        Map<String,String> picklistMap = new Map<String,String>();
       
        Schema.SObjectType targetSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = targetSobjectType.getDescribe(); 
        
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistEntries = fieldMap.get(fieldName).getDescribe().getPickListValues(); 
        
        for(Schema.PicklistEntry a : picklistEntries){
            picklistMap.put(a.getLabel(),a.getValue());
        }
        return picklistMap;
    }

    
    /**
     方法名: getRecordTypeMapBySobj
     功能说明: 根据记录类型名称获取记录Id, 或者根据记录Id得到记录名称
     参数说明: 
     返回值: Map<String,String>
     作者: Gerry
     日期: 2024-05-07
    */
    public static Map<String, String> getRecordTypeMapBySobj(String sobj) {
        Map<String, String> sobjMap = new Map<String, String>();
        for(RecordType rt :[SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :sobj AND IsActive = TRUE]){
            sobjMap.put(rt.DeveloperName, rt.Id);
            sobjMap.put(rt.Id, rt.DeveloperName);   //id => developer name
        }
        return sobjMap;        
    }
    
    //这是一个trigger的控制开关
    public static Boolean isTriggerDisabled() {
        if (!Test.isRunningTest()) {
            GlobalSetting__c gs = GlobalSetting__c.getInstance();
            if (gs != null && gs.Ignore_Trigger__c) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

        /**
    * @description 忽略触发器,验证规则操作
    * @author Gerry | 06-29-2021 
    * @param isIgnoreTrigger 
    * @param isIgnoreValidation 
    * @param LastAddress 
    * @return GlobalSetting__c 
    * @use ignore : GlobalSetting__c ignoreGs = Utility.IgnoreAction(true,true,'ConfirmProductSolutionController');
    * @user return :   Utility.IgnoreAction(false,false,'',ignoreGs); 
    **/
    public static GlobalSetting__c IgnoreAction(
        Boolean isIgnoreTrigger, 
        Boolean isIgnoreValidation, 
        String LastAddress){

        List<GlobalSetting__c> gsList = [SELECT Id, 
                                                SetupOwnerId, 
                                                Ignore_Trigger__c,
                                                Ignore_Validation__c
                                            FROM GlobalSetting__c  
                                            WHERE SetupOwnerId = :UserInfo.getUserId()];
        GlobalSetting__c gs;
        if (gsList.size() > 0) {
            gs = gsList[0];
        } else {
            gs = new GlobalSetting__c();
        }
        gs.SetupOwnerId = UserInfo.getUserId();
        gs.Ignore_Trigger__c = isIgnoreTrigger;
        gs.Ignore_Validation__c = isIgnoreValidation;
        gs.Last_Address__c = LastAddress;
        UPSERT gs;
        return gs;
    }

    public static void setBatchInfo(
        String jobName,
        Boolean isSuccessful,
        Datetime startTime,
        String failReason
    ) {
        BatchJob__c bj = new BatchJob__c();
        bj.Name = jobName;
        bj.End_Time__c = System.now();
        bj.Is_Successful__c = isSuccessful;
        bj.Fail_Reason__c = failReason;
        bj.Start_Time__c = startTime;
        insert bj;
    }

    public static void notificationUser(String ownerId,String recordId) {
        CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
        Set<String> adminSet = new Set<String>();
        adminSet.add(ownerId);
        CustomNotificationFromApex.notifyUsers(
            notificationType, 
            adminSet, //发送通知给谁
            recordId, //通知点击后跳转到什么数据上
            System.Label.NotficationSyncErrorTitle, //标题
            System.Label.NotficationBody//内容
        );
    }

    public static void notificationUserTitle(Set<String> ownerIds,String recordId,String title,String body) {
        CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
        CustomNotificationFromApex.notifyUsers(
            notificationType, 
            ownerIds, //发送通知给谁
            recordId, //通知点击后跳转到什么数据上
            title, //标题
            body//内容
        );
    }

    /**
     * @author: Zach
     * @date:     2021-03-3
     * @function: 获取依赖选项列表的map，并返回到前台
     * @param     sObjectName [description]
     * @param     contrfieldName  [description]
     * @param     depfieldName  [description]
     * @return                [description]
     */
    //【获取依赖选项列表的map，并返回到前台 -start】
    public static Map<String, List<returnValue>> getDependentOptionsImpl(String objName, String contrfieldName, String depfieldName) {

        String objectName = objName.toLowerCase();
        String controllingField = contrfieldName.toLowerCase();
        String dependentField = depfieldName.toLowerCase();

        Map<String, List<returnValue>> objResults = new Map<String, List<returnValue>>();
        //get the string to sobject global map
        Map<String, Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!Schema.getGlobalDescribe().containsKey(objectName)) {
            System.debug('OBJNAME NOT FOUND --.> ' + objectName);
            return null;
        }

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType == null) {
            return objResults;
        }
        Bitset bitSetObj = new Bitset();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)) {
            System.debug('FIELD NOT FOUND --.> ' + controllingField + ' OR ' + dependentField);
            return objResults;
        }
        List<Schema.PicklistEntry> contrEntries = objFieldMap.get(controllingField).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> depEntries = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
        objFieldMap = null;
        List<Integer> controllingIndexes = new List<Integer>();
        for (Integer contrIndex = 0; contrIndex < contrEntries.size(); contrIndex++) {
            Schema.PicklistEntry ctrlentry = contrEntries[contrIndex];
            String label = ctrlentry.getValue();
            objResults.put(label, new List<returnValue>());
            controllingIndexes.add(contrIndex);
        }
        List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<PicklistEntryWrapper> objJsonEntries = new List<PicklistEntryWrapper>();
        for (Integer dependentIndex = 0; dependentIndex < depEntries.size(); dependentIndex++) {
            Schema.PicklistEntry depentry = depEntries[dependentIndex];
            objEntries.add(depentry);
        }
        objJsonEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objEntries), List<PicklistEntryWrapper>.class);
        List<Integer> indexes;
        for (PicklistEntryWrapper objJson : objJsonEntries) {
            if (objJson.validFor == null || objJson.validFor == '') {
                continue;
            }
            indexes = bitSetObj.testBits(objJson.validFor, controllingIndexes);
            for (Integer idx : indexes) {
                String contrLabel = contrEntries[idx].getValue();
                objResults.get(contrLabel).add(new returnValue(objJson.label,objJson.value));
            }
        }
        objEntries = null;
        objJsonEntries = null;
        return objResults;
    }

    public class PicklistEntryWrapper {

        public PicklistEntryWrapper() {
        }
        public String active {get; set;}
        public String defaultValue {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }

    public class BitSet {
        public Map<String, Integer> alphaNumCharCodes {get; set;}
        public Map<String, Integer> base64CharCodes {get; set;}

        public BitSet() {
            LoadCharCodes();
        }

        //Method loads the character codes for all letters
        private void LoadCharCodes() {
            alphaNumCharCodes = new Map<String, Integer> {
                'A' => 65, 'B' => 66, 'C' => 67, 'D' => 68, 'E' => 69, 'F' => 70, 'G' => 71, 'H' => 72, 'I' => 73, 'J' => 74,
                'K' => 75, 'L' => 76, 'M' => 77, 'N' => 78, 'O' => 79, 'P' => 80, 'Q' => 81, 'R' => 82, 'S' => 83, 'T' => 84,
                'U' => 85, 'V' => 86, 'W' => 87, 'X' => 88, 'Y' => 89, 'Z' => 90
            };
            base64CharCodes = new Map<String, Integer>();
            //all lower cases
            Set<String> pUpperCase = alphaNumCharCodes.keySet();
            for (String pKey : pUpperCase) {
                //the difference between upper case and lower case is 32
                alphaNumCharCodes.put(pKey.toLowerCase(), alphaNumCharCodes.get(pKey) + 32);
                //Base 64 alpha starts from 0 (The ascii charcodes started from 65)
                base64CharCodes.put(pKey, alphaNumCharCodes.get(pKey) - 65);
                base64CharCodes.put(pKey.toLowerCase(), alphaNumCharCodes.get(pKey) - (65) + 26);
                base64CharCodes.put('+', 62);
                base64CharCodes.put('/', 63);
            }
            //numerics
            for (Integer i = 0; i <= 9; i++) {
                alphaNumCharCodes.put(string.valueOf(i), i + 48);
                //base 64 numeric starts from 52
                base64CharCodes.put(string.valueOf(i), i + 52);
            }
        }

        public List<Integer> testBits(String pValidFor, List<Integer> nList) {
            List<Integer> results = new List<Integer>();
            List<Integer> pBytes = new List<Integer>();
            Integer bytesBeingUsed = (pValidFor.length() * 6) / 8;
            Integer pFullValue = 0;
            if (bytesBeingUsed <= 1)
                return results;
            for (Integer i = 0; i < pValidFor.length(); i++) {
                pBytes.Add((base64CharCodes.get((pValidFor.Substring(i, i + 1)))));
            }
            for (Integer i = 0; i < pBytes.size(); i++) {
                Integer pShiftAmount = (pBytes.size() - (i + 1)) * 6; //used to shift by a factor 6 bits to get the value
                pFullValue = pFullValue + (pBytes[i] << (pShiftAmount));
            }

            Integer bit;
            Integer targetOctet;
            Integer shiftBits;
            Integer tBitVal;
            Integer n;
            Integer nListSize = nList.size();
            for (Integer i = 0; i < nListSize; i++) {
                n = nList[i];
                bit = 7 - (Math.mod(n, 8));
                targetOctet = (bytesBeingUsed - 1) - (n >> bytesBeingUsed);
                shiftBits = (targetOctet * 8) + bit;
                tBitVal = ((Integer)(2 << (shiftBits - 1)) & pFullValue) >> shiftBits;
                if (tBitVal == 1)
                    results.add(n);
            }
            return results;
        }
    }
    
    public class returnValue {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public returnValue(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    //【获取依赖选项列表的map，并返回到前台 -end】
    
    //【get sobject all field label map -start】
    public static Map<String, String> getFieldLabelTranslateMap(String sobjectType) {
        Map<String, String> fieldLabelMap = new Map<String, String>();
        Map<String, Schema.SObjectField> objFieldMap = Schema.getGlobalDescribe().get(sobjectType).getDescribe().fields.getMap();

        for (String fieldName : objFieldMap.keySet()) {
            fieldLabelMap.put(fieldName, objFieldMap.get(fieldName).getDescribe().getLabel());
        }
        return fieldLabelMap;
    }
    //【get sobject all field label map -end】
    
    //【返回对象上的所有字段的soql -start】
    public static String getAllFieldSoql(String sobjectAPIName){
        String sqlStr = 'SELECT  ';
        sqlStr += getAllField(sobjectAPIName);
        sqlStr += ' FROM ' + sobjectAPIName;
        return sqlStr;
    }
    //【返回对象上的所有字段的soql -end】

    //【返回对象上的所有字段的soql -start】
    public static String getAllField(String sobjectAPIName){
        String sqlStr = '';
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sobjectAPIName).getDescribe().fields.getMap();
        for (Schema.SObjectField field : fieldMap.values()) {
            DescribeFieldResult selectedField = field.getDescribe();
            String fieldAPIName = selectedField.getName();
            sqlStr += fieldAPIName + ',';
        }
        sqlStr = sqlStr.removeEnd(',');
        return sqlStr;
    }
    //【返回对象上的所有字段的soql -end】
    
    /**
    * create Email
    * @Author   Zach
    * @DateTime 2023-6-14
    * @param
    * @return
    */
    //【创建邮件 -start】
    public static Messaging.SingleEmailMessage getSingleEmailMessage(String subject, String[] addresses, String htmlbody, Id orgWideEmailAddressId, List<String> ccAddressList) {
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        singleEmail.setSubject(subject);
        singleEmail.setToAddresses(addresses);
        singleEmail.setHtmlBody(htmlbody);
        if (orgWideEmailAddressId != NULL) {
            singleEmail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        }
        if(ccAddressList <> null && !ccAddressList.isEmpty()){
            singleEmail.setCcAddresses(ccAddressList);
        }
        return singleEmail;
    }
    //【创建邮件 -end】
    
    /**
     * [getEmailTableHTML 获取table HTML]
     * @Author   zach
     * @DateTime 
     * @param    table                    [description]
     * @param    thHeadList                [description]
     * @return                            [description]
     */
    public static String getEmailTableHTML(Table table,String[] thHeadList) {
        String tableHTML = '';
        tableHTML += '<table cellspacing="0" cellpadding="0" border="1" align="center"' + getCssHTML(table.cssMap) +'>';
        tableHTML += '<thead' + getCssHTML(table.thead.cssMap) + '>';
        tableHTML += getEmailTrHTML(thHeadList,table.thead.tr);
        tableHTML += '</thead>';
        tableHTML += '<tbody>';
        for(TableTr tableTr:table.tbody.trs) {
            tableHTML += getEmailTrHTML(thHeadList,tableTr);
        }
        tableHTML += '</tbody></table>';
        return tableHTML;
    }
    
    /**
     * [getEmailTrHTML 获取tr HTML]
     * @Author   zach
     * @DateTime 
     * @param    thHeadList                [description]
     * @param    tableTr                  [description]
     * @return                            [description]
     */
    public static String getEmailTrHTML(String[] thHeadList,TableTr tableTr) {
        String trHTML = '<tr' + getCssHTML(tableTr.cssMap) + '>';
        for(String thHead:thHeadList) {
            if(tableTr.tdMap.containsKey(thHead)) {
                trHTML += getEmailTdHTML(tableTr.tdMap.get(thHead));
            }
        }
        trHTML += '</tr>';
        return trHTML;
    }
    
    /**
     * [getEmailTdHTML 获取TD HTML]
     * @Author   zach
     * @DateTime 
     * @param    tableTd                  [description]
     * @return                            [description]
     */
    public static String getEmailTdHTML(TableTd tableTd) {
        if(tableTd == NULL) tableTd = new TableTd();
        String tdHTML = '<td' + getCssHTML(tableTd.cssMap) + ' rowspan="' + tableTd.rowspan + '" colspan="' + tableTd.colspan + '">';
        tdHTML += (tableTd.context == NULL ? '':tableTd.context) + '</td>';
        return tdHTML;
    }
    
    /**
     * [getCssHTML 获取需要渲染的css style]
     * @Author   zach
     * @DateTime 
     * @param    cssMap                   [description]
     * @return                            [description]
     */
    public static String getCssHTML(Map<String,String> cssMap) {
        String cssHTML = '';
        if(cssMap == NULL) {
            return cssHTML;
        }
        cssHTML += ' style="';
        for(String cssKey:cssMap.keySet()) {
            cssHTML += cssKey + ':' + cssMap.get(cssKey) + ';';
        }
        cssHTML += '"';
        return cssHTML;
    }
    
    public class Table {
        public TableThead thead;
        public TableTbody tbody;
        // tbody的css属性 会渲染到style中 key为css属性，value为css属性值
        public Map<String,String> cssMap;
        public Table() {
            this.thead = new TableThead();
            this.tbody = new TableTbody();
        }
    }
    
    public class TableThead {
        // thead的tr
        public TableTr tr;
        // thead的css属性 会渲染到style中 key为css属性，value为css属性值
        public Map<String,String> cssMap;
        public TableThead() {
            this.tr = new TableTr();
        }
    }

    public class TableTbody {
        // tbody 的 tr
        public TableTr[] trs; 
        // tbody的css属性 会渲染到style中 key为css属性，value为css属性值
        public Map<String,String> cssMap;
        public TableTbody() {
            this.trs = new TableTr[]{};
        }
    }
    
    public class TableTr {
        // tr所在行数
        public Integer row;
        // tr的td
        public Map<String,TableTd> tdMap;
        // tr的css属性 会渲染到style中 key为css属性，value为css属性值
        public Map<String,String> cssMap;
        public TableTr() {
            this.tdMap = new Map<String,TableTd>{};
        }
    }
    
    public class TableTd {
        // td所在列数
        public Integer col;
        // td的内容
        public String context;
        // td的css属性 会渲染到style中 key为css属性，value为css属性值
        public Map<String,String> cssMap = new Map<String,String>{'padding'=>'5px'};
        // td合并的行数
        public Integer rowspan = 1;
        // td合并列数
        public Integer colspan = 1;
        public TableTd(String context) {
            this.context = context;
        }
        public TableTd() { }
    }

    //【add by zach 2025/8/4 测算成本赋值通用方法-start】
    public static void getUnitEstimateCost(Set<Id> itemIdSet){
        Set<String> unitId = new Set<String>();
        Set<String> priceItemId = new Set<String>();
        List<Order_Item__c> itemList = [SELECT Order__r.Interest_Rate__c,Id,Sales_Unit__c,Price_Book_Item__c,Order__r.Currency__c,Unit_Estimate_Cost__c FROM Order_Item__c WHERE Id IN:itemIdSet];
        for(Order_Item__c item : itemList){
            unitId.add(item.Sales_Unit__c);
            priceItemId.add(item.Price_Book_Item__c);
        }

        Map<Id,Product_Unit__c> unitMap = new Map<Id,Product_Unit__c>([SELECT Product_Sales_Unit__c,Id,Conversion_Coefficient__c FROM Product_Unit__c WHERE Id IN:unitId]);

        Map<String,Decimal> usdCostMap = new Map<String,Decimal>();
        Map<String,Decimal> usdLocalMap = new Map<String,Decimal>();
        for (Price_Book_Item__c pn : [SELECT Estimation_Cost_Local__c,Estimation_Cost_USD__c,Id,Price__c,Min_Sales_Price__c FROM Price_Book_Item__c WHERE Id IN:priceItemId]) {
            if(pn.Estimation_Cost_USD__c <> null)usdCostMap.put(pn.Id,pn.Estimation_Cost_USD__c);
            if(pn.Estimation_Cost_Local__c <> null)usdLocalMap.put(pn.Id,pn.Estimation_Cost_Local__c);
        }

        //测算成本赋值
        for(Order_Item__c item : itemList){
            if (item.Order__r.Currency__c == 'USD') {
                if(usdCostMap.containsKey(item.Price_Book_Item__c))item.Unit_Estimate_Cost__c = usdCostMap.get(item.Price_Book_Item__c);
            }else{
                if(usdLocalMap.containsKey(item.Price_Book_Item__c))item.Unit_Estimate_Cost__c = usdLocalMap.get(item.Price_Book_Item__c);
            }
            if(item.Unit_Estimate_Cost__c!=null && unitMap.get(item.Sales_Unit__c) != null && unitMap.get(item.Sales_Unit__c).Conversion_Coefficient__c != null) {
                item.Unit_Estimate_Cost__c = (item.Unit_Estimate_Cost__c * unitMap.get(item.Sales_Unit__c).Conversion_Coefficient__c).setScale(2);
            }else if(item.Unit_Estimate_Cost__c!=null){
                item.Unit_Estimate_Cost__c = item.Unit_Estimate_Cost__c.setScale(2);
            }
            if(item.Unit_Estimate_Cost__c <> null && item.Order__r.Interest_Rate__c <> null)item.Unit_Estimate_Cost__c *= item.Order__r.Interest_Rate__c;
        }

        update itemList;
    }
    //【add by zach 2025/8/4 测算成本赋值通用方法-end】


    //【add by zach 2025/8/6 get custom error message -start】
    public static String getCustomMessage(String message,Boolean isFromFlow) {
        system.debug('message:'+message);
        if(String.isBlank(message)){
            return message;
        }
        if (message.indexOf('_EXCEPTION') != -1) {
            message = message.subString(message.indexOf('_EXCEPTION') + 11);
            if (message.indexOf(':') != -1) {
                message = message.subString(0, message.indexOf(':'));
            }
        } else if (message.indexOf('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST') != -1) {
            message = message.subString(message.indexOf('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST') + 40);
        } else if (message.indexOf('NO_APPLICABLE_PROCESS') != -1) {
            message = message.subString(message.indexOf('NO_APPLICABLE_PROCESS') + 22);
            if (message.indexOf(':') != -1) {
                message = message.subString(0, message.indexOf(':'));
            }
        } else if(message.indexOf('DUPLICATES_DETECTED') != -1){
            message = message.subString(message.indexOf('DUPLICATES_DETECTED') + 20);
        } else if(message.indexOf('DUPLICATE_VALUE') != -1){
            message = message.subString(message.indexOf('DUPLICATE_VALUE') + 16);
        }else if(message.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') != -1){
            message = message.subString(message.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') + 34);
        } else if(message.indexOf('NUMBER_OUTSIDE_VALID_RANGE') != -1){
            message = message.subString(message.indexOf('NUMBER_OUTSIDE_VALID_RANGE') + 27);
            if(message.indexOf(':') != -1){
                message = message.subString(0,message.lastIndexOf(':'));
            }
        } else if(message.indexOf('INSUFFICIENT_ACCESS_OR_READONLY') != -1){
            message = message.subString(message.indexOf('INSUFFICIENT_ACCESS_OR_READONLY') + 32);
        } else if (message.indexOf('错误信息') != -1) {
            message = message.subString(message.indexOf('错误信息：')+5,message.indexOf('：错误信息'));
        }else {
            message = Label.Error;
        }
        
        if(isFromFlow && message.indexOf('.')!= -1){
            message = message.subString(0,message.indexOf('.'));
        }
        return message;
    }
    //【add by zach 2025/8/6 get custom error message -end】

    //【add by zach 2025/8/6 create batch log -start】
    /*public static void insertBatchLog(String logId,String apexClassName,String description){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:logId];
		InterfaceUtility.insertInterfaceLog(apexClassName, 'CRM',
                    '', '', '', a.NumberOfErrors <=0 , a.NumberOfErrors != a.TotalJobItems,
                    '', 'The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.', '', new List<String>(),
                    '定时任务日志', description);
    }*/
    //【add by zach 2025/8/6 get custom error message -end】
}