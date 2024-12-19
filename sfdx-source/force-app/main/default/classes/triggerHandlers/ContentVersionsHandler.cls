/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Trigger handler class for Content Version object.
 */
public class ContentVersionsHandler extends ApplicationDomainHandler {
    /**
     * @description Default constructor method.
     * @param sObjects
     */
    public ContentVersionsHandler(List<ContentVersion> sObjects) {
        super(sObjects);
        setContextBypass(ContentVersion.SObjectType, ContentVersionsHandler.class);
    }
    /**
     * @description Constructor class implements fflib_SObjectDomain class.
     */
    public class Constructor implements fflib_SObjectDomain.Iconstructable {
        /**
         * @description this method implements construct class in fflib_SObjectDomain.
         * @param sObjects
         * @return ContentVersionsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new ContentVersionsHandler(sObjects);
        }
    }

    /**
     * @description Called to perform processing during the after before phase.
     */
    public override void onBeforeInsert() {
        ContentVersions.newInstance(this.records).addToMxFraudDocuments();
    }

    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onAfterInsert() {
        ContentVersionsService.organizeDocumentsInsertedFromAPIService(this.records);
    }
}