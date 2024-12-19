/**
 * @author Deloitte
 * @date 2024-04-26
 * @description Interface to add domain class methods of Mx Tag Association Object
 */
public interface IMxTagAssociations extends fflib_ISObjects {
    /**
     * @description Assign Opportunity lookup on Mx Tag Association Insert
     */
    void assignOpportunityLookUpOnInsertOrUpdateWhenAccountLookupIsPresent();

    /**
     * @description update Opportunity lookup on Mx Tag Association update
     * @param existingRecords
     */
    void updateOpportunityLookUpOnMxTagAssociationUpdate(Map<Id, SObject> existingRecords);

    /**
     * @description update Opportunity lookup on Mx Tag Association Delete
     */
    void updateOpportunityLookUpOnMxTagAssociationDelete();

    /**
     * @description create Mx Tag Association with the same attributes against that store’s Parent Account
     */
    void createMxTagAssociationsOnParentAccount();

    /**
     * @description It updates Start Date and End Date according to Mx Tag Association Status value being 'Active' or 'Inactive'.
     */
    void updateStartAndEndDate();

    /**
     * @description It is used to get 'Active' Mx Tag Associations
     * by the passed Business Account Ids.
     * @param businessAccountIds
     * @return Map<Id, Set<String>>
     */
    Map<Id, Set<String>> getActiveMxTagAssociationsByBusinessAccountIds(Set<Id> businessAccountIds);
}