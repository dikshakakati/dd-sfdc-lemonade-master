/**
 * @author Deloitte
 * @date 08/25/2022
 * @description Service class for Parent Work Orders creation related logic.
 */
public inherited sharing class ParentWorkOrdersCreationService {
    /**
     * @description It is used to create parent Work Orders based on Nintex use case
     * from the passed Opportunities.
     * @JIRA# LEM-2348
     * @param opportunities
     */
    public static void createParentWorkOrdersByNintexUseCases(List<Opportunity> opportunities) {
        service().createParentWorkOrdersByNintexUseCases(opportunities);
    }

    /**
     * @description It is used to create parent Work Orders based on Rate change request.
     * @JIRA# LEM-12932
     * @param rcrList
     */
    public static void createParentWorkOrdersByRateChangeRequest(
        List<Rate_Change_Request__c> rcrList
    ) {
        service().createParentWorkOrdersByRateChangeRequest(rcrList);
    }


    /**
     * @description It is used to create parent Work Orders from Work Order Generators
     * @JIRA# LEM-15362
     * @param interfaceTransactions
     */
    public static void createParentWorkOrder(List<Interface_Transaction__c> interfaceTransactions) {
        service().createParentWorkOrder(interfaceTransactions);
    }

    /**
     * @description It creates instance of ParentWorkOrdersCreationServiceImpl class.
     * @return IParentWorkOrdersCreationService - return instance of ParentWorkOrdersCreationServiceImpl
     */
    private static IParentWorkOrdersCreationService service() {
        return (IParentWorkOrdersCreationService) Application.SERVICE.newInstance(
            IParentWorkOrdersCreationService.class
        );
    }
}