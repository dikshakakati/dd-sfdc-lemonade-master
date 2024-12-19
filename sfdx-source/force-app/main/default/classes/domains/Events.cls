/**
 * @author Deloitte
 * @date 05/02/2024
 * @description Domain Class for Event Object.
 */
public inherited sharing class Events extends fflib_SObjects implements IEvents {
    private static final String YES = 'Yes';
    private static final String EVENT_MISSED = 'Event Missed';
    private static final String EVENT_HELD = 'Event Held';
    private static final String UNVERIFIED = 'Unverified';
    private static final String LOG_UPDATE_SDR_ON_OPPORTUNITY = 'Update SDR Touch Required on Opportunity failed';
    private static final String LOG_UPDATE_MEETING_SET = 'Update Meeting Set failed';
    private static final String LOG_UPDATE_LAST_MEETING_RAN = 'Update Last Meeting Ran failed';
    private static final String LOG_UPDATE_FIRST_AND_LAST_ACTIVITY = 'Update First and Last Activity failed';
    private static final String LOG_DOMAIN = 'Events';
    private static final String EVENT_SUBJECT_MEETING = 'Meeting';
    private static final String LEAD_OBJECT_NAME = 'Lead';
    private static final String OPPORTUNITY_OBJECT_NAME = 'Opportunity';
    private static final String OPPORTUNITY_FIELD_MEETING_SET = 'Meeting_Set__c';
    private static final String OPPORTUNITY_FIELD_LAST_MEETING_RAN = 'Last_Meeting_Ran__c';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';

    private enum ObjectTypes {
        LEAD,
        OPPORTUNITY
    }
    private static final Map<String, ObjectTypes> OBJECT_NAME_TO_OBJECT_TYPES = new Map<String, ObjectTypes>{
        LEAD_OBJECT_NAME => ObjectTypes.LEAD,
        OPPORTUNITY_OBJECT_NAME => ObjectTypes.OPPORTUNITY
    };

    /**
     * @description This method is used to return the IEvents interface.
     * @param recordList
     * @return IEvents
     */
    public static IEvents newInstance(List<Event> recordList) {
        return (IEvents) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public Events(List<Event> sObjectList) {
        super(sObjectList, Schema.Event.SObjectType);
    }

    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description To create instance of Event domain class.
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description construct
         * @param objects List<Object>
         * @return instance of Event
         */
        public fflib_ISObjects construct(List<Object> objects) {
            if (Events.constructorMock != null) {
                return (fflib_ISObjects) Events.constructorMock.construct(objects);
            }
            return new Events((List<Event>) objects);
        }
    }

    /**
     * @description It is used to update meeting set date on related Lead and Opportunity when Event Start Date is updated
     * @JIRA# LEM-21484
     */
    public void updateMeetingSetOnLeadAndOpportunityOnEventStartDateUpdate() {
        Map<Id, DateTime> sObjectIdToMeetingSet = new Map<Id, DateTime>();
        Id sObjectId;
        for (Event event : (List<Event>) getRecords()) {
            if (event.WhatId != null) {
                sObjectId = event.WhatId;
            } else if (event.WhoId != null) {
                sObjectId = event.WhoId;
            } else {
                return;
            }
            sObjectIdToMeetingSet.put(sObjectId, event.StartDateTime);
        }
        if (sObjectIdToMeetingSet.isEmpty()) {
            return;
        }
        updateMeetingSetOnSObjectOnStartDateChange(sObjectIdToMeetingSet);
    }

    /**
     * @description It is used to fetch Leads and opportunities from the passed Object Ids
     * @JIRA# LEM-21484
     * @param sObjectIdToMeetingSet
     * @return List<SObject>
     */
    private List<SObject> getSobjects(Map<Id, DateTime> sObjectIdToMeetingSet) {
        List<SObject> sObjects = new List<SObject>();
        sObjects.addAll(
            (List<SObject>) LeadsSelector.newInstance().selectById(sObjectIdToMeetingSet.keySet())
        );
        for (
            Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                .selectById(sObjectIdToMeetingSet.keySet())
        ) {
            if (eachOpportunity.Account_Segment__c == ACCOUNT_SEGMENT_SMB) {
                sObjects.add((sObject) eachOpportunity);
            }
        }
        return sObjects;
    }

    /**
     * @description It is used to update meetingSet Field on Lead & Opportunity when Event Start Date is updated on Event
     * @JIRA# LEM-21484
     * @param sObjectIdToMeetingSet
     */
    private void updateMeetingSetOnSObjectOnStartDateChange(
        Map<Id, DateTime> sObjectIdToMeetingSet
    ) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        DateTime meetingSet;
        Map<Id, DateTime> sObjectToFutureMeetingDate = getsObjectWithFutureMeetingDate(
            sObjectIdToMeetingSet
        );

        List<SObject> sObjects = getSobjects(sObjectIdToMeetingSet);

        for (sObject eachSObject : sObjects) {
            meetingSet = sObjectToFutureMeetingDate.containsKey(eachSObject.Id)
                ? sObjectToFutureMeetingDate.get(eachSObject.Id)
                : null;
            eachSObject.put(OPPORTUNITY_FIELD_MEETING_SET, meetingSet);
            uow.registerDirty(eachSObject);
        }
        commitWork(uow);
    }

    /**
     * @description It is used to update meeting set date on related Lead for Events
     * which are inserted
     * @JIRA# LEM-21484
     */
    public void updateMeetingSetOnLeadAndOpportunity() {
        Map<Id, DateTime> sObjectIdToMeetingSet = new Map<Id, DateTime>();
        Id sObjectId;
        for (Event event : (List<Event>) getRecords()) {
            if (event.WhatId != null) {
                sObjectId = event.WhatId;
            } else if (event.WhoId != null) {
                sObjectId = event.WhoId;
            } else {
                return;
            }

            if (event.StartDateTime > System.now() && event.Event_Status__c != EVENT_HELD) {
                if (
                    (sObjectIdToMeetingSet.containsKey(sObjectId) &&
                    sObjectIdToMeetingSet.get(sObjectId) > event.StartDateTime) ||
                    !sObjectIdToMeetingSet.containsKey(sObjectId)
                ) {
                    // current record is closest so, replace the old one
                    sObjectIdToMeetingSet.put(sObjectId, event.StartDateTime);
                }
            }
        }
        updateMeetingSetOnSObject(sObjectIdToMeetingSet);
    }
    /**
     * @description Common method to update meetingSet Field on Lead & Opportunity
     * @JIRA# LEM-21484
     * @param sObjectIdToMeetingSet
     */
    private void updateMeetingSetOnSObject(Map<Id, DateTime> sObjectIdToMeetingSet) {
        if (sObjectIdToMeetingSet.isEmpty()) {
            return;
        }
        DateTime meetingSet;
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<SObject> sObjects = getSobjects(sObjectIdToMeetingSet);
        for (sObject eachSObject : sObjects) {
            if (
                eachSObject.get(OPPORTUNITY_FIELD_MEETING_SET) == null ||
                (DateTime) eachSObject.get(OPPORTUNITY_FIELD_MEETING_SET) >
                sObjectIdToMeetingSet.get(eachSObject.Id)
            ) {
                meetingSet = sObjectIdToMeetingSet.get(eachSObject.Id);
                eachSObject.put(OPPORTUNITY_FIELD_MEETING_SET, meetingSet);
                uow.registerDirty(eachSObject);
            }
        }
        commitWork(uow);
    }

    /**
     * @description It is used to update Last Meeting Ran date on related Lead for Event
     * which are updated
     * @JIRA# LEM-21484
     */
    public void updateLastMeetingRanOnLeadAndOpportunity() {
        Map<Id, DateTime> sObjectToLastMeetingRan = new Map<Id, DateTime>();
        for (Event event : (List<Event>) getRecords()) {
            if (event.Event_Status__c != EVENT_HELD) {
                return;
            }
            if (!String.isBlank(event.WhoId) && event.WhoId.getSObjectType() == Lead.SObjectType) {
                sObjectToLastMeetingRan.put(event.WhoId, event.EndDateTime);
            }
            if (
                !String.isBlank(event.whatId) &&
                event.whatId.getSObjectType() == Opportunity.SObjectType
            ) {
                sObjectToLastMeetingRan.put(event.whatId, event.EndDateTime);
            }
        }
        if (sObjectToLastMeetingRan.isEmpty()) {
            return;
        }
        updateLastMeetingRanOnSObject(sObjectToLastMeetingRan);
    }

    /**
     * @description to find future meeting Date on SObjects
     * @JIRA# LEM-21484
     * @param sObjectToLastMeetingRan
     * @return Map<Id, DateTime>
     */
    private Map<Id, DateTime> getsObjectWithFutureMeetingDate(
        Map<Id, DateTime> sObjectToLastMeetingRan
    ) {
        Map<Id, DateTime> sObjectToFutureMeetingDate = new Map<Id, DateTime>();
        Map<Id, List<DateTime>> sObjectToFutureMeetingDates = new Map<Id, List<DateTime>>();
        Id sObjectId;
        for (
            Event eachEvent : EventsSelector.newInstance()
                .selectByWhatIdAndWhoId(sObjectToLastMeetingRan.keySet())
        ) {
            if (eachEvent.WhatId != null) {
                sObjectId = eachEvent.WhatId;
            } else if (eachEvent.WhoId != null) {
                sObjectId = eachEvent.WhoId;
            }
            if (
                eachEvent.Event_Status__c != EVENT_HELD &&
                eachEvent.StartDateTime >= System.now()
            ) {
                if (sObjectToFutureMeetingDates.containsKey(sObjectId)) {
                    sObjectToFutureMeetingDates.get(sObjectId).add(eachEvent.StartDateTime);
                } else {
                    sObjectToFutureMeetingDates.put(
                        sObjectId,
                        new List<DateTime>{ eachEvent.StartDateTime }
                    );
                }
            }
        }
        for (Id eachSObjectId : sObjectToFutureMeetingDates.keySet()) {
            List<DateTime> startDateTimes = sObjectToFutureMeetingDates.get(eachSObjectId);
            startDateTimes.sort();
            sObjectToFutureMeetingDate.put(sObjectId, startDateTimes[0]);
        }
        return sObjectToFutureMeetingDate;
    }

    /**
     * @description Common method to update Last Meeting Ran Field on Lead & Opportunity
     * @JIRA# LEM-21484
     * @param sObjectToLastMeetingRan
     */
    private void updateLastMeetingRanOnSObject(Map<Id, DateTime> sObjectToLastMeetingRan) {
        DateTime lastMeetingRan;
        Map<Id, DateTime> sObjectToFutureMeetingDate;
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        sObjectToFutureMeetingDate = getsObjectWithFutureMeetingDate(sObjectToLastMeetingRan);

        List<SObject> sObjects = getSobjects(sObjectToLastMeetingRan);

        for (sObject eachSObject : sObjects) {
            lastMeetingRan = sObjectToLastMeetingRan.get(eachSObject.Id);
            if (sObjectToFutureMeetingDate.containsKey(eachSObject.Id)) {
                eachSObject.put(
                    OPPORTUNITY_FIELD_MEETING_SET,
                    sObjectToFutureMeetingDate.get(eachSObject.Id)
                );
            } else {
                eachSObject.put(OPPORTUNITY_FIELD_MEETING_SET, null);
            }
            eachSObject.put(OPPORTUNITY_FIELD_LAST_MEETING_RAN, lastMeetingRan);
            uow.registerDirty(eachSObject);
        }
        commitWork(uow);
    }

    /**
     * @description update first and last qualified activity on lead and Opportunity
     * @JIRA# LEM-21484
     */
    public void updateFirstAndLastQualifiedActivityOnLeadAndOpportunity() {
        Set<Id> sObjectIds = new Set<Id>();
        for (Event event : (List<Event>) getRecords()) {
            if (event.whatId != null) {
                sObjectIds.add(event.WhatId);
            } else if (event.whoId != null) {
                sObjectIds.add(event.WhoId);
            }
        }
        if (sObjectIds.isEmpty()) {
            return;
        }
        updateFirstAndLastQualifiedActivityOnSobject(sObjectIds);
    }

    /**
     * @description Common method to update first and last qualified activity on lead and Opportunity
     * @JIRA# LEM-21484
     * @param sObjectIds
     */
    private void updateFirstAndLastQualifiedActivityOnSobject(Set<Id> sObjectIds) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        DateTime firstQualifiedActivity;
        List<SObject> sObjects = new List<SObject>();
        sObjects.addAll((List<SObject>) LeadsSelector.newInstance().selectById(sObjectIds));
        sObjects.addAll((List<SObject>) OpportunitiesSelector.newInstance().selectById(sObjectIds));
        for (sObject eachSObject : sObjects) {
            switch on
                OBJECT_NAME_TO_OBJECT_TYPES.get(
                    eachSObject.getSObjectType().getDescribe().getName()
                ) {
                when Lead {
                    firstQualifiedActivity = (((Lead) eachSObject).First_Qualified_Activity__c ==
                        null)
                        ? System.now()
                        : ((Lead) eachSObject).First_Qualified_Activity__c;

                    uow.registerDirty(
                        new Lead(
                            Id = eachSObject.Id,
                            First_Qualified_Activity__c = firstQualifiedActivity,
                            Last_Qualified_Activity__c = System.now()
                        )
                    );
                }
                when Opportunity {
                    if (((Opportunity) eachSObject).Account_Segment__c == ACCOUNT_SEGMENT_SMB) {
                        firstQualifiedActivity = (((Opportunity) eachSObject).First_Activity__c ==
                            null)
                            ? System.now()
                            : ((Opportunity) eachSObject).First_Activity__c;

                        uow.registerDirty(
                            new Opportunity(
                                Id = eachSObject.Id,
                                First_Activity__c = firstQualifiedActivity,
                                Last_Activity__c = System.now()
                            )
                        );
                    }
                }
            }
        }
        commitWork(uow);
    }

    /**
     * @description It is used to get the Opportunity To SDR Id Map.
     * @param opportunityIds
     * @return Map<Id, Set<Id>>
     */
    private Map<Id, Set<Id>> getOpportunityToSdrIdMap(Set<Id> opportunityIds) {
        Map<Id, Set<Id>> oppIdToSdrIdMap = new Map<Id, Set<Id>>();
        for (
            OpportunityTeamMember eachOpportunityTeamMember : OpportunityTeamMembersSelector.newInstance()
                .selectByOpportunityIds(opportunityIds)
        ) {
            if (!oppIdToSdrIdMap.containsKey(eachOpportunityTeamMember.OpportunityId)) {
                oppIdToSdrIdMap.put(
                    eachOpportunityTeamMember.OpportunityId,
                    new Set<Id>{ eachOpportunityTeamMember.userId }
                );
            } else {
                oppIdToSdrIdMap.get(eachOpportunityTeamMember.OpportunityId)
                    .add(eachOpportunityTeamMember.userId);
            }
        }
        return oppIdToSdrIdMap;
    }
    /**
     * @description It is used to Update the SDR Assisted Task Id and SDR Assisted field on opportunity
     * when Event is Held and there is Opportunity team member with Role Sales Deveelopment Rep.
     */
    public void updateSDRAssistedFieldOnOpportunity() {
        Set<Id> opportunityIds = new Set<Id>();
        fflib_ISobjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
        Map<Id, Set<Id>> oppIdToSdrIdMap = new Map<Id, Set<Id>>();
        List<Event> eventList = new List<Event>();
        for (Event eachEvent : (List<Event>) getRecords()) {
            if (String.isNotBlank(eachEvent.WhatId)) {
                if (
                    (eachEvent.WhatId.getSObjectType() == Opportunity.SObjectType) &&
                    (eachEvent.Event_Status__c == EVENT_HELD)
                ) {
                    opportunityIds.add(eachEvent.whatId);
                    eventList.add(eachEvent);
                }
            }
        }
        if (opportunityIds.isEmpty()) {
            return;
        }
        oppIdToSdrIdMap = getOpportunityToSdrIdMap(opportunityIds);
        for (Event objEvent : eventList) {
            if (isEligibleToPopulateSDRAssistedField(oppIdToSdrIdMap, objEvent)) {
                unitOfWork.registerDirty(
                    new Opportunity(
                        Id = objEvent.WhatId,
                        SDR_Assisted_Task_Id__c = objEvent.Id,
                        SDR_Assisted__c = date.newinstance(
                            objEvent.lastModifiedDate.year(),
                            objEvent.lastModifiedDate.month(),
                            objEvent.lastModifiedDate.day()
                        )
                    )
                );
            }
        }
        commitWork(unitOfWork);
    }

    /**
     * @description It is used to check eligibility to update SDR Assisted Fields.
     * @param opportunityIdToSDRUserId
     * @param eventInstance
     * @return Boolean
     */
    private Boolean isEligibleToPopulateSDRAssistedField(
        Map<Id, Set<Id>> opportunityIdToSDRUserId,
        Event eventInstance
    ) {
        return opportunityIdToSDRUserId.containsKey(eventInstance.WhatId) &&
            opportunityIdToSDRUserId.get(eventInstance.WhatId).contains(eventInstance.createdById) &&
            !opportunityIdToSDRUserId.get(eventInstance.WhatId).contains(UserInfo.getUserId());
    }

    /**
     * @description It is used to Update the SDR Touch Required field on opportunity
     * when Event is Missed and there is Opportunity team member with Role Sales Deveelopment Rep.
     */
    public void updateSDRTouchOnOpportunity() {
        Set<Id> opportunityIds = new Set<Id>();
        for (Event eachEvent : (List<Event>) getRecords()) {
            if (String.isNotBlank(eachEvent.WhatId)) {
                if (
                    (eachEvent.WhatId.getSObjectType() == Opportunity.SObjectType) &&
                    (eachEvent.Event_Status__c == EVENT_MISSED)
                ) {
                    opportunityIds.add(eachEvent.whatId);
                }
            }
            fflib_ISobjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
            Set<Id> opportunitiesWithSalesRep = new Set<Id>();
            if (opportunityIds.isEmpty()) {
                return;
            }
            for (
                OpportunityTeamMember eachOpportunityTeamMember : OpportunityTeamMembersSelector.newInstance()
                    .selectByOpportunityIds(opportunityIds)
            ) {
                if (!opportunitiesWithSalesRep.contains(eachOpportunityTeamMember.OpportunityId)) {
                    opportunitiesWithSalesRep.add(eachOpportunityTeamMember.OpportunityId);
                    unitOfWork.registerDirty(
                        new Opportunity(
                            Id = eachOpportunityTeamMember.OpportunityId,
                            SDR_Touch_Required__c = YES
                        )
                    );
                }
            }
            commitWork(unitOfWork);
        }
    }

    /**
     * @description It is a common method to commit unit of work.
     * @param unitOfWork
     */
    private static void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_UPDATE_SDR_ON_OPPORTUNITY,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }
}