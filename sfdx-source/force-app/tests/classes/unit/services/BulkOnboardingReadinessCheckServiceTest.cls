/**
 * @author BizApps
 * @date 9-June-2024
 * @description Test class for the BulkOnboardingReadinessCheckService class
**/
@IsTest
private class BulkOnboardingReadinessCheckServiceTest {
    private static final String ACCOUNT_OBJECT = 'Account';
    private static final String ACTIVATE_CENTRALLY_YES = 'Yes';
    private static final String MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER = 'Account Owner';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String MENU_UI_TYPE_RESTAURANT = 'Restaurant';
    private static final String ORDER_PROTOCOL_POS = 'POS';
    private static final String PRIMARY_VERTICAL_FLORAL = 'Floral';
    private static final String READINESS_VALIDATION_MISSING_ERROR = 'Readiness Check validation message is not in the list of error messages.';
    private static final String SHOPPER_PICK_SHOPPING_PROTOCOL = 'Shopper Pick';
    private static final String SHOPPING_PROTOCOL_DASHER_PICK = 'Dasher Pick';

    private static final String METHOD_ACTIVATE_CENTRALLY = 'validateActivateCentrally';
    private static final String METHOD_MIN_PREP_TIME = 'validateMinimumPrepTime';
    private static final String METHOD_NULL_FIELDS = 'validateNullFieldValuesOnStore';
    private static final String METHOD_POS_INTEGRATION = 'validatePOSIntegrationFields';
    private static final String METHOD_SHOPPING_PROTOCOL_REQUIRED_MENU_UI = 'validateShoppingProtocolMandatoryOnRetailMenuUIType';
    private static final String METHOD_SHOPPING_PROTOCOL_BLANK_MENU_UI = 'validateShoppingProtocolBlankOnRxMenuUIType';

    /**
     * @description Lists the Store Readiness Metadata Rule records by their Service Method Names
     * @return Map<String, Store_Readiness_Validation_Rule__mdt>
    **/
    public static Map<String, Store_Readiness_Validation_Rule__mdt> metadataRecordsByMethodNames { get {
        if(metadataRecordsByMethodNames == null) {
            metadataRecordsByMethodNames = new Map<String, Store_Readiness_Validation_Rule__mdt>{

            };
        }
        return metadataRecordsByMethodNames;
    } set;}

    private static Map<String, Store_Readiness_Validation_Rule__mdt> readinessChecksByNames { get {
        if(readinessChecksByNames == null) {
            readinessChecksByNames = new Map<String, Store_Readiness_Validation_Rule__mdt>();

            for(Store_Readiness_Validation_Rule__mdt thisReadinessCheck : StoreReadinessValidationRulesSelector.newInstance().selectAllValidReadinessValidationRules()) {
                if(thisReadinessCheck.Object_Name__c != ACCOUNT_OBJECT) {
                    continue;
                }

                readinessChecksByNames.put(thisReadinessCheck.Service_Method_Name__c, thisReadinessCheck);
            }
        }

        return readinessChecksByNames;
    } set;}

    private static BulkCorporateOnboardingWrappers.StoreInfo mockWrapper {get {
        if(mockWrapper == null) {
            mockWrapper = new BulkCorporateOnboardingWrappers.StoreInfo(null, null, null);
            mockWrapper.rowNumber = 1;
        }
        return mockWrapper;
    } set;}


