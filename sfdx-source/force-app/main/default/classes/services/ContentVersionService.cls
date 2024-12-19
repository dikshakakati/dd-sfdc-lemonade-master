/**
 * @author DoorDash QTC
 * @date   07/25/2022
 * @description LEM-2190
 */
public inherited sharing class ContentVersionService {
    /**
     * @description This method used to create ContentVersion(Files).
     * @param base64Data
     * @param filename
     * @param recordId
     */
    public static void createContentVersion(String base64Data, String filename , Id recordId) {
        service().createContentVersion(base64Data , filename , recordId);
    }

    private static IContentVersionService service() {
        return (IContentVersionService) Application.Service.newInstance(IContentVersionService.class);
    }
}