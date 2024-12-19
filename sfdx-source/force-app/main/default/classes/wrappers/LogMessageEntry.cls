/**
 * @author Deloitte
 * @date 10/03/2023
 * @description Wrapper class used for storing Log message related details.
 */
public class LogMessageEntry {
    public Id businessAccountId;
    public String detailedMessage;
    public Id franchiseAccountId;
    public Id logOwnerId;
    public String logType;
    public String recipientIdsToNotify;
    public Boolean sendNotification;
    public String severityLevel;
    public Id sourceRecordId;
    public Id storeAccountId;
    public String storeAccountName;

    /**
     * @description Parameterized constructor to set wrapper class variables.
     * @param businessAccountId
     * @param detailedMessage
     * @param logOwnerId
     * @param sourceRecordId
     * @param storeAccountId
     */
    public LogMessageEntry(
        Id businessAccountId,
        String detailedMessage,
        Id logOwnerId,
        Id sourceRecordId,
        Id storeAccountId
    ) {
        this.businessAccountId = businessAccountId;
        this.detailedMessage = detailedMessage;
        this.logType = LogEntry.LogCategory.GENERIC_LOG.name();
        this.logOwnerId = logOwnerId;
        this.recipientIdsToNotify = recipientIdsToNotify;
        this.sendNotification = false;
        this.severityLevel = LogEntry.SeverityLevel.MEDIUM.name();
        this.sourceRecordId = sourceRecordId;
        this.storeAccountId = storeAccountId;
    }
}