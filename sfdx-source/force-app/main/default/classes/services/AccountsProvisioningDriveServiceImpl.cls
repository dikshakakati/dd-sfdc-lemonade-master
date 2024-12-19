/**
 * @author Deloitte
 * @date 11/08/2022
 * @description Accounts Provisioning for Drive Implementation class.
 */
public class AccountsProvisioningDriveServiceImpl implements IAccountsProvisioningDriveService {
    private static final String ACCOUNT_TYPE_FRACHISEE = 'Franchisee';
    private static final String CREATION_METHOD_MANUAL = 'Manual';
    private static final String CREATION_METHOD_AUTOMATIC = 'Automatic';
    private static final Set<String> DRIVE_AUTOMATIC_PROVISIONING_SUB_TYPES = new Set<String>{
        'Auto-Activations',
        'Net-new business',
        'Withholding'
    };
    private static final Set<String> DRIVE_MANUAL_PROVISIONING_SUB_TYPES = new Set<String>{
        'Net-new business',
        'Withholding'
    };
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String INTEGRATION_STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String INTEGRATION_STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    private static final String EXTERNAL_DB_SOURCE_DRIVE = 'DriveDb';
    private static final string STORE_RECORD_TYPE = 'Store';
    private static final string BUSINESS_RECORD_TYPE = 'Business';
    private static final string NEW_STATUS = 'NEW';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String AUTO_ACTIVATIONS_SUB_TYPE = 'Auto-Activations';
    private static final String NET_NEW_SUB_TYPE = 'Net-new business';
    private static final String WITHHOLDING_SUB_TYPE = 'Withholding';

    private enum CREATION_METHOD {
        MANUAL,
        AUTOMATIC
    }
    private static Map<String, CREATION_METHOD> creationMethodMap = new Map<String, CREATION_METHOD>{
        'Manual' => CREATION_METHOD.MANUAL,
        'Automatic' => CREATION_METHOD.AUTOMATIC
    };

    /**
     * @description Generic method to provision Drive accounts by creation method.
     * @param accountIdsByCreationMethod
     */
    public static void provisionDriveAccountsByCreationMethod(
        Map<String, Set<Id>> accountIdsByCreationMethod
    ) {
        for (String creationMethod : accountIdsByCreationMethod.keySet()) {
            CREATION_METHOD creationMethodVar = creationMethodMap.get(creationMethod);
            switch on creationMethodVar {
                when MANUAL {
                    processDriveManualWorkOrders(
                        accountIdsByCreationMethod.get(CREATION_METHOD_MANUAL)
                    );
                }
                when AUTOMATIC {
                    processDriveAutoWorkOrders(
                        accountIdsByCreationMethod.get(CREATION_METHOD_AUTOMATIC)
                    );
                }
                when else {
                    return;
                }
            }
        }
    }

    /**
     * @description It evaluates whether the passed Work Order is eligible for Drive provisioning.
     * @param workOrder
     * @return Boolean
     */
    private static Boolean isEligibleDriveParentWorkOrder(WorkOrder workOrder) {
        return (workOrder.ParentWorkOrderId == null &&
        workOrder.Account_Record_Type_Name__c == BUSINESS_RECORD_TYPE &&
        workOrder.Actual_Number_Of_Stores__c == null);
    }

    /**
     * @description It evaluates whether the passed Work Order is Drive Withholding.
     * @param workOrder
     * @return Boolean
     */
    private static Boolean isDriveWithHolding(WorkOrder workOrder) {
        return (workOrder.Sub_Type__c == WITHHOLDING_SUB_TYPE ||
        (workOrder.Sub_Type__c == AUTO_ACTIVATIONS_SUB_TYPE &&
        workOrder.Withholding_with_Auto_Activations__c) &&
        ((workOrder.Business_to_Store_Assignment__c == CREATION_METHOD_AUTOMATIC &&
        workOrder.Account_Type__c == ACCOUNT_TYPE_FRACHISEE) ||
        (workOrder.Business_to_Store_Assignment__c == CREATION_METHOD_MANUAL &&
        workOrder.Account_Type__c != ACCOUNT_TYPE_FRACHISEE)));
    }

