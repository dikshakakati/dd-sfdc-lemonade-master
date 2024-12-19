/**
 * @author DoorDash
 * @date 07/21/2022
 * @description OpportunityContactRole Object Trigger Handler
 */
public with sharing class OpportunityContactRoleHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor to instantiate a List of OpportunityContactRole
     * @param sObjectList
     */
    public OpportunityContactRoleHandler(List<OpportunityContactRole> sObjectList) {
        super(sObjectList);
        setContextBypass(OpportunityContactRole.SObjectType, OpportunityContactRoleHandler.class);
    }
    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        List<OpportunityContactRole> primaryChangedContactRoles = new List<OpportunityContactRole>(
            (List<OpportunityContactRole>) getChangedRecords(
                new Set<SObjectField>{ OpportunityContactRole.IsPrimary }
            )
        );
        OpportunityContactRoles.newInstance(oppContactRolesWithUpdatedRole())
            .populateQuoteOnOpportunityContactRole();
        OpportunityContactRoles.newInstance(primaryChangedContactRoles)
            .populateDateWhenOpportunityContactRoleMarkedPrimary(
                (Map<Id, OpportunityContactRole>) existing
            );
    }

    /**
     * @description Called to perform before insert processing
     */
    public override void onBeforeInsert() {
        OpportunityContactRoles.newInstance(this.records).populateQuoteOnOpportunityContactRole();
        OpportunityContactRoles.newInstance(this.records)
            .populateFieldsWhenOpportunityContactRoleCreated();
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        OpportunityContactRoleService.updateRelatedQuotesContractSignatoryExists(this.records);
        OpportunityContactRoles.newInstance(this.records).updatePrimaryContactOnOpportunities();
    }

    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        OpportunityContactRoleService.updateRelatedQuotesContractSignatoryExists(
            oppContactRolesWithUpdatedRole()
        );
        OpportunityContactRoles.newInstance(getOpportunityContactRolesWithChangedIsPrimary())
            .updatePrimaryContactOnOpportunities();
    }

    /**
     * @description Called to perform after delete processing
     */
    public override void onAfterDelete() {
        OpportunityContactRoleService.updateRelatedQuotesContractSignatoryExists(this.records);
    }
    /**
     * @description this method used to get changed records.
     * @return List<OpportunityContactRole>
     */
    private List<OpportunityContactRole> oppContactRolesWithUpdatedRole() {
        return new List<OpportunityContactRole>(
            (List<OpportunityContactRole>) getChangedRecords(
                new Set<SObjectField>{ OpportunityContactRole.Role }
            )
        );
    }
    /**
     * @description It is used to retrieve a collection of Opportunity Contact Roles with updated IsPrimary status.
     * @return List<OpportunityContactRole>
     */
    private List<OpportunityContactRole> getOpportunityContactRolesWithChangedIsPrimary() {
        return new List<OpportunityContactRole>(
            (List<OpportunityContactRole>) getChangedRecords(
                new Set<SObjectField>{ OpportunityContactRole.IsPrimary }
            )
        );
    }

    /**
     * @description Constructor Class which implements fflib_SObjectDomain.IConstructable class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjectList
         * @return OpportunityContactRoleHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OpportunityContactRoleHandler(sObjectList);
        }
    }
}