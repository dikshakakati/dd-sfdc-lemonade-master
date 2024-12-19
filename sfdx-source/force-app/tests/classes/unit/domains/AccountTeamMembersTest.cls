/**
 * @author Deloitte
 * @date 20/06/2023
 * @description This is test class for AccountTeamMembers class
 */
@isTest(seeAllData=false)
public class AccountTeamMembersTest {
    /**
     * @description This is method used to test AccountTeamMembers class
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember>();
        AccountTeamMembers accountTeamMembersObject = new AccountTeamMembers(AccountTeamMemberList);
        AccountTeamMembers.newInstance(accountTeamMemberList);
        System.assertNotEquals(
            AccountTeamMembers.newInstance(accountTeamMemberList),
            accountTeamMembersObject,
            'Unexpected result: both objects are similar.'
        );
    }
    /**
     * @description To validate if account already has a franchise representative team member,
     * then error must be thrown if new account team member with same role is inserted.
     */
    @isTest
    private static void testWhenExistingTeamMemberRoleIsFranchiseAndFranchiseRoleMemberIsInsertedThenThrowError() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id userId2 = fflib_IDGenerator.generate(User.SObjectType);
        Id parentAccountId = fake.generateId(Account.SObjectType);

        Fake parentAccountInstance = new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, 'Account1')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, 'SMB')
            .setField(Account.Type, 'Corporate')
            .setChildren(
                'AccountTeamMembers',
                new List<Fake>{
                    new Fake(AccountTeamMember.class)
                        .setField(AccountTeamMember.UserId, userId1)
                        .setField(AccountTeamMember.TeamMemberRole, 'Franchise Representative')
                        .setField(AccountTeamMember.AccountId, parentAccountId)
                        .setField(AccountTeamMember.AccountAccessLevel, 'Read Only')
                        .setField(AccountTeamMember.CaseAccessLevel, 'Read Only')
                        .setField(AccountTeamMember.ContactAccessLevel, 'Read Only')
                        .setField(AccountTeamMember.OpportunityAccessLevel, 'Read Only')
                }
            );

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountInstance
        );

        AccountTeamMember newAccountTeamMember = (AccountTeamMember) new Fake(
                AccountTeamMember.class
            )
            .setField(AccountTeamMember.UserId, userId2)
            .setField(AccountTeamMember.TeamMemberRole, 'Franchise Representative')
            .setField(AccountTeamMember.AccountAccessLevel, 'Read Only')
            .setField(AccountTeamMember.CaseAccessLevel, 'Read Only')
            .setField(AccountTeamMember.ContactAccessLevel, 'Read Only')
            .setField(AccountTeamMember.OpportunityAccessLevel, 'Read Only')
            .setField(AccountTeamMember.AccountId, parentAccountId)
            .setParent('Account', parentAccountInstance)
            .setFakeId()
            .toSObject();

        List<Account> parentAccounts = new List<Account>{ parentAccount };
        Set<Id> accountIds = new Set<Id>{ parentAccountId };
        List<AccountTeamMember> newAccountTeamMembers = new List<AccountTeamMember>{
            newAccountTeamMember
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);

        mocks.when(accountSelectorMock.selectAccountWithAccTeamMembers(accountIds))
            .thenReturn(parentAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        //Act
        AccountTeamMembers.newInstance(newAccountTeamMembers).validateIfItsAFranchiseRoleUser();

        //Assert
        System.assertEquals(1, newAccountTeamMembers[0].getErrors().size(), 'Error is not thrown');
    }

    /**
     * @description To validate and throw error if two new account team members with same franchise
     * representative role is inserted.
     */
    @isTest
    private static void testWhenTwoTeamMembersWithFranchiseRoleIsInsertedThenThrowError() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id userId2 = fflib_IDGenerator.generate(User.SObjectType);
        Id parentAccountId = fake.generateId(Account.SObjectType);

        Fake parentAccountInstance = new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, 'Account1')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, 'SMB')
            .setField(Account.Type, 'Corporate');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountInstance
        );

        AccountTeamMember firstAccountTeamMember = (AccountTeamMember) new Fake(
                AccountTeamMember.class
            )
            .setField(AccountTeamMember.UserId, userId1)
            .setField(AccountTeamMember.TeamMemberRole, 'Franchise Representative')
            .setField(AccountTeamMember.AccountId, parentAccountId)
            .setField(AccountTeamMember.AccountAccessLevel, 'Read Only')
            .setField(AccountTeamMember.CaseAccessLevel, 'Read Only')
            .setField(AccountTeamMember.ContactAccessLevel, 'Read Only')
            .setField(AccountTeamMember.OpportunityAccessLevel, 'Read Only')
            .setParent('Account', parentAccountInstance)
            .setFakeId()
            .toSObject();

        AccountTeamMember secondAccountTeamMember = (AccountTeamMember) new Fake(
                AccountTeamMember.class
            )
            .setField(AccountTeamMember.UserId, userId2)
            .setField(AccountTeamMember.TeamMemberRole, 'Franchise Representative')
            .setField(AccountTeamMember.AccountAccessLevel, 'Read Only')
            .setField(AccountTeamMember.CaseAccessLevel, 'Read Only')
            .setField(AccountTeamMember.ContactAccessLevel, 'Read Only')
            .setField(AccountTeamMember.OpportunityAccessLevel, 'Read Only')
            .setField(AccountTeamMember.AccountId, parentAccountId)
            .setParent('Account', parentAccountInstance)
            .setFakeId()
            .toSObject();

        List<Account> parentAccounts = new List<Account>{ parentAccount };
        Set<Id> accountIds = new Set<Id>{ parentAccountId };
        List<AccountTeamMember> newAccountTeamMembers = new List<AccountTeamMember>{
            firstAccountTeamMember,
            secondAccountTeamMember
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountWithAccTeamMembers(accountIds))
            .thenReturn(parentAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);

        AccountTeamMembers.newInstance(newAccountTeamMembers).validateIfItsAFranchiseRoleUser();

        System.assertEquals(1, newAccountTeamMembers[0].getErrors().size(), 'Error is not thrown');
        System.assertEquals(1, newAccountTeamMembers[1].getErrors().size(), 'Error is not thrown');
    }

     /**
     * @description Test to update Account And WorkOrder Owners as FranchiseReps
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMethodCalledThenUpdateAccountAndWorkOrderOwnersAsFranchiseReps() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id userId = fflib_IDGenerator.generate(User.SObjectType);

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
                AccountId = newAccounts[0].Id,
                UserId = userId
            )
        };

        Map<ID,ID> accountIdsandOwnerIdsToProcess = new Map<ID,ID>();
        accountIdsandOwnerIdsToProcess.put(newAccountTeamMembers[0].AccountId, newAccountTeamMembers[0].UserId);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectFranchiseAccountsForCorporateAccounts(new Set<ID>{newAccountTeamMembers[0].AccountId}))
            .thenReturn(newAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);

        AccountTeamMembers.newInstance(newAccountTeamMembers).updateAccountAndWorkOrderOwnersasFranchiseReps(accountIdsandOwnerIdsToProcess);

    }
}