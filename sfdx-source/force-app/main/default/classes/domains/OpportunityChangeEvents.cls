/**
 * @author Deloitte
 * @date 06/16/2022
 * @description Domain Class for Opportunity Change Event Object
 */
public inherited sharing class OpportunityChangeEvents extends fflib_SObjects implements IOpportunityChangeEvents {
    private static final String ACCOUNT_ID_FIELD = 'AccountId';
    private static final String CHANGE_EVENT_TYPE_CREATE = 'CREATE';
    private static final String CHANGE_EVENT_TYPE_UPDATE = 'UPDATE';
    private static final String CLOSEDWON_STAGE = 'Closed Won';
    private static final String CONTRACT_ID_FIELD = 'ContractId';
    private static final Set<String> NINTEX_ID_FIELDS = new Set<String>{
        'Drive_Nintex_Id__c',
        'Marketplace_Nintex_Id__c'
    };
    private static final Set<String> NINTEX_FRANCHISE_AMENDMENT_FIELDS = new Set<String>{
        'Nintex_Signed_Date__c'
    };
    private enum ChangeEventTypes {
        CREATE_EVENT,
        UPDATE_EVENT
    }
    private static final Map<String, ChangeEventTypes> CHANGEEVENTTYPEMAPPINGS = new Map<String, ChangeEventTypes>{
        CHANGE_EVENT_TYPE_CREATE => ChangeEventTypes.CREATE_EVENT,
        CHANGE_EVENT_TYPE_UPDATE => ChangeEventTypes.UPDATE_EVENT
    };
    private static final String STAGENAME_FIELD = 'StageName';

    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description This method is to return the IOpportunityChangeEvents interface
     * @param recordList - OpportunityChangeEvents record list
     * @return IOpportunityChangeEvents - Returns IOpportunityChangeEvents Interface
     */
    public static IOpportunityChangeEvents newInstance(List<OpportunityChangeEvent> recordList) {
        return (IOpportunityChangeEvents) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for OpportunityChangeEvents.
     * @param sObjectList
     * @param Schema.OpportunityChangeEvent.SObjectType
     */
    public OpportunityChangeEvents(List<OpportunityChangeEvent> sObjectList) {
        super(sObjectList, Schema.OpportunityChangeEvent.SObjectType);
    }

    /**
     * @description It is used to collect Opportunities on Nintex form submission
     * for parent Work Order creation.
     * @JIRA# LEM-2348
     */
    public void createParentWorkOrderOnNintexFormSubmission() {
        EventBus.ChangeEventHeader changeEventHeader;
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> opportunityIdsToInitiateParentWorkOrderCreation = new Set<Id>();
        Set<Id> opportunityIdsToInitiateFranchiseAmendment = new Set<Id>();
        //LEM-3862 Only call if the Opps were inserted as Closed Won, not updated to Closed Won later
        Set<Id> opportunityIdsInsertedAsClosedWon = new Set<Id>();
        // It is used for QTC objects' data creation as well.
        Set<Id> opportunityIdsToInitiateStoresAssociation = new Set<Id>();
        Boolean isCreateEvent = false;
        for (OpportunityChangeEvent eachChangeEvent : getOpportunityChangeEvents()) {
            changeEventHeader = eachChangeEvent.ChangeEventHeader;
            opportunityIds = collectOpportunityIds(changeEventHeader.getRecordIds());
            switch on CHANGEEVENTTYPEMAPPINGS.get(changeEventHeader.changeType) {
                when CREATE_EVENT {
                    opportunityIdsToInitiateParentWorkOrderCreation.addAll(opportunityIds);
                    opportunityIdsToInitiateFranchiseAmendment.addAll(opportunityIds);
                    opportunityIdsToInitiateStoresAssociation.addAll(opportunityIds);
                    isCreateEvent = true;
                    if (eachChangeEvent.StageName == CLOSEDWON_STAGE) {
                        opportunityIdsInsertedAsClosedWon.addAll(opportunityIds);
                    }
                }
                when UPDATE_EVENT {
                    for (String eachChangedField : changeEventHeader.changedFields) {
                        if (NINTEX_ID_FIELDS.contains(eachChangedField)) {
                            opportunityIdsToInitiateParentWorkOrderCreation.addAll(opportunityIds);
                        }
                        if (NINTEX_FRANCHISE_AMENDMENT_FIELDS.contains(eachChangedField)) {
                            opportunityIdsToInitiateFranchiseAmendment.addAll(opportunityIds);
                        }
                        if (eachChangedField == STAGENAME_FIELD) {
                            opportunityIdsToInitiateStoresAssociation.addAll(opportunityIds);
                        }
                        if (eachChangedField == CONTRACT_ID_FIELD) {
                            opportunityIdsToInitiateParentWorkOrderCreation.addAll(opportunityIds);
                        }
                    }
                }
            }
        }
        OpportunitiesService.updateStageToClosedByFranchiseAmendmentProcessByChangeEvent(
            opportunityIdsToInitiateFranchiseAmendment,
            isCreateEvent
        );
        /**
         * JIRA#: LEM-3378 - Parent Work Order creation should happen after the Franchise Amendment
         * Process related logic to ensure that PDOA date gets calculated according to the current
         * Stage and Close Date.
         */
        OpportunitiesService.initiateParentWorkOrdersCreation(
            opportunityIdsToInitiateParentWorkOrderCreation
        );
        //JIRA-3269 Call Closed Won logic on Opportunities that are now set to Closed Won.
        Opportunities.newInstance(
                OpportunitiesSelector.newInstance()
                    .selectOpportunitiesWithNintexIdById(opportunityIdsInsertedAsClosedWon)
            )
            .createAgreementsFromOpportunities();
        //JIRA#: LEM-3711 - Enable banner message indicator on parent Work Order.
        OpportunitiesService.activateBannerOnClosedWonRateChangeOpportunities(
            opportunityIdsToInitiateStoresAssociation
        );
        //JIRA#: LEM-3658 - Initiates child Work Orders creation on parent Work Order.
        OpportunitiesService.initiateChildWorkOrdersCreationByNintexUseCase(
            opportunityIdsToInitiateStoresAssociation
        );
    }

    /**
     * @description This method used to check Update Events to AccountId on Opportunity and delete
     * child Opportunity Account Relationship records on successful reparenting.
     */
    public void deleteRelatedOpportunityAccountRelationshipsOnOpportunityReparenting() {
        Set<String> opportunityIds = new Set<String>();
        for (OpportunityChangeEvent eachChangeEvent : getOpportunityChangeEvents()) {
            EventBus.ChangeEventHeader eventHeader = eachChangeEvent.ChangeEventHeader;
            if (eventHeader.changeType == CHANGE_EVENT_TYPE_UPDATE) {
                for (String eachChangedField : eventHeader.changedFields) {
                    if (eachChangedField == ACCOUNT_ID_FIELD) {
                        opportunityIds.addAll((List<String>) eventHeader.getRecordIds());
                    }
                }
            }
        }
        OpportunitiesService.deleteOpportunityAccountRelationships(opportunityIds);
    }

    /**
     * @description It is used to collect Ids from the passed String of Ids.
     * @JIRA# LEM-2348
     * @param recordIds
     * @return Set<Id>
     */
    private Set<Id> collectOpportunityIds(List<String> recordIds) {
        return ((Set<Id>) JSON.deserialize(JSON.serialize(recordIds), Set<Id>.class));
    }

    /**
     * @description This method is used to return the trigger context records
     * of type OpportunityChangeEvent.
     * @return List<OpportunityChangeEvent>
     */
    private List<OpportunityChangeEvent> getOpportunityChangeEvents() {
        return (List<OpportunityChangeEvent>) getRecords();
    }

    /**
     * @description This private method allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This constructor is used to create instance of OpportunityChangeEvent domain class.
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description construct
         * @param objects List<Object>
         * @return instance of OpportunityChangeEvent
         */
        public fflib_ISObjects construct(List<Object> objects) {
            if (OpportunityChangeEvents.constructorMock != null) {
                return (fflib_ISObjects) OpportunityChangeEvents.constructorMock.construct(objects);
            }
            return new OpportunityChangeEvents((List<OpportunityChangeEvent>) objects);
        }
    }
}