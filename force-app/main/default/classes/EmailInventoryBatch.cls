/**
 * @description       : 发送寄售库存至客户邮箱:展示客户+产品+产品名+ 寄售数量+预计开票日
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 09-12-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   09-12-2025   Gerry   Initial Version
**/
global without sharing class EmailInventoryBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    public String query;
    
    global Boolean flag;
    global String errorMsg;
    global Datetime startTime;
    global EmailInventoryBatch() {
        this.startTime = System.now();
        this.flag = true;
        this.query = 'SELECT Id,Customer__r.Email__c FROM Customer_Sales_Info__c WHERE Sales_Org__c=\'5130\' AND Sales_View_Status__c=\'Approved\'';
    }

    global void execute(SchedulableContext sc) {
        EmailInventoryBatch svo = new EmailInventoryBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 5);
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Customer_Sales_Info__c> csiList) {
        try {
            //销售视图Id
            Set<String> csiIdList = new Set<String>();

            for (Customer_Sales_Info__c csi : csiList) {
                csiIdList.add(csi.Id);
            }

            //客户+产品+产品名+预计开票日------>寄售数量
            Map<String,Decimal> remainMap = new Map<String,Decimal>();

            //客户ID
            Set<String> accIdList = new Set<String>();
            for (AggregateResult agg1 : [
                                        SELECT 
                                            SUM(Remain_Quantity__c) remain,
                                            Order__r.Customer__c acc,
                                            Order_Item__r.Commodity__r.Name productName,
                                            Order_Item__r.Commodity__r.Product_Sales_Info__r.Product__r.Name productCode,
                                            Estimated_invoicing_date__c eidate
                                        FROM 
                                            Delivery_Note__c
                                        WHERE 
                                            Order__r.Customer_Sales_Info__c IN:csiIdList AND 
                                            Delivery_Post_Status__c ='C' AND 
                                            Order__r.Order_type__c = 'ZARB' AND  
                                            Order__r.Sales_Org__c = '5130' AND 
                                            // Auto_Issue_Consignment__c=false AND
                                            Remain_Quantity__c >0 AND
                                            Estimated_invoicing_date__c !=null
                                            Group by Order__r.Customer__c,Order_Item__r.Commodity__r.Name,Order_Item__r.Commodity__r.Product_Sales_Info__r.Product__r.Name,Estimated_invoicing_date__c
                                            order by Estimated_invoicing_date__c

            ]) {
                remainMap.put((String)agg1.get('acc')+'_'+(String)agg1.get('productCode')+'_'+(String)agg1.get('productName')+'_'+String.valueOf(agg1.get('eidate')), (Decimal)agg1.get('remain'));
                accIdList.add((String)agg1.get('acc'));
            }

            Map<String,Account> accMap = new Map<String,Account>();
            for (Account acc : [SELECT Id,Email__c,Name FROM Account WHERE Id IN:accIdList]) {
                accMap.put(acc.Id,acc);
            }
            List<String> thHeadList = new List<String> {System.Label.CustomerName,System.Label.ProductCode,System.Label.ProductName,System.Label.RemainQuantity,System.Label.EstimatedInvoicingDate};
            if(remainMap.size()>0){

                //客户---->所有产品剩余数量
                Map<String,Utility.Table> currTableMap = new Map<String,Utility.Table>();

                
                for(String key : remainMap.keySet()){
                    List<String> keyList = key.split('_');
                    // 构建邮件表格的tr td内容
                    Utility.TableTr tableTr = new Utility.TableTr();
                    tableTr.tdMap.put(System.Label.CustomerName,new Utility.TableTd(accMap.get(keyList[0]).Name));
                    tableTr.tdMap.put(System.Label.ProductCode,new Utility.TableTd(keyList[1]));
                    tableTr.tdMap.put(System.Label.ProductName,new Utility.TableTd(keyList[2]));
                    tableTr.tdMap.put(System.Label.RemainQuantity,new Utility.TableTd(String.valueOf(remainMap.get(key))));
                    tableTr.tdMap.put(System.Label.EstimatedInvoicingDate,new Utility.TableTd(keyList[3]));
                    if (currTableMap.containsKey(keyList[0])) {
                        currTableMap.get(keyList[0]).tbody.trs.add(tableTr);
                    }else{
                       
                        Utility.Table currTable = BatchSendEmailToOrder.getDefaultTable(thHeadList);
                        currTable.tbody.trs.add(tableTr);
                        currTableMap.put(keyList[0],currTable);
                    }
                    
                }
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                if (currTableMap.size()>0) {

                    //汇总客户对应的产品信息到一个邮件中
                    for (String key : currTableMap.keySet()) {
                        List<String> emailList = new List<String>();
                        emailList.add(accMap.get(key).Email__c);
                        String body = Utility.getEmailTableHTML(currTableMap.get(key), thHeadList);
                        Messaging.SingleEmailMessage email = Utility.getSingleEmailMessage(System.Label.CQN,emailList, body,null,null);
                        emails.add(email);
                    }
                }

                if (emails.size()>0) {
                    Messaging.sendEmail(emails);
                }
            }
            
            
        } catch (Exception e) {
            this.flag = false;
            this.errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        Utility.setBatchInfo('EmailInventoryBatch', this.flag, this.startTime, this.errorMsg);
    }
}