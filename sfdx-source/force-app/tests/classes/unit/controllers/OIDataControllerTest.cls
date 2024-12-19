/**
 * @author Deloitte
 * @date 06/11/2024
 * @description Test class for OIDataController class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class OIDataControllerTest {
    private static final String ACTIVATED_CENTRALLY_API_NAME = 'Activated_Centrally_AC__c';
    private static final String ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String FRENCH_LANGUAGE = 'fr';
    private static final String NO = 'No';
    private static final String ONBOARDING_SCENARIO = 'Net-New';
    private static final String ONBOARDING_SCENARIO_PRODUCT_ADDITION = 'Product Addition';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_SUCCESS = 'Success';

    /**
     * @description To test Mx Onboarding Link record is returned using the passed Wrapper.
     */
    @isTest
    private static void testWhenSaveMxOnboardingLinkRecordThenReturnMxOnboardingLinkRecord() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String oiMainDataWrapperJSON;
        OIMainDataWrapper oiMainDataWrapperToPass = new OIMainDataWrapper(
            businessAccountId,
            contractId
        );
        oiMainDataWrapperToPass.onboardingScenario = ONBOARDING_SCENARIO;
        List<OIFieldWrapper> fieldWrappers = new List<OIFieldWrapper>{
            new OIFieldWrapper(ACTIVATED_CENTRALLY_API_NAME, ACTIVATED_CENTRALLY_YES, 'Picklist')
        };
        oiMainDataWrapperToPass.businessInfoWrappers = fieldWrappers;
        oiMainDataWrapperToPass.repCollectingOnMxBehalf = NO;
        oiMainDataWrapperJSON = JSON.serialize(oiMainDataWrapperToPass);
        Mx_Onboarding_Link__c mxOnboardingLink = new Mx_Onboarding_Link__c(
            Business_Account__c = businessAccountId,
            Contract__c = contractId,
            Onboarding_Scenario__c = ONBOARDING_SCENARIO,
            Rep_Collecting_On_Mx_Behalf__c = NO,
            Expiration_Date_Time__c = System.today().addDays(10),
            Status__c = STATUS_ACTIVE,
            Record_Creation_Status__c = STATUS_SUCCESS
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOIDataService oiDataService = (IOIDataService) mocks.mock(IOIDataService.class);
        mocks.startStubbing();
        mocks.when(oiDataService.saveMxOnboardingLinkRecord(oiMainDataWrapperJSON))
            .thenReturn(mxOnboardingLink);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IOIDataService.class, oiDataService);
        Test.startTest();
        OIDataController.saveMxOnboardingLinkRecord(oiMainDataWrapperJSON);
        Test.stopTest();
        ((IOIDataService) mocks.verify(oiDataService, 1))
            .saveMxOnboardingLinkRecord(oiMainDataWrapperJSON);
    }

    /**
     * @description To test Mx Onboarding Link record is returned using the passed contractId.
     */
    @isTest
    private static void testWhenGetActiveMxOnboardingLinkThenReturnMxOnboardingLinkRecord() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Mx_Onboarding_Link__c mxOnboardingLink = new Mx_Onboarding_Link__c(
            Business_Account__c = businessAccountId,
            Contract__c = contractId,
            Onboarding_Scenario__c = ONBOARDING_SCENARIO,
            Rep_Collecting_On_Mx_Behalf__c = NO,
            Expiration_Date_Time__c = System.today().addDays(10),
            Status__c = STATUS_ACTIVE,
            Record_Creation_Status__c = STATUS_SUCCESS
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOIDataService oiDataService = (IOIDataService) mocks.mock(IOIDataService.class);
        mocks.startStubbing();
        mocks.when(oiDataService.getActiveMxOnboardingLink(contractId))
            .thenReturn(mxOnboardingLink);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IOIDataService.class, oiDataService);
        Test.startTest();
        OIDataController.getActiveMxOnboardingLink(contractId);
        Test.stopTest();
        ((IOIDataService) mocks.verify(oiDataService, 1)).getActiveMxOnboardingLink(contractId);
    }

    /**
     * @description To test record is returned using the passed contractId.
     */
    @isTest
    private static void testWhenFetchContractDetailsThenReturnContractInfoWrapper() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);

        ContractInfoWrapper contractInfoWrapper = new ContractInfoWrapper();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOIDataService oiDataService = (IOIDataService) mocks.mock(IOIDataService.class);
        mocks.startStubbing();
        mocks.when(oiDataService.fetchContractDetails(contractId, ONBOARDING_SCENARIO))
            .thenReturn(contractInfoWrapper);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IOIDataService.class, oiDataService);
        Test.startTest();
        OIDataController.fetchContractDetails(contractId, ONBOARDING_SCENARIO);
        Test.stopTest();
        ((IOIDataService) mocks.verify(oiDataService, 1))
            .fetchContractDetails(contractId, ONBOARDING_SCENARIO);
    }

    /**
     * @description To test  record is returned using the passed List of productsOnContract.
     */
    @isTest
    private static void testWhenFetchOIMetadataRecordsThenReturnOISectionAttributeWrapper() {
        String productsOnContract = '';
        String onboardingScenario;
        String repCollectingOnMxBehalf;
        String formType;
        OISectionAttributeWrapper oISectionAttributeWrapper = new OISectionAttributeWrapper();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOIDataService oiDataService = (IOIDataService) mocks.mock(IOIDataService.class);
        mocks.startStubbing();
        mocks.when(
                oiDataService.fetchOIMetadataRecords(
                    productsOnContract,
                    onboardingScenario,
                    repCollectingOnMxBehalf,
                    formType
                )
            )
            .thenReturn(oISectionAttributeWrapper);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IOIDataService.class, oiDataService);
        Test.startTest();
        OIDataController.fetchOIMetadataRecords(
            productsOnContract,
            onboardingScenario,
            repCollectingOnMxBehalf,
            formType
        );
        Test.stopTest();
        ((IOIDataService) mocks.verify(oiDataService, 1))
            .fetchOIMetadataRecords(
                productsOnContract,
                onboardingScenario,
                repCollectingOnMxBehalf,
                formType
            );
    }

    /**
     * @description To test record is returned using the passed contractId.
     */
    @isTest
    private static void testWhenFetchOpportunityDetailsThenReturnOpportunityId() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOIDataService oiDataService = (IOIDataService) mocks.mock(IOIDataService.class);
        mocks.startStubbing();
        mocks.when(
                oiDataService.fetchOpportunityBasedOnOnboardingScenario(
                    contractId,
                    accountId,
                    ONBOARDING_SCENARIO_PRODUCT_ADDITION
                )
            )
            .thenReturn(opportunityId);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IOIDataService.class, oiDataService);
        Test.startTest();
        OIDataController.fetchOpportunityBasedOnOnboardingScenario(
            contractId,
            accountId,
            ONBOARDING_SCENARIO_PRODUCT_ADDITION
        );
        Test.stopTest();
        ((IOIDataService) mocks.verify(oiDataService, 1))
            .fetchOpportunityBasedOnOnboardingScenario(
                contractId,
                accountId,
                ONBOARDING_SCENARIO_PRODUCT_ADDITION
            );
    }

    /**
     * @description To test OI Metadata records are fetched for Mx Forms when controller method is called.
     */
    @isTest
    private static void testWhenControllerMethodCalledWithMxFormLanguageThenReturnOISectionAttributeWrapper() {
        String productsOnContract = '';
        String onboardingScenario;
        String repCollectingOnMxBehalf;
        String formType;
        OISectionAttributeWrapper oISectionAttributeWrapper = new OISectionAttributeWrapper();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOIDataService oiDataService = (IOIDataService) mocks.mock(IOIDataService.class);
        mocks.startStubbing();
        mocks.when(
                oiDataService.fetchOIMetadataRecords(
                    productsOnContract,
                    onboardingScenario,
                    repCollectingOnMxBehalf,
                    formType,
                    FRENCH_LANGUAGE
                )
            )
            .thenReturn(oISectionAttributeWrapper);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IOIDataService.class, oiDataService);
        Test.startTest();
        OIDataController.fetchOIMetadataRecordsMxForm(
            productsOnContract,
            onboardingScenario,
            repCollectingOnMxBehalf,
            formType,
            FRENCH_LANGUAGE
        );
        Test.stopTest();
        ((IOIDataService) mocks.verify(oiDataService, 1))
            .fetchOIMetadataRecords(
                productsOnContract,
                onboardingScenario,
                repCollectingOnMxBehalf,
                formType,
                FRENCH_LANGUAGE
            );
    }
}