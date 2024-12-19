/**
 * @author Deloitte
 * @date 02/05/2022
 * @description Test class for StoresListViewConfigurationsSelector class.
 */
@isTest(seeAllData=false)
private class StoresListViewConfigurationsSelectorTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Store List View Configuartions custom metadata.';
    private static final String CUSTOM_METADATA_DEV_NAME = 'Account_Details_All';
    private static final String CUSTOM_METADATA_FIELD_SET_NAME = 'Account_Details_All';
    private static final String CUSTOM_METADATA_MASTER_LABEL = 'Account_Details_All';
    private static final String CUSTOM_METADATA_OBJECT_NAME = 'Account';
    private static final String CUSTOM_METADATA_SECTION_NAME = 'Account Details';
    private static final Integer CUSTOM_METADATA_SEQUENCE = 1;
    private static final String CUSTOM_METADATA_TYPE_TO_EXCLUDED = '';
    private static final String CUSTOM_METADATA_WORK_PLAN_TYPE = 'All';
    private static final String CUSTOM_METADATA_WORK_PLAN_TYPE_DRIVE = 'Drive';
    private static final String WORK_PLAN_TYPE = 'Onboarding';
    private static final String WORK_PLAN_TYPE_DRIVE = 'Drive';

    /**
     * @description To test Store List View Configurations custom metadata query
     * when Work Plan Type and "Business" Account record type are received.
     */
    @isTest
    private static void testWhenSelectByTypeWithBusinessAccountRecordTypeCalledThenReturnAppropriateValues() {
        List<Stores_List_View_Configuration__mdt> customMetadataMocks = new List<Stores_List_View_Configuration__mdt>{
            new Stores_List_View_Configuration__mdt(
                DeveloperName = CUSTOM_METADATA_DEV_NAME,
                FieldSet_Name__c = CUSTOM_METADATA_FIELD_SET_NAME,
                Is_Active__c = true,
                MasterLabel = CUSTOM_METADATA_MASTER_LABEL,
                Object_Name__c = CUSTOM_METADATA_OBJECT_NAME,
                Section_Name__c = CUSTOM_METADATA_SECTION_NAME,
                Section_Sequence__c = CUSTOM_METADATA_SEQUENCE,
                Type__c = CUSTOM_METADATA_WORK_PLAN_TYPE_DRIVE,
                Types_To_Exclude__c = CUSTOM_METADATA_TYPE_TO_EXCLUDED
            )
        };
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Stores_List_View_Configuration__mdt.Applicable_Account_Record_Type__c,
            Stores_List_View_Configuration__mdt.DeveloperName,
            Stores_List_View_Configuration__mdt.FieldSet_Name__c,
            Stores_List_View_Configuration__mdt.Is_Active__c,
            Stores_List_View_Configuration__mdt.Object_Name__c,
            Stores_List_View_Configuration__mdt.Section_Name__c,
            Stores_List_View_Configuration__mdt.Section_Sequence__c,
            Stores_List_View_Configuration__mdt.Show_Section_Header__c,
            Stores_List_View_Configuration__mdt.Type__c,
            Stores_List_View_Configuration__mdt.Types_To_Exclude__c
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        StoresListViewConfigurationsSelector mockStoreListViewConfiguration = (StoresListViewConfigurationsSelector) mocks.mock(
            StoresListViewConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStoreListViewConfiguration.getSObjectType())
            .thenReturn(Stores_List_View_Configuration__mdt.SObjectType);
        mocks.when(
                mockStoreListViewConfiguration.selectByWorkPlanTypeAndAccountRecordType(
                    WORK_PLAN_TYPE_DRIVE,
                    ACCOUNT_RECORD_TYPE_NAME_BUSINESS
                )
            )
            .thenReturn(customMetadataMocks);
        mocks.when(mockStoreListViewConfiguration.getSObjectFieldList())
            .thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStoreListViewConfiguration);
        Schema.SObjectType typeOfObject = StoresListViewConfigurationsSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> sObjectFields = StoresListViewConfigurationsSelector.newInstance()
            .getSObjectFieldList();
        List<Stores_List_View_Configuration__mdt> onboardingDetailsConfigurations = StoresListViewConfigurationsSelector.newInstance()
            .selectByWorkPlanTypeAndAccountRecordType(
                WORK_PLAN_TYPE_DRIVE,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            );
        System.assertEquals(
            Stores_List_View_Configuration__mdt.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            !onboardingDetailsConfigurations.isEmpty(),
            true,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test Store List View Configurations custom metadata query
     * when Work Plan Type and "Store" Account record type are received.
     */
    @isTest
    private static void testWhenSelectByTypeWithStoreAccountRecordTypeCalledThenReturnAppropriateValues() {
        List<Stores_List_View_Configuration__mdt> customMetadataMocks = new List<Stores_List_View_Configuration__mdt>{
            new Stores_List_View_Configuration__mdt(
                DeveloperName = CUSTOM_METADATA_DEV_NAME,
                FieldSet_Name__c = CUSTOM_METADATA_FIELD_SET_NAME,
                Is_Active__c = true,
                MasterLabel = CUSTOM_METADATA_MASTER_LABEL,
                Object_Name__c = CUSTOM_METADATA_OBJECT_NAME,
                Section_Name__c = CUSTOM_METADATA_SECTION_NAME,
                Section_Sequence__c = CUSTOM_METADATA_SEQUENCE,
                Type__c = CUSTOM_METADATA_WORK_PLAN_TYPE,
                Types_To_Exclude__c = CUSTOM_METADATA_TYPE_TO_EXCLUDED
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        StoresListViewConfigurationsSelector mockStoreListViewConfiguration = (StoresListViewConfigurationsSelector) mocks.mock(
            StoresListViewConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStoreListViewConfiguration.getSObjectType())
            .thenReturn(Stores_List_View_Configuration__mdt.SObjectType);
        mocks.when(
                mockStoreListViewConfiguration.selectByWorkPlanTypeAndAccountRecordType(
                    WORK_PLAN_TYPE,
                    ACCOUNT_RECORD_TYPE_NAME_BUSINESS
                )
            )
            .thenReturn(customMetadataMocks);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStoreListViewConfiguration);
        List<Stores_List_View_Configuration__mdt> onboardingDetailsConfigurations = StoresListViewConfigurationsSelector.newInstance()
            .selectByWorkPlanTypeAndAccountRecordType(
                WORK_PLAN_TYPE,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            );
        System.assertEquals(
            !onboardingDetailsConfigurations.isEmpty(),
            true,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
    }
}