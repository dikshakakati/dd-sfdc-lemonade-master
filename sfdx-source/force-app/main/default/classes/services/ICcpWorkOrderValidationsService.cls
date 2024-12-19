/**
 * @author Deloitte
 * @date 31/12/2024
 * @description Interface of service class for Brand Association related logic.
 */
public interface ICcpWorkOrderValidationsService {
    /**
     * @description It performs validations on the passed
     * according to the rules configured in the custom metadata.
     * @JIRA# LEM-1684
     * @param subscriptionPackageList
     * @param workOrderTypeAndSubTypesMap
     * @param isBusinessAccount
     * @param booleanWrapper
     * @return string
     */
    String validateWorkOrders(
        List<SBQQ__Subscription__c> subscriptionPackageList,
        Map<String, String> workOrderTypeAndSubTypesMap,
        Boolean isBusinessAccount,
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper
    );
}