/**
 * @author Deloitte
 * @date 04/07/2022
 * @description Service implementation class for WorkStep Rescue process related calculations logic.
 */
public inherited sharing class WorkStepsRescueCalculationServiceImpl implements IWorkStepsRescueCalculationService {
    private static final String AGGREGATE_NUMBER_OF_CHILD_WORKSTEPS_ALIAS = 'workStepsCount';
    private static final String AGGREGATE_PARENTWORKSTEPID_FIELD_ALIAS = 'parentWorkStepId';
    private static final String AGGREGATE_WORK_STEP_STATUS_FIELD_ALIAS = 'workStepStatus';
    private static final String EVENT_TOPIC_WORK_STEPS_CALCULATION = 'WORK_STEPS_RESCUE_PROCESS_CALCULATION';
    private static final String STATUS_BLOCKED = 'Blocked';
    private static final String STATUS_RESOLVED = 'Resolved';
    private static final String LOG_SERVICE_WORK_STEP = 'WorkStep Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private Set<Id> parentWorkStepIds;

    /**
     * @description Default constructor to instantiate the variables.
     */
    public WorkStepsRescueCalculationServiceImpl() {
        this.parentWorkStepIds = new Set<Id>();
    }

    /**
     * @description It gets parent WorkStep Ids from the payload received via platform event
     * and performs calculations related to number of blocked or resolved child WorkSteps.
     * @JIRA# LEM-2043
     * @param events
     */
    public void handleNotifierEvents(List<Notifier__e> events) {
        Set<Id> recordIdsFromPayload;
        for (Notifier__e eachEvent : events) {
            if (String.isBlank(eachEvent.Payload__c)) {
                continue;
            }
            recordIdsFromPayload = (Set<Id>) JSON.deserialize(eachEvent.Payload__c, Set<Id>.class);
            if (eachEvent.Topic__c == EVENT_TOPIC_WORK_STEPS_CALCULATION) {
                parentWorkStepIds.addAll(recordIdsFromPayload);
            }
        }
        collectChildWorkStepDetailsBasedOnParentWorkStepIds();
    }

    /**
     * @description It collects child Work Steps count to update on parent Work Step.
     * @JIRA# LEM-2043
     */
    private void collectChildWorkStepDetailsBasedOnParentWorkStepIds() {
        Map<Id, Map<String, Integer>> parentWorkStepIdToStatusToCount = new Map<Id, Map<String, Integer>>();
        Set<Id> unprocessedParentWorkStepIds = parentWorkStepIds;
        Id parentWorkStepId;
        String workStepStatus;
        Map<Id, WorkStep> parentWorkSteps = new Map<Id, WorkStep>(
            WorkStepsSelector.newInstance().selectById(parentWorkStepIds)
        );
        for (
            Aggregate eachAggregate : WorkStepsSelector.newInstance()
                .getChildWorkStepsCountFilteredByAndGroupedByParentAndStatus(parentWorkStepIds)
        ) {
            parentWorkStepId = (Id) eachAggregate.get(AGGREGATE_PARENTWORKSTEPID_FIELD_ALIAS);
            workStepStatus = (String) eachAggregate.get(AGGREGATE_WORK_STEP_STATUS_FIELD_ALIAS);
            if (!parentWorkStepIdToStatusToCount.containsKey(parentWorkStepId)) {
                parentWorkStepIdToStatusToCount.put(parentWorkStepId, new Map<String, Integer>());
            }
            if (
                !parentWorkStepIdToStatusToCount.get(parentWorkStepId).containsKey(workStepStatus)
            ) {
                parentWorkStepIdToStatusToCount.get(parentWorkStepId)
                    .put(
                        workStepStatus,
                        Integer.valueOf(
                            eachAggregate.get(AGGREGATE_NUMBER_OF_CHILD_WORKSTEPS_ALIAS)
                        )
                    );
            }
            unprocessedParentWorkStepIds.remove(parentWorkStepId);
        }
        for (Id unprocessedParentWorkStepId : unprocessedParentWorkStepIds) {
            parentWorkStepIdToStatusToCount.put(
                unprocessedParentWorkStepId,
                new Map<String, Integer>()
            );
            parentWorkStepIdToStatusToCount.get(unprocessedParentWorkStepId).put(STATUS_BLOCKED, 0);
            parentWorkStepIdToStatusToCount.get(unprocessedParentWorkStepId)
                .put(STATUS_RESOLVED, 0);
        }
        updateParentWorkStepsWithNumberOfBlockedAndResolvedChildWorkSteps(
            parentWorkStepIdToStatusToCount,
            parentWorkSteps
        );
    }

    /**
     * @description It checks whether the Secondary_Email_Timer_Start_Time__c
     * value needs to be blanked out.
     * @JIRA# LEM-2045
     * @param workStep
     * @return Boolean
     */
    private Boolean doesSecondaryEmailTimerNeedsToBeBlanked(WorkStep workStep) {
        return workStep.Status__c != STATUS_BLOCKED && workStep.Number_of_Blocked_Work_Steps__c > 0;
    }

    /**
     * @description It checks whether the current parent WorkStep satisfies the condition
     * to update the Secondary_Email_Timer_Start_Time__c value.
     * @JIRA# LEM-2045
     * @param numberOfBlockedWorkSteps
     * @param workStep
     * @return Boolean
     */
    private Boolean isEligibleToUpdateSecondaryEmailTimer(
        Integer numberOfBlockedWorkSteps,
        WorkStep workStep
    ) {
        return workStep.Status__c == STATUS_BLOCKED &&
            workStep.Number_of_Blocked_Work_Steps__c > 0 &&
            numberOfBlockedWorkSteps > workStep.Number_of_Blocked_Work_Steps__c &&
            (workStep.Secondary_Email_Timer_Start_Time__c == null ||
            (workStep.Secondary_Email_Timer_Start_Time__c != null &&
            workStep.Secondary_Email_Next_Schedule__c < System.now()));
    }

    /**
     * @description It updates the number of Blocked and Resolved child Work Steps
     * on parent Work Steps. It also updates Secondary Email Timer Start Time on parent Work Step.
     * @JIRA# LEM-2043, LEM-2045
     * @param parentWorkStepIdToStatusToCount
     * @param parentWorkSteps
     */
    private void updateParentWorkStepsWithNumberOfBlockedAndResolvedChildWorkSteps(
        Map<Id, Map<String, Integer>> parentWorkStepIdToStatusToCount,
        Map<Id, WorkStep> parentWorkSteps
    ) {
        WorkStep currentRecord;
        Integer numberOfBlockedWorkSteps;
        Integer numberOfResolvedWorkSteps;
        fflib_ISObjectUnitOfWork uowToUpdateParentWorkStep = Application.UNITOFWORK.newInstance();
        WorkStep recordToBeUpdated;
        List<WorkStep> recordsToBeUpdated = new List<WorkStep>();
        for (Id eachWorkStepId : parentWorkStepIdToStatusToCount.keySet()) {
            Map<String, Integer> workStepStatusToCount = parentWorkStepIdToStatusToCount.get(
                eachWorkStepId
            );
            numberOfBlockedWorkSteps = workStepStatusToCount.get(STATUS_BLOCKED);
            numberOfResolvedWorkSteps = workStepStatusToCount.get(STATUS_RESOLVED);
            currentRecord = parentWorkSteps.get(eachWorkStepId);
            recordToBeUpdated = new WorkStep(
                Id = eachWorkStepId,
                Number_of_Blocked_Work_Steps__c = (numberOfBlockedWorkSteps == null)
                    ? 0
                    : numberOfBlockedWorkSteps,
                Number_of_Resolved_Work_Steps__c = (numberOfResolvedWorkSteps == null)
                    ? 0
                    : numberOfResolvedWorkSteps
            );
            //JIRA#: LEM-2045 - rescue communication secondary email notification timer changes
            if (isEligibleToUpdateSecondaryEmailTimer(numberOfBlockedWorkSteps, currentRecord)) {
                recordToBeUpdated.Secondary_Email_Timer_Start_Time__c = System.now();
            } else if (doesSecondaryEmailTimerNeedsToBeBlanked(currentRecord)) {
                recordToBeUpdated.Secondary_Email_Timer_Start_Time__c = null;
            }
            recordsToBeUpdated.add(recordToBeUpdated);
        }
        uowToUpdateParentWorkStep.registerDirty(recordsToBeUpdated);
        try {
            uowToUpdateParentWorkStep.commitWork();
        } catch (Exception parentWorkStepsUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    parentWorkStepsUpdateException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE_WORK_STEP,LOG_DOMAIN_PROVISIONING,GenericLogEntry.SeverityLevel.HIGH
                ).logException(parentWorkStepsUpdateException)
            );
        }
    }
}