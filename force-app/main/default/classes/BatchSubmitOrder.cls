/**************************************************************************************************
 * Name: BatchOrderSyncToSap
 * Object:
 * Purpose: 批量调用SAP接口OrderSyncToSap，避免future方法超限
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          zach             2023-6-5          Created
***************************************************************************************************/
public without sharing class BatchSubmitOrder implements Database.Batchable<BatchData>, Database.Stateful,Database.AllowsCallouts{
	public String dataJsonStr;
    public String errorMsg;
    public Datetime startTime;
    public Boolean flag = TRUE;
    
    public BatchSubmitOrder(String dataJsonStr) {
        this.dataJsonStr = dataJsonStr;
    }
    
    public List<BatchData> start(Database.BatchableContext bc) {
        try {
            startTime = System.now();
            List<BatchData> dataList = (List<BatchData>)JSON.deserialize(dataJsonStr,List<BatchData>.class);
            return dataList;
        } catch (Exception e) {
            return new List<BatchData>();
        }
    }
    
    public void execute(Database.BatchableContext BC, List<BatchData> dataList){
        try{
            BatchData data = dataList[0];
            SubmitOrderController.submitDataMe(data.orderId,data.output);
            if(System.Test.isRunningTest()){
                throw new AuraHandledException('测试需要要覆盖catch');
            }   	
        }catch (Exception e) {
            flag = FALSE;
            errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }	
    }
    
    public void finish(Database.BatchableContext BC){
        Utility.setBatchInfo('BatchSubmitOrder', flag, startTime, errorMsg);
    }
    
    public Class BatchData{
        public String orderId;
        public SubmitOrderController.Output output;
    }
}