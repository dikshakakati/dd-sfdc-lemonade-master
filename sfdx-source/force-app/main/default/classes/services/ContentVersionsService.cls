/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Service class for Content Version related logic.
 */
public inherited sharing class ContentVersionsService {
    /**
     * @description It organizes the Content Version Documents inserted from API services
     * based on type of document.
     * @JIRA# LEM-15836
     * @param contentVersions
     */
    public static void organizeDocumentsInsertedFromAPIService(
        List<ContentVersion> contentVersions
    ) {
        service().organizeDocumentsInsertedFromAPIService(contentVersions);
    }

    /**
     * @description It creates and returns instance of IContentVersionsService
     * to call methods from ContentVersionsServiceImpl.
     * @JIRA# LEM-15836
     * @return IContentVersionsService
     */
    private static IContentVersionsService service() {
        return (IContentVersionsService) Application.SERVICE.newInstance(
            IContentVersionsService.class
        );
    }
}