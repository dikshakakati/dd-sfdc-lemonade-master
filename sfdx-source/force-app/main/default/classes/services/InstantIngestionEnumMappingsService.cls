/**
 * @author Deloitte
 * @date 06/10/2024
 * @description Service class used to map ENUM related field received in payload.
 */
public inherited sharing class InstantIngestionEnumMappingsService {
    /**
     * @description It is used to return the primary vertical details received in payload.
     * @param receivedPrimaryVertical
     * @return String
     */
    public static String getPrimaryVertical(String receivedPrimaryVertical) {
        return service().getPrimaryVertical(receivedPrimaryVertical);
    }
    /**
     * @description It is used to return the order Protocol details received in payload.
     * @param receivedOrderProtocol
     * @return String
     */
    public static String getOrderProtocol(String receivedOrderProtocol) {
        return service().getOrderProtocol(receivedOrderProtocol);
    }
    /**
     * @description It is used to return the Estimated store details received in payload.
     * @param receivedEstimatedStore
     * @return String
     */
    public static String getEstimatedStore(String receivedEstimatedStore) {
        return service().getEstimatedStore(receivedEstimatedStore);
    }
    /**
     * @description It is used to return the store type details received in payload.
     * @param  receivedStoreType
     * @return String
     */
    public static String getStoreType(String receivedStoreType) {
        return service().getStoreType(receivedStoreType);
    }
    /**
     * @description It is used to return the treatment group details received in payload.
     * @param receivedTreatmentGroup
     * @return String
     */
    public static String getTreatmentGroup(String receivedTreatmentGroup) {
        return service().getTreatmentGroup(receivedTreatmentGroup);
    }
    /**
     * @description It is used to create an instance of InstantIngestionEnumMappingsService class.
     * @return IInstantIngestionEnumMappingsService - return instance of InstantIngestionEnumMappingsServiceImpl
     */
    private static IInstantIngestionEnumMappingsService service() {
        return (IInstantIngestionEnumMappingsService) Application.Service.newInstance(
            IInstantIngestionEnumMappingsService.class
        );
    }
}