/**
 * @author Deloitte
 * @date 08/23/2022
 * @description Interface for service class for Attachment related logic.
 */
public interface IAttachmentsService {
    /**
     * @description It converts Attachments to Files.
     * @param attachments
     */
    void convertToFiles(List<Attachment> attachments);

    /**
     * @description It converts Attachments to Files with passed
     * Unit of Work instance.
     * @param unitOfWorkInstance
     * @param attachments
     */
    void convertToFiles(fflib_ISObjectUnitOfWork unitOfWorkInstance, List<Attachment> attachments);

    /**
     * @description It deletes the passed Attachments.
     * @param attachments
     */
    void remove(List<Attachment> attachments);

    /**
     * @description It deletes the passed Attachments with passed
     * Unit of Work instance.
     * @param unitOfWorkInstance
     * @param attachments
     */
    void remove(fflib_ISObjectUnitOfWork unitOfWorkInstance, List<Attachment> attachments);
}