/**
 * @author atg
 * @date 08/08/2022
 * @description Service implementation class for ReattemptProvisioningService related logic.
 */
public inherited sharing class ReattemptProvisioningServiceImpl implements IReattemptProvisioningService {
    public static final String STATUS_SUCCESS = 'Success';
    public static final String STATUS_FAILURE = 'Failure';
    private static final String STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String STATUS_READY_FOR_COO_INTEGRATION = 'Ready for COO Integration';
    private static final String EXTERNAL_DB_SOURCE_DRIVE = 'DriveDb';
    private static final String DEFAULT_TYPE_COO_GRAVEYARD = 'COO Graveyard';
    private static final String FAILURE_INTEGRATION_MESSAGE = 'A Business Reference must be tied to the Xref before reattempting provisioning.';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String LOG_SERVICE_PROVISIONING = 'Reattempt Provisioning';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static List<IGenericLogEntry> genericLogList = new List<IGenericLogEntry>();
    /**
     * @description To reprovision Business References or Xrefs that failed Integration.
     * @param parentWorkPlanId
     * @return boolean
     */
    public boolean reattemptProvisioning(Id parentWorkPlanId) {
        List<WorkPlan> workPlanList = WorkPlansSelector.newInstance().selectIntegrationInfoForWorkPlansByParentWorkPlanId(parentWorkPlanId);

        boolean isAnyWorkPlansForReattemptProvision = false;
        if(!workPlanList.isEmpty()){
            isAnyWorkPlansForReattemptProvision = true;
        }

        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (WorkPlan wp: workPlanList) {
            updateBusinessReferences(wp, uow);
            updateXrefs(wp, uow);
        }

        try {
            uow.commitWork();
            publishGenericLog();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            genericLogList.add(getGenericLog().logException(ex));
            publishGenericLog();
        }
        return isAnyWorkPlansForReattemptProvision;
    }

     /**
     * @description To reprovision Business References or Xrefs that failed Integration.
     * called from Parent WO, If Parent WO has associated child WOs call the  reattemptProvisioningOnFailedXrefs method
     * If Drive WO and child WO doesn't exist, and parent WO.Actual_Number_Of_Stores__c = null, call reattemptProvisioningOnDriveWO method, Query on WorkPlan
     * @param parentWorkOrderId
     * @return boolean
     */
    public boolean reattemptProvisioningOnWorkOrder(Id parentWorkOrderId) {

        boolean isAnyWorkPlansForReattemptProvision = false;
        Set<Id> storeAccountIds = new Set<Id>();
        WorkOrder parentWorkOrder = new WorkOrder();
        List<Xref__c> xRefFailedList = new List<Xref__c>();
        List<WorkOrder> parentWorkOrderList  =  WorkOrdersSelector.newInstance().selectById(new Set<Id>{ parentWorkOrderId });
        if (!parentWorkOrderList.isEmpty()) {
            parentWorkOrder = parentWorkOrderList[0];
        }
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrderId }))
        {
            if (eachWorkOrder.AccountId != null){
                storeAccountIds.add(eachWorkOrder.AccountId);
            }
        }
        if (!storeAccountIds.isEmpty()) {
            xRefFailedList = XrefsSelector.newInstance().selectActiveFailedXrefsBySalesforceAccountName(storeAccountIds);
        }

        if(!xRefFailedList.isEmpty()){
            reattemptProvisioningOnFailedXrefs(xRefFailedList);
            isAnyWorkPlansForReattemptProvision = true;
        } else if (parentWorkOrder.Type__c == WORK_ORDER_TYPE_DRIVE && parentWorkOrder.Actual_Number_Of_Stores__c == null ) {
           List<WorkPlan> workPlanList = WorkPlansSelector.newInstance().selectIntegrationInfoForWorkPlansByParentWorkOrderDriveId(parentWorkOrderId);
            if (!workPlanList.isEmpty()) {
                reattemptProvisioningOnDriveWO(workPlanList);
                isAnyWorkPlansForReattemptProvision = true;
            }
        }
        return isAnyWorkPlansForReattemptProvision;
    }

    /**
     * @description update any Business_Reference__c objects tied to this work Plan.
     * @param wp
     * @param uow
     */
    private void updateBusinessReferences(WorkPlan wp, fflib_ISobjectUnitOfWork uow) {
        if ((wp.Business_Reference__c != null) && (wp.Business_Reference__r.Integration_Status__c == STATUS_FAILURE))
        {
            String integrationStatusToSet = wp.Business_Reference__r.Default_Type__c == DEFAULT_TYPE_COO_GRAVEYARD ?
                                                STATUS_READY_FOR_COO_INTEGRATION  : STATUS_READY_FOR_INTEGRATION;
            Business_Reference__c busRefToUpdate = new Business_Reference__c(
                    Id = wp.Business_Reference__c, Integration_Status__c = integrationStatusToSet);
            uow.registerDirty(busRefToUpdate);
        }
    }

    /**
     * @description update any Business_Reference__c objects tied to this work Plan.
     * @param wp
     * @param uow
     */
    private void updateXrefs(WorkPlan wp, fflib_ISobjectUnitOfWork uow) {
        boolean isBusinessReferenceNull = isBusinessReferenceNull(wp, uow);
        if (!isBusinessReferenceNull && (wp.Xref__c != null) &&
            (wp.Xref__r.Integration_Status__c == STATUS_FAILURE ||
            (wp.Xref__r.Integration_Status__c == STATUS_WAITING_FOR_BUSINESS &&
             wp.Xref__r.Business_Reference__r.Integration_Status__c == STATUS_SUCCESS))) {
                Xref__c xrefToUpdate = new Xref__c(Id = wp.Xref__c, Integration_Status__c = getStatus(wp));
                uow.registerDirty(xrefToUpdate);
                genericLogList.add(getGenericLog().logMessage(xrefToUpdate.Id +' '+xrefToUpdate.Integration_Status__c));
        }
    }

    private boolean isBusinessReferenceNull(WorkPlan wp, fflib_ISobjectUnitOfWork uow){
        boolean isBusinessRefNull = false;
        if((wp.Xref__c != null) && (wp.Xref__r.Business_Reference__c == null)){
            Xref__c xrefToUpdate = new Xref__c(Id = wp.Xref__c, Integration_Status__c = STATUS_FAILURE, Integration_Message__c = FAILURE_INTEGRATION_MESSAGE);
            uow.registerDirty(xrefToUpdate);
            isBusinessRefNull = true;
            genericLogList.add(getGenericLog().logMessage(xrefToUpdate.Id +' '+xrefToUpdate.Integration_Status__c +' '+xrefToUpdate.Integration_Message__c));
        }
        return isBusinessRefNull;
    }

    private String getStatus(WorkPlan wp){
        //Default Waiting for Business
        String xRefIntegrationStatus = STATUS_WAITING_FOR_BUSINESS ;
        if(wp.Xref__r.External_ID_Source__c == EXTERNAL_DB_SOURCE_DRIVE){
            //Set Drive to Ready For Integration
            xRefIntegrationStatus=STATUS_READY_FOR_INTEGRATION;
        }
        if ((wp.Xref__r.Business_Reference__r.Default_Type__c != null) &&
            (wp.Xref__r.Business_Reference__r.Default_Type__c == DEFAULT_TYPE_COO_GRAVEYARD)) {
            //COO set the Xref to Ready for COO Integration.
            xRefIntegrationStatus = STATUS_READY_FOR_COO_INTEGRATION;
        }
        if ((wp.Xref__r.Business_Reference__r.Integration_Status__c != null) &&
            (wp.Xref__r.Business_Reference__r.Integration_Status__c == STATUS_SUCCESS)) {
            //Only set to Ready for Integration if the Business_Reference__c is already integrated.
            xRefIntegrationStatus = STATUS_READY_FOR_INTEGRATION;
        }
        return xRefIntegrationStatus;
    }

    /**
     * @description reAttempt Provisioning on failed XRefs called from Parent WorkOrder
     * @param xRefFailedList
     */
    private void reattemptProvisioningOnFailedXrefs(List<Xref__c> xRefFailedList) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Xref__c xRef : xRefFailedList) {
            updateFailedXrefs(xRef,uow);
            updateFailedBusinessReferences(xRef,uow);
        }
        try {
            uow.commitWork();
            publishGenericLog();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            genericLogList.add(getGenericLog().logException(ex));
            publishGenericLog();
        }
    }

     /**
     * @description update any Xref__c objects tied to the Parent WorkOrder
     * @param xRef
     * @param uow
     */
    private void updateFailedXrefs(Xref__c xRef, fflib_ISobjectUnitOfWork uow) {
        if(xRef != null && xRef.Business_Reference__c == null){
            Xref__c xrefToUpdate = new Xref__c(Id = xRef.Id, Integration_Status__c = STATUS_FAILURE, Integration_Message__c = FAILURE_INTEGRATION_MESSAGE);
            uow.registerDirty(xrefToUpdate);
            genericLogList.add(getGenericLog().logMessage(xrefToUpdate.Id +' '+xrefToUpdate.Integration_Status__c+' '+xrefToUpdate.Integration_Message__c));
        }else if(xRef != null &&  xRef.Business_Reference__c != null && (xRef.Integration_Status__c == STATUS_FAILURE ||
            (xRef.Integration_Status__c == STATUS_WAITING_FOR_BUSINESS && xRef.Business_Reference__r.Integration_Status__c == STATUS_SUCCESS))){
            Xref__c xrefToUpdate = new Xref__c(Id = xRef.Id, Integration_Status__c = getXrefStatus(xRef));
            uow.registerDirty(xrefToUpdate);
            genericLogList.add(getGenericLog().logMessage(xrefToUpdate.Id +' '+xrefToUpdate.Integration_Status__c));
        }
    }

     /**
     * @description update any Business_Reference__c objects tied to the Parent WorkOrder
     * @param xRef
     * @param uow
     */
    private void updateFailedBusinessReferences(Xref__c xRef, fflib_ISobjectUnitOfWork uow) {
        if ((xRef.Business_Reference__c != null) && (xRef.Business_Reference__r.Integration_Status__c == STATUS_FAILURE))
        {
            String integrationStatusToSet = xRef.Business_Reference__r.Default_Type__c == DEFAULT_TYPE_COO_GRAVEYARD ?
                                                STATUS_READY_FOR_COO_INTEGRATION  : STATUS_READY_FOR_INTEGRATION;
            Business_Reference__c busRefToUpdate = new Business_Reference__c(
                    Id = xRef.Business_Reference__c, Integration_Status__c = integrationStatusToSet);
            uow.registerDirty(busRefToUpdate);
        }
    }

     /**
     * @description Drive WO with no child WorkOrders
     * reAttempt Provisioning on failed XRefs called from Parent WorkOrder
     * @param workPlanList
     */
    private void reattemptProvisioningOnDriveWO(List<WorkPlan> workPlanList) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (WorkPlan wp: workPlanList) {
            updateBusinessReferences(wp, uow);
            updateXrefs(wp, uow);
        }
        try {
            uow.commitWork();
            publishGenericLog();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            genericLogList.add(getGenericLog().logException(ex));
            publishGenericLog();
        }
    }

     /**
     * @description Get Status to Update on Xref
     * @param xRef
     * @return xref integration status
     */
    private String getXrefStatus(Xref__c xRef){
        //Default Waiting for Business
        String xRefIntegrationStatus = STATUS_WAITING_FOR_BUSINESS ;
        if(xRef.External_ID_Source__c == EXTERNAL_DB_SOURCE_DRIVE){
            //Set Drive to Ready For Integration
            xRefIntegrationStatus = STATUS_READY_FOR_INTEGRATION;
        }
        if ((xRef.Business_Reference__r.Default_Type__c != null) &&
            (xRef.Business_Reference__r.Default_Type__c == DEFAULT_TYPE_COO_GRAVEYARD)) {
            //COO set the Xref to Ready for COO Integration.
            xRefIntegrationStatus = STATUS_READY_FOR_COO_INTEGRATION;
        }
        if ((xRef.Business_Reference__r.Integration_Status__c != null) &&
            (xRef.Business_Reference__r.Integration_Status__c == STATUS_SUCCESS)) {
            //Only set to Ready for Integration if the Business_Reference__c is already integrated.
            xRefIntegrationStatus = STATUS_READY_FOR_INTEGRATION;
        }
        return xRefIntegrationStatus;
    }

    /**
     * @description Get log instance of IGenericLogEntry implementation
     * @return instance of IGenericLogEntry imlementation
     */
    @TestVisible
    private static IGenericLogEntry getGenericLog(){
        return GenericLoggerService.createGenericLog(
            LOG_SERVICE_PROVISIONING,
            LOG_DOMAIN_PROVISIONING,
            GenericLogEntry.SeverityLevel.HIGH
        );
    }

    /**
     * @description Publish log instances added to list
     */
    @TestVisible
    private static void publishGenericLog(){
        GenericLoggerService.publish(genericLogList);
        genericLogList.clear();
    }
}