/**
 * @author Deloitte
 * @date 08/23/2022
 * @description Service class for Nintex Attachments conversion related logic.
 */
public inherited sharing class NintexAttachmentsConversionService {
    /**
     * @description It converts Attachments uploaded by Nintex integration
     * user to Files and deletes the Attachments.
     * @JIRA# LEM-2616
     * @param attachments
     */
    public static void convertAttachmentsToFiles(List<Attachment> attachments) {
        service().convertAttachmentsToFiles(attachments);
    }

    /**
     * @description It creates instance of NintexAttachmentsConversionServiceImpl class.
     * @return INintexAttachmentsConversionService - return instance of NintexAttachmentsConversionServiceImpl
     */
    private static INintexAttachmentsConversionService service() {
        return (INintexAttachmentsConversionService) Application.Service.newInstance(
            INintexAttachmentsConversionService.class
        );
    }
}