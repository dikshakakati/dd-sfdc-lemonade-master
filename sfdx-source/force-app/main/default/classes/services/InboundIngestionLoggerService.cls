/**
 * @author Shiva Pochamalla
 * @date 07/09/2024
 * @description Service class for InboundIngestionLoggerService to create logs
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public class InboundIngestionLoggerService {

    /**
     * @description It is used to create inbound ingestion log with required params
     * @param serviceName
     * @param domainName
     * @param inboundIngestionLogId
     * @param uuid
     * @param uniqueId
     * @return IInboundIngestionLoggerEntry
     */
    public static IInboundIngestionLoggerEntry createInboundIngestionLog(String serviceName, String domainName, String inboundIngestionLogId, String uuid, String uniqueId){
        IInboundIngestionLoggerEntry ingestionLogEntry = new InboundIngestionLoggerEntry(serviceName,domainName,inboundIngestionLogId,uuid,uniqueId);
       	return ingestionLogEntry;
    }

    /**
     * @description It is used to log the governer success
     * @param ingestionLogEntry
     * @param message
     */
    public static void logSuccess(IInboundIngestionLoggerEntry ingestionLogEntry, String message){
        service().logSuccess(ingestionLogEntry,message);
    }

    /**
     * @description It is used to log the governer success
     * @param ingestionLogEntry
     * @param e
     * @param businessErrorMessage
     * @param failedSteps
     * @param sfRecordIds
     * @param errorCategory
     */
    public static void logException(IInboundIngestionLoggerEntry ingestionLogEntry, Exception e, String businessErrorMessage,String failedSteps,Set<String> sfRecordIds, String errorCategory){
        service().logException(ingestionLogEntry,e,businessErrorMessage,failedSteps,sfRecordIds,errorCategory);
    }

    /**
     * @description It is used to log the governer limits exception
     * @param ingestionLogEntry
     * @param errorMessage
     * @param failedSteps
     * @param className
     * @param methodName
     */
    public static void logGovLimitsException(IInboundIngestionLoggerEntry ingestionLogEntry, String errorMessage,String failedSteps,String className, string methodName){
        service().logGovLimitsException(ingestionLogEntry,errorMessage,failedSteps,className,methodName);
    }

    /**
     * @description It is used to get limit exceeded error string
     * @return error message
     */
    public static string errorOnGovtLimitsExceeded(){
        return service().errorOnGovtLimitsExceeded();
    }

    /**
     * @description It is used to get the correspoding service class implementation from Application binding
     * @return IInboundIngestionLoggerImpl
     */
    private static IInboundIngestionLoggerImpl service() {
        return (IInboundIngestionLoggerImpl) Application.SERVICE.newInstance(IInboundIngestionLoggerImpl.class);
    }

}