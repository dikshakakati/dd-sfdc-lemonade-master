/**
 * @author Deloitte
 * @date 26/06/2024
 * @description Service implementation class for Mx Onboarding Link related logic.
 */
public inherited sharing class MxOnboardingLinksServiceImpl implements IMxOnboardingLinksService {
    private static final String INITIATE_RELATED_OBJECTS_CREATION = 'INITIATE_RELATED_OBJECTS_CREATION';
    private static final String INTERFACE_TRANSACTION_STATUS_FAILURE = 'Failure';
    private static final String LOG_DOMAIN_MX_ONBOARDING_LINKS = 'Mx Onboarding Links';
    private static final String LOG_SERVICE_MX_ONBOARDING_LINKS_SERVICE = 'MxOnboardingLinksService';
    private enum EventTopics {
        EVENT_TOPIC_INITIATE_RELATED_OBJECTS_CREATION
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        INITIATE_RELATED_OBJECTS_CREATION => EventTopics.EVENT_TOPIC_INITIATE_RELATED_OBJECTS_CREATION
    };
    private enum ObjectTypes {
        MX_ONBOARDING_LINK,
        INTERFACE_TRANSACTION
    }
    private static final Map<Schema.SobjectType, ObjectTypes> SOBJECTTYPETOOBJECTTYPES = new Map<Schema.SobjectType, ObjectTypes>{
        Mx_Onboarding_Link__c.SObjectType => ObjectTypes.MX_ONBOARDING_LINK,
        Interface_Transaction__c.SObjectType => ObjectTypes.INTERFACE_TRANSACTION
    };

    Set<Id> interfaceTransactionIds;
    Set<Id> mxOnboardingLinkIds;
    fflib_ISObjectUnitOfWork uow;

    /**
     * @description default constructor
     */
    public MxOnboardingLinksServiceImpl() {
        this.interfaceTransactionIds = new Set<Id>();
        this.mxOnboardingLinkIds = new Set<Id>();
        this.uow = Application.UnitOfWork.newInstance();
    }

    /**
     * @description It is used to handle and route the published OnboardingActivationsEvents.
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    public void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    ) {
        Set<Id> sObjectIds = new Set<Id>();
        Set<Id> recordIdsByPayload;
        for (Onboarding_Activation__e eachEvent : onboardingActivationsEvents) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENT_TOPIC_INITIATE_RELATED_OBJECTS_CREATION {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    if (recordIdsByPayload == null) {
                        continue;
                    }
                    sObjectIds.addAll(recordIdsByPayload);
                }
            }
        }
        groupSobjectIdsBySObjectTypes(sObjectIds);
        try {
            MxOnboardingLinks.newInstance(new List<Mx_Onboarding_Link__c>{})
                .initiateStoreAgreementCreation(mxOnboardingLinkIds);
        } catch (Exception agreementCreationException) {
            updateInterfaceTransactionToFailure();
            createLogEntries(agreementCreationException);
        }
    }

    /**
     * @description It is used to create Log Entries.
     * @param agreementCreationException
     */
    public void createLogEntries(Exception agreementCreationException) {
        Set<String> recordIdsToLog = new Set<String>();
        recordIdsToLog.add(JSON.serialize(interfaceTransactionIds));
        recordIdsToLog.add(JSON.serialize(mxOnboardingLinkIds));
        Logger.publish(
            LogEntry.newExceptionLog(agreementCreationException, LogEntry.SeverityLevel.HIGH)
        );
        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                    LOG_SERVICE_MX_ONBOARDING_LINKS_SERVICE,
                    LOG_DOMAIN_MX_ONBOARDING_LINKS,
                    GenericLogEntry.SeverityLevel.HIGH
                )
                .logException(agreementCreationException)
                .logSFRecordId(recordIdsToLog)
        );
    }

    /**
     * @description It is used to group SObject Ids from Platform Event by SObject Types.
     * @param sObjectIds
     */
    private void groupSobjectIdsBySObjectTypes(Set<Id> sObjectIds) {
        for (Id eachId : sObjectIds) {
            Schema.SObjectType sobjectType = eachId.getSObjectType();
            switch on SOBJECTTYPETOOBJECTTYPES.get(sobjectType) {
                when MX_ONBOARDING_LINK {
                    mxOnboardingLinkIds.add(eachId);
                }
                when INTERFACE_TRANSACTION {
                    interfaceTransactionIds.add(eachId);
                }
            }
        }
    }

    /**
     * @description It is used to update Interface Transaction Status to Failure.
     */
    private void updateInterfaceTransactionToFailure() {
        for (Id eachInterfaceTransactionId : interfaceTransactionIds) {
            uow.registerDirty(
                new Interface_Transaction__c(
                    Id = eachInterfaceTransactionId,
                    Status__c = INTERFACE_TRANSACTION_STATUS_FAILURE
                )
            );
        }
        uow.commitWork();
    }
}