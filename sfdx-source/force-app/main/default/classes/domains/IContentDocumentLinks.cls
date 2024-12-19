/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Interface to add domain class methods
 */
public interface IContentDocumentLinks extends fflib_ISObjects {

     /**
     * @description Calls BriefItemsService to update Draft Contract Fields when IO Templates are inserted
     * is inserted
     * @JIRA# LEM-16593
     */
    Void updateIOTemplateLinksOnBriefItems();

}