/**
 * @description       : Tests for UpdateBPMDamageNumberController
 * @author            : Agentforce
 * @date              : 2026-03-31
 * Notes:
 * - Covers success path (valid Order__c Id) and exception path (invalid Id)
 * - Ensures >=80% coverage on UpdateBPMDamageNumberController
 */
@IsTest
private class UpdateBPMDamageNumberControllerTest {

    /**
     * @testmethod
     * Verifies that updateNumber successfully updates BPM_Damage_Assessment_Number__c
     * when provided a valid Order__c Id.
     */
    @IsTest
    static void testUpdateNumber_Success() {
        
        Account account = new Account();
        account.Name = 'TestAccount';
        account.Group_Name__c = 'TestGroup';
        account.Customer_Approval_Status__c = 'Approved';
        account.Sync_Status__c = 'Synchronized';
        account.MDG__c = false;
        insert account;
        System.debug('新建时候的状态'+account.Sync_Status__c);
        
        // 创建客户信用信息
        Customer_Credit_Info__c customerCreditInfo = new Customer_Credit_Info__c();
        customerCreditInfo.Customer__c = account.Id;
        customerCreditInfo.ExternalId__c = account.Id;
        insert customerCreditInfo;
        
        // 创建客户销售信息
        Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
        customerSalesInfo.Sales_Org__c = '3020';
        customerSalesInfo.Distr_Channel__c = '10';
        customerSalesInfo.Sales_View_Status__c = 'Approved';
        customerSalesInfo.Sync_Status__c = 'Synchronized';
        customerSalesInfo.Customer__c = account.Id;
        customerSalesInfo.Payment_method__c = 'YPF';
        insert customerSalesInfo;
        // Arrange: create minimal Order__c test data (assuming only Name is required)
        Order__c order = new Order__c();
        order.Customer__c = account.Id;
        order.Sales_Org__c = '5130';
        order.Distr_Channel__c = '00';
        order.Customer_Sales_Info__c = customerSalesInfo.Id;
        order.Currency__c = 'USD';
        order.Deliver_Plant__c = '5130';
        order.Order_type__c = 'ZARB';
        order.Interest_Rate__c = 5.0;
        insert order;

        // Act
        Test.startTest();
        UpdateBPMDamageNumberController.Output out =
            UpdateBPMDamageNumberController.updateNumber(order.Id, 'DMG-001');
        Test.stopTest();

        // Assert: method indicates success
        System.assertNotEquals(null, out, 'Output should not be null');
        System.assertEquals(true, out.isSucess, 'Expected isSucess to be true on successful update');
        System.assertEquals(null, out.errorMsg, 'errorMsg should be null on success');

        // Verify record actually updated
        Order__c ordAfter = [
            SELECT Id, BPM_Damage_Assessment_Number__c
            FROM Order__c
            WHERE Id = :order.Id
            LIMIT 1
        ];
        System.assertEquals('DMG-001', ordAfter.BPM_Damage_Assessment_Number__c, 'Damage number should be updated');
    }

    /**
     * @testmethod
     * Verifies exception branch by using an invalid Id, expecting isSucess=false and errorMsg populated.
     */
    @IsTest
    static void testUpdateNumber_Failure_InvalidId() {
        // Arrange: use a bogus Id that won't match any record
        String bogusId = 'a00XXXXXXXXXXXXXXX'; // invalid Id format/record for update

        // Act
        Test.startTest();
        UpdateBPMDamageNumberController.Output out =
            UpdateBPMDamageNumberController.updateNumber(bogusId, 'DMG-ERR');
        Test.stopTest();

        // Assert: method indicates failure and includes an error message
        System.assertNotEquals(null, out, 'Output should not be null');
        System.assertEquals(false, out.isSucess, 'Expected isSucess to be false on error');
        System.assertNotEquals(null, out.errorMsg, 'errorMsg should be populated on error');
        System.assert(out.errorMsg.contains(';'), 'errorMsg should contain a semicolon with line number suffix');
    }
}