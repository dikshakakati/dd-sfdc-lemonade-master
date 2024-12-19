/**
 *  @author Deloitte
 *  @date 23/05/2022
 *  @description Handler class for BatchAPexErrorEvents trigger
 */
public class BatchApexErrorEventHandler extends ApplicationDomainHandler {
    /**
     * @description default constructor for the class
     * @param sObjectList - List of events
     */
    public BatchApexErrorEventHandler(List<BatchApexErrorEvent> sObjectList) {
        super(sObjectList);
    }

    /**
     * @description This method logs error in Log__c object
     */
    public override void onAfterInsert() {
        LogEntry logEntryInstance;
        ILogger loggerInstance;
        for (BatchApexErrorEvent eachEvent : (List<BatchApexErrorEvent>) this.records) {
            logEntryInstance = LogEntry.newLog(eachEvent.StackTrace, LogEntry.SeverityLevel.HIGH);
            if (loggerInstance == null) {
                loggerInstance = Logger.add(logEntryInstance);
                continue;
            }
            loggerInstance.add(logEntryInstance);
        }
        if (loggerInstance != null) {
            loggerInstance.publish();
        }
    }
    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return BatchApexErrorEventHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new BatchApexErrorEventHandler(sObjectList);
        }
    }
}