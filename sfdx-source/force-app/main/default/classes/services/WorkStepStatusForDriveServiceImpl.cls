/**
 * @author atg
 * @date 07/26/2022
 * @description Service class for WorkStep related logic when Business Reference or Xref objects are integrated.
 */
public with sharing class WorkStepStatusForDriveServiceImpl implements IWorkStepStatusForDriveService {
    @testVisible
    private static final String ACCOUNT_RECORD_TYPE_STORE = 'Store';
    private static final String BUSINESS_REF_STATUS_SUCCESS = 'Success';
    @testVisible
    private static final String XREF_SUCCESS_STATUS = 'Success';
    private static final String XREF_STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    @testVisible
    private static final String BUSINESS_REF_STATUS_FAILURE = 'Failure';
    private static final String BUSINESS_REF_STATUS_NEW = 'New';
    private static final String BUSINESS_REF_STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String STATUS_COMPLETE = 'Complete';
    private static final String STATUS_ESCALATED = 'Escalated';
    private static final String NOT_STARTED = 'Not Started';
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
    private static final String WORKORDER_TYPE_COO = 'COO';
    private static final String EXTERNAL_ID_SOURCE_DRIVEDB = 'DriveDb';
    private static final String LAST_COMPLETED_CONFIGURATION_CREATED = 'Business Configuration Created';
    private static final String LAST_COMPLETED_USER_CREATED = 'Business and User Created';
    private static final String LAST_COMPLETED_WITHHOLDING = 'Drive Withholding Business Request Processed';
    private static final String ACCOUNT_RECORD_TYPE_BUSINESS = 'Business';
    private static final String WORKORDER_SUBTYPE_AUTO_ACTIVATION = 'Auto-Activations';
    private static final String WORKORDER_SUBTYPE_NET_NEW_BUSINESS = 'Net-new business';
    private static final String WORKORDER_SUBTYPE_WITHHOLDING = 'Withholding';
    private static final String LAST_COMPLETED_STEP = 'Last Completed Step: ';
    private static final String WORK_STEP_STATUS_REASON_BUSINESS_ID_PROVISION_FAILED = 'Business Provisioning Failed - Please refer to Provisioning Errors tab';
    private static final String WORK_STEP_STATUS_REASON_STORE_ID_PROVISIONING = 'Store Provisioning Failed - Please refer to Provisioning Errors tab';
    private Map<Id, Business_Reference__c> xRefIdToBusinessReference;
    private Map<Id, Xref__c> accountIdToXref;
    private static final String EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION = 'EBID_INTEGRATE';
    private static final String LOG_SERVICE_WORK_STEP = 'Work Step Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private List<IGenericLogEntry> genericLogList = new List<IGenericLogEntry>();
    private enum StatusList {
        BUSINESS_REF_STATUS_SUCCESS,
        BUSINESS_REF_STATUS_FAILURE,
        BUSINESS_REF_STATUS_NEW,
        BUSINESS_REF_STATUS_READY_FOR_INTEGRATION
    }
    private static final Map<String, StatusList> STATUSMAPPINGS = new Map<String, StatusList>{
        BUSINESS_REF_STATUS_SUCCESS => StatusList.BUSINESS_REF_STATUS_SUCCESS,
        BUSINESS_REF_STATUS_FAILURE => StatusList.BUSINESS_REF_STATUS_FAILURE,
        BUSINESS_REF_STATUS_NEW => StatusList.BUSINESS_REF_STATUS_NEW,
        BUSINESS_REF_STATUS_READY_FOR_INTEGRATION => StatusList.BUSINESS_REF_STATUS_READY_FOR_INTEGRATION
    };
    private static final String AUTOMATIC = 'Automatic';
    private static final Set<String> WORK_ORDER_SUB_TYPES_TO_UPDATE_DRIVE_FAILURE = new Set<String>{
        WORKORDER_SUBTYPE_AUTO_ACTIVATION,
        WORKORDER_SUBTYPE_NET_NEW_BUSINESS,
        WORKORDER_SUBTYPE_WITHHOLDING
    };
    private static final Set<String> WORK_ORDER_SUB_TYPES_TO_UPDATE_DRIVE_WITHHOLDING_SUCCESS = new Set<String>{
        WORKORDER_SUBTYPE_AUTO_ACTIVATION,
        WORKORDER_SUBTYPE_WITHHOLDING
    };

    private enum LASTCOMPLETEDSTEPVALUES {
        CONFIGURATION_CREATED,
        WITHHOLDING
    }
    private static final Map<String, LASTCOMPLETEDSTEPVALUES> LASTCOMPLETEDSTEPMAPPINGS = new Map<String, LASTCOMPLETEDSTEPVALUES>{
        LAST_COMPLETED_CONFIGURATION_CREATED => LASTCOMPLETEDSTEPVALUES.CONFIGURATION_CREATED,
        LAST_COMPLETED_WITHHOLDING => LASTCOMPLETEDSTEPVALUES.WITHHOLDING
    };

    /**
     * @description Default Consturctor to instantiate variables.
     */
    public WorkStepStatusForDriveServiceImpl() {
        this.accountIdToXref = new Map<Id, Xref__c>();
        this.xRefIdToBusinessReference = new Map<Id, Business_Reference__c>();
    }

    /**
     * @description Updates WorkStep Status when Business References Integration Status updates
     * @JIRA# LEM-3166
     * @param busReferIdToBusRefRecMap
     */
    public void updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
        Map<Id, Business_Reference__c> busReferIdToBusRefRecMap
    ) {
        List<Xref__c> xrefsForBusinessReferences = XrefsSelector.newInstance()
            .selectAllMatchingBusinessReference(busReferIdToBusRefRecMap.keySet());

        if (xrefsForBusinessReferences.isEmpty()) {
            return;
        }

        processSetupBusinessWorkStepStatusUpdatesForDrive(
            xrefsForBusinessReferences,
            busReferIdToBusRefRecMap
        );
    }

    /**
     * @description Updates WorkStep Status when Buisness Reference records were Updated of Type Drive.
     * @JIRA# LEM-3166
     * @param xrefsForBusinessReferences
     * @param businessReferenceIdToBrefRecMap
     */
    private void processSetupBusinessWorkStepStatusUpdatesForDrive(
        List<Xref__c> xrefsForBusinessReferences,
        Map<Id, Business_Reference__c> businessReferenceIdToBrefRecMap
    ) {
        Map<Id, Business_Reference__c> accountIdToBusRefRecMap = getAccountIdToBusinessReferenceRecordMap(
            xrefsForBusinessReferences,
            businessReferenceIdToBrefRecMap
        );
        Map<Id, Business_Reference__c> businessReferencesToExternalNotifierEvents = new Map<Id, Business_Reference__c>();

        for (Xref__c eachXref : xrefsForBusinessReferences) {
            accountIdToXref.put(eachXref.Salesforce_Account_Name__c, eachXref);
        }
        List<WorkStep> workStepList = new List<WorkStep>();
        workStepList = WorkStepsSelector.newInstance()
            .getNonCompleteWorkStepRecForDriveByBusinessAccount(accountIdToBusRefRecMap.keySet());
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (WorkStep ws : workStepList) {
            Business_Reference__c busRefRecForThisWorkStep = accountIdToBusRefRecMap.containsKey(
                    ws.WorkOrder.AccountID
                )
                ? accountIdToBusRefRecMap.get(ws.WorkOrder.AccountID)
                : null;
            String busRefStatus = busRefRecForThisWorkStep.Integration_Status__c;
            String busRefLastCompletedStep = busRefRecForThisWorkStep.Last_Completed_Step__c;
            Xref__c xrefForThisWorkStep = accountIdToXref?.get(ws.WorkOrder.AccountID);

            switch on STATUSMAPPINGS.get(busRefStatus) {
                when BUSINESS_REF_STATUS_SUCCESS {
                    if (xrefForThisWorkStep?.Integration_Status__c == XREF_SUCCESS_STATUS) {
                        setWorkStepSuccessDataForBusRefUpdate(busRefRecForThisWorkStep, ws, uow);
                    }
                    if (
                        busRefLastCompletedStep == LAST_COMPLETED_USER_CREATED &&
                        ws.WorkOrder.Sub_Type__c == WORKORDER_SUBTYPE_AUTO_ACTIVATION
                    ) {
                        businessReferencesToExternalNotifierEvents.put(
                            busRefRecForThisWorkStep.Id,
                            busRefRecForThisWorkStep
                        );
                    }
                }
                when else {
                    if (
                        isXrefEligibleForBusinessReferenceFailureStatusUpdate(xrefForThisWorkStep)
                    ) {
                        setWorkStepFailureDataForBusRefUpdateForDrive(
                            busRefRecForThisWorkStep,
                            ws,
                            uow
                        );
                    }
                }
            }
        }
        if (!businessReferencesToExternalNotifierEvents.isEmpty()) {
            // Fire External Notifier Events on success
            BusReferenceIntegrationService.createIntegrationPlatformEvents(
                businessReferencesToExternalNotifierEvents.values(),
                EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION
            );
        }

        commitWork(uow);
    }

    /**
     * @description Pulls a map of AccountId to Business Reference record from a list of Xrefs
     * @param xRefList
     * @param businessReferenceRecToStatusMap
     * @return Map<Id, Id>
     */
    private Map<Id, Business_Reference__c> getAccountIdToBusinessReferenceRecordMap(
        List<Xref__c> xRefList,
        Map<Id, Business_Reference__c> businessReferenceRecToStatusMap
    ) {
        //If there are multiple xrefs for the same account, and these Xrefs have different Business Reference lookups, we will choose a
        //business reference that has a Failed Status, so we know which Work Orders need to be ESCALATED.  Otherwise we will set the first
        //Business Reference object since they were all successful.
        Map<Id, Business_Reference__c> accountIdToBusRefIdMap = new Map<Id, Business_Reference__c>();
        for (Xref__c xref : xRefList) {
            if (xref.Salesforce_Account_Name__c != null) {
                Business_Reference__c businesRefRec = getCorrectBusinessRefRec(
                    xref,
                    accountIdToBusRefIdMap,
                    businessReferenceRecToStatusMap
                );
                accountIdToBusRefIdMap.put(xref.Salesforce_Account_Name__c, businesRefRec);
            }
        }
        return accountIdToBusRefIdMap;
    }

    /**
     * @description determine which Business Reference Record should be used
     * @param xref
     * @param accountIdToBusRefRecMap
     * @param businessReferenceIdToStatusMap
     * @return Id
     */
    private Business_Reference__c getCorrectBusinessRefRec(
        Xref__c xref,
        Map<Id, Business_Reference__c> accountIdToBusRefRecMap,
        Map<Id, Business_Reference__c> businessReferenceIdToStatusMap
    ) {
        Business_Reference__c businessReferenceRec = businessReferenceIdToStatusMap.containsKey(
                xref.Business_Reference__c
            )
            ? businessReferenceIdToStatusMap.get(xref.Business_Reference__c)
            : new Business_Reference__c();

        if (accountIdToBusRefRecMap.containsKey(xref.Salesforce_Account_Name__c)) {
            Business_Reference__c previousBusinesRefRec = accountIdToBusRefRecMap.get(
                xref.Salesforce_Account_Name__c
            );
            String previousBusinessRefStatus = previousBusinesRefRec.Integration_Status__c;
            String newBusinessRefStatus = businessReferenceRec.Integration_Status__c;

            if (
                (previousBusinessRefStatus == BUSINESS_REF_STATUS_FAILURE) ||
                (newBusinessRefStatus == BUSINESS_REF_STATUS_SUCCESS)
            ) {
                businessReferenceRec = previousBusinesRefRec;
            }
        }
        return businessReferenceRec;
    }

    /**
     * @description It checks whether the passed Work Step is eligible to set 'Complete'
     * according to the Last Completed Step of the passed Business Reference.
     * @param businessReferenceToValidate
     * @param workStepToValidate
     * @return Boolean
     */
    private Boolean isWorkStepEligibleToSetSuccess(
        Business_Reference__c businessReferenceToValidate,
        WorkStep workStepToValidate
    ) {
        Boolean isEligible = false;
        switch on
            LASTCOMPLETEDSTEPMAPPINGS.get(businessReferenceToValidate.Last_Completed_Step__c) {
            when CONFIGURATION_CREATED {
                isEligible =
                    workStepToValidate.WorkOrder.Sub_Type__c == WORKORDER_SUBTYPE_AUTO_ACTIVATION;
            }
            when WITHHOLDING {
                isEligible = WORK_ORDER_SUB_TYPES_TO_UPDATE_DRIVE_WITHHOLDING_SUCCESS.contains(
                    workStepToValidate.WorkOrder.Sub_Type__c
                );
            }
        }
        return isEligible;
    }

    /**
     * @description It checks whether the passed Xref is eligible for status roll-up
     * when Business Reference's Integration Status is set to 'Failure'.
     * @param xrefInstance
     * @return Boolean
     */
    private Boolean isXrefEligibleForBusinessReferenceFailureStatusUpdate(Xref__c xrefInstance) {
        return (xrefInstance?.Salesforce_Account_Name__r.Record_Type_Name__c ==
            ACCOUNT_RECORD_TYPE_STORE &&
            xrefInstance?.Integration_Status__c == XREF_STATUS_WAITING_FOR_BUSINESS) ||
            (xrefInstance?.Salesforce_Account_Name__r.Record_Type_Name__c ==
            ACCOUNT_RECORD_TYPE_BUSINESS);
    }

    /**
     * @description the status correctly for WorkOrder and Workstep when Successful Business Refrence is update to success
     * @param busRefRecForThisWorkStep
     * @param workStep
     * @param uow
     */
    private void setWorkStepSuccessDataForBusRefUpdate(
        Business_Reference__c busRefRecForThisWorkStep,
        WorkStep workStep,
        fflib_ISobjectUnitOfWork uow
    ) {
        if (isWorkStepEligibleToSetSuccess(busRefRecForThisWorkStep, workStep)) {
            updateWorkStep(workStep.Id, busRefRecForThisWorkStep.Id, STATUS_COMPLETE, uow);
            updateWorkOrder(workStep.WorkOrderId, WORK_ORDER_PROVISIONING_COMPLETE, uow);
            updateWorkPlan(
                workStep.WorkPlanId,
                busRefRecForThisWorkStep.Id,
                accountIdToXref?.get(workStep.Store_Account__c)?.Id,
                uow
            );
        } else if (
            workStep.WorkOrder.Sub_Type__c == WORKORDER_SUBTYPE_NET_NEW_BUSINESS &&
            workStep.WorkOrder.Business_to_Store_Assignment__c == AUTOMATIC
        ) {
            if (workStep.Status__c == STATUS_ESCALATED) {
                updateWorkStep(workStep.Id, busRefRecForThisWorkStep.Id, NOT_STARTED, uow);
                updateWorkPlan(
                    workStep.WorkPlanId,
                    busRefRecForThisWorkStep.Id,
                    accountIdToXref?.get(workStep.Store_Account__c)?.Id,
                    uow
                );
            }
            updateWorkOrder(workStep.WorkOrderId, WORK_ORDER_PROVISIONING_COMPLETE, uow);
        }
    }

    /**
     * @description Set the status correctly for WorkOrder and Workstep when Successful Business Refrence is update to fail
     * @param busRefRecForThisWorkStep
     * @param workStep
     * @param uow
     */
    private void setWorkStepFailureDataForBusRefUpdateForDrive(
        Business_Reference__c busRefRecForThisWorkStep,
        WorkStep workStep,
        fflib_ISobjectUnitOfWork uow
    ) {
        if (WORK_ORDER_SUB_TYPES_TO_UPDATE_DRIVE_FAILURE.contains(workStep.WorkOrder.Sub_Type__c)) {
            String lastCompletedStep = (busRefRecForThisWorkStep.Last_Completed_Step__c) != null
                ? busRefRecForThisWorkStep.Last_Completed_Step__c
                : '';
            WorkStep wsToUpdate = new WorkStep(
                Id = workStep.Id,
                Business_Reference__c = busRefRecForThisWorkStep.Id,
                Status__c = STATUS_ESCALATED,
                Status_Reason__c = WORK_STEP_STATUS_REASON_BUSINESS_ID_PROVISION_FAILED,
                Status_Reason_Details__c = String.isNotBlank(lastCompletedStep)
                    ? LAST_COMPLETED_STEP + lastCompletedStep
                    : ''
            );
            uow.registerDirty(wsToUpdate);
            genericLogList.add(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_WORK_STEP,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logMessage(
                        wsToUpdate.Status__c +
                        ' ' +
                        wsToUpdate.Status_Reason__c +
                        ' ' +
                        wsToUpdate.Status_Reason_Details__c
                    )
            );

            updateWorkOrder(workStep.WorkOrderId, WORK_ORDER_PROVISIONING_FAILED, uow);
            updateWorkPlan(
                workStep.WorkPlanId,
                busRefRecForThisWorkStep.Id,
                accountIdToXref?.get(workStep.Store_Account__c)?.Id,
                uow
            );
        }
    }

    /**
     * @description Updates WorkStep Status when Xref Integration Status updates for type Drive
     * @JIRA# LEM-3166
     * @param busRefIdXrefRecMap
     */
    public void updateWorkStepsStatusOnXrefStatusChangeForDrive(
        Map<Id, List<Xref__c>> busRefIdXrefRecMap
    ) {
        Map<Id, Xref__c> filteredXrefs = new Map<Id, Xref__c>();

        List<Business_Reference__c> busRefFromXrefId = BusinessReferencesSelector.newInstance()
            .selectByBusRefId(busRefIdXrefRecMap.keySet());

        //Each Business_Reference__c can have multiple Xrefs associated.
        for (Business_Reference__c brefRec : busRefFromXrefId) {
            List<Xref__c> xrefRecRelatedToBusRef = busRefIdXrefRecMap.get(brefRec.Id);
            if (xrefRecRelatedToBusRef.isEmpty()) {
                continue;
            }

            for (Xref__c xrefRec : xrefRecRelatedToBusRef) {
                if (
                    (brefRec.Integration_Status__c == BUSINESS_REF_STATUS_SUCCESS ||
                    brefRec.Integration_Status__c == BUSINESS_REF_STATUS_FAILURE ||
                    xrefRec.Integration_Status__c == BUSINESS_REF_STATUS_FAILURE) &&
                    brefRec.External_ID_Source__c == EXTERNAL_ID_SOURCE_DRIVEDB
                ) {
                    filteredXrefs.put(xrefRec.id, xrefRec);
                    xRefIdToBusinessReference.put(xrefRec.Id, brefRec);
                }
            }
        }

        Map<Id, Set<Id>> accountIdtoXrefIdSetMap = getAccountIdToXrefIdSetMap(
            filteredXrefs.values()
        );
        List<WorkStep> workStepList = WorkStepsSelector.newInstance()
            .getNonCompleteSetupStoreWorkStepsByStoreAccountForTypeStore(
                accountIdtoXrefIdSetMap.keySet()
            );
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        processQueryWorkstep(workStepList, filteredXrefs, accountIdtoXrefIdSetMap, uow);
        commitWork(uow);
    }

    /**
     * @description Process WorkStep record queried from WorkstepSelector to update Status when Xref Integration Status updates for type Drive
     * @JIRA# LEM-3166
     * @param workStepList
     * @param xrefMap
     * @param accountIdtoXrefIdSetMap
     * @param uow
     */
    private void processQueryWorkstep(
        List<Workstep> workStepList,
        Map<Id, Xref__c> xrefMap,
        Map<Id, Set<Id>> accountIdtoXrefIdSetMap,
        fflib_ISobjectUnitOfWork uow
    ) {
        for (WorkStep ws : workStepList) {
            set<Id> xrefIdForThisWorkStep = accountIdtoXrefIdSetMap.containsKey(ws.Store_Account__c)
                ? accountIdtoXrefIdSetMap.get(ws.Store_Account__c)
                : null;

            for (Id xrefId : xrefIdForThisWorkStep) {
                Xref__c xref = xrefMap.containsKey(xrefId)
                    ? xrefMap.get(xrefId)
                    : new Xref__c(External_ID_Source__c = '');
                updateUOWForWorkStepXrefForDrive(ws, xref, uow);
            }
        }
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
     * @description Set the status correctly for a Success/Failur When Account type is Store
     * @param ws
     * @param xref
     * @param uow
     */
    private void updateUOWForWorkStepXrefForDrive(
        WorkStep ws,
        Xref__c xref,
        fflib_ISobjectUnitOfWork uow
    ) {
        if (
            xref.Integration_Status__c == BUSINESS_REF_STATUS_SUCCESS &&
            xRefIdToBusinessReference?.get(xref.Id)?.Integration_Status__c ==
            BUSINESS_REF_STATUS_SUCCESS
        ) {
            setWorkStepSuccessDataForXrefUpdateForDrive(xref.External_ID__c, xref.Id, ws, uow);
        } else if (xref.Integration_Status__c == BUSINESS_REF_STATUS_FAILURE) {
            setWorkStepFailureDataForXrefUpdateForDrive(xref.External_ID__c, xref.Id, ws, uow);
        }
    }

    /**
     * @description Set the status correctly for a Success for WorkStep and WorkOrder correctly
     * @param xrefStoreId
     * @param xrefId
     * @param workStep
     * @param uow
     */
    private void setWorkStepSuccessDataForXrefUpdateForDrive(
        String xrefStoreId,
        Id xrefId,
        WorkStep workStep,
        fflib_ISobjectUnitOfWork uow
    ) {
        if (
            workStep.WorkOrder.Sub_Type__c == WORKORDER_SUBTYPE_AUTO_ACTIVATION &&
            xRefIdToBusinessReference?.get(xrefId)?.Last_Completed_Step__c ==
            LAST_COMPLETED_CONFIGURATION_CREATED
        ) {
            updateWorkStep(
                workStep.Id,
                xRefIdToBusinessReference?.get(xrefId)?.Id,
                STATUS_COMPLETE,
                uow
            );
            updateWorkOrder(workStep.WorkOrderId, WORK_ORDER_PROVISIONING_COMPLETE, uow);
            updateWorkPlan(
                workStep.WorkPlanId,
                xRefIdToBusinessReference?.get(xrefId)?.Id,
                xrefId,
                uow
            );
        } else if (
            workStep.WorkOrder.Sub_Type__c == WORKORDER_SUBTYPE_NET_NEW_BUSINESS &&
            workStep.WorkOrder.Business_to_Store_Assignment__c == AUTOMATIC
        ) {
            if (workStep.Status__c == STATUS_ESCALATED) {
                updateWorkStep(
                    workStep.Id,
                    xRefIdToBusinessReference?.get(xrefId)?.Id,
                    NOT_STARTED,
                    uow
                );
                updateWorkPlan(
                    workStep.WorkPlanId,
                    xRefIdToBusinessReference?.get(xrefId)?.Id,
                    xrefId,
                    uow
                );
            }
            updateWorkOrder(workStep.WorkOrderId, WORK_ORDER_PROVISIONING_COMPLETE, uow);
        }
    }

    /**
     * @description Set the status for WorkStep and WorkOrder correctly for a Success
     * @param xrefStoreId
     * @param xrefId
     * @param workStep
     * @param uow
     */
    private void setWorkStepFailureDataForXrefUpdateForDrive(
        String xrefStoreId,
        Id xrefId,
        WorkStep workStep,
        fflib_ISobjectUnitOfWork uow
    ) {
        if (
            (workStep.WorkOrder.Sub_Type__c == WORKORDER_SUBTYPE_AUTO_ACTIVATION ||
            workStep.WorkOrder.Sub_Type__c == WORKORDER_SUBTYPE_NET_NEW_BUSINESS)
        ) {
            WorkStep wsToUpdate = new WorkStep(
                Id = workStep.Id,
                Status__c = STATUS_ESCALATED,
                Status_Reason__c = WORK_STEP_STATUS_REASON_STORE_ID_PROVISIONING
            );
            uow.registerDirty(wsToUpdate);

            genericLogList.add(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_WORK_STEP,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logMessage(wsToUpdate.Status__c + ' ' + wsToUpdate.Status_Reason__c)
            );

            updateWorkOrder(workStep.WorkOrderId, WORK_ORDER_PROVISIONING_FAILED, uow);
            updateWorkPlan(
                workStep.WorkPlanId,
                xRefIdToBusinessReference?.get(xrefId)?.Id,
                xrefId,
                uow
            );
        }
    }

    /**
     * @description Commits work on the UOW, and handles exceptions
     * @param uow
     */
    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();

            GenericLoggerService.publish(genericLogList);
            genericLogList.clear();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));

            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_WORK_STEP,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(ex)
            );

            throw ex;
        }
    }

    /**
     * @description To update work step with correct business reference and status values.
     * @param workStep
     * @param businessRef
     * @param status
     * @param uow
     */
    private void updateWorkStep(
        Id workStep,
        Id businessRef,
        String status,
        fflib_ISobjectUnitOfWork uow
    ) {
        WorkStep wsToUpdate = new WorkStep(
            Id = workStep,
            Business_Reference__c = businessRef,
            Status__c = status,
            Status_Reason__c = ''
        );
        uow.registerDirty(wsToUpdate);
    }

    /**
     * @description To update work order with correct provisioning status.
     * @param workOrder
     * @param provisioningStatus
     * @param uow
     */
    private void updateWorkOrder(
        Id workOrder,
        String provisioningStatus,
        fflib_ISobjectUnitOfWork uow
    ) {
        WorkOrder woToUpdate = new WorkOrder(
            Id = workOrder,
            Provisioning_Status__c = provisioningStatus
        );
        uow.registerDirty(woToUpdate);
    }

    /**
     * @description To update work plan with correct business reference and xref values.
     * @param workPlan
     * @param businessRef
     * @param xref
     * @param uow
     */
    private void updateWorkPlan(
        Id workPlan,
        Id businessRef,
        Id xref,
        fflib_ISobjectUnitOfWork uow
    ) {
        WorkPlan wpToUpdate = new WorkPlan(
            Id = workPlan,
            Business_Reference__c = businessRef,
            Xref__c = xref
        );
        uow.registerDirty(wpToUpdate);
    }
}