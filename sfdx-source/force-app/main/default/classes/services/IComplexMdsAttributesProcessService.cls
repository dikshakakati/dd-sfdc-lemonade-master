/**
 * @author Doordash
 * @date 03/12/2024
 * @description Interface for service class for processing complex attributes on
 * MDS Sync Service related logic.
 */
public interface IComplexMdsAttributesProcessService {
    /**
     * @description to update the account record fields that needs to processed via store sync event
     * @param serviceInput object record on which we will have to update a field value
     * @param mdsSyncMapping metadata record for refering the store update Json tag details
     * @param thisEventRecievedDateTime this is the store event recieved date time
     * @param storeUpdate this is the formatted JSON of the store event
     * @return MDSSyncServiceWrapper
     */
    MDSSyncServiceWrapper processAttribute(MDSSyncServiceWrapper serviceInput, MDS_Sync_Mapping__mdt mdsSyncMapping, DateTime thisEventRecievedDateTime, StoreUpdateIntegrationWrapper storeUpdate);
}
