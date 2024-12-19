/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Service Implementation class for creating Parent Work Order, Child Work Order and Merchant Orders
 * for Tablet, Marketing Kit and Photoshoot Type of Bulk Requests
 */
public inherited sharing class BulkOrdersCreationServiceImpl implements IBulkOrdersCreationService {
    private static final String TYPE_TABLET = 'Tablet';
    private static final String TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String REQUEST_TYPE_RETURN = 'Return';
    private static final String SOURCE_BULK_REQUEST = 'Bulk Request';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String LOG_DOMAIN_BULK_ORDER = 'Bulk Order';
    private static final String LOG_CREATE_BULK_ORDERS_FAILED = 'Creation of BULK Orders Failed';

    /**
     * @description It is used for creating Parent Work Order and Child Work Order for Bulk Request
     * @param stagingRequests
     */
    public void createBulkParentAndChilOrders(
        List<Staging_Bulk_Upload_Request__c> stagingRequests
    ) {
        Map<String, Id> businessIdToParentOrderId = new Map<String, Id>();
        Map<String, Id> businessPlusStoreIdToParentOrderIdForPhotoshoot = new Map<String, Id>();
        List<WorkOrder> childWorkOrders = new List<WorkOrder>();
        Map<Id,Staging_Bulk_Upload_Request__c> bulkStagingIdToRecord = new Map<Id,Staging_Bulk_Upload_Request__c>(stagingRequests);
        Set<String> bulkParentOrderKeys = getBulkParentOrderKeys(stagingRequests);
        Map<String, Id> bulkParentOrderKeyToWorkOrderId = fetchParentOrderKeyToId(bulkParentOrderKeys);
        createParentWorkOrders(stagingRequests, bulkParentOrderKeyToWorkOrderId, businessIdToParentOrderId, businessPlusStoreIdToParentOrderIdForPhotoshoot);
        createChildWorkOrders(stagingRequests, bulkParentOrderKeyToWorkOrderId, businessIdToParentOrderId, businessPlusStoreIdToParentOrderIdForPhotoshoot, childWorkOrders);
        createMxOrdersForTablets(childWorkOrders, bulkStagingIdToRecord);
    }

    /**
     * @description It is used to form set of key(ReferenceId + Request Type + Business)
     * for the Staging Request records
     * @param stagingRecords
     * @return  Set<String>
     */
    private static Set<String> getBulkParentOrderKeys(
        List<Staging_Bulk_Upload_Request__c> stagingRecords
    ) {
        Set<String> bulkParentOrderKeys = new Set<String>();
        for (
            Staging_Bulk_Upload_Request__c eachStagingRecord : stagingRecords
        ) {
            bulkParentOrderKeys.add(eachStagingRecord.Staging_Upload_Ref__c + eachStagingRecord.Request_Type__c + eachStagingRecord.Business_ID__c);
        }
        return bulkParentOrderKeys;
    }

    /**
     * @description It is used to fetch Work Orders for the set of key(ReferenceId + Request Type + Business)
     * @param bulkParentOrderKeys
     * @return  Map<String, Id>
     */
    private static Map<String, Id> fetchParentOrderKeyToId(
        Set<String> bulkParentOrderKeys
    ) {
        Map<String, Id> bulkParentOrderKeyToWorkOrderId = new Map<String, Id>();
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrdersByBulkParentOrderKeys(bulkParentOrderKeys))
        {
            bulkParentOrderKeyToWorkOrderId.put(eachWorkOrder.Bulk_Parent_Order_Key__c, eachWorkOrder.Id);
        }
        return bulkParentOrderKeyToWorkOrderId;
    }

    /**
     * @description It is used to create Parent Work Orders for the Bulk Request
     * @param stagingRecords
     * @param bulkParentOrderKeyToWorkOrderId
     * @param businessIdToParentOrderId
     * @param businessPlusStoreIdToParentOrderIdForPhotoshoot
     */
    private static void createParentWorkOrders(
        List<Staging_Bulk_Upload_Request__c> stagingRecords,
        Map<String, Id> bulkParentOrderKeyToWorkOrderId,
        Map<String, Id> businessIdToParentOrderId,
        Map<String, Id> businessPlusStoreIdToParentOrderIdForPhotoshoot
    ) {
        Set<String> workOrderAlreadyCollected = new Set<String>();
        List<WorkOrder> parentWorkOrders = new List<WorkOrder>();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Staging_Bulk_Upload_Request__c stagingRecord : stagingRecords)
        {
            String bulkParentOrderKey = stagingRecord?.Staging_Upload_Ref__c + stagingRecord?.Request_Type__c + stagingRecord?.Business_ID__c;
            if (
                (!bulkParentOrderKeyToWorkOrderId.containsKey(bulkParentOrderKey) &&
                !workOrderAlreadyCollected.contains(bulkParentOrderKey) &&
                stagingRecord?.Type__c != TYPE_PHOTOSHOOT) ||
                stagingRecord?.Type__c == TYPE_PHOTOSHOOT
            ){
                workOrderAlreadyCollected.add(bulkParentOrderKey);
                WorkOrder parentWorkOrderInstance = createWorkOrderInstance(stagingRecord,bulkParentOrderKey,true,null);
                parentWorkOrders.add(parentWorkOrderInstance);
                uow.registerNew(parentWorkOrderInstance);
            }
        }
        commitWork(uow);
        for (WorkOrder wo : parentWorkOrders) {
            if(wo.Type__c != TYPE_PHOTOSHOOT){
               businessIdToParentOrderId.put(wo.Bulk_Parent_Order_Key__c, wo.Id);
            }
            else{
                businessPlusStoreIdToParentOrderIdForPhotoshoot.put(wo.Bulk_Parent_Order_Key__c,wo.Id);
            }
        }
    }

    /**
     * @description It is used to create Child Work Orders for the Bulk Request
     * @param stagingRecords
     * @param bulkParentOrderKeyToWorkOrderId
     * @param businessIdToParentOrderId
     * @param businessPlusStoreIdToParentOrderIdForPhotoshoot
     * @param childWorkOrders
     */
    private static void createChildWorkOrders(
        List<Staging_Bulk_Upload_Request__c> stagingRecords,
        Map<String, Id> bulkParentOrderKeyToWorkOrderId,
        Map<String, Id> businessIdToParentOrderId,
        Map<String, Id> businessPlusStoreIdToParentOrderIdForPhotoshoot,
        List<WorkOrder> childWorkOrders
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Staging_Bulk_Upload_Request__c stagingRecord : stagingRecords)
        {
            String bulkParentOrderKey = stagingRecord?.Staging_Upload_Ref__c + stagingRecord?.Request_Type__c + stagingRecord?.Business_ID__c;
            Id parentOrderId = stagingRecord?.Type__c != TYPE_PHOTOSHOOT ?
            (bulkParentOrderKeyToWorkOrderId.containsKey(bulkParentOrderKey) ? bulkParentOrderKeyToWorkOrderId.get(bulkParentOrderKey) : businessIdToParentOrderId.get(bulkParentOrderKey)) : businessPlusStoreIdToParentOrderIdForPhotoshoot.get(bulkParentOrderKey + stagingRecord?.Id);

            WorkOrder childWorkOrderInstance = createWorkOrderInstance(stagingRecord,bulkParentOrderKey,false,parentOrderId);
            childWorkOrders.add(childWorkOrderInstance);
            uow.registerNew(childWorkOrderInstance);
        }
        commitWork(uow);
    }

    /**
     * @description It is used to create Merchant Orders for Tablet Type Request
     * @param childWorkOrders
     * @param bulkStagingIdToRecord
     */
    private static void createMxOrdersForTablets(
        List<WorkOrder> childWorkOrders,
        Map<Id,Staging_Bulk_Upload_Request__c> bulkStagingIdToRecord
    ){
        Map<Id,Staging_Bulk_Upload_Request__c> childWOToStagingRequest = new Map<Id,Staging_Bulk_Upload_Request__c>();
        for(
            WorkOrder childWorkOrder : childWorkOrders
        ) {
            if(childWorkOrder.Type__c == TYPE_TABLET){
            childWOToStagingRequest.put(childWorkOrder.id,bulkStagingIdToRecord.get(childWorkOrder.Staging_Bulk_Request_Id__c));
            }
        }
        if(
            !childWOToStagingRequest.isEmpty()
        ) {
            Map<Id,WorkStep> workStepIdsToWorkStep = new Map<Id,WorkStep> (WorkStepsSelector.newInstance()
                .selectWorkStepsByWorkOrderIds(childWOToStagingRequest.keyset()));
            MxOrderCreationService.generateMxOrderForTabletBulkRequest(workStepIdsToWorkStep,childWOToStagingRequest);
        }
    }

    /**
     * @description It is used to create work order instance
     * @param stagingRecord
     * @param bulkParentOrderKey
     * @param isParentWorkOrder
     * @param parentWorkOrderId
     * @return WorkOrder
     */
    private static WorkOrder createWorkOrderInstance(
        Staging_Bulk_Upload_Request__c stagingRecord,
        String bulkParentOrderKey,
        Boolean isParentWorkOrder,
        Id parentWorkOrderId
    ) {
        WorkOrder workOrderInstance = new WorkOrder();
        workOrderInstance.AccountId = isParentWorkOrder ? stagingRecord?.Business_ID__c : stagingRecord?.Store_ID__c;
        workOrderInstance.ContactId = stagingRecord?.Contact_Id__c;
        workOrderInstance.Activated_Centrally_AC__c = stagingRecord?.Store_ID__r.Activated_Centrally_AC__c;
        workOrderInstance.Menu_to_be_Completed_By__c = stagingRecord?.Store_ID__r.Menu_to_be_Completed_By__c;
        workOrderInstance.Order_Protocol__c = stagingRecord?.Order_Protocol__c;
        workOrderInstance.Proposed_Date_of_Activation__c = stagingRecord?.Store_ID__r.Proposed_Date_of_Activation__c;
        workOrderInstance.Provisioning_Status__c = STATUS_NOT_STARTED;
        workOrderInstance.type__c = stagingRecord?.Type__c;
        workOrderInstance.sub_type__c = stagingRecord?.Type__c == TYPE_TABLET ? stagingRecord?.Request_Type__c : '';
        workOrderInstance.Creation_Source__c = SOURCE_BULK_REQUEST;
        workOrderInstance.Bulk_Parent_Order_Key__c = isParentWorkOrder ? (stagingRecord?.Type__c != TYPE_PHOTOSHOOT ?  bulkParentOrderKey : bulkParentOrderKey + stagingRecord?.Id) : '';
        workOrderInstance.ParentWorkOrderId = !isParentWorkOrder ? parentWorkOrderId : null;
        workOrderInstance.Staging_Bulk_Request_Id__c = !isParentWorkOrder ? String.valueOf(stagingRecord?.id) : '';
        workOrderInstance.Return_Components__c = String.valueOf(stagingRecord?.Return_Components__c);
        if(isParentWorkOrder){
            updateParentWorkOrderDetails(workOrderInstance,stagingRecord);
        }
        return workOrderInstance;
    }

    /**
     * @description It is used to update Parent Work Order Details.
     * @param workOrderInstance
     * @param stagingRecord
     */
    private static void updateParentWorkOrderDetails(
    	WorkOrder workOrderInstance,
        Staging_Bulk_Upload_Request__c stagingRecord
    ) {
        if(
            stagingRecord?.Type__c == TYPE_PHOTOSHOOT
        ) {
            workOrderInstance.Store_Location_for_Photoshoot__c = stagingRecord?.Store_ID__c;
            workOrderInstance.Menu_Preview_Link__c = String.isNotBlank(stagingRecord?.Menu_Preview_Link__c) ? stagingRecord?.Menu_Preview_Link__c : stagingRecord?.Menu_URL__c;
            workOrderInstance.Reason_for_Additional_Photoshoot__c = stagingRecord?.Reason_for_Additional_Photoshoot__c;
            workOrderInstance.Reason_if_Other__c = stagingRecord?.Reason_if_Other__c;
            workOrderInstance.Photoshoot_Date__c = stagingRecord?.Photoshoot_Date__c;
            workOrderInstance.Photoshoot_Time__c = stagingRecord?.Photoshoot_Time__c;
            workOrderInstance.PhotoShoot_Review_Notes_and_Tags__c = stagingRecord?.Photoshoot_Review_Notes_Tags__c;
            workOrderInstance.PhotoShoot_Vendor__c = stagingRecord?.Vendor__c;            
        }
        else {
            workOrderInstance.Product_Bundle__c = stagingRecord?.Product_Bundle__c;
        }
    }

    /**
     * @description A common method to commit unit of work.
     * @param unitOfWork
     */
    private static void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_CREATE_BULK_ORDERS_FAILED,LOG_DOMAIN_BULK_ORDER,GenericLogEntry.SeverityLevel.HIGH
                ).logException(ex)
            );
        }
    }
}
