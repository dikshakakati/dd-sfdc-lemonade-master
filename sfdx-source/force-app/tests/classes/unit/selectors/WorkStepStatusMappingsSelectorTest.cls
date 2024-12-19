/**
 * @author Deloitte
 * @date 19/05/2022
 * @description Test class for WorkStepStatusMappingsSelector class.
 */
@isTest(seeAllData=false)
private class WorkStepStatusMappingsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Work Step Status Mapping Metadata.';
    private static final String METADATA_DEV_NAME = 'Complete';
    private static final String METADATA_MASTER_LABEL = 'Complete';
    private static final String METADATA_OPERATOR = 'equals';
    private static final Integer METADATA_SEQUENCE = 1;
    private static final String METADATA_STATUS_TO_APPLY = 'In Progress';
    private static final String METADATA_STATUS = 'Complete';

    /**
     * @description To test Work Step Status Mappings custom metadata fields.
     */
    @isTest
    private static void testWhenGetSObjectFieldListMethodCalledThenReturnFields() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Work_Step_Status_Mapping__mdt.Sequence__c,
            Work_Step_Status_Mapping__mdt.Status__c,
            Work_Step_Status_Mapping__mdt.Operator__c,
            Work_Step_Status_Mapping__mdt.Status_To_Apply__c
        };
        Schema.SObjectType typeOfObject = WorkStepStatusMappingsSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> sObjectFields = WorkStepStatusMappingsSelector.newInstance()
            .getSObjectFieldList();
        System.assertEquals(
            Work_Step_Status_Mapping__mdt.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test Work Step Status Mappings custom metadata query.
     */
    @isTest
    private static void testWhenGetAllValuesMethodCalledThenReturnAllMetadataRecords() {
        List<Work_Step_Status_Mapping__mdt> statusMappings = WorkStepStatusMappingsSelector.newInstance()
            .getAllValues();
        System.assertEquals(
            !statusMappings.isEmpty(),
            true,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
    }
}