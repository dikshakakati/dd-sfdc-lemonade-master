/**
 * @author DoorDash
 * @date 03/12/2024
 * @description Service class for Complex update processing of MDS Sync event attributes
 */
public inherited sharing class ComplexMdsAttributesProcessService {
    private static IComplexMdsAttributesProcessService service() {
        return (IComplexMdsAttributesProcessService) Application.SERVICE.newInstance(IComplexMdsAttributesProcessService.class);
    }
    /**
     * @description to update the account record fields that needs to processed via store sync event
     * @param serviceInput object record on which we will have to update a field value
     * @param mdsSyncMapping metadata record for refering the store update Json tag details
     * @param thisEventRecievedDateTime this is the store event recieved date time
     * @param storeUpdate this is the formatted JSON of the store event
     * @return MDSSyncServiceWrapper
     */
    public static MDSSyncServiceWrapper processAttribute(MDSSyncServiceWrapper serviceInput, MDS_Sync_Mapping__mdt mdsSyncMapping, DateTime thisEventRecievedDateTime, StoreUpdateIntegrationWrapper storeUpdate) {
        return service().processAttribute(serviceInput, mdsSyncMapping, thisEventRecievedDateTime, storeUpdate);
    }

}