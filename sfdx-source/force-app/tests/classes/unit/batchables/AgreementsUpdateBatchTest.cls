/**
 * @author Deloitte
 * @date 02/05/2024
 * @description Test AgreementsUpdateBatchTest class.
 */
@isTest
public class AgreementsUpdateBatchTest {
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String SCHEDULED_JOB_NAME = AgreementsUpdateBatch.class.getName();
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

        Contract contract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .toSObject();

        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId1)
            .toSObject();
        string accountIdString = String.valueof(accountId1);
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id grp1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id orderItem1 = Fake.generateId(OrderItem.class);
        Id orderItem2 = Fake.generateId(OrderItem.class);
        SBQQ__Subscription__c[] subs = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(
                Id = subs1,
                SBQQ__OrderProduct__c = orderItem1,
                SBQQ__TerminatedDate__c = null
            ),
            new SBQQ__Subscription__c(
                Id = subs2,
                SBQQ__OrderProduct__c = orderItem2,
                SBQQ__TerminatedDate__c = null
            )
        };
        Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements = new Map<Id, Map<Id, String>>();
        Map<Id, String> innerMap1 = new Map<Id, String>();
        List<Id> subRec1 = new List<Id>{ subs[0].Id, subs[1].Id };
        innerMap1.put(grp1, String.join(subRec1, ','));
        associatedAccountIdGroupIdMapWithEntitlements.put(accountId1, innerMap1);
        associatedAccountIdGroupIdMapWithEntitlements.put(accountId1, innerMap1);

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

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectByIdsForBatchProcess(new Set<Id>{ accountId1 }))
            .thenReturn(null);
        mocks.stopStubbing();

        Application.Selector.setMock(accountsSelectorMock);

        IAgreementsService agreementsServiceMock = (IAgreementsService) mocks.mock(
            IAgreementsService.class
        );
        Application.SERVICE.setMock(IAgreementsService.class, agreementsServiceMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        //ACT
        AgreementsUpdateBatch batch = new AgreementsUpdateBatch(contractAssociatedAccount);
        batch.start(null);
        batch.execute(null, new List<Account>{ account1 });
        batch.finish(null);
        AgreementsService.updateAgreementsForExistingStoresWithGroups(
            associatedAccountIdGroupIdMapWithEntitlements
        );

        //ASSERT
        ((IAccountsSelector) mocks.verify(accountsSelectorMock, 1))
            .selectByIdsForBatchProcess(new Set<Id>{ accountId1 });
        ((IAgreementsService) mocks.verify(agreementsServiceMock, 1))
            .updateAgreementsForExistingStoresWithGroups(
                associatedAccountIdGroupIdMapWithEntitlements
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Contract_Associated_Accounts__c.Id => contractAssociatedAccount.Id,
                        Contract_Associated_Accounts__c.Batch_Process_Status__c => 'Complete',
                        Contract_Associated_Accounts__c.Batch_Process_Enabled__c => false
                    }
                )
            );
    }
}