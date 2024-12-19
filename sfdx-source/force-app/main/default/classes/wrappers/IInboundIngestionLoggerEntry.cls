/**
 * @author Shiva Pochamalla
 * @date 07/09/2024
 * @description Interface class for InboundIngestionLoggerEntry wrapper
 */
public interface IInboundIngestionLoggerEntry{

    /**
     * @description It is used to logException
     * @param e
     * @param businessErrorMessage
     * @param failedSteps
     * @param sfRecordIds
     * @param errorCategory
     * @return IInboundIngestionLoggerEntry
     */
    IInboundIngestionLoggerEntry logException(Exception e, String businessErrorMessage,String failedSteps,Set<String> sfRecordIds, String errorCategory) ;

    /**
     * @description It is used to log success
     * @param successMessage
     * @return IInboundIngestionLoggerEntry
     */
    IInboundIngestionLoggerEntry logSuccess(String successMessage);
    /**
     * @description It is used to create generic log entry
     * @return IGenericLogEntry
     */
    IGenericLogEntry createGenericLogEntry();

    /**
     * @description It is used to logException
     * @param errorMessage
     * @param failedSteps
     * @param className
     * @param methodName
     * @return IInboundIngestionLoggerEntry
     */
    IInboundIngestionLoggerEntry logGovtLimitException(String errorMessage,String failedSteps,String className, string methodName);


}