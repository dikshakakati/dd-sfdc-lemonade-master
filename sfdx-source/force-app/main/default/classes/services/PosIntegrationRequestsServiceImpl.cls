/**
 * @author DoorDash
 * @date 03/09/2023
 * @description This class will process new pos integration requests.
 * TDD: https://docs.google.com/document/d/1uEpdSlwXHU_7_uLElwKtre6W_71GhFiCaRhhRR8wc0E/edit
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessiveClassLength, PMD.StdCyclomaticComplexity')
public inherited sharing class PosIntegrationRequestsServiceImpl implements IPosIntegrationRequestsService{
    private static final String EVENT_TOPIC_PROCESS_NEW_POS_INTEGRATION_REQUEST = 'PROCESS_NEW_POS_INTEGRATION_REQUEST';
    private static final String EVENT_TOPIC_PROCESS_UPDATE_POS_INTEGRATION_REQUEST = 'PROCESS_UPDATE_POS_INTEGRATION_REQUEST';
    private static final String MAKE_WORK_PLAN_CURRENT_CHUNK_SIZE_SETTING = 'makeWorkPlanCurrentChunkSizeSetting';
    private static final String SEND_WO_FOR_WP_CREATION_CHUNK_SIZE_SETTING = 'sendWoAndWpCreationChunkSizeSetting';
    private static final String PROCESS_UPDATE_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING = 'ProcessUpdatePosIrChunkSize';
    private Integer makeWorkPlanCurrentChunkSizeSetting;
    private Integer sendWoAndWpCreationChunkSizeSetting;
    private Integer processUpdatePosIntegrationRequestChunkSize;
    private static final String EVENT_TOPIC_MAKE_WORK_PLAN_CURRENT= 'MAKE_WORK_PLAN_CURRENT';
    private static final String EVENT_TOPIC_SEND_WO_FOR_WP_CREATION= 'SEND_WO_FOR_WP_CREATION';
    private static final String TYPE_POS = 'POS';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_MARKET_PLACE = 'Marketplace';
    private static final String IR_SFDC_STATUS_PROCESSED = 'Processed';
    private static final String IR_SFDC_STATUS_FAILED = 'Failed';
    private static final String IR_SFDC_STATUS_PENDING = 'Pending';
    private static final String IR_REQUEST_ACTION_UPDATE = 'UPDATE';
    private static final String WP_STATUS_DEAD = 'Dead';
    private static final String GENERIC_LOG_SERVICE_POS = 'POS';

    private static final Set<String> WO_OPEN_STATUS =
        new Set<String>{'Planning', 'Confirmed', 'In Progress', 'At Risk', 'Past Due', 'Not Started'};
    private static final Set<String> WO_CLOSED_STATUS =
        new Set<String>{'Onboarding Complete', WP_STATUS_DEAD};
    private static final Set<String> WP_CLOSED_STATUS =
        new Set<String>{WP_STATUS_DEAD, 'Complete'};
    private static final String WP_DEAD_STATUS_REASON = 'Duplicate Onboarding Record';


    public Map<String, String> orderProtocolOldVsNew = new Map<String, String>{
        'Android Tablet (Merchant Owns)' => 'POS',
        'Email' => 'POS',
        'Fax' => 'POS',
        'Other' => 'POS',
        'Tablet (DoorDash Owns)' => 'POS and Tablet (DoorDash Owns)',
        'Tablet and Printer (DoorDash Owns)' => 'POS and Tablet (DoorDash Owns)',
        'Tablet (Caviar Owns)'=>'POS and Tablet (Caviar Owns)'
    };
    private enum EventTopics {
        EVENT_TOPIC_PROCESS_NEW_POS_INTEGRATION_REQUEST,
        EVENT_TOPIC_PROCESS_UPDATE_POS_INTEGRATION_REQUEST,
        EVENT_TOPIC_MAKE_WORK_PLAN_CURRENT,
        EVENT_TOPIC_SEND_WO_FOR_WP_CREATION
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_PROCESS_NEW_POS_INTEGRATION_REQUEST => EventTopics.EVENT_TOPIC_PROCESS_NEW_POS_INTEGRATION_REQUEST,
        EVENT_TOPIC_PROCESS_UPDATE_POS_INTEGRATION_REQUEST => EventTopics.EVENT_TOPIC_PROCESS_UPDATE_POS_INTEGRATION_REQUEST,
        EVENT_TOPIC_MAKE_WORK_PLAN_CURRENT => EventTopics.EVENT_TOPIC_MAKE_WORK_PLAN_CURRENT,
        EVENT_TOPIC_SEND_WO_FOR_WP_CREATION => EventTopics.EVENT_TOPIC_SEND_WO_FOR_WP_CREATION
    };

    fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

    private enum RESOURCE_TYPE {
        STORE_ID,
        PARENT_MO_OR_COO_WORK_ORDER_ID,
        PARENT_POS_WORK_ORDER_ID,
        PARENT_POS_WORK_PLAN_ID,
        CHILD_MO_OR_COO_WORK_ORDER_ID,
        CHILD_POS_WORK_ORDER_ID,
        CHILD_POS_WORK_PLAN_ID,
        CHILD_POS_WORK_PLAN_CLOSED,
        IR_ID,
        ACCOUNT_ID,
        BUSINESS_ID,
        BAT_PROVIDER_TYPE,
        BAT_INT_ID,
        ACCOUNT_INT_ID,
        ACCOUNT_PROVIDER_TYPE,
        POS_ORDER_PROTOCOL,
        PARENT_WO_POS_ORDER_PROTOCOL,
        SEND_IT_FOR_RETRY,
        ON_BOARDING_ID
    }

    private enum USE_CASE {
        /* No ongoing MO_OR_COO work order. parent and child */
        CREATE_POS_WO,
        /* ongoing MO_OR_COO at parent and child but not the pos wp. create wp at Parent and child. */
        CREATE_POS_WP,
        /* Ongoing pos work plan at parent MO_OR_COO but at not at child.  */
        CREATE_POS_WP_UNDER_STORE_MO_OR_COO,
        /* Ongoing pos at parent MO_OR_COO and child MO_OR_COO but provider is differnt. */
        CREATE_POS_WP_UNDER_STORE_MO_OR_COO_AND_MAKE_EXISTING_WP_DEAD,
        /* Ongoing pos at parent and child POS but provider type is different. */
        CREATE_POS_WP_UNDER_STORE_POS_AND_MAKE_EXISTING_WP_DEAD,
        /* Ongoing pos wo at parent but not at child. This scenario will not exists. */
        //CREATE_POS_WO_WP_ON_CHILD,
        /* If there is an on going child wp and int Id is same consider it as duplicate IR */
        /* update latest IR on workplan */
        DUPLICATE_INT_REQUEST,
        /* If there is no matching use case found update integration request to failed. */
        NO_USE_CASE_FOUND
    }

    private Map<Id, Id> childAccountIdToParentAccountId;
    private Map<Id, String> intRequestIdToStoreId;
    private Map<String, Map<RESOURCE_TYPE, String>> storeIdToResource;
    private Map<Id, String> accountIdToStoreId;
    private Map<Id, WorkOrder> workOrderIdToWorkOrder;

    /**
     * @description Default Constructor to initialize class variables.
     */
    public PosIntegrationRequestsServiceImpl(){
        collectStaticConfigurations();
        storeIdToResource = new Map<String, Map<RESOURCE_TYPE, String>>();
        intRequestIdToStoreId = new Map<Id, String>();
        childAccountIdToParentAccountId = new Map<Id, Id>();
        accountIdToStoreId = new Map<Id, String>();
        workOrderIdToWorkOrder = new Map<Id, WorkOrder>();
    }

    /**
     * @description class to hold the records for update.
     */
    public class OutputWrapper{
        List<WorkOrder> newParentworkOrders;
        List<WorkOrder> updateWorkOrders;
        List<Account> accounts;
        Set<Id> woIdsForWpCreation;
        List<WorkPlan> workPlans;
        List<Integration_Request__c> integrationRequest;
        outputWrapper(){
            newParentWorkOrders = new List<WorkOrder>();
            updateWorkOrders = new List<WorkOrder>();
            woIdsForWpCreation = new Set<Id>();
            workPlans = new List<WorkPlan>();
            accounts = new List<Account>();
            integrationRequest = new List<Integration_Request__c>();
        }
    }
    /**
    * @description This method handles the events from the Notifier platform event.
    * Sends the grouped events to the appropriate handler for further processing.
    * @param events a list of Notifier__e objects representing the events to be processed.
    */
    public void handleNotifierEvents(List<Notifier__e> events){
        try {
            Set<Id> intRequests = new Set<Id>();
            Set<Id> woIdsForMakeWpCurrent =new Set<Id>();
            Set<Id> woIdsForWpCreation =new Set<Id>();
            Set<Id> recordIdsFromPayload = new Set<Id>();
            for (Notifier__e eachEvent : events) {
                recordIdsFromPayload = (Set<Id>) JSON.deserialize(eachEvent.Payload__c, Set<Id>.class);
                if (recordIdsFromPayload == null) {
                    continue;
                }
                switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                    when EVENT_TOPIC_PROCESS_NEW_POS_INTEGRATION_REQUEST {
                        intRequests.addAll(recordIdsFromPayload);
                    }
                    when EVENT_TOPIC_MAKE_WORK_PLAN_CURRENT {
                        woIdsForMakeWpCurrent.addAll(recordIdsFromPayload);
                    }
                    when EVENT_TOPIC_SEND_WO_FOR_WP_CREATION {
                        woIdsForWpCreation.addAll(recordIdsFromPayload);
                    }
                }
            }
            if(intRequests.size()>0){
                processIntegrationRequests(intRequests);
            }
            if(woIdsForMakeWpCurrent.size()>0){
                makeWorkPlanCurrent(woIdsForMakeWpCurrent);
            }
            if(woIdsForWpCreation.size()>0){
                sendWorkOrdersForWpCreation(woIdsForWpCreation);
            }
        } catch (Exception ex) {
            Logger.publish( LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH) );
        }
    }
    /**
    * @description This is main method which intiates the POS workplan creation by taking IR inputs.
    * @param integrationRequestIds a set of IDs representing the integration requests to be processed.
    */
    @testVisible
    private void processIntegrationRequests(Set<Id> integrationRequestIds){
            List<OutputWrapper> recordsToUpdate = new List<OutputWrapper>();
            Set<Id> woIdsForWp = new Set<Id>();
            getIntegrationRequests(integrationRequestIds);
            getAccountIdsFromXrefs();
            getWorkOrdersAndWorkPlans();
            for(Id eachIr: integrationRequestIds){
                String storeId = intRequestIdToStoreId.get(eachIr);
                Map<RESOURCE_TYPE, String> inputPayloadByRt = storeIdToResource.get(storeId);
                //If the SEND_IT_FOR_RETRY populated the Ir request has been processed but failed to make work plan current.
                if(inputPayloadByRt.containsKey(RESOURCE_TYPE.SEND_IT_FOR_RETRY)){
                    getWorkOrdersForRetry(woIdsForWp, inputPayloadByRt.get(RESOURCE_TYPE.SEND_IT_FOR_RETRY));
                    continue;
                }
                USE_CASE useCase = deriveTheUseCase(inputPayloadByRt);
                ProcessIntRequestHandler handler = processRequestByUseCase(useCase, inputPayloadByRt);
                recordsToUpdate.add(handler.processIntegrationRequest(inputPayloadByRt));
            }
            processUpdates(recordsToUpdate, woIdsForWp);
            createLog(integrationRequestIds);
    }
    /**
    * @description this method will be called asynchronously to create work plans for all use cases except CREATE_POS_WO .
    * @param woIdsForWpcreation a set of IDs representing the work orders to be sent for work plan creation.
    */
    @testVisible
    private void sendWorkOrdersForWpCreation(Set<Id> woIdsForWpcreation){
        //Make WorkSteps Dead for the WP marked as Dead
        for(WorkStep deprecatedWorkStep : updateExistingWorkStepToDeprecated(woIdsForWpCreation)){
            uow.registerUpsert(deprecatedWorkStep);
        }
        List<WorkOrder> workOrders = WorkOrdersSelector.newInstance().selectbyId(woIdsForWpCreation);
        WorkPlanTemplatesService.createWorkPlansOnWorkOrdersByMatchingCriteria(workOrders);
        //Once the work plans has been created update work plan with necessary details asynchronously
        //in makeworkplancurrent process.
        makePosWorkPlansCurrent(workOrders);
        commitWork(uow);

    }
    /**
    * @description this method will be called make newly created work plans to current.
    * this method will be called from these classes PosIntegrationRequestServiceImpl and WorkOrdersServiceImpl.
    * @param workOrders a list of WorkOrder objects representing the work orders whose associated work plans should be made current.
    */
    public void makePosWorkPlansCurrent(List<WorkOrder> workOrders){
        Set<Id> workOrderIds = new Set<Id>();
        for(WorkOrder eachWorkOrder: workOrders){
            // Incase of CREATE_POS_WO parent child work order will not have integration Ids so the check POS check will be true.
            // Incase of other use cases Wo case be POS or market place so checking for Integration_Request_Ids__c and
            // Integration_Request_Ids__c always present on child work orders.
            if(TYPE_POS.equals(eachWorkOrder.Type__c) || String.isNotBlank(eachWorkOrder.Integration_Request_Ids__c)){
                workOrderIds.add(eachWorkOrder.Id);
                workOrderIds.add(eachWorkOrder.parentWorkOrderId);
            }
        }
        //make work plan current asynchronously.
        publishEventsByTopic(EVENT_TOPIC_MAKE_WORK_PLAN_CURRENT,
            workOrderIds,
            makeWorkPlanCurrentChunkSizeSetting
            );
    }
     /**
    * @description this method will be called to dead out the WorkPlans which are already marked as Dead
    * @param woIdsToCheck a list of WorkOrder objects representing the work plans whose associated work steps should be made dead.
    * @return List<WorkStep>
    */
    @testVisible
    private List<WorkStep> updateExistingWorkStepToDeprecated(Set<Id> woIdsToCheck){
        List<WorkStep> childWorkSteps = WorkStepsSelector.newInstance().
                                        selectAllChildWorkStepsByWorkOrderIDToDeadOut(woIdsToCheck,TYPE_POS);
        for(WorkStep ws:childWorkSteps){
            ws.Status__c = WP_STATUS_DEAD;
            ws.Status_Reason__c = WP_DEAD_STATUS_REASON;
        }
        return childWorkSteps;
    }

    /**
    * @description This method processes the updates contained in the given list of OutputWrapper objects and the set of work order IDs to be sent for work plan creation.
    * It performs the following operations:
    * Extracts the relevant records from the OutputWrapper objects.
    * Registers the extracted records for upsert operation in the UnitOfWork object.
    * Sends the work orders identified by the set of IDs for work plan creation.
    * @param recordsToUpdate a list of OutputWrapper objects representing the updates to be processed.
    * @param woIdsForWpCreation a set of IDs representing the work orders to be sent for work plan creation.
    */
    @testVisible
    private void processUpdates(List<OutputWrapper> recordsToUpdate, Set<Id> woIdsForWpCreation){

        Map<Id, WorkOrder> woByActIdorWoId = new Map<Id, WorkOrder>();
        for(OutputWrapper eachIrOutput: recordsToUpdate){
            if(eachIrOutput.newParentWorkOrders.size() > 0){
                removeDuplicates(eachIrOutput.newParentWorkOrders, woByActIdorWoId);
            }
            if(eachIrOutput.updateWorkOrders.size() > 0){
                uow.registerUpsert(eachIrOutput.updateWorkOrders);
            }
            if(eachIrOutput.accounts.size() > 0){
                uow.registerUpsert(eachIrOutput.accounts);
            }
            if(eachIrOutput.woIdsForWpCreation.size() > 0){
                woIdsForWpCreation.addAll(eachIrOutput.woIdsForWpCreation);
            }
            if(eachIrOutput.integrationRequest.size() > 0){
                uow.registerDirty(eachIrOutput.integrationRequest[0]);
            }
            for(WorkPlan eachWorkPlan : eachIrOutput.workPlans){
                uow.registerUpsert(eachWorkPlan);
            }
        }

        uow.registerUpsert(woByActIdorWoId.values());
        commitWork(uow);

        if(!woIdsForWpCreation.isEmpty()){
            publishEventsByTopic(EVENT_TOPIC_SEND_WO_FOR_WP_CREATION,
                woIdsForWpCreation,
                sendWoAndWpCreationChunkSizeSetting);
        }
    }
    /**
     * @description Publishes Notifier__e events to the specified topic based on the given set of IDs.
     * This will be calles for making work plan current and creating work plan asynchronously.
     * @param topic A string representing the name of the topic to which the events should be published.
     * @param inputIds A set of IDs representing the input data for the events.
     * @param chunkSize number events to be wrapped in each event.
     */
    @testVisible
    private void publishEventsByTopic(String topic, Set<Id> inputIds, Integer chunkSize){
        if(!inputIds.isEmpty()){
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    Topic => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        inputIds,
                        chunkSize
                    )
                }
            );
        }
    }
    /**
     * @description Adds the IDs of the work orders to the specified set for processing during work plan creation retry.
     * @param woIdsForWpCreation A set of IDs representing the work orders to be processed for work plan creation.
     * @param workOrderIds A comma-separated string of work order IDs to be added to the specified set.
     */
    @testVisible
    private void getWorkOrdersForRetry(Set<Id> woIdsForWpCreation, String workOrderIds){
        for(String eachId: workOrderIds.split(',')){
            woIdsForWpCreation.add(eachId);
        }
    }
    /**
     * @description Removes duplicates from the given list of WorkOrder objects and updates the specified map with the result.
     * There could be a chance that multiple stores under same business account will be processed in same transaction
     * this method will prevent creating duplicate parent work orders.
     * @param workOrders A list of WorkOrder objects to be deduplicated.
     * @param woByActIdorWoId A map of WorkOrder objects indexed by the associated Account ID or WorkOrder ID.
     */
    @testVisible
    private void removeDuplicates(List<WorkOrder> workOrders, Map<Id, WorkOrder> woByActIdorWoId){
        for(WorkOrder eachWo: workOrders){
            if(eachWo.AccountId != null){
                if(woByActIdorWoId.containsKey(eachWo.AccountId)){
                    WorkOrder wo = woByActIdorWoId.get(eachWo.AccountId);
                    wo.Integration_Request_Ids__c = wo.Integration_Request_Ids__c +','+eachWo.Integration_Request_Ids__c;
                    wo.Associated_Account_Ids__c = wo.Associated_Account_Ids__c +','+eachWo.Associated_Account_Ids__c;
                } else {
                    woByActIdorWoId.put(eachWo.AccountId, eachWo);
                }
            }
        }
    }
    /**
     * @description Retrieves WorkOrder and WorkPlan records from the database and stores them in the relevant data structures for later processing.
     *
     * This method performs the following operations:
     * - Collects the Account IDs associated with parent and child WorkOrder records.
     * - Retrieves WorkOrder and WorkPlan records from the database using the relevant criteria.
     * - Calls the 'getWorkPlans' method to retrieve the WorkPlan records associated with the given WorkOrder record.
     */
    @testVisible
    private void getWorkOrdersAndWorkPlans(){
        Set<Id> accountIds = new Set<Id>();
        accountIds.addAll(childAccountIdToParentAccountId.keySet());
        accountIds.addAll(childAccountIdToParentAccountId.values());
        Set<String> validTypes = new Set<String>{TYPE_POS, TYPE_MARKET_PLACE, TYPE_COO};
        for (WorkOrder eachWo: WorkOrdersSelector.newInstance().selectWorkOrdersAndWorkPlansByAccountIdsAndStatusAndType(accountIds, WO_OPEN_STATUS, validTypes)){
            String storeId = accountIdToStoreId.get(eachWo.AccountId);
            Map<RESOURCE_TYPE, String> valueByRt = storeIdToResource.get(storeId);
            if(valueByRt != null ){
                //wo should open status and assuming if child is open, parent is always open.
                //collect details only from child items. Assuming child is open parent is always open.
                if(String.isNotBlank(eachWo.Integration_Request_Ids__c)){
                    valueByRt.put(RESOURCE_TYPE.SEND_IT_FOR_RETRY, String.valueOf(eachWo.Id));
                }
                if(eachWo.ParentWorkOrderId == null || WO_CLOSED_STATUS.contains(eachWo.Status)){
                    continue;
                }
                workOrderIdToWorkOrder.put(eachWo.Id, eachWo);
                if(TYPE_POS.equals(eachWo.Type__c)){
                    valueByRt.put(RESOURCE_TYPE.PARENT_POS_WORK_ORDER_ID, eachWo.ParentWorkOrderId);
                    valueByRt.put(RESOURCE_TYPE.CHILD_POS_WORK_ORDER_ID, eachWo.Id);
                }
                if(TYPE_MARKET_PLACE.equals(eachWo.Type__c) || TYPE_COO.equals(eachWo.Type__c)){
                    valueByRt.put(RESOURCE_TYPE.PARENT_MO_OR_COO_WORK_ORDER_ID, eachWo.ParentWorkOrderId);
                    valueByRt.put(RESOURCE_TYPE.CHILD_MO_OR_COO_WORK_ORDER_ID, eachWo.Id);
                    valueByRt.put(RESOURCE_TYPE.PARENT_WO_POS_ORDER_PROTOCOL, getPosOrderProtocol(eachWo.ParentWorkOrder.Order_Protocol__c));
                }
                getWorkPlans(valueByRt, eachWo.WorkPlans);
            }
        }
    }
    /**
     * @description Returns the POS order protocol based on the given order protocol value.
     * @param orderProtocol a string value representing the order protocol to be checked.
     * @return a string value representing the POS order protocol based on the given order protocol value.
     */
    @testVisible
    private String getPosOrderProtocol(String orderProtocol){
        String woOrderProtocol = String.isNotBlank(orderProtocol) ? orderProtocol : TYPE_POS;
        return !woOrderProtocol.Contains(TYPE_POS) && orderProtocolOldVsNew.containsKey(woOrderProtocol) ?
            orderProtocolOldVsNew.get(woOrderProtocol) : woOrderProtocol;

    }
    /**
     * @description This method retrieves the work plans associated with a given set of WorkOrders.
     * The retrieved work plans are processed to extract relevant information, which is stored in a map
     * @param valueByRt A Map object used to store the relevant information extracted from the retrieved
     * work plans, indexed by RESOURCE_TYPE values.
     * @param wps A List object containing the work plans to be processed.
     */
    @testVisible
    private void getWorkPlans(Map<RESOURCE_TYPE, String> valueByRt, List<WorkPlan> wps){
        for(WorkPlan eachWp: wps){
            if(WP_CLOSED_STATUS.contains(eachWp.Status__c) && TYPE_POS.equals(eachWp.Type__c)){
                valueByRt.put(RESOURCE_TYPE.CHILD_POS_WORK_PLAN_CLOSED, 'true');
                continue;
            }
            if(TYPE_POS.equals(eachWp.Type__c)){
                valueByRt.put(RESOURCE_TYPE.PARENT_POS_WORK_PLAN_ID, eachWp.Parent_Work_Plan__c);
                valueByRt.put(RESOURCE_TYPE.CHILD_POS_WORK_PLAN_ID, eachWp.Id);
            }
        }
    }

    /**
    * @description This method retrieves the account IDs associated with the store IDs of the integration requests
    * identified by the request IDs stored in the intRequestIdToStoreId map. The retrieved account IDs are then used
    * to extract relevant account and business information, which is stored in the storeIdToResource map.
    */
    @testVisible
    private void getAccountIdsFromXrefs(){
        for (Xref__c eachXref: XrefsSelector.newInstance().selectXrefsByStoreIds(new Set<String>(intRequestIdToStoreId.values()))){
            accountIdToStoreId.put(eachXref.Salesforce_Account_Name__c, eachXref.External_ID__c);
        }
        for(Account eachAccount: AccountsSelector.newInstance().selectById(accountIdToStoreId.keySet())){
            childAccountIdToParentAccountId.put(eachAccount.Id, eachAccount.ParentId);
            String storeId = accountIdToStoreId.get(eachAccount.Id);
            if(storeIdToResource.containsKey(storeId)){
                Map<RESOURCE_TYPE, String> valueByRType = storeIdToResource.get(storeId);
                valueByRType.put(RESOURCE_TYPE.ACCOUNT_ID, eachAccount.Id);
                valueByRType.put(RESOURCE_TYPE.BUSINESS_ID, eachAccount.ParentId);
                valueByRType.put(RESOURCE_TYPE.ACCOUNT_INT_ID, eachAccount.POS_Integration_ID__c);
                valueByRType.put(RESOURCE_TYPE.ACCOUNT_PROVIDER_TYPE, eachAccount.POS_Integration_Type__c);
                valueByRType.put(RESOURCE_TYPE.POS_ORDER_PROTOCOL, getPosOrderProtocol(eachAccount.Order_Protocol__c));
            }
        }
    }

    /**
    * @description This method retrieves the Integration Requests associated with a given set of IDs.
    * @param integrationRequestIds A Set object containing the IDs of the Integration Requests to be retrieved.
    */
    @testVisible
    private void getIntegrationRequests(Set<Id> integrationRequestIds){
        for(Integration_Request__c eachIr: IntegrationRequestsSelector.newInstance().selectById(IntegrationRequestIds)){
            intRequestIdToStoreId.put(eachIr.Id, eachIr.Store_Id__c);
            storeIdToResource.put(eachIr.Store_Id__c,
                new Map<RESOURCE_TYPE, String>{RESOURCE_TYPE.STORE_ID => eachIr.Store_Id__c,
                    RESOURCE_TYPE.BAT_INT_ID => eachIr.Integration_Id__c,
                    RESOURCE_TYPE.BAT_PROVIDER_TYPE => eachIr.Integration_Provider__c,
                    RESOURCE_TYPE.ON_BOARDING_ID => eachIr.Onboarding_Id__c,
                    RESOURCE_TYPE.IR_ID => eachIr.Id});
        }
    }
    /**
    * @description This method processes an integration request payload for a given use case,
    * returning a corresponding ProcessIntRequestHandler instance.
    * @param useCase A USE_CASE enum value representing the use case for the integration request.
    * @param inputPayloadByRt A Map object containing the input payload for the integration request, indexed by RESOURCE_TYPE values.
    * @return A ProcessIntRequestHandler instance corresponding to the given use case, or null if no such handler is available.
    */
    @testVisible
    private ProcessIntRequestHandler processRequestByUseCase(USE_CASE useCase, Map<RESOURCE_TYPE, String> inputPayloadByRt){
        switch on useCase {
            when CREATE_POS_WO {
                return new CreatePosParentWorkOrder();
            }
            when CREATE_POS_WP, CREATE_POS_WP_UNDER_STORE_MO_OR_COO {
                return new UpdateParentAndChildMoWoForWpCreation();
            }
            when CREATE_POS_WP_UNDER_STORE_MO_OR_COO_AND_MAKE_EXISTING_WP_DEAD, CREATE_POS_WP_UNDER_STORE_POS_AND_MAKE_EXISTING_WP_DEAD {
                return new UpdateChildWoForWpCreationAndUpdateExistingWp();
            }
            when DUPLICATE_INT_REQUEST {
                return new FlagIntRequestAsDuplicateAndUpdateChildWp();
            }
            when NO_USE_CASE_FOUND {
                return new FlagIntRequestAsNoUseCaseFound();
            }

            When else {
                return null;
            }
        }
    }
    /**
     * @description Abstract class that defines methods to handle different types of integration requests
     */
    @SuppressWarnings('PMD.ClassNamingConventions')
    public abstract class ProcessIntRequestHandler{
        /**
         * @description Method to process the integration request payload
         * @param inputPayload - Map of input payload data by RESOURCE_TYPE
         * @return outputWrapper object with the processed data
         */
        @testVisible
        private virtual outputWrapper processIntegrationRequest(Map<RESOURCE_TYPE, String> inputPayload){
            return null;
        }
        /**
         * @description Method to update the child WorkOrder with integration request data
         * @param inputPayload - Map of input payload data by RESOURCE_TYPE
         * @return WorkOrder object with updated data
         */
        @testVisible
        private WorkOrder updateChildWorkOrders(Map<RESOURCE_TYPE, String> inputPayload){
            String workOrderId = getChildWokOrderId(inputPayload);
            WorkOrder woInstance = new WorkOrder(
                Id = workOrderId,
                Order_Protocol__c = getAccountOrderProtocol(inputPayload),
                Integration_Request_Ids__c = getIntegrationRequestId(inputPayload)
            );
            return woInstance;
        }
        /**
         * @description Method to update the parent WorkOrder with integration request data
         * @param inputPayload - Map of input payload data by RESOURCE_TYPE
         * @return WorkOrder object with updated data
         */
        @testVisible
        private WorkOrder updateParentWorkOrder(Map<RESOURCE_TYPE, String> inputPayload){
            String parentWorkOrderId = inputPayload.get(RESOURCE_TYPE.PARENT_MO_OR_COO_WORK_ORDER_ID);
            WorkOrder parentWoInstance = new WorkOrder(
               Id = parentWorkOrderId,
               Order_Protocol__c = getParentWoOrderProtocol(inputPayload),
               Integration_Request_Ids__c = getIntegrationRequestId(inputPayload)
           );
           return parentWoInstance;
        }
        /**
         * @description Method to update the Account object with integration request data
         * @param inputPayload - Map of input payload data by RESOURCE_TYPE
         * @return Account object with updated data
         */
        @testVisible
        private  Account updateAccount(Map<RESOURCE_TYPE, String>  inputPayload){
            String accountId =  inputPayload.get(RESOURCE_TYPE.ACCOUNT_ID);
            String integrationId = inputPayload.get(RESOURCE_TYPE.BAT_INT_ID);
            String integrationType =  inputPayload.get(RESOURCE_TYPE.BAT_PROVIDER_TYPE);
            Account act = new Account(Id = accountId,
                POS_Integration_ID__c = integrationId,
                Order_Protocol__c = getAccountOrderProtocol(inputPayload),
                POS_Integration_Type__c =integrationType);
                return act;
        }
        /**
         * @description Method to update the existing WorkPlan object to deprecated status
         * @param inputPayload - Map of input payload data by RESOURCE_TYPE
         * @return WorkPlan object with updated data
         */
        @testVisible
        private WorkPlan updateExistingWorkPlantoDeprecated(Map<RESOURCE_TYPE, String>  inputPayload){
            String workPlanId = inputPayload.get(RESOURCE_TYPE.CHILD_POS_WORK_PLAN_ID);
            WorkPlan wpInstance = new WorkPlan(
                Id = workPlanId,
                Deprecated__c = true,
                Status__c = WP_STATUS_DEAD
            );
            return wpInstance;
        }


        @testVisible
        private String getChildWokOrderId(Map<RESOURCE_TYPE, String>  inputPayload){
            return inputPayload.containsKey(RESOURCE_TYPE.CHILD_MO_OR_COO_WORK_ORDER_ID) ?
            inputPayload.get(RESOURCE_TYPE.CHILD_MO_OR_COO_WORK_ORDER_ID): inputPayload.get(RESOURCE_TYPE.CHILD_POS_WORK_ORDER_ID);
        }
        @testVisible
        private String getAccountOrderProtocol(Map<RESOURCE_TYPE, String>  inputPayload){
            return inputPayload.containsKey(RESOURCE_TYPE.POS_ORDER_PROTOCOL) ?
                inputPayload.get(RESOURCE_TYPE.POS_ORDER_PROTOCOL) : TYPE_POS;
        }
        @testVisible
        private String getParentWoOrderProtocol(Map<RESOURCE_TYPE, String>  inputPayload){
            return inputPayload.containsKey(RESOURCE_TYPE.PARENT_WO_POS_ORDER_PROTOCOL) ?
                inputPayload.get(RESOURCE_TYPE.PARENT_WO_POS_ORDER_PROTOCOL) : TYPE_POS;
        }

        @testVisible
        private String getIntegrationRequestId(Map<RESOURCE_TYPE, String>  inputPayload){
            return inputPayload.get(RESOURCE_TYPE.IR_ID);
        }
    }

   /**
    * @description This class extends ProcessIntRequestHandler and implements the processInetgrationRequest method
    * to create a new POS Parent Work Order record.
    */
    private class CreatePosParentWorkOrder extends ProcessIntRequestHandler{
    /**
    * @description Overrides the base class method to process integration request for creating POS parent work order
    * @param inputPayload A Map containing input payload of type RESOURCE_TYPE and String
    * @return output An instance of outputWrapper class containing updated records
    */  @testVisible
        private override outputWrapper processIntegrationRequest(Map<RESOURCE_TYPE, String> inputPayload){
            outputWrapper output = new outputWrapper();
            /* Create a new WorkOrder instance with the given fields */
                WorkOrder woInstance = new WorkOrder(
                    AccountId =  inputPayload.get(RESOURCE_TYPE.BUSINESS_ID),
                    Type__c = TYPE_POS,
                    Associated_Account_Ids__c = inputPayload.get(RESOURCE_TYPE.ACCOUNT_ID),
                    Integration_Request_Ids__c = inputPayload.get(RESOURCE_TYPE.IR_ID),
                    Order_Protocol__c = TYPE_POS
                    );
                    /* Add the updated Account and new Parent Work Order instances to the output */
                    output.accounts.add(updateAccount(inputPayload));
                    output.newParentWorkOrders = new List<WorkOrder>{woInstance};

            return output;
        }
    }
    /**
     * @description Handles the processing of integration requests to update parent and child work orders for work plan creation.
     */
    private class UpdateParentAndChildMoWoForWpCreation extends ProcessIntRequestHandler{
     /**
     * @description Processes the integration request and returns the output wrapper with the updated work orders and accounts.
     * @param inputPayload The input payload map.
     * @return The output wrapper with the updated work orders and accounts.
     */ @testVisible
        private override outputWrapper processIntegrationRequest(Map<RESOURCE_TYPE, String> inputPayload){
            outputWrapper output = new outputWrapper();
            WorkOrder updatedChildWorkOrder = updateChildWorkOrders(inputPayload);
            WorkOrder updatedParentWorkOrder = updateParentWorkOrder(inputPayload);
            output.accounts.add(updateAccount(inputPayload));
            output.woIdsForWpCreation.add(updatedChildWorkOrder.Id);
            output.woIdsForWpCreation.add(updatedParentWorkOrder.Id);
            output.updateWorkOrders.add(updatedChildWorkOrder);
            output.updateWorkOrders.add(updatedParentWorkOrder);
            return output;
        }
    }
    /**
     * @description This class extends ProcessIntRequestHandler and implements the processing logic
     * for creating/updating a child work order for work plan creation and updating
     * the existing work plan.
     */
    public class UpdateChildWoForWpCreationAndUpdateExistingWp extends ProcessIntRequestHandler{
         /**
         * @description Overrides the base class method to implement processing logic for
         * updating the child work order and existing work plan.
         * @param inputPayload A Map containing the input payload data
         * @return An outputWrapper object containing the results of the processing
         */
        @testVisible
        private override outputWrapper processIntegrationRequest(Map<RESOURCE_TYPE, String> inputPayload){
            outputWrapper output = new outputWrapper();
            WorkOrder updatedChildWorkOrder = updateChildWorkOrders(inputPayload);
            WorkPlan deprecatedWorkPlan = updateExistingWorkPlantoDeprecated(inputPayload);
            output.accounts.add(updateAccount(inputPayload));
            output.woIdsForWpCreation.add(updatedChildWorkOrder.Id);
            output.updateWorkOrders.add(updatedChildWorkOrder);
            output.workPlans.add(deprecatedWorkPlan);
            return output;
        }
    }
    /**
     * @description This class extends ProcessIntRequestHandler and implements the processing logic
     * for updating Int request as duplicate when there is a ongoing child wp and integration Id is same.
     * also updates the wp with latest IR and updates account with latest Integration Id if int Id is blank.
     */
    public class FlagIntRequestAsDuplicateAndUpdateChildWp extends ProcessIntRequestHandler{
        /**
        * @description Overrides the base class method to implement processing logic for
        updating Int request as duplicate when there is a ongoing child wp and integration is same
        * @param inputPayload A Map containing the input payload data
        * @return An outputWrapper object containing the results of the processing
        */
       @testVisible
       private override outputWrapper processIntegrationRequest(Map<RESOURCE_TYPE, String> inputPayload){
           outputWrapper output = new outputWrapper();
           Id intId = inputPayload.get(RESOURCE_TYPE.IR_ID);
           output.integrationRequest.add(new Integration_Request__c(Id = intId,
           Sfdc_Status__c = IR_SFDC_STATUS_PROCESSED,
           Error_Message__c = 'Duplicate Integration Request'));

           Id childWpId = inputPayload.get(RESOURCE_TYPE.CHILD_POS_WORK_PLAN_ID);
           // update child work plan with latest integration request
           workplan childWorkPlan = new workplan(Id = childWpId,
           Integration_Request__c = intId);
           // update account with latest integration Id if the integration id blank.
           updateAccount(inputPayload);
           output.accounts.add(updateAccount(inputPayload));
           output.workPlans.add(childWorkPlan);
           return output;
       }
   }
    /**
     * @description This class extends ProcessIntRequestHandler and implements the processing logic
     * for updating Int request as failed when no matching use case found.
     */
    public class FlagIntRequestAsNoUseCaseFound extends ProcessIntRequestHandler{
        /**
        * @description Overrides the base class method to implement processing logic for
        * for updating Int request as failed when no matching use case found.
        * @param inputPayload A Map containing the input payload data
        * @return An outputWrapper object containing the results of the processing
        */
       @testVisible
       private override outputWrapper processIntegrationRequest(Map<RESOURCE_TYPE, String> inputPayload){
           outputWrapper output = new outputWrapper();
           output.integrationRequest.add(new Integration_Request__c(Id = inputPayload.get(RESOURCE_TYPE.IR_ID),
           Sfdc_Status__c = IR_SFDC_STATUS_FAILED,
           Error_Message__c = 'No matching use case found for the integration request'));
           return output;
       }
   }

    /**
     * @description This method derives the USE_CASE corresponding to a given input payload.
     * @param input A Map object containing the input payload for the integration request, indexed by RESOURCE_TYPE values.
     * @return A USE_CASE enum value representing the USE_CASE corresponding to the given input payload.
     */
    @testVisible
    private USE_CASE deriveTheUseCase(Map<RESOURCE_TYPE, String> input){
        Boolean intIdIsDifferent = isIntegrationIdIsDifferent(input);
        Boolean onGoingChildPosWp = input.containsKey(RESOURCE_TYPE.CHILD_POS_WORK_PLAN_ID);
        Boolean onGoingChildMoWo = input.containsKey(RESOURCE_TYPE.CHILD_MO_OR_COO_WORK_ORDER_ID);
        Boolean onGoingParentPOSWp = input.containsKey(RESOURCE_TYPE.PARENT_POS_WORK_PLAN_ID);
        Boolean onGoingParentMoWo = input.containsKey(RESOURCE_TYPE.PARENT_MO_OR_COO_WORK_ORDER_ID);
        Boolean onGoingChildPOsWo = input.containsKey(RESOURCE_TYPE.CHILD_POS_WORK_ORDER_ID);
            //if there is a child pos wp and it is closed consider it as work plan exists because if
        // work plan exists and closed template service will not create another work plan so sending it to CREATE_POS_WO.
        Boolean childPosWpClosed = input.containsKey(RESOURCE_TYPE.CHILD_POS_WORK_PLAN_CLOSED);

        if(onGoingChildPosWp && !intIdIsDifferent){
            return USE_CASE.DUPLICATE_INT_REQUEST;

        } else if(onGoingChildPosWo && onGoingChildPosWp && intIdIsDifferent){
            return USE_CASE.CREATE_POS_WP_UNDER_STORE_POS_AND_MAKE_EXISTING_WP_DEAD;

        } else if(onGoingChildMoWo && onGoingChildPosWp && intIdIsDifferent){
            return USE_CASE.CREATE_POS_WP_UNDER_STORE_MO_OR_COO_AND_MAKE_EXISTING_WP_DEAD;

        } else if(onGoingParentPOSWp && onGoingChildMoWo && !onGoingChildPosWp && !childPosWpClosed){
            return USE_CASE.CREATE_POS_WP_UNDER_STORE_MO_OR_COO;

        } else if(onGoingParentMoWo && onGoingChildMoWo && !onGoingParentPOSWp && !onGoingChildPosWp && !childPosWpClosed ){
            return USE_CASE.CREATE_POS_WP;

        } else if((!onGoingParentMoWo && !input.containsKey(RESOURCE_TYPE.PARENT_POS_WORK_ORDER_ID)) || childPosWpClosed){
            return USE_CASE.CREATE_POS_WO;
        }
        return USE_CASE.NO_USE_CASE_FOUND;
    }
    /**
     * @description This method checks if the integration ID is different between the input payload values for a given WorkOrder/WorkPlan creation request.
     * @param input A Map object containing the input payload for the integration request, indexed by RESOURCE_TYPE values.
     * @return A Boolean value indicating if the integration ID is different between the input payload values for a given WorkOrder/WorkPlan creation request.
     */
    @testVisible
    private Boolean isIntegrationIdIsDifferent(Map<RESOURCE_TYPE, String> input){
        String batIntId = input.get(RESOURCE_TYPE.BAT_INT_ID) != null ? input.get(RESOURCE_TYPE.BAT_INT_ID) : '';
        String batProviderType = input.get(RESOURCE_TYPE.BAT_PROVIDER_TYPE) != null ? input.get(RESOURCE_TYPE.BAT_PROVIDER_TYPE) : '';
        // if the account integration Id is blank and provider type is same consider int id is same and update the bat int Id with account int Id.
        // do not make wp dead if the the int Id on account is blank and provider type is same.
        String accountIntId = input.get(RESOURCE_TYPE.ACCOUNT_INT_ID) != null ?  input.get(RESOURCE_TYPE.ACCOUNT_INT_ID) : batIntId;
        String accuountProviderType = input.get(RESOURCE_TYPE.ACCOUNT_PROVIDER_TYPE) != null ? input.get(RESOURCE_TYPE.ACCOUNT_PROVIDER_TYPE) : '';
        Boolean providerTypeIsDifferent = batProviderType != accuountProviderType ? true : false;
        if(providerTypeIsDifferent || !batIntId.equals(accountIntId)){
            return true;
        }
        return false;
    }
    /**
     * @description This method makes the given WorkPlans current and completes the IR process.
     * @param workOrderIds A Set of WorkOrder IDs to be processed.
     * @return A Boolean value indicating the success of the operation.
     */
    @testVisible
    private Boolean makeWorkPlanCurrent(Set<Id> workOrderIds){
        // query workOrdersAndWorkPlans.
        List<WorkOrder> workOrders = WorkOrdersSelector.newInstance().selectWorkOrdersWithWorkPlansByParentWorkOrderIds(workOrderIds);
        Map<String, Id> storeIdToIntRequestId = getstoreIdToIntRequestId(workOrders);
        if(storeIdToIntRequestId == null){
            return false;
        }
        getAccountIdsFromXrefs();
        for(WorkOrder eachWo: workOrders){
            updateSobjectsToCompleteTheIrProcess(eachWo, eachWo.WorkPlans, storeIdToIntRequestId);
        }
        commitWork(uow);
        processPendingIntRequests();
        return true;
    }
    /**
     * @description This method updates the fields of SObjects to complete the integration request process for a given work order
     * @param workOrder A WorkOrder object representing the work order to be processed
     * @param workPlans A List object containing the work plans associated with the given work order
     * @param storeIdToIntRequestId A Map object containing the integration request IDs by store ID
    */
    @testVisible
    private void updateSobjectsToCompleteTheIrProcess(WorkOrder workOrder, List<WorkPlan> workPlans, Map<String, Id> storeIdToIntRequestId){
        for(WorkPlan eachWp: workPlans){
           if(TYPE_POS.equals(eachWp.Type__c) && eachWp.Parent_Work_Plan__c != null && !WP_STATUS_DEAD.equals(eachWp.Status__c)){
                if(String.isNotBlank(workOrder.Integration_Request_Ids__c)){
                    populateSObjectFields(workOrder, eachWp, workOrder.Integration_Request_Ids__c);
                    break;
                } else if(String.isNotBlank(workOrder.ParentWorkOrder.Integration_Request_Ids__c)){
                    String irId = getIrIdForChildWorkPlan(workOrder, storeIdToIntRequestId);
                    populateSObjectFields(workOrder, eachWp, irId);
                    break;
                }
            }
        }
    }
    /**
     * @description This method will pickup any pending update requests for the Ir requests which just completed creating new work plans.
     * this method will delegate processing updates to BatPosIntegrationUpdateServiceImpl.
     */
    @testVisible
    private void processPendingIntRequests(){
        Set<String> onboardingIds = new Set<String>();
        Set<Id> pendingUpdateIntRequests = new Set<Id>();
        for(Map<RESOURCE_TYPE, String> eachResource: storeIdToResource.values()){
            onboardingIds.add(eachResource.get(RESOURCE_TYPE.ON_BOARDING_ID));
        }

        for(Integration_request__c eachIr: IntegrationRequestsSelector.newInstance()
            .selectByOnboardingId(onboardingIds, new Set<String>{IR_SFDC_STATUS_PENDING})){
            if(IR_REQUEST_ACTION_UPDATE.equals(eachIr.Action__c)){
                pendingUpdateIntRequests.add(eachIr.Id);
            }
        }
        publishEventsByTopic(EVENT_TOPIC_PROCESS_UPDATE_POS_INTEGRATION_REQUEST,
            pendingUpdateIntRequests,
            processUpdatePosIntegrationRequestChunkSize
            );
    }

    /**
     * @description This method populates the Integration Request fields on the child Work Plan
     * update the integration request to processed
     * update the child work order Integration_Request_Ids__c to empty so the make work plan current will not be called again.
     * @param childWo A WorkOrder object representing the child Work Order instance.
     * @param childWp A WorkPlan object representing the child Work Plan instance.
     * @param irId A String value representing the Integration Request ID.
     * @return A Boolean value indicating if the SObject fields are populated successfully.
     */
    @testVisible
    private boolean populateSObjectFields(WorkOrder childWo, WorkPlan childWp, String irId){
        if(String.isBlank(irId) || !intRequestIdToStoreId.containsKey(irId)){
            return false;
        }
        childWp.Integration_Request__c = irId;
        uow.registerDirty(childWp);

        Integration_Request__c irInstance = new Integration_Request__c(Id = irId,
        Sfdc_Status__c = IR_SFDC_STATUS_PROCESSED);
        uow.registerDirty(irInstance);

        childWo.Integration_Request_Ids__c = '';
        uow.registerDirty(childWo);
        return true;
    }
    /**
     * @description This method retrieves the integration request IDs for a list of work orders, and maps them by store ID.
     * @param workOrders A List of WorkOrder records.
     * @return A Map object mapping store IDs to the corresponding integration request IDs, or null if no such mapping is found.
     */
    @testVisible
    private Map<String, Id> getstoreIdToIntRequestId(List<WorkOrder> workOrders){
        Set<Id> irIds = getIrIdsFromWorkOrder(workOrders);
        if(irIds.isEmpty()){
            return null;
        }
        getIntegrationRequests(irIds);
        Map<String, Id> storeIdToIntRequestId = new Map<String, Id>();
        for(Id eachIrId: intRequestIdToStoreId.keySet()){
            storeIdToIntRequestId.put(intRequestIdToStoreId.get(eachIrId), eachIrId);
        }
        return storeIdToIntRequestId;
    }
    /**
     * @description This method retrieves all integration request IDs associated with a given list of work orders.
     * @param workOrders A List of WorkOrder objects to retrieve integration request IDs from.
     * @return A Set of Integration Request IDs associated with the given work orders.
     */
    @testVisible
    private Set<Id> getIrIdsFromWorkOrder(List<WorkOrder> workOrders){
        List<Id> irIds = new List<Id>();
        for(WorkOrder eachWo: workOrders){
            if(String.isNotBlank(eachWo.Integration_Request_Ids__c)){
                irIds.addAll(eachWo.Integration_Request_Ids__c.split(','));
            } else if(String.isNotBlank(eachWo.ParentWorkOrder.Associated_Account_Ids__c)){
                irIds.addAll(eachWo.ParentWorkOrder.Integration_Request_Ids__c.split(','));
            }
        }
        return new Set<Id>(irIds);
    }

    /**
     * @description This method retrieves the Integration Request Id for a child Work Plan.
     * @param workOrder A WorkOrder object representing the child Work Order.
     * @param storeIdToIntRequestId A Map object containing Integration Request Ids by Store Ids.
     * @return A string representing the Integration Request Id for the child Work Plan.
     */
    @testVisible
    private String getIrIdForChildWorkPlan(WorkOrder workOrder, Map<String, Id> storeIdToIntRequestId){
            Set<String> irIds = new Set<String>(workOrder.ParentWorkOrder.Integration_Request_Ids__c.split(','));
            String storeId = accountIdToStoreId.containsKey(workOrder.AccountId) ? accountIdToStoreId.get(workOrder.AccountId) : null;
            String irId = storeId != null && storeIdToIntRequestId.containsKey(storeId) ? storeIdToIntRequestId.get(storeId) : null;
            Boolean irIdContainsInWoIrIds = irId !=null && irIds.contains(irId) ? true : false;
            if(irIdContainsInWoIrIds){
                return irId;
            }
            return '';
    }
    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.makeWorkPlanCurrentChunkSizeSetting = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(MAKE_WORK_PLAN_CURRENT_CHUNK_SIZE_SETTING)
                .Configuration_Value__c
        );
        this.sendWoAndWpCreationChunkSizeSetting = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(SEND_WO_FOR_WP_CREATION_CHUNK_SIZE_SETTING)
                .Configuration_Value__c
        );
        this.processUpdatePosIntegrationRequestChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PROCESS_UPDATE_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING)
                .Configuration_Value__c
        );
    }
    /**
     * @description A common method to commit unit of work.
     * @param unitOfWork
     */
    @testVisible
    private void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
            unitOfWork.commitWork();
    }

    /**
     * @description Create a Log__c record
     * @param integrationRequestIds
     */
    private void createLog(Set<Id> integrationRequestIds) {
        List<String> integrationRequestList = new List<String>((Set<String>)JSON.deserialize(JSON.serialize(integrationRequestIds), Set<String>.class));
        String integrationIdsString = String.join(integrationRequestList, ',');

        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                GENERIC_LOG_SERVICE_POS,
                GenericLogEntry.GENERIC_LOG_DOMAIN_ONBOARDING,
                GenericLogEntry.SeverityLevel.LOW
            ).logException(
                new DmlException( 'Service was successful for batch Ids: ' + integrationIdsString )
            )
            .setCategory(GenericLogEntry.GENERIC_LOG_INFORMATION)
            .setLogLevel(GenericLogEntry.GENERIC_LOG_INFORMATION)
        );
    }
}