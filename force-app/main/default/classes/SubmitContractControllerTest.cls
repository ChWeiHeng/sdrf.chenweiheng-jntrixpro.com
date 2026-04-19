@isTest
private class SubmitContractControllerTest {
    static testMethod void testMethod1() {
        Contracts__c con = new Contracts__c();
        insert con;
        
        Product__c p = new Product__c();
        p.Name = '12341234';
        p.External_Id__c = '12341234';
        insert p;
        
        Contracts_Detail__c conDetail=new Contracts_Detail__c();
        conDetail.Contracts__c=con.Id;
        conDetail.Product__c=p.Id;
        insert conDetail;
        
        SubmitContractController.submitContract('');
        SubmitContractController.submitContract(con.Id);
        con.CRM_Approval_Status__c='Approved';
        update con;
        SubmitContractController.submitContract(con.Id);
    }
}