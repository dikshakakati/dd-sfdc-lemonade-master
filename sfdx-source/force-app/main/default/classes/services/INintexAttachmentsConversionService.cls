/**
 * @author Deloitte
 * @date 08/23/2022
 * @description Interface for service class for Nintex Attachments conversion related logic.
 */
public interface INintexAttachmentsConversionService {
    /**
     * @description It converts Attachments uploaded by Nintex integration
     * user to Files and deletes the Attachments.
     * @param attachments
     */
    void convertAttachmentsToFiles(List<Attachment> attachments);
}