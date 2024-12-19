/**
 * @author DoorDash
 * @date 07/21/2022
 * @description Interface to add OpportunityContactRoles domain class methods.
 */
public interface IOpportunityContactRoles extends fflib_ISObjects {
    /**
     * @description It is used to populate 'Contact Role Added Date' to current date
     * when Opportunity Contact Role is created.
     */
    void populateFieldsWhenOpportunityContactRoleCreated();

    /**
     * @description It is used to populate 'Primary Contact Confirmed Date' to current date
     * when Opportunity Contact Role is marked as Primary.
     * @param oldOpportunityContactRoles
     */
    void populateDateWhenOpportunityContactRoleMarkedPrimary(
        Map<Id, OpportunityContactRole> oldOpportunityContactRoles
    );

    /**
     * @description Populate Quote on Opportunity Contact Role.
     */
    void populateQuoteOnOpportunityContactRole();

    /**
     * @description It is used to update the Primary Contact on Opportunity.
     */
    void updatePrimaryContactOnOpportunities();
}