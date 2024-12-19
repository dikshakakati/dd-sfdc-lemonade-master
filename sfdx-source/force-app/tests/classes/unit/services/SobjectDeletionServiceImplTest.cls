/**
 * @author Deloitte
 * @date 10/12/2022
 * @description Test class for SobjectDeletionServiceImpl class.
 */
@isTest(SeeAllData=false)
private class SobjectDeletionServiceImplTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ASSERT_MESSAGE_EXCEPTION_MESSAGE = 'Unexpected result: exception message is not matching';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';

    /**
     * @description To test deletion of sObjects when sObjects are received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSObjectsReceivedThenSObjectsDeleted() {
        List<sObject> sObjects = new List<sObject>();
        Fake accountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account account = (Account) ServiceMockDataBuilder.convertToSObject(accountFakeInstance);
        sObjects.add(account);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        SobjectDeletionService.fireRecordsDeletion(sObjects);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerDeleted(sObjects);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test exception log (Log__c) is created when DML Exception occurs
     * while deleting the received sObjects.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDeletionFailsWithDMLExceptionThenLogCreated() {
        List<sObject> sObjects = new List<sObject>();
        String exceptionMessage;
        Fake accountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account account = (Account) ServiceMockDataBuilder.convertToSObject(accountFakeInstance);
        sObjects.add(account);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        try {
            SobjectDeletionService.fireRecordsDeletion(sObjects);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        } catch (Exception mockException) {
            exceptionMessage = mockException.getMessage();
        }
        System.assertEquals(
            MOCK_EXCEPTION_MESSAGE,
            exceptionMessage,
            ASSERT_MESSAGE_EXCEPTION_MESSAGE
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.HIGH.name()
                    }
                )
            );
    }

    /**
     * @description To test commit work is not performed when empty/null sObject is received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenReceivedNullSObjectsThenSObjectsDeletionNotFired() {
        List<sObject> sObjects = new List<sObject>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        SobjectDeletionService.fireRecordsDeletion(sObjects);
        //when sObjects list is null then the method is returned without performing commit work.
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}