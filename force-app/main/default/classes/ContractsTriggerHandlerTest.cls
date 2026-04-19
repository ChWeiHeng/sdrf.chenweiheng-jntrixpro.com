@IsTest
private  class ContractsTriggerHandlerTest {
	static testMethod void testMock(){
		Contracts__c con=new Contracts__c();
		insert con;
        Contracts_Detail__c conDetail=new Contracts_Detail__c();
        conDetail.Contracts__c=con.Id;
        insert conDetail;

		Contracts__c con1=new Contracts__c();
        con1.CRM_Approval_Status__c='Draft';
		insert con1;
        con1.CRM_Approval_Status__c='Approved';
		update con1;
	}
    
}