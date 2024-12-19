/**
 * @author BizApps
 * @date 5/23
 * @description This is test class for ContractAssociatedAccountsSelector class
 */
@isTest
public class ContractAssociatedAccountsSelectorTest {
    @testSetup
    static void setupData() {
        Account parentAccount = new Account(Name = 'Test Parent Account', Segment__c = 'Enterprise');
        insert parentAccount;
        List<Contract> childContracts = new List<Contract>{
            new Contract(
                StartDate = Date.today() + 1,
                Status = 'Draft',
                AccountId = parentAccount.Id
            ),
            new Contract(
                StartDate = Date.today() + 1,
                Status = 'Draft',
                AccountId = parentAccount.Id
            )
        };
        insert childContracts;
    }

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        Account acc = new Account(Name = 'Test 1', Segment__c = 'Enterprise');
        insert acc;
        Contract testContract1 = new Contract(Name = 'Test Contract1', AccountId = acc.Id);
        insert testContract1;
        Contract_Associated_Accounts__c conAssociatedAccount = new Contract_Associated_Accounts__c(
            Contract__c = testContract1.Id,
            Order__c = 1
        );
        insert ConAssociatedAccount;
        List<Contract_Associated_Accounts__c> contractsAssociatedAccounts = ContractAssociatedAccountsSelector.newInstance()
            .selectById(new Set<Id>{ conAssociatedAccount.Id });
        System.assertEquals(
            contractsAssociatedAccounts.size(),
            1,
            'The list should Contain 1 Contract Associated Account'
        );

        ContractAssociatedAccountsSelector contractAssoAccountInstance = new ContractAssociatedAccountsSelector();
        Schema.SObjectType typeOfObj = contractAssoAccountInstance.getSObjectType();
        System.assertEquals(
            Schema.Contract_Associated_Accounts__c.SObjectType,
            typeOfObj,
            'The object type must be Contract Associated Account'
        );
        List<Schema.SObjectField> fieldList = contractAssoAccountInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Contract_Associated_Accounts__c.Id,
                Contract_Associated_Accounts__c.Associated_Account_Ids__c,
                Contract_Associated_Accounts__c.Contract__c,
                Contract_Associated_Accounts__c.Batch_Process_Enabled__c,
                Contract_Associated_Accounts__c.Batch_Process_Status__c,
                Contract_Associated_Accounts__c.Order__c,
                Contract_Associated_Accounts__c.Group__c,
                Contract_Associated_Accounts__c.IsProcessingExistingStores__c,
                Contract_Associated_Accounts__c.Serialized_Entitlements_Data__c
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    /**
     * @description To test When ContractId Is Passed Then ContractAssociatedAccounts Are Returned
     */
    @isTest
    private static void testWhenContractIdIsPassedThenContractAssociatedAccountsAreReturned() {
        Contract testContract1 = [SELECT id FROM Contract LIMIT 1][0];
        List<Contract_Associated_Accounts__c> conAssociatedAccounts = new List<Contract_Associated_Accounts__c>{
            new Contract_Associated_Accounts__c(Contract__c = testContract1.Id, Order__c = 1),
            new Contract_Associated_Accounts__c(Contract__c = testContract1.Id, Order__c = 2)
        };
        insert conAssociatedAccounts;
        ContractAssociatedAccountsSelector contractAssoAccountInstance = new ContractAssociatedAccountsSelector();
        List<Contract_Associated_Accounts__c> conAssoAccounts = contractAssoAccountInstance.selectByContractId(
            testContract1.Id
        );
        System.assertEquals(
            2,
            conAssoAccounts.size(),
            'Should return 2 ContractAssociatedAccounts'
        );
    }

    /**
     * @description To test When ContractId Is Passed Then ContractAssociatedAccounts Are Returned
     */
    @isTest
    private static void testWhenContractIdsArePassedThenContractAssociatedAccountsAreReturned() {
        List<Contract> testContractList = [SELECT Id FROM Contract LIMIT 2];
        List<Contract_Associated_Accounts__c> conAssociatedAccounts = new List<Contract_Associated_Accounts__c>{
            new Contract_Associated_Accounts__c(Contract__c = testContractList[0].Id, Order__c = 1),
            new Contract_Associated_Accounts__c(Contract__c = testContractList[1].Id, Order__c = 2)
        };
        insert conAssociatedAccounts;
        ContractAssociatedAccountsSelector contractAssoAccountInstance = new ContractAssociatedAccountsSelector();
        List<Contract_Associated_Accounts__c> conAssoAccounts = contractAssoAccountInstance.selectByContractIds(
            new Set<Id>{ testContractList[0].Id, testContractList[1].Id }
        );
        System.assertEquals(
            2,
            conAssoAccounts.size(),
            'Should return 2 ContractAssociatedAccounts'
        );
    }

    @isTest
    private static void testWhenSearchingByBatchProcessEnabledThenReturnRecords() {
        Account acc1 = new Account(Name = 'Test 1', Segment__c = 'Enterprise');
        Account acc2 = new Account(Name = 'Test 2', Segment__c = 'Enterprise');
        insert new List<Account>{ acc1, acc2 };
        Contract testContract = [SELECT id FROM Contract][0];
        Contract_Associated_Accounts__c contractAssociatedAccount = new Contract_Associated_Accounts__c(
            Contract__c = testContract.Id,
            Order__c = 1,
            Batch_Process_Status__c = 'Not Started',
            Batch_Process_Enabled__c = true,
            Associated_Account_Ids__c = acc1.Id + ',' + acc2.Id
        );
        insert contractAssociatedAccount;
        Test.startTest();
        ContractAssociatedAccountsSelector contractAssoAccountInstance = new ContractAssociatedAccountsSelector();
        Database.QueryLocator queryLocator = contractAssoAccountInstance.selectByBatchProcessEnabledAndStatus();
        List<Contract_Associated_Accounts__c> conAssociatedAccounts = Database.query(
            queryLocator.getQuery()
        );
        Test.stopTest();
        System.assertEquals(
            1,
            conAssociatedAccounts.size(),
            '1 record is expected for this criteria'
        );
    }

    @isTest
    private static void testWhenSearchingByBatchProcessEnabledIdsThenReturnRecords() {
        Account acc1 = new Account(Name = 'Test 1', Segment__c = 'Enterprise');
        Account acc2 = new Account(Name = 'Test 2', Segment__c = 'Enterprise');
        insert new List<Account>{ acc1, acc2 };
        Contract testContract = [SELECT id FROM Contract][0];
        Contract_Associated_Accounts__c contractAssociatedAccount = new Contract_Associated_Accounts__c(
            Contract__c = testContract.Id,
            Order__c = 1,
            Batch_Process_Status__c = 'Not Started',
            Batch_Process_Enabled__c = true,
            Associated_Account_Ids__c = acc1.Id + ',' + acc2.Id
        );
        insert contractAssociatedAccount;
        Test.startTest();
        ContractAssociatedAccountsSelector contractAssoAccountInstance = new ContractAssociatedAccountsSelector();
        Set<Id> conAssociatedAccountIds = new Set<Id>{ contractAssociatedAccount.Id };
        Database.QueryLocator queryLocator = contractAssoAccountInstance.selectByBatchProcessEnabledAndStatusIds(
            conAssociatedAccountIds
        );
        List<Contract_Associated_Accounts__c> conAssociatedAccounts = Database.query(
            queryLocator.getQuery()
        );
        Test.stopTest();
        System.assertEquals(
            1,
            conAssociatedAccounts.size(),
            '1 record is expected for this criteria'
        );
    }
}