/**
 * @author DoorDash
 * @description Selector interface for ContentVersion SObject.
 **/
public interface IContentVersionsSelector extends fflib_ISObjectSelector {
    /**
     * @description Retrieves a List of ContentVersion by a Set of their IDs
     * @param idSet
     * @return List<ContentVersion> - List of ContentVersion
     */
    List<ContentVersion> selectById(Set<Id> idSet);

    /**
     * @description Returns a List of ContentVersions by ContentDocumentId
     * @param documentIds - ContentDocumentIds
     * @return List<ContentVersion>
     **/
    List<ContentVersion> selectByContentDocumentIds(Set<Id> documentIds);

    /**
     * @description Returns a List of the latest ContentVersions by ContentDocumentId
     * @param documentIds - ContentDocumentIds
     * @return List<ContentVersion>
     **/
    List<ContentVersion> selectLatestByContentDocumentIds(Set<Id> documentIds);

    /**
     * @description It queries Content Versions along with Fraud Document details
     * based on passed Store Account Ids.
     * @param relatedToIds
     * @return List<ContentVersion>
     */
    List<ContentVersion> selectByRelatedStoreIds(Set<Id> relatedToIds);
}