    /**
     * @description Grab workorder from account Id
     * @param accountIdSet
     */
    private static void processDriveAutoWorkOrders(Set<Id> accountIdSet) {
        Set<WorkOrder> automaticProvisioningWorkOrders = new Set<WorkOrder>();
        if (accountIdSet.isEmpty()) {
            return;
        }
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrdersByAccountIds(accountIdSet)
        ) {
            if (DRIVE_AUTOMATIC_PROVISIONING_SUB_TYPES.contains(eachWorkOrder.Sub_Type__c)) {
                automaticProvisioningWorkOrders.add(eachWorkOrder);
            }
        }
        if (!automaticProvisioningWorkOrders.isEmpty()) {
            processAutomaticNetNewAndAutoActivationDriveWorkOrders(automaticProvisioningWorkOrders);
        }
    }

    /**
     * @description Grab workorder from account Id to process the Manual Drive workOrders
     * @param accountIdSet
     */
    private static void processDriveManualWorkOrders(Set<Id> accountIdSet) {
        Set<WorkOrder> manualProvisioningWorkOrders = new Set<WorkOrder>();
        if (accountIdSet.isEmpty()) {
            return;
        }
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrdersByAccountIds(accountIdSet)
        ) {
            if (DRIVE_MANUAL_PROVISIONING_SUB_TYPES.contains(eachWorkOrder.Sub_Type__c)) {
                manualProvisioningWorkOrders.add(eachWorkOrder);
            }
        }
        if (!manualProvisioningWorkOrders.isEmpty()) {
            processNetNewManualDriveWorkOrders(manualProvisioningWorkOrders);
        }
    }
    /**
     * @description send work orders for automatic creation of xref and bizref
     * @param workOrders
     */
    private static void processAutomaticNetNewAndAutoActivationDriveWorkOrders(
        Set<WorkOrder> workOrders
    ) {
        Map<Id, String> businessAccountIdToMpBzId = new Map<Id, String>();
        Set<Id> workOrderBusinessAccountIds = new Set<Id>();
        Set<Id> workOrderStoreAccountIds = new Set<Id>();
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                eachWorkOrder.ParentWorkOrderId != null &&
                eachWorkOrder.Account_Record_Type_Name__c == STORE_RECORD_TYPE
            ) {
                workOrderStoreAccountIds.add(eachWorkOrder.AccountId);
            }
            if (isEligibleDriveParentWorkOrder(eachWorkOrder)) {
                if (isDriveWithHolding(eachWorkOrder)) {
                    businessAccountIdToMpBzId.put(
                        eachWorkOrder.AccountId,
                        eachWorkOrder.MP_BZ_Id__c
                    );
                    continue;
                }
                workOrderBusinessAccountIds.add(eachWorkOrder.AccountId);
            }
        }

        if (!workOrderBusinessAccountIds.isEmpty()) {
            XrefAndBizRefService.createXRefsAndBusinessRefs(
                workOrderBusinessAccountIds,
                INTEGRATION_STATUS_READY_FOR_INTEGRATION,
                INTEGRATION_STATUS_SUCCESS,
                false,
                true
            );
        }
        if (!workOrderStoreAccountIds.isEmpty()) {
            XrefAndBizRefService.createXRefsAndBusinessRefs(
                workOrderStoreAccountIds,
                INTEGRATION_STATUS_READY_FOR_INTEGRATION,
                INTEGRATION_STATUS_WAITING_FOR_BUSINESS,
                true,
                false
            );
        }
        if (!businessAccountIdToMpBzId.isEmpty()) {
            XrefAndBizRefService.createXrefsAndBusinessRefsByMpBzIds(
                businessAccountIdToMpBzId,
                INTEGRATION_STATUS_READY_FOR_INTEGRATION,
                INTEGRATION_STATUS_SUCCESS,
                false,
                true
            );
        }
    }

    /**
     * @description send work orders for Manual creation of xref and bizref
     * @param workOrders
     */
    private static void processNetNewManualDriveWorkOrders(Set<WorkOrder> workOrders) {
        Map<Id, String> businessAccountIdToMpBzId = new Map<Id, String>();
        Set<Id> workOrderBusinessAccountIds = new Set<Id>();
        Set<Id> workOrderStoreAccountIds = new Set<Id>();
        for (WorkOrder eachWorkOrder : workOrders) {
            if (isEligibleDriveParentWorkOrder(eachWorkOrder)) {
                if (isDriveWithHolding(eachWorkOrder)) {
                    businessAccountIdToMpBzId.put(
                        eachWorkOrder.AccountId,
                        eachWorkOrder.MP_BZ_Id__c
                    );
                    continue;
                }
                workOrderBusinessAccountIds.add(eachWorkOrder.AccountId);
            }
            if (
                eachWorkOrder.ParentWorkOrderId != null &&
                eachWorkOrder.Account_Record_Type_Name__c == STORE_RECORD_TYPE
            ) {
                workOrderStoreAccountIds.add(eachWorkOrder.AccountId);
            }
        }
        if (!workOrderBusinessAccountIds.isEmpty()) {
            XrefAndBizRefService.createXRefsAndBusinessRefs(
                workOrderBusinessAccountIds,
                NEW_STATUS,
                INTEGRATION_STATUS_SUCCESS,
                false,
                true
            );
        }
        if (!workOrderStoreAccountIds.isEmpty()) {
            XrefAndBizRefService.createXRefsAndBusinessRefs(
                workOrderStoreAccountIds,
                NEW_STATUS,
                INTEGRATION_STATUS_WAITING_FOR_BUSINESS,
                true,
                false
            );
        }
        if (!businessAccountIdToMpBzId.isEmpty()) {
            XrefAndBizRefService.createXrefsAndBusinessRefsByMpBzIds(
                businessAccountIdToMpBzId,
                NEW_STATUS,
                INTEGRATION_STATUS_SUCCESS,
                false,
                true
            );
        }
    }
}