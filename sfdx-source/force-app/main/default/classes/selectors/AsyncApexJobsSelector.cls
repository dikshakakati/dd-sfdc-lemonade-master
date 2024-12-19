/**
 * @author Deloitte
 * @date 28/11/2022
 * @description Selector Class for AsyncApexJob Object
 */
public inherited sharing class AsyncApexJobsSelector extends fflib_SObjectSelector implements IAsyncApexJobsSelector {
    private static final Set<String> SCHEDULED_STATUS = new Set<String>{ 'Holding', 'Queued' };

    /**
     * @description default constructor for the AsyncApexJob Selector class
     * @return IAsyncApexJobsSelector
     */
    public static IAsyncApexJobsSelector newInstance() {
        return (IAsyncApexJobsSelector) Application.Selector.newInstance(AsyncApexJob.SObjectType);
    }

    /**
     * @description This method is for getting the fields on account object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ AsyncApexJob.Id };
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return AsyncApexJob.SObjectType;
    }

    /**
     * @description This method is used for getting Sobject record by Id
     * @param idSet
     * @return List<AsyncApexJob>
     */
    public List<AsyncApexJob> selectById(Set<Id> idSet) {
        return (List<AsyncApexJob>) selectSObjectsById(idSet);
    }

    /**
     * @description This method is used to query running async jobs by class name
     * @param apexClassName
     * @return List<AsyncApexJob>
     */
    public List<AsyncApexJob> selectRunningAsycJobByApexClassName(String apexClassName) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('ApexClass.Name =: apexClassName AND Status IN: SCHEDULED_STATUS');
        return (List<AsyncApexJob>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is for getting object type
     * @param jobId
     * @param jobName
     * @param jobstatus
     * @param jobType
     * @return List<AsyncApexJob> - List of AsyncApexJobs
     */
    public List<AsyncApexJob> selectProcessingBatchJobByNameAndStatus(Id jobId, String jobName, String jobstatus, String jobType) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('ApexClass.Name');
        query.setCondition('Id !=:jobId AND ApexClass.Name =: jobName AND status =:jobstatus AND JobType =:jobType');
        return (List<AsyncApexJob>) Database.query(query.toSOQL());
    }
}