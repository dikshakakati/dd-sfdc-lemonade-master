/**
 * @author Deloitte
 * @date 1/24/2024
 * @description Test class for AggregateResultIterable and AggregateResultIterator class.
 */
@isTest(SeeAllData=false)
private class AggregateResultIterableTest {
    private static final String AGGREGATEQUERYTOEXECUTE = System.Label.Aggregate_Query_On_Log_By_Parent_Id;
    private static final String BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String COLON = ':';
    private static final String CREATED_DATE_FILTER_IDENTIFIER = 'createdDateFilter';
    private static final Map<String, Object> FILTERS = new Map<String, Object>{
        CREATED_DATE_FILTER_IDENTIFIER => DateTime.newInstance(
            System.today().addDays(-1),
            Time.newInstance(9, 0, 0, 0)
        )
    };
    private static final String INVALID_ASSERT_MESSAGE = 'Unexpected result';

    /**
     * @description To test Constructor instantiation with single parameter.
     */
    @isTest
    private static void testWhenSingleParameterPassedThenClassInstantiated() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account parentAccount = new Account(
            Name = 'Parent Account',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Segment__c = 'Enterprise'
        );
        insert parentAccount;
        List<Log__c> logs = new List<Log__c>{
            new Log__c(
                Send_Notification__c = true,
                Parent_Account_Id_18__c = parentAccount.Id,
                Store_Account_Id_18__c = storeAccountId,
                Recipient_Ids_To_Send_Notification__c = UserInfo.getUserId()
            ),
            new Log__c(
                Send_Notification__c = false,
                Parent_Account_Id_18__c = parentAccount.Id,
                Store_Account_Id_18__c = storeAccountId,
                Recipient_Ids_To_Send_Notification__c = UserInfo.getUserId()
            ),
            new Log__c(
                Send_Notification__c = true,
                Recipient_Ids_To_Send_Notification__c = UserInfo.getUserId(),
                Parent_Account_Id_18__c = parentAccount.Id,
                Store_Account_Id_18__c = storeAccountId
            ),
            new Log__c(
                Send_Notification__c = true,
                Parent_Account_Id_18__c = parentAccount.Id,
                Store_Account_Id_18__c = storeAccountId
            )
        };
        insert logs;
        DateTime filterDate = DateTime.newInstance(
            System.today().addDays(-1),
            Time.newInstance(9, 0, 0, 0)
        );
        String aggregateQuery = System.Label.Aggregate_Query_On_Log_By_Parent_Id;
        aggregateQuery = aggregateQuery.replace(
            COLON + CREATED_DATE_FILTER_IDENTIFIER,
            filterDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX')
        );
        Test.startTest();
        AggregateResultIterable aggregateResultIterableInstance = new AggregateResultIterable(
            AGGREGATEQUERYTOEXECUTE
        );
        AggregateResultIterator aggregateResultIteratorInstance = new AggregateResultIterator(
            aggregateQuery
        );
        Test.stopTest();
        Boolean aggregateHasNext = aggregateResultIteratorInstance.hasNext();
        aggregateResultIteratorInstance.next();
        System.assertEquals(
            AGGREGATEQUERYTOEXECUTE,
            aggregateResultIterableInstance.aggregateQuery,
            INVALID_ASSERT_MESSAGE
        );
        System.assertEquals(true, aggregateHasNext, INVALID_ASSERT_MESSAGE);
    }

    /**
     * @description To test Constructor instantiation for AggregateResultIterator with
     * multiple parameter.
     */
    @isTest
    private static void testWhenMultipleParametersPassedThenAggregateResultIteratorClassInstantiated() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account parentAccount = new Account(
            Name = 'Parent Account',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Segment__c = 'Enterprise'
        );
        insert parentAccount;
        List<Log__c> logs = new List<Log__c>{
            new Log__c(
                Send_Notification__c = true,
                Parent_Account_Id_18__c = parentAccount.Id,
                Store_Account_Id_18__c = storeAccountId,
                Recipient_Ids_To_Send_Notification__c = UserInfo.getUserId()
            ),
            new Log__c(
                Send_Notification__c = false,
                Parent_Account_Id_18__c = parentAccount.Id,
                Store_Account_Id_18__c = storeAccountId,
                Recipient_Ids_To_Send_Notification__c = UserInfo.getUserId()
            ),
            new Log__c(
                Send_Notification__c = true,
                Recipient_Ids_To_Send_Notification__c = UserInfo.getUserId(),
                Parent_Account_Id_18__c = parentAccount.Id,
                Store_Account_Id_18__c = storeAccountId
            ),
            new Log__c(
                Send_Notification__c = true,
                Parent_Account_Id_18__c = parentAccount.Id,
                Store_Account_Id_18__c = storeAccountId
            )
        };
        insert logs;
        Test.startTest();
        AggregateResultIterable aggregateResultIterableInstance = new AggregateResultIterable(
            AGGREGATEQUERYTOEXECUTE,
            FILTERS,
            AccessLevel.USER_MODE
        );
        aggregateResultIterableInstance.iterator();
        AggregateResultIterator aggregateResultIteratorInstance = new AggregateResultIterator(
            AGGREGATEQUERYTOEXECUTE,
            FILTERS,
            AccessLevel.USER_MODE
        );
        Test.stopTest();
        Boolean aggregateHasNext = aggregateResultIteratorInstance.hasNext();
        aggregateResultIteratorInstance.next();
        System.assertEquals(true, aggregateHasNext, INVALID_ASSERT_MESSAGE);
    }
}
