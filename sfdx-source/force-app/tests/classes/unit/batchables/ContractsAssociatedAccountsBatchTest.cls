/**
 * @author DoorDash
 * @date 05/08/2023
 * @description Test ContractsAssociatedAccountsBatch class.
 */
@isTest
public class ContractsAssociatedAccountsBatchTest {
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String SCHEDULED_JOB_NAME = ContractsAssociatedAccountsBatch.class
        .getName();
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected Error: The Batch has not been triggered yet';

    /**
     * @description : test the batch execution
     **/
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractAssociatedAccountsMarkedForBatchThenProcessThoseRecords() {
        //ARRANGE
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Contract contract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .toSObject();

        string accountIdString = String.valueof(accountId1) + ',' + String.valueof(accountId2);
        Contract_Associated_Accounts__c contractAssociatedAccount = (Contract_Associated_Accounts__c) new Fake(
                Contract_Associated_Accounts__c.class
            )
            .setField(Contract_Associated_Accounts__c.Contract__c, contractId)
            .setField(Contract_Associated_Accounts__c.Batch_Process_Status__c, 'Not Started')
            .setField(Contract_Associated_Accounts__c.Batch_Process_Enabled__c, true)
            .setField(Contract_Associated_Accounts__c.Associated_Account_Ids__c, accountIdString)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractAssociatedAccountsSelector contractAssociatedAccountsSelectorMock = (IContractAssociatedAccountsSelector) mocks.mock(
            IContractAssociatedAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(contractAssociatedAccountsSelectorMock.sObjectType())
            .thenReturn(Contract_Associated_Accounts__c.SObjectType);
        mocks.when(contractAssociatedAccountsSelectorMock.selectByBatchProcessEnabledAndStatus())
            .thenReturn(null);
        mocks.stopStubbing();

        Application.Selector.setMock(contractAssociatedAccountsSelectorMock);

        //ACT
        ContractsAssociatedAccountsBatch batch = new ContractsAssociatedAccountsBatch();
        batch.start(null);
        batch.execute(null, new List<Contract_Associated_Accounts__c>{ contractAssociatedAccount });
        batch.finish(null);

        //ASSERT
        ((IContractAssociatedAccountsSelector) mocks.verify(
                contractAssociatedAccountsSelectorMock,
                1
            ))
            .selectByBatchProcessEnabledAndStatus();
    }

    /**
     * @description : test the batch execution
     **/
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractAssociatedAccountsMarkedForBatchAndExistingStoresThenProcessThoseRecords() {
        //ARRANGE
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        //Id contractAssociateAccountId1 = Fake.generateId(Contract_Associated_Accounts__c.class);
        //Id contractAssociateAccountId2 = Fake.generateId(Contract_Associated_Accounts__c.class);
        Contract contract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .toSObject();

        string accountIdString = String.valueof(accountId1) + ',' + String.valueof(accountId2);
        Contract_Associated_Accounts__c contractAssociatedAccount = (Contract_Associated_Accounts__c) new Fake(
                Contract_Associated_Accounts__c.class
            )
            .setField(Contract_Associated_Accounts__c.Contract__c, contractId)
            .setField(Contract_Associated_Accounts__c.Batch_Process_Status__c, 'Not Started')
            .setField(Contract_Associated_Accounts__c.Batch_Process_Enabled__c, true)
            .setField(Contract_Associated_Accounts__c.Associated_Account_Ids__c, accountIdString)
            .setField(Contract_Associated_Accounts__c.IsProcessingExistingStores__c, true)
            .setFakeId()
            .toSObject();
        Set<Id> conAssociatedAccountIds = new Set<Id>{ contractAssociatedAccount.id };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractAssociatedAccountsSelector contractAssociatedAccountsSelectorMock = (IContractAssociatedAccountsSelector) mocks.mock(
            IContractAssociatedAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(contractAssociatedAccountsSelectorMock.sObjectType())
            .thenReturn(Contract_Associated_Accounts__c.SObjectType);
        mocks.when(
                contractAssociatedAccountsSelectorMock.selectByBatchProcessEnabledAndStatusIds(
                    conAssociatedAccountIds
                )
            )
            .thenReturn(null);
        mocks.stopStubbing();

        Application.Selector.setMock(contractAssociatedAccountsSelectorMock);

        //ACT
        ContractsAssociatedAccountsBatch batch = new ContractsAssociatedAccountsBatch(
            conAssociatedAccountIds
        );
        batch.start(null);
        batch.execute(null, new List<Contract_Associated_Accounts__c>{ contractAssociatedAccount });
        batch.finish(null);

        //ASSERT
        ((IContractAssociatedAccountsSelector) mocks.verify(
                contractAssociatedAccountsSelectorMock,
                1
            ))
            .selectByBatchProcessEnabledAndStatusIds(conAssociatedAccountIds);
    }

    /**
     * @description To validate that schedulable context execute
     * is scheduling the batch job correctly.
     **/
    @isTest
    private static void testWhenBatchIsScheduledThenBatchIsExecutedOnScheduledTime() {
        Test.startTest();
        String jobId = System.schedule(
            SCHEDULED_JOB_NAME,
            CRON_EXPRESSION,
            new ContractsAssociatedAccountsBatch()
        );
        Test.stopTest();
        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(
            Time.newInstance(1, 0, 0, 0),
            cronTriggerRecord.NextFireTime.time(),
            BATCH_NOT_TRIGGERED_ASSERT_MESSAGE
        );
    }
}