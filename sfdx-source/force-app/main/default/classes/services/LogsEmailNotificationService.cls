/**
 * @author Deloitte
 * @date 01/11/2023
 * @description Service class for Logs Email Notification related logic.
 */
public inherited sharing class LogsEmailNotificationService {
    /**
     * @description It is used to process passed Log records and send email
     * notifications to relevant recipients.
     * @param parentField
     * @param parentIds
     */
    public static void initiateEmailNotificationsProcessor(
        Schema.SObjectField parentField,
        Set<Id> parentIds
    ) {
        service().initiateEmailNotificationsProcessor(parentField, parentIds);
    }

    /**
     * @description It creates instance of LogsEmailNotificationServiceImpl class.
     * @return ILogsEmailNotificationService - return instance of LogsEmailNotificationServiceImpl
     */
    private static ILogsEmailNotificationService service() {
        return (ILogsEmailNotificationService) Application.SERVICE.newInstance(
            ILogsEmailNotificationService.class
        );
    }
}