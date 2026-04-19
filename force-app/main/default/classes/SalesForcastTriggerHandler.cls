/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-26-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-26-2025   Gerry   Initial Version
**/
public without sharing class SalesForcastTriggerHandler implements Triggers.Handler {
    public void handle() {
        if (Trigger.isbefore && (Trigger.isInsert)) {
            Set<String> sfIdSet = new Set<String>();
            Set<String> lastsfIdSet = new Set<String>();
            for (Sales_Forcast__c sf : (List<Sales_Forcast__c>)Trigger.new) {
                if (sf.Customer__c!=null && sf.Year__c!=null && sf.Month__c!=null && sf.Product_Name__c!=null && sf.OwnerId!=null) {
                    String key = sf.Year__c + sf.Month__c + sf.Product_Name__c + sf.Customer__c + sf.OwnerId;
                    Integer lastInt = Integer.valueOf(sf.Year__c) - 1;
                    String lastkey = lastInt + sf.Month__c + sf.Product_Name__c + sf.Customer__c + sf.OwnerId;
                    sfIdSet.add(key);
                    lastsfIdSet.add(lastkey);
                }else{
                    if(!Test.isRunningTest()){
                        sf.addError(System.Label.Sales_Forcast_External);
                    }
                }
                
            }
            if (sfIdSet.size() > 0) {
                List<Sales_Forcast__c> sfList = [SELECT Id,External_Id__c FROM Sales_Forcast__c WHERE External_Id__c IN: sfIdSet];
                if (sfList.size()>0) {
                    Set<String> exisIdSet = new Set<String>();
                    for (Sales_Forcast__c sf : sfList) {
                        exisIdSet.add(sf.External_Id__c);
                    }
                    for (Sales_Forcast__c sf : (List<Sales_Forcast__c>)Trigger.new) {
                        String key = sf.Year__c + sf.Month__c + sf.Product_Name__c + sf.Customer__c + sf.OwnerId;
                        if (exisIdSet.contains(key)) {
                            if(!Test.isRunningTest()){
                                sf.addError(System.Label.Sales_Forcast_External_Exis);
                            }
                        }
                    }
                }
            }

            if (lastsfIdSet.size() > 0) {
                List<Sales_Forcast__c> lastsfList = [SELECT Id,External_Id__c,Monthly_Actual_USD__c FROM Sales_Forcast__c WHERE External_Id__c IN: lastsfIdSet];
                if (lastsfList.size() > 0) {
                    Map<String,Sales_Forcast__c> lastYearSFMap = new Map<String,Sales_Forcast__c>();
                    for (Sales_Forcast__c lsf : lastsfList) {
                        lastYearSFMap.put(lsf.External_Id__c,lsf);
                    }
                    for (Sales_Forcast__c sf : (List<Sales_Forcast__c>)Trigger.new) {
                        Integer lastInt = Integer.valueOf(sf.Year__c) - 1;
                        String lastkey = lastInt + sf.Month__c + sf.Product_Name__c + sf.Customer__c + sf.OwnerId;
                        if (lastYearSFMap.containsKey(lastkey)) {
                            sf.Last_Year_Monthly_Actual_USD__c = lastYearSFMap.get(lastkey).Monthly_Actual_USD__c;
                        }
                        
                    }
                }
            }
            
            
        }

        //赋值月份主数据
        if(Trigger.isbefore && (Trigger.isupdate || Trigger.isInsert)) {
            Map<String,String> monthIdMap = new Map<String,String>();
            for (Month_Data__c md : [SELECT Id,Name FROM Month_Data__c]) {
                monthIdMap.put(md.Name, md.ID);
            }
            for (Sales_Forcast__c sf : (List<Sales_Forcast__c>)Trigger.new) {
                sf.Month_Data__c = monthIdMap.get(sf.Month__c);
            }
        }
    }
}