/**
 * @author Deloitte
 * @description Interface to add Selector class methods
 */
public interface IAsyncApexJobsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting Sobject record by Id
     * @param idSet
     * @return List<AsyncApexJob>
     */
    List<AsyncApexJob> selectById(Set<Id> idSet);

    /**
     * @description This method is used to query running asyc jobs by class name
     * @param apexClassName
     * @return List<AsyncApexJob>
     */
    List<AsyncApexJob> selectRunningAsycJobByApexClassName(String apexClassName);

    /**
     * @description This method is for getting object type
     * @param jobId
     * @param jobName
     * @param jobstatus
     * @param jobType
     * @return List<AsyncApexJob> - List of AsyncApexJobs
     */
    List<AsyncApexJob> selectProcessingBatchJobByNameAndStatus(Id jobId, String jobName, String jobstatus, String jobType);
}