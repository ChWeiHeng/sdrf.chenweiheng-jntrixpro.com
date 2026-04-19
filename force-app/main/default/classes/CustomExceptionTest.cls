@isTest
private class CustomExceptionTest {
    static testMethod void testMethod1() {
        try{
            throw new CustomException('Test');
        }catch(Exception e){

        }
    }
}