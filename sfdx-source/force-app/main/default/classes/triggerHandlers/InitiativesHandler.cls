/**
 * @description Handler to perform all trigger based actions on Initiatives
 *              and other related records
 * @author Deloitte
 * @date 27/04/2022
 */
public class InitiativesHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor to instantiate a List of Initiatives
     * @param sObjectList
     */
    public InitiativesHandler(List<Initiative__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Initiative__c.SObjectType, InitiativesHandler.class);
    }

    /**
     * @description Constructor Class which implements fflib_SObjectDomain.IConstructable class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjectList
         * @return InitiativesHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new InitiativesHandler(sObjectList);
        }
    }

    /**
     * @description Overriding method to perform default operations on Insertion
     */
    public override void onApplyDefaults() {
        Initiatives.newInstance(getInitiatives()).populateUltimateParentAccount();
    }

    /**
     * @description It is called for after update trigger processing.
     * @JIRA LEM-14728
     * @param existingRecords
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        Initiatives.newInstance(getInitiativesWithUpdatedStatus())
            .createTaskOnCompleteMxTouchpoints();
    }

    /**
     * @description It is called for after insert trigger processing.
     */
    public override void onAfterInsert() {
        Initiatives.newInstance(this.records).createTaskOnCompleteMxTouchpoints();
    }

    /**
     * @description Before Update Trigger processing
     * @param existingRecords - The map of old Initiative records
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        Initiatives.newInstance(getInitiativesWithUpdatedAccountRelationships())
            .populateUltimateParentAccount();
        Initiatives.newInstance(
                new List<Initiative__c>(
                    (List<Initiative__c>) getChangedRecords(
                        new Set<SObjectField>{ Initiative__c.Status__c }
                    )
                )
            )
            .addErrorOnCompleteMxTouchpointsWithoutStakeholders();
    }

    /**
     * @description Fetch All Records present in the Trigger Context
     * @return List<Initiative__c>
     */
    private List<Initiative__c> getInitiatives() {
        return (List<Initiative__c>) getRecords();
    }

    /**
     * @description This method is used to call the domain method for
     *              autopopulating blank Account_Name__c field on
     *              Initiative__c records.
     * @return List<Initiative__c>
     */
    private List<Initiative__c> getInitiativesWithUpdatedAccountRelationships() {
        return new List<Initiative__c>(
            (List<Initiative__c>) getChangedRecords(
                new Set<Schema.SObjectField>{
                    Initiative__c.Account__c,
                    Initiative__c.Is_Parent_Account_Merged__c
                }
            )
        );
    }

    /**
     * @description This method is used to get all the Initiatives with updated Status.
     * @return List<Initiative__c>
     */
    private List<Initiative__c> getInitiativesWithUpdatedStatus() {
        return new List<Initiative__c>(
            (List<Initiative__c>) getChangedRecords(
                new Set<SObjectField>{ Initiative__c.Status__c }
            )
        );
    }
}