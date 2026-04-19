/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-30-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-30-2025   Gerry   Initial Version
**/
@isTest
private class AccountVisitTriggerHandlerTest {
    static testMethod void testMethod1() {
        Sales_Forecast_Summary__c sfs=new Sales_Forecast_Summary__c();
        sfs.Sales_Org__c='3010';
        sfs.Delivery_Plant__c='3010';
        sfs.Year__c=String.valueOf(date.today().Year());
        insert sfs;

        Account_Visit__c av=new Account_Visit__c();
        av.Start_Date__c=date.today();
        av.visit_Date__c = date.today();
        av.Sales_Org__c='3010';
        av.Plant__c='3010';
        insert av;
        update av;
    }
}