/**
 * @author Deloitte
 * @date 30/05/2022
 * @description Service class for Decision Maker population related logic.
 */
public inherited sharing class DecisionMakerCalculationService {
    /**
     * @description To fetch unique Decision Makers when WorkOrders are passed.
     * @JIRA# LEM-1652
     * @param workOrders
     * @return Map<Id,List<Id>>
     */
    public static Map<Id, List<Id>> getDecisionMakers(List<WorkOrder> workOrders) {
        return service().getDecisionMakers(workOrders);
    }

    /**
     * @description It is used to get 'Opportunity Contact Role' and 'Account Contact Relationship' Ids using the passed Work Orders.
     * @JIRA# LEM-5367
     * @param workOrders
     * @return Map<Id, List<Id>>
     */
    public static Map<Id, List<Id>> getOCRAndACRIds(List<WorkOrder> workOrders) {
        return service().getOCRAndACRIds(workOrders);
    }

    /**
     * @description It creates instance of DecisionMakerCalculationServiceImpl class.
     * @return IDecisionMakerCalculationService - return instance of DecisionMakerCalculationServiceImpl
     */
    private static IDecisionMakerCalculationService service() {
        return (IDecisionMakerCalculationService) Application.Service.newInstance(
            IDecisionMakerCalculationService.class
        );
    }
}