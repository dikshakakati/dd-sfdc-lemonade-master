/**
 * @author BizApps
 * @date 4 January 2024
 * @description Service implementation for Automated New Store Onboarding, specifically around validations and readiness checks.
**/
public with sharing class BulkOnboardingReadinessCheckService {
    /**
     * @description Takes a record and phone number and applies standard phone validation logic
     * @param newRecord - The record on which to perform validation
     * @param columnName - The name of the `Phone` column to validate
     * @return String
     **/
    public static String runPhoneValidation(SObject newRecord, String columnName) {
        return service().runPhoneValidation(newRecord, columnName);
    }

    /**
     * @description Determines if the inputted Parent Account ID is of a valid value
     * @param parentIdValue - The ID value in the CSV
     * @param businessAccountId - The actual valid Parent Account related to the Contract
     * @param parentColumnName - The name of the Parent Account ID column in the CSV header
     * @param rowNumber - The row number for the Store we are evaluating
     * @return String
    **/
    public static String validateParentAccount(String parentIdValue, String businessAccountId, String parentColumnName, Integer rowNumber) {
        return service().validateParentAccount(parentIdValue, businessAccountId, parentColumnName, rowNumber);
    }

    /**
     * @description Runs readiness checks for a single Store and returns errors, if any
     * @param newRecord - SObject to validate
     * @param wrapperObj - StoreInfo properties
     * @return List<BulkCorporateOnboardingWrappers.ErrorMessage>
     **/
    public static List<BulkCorporateOnboardingWrappers.ErrorMessage> runReadinessChecksAndGetErrors(
        SObject newRecord,
        BulkCorporateOnboardingWrappers.StoreInfo wrapperObj
    ) {
        return service().runReadinessChecksAndGetErrors(newRecord, wrapperObj);
    }

    /**
     * @description Creates instance of BulkCorporateReadinessCheckServiceImpl class.
     * @return IBulkOnboardingReadinessCheckService - return instance of BulkCorporateReadinessCheckService
    **/
    private static IBulkOnboardingReadinessCheckService service() {
        return (IBulkOnboardingReadinessCheckService) Application.Service.newInstance(IBulkOnboardingReadinessCheckService.class);
    }
}