/**
 * @author Deloitte
 * @date 10/03/2023
 * @description Service implementation class for Log related logic.
 */
public inherited sharing class LogsServiceImpl implements ILogsService {
    private static final String EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION = 'BUSINESS_ERROR_LOGS_CREATION';
    private static final String GROUP_BY_ID_TYPE_STORE_ACCOUNT_ID = 'STORE_ACCOUNT_ID';
    private static final String RECORD_IDS_SOURCE_RECORD_SUFFIX = 'Source Record Ids: ';
    private static final String SEPARATOR = System.Label.Separator;
    private Map<String, LogFields> logMessageIdentifierToLogFields;
    private Map<String, Set<Id>> logMessageIdentifierToSourceRecordIds;
    private Map<String, Set<Id>> logMessageIdentifierToStoreAccountIds;
    private Map<String, LogCreationEntry> logMessageIdentifierToLogCreationEntryWrapper;

    /**
     * @description Default constructor to instantiate variables.
     */
    public LogsServiceImpl() {
        this.logMessageIdentifierToLogFields = new Map<String, LogFields>();
        this.logMessageIdentifierToSourceRecordIds = new Map<String, Set<Id>>();
        this.logMessageIdentifierToStoreAccountIds = new Map<String, Set<Id>>();
        this.logMessageIdentifierToLogCreationEntryWrapper = new Map<String, LogCreationEntry>();
    }

    /**
     * @description It handles platform events and creates Log object instances based on the
     * passed platform events.
     * @JIRA# LEM-10033, LEM-10035, LEM-11498
     * @param events
     */
    public void handleNotifierEvents(List<Notifier__e> events) {
        for (Notifier__e event : events) {
            if (event.Topic__c == EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION) {
                collectLogDetails(
                    (Set<LogCreationEntry>) System.JSON.deserialize(
                        event.Payload__c,
                        Set<LogCreationEntry>.class
                    )
                );
            }
        }
        generateLogs();
    }

    /**
     * @description It collects Log details by processing the received
     * LogCreationEntry wrapper instances.
     * @param logCreationEntries
     */
    private void collectLogDetails(Set<LogCreationEntry> logCreationEntries) {
        Id groupById;
        LogFields logFields;
        String logMessageIdentifier;
        List<LogMessageEntry> logMessageEntries = new List<LogMessageEntry>();
        for (LogCreationEntry eachLogCreationEntry : logCreationEntries) {
            for (
                LogMessageEntry logMessageEntryInstance : eachLogCreationEntry?.logMessageEntries
            ) {
                //LEM-10849 - Changed to fire bell notification as per groupByIdType
                groupById = eachLogCreationEntry.groupByIdType == GROUP_BY_ID_TYPE_STORE_ACCOUNT_ID
                    ? logMessageEntryInstance.storeAccountId
                    : logMessageEntryInstance.businessAccountId;
                logMessageEntries.add(logMessageEntryInstance);
                logMessageIdentifier =
                    groupById +
                    SEPARATOR +
                    logMessageEntryInstance.detailedMessage;
                logFields = new LogFields(
                    logMessageEntryInstance.logType,
                    logMessageEntryInstance.sendNotification,
                    logMessageEntryInstance.logOwnerId,
                    logMessageEntryInstance.severityLevel,
                    logMessageEntryInstance.storeAccountName
                );
                logFields.businessAccountId = logMessageEntryInstance.businessAccountId;
                logFields.franchiseAccountId = logMessageEntryInstance.franchiseAccountId;
                logFields.recipientIdsToNotify = logMessageEntryInstance.recipientIdsToNotify;
                logMessageIdentifierToLogFields.put(logMessageIdentifier, logFields);
                if (!logMessageIdentifierToStoreAccountIds.containsKey(logMessageIdentifier)) {
                    logMessageIdentifierToStoreAccountIds.put(logMessageIdentifier, new Set<Id>());
                }
                logMessageIdentifierToStoreAccountIds.get(logMessageIdentifier)
                    .add(logMessageEntryInstance.storeAccountId);
                if (!logMessageIdentifierToSourceRecordIds.containsKey(logMessageIdentifier)) {
                    logMessageIdentifierToSourceRecordIds.put(logMessageIdentifier, new Set<Id>());
                }
                logMessageIdentifierToSourceRecordIds.get(logMessageIdentifier)
                    .add(logMessageEntryInstance.sourceRecordId);
                logMessageIdentifierToLogCreationEntryWrapper.put(
                    logMessageIdentifier,
                    eachLogCreationEntry
                );
            }
        }
    }

    /**
     * @description It generates Log records per business Account for each detailed message.
     */
    private void generateLogs() {
        LogEntry logEntryInstance;
        ILogger loggerInstance;
        for (String eachlogMessageIdentifier : logMessageIdentifierToLogFields.keySet()) {
            logEntryInstance = getLogEntry(
                logMessageIdentifierToLogCreationEntryWrapper.get(eachlogMessageIdentifier),
                eachlogMessageIdentifier
            );
            if (logEntryInstance != null) {
                if (loggerInstance == null) {
                    loggerInstance = Logger.add(logEntryInstance);
                } else {
                    loggerInstance.add(logEntryInstance);
                }
            }
        }
        if (loggerInstance != null) {
            loggerInstance.publish();
        }
    }

    /**
     * @description It creates Log object instance using the passed parameters.
     * @param logCreationEntry
     * @param logMessageIdentifier
     * @return LogEntry
     */
    private LogEntry getLogEntry(LogCreationEntry logCreationEntry, String logMessageIdentifier) {
        String detailedMessage;
        LogFields logFieldsInstance;
        List<String> logMessageIdentifierValues = new List<String>();
        List<Id> storeAccountIds = new List<Id>();
        logMessageIdentifierValues = logMessageIdentifier.split(SEPARATOR);
        if (logMessageIdentifierValues.size() < 2) {
            return null;
        }
        detailedMessage = logMessageIdentifierValues[1];
        logFieldsInstance = logMessageIdentifierToLogFields.get(logMessageIdentifier);
        LogEntry logEntryInstance = LogEntry.newLog(
            logCreationEntry.sourceClassName,
            logCreationEntry.sourceMethodName,
            detailedMessage
        );
        logEntryInstance.franchiseAccountId = logFieldsInstance.franchiseAccountId;
        logEntryInstance.logType = logFieldsInstance.logType;
        logEntryInstance.ownerId = logFieldsInstance.logOwnerId;
        logEntryInstance.recipientIdsToNotify = logFieldsInstance.recipientIdsToNotify;
        logEntryInstance.parentAccountId = logFieldsInstance.businessAccountId;
        logEntryInstance.recordId =
            RECORD_IDS_SOURCE_RECORD_SUFFIX +
            logMessageIdentifierToSourceRecordIds.get(logMessageIdentifier);
        logEntryInstance.sendNotification = logFieldsInstance.notifyAccountOwner;
        logEntryInstance.severity = LogEntry.SeverityLevel.valueOf(logFieldsInstance.severityLevel);
        storeAccountIds.addAll(logMessageIdentifierToStoreAccountIds.get(logMessageIdentifier));
        logEntryInstance.storeAccountId = storeAccountIds[0];
        logEntryInstance.storeAccountName = logFieldsInstance.storeAccountName;
        return logEntryInstance;
    }

    /**
     * @author Deloitte
     * @date 10/03/2023
     * @description Wrapper class to store fields for each log record creation.
     */
    private class LogFields {
        Id businessAccountId;
        Id franchiseAccountId;
        Id logOwnerId;
        String logType;
        Boolean notifyAccountOwner;
        String recipientIdsToNotify;
        String severityLevel;
        String storeAccountName;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         * @param logType
         * @param notifyAccountOwner
         * @param logOwnerId
         * @param severityLevel
         * @param storeAccountName
         */
        public LogFields(
            String logType,
            Boolean notifyAccountOwner,
            Id logOwnerId,
            String severityLevel,
            String storeAccountName
        ) {
            this.logType = logType;
            this.notifyAccountOwner = notifyAccountOwner;
            this.logOwnerId = logOwnerId;
            this.severityLevel = severityLevel;
            this.storeAccountName = storeAccountName;
        }
    }
}