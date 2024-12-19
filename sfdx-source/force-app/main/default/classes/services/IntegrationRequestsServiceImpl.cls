/**
 * @author DoorDash
 * @date 06/03/2023
 * @description Service impl class for processing integration requests.
 */
public inherited sharing class IntegrationRequestsServiceImpl implements IIntegrationRequestsService {
    private static final String PROCESS_NEW_POS_INTEGRATION_REQUEST = 'PROCESS_NEW_POS_INTEGRATION_REQUEST';
    private static final String PROCESS_UPDATE_POS_INTEGRATION_REQUEST = 'PROCESS_UPDATE_POS_INTEGRATION_REQUEST';
    private static final String PROCESS_COO_SAME_STORE = 'PROCESS_COO_SAME_STORE';
    //@jira LEM-10463
    private static final String UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS = 'UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS';
    private static final String CREATE_ACTIVATION_CHECKLIST = 'CREATE_ACTIVATION_CHECKLIST';
    private static final String EVENT_TOPIC_FRAUD_EVENT_CHECK = 'EVENT_TOPIC_FRAUD_EVENT_CHECK';
    private static final String EVENT_TOPIC_PLACEITFORME_INBOUND_INTEGRATION = 'PLACEITFORME_INBOUND_INTEGRATION';
    private static final String PROCESS_NEW_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING = 'ProcessNewPosIrChunkSize';
    private static final String PROCESS_UPDATE_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING = 'ProcessUpdatePosIrChunkSize';
    private static final String PROCESS_COO_SAME_STORE_CHUNK_SIZE_SETTING = 'ProcessCooSameStoreChunkSize';
    private static final String ACTIVATION_CHECKLIST_CHUNK_SIZE = 'Activation_Checklist_Chunk_Size';
    private static final String FRAUD_EVENT_CHUNK_SIZE = 'Fraud_Event_Chunk_Size';
    private static final String PLACEITFORME_EVENT_CHUNK_SIZE = 'PlaceItForMe_Event_Chunk_Size';

    //@jira LEM-10463
    private static final String PROCESS_TABLET_CASE_SYNC_CHUNK_SIZE_SETTING = 'ProcessTabletCaseSyncChunkSize';
    private Integer processNewPosIntegrationRequestChunkSize;
    private Integer processUpdatePosIntegrationRequestChunkSize;
    private Integer processTabletCaseSyncChunkSize;
    private Integer processActivationChecklistChunkSize;
    private Integer processFraudEventChunkSize;
    private Integer processPlaceItForMeChunkSize;
    private static final String NEW_IR_REQUEST = 'CREATE';
    private static final String UPDATE_IR_REQUEST = 'UPDATE';
    private static final String SFDC_ORG_LEMONADE = 'Lemonade';
    private static final String SFDC_ORG_FIGMENT = 'Figment';
    private static final String INTEGRATION_TYPE_POS = 'POS Requests';
    private static final String INTEGRATION_TYPE_COO_SAME_STORE = 'COO Same Store';
    private static final String INTEGRATION_TYPE_ACTIVATION_CHECKLIST = 'Activation Checklist';
    private static final String INTEGRATION_TYPE_FRAUD_EVENT = 'Fraud Event';
    private static final String INTEGRATION_TYPE_PLACEITFORME = 'Place It For Me';
    //@jira LEM-10463
    private static final String INTEGRATION_TYPE_TABLET_CASE_SYNC = 'Tablet Case Sync';
    //@jira LEM-11258
    private static final String INTEGRATION_TYPE_MDS_STORE_SYNC = 'MDS Store Sync';
    private static final String SFDC_STATUS_FAILED = 'Failed';
    private static final String MESSAGE_STORE_NOT_FOUND = 'Store not found';
    fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    private static final String PRODUCT_STATUS_CREATED = 'created';
    private static final String PRODUCT_STATUS_APPROVED = 'approved';
    private static final String PRODUCT_STATUS_COMPLETED = 'completed';
    private static final String PRODUCT_STATUS_CANCELLED = 'cancelled';
    private static final String PRODUCT_STATUS_READY = 'ready';
    private static final String SFDC_STATUS_PENDING = 'Pending';
    private static final String SFDC_STATUS_PROCESSED = 'Processed';
    private static final String LOG_SERVICE_INTEGRATION_REQUESTS_SVC = 'IntegrationRequestsService';
    private static final String LOG_DOMAIN_NAME = 'Provisioning';
    private static final Set<String> PRODUCT_STATUS_TO_SEND_EVENTS = new Set<String>{
        PRODUCT_STATUS_READY,
        PRODUCT_STATUS_CREATED,
        PRODUCT_STATUS_CANCELLED,
        PRODUCT_STATUS_COMPLETED
    };
    private enum POS_ACTION_TYPES {
        NEW_IR_REQUEST,
        UPDATE_IR_REQUEST
    }
    private enum INT_TYPE {
        INTEGRATION_TYPE_POS,
        INTEGRATION_TYPE_COO_SAME_STORE,
        //@jira LEM-10463
        INTEGRATION_TYPE_TABLET_CASE_SYNC,
        INTEGRATION_TYPE_MDS_STORE_SYNC,
        INTEGRATION_TYPE_ACTIVATION_CHECKLIST,
        INTEGRATION_TYPE_FRAUD_EVENT,
        INTEGRATION_TYPE_PLACEITFORME
    }
    private static final Map<String, POS_ACTION_TYPES> ACTION_EVENT_MAPPINGS = new Map<String, POS_ACTION_TYPES>{
        NEW_IR_REQUEST => POS_ACTION_TYPES.NEW_IR_REQUEST,
        UPDATE_IR_REQUEST => POS_ACTION_TYPES.UPDATE_IR_REQUEST
    };
    private static final Map<String, INT_TYPE> INT_TYPE_MAPPING = new Map<String, INT_TYPE>{
        INTEGRATION_TYPE_POS => INT_TYPE.INTEGRATION_TYPE_POS,
        INTEGRATION_TYPE_COO_SAME_STORE => INT_TYPE.INTEGRATION_TYPE_COO_SAME_STORE,
        //@jira LEM-10463
        INTEGRATION_TYPE_TABLET_CASE_SYNC => INT_TYPE.INTEGRATION_TYPE_TABLET_CASE_SYNC,
        INTEGRATION_TYPE_MDS_STORE_SYNC => INT_TYPE.INTEGRATION_TYPE_MDS_STORE_SYNC,
        INTEGRATION_TYPE_ACTIVATION_CHECKLIST => INT_TYPE.INTEGRATION_TYPE_ACTIVATION_CHECKLIST,
        INTEGRATION_TYPE_FRAUD_EVENT => INT_TYPE.INTEGRATION_TYPE_FRAUD_EVENT,
        INTEGRATION_TYPE_PLACEITFORME => INT_TYPE.INTEGRATION_TYPE_PLACEITFORME
    };
    private static final String INTEGRATION_REQUEST_DELETE_OLDER_THAN_N_MONTHS = 'IntegrationRequestDeleteOlderThanNMonths'; // @jira LEM-10464
    private static final String INTEGRATION_REQUEST_DELETE_TYPES = 'IntegrationRequestDeleteTypes'; // @jira LEM-10464
    private Integer integrationRequestDeleteOlderThanNMonths; // @jira LEM-10464
    private Set<String> integrationRequestDeleteTypes; // @jira LEM-10464

    /**
     * @description sync child with Product_Status__c with the parent integration requests.
     * only updating Product_Status__c not updating sfdc_status__c
     * because it will override parent request status with pending or failed status
     * and in cooImpl before processing child request will check for parent processed.
     * called from integration request handler
     * @param oldIntReq old integration requests
     * @param newIntReq new int requests.
     */
    public void updateParentIntRequest(
        Map<Id, Integration_Request__c> oldIntReq,
        List<Integration_Request__c> newIntReq
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Integration_Request__c eachIr : newIntReq) {
            Boolean parentRecordExists = eachIr.Parent_Integration_Request__c != null
                ? true
                : false;
            if (parentRecordExists) {
                Integration_Request__c parentIntRequest = new Integration_Request__c(
                    Id = eachIr.Parent_Integration_Request__c,
                    Stage__c = eachIr.Product_Status__c,
                    Stage_Status__c = eachIr.sfdc_status__c,
                    Activation_Date__c = eachIr.Activation_Date__c
                );
                uow.registerDirty(parentIntRequest);
            }
        }
        uow.commitWork();
    }
    /**
     * @description Publishes events for processing the Integration Requests.
     * This method can be called from int req trigger or integration req scheduler.
     * @param oldIntReq A map of old Integration_Request__c records.
     * @param newIntReq A list of new Integration_Request__c records.
     * @param fromScheduler Specifies if the method is called from the scheduler.
     */
    public void publishEventsForProcessing(
        Map<Id, Integration_Request__c> oldIntReq,
        List<Integration_Request__c> newIntReq,
        Boolean fromScheduler
    ) {
        collectStaticConfigurations(fromScheduler);
        List<Integration_request__c> processCooIntReq = new List<Integration_request__c>();
        List<Integration_request__c> processPosIntReq = new List<Integration_request__c>();
        //@jira LEM-10463
        List<Integration_request__c> processTabletSyncCaseIntReq = new List<Integration_request__c>();
        List<Integration_request__c> processMDSStoreSyncIntReq = new List<Integration_request__c>();
        List<Integration_Request__c> processActivationChecklistIntReq = new List<Integration_Request__c>();
        List<Integration_Request__c> processFraudEventIntegrationRequests = new List<Integration_Request__c>();
        List<Integration_Request__c> processPlaceItForMeIntegrationRequests = new List<Integration_Request__c>();
        //oldIntReq can be empty if this method called from integration request scheduler.
        Boolean isInsert = oldIntReq.isEmpty() ? true : false;
        // New set to capture Work Step IDs for tablet case sync

        for (Integration_request__c eachIr : newIntReq) {
            if (!isIntegrationRequestValidToProcess(isInsert, eachIr, oldIntReq)) {
                continue;
            }
            switch on INT_TYPE_MAPPING.get(eachIr.Integration_Type__c) {
                when INTEGRATION_TYPE_POS {
                    processPosIntReq.add(eachIr);
                }
                when INTEGRATION_TYPE_COO_SAME_STORE {
                    processCooIntReq.add(eachIr);
                }
                //@jira LEM-10463  Check if it's a Tablet Case Sync and map Work Step IDs
                when INTEGRATION_TYPE_TABLET_CASE_SYNC {
                    processTabletSyncCaseIntReq.add(eachIr);
                }
                //@jira LEM-11258 MDS Store Sync events for processing
                when INTEGRATION_TYPE_MDS_STORE_SYNC {
                    processMDSStoreSyncIntReq.add(eachIr);
                }
                when INTEGRATION_TYPE_ACTIVATION_CHECKLIST {
                    processActivationChecklistIntReq.add(eachIr);
                }
                when INTEGRATION_TYPE_FRAUD_EVENT {
                    processFraudEventIntegrationRequests.add(eachIr);
                }
                when INTEGRATION_TYPE_PLACEITFORME {
                    processPlaceItForMeIntegrationRequests.add(eachIr);
                }
            }
        }

        publishPosEvents(processPosIntReq);
        //publish coo events only if triggering from scheduler. Do not coo process from trigger.
        //because there is possibilty that duplicate records might create if coo belongs to same batch id
        publishCOOEvents(processCooIntReq, fromScheduler);
        //@jira LEM-10463  Publish tablet case sync events
        publishTabletCaseSyncEvents(processTabletSyncCaseIntReq);
        publishActivationChecklistEvents(processActivationChecklistIntReq);
        publishFraudEventEvents(processFraudEventIntegrationRequests);
        publishPlaceItForMeEvents(processPlaceItForMeIntegrationRequests);
        //@jira LEM-11258 public MDS Store sync events
        if (!processMDSStoreSyncIntReq.isEmpty()) {
            publishMdsStoreSyncEvents(processMDSStoreSyncIntReq);
        }
    }

    /**
     * @description It updates the Integration Requests SFDC Status based on passed Status value.
     * @JIRA# LEM-17497
     * @param integrationRequestIds
     * @param statusToUpdate
     */
    public void updateIntegrationRequestsSFDCStatus(
        Set<Id> integrationRequestIds,
        String statusToUpdate
    ) {
        if (integrationRequestIds.isEmpty()) {
            return;
        }
        List<Integration_Request__c> integrationRequestsToUpdate = new List<Integration_Request__c>();
        fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
        for (Id eachIntegrationRequestId : integrationRequestIds) {
            integrationRequestsToUpdate.add(
                new Integration_Request__c(
                    Id = eachIntegrationRequestId,
                    Sfdc_Status__c = statusToUpdate,
                    Stage_Status__c = statusToUpdate
                )
            );
        }
        unitOfWork.registerDirty(integrationRequestsToUpdate);
        commitWork(unitOfWork);
    }

    private void publishCOOEvents(List<Integration_Request__c> cooIntReq, Boolean fromScheduler) {
        if (fromScheduler && cooIntReq.size() > 0) {
            Set<Object> cooBatchIds = new Set<Object>();
            for (Integration_request__c eachIr : cooIntReq) {
                if (PRODUCT_STATUS_TO_SEND_EVENTS.contains(eachIr.Product_Status__c)) {
                    cooBatchIds.add(eachIr.batch_Id__c);
                }
            }
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    PROCESS_COO_SAME_STORE => NotifierEventsPayloadGenerationService.generateChunkedPayloadsByObjects(
                        cooBatchIds,
                        1
                    )
                }
            );
        }
    }
    private void publishPosEvents(List<Integration_Request__c> posIntReq) {
        Set<Id> newRequestStoreIds = new Set<Id>();
        Set<Id> updateRequestStoreIds = new Set<Id>();
        Set<Id> queryParentIRStatus = new Set<Id>();
        Map<Id,Integration_request__c> mapUpdateReqs = new Map<Id,Integration_request__c>();
        for (Integration_request__c irRec : posIntReq) {
            if(irRec.Action__c == UPDATE_IR_REQUEST && irRec.Parent_Integration_Request__c != null){
                queryParentIRStatus.add(irRec.Id);
            }
        }
        for(Integration_request__c eachIr : IntegrationRequestsSelector.newInstance().
                                            selectByIdForParentIntegration(queryParentIRStatus)){
            mapUpdateReqs.put(eachIr.Id,eachIr);
        }
        for (Integration_request__c eachIr : posIntReq) {
            switch on ACTION_EVENT_MAPPINGS.get(eachIr.Action__c) {
                when NEW_IR_REQUEST {
                    newRequestStoreIds.add(eachIr.Id);
                }
                when UPDATE_IR_REQUEST {
                    Boolean isParentProcessed = false;
                    if(mapUpdateReqs.containsKey(eachIr.Id)){
                        isParentProcessed = SFDC_STATUS_PROCESSED.equals(
                            //Parent_Integration_Request__r.sfdc_status__c in trigger context we need query to pull this info
                            mapUpdateReqs.get(eachIr.Id).Parent_Integration_Request__r.sfdc_status__c
                        );
                    }
                    // publish events only if parent integration request is processed or if parent is not linked.
                    // parent cannot be linked if the child would have sent sfdc first. This could happen so included.
                    Boolean readyToProcess =
                        eachIr.Parent_Integration_Request__c == null || isParentProcessed;
                    if (readyToProcess) {
                        updateRequestStoreIds.add(eachIr.Id);
                    }
                }
            }
        }
        NotifierEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                PROCESS_NEW_POS_INTEGRATION_REQUEST => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    newRequestStoreIds,
                    processNewPosIntegrationRequestChunkSize
                )
            }
        );
        NotifierEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                PROCESS_UPDATE_POS_INTEGRATION_REQUEST => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    updateRequestStoreIds,
                    processUpdatePosIntegrationRequestChunkSize
                )
            }
        );
    }

    /**
     * @description Publishes events for updating the Work Step object's status field to match the Integration Request object's Status field.
     * @param tabletSyncCaseIntReq A list of Integration_Request__c
     * @jira LEM-10463
     */
    private void publishTabletCaseSyncEvents(List<Integration_Request__c> tabletSyncCaseIntReq) {
        if (tabletSyncCaseIntReq.size() > 0) {
            Set<Id> workStepIds = new Set<Id>();
            for (Integration_request__c eachIr : tabletSyncCaseIntReq) {
                if (eachIr.Sfdc_Status__c != SFDC_STATUS_PROCESSED) {
                    workStepIds.add(Id.valueOf(eachIr.Onboarding_Id__c));
                }
            }
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        workStepIds,
                        processTabletCaseSyncChunkSize
                    )
                }
            );
        }
    }

    /**
     * @description It publishes events for updating the Work Step Status, Status Reason and Notes field
     * based on payload received in Integration Request.
     * @param processFraudEventIntegrationRequests
     */
    private void publishFraudEventEvents(
        List<Integration_Request__c> processFraudEventIntegrationRequests
    ) {
        if (processFraudEventIntegrationRequests.isEmpty()) {
            return;
        }

        Set<Id> integrationRequestIds = new Set<Id>();
        for (Integration_request__c eachIntegrationRequest : processFraudEventIntegrationRequests) {
            if (eachIntegrationRequest.Sfdc_Status__c != SFDC_STATUS_PROCESSED) {
                integrationRequestIds.add(eachIntegrationRequest.Id);
            }
        }
        OnboardingActivationsEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_FRAUD_EVENT_CHECK => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    integrationRequestIds,
                    processFraudEventChunkSize
                )
            }
        );
    }

    /**
     * @description Publishes events for updating the Work Step object's status field to match the Integration Request object's Status field.
     * @param activationChecklistIntReq A list of Integration_Request__c
     * @jira LEM-10463
     */
    private void publishActivationChecklistEvents(
        List<Integration_Request__c> activationChecklistIntReq
    ) {
        if (activationChecklistIntReq.size() > 0) {
            Set<Id> integrationRequestIds = new Set<Id>();
            for (Integration_request__c eachIr : activationChecklistIntReq) {
                if (eachIr.Sfdc_Status__c != SFDC_STATUS_PROCESSED) {
                    integrationRequestIds.add(eachIr.Id);
                }
            }
            OnboardingActivationsEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    CREATE_ACTIVATION_CHECKLIST => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        integrationRequestIds,
                        processActivationChecklistChunkSize
                    )
                }
            );
        }
    }

    /**
     * @description It publishes events for "Place It For Me" Integration Requests processing.
     * @param integrationRequestsToProcess
     * @JIRA# LEM-15585
     */
    private void publishPlaceItForMeEvents(
        List<Integration_Request__c> integrationRequestsToProcess
    ) {
        if (integrationRequestsToProcess.isEmpty()) {
            return;
        }
        Set<Id> integrationRequestIds = new Set<Id>();
        for (Integration_Request__c eachIntegrationRequest : integrationRequestsToProcess) {
            if (eachIntegrationRequest.Sfdc_Status__c != SFDC_STATUS_PROCESSED) {
                integrationRequestIds.add(eachIntegrationRequest.Id);
            }
        }
        if (integrationRequestIds.isEmpty()) {
            return;
        }
        OnboardingActivationsEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_PLACEITFORME_INBOUND_INTEGRATION => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    integrationRequestIds,
                    processPlaceItForMeChunkSize
                )
            }
        );
    }

    /**
     * @description get static static onfiguration from metadata
     * @param retrying Boolean whether it is retrying or not. If it is retrying then use batch Id as 1.
     * So that if the record failing due to the exception of other record will be batched it into separate transaction.
     */
    private void collectStaticConfigurations(Boolean retrying) {
        this.processNewPosIntegrationRequestChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PROCESS_NEW_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING)
                .Configuration_Value__c
        );
        this.processNewPosIntegrationRequestChunkSize = retrying
            ? 1
            : this.processNewPosIntegrationRequestChunkSize;
        this.processUpdatePosIntegrationRequestChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PROCESS_UPDATE_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING)
                .Configuration_Value__c
        );
        this.processNewPosIntegrationRequestChunkSize = retrying
            ? 1
            : this.processNewPosIntegrationRequestChunkSize;
        this.processUpdatePosIntegrationRequestChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PROCESS_COO_SAME_STORE_CHUNK_SIZE_SETTING)
                .Configuration_Value__c
        );
        //@jira LEM-10463
        this.processTabletCaseSyncChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PROCESS_TABLET_CASE_SYNC_CHUNK_SIZE_SETTING)
                .Configuration_Value__c
        );
        //Additional configurations for deleteOldRecords @jira LEM-10464
        this.integrationRequestDeleteOlderThanNMonths = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(INTEGRATION_REQUEST_DELETE_OLDER_THAN_N_MONTHS)
                .Configuration_Value__c
        );
        this.integrationRequestDeleteTypes = new Set<String>(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(INTEGRATION_REQUEST_DELETE_TYPES)
                .Configuration_Value__c.split(',')
        );
        this.processTabletCaseSyncChunkSize = retrying ? 1 : this.processTabletCaseSyncChunkSize;
        this.processActivationChecklistChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(ACTIVATION_CHECKLIST_CHUNK_SIZE)
                .Configuration_Value__c
        );
        this.processFraudEventChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(FRAUD_EVENT_CHUNK_SIZE)
                .Configuration_Value__c
        );
        this.processPlaceItForMeChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PLACEITFORME_EVENT_CHUNK_SIZE)
                .Configuration_Value__c
        );
    }

    /**
     * @description delete old integration request records based on configuration
     * @jira LEM-10464
     */
    public void deleteOldRecords() {
        collectStaticConfigurations(false);
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        try {
            DateTime integrationRequestDeleteOlderThanNMonth = System.now()
                .addMonths(-integrationRequestDeleteOlderThanNMonths);
            List<integration_Request__c> intReqToDelete = IntegrationRequestsSelector.newInstance()
                .selectIntegrationRequestsByIntegrationType(
                    integrationRequestDeleteTypes,
                    integrationRequestDeleteOlderThanNMonth
                );
            if (!intReqToDelete.isEmpty()) {
                uow.registerDeleted(intReqToDelete);
                commitWork(uow);
            }
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_INTEGRATION_REQUESTS_SVC,
                        LOG_DOMAIN_NAME,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description to determine if the Integration request is valid to process
     * @param isInsert
     * @param intReq
     * @param oldIntReq
     * @return processIntReq
     */
    private Boolean isIntegrationRequestValidToProcess(
        Boolean isInsert,
        Integration_request__c intReq,
        Map<Id, Integration_Request__c> oldIntReq
    ) {
        Boolean intReqValidForProcess = !isInsert &&
            SFDC_STATUS_PENDING.equals(intReq.sfdc_status__c) &&
            oldIntReq.get(intReq.Id).sfdc_status__c != intReq.sfdc_status__c
            ? true
            : false;
        Boolean processIntReq = intReqValidForProcess ||
            isInsert ||
            intReq.Integration_Type__c == INTEGRATION_TYPE_TABLET_CASE_SYNC
            ? true
            : false;
        return processIntReq;
    }

    private void publishMdsStoreSyncEvents(List<Integration_Request__c> integrationRequests) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Integration_Request__c ir : integrationRequests) {
            if (ir.Sfdc_Status__c == SFDC_STATUS_PENDING) {
                MDS_Sync_Event__e evt = new MDS_Sync_Event__e();
                evt.Integration_Request_Id__c = ir.Id;
                uow.registerPublishAfterSuccessTransaction(evt);
            }
        }
        commitWork(uow);
    }
}