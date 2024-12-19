/**
 * @author Deloitte
 * @date 08/23/2022
 * @description Service implementation class for Attachment related logic.
 */
public inherited sharing class AttachmentsServiceImpl implements IAttachmentsService {
    /**
     * @description It converts Attachments to Files.
     * @param attachments
     */
    public void convertToFiles(List<Attachment> attachments) {
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UnitOfWork.newInstance();
        convertToFiles(unitOfWorkInstance, attachments);
    }

    /**
     * @description It converts Attachments to Files with passed
     * Unit of Work instance.
     * @param unitOfWorkInstance
     * @param attachments
     */
    public void convertToFiles(
        fflib_ISObjectUnitOfWork unitOfWorkInstance,
        List<Attachment> attachments
    ) {
        for (Attachment eachAttachment : attachments) {
            unitOfWorkInstance.registerNew(
                new ContentVersion(
                    PathOnClient = eachAttachment.Name,
                    Title = eachAttachment.Name,
                    Description = eachAttachment.Description,
                    VersionData = eachAttachment.Body,
                    //Setting FirstPublishLocationId marks view access for parent record
                    FirstPublishLocationId = eachAttachment.ParentId
                )
            );
        }
    }

    /**
     * @description It registers a new UOW instance for deletion
     * of the passed Attachment records.
     * @param attachments
     */
    public void remove(List<Attachment> attachments) {
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UnitOfWork.newInstance();
        remove(unitOfWorkInstance, attachments);
    }

    /**
     * @description It registers passed UOW instance for deletion
     * of the passed Attachment records.
     * @param unitOfWorkInstance
     * @param attachments
     */
    public void remove(fflib_ISObjectUnitOfWork unitOfWorkInstance, List<Attachment> attachments) {
        for (Attachment eachAttachment : attachments) {
            unitOfWorkInstance.registerDeleted(new Attachment(Id = eachAttachment.Id));
        }
    }
}