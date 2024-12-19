/**
 * @author Deloitte
 * @date 23/05/2022
 * @description Service Implementation class to calculate and update the value of date fields
 * utilized for tracking WorkStep Status changes.
 */
public inherited sharing class WorkStepsStatusRelatedDatesCalcSrvcImpl implements IWorkStepsStatusRelatedDatesCalcService {
    private static final String WORK_STEP_STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String WORK_STEP_STATUS_NOT_STARTED = 'Not Started';
    private static final Set<String> NOT_STARTED_STATUS_VALUES = new Set<String>{
        WORK_STEP_STATUS_NOT_STARTED,
        WORK_STEP_STATUS_NOT_WORKABLE
    };
    private enum Status {
        BLOCKED,
        COMPLETE,
        DEAD,
        ESCALATED,
        IN_PROGRESS,
        NOT_STARTED,
        NOT_WORKABLE,
        QA_COMPLETE,
        READY_FOR_QA
    }
    private static final String WORK_STEP_STATUS_BLOCKED = 'Blocked';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_STATUS_COMPLETE_DD_TO_IMPLEMENT_LINK = 'Complete - DoorDash to implement link';
    private static final String WORK_STEP_STATUS_COMPLETE_MX_TO_IMPLEMENT_LINK = 'Complete - Mx to implement link';
    private static final String WORK_STEP_STATUS_COMPLETE_IMPLEMENTED_ON_THE_CALL = 'Complete - Implemented on the call';
    private static final String WORK_STEP_STATUS_DEAD = 'Dead';
    private static final String WORK_STEP_STATUS_ESCALATED = 'Escalated';
    private static final String WORK_STEP_STATUS_IN_PROGRESS = 'In Progress';
    private static final String WORK_STEP_STATUS_QA_COMPLETE = 'QA Complete';
    private static final String WORK_STEP_STATUS_READY_FOR_QA = 'Ready for QA';
    private static final Map<String, Status> STATUSVALUETOENUMVALUES = new Map<String, Status>{
        WORK_STEP_STATUS_BLOCKED => Status.BLOCKED,
        WORK_STEP_STATUS_COMPLETE => Status.COMPLETE,
        WORK_STEP_STATUS_COMPLETE_DD_TO_IMPLEMENT_LINK => Status.COMPLETE,
        WORK_STEP_STATUS_COMPLETE_MX_TO_IMPLEMENT_LINK => Status.COMPLETE,
        WORK_STEP_STATUS_COMPLETE_IMPLEMENTED_ON_THE_CALL => Status.COMPLETE,
        WORK_STEP_STATUS_DEAD => Status.DEAD,
        WORK_STEP_STATUS_ESCALATED => Status.ESCALATED,
        WORK_STEP_STATUS_IN_PROGRESS => Status.IN_PROGRESS,
        WORK_STEP_STATUS_NOT_STARTED => Status.NOT_STARTED,
        WORK_STEP_STATUS_NOT_WORKABLE => Status.NOT_WORKABLE,
        WORK_STEP_STATUS_QA_COMPLETE => Status.QA_COMPLETE,
        WORK_STEP_STATUS_READY_FOR_QA => Status.READY_FOR_QA
    };

    /**
     * @description It is used to calculate and update the value of date fields
     * utilized for tracking WorkStep Status changes.
     * @JIRA# LEM-1489
     * @param newWorkSteps
     * @param oldWorkSteps
     */
    public void updateAssociatedDateTrackingFieldsOnStatusChange(
        List<WorkStep> newWorkSteps,
        Map<Id, WorkStep> oldWorkSteps
    ) {
        if (newWorkSteps == null) {
            return;
        }
        WorkStep oldWorkStep;
        Boolean isWorkStepStarted;
        for (WorkStep eachWorkStep : newWorkSteps) {
            oldWorkStep = oldWorkSteps.get(eachWorkStep.Id);
            updatePreviousSpentDaysInBlockedStatusFieldWhenWorkStepIsUnblocked(
                eachWorkStep,
                oldWorkStep
            );
            isWorkStepStarted = hasUserStartedWorkingOnWorkStep(eachWorkStep, oldWorkStep);
            switch on STATUSVALUETOENUMVALUES.get(eachWorkStep.Status__c) {
                when IN_PROGRESS {
                    if (!isWorkStepStarted) {
                        continue;
                    }
                    updateInitialAuditFields(eachWorkStep, oldWorkStep);
                }
                when COMPLETE {
                    if (isWorkStepStarted) {
                        updateInitialAuditFields(eachWorkStep, oldWorkStep);
                    }
                    eachWorkStep.Completed_Date_Time__c = System.now();
                    updateLastQAedByAndLastQADateTimeFields(eachWorkStep, oldWorkStep);
                }
                when BLOCKED {
                    if (isWorkStepStarted) {
                        updateInitialAuditFields(eachWorkStep, oldWorkStep);
                    }
                    eachWorkStep.Last_Blocked_Date_Time__c = System.now();
                }
                when ESCALATED {
                    if (isWorkStepStarted) {
                        updateInitialAuditFields(eachWorkStep, oldWorkStep);
                    }
                    eachWorkStep.Last_Escalation_Date_Time__c = System.now();
                    updateLastQAedByAndLastQADateTimeFields(eachWorkStep, oldWorkStep);
                }
                when READY_FOR_QA {
                    eachWorkStep.Last_Prepared_By__c = UserInfo.getUserId();
                    if (eachWorkStep.Initial_Preparation_Date_Time__c == null) {
                        eachWorkStep.Initial_Preparation_Date_Time__c = System.now();
                    }
                }
                when QA_COMPLETE {
                    updateLastQAedByAndLastQADateTimeFields(eachWorkStep, oldWorkStep);
                }
                when else {
                    continue;
                }
            }
        }
    }

    /**
     * @description It checks whether the Status is changed from 'Not Started' to any other Status.
     * @JIRA# LEM-1489
     * @param newWorkStep
     * @param oldWorkStep
     * @return Boolean
     */
    private Boolean hasUserStartedWorkingOnWorkStep(WorkStep newWorkStep, WorkStep oldWorkStep) {
        return (NOT_STARTED_STATUS_VALUES.contains(oldWorkStep.Status__c)) &&
            !(NOT_STARTED_STATUS_VALUES.contains(newWorkStep.Status__c));
    }

    /**
     * @description It checks whether the previous Status value is 'Ready for QA'.
     * @JIRA# LEM-1489
     * @param oldWorkStepStatus
     * @return Boolean
     */
    private Boolean isPreviousValueOfStatusReadyForQA(String oldWorkStepStatus) {
        return (oldWorkStepStatus == WORK_STEP_STATUS_READY_FOR_QA);
    }

    /**
     * @description It checks whether the Status is changed from 'Blocked' to any other Status.
     * @JIRA# LEM-1489
     * @param newWorkStep
     * @param oldWorkStep
     * @return Boolean
     */
    private Boolean isWorkStepUnblocked(WorkStep newWorkStep, WorkStep oldWorkStep) {
        return oldWorkStep.Status__c == WORK_STEP_STATUS_BLOCKED &&
            newWorkStep.Status__c != WORK_STEP_STATUS_BLOCKED;
    }

    /**
     * @description It updates the Last QAed By and Last QA Date/Time fields.
     * @JIRA# LEM-1489
     * @param newWorkStep
     * @param oldWorkStep
     */
    private void updateLastQAedByAndLastQADateTimeFields(
        WorkStep newWorkStep,
        WorkStep oldWorkStep
    ) {
        if (!isPreviousValueOfStatusReadyForQA(oldWorkStep.Status__c)) {
            return;
        }
        newWorkStep.Last_QAed_By__c = UserInfo.getUserId();
        newWorkStep.Last_QA_Date_Time__c = System.now();
    }

    /**
     * @description It updates the Previous spent days in blocked status field value with Time spent
     * in blocked days field's previous value when WorkStep is unblocked.
     * @JIRA# LEM-1489
     * @param newWorkStep
     * @param oldWorkStep
     */
    private void updatePreviousSpentDaysInBlockedStatusFieldWhenWorkStepIsUnblocked(
        WorkStep newWorkStep,
        WorkStep oldWorkStep
    ) {
        if (isWorkStepUnblocked(newWorkStep, oldWorkStep)) {
            newWorkStep.Previous_Spent_Days_In_Blocked_Status__c = oldWorkStep.Time_Spent_In_Blocked_Days_Calculated__c;
        }
    }

    /**
     * @description It updates the Start Date/Time and Initial Owner fields
     * when user starts working on the Work Step.
     * @JIRA# LEM-4001
     * @param newWorkStep
     * @param oldWorkStep
     */
    private void updateInitialAuditFields(WorkStep newWorkStep, WorkStep oldWorkStep) {
        if (oldWorkStep.Start_Date_Time__c == null) {
            newWorkStep.Start_Date_Time__c = System.now();
        }
        if (oldWorkStep.Initial_Owner__c == null) {
            newWorkStep.Initial_Owner__c = UserInfo.getName();
        }
    }
}