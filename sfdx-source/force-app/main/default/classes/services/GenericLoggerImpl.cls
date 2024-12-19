/**
     @description Implementation class for generic logger
*/
@SuppressWarnings('PMD.StdCyclomaticComplexity')
public class GenericLoggerImpl implements IGenericLogger{

    /**
     * @description convert data in JSON and publish it into platform event Generic_Log_Event__e
     * @param log to publish
     */
    public void publish(IGenericLogEntry log ){
        publish( new List<IGenericLogEntry>{ log } );
    }

    /**
     * @description Converts GenericLogEntry to JSON format for scalyr
     * @param pubLogList Uses existing log format of GenericLogEntry
     */
    public void publish(List<IGenericLogEntry> pubLogList ){
        List<Generic_Log_Event__e> eventsToPublish = new List<Generic_Log_Event__e>();
        if( pubLogList == null || pubLogList.isEmpty() ) {
            return;
        }
        for(IGenericLogEntry log : pubLogList ){
            eventsToPublish.add(
                new Generic_Log_Event__e( Log_Details__c = log.convertToJSON( ) )
            );
        }
        if (eventsToPublish.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerPublishAfterSuccessTransaction(eventsToPublish);
        uow.commitWork();
    }
    /**
     * @description class for handling exceptions
     */
    public class GenericLogEntryException extends Exception {}

}