/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Mx Order Trigger handler class
 */
public class MerchantOrdersHandler extends ApplicationDomainHandler {
    private static final String COMMA_SPLIT = ',';
    private static final String MX_ORDER_STATUS_FAILED = 'Failed';
    private static final String MX_ORDER_STATUS_FIELD_API_NAME = 'Status__c';
    private static final String MX_ORDER_TYPE_TO_REEVALUATE_STATIC_CONFIG = 'MxOrderTypesToReevaluateMxOrderItems';

    /**
     * @description default constructor method
     * @param sObjectList
     */
    public MerchantOrdersHandler(List<MX_Order__c> sObjectList) {
        super(sObjectList);
        setContextBypass(MX_Order__c.SObjectType, MerchantOrdersHandler.class);
    }

    /**
     * @description constructor Class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.Iconstructable {
        /**
         * @description this method implements construct class in fflib_SObjectDomain
         * @param sObjectList
         * @return MerchantOrdersHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new MerchantOrdersHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform processing during the before insert phase.
     */
    public override void onBeforeInsert() {
        IMerchantOrders mxOrderInstance = MerchantOrders.newInstance(this.records);
        mxOrderInstance.updateMerchantOrderStatus(this.records);
    }

    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onAfterInsert() {
        MerchantOrderItemsService.createMxOrderItems(this.records);
        MerchantOrdersService.initiateTabletIntegrationOnOrderCreation(this.records);
        MxOrderToWorkStepStatusUpdateService.updateWorkStepStatus(this.records);
    }

    /**
     * @description Called to perform processing during the after update processing.
     * @param existing - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        List<MX_Order__c> changedMxOrders = new List<MX_Order__c>(
            (List<MX_Order__c>) getChangedRecords(new Set<SObjectField>{ MX_Order__c.Status__c })
        );
        MerchantOrdersService.reevaluateMerchantOrderItemsOnVendorChange(
            collectMxOrdersWithChangedVendorByMxOrderType()
        );
        MerchantOrdersService.retryPayloadGeneration(
            collectFailedMxOrders(changedMxOrders, existing)
        );
        MerchantOrdersService.updateStatusModifiedDate(changedMxOrders);
        List<MX_Order__c> changedRecords = new List<MX_Order__c>(
            (List<MX_Order__c>) getChangedRecords(
                new Set<SObjectField>{
                    MX_Order__c.Shipment_Status_Description__c,
                    MX_Order__c.Status__c
                }
            )
        );
        List<MX_Order__c> changedPhotoShootDateRecords = new List<MX_Order__c>(
            (List<MX_Order__c>) getChangedRecords(
                new Set<SObjectField>{
                    MX_Order__c.Vendor_PhotoShoot_Date__c,
                    MX_Order__c.Vendor_PhotoShoot_Time__c
                }
            )
        );
        MxOrderToWorkStepStatusUpdateService.updateWorkStepStatus(changedRecords);
        MxOrderToWorkOrderUpdateService.updateWorkOrderPhotoShootDateAndTime(changedPhotoShootDateRecords);
        new IntegrationCriteriaEvaluator()
            .evaluateInitialCriteriaForEmailIntegration(this.records, existing);
    }

    /**
     * @description It is used to perform processing during the before update phase.
     * @param existing - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        List<MX_Order__c> vendorUpdatedMxOrders = collectMxOrdersWithChangedVendorByMxOrderType();
        IMerchantOrders mxOrderInstance = MerchantOrders.newInstance(vendorUpdatedMxOrders);
        mxOrderInstance.resetMerchantOrdersOnVendorChange(vendorUpdatedMxOrders);
    }

    /**
     * @description It collects the Mx Orders with updated Status value 'Failed'.
     * @param mxOrdersWithStatusUpdate
     * @param oldRecords
     * @return List<MX_Order__c>
     */
    private List<MX_Order__c> collectFailedMxOrders(
        List<MX_Order__c> mxOrdersWithStatusUpdate,
        Map<Id, SObject> oldRecords
    ) {
        List<MX_Order__c> failedMxOrders = new List<MX_Order__c>();
        String previousStatus;
        for (MX_Order__c eachMxOrder : mxOrdersWithStatusUpdate) {
            previousStatus = (String) oldRecords.get(eachMxOrder.Id)
                .get(MX_ORDER_STATUS_FIELD_API_NAME);
            if (
                eachMxOrder.Status__c == MX_ORDER_STATUS_FAILED &&
                previousStatus != MX_ORDER_STATUS_FAILED
            ) {
                failedMxOrders.add(eachMxOrder);
            }
        }
        return failedMxOrders;
    }

    /**
     * @description It collects the Mx Orders with updated vendor based on Mx Order Types.
     * @return List<MX_Order__c>
     */
    private List<MX_Order__c> collectMxOrdersWithChangedVendorByMxOrderType() {
        List<MX_Order__c> filteredMxOrders = new List<MX_Order__c>();
        String mxOrderTypesToRecalculateFieldsOnVendorChange = String.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(MX_ORDER_TYPE_TO_REEVALUATE_STATIC_CONFIG)
                .Configuration_Value__c
        );
        List<String> mxOrderTypes = mxOrderTypesToRecalculateFieldsOnVendorChange.contains(
                COMMA_SPLIT
            )
            ? mxOrderTypesToRecalculateFieldsOnVendorChange.split(COMMA_SPLIT)
            : new List<String>{ mxOrderTypesToRecalculateFieldsOnVendorChange };
        for (
            MX_Order__c eachMxOrder : (List<MX_Order__c>) getChangedRecords(
                new Set<SObjectField>{ MX_Order__c.Vendor__c }
            )
        ) {
            if (mxOrderTypes.contains(eachMxOrder.Type__c)) {
                filteredMxOrders.add(eachMxOrder);
            }
        }
        return filteredMxOrders;
    }
}