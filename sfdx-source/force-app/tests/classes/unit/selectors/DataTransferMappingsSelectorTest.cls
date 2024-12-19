/**
 * @author DoorDash
 * @date 30-August-2023
 * @description Test class for the Selector class for the Data_Transfer_Mapping__mdt custom metadata object.
**/
@IsTest
private class DataTransferMappingsSelectorTest {

    @IsTest
    private static void testWhenClassInstantiatesThenCall() {
        // Test instantiation and selector methods
        DataTransferMappingsSelector selectorInstance = new DataTransferMappingsSelector();
        Schema.SObjectType typeOfObj = selectorInstance.getSObjectType();

        // Assertions
        System.assertEquals(Schema.Data_Transfer_Mapping__mdt.SObjectType, typeOfObj, 'The object type must match Data_Transfer_Mapping__mdt');

        List<Schema.SObjectField> fieldList = selectorInstance.getSObjectFieldList();

        // Assertions
        System.assertEquals(
            new List<Schema.SObjectField>{
                Data_Transfer_Mapping__mdt.MasterLabel,
                Data_Transfer_Mapping__mdt.Field_API_Name__c,
                Data_Transfer_Mapping__mdt.Is_Required__c,
                Data_Transfer_Mapping__mdt.Field_Data_Type__c,
                Data_Transfer_Mapping__mdt.Field_Label__c,
                Data_Transfer_Mapping__mdt.Object_API_Name__c,
                Data_Transfer_Mapping__mdt.Active__c
            },
            fieldList,
            'Mismatch in field list'
        );
    }

    @IsTest
    private static void testWhenCallingGetAllValuesThenRetrieveAllMetadata() {
        List<Data_Transfer_Mapping__mdt> result = DataTransferMappingsSelector.newInstance().getAllValues();

        System.assertNotEquals(null, result, 'Should not return null');
        System.assert(!result.isEmpty(), 'Should return at least one record');
    }

    @IsTest
    private static void testWhenCallingGetAllActiveValuesThenRetrieveActiveMetadata() {
        List<Data_Transfer_Mapping__mdt> activeValues = DataTransferMappingsSelector.newInstance().getAllActiveValues();

        for(Data_Transfer_Mapping__mdt thisValue : activeValues) {
            System.assert(thisValue.Active__c, 'All DTM records should be active');
        }

        System.assertNotEquals(null, activeValues, 'should not return null');
    }
}