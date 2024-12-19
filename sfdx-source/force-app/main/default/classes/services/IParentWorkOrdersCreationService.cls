/**
 * @author Deloitte
 * @date 08/25/2022
 * @description Interface of service class for Parent Work Orders creation related logic.
 */
public interface IParentWorkOrdersCreationService {
    /**
     * @description It is used to create parent Work Orders based on Nintex use case
     * from the passed Opportunities.
     * @param opportunities
     */
    void createParentWorkOrdersByNintexUseCases(List<Opportunity> opportunities);

    /**
     * @description It is used to create parent Work Orders based on Rate change request.
     * @JIRA# LEM-12932
     * @param rcrList
     */
    void createParentWorkOrdersByRateChangeRequest(List<Rate_Change_Request__c> rcrList);

    /**
     * @description It is used to create parent Work Orders from Work Order Generators
     * @JIRA# LEM-15362
     * @param interfaceTransactions
     */
    void createParentWorkOrder(List<Interface_Transaction__c> interfaceTransactions);
}