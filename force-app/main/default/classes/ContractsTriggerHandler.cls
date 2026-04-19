/**
 * @description       : 合同trigger
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 01-14-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-13-2025   Gerry   Initial Version
**/
public without sharing class ContractsTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isBefore &&  Trigger.isinsert)
        {
            for (Contracts__c con : (List<Contracts__c>)Trigger.new) 
            {
                if(con.Quote__c==null)
                {
                    if(con.Sales_Org__c=='3010'){/*con.Final_Customer_Payment_Terms__c=system.label.MXContractPaymentTerms;*/}
                    if(con.Sales_Org__c=='5070'){con.Final_Customer_Payment_Terms__c=system.label.ARContractPaymentTerms;}
                }
            }
            //校验客户冻结
            // Set<String> accSet = new Set<String>();
            // Set<String> salesOrgSet = new Set<String>();
            // Set<String> accSalesOrgSet = new Set<String>();
            // for (Contracts__c con : (List<Contracts__c>)Trigger.new) {
            //     accSet.add(con.Final_Customer__c);
            //     salesOrgSet.add(con.Sales_Org__c);
            // }
            // for(Customer_Sales_Info__c csi :[SELECT Id,Customer__c,Sales_Org__c FROM Customer_Sales_Info__c WHERE Customer__c IN:accSet AND Sales_Org__c IN:salesOrgSet AND Is_Freeze__c='01'])
            // {
            //     accSalesOrgSet.add(csi.Customer__c+'_'+csi.Sales_Org__c);
            // }
            // System.debug('accSalesOrgSet=>'+accSalesOrgSet);
            // for (Contracts__c con : (List<Contracts__c>)Trigger.new) {
            //     if (accSalesOrgSet != null && accSalesOrgSet.contains(con.Final_Customer__c+'_'+con.Sales_Org__c)) {
            //         con.addError(System.Label.AccFreezeError);
            //     }
            // }
        }
        if(Trigger.isBefore && Trigger.isupdate) {
            Map<Id,Contracts__c> oldMap = (Map<Id,Contracts__c>)Trigger.oldMap;
            User u = [SELECT Id,Profile.Name,Delivery_Plant__c FROM User WHERE Id=:System.UserInfo.getUserId()];
            Profile pro = [SELECT Id FROM Profile WHERE Name='Interface Profile' limit 1];
            for (Contracts__c con : (List<Contracts__c>)Trigger.new) 
            {
                
                if(con.Sync_Status__c=='Synchronized' &&  u.Profile.Name != 'System Administrator' &&  oldMap.get(con.Id).Sync_Status__c==con.Sync_Status__c && system.UserInfo.getProfileId()!=pro.Id) {
                    //con.addError('This contract synced to BPM,can not change');
                    con.addError(System.Label.ContractChangeSyncStatusError);
                }
            }
        }
        if (Trigger.isBefore && (Trigger.isupdate || Trigger.isinsert)) {
            //List<Profile> adminPro = [SELECT Id FROM Profile WHERE Id=:UserInfo.getProfileId() AND  (Name='Interface Profile' OR Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema') limit 1];
            System.debug('进入逻辑');
            Set<String> paymentTermSet = new Set<String>();
            List<Contracts__c> conList = (List<Contracts__c>)Trigger.new;
            for (Contracts__c con : conList) 
            {
                
                if(con.Final_Customer_Payment_Terms__c != null)
                {
                    paymentTermSet.add(con.Final_Customer_Payment_Terms__c);
                }
            }
            System.debug('paymentTermSet'+paymentTermSet);
            Map<String,Payment_Rate__c> paymentRateMap = new Map<String,Payment_Rate__c>();
            for(Payment_Rate__c payRate:[SELECT Id,Name,Payment_Term_Cost_Rate__c,Payment_Term_Cost_Rate_Subsidiary__c  FROM Payment_Rate__c WHERE Name IN:paymentTermSet])
            {
                paymentRateMap.put(payRate.Name,payRate);
            }
            for (Contracts__c con : (List<Contracts__c>)Trigger.new) 
            {
                //if(quote.Sync_Status__c=='Not synchronized')
                //{       
                    if (paymentRateMap.get(con.Final_Customer_Payment_Terms__c) == null) 
                    {
                        //con.addError('Contracts Payment_Term Not Map Payment_Rate__c Data');
                        con.Payment_Term_Cost_Rate__c =1;
                    }
                    else 
                    {
                        con.Payment_Term_Cost_Rate__c = paymentRateMap.get(con.Final_Customer_Payment_Terms__c).Payment_Term_Cost_Rate__c;
                    }
                //}
            }

        }
        if (Trigger.isAfter && Trigger.isinsert) {
            // 共享数据到客户小组
            for (Contracts__c con : (List<Contracts__c>)Trigger.new) {
                ShareDataToAccountTeam.shareData('Contracts__c', con.Id, con.Final_Customer__c, 'Contract__c',con.OwnerId);
            }
        }
        if (Trigger.isAfter && Trigger.isupdate)
        {
            Map<Id,Contracts__c> oldMap = (Map<Id,Contracts__c>)Trigger.oldMap;
            for (Contracts__c con : (List<Contracts__c>)Trigger.new)
            {
                if(oldMap.get(con.Id).CRM_Approval_Status__c != con.CRM_Approval_Status__c && con.CRM_Approval_Status__c=='Approved') {
                   //  DraftContractSyncToBPM.ReturnResult rr = DraftContractSyncToBPM.submitToBPMFu(con.Id);
                   DraftContractSyncToBPM.submitToBPMFu(con.Id);
                   //同步BPM后发送邮件
                //    String body = '<div>'+System.Label.ContractSyncBPMBody+'</div>';
                //    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                //    body = body.replaceAll('【合同编号】', con.Name);
                //    Integer index = String.valueOf(URL.getOrgDomainUrl()).indexof('=')+1;
                //    System.debug('28');
                //    String recordURL = String.valueOf(URL.getOrgDomainUrl()).subString(index);
                //    System.debug('30');
                //    //body = body.replaceAll('【链接】',recordURL.replace(']','')+'/'+con.Id);
                //    email.setHtmlBody(body);
                //    email.setSubject(System.Label.Contract_Sync_BPM+con.Name);
                //    List<String> emailList = new List<String>();
                //    if(con.Sales_Org__c=='3010'){ 
                //     for(String userEmail:System.Label.MXContractSyncNoticeEmail.split(';'))
                //     {if(userEmail != null){emailList.add(userEmail);}
                //     }}
                //    if(con.Sales_Org__c=='5070'){
                //     for(String userEmail:System.Label.ARContractSyncNoticeEmail.split(';'))
                //     {if(userEmail != null){emailList.add(userEmail);}
                //     }}
                //    email.setToAddresses(emailList);
                //    OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress];
                //    if (owea.size() > 0 ) {
                //    email.setOrgWideEmailAddressId(owea.get(0).Id);
                // // email.setSenderDisplayName(owea.get(0).DisplayName);
                //   }
                //    email.setUseSignature(false);
                //    email.setBccSender(false);
                //    if(!Test.isRunningTest())Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                //    System.debug('105');   
                }
                if(oldMap.get(con.Id).Delivery_Plant__c !=con.Delivery_Plant__c) {
                    Database.executeBatch(new ChangeShareDataToAccountTeamBatch('Contracts__c', con.Id, con.Final_Customer__c, 'Contract__c',con.OwnerId,oldMap.get(con.Id).Delivery_Plant__c,'Contracts__share'));
                }
            }
        }
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isupdate))
        {
            Map<String,Id> codeCountryMap=new Map<String,Id>();
            for(Country_Province_Master_Data__c cpmd:[SELECT Id,Code__c FROM Country_Province_Master_Data__c WHERE RecordType.DeveloperName='Country'])
            {
                codeCountryMap.put(cpmd.Code__c,cpmd.Id);
            }
            system.debug('codeCountryMap=>'+codeCountryMap);
            List<User> userList = [SELECT Id,Country__c FROM User WHERE Id=:System.UserInfo.getUserId()];
            if(userList.size()>0)
            {
                for (Contracts__c con : (List<Contracts__c>)Trigger.new)
                {
                    con.Export_Country__c=codeCountryMap.get(userList[0].Country__c);
                }
            }
            Set<String> mdgCodeSet=new Set<String>();
            string mdgCode;
            for (Contracts__c con : (List<Contracts__c>)Trigger.new)
            {
                if(con.Delivery_Plant__c != null){mdgCode='000000'+con.Delivery_Plant__c;mdgCodeSet.add(mdgCode);}
            }
            System.debug('mdgCodeSet==>'+mdgCodeSet);
            Map<String,Id> codeAccMap=new Map<String,Id>();
            for(Account acc:[SELECT Id,MDG_Customer_Code__c FROM Account WHERE MDG_Customer_Code__c IN:mdgCodeSet])
            {
                codeAccMap.put(acc.MDG_Customer_Code__c,acc.Id);
            }
            System.debug('codeAccMap==>'+codeAccMap);
            for (Contracts__c con : (List<Contracts__c>)Trigger.new)
            {
                if(con.Quote__c == null && con.Delivery_Plant__c != null && codeAccMap.get('000000'+con.Delivery_Plant__c) != null){con.Customer__c=codeAccMap.get(mdgCode);con.Final_Customer__c=con.Customer__c;}
            }
        }
        

    }
}