public without sharing class InterfaceUtility {
    /*
    Name: send_SAP_POST_Service
    Author: Bob
    Create Date: 2024-05-09
    Function: 发送信息至SAP
    调用时外部需添加try catch捕捉错误
    Params:
        String bodyStrJson : 传参Json
        String endpoint : 终端地址(不加domain地址)如：'/RESTAdapter/BC_CRM/SD001'
    Return:
        HTTPResponse

    */
    public static HTTPResponse send_SAP_POST_Service(String bodyStrJson, String endpoint) {
        System.debug('1');
        String getEnviromentFlag = getEnviromentFlag();
        System.debug('2');
        String developerName =  endpoint + getEnviromentFlag;
        System.debug('3');
        Interface_Info__mdt iiItem = [
                                        SELECT
                                            Id,
                                            DeveloperName,
                                            Endpoint__c,
                                            Username__c,
                                            Password__c
                                        FROM
                                            Interface_Info__mdt
                                        WHERE
                                            DeveloperName =: developerName ];
        String hed = 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(iiItem.Username__c + ':' + iiItem.Password__c));
        System.debug('iiItem.Endpoint__c====>'+iiItem.Endpoint__c);
        System.debug('hed:' + hed);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setEndpoint(iiItem.Endpoint__c);
        req.setHeader('Content-Type','application/json');
        // req.setHeader('charset', 'utf-8');
        req.setHeader('Authorization',hed);
        req.setBody(bodyStrJson);
        
        HTTPResponse res = new HTTPResponse();
        res = http.send(req);
        String responseBody = res.getBody();

        // System.debug('url' + iiItem.Endpoint__c + endpoint);
        // System.debug('access_token:' + req.getHeader('access_token'));
        // System.debug('bodyStrJson:' + bodyStrJson);
        // System.debug('res.getBody():' + res.getBody());
        // System.debug(res.getStatusCode());
        return res;
    }

    /*
	Name: getEnviromentFlag
	Author: Gerry 
	Create Date: 2024-05-11
	Function: 获取环境类型
	Return:
		String : PRODUCTION / DEV
	*/ 
    public static String getEnviromentFlag() {
    	Organization currentOrganization = [SELECT Id,IsSandbox FROM Organization LIMIT 1];
    	String getEnviromentFlag = '';
    	if(currentOrganization != NULL &&!currentOrganization.IsSandbox) {
    		getEnviromentFlag = 'PRODUCTION';
    	}else {
    		getEnviromentFlag = 'DEV';
    	}
    	return getEnviromentFlag;
    }

    /**  
     * 处理接口日志
     * @param 
     * String className ： 类名
     * String requestSystem ： 发起请求系统
     * String destinationSystem ：目的系统
     * String url : 接口地址
     * String interactJSONContent ： 交互json内容
     * Boolean isSuccess ：是否成功
     * Boolean isPartSucessful ： 是否部分成功(批量)
     * String log ： 响应
     * String message : 异常报错信息
     * String callType ： 请求方式 POST/GET...
     * List<String> recordID ：记录Id
     * String dmlOption ：Insert/Update/Upsert...
     * String description : 描述
     * @return 
     * String : 日志记录Id
     * */
    public static String insertInterfaceLog(
        String className,
        String requestSystem,
        String destinationSystem,
        String url,
        String interactJSONContent,
        Boolean isSuccess,
        Boolean isPartSucessful,
        String log,
        String message,
        String callType,
        List<String> recordID,
        String dmlOption,
        String description){
        Interface_Log__c  InterfaceLog= new Interface_Log__c();
        InterfaceLog.Apex_Class_Name__c = className;
        InterfaceLog.Request_System__c = requestSystem;
        InterfaceLog.Destination_System__c = destinationSystem;
        InterfaceLog.Interface_URL__c = url;
        InterfaceLog.Interact_Time__c = Datetime.now();
        InterfaceLog.Is_Success__c = isSuccess;
        InterfaceLog.Is_Part_Sucessful__c = isPartSucessful;
        if (interactJSONContent!=null && interactJSONContent.length()>131072) {
            InterfaceLog.Interact_Content__c = interactJSONContent.substring(0,131072);
            if(interactJSONContent!=null&&interactJSONContent.length()>262144){
               InterfaceLog.Interact_Content1__c = interactJSONContent.substring(131072,262144);
            }else{
                InterfaceLog.Interact_Content1__c = interactJSONContent.substring(131072,interactJSONContent.length());
            }
          
        }else{
            InterfaceLog.Interact_Content__c = interactJSONContent;
        }
        if (String.isNotBlank(log) && log.length()>131072) {
            InterfaceLog.log1__c = log.substring(0, 131072);
         if (String.isNotBlank(log) && log.length()>262144){
            InterfaceLog.log2__c = log.substring(131072,262144);
         }else{
             InterfaceLog.log2__c = log.substring(131072,log.length());
         }
        }else{
            InterfaceLog.log1__c = log;
        }
        if (String.isNotBlank(message)) {
            if (message.length()>131072) {
                InterfaceLog.Exception_Message__c = message.substring(0, 131071);
            }else{
                InterfaceLog.Exception_Message__c = message;
            }
			
		}
        InterfaceLog.Call_Type__c = callType;

        if(recordID.size()>0){
            String recordIDList='';
            for(String iDStrl : recordID){
                recordIDList +=iDStrl;
                if(recordID.indexOf(iDStrl)<>(recordID.size()-1)){
                    recordIDList +=',';
                }
            }
             if (recordIDList!=null && recordIDList.length()<= 250) {
                InterfaceLog.recordID__c = recordIDList;
            }else if(recordIDList!=null && recordIDList.length()> 250){
                InterfaceLog.recordID__c = recordIDList.substring(0,250);
            }
        }
        InterfaceLog.Dml_Option__c = dmlOption;
        InterfaceLog.Description__c = description;
        Database.insert(InterfaceLog);
        return InterfaceLog.Id;
    }

    /**  
     * 处理异常信息
     * @param exceptionMsg 异常信息  
     * @return 格式化的异常信息  
     * */
    public static String getProperErrorMessage(String exceptionMsg) {
        //validation error message
        if(exceptionMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ) {
            exceptionMsg = exceptionMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ': [');
        }else if(exceptionMsg.contains('FIELD_INTEGRITY_EXCEPTION') ) {
            exceptionMsg = exceptionMsg.substringBetween('FIELD_INTEGRITY_EXCEPTION,', ': [');
        }else if(exceptionMsg.contains('FIELD_FILTER_VALIDATION_EXCEPTION') ) {
            exceptionMsg = exceptionMsg.substringBetween('FIELD_FILTER_VALIDATION_EXCEPTION,', ': [');
        }else if(exceptionMsg.contains('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST') ) {
            exceptionMsg = exceptionMsg.substringBetween('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST,', ': [');
        }else if(exceptionMsg.contains('NUMBER_OUTSIDE_VALID_RANGE') ) {
            exceptionMsg = exceptionMsg.substringBetween('NUMBER_OUTSIDE_VALID_RANGE,', ': [');
        }else if(exceptionMsg.contains('ENTITY_IS_LOCKED')){
            exceptionMsg = '当前记录已锁，不可执行此操作！';
        }else if(exceptionMsg.contains('DUPLICATES_DETECTED')) {
            exceptionMsg = exceptionMsg.substringBetween('DUPLICATES_DETECTED,', ': [');
        }
        return exceptionMsg;
    }
    
}