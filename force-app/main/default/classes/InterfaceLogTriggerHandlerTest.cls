@isTest
private class InterfaceLogTriggerHandlerTest {
    static testMethod void testMethod1() {
        Interface_Log__c il = new Interface_Log__c();
        il.Apex_Class_Name__c = 'test';
        il.Is_Success__c = true;
        il.Dml_Option__c = 'test';
        insert il;
    }
}