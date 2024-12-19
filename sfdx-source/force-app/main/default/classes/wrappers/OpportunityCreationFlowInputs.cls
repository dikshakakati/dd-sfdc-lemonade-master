/**
 * @author Deloitte
 * @date 06/04/2024
 * @description It is used for passing the inputs from Opportity Creation flow.
 */
public class OpportunityCreationFlowInputs {
    @InvocableVariable
    public List<Lever__c> levers;
    @InvocableVariable
    public Opportunity opportunityRecord;
    @InvocableVariable
    public Id accountPlanId;
}