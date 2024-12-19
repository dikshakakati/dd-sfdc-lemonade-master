/**
 * @author CriticalRiver
 * @date 10/16/2023
 * @description interface class for generic logger impl
*/
public interface IGenericLogger {

    /**
     * @description convert data in JSON and publish it into platform event Generic_Log_Event__e
     * @param log IGenericLogEntry log to publish
     */
    void publish(IGenericLogEntry log );

    /**
     * @description convert data in JSON and publish it into platform event Generic_Log_Event__e
     * @param pubLogList List<IGenericLogEntry> List of log to publish
     */
    void publish( List<IGenericLogEntry> pubLogList );

}