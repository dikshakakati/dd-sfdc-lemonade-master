/**
 * @description This is test class for ContractAssociatedAccounts Trigger handler class
 * @author BizApps
 * @date 5/23
 */
@isTest
public class ContractAssociatedAccountsHandlerTest {
    /**
     * @description To test method call on ContractAssociatedAccounts After Insert
     *
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractAssociatedAccountsInsertedThenCall() {
        Id contractId1 = Fake.generateId(Contract.class);
        Id contractAssociateAccountId1 = Fake.generateId(Contract_Associated_Accounts__c.class);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Contract_Associated_Accounts__c> contracAssoAccounttList = new List<Contract_Associated_Accounts__c>{
            new Contract_Associated_Accounts__c(
                Id = contractAssociateAccountId1,
                Contract__c = contractId1,
                Associated_Account_Ids__c = accountId,
                Order__c = 1,
                Batch_Process_Enabled__c = true,
                Batch_Process_Status__c = 'Not Started',
                IsProcessingExistingStores__c = true
            )
        };

        Map<Id, Set<String>> getNewAssociatedAccountIdMap = new Map<Id, Set<String>>();
        getNewAssociatedAccountIdMap.put(contractId1, new Set<String>{ String.valueOf(accountId) });
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractAssociatedAccounts conAssociatedAccountsMock = (IContractAssociatedAccounts) mocks.mock(
            IContractAssociatedAccounts.class
        );
        mocks.startStubbing();
        mocks.when(conAssociatedAccountsMock.getType())
            .thenReturn(Schema.Contract_Associated_Accounts__c.SObjectType);
        mocks.when(conAssociatedAccountsMock.getNewAssociatedAccountIds())
            .thenReturn(getNewAssociatedAccountIdMap);
        mocks.when(conAssociatedAccountsMock.getExistingAssociatedAccountIdsFromCaa())
            .thenReturn(getNewAssociatedAccountIdMap);
        mocks.stopStubbing();
        Application.Domain.setMock(conAssociatedAccountsMock);
        fflib_SObjectDomain.Test.Database.onInsert(contracAssoAccounttList);
        fflib_SObjectDomain.triggerHandler(ContractAssociatedAccountsHandler.class);
        ((IContractAssociatedAccounts) mocks.verify(conAssociatedAccountsMock, 1))
            .getNewAssociatedAccountIds();
    }
}