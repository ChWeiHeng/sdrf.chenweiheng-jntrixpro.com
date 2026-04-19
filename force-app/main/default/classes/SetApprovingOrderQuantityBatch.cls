/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 11-19-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   11-19-2025   Gerry   Initial Version
**/
public without sharing class SetApprovingOrderQuantityBatch implements Database.Batchable<sObject>, Database.Stateful{
    public String errorMsg;
    public Datetime startTime;
    public Boolean flag = TRUE;
    public String query;
    
    public SetApprovingOrderQuantityBatch() {
        this.query = 'SELECT Id,Plant__c,Product_Name_Text__c,Product__r.Name FROM Product_Inventory__c WHERE Customer__c=null';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Product_Inventory__c> piList){
        try{
            Set<String> productSet = new Set<String>();
            Set<String> productNameSet = new Set<String>();
            Set<String> plantSet = new Set<String>();
            for (Product_Inventory__c pi : piList) {
                productSet.add(pi.Product__r.Name);
                productNameSet.add(pi.Product_Name_Text__c);
                plantSet.add(pi.Plant__c);
            }

            List<Order_Item__c> approvingList = [SELECT Material_Number__c,Id,Commodity__c,Quantity__c,Commodity__r.Product__r.Name,Order__r.Deliver_Plant__c,Commodity__r.Name,Default_Unit_Quantity__c 
                                             FROM Order_Item__c WHERE Order__r.Deliver_Plant__c IN:plantSet AND Material_Number__c IN:productSet AND Order__r.Status__c = 'Approving' AND Commodity__r.Name IN:productNameSet];
        
            //审批中产品的数量
            Map<String,Decimal> proQuantityMap = new Map<String,Decimal>();
            for(Order_Item__c item : approvingList){
                String uk = item.Material_Number__c + '-' + item.Order__r.Deliver_Plant__c + '-' + item.Commodity__r.Name;
                if(!proQuantityMap.containsKey(uk)){
                    proQuantityMap.put(uk,0);
                }
                Decimal quantity = proQuantityMap.get(uk);
                quantity += item.Default_Unit_Quantity__c ?? 0;
                proQuantityMap.put(uk,quantity);   
            }

            for (Product_Inventory__c pi : piList) {
                pi.Approving_Order_Quantity__c = proQuantityMap.get(pi.Product__r.Name + '-' + pi.Plant__c + '-' + pi.Product_Name_Text__c) ?? 0;
            }


            update piList;
        }catch (Exception e) {
            flag = FALSE;
            errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }
    
    public void finish(Database.BatchableContext BC){
        Utility.setBatchInfo('SetApprovingOrderQuantityBatch', flag, startTime, errorMsg);
        
    }
}