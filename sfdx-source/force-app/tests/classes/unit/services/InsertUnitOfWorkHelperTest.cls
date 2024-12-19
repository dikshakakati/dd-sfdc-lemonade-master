/**
 * @author Deloitte
 * @date 21/06/2022
 * @description Test class for InsertUnitOfWorkHelper class.
 */
@isTest(seeAllData=false)
private class InsertUnitOfWorkHelperTest {
    private static final String CHILD_ACCOUNT_NAME = 'Child Account';
    private static final String DO_WORK_ASSERT_MESSAGE = 'Unexpected result: failed to perform insert using database method';
    private static final String PARENT_ACCOUNT_NAME = 'Parent Account';
    private static final String REGISTER_SINGLE_RECORD_ASSERT_MESSAGE = 'Unexpected result: failed to register a single record';
    private static final String REGISTER_MULTIPLE_RECORDS_ASSERT_MESSAGE = 'Unexpected result: failed to register a list of records';
    private static final String REGISTER_NULL_LIST_ASSERT_MESSAGE = 'Unexpected result: null list registered successfully';

    /**
     * @description To test registerInsert() method for a single sObject record.
     */
    @isTest
    private static void testWhenRegisterInsertWithSingleRecordCalledThenSobjectListUpdated() {
        Account accountMockInstance = new Account(Name = PARENT_ACCOUNT_NAME);
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        Test.startTest();
        insertUnitOfWorkHelper.registerInsert(accountMockInstance);
        Test.stopTest();
        System.assertEquals(
            1,
            insertUnitOfWorkHelper.sObjectsToInsert.size(),
            REGISTER_SINGLE_RECORD_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test registerInsert() method for a list of sObject records.
     */
    @isTest
    private static void testWhenRegisterInsertWithListOfRecordCalledThenSobjectListUpdated() {
        Account parentAccountMockInstance = new Account(Name = PARENT_ACCOUNT_NAME);
        Account childAccountMockInstance = new Account(Name = CHILD_ACCOUNT_NAME);
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        Test.startTest();
        insertUnitOfWorkHelper.registerInsert(
            new List<Account>{ parentAccountMockInstance, childAccountMockInstance }
        );
        Test.stopTest();
        System.assertEquals(
            2,
            insertUnitOfWorkHelper.sObjectsToInsert.size(),
            REGISTER_MULTIPLE_RECORDS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test registerInsert() method passed a null list.
     */
    @isTest
    private static void testWhenRegisterInsertWithNullListCalledThenExceptionThrown() {
        List<Account> accounts;
        Boolean hasExceptionOccurred = false;
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        Test.startTest();
        try {
            insertUnitOfWorkHelper.registerInsert(accounts);
        } catch (Exception nullListException) {
            hasExceptionOccurred = true;
        }
        Test.stopTest();
        System.assertEquals(true, hasExceptionOccurred, REGISTER_NULL_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test doWork() method performs insert operation using database method.
     */
    @isTest
    private static void testWhenDoWorkCalledThenSaveResultsUpdated() {
        Account accountMockInstance = new Account(Name = PARENT_ACCOUNT_NAME);
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        insertUnitOfWorkHelper.registerInsert(accountMockInstance);

        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.DuplicateRuleHeader.allowSave = true;
        insertUnitOfWorkHelper.setDmlOptions(dmlOptions);

        Test.startTest();
        insertUnitOfWorkHelper.doWork();
        Test.stopTest();
        System.assertEquals(
            false,
            insertUnitOfWorkHelper.saveResults.isEmpty(),
            DO_WORK_ASSERT_MESSAGE
        );
    }
}