/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 08-27-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-27-2025   Gerry   Initial Version
**/

/**************************************************************************************************
 * Name: SubmitOrderController
 * Object: 
 * Purpose: 销售数据batch
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-20         Created             
***************************************************************************************************/
global without sharing class SetOrderItemFieldBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    public String query;
    global SetOrderItemFieldBatch() {
        
        this.query = 'SELECT Order__r.Interest_Rate__c,Price__c,Product_Combo_Name__c,Order__r.Currency__c,Id,Price_Book_Item__r.Estimation_Cost_Local__c,Price_Book_Item__r.Estimation_Cost_USD__c,Sales_Unit__r.Conversion_Coefficient__c,Unit_Estimate_Cost__c  FROM Order_Item__c';
        
    }

    global void execute(SchedulableContext sc) {
        SetOrderItemFieldBatch svo = new SetOrderItemFieldBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 100);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order_Item__c> oiList) {
        for(Order_item__c oi : oiList) {
            //测算成本赋值 -start
            if (oi.order__r.Currency__c == 'USD') {
                oi.Unit_Estimate_Cost__c = oi.Price_Book_Item__r.Estimation_Cost_USD__c;
            }else{
                oi.Unit_Estimate_Cost__c = oi.Price_Book_Item__r.Estimation_Cost_Local__c;
            }
            if(oi.Unit_Estimate_Cost__c!=null) {
                if(oi.Sales_Unit__r.Conversion_Coefficient__c!=null ) {
                    oi.Unit_Estimate_Cost__c = (oi.Unit_Estimate_Cost__c * oi.Sales_Unit__r.Conversion_Coefficient__c).setScale(2);
                }else if(oi.Unit_Estimate_Cost__c!=null){
                    oi.Unit_Estimate_Cost__c = oi.Unit_Estimate_Cost__c.setScale(2);
                }
            }
            
            //测算成本赋值 -end
            if(oi.Price__c!=null && oi.Order__r.Interest_Rate__c!=null && String.isBlank(oi.Product_Combo_Name__c)) {
                oi.Cash_Price__c = ((oi.Price__c)/oi.Order__r.Interest_Rate__c).setScale(2);
            }
            
        }
        update oiList;
    }

    global void finish(Database.BatchableContext BC) {
        // SalesOrderInvoiceBatch soib = new SalesOrderInvoiceBatch();
        // Database.executeBatch(soib,100);
        // Utility.setBatchInfo('SalesOrderDataBatch', this.flag, this.startTime, this.errorMsg);
    }
}