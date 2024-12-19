/**
 * @author Deloitte
 * @date 06/10/2024
 * @description Interface of service class for InstantIngestionEnumMappingsService.
 */
public interface IInstantIngestionEnumMappingsService {
    /**
     * @description It is used to return the primary vertical value received in payload.
     * @param receivedPrimaryVertical
     * @return String
     */
    String getPrimaryVertical(String receivedPrimaryVertical);
    /**
     * @description It is used to return the order Protocol value received in payload.
     * @param receivedOrderProtocol
     * @return String
     */
    String getOrderProtocol(String receivedOrderProtocol);
    /**
     * @description It is used to return the Estimated store value received in payload.
     * @param receivedStoreType
     * @return String
     */
    String getEstimatedStore(String receivedStoreType);
    /**
     * @description It is used to return the  store type value received in payload.
     * @param  receivedTreatmentGroup
     * @return String
     */
    String getStoreType(String receivedTreatmentGroup);
    /**
     * @description It is used to return the treatment group value received in payload.
     * @param receivedTreatmentGroup
     * @return String
     */
    String getTreatmentGroup(String receivedTreatmentGroup);
}