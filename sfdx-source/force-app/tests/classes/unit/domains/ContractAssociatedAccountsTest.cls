/**
 * @description Test Class for ContractAssociatedAccounts  Domain
 * @author BizApps
 * @date 05/2023
 */
@isTest
public class ContractAssociatedAccountsTest {
    /**
     * @description To test getNewAssociatedAccountIds call
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractAssociatedAccountsInsertedThenReturnAssociatedAccounts() {
        Id contractId = Fake.generateId(Contract.class);
        Id contractAssociateAccountId1 = Fake.generateId(Contract_Associated_Accounts__c.class);
        Id accountId = Fake.generateId(Account.class);
        List<Contract_Associated_Accounts__c> contractAssociateAccountsList = new List<Contract_Associated_Accounts__c>{
            new Contract_Associated_Accounts__c(
                Id = contractAssociateAccountId1,
                Contract__c = contractId,
                Associated_Account_Ids__c = accountId
            )
        };
        IContractAssociatedAccounts contractInstance = ContractAssociatedAccounts.newInstance(
            contractAssociateAccountsList
        );
        Map<Id, Set<String>> contractIdAssociatedAccountIdsMap = contractInstance.getNewAssociatedAccountIds();
        system.assert(
            contractIdAssociatedAccountidsMap.get(contractId) == new Set<String>{ accountId },
            'Accounts are associated'
        );
    }

    /**
     * @description To test ContractAssociatedAccounts Trigger
     */
    @isTest
    private static void testWhenContractAssociatedAccountsInsertedThenRun() {
        Account acc = new Account(Name = 'Test 1', Segment__c = 'Enterprise');
        insert acc;

        Contract contract = new Contract(AccountId = acc.Id);
        insert contract;

        Contract_Associated_Accounts__c contractAssoAccount = new Contract_Associated_Accounts__c(
            Contract__c = contract.Id,
            Order__c = 1
        );
        insert contractAssoAccount;
        System.assertNotEquals(null, contractAssoAccount.Id, 'Id is null');
    }

    /**
     * @description To test getNewAssociatedAccountIdWithGroupIdAndEntitlementsToBeExcluded call
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractAssociatedAccountsInsertedThenReturnAssociatedAccountIdGroupIdMapWithEntitlements() {
        Id contractId = Fake.generateId(Contract.class);
        Id contractAssociateAccountId1 = Fake.generateId(Contract_Associated_Accounts__c.class);
        Id contractAssociateAccountId2 = Fake.generateId(Contract_Associated_Accounts__c.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id quoteLineGroup1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id quoteLineGroup2 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id sub1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id sub2 = Fake.generateId(SBQQ__Subscription__c.class);

        List<Contract_Associated_Accounts__c> contractAssociateAccountsList = new List<Contract_Associated_Accounts__c>{
            new Contract_Associated_Accounts__c(
                Id = contractAssociateAccountId1,
                Contract__c = contractId,
                Associated_Account_Ids__c = accountId1 + ',' + accountId2,
                group__c = quoteLineGroup1,
                Serialized_Entitlements_Data__c = String.valueOf(sub1)
            ),
            new Contract_Associated_Accounts__c(
                Id = contractAssociateAccountId2,
                Contract__c = contractId,
                Associated_Account_Ids__c = accountId3 + ',' + accountId4,
                group__c = quoteLineGroup2,
                Serialized_Entitlements_Data__c = String.valueOf(sub2)
            )
        };
        IContractAssociatedAccounts contractInstance = ContractAssociatedAccounts.newInstance(
            contractAssociateAccountsList
        );
        Map<Id, Set<String>> contractIdAssociatedAccountIdsMap = contractInstance.getNewAssociatedAccountIds();
        Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements = contractInstance.getNewAssociatedAccountIdWithGroupIdAndSerializedEntitlements(
            contractIdAssociatedAccountIdsMap
        );

        system.assert(
            associatedAccountIdGroupIdMapWithEntitlements != null,
            'AccountIdGroupIdMapWithEntitlements are associated'
        );
    }

    /**
     * @description To test getExistingAssociatedAccountIds call
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractAssociatedAccountsInsertedThenReturnExistingAssociatedAccounts() {
        Id contractId = Fake.generateId(Contract.class);
        Id contractAssociateAccountId1 = Fake.generateId(Contract_Associated_Accounts__c.class);
        Id accountId = Fake.generateId(Account.class);
        List<Contract_Associated_Accounts__c> contractAssociateAccountsList = new List<Contract_Associated_Accounts__c>{
            new Contract_Associated_Accounts__c(
                Id = contractAssociateAccountId1,
                Contract__c = contractId,
                Associated_Account_Ids__c = accountId,
                Batch_Process_Enabled__c = false,
                IsProcessingExistingStores__c = true
            )
        };
        IContractAssociatedAccounts contractInstance = ContractAssociatedAccounts.newInstance(
            contractAssociateAccountsList
        );
        Map<Id, Set<String>> contractIdAssociatedAccountIdsMap = contractInstance.getExistingAssociatedAccountIdsFromCaa();
        system.assert(
            contractIdAssociatedAccountidsMap.get(contractId) == new Set<String>{ accountId },
            'Accounts are associated'
        );
    }
}