/**
 * @description Handler to perform all trigger based actions on Merchant Services
 * @author DoorDash QTC
 * @date 2022-09-15
 */
public class MerchantServicesHandler extends ApplicationDomainHandler {
    private static final String MX_AGREED_TO_PRODUCT_YES = 'Yes';
    private static final String SERVICE_ACTIVE_YES = 'Yes';
    /**
     * @description Constructor to instantiate a List of Merchant Services
     * @param sObjectList
     */
    public MerchantServicesHandler(List<Merchant_Service__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Merchant_Service__c.SObjectType, MerchantServicesHandler.class);
    }
    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        callWorkOrderServiceOnAfterInsert();
        MerchantServices.newInstance(this.records).inactivateExistingMxServicesOnCoreProducts();
    }
    /**
     * @description Called to perform after Update processing
     * @param existingRecords - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        callWorkOrderServiceOnAfterUpdate();
    }

    /**
     * @description LEM-2711  To call WorkOrder service from Merchant Service When it is inserted
     */
    private void callWorkOrderServiceOnAfterInsert() {
        Set<Id> orderItemIds = new Set<Id>();
        for (
            Merchant_Service__c serviceRec : (List<Merchant_Service__c>) getRecordsByFieldValue(
                Merchant_Service__c.Mx_Agreed_to_Product__c,
                MX_AGREED_TO_PRODUCT_YES
            )
        ) {
            if (serviceRec.Order_Product__c != null) {
                orderItemIds.add(serviceRec.Order_Product__c);
            }
        }
        if (orderItemIds.isEmpty()) {
            return;
        }
        OrderItemsService.initiateChildWorkOrdersCreation(orderItemIds, false);
    }

    /**
     * @description LEM-2711 To call WorkOrder service from Merchant Service When it is updated.
     */
    private void callWorkOrderServiceOnAfterUpdate() {
        Set<Id> orderItemIds = new Set<Id>();
        Boolean isManagePricingProcess = false;
        for (
            Merchant_Service__c serviceRec : (List<Merchant_Service__c>) getChangedRecords(
                new Set<Schema.SObjectField>{
                    Merchant_Service__c.Mx_Agreed_to_Product__c,
                    Merchant_Service__c.Order_Product__c
                }
            )
        ) {
            if (
                serviceRec.Mx_Agreed_to_Product__c == MX_AGREED_TO_PRODUCT_YES &&
                serviceRec.Order_Product__c != null
            ) {
                orderItemIds.add(serviceRec.Order_Product__c);
            }
        }
        if (orderItemIds.isEmpty()) {
            return;
        }
        isManagePricingProcess = MerchantServices.verifyManagePricingProcess(
            (List<Merchant_Service__c>) getRecordsByFieldValue(
                Merchant_Service__c.Active_Rates_Applied__c,
                true
            )
        );
        OrderItemsService.initiateChildWorkOrdersCreation(orderItemIds, isManagePricingProcess);
    }

    /**
     * @description Constructor Class which implements fflib_SObjectDomain.IConstructable class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjectList
         * @return MerchantServicesHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new MerchantServicesHandler(sObjectList);
        }
    }
}