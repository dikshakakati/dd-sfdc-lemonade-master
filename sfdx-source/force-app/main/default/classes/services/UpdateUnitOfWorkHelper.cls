/**
 * @author Deloitte
 * @date 12/07/2022
 * @description Unit of work helper class to allow partial success on sObject updation.
 * It leverages IDoWork interface of fflib framework to overide the OOTB fflib commitWork method.
 * @purpose Update partial success is required for updation of sObjects.
 * @documentation https://andyinthecloud.com/2014/07/17/doing-more-work-with-the-unit-of-work/
 */
public inherited sharing class UpdateUnitOfWorkHelper implements fflib_SObjectUnitOfWork.IDoWork {
    private static final String NULL_LIST_EXCEPTION_MESSAGE = 'null list cannot be registered';
    /**
     * @description It can be used by the calling class to identify the failed records.
     */
    public Database.SaveResult[] saveResults { get; private set; }
    // Keeping SObject to allow other use-cases in future.
    @TestVisible
    private List<SObject> sObjectsToUpdate;

    /**
     * @description Default constructor to instantiate variables.
     */
    public UpdateUnitOfWorkHelper() {
        sObjectsToUpdate = new List<SObject>();
    }

    /**
     * @description It is implementation of doWork() method for updating the sObject records.
     */
    public void doWork() {
        saveResults = Database.update(sObjectsToUpdate, false);
    }

    /**
     * @description It acts as the OOTB fflib registerDirty() method
     * to collect a record for updation.
     * @param sObjectRecord
     */
    public void registerUpdate(SObject sObjectRecord) {
        sObjectsToUpdate.add(sObjectRecord);
    }

    /**
     * @description It acts as the OOTB fflib registerDirty() method
     * to collect a list of records for updation.
     * @param sObjectRecords
     */
    public void registerUpdate(List<SObject> sObjectRecords) {
        if (sObjectRecords == null) {
            throw new fflib_SObjectUnitOfWork.UnitOfWorkException(NULL_LIST_EXCEPTION_MESSAGE);
        }
        for (SObject eachSobjectRecord : sObjectRecords) {
            registerUpdate(eachSobjectRecord);
        }
    }
}