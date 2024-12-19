/**
 * @author Deloitte
 * @date 12/09/2023
 * @description This is the test class for AccountUpdateForActiveRatesBatch class
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class AccountUpdateForActiveRatesBatchTest {
    private static final String NEW_RATE_CHANGE = 'New';
    private static final String APPROVED = 'Approved';
    private static final Date TODAY_DATE = System.today();
    @IsTest
    static void testWhenForPassedListOfAccountsThenRateChangeRequestIdIsStamped() {
        //ARRANGE
        Id accountId = Fake.generateId(Account.class);
        Id accId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id caseId = Fake.generateId(Case.class);
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test Account 1 - Batch')
            .setField(Account.Id, accountId)
            .toSObject();

        Account account2 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test Account 2 - Batch')
            .setField(Account.Id, accId)
            .toSObject();

        Rate_Change_Request__c rateChangeRequest = (Rate_Change_Request__c) new Fake(
                Rate_Change_Request__c.class
            )
            .setField(Rate_Change_Request__c.Contract__c, contractId)
            .setField(Rate_Change_Request__c.Effective_Date__c, TODAY_DATE)
            .setField(Rate_Change_Request__c.S_O_Support_Request_Link__c, caseId)
            .setField(Rate_Change_Request__c.Activation_Status__c, NEW_RATE_CHANGE)
            .setField(Rate_Change_Request__c.Status__c, APPROVED)
            .setFakeId()
            .toSObject();

        List<Account> storeAccountsToUpdate = new List<Account>{ account1, account2 };
        Set<Id> storeAccountIdsToUpdate = new Set<Id>{ account1.Id, account2.Id };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        IAccountsService serviceMock = (IAccountsService) mocks.mock(IAccountsService.class);

        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.getStoreAccountsById(new Set<Id>{ account1.Id, account2.Id }))
            .thenReturn(null);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IAccountsService.class, serviceMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        //ACT
        AccountUpdateForActiveRatesBatch batch = new AccountUpdateForActiveRatesBatch(
            storeAccountIdsToUpdate,
            rateChangeRequest.Id
        );
        batch.start(null);
        batch.execute(null, storeAccountsToUpdate);
        batch.finish(null);

        //ASSERT
        ((IAccountsService) mocks.verify(serviceMock, 1))
            .updateRateChangeRequestOnAccount(storeAccountsToUpdate, rateChangeRequest.Id);
        ((IAccountsSelector) mocks.verify(selectorMock, 1))
            .getStoreAccountsById(new Set<Id>{ account1.Id, account2.Id });
    }
}