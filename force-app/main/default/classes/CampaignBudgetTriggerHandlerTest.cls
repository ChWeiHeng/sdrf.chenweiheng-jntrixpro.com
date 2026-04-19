@isTest
public with sharing class CampaignBudgetTriggerHandlerTest {
    static testMethod void testMethod1() {
        Campaign_Budget__c cam = new Campaign_Budget__c();
        cam.Budgeted_Amount__c=2000;
        cam.ExteralId__c='test1233e11';
        insert cam;
    }
}