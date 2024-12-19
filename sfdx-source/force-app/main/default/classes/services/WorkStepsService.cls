/**
 * @author Deloitte
 * @date 04/15/2022
 * @description Service class for WorkStep related logic.
 */
public inherited sharing class WorkStepsService implements IHandleNotifierEvents {
    /** It is used to prevent the recursion in-case of Parent-to-Child WorkStep
     * or vice-versa Status updates (JIRA#: LEM-530).
     * Note: This variable is used for specific scenario of WorkStep Status changes only.
     * Caution before reusing it in other scenarios.
     * fflib in-built TriggerStateEnabled check to prevent the recursion is not utilised here since
     * other updates on WorkSteps in recursion are still required.
     */
    public static Set<Id> processedWorkStepIds;

    /**
     * @description Initialize static variables.
     */
    static {
        processedWorkStepIds = new Set<Id>();
    }

    /**
     * @description It is used for getting Work Steps Ids from the payload
     * received via Platform Event.
     * @JIRA# LEM-2132
     * @param events
     */
    public static void execute(List<Notifier__e> events) {
        service().handleNotifierEvents(events);
    }

    /**
     * @description Collect child Activation Checklist Work Steps details and generate
     * request payload for outbound integration.
     * @JIRA# LEM-13305
     * @param activationChecklistWorkSteps
     */
    public static void collectChildActivationChecklistWorkStepsForOutboundIntegration(
        Set<Id> activationChecklistWorkSteps
    ) {
        service()
            .collectChildActivationChecklistWorkStepsForOutboundIntegration(
                activationChecklistWorkSteps
            );
    }

    /**
     * @description It triggers WorkStep Status calculations to update WorkOrder & WorkPlan and
     * other Parent records Status.
     * @param parentIds
     */
    public static void runWorkStepStatusCalculationsOnParentRecords(Set<Id> parentIds) {
        service().runWorkStepStatusCalculationsOnParentRecords(parentIds);
    }

    /**
     * @description Update parent Activation Checklist Work Step status to 'In Progress'
     * after outbound integration request is sent.
     * @JIRA# LEM-13305
     * @param activationChecklistWorkSteps
     * @param isSystemError
     * @param workStepStatus
     */
    public static void updateActivationChecklistWorkStepsStatus(
        Set<Id> activationChecklistWorkSteps,
        Boolean isSystemError,
        String workStepStatus
    ) {
        service()
            .updateActivationChecklistWorkStepsStatus(
                activationChecklistWorkSteps,
                isSystemError,
                workStepStatus
            );
    }

    /**
     * @description It updates child WorkStep Status based on parent WorkStep status changes.
     * @JIRA# LEM-530
     * @param parentWorkSteps
     */
    public static void updateChildWorkStepsStatusOnParentWorkStepsStatusChange(
        Map<Id, WorkStep> parentWorkSteps
    ) {
        service().updateChildWorkStepsStatusOnParentWorkStepsStatusChange(parentWorkSteps);
    }

    /**
     * @description It updates the 'Click N Pop Eligible' checkbox and the 'Original Status Reason and Details' fields
     * when the status of a workstep is changed to 'blocked'.
     * @JIRA# LEM-13961
     * @param workSteps
     */
    public static void updatePopnClickOnWorkStepStatusChange(List<WorkStep> workSteps) {
        service().updatePopnClickOnWorkStepStatusChange(workSteps);
    }

    /**
     * @description When WorkSteps are marked as Complete, remove the Status Reasons that are
     *              no longer applicable and add those that are applicable.
     * @param thisWorkStep - WorkStep record to update
     **/
    public static void handleCompletionStatusReasonUpdates(WorkStep thisWorkStep) {
        service().handleCompletionStatusReasonUpdates(thisWorkStep);
    }

    /**
     * @description It is used to map parent Work Order Ids to Work Steps.
     * @param workSteps
     * @return Map<Id, WorkStep>
     */
    public static Map<Id, WorkStep> getParentWorkOrdersToWorkStep(List<WorkStep> workSteps) {
        return service().getParentWorkOrdersToWorkStep(workSteps);
    }

    /**
     * @description It creates instance of WorkStepsServiceImpl class.
     * @return IWorkStepsService - return instance of WorkStepsServiceImpl
     */
    private static IWorkStepsService service() {
        return (IWorkStepsService) Application.Service.newInstance(IWorkStepsService.class);
    }
    /**
     * @description It updates WorkStep Status, Status Reason and Notes based on Business Verification Details.
     * @JIRA# LEM-15834
     * @param storeAccountIds
     * @param salesforceAccountIdToStoreId
     * @param storeIdsToBusinessVertificationDetails
     */
    public static void updateWorkStepsStatusDetailsByBusinessVerificationStatusDetails(
        Set<Id> storeAccountIds,
        Map<Id, String> salesforceAccountIdToStoreId,
        Map<String, BusinessVerficationDetails> storeIdsToBusinessVertificationDetails
    ) {
        service()
            .updateWorkStepsStatusDetailsByBusinessVerificationStatusDetails(
                storeAccountIds,
                salesforceAccountIdToStoreId,
                storeIdsToBusinessVertificationDetails
            );
    }
}