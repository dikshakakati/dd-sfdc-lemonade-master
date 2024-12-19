/**
 * @author Deloitte
 * @date 08/09/2024
 * @description Service class for Store Detail Roll Up.
 */
public inherited sharing class StoreDetailRollUpService {
    /**
     * @description To publish roll up event for Address Verification Status.
     * @param storeDetailsToRollUp
     */
    public static void publishAddressVerificationRollUpEvents(
        List<Store_Detail__c> storeDetailsToRollUp
    ) {
        service().publishAddressVerificationRollUpEvents(storeDetailsToRollUp);
    }

    /**
     * @description To perform roll up calculation on Address Verification Status.
     * @param storeDetailIds
     */
    public static void rollUpAddressVerificationStatus(Set<Id> storeDetailIds) {
        service().rollUpAddressVerificationStatus(storeDetailIds);
    }

    private static IStoreDetailRollUpService service() {
        return (IStoreDetailRollUpService) Application.Service.newInstance(
            IStoreDetailRollUpService.class
        );
    }
}