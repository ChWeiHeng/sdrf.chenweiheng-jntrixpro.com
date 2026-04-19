/**************************************************************************************************
 * Name: BatchOrderSyncToSap
 * Object:
 * Purpose: 批量调用SAP接口OrderSyncToSap，避免future方法超限
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          zach             2025-8-11          Created
***************************************************************************************************/
public without sharing class BatchGetCustomerLimit implements Database.Batchable<String>, Database.Stateful,Database.AllowsCallouts{
	public String orderIdStr;
    public List<BatchSubmitOrder.BatchData> submitDataList = new List<BatchSubmitOrder.BatchData>();
    public String errorMsg;
    public Datetime startTime;
    public Boolean flag = TRUE;
    
    public BatchGetCustomerLimit(String orderIdStr) {
        this.orderIdStr = orderIdStr;
    }
    
    public List<String> start(Database.BatchableContext bc) {
        try {
            startTime = System.now();
            List<String> orderIdList = (List<String>)JSON.deserialize(orderIdStr,List<String>.class);
            return orderIdList;
        } catch (Exception e) {
            return new List<String>();
        }
    }
    
    public void execute(Database.BatchableContext BC, List<String> orderList){
        try{
            String orderId = orderList[0];
            SubmitOrderController.Output output = SubmitOrderController.init(orderId);
            if(output.isCanSubmit){
                BatchSubmitOrder.BatchData data = new BatchSubmitOrder.BatchData();
                data.orderId = orderId;
                data.output = output;
                submitDataList.add(data);
            }
        }catch (Exception e) {
            flag = FALSE;
            errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }	
    }
    
    public void finish(Database.BatchableContext BC){
        Utility.setBatchInfo('BatchGetCustomerLimit', flag, startTime, errorMsg);
        Database.executeBatch(new BatchSubmitOrder(JSON.serialize(submitDataList)),1);
    }
}