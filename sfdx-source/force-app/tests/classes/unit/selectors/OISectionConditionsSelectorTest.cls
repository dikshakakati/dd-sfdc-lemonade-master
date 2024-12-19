/**
 * @author Deloitte
 * @date 06/10/2024
 * @description Test class for OISectionConditionsSelector class.
 */
@isTest(SeeAllData=false)
private class OISectionConditionsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be OISectionCondition metadata.';
    private static final String CUSTOM_METADATA_DEV_NAME = 'Section_Condition';
    private static final String CUSTOM_METADATA_ONBOARDING_SCENERIO = 'Net-New';
    private static final String CUSTOM_METADATA_ORDER_PROTOCOL = 'Tablet';
    private static final Integer CUSTOM_METADATA_ORDER = 1;
    private static final String CUSTOM_METADATA_PRODUCT_ON_CONTRACT = 'Marketplace';
    private static final String CUSTOM_METADATA_REP_FILLING_ON_MX_BEHALF = 'Yes';
    private static final String CUSTOM_METADATA_SECTION = 'ABC';
    private static final String METADATA_FORM_TYPE = 'SALES FORM';
    private static final String ONBOARDING_SCENERIO = 'Net-New';
    private static final String REP_FILLING_ON_MX_BEHALF = 'Yes';

    /**
     * @description To test OISectionConditions custom metadata query
     */
    @isTest
    private static void testWhenFetchOIMetadataRecordsThenReturnListOISectionConditionsRecord() {
        List<OISectionCondition__mdt> customMetadataMocks = new List<OISectionCondition__mdt>{
            new OISectionCondition__mdt(
                Alcohol__c = true,
                DeveloperName = CUSTOM_METADATA_DEV_NAME,
                Form_Type__c = METADATA_FORM_TYPE,
                Is_it_Store_Section__c = true,
                Onboarding_Scenario__c = CUSTOM_METADATA_ONBOARDING_SCENERIO,
                Order__c = CUSTOM_METADATA_ORDER,
                Order_Protocol__c = CUSTOM_METADATA_ORDER_PROTOCOL,
                Products_on_Contract__c = CUSTOM_METADATA_PRODUCT_ON_CONTRACT,
                Rep_Filling_on_Mx_Behalf__c = CUSTOM_METADATA_REP_FILLING_ON_MX_BEHALF,
                Seattle__c = true,
                Section__c = CUSTOM_METADATA_SECTION
            )
        };
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            OISectionCondition__mdt.Alcohol__c,
            OISectionCondition__mdt.DeveloperName,
            OISectionCondition__mdt.Form_Type__c,
            OISectionCondition__mdt.Is_it_Store_Section__c,
            OISectionCondition__mdt.Onboarding_Scenario__c,
            OISectionCondition__mdt.Order_Protocol__c,
            OISectionCondition__mdt.Products_on_Contract__c,
            OISectionCondition__mdt.Rep_Filling_on_Mx_Behalf__c,
            OISectionCondition__mdt.Seattle__c,
            OISectionCondition__mdt.Section__c,
            OISectionCondition__mdt.Payment_Method__c,
            OISectionCondition__mdt.Store_Section_For_No_Rep_Scenario__c
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OISectionConditionsSelector mockOISectionConditionsSelector = (OISectionConditionsSelector) mocks.mock(
            OISectionConditionsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOISectionConditionsSelector.getSObjectType())
            .thenReturn(OISectionCondition__mdt.SObjectType);
        mocks.when(
                mockOISectionConditionsSelector.fetchOIMetadataRecords(
                    CUSTOM_METADATA_PRODUCT_ON_CONTRACT,
                    ONBOARDING_SCENERIO,
                    REP_FILLING_ON_MX_BEHALF,
                    METADATA_FORM_TYPE
                )
            )
            .thenReturn(customMetadataMocks);
        mocks.when(mockOISectionConditionsSelector.getSObjectFieldList())
            .thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOISectionConditionsSelector);
        Schema.SObjectType typeOfObject = OISectionConditionsSelector.newInstance().SObjectType();
        List<Schema.SObjectField> sObjectFields = OISectionConditionsSelector.newInstance()
            .getSObjectFieldList();
        Test.startTest();
        OISectionConditionsSelector.newInstance()
            .fetchOIMetadataRecords(
                CUSTOM_METADATA_PRODUCT_ON_CONTRACT,
                ONBOARDING_SCENERIO,
                REP_FILLING_ON_MX_BEHALF,
                METADATA_FORM_TYPE
            );
        Test.stopTest();
        System.assertEquals(
            OISectionCondition__mdt.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }
}