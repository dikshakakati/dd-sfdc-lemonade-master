/**
 * @author Deloitte
 * @date 08/04/2022
 * @description Interface to add ContentDocumentLinkSelector class methods
 */
public interface IContentDocumentLinkSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is to get the ContentDocumentLink records
     * @param setIds Set of Ids
     * @return list of ContentDocumentLink records
     */
    List<ContentDocumentLink> selectById(Set<Id> setIds);

    /**
     * @description This method is to get ContentDocumentLink Ids
     * @param setIds Set of Ids
     * @param numberOfDays
     * @return list of ContentDocumentLink records
     */
    List<ContentDocumentLink> selectNotesByLinkedEntityAndLastModifiedDate(
        Set<Id> setIds,
        Integer numberOfDays
    );

    /**
     * @description This method is to get ContentDocumentLink data for files
     * with a Title that ends in completed.pdf linked to a quote in the Set of Ids
     * @param setIds Set of Ids
     * @return list of ContentDocumentLink records
     */
    List<ContentDocumentLink> selectCompletedTitlesByLinkedEntity(Set<Id> setIds);

    /**
     * @description This method is to get ContentDocumentLink data for files
     * with a Title that starts with Insertion_order_for_quotename and linked entity is quote
     * @param setIds Set of Ids
     * @return list of ContentDocumentLink records
     */
    List<ContentDocumentLink> selectDraftIOTemplates(Set<Id> setIds);
}