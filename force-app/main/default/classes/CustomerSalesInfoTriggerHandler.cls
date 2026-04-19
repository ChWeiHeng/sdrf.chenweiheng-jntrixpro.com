/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 11-11-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-16-2025   Gerry   Initial Version
**/
public without sharing class CustomerSalesInfoTriggerHandler  implements Triggers.Handler{
    public void handle() {
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            Map<Id,Customer_Sales_Info__c> oldMap = (Map<Id,Customer_Sales_Info__c>)Trigger.oldMap;
            Set<String> countrySet = new Set<String>();
            Set<String> csiSet = new Set<String>();
            Set<String> customerSet = new Set<String>();//客户Id
            for (Customer_Sales_Info__c csi : (List<Customer_Sales_Info__c>)Trigger.New) {
                countrySet.add(csi.Country_Code_Text__c);
                customerSet.add(csi.Customer__c);
                if (Trigger.isUpdate && csi.Country__c!=oldMap.get(csi.Id).Country__c) {
                    csiSet.add(csi.Id);
                }
            }
            List<Customer_Tax_Category__c> ccDeleteList = [SELECT Id FROM Customer_Tax_Category__c WHERE Sales_View__c IN:csiSet];
            if (ccDeleteList.size()>0) {
                Database.delete(ccDeleteList);
            }
            Map<String,List<Tax_Category_Master_Data__c>> tcmdMap = new Map<String,List<Tax_Category_Master_Data__c>>();
            for (Tax_Category_Master_Data__c tcmd : [SELECT Id,Country_Code__c,Name FROM Tax_Category_Master_Data__c WHERE Country_Code__c IN:countrySet]) {
                if (tcmdMap.containsKey(tcmd.Country_Code__c)) {
                    tcmdMap.get(tcmd.Country_Code__c).add(tcmd);
                }else{
                    tcmdMap.put(tcmd.Country_Code__c, new List<Tax_Category_Master_Data__c>{tcmd});
                }
            }
            List<Customer_Tax_Category__c> insertList = new List<Customer_Tax_Category__c>();
            
            for (Customer_Sales_Info__c csi : (List<Customer_Sales_Info__c>)Trigger.New) {
                if (tcmdMap.get(csi.Country_Code_Text__c)!=null && (Trigger.isInsert || (Trigger.isUpdate && csi.Country__c!=oldMap.get(csi.Id).Country__c))) {
                    for (Tax_Category_Master_Data__c tcm : tcmdMap.get(csi.Country_Code_Text__c)) {
                        Customer_Tax_Category__c ctc = new Customer_Tax_Category__c();
                        ctc.Sales_View__c = csi.Id;
                        ctc.Tax_Category_Master_Data__c = tcm.Id;
                        ctc.Tax_Category_Type__c = tcm.Name;
                        insertList.add(ctc);
                    }
                }
            }
            Database.Insert(insertList);

            //判断该客户是否为ypf客户---start
            List<Account> accList = new List<Account>();
            for (Account acc : [SELECT Id,Is_YPF__c,(SELECT Id FROM Account_Sales_Info__r WHERE Payment_method__c='YPF' limit 1) FROM Account WHERE Id IN:customerSet]) {
                if (acc.Account_Sales_Info__r.size()>0) {
                    acc.Is_YPF__c = true;
                }else{
                    acc.Is_YPF__c = false;
                }
                accList.add(acc);
            }
            Utility.IgnoreAction(true,false,'CustomerSalesInfoTriggerHandler'); 
            Database.Update(accList);
            Utility.IgnoreAction(false,false,'CustomerSalesInfoTriggerHandler');
            //判断该客户是否为ypf客户---end

        }

        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            Set<String> customerSet = new Set<String>();
            for (Customer_Sales_Info__c csi : (List<Customer_Sales_Info__c>)Trigger.New) {
                if (
                    (csi.Delivering_Plant__c == '3010' || csi.Delivering_Plant__c == '3011' || csi.Delivering_Plant__c == '3020') &&
                    csi.Acct_Assmt_Grp_Cust__c == '01'
                ) {
                    csi.Reconciliation_Account__c = '1122010100';
                }

                if (
                    (csi.Delivering_Plant__c == '3010' || csi.Delivering_Plant__c == '3011' || csi.Delivering_Plant__c == '3020') &&
                    csi.Acct_Assmt_Grp_Cust__c == '02'
                ) {
                    csi.Reconciliation_Account__c = '1122020100';
                }

                if (
                    (csi.Delivering_Plant__c == '5070' || csi.Delivering_Plant__c == '5130') &&
                    csi.Acct_Assmt_Grp_Cust__c == '01'
                ) {
                    csi.Reconciliation_Account__c = '1122010000';
                }

                if (
                    (csi.Delivering_Plant__c == '5070' || csi.Delivering_Plant__c == '5130') &&
                    csi.Acct_Assmt_Grp_Cust__c == '02'
                ) {
                    csi.Reconciliation_Account__c = '1122020000';
                }

                customerSet.add(csi.Customer__c);
                csi.External_ID__c = csi.Customer__c+'_'+csi.Sales_Org__c+'_'+csi.Distr_Channel__c;
            }

            Map<String,Account> accMap = new Map<String,Account>();
            for (Account acc : [SELECT Id,Customer_Approval_Status__c,MDG_Customer_Code__c FROM Account WHERE Id IN:customerSet]) {
                accMap.put(acc.Id, acc);
            }

            for (Customer_Sales_Info__c csi : (List<Customer_Sales_Info__c>)Trigger.New) {
                if(accMap.get(csi.Customer__c).Customer_Approval_Status__c!='Draft' && accMap.get(csi.Customer__c).Customer_Approval_Status__c!='Approved') {
                    csi.addError(System.Label.SalesInfoCannotSave);
                }

                // if (accMap.get(csi.Customer__c).Customer_Approval_Status__c=='Approved' && accMap.get(csi.Customer__c).MDG_Customer_Code__c == null) {
                //     csi.addError(System.Label.SalesInfoCannotSave);
                // }
            }
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            Map<Id,Customer_Sales_Info__c> oldMap = (Map<Id,Customer_Sales_Info__c>)Trigger.oldMap;
            Set<String> accIdSet = new Set<String>();
            for (Customer_Sales_Info__c csi : (List<Customer_Sales_Info__c>)Trigger.New) {
                accIdSet.add(csi.Customer__c);
            }
            Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,MDG_Customer_Code__c FROM Account WHERE Id IN:accIdSet]);
            for (Customer_Sales_Info__c csi : (List<Customer_Sales_Info__c>)Trigger.New) {
                
                Set<String> uSet = new Set<String>();
                uSet.add(csi.OwnerId);
                if(oldMap.get(csi.Id).Sales_View_Status__c!=csi.Sales_View_Status__c && csi.Sales_View_Status__c=='Approved') {
                    if(accMap.get(csi.Customer__c)!=null && accMap.get(csi.Customer__c).MDG_Customer_Code__c!=null) {
                        if (!csi.isSync__c) {
                            CustomerSalesInfoSyncToSAP.submitToSAPFutrue(csi.Id,'I');
                        }else{
                            CustomerSalesInfoSyncToSAP.submitToSAPFutrue(csi.Id,'U');
                        }
                    }else{
                        Datetime d = Datetime.now();
                        String minute = d.minute() + 1 + '';
                        String sch =  d.second() +  ' ' +   minute +    ' ' +   d.hour() +   ' ' +   d.day() +  ' ' +  d.month() +  ' ? ' + d.year();
                        SyncAccountSalesInfoSchedule schup = new SyncAccountSalesInfoSchedule(
                            csi.Id
                        );
                        System.schedule(
                        '定时一分钟后SyncAccountSalesInfo' + Datetime.now().getTime(),
                        sch,
                        schup
                        );
                    }
                }

                if(oldMap.get(csi.Id).Sales_View_Status__c==csi.Sales_View_Status__c && csi.Sales_View_Status__c=='Approved' && !System.isBatch() && !System.isFuture() && csi.Sync_Status__c==oldMap.get(csi.Id).Sync_Status__c) {
                    if (!csi.isSync__c) {
                        CustomerSalesInfoSyncToSAP.submitToSAPFutrue(csi.Id,'I');
                    }else{
                        CustomerSalesInfoSyncToSAP.submitToSAPFutrue(csi.Id,'U');
                    }
                }

                //审批结果通知
                if(csi.Sales_View_Status__c == 'Approved' && csi.Sales_View_Status__c!=oldMap.get(csi.Id).Sales_View_Status__c) {
                    Utility.notificationUserTitle(uSet,csi.Id,System.Label.Sales_Approved_Title,System.Label.Sales_Approved_Title+csi.Name);
                }

                if(csi.Sales_View_Status__c == 'Rejected' && csi.Sales_View_Status__c!=oldMap.get(csi.Id).Sales_View_Status__c) {
                    Utility.notificationUserTitle(uSet,csi.Id,System.Label.Sales_Rejected_Title,System.Label.Sales_Rejected_Title+csi.Name);
                }
            }
           
        }

        // 共享数据到客户小组
        if (Trigger.isAfter && Trigger.isinsert ) {
            for (Customer_Sales_Info__c order : (List<Customer_Sales_Info__c>)Trigger.new) {
                ShareDataToAccountTeam.shareData('Customer_Sales_Info__c', order.Id, order.Customer__c, 'Customer_Sales_Info__c',order.OwnerId);
            }
        }
        // 共享数据到客户小组
        if (Trigger.isbefore && Trigger.isUpdate ) {
             Map<Id,Customer_Sales_Info__c> oldMap = (Map<Id,Customer_Sales_Info__c>)Trigger.oldMap;
             for (Customer_Sales_Info__c csi : (List<Customer_Sales_Info__c>)Trigger.new) {
                if(oldMap.get(csi.Id).Delivering_Plant__c !=csi.Delivering_Plant__c) {
                    system.debug('变更工厂');
                Database.executeBatch(new ChangeShareDataToAccountTeamBatch('Customer_Sales_Info__c', csi.Id, csi.Customer__c, 'Customer_Sales_Info__c',csi.OwnerId,oldMap.get(csi.Id).Delivering_Plant__c,'Customer_Sales_Info__share'));
                }}
        }
    }
}