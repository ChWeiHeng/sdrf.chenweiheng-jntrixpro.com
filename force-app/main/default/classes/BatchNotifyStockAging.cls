/**************************************************************************************************
 * Name: BatchSendEmailToOrder
 * Object: Delivery_Note__c
 * Purpose: ZARB订单需要在每月20号凌晨自动向客户的owner发送邮件通知，通知用户目前的库存为多少
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          zach            2025-07-08        Created			    
***************************************************************************************************/
global without sharing class BatchNotifyStockAging implements Database.Batchable<sObject>,Schedulable,Database.Stateful {
    public Set<String> zarbIdSet = new Set<String>();
    public String errorMsg;
    public Datetime startTime;
    public Boolean flag = TRUE;
    
    global BatchNotifyStockAging(){
        
    }
    
    global BatchNotifyStockAging(Set<String> zarbIdSet){
        this.zarbIdSet = zarbIdSet;
    }
    
	global Database.QueryLocator start(Database.BatchableContext bc){
        startTime = System.now();
        Decimal daysNotify5130 = Decimal.valueOf(System.Label.daysNotify5130);
        String sql;
        if(!System.Test.isRunningTest()){
             sql = 'SELECT Id,Order_Item__c,Remain_Quantity__c,Order__c,Order__r.Customer__r.Email__c,Order__r.Customer__r.Name,Order__r.Stock_Aging_Limit__c,Delivery_Post_Date__c,Stock_Aging_Countdown__c,Order__r.Sales_Org__c,Order__r.Customer__r.Owner.Email,' + 
            		'Order_Item__r.Commodity__c,Order_Item__r.Commodity__r.Name,Auto_issue_Consignment__c FROM Delivery_Note__c WHERE Order__r.Order_type__c = \'ZARB\' AND Order__r.Sales_Org__c = \'5130\' ' + 
            		'AND Order__r.RecordType.DeveloperName = \'Model_C\' AND Order__r.Customer__r.Email__c !=NULL AND Days_after_delivery__c >= :daysNotify5130';
        }else{
             sql = 'SELECT Id,Order_Item__c,Remain_Quantity__c,Order__c,Order__r.Customer__r.Email__c,Order__r.Customer__r.Name,Order__r.Stock_Aging_Limit__c,Delivery_Post_Date__c,Stock_Aging_Countdown__c,Order__r.Sales_Org__c,Order__r.Customer__r.Owner.Email,' + 
            		'Order_Item__r.Commodity__c,Order_Item__r.Commodity__r.Name,Auto_issue_Consignment__c FROM Delivery_Note__c WHERE Order__r.Order_type__c = \'ZARB\' AND Order__r.Sales_Org__c = \'5130\' ' + 
            		'AND Order__r.RecordType.DeveloperName = \'Model_C\' AND Order__r.Customer__r.Email__c !=NULL';
        }
        
        system.debug(zarbIdSet);
        if(zarbIdSet != NULL && !zarbIdSet.isEmpty()){
            sql += ' AND Order__c IN:zarbIdSet';
        }
        return Database.getQueryLocator(sql);  
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new BatchNotifyStockAging());
    }
    
    global void execute(Database.BatchableContext BC,List<Delivery_Note__c> itemList){
        system.debug('itemList===='+itemList);
        try{
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Map<Id,Delivery_Note__c> noteMap = new Map<Id,Delivery_Note__c>(itemList);
            
            //product name
            Set<String> proIdSet = new Set<String>();
            for(Delivery_Note__c item : itemList){
                if(item.Remain_Quantity__c > 0){
                    proIdSet.add(item.Order_Item__r.Commodity__c);
                }
            }
            
            //获取产品名称
            Map<String,List<String>> proNameMap = BatchSendEmailToOrder.getProductName(proIdSet);
            system.debug('proNameMap===='+proNameMap);
            
            for(Delivery_Note__c item : itemList){
                if(item.Remain_Quantity__c > 0){
                    //新建自定义邮件
                    emails.add(BatchSendEmailToOrder.getOrderEmail(item,proNameMap));
                }
                
            }
            //发送邮件
            system.debug(emails);
            Messaging.sendEmail(emails);
        }catch (Exception e) {
            flag = FALSE;
            errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }
    
    global void finish(Database.BatchableContext bc) {
		Utility.setBatchInfo('BatchNotifyStockAging', flag, startTime, errorMsg);
    }
}