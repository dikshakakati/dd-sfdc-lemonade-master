/**
 * @author Deloitte
 * @date 06/16/2022
 * @description Interface to add Opportunity domain class methods
 */
public interface IOpportunityChangeEvents extends fflib_ISObjects {
    /**
     * @description It is used to collect Opportunities on Nintex form submission
     * for parent Work Order creation.
     */
    void createParentWorkOrderOnNintexFormSubmission();

    /**
     * @description This method used to check Update Events to AccountId on Opportunity and delete
     * child Opportunity Account Relationship records on successful reparenting.
     */
    void deleteRelatedOpportunityAccountRelationshipsOnOpportunityReparenting();
}