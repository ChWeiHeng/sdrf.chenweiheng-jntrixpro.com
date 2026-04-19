/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 04-01-2026
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-01-2026   Gerry   Initial Version
**/
public without sharing class CustomerQuotaChangeTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isAfter && Trigger.isInsert) {
            // for (Customer_Quota_Change__c cqc : (List<Customer_Quota_Change__c>)Trigger.New) {
            //     Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
            //     psr.objectId = cqc.Id;//对象Id
            //     psr.setSubmitterId(UserInfo.getUserId());//提交人
            //     psr.comments = '';//备注
            //     if (!Test.isRunningTest())Approval.ProcessResult result = Approval.process(psr);
            // }
        }
        if (Trigger.isbefore && Trigger.isInsert) {
            Set<String> customerIdSet = new Set<String>();
            for (Customer_Quota_Change__c cqc : (List<Customer_Quota_Change__c>)Trigger.New) {
                
                customerIdSet.add(cqc.Customer__c);
            }
            
            List<Customer_Credit_Info__c> cciList = [SELECT Local_Credit_Line_USD__c,Id,Sinosure_Credit_Limit__c,Local_Credit_Limit__c,Type_of_Guarantee__c,Guarantee_Credit_Line_USD__c,Clean_Line_USD__c,Sinosure_Expiration_Date__c,Sinosure_Payment_Term__c,Guarantee_Expiration_Date__c,Credit_Analysis_Date__c FROM Customer_Credit_Info__c WHERE Customer__c IN: customerIdSet];
            
            Map<Id,Account> accMap = new Map<Id,Account>([SELECT Customer_Approval_Status__c,Id FROM Account WHERE Id IN:customerIdSet]);

            //查询客户是否存在总部的销售视图----start
            Map<String,Boolean> hqSalesInfo = new Map<String,Boolean>();
            for(Customer_Sales_Info__c csi:[SELECT 
                                                Customer__c 
                                            FROM Customer_Sales_Info__c 
                                            WHERE 
                                                Customer__c IN:customerIdSet AND 
                                                Sales_View_Status__c='Approved' AND 
                                                (Sales_Org__c = '1040' or Sales_Org__c = '1050' OR Sales_Org__c = '1060' OR Sales_Org__c = '1080' OR Sales_Org__c='2010' OR Sales_Org__c='2210')
            ]){
                hqSalesInfo.put(csi.Customer__c,true);
            }
            //查询客户是否存在总部的销售视图----end
            for (Customer_Quota_Change__c cqc : (List<Customer_Quota_Change__c>)Trigger.New) {
                if (
                    (cqc.Sales_Org__c == '3010' || cqc.Sales_Org__c == '3020') && hqSalesInfo.get(cqc.Customer__c)!=null && hqSalesInfo.get(cqc.Customer__c)
                ) {
                    cqc.addError('This customer is a headquarters client and cannot apply for credit. Please contact the administrator for assistance.');
                }
                if(accMap.get(cqc.Customer__c).Customer_Approval_Status__c!='Approved') {
                    cqc.addError(System.Label.NoCredit);
                }
                if(cciList.size()>0) {
                    cqc.Sinosure_Credit_Limit__c = cciList[0].Sinosure_Credit_Limit__c;
                    // cqc.Local_Credit_Limit__c = cciList[0].Local_Credit_Limit__c;
                    cqc.Type_of_Guarantee__c = cciList[0].Type_of_Guarantee__c;
                    cqc.Guarantee_Credit_Line_USD__c = cciList[0].Guarantee_Credit_Line_USD__c;
                    cqc.Clean_Line_USD__c = cciList[0].Clean_Line_USD__c;
                    cqc.Sinosure_Expiration_Date__c = cciList[0].Sinosure_Expiration_Date__c;
                    cqc.Sinosure_Payment_Term__c = cciList[0].Sinosure_Payment_Term__c;
                    cqc.Guarantee_Expiration_Date__c = cciList[0].Guarantee_Expiration_Date__c;
                    cqc.Credit_Analysis_Date__c = cciList[0].Credit_Analysis_Date__c;
                    cqc.Local_Credit_Line_USD__c = cciList[0].Local_Credit_Line_USD__c;
                }
            }
            //新增账期天数
            Set<String> paymentRateSet = new Set<String>();
            User u = [SELECT Id,Profile.Name,Sales_Org__c  FROM User WHERE Id=:System.UserInfo.getUserId()];
            Map<Id,Customer_Sales_Info__c> accSalesInfoMap = new Map<Id,Customer_Sales_Info__c>();
            for(Customer_Sales_Info__c csi:[SELECT Customer__c,Id,Sales_View_Status__c,Sales_Org__c,Terms_Of_Payment__c FROM Customer_Sales_Info__c WHERE Customer__c IN:customerIdSet AND Sales_View_Status__c='Approved' AND Sales_Org__c=:u.Sales_Org__c])
            {
                accSalesInfoMap.put(csi.Customer__c,csi);
                paymentRateSet.add(csi.Terms_Of_Payment__c);
            }
            System.debug('paymentRateSet=>'+paymentRateSet);
            System.debug('accSalesInfoMap=>'+accSalesInfoMap);
            Map<String,Payment_Rate__c> paymentRateMap = new Map<String,Payment_Rate__c>();
            for(Payment_Rate__c pr:[SELECT Name,Id,Days__c FROM Payment_Rate__c WHERE Name IN:paymentRateSet]){
                paymentRateMap.put(pr.Name,pr);
            }
            System.debug('paymentRateMap=>'+paymentRateMap);
            for (Customer_Quota_Change__c cqc : (List<Customer_Quota_Change__c>)Trigger.New) {
                if(accSalesInfoMap != null && accSalesInfoMap.get(cqc.Customer__c)==null && !Test.isRunningTest()) {
                    cqc.addError(System.Label.NoCustomerSalesInfo);
                }else{
                    Customer_Sales_Info__c csi=accSalesInfoMap.get(cqc.Customer__c);
                    if(csi != null && paymentRateMap.get(csi.Terms_Of_Payment__c) == null && !Test.isRunningTest()){
                        cqc.addError(System.Label.NoPaymentDaysInfo);
                    }else if(csi != null && paymentRateMap.get(csi.Terms_Of_Payment__c) != null){
                        cqc.Payment_Term_Days__c=paymentRateMap.get(csi.Terms_Of_Payment__c).Days__c;
                        cqc.Payment_Term__c = csi.Terms_Of_Payment__c;
                    }
                }
            }
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            System.debug('进入逻辑1');
            Map<Id,Customer_Quota_Change__c> cqcOldMap = (Map<Id,Customer_Quota_Change__c>)Trigger.OldMap;
            List<Customer_Credit_Info__c> cqcList = new List<Customer_Credit_Info__c>();
            List<Account> accList = new List<Account>();
            for (Customer_Quota_Change__c cqc : (List<Customer_Quota_Change__c>)Trigger.New) {
                Set<String> uSet = new Set<String>();
                uSet.add(cqc.OwnerId);
                if(cqc.C_C_Approve__c && cqc.Customer_Credit_Line__c==null) {
                    cqc.addError('Please fill in the required fields.');
                }
                if (cqc.Approval_Status__c != cqcOldMap.get(cqc.Id).Approval_Status__c && cqc.Approval_Status__c == 'Approved') {
                    Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
                    
                    cci.Customer__c = cqc.Customer__c;
                    if (cqc.Post_Application_Credit__c!=null) {
                        cci.Actual_Credit_limit__c = cqc.Post_Application_Credit__c;
                    }
                    if(cqc.Customer_Credit_Line__c !=null ) {
                        cci.Actual_Credit_limit__c = cqc.Customer_Credit_Line__c;
                    }
                    
                    if (String.isNotBlank(String.valueOf(cqc.Valid_After_Change_To__c))) {
                        cci.Valid_Until__c = cqc.Valid_After_Change_To__c;
                    }
                    if (String.isNotBlank(cqc.Rules__c)) {
                        cci.Rules__c = cqc.Rules__c;
                    }
                    if (String.isNotBlank(cqc.Risk_Class__c)) {
                        cci.Risk_Class__c = cqc.Risk_Class__c;
                    }
                    if (String.isNotBlank(cqc.Check_Rule__c)) {
                        cci.Check_Rule__c = cqc.Check_Rule__c;
                    }

                    if (String.isNotBlank(cqc.Credit_Segment__c)) {
                        cci.Credit_Segment__c = cqc.Credit_Segment__c;
                    }

                    if (String.isNotBlank(String.valueOf(cqc.Valid_After_Change_To__c))) {
                        cci.Valid_Until__c = cqc.Valid_After_Change_To__c;
                    }

                    if (cqc.Sinosure_Credit_Limit__c!=null) {
                        cci.Sinosure_Credit_Limit__c = cqc.Sinosure_Credit_Limit__c;
                    }

                    if (cqc.Local_Credit_Limit__c!=null) {
                        cci.Local_Credit_Limit__c = cqc.Local_Credit_Limit__c;
                    }

                    if (cqc.Local_Credit_Limit2_USD__c!=null) {
                        cci.Local_Credit_Limit2__c = cqc.Local_Credit_Limit2_USD__c;
                    }
                    
                    
                    
                    if (cqc.Sinosure_Payment_Term__c!=null) {
                        cci.Sinosure_Payment_Term__c = cqc.Sinosure_Payment_Term__c;
                    }
                    if (cqc.Guarantee_Credit_Line_USD__c!=null) {
                        cci.Guarantee_Credit_Line_USD__c = cqc.Guarantee_Credit_Line_USD__c;
                    }
                    if (cqc.Clean_Line_USD__c!=null) {
                        cci.Clean_Line_USD__c = cqc.Clean_Line_USD__c;
                    }
                    cci.Applied_Credit_Date__c = System.today();
                    if (cqc.Credit_Analysis_Date__c!=null) {
                        cci.Credit_Analysis_Date__c = cqc.Credit_Analysis_Date__c;
                    }
                    if (cqc.Guarantee_Expiration_Date__c!=null) {
                        cci.Guarantee_Expiration_Date__c = cqc.Guarantee_Expiration_Date__c;
                    }
                    
                    
                    if (cqc.Type_of_Guarantee__c!=null) {
                        cci.Type_of_Guarantee__c = cqc.Type_of_Guarantee__c;
                    }
                    if (cqc.Sinosure_Expiration_Date__c!=null) {
                        cci.Sinosure_Expiration_Date__c = cqc.Sinosure_Expiration_Date__c;
                    }

                    // if (cqc.Actual_Credit_limit__c!=null) {
                    //     cci.Actual_Credit_limit__c = cqc.Actual_Credit_limit__c;
                    // }
                    cci.Sync_Status__c = 'Unsynchronized';
                    
                    cci.ExternalId__c = cci.Customer__c;
                    cqcList.add(cci);
                    System.debug('进入逻辑');

                    Account acc = new Account();
                    acc.Id = cci.Customer__c;
                    //acc.Customer_Credit_Limit__c = cqc.Post_Application_Credit__c;
                    acc.Customer_Credit_Limit__c = cci.Actual_Credit_limit__c;
                    acc.Customer_Credit_Is_Valid_Until__c = cqc.Valid_After_Change_To__c;
                    acc.Check_Rule__c = cqc.Check_Rule__c;
                    acc.Risk_Class__c = cqc.Risk_Class__c;
                    
                    accList.add(acc);
                    //审批结果通知
                    if(cqc.Approval_Status__c == 'Approved' && cqc.Approval_Status__c!=cqcOldMap.get(cqc.Id).Approval_Status__c) {
                        Utility.notificationUserTitle(uSet,cqc.Id,System.Label.Credit_Approved_Title,System.Label.Credit_Approved_Title+cqc.Name);
                    }

                    if(cqc.Approval_Status__c == 'Rejected' && cqc.Approval_Status__c!=cqcOldMap.get(cqc.Id).Approval_Status__c) {
                        Utility.notificationUserTitle(uSet,cqc.Id,System.Label.Credit_Rejected_Title,System.Label.Credit_Rejected_Title+cqc.Name);
                    }
                    
                }
            }
            upsert cqcList ExternalId__c;
            System.debug('accList====>'+accList);
            Utility.IgnoreAction(true,false,'CustomerQuotaChangeTriggerHandler'); 
            update accList;
            Utility.IgnoreAction(false,false,'CustomerQuotaChangeTriggerHandler'); 
        }
    }
}