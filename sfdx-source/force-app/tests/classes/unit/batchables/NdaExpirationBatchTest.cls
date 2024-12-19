/**
 * @author Deloitte
 * @description This is the test class for NdaExpirationBatch class
 * @date 27/04/2022
 */
@isTest
private class NdaExpirationBatchTest {
    @IsTest
    static void testWhenNDAExpiredAccountsExistThenUpdateNDAStatus() {
        //ARRANGE
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test Account 1 - Batch')
            .setField(Account.NDA_Expiration_Date__c, Date.today() - 3)
            .setField(Account.NDA_Status__c, 'Active')
            .setFakeId()
            .toSObject();

        List<Account> accountRecords = new List<Account>{ account1 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectAccountsWithExpiredNda()).thenReturn(null);
        mocks.stopStubbing();

        Application.Selector.setMock(accountsSelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        //ACT
        NdaExpirationBatch batch = new NdaExpirationBatch();
        batch.start(null);
        batch.execute(null, accountRecords);
        batch.finish(null);

        //ASSERT
        ((IAccountsSelector) mocks.verify(accountsSelectorMock, 1)).selectAccountsWithExpiredNda();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
        System.assertEquals(
            'Expired',
            accountRecords[0].NDA_Status__c,
            'NDA Status is not updated as expected'
        );
    }
}