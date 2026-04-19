/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 02-04-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-18-2025   Gerry   Initial Version
**/
@IsTest 
public with sharing class AccountTriggerHandlerTest {
    static testMethod void testMock(){
        Account acc = new Account();
        acc.Name = 'test acc';
        acc.Group_Name__c = '001D600001n4hjPIAQ';
        acc.Customer_Approval_Status__c = 'Approved';
        acc.Sync_Status__c = 'Synchronized';
        acc.MDG__c = false;
        insert acc;

        acc.Group_Name__c = '001D600001n4hjPIAZ';
        update acc;
        acc.Credit_Investigation_Date__c = System.today();
        update acc;
    }

    static testMethod void testMock1(){
        Account acc = new Account();
        acc.Name = 'test acc';
        acc.Group_Name__c = '001D600001n4hjPIAQ';
        acc.Customer_Approval_Status__c = 'Draft';
        acc.Sync_Status__c = 'Synchronized';
        acc.MDG__c = false;
        insert acc;
        Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
        csi.Sales_Org__c = '5130';
        csi.Distr_Channel__c = '00';
        csi.Customer__c = acc.Id;
        // csi.Acct_Assmt_Grp_Cust__c='01';
        insert csi;

        acc.Customer_Approval_Status__c = 'Approved';
        acc.Group_Name__c = '001D600001n4hjPIAZ';
        update acc;
    }

    static testMethod void testMock2(){
        try {
            Account acc = new Account();
            System.runAs(new User(Id = UserInfo.getUserId())) {
                
                acc.Name = 'test acc';
                acc.Group_Name__c = '001D600001n4hjPIAQ';
                acc.Customer_Approval_Status__c = 'Draft';
                acc.Sync_Status__c = 'Synchronized';
                acc.MDG__c = false;
                insert acc;
                Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
                csi.Sales_Org__c = '5130';
                csi.Distr_Channel__c = '00';
                csi.Customer__c = acc.Id;
                // csi.Acct_Assmt_Grp_Cust__c = '01';
                insert csi;
            }
            Profile prof = [SELECT Id FROM Profile WHERE Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema' LIMIT 1]; 
            User u = new User();
            u.LastName = 'test';
            u.Username = 'testuserbisfc@testorg.com';
            u.Alias = 'newUser';
            u.Email='testuserbisfc@testorg.com';
            u.EmailEncodingKey='UTF-8';
            u.LanguageLocaleKey='en_US';
            u.LocaleSidKey='en_US';
            u.ProfileId = prof.Id;
            u.TimeZoneSidKey='America/Los_Angeles';
            User currentUser = [SELECT Id,Sales_Org__c,Delivery_Plant__c FROM User WHERE id=:System.UserInfo.getUserId()];
            u.Sales_Org__c = currentUser.Sales_Org__c;
            u.Delivery_Plant__c = currentUser.Delivery_Plant__c;
            insert u;
            acc.Customer_Approval_Status__c = 'Approving';
            acc.Group_Name__c = '001D600001n4hjPIAZ';
            acc.OwnerId = u.Id;
            update acc;
        } catch (Exception e) {
            
        }
        
    }
}