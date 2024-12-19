/**
 * @author Deloitte
 * @date 04-26-2024
 * @description Mx_Tag_Association__c Object Trigger Handler
 */
public class MxTagAssociationsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method
     * @param sObjectList - Mx_Tag_Association__c Record List
     */
    public MxTagAssociationsHandler(List<Mx_Tag_Association__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Mx_Tag_Association__c.SObjectType, MxTagAssociationsHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return MxTagAssociationsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new MxTagAssociationsHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform before insert processing
     */
    public override void onBeforeInsert() {
        MxTagAssociations.newInstance(this.records).updateStartAndEndDate();
    }

    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        MxTagAssociations.newInstance(
                new List<Mx_Tag_Association__c>(
                    (List<Mx_Tag_Association__c>) getChangedRecords(
                        new Set<SObjectField>{ Mx_Tag_Association__c.MxTagAssociation_Status__c }
                    )
                )
            )
            .updateStartAndEndDate();
    }

    /**
     * @description Called to perform after insert processing
     */

    public override void onAfterInsert() {
        MxTagAssociations.newInstance(this.records)
            .assignOpportunityLookUpOnInsertOrUpdateWhenAccountLookupIsPresent();
        MxTagAssociations.newInstance(this.records).createMxTagAssociationsOnParentAccount();
    }
    /**
     * @description Called to perform on after update processing
     * @param existingRecords - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        MxTagAssociations.newInstance(this.records)
            .updateOpportunityLookUpOnMxTagAssociationUpdate(existingRecords);
        MxTagAssociations.newInstance(this.records)
            .assignOpportunityLookUpOnInsertOrUpdateWhenAccountLookupIsPresent();
    }

    /**
     * @description Called to perform on after delete processing
     */
    public override void onAfterDelete() {
        MxTagAssociations.newInstance(existingRecords.values())
            .updateOpportunityLookUpOnMxTagAssociationDelete();
        OpportunitiesService.concatenateMxTagsOnSObjects(existingRecords.values());
    }
}