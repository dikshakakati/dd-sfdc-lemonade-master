/**
 * @author Deloitte
 * @date 08/17/2022
 * @description Attachments trigger handler class.
 */
public class AttachmentsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method
     * @param attachments
     */
    public AttachmentsHandler(List<Attachment> attachments) {
        super(attachments);
        setContextBypass(Attachment.SObjectType, AttachmentsHandler.class);
    }

    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onAfterInsert() {
        NintexAttachmentsConversionService.convertAttachmentsToFiles(
            (List<Attachment>) getRecords()
        );
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjects
         * @return AttachmentsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new AttachmentsHandler(sObjects);
        }
    }
}