/**
 * @author BizApps
 * @date 8 January 2024
 * @description Interface of service class for BulkOnboardingReadinessCheckService related logic.
**/
public interface IBulkOnboardingReadinessCheckService {

    /**
     * @description Takes a record and phone number and applies standard phone validation logic
     * @param newRecord - The record on which to perform validation
     * @param columnName - The name of the `Phone` column to validate
     * @return String
     **/
    String runPhoneValidation(SObject newRecord, String columnName);

    /**
     * @description Determines if the inputted Parent Account ID is of a valid value
     * @param parentIdValue - The ID value in the CSV
     * @param businessAccountId - The actual valid Parent Account related to the Contract
     * @param parentColumnName - The name of the Parent Account ID column in the CSV header
     * @param rowNumber - The row number for the Store we are evaluating
     * @return String
    **/
    String validateParentAccount(String parentIdValue, String businessAccountId, String parentColumnName, Integer rowNumber);

    /**
     * @description Runs readiness checks for a single Store and returns errors, if any
     * @param newRecord - SObject to validate
     * @param wrapperObj - StoreInfo properties
     * @return List<BulkCorporateOnboardingWrappers.ErrorMessage>
     **/
    List<BulkCorporateOnboardingWrappers.ErrorMessage> runReadinessChecksAndGetErrors(
        SObject newRecord,
        BulkCorporateOnboardingWrappers.StoreInfo wrapperObj
    );
}