/**
 * @author Deloitte
 * @date 04/26/2024
 * @description It contains custom criteria logics to evaluate SObject records
 * based on initial conditions to trigger email integration.
 */
public inherited sharing class IntegrationCriteriaEvaluator {
    private static final String EMAIL_INTEGRATION_CHUNK_SIZE = 'Email_Outbound_Integration_Chunk_Size';
    private static final String INITIATE_EMAIL_INTEGRATION = 'EMAIL_INTEGRATION_OUTBOUND';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String ORDER_STATUS_SHIPPED = 'Shipped';
    private static final String WORK_ORDER_READINESS_CHECK_COMPLETE = 'Readiness Check Complete';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String WORK_STEP_STATUS_BLOCKED = 'Blocked';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String COMMA_DELIMITER = ',';
    private static final String WORK_ORDER_SUB_TYPE_COO_SAME_STORE = 'COO Same Store';
    private static final String WORK_ORDER_PROVISION_COMPLETED = 'Provisioning Complete';
    private static final Set<String> WORK_ORDER_TYPES_ELIGIBLE_FOR_READINESS_CHECK_COMPLETION_EMAIL = new Set<String>(
        System.Label.WO_Types_For_Readiness_Check_Completion_Email.split(COMMA_DELIMITER)
    );
    private static final Set<String> PROVISION_COMPLETED_ON_RECORD_CREATION = new Set<String>(
        System.Label.Create_WorkOrder_With_Provisioning_Complete.split(COMMA_DELIMITER)
    );
    private enum ObjectTypes {
        ACCOUNT,
        MX_ONBOARDING_LINK,
        MX_ORDER,
        WORK_ORDER,
        WORK_STEP
    }
    private static final Map<Schema.SobjectType, ObjectTypes> SOBJECTTYPETOOBJECTTYPES = new Map<Schema.SobjectType, ObjectTypes>{
        Account.SObjectType => ObjectTypes.ACCOUNT,
        Mx_Onboarding_Link__c.SObjectType => ObjectTypes.MX_ONBOARDING_LINK,
        Mx_Order__c.SObjectType => ObjectTypes.MX_ORDER,
        WorkOrder.SObjectType => ObjectTypes.WORK_ORDER,
        WorkStep.SObjectType => ObjectTypes.WORK_STEP
    };
    private Integer emailIntegrationChunkSize;
    private Set<Id> evaluatedSObjectIds;
    private Map<Id, SObject> oldRecordsToEvaluate;

    /**
     * @description Default constructor for this class.
     */
    public IntegrationCriteriaEvaluator() {
        this.evaluatedSObjectIds = new Set<Id>();
        this.oldRecordsToEvaluate = new Map<Id, SObject>();
        collectStaticConfigurations();
    }

    /**
     * @description It validates the outbound Email integration eligibility for received records
     * based on new field updates.
     * @JIRA# LEM-15575
     * @param newRecords
     */
    public void evaluateInitialCriteriaForEmailIntegration(List<SObject> newRecords) {
        evaluateInitialCriteria(newRecords);
    }

    /**
     * @description It validates the outbound Email integration eligibility for received records
     * by comparing old value with updated value.
     * @JIRA# LEM-13778
     * @param newRecords
     * @param oldRecords
     */
    public void evaluateInitialCriteriaForEmailIntegration(
        List<SObject> newRecords,
        Map<Id, SObject> oldRecords
    ) {
        oldRecordsToEvaluate = oldRecords;
        evaluateInitialCriteria(newRecords);
    }

    /**
     * @description It initiates email integration for eligible records
     * by triggering email outbound event.
     * @JIRA# LEM-15575
     * @param newRecords
     */
    private void evaluateInitialCriteria(List<SObject> newRecords) {
        for (SObject eachSObject : newRecords) {
            if (eachSObject.Id == null) {
                continue;
            }
            switch on SOBJECTTYPETOOBJECTTYPES.get(eachSObject?.Id?.getSObjectType()) {
                when MX_ONBOARDING_LINK {
                    evaluateMxOnboardingLinkForEmailIntegration(
                        (Mx_Onboarding_Link__c) eachSObject
                    );
                }
                when MX_ORDER {
                    evaluateMxOrdersForEmailIntegration((Mx_Order__c) eachSObject);
                }
                when WORK_ORDER {
                    evaluateWorkOrdersForEmailIntegration((WorkOrder) eachSObject);
                }
                when WORK_STEP {
                    evaluateWorkStepsForEmailIntegration((WorkStep) eachSObject);
                }
            }
        }
        if (!evaluatedSObjectIds.isEmpty()) {
            EmailOutboundIntegrationsEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    INITIATE_EMAIL_INTEGRATION => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        evaluatedSObjectIds,
                        emailIntegrationChunkSize
                    )
                }
            );
        }
    }

    /**
     * @description It evaluates received Mx Onboarding Links records eligibility for email integration.
     * @JIRA# LEM-16403
     * @param mxOnboardingLinkToEvaluate
     */
    private void evaluateMxOnboardingLinkForEmailIntegration(
        Mx_Onboarding_Link__c mxOnboardingLinkToEvaluate
    ) {
        if (
            String.isNotBlank(mxOnboardingLinkToEvaluate.Mx_Email__c) &&
            mxOnboardingLinkToEvaluate.Status__c == STATUS_ACTIVE
        ) {
            evaluatedSObjectIds.add(mxOnboardingLinkToEvaluate.Id);
        }
    }

    /**
     * @description It evaluates received Merchant Order records eligibility for email integration.
     * @JIRA# LEM-15575
     * @param mxOrderToEvaluate
     */
    private void evaluateMxOrdersForEmailIntegration(Mx_Order__c mxOrderToEvaluate) {
        Mx_Order__c oldMxOrder = (Mx_Order__c) oldRecordsToEvaluate.get(mxOrderToEvaluate.Id);
        if (
            mxOrderToEvaluate?.Status__c == ORDER_STATUS_SHIPPED &&
            oldMxOrder?.Status__c != ORDER_STATUS_SHIPPED
        ) {
            evaluatedSObjectIds.add(mxOrderToEvaluate.Id);
        }
    }

    /**
     * @description It evaluates received Work Order records eligibility for email integration.
     * @JIRA# LEM-15574
     * @param workOrderToEvaluate
     */
    private void evaluateWorkOrdersForEmailIntegration(WorkOrder workOrderToEvaluate) {
        WorkOrder oldWorkOrder = (WorkOrder) oldRecordsToEvaluate?.get(workOrderToEvaluate.Id);
        if (
            WORK_ORDER_TYPES_ELIGIBLE_FOR_READINESS_CHECK_COMPLETION_EMAIL.contains(workOrderToEvaluate.Type__c) &&
            workOrderToEvaluate?.Sub_Type__c != WORK_ORDER_SUB_TYPE_COO_SAME_STORE &&
            ((
                workOrderToEvaluate?.Provisioning_Status__c == WORK_ORDER_READINESS_CHECK_COMPLETE &&
                oldWorkOrder?.Provisioning_Status__c != WORK_ORDER_READINESS_CHECK_COMPLETE
            ) || (
                    oldWorkOrder == null &&
                    String.isNotBlank(workOrderToEvaluate.Creation_Source__c) &&
                    PROVISION_COMPLETED_ON_RECORD_CREATION.contains(workOrderToEvaluate.Creation_Source__c) &&
                    workOrderToEvaluate.Provisioning_Status__c == WORK_ORDER_PROVISION_COMPLETED
                )
            )

        ) {
            evaluatedSObjectIds.add(workOrderToEvaluate.Id);
        }
    }

    /**
     * @description It evaluates received Work Step records eligibility for email integration.
     * @JIRA# LEM-15573
     * @param workstepToEvaluate
     */
    private void evaluateWorkStepsForEmailIntegration(WorkStep workstepToEvaluate) {
        WorkStep oldWorkStep = (WorkStep) oldRecordsToEvaluate.get(workstepToEvaluate.Id);
        if (
            (workstepToEvaluate?.Status__c == WORK_STEP_STATUS_BLOCKED &&
            oldWorkStep?.Status__c != WORK_STEP_STATUS_BLOCKED) ||
            (workstepToEvaluate?.Status__c == WORK_STEP_STATUS_COMPLETE &&
            oldWorkStep?.Status__c != WORK_STEP_STATUS_COMPLETE)
        ) {
            evaluatedSObjectIds.add(workstepToEvaluate.Id);
        }
    }

    /**
     * @description It collects the configured values from Static Configuration metadata.
     * @JIRA# LEM-13778
     */
    private void collectStaticConfigurations() {
        this.emailIntegrationChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(EMAIL_INTEGRATION_CHUNK_SIZE)
                .Configuration_Value__c
        );
    }
}