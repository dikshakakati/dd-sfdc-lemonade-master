/**
 * @author Deloitte
 * @date 10/16/2023
 * @description Test class for StatusReasonAndDetailsMappingsSelector class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class StatusReasonAndDetailsMappingsSelectTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: there is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: the object type must be Nintex To Work Order Mapping custom metadata';
    private static final String ASSERT_MESSAGE_NO_STATUS_REASON_MAPPINGS_RETURNED = 'Unexpected result: selector call failed to return all Status Reason to Detail Mappings';

    /**
     * @description To test standard methods in StatusReasonAndDetailsMappingsSelector.
     */
    @isTest
    private static void testWhenStandardSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Status_Reason_And_Details_Mapping__mdt.Business_Friendly_Mapping__c,
            Status_Reason_And_Details_Mapping__mdt.MasterLabel,
            Status_Reason_And_Details_Mapping__mdt.DeveloperName,
            Status_Reason_And_Details_Mapping__mdt.Status__c,
            Status_Reason_And_Details_Mapping__mdt.Status_Reason__c,
            Status_Reason_And_Details_Mapping__mdt.Type__c,
            Status_Reason_And_Details_Mapping__mdt.Quick_Action_Name__c
        };
        StatusReasonAndDetailsMappingsSelector statusReasonAndDetailsMappings = new StatusReasonAndDetailsMappingsSelector();
        Schema.SObjectType typeOfObject = statusReasonAndDetailsMappings.SObjectType();
        List<Schema.SObjectField> sObjectFields = statusReasonAndDetailsMappings.getSObjectFieldList();
        System.assertEquals(
            typeOfObject,
            Status_Reason_And_Details_Mapping__mdt.SObjectType,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            sObjectFields,
            sObjectFieldsMock,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test selection of all Status Reason And Detail Mappings.
     */
    @isTest
    private static void testWhenGetAllMappingsCalledThenAllCustomMetadataRecordsReturned() {
        Id businessFriendlyMappingId = fflib_IDGenerator.generate(
            Business_Friendly_Mapping__mdt.SObjectType
        );

        Status_Reason_And_Details_Mapping__mdt statusReasonAndDetailsMappings = (Status_Reason_And_Details_Mapping__mdt) new Fake(
                Status_Reason_And_Details_Mapping__mdt.class
            )
            .setField(Status_Reason_And_Details_Mapping__mdt.Status__c, 'Blocked')
            .setField(Status_Reason_And_Details_Mapping__mdt.Status_Reason__c, 'Invalid Address')
            .setField(Status_Reason_And_Details_Mapping__mdt.Type__c, 'Setup Store')
            .setField(
                Status_Reason_And_Details_Mapping__mdt.Business_Friendly_Mapping__c,
                businessFriendlyMappingId
            )
            .setParent(
                'Business_Friendly_Mapping__r',
                new Fake(Business_Friendly_Mapping__mdt.class)
                    .setField(Business_Friendly_Mapping__mdt.id, businessFriendlyMappingId)
                    .setField(
                        Business_Friendly_Mapping__mdt.Integration_Key_String__c,
                        'required key [accountCurrency] not found'
                    )
                    .setField(
                        Business_Friendly_Mapping__mdt.Integration_Type__c,
                        'Xref Provisioning'
                    )
                    .setField(
                        Business_Friendly_Mapping__mdt.Message_Category__c,
                        'Missing Data - Currency'
                    )
                    .setField(Business_Friendly_Mapping__mdt.Order__c, 40)
                    .setField(Business_Friendly_Mapping__mdt.Active__c, true)
            )
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        StatusReasonAndDetailsMappingsSelector mockStatusReasonAndDetailsMappingsSelector = (StatusReasonAndDetailsMappingsSelector) mocks.mock(
            StatusReasonAndDetailsMappingsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStatusReasonAndDetailsMappingsSelector.sObjectType())
            .thenReturn(Status_Reason_And_Details_Mapping__mdt.SObjectType);
        mocks.when(mockStatusReasonAndDetailsMappingsSelector.getAllMappings())
            .thenReturn(
                new List<Status_Reason_And_Details_Mapping__mdt>{ statusReasonAndDetailsMappings }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStatusReasonAndDetailsMappingsSelector);
        List<Status_Reason_And_Details_Mapping__mdt> queryResult = StatusReasonAndDetailsMappingsSelector.newInstance()
            .getAllMappings();
        System.assertEquals(
            'Blocked',
            queryResult[0].Status__c,
            ASSERT_MESSAGE_NO_STATUS_REASON_MAPPINGS_RETURNED
        );
        System.assertEquals(
            'Invalid Address',
            queryResult[0].Status_Reason__c,
            ASSERT_MESSAGE_NO_STATUS_REASON_MAPPINGS_RETURNED
        );
    }
}