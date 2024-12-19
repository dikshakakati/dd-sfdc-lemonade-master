/**
 * @author Deloitte
 * @date 06/13/2024
 * @description Test class for MxOnboardingLinksHandler class.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class MxOnboardingLinksHandlerTest {
    private static final String CREATION_STATUS_FAILURE = 'Failure';
    private static final String CREATION_STATUS_SUCCESS = 'Success';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';
    private static final String ONE_TIME_LINK = 'www.test.com';

    /**
     * @description To test when Mx Onboarding Links are updated then call initaite Work Order
     * creation.
     */
    @isTest
    private static void testWhenMxOnboardingLinksUpdatedThenInitiateWorkOrderCreation() {
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Map<Id, Mx_Onboarding_Link__c> oldOnboardingLinksMap = new Map<Id, Mx_Onboarding_Link__c>();
        Mx_Onboarding_Link__c oldMxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(Mx_Onboarding_Link__c.Record_Creation_Status__c, CREATION_STATUS_FAILURE)
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .toSobject();
        oldOnboardingLinksMap.put(mxOnboardingLinkId, oldMxOnboardingLinkFake);
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(Mx_Onboarding_Link__c.Record_Creation_Status__c, CREATION_STATUS_SUCCESS)
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .toSobject();

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
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake },
            oldOnboardingLinksMap
        );
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(MxOnboardingLinksHandler.class);
        ((IMxOnboardingLinks) mocks.verify(mxOnboardingLinksMock, 1)).initiateWorkOrderCreation();
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxOnboardingLinksThenStatusChange() {
        Id mXOnboardingLinkId = Fake.generateId(Mx_Onboarding_Link__c.class);

        List<Mx_Onboarding_Link__c> mxOnboardingLinkNewStatusList = new List<Mx_Onboarding_Link__c>{
            new Mx_Onboarding_Link__c(
                Id = mXOnboardingLinkId,
                Record_Creation_Status__c = CREATION_STATUS_SUCCESS
            )
        };

        List<Mx_Onboarding_Link__c> mxOnboardingLinkOldStatusList = new List<Mx_Onboarding_Link__c>{
            new Mx_Onboarding_Link__c(
                Id = mXOnboardingLinkId,
                Record_Creation_Status__c = CREATION_STATUS_FAILURE
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxOnboardingLinks mxOnboardingLinksmock = (IMxOnboardingLinks) mocks.mock(
            IMxOnboardingLinks.class
        );
        mocks.startStubbing();
        mocks.when(mxOnboardingLinksmock.getType())
            .thenReturn(Schema.Mx_Onboarding_Link__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(mxOnboardingLinksmock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            mxOnboardingLinkNewStatusList,
            new Map<Id, Mx_Onboarding_Link__c>(mxOnboardingLinkOldStatusList)
        );
        fflib_SObjectDomain.triggerHandler(MxOnboardingLinksHandler.class);
        ((IMxOnboardingLinks) mocks.verify(mxOnboardingLinksmock))
            .initiateStoreAgreementCreationAsync();
    }

    /**
     * @description To test when Mx Onboarding Links are inserted then Initiate Onboarding Link Email Integration.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxOnboardingLinksInsertedThenInitiateOnboardingLinkEmailIntegration() {
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.One_Time_Mx_Link__c, ONE_TIME_LINK)
            .toSobject();

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
        fflib_SObjectDomain.Test.Database.onInsert(
            new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake }
        );
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(MxOnboardingLinksHandler.class);
        IntegrationCriteriaEvaluator integrationCriteriaEvaluatorInstance = new IntegrationCriteriaEvaluator();
        ((IntegrationCriteriaEvaluator) mocks.verify(integrationCriteriaEvaluatorInstance, 1))
            .evaluateInitialCriteriaForEmailIntegration(
                new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake }
            );
    }
}