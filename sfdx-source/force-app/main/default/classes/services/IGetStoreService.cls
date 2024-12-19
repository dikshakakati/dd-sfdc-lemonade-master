/**
 * @author DoorDash
 * @date   04/18/2023
 * @description This is the service interface for retrieving the store details thru Getstore API
 */
public interface IGetStoreService {
    /**
     * @description method to get the drive store Id for a given store
     * @param storeNumber Store number for which we need to retrieve the information
     * @return Map<String, String>
     */
    Map<String, String> getDriveStoreId(String storeNumber);
}