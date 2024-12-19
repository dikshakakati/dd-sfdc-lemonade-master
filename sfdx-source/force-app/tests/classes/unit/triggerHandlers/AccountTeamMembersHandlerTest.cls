/**
 * @author Deloitte
 * @date 20/06/2023
 * @description This is test class for AccountTeamMembersHandler class
 */
@isTest(seeAllData=false)
public class AccountTeamMembersHandlerTest {
    /**
     * @description To Restrict Franchise Represent role more than one on Corporate Account
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountTeamMemberRoleIsFranchiseRepresentativeCreatingMoreThanOneThenThrowAnError() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] newAccounts = new List<Account>{
            new Account(Id = account1Id, Name = 'Test', BillingCity = '123 Existing Street'),
            new Account(Id = account2Id, Name = 'Test', BillingCity = '987 Existing Street')
        };

        AccountTeamMember[] newAccountTeamMembers = new List<AccountTeamMember>{
            new AccountTeamMember(
                Id = fflib_IDGenerator.generate(AccountTeamMember.SObjectType),
                TeamMemberRole = 'Franchise Representative',
                AccountId = newAccounts[0].Id
            )
        };
        fflib_SObjectDomain.Test.Database.onInsert(newAccountTeamMembers);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountTeamMembers accountTeamMemberMock = (IAccountTeamMembers) mocks.mock(
            IAccountTeamMembers.class
        );
        mocks.startStubbing();
        mocks.when(accountTeamMemberMock.getType()).thenReturn(AccountTeamMember.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountTeamMemberMock);

        fflib_SObjectDomain.triggerHandler(AccountTeamMembersHandler.class);
        ((IAccountTeamMembers) mocks.verify(accountTeamMemberMock, 1))
            .validateIfItsAFranchiseRoleUser();
    }

    /**
     * @description To Restrict Franchise Represent role more than one on Corporate Account
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountTeamMemberRoleIsFranchiseRepresentativeUpdatingMoreThanOneThenThrowAnError() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] newAccounts = new List<Account>{
            new Account(Id = account1Id, Name = 'Test', BillingCity = '123 Existing Street'),
            new Account(Id = account2Id, Name = 'Test', BillingCity = '987 Existing Street')
        };

        AccountTeamMember[] oldAccountTeamMembers = new List<AccountTeamMember>{
            new AccountTeamMember(
                Id = fflib_IDGenerator.generate(AccountTeamMember.SObjectType),
                TeamMemberRole = 'Franchise Representative',
                AccountId = newAccounts[0].Id
            )
        };

        AccountTeamMember[] newAccountTeamMembers = new List<AccountTeamMember>{
            new AccountTeamMember(
                Id = fflib_IDGenerator.generate(AccountTeamMember.SObjectType),
                TeamMemberRole = 'Team Lead',
                AccountId = newAccounts[0].Id
            )
        };
        fflib_SObjectDomain.Test.Database.onUpdate(
            newAccountTeamMembers,
            new Map<Id, SObject>(oldAccountTeamMembers)
        );
        fflib_SObjectDomain.triggerHandler(AccountTeamMembersHandler.class);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountTeamMembers accountTeamMemberMock = (IAccountTeamMembers) mocks.mock(
            IAccountTeamMembers.class
        );
        mocks.startStubbing();
        mocks.when(accountTeamMemberMock.getType()).thenReturn(AccountTeamMember.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountTeamMemberMock);

        fflib_SObjectDomain.triggerHandler(AccountTeamMembersHandler.class);
        ((IAccountTeamMembers) mocks.verify(accountTeamMemberMock, 1))
            .validateIfItsAFranchiseRoleUser();
    }

    /**
     * @description to process account team member after inserted.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountTeamMemberRoleIsInsertedAsFranchiseThenUpdateAccountAndWorkOrder() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
       	Id businessRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] newAccounts = new List<Account>{
            new Account(Id = account1Id, Name = 'Test', BillingCity = '123 Existing Street',Type = 'Corporate',RecordTypeID = businessRecordTypeId),
            new Account(Id = account2Id, Name = 'Test', BillingCity = '987 Existing Street',Type = 'Corporate',RecordTypeID = businessRecordTypeId)
        };

        AccountTeamMember[] newAccountTeamMembers = new List<AccountTeamMember>{
            new AccountTeamMember(
                Id = fflib_IDGenerator.generate(AccountTeamMember.SObjectType),
                TeamMemberRole = 'Franchise Representative',
                AccountId = newAccounts[0].Id
            )
        };
        fflib_SObjectDomain.Test.Database.onInsert(newAccountTeamMembers);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAccountTeamMembers accountTeamMemberMock = (IAccountTeamMembers) mocks.mock(
            IAccountTeamMembers.class
        );
        mocks.startStubbing();
        mocks.when(accountTeamMemberMock.getType()).thenReturn(AccountTeamMember.SObjectType);

        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
       	mocks.when(selectorMock.selectById(new Set<Id>{ newAccounts[0].Id }))
            .thenReturn(new List<Account>{newAccounts[0]});

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.DOMAIN.setMock(accountTeamMemberMock);

        fflib_SObjectDomain.triggerHandler(AccountTeamMembersHandler.class);

    }
}