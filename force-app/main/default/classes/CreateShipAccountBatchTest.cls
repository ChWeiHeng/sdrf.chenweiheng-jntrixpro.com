@IsTest
private  class CreateShipAccountBatchTest {
	static testMethod void testMock(){
		CreateShipAccountBatch svo = new CreateShipAccountBatch();
        CreateShipAccountBatch.testMock();

        SetTaxBatch svo1 = new SetTaxBatch();

       SetTaxBatch.testMock();
	}
    
}