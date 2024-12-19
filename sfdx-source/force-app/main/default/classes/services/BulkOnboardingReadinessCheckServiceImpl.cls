/**
 * @author BizApps
 * @date 4 January 2024
 * @description Service implementation for Automated New Store Onboarding, specifically around validations and readiness checks.
**/
public with sharing class BulkOnboardingReadinessCheckServiceImpl implements IBulkOnboardingReadinessCheckService {
    // CONSTANTS - Organized alphabetically for readability
    private static final String ACCOUNT_OBJECT = 'Account';
    private static final String ACTIVATE_CENTRALLY_NO = 'No';
    private static final String MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER = 'Account Owner';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String MENU_UI_TYPE_RESTAURANT = 'Restaurant';
    private static final String ORDER_PROTOCOL_POS = 'POS';
    private static final String PHONE_FIELD_API_NAME = 'Phone';
    private static final String PRIMARY_VERTICAL_FLORAL = 'Floral';
    private static final String ROW = 'Row ';

    private static final Set<String> FIELDS_TO_SKIP_NULL_VALUE_READINESS_CHECK = new Set<String>{PHONE_FIELD_API_NAME};

    private static final Map<String, MethodTypes> METHODNAMETOMETHODTYPES = new Map<String, MethodTypes>{
        'validateActivateCentrally' => MethodTypes.ACTIVATECENTRALLY,
        'validateMinimumPrepTime' => MethodTypes.MINPREPTIME,
        'validateNullFieldValuesOnStore' => MethodTypes.NULLVALUES,
        'validatePOSIntegrationFields' => MethodTypes.POSINTEGRATION,
        'validateShoppingProtocolMandatoryOnRetailMenuUIType' => MethodTypes.SHOPPINGPROTOCOLONRETAILMENUUITYPE,
        'validateShoppingProtocolBlankOnRxMenuUIType' => MethodTypes.SHOPPINGPROTOCOLONRXMENUUITYPE
    };

    // ENUMS
    private enum MethodTypes {
        ACTIVATECENTRALLY,
        MINPREPTIME,
        NULLVALUES,
        POSINTEGRATION,
        SHOPPINGPROTOCOLONRETAILMENUUITYPE,
        SHOPPINGPROTOCOLONRXMENUUITYPE
    }

    // MEMBER VARIABLES
    private Map<String, String> objectNameToServiceClassName = new Map<String, String>();
    private Map<String, List<Store_Readiness_Validation_Rule__mdt>> objectNameToValidationRules = new  Map<String, List<Store_Readiness_Validation_Rule__mdt>>();
    private Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
    private Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();

    /**
     * @description Constructor / initialization logic
    **/
    public BulkOnboardingReadinessCheckServiceImpl() {
        for(Country_Attributes_Mapping__mdt countryAttribute : CountryAttributesMappingSelector.newInstance().getAllValues()) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        setPropertiesFromReadinessChecks();
    }

    /**
     * @description Takes a record and phone number and applies standard phone validation logic
     * @param newRecord - The record on which to perform validation
     * @param columnName - The name of the `Phone` column to validate
     * @return String
     **/
    public String runPhoneValidation(SObject newRecord, String columnName) {
        String validationMessage = validatePhone(newRecord);

        if (validationMessage == null) {
            return null;
        }

        return columnName + ' ' + validationMessage;
    }

    /**
     * @description Takes a record and phone number and applies standard phone validation logic
     * @param newRecord - The record on which to perform validation
     * @return String
    **/
    private String validatePhone(SObject newRecord) {
        return PhoneValidation.validationOnPhoneFields(
            newRecord,
            Account.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            null
        );
    }

    /**
     * @description Determines if the inputted Parent Account ID is of a valid value
     * @param parentIdValue - The ID value in the CSV
     * @param businessAccountId - The actual valid Parent Account related to the Contract
     * @param parentColumnName - The name of the Parent Account ID column in the CSV header
     * @param rowNumber - The row number for the Store we are evaluating
     * @return String
    **/
    public String validateParentAccount(String parentIdValue, String businessAccountId, String parentColumnName, Integer rowNumber) {
        if (parentIdValue != null && businessAccountId != parentIdValue) {
            return ROW + rowNumber + ': ' + parentColumnName + ' is not in the Account Hierarchy for this Contract.';
        }

        return null;
    }

    /**
     * @description Runs readiness checks for a single Store and returns errors, if any
     * @param newRecord - SObject to validate
     * @param wrapperObj - StoreInfo properties
     * @return List<BulkCorporateOnboardingWrappers.ErrorMessage>
     **/
    public List<BulkCorporateOnboardingWrappers.ErrorMessage> runReadinessChecksAndGetErrors(
        SObject newRecord,
        BulkCorporateOnboardingWrappers.StoreInfo wrapperObj
    ) {
        List<BulkCorporateOnboardingWrappers.ErrorMessage> errorsForStore = new List<BulkCorporateOnboardingWrappers.ErrorMessage>();

        for (
            Store_Readiness_Validation_Rule__mdt eachStoreReadinessValidationRule : objectNameToValidationRules.get(
                ACCOUNT_OBJECT
            )
        ) {
            String readinessCheckMessage;

            switch on
                METHODNAMETOMETHODTYPES.get(
                    eachStoreReadinessValidationRule.Service_Method_Name__c
                ) {
                when ACTIVATECENTRALLY {
                    readinessCheckMessage = validateActivateCentrally(
                        eachStoreReadinessValidationRule,
                        newRecord
                    );
                }
                when MINPREPTIME {
                    readinessCheckMessage = validateMinimumPrepTime(
                        eachStoreReadinessValidationRule,
                        newRecord
                    );
                }
                when NULLVALUES {
                    readinessCheckMessage = validateNullFieldValuesOnAccount(
                        eachStoreReadinessValidationRule,
                        newRecord
                    );
                }
                when POSINTEGRATION {
                    readinessCheckMessage = validatePOSIntegrationFields(
                        eachStoreReadinessValidationRule,
                        newRecord
                    );
                }
                when SHOPPINGPROTOCOLONRETAILMENUUITYPE {
                    readinessCheckMessage = validateShoppingProtocolMandatoryOnRetailMenuUIType(
                        eachStoreReadinessValidationRule,
                        newRecord
                    );
                }
                when SHOPPINGPROTOCOLONRXMENUUITYPE {
                    readinessCheckMessage = validateShoppingProtocolBlankOnRxMenuUIType(
                        eachStoreReadinessValidationRule,
                        newRecord
                    );
                }
            }

            if (readinessCheckMessage != null) {
                errorsForStore.add(
                    new BulkCorporateOnboardingWrappers.ErrorMessage(
                        wrapperObj.rowNumber,
                        readinessCheckMessage,
                        false
                    )
                );
            }
        }

        return errorsForStore;
    }

    /**
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts.
     * @param storeReadinessValidationRule
     * @param newNewRecord
     * @return String
     */
    private String validateActivateCentrally(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        SObject newNewRecord
    ) {
        Account newStoreAccount = (Account)newNewRecord;
        if (
            (newStoreAccount.Menu_to_be_Completed_By__c == MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER &&
            newStoreAccount.Activated_Centrally_AC__c != ACTIVATE_CENTRALLY_NO)
        ) {
            return storeReadinessValidationRule.Error_Message__c;
        }
        return null;
    }

    /**
     * @description It is used to perform validation on 'Minimum prep Time' field
     * of the store Accounts.
     * @param storeReadinessValidationRule
     * @param newNewRecord
     * @return String
     */
    private String validateMinimumPrepTime(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        SObject newNewRecord
    ) {
        Account newStoreAccount = (Account)newNewRecord;
        if (
            newStoreAccount.Primary_Vertical__c == PRIMARY_VERTICAL_FLORAL &&
            isFieldValueNull(newStoreAccount, storeReadinessValidationRule.Field_Name__c)
        ) {
            return storeReadinessValidationRule.Error_Message__c;
        }
        return null;
    }

    /**
     * @description It is used to perform validation to check whether the field configured
     * in the passed custom metadata is null on the store Accounts.
     * @param storeReadinessValidationRule
     * @param newNewRecord
     * @return String
     */
    private String validateNullFieldValuesOnAccount(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        SObject newNewRecord
    ) {
        Account newStoreAccount = (Account)newNewRecord;
        if (isFieldValueNull(newStoreAccount, storeReadinessValidationRule.Field_Name__c) &&
            !FIELDS_TO_SKIP_NULL_VALUE_READINESS_CHECK.contains(storeReadinessValidationRule.Field_Name__c)) {
            return storeReadinessValidationRule.Error_Message__c;
        }
        return null;
    }

    /**
     * @description It is used to perform validation on POS Integration Id and Integration Type
     * fields of the store Accounts.
     * @param storeReadinessValidationRule
     * @param newNewRecord
     * @return String
     */
    private String validatePOSIntegrationFields(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        SObject newNewRecord
    ) {
        Account newStoreAccount = (Account)newNewRecord;
        if (
            String.isNotBlank(newStoreAccount.Order_Protocol__c) &&
            String.valueOf(newStoreAccount.Order_Protocol__c)
                .contains(ORDER_PROTOCOL_POS) &&
            isFieldValueNull(newStoreAccount, storeReadinessValidationRule.Field_Name__c)
        ) {
            return storeReadinessValidationRule.Error_Message__c;
        }
        return null;
    }

    /**
     * @description It is used to validate that 'Shopping Protocol' field is populated
     * on the store Accounts.
     * @param storeReadinessValidationRule
     * @param newNewRecord
     * @return String
     */
    private String validateShoppingProtocolMandatoryOnRetailMenuUIType(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        SObject newNewRecord
    ) {
        Account newStoreAccount = (Account)newNewRecord;
        if (
            newStoreAccount.Menu_UI_Type__c == MENU_UI_TYPE_RETAIL &&
            isFieldValueNull(newStoreAccount, storeReadinessValidationRule.Field_Name__c)
        ) {
            return storeReadinessValidationRule.Error_Message__c;
        }
        return null;
    }

    /**
     * @description It is used to validate that 'Shopping Protocol' field is blank
     * on the store Accounts.
     * @param storeReadinessValidationRule
     * @param newNewRecord
     * @return String
     */
    private String validateShoppingProtocolBlankOnRxMenuUIType(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        SObject newNewRecord
    ) {
        Account newStoreAccount = (Account)newNewRecord;
        if (
            (newStoreAccount.Menu_UI_Type__c == MENU_UI_TYPE_RESTAURANT) &&
            !isFieldValueNull(newStoreAccount, storeReadinessValidationRule.Field_Name__c)
        ) {
            return storeReadinessValidationRule.Error_Message__c;
        }
        return null;
    }

    /**
     * @description It checks whether the passed field value is null on the passed sObjectInstance.
     * @param sObjectInstance
     * @param fieldName
     * @return Boolean
     */
    private Boolean isFieldValueNull(SObject sObjectInstance, String fieldName) {
        return sObjectInstance.get(fieldName) == null;
    }

    /**
     * @description Prepends row details to a raw validation error message
     * @param rowNumber - The number of the store
     * @param validationMessage - The possible validation error that might have been returned
     * @return String
    **/
    private String buildValidationMessageForRow(Integer rowNumber, String validationMessage) {
        if(String.isNotBlank(validationMessage)) {
            validationMessage = ROW + rowNumber + ': ' + validationMessage;
        }

        return validationMessage;
    }

    /**
     * @description Populates instance Maps from valid active Readiness Checks
    **/
    private void setPropertiesFromReadinessChecks() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessChecks = StoreReadinessValidationRulesSelector.newInstance().selectAllValidReadinessValidationRules();

        for(Store_Readiness_Validation_Rule__mdt thisReadinessCheck : storeReadinessChecks) {
            String objectName = thisReadinessCheck.Object_Name__c;

            if(!objectNameToServiceClassName.containsKey(objectName)) {
                objectNameToServiceClassName.put(objectName, thisReadinessCheck.Service_Class_Name__c);
            }

            if(!objectNameToValidationRules.containsKey(objectName)) {
                objectNameToValidationRules.put(objectName, new List<Store_Readiness_Validation_Rule__mdt>());
            }

            objectNameToValidationRules.get(objectName).add(thisReadinessCheck);
        }
    }
}