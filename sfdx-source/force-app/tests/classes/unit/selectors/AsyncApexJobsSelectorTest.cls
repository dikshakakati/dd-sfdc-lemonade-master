/**
 * @author Deloitte
 * @date 28/11/2022
 * @description This is test class for AsyncApexJobsSelector class.
 */
@isTest(seeAllData=false)
public class AsyncApexJobsSelectorTest {
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        AsyncApexJobsSelector asyncApexJobInstance = new AsyncApexJobsSelector();
        Schema.SObjectType typeOfObj = asyncApexJobInstance.getSObjectType();
        System.assertEquals(
            Schema.AsyncApexJob.SObjectType,
            typeOfObj,
            'The object type must be AsyncApexJob'
        );

        List<Schema.SObjectField> fieldList = asyncApexJobInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{ AsyncApexJob.Id },
            fieldList,
            ' Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenSelectByIdCalledThenReturnRecords() {
        Id asyncApexJob1 = Fake.generateId(AsyncApexJob.getSObjectType());
        Id asyncApexJob2 = Fake.generateId(AsyncApexJob.getSObjectType());

        List<AsyncApexJob> asyncJobRecords = AsyncApexJobsSelector.newInstance()
            .selectById(new Set<Id>{ asyncApexJob1, asyncApexJob2 });

        System.assert(asyncJobRecords.isEmpty(), 'The list was not empty');
    }

    @isTest
    private static void testWhenSelectRunningAsycJobByApexClassNameThenReturnRecords() {
        List<AsyncApexJob> asyncJobRecords = AsyncApexJobsSelector.newInstance()
            .selectRunningAsycJobByApexClassName('MockClass');

        System.assert(asyncJobRecords.isEmpty(), 'The list was not empty');
    }

    @isTest
    private static void testWhenSelectProcessingBatchJobByNameAndStatusThenReturnRecords() {
        Id jobId = Fake.generateId(AsyncApexJob.getSObjectType());
        String jobName = ContractsAssociatedAccountsBatch.class.getName();
        String jobType = 'BatchApex';
        String jobstatus = 'Processing';
        List<AsyncApexJob> asyncJobRecords = AsyncApexJobsSelector.newInstance()
            .selectProcessingBatchJobByNameAndStatus(jobId, jobName, jobType, jobstatus);

        System.assert(asyncJobRecords.isEmpty(), 'The list was not empty');
    }
}