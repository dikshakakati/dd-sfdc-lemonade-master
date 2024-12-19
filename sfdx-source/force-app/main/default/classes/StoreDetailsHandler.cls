/**
 * @author Deloitte
 * @date 07/08/2024
 * @description Trigger Handler for Store Detail object.
 */
public class StoreDetailsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method
     * @param sObjects - Store Details Record List
     */
    public StoreDetailsHandler(List<Store_Detail__c> sObjects) {
        super(sObjects);
        setContextBypass(Store_Detail__c.SObjectType, StoreDetailsHandler.class);
    }
    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjects - List of SObjects
         * @return StoreDetailsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new StoreDetailsHandler(sObjects);
        }
    }

    /**
     * @description Called to perform before insert processing
     */
    public override void onBeforeInsert() {
        StoreDetails.newInstance(this.records).captureUserEnteredAddress();
    }
    /**
     * @description It is used to perform processing after Store Detail insertion.
     */
    public override void onAfterInsert() {
        List<Store_Detail__c> storeDetailrecords = new List<Store_Detail__c>();
        for (Store_Detail__c eachStoreDetail : (List<Store_Detail__c>) this.records) {
            if (eachStoreDetail.Address_Verification_Status__c != 'Not Applicable') {
                storeDetailrecords.add(eachStoreDetail);
            }
        }
        AddressVerificationService.publishAddressVerificationEvent(storeDetailrecords);
    }
    /**
     * @description It is used to perform processing before Store Details are updated.
     * @param existing
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        StoreDetailRollUpService.publishAddressVerificationRollUpEvents(
            storesWithUpdatedAddressVerificationStatus()
        );
    }
    /**
     * @description Called to perform after Undelete processing
     */
    public override void onAfterUndelete() {
        AddressVerificationService.publishAddressVerificationEvent(this.records);
    }

    /**
     * @description It is used to get Store Details with updated Address Verification Status.
     * @return List<Store_Detail__c>
     */
    private List<Store_Detail__c> storesWithUpdatedAddressVerificationStatus() {
        return new List<Store_Detail__c>(
            (List<Store_Detail__c>) getChangedRecords(
                new Set<SObjectField>{ Store_Detail__c.Address_Verification_Status__c }
            )
        );
    }
}