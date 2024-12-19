/**
 * @author Deloitte
 * @date 05/02/2024
 * @description Trigger Handler for Event.
 */
public class EventsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method
     * @param sObjectList - Event Record List
     */
    public EventsHandler(List<Event> sObjectList) {
        super(sObjectList);
        setContextBypass(Event.SObjectType, EventsHandler.class);
    }
    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjects - List of SObjects
         * @return EventsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new EventsHandler(sObjects);
        }
    }
    /**
     * @description It is called to perform after insert processing.
     */
    public override void onAfterInsert() {
        Events.newInstance(this.records).updateSDRTouchOnOpportunity();
        Events.newInstance(this.records).updateMeetingSetOnLeadAndOpportunity();
        Events.newInstance(this.records).updateFirstAndLastQualifiedActivityOnLeadAndOpportunity();
    }
    /**
     * @description It is called to perform after update processing.
     * @param existing
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        List<Event> changedEvents = new List<Event>(
            (List<Event>) getChangedRecords(new Set<SObjectField>{ Event.Event_Status__c })
        );
        Events.newInstance(changedEvents).updateSDRTouchOnOpportunity();
        Events.newInstance(changedEvents).updateSDRAssistedFieldOnOpportunity();
        Events.newInstance(changedEvents).updateLastMeetingRanOnLeadAndOpportunity();
        List<Event> changedStartDateEvents = new List<Event>(
            (List<Event>) getChangedRecords(new Set<SObjectField>{ Event.StartDateTime })
        );
        Events.newInstance(changedStartDateEvents)
            .updateMeetingSetOnLeadAndOpportunityOnEventStartDateUpdate();
    }

    /**
     * @description It is called to perform after delete processing.
     */
    public override void onAfterDelete() {
        Events.newInstance(existingRecords.values())
            .updateMeetingSetOnLeadAndOpportunityOnEventStartDateUpdate();
    }
}