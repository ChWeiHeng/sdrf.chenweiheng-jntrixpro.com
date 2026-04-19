@isTest
public class InterfaceUtilityTest {
    @IsTest
    static void TestInterfaceUtilityMethod() {
        InterfaceUtility.getProperErrorMessage('FIELD_CUSTOM_VALIDATION_EXCEPTION');
        InterfaceUtility.getProperErrorMessage('FIELD_INTEGRITY_EXCEPTION');
        InterfaceUtility.getProperErrorMessage('FIELD_FILTER_VALIDATION_EXCEPTION');
        InterfaceUtility.getProperErrorMessage('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST');
        InterfaceUtility.getProperErrorMessage('NUMBER_OUTSIDE_VALID_RANGE');
        InterfaceUtility.getProperErrorMessage('ENTITY_IS_LOCKEDs');
        InterfaceUtility.getProperErrorMessage('DUPLICATES_DETECTED');
        String interactJSONContent = '';
        String log = '';
        for(Integer i = 0; i< 131095 ; i ++) {
            interactJSONContent = interactJSONContent + 'T'; 
        }
        for(Integer i = 0; i< 131095 ; i ++) {
            log = log + 'T'; 
        }
        InterfaceUtility.insertInterfaceLog(
            'CaseSyncPOWebService', 
            'CRM',
            'SAP',
            'url',
            interactJSONContent,
            TRUE,
            false,
            log ,
            'message',
            'POST',
            new List<String>{'recordID'},
            'Update',
            'Test'
            );
        
        InterfaceUtility.getEnviromentFlag();
        try {
            InterfaceUtility.send_SAP_POST_Service('12312','CustomerInfo');
           
        } catch (Exception e) {

        }

    }
    @IsTest
    static void TestInterfaceUtilityMethod1() {
        InterfaceUtility.getProperErrorMessage('FIELD_CUSTOM_VALIDATION_EXCEPTION');
        InterfaceUtility.getProperErrorMessage('FIELD_INTEGRITY_EXCEPTION');
        InterfaceUtility.getProperErrorMessage('FIELD_FILTER_VALIDATION_EXCEPTION');
        InterfaceUtility.getProperErrorMessage('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST');
        InterfaceUtility.getProperErrorMessage('NUMBER_OUTSIDE_VALID_RANGE');
        InterfaceUtility.getProperErrorMessage('ENTITY_IS_LOCKEDs');
        InterfaceUtility.getProperErrorMessage('DUPLICATES_DETECTED');
        String interactJSONContent = '';
        String log = '';
        for(Integer i = 0; i< 131095 ; i ++) {
            interactJSONContent = interactJSONContent + 'T'; 
        }
        for(Integer i = 0; i< 131095 ; i ++) {
            log = log + 'T'; 
        }
        InterfaceUtility.insertInterfaceLog(
            'CaseSyncPOWebService', 
            'CRM',
            'SAP',
            'url',
            interactJSONContent,
            TRUE,
            false,
            log ,
            'message',
            'POST',
            new List<String>{'recordID'},
            'Update',
            'Test'
            );
        
        InterfaceUtility.getEnviromentFlag();
        try {
           
        } catch (Exception e) {

        }

}
    @IsTest
    static void TestInterfaceUtilityMethod2() {
        InterfaceUtility.getProperErrorMessage('FIELD_CUSTOM_VALIDATION_EXCEPTION');
        InterfaceUtility.getProperErrorMessage('FIELD_INTEGRITY_EXCEPTION');
        InterfaceUtility.getProperErrorMessage('FIELD_FILTER_VALIDATION_EXCEPTION');
        InterfaceUtility.getProperErrorMessage('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST');
        InterfaceUtility.getProperErrorMessage('NUMBER_OUTSIDE_VALID_RANGE');
        InterfaceUtility.getProperErrorMessage('ENTITY_IS_LOCKEDs');
        InterfaceUtility.getProperErrorMessage('DUPLICATES_DETECTED');
        String interactJSONContent = '';
        String log = '';
        for(Integer i = 0; i< 131095 ; i ++) {
            interactJSONContent = interactJSONContent + 'T'; 
        }
        for(Integer i = 0; i< 131095 ; i ++) {
            log = log + 'T'; 
        }
        InterfaceUtility.insertInterfaceLog(
            'CaseSyncPOWebService', 
            'CRM',
            'SAP',
            'url',
            interactJSONContent,
            TRUE,
            false,
            log ,
            'message',
            'POST',
            new List<String>{'recordID'},
            'Update',
            'Test'
            );
        
        InterfaceUtility.getEnviromentFlag();
        try {
            Map<String, String> kevValueParamMap = new Map<String, String>();
            kevValueParamMap.put('1','1');
           
        } catch (Exception e) {

        }

}
}