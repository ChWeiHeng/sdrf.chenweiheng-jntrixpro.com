/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-28-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-28-2025   Gerry   Initial Version
**/
@isTest
private class InvoiceItemTriggerHandlerTest {


    @IsTest
    static void testHandle() {
        Invoice__c inv = new Invoice__c();
        inv.External_Id__c = '1';
        Insert inv;
        Billing__c bill = new Billing__c();
        // bill.Order_Item__c = orI1.Id;
        bill.Billing_Status__c = 'C';
        bill.Billing_Num__c = '1234';
        // bill.Order__c = order1.Id;
        bill.Invoice_Date__c = Date.valueOf('2024-01-02');
        bill.SAP_Total_Net__c = 10;
        bill.SAP_Total_Net_UDS__c = 10;
        bill.SAP_Total_Amount__c = 0;
        bill.Collection_Transaction_Amount__c = 0;
        // bill.OwnerId = u.Id;
        bill.Invoice__c = inv.Id;
        Insert bill;
    }
}