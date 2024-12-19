/**
 * @author Deloitte
 * @date 02/03/2022
 * @description used to create new log records.
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessivePublicCount, PMD.ExcessiveParameterList')
public class LogEntry {
    /**
     * @description String used to format the governor limits stored in the log
     */
    public static final String GOVERNOR_LIMITS_STRING_FORMAT =
        '1. SOQL Queries used / SOQL Queries allowed: {0}/{1}\n' +
        '2. Number of DML records / Number allowed: {2}/{3}\n' +
        '3. Number of DML statements used so far / Number allowed: {4}/{5}\n' +
        '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: {6}/{7}\n' +
        '5. Number of records queried so far / Number allowed: {8}/{9}';

    /**
     * @description Generates a new log object based on the message provided.
     * Assumes LOW severity.
     * @param message String error message to capture in the log
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newLog(String message) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        LogEntry logEntry = new LogEntry(message, traceString, LogEntry.SeverityLevel.LOW);
        return logEntry;
    }

    /**
     * @description Generates a new log object based on the message and severity level provided.
     * @param message String error message to capture in the log
     * @param severityLevel LogEntry.SeverityLevel enum to indicate the level of severity
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newLog(String message, SeverityLevel severityLevel) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        LogEntry logEntry = new LogEntry(message, traceString, severityLevel);
        return logEntry;
    }

    /**
     * @description Generates a new log object based on the message and severity level provided.
     * @param className Class Name to capture in the log
     * @param methodName Method Name enum to capture in log
     * @param message String error message to capture in the log
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newLog(String className, String methodName, String message) {
        LogEntry logEntry = new LogEntry();
        logEntry.className = className;
        logEntry.methodName = methodName;
        logEntry.message = message;
        return logEntry;
    }

    /**
     * @description Generates a new log object based on the message and severity level provided.
     * @param className Class Name to capture in the log
     * @param methodName Method Name enum to capture in log
     * @param message String error message to capture in the log
     * @param service Name of the service running at the time of the logging
     * @param recordId Id of the record for which this method is logging
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newLog(
        String className,
        String methodName,
        String message,
        String service,
        String recordId
    ) {
        LogEntry logEntry = new LogEntry();
        logEntry.className = className;
        logEntry.methodName = methodName;
        logEntry.message = message;
        logEntry.service = service;
        logEntry.recordId = recordId;
        return logEntry;
    }

    /**
     * @description Generates a new log object based on the exception provided.
     * Assumes LOW severity
     * @param exceptionObj Any standard or custom exception.
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newExceptionLog(Exception exceptionObj) {
        String message = exceptionObj.getMessage().left(131072);
        String traceString = exceptionObj.getStackTraceString();
        return new LogEntry(message, traceString, SeverityLevel.LOW).withException(exceptionObj);
    }

    /**
     * @description Generates a new log object based on the exception and the severity level provided.
     * @param exceptionObj Any standard or custom exception.
     * @param severityLevel LogEntry.SeverityLevel enum to indicate the level of severity
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newExceptionLog(Exception exceptionObj, SeverityLevel severityLevel) {
        String message = exceptionObj.getMessage().left(131072);
        String traceString = exceptionObj.getStackTraceString();
        return new LogEntry(message, traceString, severityLevel).withException(exceptionObj);
    }

    /**
     * @description Generates a new log object based on the exception and the severity level provided.
     * @param exceptionObj Any standard or custom exception.
     * @param severityLevel LogEntry.SeverityLevel enum to indicate the level of severity
     * @param service Name of the service running at the time of the logging
     * @param recordId Id of the record for which this method is logging
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newExceptionLog(
        Exception exceptionObj,
        SeverityLevel severityLevel,
        String service,
        String recordId
    ) {
        String message = exceptionObj.getMessage().left(131072);
        String traceString = exceptionObj.getStackTraceString();
        return new LogEntry(message, traceString, severityLevel, service, recordId)
            .withException(exceptionObj);
    }

    /**
     * @description Generates a new log object for a batch process error.
     * @param message String error message to capture in the log
     * @param batchJobId String Id of the asynchronous job.
     * @param severityLevel LogEntry.SeverityLevel enum to indicate the level of severity
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newBatchLog(
        String message,
        String batchJobId,
        SeverityLevel severityLevel
    ) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        return new LogEntry(message, traceString, severityLevel).withBatchJobId(batchJobId);
    }

    /**
     * @description Generates a new log object for a batch process error.
     * @param message String error message to capture in the log
     * @param batchJobId String Id of the asynchronous job.
     * @param severityLevel LogEntry.SeverityLevel enum to indicate the level of severity
     * @param service Name of the service running at the time of the logging
     * @param recordId Id of the record for which this method is logging
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newBatchLog(
        String message,
        String batchJobId,
        SeverityLevel severityLevel,
        String service,
        String recordId
    ) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        return new LogEntry(message, traceString, severityLevel, service, recordId)
            .withBatchJobId(batchJobId);
    }

    /**
     * @description Generates a new log object for a batch process exception.
     * @param exceptionObj Any standard or custom exception.
     * @param batchJobId String Id of the asynchronous job.
     * @param severityLevel LogEntry.SeverityLevel enum to indicate the level of severity
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newBatchLog(
        Exception exceptionObj,
        String batchJobId,
        SeverityLevel severityLevel
    ) {
        String message = exceptionObj.getMessage().left(131072);
        String traceString = exceptionObj.getStackTraceString();
        return new LogEntry(message, traceString, severityLevel)
            .withBatchJobId(batchJobId)
            .withException(exceptionObj);
    }

    /**
     * @description Generates a new log object for an Apex API callout error
     * @param message String error message to capture in the log
     * @param responseStatus The response status value from System.HttpResponse.getStatus()
     * @param responseStatusCode The response status code from System.HttpResponse.getStatusCode()
     * @param requestEndpoint The target url for the callout from System.HttpRequest.getEndpoint()
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newCalloutLog(
        String message,
        String responseStatus,
        String responseStatusCode,
        String requestEndpoint
    ) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        return new LogEntry(message, traceString, SeverityLevel.LOW)
            .withCallout(responseStatus, responseStatusCode, requestEndpoint)
            .withLogType(LogCategory.API_CALLOUT_EXCEPTION);
    }

    /**
     * @description Generates a new log object for an Apex API callout error
     * @param message String error message to capture in the log
     * @param responseStatus The response status value from System.HttpResponse.getStatus()
     * @param responseStatusCode The response status code from System.HttpResponse.getStatusCode()
     * @param requestEndpoint The target url for the callout from System.HttpRequest.getEndpoint()
     * @param service Name of the service running at the time of the logging
     * @param recordId Id of the record for which this method is logging
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newCalloutLog(
        String message,
        String responseStatus,
        String responseStatusCode,
        String requestEndpoint,
        String service,
        String recordId
    ) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        return new LogEntry(message, traceString, SeverityLevel.LOW, service, recordId)
            .withCallout(responseStatus, responseStatusCode, requestEndpoint)
            .withLogType(LogCategory.API_CALLOUT_EXCEPTION);
    }

    /**
     * @description Generates a new log object for a list of failed Database.SaveResult objects
     * @param dmlResultList List of Database.SaveResult objects
     * @param dmlRecordList List of SObjects included in the DML transaction
     * @param severityLevel LogEntry.SeverityLevel enum to indicate the level of severity
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newDmlLog(
        List<Database.SaveResult> dmlResultList,
        List<SObject> dmlRecordList,
        SeverityLevel severityLevel
    ) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        return new LogEntry('', traceString, severityLevel)
            .withLogType(LogCategory.DML_EXCEPTION)
            .withDmlResults(dmlResultList, dmlRecordList);
    }

    /**
     * @description Generates a new log object for a list of failed Database.SaveResult objects
     * @param dmlResultList List of Database.SaveResult objects
     * @param dmlRecordList List of SObjects included in the DML transaction
     * @param severityLevel LogEntry.SeverityLevel enum to indicate the level of severity
     * @param service Name of the service running at the time of the logging
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newDmlLog(
        List<Database.SaveResult> dmlResultList,
        List<SObject> dmlRecordList,
        SeverityLevel severityLevel,
        String service
    ) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        return new LogEntry('', traceString, severityLevel, service, '')
            .withLogType(LogCategory.DML_EXCEPTION)
            .withDmlResults(dmlResultList, dmlRecordList);
    }

    /**
     * @description Generates a new log object for a list of failed Database.UpsertResult objects
     * @param dmlResultList List of Database.UpsertResult objects
     * @param dmlRecordList List of SObjects included in the DML transaction
     * @param severityLevel LogEntry.SeverityLevel enum to indicate the level of severity
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newDmlLog(
        List<Database.UpsertResult> dmlResultList,
        List<SObject> dmlRecordList,
        SeverityLevel severityLevel
    ) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        return new LogEntry('', traceString, severityLevel)
            .withLogType(LogCategory.DML_EXCEPTION)
            .withDmlResults(dmlResultList, dmlRecordList);
    }

    /**
     * @description Generates a new log object for a list of failed Database.UpsertResult objects
     * @param dmlResultList List of Database.UpsertResult objects
     * @param dmlRecordList List of SObjects included in the DML transaction
     * @param severityLevel LogEntry.SeverityLevel enum to indicate the level of severity
     * @param service Name of the service running at the time of the logging
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newDmlLog(
        List<Database.UpsertResult> dmlResultList,
        List<SObject> dmlRecordList,
        SeverityLevel severityLevel,
        String service
    ) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        return new LogEntry('', traceString, severityLevel, service, '')
            .withLogType(LogCategory.DML_EXCEPTION)
            .withDmlResults(dmlResultList, dmlRecordList);
    }

    /**
     * @description Generates a new log object for a list of failed Database.DeleteResult objects
     * @param dmlResultList List of Database.DeleteResult objects
     * @param dmlRecordList List of SObjects included in the DML transaction
     * @param severityLevel LogEntry.SeverityLevel enum to indicate the level of severity
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newDmlLog(
        List<Database.DeleteResult> dmlResultList,
        List<SObject> dmlRecordList,
        SeverityLevel severityLevel
    ) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        return new LogEntry('', traceString, severityLevel)
            .withLogType(LogCategory.DML_EXCEPTION)
            .withDmlResults(dmlResultList, dmlRecordList);
    }

    /**
     * @description Generates a new log object for a list of failed Database.DeleteResult objects
     * @param dmlResultList List of Database.DeleteResult objects
     * @param dmlRecordList List of SObjects included in the DML transaction
     * @param severityLevel LogEntry.SeverityLevel enum to indicate the level of severity
     * @param service Name of the service running at the time of the logging
     * @return LogEntry object required by Logger.
     */
    public static LogEntry newDmlLog(
        List<Database.DeleteResult> dmlResultList,
        List<SObject> dmlRecordList,
        SeverityLevel severityLevel,
        String service
    ) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        return new LogEntry('', traceString, severityLevel, service, '')
            .withLogType(LogCategory.DML_EXCEPTION)
            .withDmlResults(dmlResultList, dmlRecordList);
    }

    /**
     * @description Provides a list of possible categories or log type values
     */
    public enum LogCategory {
        GENERIC_LOG,
        API_CALLOUT_EXCEPTION,
        DML_EXCEPTION,
        BUSINESS_ERROR
    }

    /**
     * @description Provides a list of possible severity levels values
     */
    public enum SeverityLevel {
        LOW,
        MEDIUM,
        HIGH,
        CRITICAL
    }

    /**
     * @description Public read only property for the request id. Privately set.
     */
    public String requestId {
        get {
            if (requestId == null) {
                requestId = Request.getCurrent().getRequestId();
            }
            return requestId;
        }
        private set;
    }

    /**
     * @description Public read only property for quiddity. Privately set.
     */
    public Quiddity quiddity {
        get {
            if (quiddity == null) {
                quiddity = Request.getCurrent().getQuiddity();
            }
            return quiddity;
        }
        private set;
    }

    /**
     * @description Public read only property for platform limits for the current transaction.. Privately set.
     */
    public String governorLimits {
        get {
            return String.format(
                GOVERNOR_LIMITS_STRING_FORMAT,
                new List<String>{
                    String.valueOf(Limits.getQueries()),
                    String.valueOf(Limits.getLimitQueries()),
                    String.valueOf(Limits.getDmlRows()),
                    String.valueOf(Limits.getLimitDmlRows()),
                    String.valueOf(Limits.getDmlStatements()),
                    String.valueOf(Limits.getLimitDmlStatements()),
                    String.valueOf(Limits.getCpuTime()),
                    String.valueOf(Limits.getLimitCpuTime()),
                    String.valueOf(Limits.getQueryRows()),
                    String.valueOf(Limits.getLimitQueryRows())
                }
            );
        }
        private set;
    }

    /**
     * @description Public property for Exception object.
     */
    public Exception exceptionObj {
        get {
            return exceptionObj;
        }
        set {
            this.exceptionObj = value;
            this.lineNumber = value.getLineNumber();
            this.stackTrace = value.getStackTraceString().left(131072);
            this.logType = value.getTypeName();
            this.message = value.getMessage();
        }
    }

    /**
     * @description Public message property.
     */
    public String message { get; set; }

    /**
     * @description Public severity property.
     */
    public SeverityLevel severity { get; set; }

    /**
     * @description Public logType property.  Value is derived from the LogCategory name or the Exception type
     */
    public String logType { get; set; }

    /**
     * @description Public class name property.  The class that called the log.
     */
    public String className { get; set; }

    /**
     * @description Public class method name property.  The class method that called the log.
     */
    public String methodName { get; set; }

    /**
     * @description Public service property.
     */
    public String service { get; set; }

    /**
     * @description Public record id property.  Contains the record Ids from DmlException logs
     */
    public String recordId { get; set; }

    /**
     * @description Public batch job id property.
     */
    public String batchJobId { get; set; }

    /**
     * @description Public class line number property.
     */
    public Integer lineNumber { get; set; }

    /**
     * @description Public stack trace property.
     */
    public String stackTrace { get; set; }

    /**
     * @description Public callout response status property.
     */
    public String calloutResponseStatus { get; set; }

    /**
     * @description Public callout response status code property.
     */
    public String calloutResponseStatusCode { get; set; }

    /**
     * @description Public callout request endpoint property.
     */
    public String calloutRequestEndpoint { get; set; }

    /**
     * @description Public property for the number of failed records.
     */
    public Integer failedRecordCount { get; set; }

    /**
     * @description Public franchise Account Id property.
     */
    public Id franchiseAccountId { get; set; }

    /**
     * @description Public owner id property.
     */
    public Id ownerId { get; set; }

    /**
     * @description Public parent account id property.
     */
    public Id parentAccountId { get; set; }

    /**
     * @description Public recipient ids to notify property.
     */
    public String recipientIdsToNotify { get; set; }

    /**
     * @description Public send notification property.
     */
    public Boolean sendNotification { get; set; }

    /**
     * @description Public store account id property.
     */
    public Id storeAccountId { get; set; }

    /**
     * @description Public store account name property.
     */
    public String storeAccountName { get; set; }

    /**
     * @description Constructor
     */
    public LogEntry() {
        this('');
    }

    /**
     * @description Constructor
     * @param trace String stack trace that is used to derive the class name and class method
     */
    public LogEntry(String trace) {
        this('', trace);
    }

    /**
     * @description Overloaded constructor
     * @param message String error message to log
     * @param trace String stack trace that is used to derive the class name and class method
     */
    public LogEntry(String message, String trace) {
        this(message, trace, SeverityLevel.LOW);
    }

    /**
     * @description Overloaded constructor
     * @param message String error message to log
     * @param trace String stack trace that is used to derive the class name and class method
     * @param severityLevel SeverityLog enum
     */
    public LogEntry(String message, String trace, SeverityLevel severityLevel) {
        this.message = message;
        this.stackTrace = trace;
        this.className = getClassName(trace);
        this.methodName = getMethodName(trace);
        this.failedRecordCount = 0;
        this.logType = LogCategory.GENERIC_LOG.name();
        this.severity = (severityLevel == null) ? LogEntry.SeverityLevel.LOW : severityLevel;
    }

    /**
     * @description Overloaded constructor
     * @param message String error message to log
     * @param trace String stack trace that is used to derive the class name and class method
     * @param severityLevel SeverityLog enum
     * @param service Name of the service running at the time of the logging
     * @param recordId Id of the record for which this method is logging
     */
    public LogEntry(
        String message,
        String trace,
        SeverityLevel severityLevel,
        String service,
        String recordId
    ) {
        this.message = message;
        this.stackTrace = trace;
        this.className = getClassName(trace);
        this.methodName = getMethodName(trace);
        this.failedRecordCount = 0;
        this.logType = LogCategory.GENERIC_LOG.name();
        this.severity = (severityLevel == null) ? LogEntry.SeverityLevel.LOW : severityLevel;
        this.service = service;
        this.recordId = recordId;
    }

    /**
     * @description Fluent method to apply a LogCategory value to the LogEntry object
     * @param logCategory LogCategory enum
     * @return LogEntry this
     */
    public LogEntry withLogType(LogCategory logCategory) {
        this.logType = logCategory.name();
        return this;
    }

    /**
     * @description Fluent method to apply a batchJobId value to the LogEntry object
     * @param batchJobId String id of the async apex job
     * @return LogEntry this
     */
    public LogEntry withBatchJobId(String batchJobId) {
        this.batchJobId = batchJobId;
        return this;
    }

    /**
     * @description Fluent method to apply an Exception object to the LogEntry object
     * @param e Exception object
     * @return LogEntry this
     */
    public LogEntry withException(Exception e) {
        this.exceptionObj = e;
        return this;
    }

    /**
     * @description Fluent method to apply callout values to the LogEntry object
     * @param responseStatus HttpResponse.getStatus() value
     * @param responseStatusCode HttpResponse.getStatusCode() value
     * @param requestEndpoint HttpRequest.getEndpoint() value
     * @return LogEntry this
     */
    public LogEntry withCallout(
        String responseStatus,
        String responseStatusCode,
        String requestEndpoint
    ) {
        this.calloutResponseStatus = responseStatus;
        this.calloutResponseStatusCode = responseStatusCode;
        this.calloutRequestEndpoint = requestEndpoint;
        return this;
    }

    /**
     * @description Fluent method to apply Database.SaveResult values to the LogEntry object
     * @param dmlResultList List<Database.SaveResult> objects
     * @param dmlRecordList List<SObject> records in the DML transaction
     * @return LogEntry this
     */
    public LogEntry withDmlResults(
        List<Database.SaveResult> dmlResultList,
        List<SObject> dmlRecordList
    ) {
        if (dmlResultList == null || dmlResultList.isEmpty()) {
            return this;
        }

        Set<String> errors = new Set<String>();
        Set<String> recordIds = new Set<String>();
        for (Integer i = 0; i < dmlResultList.size(); i++) {
            Database.SaveResult result = dmlResultList[i];
            SObject record = dmlRecordList[i];
            if (record.Id != null) {
                recordIds.add(record.Id);
            }
            errors.addAll(serializeErrorMessages(result.getErrors()));
        }
        if (errors.size() == 0) {
            return this;
        }
        return withDmlResults(errors, recordIds);
    }

    /**
     * @description Fluent method to apply Database.UpsertResult values to the LogEntry object
     * @param dmlResultList List<Database.UpsertResult> objects
     * @param dmlRecordList List<SObject> records in the DML transaction
     * @return LogEntry this
     */
    public LogEntry withDmlResults(
        List<Database.UpsertResult> dmlResultList,
        List<SObject> dmlRecordList
    ) {
        if (dmlResultList == null || dmlResultList.isEmpty()) {
            return this;
        }
        Set<String> errors = new Set<String>();
        Set<String> recordIds = new Set<String>();
        for (Integer i = 0; i < dmlResultList.size(); i++) {
            Database.UpsertResult result = dmlResultList[i];
            SObject record = dmlRecordList[i];
            if (record.Id != null) {
                recordIds.add(record.Id);
            }
            errors.addAll(serializeErrorMessages(result.getErrors()));
        }
        if (errors.size() == 0) {
            return this;
        }
        return withDmlResults(errors, recordIds);
    }

    /**
     * @description Fluent method to apply Database.DeleteResult values to the LogEntry object
     * @param dmlResultList List<Database.DeleteResult> objects
     * @param dmlRecordList List<SObject> records in the DML transaction
     * @return LogEntry this
     */
    public LogEntry withDmlResults(
        List<Database.DeleteResult> dmlResultList,
        List<SObject> dmlRecordList
    ) {
        if (dmlResultList == null || dmlResultList.isEmpty()) {
            return this;
        }
        Set<String> errors = new Set<String>();
        Set<String> failedRecordIds = new Set<String>();
        for (Integer i = 0; i < dmlResultList.size(); i++) {
            Database.DeleteResult result = dmlResultList[i];
            if (result.isSuccess()) {
                continue;
            }
            SObject record = dmlRecordList[i];
            if (record.Id != null) {
                failedRecordIds.add(record.Id);
            }
            errors.addAll(serializeErrorMessages(result.getErrors()));
        }

        if (errors.size() == 0) {
            return this;
        }
        return withDmlResults(errors, failedRecordIds);
    }

    /**
     * @description Generates the Log__c record to save
     * @return Log__c
     */
    public Log__c toRecord() {
        Log__c log = new Log__c(
            Batch_Job_Id__c = this.batchJobId,
            Callout_Request_Endpoint__c = this.calloutRequestEndpoint,
            Callout_Status_Code__c = this.calloutResponseStatusCode,
            Class_Line_Number__c = this.lineNumber,
            Class_Method_Name__c = this.methodName,
            Class_Name__c = this.className,
            Detailed_Message__c = this.message,
            Failed_Record_Count__c = this.failedRecordCount,
            Franchise_Parent_Account_Id_18__c = this.franchiseAccountId,
            Governor_Limits_Logged__c = this.governorLimits,
            Log_Type__c = this.logType,
            Parent_Account_Id_18__c = this.parentAccountId,
            Quiddity__c = this.quiddity.name(),
            Recipient_Ids_to_Send_Notification__c = this.recipientIdsToNotify,
            Record_Id__c = this.recordId,
            Request_Id__c = this.requestId,
            Severity_Level__c = this.severity.name(),
            Stack_Trace__c = this.stackTrace,
            Status__c = this.calloutResponseStatus,
            Store_Account_Id_18__c = this.storeAccountId,
            Store_Account_Name__c = this.storeAccountName,
            Service__c = this.service
        );
        // To resolve INVALID_CROSS_REFERENCE_KEY exception:
        // Owner ID: owner cannot be blank: [OwnerId] exception
        if (this.ownerId != null) {
            log.OwnerId = this.ownerId;
        }
        // To resolve INVALID_TYPE_ON_FIELD_IN_RECORD exception:
        // Send Notification: value not of required type: : [Send_Notification__c]
        if (this.sendNotification != null) {
            log.Send_Notification__c = this.sendNotification;
        }
        return log;
    }

    /**
     * @description Summarizes the results of the Database result objects
     * @param errors Set<String> error messages from Database result objects
     * @param failedRecordIds Set<String> record ids that failed in the DML transaction attempt
     * @return LogEntry Returns this to provide a fluent api
     */
    private LogEntry withDmlResults(Set<String> errors, Set<String> failedRecordIds) {
        this.failedRecordCount += failedRecordIds.size();
        this.message = convertSetToString(errors, '\n');
        this.recordId = convertSetToString(failedRecordIds, ', ');
        return this;
    }

    /**
     * @description Derives the class name from the string of an Exception stack trace
     * @param trace String stack trace from Exception object
     * @return String the class that initiated the logging event
     */
    private String getClassName(String trace) {
        String lastTrace = getLastLineOfTrace(trace);
        if (lastTrace.startsWith('Class.')) {
            lastTrace = lastTrace.substringAfter('Class.');
        }
        return lastTrace.substringBefore(':').substringBeforeLast('.');
    }

    /**
     * @description Derives the class method name from the string of an Exception stack trace
     * @param trace String stack trace from Exception object
     * @return String the name of the method that initiated the logging event
     */
    private String getMethodName(String trace) {
        String lastTrace = getLastLineOfTrace(trace);
        return lastTrace.substringBefore(':').substringAfterLast('.');
    }

    /**
     * @description Concatenates a list of Database.Errors from a Database result object
     * @param errors List<Database.Error>
     * @return Set<String> concatenated results
     */
    private static Set<String> serializeErrorMessages(List<Database.Error> errors) {
        Set<String> logMessages = new Set<String>();
        for (Database.Error eachError : errors) {
            logMessages.add(
                eachError.getStatusCode() +
                ' - ' +
                eachError.getMessage() +
                ' - ' +
                eachError.getFields()
            );
        }
        return logMessages;
    }

    /**
     * @description Concatenates a set of string values with a given separator and truncates the final
     * result to fit in a 131072 character long text area field
     * @param objectList Set<String> values to be concatenated
     * @param separator the connecting text between each concatenated value
     * @return String the result of the concatenation
     */
    private static String convertSetToString(Set<String> objectList, String separator) {
        String concatValues = String.join((Iterable<String>) objectList, separator);
        return concatValues.left(131069) + '...';
    }
    /**
     * @description get last line of stack trace and helps to get class name and method
     * @param trace string value used to split
     * @return String
     */
    private static String getLastLineOfTrace(String trace) {
        List<String> stackTraces = trace.split('\n');
        if (stackTraces != null) {
            return stackTraces[stackTraces.size() - 1];
        }
        return trace;
    }
}