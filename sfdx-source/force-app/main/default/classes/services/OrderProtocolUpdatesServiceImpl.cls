/**
 * @author DoorDash
 * @date 03/25/2024
 * @description This class will process order protocol updates on store accounts.
 */
public inherited sharing class OrderProtocolUpdatesServiceImpl implements IOrderProtocolUpdatesService {

    private static final String LOG_DOMAIN_NAME = 'Provisioning';
    private static final String LOG_SERVICE_NAME = 'OrderProtocolUpdatesServiceImpl';
    private static final  List<String> IGNORED_STATUSES = new List<String>{'Dead','Onboarding Complete'};

    private static final String POS_STRING = 'POS';
    private static final String MENU_STRING = 'Menu';
    private static final String TABLET_STRING = 'Tablet';

    private static final String DEAD_STATUS = 'Dead';
    private static final String OTHER_STATUS_REASON = 'Other';

    private static String accountId;

    /**
     * @description It is used for processing the store Accounts Order Protocol updates on the WO(s)
     * @param storeAccountMap
     */
    public void processOrderProtocolUpdatesOnStoreAccounts(Map<Id, Account> storeAccountMap){
        List<WorkOrder> workOrders = WorkOrdersSelector.newInstance().selectInProgressWorkOrdersWithParentDetailsByAccountIds(storeAccountMap.keyset());
        if(workOrders.isEmpty()){
            return;
        }
        WorkOrder childWo = workOrders[0];
        accountId = childWo.AccountId;
        Boolean updatedOrderProtocolOnbothChildAndParent = false;

        String newOrderProtocol = storeAccountMap.get(accountId).Order_Protocol__c;
        String oldOrderProtocol = childWo.Order_Protocol__c;

        if(childWo.ParentWorkOrder.Actual_Number_Of_Stores__c == 1) {
            updatedOrderProtocolOnbothChildAndParent = updateOrderProtocolOnWO(false, childWo, newOrderProtocol);
        } else{
            List<WorkOrder> allChildWosExceptThisStoreWo = WorkOrdersSelector.newInstance().selectAllChildWosByOrderProtocol(childWo.ParentWorkOrderId, newOrderProtocol);
            if(!allChildWosExceptThisStoreWo.isEmpty() && childWo.ParentWorkOrder.Actual_Number_Of_Stores__c == allChildWosExceptThisStoreWo.size()+1) {
                updatedOrderProtocolOnbothChildAndParent = updateOrderProtocolOnWO(false, childWo, newOrderProtocol);
            } else {
                updateOrderProtocolOnWO(true, childWo, newOrderProtocol);
            }
        }
        if(updatedOrderProtocolOnbothChildAndParent){
            invokeReevaluateWPService(childWo.ParentWorkOrderId);
            handleWorkPlansDeprecation(childWo.ParentWorkOrderId, oldOrderProtocol, newOrderProtocol);
        }
    }

    @SuppressWarnings('PMD.CyclomaticComplexity')
    @future
    private static void handleWorkPlansDeprecation(Id parentWorkOrderId, String oldOrderProtocol, String newOrderProtocol){
        List<String> workPlansNeedsToBeDead = new List<String>();
        //Possible cases for WP deprecations
        //Case 1 - Old one contains POS & Tablet, new one doesn't contain POS & Tablet - deprecate "POS" & "Tablet" WP related work steps
        //Case 2 - Old one doesn't contain POS & Tablet, new one contains POS - deprecate "Menu" WP related Work Steps
        //Case 3 - Old one contains Tablet, new one contains POS & Tablet - deprecate "Menu" WP related Work Steps
        //Case 4 - Old one contains POS, new one doesn't contain POS - deprecate "POS" WP related work steps
        //Case 5 - Old one contains Tablet, new one doesn't contain POS - deprecate "Tablet" WP related work steps
        if(oldOrderProtocol.contains(POS_STRING) && oldOrderProtocol.contains(TABLET_STRING) && !newOrderProtocol.contains(POS_STRING) && !newOrderProtocol.contains(TABLET_STRING)) {
            workPlansNeedsToBeDead.add(POS_STRING);
            workPlansNeedsToBeDead.add(TABLET_STRING);
        } else if(!oldOrderProtocol.contains(POS_STRING) && !oldOrderProtocol.contains(TABLET_STRING) && newOrderProtocol.contains(POS_STRING)) {
            workPlansNeedsToBeDead.add(MENU_STRING);
        } else if(oldOrderProtocol.contains(TABLET_STRING) && newOrderProtocol.contains(POS_STRING) && newOrderProtocol.contains(TABLET_STRING)){
            workPlansNeedsToBeDead.add(MENU_STRING);
        } else if(oldOrderProtocol.contains(POS_STRING) && !newOrderProtocol.contains(POS_STRING)) {
            workPlansNeedsToBeDead.add(POS_STRING);
        } else if(oldOrderProtocol.contains(TABLET_STRING) && !newOrderProtocol.contains(POS_STRING)) {
            workPlansNeedsToBeDead.add(TABLET_STRING);
        }
        if(workPlansNeedsToBeDead.isEmpty()){
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for(WorkStep ws: WorkStepsSelector.newInstance().selectWorkStepsByParentWorkOrderAndPlanName(parentWorkOrderId, workPlansNeedsToBeDead)){
            ws.Status__c = DEAD_STATUS;
            ws.Status_Reason__c = OTHER_STATUS_REASON;
            uow.registerDirty(ws);
        }
        string serviceName = LOG_SERVICE_NAME+'- Update Work Step Status to Dead';
        commitDmlTransactions(uow, serviceName, parentWorkOrderId);
    }

    private boolean updateOrderProtocolOnWO(Boolean updateOnlyChildWo, WorkOrder childWo, String newOrderProtocol){
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        WorkOrder storeWo = new WorkOrder(Id = childWo.Id, Order_Protocol__c = newOrderProtocol);
        uow.registerDirty(storeWo);
        if(!updateOnlyChildWo && !IGNORED_STATUSES.contains(childWo.ParentWorkOrder.Status)){
            WorkOrder parentWo = new WorkOrder(Id = childWo.ParentWorkOrderId, Order_Protocol__c = newOrderProtocol);
            uow.registerDirty(parentWo);
        }
        string serviceName = LOG_SERVICE_NAME+'- Update Order Protocol on Work Order';
        return commitDmlTransactions(uow, serviceName, accountId);
    }

    /**
     * @description This method is used to commit DML transactions in this accounts service and log any errors to scalyr
     * @param uow
     * @param serviceName
     * @param recordId
     * @return boolean
     */
    public static boolean commitDmlTransactions(fflib_ISObjectUnitOfWork uow, String serviceName, Id recordId) {
        Boolean isCommittedSuccessfully = true;
        try {
            uow.commitWork();
        } catch (Exception unitOfWorkException) {
            //set the Account Id in error message so that we can search by Id in Scalayr
            String errorMessage = unitOfWorkException.getMessage();
            errorMessage = errorMessage+'-'+recordId;
            unitOfWorkException.setMessage(errorMessage);
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    serviceName,LOG_DOMAIN_NAME,GenericLogEntry.SeverityLevel.MEDIUM
                ).logException(unitOfWorkException)
            );
            isCommittedSuccessfully = false;
        }
        return isCommittedSuccessfully;
    }
    @future
    private static void invokeReevaluateWPService(Id parentWoId){
        try{
            ReevaluateWorkPlansOnWorkOrderController.reevaluateWorkPlans(parentWoId);
        } catch(Exception e){
            //set the parentWoId Id in error message so that we can search by Id in Scalayr
            String errorMessage = e.getMessage();
            string serviceName = LOG_SERVICE_NAME+'- WorkPlan reevaluation Service';
            errorMessage = errorMessage+'-'+parentWoId;
            e.setMessage(errorMessage);
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    serviceName,LOG_DOMAIN_NAME,GenericLogEntry.SeverityLevel.LOW
                ).logException(e)
            );
        }
    }
}