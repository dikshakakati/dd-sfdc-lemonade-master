/**
 * @author Deloitte
 * @date 08/23/2022
 * @description Service implementation class for Nintex Attachments conversion related logic.
 */
public inherited sharing class NintexAttachmentsConversionServiceImpl implements INintexAttachmentsConversionService {
    /**
     * @description It converts Attachments uploaded by Nintex integration
     * user to Files and deletes the Attachments.
     * @JIRA# LEM-2616
     * @param attachments
     */
    public void convertAttachmentsToFiles(List<Attachment> attachments) {
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UnitOfWork.newInstance();
        if (!isValidUploadToConvertIntoFiles()) {
            return;
        }
        AttachmentsService.convertToFiles(unitOfWorkInstance, attachments);
        AttachmentsService.remove(unitOfWorkInstance, attachments);
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception commitException) {
            Logger.publish(LogEntry.newExceptionLog(commitException, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description It checks whether the Attachment upload is valid to convert into Files.
     * @JIRA# LEM-2616
     * @return Boolean
     */
    private Boolean isValidUploadToConvertIntoFiles() {
        return UserInfo.getUserName().startsWithIgnoreCase(System.Label.NintexUserName);
    }
}