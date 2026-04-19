@isTest
private class closeEscComplaintControllerTest {
    static testMethod void testMethod1() {
        Case caseRecord=new Case();
        caseRecord.Approve_Status__c='Approved';
        insert caseRecord;
        closeEscComplaintController.init(caseRecord.Id);
        closeEscComplaintController.init('111');
        closeEscComplaintController.confirmSave(caseRecord.Id,'Closed','','Y');
        closeEscComplaintController.confirmSave(caseRecord.Id,'Cancel','test','');
    }
}