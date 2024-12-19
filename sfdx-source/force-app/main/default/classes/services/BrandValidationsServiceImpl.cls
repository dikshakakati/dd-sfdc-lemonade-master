/**
 * @author Deloitte
 * @date 04/28/2023
 * @description Service implementation class for Brand's readiness validations related logic.
 */
public inherited sharing class BrandValidationsServiceImpl implements IBrandValidationsService, IHandleStoreReadinessValidations {
    private enum MethodTypes {
        NULLVALUESBYWOTYPE
    }
    private static final Map<String, MethodTypes> METHODNAMETOMETHODTYPES = new Map<String, MethodTypes>{
        'validateNullFieldValuesByWorkOrderType' => MethodTypes.NULLVALUESBYWOTYPE
    };
    private Map<Id, Brand__c> brandsToValidate;
    private List<WorkOrder> childWorkOrders;
    private Map<Id, WorkOrder> parentWorkOrders;
    private List<Readiness_Check_Failure__c> readinessValidationFailures;
    private Map<String, Map<String, Set<String>>> readinessValidationToTypeToSubTypes;
    private List<Readiness_Check_Failure__c> existingReadinessValidationFailuresRecords; //* @jira LEM-13963
    private String readinessObjectName; //* @jira LEM-13963
    private static final String CLASS_NAME = 'BrandValidationsServiceImpl'; //* @jira LEM-13963

    /**
     * @description Default Constructor to initialize class variables.
     */
    public BrandValidationsServiceImpl() {
        this.brandsToValidate = new Map<Id, Brand__c>();
        this.childWorkOrders = new List<WorkOrder>();
        this.parentWorkOrders = new Map<Id, WorkOrder>();
        this.readinessValidationFailures = new List<Readiness_Check_Failure__c>();
        this.readinessValidationToTypeToSubTypes = new Map<String, Map<String, Set<String>>>();
        this.existingReadinessValidationFailuresRecords = new List<Readiness_Check_Failure__c>(); //* @jira LEM-13963

    }

    /**
     * @description It performs readiness validations on the Brands related to store Accounts
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
        collectBrandDetails();
        runValidations(storeReadinessValidations);
        publishReadinessCheckFailures();
    }

    /**
     * @description It is used to collect Brand records based on store Account
     * associated to child Work Orders.
     * @JIRA# LEM-6250
     */
    private void collectBrandDetails() {
        Set<Id> brandIds = new Set<Id>();
        Id brandId;
        for (WorkOrder eachWorkOrder : childWorkOrders) {
            brandId = eachWorkOrder.Account.Brand__c;
            if (brandId == null) {
                continue;
            }
            brandIds.add(brandId);
        }
        brandsToValidate = new Map<Id, Brand__c>(BrandsSelector.newInstance().selectById(brandIds));
    }

    /**
     * @description It checks whether the passed field value is null on the passed sObjectInstance.
     * @JIRA# LEM-6250
     * @param sObjectInstance
     * @param fieldName
     * @return Boolean
     */
    private Boolean isFieldValueNull(SObject sObjectInstance, String fieldName) {
        return sObjectInstance == null || sObjectInstance.get(fieldName) == null;
    }

    /**
     * @description It creates 'Readiness Check Failures' records based on the passed Work Order
     * and Store Readiness Validation Rule.
     * @JIRA# LEM-6250
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
     * @JIRA# LEM-6250 @jira LEM-13963
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
     * @JIRA# LEM-6250
     * @param storeReadinessValidations - custom metadata records
     */
    private void runValidations(
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidations
    ) {
        for (
            Store_Readiness_Validation_Rule__mdt eachStoreReadinessValidationRule : storeReadinessValidations
        ) {
            switch on
                METHODNAMETOMETHODTYPES.get(
                    eachStoreReadinessValidationRule.Service_Method_Name__c
                ) {
                when NULLVALUESBYWOTYPE {
                    validateNullFieldValuesByWorkOrderType(
                        eachStoreReadinessValidationRule,
                        childWorkOrders
                    );
                }
            }
        }
    }

    /**
     * @description It is used to perform validation to check whether the field configured
     * in the passed custom metadata is null on the Brands linked to stores associated with the
     * passed Work Orders applicable to configured Type & Sub-Type mapping.
     * @JIRA# LEM-6250
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateNullFieldValuesByWorkOrderType(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Brand__c brandToValidate;
        WorkOrder workOrderToCompare;
        for (WorkOrder eachWorkOrder : workOrders) {
            if (eachWorkOrder.Account.Brand__c == null) {
                continue;
            }
            brandToValidate = brandsToValidate.get(eachWorkOrder.Account.Brand__c);
            workOrderToCompare = eachWorkOrder.ParentWorkOrderId == null
                ? eachWorkOrder
                : eachWorkOrder.ParentWorkOrder;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    workOrderToCompare
                ) && isFieldValueNull(brandToValidate, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }
}