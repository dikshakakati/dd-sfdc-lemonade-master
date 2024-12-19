/**
 * @author Deloitte
 * @date 07/07/2024
 * @description Service implementation class for "Place It For Me" inbound integration
 * related logic.
 */
public inherited sharing class PlaceItForMeIntegrationServiceImpl implements IPlaceItForMeIntegrationService {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String COMMA_SPLIT = ',';
    private static final String DATETIME_DAY_OF_WEEK_SYMBOL = 'E';
    private static final String DAY_SATURDAY = 'Sat';
    private static final String DAY_SUNDAY = 'Sun';
    private static final String EVENT_TOPIC_PLACEITFORME_INBOUND_INTEGRATION = 'PLACEITFORME_INBOUND_INTEGRATION';
    private static final String ACCOUNT_EXPERIENCE_STOREFRONT = 'Storefront';
    private static final String FORWARDSLASH_R_N = '\r\n';
    private static final List<String> INELIGIBLE_PROVISIONING_STATUSES_FOR_EXISTING_STOREFRONT_WORKORDER = new List<String>{
        'Not Started',
        'Readiness Check',
        'Readiness Check Complete',
        'Readiness Check Failed'
    };
    private static final String INTEGRATION_REQUEST_STATUS_FAILED = 'Failed';
    private static final String INTEGRATION_REQUEST_STATUS_PROCESSED = 'Processed';
    private static final String INTERFACE_TRANSACTION_CONFIG_NAME_WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION = 'WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION';
    private static final String LOG_SERVICE_CREATE_STOREFRONT_WORKORDERS = 'Place It For Me - Work Order Create/Update';
    private static final String LOG_DOMAIN = 'Place It For Me';
    private static final String SFDC_STATUS_PROCESSED = 'Processed';
    private static final String STATUS_ESCALATED = 'Escalated';
    private static final String STOREFRONT_MX_ESCALATION_QUEUE_NAME = 'Storefront - Mx Escalation';
    private static final String WORK_ORDER_BUNDLED_WITH_MARKETPLACE_NO = 'No';
    private static final String WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME = 'Place It For Me';
    private static final String WORK_ORDER_PRIMARY_VERTICAL_RX = 'Rx';
    private static final String WORK_ORDER_PROVISIONING_PROCESS_AUTOMATIC = 'Automatic';
    private static final String WORK_ORDER_PROVISIONING_STATUS = 'Provisioning Complete';
    private static final String WORK_ORDER_SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String WORK_ORDER_STATUS_AT_RISK = 'At Risk';
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORKPLAN_NOTES_WEBSITE_PROVIDER_KEY = 'Website Provider: ';
    private static final String WORKPLAN_NOTES_WEBSITE_URL_KEY = 'Website URL: ';
    private static final String WORKPLAN_NOTES_PLACEMENT_REQUEST_KEY = 'Placement Request: ';
    private static final String WORKSTEP_STATUS_PIFM_LEAD = 'PIFM Lead';
    private static final String WORKSTEP_TYPE_IMPLEMENTATION_CALL = 'Implementation Call';
    private enum EventTopics {
        EVENT_TOPIC_PLACEITFORME_INBOUND_INTEGRATION
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_PLACEITFORME_INBOUND_INTEGRATION => EventTopics.EVENT_TOPIC_PLACEITFORME_INBOUND_INTEGRATION
    };
    private enum DaysOfWeek {
        SATURDAY,
        SUNDAY
    }
    private static final Map<String, DaysOfWeek> DAYS_OF_WEEK = new Map<String, DaysOfWeek>{
        DAY_SATURDAY => DaysOfWeek.SATURDAY,
        DAY_SUNDAY => DaysOfWeek.SUNDAY
    };

    private static Id storefrontMxEscalationQueueId;
    private static Map<String, String> businessIdToNotes;
    private static Map<String, Id> businessIdToIntegrationRequestId;
    private static Map<String, Account> businessIdToBusinessAccount;
    private static Map<Id, String> businessAccountIdToBusinessId;
    private static Map<Id, String> businessAccountIdToStoreAccountIds;
    private static Map<Id, WorkOrder> businessAccountIdToWorkOrder;
    private static Map<Id, List<WorkOrder>> parentWorkOrderIdToChildWorkOrders;
    private static Set<Id> unProcessedBusinessAccountIds;
    private static Map<String, Id> unProcessedBusinessIdToIntegrationRequestId;

    /**
     * @description Default Constructor to initialize class variables.
     */
    public PlaceItForMeIntegrationServiceImpl() {
        businessIdToNotes = new Map<String, String>();
        businessIdToIntegrationRequestId = new Map<String, Id>();
        businessAccountIdToBusinessId = new Map<Id, String>();
        businessIdToBusinessAccount = new Map<String, Account>();
        businessAccountIdToStoreAccountIds = new Map<Id, String>();
        businessAccountIdToWorkOrder = new Map<Id, WorkOrder>();
        parentWorkOrderIdToChildWorkOrders = new Map<Id, List<WorkOrder>>();
        unProcessedBusinessAccountIds = new Set<Id>();
        unProcessedBusinessIdToIntegrationRequestId = new Map<String, Id>();
    }

    /**
     * @description  It is used to handle the payload received via Platform Event.
     * @JIRA# LEM-15585
     * @param events
     */
    public void handleOnboardingActivationsEvents(List<Onboarding_Activation__e> events) {
        Set<Id> integrationRequestIdsToProcess = new Set<Id>();
        Set<Id> failedIntegrationRequestIds = new Set<Id>();
        Set<Id> recordIdsFromPayload;
        Boolean isProcessed = true;
        for (Onboarding_Activation__e eachEvent : events) {
            recordIdsFromPayload = (Set<Id>) JSON.deserialize(eachEvent.Payload__c, Set<Id>.class);
            if (recordIdsFromPayload == null) {
                continue;
            }
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENT_TOPIC_PLACEITFORME_INBOUND_INTEGRATION {
                    integrationRequestIdsToProcess.addAll(recordIdsFromPayload);
                }
            }
        }
        try {
            processIntegrationRequests(integrationRequestIdsToProcess);
        } catch (Exception runTimeException) {
            isProcessed = false;
            Logger.publish(LogEntry.newExceptionLog(runTimeException, LogEntry.SeverityLevel.High));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_CREATE_STOREFRONT_WORKORDERS,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(runTimeException)
            );
        }
        failedIntegrationRequestIds.addAll(unProcessedBusinessIdToIntegrationRequestId.values());
        if (!isProcessed) {
            failedIntegrationRequestIds.addAll(integrationRequestIdsToProcess);
        } else {
            integrationRequestIdsToProcess.removeAll(failedIntegrationRequestIds);
            IntegrationRequestsService.updateIntegrationRequestsSFDCStatus(
                integrationRequestIdsToProcess,
                INTEGRATION_REQUEST_STATUS_PROCESSED
            );
        }
        if (!failedIntegrationRequestIds.isEmpty()) {
            IntegrationRequestsService.updateIntegrationRequestsSFDCStatus(
                failedIntegrationRequestIds,
                INTEGRATION_REQUEST_STATUS_FAILED
            );
        }
    }

    /**
     * @description  It is used to update the Work Plan Notes based on payload and assign Work Plans
     * to 'Storefront - Mx Escalation' queue.
     * @JIRA# LEM-15585
     * @param placeItForMeStorefrontWorkPlans
     */
    public void updatePlaceItForMeStorefrontWorkPlans(
        List<WorkPlan> placeItForMeStorefrontWorkPlans
    ) {
        if (placeItForMeStorefrontWorkPlans.isEmpty()) {
            return;
        }
        List<WorkPlan> workPlansToUpdate = new List<WorkPlan>();
        Map<Id, Id> parentWorkOrderIdToWorkPlanId = new Map<Id, Id>();
        fflib_ISobjectUnitOfWork updateUnitOfWork = Application.UnitOfWork.newInstance();
        collectStorefrontMxEscalationQueueId();
        for (WorkPlan eachWorkPlan : placeItForMeStorefrontWorkPlans) {
            if (eachWorkPlan.Parent_Work_Plan__c == null) {
                parentWorkOrderIdToWorkPlanId.put(eachWorkPlan.WorkOrderId, eachWorkPlan.Id);
            } else {
                workPlansToUpdate.add(
                    new WorkPlan(
                        Id = eachWorkPlan.Id,
                        OwnerId = storefrontMxEscalationQueueId,
                        Status__c = STATUS_ESCALATED,
                        Primary_Routing_Assigned__c = true,
                        Secondary_Routing_Assigned__c = true
                    )
                );
            }
        }
        if (!parentWorkOrderIdToWorkPlanId.isEmpty()) {
            Set<Id> integrationRequestIds = collectParentWorkOrderDetails(
                parentWorkOrderIdToWorkPlanId.keySet()
            );
            generateNotesFromPayloadForBusinessIds(integrationRequestIds);
            getBusinessAccountsByBusinessIds();
            workPlansToUpdate.addAll(
                updateParentWorkPlanWithGeneratedNotes(parentWorkOrderIdToWorkPlanId)
            );
        }
        updateUnitOfWork.registerDirty(workPlansToUpdate);
        commitUnitOfWork(updateUnitOfWork);
    }
    /**
     * @description It is used to update Parent Work Plans with the Notes generated.
     * @JIRA# LEM-15585
     * @param parentWorkOrderIdToWorkPlanId
     * @return Set<Id>
     */
    private List<WorkPlan> updateParentWorkPlanWithGeneratedNotes(
        Map<Id, Id> parentWorkOrderIdToWorkPlanId
    ) {
        List<WorkPlan> workPlansToUpdate = new List<WorkPlan>();
        for (Id eachBusinessAccountId : businessAccountIdToWorkOrder.keySet()) {
            workPlansToUpdate.add(
                new WorkPlan(
                    Id = parentWorkOrderIdToWorkPlanId.get(
                        businessAccountIdToWorkOrder.get(eachBusinessAccountId).Id
                    ),
                    OwnerId = storefrontMxEscalationQueueId,
                    Notes__c = businessIdToNotes.get(
                        businessAccountIdToBusinessId.get(eachBusinessAccountId)
                    ),
                    Status__c = STATUS_ESCALATED,
                    Primary_Routing_Assigned__c = true,
                    Secondary_Routing_Assigned__c = true
                )
            );
        }
        return workPlansToUpdate;
    }

    /**
     * @description It is used to collect Work Order details based on passed Work Order Ids.
     * @JIRA# LEM-15585
     * @param workOrderIds
     * @return Set<Id>
     */
    private Set<Id> collectParentWorkOrderDetails(Set<Id> workOrderIds) {
        Set<Id> integrationRequestIds = new Set<Id>();
        for (WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance().selectById(workOrderIds)) {
            businessAccountIdToWorkOrder.put(eachWorkOrder.AccountId, eachWorkOrder);
            integrationRequestIds.add((Id) eachWorkOrder.Integration_Request_Id__c);
        }
        return integrationRequestIds;
    }

    /**
     * @description It is used to get the 'Storefront - Mx Escalation' queue Id.
     * @JIRA# LEM-15585
     */
    private void collectStorefrontMxEscalationQueueId() {
        List<Group> storefrontMxEscalationQueue = GroupsSelector.newInstance()
            .selectQueueByName(STOREFRONT_MX_ESCALATION_QUEUE_NAME);
        if (!storefrontMxEscalationQueue.isEmpty()) {
            storefrontMxEscalationQueueId = storefrontMxEscalationQueue[0].Id;
        }
    }

    /**
     * @description It is used to process the received integration requests.
     * @JIRA# LEM-15585
     * @param integrationRequestsToProcess
     */
    private void processIntegrationRequests(Set<Id> integrationRequestsToProcess) {
        if (integrationRequestsToProcess.isEmpty()) {
            return;
        }
        collectStorefrontMxEscalationQueueId();
        generateNotesFromPayloadForBusinessIds(integrationRequestsToProcess);
        getBusinessAccountsByBusinessIds();
        searchStorefrontWorkOrdersByBusinessIds();
        updateExistingStorefrontWorkPlansAndWorkSteps();
        if (!unProcessedBusinessAccountIds.isEmpty()) {
            collectStoreAccountIdsForStorefrontWOsCreation();
            createInterfaceTransactionsForWorkOrdersCreation();
        }
    }
    /**
     * @description It collects Store Account Ids for child Storefront Work Orders creation.
     * @JIRA# LEM-15585
     */
    private void collectStoreAccountIdsForStorefrontWOsCreation() {
        for (
            Account eachStoreAccount : AccountsSelector.newInstance()
                .selectStoreAccountsByParentIdsAndExperience(
                    unProcessedBusinessAccountIds,
                    ACCOUNT_EXPERIENCE_STOREFRONT
                )
        ) {
            if (!businessAccountIdToStoreAccountIds.containsKey(eachStoreAccount.ParentId)) {
                businessAccountIdToStoreAccountIds.put(
                    eachStoreAccount.ParentId,
                    eachStoreAccount.Id
                );
            } else {
                businessAccountIdToStoreAccountIds.put(
                    eachStoreAccount.ParentId,
                    businessAccountIdToStoreAccountIds.get(eachStoreAccount.ParentId) +
                    COMMA_SPLIT +
                    eachStoreAccount.Id
                );
            }
        }
    }

    /**
     * @description It creates Interface Transactions for initiating Work Order creation.
     * @JIRA# LEM-15585
     */
    private void createInterfaceTransactionsForWorkOrdersCreation() {
        List<Interface_Transaction__c> interfaceTransactionsForWOsCreation = new List<Interface_Transaction__c>();
        fflib_ISobjectUnitOfWork insertUnitOfWork = Application.UnitOfWork.newInstance();
        for (Id eachBusinessAccountId : unProcessedBusinessAccountIds) {
            interfaceTransactionsForWOsCreation.add(
                new Interface_Transaction__c(
                    Payload__c = generateStorefrontWorkOrderPayload(eachBusinessAccountId),
                    Remaining_Retry_Attempts__c = 3,
                    Interface_Transaction_Configuration_Name__c = INTERFACE_TRANSACTION_CONFIG_NAME_WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION
                )
            );
        }
        insertUnitOfWork.registerNew(interfaceTransactionsForWOsCreation);
        commitUnitOfWork(insertUnitOfWork);
    }

    /**
     * @description It generates Work Order payload for creating Storefront Work Order.
     * @JIRA# LEM-15585
     * @param businessAccountId
     * @return String
     */
    private String generateStorefrontWorkOrderPayload(Id businessAccountId) {
        WorkOrderGenerationWrapper newWorkOrderGenerationWrapper = new WorkOrderGenerationWrapper();
        newWorkOrderGenerationWrapper.setType(WORK_ORDER_TYPE_STOREFRONT);
        newWorkOrderGenerationWrapper.setStatus(WORK_ORDER_STATUS_AT_RISK);
        newWorkOrderGenerationWrapper.setAccountId((String) businessAccountId);
        newWorkOrderGenerationWrapper.setPrimaryVertical(WORK_ORDER_PRIMARY_VERTICAL_RX);
        newWorkOrderGenerationWrapper.setBundledWithMarketplace(
            WORK_ORDER_BUNDLED_WITH_MARKETPLACE_NO
        );
        newWorkOrderGenerationWrapper.setProvisioningProcess(
            WORK_ORDER_PROVISIONING_PROCESS_AUTOMATIC
        );
        newWorkOrderGenerationWrapper.setProvisioningStatus(WORK_ORDER_PROVISIONING_STATUS);
        newWorkOrderGenerationWrapper.setCreationSource(WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME);
        newWorkOrderGenerationWrapper.setWorkOrderSource(WORK_ORDER_SOURCE_MX_PORTAL);
        newWorkOrderGenerationWrapper.setStoreAccountIds(
            businessAccountIdToStoreAccountIds.get(businessAccountId)
        );
        newWorkOrderGenerationWrapper.setProposedDateOfActivation(
            convertToNearestBusinessDay(System.today().addDays(5))
        );
        newWorkOrderGenerationWrapper.setProposedDateOfImplementation(
            convertToNearestBusinessDay(System.today().addDays(5))
        );
        newWorkOrderGenerationWrapper.setIntegrationRequestId(
            businessIdToIntegrationRequestId.get(
                businessAccountIdToBusinessId.get(businessAccountId)
            )
        );
        return JSON.serialize(newWorkOrderGenerationWrapper);
    }

    /**
     * @description It is used to commit the create/update change on SObject records
     * and publish expections.
     * @JIRA# LEM-15585
     * @param unitOfWork
     */
    private void commitUnitOfWork(fflib_ISobjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception commitException) {
            Logger.publish(LogEntry.newExceptionLog(commitException, LogEntry.SeverityLevel.High));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_CREATE_STOREFRONT_WORKORDERS,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(commitException)
            );
        }
    }

    /**
     * @description It converts the given date to nearest business day.
     * @JIRA# LEM-15585
     * @param dateToConvert
     * @return Date
     */
    private Date convertToNearestBusinessDay(Date dateToConvert) {
        DateTime requiredDateTime = (DateTime) dateToConvert;
        String dayOfWeek = requiredDateTime.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL);
        switch on DAYS_OF_WEEK.get(dayOfWeek) {
            when SATURDAY {
                return dateToConvert.addDays(2);
            }
            when SUNDAY {
                return dateToConvert.addDays(1);
            }
        }
        return dateToConvert;
    }

    /**
     * @description It process the payload from Integration Requests and
     * collects inbound notes for each Business Ids.
     * @JIRA# LEM-15585
     */
    private void updateExistingStorefrontWorkPlansAndWorkSteps() {
        unProcessedBusinessAccountIds.addAll(businessAccountIdToBusinessId.keySet());
        if (businessAccountIdToWorkOrder.isEmpty()) {
            return;
        }
        List<SObject> sObjectsToUpdate = new List<SObject>();
        fflib_ISobjectUnitOfWork updateUnitOfWork = Application.UnitOfWork.newInstance();
        WorkOrder parentWorkOrder;
        for (Id eachBusinessAccountId : businessAccountIdToWorkOrder.keySet()) {
            parentWorkOrder = businessAccountIdToWorkOrder.get(eachBusinessAccountId);
            if (!parentWorkOrder.WorkSteps.isEmpty()) {
                sObjectsToUpdate.add(
                    new WorkStep(
                        Id = parentWorkOrder.WorkSteps[0].Id,
                        Status__c = STATUS_ESCALATED,
                        Status_Reason__c = WORKSTEP_STATUS_PIFM_LEAD
                    )
                );
                sObjectsToUpdate.add(
                    new WorkPlan(
                        Id = parentWorkOrder.WorkSteps[0].WorkPlanId,
                        OwnerId = storefrontMxEscalationQueueId,
                        Notes__c = businessIdToNotes.get(
                            businessAccountIdToBusinessId.get(eachBusinessAccountId)
                        ),
                        Primary_Routing_Assigned__c = true,
                        Secondary_Routing_Assigned__c = true
                    )
                );
            }
            if (parentWorkOrderIdToChildWorkOrders.containsKey(parentWorkOrder.Id)) {
                for (
                    WorkOrder eachChildWorkOrder : parentWorkOrderIdToChildWorkOrders.get(
                        parentWorkOrder.Id
                    )
                ) {
                    if (!eachChildWorkOrder.WorkSteps.isEmpty()) {
                        sObjectsToUpdate.add(
                            new WorkStep(
                                Id = eachChildWorkOrder.WorkSteps[0].Id,
                                Status__c = STATUS_ESCALATED,
                                Status_Reason__c = WORKSTEP_STATUS_PIFM_LEAD
                            )
                        );
                        sObjectsToUpdate.add(
                            new WorkPlan(
                                Id = eachChildWorkOrder.WorkSteps[0].WorkPlanId,
                                OwnerId = storefrontMxEscalationQueueId,
                                Primary_Routing_Assigned__c = true,
                                Secondary_Routing_Assigned__c = true
                            )
                        );
                    }
                }
            }
            unProcessedBusinessAccountIds.remove(eachBusinessAccountId);
        }
        updateUnitOfWork.registerDirty(sObjectsToUpdate);
        commitUnitOfWork(updateUnitOfWork);
    }

    /**
     * @description It process the payload from Integration Requests and
     * collects inbound notes for each Business Ids.
     * @JIRA# LEM-15585
     * @param integrationRequestIdsToProcess
     */
    private void generateNotesFromPayloadForBusinessIds(Set<Id> integrationRequestIdsToProcess) {
        PlaceItForMePayloadParser newPlaceItForMePayloadParser;
        for (
            Integration_Request__c eachIntegrationRequest : IntegrationRequestsSelector.newInstance()
                .selectById(integrationRequestIdsToProcess)
        ) {
            if (!isNullOrBlank(eachIntegrationRequest.Business_Id__c)) {
                newPlaceItForMePayloadParser = (PlaceItForMePayloadParser) JSON.deserialize(
                    eachIntegrationRequest.Payload__c,
                    PlaceItForMePayloadParser.class
                );
                businessIdToNotes.put(
                    eachIntegrationRequest.Business_Id__c,
                    generateNotesByPayload(newPlaceItForMePayloadParser)
                );
                businessIdToIntegrationRequestId.put(
                    eachIntegrationRequest.Business_Id__c,
                    eachIntegrationRequest.Id
                );
                unProcessedBusinessIdToIntegrationRequestId.put(
                    eachIntegrationRequest.Business_Id__c,
                    eachIntegrationRequest.Id
                );
            }
        }
    }

    /**
     * @description It generates Work Plan notes based on the activation_notes, websiteUrl and
     * placementRequest values from payload received.
     * @JIRA# LEM-15585
     * @param newPlaceItForMePayloadParser
     * @return String
     */
    private String generateNotesByPayload(PlaceItForMePayloadParser newPlaceItForMePayloadParser) {
        String generatedNotes = '';
        if (newPlaceItForMePayloadParser == null) {
            return generatedNotes;
        }
        if (!isNullOrBlank(newPlaceItForMePayloadParser.getWebsiteProvider())) {
            generatedNotes =
                WORKPLAN_NOTES_WEBSITE_PROVIDER_KEY +
                String.valueOf(newPlaceItForMePayloadParser.getWebsiteProvider());
        }
        if (!isNullOrBlank(newPlaceItForMePayloadParser.getWebsiteURL())) {
            generatedNotes =
                generatedNotes +
                FORWARDSLASH_R_N +
                WORKPLAN_NOTES_WEBSITE_URL_KEY +
                String.valueOf(newPlaceItForMePayloadParser.getWebsiteURL());
        }
        if (!isNullOrBlank(newPlaceItForMePayloadParser.getPlacementRequest())) {
            generatedNotes =
                generatedNotes +
                FORWARDSLASH_R_N +
                WORKPLAN_NOTES_PLACEMENT_REQUEST_KEY +
                String.valueOf(newPlaceItForMePayloadParser.getPlacementRequest());
        }
        return generatedNotes;
    }

    /**
     * @description It validates whether the passed value is null or blank.
     * @JIRA# LEM-15585
     * @param valueToValidate
     * @return Boolean
     */
    private Boolean isNullOrBlank(Object valueToValidate) {
        return valueToValidate == null || String.isBlank(String.valueOf(valueToValidate));
    }

    /**
     * @description It collects the Business Accounts based on Business Ids.
     * @JIRA# LEM-15585
     */
    private void getBusinessAccountsByBusinessIds() {
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectXrefByBusinessReferenceExternalId(
                    new List<String>(businessIdToNotes.keySet())
                )
        ) {
            unProcessedBusinessIdToIntegrationRequestId.remove(eachXref.BusinessID__c);
            if (eachXref.Account_Record_Type__c == ACCOUNT_RECORD_TYPE_NAME_BUSINESS) {
                businessIdToBusinessAccount.put(
                    eachXref.BusinessID__c,
                    eachXref.Salesforce_Account_Name__r
                );
                businessAccountIdToBusinessId.put(
                    eachXref.Salesforce_Account_Name__c,
                    eachXref.BusinessID__c
                );
            } else if (eachXref.Account_Record_Type__c == ACCOUNT_RECORD_TYPE_NAME_STORE) {
                businessIdToBusinessAccount.put(
                    eachXref.BusinessID__c,
                    eachXref.Salesforce_Account_Name__r.Parent
                );
                businessAccountIdToBusinessId.put(
                    eachXref.Salesforce_Account_Name__r.Parent.Id,
                    eachXref.BusinessID__c
                );
            }
        }
    }

    /**
     * @description It collects parent and child Storefront Work Orders based on Business Account Ids.
     * @JIRA# LEM-15585
     */
    private void searchStorefrontWorkOrdersByBusinessIds() {
        if (businessAccountIdToBusinessId.isEmpty()) {
            return;
        }
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrdersAndWorkStepsByAccountIdsAndTypesAndWorkStepTypes(
                    businessAccountIdToBusinessId.keySet(),
                    new Set<String>{ WORK_ORDER_TYPE_STOREFRONT },
                    new Set<String>{ WORKSTEP_TYPE_IMPLEMENTATION_CALL }
                )
        ) {
            if (
                INELIGIBLE_PROVISIONING_STATUSES_FOR_EXISTING_STOREFRONT_WORKORDER.contains(
                    eachWorkOrder.Provisioning_Status__c
                )
            ) {
                continue;
            }
            if (isNullOrBlank(eachWorkOrder.ParentWorkOrderId)) {
                if (!businessAccountIdToWorkOrder.containsKey(eachWorkOrder.AccountId)) {
                    businessAccountIdToWorkOrder.put(eachWorkOrder.AccountId, eachWorkOrder);
                }
            } else {
                if (
                    !parentWorkOrderIdToChildWorkOrders.containsKey(eachWorkOrder.ParentWorkOrderId)
                ) {
                    parentWorkOrderIdToChildWorkOrders.put(
                        eachWorkOrder.ParentWorkOrderId,
                        new List<WorkOrder>()
                    );
                }
                parentWorkOrderIdToChildWorkOrders.get(eachWorkOrder.ParentWorkOrderId)
                    .add(eachWorkOrder);
            }
        }
    }
}