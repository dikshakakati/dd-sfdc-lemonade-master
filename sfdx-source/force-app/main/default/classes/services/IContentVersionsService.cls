/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Interface of service class for Content Version related logic.
 */
public interface IContentVersionsService {
    /**
     * @description It organizes the Content Version Documents inserted from API services
     * based on type of document.
     * @param contentVersions
     */
    void organizeDocumentsInsertedFromAPIService(List<ContentVersion> contentVersions);
}