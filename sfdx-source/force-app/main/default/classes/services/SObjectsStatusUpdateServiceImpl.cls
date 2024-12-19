/**
 * @author Deloitte
 * @date 05/28/2024
 * @description Service class Implementation for SObjectsStatusUpdateService.
 */
public inherited sharing class SObjectsStatusUpdateServiceImpl implements ISObjectsStatusUpdateService {
    private static final String QUOTE_STATUS_DRAFT = 'Draft';
    private static final String OPPORTUNITY_STAGE_CLOSED = 'Closed Lost';
    private static final String IRONCLAD_STATUS_CANCELED = 'Canceled';
    private static final String PROCESS_AUTOMATION_USER = 'Process Automation User';
    private static final String EVENT_TOPIC_UPDATE_IRONCLAD_WORKFLOW_TO_CANCELLED = 'EVENT_TOPIC_UPDATE_IRONCLAD_WORKFLOW_TO_CANCELLED';

    /**
     * @description It is used to handle Notifier Events to further process.
     * @JIRA# LEM-15269
     * @param notifierEvents
     */
    public void handlenotifierEvents(List<Notifier__e> notifierEvents) {
        Set<Id> ironcladWorkflowIds = new Set<Id>();
        for (Notifier__e eachEvent : notifierEvents) {
            if (eachEvent.Topic__c == EVENT_TOPIC_UPDATE_IRONCLAD_WORKFLOW_TO_CANCELLED) {
                ironcladWorkflowIds = (Set<Id>) JSON.deserialize(
                    eachEvent.Payload__c,
                    Set<Id>.class
                );
            }
        }
        if (ironcladWorkflowIds.isEmpty()) {
            return;
        }
        updateIroncladWorkflowsStatus(ironcladWorkflowIds);
    }

    /**
     * @description It is used to update Status for the passed SObjects.
     * @JIRA# LEM-15269
     * @param sObjects
     */
    public void updateSObjectsStatusFieldValue(List<SObject> sObjects) {
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity eachOpportunity : (List<Opportunity>) sObjects) {
            if (eachOpportunity.StageName == OPPORTUNITY_STAGE_CLOSED) {
                opportunityIds.add(eachOpportunity.Id);
            }
        }
        Map<Id, ironclad__Ironclad_Workflow__c> ironcladWorkflowIds = new Map<Id, ironclad__Ironclad_Workflow__c>(
            IroncladWorkflowsSelector.newInstance()
                .selectIroncladWorkflowsWithOutForSignaturePrimaryQuotesByOpportunityIds(
                    opportunityIds
                )
        );
        if (ironcladWorkflowIds.isEmpty()) {
            return;
        }
        publishEventsByEventTopic(
            EVENT_TOPIC_UPDATE_IRONCLAD_WORKFLOW_TO_CANCELLED,
            ironcladWorkflowIds.keySet()
        );
    }

    /**
     * @description It is used to publish the notifier events by the received event topic and Ids.
     * @param eventTopic
     * @param sObjectIds
     */
    private void publishEventsByEventTopic(String eventTopic, Set<Id> sObjectIds) {
        notifierEventsService.publishEvents(
            new Map<String, String>{ eventTopic => JSON.serialize(sObjectIds) }
        );
    }

    /**
     * @description It is used to update the status of ironclad workflows to canceled.
     * @param ironcladWorkflowIds
     */
    private void updateIroncladWorkflowsStatus(Set<Id> ironcladWorkflowIds) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Id eachIronClad : ironcladWorkflowIds) {
            uow.registerDirty(
                new ironclad__Ironclad_Workflow__c(
                    Id = eachIronClad,
                    ironclad__Workflow_Status__c = IRONCLAD_STATUS_CANCELED
                )
            );
        }
        uow.commitWork();
    }
}