/**
 * @author DoorDash
 * @date 07/25/2022
 * @description Interface to add Content Document Links class methods
 */
public interface IContentVersionService {
    /**
     * @description This method used to create Content(Files).
     * @param base64Data
     * @param filename
     * @param recordId
     */
    void createContentVersion(String base64Data, String filename , Id recordId);
}