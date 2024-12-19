/**
 * @author atg
 * @date 07/26/2022
 * @description Service class for WorkStep related logic when Business Reference or Xref objects are integrated.
 * Suppressing Warning as Service class contains multiple public methods due to previous changes.
 * TODO: Fix PMD warnings by moving methods to other Service classes.
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity')
public inherited sharing class WorkStepIntegrationStatusServiceImpl implements IWorkStepIntegrationStatusService {
    @testVisible
    private static final String BUSINESS_REF_STATUS_SUCCESS = 'Success';
    @testVisible
    private static final String BUSINESS_REF_STATUS_FAILURE = 'Failure';
    private static final String BUSINESS_REF_STATUS_NEW = 'New';
    private static final String BUSINESS_REF_STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String CURRENT_RETRY_COUNT = 'Current Retry Count: ';
    private static final String EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_INTEGRATION = 'REINITIATE_WORK_STEPS_STATUS_INTEGRATION';
    private static final String EVENT_TOPIC_UPDATE_WORK_STEPS_INTEGRATION_STATUS = 'UPDATE_SETUP_BUSINESS_WORKSTEP_STATUS';
    private static final String EXCEEDED_MAXIMUM_RETRY_LIMIT_ERROR_MESSAGE = 'Maximum retry limit exceeded for Work Steps status integration.';
    private static final String PIPELINE_SEPARATOR = ' || ';
    private static final String STATUS_COMPLETE = 'Complete';
    private static final String STATUS_ESCALATED = 'Escalated';
    private static final String STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String WORK_ORDER_PROVISIONING_COMPLETE = 'Provisioning Complete';
    @testVisible
    private static final String WORK_ORDER_PROVISIONING_FAILED = 'Provisioning Failed';
    @testvisible
    private static final String XREF_EXTERNAL_SOURCE_DRIVE = 'DriveDb';
    @testvisible
    private static final String XREF_EXTERNAL_SOURCE_MARKETPLACE = 'MDS';
    @testvisible
    private static final String XREF_EXTERNAL_SOURCE_MARKETPLACE_CATERING = 'MDS - Catering';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORKORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORKORDER_TYPE_COO = 'COO';
    private static final String WORKSTEP_TYPE_RATE_CHANGE = 'Rate Change';
    private static final String WORKSTEP_BUSINESS_STATUS_REASON = 'Business Provisioning Failed - Please refer to Provisioning Errors tab';
    private static final String WORKSTEP_STORE_STATUS_REASON = 'Store Provisioning Failed - Please refer to Provisioning Errors tab';
    private static final String INTEGRATION_MESSAGE_START_SUCCESS = 'Success';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String WORK_STEP_TYPE_SETUP_STOREFRONT = 'Setup Storefront Page';
    private static final String LOG_SERVICE_WORK_STEP = 'Work Step Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String STATUS_BLOCKED = 'Blocked';
    private static final String STATUS_INTEGRATION_METHOD_NAME = 'updateSetupBusinessWorkStepStatusOnXrefCreation';
    private static final String STATUS_READY_FOR_QA = 'Ready for QA';
    private static final String WORKSTEP_BUSINESS_REFERENCE_NOT_FOUND_STATUS_REASON = 'Business reference not found';
    private static final String WORK_STEP_STATUS_INTEGRATION_RETRY_LIMIT_STATIC_CONFIG = 'Work_Step_Status_Integration_Retry_Limit';
    @testVisible
    private static final String CANNOT_FIND_BUS_REF_ERROR_MESSAGE = 'A Business Reference with the following criteria could not be found: ';
    @testvisible
    private static final String CANNOT_FIND_DEFAULT_BUSINESS_REF = 'Default Business Reference cannot be found.';
    private enum EventTopics {
        EVENTTOPIC_REINITIATE_WORK_STEPS_STATUS_INTEGRATION,
        EVENTTOPIC_UPDATE_WORK_STEPS_INTEGRATION_STATUS
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_INTEGRATION => EventTopics.EVENTTOPIC_REINITIATE_WORK_STEPS_STATUS_INTEGRATION,
        EVENT_TOPIC_UPDATE_WORK_STEPS_INTEGRATION_STATUS => EventTopics.EVENTTOPIC_UPDATE_WORK_STEPS_INTEGRATION_STATUS
    };

    private enum XREFSTATUSES {
        FAILURE,
        SUCCESS,
        WAITINGFORBUSINESS
    }
    private static final Map<String, XREFSTATUSES> XREFSTATUSMAPPINGS = new Map<String, XREFSTATUSES>{
        BUSINESS_REF_STATUS_FAILURE => XREFSTATUSES.FAILURE,
        BUSINESS_REF_STATUS_SUCCESS => XREFSTATUSES.SUCCESS,
        STATUS_WAITING_FOR_BUSINESS => XREFSTATUSES.WAITINGFORBUSINESS
    };

    private static List<IGenericLogEntry> genericLogList = new List<IGenericLogEntry>();
    private Map<String, Map<String, Status_Reason_And_Details_Mapping__mdt>> provisioningCategoryToStatusReasonAndDetailsMappings;
    private Set<Id> initialPayload;
    private Integer rollUpReExecutionLimit;
    private Integer rollupRetryCount;

    /**
     * @description Default constructor to instantiate variables.
     */
    public WorkStepIntegrationStatusServiceImpl() {
        this.initialPayload = new Set<Id>();
        provisioningCategoryToStatusReasonAndDetailsMappings = new Map<String, Map<String, Status_Reason_And_Details_Mapping__mdt>>();
        this.rollupRetryCount = 0;
        collectCustomMetadataConfigs();
    }

    /**
     * @description It is used to handle the payload received via Platform Event.
     * @JIRA# LEM-18813
     * @param events
     */
    public void handleOnboardingActivationsEvents(List<Onboarding_Activation__e> events) {
        Set<Id> xrefIds = new Set<Id>();
        Set<Id> recordIdsByPayload;
        for (Onboarding_Activation__e eachEvent : events) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENTTOPIC_REINITIATE_WORK_STEPS_STATUS_INTEGRATION {
                    WorkStepStatusEntry workStepStatusEntryInstance = (WorkStepStatusEntry) JSON.deserialize(
                        eachEvent.Payload__c,
                        WorkStepStatusEntry.class
                    );
                    recordIdsByPayload = workStepStatusEntryInstance.xrefIds;
                    rollupRetryCount = workStepStatusEntryInstance.retryCount;
                    xrefIds.addAll(recordIdsByPayload);
                }
                when EVENTTOPIC_UPDATE_WORK_STEPS_INTEGRATION_STATUS {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    xrefIds.addAll(recordIdsByPayload);
                }
            }
        }
        try {
            updateSetupBusinessWorkStepStatusOnXrefCreation(xrefIds);
        } catch (Exception runTimeException) {
            createLogsAndReinitiateWorkStepStatusUpdate(runTimeException);
        }
    }

    /**
     * @description Updates WorkStep Status when Xref records were created
     * @JIRA# LEM-3389
     * @param xrefs
     * @param businessReferenceIds
     */
    public void updateSetupBusinessWorkStepStatusOnXrefCreation(
        List<Xref__c> xrefs,
        Set<Id> businessReferenceIds
    ) {
        Map<Id, Business_Reference__c> businessReferences = new Map<Id, Business_Reference__c>(
            BusinessReferencesSelector.newInstance()
                .selectBydIdAndIntegrationStatus(
                    businessReferenceIds,
                    new Set<String>{
                        BUSINESS_REF_STATUS_SUCCESS,
                        BUSINESS_REF_STATUS_FAILURE,
                        BUSINESS_REF_STATUS_NEW,
                        BUSINESS_REF_STATUS_READY_FOR_INTEGRATION
                    }
                )
        );
        if (!businessReferences.isEmpty()) {
            processSetupBusinessWorkStepStatusUpdates(xrefs, businessReferences);
        }
    }

    /**
     * @description It is used to fetch Status Reason and Details Mapping custom metadata records
     * and map them by type and provisioning error category.
     */
    private void collectCustomMetadataConfigs() {
        this.rollUpReExecutionLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(WORK_STEP_STATUS_INTEGRATION_RETRY_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
        for (
            Status_Reason_And_Details_Mapping__mdt eachStatusReasonAndDetailsMapping : StatusReasonAndDetailsMappingsSelector.newInstance()
                .getAllMappings()
        ) {
            if (
                !provisioningCategoryToStatusReasonAndDetailsMappings.containsKey(
                    eachStatusReasonAndDetailsMapping.Type__c
                )
            ) {
                provisioningCategoryToStatusReasonAndDetailsMappings.put(
                    eachStatusReasonAndDetailsMapping.Type__c,
                    new Map<String, Status_Reason_And_Details_Mapping__mdt>()
                );
            }
            provisioningCategoryToStatusReasonAndDetailsMappings.get(
                    eachStatusReasonAndDetailsMapping.Type__c
                )
                .put(
                    eachStatusReasonAndDetailsMapping.Business_Friendly_Mapping__r.Message_Category__c,
                    eachStatusReasonAndDetailsMapping
                );
        }
    }

    private void processSetupBusinessWorkStepStatusUpdates(
        List<Xref__c> xrefsForBusinessReferences,
        Map<Id, Business_Reference__c> businessReferences
    ) {
        Map<Id, Id> accountIdToBusRefIdMap = getAccountIdToBusinessReferenceIdMap(
            xrefsForBusinessReferences,
            businessReferences
        );

        List<WorkStep> workStepList = WorkStepsSelector.newInstance()
            .getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                accountIdToBusRefIdMap.keySet()
            );

        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for (WorkStep ws : workStepList) {
            Id busRefIdForThisWorkStep = getBusinessReferenceId(accountIdToBusRefIdMap, ws);
            String busRefStatus = getBusinessReferenceStatus(
                busRefIdForThisWorkStep,
                businessReferences
            );

            if (busRefStatus == BUSINESS_REF_STATUS_SUCCESS) {
                setWorkStepSuccessDataForBusRefUpdate(busRefIdForThisWorkStep, ws, uow);
            } else {
                setWorkStepFailureDataForBusRefUpdate(
                    businessReferences.get(busRefIdForThisWorkStep),
                    ws,
                    uow
                );
            }
        }

        //Process Failures for COO Business References. Only Process Failures, COO Success is a special use case.
        List<WorkStep> cooWorkStepList = WorkStepsSelector.newInstance()
            .getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(accountIdToBusRefIdMap.keySet());
        for (WorkStep ws : cooWorkStepList) {
            Id busRefIdForThisWorkStep = getBusinessReferenceId(accountIdToBusRefIdMap, ws);
            String busRefStatus = getBusinessReferenceStatus(
                busRefIdForThisWorkStep,
                businessReferences
            );
            if (busRefStatus == BUSINESS_REF_STATUS_FAILURE) {
                setWorkStepFailureDataForBusRefUpdate(
                    businessReferences.get(busRefIdForThisWorkStep),
                    ws,
                    uow
                );
            } else if (busRefStatus == BUSINESS_REF_STATUS_SUCCESS) {
                setWorkStepSuccessDataForBusRefUpdate(busRefIdForThisWorkStep, ws, uow);
            }
        }

        commitWork(uow);
    }

    /**
     * @description It fires notifier event to reinitiate Work Steps Status rollup.
     */
    private void reinitiateWorkStepStatusIntegration() {
        WorkStepStatusEntry workStepStatusEntryInstance = new WorkStepStatusEntry(
            new Set<Id>(),
            ++rollupRetryCount
        );
        workStepStatusEntryInstance.xrefIds = initialPayload;
        OnboardingActivationsEventsService.publishEvents(
            new Map<String, String>{
                EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_INTEGRATION => JSON.serialize(
                    workStepStatusEntryInstance
                )
            }
        );
    }

    /**
     * @description Updates WorkStep Status when Xref records are created.
     * @JIRA# LEM-18813
     * @param xrefIds
     */
    private void updateSetupBusinessWorkStepStatusOnXrefCreation(Set<Id> xrefIds) {
        initialPayload.addAll(xrefIds);
        Set<Id> businessReferenceIds = new Set<Id>();
        List<Xref__c> xrefs = new List<Xref__c>();
        for (Xref__c eachXref : XrefsSelector.newInstance().selectById(xrefIds)) {
            businessReferenceIds.add(eachXref.Business_Reference__c);
            xrefs.add(eachXref);
        }
        updateSetupBusinessWorkStepStatusOnXrefCreation(xrefs, businessReferenceIds);
    }

    /**
     * @description Updates WorkStep Status when Business References Integration Status updates
     * @JIRA# LEM-2181
     * @param businessReferences
     */
    public void updateWorkStepsStatusOnBusinessReferenceStatusChange(
        Map<Id, Business_Reference__c> businessReferences
    ) {
        List<Xref__c> xrefsForBusinessReferences = XrefsSelector.newInstance()
            .selectAllMatchingBusinessReference(businessReferences.keySet());
        if (!xrefsForBusinessReferences.isEmpty()) {
            processSetupBusinessWorkStepStatusUpdates(
                xrefsForBusinessReferences,
                businessReferences
            );
        }
    }

    /**
     * @description Updates WorkStep Status when Xref Integration Status updates
     * @JIRA# LEM-2203
     * @param xrefList
     */
    public void updateWorkStepsStatusOnXrefStatusChange(List<Xref__c> xrefList) {
        Map<Id, Xref__c> xrefMap = new Map<Id, Xref__c>(xrefList);
        //Each account can have multiple Xrefs associated.
        Map<Id, Set<Id>> accountIdtoXrefIdSetMap = getAccountIdToXrefIdSetMap(xrefList);
        List<WorkStep> workStepList = WorkStepsSelector.newInstance()
            .getNonCompleteSetupStoreWorkStepsByStoreAccount(accountIdtoXrefIdSetMap.keySet());
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (WorkStep ws : workStepList) {
            Set<Id> xrefIdSet = accountIdtoXrefIdSetMap.containsKey(ws.Store_Account__c)
                ? accountIdtoXrefIdSetMap.get(ws.Store_Account__c)
                : new Set<Id>();
            for (Id xrefId : xrefIdSet) {
                Xref__c xref = xrefMap.containsKey(xrefId)
                    ? xrefMap.get(xrefId)
                    : new Xref__c(External_ID_Source__c = '');
                updateUOWForWorkStepXref(ws, xref, uow);
            }
        }

        commitWork(uow);
    }

    /**
     * @description Updates WorkStep Status when Business References Integration Status updates for COO
     * @param businessReferenceList
     */
    public void updateWorkStepsStatusOnBusinessReferenceCOOStatusChange(
        List<Business_Reference__c> businessReferenceList
    ) {
        Map<Id, Business_Reference__c> businessReferenceMap = new Map<Id, Business_Reference__c>(
            businessReferenceList
        );
        List<Xref__c> xrefsForBusinessReferences = XrefsSelector.newInstance()
            .selectAllMatchingBusinessReference(businessReferenceMap.keySet());
        Map<Id, Id> accountIdToBusRefIdMap = getAccountIdToBusinessReferenceIdMap(
            xrefsForBusinessReferences
        );
        List<WorkStep> workStepList = WorkStepsSelector.newInstance()
            .getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(accountIdToBusRefIdMap.keySet());

        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for (WorkStep ws : workStepList) {
            Id busRefIdForThisWorkStep = accountIdToBusRefIdMap.containsKey(ws.Store_Account__c)
                ? accountIdToBusRefIdMap.get(ws.Store_Account__c)
                : null;
            String integrationMessage = ((busRefIdForThisWorkStep != null) &&
                businessReferenceMap.containsKey(busRefIdForThisWorkStep))
                ? businessReferenceMap.get(busRefIdForThisWorkStep).Integration_Message__c
                : '';

            if (
                String.isBlank(integrationMessage) ||
                (integrationMessage.startsWith(INTEGRATION_MESSAGE_START_SUCCESS))
            ) {
                //Empty String or start with Success in the Integration Message signals success.
                setWorkStepSuccessDataForBusRefUpdate(busRefIdForThisWorkStep, ws, uow);
            } else {
                setWorkStepFailureDataForBusRefUpdate(
                    businessReferenceMap.get(busRefIdForThisWorkStep),
                    ws,
                    uow
                );
            }
        }

        commitWork(uow);
    }

    /**
     * @description Updates WorkStep Status when Xref records are created.
     * @JIRA# LEM-18813
     * @param statusUpdateException
     */
    private void createLogsAndReinitiateWorkStepStatusUpdate(Exception statusUpdateException) {
        String logDetailedMessage;
        LogEntry logEntryInstance;
        ILogger loggerInstance;
        logDetailedMessage =
            statusUpdateException.getMessage() +
            PIPELINE_SEPARATOR +
            CURRENT_RETRY_COUNT +
            rollupRetryCount;
        if (rollupRetryCount < rollUpReExecutionLimit) {
            reinitiateWorkStepStatusIntegration();
        } else {
            logDetailedMessage += PIPELINE_SEPARATOR + EXCEEDED_MAXIMUM_RETRY_LIMIT_ERROR_MESSAGE;
        }
        logEntryInstance = LogEntry.newLog(
            WorkStepIntegrationStatusServiceImpl.class.getName(),
            STATUS_INTEGRATION_METHOD_NAME,
            logDetailedMessage
        );
        loggerInstance = Logger.add(logEntryInstance);
        if (loggerInstance != null) {
            loggerInstance.publish();
        }
        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                    LOG_SERVICE_WORK_STEP,
                    LOG_DOMAIN_PROVISIONING,
                    GenericLogEntry.SeverityLevel.LOW
                )
                .logException(statusUpdateException)
        );
    }

    /**
     * @description Pulls a map of AccountId to Business Reference Id from a list of Xrefs
     * @param xRefList
     * @param businessReferences
     * @return Map<Id, Id>
     */
    private Map<Id, Id> getAccountIdToBusinessReferenceIdMap(
        List<Xref__c> xRefList,
        Map<Id, Business_Reference__c> businessReferences
    ) {
        //If there are multiple xrefs for the same account, and these Xrefs have different Business Reference lookups, we will choose a
        //business reference that has a Failed Status, so we know which Work Orders need to be ESCALATED.  Otherwise we will set the first
        //Business Reference object since they were all successful.
        Map<Id, Id> accountIdToBusRefIdMap = new Map<Id, Id>();
        for (Xref__c xref : xRefList) {
            if (xref.Salesforce_Account_Name__c != null) {
                Id businesRefId = getCorrectBusinessRefId(
                    xref,
                    accountIdToBusRefIdMap,
                    businessReferences
                );
                accountIdToBusRefIdMap.put(xref.Salesforce_Account_Name__c, businesRefId);
            }
        }
        return accountIdToBusRefIdMap;
    }

    /**
     * @description Pulls a map of AccountId to Set Xref Ids from a list of Xrefs
     * @param xRefList
     * @return Map<Id, Set<Id>>
     */
    private Map<Id, Set<Id>> getAccountIdToXrefIdSetMap(List<Xref__c> xRefList) {
        Map<Id, Set<Id>> accountIdtoXrefIdSetMap = new Map<Id, Set<Id>>();
        for (Xref__c xref : xRefList) {
            if (xref.Salesforce_Account_Name__c != null) {
                Set<Id> xrefIdSet = new Set<Id>();
                if (accountIdtoXrefIdSetMap.containsKey(xref.Salesforce_Account_Name__c)) {
                    xrefIdSet = accountIdtoXrefIdSetMap.get(xref.Salesforce_Account_Name__c);
                }
                xrefIdSet.add(xref.Id);
                accountIdtoXrefIdSetMap.put(xref.Salesforce_Account_Name__c, xrefIdSet);
            }
        }
        return accountIdtoXrefIdSetMap;
    }

    /**
     * @description Set the status correctly for a Success
     * @param ws
     * @param xref
     * @param uow
     */
    private void updateUOWForWorkStepXref(WorkStep ws, Xref__c xref, fflib_ISobjectUnitOfWork uow) {
        if (!isEligibleWorkOrderTypeForWSUpdate(ws, xref)) {
            return;
        }
        switch on XREFSTATUSMAPPINGS.get(xref.Integration_Status__c) {
            when FAILURE {
                setWorkStepFailureDataForXrefUpdate(xref, ws, uow);
            }
            when SUCCESS {
                setWorkStepSuccessDataForXrefUpdate(xref.External_ID__c, xref.Id, ws, uow);
            }
            when WAITINGFORBUSINESS {
                if (isEligibleToRollUpWaitingForBusiness(ws, xref)) {
                    setWorkStepFailureDataForXrefUpdate(xref, ws, uow);
                }
            }
        }
    }

    /**
     * @description Check if the Workstep is eligible for Update
     * @param ws
     * @param xref
     * @return Boolean
     */
    private Boolean isEligibleWorkOrderTypeForWSUpdate(WorkStep ws, Xref__c xref) {
        Boolean workStepEligible = false;
        if ((isEligibleDriveWorkStep(ws, xref)) || (isEligibleMarketplaceWorkStep(ws, xref))) {
            workStepEligible = true;
        } else {
            workStepEligible = false;
        }
        return workStepEligible;
    }

    /**
     * @description Check if the Workstep is drive
     * @param ws
     * @param xref
     * @return Boolean
     */
    private Boolean isEligibleDriveWorkStep(WorkStep ws, Xref__c xref) {
        Boolean driveWorkStep = false;
        if (
            ((xref.External_ID_Source__c == XREF_EXTERNAL_SOURCE_DRIVE) &&
            (ws.WorkOrder.Type__c == WORKORDER_TYPE_DRIVE))
        ) {
            driveWorkStep = true;
        }
        return driveWorkStep;
    }

    /**
     * @description Check if the Workstep is drive
     * @param ws
     * @param xref
     * @return Boolean
     */
    private Boolean isEligibleMarketplaceWorkStep(WorkStep ws, Xref__c xref) {
        Boolean marketplaceWorkStep = false;
        if (
            (((xref.External_ID_Source__c == XREF_EXTERNAL_SOURCE_MARKETPLACE) ||
            (xref.External_ID_Source__c == XREF_EXTERNAL_SOURCE_MARKETPLACE_CATERING)) &&
            ((ws.WorkOrder.Type__c == WORKORDER_TYPE_MARKETPLACE) ||
            (ws.WorkOrder.Type__c == WORKORDER_TYPE_COO) ||
            (ws.Type__c == WORKSTEP_TYPE_RATE_CHANGE) ||
            (ws.WorkOrder.Type__c == WORKORDER_TYPE_STOREFRONT)))
        ) {
            marketplaceWorkStep = true;
        }
        return marketplaceWorkStep;
    }

    /**
     * @description To check wether the passed WorkStep and Xref is eligible for
     * 'Waiting for Business' status roll-up.
     * @param workStepToValidate
     * @param xrefToValidate
     * @return Boolean
     */
    private Boolean isEligibleToRollUpWaitingForBusiness(
        WorkStep workStepToValidate,
        Xref__c xrefToValidate
    ) {
        return ((workStepToValidate.Type__c == WORKSTEP_TYPE_RATE_CHANGE) &&
        (xrefToValidate.Business_Reference__r.Integration_Status__c !=
        BUSINESS_REF_STATUS_SUCCESS &&
        xrefToValidate.Business_Reference__r.Integration_Status__c !=
        BUSINESS_REF_STATUS_READY_FOR_INTEGRATION));
    }

    /**
     * @description determine which Business Reference Id should be used
     * @param xref
     * @param accountIdToBusRefIdMap
     * @param businessReferences
     * @return Id
     */
    private Id getCorrectBusinessRefId(
        Xref__c xref,
        Map<Id, Id> accountIdToBusRefIdMap,
        Map<Id, Business_Reference__c> businessReferences
    ) {
        Id businessReferenceId = xref.Business_Reference__c;
        if (accountIdToBusRefIdMap.containsKey(xref.Salesforce_Account_Name__c)) {
            Id previousBusinesRefId = accountIdToBusRefIdMap.get(xref.Salesforce_Account_Name__c);
            String previousBusinessRefStatus = businessReferences.containsKey(previousBusinesRefId)
                ? businessReferences.get(previousBusinesRefId).Integration_Status__c
                : '';
            String newBusinessRefStatus = businessReferences.containsKey(xref.Business_Reference__c)
                ? businessReferences.get(xref.Business_Reference__c).Integration_Status__c
                : '';
            if (
                (previousBusinessRefStatus == BUSINESS_REF_STATUS_FAILURE) ||
                (newBusinessRefStatus == BUSINESS_REF_STATUS_SUCCESS)
            ) {
                businessReferenceId = previousBusinesRefId;
            }
        }
        return businessReferenceId;
    }

    /**
     * @description Set the status correctly for a Success
     * @param busRefIdForThisWorkStep
     * @param workStep
     * @param uow
     */
    private void setWorkStepSuccessDataForBusRefUpdate(
        Id busRefIdForThisWorkStep,
        WorkStep workStep,
        fflib_ISobjectUnitOfWork uow
    ) {
        WorkStep wsToUpdate = new WorkStep(
            Id = workStep.Id,
            Business_Reference__c = busRefIdForThisWorkStep,
            Is_Updated_By_System__c = true,
            Status__c = STATUS_COMPLETE,
            Status_Reason__c = ''
        );
        uow.registerDirty(wsToUpdate);

        if (workStep.WorkPlanId != null) {
            WorkPlan wpToUpdate = new WorkPlan(
                Id = workStep.WorkPlanId,
                Business_Reference__c = busRefIdForThisWorkStep
            );
            uow.registerDirty(wpToUpdate);
        }
    }

    /**
     * @description Set the status correctly for a Success
     * @param businessReference
     * @param workStep
     * @param uow
     */
    private void setWorkStepFailureDataForBusRefUpdate(
        Business_Reference__c businessReference,
        WorkStep workStep,
        fflib_ISobjectUnitOfWork uow
    ) {
        if (businessReference == null) {
            return;
        }
        WorkStep wsToUpdate = new WorkStep(
            Id = workStep.Id,
            Business_Reference__c = businessReference.Id,
            Is_Updated_By_System__c = true,
            Provisioning_Failure_Date_Time__c = workStep.Provisioning_Failure_Date_Time__c == null
                ? System.now()
                : workStep.Provisioning_Failure_Date_Time__c,
            Status__c = STATUS_ESCALATED,
            Status_Reason__c = WORKSTEP_BUSINESS_STATUS_REASON,
            Type__c = workStep.Type__c
        );
        setWorkStepDetailsByProvisioningCategory(
            wsToUpdate,
            businessReference.Provisioning_Error_Category__c,
            businessReference.Integration_Message__c
        );
        uow.registerDirty(wsToUpdate);
        if (workStep.WorkPlanId != null) {
            WorkPlan wpToUpdate = new WorkPlan(
                Id = workStep.WorkPlanId,
                Business_Reference__c = businessReference.Id,
                Status__c = STATUS_ESCALATED
            );
            uow.registerDirty(wpToUpdate);
        }

        if (workStep.WorkOrderId != null) {
            WorkOrder woToUpdate = new WorkOrder(
                Id = workStep.WorkOrderId,
                Provisioning_Status__c = WORK_ORDER_PROVISIONING_FAILED
            );
            uow.registerDirty(woToUpdate);
        }

        genericLogList.add(
            getGenericLog()
                .logMessage(
                    wsToUpdate.Id + ' ' + wsToUpdate.Status__c + ' ' + wsToUpdate.Status_Reason__c
                )
        );
    }

    /**
     * @description Set the status correctly for a Success
     * @param xrefStoreId
     * @param xrefId
     * @param workStep
     * @param uow
     */
    private void setWorkStepSuccessDataForXrefUpdate(
        String xrefStoreId,
        Id xrefId,
        WorkStep workStep,
        fflib_ISobjectUnitOfWork uow
    ) {
        if (workStep.Type__c != WORK_STEP_TYPE_SETUP_STOREFRONT) {
            WorkStep wsToUpdate = new WorkStep(
                Id = workStep.Id,
                Is_Updated_By_System__c = true,
                Status__c = STATUS_COMPLETE,
                Status_Reason__c = '',
                Status_Reason_Details__c = ''
            );
            //LEM-16576 - Set the status to 'Ready for QA' for 'Rate Change' Work Steps of 'SMB' Work Order.
            if (
                workStep.WorkOrder.Segment__c == SEGMENT_SMB &&
                workStep.Type__c == WORKSTEP_TYPE_RATE_CHANGE
            ) {
                wsToUpdate.Status__c = STATUS_READY_FOR_QA;
            }
            uow.registerDirty(wsToUpdate);

            if (workStep.WorkPlanId != null) {
                WorkPlan wpToUpdate = new WorkPlan(Id = workStep.WorkPlanId, Xref__c = xrefId);
                uow.registerDirty(wpToUpdate);
            }
        }

        if (workStep.WorkOrderId != null) {
            WorkOrder woToUpdate = new WorkOrder(
                Id = workStep.WorkOrderId,
                Store_Id__c = xrefStoreId,
                Provisioning_Status__c = WORK_ORDER_PROVISIONING_COMPLETE
            );
            uow.registerDirty(woToUpdate);
        }
    }

    /**
     * @description Set the status correctly for a Success
     * In order display 'Fix It' in click and pop, we are making set up store work step as blocked as part of this ticket, LEM-11773
     * But work step also getting blocked for other provisioning failures so we had to use xref integration message
     * to filter the bizref not found failure.
     * @param xref
     * @param workStep
     * @param uow
     */
    private void setWorkStepFailureDataForXrefUpdate(
        Xref__c xref,
        WorkStep workStep,
        fflib_ISobjectUnitOfWork uow
    ) {
        if (workStep.Type__c != WORK_STEP_TYPE_SETUP_STOREFRONT) {
            String integrationMessage = xref.Integration_Message__c;
            WorkStep wsToUpdate = new WorkStep(
                Id = workStep.Id,
                Is_Updated_By_System__c = true,
                Provisioning_Failure_Date_Time__c = workStep.Provisioning_Failure_Date_Time__c ==
                    null
                    ? System.now()
                    : workStep.Provisioning_Failure_Date_Time__c,
                Type__c = workStep.Type__c
            );

            if (
                String.isNotBlank(integrationMessage) &&
                (integrationMessage.contains(CANNOT_FIND_BUS_REF_ERROR_MESSAGE) ||
                integrationMessage.contains(CANNOT_FIND_DEFAULT_BUSINESS_REF))
            ) {
                wsToUpdate.Status__c = STATUS_BLOCKED;
                wsToUpdate.Status_Reason__c = WORKSTEP_BUSINESS_REFERENCE_NOT_FOUND_STATUS_REASON;
            } else {
                wsToUpdate.Status__c = STATUS_ESCALATED;
                wsToUpdate.Status_Reason__c = WORKSTEP_STORE_STATUS_REASON;
            }
            setWorkStepDetailsByProvisioningCategory(
                wsToUpdate,
                xref.Provisioning_Error_Category__c,
                xref.Integration_Message__c
            );
            uow.registerDirty(wsToUpdate);
            if (workStep.WorkPlanId != null) {
                WorkPlan wpToUpdate = new WorkPlan(
                    Id = workStep.WorkPlanId,
                    Xref__c = xref.Id,
                    Status__c = STATUS_ESCALATED
                );
                uow.registerDirty(wpToUpdate);
            }

            genericLogList.add(
                getGenericLog()
                    .logMessage(
                        wsToUpdate.Id +
                            ' ' +
                            wsToUpdate.Status__c +
                            ' ' +
                            wsToUpdate.Status_Reason__c
                    )
            );
        }

        if (workStep.WorkOrderId != null) {
            WorkOrder woToUpdate = new WorkOrder(
                Id = workStep.WorkOrderId,
                Store_Id__c = xref.External_ID__c,
                Provisioning_Status__c = WORK_ORDER_PROVISIONING_FAILED
            );
            uow.registerDirty(woToUpdate);
        }
    }

    /**
     * @description Pulls a map of AccountId to Business Reference Id from a list of Xrefs
     * @param xRefList
     * @return Map<Id, Id>
     */
    private Map<Id, Id> getAccountIdToBusinessReferenceIdMap(List<Xref__c> xRefList) {
        Map<Id, Id> accountIdToBusRefIdMap = new Map<Id, Id>();
        for (Xref__c xref : xRefList) {
            accountIdToBusRefIdMap.put(xref.Salesforce_Account_Name__c, xref.Business_Reference__c);
        }
        return accountIdToBusRefIdMap;
    }

    /**
     * @description Pulls a map of AccountId to Business Reference Id from a list of Xrefs
     * @param accountIdToBusRefIdMap
     * @param ws
     * @return Id
     */
    private Id getBusinessReferenceId(Map<Id, Id> accountIdToBusRefIdMap, WorkStep ws) {
        Id busRefIdForThisWorkStep = accountIdToBusRefIdMap.containsKey(ws.Store_Account__c)
            ? accountIdToBusRefIdMap.get(ws.Store_Account__c)
            : null;
        return busRefIdForThisWorkStep;
    }

    /**
     * @description Pulls a map of AccountId to Business Reference Id from a list of Xrefs
     * @param busRefIdForThisWorkStep
     * @param businessReferences
     * @return String
     */
    private String getBusinessReferenceStatus(
        Id busRefIdForThisWorkStep,
        Map<Id, Business_Reference__c> businessReferences
    ) {
        String busRefStatus = ((busRefIdForThisWorkStep != null) &&
            businessReferences.containsKey(busRefIdForThisWorkStep))
            ? businessReferences.get(busRefIdForThisWorkStep).Integration_Status__c
            : '';
        return busRefStatus;
    }

    /**
     * @description Commits work on the UOW, and handles exceptions
     * @param uow
     */
    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
            publishGenericLog();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            genericLogList.add(getGenericLog().logException(ex));
            publishGenericLog();
            throw ex;
        }
    }

    /**
     * @description It sets the Status Reason and Status Reason Details on the passed Work Step
     * based on the Business Friendly Mapping corresponding to the passed
     * Provisioning Error Category and Integration Message.
     * @param workStep
     * @param provisioningErrorCategory
     * @param integrationMessage
     */
    private void setWorkStepDetailsByProvisioningCategory(
        WorkStep workStep,
        String provisioningErrorCategory,
        String integrationMessage
    ) {
        Status_Reason_And_Details_Mapping__mdt statusReasonAndDetailsMapping;
        if (
            provisioningCategoryToStatusReasonAndDetailsMappings.isEmpty() ||
            String.isBlank(provisioningErrorCategory)
        ) {
            return;
        }

        if (
            provisioningCategoryToStatusReasonAndDetailsMappings.containsKey(workStep.Type__c) &&
            provisioningCategoryToStatusReasonAndDetailsMappings.get(workStep.Type__c)
                .containsKey(provisioningErrorCategory)
        ) {
            statusReasonAndDetailsMapping = provisioningCategoryToStatusReasonAndDetailsMappings.get(
                    workStep.Type__c
                )
                .get(provisioningErrorCategory);
        }
        /**
         * Overrides the Status and Status Reason on WorkStep when a Status Reason And Detail
         * Mapping is found.
         */
        if (statusReasonAndDetailsMapping != null) {
            workStep.Status__c = statusReasonAndDetailsMapping.Status__c;
            workStep.Status_Reason__c = statusReasonAndDetailsMapping.Status_Reason__c;
            workStep.Status_Reason_Details__c = integrationMessage;
        }
    }

    /**
     * @description Get log instance of IGenericLogEntry implementation
     * @return instance of IGenericLogEntry imlementation
     */
    @TestVisible
    private static IGenericLogEntry getGenericLog() {
        return GenericLoggerService.createGenericLog(
            LOG_SERVICE_WORK_STEP,
            LOG_DOMAIN_PROVISIONING,
            GenericLogEntry.SeverityLevel.HIGH
        );
    }

    /**
     * @description Publish log instances added to list
     */
    @TestVisible
    private static void publishGenericLog() {
        GenericLoggerService.publish(genericLogList);
        genericLogList.clear();
    }
}