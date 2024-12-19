/**
 * @author Deloitte
 * @date   04/03/2022
 * @description This is the test class for AccountsServiceImpl
 */
@IsTest(SeeAllData=false)
public with sharing class UltimateParentUpdateBatchableTest {
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    /**
     * @description Tests when Parent is updated it reflects in Account record
     */
    @IsTest
    public static void testWhenAccUpdateThenGiveUltimateParentAccount() {
        Account parentAccountRoot = new Account(
            Name = 'Root Account',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccountRoot;

        Account parentAccountL1 = new Account(
            Name = 'Level 1 Parent Account',
            ParentId = parentAccountRoot.Id,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccountL1;

        Account childAccount = new Account(
            Name = 'Child Account',
            ParentId = parentAccountL1.Id,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert childAccount;

        Set<Id> accountIds = new Set<Id>();
        accountIds.add(parentAccountRoot.Id);
        accountIds.add(parentAccountL1.Id);
        accountIds.add(childAccount.Id);
        Test.startTest();
        UltimateParentUpdateBatchable obj = new UltimateParentUpdateBatchable(accountIds);
        Database.executeBatch(obj);
        Test.stopTest();
        List<Account> accountList = new List<Account>();
        accountList = [
            SELECT Id, Ultimate_Parent_Account__c
            FROM Account
            WHERE ParentId != NULL
            LIMIT 2
        ];
        System.assertEquals(
            accountList[0].Ultimate_Parent_Account__c,
            parentAccountRoot.Id,
            'Incorrect Ultimate Parent Account'
        );
        System.assertEquals(
            accountList[1].Ultimate_Parent_Account__c,
            parentAccountRoot.Id,
            'Incorrect Ultimate Parent Account'
        );
    }

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenProcessingBatchesOfAccountsThenCallTheAccountService() {
        // Arrange
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        for (Integer i = 0; i < 10; i++) {
            Account objAccount = (Account) new Fake(Account.class).setFakeId().toSObject();
            mapAccounts.put(objAccount.Id, objAccount);
        }

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IAccountsService serviceMock = (IAccountsService) mocks.mock(IAccountsService.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectAllParents(mapAccounts.keySet())).thenReturn(null);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IAccountsService.class, serviceMock);

        // Act
        UltimateParentUpdateBatchable batch = new UltimateParentUpdateBatchable(
            mapAccounts.keySet()
        );
        batch.start(null);
        batch.execute(null, mapAccounts.values());
        batch.finish(null);

        // Assert
        ((IAccountsService) mocks.verify(serviceMock, 1))
            .updateUltimateParent(mapAccounts.values());
        ((IAccountsSelector) mocks.verify(selectorMock, 1)).selectAllParents(mapAccounts.keySet());
    }
}