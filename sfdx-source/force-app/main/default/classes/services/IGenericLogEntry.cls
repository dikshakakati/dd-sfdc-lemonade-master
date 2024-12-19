/**
     @description interface class for Generic Log Entry
*/
public interface IGenericLogEntry {
    /**
     * @description Generates a new log object based on data provided.
     * @param methodName String Method Name enum to capture in log
     * @param className String Class Name to capture in the log
     * @param serviceName String indicate the serviceName
     * @return IGenericLogEntry object required by Logger.
     */

    /**
     * @description Generates a new log object based on the exception provided.
     * Assumes LOW severity
     * @param exceptionObj Any standard or custom exception.
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry logException(Exception exceptionObj);

    /**
     * @description Generates a new log object for a list of failed Database.SaveResult objects
     * @param dmlResultList List of Database.SaveResult objects
     * @param dmlRecordList List of SObjects included in the DML transaction
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry logDmlException(
        List<Database.SaveResult> dmlResultList,
        List<SObject> dmlRecordList
    );

    /**
     * @description Generates a new log object for a batch process error.
     * @param message String error message to capture in the log
     * @param batchJobId String Id of the asynchronous job.
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry logBatch(String message, String batchJobId);

    /**
     * @description Generates a new log object for an Apex API callout error
     * @param message String error message to capture in the log
     * @param requestPayload The request payload sent in API call
     * @param responsePayload The response payload recevied from API call
     * @param requestEndpoint The target url for the callout from System.HttpRequest.getEndpoint()
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry logCallout(
        String message,
        String requestPayload,
        String responsePayload,
        String requestEndpoint
    );

    /**
     * @description Converts IGenericLogEntry to JSON format for scalyr
     * @return String string on serialized format of the structure
     */
    String convertToJSON();

    /**
     * @description Generates a new log object
     * @param message String error message to capture in the log
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry logMessage(String message);

    /**
     * @description Generates a new log object from a custom message and one or multiple records
     * @param sfRecordIds Set of failed Record Ids
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry logSFRecordId(Set<String> sfRecordIds);

    /**
     * @description Generates a new log object
     * @param message String error message to capture in the log
     * @param className
     * @param methodName
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry logGovLimits(String message, String className, String methodName);

    /**
     * @description Generates a new log object
     * @param category String category to capture in the log
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry setCategory(String category);

    /**
     * @description Generates a new log object
     * @param logLevel String  to capture in the log
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry setLogLevel(String logLevel);

    /**
     * @description Generates a new log object
     * @param requestId String to capture in the log
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry setRequestId(String requestId);

    /**
     * @description Generates a new log object
     * @param uniqueId String to capture in the log
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry setUniqueId(String uniqueId);

    /**
     * @description Generates a new log object
     * @param uuid String to capture in the log
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry setUUID(String uuid);

    /**
     * @description Generates a new log object
     * @param statusCode String  to capture in the log
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry setStatusCode(string statusCode);

    /**
     * @description Generates a new log object
     * @param inboundIngestionLogId String to capture in the log
     * @return IGenericLogEntry object required by Logger.
     */
    IGenericLogEntry setInboundIngestionLogId(String inboundIngestionLogId);
}