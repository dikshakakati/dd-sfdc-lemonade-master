/**
 * @author Deloitte
 * @date 14/06/2022
 * @description Service class for CampaignMember related logic.
 */
public inherited sharing class CcpWorkOrderValidationsService {
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
    public String validateWorkOrders(
        List<SBQQ__Subscription__c> subscriptionPackageList,
        Map<String, String> workOrderTypeAndSubTypesMap,
        Boolean isBusinessAccount,
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper
    ) {
        return service()
            .validateWorkOrders(
                subscriptionPackageList,
                workOrderTypeAndSubTypesMap,
                isBusinessAccount,
                booleanWrapper
            );
    }

    /**
     * @description It creates an instance of CampaignMemberService class.
     * @return ICcpWorkOrderValidationsService - return instance of CampaignMembersServiceImpl
     */
    private static ICcpWorkOrderValidationsService service() {
        return (ICcpWorkOrderValidationsService) Application.SERVICE.newInstance(
            ICcpWorkOrderValidationsService.class
        );
    }
}