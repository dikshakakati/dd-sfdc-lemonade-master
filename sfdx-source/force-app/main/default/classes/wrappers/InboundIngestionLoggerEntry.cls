/**
 * @author Deloitte
 * @date 04/24/2024
 * @description Apex class for InboundIngestionLogger creation.
 */
@SuppressWarnings('PMD.ExcessiveParameterList,PMD.ExcessivePublicCount')
public class InboundIngestionLoggerEntry implements IInboundIngestionLoggerEntry {
    private static final String SUCCESS = 'Success';
    private static final String SALESFORCE_GOVERNER_LIMITS = 'Salesforce Governor Limits';
    private static final String FAILED = 'Failed';
    private static final String SUCCESS_CODE = '200';
    private static final String ERROR_CODE = '500';
    private static final String QUERY_LIMIT_ERROR = 'Salesforce Governor Limit - Total number of Soql Query count limit is exceeded';
    private static final String DML_ERROR = 'Salesforce Governor Limit - DML limit is exceeded';
    private static final String DML_STATEMENT_ERROR = 'Salesforce Governor Limit - DML Statement limit is exceeded';
    private static final String SALESFORCE_GOVERNER_LIMIT_ERROR = 'Salesforce Governor Limit - number of records count by SOQL queries limit is exceeded';
    private static final String CPU_LIMIT_ERROR = 'Salesforce Governor Limit - Apex CPU time limit exceeded';

    /**
     * @description Public serviceName property.
     */
    public String serviceName { get; set; }
    /**
     * @description Public successMessage property.
     */
    public String successMessage { get; set; }
    /**
     * @description Public businessErrorMessage property.
     */
    public String businessErrorMessage { get; set; }
    /**
     * @description Public domainName property.
     */
    public String domainName { get; set; }
    /**
     * @description Public sfRecordIds property.
     */
    public Set<String> sfRecordIds { get; set; }
    /**
     * @description Public log property.
     */
    public Inbound_Ingestion_Log__c log { get; set; }
    /**
     * @description Public severity property.
     */
    public GenericLogEntry.SeverityLevel severity { get; set; }
    /**
     * @description Public category property.
     */
    public String category { get; set; }
    /**
     * @description Public statusCode property.
     */
    public String statusCode { get; set; }
    /**
     * @description Public uuid property.
     */
    public String uuid { get; set; }
    /**
     * @description Public uniqueId property.
     */
    public String uniqueId { get; set; }
    /**
     * @description Public className property.
     */
    public String className { get; set; }
    /**
     * @description Public methodName property.
     */
    public String methodName { get; set; }
    /**
     * @description Public inboundIngestionLogId property.
     */
    public String inboundIngestionLogId { get; set; }
    public Exception exceptionLog;

    /**
     * @description constructor
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public InboundIngestionLoggerEntry(){}

    /**
     * @description It is used to create Inbound Ingestion Log record.
     * @param serviceName
     * @param domainName
     * @param inboundIngestionLogId
     * @param uuid
     * @param uniqueId
     */
    public InboundIngestionLoggerEntry( String serviceName, String domainName, String inboundIngestionLogId, String uuid, String uniqueId ){
        this.serviceName = serviceName;
        this.domainName = domainName;
        this.inboundIngestionLogId = inboundIngestionLogId;
        this.uuid = uuid;
        this.uniqueId = uniqueId;

    }

    /**
     * @description It is used to log the exception.
     * @param e
     * @param businessErrorMessage
     * @param failedSteps
     * @param sfRecordIds
     * @param errorCategory
     * @return IInboundIngestionLoggerEntry
     */
    public IInboundIngestionLoggerEntry logException(Exception e, String businessErrorMessage,String failedSteps,Set<String> sfRecordIds,
        String errorCategory) {
        this.log = new Inbound_Ingestion_Log__c();
        this.severity = GenericLogEntry.SeverityLevel.HIGH;
        this.exceptionLog = e;
        this.statusCode = ERROR_CODE;
        this.category = errorCategory;
        this.log.category__c = errorCategory;
        this.log.Status__c = FAILED;
        this.log.Exception_Message__c = e.getMessage();
        this.log.Business_Error_Message__c = businessErrorMessage;
        this.log.Stack_Trace__c = e.getStackTraceString();
        //this.log.Id = this.inboundIngestionLogId;
        this.log.Failed_Record_Id__c = String.join(sfRecordIds,',');
        this.log.Failed_Steps__c = failedSteps == ''?'':failedSteps;
        return this;
    }

