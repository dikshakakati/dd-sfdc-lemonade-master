/**
 * @author Deloitte
 * @date 12/07/2022
 * @description Test class for UpdateUnitOfWorkHelper class.
 */
@isTest(SeeAllData=false)
private class UpdateUnitOfWorkHelperTest {
    private static final String CHILD_ACCOUNT_NAME = 'Child Account';
    private static final String DO_WORK_ASSERT_MESSAGE = 'Unexpected result: failed to perform update using database method';
    private static final String PARENT_ACCOUNT_NAME = 'Parent Account';
    private static final String REGISTER_SINGLE_RECORD_ASSERT_MESSAGE = 'Unexpected result: failed to register a single record';
    private static final String REGISTER_MULTIPLE_RECORDS_ASSERT_MESSAGE = 'Unexpected result: failed to register a list of records';
    private static final String REGISTER_NULL_LIST_ASSERT_MESSAGE = 'Unexpected result: null list registered successfully';

    /**
     * @description To test registerUpdate() method for a single sObject record.
     */
    @isTest
    private static void testWhenRegisterUpdateWithSingleRecordCalledThenSobjectListUpdated() {
        Account accountMockInstance = new Account(Name = PARENT_ACCOUNT_NAME);
        UpdateUnitOfWorkHelper updateUnitOfWorkHelper = new UpdateUnitOfWorkHelper();
        Test.startTest();
        updateUnitOfWorkHelper.registerUpdate(accountMockInstance);
        Test.stopTest();
        System.assertEquals(
            1,
            updateUnitOfWorkHelper.sObjectsToUpdate.size(),
            REGISTER_SINGLE_RECORD_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test registerUpdate() method for a list of sObject records.
     */
    @isTest
    private static void testWhenRegisterUpdateWithListOfRecordCalledThenSobjectListUpdated() {
        Account parentAccountMockInstance = new Account(Name = PARENT_ACCOUNT_NAME);
        Account childAccountMockInstance = new Account(Name = CHILD_ACCOUNT_NAME);
        UpdateUnitOfWorkHelper updateUnitOfWorkHelper = new UpdateUnitOfWorkHelper();
        Test.startTest();
        updateUnitOfWorkHelper.registerUpdate(
            new List<Account>{ parentAccountMockInstance, childAccountMockInstance }
        );
        Test.stopTest();
        System.assertEquals(
            2,
            updateUnitOfWorkHelper.sObjectsToUpdate.size(),
            REGISTER_MULTIPLE_RECORDS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test registerUpdate() method passed a null list.
     */
    @isTest
    private static void testWhenRegisterUpdateWithNullListCalledThenExceptionThrown() {
        List<Account> accounts;
        Boolean hasExceptionOccurred = false;
        UpdateUnitOfWorkHelper updateUnitOfWorkHelper = new UpdateUnitOfWorkHelper();
        Test.startTest();
        try {
            updateUnitOfWorkHelper.registerUpdate(accounts);
        } catch (Exception nullListException) {
            hasExceptionOccurred = true;
        }
        Test.stopTest();
        System.assertEquals(true, hasExceptionOccurred, REGISTER_NULL_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test doWork() method performs update operation using database method.
     */
    @isTest
    private static void testWhenDoWorkCalledThenSaveResultsUpdated() {
        Account accountMockInstance = new Account(Name = PARENT_ACCOUNT_NAME);
        UpdateUnitOfWorkHelper updateUnitOfWorkHelper = new UpdateUnitOfWorkHelper();
        updateUnitOfWorkHelper.registerUpdate(accountMockInstance);
        Test.startTest();
        updateUnitOfWorkHelper.doWork();
        Test.stopTest();
        System.assertEquals(
            false,
            updateUnitOfWorkHelper.saveResults.isEmpty(),
            DO_WORK_ASSERT_MESSAGE
        );
    }
}