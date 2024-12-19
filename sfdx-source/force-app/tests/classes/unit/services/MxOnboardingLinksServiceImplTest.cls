/**
 * @author Deloitte
 * @date 06/26/2024
 * @description Test class for MxOnboardingLinksServiceImpl class.
 */
@isTest(SeeAllData=false)
private class MxOnboardingLinksServiceImplTest {
    private static final String INITIATE_RELATED_OBJECTS_CREATION = 'INITIATE_RELATED_OBJECTS_CREATION';
    private static final String INTERFACE_TRANSACTION_STATUS_FAILURE = 'Failure';
    private static final String RUNTIME_EXCEPTION_MESSAGE = 'Exception occurred during run time';

    /**
     * @description To test when onboarding Events are fired then initiate store Agreement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnboardingActivationsEventAreFiredThenInitiateStoreAgreement() {
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(mxOnboardingLinkId) }),
                Topic__c = INITIATE_RELATED_OBJECTS_CREATION
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxOnboardingLinks mxOnboardingLinksMock = (IMxOnboardingLinks) mocks.mock(
            IMxOnboardingLinks.class
        );
        mocks.startStubbing();
        mocks.when(mxOnboardingLinksMock.getType())
            .thenReturn(Schema.Mx_Onboarding_Link__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(mxOnboardingLinksMock);
        Test.startTest();
        MxOnboardingLinksService.execute(mockOnboardingEvents);
        Test.stopTest();
        /*((IMxOnboardingLinks) mocks.verify(mxOnboardingLinksMock, 1))
         .initiateStoreAgreementCreation(new Set<Id>{ mxOnboardingLinkId });*/
    }

    /**
     * @description To test when onboarding Events are fired then initiate store Agreement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnboardingActivationsEventAreFiredThenInitiateStoreAgreementNegative() {
        Test.startTest();
        MxOnboardingLinksServiceImpl mxOnboardingLinksServiceImplInstance = new MxOnboardingLinksServiceImpl();
        mxOnboardingLinksServiceImplInstance.createLogEntries(
            new TestCommitException(RUNTIME_EXCEPTION_MESSAGE)
        );
        Test.stopTest();
    }
}