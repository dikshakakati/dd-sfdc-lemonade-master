/**
 * @description GeericLog Event Object Trigger Handler
 */
public with sharing class GenericLogEventsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method
     * @param sObjectList - Provisioning Events Record List
     */
    public GenericLogEventsHandler(List<Generic_Log_Event__e> sObjectList) {
        super(sObjectList);
        setContextBypass(Generic_Log_Event__e.SObjectType, GenericLogEventsHandler.class);
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {

        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Generic_Log_Event__e> genericLogEventsToProcess = new List<Generic_Log_Event__e>();

        for (Integer counter = 0; counter < this.records.size(); counter++) {
            Generic_Log_Event__e genericLogEvent = (Generic_Log_Event__e) this.records[counter];

            genericLogEventsToProcess.add(genericLogEvent);
            EventBus.TriggerContext.currentContext().setResumeCheckpoint(genericLogEvent.replayId);
        }

        for (Generic_Log_Event__e event : genericLogEventsToProcess) {
            uow.registerNew(new Generic_Log__c(Log_Details__c = event.Log_Details__c));
        }

        uow.commitWork();

    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return GenericLogEventsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new GenericLogEventsHandler(sObjectList);
        }
    }
}