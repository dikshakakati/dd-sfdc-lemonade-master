/**
 * @author Deloitte
 * @date 04/24/2023
 * @description It is used for passing the inputs from
 * "Subflow - Internal MxS Communications By Account Team Members" flow to
 * "InternalMxSCommunicationsService" apex class.
 */
public class InternalMxSCommunicationsFlowInputs {
    @InvocableVariable
    public List<AccountTeamMember> accountTeamMembers;
    @InvocableVariable
    public String emailTemplateId;
    @InvocableVariable
    public List<Contact> existingContacts;
    @InvocableVariable
    public List<OpportunityTeamMember> opportunityTeamMembers;
    @InvocableVariable
    public String orgWideAddressId;
    @InvocableVariable
    public List<Id> recordOwnerIds;
    @InvocableVariable
    public String sObjectType;
    @InvocableVariable
    public List<User> userInstances;
    @InvocableVariable
    public WorkOrder workOrderInstance;
    @InvocableVariable
    public WorkStep workStepInstance;
    @InvocableVariable
    public Mx_Onboarding_Link__c mxOnboardingLinkInstance;
}