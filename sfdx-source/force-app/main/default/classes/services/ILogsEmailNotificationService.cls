/**
 * @author Deloitte
 * @date 01/11/2024
 * @description Interface for LogsEmailNotificationService class.
 */
public interface ILogsEmailNotificationService {
    /**
     * @description It is used to process passed Log records and send email
     * notifications to relevant recipients.
     * @param parentField
     * @param parentIds
     */
    void initiateEmailNotificationsProcessor(Schema.SObjectField parentField, Set<Id> parentIds);
}