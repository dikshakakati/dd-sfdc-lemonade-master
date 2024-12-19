/**
 * @author Deloitte
 * @date 12/01/2023
 * @description Service impl class for processing Tablet Case Sync integration requests.
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessiveClassLength')
public inherited sharing class FigmentToDdmxSyncServiceImpl implements IFigmentToDdmxSyncService {
    private static final String INTEGRATION_TYPE = 'Tablet Case Sync';
    private static final String WORK_STEP_TYPE = 'Deliver Tablet';
    private static final String SFDC_STATUS = 'Processed';
    private static final String EVENT_TOPIC_UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS = 'UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS';

    private enum EventTopics {
        EVENT_TOPIC_UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS
    }

    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS => EventTopics.EVENT_TOPIC_UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS
    };

    fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

    /**
     * @description This method handles the events from the Notifier platform event.
     * Sends the grouped events to the appropriate handler for further processing.
     * @param events a list of Notifier__e objects representing the events to be processed.
     */
    public void handleNotifierEvents(List<Notifier__e> events) {
        Savepoint savePointBeforeProcessing = Database.setSavepoint();
        Set<Id> recordIdsFromPayload = new Set<Id>();
        Set<Id> intRequestIds = new Set<Id>();
        try {
            for (Notifier__e eachEvent : events) {
                recordIdsFromPayload = (Set<Id>) JSON.deserialize(
                    eachEvent.Payload__c,
                    Set<Id>.class
                );
                if (recordIdsFromPayload == null) {
                    continue;
                }
                if (
                    EVENT_TOPIC_UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS.equals(
                        eachEvent.Topic__c
                    )
                ) {
                    intRequestIds.addAll(recordIdsFromPayload);
                }
            }

            if (intRequestIds.size() > 0) {
                updateWorkstepStatus(intRequestIds);
            }
        } catch (Exception ex) {
            Database.rollback(savePointBeforeProcessing);
            String message = 'Record Ids ' + recordIdsFromPayload + '  ' + ex;
            ex.setMessage(message);
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description Update WorkStep status based on Integration Request information.
     * @param workStepIds a set of WorkStep record Ids to be updated.
     */
    public void updateWorkstepStatus(Set<Id> workStepIds) {
        if (workStepIds.isEmpty()) {
            return;
        }
        // Get Integration Requests based on Work Step Ids
        Map<Id, Integration_Request__c> workStepIdToIntegrationRequestMap = getIntegrationRequestsMap(
            workStepIds
        );
        String businessFriendlyMessage = '';
        for (Id workStepId : workStepIds) {
            Integration_Request__c intRequest = workStepIdToIntegrationRequestMap.get(workStepId);

            if (intRequest != null) {
                // Get Business Friendly Message Details using UNFRIENDLY_MESSAGE from Integration Request
                Business_Friendly_Mapping__mdt businessFriendlyMessageDetails = GetBusinessFriendlyMessageService.getMessageDetails(
                    intRequest.Notes__c,
                    INTEGRATION_TYPE
                );
                if (businessFriendlyMessageDetails != null) {
                    businessFriendlyMessage = businessFriendlyMessageDetails.Business_Friendly_Message__c;
                } else {
                    businessFriendlyMessage = intRequest.Notes__c;
                }

                // Update WorkStep fields based on Integration Request

                WorkStep workStepToUpdate = new WorkStep(
                    Id = workStepId,
                    Type__c = WORK_STEP_TYPE,
                    Status__c = intRequest.Stage__c,
                    Status = intRequest.Stage__c,
                    Tablet_Escalation_Notes__c = businessFriendlyMessage,
                    Tablet_Integration_Message__c = intRequest.Notes__c,
                    Is_Updated_By_System__c = true
                );
                uow.registerDirty(workStepToUpdate);
            }
        }
        // Update Integration Request status to 'Processed'
        updateIntegrationRequestStatus(workStepIdToIntegrationRequestMap.values());
        uow.commitWork();
    }

    /**
     * @description Get a map of Integration Requests based on Work Step Ids.
     * @param workStepIds a set of WorkStep record Ids.
     * @return a map of Work Step Ids to corresponding Integration Requests.
     */
    private Map<Id, Integration_Request__c> getIntegrationRequestsMap(Set<Id> workStepIds) {
        Map<Id, Integration_Request__c> workStepIdToIntegrationRequestMap = new Map<Id, Integration_Request__c>();

        for (
            Integration_Request__c intRequest : IntegrationRequestsSelector.newInstance()
                .selectIntegrationRequestsByOnboardingId(workStepIds)
        ) {
            workStepIdToIntegrationRequestMap.put(
                Id.valueOf(intRequest.Onboarding_Id__c),
                intRequest
            );
        }

        return workStepIdToIntegrationRequestMap;
    }

    /**
     * @description Update Integration Request status to 'Processed'.
     * @param integrationRequestsToUpdate a set of Integration Request record Ids.
     */
    public void updateIntegrationRequestStatus(
        List<Integration_Request__c> integrationRequestsToUpdate
    ) {
        for (Integration_Request__c intRequest : integrationRequestsToUpdate) {
            intRequest.sfdc_status__c = SFDC_STATUS;
            uow.registerDirty(intRequest);
        }
    }
}