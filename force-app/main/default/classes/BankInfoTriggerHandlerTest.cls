@IsTest  
private class BankInfoTriggerHandlerTest {  
    static testMethod void testMock(){
            Account a = new Account();
         
            a.Name = '001D600001n4hjPIAQ';
            a.Group_Name__c = '001D600001n4hjPIAQ';
            a.Customer_Approval_Status__c = 'Approved';
            a.Sync_Status__c = 'Synchronized';
            a.MDG__c = false;
            insert a;

            Bank_Info__c bank1 = new Bank_Info__c();
            //bank1.name= 'BI-000008';
            bank1.Customer__c = a.Id;
            bank1.BANK_KEY__c = '015';
            bank1.Valid_Start_Date__c = Date.valueOf('2024-06-01');
            bank1.Valid_End_Date__c = Date.valueOf('2024-07-01');
            bank1.C_R__c = 'MX';
            insert bank1;

            //bank1.BANK_KEY__c = '016';
            //update bank1;
            //BankInfoTriggerHandler.handle();
        }
}