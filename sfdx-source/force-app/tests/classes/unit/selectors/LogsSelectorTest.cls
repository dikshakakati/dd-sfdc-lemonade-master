/**
 * @author Deloitte
 * @date 1/18/2024
 * @description Test class for LogsSelector class.
 */
@isTest(SeeAllData=false)
private class LogsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Group';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_LOGS = 'Unexpected result: The number of logs returned do not match the expected number of logs';
    private static final String BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        LogsSelector logsInstance = new LogsSelector();
        Schema.SObjectType typeOfObject = logsInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = logsInstance.getSObjectFieldList();
        LogsSelector.newInstance();
        System.assertEquals(
            Schema.Log__c.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{ Log__c.Id },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test if the expected log records are returned.
     */
    @isTest
    private static void testWhenSelectLogsToSendNotificationThenReturnLogs() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id franchiseAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account parentAccount = new Account(
            Name = 'Parent Account',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Segment__c = 'Enterprise'
        );
        insert parentAccount;
        Schema.SObjectField parentField = Log__c.Parent_Account_Id_18__c;
        Schema.SObjectField secondaryParentFieldToExclude = Log__c.Franchise_Parent_Account_Id_18__c;
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
            ),
            new Log__c(
                Franchise_Parent_Account_Id_18__c = franchiseAccountId,
                Parent_Account_Id_18__c = parentAccount.Id,
                Recipient_Ids_To_Send_Notification__c = UserInfo.getUserId(),
                Send_Notification__c = true,
                Store_Account_Id_18__c = storeAccountId
            ),
            new Log__c(
                Franchise_Parent_Account_Id_18__c = franchiseAccountId,
                Parent_Account_Id_18__c = parentAccount.Id,
                Send_Notification__c = true,
                Store_Account_Id_18__c = storeAccountId
            )
        };
        insert logs;
        Test.startTest();
        List<Log__c> queriedLogs = LogsSelector.newInstance()
            .selectLogsEligibleToSendNotification(
                parentField,
                new Set<Id>{ parentAccount.Id },
                secondaryParentFieldToExclude
            );
        List<Log__c> queriedFranchiseLogs = LogsSelector.newInstance()
            .selectLogsEligibleToSendNotification(
                secondaryParentFieldToExclude,
                new Set<Id>{ franchiseAccountId },
                null
            );
        Test.stopTest();
        System.assertEquals(2, queriedLogs.size(), ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_LOGS);
        System.assertEquals(
            1,
            queriedFranchiseLogs.size(),
            ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_LOGS
        );
    }

    /**
     * @description To test if the expected log records not found, then none are returned.
     */
    @isTest
    private static void testWhenEligibleLogsToSendNotificationNotFoundThenReturnNone() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id franchiseAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account parentAccount = new Account(
            Name = 'Parent Account',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Segment__c = 'Enterprise'
        );
        insert parentAccount;
        Schema.SObjectField parentField = Log__c.Parent_Account_Id_18__c;
        Schema.SObjectField franchiseParentField = Log__c.Franchise_Parent_Account_Id_18__c;
        List<Log__c> logs = new List<Log__c>{
            new Log__c(
                Franchise_Parent_Account_Id_18__c = franchiseAccountId,
                Parent_Account_Id_18__c = parentAccount.Id,
                Send_Notification__c = true,
                Store_Account_Id_18__c = storeAccountId
            ),
            new Log__c(
                Send_Notification__c = false,
                Parent_Account_Id_18__c = parentAccount.Id,
                Store_Account_Id_18__c = storeAccountId,
                Recipient_Ids_To_Send_Notification__c = UserInfo.getUserId()
            ),
            new Log__c(
                Send_Notification__c = true,
                Parent_Account_Id_18__c = parentAccount.Id,
                Store_Account_Id_18__c = storeAccountId
            )
        };
        insert logs;
        Test.startTest();
        List<Log__c> queriedLogs = LogsSelector.newInstance()
            .selectLogsEligibleToSendNotification(
                parentField,
                new Set<Id>{ parentAccount.Id },
                franchiseParentField
            );
        List<Log__c> queriedFranchiseLogs = LogsSelector.newInstance()
            .selectLogsEligibleToSendNotification(
                franchiseParentField,
                new Set<Id>{ franchiseAccountId },
                null
            );
        Test.stopTest();
        System.assertEquals(0, queriedLogs.size(), ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_LOGS);
        System.assertEquals(
            0,
            queriedFranchiseLogs.size(),
            ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_LOGS
        );
    }
}