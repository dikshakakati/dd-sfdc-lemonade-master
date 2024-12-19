/**
 * @author Deloitte
 * @date 08/23/2022
 * @description Service implementation class for Logs email notification related logic.
 */
public inherited sharing class LogsEmailNotificationServiceImpl implements ILogsEmailNotificationService {
    private static final String COMMA_SEPARATOR = ',';
    private static final String FLOW_PARAM_RECIPIENT_IDS = 'recipientIdsToSendEmail';
    private static final String FLOW_PARAM_PARENT_ID = 'parentId';

    /**
     * @description It is used to process the Log records and send email
     * notifications to relevant recipients.
     * TODO: To improve implementation by handling successful emails sent scenario.
     * @param parentField
     * @param parentIds
     */
    public void initiateEmailNotificationsProcessor(
        Schema.SObjectField parentField,
        Set<Id> parentIds
    ) {
        Schema.SObjectField secondaryParentField = parentField == Log__c.Parent_Account_Id_18__c
            ? Log__c.Franchise_Parent_Account_Id_18__c
            : null;
        Id parentId;
        Map<Id, Set<String>> parentIdToRecepientIds = new Map<Id, Set<String>>();
        for (
            Log__c eachLog : LogsSelector.newInstance()
                .selectLogsEligibleToSendNotification(parentField, parentIds, secondaryParentField)
        ) {
            parentId = (Id) eachLog.get(parentField);
            if (!parentIdToRecepientIds.containsKey(parentId)) {
                parentIdToRecepientIds.put(parentId, new Set<String>());
            }
            parentIdToRecepientIds.get(parentId)
                .addAll(
                    new Set<String>(
                        eachLog.Recipient_Ids_To_Send_Notification__c.split(COMMA_SEPARATOR)
                    )
                );
        }
        sendEmailNotifications(parentIdToRecepientIds);
    }

    /**
     * @description It triggers email notification to recepients
     * by the passed parent Ids through flow.
     * @param parentIdToRecepientIds
     */
    private void sendEmailNotifications(Map<Id, Set<String>> parentIdToRecepientIds) {
        if (parentIdToRecepientIds.isEmpty()) {
            return;
        }
        Map<String, Object> flowParams = new Map<String, Object>();
        for (Id eachParentId : parentIdToRecepientIds.keySet()) {
            if (parentIdToRecepientIds.get(eachParentId).isEmpty()) {
                continue;
            }
            flowParams.put(FLOW_PARAM_RECIPIENT_IDS, parentIdToRecepientIds.get(eachParentId));
            flowParams.put(FLOW_PARAM_PARENT_ID, eachParentId);
            new Flow.Interview.Subflow_Send_Email_Notification_To_Recipient_Ids(flowParams).start();
        }
    }
}