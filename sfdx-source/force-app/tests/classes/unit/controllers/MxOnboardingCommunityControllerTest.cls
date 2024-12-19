/**
 * @author Deloitte
 * @date 12/07/2024
 * @description Test class for MxOnboardingCommunityController class.
 */
@isTest(seeAllData=false)
private class MxOnboardingCommunityControllerTest {
    private static final String FRENCH_LANGUAGE = 'fr';
    private static final String ONE_TIME_MX_LINK_STATIC_CONFIG = 'One_Time_Mx_Link';
    private static final String METADATA_VALUE = 'test.test.com';
    private static final String ONBOARDING_SCENARIO = 'Net-New Mx Onboarding';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String ASSERT_MESSAGE_MX_ONBOARDING_LINK = 'Unexpected result: Mx Onboarding Link record is not matching';
    private static final String PHOTOSHOOT_DATE_API_NAME = 'Photoshoot_Date__c';
    private static final String PHOTOSHOOT_TIME_API_NAME = 'Photoshoot_Time__c';
    private static final String ACTIVATED_CENTRALLY_API_NAME = 'Activated_Centrally_AC__c';
    private static final String DELAY_TABLET_SHIPMENT_API_NAME = 'Delay_Tablet_Shipment__c';
    private static final String UUID = '1234';
    private static final String NO = 'NO';
    private static final String MOCK_EMAIL = 'testmock@gmail.com';
    private static final String EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String ASSERT_MESSAGE_EXCEPTION_MESSAGE = 'Unexpected Error: The Exception fired was not a TestCommitException.';
    private static final Integer ADD_DAYS = 10;
    /**
     * @description To test Mx Onboarding Link record is returned using the passed UUID.
     */
    @isTest
    private static void testWhenGetActiveMxOnboardingLinkThenReturnMxOnboardingLinkRecord() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelector = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(ONE_TIME_MX_LINK_STATIC_CONFIG))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ONE_TIME_MX_LINK_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mxOnboardingLinksSelector.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(mxOnboardingLinksSelector.currentOnBoardingLinkByUUID(UUID))
            .thenReturn(
                new List<Mx_Onboarding_Link__c>{
                    new Mx_Onboarding_Link__c(
                        Id = mxOnboardingLinkId,
                        Business_Account__c = businessAccountId,
                        Contract__c = contractId,
                        Onboarding_Scenario__c = ONBOARDING_SCENARIO,
                        Rep_Collecting_On_Mx_Behalf__c = NO,
                        Expiration_Date_Time__c = System.today().addDays(ADD_DAYS),
                        Status__c = STATUS_ACTIVE,
                        Record_Creation_Status__c = STATUS_SUCCESS,
                        UUID__c = UUID
                    )
                }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SELECTOR.setMock(mxOnboardingLinksSelector);
        Test.startTest();
        Mx_Onboarding_Link__c mxOnboardingLinks = MxOnboardingCommunityController.getMxOnboardingLink(
            UUID
        );
        Test.stopTest();
        System.assertEquals(
            contractId,
            mxOnboardingLinks.Contract__c,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK
        );
        System.assertEquals(
            ONBOARDING_SCENARIO,
            mxOnboardingLinks.Onboarding_Scenario__c,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK
        );
        System.assertEquals(
            STATUS_ACTIVE,
            mxOnboardingLinks.Status__c,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK
        );
        System.assertEquals(
            STATUS_SUCCESS,
            mxOnboardingLinks.Record_Creation_Status__c,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK
        );
    }

    /**
     * @description To test Business Info and Store Detail records are created from MX form.
     */
    @isTest
    private static void testWhenSaveMxFormDetailsThenCreateDetailRecords() {
        String oiMainDataWrapperJSON = JSON.serialize(new List<OIMainDataWrapper>{});
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IEmailTemplateSelector emailTemplateSelectorMock = (IEmailTemplateSelector) mocks.mock(
            IEmailTemplateSelector.class
        );
        IOIDataService mockOIDataServicer = (IOIDataService) mocks.mock(IOIDataService.class);
        mocks.startStubbing();
        mocks.when(mockOIDataServicer.saveMXFormDetails(oiMainDataWrapperJSON, mxOnboardingLinkId))
            .thenReturn(true);
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IOIDataService.class, mockOIDataServicer);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SELECTOR.setMock(emailTemplateSelectorMock);
        Test.startTest();
        try {
            MxOnboardingCommunityController.submitMXForm(
                oiMainDataWrapperJSON,
                mxOnboardingLinkId,
                MOCK_EMAIL,
                FRENCH_LANGUAGE
            );
        } catch (Exception mockException) {
            System.assertEquals(
                EXCEPTION_MESSAGE,
                mockException.getMessage(),
                ASSERT_MESSAGE_EXCEPTION_MESSAGE
            );
        }
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }
}