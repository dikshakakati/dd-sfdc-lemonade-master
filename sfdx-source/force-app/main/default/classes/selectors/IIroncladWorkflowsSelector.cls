/**
 * @author Deloitte
 * @date 05/27/2024
 * @description Interface to add IroncladWorkflowsSelector class methods.
 */
public interface IIroncladWorkflowsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to fetch Quote fields from Ironclad Workflow record based on the passed
     * Opportunity Ids where Quote is 'Primary' and Quote's Status is 'Out for Signature'.
     * @param opportunityIds
     * @return List<ironclad__Ironclad_Workflow__c>
     */
    List<ironclad__Ironclad_Workflow__c> selectIroncladWorkflowsWithOutForSignaturePrimaryQuotesByOpportunityIds(
        Set<Id> opportunityIds
    );
}