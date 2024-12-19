/**
 * @author Deloitte
 * @date 01/07/2022
 * @description Unit of work helper class to allow partial success on sObject insertion.
 * It leverages IDoWork interface of fflib framework to overide the OOTB fflib commitWork method.
 * @purpose Insert partial success is required for creation of Work Orders for Store Accounts.
 * Child Work Orders creation happens in bulk which means any single failure like PDOA in past
 * will prevent other Work Orders creation (refer LEM-658 & LEM-2224).
 * @documentation https://andyinthecloud.com/2014/07/17/doing-more-work-with-the-unit-of-work/
 */
public inherited sharing class InsertUnitOfWorkHelper implements fflib_SObjectUnitOfWork.IDoWork {
    private static final String NULL_LIST_EXCEPTION_MESSAGE = 'null list cannot be registered';
    /**
     * @description It can be used by the calling class to identify the failed records.
     */
    public Database.SaveResult[] saveResults { get; private set; }
    // Keeping SObject to allow other use-cases in future.
    @TestVisible
    private List<SObject> sObjectsToInsert;

    private Database.DMLOptions dmlOptions;

    /**
     * @description Default constructor to instantiate variables.
     */
    public InsertUnitOfWorkHelper() {
        sObjectsToInsert = new List<SObject>();
        this.dmlOptions = new Database.DMLOptions();
        this.dmlOptions.optAllOrNone = false;
    }

    /**
     * @description It is implementation of doWork() method for inserting the sObject records.
     */
    public void doWork() {
        if (this.dmlOptions != null) {
            for (SObject record : sObjectsToInsert) {
                record.setOptions(this.dmlOptions);
            }
        }

        saveResults = Database.insert(sObjectsToInsert, this.dmlOptions);
    }

    /**
     * @description It acts as the OOTB fflib registerNew() method
     * to collect a record for insertion.
     * @param sObjectRecord
     */
    public void registerInsert(SObject sObjectRecord) {
        sObjectsToInsert.add(sObjectRecord);
    }

    /**
     * @description It acts as the OOTB fflib registerNew() method
     * to collect a list of records for insertion.
     * @param sObjectRecords
     */
    public void registerInsert(List<SObject> sObjectRecords) {
        if (sObjectRecords == null) {
            throw new fflib_SObjectUnitOfWork.UnitOfWorkException(NULL_LIST_EXCEPTION_MESSAGE);
        }
        for (SObject eachSobjectRecord : sObjectRecords) {
            registerInsert(eachSobjectRecord);
        }
    }

    /**
     * @description Assigns the dmlOptions member variable with the inputted options argument.
     * @param options
    **/    
    public void setDmlOptions(Database.DMLOptions options) {
        this.dmlOptions = options;
    }
}