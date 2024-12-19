/**
 * @author Deloitte
 * @date 04/05/2022
 * @description Test class for StoresOnWorkPlanController class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class StoresOnWorkPlanControllerTest {
    private static final String ACCOUNT_NAME = 'Test KFC Account';
    private static final List<String> FILEDS = new List<String>{ 'Name', 'Phone' };
    private static final String OBJECT_NAME = 'Account';
    private static final String SECTION_NAME = 'Account Details';
    private static final Integer SEQUENCE = 1;
    private static final String STORE_ACCOUNT_NAME = 'Test Account';
    private static final String WORK_PLAN_TYPE = 'Onboarding';

    /**
     * @description To test Work Step's related store account from WorkPlan Id.
     */
    @isTest
    private static void testWhenFetchStoresByWorkPlanThenReturnRelatedUniqueStores() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        AccountWrapper accountWrapper = new AccountWrapper(
            storeAccountId,
            STORE_ACCOUNT_NAME,
            opportunityId,
            workOrderId
        );
        StoresOnWorkPlanWrapper parentWrapper = new StoresOnWorkPlanWrapper(
            new List<AccountWrapper>{ accountWrapper },
            WORK_PLAN_TYPE,
            false
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStoresOnWorkPlansService storeOnWorkPlanService = (IStoresOnWorkPlansService) mocks.mock(
            IStoresOnWorkPlansService.class
        );
        mocks.startStubbing();
        mocks.when(storeOnWorkPlanService.fetchStoresByWorkPlan(workPlanId))
            .thenReturn(parentWrapper);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IStoresOnWorkPlansService.class, storeOnWorkPlanService);
        Test.startTest();
        StoresOnWorkPlanController.fetchStoresByWorkPlan(workPlanId);
        Test.stopTest();
        ((IStoresOnWorkPlansService) mocks.verify(storeOnWorkPlanService, 1))
            .fetchStoresByWorkPlan(workPlanId);
    }

    /**
     * @description To test fetch store data when a section is changed on UI.
     */
    @isTest
    private static void testWhenFetchStoreDataThenReturnStoreData() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        SectionWrapper sectionWrapper = new SectionWrapper(
            SEQUENCE,
            SECTION_NAME,
            storeAccountId,
            OBJECT_NAME,
            FILEDS
        );
        AccountWrapper accountWrapper = new AccountWrapper(
            storeAccountId,
            ACCOUNT_NAME,
            opportunityId,
            workOrderId
        );
        accountWrapper.workPlanType = WORK_PLAN_TYPE;
        accountWrapper.businessAccountId = businessAccountId;
        List<SectionWrapper> sectionWrappers = new List<SectionWrapper>{ sectionWrapper };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStoresOnWorkPlansService storeOnWorkPlanService = (IStoresOnWorkPlansService) mocks.mock(
            IStoresOnWorkPlansService.class
        );
        mocks.startStubbing();
        mocks.when(
                storeOnWorkPlanService.fetchStoresData(
                    JSON.serialize(new List<AccountWrapper>{ accountWrapper })
                )
            )
            .thenReturn(sectionWrappers);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IStoresOnWorkPlansService.class, storeOnWorkPlanService);
        Test.startTest();
        StoresOnWorkPlanController.fetchStoresData(
            JSON.serialize(new List<AccountWrapper>{ accountWrapper })
        );
        Test.stopTest();
        ((IStoresOnWorkPlansService) mocks.verify(storeOnWorkPlanService, 1))
            .fetchStoresData(JSON.serialize(new List<AccountWrapper>{ accountWrapper }));
    }
}