    /**
     * @description It is used to log the governer limits exception.
     * @param errorMessage
     * @param failedSteps
     * @param className
     * @param methodName
     * @return IInboundIngestionLoggerEntry
     */
    public IInboundIngestionLoggerEntry logGovtLimitException(String errorMessage,String failedSteps,String className, string methodName) {
        this.log = new Inbound_Ingestion_Log__c();
        this.businessErrorMessage = errorMessage;
        this.statusCode = ERROR_CODE;
        this.category = SALESFORCE_GOVERNER_LIMITS;
        this.log.category__c = SALESFORCE_GOVERNER_LIMITS;
        this.log.Status__c = FAILED;
        this.log.Exception_Message__c = errorMessage;
        this.log.Business_Error_Message__c = '';
        this.log.Stack_Trace__c = '';
        //this.log.Id = this.inboundIngestionLogId;
        this.log.Failed_Record_Id__c = '';
        this.log.Failed_Steps__c = failedSteps == ''?'':failedSteps;
        this.className = className;
        this.methodName = methodName;
        return this;
        }

    /**
     * @description It is used to log the success.
     * @param successMessage
     * @return IInboundIngestionLoggerEntry
     */
    public IInboundIngestionLoggerEntry logSuccess(String successMessage) {
        this.statusCode = SUCCESS_CODE;
        this.severity = GenericLogEntry.SeverityLevel.LOW;
        this.log = new Inbound_Ingestion_Log__c();
        this.log.Status__c = SUCCESS;
        this.log.Exception_Message__c = '';
        this.log.Business_Error_Message__c = '';
        this.log.Stack_Trace__c = '';
        //this.log.Id = this.inboundIngestionLogId;
        this.log.Success_Message__c = successMessage ;
        this.successMessage = successMessage;
        return this;
    }

    /**
     * @description It is used to check if there is any error for Governer Limits
     * @return String
     */
    public static String errorOnGovtLimitsExceeded() {
        if (Limits.getQueries() >= Limits.getLimitQueries() - 2) {
            return QUERY_LIMIT_ERROR;
        } else if (Limits.getDMLRows() >= Limits.getLimitDMLRows()) {
            return DML_ERROR;
        } else if (Limits.getDMLStatements() >= Limits.getLimitDMLStatements()) {
            return DML_STATEMENT_ERROR;
        } else if (Limits.getQueryRows() >= Limits.getLimitQueryRows() - 2) {
            return SALESFORCE_GOVERNER_LIMIT_ERROR;
        } else if (Limits.getCpuTime() >= Limits.getLimitCpuTime() - 2000) {
            return CPU_LIMIT_ERROR;
        } else {
            return null;
        }
    }

    /**
     * @description It is used to publish the event
     * @return IGenericLogEntry
     */
    public IGenericLogEntry createGenericLogEntry(){
        // update logEntry.log (DML)
        Request reqInfo = Request.getCurrent();
        //Get the identifier for this request, which is universally unique
        //Same as requestId in splunk or REQUEST_ID in event monitoring
        String currentRequestId = reqInfo.getRequestId();


        // Log Scaylr entry for failure
        if(this.statusCode == ERROR_CODE){
            if(this.category != SALESFORCE_GOVERNER_LIMITS){

                return GenericLoggerService.createGenericLog(
                        this.serviceName,
                        this.domainName,
                        this.severity
                    )
                    .setCategory(this.category)
                    .setRequestId(currentRequestId)
                    .setUUID(this.UUID)
                    .setUniqueId(this.uniqueId)
                    .setInboundIngestionLogId(this.inboundIngestionLogId)
                    .setStatusCode(this.statusCode)
                    .logSFRecordId(this.sfRecordIds)
                    .logException(this.exceptionLog);

            }
            else{
                return
                    GenericLoggerService.createGenericLog(
                        this.serviceName,
                        this.domainName,
                        this.severity
                    ).setCategory(this.category)
                    .setRequestId(currentRequestId)
                    .setUUID(this.UUID)
                    .setUniqueId(this.uniqueId)
                    .setInboundIngestionLogId(this.inboundIngestionLogId)
                    .setStatusCode(this.statusCode)
                    .logMessage(this.businessErrorMessage);
                    //.logGovLimits(this.businessErrorMessage,this.className,this.MethodName)


            }
        }
        //Log Scaylr entry for Success
        else{
            return
                GenericLoggerService.createGenericLog(
                    this.serviceName,
                    this.domainName,
                    this.severity
                ).setCategory(this.category)
                .setRequestId(currentRequestId)
                .setUUID(this.UUID)
                .setUniqueId(this.uniqueId)
                .setInboundIngestionLogId(this.inboundIngestionLogId)
                .setStatusCode(this.statusCode)
                .logSFRecordId(this.sfRecordIds)
                .logMessage(this.successMessage)
                .setLogLevel('Info');


        }
    }
}
