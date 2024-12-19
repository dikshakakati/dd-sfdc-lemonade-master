/**
 * @author Deloitte
 * @date 13/09/2023
 * @description Test class for ManagePricingRateChangeServiceImpl.
 */
@isTest
public class ManagePricingRateChangeServiceImplTest {
    private static final String NEW_RATE_CHANGE = 'New';
    private static final String APPROVED = 'Approved';
    private static final Date TODAY_DATE = System.today();

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenManagePricingWrapperisPassedThenRateChangeRequestIsCreated() {
        //ARRANGE
        Id accountId = Fake.generateId(Account.class);
        Id accId1 = Fake.generateId(Account.class);
        Id accId2 = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id caseId = Fake.generateId(Case.class);
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id subscriptionId2 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);

        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test Account 1 - Batch')
            .setField(Account.Id, accId1)
            .setField(Account.ParentId, accountId)
            .toSObject();

        Account account2 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test Account 2 - Batch')
            .setField(Account.Id, accId2)
            .setField(Account.ParentId, accountId)
            .toSObject();

        ManagePricingWrapper.SubscriptionWrapper subWrap0 = new ManagePricingWrapper.SubscriptionWrapper(
            subscriptionId1,
            1,
            6
        );
        ManagePricingWrapper.SubscriptionWrapper subWrap1 = new ManagePricingWrapper.SubscriptionWrapper(
            subscriptionId2,
            2,
            7
        );

        String storeAccountStr = String.valueOf(account1.Id) + ',' + String.valueOf(account2.Id);

        List<ManagePricingWrapper.SubscriptionWrapper> subWrapList = new List<ManagePricingWrapper.SubscriptionWrapper>();
        subWrapList.add(subWrap0);
        subWrapList.add(subWrap1);

        ManagePricingWrapper manageWrap = new ManagePricingWrapper(
            subWrapList,
            caseId,
            TODAY_DATE,
            contractId,
            storeAccountStr
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUnitOfWork);

        //ACT
        ManagePricingRateChangeReqService.createRateChangeRequest(manageWrap);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
    }
}