    @IsTest
    static void testWhenRunningReadinessChecksThenReturnCorrectErrors() {
        Account storeWithActivateCentrallyErrors = new Account(Menu_to_be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER, Activated_Centrally_AC__c = ACTIVATE_CENTRALLY_YES);
        Account storeWithMinPrepTimeErrors = new Account(Primary_Vertical__c = PRIMARY_VERTICAL_FLORAL, Minimum_Prep_Time__c = null);
        Account storeWithPosErrors = new Account(Order_Protocol__c = ORDER_PROTOCOL_POS, POS_Integration_ID__c = null);
        Account storeWithMenuUiTypeRequiredErrors = new Account(Menu_UI_Type__c = MENU_UI_TYPE_RETAIL);
        Account storeWithMenuUiTypeBlankErrors = new Account(Menu_UI_Type__c = MENU_UI_TYPE_RESTAURANT, Shopping_Protocol__c = SHOPPING_PROTOCOL_DASHER_PICK);

        Account storeWithMultipleErrors = new Account();
        storeWithMultipleErrors.Menu_to_be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER;
        storeWithMultipleErrors.Activated_Centrally_AC__c = ACTIVATE_CENTRALLY_YES;
        storeWithMultipleErrors.Menu_UI_Type__c = MENU_UI_TYPE_RESTAURANT;
        storeWithMultipleErrors.Shopping_Protocol__c = SHOPPING_PROTOCOL_DASHER_PICK;

        assertReadinessErrorForRecord(storeWithActivateCentrallyErrors, METHOD_ACTIVATE_CENTRALLY);
        assertReadinessErrorForRecord(storeWithMinPrepTimeErrors, METHOD_MIN_PREP_TIME);
        assertReadinessErrorForRecord(storeWithPosErrors, METHOD_POS_INTEGRATION);
        assertReadinessErrorForRecord(storeWithMenuUiTypeRequiredErrors, METHOD_SHOPPING_PROTOCOL_REQUIRED_MENU_UI);
        assertReadinessErrorForRecord(storeWithMenuUiTypeBlankErrors, METHOD_SHOPPING_PROTOCOL_BLANK_MENU_UI);

        // Assert the multi error scenario
        List<BulkCorporateOnboardingWrappers.ErrorMessage> multipleMessages = BulkOnboardingReadinessCheckService.runReadinessChecksAndGetErrors(storeWithMultipleErrors, mockWrapper);
        System.assert(multipleMessages.size() > 1, 'There should be several Readiness Check validations for this Store.');
    }

    @IsTest
    static void testWhenRunningPhoneValidationsThenReturnErrorsIfNeeded() {
        Account testPhoneRecordNoError = new Account(Phone = '15553334444');
        String shouldBeNull = BulkOnboardingReadinessCheckService.runPhoneValidation(
            testPhoneRecordNoError,
            'Phone'
        );
        System.assertEquals(
            null,
            shouldBeNull,
            'The Phone should not throw an error when it is valid'
        );
    }

    private static void assertReadinessErrorForRecord(SObject recordToCheck, String validationMethod) {
        List<BulkCorporateOnboardingWrappers.ErrorMessage> errorMessagesReceived = BulkOnboardingReadinessCheckService.runReadinessChecksAndGetErrors(recordToCheck, mockWrapper);

        String errorMessageToCheck = getErrorMessageFromRuleMethod(validationMethod);
        System.assert(verifyValidation(errorMessagesReceived, errorMessageToCheck), READINESS_VALIDATION_MISSING_ERROR);
    }

    /**
     * @description Returns `true` if an error message array contains a specific error message
     * @param errorMessages
     * @param errorToCheck
     * @return Boolean
    **/
    private static Boolean verifyValidation(List<BulkCorporateOnboardingWrappers.ErrorMessage> errorMessages, String errorToCheck) {
        if(errorMessages == null || errorMessages.isEmpty()) {
            return String.isBlank(errorToCheck); // If there are no errors AND no message, then return true
        }

        for(BulkCorporateOnboardingWrappers.ErrorMessage thisMsgObj : errorMessages) {
            if(thisMsgObj.fullMessage.containsIgnoreCase(errorToCheck)) {
                return true;
            }
        }

        return false;
    }

    /**
     * @description Takes a method name and returns the Error Message from its Readiness Check record
     * @param methodName
     * @return String
    **/
    private static String getErrorMessageFromRuleMethod(String methodName) {
        return readinessChecksByNames.get(methodName).Error_Message__c;
    }
}