/**
 * @author Deloitte
 * @date 06/10/2024
 * @description Test class for OISectionConditionsSelector class.
 */
@isTest(SeeAllData=false)
private class OIAttributesConfigsSelectorTest {
     private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
     private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Store List View Configuartions custom metadata.';
     private static final String CUSTOM_METADATA_DEV_NAME = 'Attribute_Config';
     private static final Integer CUSTOM_ATTRIBUTE_ORDER = 1;

    /**
     * @description To test OISectionConditions custom metadata query
     */
    @isTest
    private static void testWhenGetSObjectFieldListThenReturnSObjectFieldList() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            OIAttributesConfig__mdt.Attribute_HelpText__c,
            OIAttributesConfig__mdt.Attribute_Order__c,
            OIAttributesConfig__mdt.Auto_Applied_To_All_Store__c,
            OIAttributesConfig__mdt.DeveloperName,
            OIAttributesConfig__mdt.Is_PrePopulated__c,
            OIAttributesConfig__mdt.Is_Required__c,
            OIAttributesConfig__mdt.OIAttribute__c,
            OIAttributesConfig__mdt.OIAttributesValidation__c,
            OIAttributesConfig__mdt.OISectionCondition__c
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OIAttributesConfigsSelector mockOIAttributesConfigsSelector = (OIAttributesConfigsSelector) mocks.mock(
            OIAttributesConfigsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOIAttributesConfigsSelector.getSObjectType())
            .thenReturn(OIAttributesConfig__mdt.SObjectType);
        mocks.when(mockOIAttributesConfigsSelector.getSObjectFieldList())
            .thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOIAttributesConfigsSelector);
        Schema.SObjectType typeOfObject = OIAttributesConfigsSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> sObjectFields = OIAttributesConfigsSelector.newInstance()
            .getSObjectFieldList();
        System.assertEquals(
            OIAttributesConfig__mdt.SObjectType,
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