/**
 * @author Deloitte
 * @date 05/05/2022
 * @description Interface for service class for Decision Maker population related logic.
 */
public interface IDecisionMakerCalculationService {
    /**
     * @description To fetch unique Decision Makers when WorkOrders are passed.
     * @param workorders
     * @return Map<Id,List<Id>>
     */
    Map<Id, List<Id>> getDecisionMakers(List<WorkOrder> workorders);

    /**
     * @description It is used to get 'Opportunity Contact Role' and 'Account Contact Relationship' Ids using the passed Work Orders.
     * @JIRA# LEM-5367
     * @param workorders
     * @return Map<Id, List<Id>>
     */
    Map<Id, List<Id>> getOCRAndACRIds(List<WorkOrder> workorders);
}