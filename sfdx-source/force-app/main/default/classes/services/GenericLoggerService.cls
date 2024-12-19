/**
 * @author CriticalRiver
 * @date 10/16/2023
 * @description Service class for GenericLogEntry
*/
public class GenericLoggerService {

    /**
     * @description Generates a new log object based on data provided.
     * @param serviceName String indicate the serviceName
     * @param domainName String Domain Name
     * @param severityLevel GenericLogEntry.SeverityLevel enum to indicate the level of severity
     * @return GenericLogEntry object required by Logger.
     */
    public static IGenericLogEntry createGenericLog(String serviceName, String domainName, GenericLogEntry.SeverityLevel severityLevel){
        IGenericLogEntry logEntry = new GenericLogEntry(serviceName,domainName,severityLevel);
       	return logEntry;
     }

    /**
     * @description convert data in JSON and publish it into platform event Generic_Log_Event__e
     * @param log to publish
     */
    public static void publish(IGenericLogEntry log ){
        service().publish(log);
    }

    /**
     * @description Converts GenericLogEntry to JSON format for scalyr
     * @param pubLogList list of logs to publish
     */
    public static void publish( List<IGenericLogEntry> pubLogList ){
        service().publish(pubLogList);
    }

    /**
     * @description calling newInstance for service class.
     * @return IGenericLogger - returning interface.
     */
    private static IGenericLogger service() {
        return (IGenericLogger) Application.SERVICE.newInstance(IGenericLogger.class);
    }
}