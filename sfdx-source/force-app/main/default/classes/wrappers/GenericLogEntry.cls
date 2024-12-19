/**
 * @author CriticalRiver
 * @date 10/16/2023
 * @description used to create new log records.
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessivePublicCount, PMD.StdCyclomaticComplexity')
public with sharing class GenericLogEntry implements IGenericLogEntry {
    public static final String GENERIC_LOG_DOMAIN_ONBOARDING = 'Onboarding';
    public static final String GENERIC_LOG_INFORMATION = 'Information';
    public static final String GENERIC_LOG_DOMAIN_PROVISIONING = 'Provisioning';

    /**
     * @description Public message property...
     */
    public String message { get; set; }
    /**
     * @description Public severity property.
     */
    public SeverityLevel severity { get; set; }
    /**
     * @description Public category property.
     */
    public String category { get; set; }
    /**
     * @description Public logType property.  Value is derived from the LogCategory name or the Exception type
     */
    public String logType { get; set; }
    /**
     * @description Public logLevel property
     */
    public String logLevel { get; set; }
    /**
     * @description Public class name property.  The class that called the log.
     */
    public String className { get; set; }
    /**
     * @description domain property.
     */
    public String domainName { get; set; }
    /**
     * @description Public class method name property.  The class method that called the log.
     */
    public String methodName { get; set; }
    /**
     * @description Public service property.
     */
    public String serviceName { get; set; }
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
    public String requestPayload { get; set; }
    /**
     * @description Public callout response status code property.
     */
    public String responsePayload { get; set; }
    /**
     * @description Public callout request endpoint property.
     */
    public String calloutRequestEndpoint { get; set; }
    /**
     * @description Public callout requestId property.
     */
    public String requestId { get; set; }
    /**
     * @description Public callout instance property.
     */
    public String instance { get; set; }
    /**
     * @description Public callout uniqueId property.
     */
    public String uniqueId { get; set; }
    /**

     * @description Public callout uuid property.
     */
    public String uuid { get; set; }
    /**
     * @description Public callout retryThresholdExceeded property.
     */
    public Boolean retryThresholdExceeded { get; set; }

    /**
     * @description Public callout statusCode property.
     */
    public String statusCode { get; set; }
    /**
     * @description Public callout inboundIngestionLogId property.
     */
    public String inboundIngestionLogId { get; set; }

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
     * @description Provides a list of possible categories or log type values
     */
    public enum LogCategory {
        GENERIC_LOG,
        API_CALLOUT_EXCEPTION,
        DML_EXCEPTION
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
     * @description Constructor generates a new log object based on data provided.
     * @param serviceName String indicate the serviceName
     * @param domainName String Domain Name
     * @param severity SeverityLevel enum to indicate the level of severity
     */
    public GenericLogEntry(String serviceName, String domainName, SeverityLevel severity) {
        this.serviceName = serviceName;
        this.domainName = domainName;
        this.severity = severity;
        this.logType = LogCategory.GENERIC_LOG.name();
    }
    /**
     * @description log object based on the exception provided.
     * Assumes LOW severity
     * @param exceptionObj Any standard or custom exception.
     * @return IGenericLogEntry object required by Logger.
     */
    public IGenericLogEntry logException(Exception exceptionObj) {
        this.message = exceptionObj.getMessage().left(131072);
        this.stackTrace = exceptionObj.getStackTraceString();
        this.className = getClassName(this.stackTrace);
        this.methodName = getMethodName(this.stackTrace);
        this.withException(exceptionObj);
        return this;
    }
    /**
     * @description Fluent method to apply an Exception object to the LogEntry object
     * @param e object
     */
    private void withException(Exception e) {
        this.exceptionObj = e;
    }

    /**
     * @description Fluent method to apply an a category to the LogEntry object
     * @param category object
     * @return IGenericLogEntry
     */
    public IGenericLogEntry setCategory(String category) {
        this.category = category;
        return this;
    }

    /**
     * @description Fluent method to apply an a logLevel to the LogEntry object
     * @param logLevel object
     * @return IGenericLogEntry
     */
    public IGenericLogEntry setLogLevel(String logLevel) {
        this.logLevel = logLevel;
        return this;
    }

    /**
     * @description Fluent method to apply an a logLevel to the LogEntry object
     * @param requestId
     * @return IGenericLogEntry
     */
    public IGenericLogEntry setRequestId(String requestId) {
        this.requestId = requestId;
        return this;
    }

    /**
     * @description Fluent method to apply an a logLevel to the LogEntry object
     * @param uuid
     * @return IGenericLogEntry
     */
    public IGenericLogEntry setUUId(String uuid) {
        this.uuid = uuid;
        return this;
    }

    /**
     * @description Fluent method to apply an a logLevel to the LogEntry object
     * @param statusCode
     * @return IGenericLogEntry
     */
    public IGenericLogEntry setStatusCode(String statusCode) {
        this.statusCode = statusCode;
        return this;
    }

    /**
     * @description Fluent method to apply an a logLevel to the LogEntry object
     * @param inboundIngestionLogId
     * @return IGenericLogEntry
     */
    public IGenericLogEntry setInboundIngestionLogId(String inboundIngestionLogId) {
        this.inboundIngestionLogId = inboundIngestionLogId;
        return this;
    }

    /**
     * @description Fluent method to apply an a retryThresholdExceeded to the LogEntry object
     * @param retryThresholdExceeded
     * @return IGenericLogEntry
     */
    public IGenericLogEntry setRetryThresholdExceeded(Boolean retryThresholdExceeded) {
        this.retryThresholdExceeded = retryThresholdExceeded;
        return this;
    }

    /**
     * @description Fluent method to apply an a logLevel to the LogEntry object
     * @param uniqueId
     * @return IGenericLogEntry
     */
    public IGenericLogEntry setUniqueId(String uniqueId) {
        this.uniqueId = uniqueId;
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
     * @description get last line of stack trace and helps to get class name and method
     * @param trace string value used to split
     * @return String
     */
    private String getLastLineOfTrace(String trace) {
        List<String> stackTraces = trace.split('\n');
        if (stackTraces != null) {
            return stackTraces[stackTraces.size() - 1];
        }
        return trace;
    }
    /**
     * @description log object for a list of failed Database.SaveResult objects
     * @param dmlResultList List of Database.SaveResult objects
     * @param dmlRecordList List of SObjects included in the DML transaction
     * @return IGenericLogEntry object required by Logger.
     */
    public IGenericLogEntry logDmlException(
        List<Database.SaveResult> dmlResultList,
        List<SObject> dmlRecordList
    ) {
        this.stackTrace = new DmlException().getStackTraceString().substringAfter('\n');
        this.className = getClassName(this.stackTrace);
        this.methodName = getMethodName(this.stackTrace);
        this.severity = SeverityLevel.HIGH;
        this.logType = LogCategory.DML_EXCEPTION.name();
        withDmlResults(dmlResultList, dmlRecordList);
        return this;
    }
    /**
     * @description Generates a new log object for a list of failed Database.DeleteResult objects
     * @param dmlResultList List of Database.DeleteResult objects
     * @param dmlRecordList List of SObjects included in the DML transaction
     */
    private void withDmlResults(
        List<Database.SaveResult> dmlResultList,
        List<SObject> dmlRecordList
    ) {
        if (dmlResultList == null || dmlResultList.isEmpty()) {
            return;
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
            return;
        }
        this.message = convertSetToString(errors, '\n');
        this.recordId = convertSetToString(recordIds, ', ');
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
     * @description Generates a new log object for a batch process error.
     * @param message String error message to capture in the log
     * @param batchJobId String Id of the asynchronous job.
     * @return IGenericLogEntry object required by Logger.
     */
    public IGenericLogEntry logBatch(String message, String batchJobId) {
        this.message = message;
        this.stackTrace = new DmlException().getStackTraceString().substringAfter('\n');
        this.className = getClassName(this.stackTrace);
        this.methodName = getMethodName(this.stackTrace);
        this.batchJobId = batchJobId;
        return this;
    }
    /**
     * @description Generates a new log object for an Apex API callout error
     * @param message String error message to capture in the log
     * @param requestPayload The request payload sent in API call
     * @param responsePayload The response payload recevied from API call
     * @param requestEndpoint The target url for the callout from System.HttpRequest.getEndpoint()
     * @return LogEntry object required by Logger.
     */
    public IGenericLogEntry logCallout(
        String message,
        String requestPayload,
        String responsePayload,
        String requestEndpoint
    ) {
        this.stackTrace = new DmlException().getStackTraceString().substringAfter('\n');
        this.className = getClassName(this.stackTrace);
        this.methodName = getMethodName(this.stackTrace);
        this.message = message;
        this.requestPayload = requestPayload;
        this.responsePayload = responsePayload;
        this.calloutRequestEndpoint = requestEndpoint;
        this.logType = LogCategory.API_CALLOUT_EXCEPTION.name();
        return this;
    }

    /**
     * @description Generates a new log object
     * @param message String error message to capture in the log
     * @return IGenericLogEntry object required by Logger.
     */
    public IGenericLogEntry logMessage(String message) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        this.className = getClassName(traceString);
        this.methodName = getMethodName(traceString);
        this.message = message;
        this.logType = LogCategory.GENERIC_LOG.name();
        return this;
    }

    /**
     * @description Generates a new log object
     * @param message String error message to capture in the log
     * @param className
     * @param methodName
     * @return IGenericLogEntry object required by Logger.
     */
    public IGenericLogEntry logGovLimits(String message, String className, String methodName) {
        this.message = message;
        this.className = className;
        this.methodName = methodName;
        return this;
    }

    /**
     * @description Generates a new log object from a custom message and one or multiple records
     * @param sfRecordIds Set of failed Record Ids
     * @return IGenericLogEntry object required by Logger.
     */
    public IGenericLogEntry logSFRecordId(Set<String> sfRecordIds) {
        String traceString = new DmlException().getStackTraceString().substringAfter('\n');
        this.className = getClassName(traceString);
        this.methodName = getMethodName(traceString);
        if(sfRecordIds != null && !sfRecordIds.isEmpty()){
             this.recordId = convertSetToString(sfRecordIds, ', ');
        }
        return this;
    }

    /**
     * @description Converts IGenericLogEntry to JSON format for scalyr
     * @return String serialized format of the structure JSON
     */
    @SuppressWarnings('PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity')
    public String convertToJSON() {
        LogStructure ls = new LogStructure();
        ls.entrypoint = this.quiddity.name();
        ls.entity = this.className;
        ls.domain = this.domainName;
        ls.serviceName = this.serviceName;
        if (String.isBlank(this.category)) {
            ls.category = (String.isBlank(this.stackTrace)) ? 'Custom Error' : 'System Error';
        } else {
            ls.category = this.category;
        }
        ls.logLevel = (String.isBlank(this.loglevel)) ? 'Error' : this.logLevel;
        ls.severity = String.valueOf(this.severity);
        ls.sourceSystem = 'DDMX';
        System.Domain domain = System.DomainParser.parse(URL.getOrgDomainUrl());
        ls.environment = (domain.getSandboxName() != null) ? domain.getSandboxName() : 'PROD';

        MessageStructure message = new messageStructure();
        if (String.isNotBlank(this.stackTrace)) {
            message.stacktrace = this.stackTrace.left(20000);
        }
        if (String.isNotBlank(this.message)) {
            message.logMessage = this.message.left(5000);
        }
        message.requestPayload = this.requestPayload;
        message.responsePayload = this.responsePayload;
        message.uuId = this.uUID;
        message.uniqueId = this.uniqueId;
        message.inboundIngestionLogId = this.inboundIngestionLogId;
        message.requestId = (String.isBlank(this.requestId)) ? 'Error' : this.requestId;
        message.statusCode = this.statusCode;
        message.retryThresholdExceeded = this.retryThresholdExceeded;
        ls.message = message;

        if (String.isNotBlank(this.recordId)) {
            ls.sfRecordId = this.recordId.left(5000);
        }
        return json.serialize(ls);
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
     * @description Log Structure to transform to JSON
     */
    private class LogStructure {
        public String sourceSystem = '';
        public String entity = '';
        public String category = '';
        public String sfRecordId = '';
        public String logLevel = '';
        public String severity = '';
        public string environment = '';
        public datetime createAt = datetime.now();
        public String serviceName = '';
        public String domain = '';
        public string entrypoint = '';
        public MessageStructure message;
    }
    /**
     * @description Message Structure inside of LogStructure
     */
    private class MessageStructure {
        public string exceptionMessage = '';
        public string integrationResponseMessage = '';
        public string stackTrace = '';
        public string logMessage = '';
        public string requestPayload = '';
        public string responsePayload = '';
        public string calloutresponseStatus = '';
        public string uniqueId = '';
        public string uuId = '';
        public String inboundIngestionLogId;
        public Boolean retryThresholdExceeded = false;
        public String requestId = '';
        public String statusCode='';
    }
}
