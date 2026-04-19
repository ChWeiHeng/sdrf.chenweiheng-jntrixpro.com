/*******************************************************************************
 *  Summary         : ManualGenerateZARA(Flow)
 *  Refer Object    :
 *  Author          : illion
 *  CreatedDate     : 2025-08-14
 *  Change Log      :
 ------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------
 * illion                      2025-08-14                Create
 ***********************************************************************/
global without sharing class ManualGenerateZARAController {
	@InvocableMethod(label = 'ManualGenerateZARA')
	public static List<Result> generateZARA(List<Param> recordIdList) {
		Datetime startTime = System.now();
		Result result = new Result();
		try{
			system.debug('recordIdList===='+recordIdList);
			String recordId = recordIdList.get(0).recordId; 
			List<Delivery_Note__c> itemList = [SELECT Id,Order_Item__c,Auto_ZARA_Issue_Quantity__c,Delivery_Quantity__c,Remain_Quantity__c,Order__c,Order__r.Customer__r.Email__c,Order__r.Customer__r.Name,
								Order__r.Stock_Aging_Limit__c,Delivery_Post_Date__c,Stock_Aging_Countdown__c,Order_Item__r.Commodity__c,
								Order_Item__r.Commodity__r.Name,Auto_issue_Consignment__c FROM Delivery_Note__c 
							 	WHERE Order__c = :recordId];

			BatchSendEmailToOrder.generateZaraData(itemList,true);
			result.flag = false;
			List<Result> returnList = new List<Result>{result};
			return returnList;
		}catch (Exception e){
			system.debug('errorMsg===='+e.getMessage() + ' ' + e.getStackTraceString());
			Utility.setBatchInfo('BatchSendEmailToOrder', false, startTime, e.getMessage() + ' ' + e.getStackTraceString());
			result.flag = true;
			result.message = e.getMessage();
			List<Result> returnList = new List<Result>{result};
			return returnList;
		}
		
	}

	//参数
    public class Param{
        @InvocableVariable(required=true)
        public String recordId;//记录Id   
    }

    //返回结果
    public class Result{
        @InvocableVariable
        public Boolean flag; //true有报错
        @InvocableVariable
        public String message; //错误信息
    }
}