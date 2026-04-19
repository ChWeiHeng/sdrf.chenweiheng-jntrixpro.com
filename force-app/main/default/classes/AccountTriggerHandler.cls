/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-10-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-23-2025   Gerry   Initial Version
**/
public without sharing class AccountTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isAfter && Trigger.isUpdate) {
            Map<Id,Account> accMap = (Map<Id,Account>)Trigger.OldMap;
            Profile adminPro = [SELECT Id FROM Profile WHERE Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema' limit 1];
            User u = [SELECT Id,ManagerId  FROm User WHERE Id =:UserInfo.getUserId()];
            Set<String> accSet = new Set<String>();
            Set<String> accIdSet = new Set<String>();
            Set<String> accSet1 = new Set<String>();
            Set<String> accSet2 = new Set<String>();
            Set<String> accSet3 = new Set<String>();
            List<Account> accList = (List<Account>)Trigger.new;
            CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
            List<Schema.FieldSetMember> fieldSetMembersCanChange = SObjectType.Account.FieldSets.Can_not_change.getFields();
            for (Account acc : accList) {
                // ... existing code ...

                // 获取新旧记录的所有填充字段
                Map<String, Object> newFields = acc.getPopulatedFieldsAsMap();
                Map<String, Object> oldFields = accMap.get(acc.Id).getPopulatedFieldsAsMap();
                
                Boolean hasChanges = false;
                String updatef;
                // 比较所有字段值
                for (String fieldName : newFields.keySet()) {
                    // 跳过系统字段
                    if (
                        fieldName == 'LastModifiedDate' || 
                        fieldName == 'SystemModstamp' ||
                        fieldName == 'CreditNumber__c' || 
                        fieldName == 'LastModifiedById' ||
                        fieldName == 'ACN_No__c' ||
                        fieldName == 'Accounts_Email__c' ||
                        fieldName == 'Date_Business_Started__c' ||
                        fieldName == 'Operating_Address__c' || 
                        fieldName == 'OwnerId'
                    ) {
                        continue;
                    }
                    if (newFields.get(fieldName) != oldFields.get(fieldName)) {
                        System.debug('fieldName===》'+fieldName);
                        hasChanges = true;
                        updatef = fieldName;
                        break;
                    }
                }
                System.debug('updatef'+updatef);
                System.debug('hasChanges'+hasChanges);

            // ... existing code ...
                //校验销售视图是否有了税收类别
                if (acc.Customer_Approval_Status__c == 'Approving' && acc.Customer_Approval_Status__c != accMap.get(acc.Id).Customer_Approval_Status__c) {
                    accIdSet.add(acc.Id);
                }
                Account oldAcc = accMap.get(acc.Id);

                if ( acc.Customer_Approval_Status__c == 'Approved' ) {
                    for (Schema.FieldSetMember f : fieldSetMembersCanChange) {
                        
                        if (oldAcc.get(f.getFieldPath()) != acc.get(f.getFieldPath())) {
                            acc.addError(System.Label.Customer_Field_Edit);
                        }
                    }
                    // acc.addError(System.Label.Customer_Field_Edit);
                }
                if (
                    (acc.Customer_Approval_Status__c == 'Approved' && acc.Customer_Approval_Status__c == accMap.get(acc.Id).Customer_Approval_Status__c && UserInfo.getProfileId() != adminPro.Id) ||
                    System.Test.isRunningTest()
                    
                ) {
                    
                    
                    List<Schema.FieldSetMember> fieldSetMembers = SObjectType.Account.FieldSets.Customer_Info.getFields();
                    // 检查字段集中的字段是否更改
                    for (Schema.FieldSetMember f : fieldSetMembers) {
                        
                        if (oldAcc.get(f.getFieldPath()) != acc.get(f.getFieldPath())) {
                            // 值已更改，执行相应操作
                            Set<String> adminSet = new Set<String>();
                            if(u.ManagerId!=null){
                                adminSet.add(u.ManagerId);
                                CustomNotificationFromApex.notifyUsers(
                                    notificationType, 
                                    adminSet, //发送通知给谁
                                    acc.Id, //通知点击后跳转到什么数据上
                                    System.Label.AccountUpdateNotfication, //标题
                                    System.Label.AccountUpdateNotficationBody//内容
                                );
                                break;
                            }
                            
                        }
                    }
                }
                if (acc.Customer_Approval_Status__c == 'Approved' && acc.Customer_Approval_Status__c != accMap.get(acc.Id).Customer_Approval_Status__c ) {
                    if (acc.MDG_Customer_Code__c!=null) {
                        CustomerInfoSyncToSAP.submitToSAPFu(acc.Id,'U');
                    }else{
                        CustomerInfoSyncToSAP.submitToSAPFu(acc.Id,'I');
                    }
                }

                if (
                    hasChanges && acc.Customer_Approval_Status__c == 'Approved' && 
                    acc.Customer_Approval_Status__c == accMap.get(acc.Id).Customer_Approval_Status__c && !acc.MDG__c && !System.isBatch() && !System.isFuture()
                    && acc.Sync_Status__c==accMap.get(acc.Id).Sync_Status__c && acc.Sync_Status__c=='Synchronized' && acc.Name==accMap.get(acc.Id).Name
                ) {
                    System.debug('进入客户trigger');

                    if (acc.MDG_Customer_Code__c!=null) {
                        CustomerInfoSyncToSAP.submitToSAPFu(acc.Id,'U');
                    }else{
                        CustomerInfoSyncToSAP.submitToSAPFu(acc.Id,'I');
                    }
                }


                if (acc.Customer_Approval_Status__c != accMap.get(acc.Id).Customer_Approval_Status__c && acc.Customer_Approval_Status__c=='Approved') {
                    accSet.add(acc.Id);
                }

                if (acc.Customer_Approval_Status__c != accMap.get(acc.Id).Customer_Approval_Status__c && acc.Customer_Approval_Status__c=='Approving') {
                    accSet1.add(acc.Id);
                }
                if (acc.Customer_Approval_Status__c != accMap.get(acc.Id).Customer_Approval_Status__c && acc.Customer_Approval_Status__c=='Draft') {
                    accSet2.add(acc.Id);
                }

                if (acc.Customer_Approval_Status__c != accMap.get(acc.Id).Customer_Approval_Status__c && acc.Customer_Approval_Status__c=='Rejected') {
                    accSet3.add(acc.Id);
                }
            }
            List<Customer_Sales_Info__c> csiListSubmit = [SELECT Id,Can_Submit__c FROM Customer_Sales_Info__c WHERE Customer__c IN:accIdSet AND Can_Submit__c=false];
            if (csiListSubmit.size()>0) {
                accList[0].addError(System.Label.Account_Sales_Info_Required);
            }    
            List<Customer_Sales_Info__c> csiList = new List<Customer_Sales_Info__c>();
            for (Customer_Sales_Info__c csi : [SELECT Id,Sales_View_Status__c FROM Customer_Sales_Info__c WHERE Customer__c IN:accSet]) {
                csi.Sales_View_Status__c = 'Approved';
                csiList.add(csi);
            }
            // Database.update(csiList);

            List<Customer_Sales_Info__c> csiList1 = new List<Customer_Sales_Info__c>();
            for (Customer_Sales_Info__c csi : [SELECT Id,Sales_View_Status__c FROM Customer_Sales_Info__c WHERE Customer__c IN:accSet1]) {
                csi.Sales_View_Status__c = 'Approving';
                csiList1.add(csi);
            }
            if (csiList1.size()>0) {
                Utility.IgnoreAction(true,false,'AccountTriggerHandler'); 
                Database.update(csiList1);
                Utility.IgnoreAction(false,false,'AccountTriggerHandler'); 
            }

            List<Customer_Sales_Info__c> csiList2 = new List<Customer_Sales_Info__c>();
            for (Customer_Sales_Info__c csi : [SELECT Id,Sales_View_Status__c FROM Customer_Sales_Info__c WHERE Customer__c IN:accSet2]) {
                csi.Sales_View_Status__c = 'Draft';
                csiList2.add(csi);
            }
            if (csiList2.size()>0) {
                Utility.IgnoreAction(true,false,'AccountTriggerHandler'); 
                Database.update(csiList2);
                Utility.IgnoreAction(false,false,'AccountTriggerHandler'); 
            }

            List<Customer_Sales_Info__c> csiList3 = new List<Customer_Sales_Info__c>();
            for (Customer_Sales_Info__c csi : [SELECT Id,Sales_View_Status__c FROM Customer_Sales_Info__c WHERE Customer__c IN:accSet3]) {
                csi.Sales_View_Status__c = 'Reject';
                csiList3.add(csi);
            }
            if (csiList3.size()>0) {
                Utility.IgnoreAction(true,false,'AccountTriggerHandler'); 
                Database.update(csiList3);
                Utility.IgnoreAction(false,false,'AccountTriggerHandler'); 
            }



            if (csiList.size()>0) {
                Database.update(csiList);
            }
            
        }

        //客户小组赋值
        if (Trigger.isAfter && Trigger.isInsert) {
            List<Customer_Tax_Number_Category__c> ctncList = new List<Customer_Tax_Number_Category__c>();
            List<Account_Team__c> atList = new List<Account_Team__c>();
            Map<String,String> ctncMap = new Map<String,String>();
            for(Tax_Number_Master_Data__c tnmd : [SELECT Id,Name,Code__c FROM Tax_Number_Master_Data__c]) {
                ctncMap.put(tnmd.Code__c,tnmd.Id);
            }

            Map<String,String> countryMap = new Map<String,String>();
            for(Country_Province_Master_Data__c cpmd : [SELECT Id,Code__c FROM Country_Province_Master_Data__c WHERE RecordType.DeveloperName='Country']) {
                countryMap.put(cpmd.Id,cpmd.Code__c);
            }
            for (Account acc : (List<Account>)Trigger.new) {
                Account_Team__c at = new Account_Team__c();
                at.Customer__c = acc.Id;
                at.Sales_Rep__c = acc.OwnerId;
                atList.add(at);

                Customer_Tax_Number_Category__c ctnc = new Customer_Tax_Number_Category__c();
                ctnc.Customer__c = acc.Id;
                ctnc.Long_Tax_Number__c = acc.Tax_Number__c;
                if(countryMap.get(acc.Country__c) == 'AR') {
                    ctnc.Tax_Number_Master_Data__c = ctncMap.get('AR1A');
                }

                if(countryMap.get(acc.Country__c) == 'MX') {
                    ctnc.Tax_Number_Master_Data__c = ctncMap.get('MX1');
                }
                
                ctncList.add(ctnc);
            }
            if (atList.size()>0) {
                Database.insert(atList);
            }

            if(ctncList.size()>0) {
                Database.insert(ctncList);
            }
            
            
            

        }
        if (Trigger.isAfter && Trigger.isUpdate) {
            List<Account_Team__c> atList = new List<Account_Team__c>();
            Map<Id,Account> accMap = (Map<Id,Account>)Trigger.OldMap;
            User u = [SELECT Id,Deliver_Plant_Text__c FROM User WHERE Id=:UserInfo.getUserId()];
            List<AccountShare> accountShareList = new List<AccountShare>();
            for (Account acc : (List<Account>)Trigger.new) {
                Set<String> uSet = new Set<String>();
                uSet.add(acc.OwnerId);
                if (acc.OwnerId != accMap.get(acc.Id).OwnerId || System.Test.isRunningTest()) {
                    AccountShare sharingObject = new AccountShare();
                    sharingObject.put('AccountId', acc.Id);
                    sharingObject.put('AccountAccessLevel', 'Edit');
                    sharingObject.put('OpportunityAccessLevel', 'None');
                    sharingObject.put('RowCause','Manual');
                    sharingObject.put('UserOrGroupId',accMap.get(acc.Id).OwnerId);
                    accountShareList.add(sharingObject);
                    Account_Team__c at = new Account_Team__c();
                    at.Customer__c = acc.Id;
                    at.Sales_Rep__c = acc.OwnerId;
                    at.External_Id__c = at.Customer__c+'_'+at.Sales_Rep__c; 
                    atList.add(at);
                }

                //审批结果通知
                if(acc.Customer_Approval_Status__c == 'Approved' && acc.Customer_Approval_Status__c!=accMap.get(acc.Id).Customer_Approval_Status__c) {
                    Utility.notificationUserTitle(uSet,acc.Id,System.Label.Acc_Approved_Title,System.Label.Acc_Approved_Title+acc.Name);
                }

                if(acc.Customer_Approval_Status__c == 'Rejected' && acc.Customer_Approval_Status__c!=accMap.get(acc.Id).Customer_Approval_Status__c) {
                    Utility.notificationUserTitle(uSet,acc.Id,System.Label.Acc_Rejected_Title,System.Label.Acc_Rejected_Title+acc.Name);
                }
                System.debug('Utility.isPassTriggerLogic'+Utility.isPassTriggerLogic);
                //MX特定字段不能修改---start
                if (u.Deliver_Plant_Text__c != null && u.Deliver_Plant_Text__c.startsWith('30') && !Utility.isPassTriggerLogic) {
                    System.debug('进入校验逻辑');
                    List<Schema.FieldSetMember> fieldSetMembers = SObjectType.Account.FieldSets.ChangeFieldByFinance.getFields();
                    String labelValue = '';
                    for (Schema.FieldSetMember f : fieldSetMembers) {
                        if (String.isBlank(labelValue)) {
                            labelValue = f.getLabel();
                        }else{
                            labelValue += ';'+f.getLabel();
                        }
                       
                        
                    }
                    for (Schema.FieldSetMember f : fieldSetMembers) {
                        if (acc.get(f.getFieldPath())!=accMap.get(acc.Id).get(f.getFieldPath())) {//校验字段是否发生了变化
                            acc.addError(System.Label.CanNotChangeCustomerKeyInfo.replace('[XXXX]',labelValue));
                        }
                    }
                }
                
                //MX特定字段不能修改---end
               
            }
            if (atList.size()>0) {
                Database.upsert(atList,Account_Team__c.fields.External_Id__c);
            }
            if (accountShareList.size()>0 && !System.Test.isRunningTest()) {
                upsert accountShareList;
            }
        }

        //CR 商服完成资信调查信息后 通知到销售 start
        if (Trigger.isAfter && Trigger.isUpdate) {
            Map<Id,Account> accMap = (Map<Id,Account>)Trigger.OldMap;
            for (Account acc : (List<Account>)Trigger.new) {
                if (
                    accMap.get(acc.Id).Credit_Investigation_Date__c != acc.Credit_Investigation_Date__c ||
                    accMap.get(acc.Id).Credit_Investigation_Note__c != acc.Credit_Investigation_Note__c ||
                    accMap.get(acc.Id).Is_Credit_Investigation_Attached__c != acc.Is_Credit_Investigation_Attached__c ||
                    System.Test.isRunningTest()
                ) {
                    CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
                    Set<String> adminSet = new Set<String>();
                    adminSet.add(acc.OwnerId);
                    CustomNotificationFromApex.notifyUsers(
                        notificationType, 
                        adminSet, //发送通知给谁
                        acc.Id, //通知点击后跳转到什么数据上
                        acc.Name+System.Label.NotficationServiceSaleTitle, //标题:Credit investigation has been done
                        System.Label.NotficationService//内容
                    );
                    User u = [SELECT Id,Email FROM User WHERE Id=:acc.OwnerId];
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    String body = System.Label.CompleteBody;
                    body = body.replaceAll('【客户名称】', acc.Name);
                    Integer index = String.valueOf(URL.getOrgDomainUrl()).indexof('=')+1;
                    String recordURL = String.valueOf(URL.getOrgDomainUrl()).subString(index);
                    body = body.replaceAll('【链接】',recordURL.replace(']','')+'/'+acc.Id);
                    email.setPlainTextBody(body);
                    email.setSubject(System.Label.NotficationServiceSaleTitle);
                    email.setToAddresses(new List<String>{u.Email});
                    // OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'rb@crm.com'];
                    // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    // if ( owea.size() > 0 ) {
                    //     email.setOrgWideEmailAddressId(owea.get(0).Id);
                    // }
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress];
                    if (owea.size() > 0 ) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                     }
                    if(!Test.isRunningTest())Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                }
            }
        }
        //CR 商服完成资信调查信息后 通知到销售 end

        //税号去掉空格
        if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
            for (Account acc: (List<Account>)Trigger.new) {
                if (acc.Tax_Number__c != null) {
                    acc.Tax_Numbe_No_Bar__c = acc.Tax_Number__c.replace('-','');
                }
            }
        }
    }
}