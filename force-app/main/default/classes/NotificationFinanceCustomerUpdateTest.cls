/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 12-16-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   12-16-2025   Gerry   Initial Version
**/
@isTest
private class NotificationFinanceCustomerUpdateTest {
    static testMethod void testMock1(){
        Account a = new Account(
            Name = 'Tax Clean',
            Group_Name__c = 'Test Group',
            Tax_Number__c = '12-34-56',
            Country__c = null, // avoid after-insert country-specific branches not under test
            Customer_Approval_Status__c = 'Draft',
            Sync_Status__c = 'Synchronized'
        );
        insert a;
        Customer_Update__c cu = new Customer_Update__c();
        cu.New_Customer_Name__c = '1';
        cu.Customer__c = a.Id;
        cu.Approve_Status__c = 'Approving';
        cu.Finance_Start_Approve__c = System.now().addDays(-2);
        insert cu;
        NotificationFinanceCustomerUpdateBatch svo = new NotificationFinanceCustomerUpdateBatch();

        // 每次执行多少条数据，最大200
        String jobId = Database.executeBatch(svo, 5);
    }
}