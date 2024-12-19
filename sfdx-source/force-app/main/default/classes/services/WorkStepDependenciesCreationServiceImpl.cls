/**
 * @author Deloitte
 * @date 12/23/2022
 * @description Service implementation class for WorkStepDependencies creation logic.
 */
public inherited sharing class WorkStepDependenciesCreationServiceImpl implements IWorkStepDependenciesCreationService {
    private static final String EVENT_TOPIC_WORK_STEP_DEPENDENCIES_CREATE = 'WORK_STEP_DEPENDENCIES_CREATE';
    private static final Integer EXECUTION_ORDER_FIRST = 1;
    private static final Boolean IS_TEST_CONTEXT = Test.isRunningTest();
    private static final String WORK_STEP_STATUS_NOT_STARTED = 'Not Started';
    private static final String LOG_SERVICE_WORK_STEP = 'Work Step Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private Map<Id, WorkStepDependency__c> existingWorkStepDependencies;
    private Set<Id> uniqueWorkPlanTemplateEntryIds;
    private Map<Id, Map<Id, WorkStep>> workOrderIdToWorkPlanTemplateEntryIdToWorkStep;

    /**
     * @description Default constructor to instantiate variables.
     */
    public WorkStepDependenciesCreationServiceImpl() {
        existingWorkStepDependencies = new Map<Id, WorkStepDependency__c>();
        uniqueWorkPlanTemplateEntryIds = new Set<Id>();
        workOrderIdToWorkPlanTemplateEntryIdToWorkStep = new Map<Id, Map<Id, WorkStep>>();
    }

    /**
     * @description It is being called through NotifierEvent class and triggers creation of
     * WorkStepDependencies by handling platform events.
     * @JIRA# LEM-4160
     * @param events
     */
    public void initiateWorkStepDependenciesCreation(List<Notifier__e> events) {
        Set<Id> workOrderIds = new Set<Id>();
        Set<Id> recordIdsFromPayload;
        for (Notifier__e eachEvent : events) {
            recordIdsFromPayload = (Set<Id>) JSON.deserialize(eachEvent.Payload__c, Set<Id>.class);
            if (recordIdsFromPayload == null) {
                continue;
            }
            if (eachEvent.Topic__c == EVENT_TOPIC_WORK_STEP_DEPENDENCIES_CREATE) {
                workOrderIds.addAll(recordIdsFromPayload);
            }
        }
        fetchExistingWorkStepDependencies(workOrderIds);
        //@JIRA#: LEM-2394 - Added check for fetching WorkStep details to recreate WorkStepDependencies if exist
        fetchWorkStepDetails(workOrderIds);
        createWorkStepDependencies();
    }

    /**
     * @description It generates list of WorkStepDependencies using passed WorkStep records
     * from passed WorkStepTemplateEntries.
     * @JIRA# LEM-1061
     * @param dependeeWorkStepDependencyTemplates
     * @param workPlanTemplateEntryIdToWorkStep
     * @param workStepId
     * @return List<WorkStepDependency__c>
     */
    private List<WorkStepDependency__c> collectWorkStepDependencies(
        Set<WorkStepDependencyTemplate__c> dependeeWorkStepDependencyTemplates,
        Map<Id, WorkStep> workPlanTemplateEntryIdToWorkStep,
        Id workStepId
    ) {
        List<WorkStepDependency__c> workStepDependencies = new List<WorkStepDependency__c>();
        WorkStep dependeeWorkStep;
        for (
            WorkStepDependencyTemplate__c eachWorkStepDependencyTemplate : dependeeWorkStepDependencyTemplates
        ) {
            dependeeWorkStep = workPlanTemplateEntryIdToWorkStep.get(
                eachWorkStepDependencyTemplate.Dependee_Work_Plan_Template_Entry__c
            );
            // Test.isRunningTest() check added since in mock/unit testing Id will be always null
            if ((dependeeWorkStep == null || dependeeWorkStep.Id == null) && !IS_TEST_CONTEXT) {
                continue;
            }
            workStepDependencies.add(
                new WorkStepDependency__c(
                    Dependee_Work_Step__c = dependeeWorkStep?.Id,
                    Dependent_Work_Step__c = workStepId,
                    Work_Step_Dependency_Template__c = eachWorkStepDependencyTemplate.Id
                )
            );
        }
        return workStepDependencies;
    }

    /**
     * @description It creates map of dependent WorkStepTemplateEntry
     * to set of dependee WorkStepTemplateEntries.
     * @JIRA# LEM-1061
     * @param workPlanTemplateEntryIds
     * @return Map<Id, Set<WorkStepDependencyTemplate__c>>
     */
    private Map<Id, Set<WorkStepDependencyTemplate__c>> collectWorkStepDependencyTemplates(
        Set<Id> workPlanTemplateEntryIds
    ) {
        Map<Id, Set<WorkStepDependencyTemplate__c>> dependentToDependeeWorkStepDependencyTemplates = new Map<Id, Set<WorkStepDependencyTemplate__c>>();
        if (workPlanTemplateEntryIds.isEmpty()) {
            return dependentToDependeeWorkStepDependencyTemplates;
        }
        for (
            WorkStepDependencyTemplate__c eachWorkStepDependencyTemplate : WorkStepDependencyTemplatesSelector.newInstance()
                .selectDependeeWorkStepDependencyTemplates(workPlanTemplateEntryIds)
        ) {
            if (
                dependentToDependeeWorkStepDependencyTemplates.containsKey(
                    eachWorkStepDependencyTemplate.Dependent_Work_Plan_Template_Entry__c
                )
            ) {
                dependentToDependeeWorkStepDependencyTemplates.get(
                        eachWorkStepDependencyTemplate.Dependent_Work_Plan_Template_Entry__c
                    )
                    .add(eachWorkStepDependencyTemplate);
            } else {
                dependentToDependeeWorkStepDependencyTemplates.put(
                    eachWorkStepDependencyTemplate.Dependent_Work_Plan_Template_Entry__c,
                    new Set<WorkStepDependencyTemplate__c>{ eachWorkStepDependencyTemplate }
                );
            }
        }
        return dependentToDependeeWorkStepDependencyTemplates;
    }

    /**
     * @description It fetches existing WorkStepDependencies for given WorkOrders.
     * @JIRA# LEM-2394
     * @param workOrderIds
     */
    private void fetchExistingWorkStepDependencies(Set<Id> workOrderIds) {
        existingWorkStepDependencies = new Map<Id, WorkStepDependency__c>(
            WorkStepDependenciesSelector.newInstance()
                .selectDependenciesByWorkOrderIds(workOrderIds)
        );
    }

    /**
     * @description It fetches WorkSteps details by WorkOrder Ids.
     * @JIRA# LEM-2394
     * @param workOrderIds
     */
    private void fetchWorkStepDetails(Set<Id> workOrderIds) {
        for (
            WorkStep eachWorkStep : WorkStepsSelector.newInstance()
                .selectWorkStepsByWorkOrderIds(workOrderIds)
        ) {
            if (
                !workOrderIdToWorkPlanTemplateEntryIdToWorkStep.containsKey(
                    eachWorkStep.WorkOrderId
                )
            ) {
                workOrderIdToWorkPlanTemplateEntryIdToWorkStep.put(
                    eachWorkStep.WorkOrderId,
                    new Map<Id, WorkStep>()
                );
            }
            uniqueWorkPlanTemplateEntryIds.add(eachWorkStep.WorkPlanTemplateEntry__c);
            workOrderIdToWorkPlanTemplateEntryIdToWorkStep.get(eachWorkStep.WorkOrderId)
                .put(eachWorkStep.WorkPlanTemplateEntry__c, eachWorkStep);
        }
    }

    /**
     * @description It trigger UOW commitWork on the passed records.
     * @param sObjectListToInsert
     */
    private void fireRecordsInsertion(List<SObject> sObjectListToInsert) {
        if (sObjectListToInsert == null || sObjectListToInsert.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowRecordsCreation = Application.UnitOfWork.newInstance();
        uowRecordsCreation.registerNew(sObjectListToInsert);
        try {
            uowRecordsCreation.commitWork();
        } catch (Exception recordsCreationException) {
            Logger.publish(
                LogEntry.newExceptionLog(recordsCreationException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE_WORK_STEP,
                    LOG_DOMAIN_PROVISIONING,
                    GenericLogEntry.SeverityLevel.HIGH
                ).logException (
                    recordsCreationException
                )
            );
        }
    }

    /**
     * @description It deletes the existing and creates new WorkStepDependencies.
     */
    private void createWorkStepDependencies() {
        Map<Id, Set<WorkStepDependencyTemplate__c>> dependentToDependeeWorkStepDependencyTemplates = collectWorkStepDependencyTemplates(
            uniqueWorkPlanTemplateEntryIds
        );
        if (
            dependentToDependeeWorkStepDependencyTemplates == null ||
            dependentToDependeeWorkStepDependencyTemplates.isEmpty()
        ) {
            return;
        }
        Map<Id, WorkStep> workPlanTemplateEntryIdToWorkStep;
        WorkStep workStep;
        List<WorkStepDependency__c> workStepDependenciesToInsert = new List<WorkStepDependency__c>();
        List<WorkStepDependency__c> workStepDependenciesToDelete = new List<WorkStepDependency__c>();
        workStepDependenciesToDelete = existingWorkStepDependencies.values();
        for (Id eachWorkOrderId : workOrderIdToWorkPlanTemplateEntryIdToWorkStep.keySet()) {
            workPlanTemplateEntryIdToWorkStep = workOrderIdToWorkPlanTemplateEntryIdToWorkStep.get(
                eachWorkOrderId
            );
            for (Id eachWorkPlanTemplateEntryId : workPlanTemplateEntryIdToWorkStep.keySet()) {
                workStep = workPlanTemplateEntryIdToWorkStep.get(eachWorkPlanTemplateEntryId);
                // Test.isRunningTest() check added since in mock/unit testing Id will be always null
                if (workStep.Id == null && !IS_TEST_CONTEXT) {
                    continue;
                }
                if (
                    !dependentToDependeeWorkStepDependencyTemplates.containsKey(
                        eachWorkPlanTemplateEntryId
                    )
                ) {
                    continue;
                }
                workStepDependenciesToInsert.addAll(
                    collectWorkStepDependencies(
                        dependentToDependeeWorkStepDependencyTemplates.get(
                            eachWorkPlanTemplateEntryId
                        ),
                        workPlanTemplateEntryIdToWorkStep,
                        workStep.Id
                    )
                );
            }
        }
        SobjectDeletionService.fireRecordsDeletion(workStepDependenciesToDelete);
        fireRecordsInsertion(workStepDependenciesToInsert);
    }
}