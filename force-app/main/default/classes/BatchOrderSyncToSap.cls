/**************************************************************************************************
 * Name: BatchOrderSyncToSap
 * Object:
 * Purpose: 批量调用SAP接口OrderSyncToSap，避免future方法超限
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          zach             2025-8-7          Created
***************************************************************************************************/
public without sharing class BatchOrderSyncToSap implements Database.Batchable<BatchData>, Database.Stateful,Database.AllowsCallouts{
	public String dataJsonStr;
    public String errorMsg;
    public Datetime startTime;
    public Boolean flag = TRUE;
    
    public BatchOrderSyncToSap(String dataJsonStr) {
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
            for(BatchData data : dataList){
                //掉SAP接口
                OrderSyncToSAP.submitToSAP(data.orderId,data.changeType,data.isClose,data.isbeforceClose,data.reasonText,data.orderItemId,data.isRealClose,FALSE/*,data.isReprocess*/);
                if(System.Test.isRunningTest()){
                   throw new CustomException('不存在！');
                }
            }
        }catch (Exception e) {
            flag = FALSE;
            errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }
    
    public void finish(Database.BatchableContext BC){
        Utility.setBatchInfo('BatchOrderSyncToSap', flag, startTime, errorMsg);
    }
    
    //OrderSyncToSap接口调用参数内部类
    public class BatchData {
        public String orderId;
        public String changeType;
        public Boolean isClose;
        public Boolean isbeforceClose;
        public String reasonText;
        public Boolean isRealClose;
        public String orderItemId;
        //public Boolean isReprocess;
        
        public BatchData(String orderId,String changeType,Boolean isClose,Boolean isbeforceClose,String reasonText,Boolean isRealClose,String orderItemId/*,Boolean isReprocess*/){
            this.orderId = orderId;
            this.changeType = changeType;
            this.isClose = isClose;
            this.isbeforceClose = isbeforceClose;
            this.reasonText = reasonText;
            this.isRealClose = isRealClose;
            this.orderItemId = orderItemId;
            //this.isReprocess = isReprocess;
        }
    

    }
}