/**
 * @author Deloitte
 * @date 06/16/2022
 * @description Opportunity Change Event Object Trigger Handler
 */
public class OpportunityChangeEventsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor to instantiate List of Opportunity Change Events
     * @param sObjectList - Opportunity Change Event Record List
     */
    public OpportunityChangeEventsHandler(List<OpportunityChangeEvent> sObjectList) {
        super(sObjectList);
        setContextBypass(OpportunityChangeEvent.SobjectType, OpportunityChangeEventsHandler.class);
    }

    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onAfterInsert() {
        OpportunityChangeEvents.newInstance((List<OpportunityChangeEvent>) getRecords())
            .createParentWorkOrderOnNintexFormSubmission();
        OpportunityChangeEvents.newInstance((List<OpportunityChangeEvent>) getRecords())
            .deleteRelatedOpportunityAccountRelationshipsOnOpportunityReparenting();
    }

    /**
     * @description Constructor Class implements fflib_SObjectDomain.IConstructable class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjectList
         * @return OpportunityChangeEventsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OpportunityChangeEventsHandler(sObjectList);
        }
    }
}