/**
 * @author DoorDash
 * @date 06/06/2023
 * @description Service implementation class for Xref's readiness validations related logic.
 */
public inherited sharing class XrefValidationServiceImpl implements IXrefValidationService, IHandleStoreReadinessValidations {
    private enum MethodTypes {
        ACTIVEMDSXREFONSTORE,
        XREFEXISTSONSTORE
    }
    private static final String LOG_SERVICE_READINESS_CHECK = 'Readiness Check';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final Map<String, MethodTypes> METHODNAMETOMETHODTYPES = new Map<String, MethodTypes>{
        'validateActiveMDSXrefOnStore' => MethodTypes.ACTIVEMDSXREFONSTORE,
        'validateXrefsOnAccount' => MethodTypes.XREFEXISTSONSTORE
    };
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private Map<Id, List<Xref__c>> accountIdToXrefs;
    private List<WorkOrder> childWorkOrders;
    private Map<Id, WorkOrder> parentWorkOrders;
    private List<Readiness_Check_Failure__c> readinessValidationFailures;
    private Map<String, Map<String, Set<String>>> readinessValidationToTypeToSubTypes;
    private Map<Id, List<Xref__c>> workOrderIdToXrefs;
    private List<Readiness_Check_Failure__c> existingReadinessValidationFailuresRecords; //* @jira LEM-13963
    private String readinessObjectName; //* @jira LEM-13963
    private static final String CLASS_NAME = 'XrefValidationServiceImpl'; //* @jira LEM-13963

    /**
     * @description Default Constructor to initialize class variables.
     */
    public XrefValidationServiceImpl() {
        this.accountIdToXrefs = new Map<Id, List<Xref__c>>();
        this.childWorkOrders = new List<WorkOrder>();
        this.parentWorkOrders = new Map<Id, WorkOrder>();
        this.readinessValidationFailures = new List<Readiness_Check_Failure__c>();
        this.readinessValidationToTypeToSubTypes = new Map<String, Map<String, Set<String>>>();
        this.workOrderIdToXrefs = new Map<Id, List<Xref__c>>();
        this.existingReadinessValidationFailuresRecords = new List<Readiness_Check_Failure__c>(); //* @jira LEM-13963
    }

    /**
     * @description It performs readiness validations on the Xrefs
     * associated with passed Work Orders according to the rules configured in the custom metadata.
     * @JIRA# LEM-1684 @jira LEM-13963
     * @param childWorkOrders
     * @param parentWorkOrders
     * @param storeReadinessValidations
     * @param existingReadinessCheckFailures
     * @param objectName
     */
    public void validate(
        List<WorkOrder> childWorkOrders,
        List<WorkOrder> parentWorkOrders,
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidations,
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures,
        String objectName
    ) {
        this.childWorkOrders.addAll(childWorkOrders);
        this.parentWorkOrders = new Map<Id, WorkOrder>(parentWorkOrders);
        this.readinessValidationToTypeToSubTypes = ReadinessValidationRulesService.collectReadinessValidationRuleMappings(
            storeReadinessValidations
        );
        this.existingReadinessValidationFailuresRecords.addAll(existingReadinessCheckFailures); //* @jira LEM-13963
        this.readinessObjectName = objectName; //* @jira LEM-13963
        runValidations(storeReadinessValidations);
        publishReadinessCheckFailures();
    }

    /**
     * @description It is used to collect Active Xrefs related to Accounts
     * associated with the Work Orders.
     * @JIRA# LEM-6369
     */
    private void collectXrefsByAccounts() {
        Map<Id, WorkOrder> accountIdToWorkOrder = new Map<Id, WorkOrder>();
        List<WorkOrder> workOrders = new List<WorkOrder>();
        workOrders.addAll(parentWorkOrders.values());
        workOrders.addAll(childWorkOrders);
        for (WorkOrder eachWorkOrder : workOrders) {
            accountIdToWorkOrder.put(eachWorkOrder.AccountId, eachWorkOrder);
        }
        getXrefsByAccountIds(accountIdToWorkOrder);
    }

    /**
     * @description It is used to collect Xrefs from related Accounts.
     * @param accountIdToWorkOrder
     */
    private void getXrefsByAccountIds(Map<Id, WorkOrder> accountIdToWorkOrder) {
        if (accountIdToWorkOrder.isEmpty()) {
            return;
        }
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectActiveMDSXrefsByStoreIds(accountIdToWorkOrder.keyset())
        ) {
            if (!accountIdToXrefs.containsKey(eachXref.Salesforce_Account_Name__c)) {
                accountIdToXrefs.put(eachXref.Salesforce_Account_Name__c, new List<Xref__c>());
            }
            accountIdToXrefs.get(eachXref.Salesforce_Account_Name__c).add(eachXref);
        }
    }

    /**
     * @description It checks whether the passed Work Order is
     * 'Storefront' bundled with 'Marketplace'.
     * @param workOrder
     * @return Boolean
     */
    private Boolean isBundledWithMarketplace(WorkOrder workOrder) {
        return workOrder.Type__c == WORK_ORDER_TYPE_STOREFRONT &&
            workOrder.Bundled_with_Marketplace__c == BUNDLED_WITH_MARKETPLACE_YES;
    }

    /**
     * @description It validates that an Active 'MDS' Xref should exists
     * on Account related to the passed Work Orders.
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateActiveMDSXrefOnStore(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                !accountIdToXrefs.containsKey(eachWorkOrder.AccountId) &&
                !isBundledWithMarketplace(eachWorkOrder) &&
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                )
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation to check whether the Xref is
     * already associated to the store Acount
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateXrefsOnAccount(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        if (accountIdToXrefs.isEmpty()) {
            return;
        }
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                accountIdToXrefs.containsKey(eachWorkOrder.AccountId) &&
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                )
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It creates 'Readiness Check Failures' records based on the passed
     * Store Readiness Validation Rule, Work Order.
     * @JIRA# LEM-6369
     * @param storeReadinessValidationRule
     * @param workOrder
     */
    private void logReadinessCheckFailure(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        WorkOrder workOrder
    ) {
        readinessValidationFailures.add(
            new Readiness_Check_Failure__c(
                Account_Name__c = workOrder.AccountId,
                Child_Work_Order__c = workOrder.Id,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId == null
                    ? workOrder.Id
                    : workOrder.ParentWorkOrderId
            )
        );
    }

    /**
     * @description It commits 'Readiness Check Failures' records in the database.
     * @JIRA# LEM-6369 // @jira LEM-13963
     */
    private void publishReadinessCheckFailures() {
        StoreReadinessModificationService.processReadinessCheckFailures(
            existingReadinessValidationFailuresRecords,
            readinessValidationFailures,
            readinessObjectName,
            CLASS_NAME
        );
    }

    /**
     * @description It run store readiness validations on child and parent Work Orders.
     * @JIRA# LEM-6369
     * @param storeReadinessValidations - custom metadata records
     */
    private void runValidations(
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidations
    ) {
        collectXrefsByAccounts();
        for (
            Store_Readiness_Validation_Rule__mdt eachStoreReadinessValidationRule : storeReadinessValidations
        ) {
            switch on
                METHODNAMETOMETHODTYPES.get(
                    eachStoreReadinessValidationRule.Service_Method_Name__c
                ) {
                when ACTIVEMDSXREFONSTORE {
                    validateActiveMDSXrefOnStore(eachStoreReadinessValidationRule, childWorkOrders);
                }
                when XREFEXISTSONSTORE {
                    validateXrefsOnAccount(eachStoreReadinessValidationRule, childWorkOrders);
                }
            }
        }
    }
}