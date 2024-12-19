/**
 * @author Deloitte
 * @date 07/12/2024
 * @description Test class for ShowDecisionMakersOnWorkPlanController class.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class ShowDecisionMakersOnWorkPlanCtrlTest {
    private static final String CONTACT_PHONE = '7654345678';
    private static final Integer NUMBER_OF_CALL_ATTEMPTS = 1;
    private static final String STORE_ACCOUNT_NAME = 'Test Store Account';

    /**
     * @description To test service class is calling when getDecisionMakerPhoneDetails method is called by using the passed Work Plan Id.
     */
    @isTest
    private static void testWhenParentWorkPlanGivenThenFetchChildWorkPlans() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        DecisionMakerWrapper.DecisionMakerDetails decisionMakerPhoneDetails = new DecisionMakerWrapper.DecisionMakerDetails(
            STORE_ACCOUNT_NAME,
            String.valueOf(contactId),
            'Store Contact',
            NUMBER_OF_CALL_ATTEMPTS,
            workPlanId,
            storeId
        );
        DecisionMakerWrapper decisionMakerWrapperDetails = new DecisionMakerWrapper(
            String.valueOf(contactId),
            'Store Contact',
            new List<DecisionMakerWrapper.DecisionMakerDetails>{ decisionMakerPhoneDetails },
            CONTACT_PHONE
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IShowDecisionMakersOnWorkPlanService showDecisionMakersOnWorkPlanService = (IShowDecisionMakersOnWorkPlanService) mocks.mock(
            IShowDecisionMakersOnWorkPlanService.class
        );
        mocks.startStubbing();
        mocks.when(showDecisionMakersOnWorkPlanService.getDecisionMakerPhoneDetails(workPlanId))
            .thenReturn(new List<DecisionMakerWrapper>{ decisionMakerWrapperDetails });
        mocks.stopStubbing();
        Application.SERVICE.setMock(
            IShowDecisionMakersOnWorkPlanService.class,
            showDecisionMakersOnWorkPlanService
        );
        Test.startTest();
        ShowDecisionMakersOnWorkPlanController.getDecisionMakerPhoneDetails(workPlanId);
        Test.stopTest();
        ((IShowDecisionMakersOnWorkPlanService) mocks.verify(
                showDecisionMakersOnWorkPlanService,
                1
            ))
            .getDecisionMakerPhoneDetails(workPlanId);
    }

    /**
     * @description To test service class is calling when updateNumberOfCallAttemptsOnWorkPlan method is called by using Json String.
     */
    @isTest
    private static void testWhenClickedOnSaveThenUpdateWorkPlans() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        DecisionMakerWrapper.DecisionMakerDetails decisionMakerInstance = new DecisionMakerWrapper.DecisionMakerDetails(
            '',
            '',
            '',
            NUMBER_OF_CALL_ATTEMPTS,
            workPlanId,
            ''
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IShowDecisionMakersOnWorkPlanService updateWorkPlanDetails = (IShowDecisionMakersOnWorkPlanService) mocks.mock(
            IShowDecisionMakersOnWorkPlanService.class
        );
        Application.SERVICE.setMock(
            IShowDecisionMakersOnWorkPlanService.class,
            updateWorkPlanDetails
        );
        Test.startTest();
        ShowDecisionMakersOnWorkPlanController.updateNumberOfCallAttemptsOnWorkPlan(
            JSON.serialize(
                new List<DecisionMakerWrapper.DecisionMakerDetails>{ decisionMakerInstance }
            )
        );
        Test.stopTest();
        ((IShowDecisionMakersOnWorkPlanService) mocks.verify(updateWorkPlanDetails, 1))
            .updateNumberOfCallAttemptsOnWorkPlan(
                JSON.serialize(
                    new List<DecisionMakerWrapper.DecisionMakerDetails>{ decisionMakerInstance }
                )
            );
    }
}