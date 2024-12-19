/**
 * @author Shiva Pochamalla
 * @description This is the interface class for InboundIngestionLoggerImpl
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public interface IInboundIngestionLoggerImpl {
    /**
     * @description It is used to log the governer success
     * @param ingestionLogEntry
     * @param message
     */
    void logSuccess(IInboundIngestionLoggerEntry ingestionLogEntry, String message);
    /**
     * @description It is used to log the governer success
     * @param ingestionLogEntry
     * @param e
     * @param businessErrorMessage
     * @param failedSteps
     * @param sfRecordIds
     * @param errorCategory
     */
    void logException(IInboundIngestionLoggerEntry ingestionLogEntry, Exception e, String businessErrorMessage,String failedSteps,Set<String> sfRecordIds, String errorCategory);
    /**
     * @description It is used to log the governer limits exception
     * @param ingestionLogEntry
     * @param errorMessage
     * @param failedSteps
     * @param className
     * @param methodName
     */
    void logGovLimitsException(IInboundIngestionLoggerEntry ingestionLogEntry, String errorMessage,String failedSteps,String className, string methodName);
    /**
     * @description It is used to get limit exceeded error string
     * @return error message
     */
    string errorOnGovtLimitsExceeded();
}