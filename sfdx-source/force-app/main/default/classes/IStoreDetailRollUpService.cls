/**
 * @author Deloitte
 * @date 08/09/2024
 * @description Service interface for Store Detail roll up related logic.
 */
public interface IStoreDetailRollUpService {
    /**
     * @description To publish roll up event for Address Verification Status.
     * @param storeDetailsToRollUp
     */
    void publishAddressVerificationRollUpEvents(List<Store_Detail__c> storeDetailsToRollUp);
    /**
     * @description To perform roll up calculation on Address Verification Status.
     * @param storeDetailIds
     */
    void rollUpAddressVerificationStatus(Set<Id> storeDetailIds);
}