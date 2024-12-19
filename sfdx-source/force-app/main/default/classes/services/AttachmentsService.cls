/**
 * @author Deloitte
 * @date 08/23/2022
 * @description Service class for Attachment related logic.
 */
public inherited sharing class AttachmentsService {
    /**
     * @description It converts Attachments to Files.
     * @JIRA# LEM-2616
     * @param attachments
     */
    public static void convertToFiles(List<Attachment> attachments) {
        service().convertToFiles(attachments);
    }

    /**
     * @description It converts Attachments to Files with passed
     * Unit of Work instance.
     * @JIRA# LEM-2616
     * @param unitOfWorkInstance
     * @param attachments
     */
    public static void convertToFiles(
        fflib_ISObjectUnitOfWork unitOfWorkInstance,
        List<Attachment> attachments
    ) {
        service().convertToFiles(unitOfWorkInstance, attachments);
    }

    /**
     * @description It deletes the passed Attachments.
     * @JIRA# LEM-2616
     * @param attachments
     */
    public static void remove(List<Attachment> attachments) {
        service().remove(attachments);
    }

    /**
     * @description It deletes the passed Attachments with passed
     * Unit of Work instance.
     * @JIRA# LEM-2616
     * @param unitOfWorkInstance
     * @param attachments
     */
    public static void remove(
        fflib_ISObjectUnitOfWork unitOfWorkInstance,
        List<Attachment> attachments
    ) {
        service().remove(unitOfWorkInstance, attachments);
    }

    /**
     * @description It creates instance of AttachmentsServiceImpl class.
     * @return IAttachmentsService - return instance of AttachmentsServiceImpl
     */
    private static IAttachmentsService service() {
        return (IAttachmentsService) Application.Service.newInstance(IAttachmentsService.class);
    }
}