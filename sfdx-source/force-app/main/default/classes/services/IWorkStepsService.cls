/**
 * @author Deloitte
 * @date 04/15/2022
 * @description Interface of service class for WorkStep related logic.
 */
public interface IWorkStepsService {
    /**
     * @description Collect child Activation Checklist Work Steps details and generate
     * request payload for outbound integration.
     * @param activationChecklistWorkSteps
     */
    void collectChildActivationChecklistWorkStepsForOutboundIntegration(
        Set<Id> activationChecklistWorkSteps
    );

    /**
     * @description It is used to handle Notifier Events to further process Work Step Ids
     * from the received payload.
     * via Platform Event.
     * @param events
     */
    void handleNotifierEvents(List<Notifier__e> events);

    /**
     * @description It triggers WorkStep Status calculations to update WorkOrder & WorkPlan and
     * other Parent records Status.
     * @param parentIds
     */
    void runWorkStepStatusCalculationsOnParentRecords(Set<Id> parentIds);

    /**
     * @description Update parent Activation Checklist Work Step status to 'In Progress'
     * after outbound integration request is sent.
     * @param activationChecklistWorkSteps
     * @param isSystemError
     * @param workStepStatus
     */
    void updateActivationChecklistWorkStepsStatus(
        Set<Id> activationChecklistWorkSteps,
        Boolean isSystemError,
        String workStepStatus
    );

    /**
     * @description It updates child WorkStep Status based on parent WorkStep status changes.
     * @param parentWorkSteps
     */
    void updateChildWorkStepsStatusOnParentWorkStepsStatusChange(Map<Id, WorkStep> parentWorkSteps);

    /**
     * @description It updates the 'Click N Pop Eligible' checkbox and the 'Original Status Reason and Details' fields
     * when the status of a workstep is changed to 'blocked'.
     * @JIRA# LEM-13961
     * @param workSteps
     */
    void updatePopnClickOnWorkStepStatusChange(List<WorkStep> workSteps);

    /**
     * @description When WorkSteps are marked as Complete, remove the Status Reasons that are
     *              no longer applicable and add those that are applicable.
     * @param thisWorkStep - WorkStep record to update
     **/
    void handleCompletionStatusReasonUpdates(WorkStep thisWorkStep);

    /**
     * @description It is used to map parent Work Order Ids to Work Steps.
     * @param workSteps
     * @return Map<Id, WorkStep>
     */
    Map<Id, WorkStep> getParentWorkOrdersToWorkStep(List<WorkStep> workSteps);

    /**
     * @description It updates WorkStep Status, Status Reason and Notes based on Business Verification Details.
     * @JIRA# LEM-15834
     * @param storeAccountIds
     * @param salesforceAccountIdToStoreId
     * @param storeIdsToBusinessVertificationDetails
     */
    void updateWorkStepsStatusDetailsByBusinessVerificationStatusDetails(
        Set<Id> storeAccountIds,
        Map<Id, String> salesforceAccountIdToStoreId,
        Map<String, BusinessVerficationDetails> storeIdsToBusinessVertificationDetails
    );
}