/**
 * @author Deloitte
 * @date 05/08/2024
 * @description Test class for CrossObjectStatusMappingsSelector class.
 */
@isTest(SeeAllData=false)
private class CrossObjectStatusMappingsSelectorTest {
    private static final String ASSERT_MESSAGE_OBJECT_MISMATCH = 'Unexpected Error: The object type must be Country Attributes Mapping Metadata';
    private static final String ASSERT_MESSAGE_FIELD_MISMATCH = 'Unexpected Error: Mismatch in field list';
    private static final String ASSERT_MESSAGE_COUNT_MISMATCH = 'Unexpected Error : Mismatch in count of records';
    private static final String DRAFT = 'Draft';
    private static final String NOT_STARTED = 'Not Started';
    private static final String PROCESS = 'Mx Order Status to WorkStep Status';
    private static final String TABLET = 'Tablet';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        CrossObjectStatusMappingsSelector selectorInstance = (CrossObjectStatusMappingsSelector) CrossObjectStatusMappingsSelector.newInstance();
        Schema.SObjectType typeOfObject = selectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = selectorInstance.getSObjectFieldList();
        System.assertEquals(
            Cross_Object_Status_Mapping__mdt.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_OBJECT_MISMATCH
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Cross_Object_Status_Mapping__mdt.Target_Status__c,
                Cross_Object_Status_Mapping__mdt.Source_Status__c,
                Cross_Object_Status_Mapping__mdt.Process__c,
                Cross_Object_Status_Mapping__mdt.Active__c,
                Cross_Object_Status_Mapping__mdt.Type__c
            },
            sObjectFields,
            ASSERT_MESSAGE_FIELD_MISMATCH
        );
    }

    /**
     * @description To test if the Cross Object Status Mapping records related to the passed
     * process name are returned.
     */
    @isTest
    private static void testWhenOrderProcessNamePassedThenReturnOrderStatusToWorkStepStatusMappings() {
        List<Cross_Object_Status_Mapping__mdt> customMetadataMocks = new List<Cross_Object_Status_Mapping__mdt>{
            (Cross_Object_Status_Mapping__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createCrossObjectStatusMappingFakeInstance(
                    DRAFT,
                    NOT_STARTED,
                    true,
                    PROCESS,
                    TABLET
                )
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CrossObjectStatusMappingsSelector mockSelector = (CrossObjectStatusMappingsSelector) mocks.mock(
            CrossObjectStatusMappingsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType())
            .thenReturn(Cross_Object_Status_Mapping__mdt.SObjectType);
        mocks.when(mockSelector.selectActiveStatusMappingsByProcessName(PROCESS))
            .thenReturn(customMetadataMocks);
        Application.SELECTOR.setMock(mockSelector);
        Test.startTest();
        List<Cross_Object_Status_Mapping__mdt> crossObjectMappingRecords = CrossObjectStatusMappingsSelector.newInstance()
            .selectActiveStatusMappingsByProcessName(PROCESS);
        Test.stopTest();
        System.assertEquals(
            true,
            !crossObjectMappingRecords.isEmpty(),
            ASSERT_MESSAGE_COUNT_MISMATCH
        );
    }
}