/**
 * @description Handler to perform all trigger based actions on ContentDocumentLink
 * @author Deloitte
 * @date 07/03/2024
 */
public class ContentDocumentLinksHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor to instantiate a List of ContentDocumentLink
     * @param sObjectList
     */
    public ContentDocumentLinksHandler(List<ContentDocumentLink> sObjectList) {
        super(sObjectList);
        setContextBypass(ContentDocumentLink.SObjectType, ContentDocumentLinksHandler.class);
    }
    /**
     * @description Constructor Class which implements fflib_SObjectDomain.IConstructable class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjectList
         * @return ContentDocumentLinksHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new ContentDocumentLinksHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        ContentDocumentLinks.newInstance(this.records).updateIOTemplateLinksOnBriefItems();
    }
}