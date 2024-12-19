/**
 * @author Deloitte
 * @date 06/04/2024
 * @description Service Implementation class for Parent Work Orders creation related logic.
 */
public inherited sharing class WorkOrderCreationTriggerServiceImpl implements IWorkOrderCreationTriggerService {
    private static final String INTERFACE_TRANSACTION_STATUS_SUCCESS = 'Success';
    private static final Integer GENERIC_WORK_ORDER_CREATION_CHUNK_SIZE = 40;

    /**
     * @description It creates Interface Transaction based on the passed SObject Ids.
     * @JIRA# LEM-15362,LEM-13484,LEM-15321
     * @param sObjectIds
     * @param eventTopicName
     */
    public static void initiateWorkOrderCreation(Set<Id> sObjectIds, String eventTopicName) {
        if (sObjectIds.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(
            new Interface_Transaction__c(
                Payload__c = JSON.serialize(sObjectIds),
                Remaining_Retry_Attempts__c = 3,
                Interface_Transaction_Configuration_Name__c = eventTopicName,
                Status__c = INTERFACE_TRANSACTION_STATUS_SUCCESS
            )
        );
        uow.commitWork();
    }

    /**
     * @description It is used to fire Onboarding Events Platform Event for
     * Work Order creation.
     * @param sObjectIds
     * @param eventTopicName
     */
    public void fireonboardingActivationsEventsForWorkOrderCreation(
        Set<Id> sObjectIds,
        String eventTopicName
    ) {
        OnboardingActivationsEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                eventTopicName => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    sObjectIds,
                    GENERIC_WORK_ORDER_CREATION_CHUNK_SIZE
                )
            }
        );
    }
}