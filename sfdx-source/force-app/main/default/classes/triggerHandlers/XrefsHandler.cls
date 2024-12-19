/**
 * @description LEM-1911 Xrefs__c Object Trigger Handler
 * @author ATG
 * @date 2022-06-29
 */
public class XrefsHandler extends ApplicationDomainHandler {
    public static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String EVENT_TOPIC_UPDATE_WORKSTEP_STATUS = 'UPDATE_SETUP_BUSINESS_WORKSTEP_STATUS';
    public static final String STATUS_SUCCESS = 'Success';
    public static final String STATUS_FAILURE = 'Failure';
    public static final String STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String STATUS_READY_FOR_COO_INTEGRATION = 'Ready for COO Integration';
    private static final String STATUS_COO_SUCCESS = 'COO Success';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_IN_ACTIVE = 'Inactive';
    private static final String STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String RATE_CHANGE_REQUEST_PAYLOAD_CHUNK_SIZE = 'Rate_Change_Request_Payload_Chunk_Size';
    private static final String SETUP_BUSINESS_WORKSTEP_UPDATE_PAYLOAD_CHUNK_SIZE = 'Setup_Business_WS_Payload_Chunk_Size';
    private static final String EVENT_TOPIC_UPDATE_RATE_CHANGE_REQUEST = 'UPDATE_RATE_CHANGE_REQUEST';
    private static final String XREF_STATUS_FIELD_API_NAME = 'Xref_Status__c';

    private static final String EXTERNAL_NOTIFIER_TOPIC_XREF_INTEGRATION = 'XREF_INTEGRATE';
    private static final String EXTERNAL_NOTIFIER_TOPIC_XREF_DEACTIAVTE_COO = 'XREF_DEACTIVATE_COO';
    private static final String EXTERNAL_NOTIFIER_TOPIC_XREF_INTEGRATE_COO = 'XREF_INTEGRATE_COO';

    @testVisible
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    @testVisible
    private static final String EXTERNAL_ID_SOURCE_MDS_CATERING = 'MDS - Catering';
    private static final Set<String> MARKETPLACE_EXTERNAL_ID_SOURCE_SET = new Set<String>{
        EXTERNAL_ID_SOURCE_MDS,
        EXTERNAL_ID_SOURCE_MDS_CATERING
    };

    private static final String XREF_ACCOUNT_RECORD_TYPE_STORE = 'Store';
    private static final String LAST_COMPLETED_CONFIGURATION_CREATED = 'Business Configuration Created';
    public static final String EXTERNAL_ID_SOURCE_DRIVE_DB = 'DriveDb';
    private enum XREFSTATUSES {
        COOSUCCESS,
        FAILURE,
        SUCCESS,
        WAITINGFORBUSINESS
    }
    private static final Map<String, XREFSTATUSES> XREFSTATUSMAPPINGS = new Map<String, XREFSTATUSES>{
        STATUS_COO_SUCCESS => XREFSTATUSES.COOSUCCESS,
        STATUS_FAILURE => XREFSTATUSES.FAILURE,
        STATUS_SUCCESS => XREFSTATUSES.SUCCESS,
        STATUS_WAITING_FOR_BUSINESS => XREFSTATUSES.WAITINGFORBUSINESS
    };

