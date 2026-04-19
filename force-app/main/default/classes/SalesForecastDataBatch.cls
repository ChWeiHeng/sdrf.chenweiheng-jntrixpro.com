/*
* Name: SalesForecastDataBatch
* Date: 2024-05-23
* Creator: Bob
* Description: 更新销售预测达成
* History: 
*------------------------------------------------
* Version    Last Modified By     Desription
* v1         Bob              Create
*------------------------------------------------*/
global without sharing class SalesForecastDataBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    
    String month = '';
    String year = '';
    public String query;
    global Boolean flag;
    global String errorMsg;
    global Datetime startTime;
    global Boolean runV;
    
    //2024.06.29 Chervin新增：历史数据计算
    global SalesForecastDataBatch(String year, String month, Boolean runV) {
        this.flag = true;
        this.year = year;
        this.month = month;   
        this.runV = runV;
        //this.query = 'SELECT Id,Year__c,Month__c,Product_Name__c,Customer__c,External_Id__c,OwnerId FROM Sales_Forcast__c WHERE Month__c =:month AND Year__c =:year AND Sales_Forecast_Summary__r.Status__c=\'Approved\'';
    }

    global SalesForecastDataBatch() {
        this.runV = true;
        this.startTime = System.now();
        this.flag = true;
        Date day = System.today();
        if (day.Day() == 1) {
            if (day.Month() == 1) {
                Integer yeraInt = day.Year() - 1;
                this.year = yeraInt + '';
                this.month = '12';
            }else{
                Integer monthInt = day.Month() - 1;
                this.month = monthInt + '';
                this.year = day.Year() + '';
            }
        }else{
            this.month = day.Month() + '';
            this.year = day.Year() + '';
        }
        if (Test.isRunningTest()) {
            this.month = '1';
            this.year = '2024';
        }
        //this.query = 'SELECT Id,Year__c,Month__c,Product_Name__c,Customer__c,External_Id__c,OwnerId FROM Sales_Forcast__c WHERE Month__c =:month AND Year__c =:year AND Sales_Forecast_Summary__r.Status__c=\'Approved\'';
        System.debug('this.month==>'+this.month);
        System.debug('this.year==>'+this.year);
        System.debug('this.query==>'+this.query);
    }

    global void execute(SchedulableContext sc) {
        SalesForecastDataBatch svo = new SalesForecastDataBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 100);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        this.query = 'SELECT Id,Year__c,Month__c,Product_Name__c,Customer__c,External_Id__c,OwnerId FROM Sales_Forcast__c WHERE Month__c =:month AND Year__c =:year AND Sales_Forecast_Summary__r.Status__c=\'Approved\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sales_Forcast__c> salesForList) {
        try {
            System.debug('salesForList==>'+salesForList);
            Set<String> customerSet = new Set<String>();
            Set<String> proNameSet = new Set<String>();
            Set<String> ownerSet = new Set<String>();
            Set<String> salesForExtIdSet = new Set<String>();
            for (Sales_Forcast__c sf : salesForList) {
                customerSet.add(sf.Customer__c);
                proNameSet.add(sf.Product_Name__c);
                ownerSet.add(sf.OwnerId);
                salesForExtIdSet.add(sf.External_Id__c);
            }
            System.debug('salesForExtIdSet==>'+salesForExtIdSet);
            List<Billing__c> billList = [SELECT Id,Invoice_Date_Month__c,Invoice_Date_Year__c,
                                        Order_Item__r.Commodity__c,Order__r.Customer__c,Order__r.CreatedDate,
                                        SAP_Total_Net_Develop__c,SAP_Total_Net_UDS_Develop__c,
                                        Order__r.OwnerId,Currency__c ,Order__r.User_Plant__c 
                                        FROM Billing__c 
                                        WHERE Invoice_Date_Month__c =: this.month 
                                        AND Invoice_Date_Year__c =: this.year 
                                        AND Order_Item__r.Commodity__c IN: proNameSet 
                                        AND Order__r.Customer__c IN: customerSet 
                                        // AND Order__r.OwnerId IN: ownerSet
                                        AND Billing_Status__c = 'C' AND SAP_Total_Net_Develop__c!=null];
            System.debug('billList==>'+billList);
            Map<String,Decimal> total = new Map<String,Decimal>();
            Map<String,Decimal> totalUSD = new Map<String,Decimal>();
            //双算逻辑 start
            Set<String> accIdSet = new Set<String>();
            for(Billing__c bill : billList) {
                accIdSet.add(bill.Order__r.Customer__c);
            }

            Map<String,List<Account_Team__c>> accTeamMap = new Map<String,List<Account_Team__c>>();
            Map<String,Date> accTeamDateMap = new Map<String,Date>();
            for(Account_Team__c at : [SELECT Sales_Rep__r.Delivery_Plant__c,Id,Sales_Rep__c,Customer__c,Add_Operation_Date__c FROM Account_Team__c WHERE Customer__c IN:accIdSet AND Shared_Performance__c=true]) {
                if(accTeamMap.containsKey(at.Customer__c)) {
                    accTeamMap.get(at.Customer__c).add(at);
                }else{
                    accTeamMap.Put(at.Customer__c,new List<Account_Team__c>{at});   
                }
                accTeamDateMap.put(at.Customer__c+'_'+at.Sales_Rep__c,at.Add_Operation_Date__c);
            }
            //双算逻辑 end
            for(Billing__c bill : billList){
                String key = bill.Invoice_Date_Year__c + bill.Invoice_Date_Month__c 
                        + bill.Order_Item__r.Commodity__c + bill.Order__r.Customer__c
                        + bill.Order__r.OwnerId;
                System.debug('key==>'+key);
                // if (salesForExtIdSet.contains(key)) {
                System.debug('bill.SAP_Total_Net_Develop__c==>'+bill.SAP_Total_Net_Develop__c);
                System.debug('bill.SAP_Total_Net_UDS_Develop__c==>'+bill.SAP_Total_Net_UDS_Develop__c);
                setData(total,totalUSD,key,bill);
                if(accTeamMap.get(bill.Order__r.Customer__c)!=null) {
                    for(Account_Team__c at : accTeamMap.get(bill.Order__r.Customer__c)) {
                        if(at.Sales_Rep__c == bill.Order__r.OwnerId) {
                            continue;
                        }
                        if(accTeamDateMap.get(bill.Order__r.Customer__c+'_'+at.Sales_Rep__c)>bill.Order__r.CreatedDate) {
                            continue;
                        }
                        if(bill.Order__r.User_Plant__c!=at.Sales_Rep__r.Delivery_Plant__c){
                            continue;
                        }
                        key = bill.Invoice_Date_Year__c + bill.Invoice_Date_Month__c 
                            + bill.Order_Item__r.Commodity__c + bill.Order__r.Customer__c
                            + at.Sales_Rep__c;
                        setData(total,totalUSD,key,bill);
                    }
                }
                
            }
            System.debug('total=====>'+total);
            for (Sales_Forcast__c sf : salesForList) {
                System.debug('sf.External_Id__c==>'+sf.External_Id__c);
                if (total.containsKey(sf.External_Id__c) && totalUSD.containsKey(sf.External_Id__c)) {
                    sf.Monthly_Actual_USD__c = totalUSD.get(sf.External_Id__c);
                    sf.Monthly_Actual_Local_Currency__c = total.get(sf.External_Id__c);
                }
            }

            update salesForList;
            
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void setData(Map<String,Decimal> total,Map<String,Decimal> totalUSD,String key,Billing__c bill) {
        if(total.containsKey(key) && totalUSD.containsKey(key)){
            if (bill.Currency__c == 'USD') {
                total.put(key,total.get(key) + bill.SAP_Total_Net_UDS_Develop__c);
                totalUSD.put(key,totalUSD.get(key) + bill.SAP_Total_Net_Develop__c);
            }else{
                total.put(key,total.get(key) + bill.SAP_Total_Net_Develop__c);
                totalUSD.put(key,totalUSD.get(key) + bill.SAP_Total_Net_UDS_Develop__c);
            }
            
        }else{
            if (bill.Currency__c == 'USD') {
                total.put(key,bill.SAP_Total_Net_UDS_Develop__c);
                totalUSD.put(key,bill.SAP_Total_Net_Develop__c);
            }else{
                total.put(key,bill.SAP_Total_Net_Develop__c);
                totalUSD.put(key,bill.SAP_Total_Net_UDS_Develop__c);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('SalesForecastDataBatch', this.flag, this.startTime, this.errorMsg);
        if(this.runV) {
            DeleteSalesVirtualForecastDataBatch svo = new DeleteSalesVirtualForecastDataBatch();

            // 每次执行多少条数据，最大200
            String jobId = Database.executeBatch(svo, 100);
        }else{
            DeleteSalesVirtualForecastDataBatch svo = new DeleteSalesVirtualForecastDataBatch(this.year,this.month,true);

            // 每次执行多少条数据，最大200
            String jobId = Database.executeBatch(svo, 100);
        }
        
        
    }
}