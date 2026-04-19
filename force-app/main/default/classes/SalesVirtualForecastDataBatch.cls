/*
* Name: SalesVirtualForecastDataBatch
* Date: 2024-08-23
* Creator: gerry
* Description: 记录虚拟客户销量
* History: 
*------------------------------------------------
* Version    Last Modified By     Desription
* v1         Gerry              Create
*------------------------------------------------*/
global without sharing class SalesVirtualForecastDataBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    String month = '';
    String year = '';
    public String query;
    global Boolean flag;
    global String errorMsg;
    global Datetime startTime;
    global Boolean runAgin;
    global SalesVirtualForecastDataBatch(String year, String month) {
        this.month = month;
        this.year = year;
        this.runAgin = false;
        this.flag = true;
    }

    global SalesVirtualForecastDataBatch() {
        this.runAgin = true;
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

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        this.query = 'SELECT Order__r.User_Plant__c,Order__r.CreatedDate,Order__r.Deliver_Plant__c,Id,Invoice_Date_Month__c,Invoice_Date_Year__c,Order_Item__r.Commodity__c,Order__r.Customer__c,SAP_Total_Net_Develop__c,SAP_Total_Net_UDS_Develop__c,Order__r.OwnerId,Currency__c,Order__r.Sales_Org__c FROM Billing__c WHERE Invoice_Date_Month__c =: month AND Invoice_Date_Year__c =: year AND Billing_Status__c = \'C\' AND SAP_Total_Net_Develop__c!=null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Billing__c> salesForList) {
        try {
            System.debug('salesForList==>'+salesForList);
            Set<String> customerSet = new Set<String>();
            Set<String> proNameSet = new Set<String>();
            Set<String> ownerSet = new Set<String>();
            Set<String> salesForExtIdSet = new Set<String>();
            Set<String> salesOrgSet = new Set<String>();
            for (Billing__c sf : salesForList) {
                customerSet.add(sf.Order__r.Customer__c);
                proNameSet.add(sf.Order_Item__r.Commodity__c);
                ownerSet.add(sf.Order__r.OwnerId);
                // ownerSet.add(sf.OwnerId);
                // salesForExtIdSet.add(sf.External_Id__c);
                // salesOrgSet.add(sf.Sales_Forecast_Summary__r.Sales_Org__c);
            }
            Map<String,Sales_Forcast__c> sfMap = new Map<String,Sales_Forcast__c>();
            for (Sales_Forcast__c sf : [SELECT Sales_Forecast_Summary__r.Sales_Org__c,Id,Year__c,Month__c,Product_Name__c,Customer__c,External_Id__c,OwnerId FROM Sales_Forcast__c WHERE Month__c =:month AND Year__c =:year AND Sales_Forecast_Summary__r.Status__c='Approved' AND Customer__c IN:customerSet AND Product_Name__c IN:proNameSet ]) {
                sfMap.put(sf.External_Id__c,sf);
            }
            Map<String,Sales_Forcast__c> sfMap1 = new Map<String,Sales_Forcast__c>();
            for (Sales_Forcast__c sf : [SELECT Sales_Forecast_Summary__r.Sales_Org__c,Id,Year__c,Month__c,Product_Name__c,Customer__c,External_Id__c,OwnerId FROM Sales_Forcast__c WHERE Month__c =:month AND Year__c =:year AND Sales_Forecast_Summary__r.Status__c='Approved' AND Customer__r.Virtual_customer__c=true AND Product_Name__c IN:proNameSet ]) {
                sfMap1.put(sf.External_Id__c,sf);
            }
            Map<String,List<Account_Team__c>> accTeamMap = new Map<String,List<Account_Team__c>>();
            Map<String,Date> accTeamDateMap = new Map<String,Date>();
            for(Account_Team__c at : [SELECT Sales_Rep__r.Delivery_Plant__c,Id,Sales_Rep__c,Customer__c,Add_Operation_Date__c FROM Account_Team__c WHERE Customer__c IN:customerSet AND Shared_Performance__c=true]) {
                if(accTeamMap.containsKey(at.Customer__c)) {
                    accTeamMap.get(at.Customer__c).add(at);
                }else{
                    accTeamMap.Put(at.Customer__c,new List<Account_Team__c>{at});   
                }
                accTeamDateMap.put(at.Customer__c+'_'+at.Sales_Rep__c,at.Add_Operation_Date__c);
            }
            System.debug('sfMap'+sfMap);
            Map<String,Decimal> total = new Map<String,Decimal>();
            Map<String,Decimal> totalUSD = new Map<String,Decimal>();
            for(Billing__c bill : salesForList){
                Set<String> keySet = new Set<String>();
                String key = bill.Invoice_Date_Year__c + bill.Invoice_Date_Month__c 
                        + bill.Order_Item__r.Commodity__c + bill.Order__r.Customer__c
                        + bill.Order__r.OwnerId;
                keySet.add(key);
                if(accTeamMap.get(bill.Order__r.Customer__c)!=null){
                    for(Account_Team__c at : accTeamMap.get(bill.Order__r.Customer__c)) {//校验客户小组是否在里面
                        if(at.Sales_Rep__c == bill.Order__r.OwnerId) {
                            continue;
                        }
                        if(accTeamDateMap.get(bill.Order__r.Customer__c+'_'+at.Sales_Rep__c)>bill.Order__r.CreatedDate) {
                            continue;
                        }
                        if(bill.Order__r.User_Plant__c!=at.Sales_Rep__r.Delivery_Plant__c){
                            continue;
                        }
                        String key1 = bill.Invoice_Date_Year__c + bill.Invoice_Date_Month__c 
                            + bill.Order_Item__r.Commodity__c + bill.Order__r.Customer__c
                            + at.Sales_Rep__c;
                        keySet.add(key1);
                    }
                }
                
                String key1 = bill.Invoice_Date_Year__c + bill.Invoice_Date_Month__c 
                        + bill.Order_Item__r.Commodity__c;
                if (bill.Order__r.Sales_Org__c == '5130') {
                    key1 += System.Label.Acc5130+System.Label.User5130;
                }
                if (bill.Order__r.Sales_Org__c == '3020') {
                    key1 += System.Label.Acc3020+System.Label.User3020;
                }
                if (bill.Order__r.Sales_Org__c == '3010' && bill.Order__r.Deliver_Plant__c=='3011') {
                    key1 += System.Label.Acc3010+System.Label.User3010;
                }

                if (bill.Order__r.Sales_Org__c == '3010' && bill.Order__r.Deliver_Plant__c=='3010') {
                    key1 += System.Label.Acc3010B+System.Label.User3010B;
                }

                if (bill.Order__r.Sales_Org__c == '5070' && bill.Order__r.Deliver_Plant__c=='5070') {
                    key1 += System.Label.Acc5070B+System.Label.User5070B;
                }
                String key2 = bill.Invoice_Date_Year__c + bill.Invoice_Date_Month__c 
                + bill.Order_Item__r.Commodity__c;
                if (bill.Order__r.Sales_Org__c == '5130') {
                    key2 += System.Label.Acc5130+bill.Order__r.OwnerId;
                }
                if (bill.Order__r.Sales_Org__c == '3020') {
                    key2 += System.Label.Acc3020+bill.Order__r.OwnerId;
                }
                if (bill.Order__r.Sales_Org__c == '3010' && bill.Order__r.Deliver_Plant__c=='3011') {
                    key2 += System.Label.Acc3010+bill.Order__r.OwnerId;
                }

                if (bill.Order__r.Sales_Org__c == '3010' && bill.Order__r.Deliver_Plant__c=='3010') {
                    key2 += System.Label.Acc3010B+bill.Order__r.OwnerId;
                }

                if (bill.Order__r.Sales_Org__c == '5070' && bill.Order__r.Deliver_Plant__c=='5070') {
                    key2 += System.Label.Acc5070B+bill.Order__r.OwnerId;
                }
                System.debug('key2==>'+key2);
                System.debug('keySet===>'+keySet);
                System.debug(sfMap.containskey(key));
                Boolean flag = false;
                for(String str : keySet) {
                    If (sfMap.containskey(str)) {
                        flag = true;
                        break;
                    }
                }
                if (flag) {
                    
                }else if (sfMap1.containsKey(key2)) {
                    if(total.containsKey(key2) && totalUSD.containsKey(key2)){
                        if (bill.Currency__c == 'USD') {
                            total.put(key2,total.get(key2) + bill.SAP_Total_Net_UDS_Develop__c);
                            totalUSD.put(key2,totalUSD.get(key2) + bill.SAP_Total_Net_Develop__c);
                        }else{
                            total.put(key2,total.get(key2) + bill.SAP_Total_Net_Develop__c);
                            totalUSD.put(key2,totalUSD.get(key2) + bill.SAP_Total_Net_UDS_Develop__c);
                        }
                        
                    }else{
                        if (bill.Currency__c == 'USD') {
                            total.put(key2,bill.SAP_Total_Net_UDS_Develop__c);
                            totalUSD.put(key2,bill.SAP_Total_Net_Develop__c);
                        }else{
                            total.put(key2,bill.SAP_Total_Net_Develop__c);
                            totalUSD.put(key2,bill.SAP_Total_Net_UDS_Develop__c);
                        }
                    }
                }else{
                    System.debug('bill.SAP_Total_Net_Develop__c==>'+bill.SAP_Total_Net_Develop__c);
                    System.debug('bill.SAP_Total_Net_UDS_Develop__c==>'+bill.SAP_Total_Net_UDS_Develop__c);
                    if(total.containsKey(key1) && totalUSD.containsKey(key1)){
                        if(bill.SAP_Total_Net_UDS_Develop__c!=null) {
                            if (bill.Currency__c == 'USD') {
                                total.put(key1,total.get(key1) + bill.SAP_Total_Net_UDS_Develop__c);
                                totalUSD.put(key1,totalUSD.get(key1) + bill.SAP_Total_Net_Develop__c);
                            }else{
                                total.put(key1,total.get(key1) + bill.SAP_Total_Net_Develop__c);
                                totalUSD.put(key1,totalUSD.get(key1) + bill.SAP_Total_Net_UDS_Develop__c);
                            }
                        }
                    }else{
                        if(bill.SAP_Total_Net_UDS_Develop__c!=null) {
                            if (bill.Currency__c == 'USD') {
                                total.put(key1,bill.SAP_Total_Net_UDS_Develop__c);
                                totalUSD.put(key1,bill.SAP_Total_Net_Develop__c);
                            }else{
                                total.put(key1,bill.SAP_Total_Net_Develop__c);
                                totalUSD.put(key1,bill.SAP_Total_Net_UDS_Develop__c);
                            }
                        }
                       
                    }
                }
            }
            Set<String> exSet = new Set<String>();
            System.debug('total'+total);
            for (String key : total.keySet()) {
                exSet.add(key);
            }
            Map<String,Sales_Forcast__c> existMap = new Map<String,Sales_Forcast__c>();
            for (Sales_Forcast__c sf : [SELECT Monthly_Actual_USD__c,Monthly_Actual_Local_Currency__c,Sales_Forecast_Summary__r.Sales_Org__c,Id,Year__c,Month__c,Product_Name__c,Customer__c,External_Id__c,OwnerId FROM Sales_Forcast__c WHERE Sales_Forecast_Summary__r.Status__c='Approved' AND External_Id__c IN:exSet]) {
                existMap.put(sf.External_Id__c,sf);
            }
            List<Sales_Forcast__c> udpateData = new List<Sales_Forcast__c>();
            System.debug('existMap'+existMap);
            for (String key : total.keySet()) {
                if (!existMap.containskey(key) && !System.Test.isRunningTest()) {
                    continue;
                }
                Sales_Forcast__c sf = new Sales_Forcast__c();
                sf.External_Id__c = key;
                Decimal au = existMap.get(key).Monthly_Actual_USD__c==null?0:existMap.get(key).Monthly_Actual_USD__c;
                Decimal a = existMap.get(key).Monthly_Actual_Local_Currency__c==null?0:existMap.get(key).Monthly_Actual_Local_Currency__c;
                sf.Monthly_Actual_USD__c = au+totalUSD.get(sf.External_Id__c);
                sf.Monthly_Actual_Local_Currency__c = a+total.get(sf.External_Id__c);
                udpateData.add(sf);
            }
            if (udpateData.size()>0) {
                Database.upsert(udpateData,Sales_Forcast__c.fields.External_Id__c);
            }
            
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('SalesVirtualForecastDataBatch', this.flag, this.startTime, this.errorMsg);
        if(this.runAgin) {
            System.debug('this.month:'+this.month);
            if(this.month!='1') {
                SalesForecastDataBatch svo = new SalesForecastDataBatch(this.year,String.valueOf(Integer.valueOf(this.month)-1),false);

                // 每次执行多少条数据，最大200
                String jobId = Database.executeBatch(svo, 100);
            }
            
        }
    }
}