    /**
     * @description Constructor Method
     * @param sObjectList - Contract Record List
     */
    public XrefsHandler(List<Xref__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Xref__c.SObjectType, XrefsHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return ContractHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new XrefsHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform after insert processing
     * Only automation will be inserting records with an Integration Status that is not 'New'.
     */
    public override void onAfterInsert() {
        List<Xref__c> insertedRecords = (List<Xref__c>) getRecords();
        sendIntegrationPlatformEvents(insertedRecords);

        sendUpdatesBasedOnStatus(insertedRecords, true);
        updateSetupBusinessWorkSteps(insertedRecords, true);
        checkChangesOnXrefForActiveMDS(insertedRecords);
        Xrefs.newInstance(insertedRecords)
            .invokeBrandOnBusinessReferencesByXrefs(getAccountIdsFromInsertedXref(insertedRecords));
        //LEM-22688 - Commented this method invoking till the underlying code is optimized.
        //XrefIntegrationService.updateBusinessAccountsForXrefs(insertedRecords);
    }

    /**
     * @description Called to perform processing during the after update phase.
     * @param existingRecords - The map of old Xref__c Records
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        List<Xref__c> statusChangedRecords = (List<Xref__c>) getChangedRecords(
            new Set<SObjectField>{ Xref__c.Integration_Status__c }
        );

        List<Xref__c> activationStatusChangedRecs = (List<Xref__c>) getChangedRecords(
            new Set<SObjectField>{
                Xref__c.Xref_Status__c,
                Xref__c.MDS_Last_Synced__c,
                Xref__c.Date_of_Status_Change__c
            }
        );

        List<Xref__c> changedExternalReferences = (List<Xref__c>) getChangedRecords(
            new Set<SObjectField>{
                Xref__c.External_ID_Source__c,
                Xref__c.External_ID__c,
                Xref__c.Xref_Status__c,
                Xref__c.BusinessID__c
            }
        );
        List<Xref__c> xrefsWithChangedBusinessReference = (List<Xref__c>) getChangedRecords(
            new Set<SObjectField>{ Xref__c.Business_Reference__c }
        );
        sendIntegrationPlatformEvents(statusChangedRecords);
        sendUpdatesBasedOnStatus(statusChangedRecords, false);
        updateStoreIdsOnWorkOrders(statusChangedRecords);
        checkChangesOnXrefForActiveMDS(changedExternalReferences);
        sendRateChangeRequestPlatformEvent(existingRecords, statusChangedRecords);
        //LEM-4823 update Setup Business work steps when Business Reference is updated on Xref.
        updateSetupBusinessWorkSteps(xrefsWithChangedBusinessReference, false);
        updateStoreAccountActivationStatus(activationStatusChangedRecs, existingRecords);
        Xrefs.newInstance(xrfesWithUpdatedCooProcess()).invokeCooProcess();
        //LEM-22688 - Commented this method invoking till the underlying code is optimized.
        //XrefIntegrationService.updateBusinessAccountsForXrefs(changedExternalReferences);
    }

    /**
     * @description Called to perform processing during the before update phase.
     * @param existingRecords - The map of old Work Plans
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        Xrefs.newInstance(xrefsWithUpdatedProvisioningErrorMessage())
            .updateIntegrationMessageAndProvisioningCategory();
    }

    private List<Xref__c> xrefsWithUpdatedProvisioningErrorMessage() {
        return new List<Xref__c>(
            (List<Xref__c>) getChangedRecords(
                new Set<SObjectField>{ Xref__c.Provisioning_Error_Message__c }
            )
        );
    }

    /**
     * @description Called to Create busRefIdXrefRecMap.
     * @param xref
     * @param busRefIdXrefRecMap
     */
    private void createBusRefRecXrefMap(Xref__c xref, Map<Id, List<Xref__c>> busRefIdXrefRecMap) {
        if (
            (xref.Integration_Status__c == STATUS_FAILURE ||
            xref.Integration_Status__c == STATUS_SUCCESS) &&
            xref.Account_Record_Type__c == XREF_ACCOUNT_RECORD_TYPE_STORE
        ) {
            if (
                busRefIdXrefRecMap.containsKey(xref.Business_Reference__c) &&
                busRefIdXrefRecMap.get(xref.Business_Reference__c) != null
            ) {
                List<Xref__c> allXrefOfBussRefRec = busRefIdXrefRecMap.get(
                    xref.Business_Reference__c
                );
                allXrefOfBussRefRec.add(xref);
                busRefIdXrefRecMap.put(xref.Business_Reference__c, allXrefOfBussRefRec);
            } else {
                busRefIdXrefRecMap.put(xref.Business_Reference__c, new List<Xref__c>{ xref });
            }
        }
    }

    /**
     * @description Called to Create busRefIdXrefRecMap.
     * @param changedXrefs
     */
    private void checkChangesOnXrefForActiveMDS(List<Xref__c> changedXrefs) {
        Boolean isXrefEligibleForMDSActivationOnAccount = false;
        Set<Id> accountsToBeDeactivated = new Set<Id>();
        Set<Id> accountsToBeUpdated = new Set<Id>();
        List<Account> accountsToBeUpdatedWithMDSXrefs = new List<Account>();
        if (changedXrefs.isEmpty()) {
            return;
        }
        for (Xref__c eachReference : changedXrefs) {
            if (eachReference.External_ID_Source__c != EXTERNAL_ID_SOURCE_MDS) {
                continue;
            }
            isXrefEligibleForMDSActivationOnAccount =
                eachReference.External_ID__c != null &&
                eachReference.BusinessID__c != null &&
                eachReference.Xref_Status__c == STATUS_ACTIVE;
            if (isXrefEligibleForMDSActivationOnAccount) {
                accountsToBeUpdated.add(eachReference.Salesforce_Account_Name__c);
                accountsToBeUpdatedWithMDSXrefs.add(
                    new Account(
                        Id = eachReference.Salesforce_Account_Name__c,
                        Is_MDS_Activated__c = true
                    )
                );
            } else {
                accountsToBeDeactivated.add(eachReference.Salesforce_Account_Name__c);
            }
        }
        accountsToBeDeactivated.removeAll(accountsToBeUpdated);
        accountsToBeDeactivated = AccountsService.checkAccountsForDeactivation(
            accountsToBeDeactivated
        );
        if (accountsToBeDeactivated != null) {
            for (Id eachId : accountsToBeDeactivated) {
                accountsToBeUpdatedWithMDSXrefs.add(
                    new Account(Id = eachId, Is_MDS_Activated__c = false)
                );
            }
        }

        AccountsService.updateAccountsForActivatingAndDeactivatingMDSXrefs(
            accountsToBeUpdatedWithMDSXrefs
        );
    }

    private void sendIntegrationPlatformEvents(List<Xref__c> xrefList) {
        List<Xref__c> readyForIntegrationRecords = new List<Xref__c>();
        List<Xref__c> readyForCooIntegrationRecords = new List<Xref__c>();
        List<Xref__c> readyForCooDeactivateRecords = new List<Xref__c>();
        for (Xref__c xref : xrefList) {
            if (xref.Integration_Status__c == STATUS_READY_FOR_INTEGRATION) {
                //LEM-4279 an Xref that had been through a COO, but then amended was passing the wrong topic.
                if ((xref.Inactive_Xref__c != null) && (String.isBlank(xref.External_ID__c))) {
                    readyForCooIntegrationRecords.add(xref);
                } else {
                    readyForIntegrationRecords.add(xref);
                }
            }
            if (xref.Integration_Status__c == STATUS_READY_FOR_COO_INTEGRATION) {
                readyForCooDeactivateRecords.add(xref);
            }
        }

        //Send Normal Xref integrate call
        XrefIntegrationService.createIntegrationPlatformEvents(
            readyForIntegrationRecords,
            EXTERNAL_NOTIFIER_TOPIC_XREF_INTEGRATION
        );

        //Send COO New Xref record integrate call
        XrefIntegrationService.createIntegrationPlatformEvents(
            readyForCooIntegrationRecords,
            EXTERNAL_NOTIFIER_TOPIC_XREF_INTEGRATE_COO
        );

        //Send Deactivate Xref integrate call
        XrefIntegrationService.createIntegrationPlatformEvents(
            readyForCooDeactivateRecords,
            EXTERNAL_NOTIFIER_TOPIC_XREF_DEACTIAVTE_COO
        );
    }

    /**
     * @description It is used to update related records based on Integration Status.
     * @param xrefList
     * @param isInsertContext
     */
    private void sendUpdatesBasedOnStatus(List<Xref__c> xrefList, Boolean isInsertContext) {
        List<Xref__c> successRecords = new List<Xref__c>();
        List<Xref__c> successOrFailureRecords = new List<Xref__c>();
        List<Xref__c> cooSuccessRecords = new List<Xref__c>();
        Map<Id, List<Xref__c>> busRefIdXrefRecMap = new Map<Id, List<Xref__c>>();
        for (Xref__c xref : xrefList) {
            switch on XREFSTATUSMAPPINGS.get(xref.Integration_Status__c) {
                when COOSUCCESS {
                    cooSuccessRecords.add(xref);
                }
                when FAILURE, WAITINGFORBUSINESS {
                    if (skipXrefStatusRollUpToRelatedSMBRecords(xref, isInsertContext)) {
                        continue;
                    }
                    successOrFailureRecords.add(xref);
                }
                when SUCCESS {
                    successRecords.add(xref);
                    successOrFailureRecords.add(xref);
                }
            }
            if (xref.External_ID_Source__c == EXTERNAL_ID_SOURCE_DRIVE_DB) {
                createBusRefRecXrefMap(xref, busRefIdXrefRecMap);
            }
        }

        //Process Deactivated Xrefs
        XrefIntegrationService.processCOOSuccess(cooSuccessRecords);

        if (!successOrFailureRecords.isEmpty()) {
            WorkStepIntegrationStatusService.updateWorkStepsStatusOnXrefStatusChange(
                successOrFailureRecords
            );
        }

        if (!busRefIdXrefRecMap.isEmpty()) {
            WorkStepStatusForDriveService.updateWorkStepsStatusOnXrefStatusChangeForDrive(
                busRefIdXrefRecMap
            );
        }

        if (!successRecords.isEmpty()) {
            ActivationOrdersService.activateOrderProductsOnXrefSuccess(successRecords);
        }
    }

    /**
     * @description It valiates that the current Xref is inserted for SMB Account
     * and Integration Status is 'Waiting for Business'.
     * @param xrefRecord
     * @param isInsertContext
     * @return Boolean
     */
    private Boolean skipXrefStatusRollUpToRelatedSMBRecords(
        Xref__c xrefRecord,
        Boolean isInsertContext
    ) {
        return isInsertContext &&
            xrefRecord.Integration_Status__c == STATUS_WAITING_FOR_BUSINESS &&
            xrefRecord.Account_Segment__c == ACCOUNT_SEGMENT_SMB;
    }

    /**
     * @description LEM-4823 update Setup Business Workstep if necessary
     * @param xrefList
     * @param isInsertContext
     */
    private void updateSetupBusinessWorkSteps(List<Xref__c> xrefList, Boolean isInsertContext) {
        Set<Id> xrefIdsForWorkStepStatusUpdates = new Set<Id>();
        Integer workStepStatusUpdatePayloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(SETUP_BUSINESS_WORKSTEP_UPDATE_PAYLOAD_CHUNK_SIZE)
                .Configuration_Value__c
        );

        for (Xref__c xref : xrefList) {
            if (
                isMarketplaceXref(xref) &&
                hasBusinessReference(xref) &&
                !skipXrefStatusRollUpToRelatedSMBRecords(xref, isInsertContext)
            ) {
                if (xref.Business_Reference__c != null) {
                    xrefIdsForWorkStepStatusUpdates.add(xref.Id);
                }
            }
        }
        if (!xrefIdsForWorkStepStatusUpdates.isEmpty()) {
            OnboardingActivationsEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_UPDATE_WORKSTEP_STATUS => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        xrefIdsForWorkStepStatusUpdates,
                        workStepStatusUpdatePayloadChunkSize
                    )
                }
            );
        }
    }

    private boolean isMarketplaceXref(Xref__c xref) {
        return String.isNotBlank(xref.External_ID_Source__c) &&
            MARKETPLACE_EXTERNAL_ID_SOURCE_SET.contains(xref.External_ID_Source__c);
    }

    private boolean hasBusinessReference(Xref__c xref) {
        return xref.Business_Reference__c != null;
    }

    /**
     * @description called to update store id on work order.
     * @param xrefList status changed xrefs
     */
    private void updateStoreIdsOnWorkOrders(List<Xref__c> xrefList) {
        Set<Id> accountIdsToProcess = new Set<Id>();

        for (Xref__c xref : xrefList) {
            if (
                xref.Integration_Status__c == STATUS_SUCCESS &&
                xref.Account_Record_Type__c == XREF_ACCOUNT_RECORD_TYPE_STORE &&
                xref.External_ID__c != null
            ) {
                accountIdsToProcess.add(xref.Salesforce_Account_ID__c);
            }
        }

        if (!accountIdsToProcess.isEmpty()) {
            WorkOrdersService.updateStoreIdsOnChildWorkOrders(accountIdsToProcess);
        }
    }

    /**
     * @description called to update store id on work order.
     * @param oldXRefsMap existing XRefs
     * @param xrefList status changed xrefs
     */
    private void sendRateChangeRequestPlatformEvent(
        Map<Id, SObject> oldXRefsMap,
        List<Xref__c> xrefList
    ) {
        Set<Id> rateChangeRequestIds = new Set<Id>();
        Id rcrId;

        for (Xref__c xref : xrefList) {
            Xref__c oldXRef = (Xref__c) oldXRefsMap.get(xref.Id);
            if (
                xref.Xref_Status__c == STATUS_ACTIVE &&
                xref.Integration_Status__c == STATUS_READY_FOR_INTEGRATION &&
                xref.Associated_Rate_Change_Request__c != null &&
                (oldXRef.Integration_Status__c == STATUS_SUCCESS ||
                oldXRef.Integration_Status__c == STATUS_FAILURE)
            ) {
                rcrId = Id.valueOf(xref.Associated_Rate_Change_Request__c);
                rateChangeRequestIds.add(rcrId);
            }
        }

        if (!rateChangeRequestIds.isEmpty()) {
            Integer updateRateChangeRequestPayloadChunkSize = Integer.valueOf(
                StaticConfigurationsSelector.newInstance()
                    .getInstanceValue(RATE_CHANGE_REQUEST_PAYLOAD_CHUNK_SIZE)
                    .Configuration_Value__c
            );

            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_UPDATE_RATE_CHANGE_REQUEST => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        rateChangeRequestIds,
                        updateRateChangeRequestPayloadChunkSize
                    )
                }
            );
        }
    }

    /**
     * @description retrieve Xrefs where the Coo_Process__c has changed.
     * @return List<Xref__c> list of Xrefs that have a changed Coo process
     */
    private List<Xref__c> xrfesWithUpdatedCooProcess() {
        return new List<Xref__c>(
            (List<Xref__c>) getChangedRecords(new Set<SObjectField>{ Xref__c.Coo_Process__c })
        );
    }

    private void updateStoreAccountActivationStatus(
        List<Xref__c> changedXrefs,
        Map<Id, SObject> oldRecords
    ) {
        Set<Id> accountIdActivationSet = new Set<Id>();
        Set<Id> accountIdsEligibleForDeActivation = new Set<Id>();
        for (Xref__c xref : changedXrefs) {
            Xref__c oldXref = (Xref__c) oldRecords.get(xref.Id);
            if (isEligibleForActivation(xref, oldXref)) {
                accountIdActivationSet.add(xref.Salesforce_Account_Name__c);
            } else if (
                isEligibleForDeActivation(xref, oldXref) &&
                !accountIdActivationSet.contains(xref.Salesforce_Account_Name__c)
            ) {
                accountIdsEligibleForDeActivation.add(xref.Salesforce_Account_Name__c);
            }
        }

        if (!(accountIdsEligibleForDeActivation.isEmpty() && accountIdActivationSet.isEmpty())) {
            AccountsService.processStoreAccountsMdsActivationStatus(
                accountIdActivationSet,
                accountIdsEligibleForDeActivation
            );
        }
    }

    private boolean isEligibleForActivation(Xref__c thisXref, Xref__c oldXref) {
        return thisXref.Xref_Status__c == STATUS_ACTIVE &&
            thisXref.MDS_Last_Synced__c != oldXref.MDS_Last_Synced__c &&
            thisXref.Date_of_Status_Change__c != oldXref.Date_of_Status_Change__c &&
            isMdsActivationDateModified(thisXref.MDS_Last_Synced__c, oldXref.MDS_Last_Synced__c);
    }
    private boolean isEligibleForDeActivation(Xref__c thisXref, Xref__c oldXref) {
        return thisXref.Xref_Status__c == STATUS_IN_ACTIVE &&
            thisXref.MDS_Last_Synced__c != oldXref.MDS_Last_Synced__c &&
            thisXref.Date_of_Status_Change__c != oldXref.Date_of_Status_Change__c &&
            isMdsActivationDateModified(thisXref.MDS_Last_Synced__c, oldXref.MDS_Last_Synced__c);
    }
    private boolean isMdsActivationDateModified(String newSyncJson, String oldSyncJson) {
        Map<String, String> newSyncJsonMap = (Map<String, String>) JSON.deserialize(
            newSyncJson,
            Map<String, String>.class
        );
        Map<String, String> oldSyncJsonMap = String.isNotBlank(oldSyncJson)
            ? (Map<String, String>) JSON.deserialize(oldSyncJson, Map<String, String>.class)
            : null;
        return (newSyncJsonMap.containsKey(XREF_STATUS_FIELD_API_NAME) && oldSyncJsonMap == null) ||
            (newSyncJsonMap.containsKey(XREF_STATUS_FIELD_API_NAME) &&
            (oldSyncJsonMap != null && oldSyncJsonMap.containsKey(XREF_STATUS_FIELD_API_NAME)) &&
            newSyncJsonMap.get(XREF_STATUS_FIELD_API_NAME) !=
            oldSyncJsonMap.get(XREF_STATUS_FIELD_API_NAME));
    }
    /**
     * @description It is used to fetch the account ids from related Xrefs.
     * @param insertedRecords
     * @return Set<Id>
     */
    private Set<Id> getAccountIdsFromInsertedXref(List<Xref__c> insertedRecords) {
        Set<Id> accountIdsFromInsertedXref = new Set<Id>();
        for (Xref__c eachXref : insertedRecords) {
            accountIdsFromInsertedXref.add(eachXref.Salesforce_Account_ID__c);
        }
        return accountIdsFromInsertedXref;
    }
}