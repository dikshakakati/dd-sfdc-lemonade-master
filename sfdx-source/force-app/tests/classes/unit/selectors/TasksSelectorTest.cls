/**
 * @author Deloitte
 * @date 07/07/2024
 * @description Test class for TasksSelector class.
 */
@isTest(SeeAllData=false)
private class TasksSelectorTest {
    private static final String ACCOUNT_NAME = 'Mock KFC';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE = 'Business';
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_BUSINESS_RECORD_TYPE)
        .getRecordTypeId();
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String CALLTYPE_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: CallType does not match';
    private static final String COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Tasks count does not match';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Task';
    private static final String WHATID_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: WhatId does not match';
    private static final String TASK_CALL_TYPE_OUTBOUND = 'Outbound';
    private static final String TASK_SUBJECT_CALL = 'Call';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        TasksSelector tasksSelectorInstance = new TasksSelector();
        Schema.SObjectType typeOfObject = tasksSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = tasksSelectorInstance.getSObjectFieldList();
        TasksSelector.newInstance();
        System.assertEquals(
            Schema.Task.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Task.Id,
                Task.ActivityDate,
                Task.CompletedDateTime,
                Task.Description,
                Task.OwnerId,
                Task.Priority,
                Task.Status,
                Task.Subject,
                Task.WhatId,
                Task.WhoId,
                Task.Type
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test selection of Tasks with WhatId based on passed Ids.
     */
    @isTest
    private static void testWhenIdsReceviedThenReturnTasksWithWhatId() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
        );
        insert businessAccount;
        Task taskRecord = new Task(
            Subject = TASK_SUBJECT_CALL,
            Call_Type__c = TASK_CALL_TYPE_OUTBOUND,
            WhatId = businessAccount.Id
        );
        insert taskRecord;
        Test.startTest();
        List<Task> tasksQueryResult = TasksSelector.newInstance()
            .selectTasksWithWhatIdByIds(new Set<Id>{ taskRecord.Id });
        Test.stopTest();
        System.assertEquals(false, tasksQueryResult.isEmpty(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        System.assertEquals(
            businessAccount.Id,
            tasksQueryResult[0].WhatId,
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            TASK_CALL_TYPE_OUTBOUND,
            tasksQueryResult[0].Call_Type__c,
            CALLTYPE_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test selection of Tasks without WhatId based on passed Ids does not return
     * result.
     */
    @isTest
    private static void testWhenIdsReceviedThenDoNotReturnTasksWithoutWhatId() {
        Task taskRecord = new Task(
            Subject = TASK_SUBJECT_CALL,
            Call_Type__c = TASK_CALL_TYPE_OUTBOUND
        );
        insert taskRecord;
        Test.startTest();
        List<Task> tasksQueryResult = TasksSelector.newInstance()
            .selectTasksWithWhatIdByIds(new Set<Id>{ taskRecord.Id });
        Test.stopTest();
        System.assertEquals(true, tasksQueryResult.isEmpty(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }
}