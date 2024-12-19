/**
 * @description This is a test class created for DynamicColumnsController.
 * @author Deloitte
 * @date 29/04/2022
 */
@isTest(SeeAllData=false)
private class DynamicColumnsControllerTest {
    /**
     * @description Test when to retrive all fields for an object.
     */
    @isTest
    private static void testWhenRetrievingAllColumnsForGivenSObjectThenReturnAllFieldsAndTheirAttributesInJsonFormat() {
        String jsonData = DynamicColumnsController.getAllColumnsDetail('Account');
        List<DynamicColumn> gridColumnsWrapper = (List<DynamicColumn>) JSON.deserialize(
            jsonData,
            List<DynamicColumn>.class
        );
        Map<String, DynamicColumn> mapGridColumnsWrapper = new Map<String, DynamicColumn>();
        for (DynamicColumn wrapper : gridColumnsWrapper) {
            mapGridColumnsWrapper.put(wrapper.fieldName, wrapper);
        }
        System.assertEquals(
            'AccountSource',
            mapGridColumnsWrapper.get('AccountSource').fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'AccountSource',
            mapGridColumnsWrapper.get('AccountSource').apiName,
            'Unexpected Error:Api Name is not matching'
        );
        System.assertEquals(
            'picklist',
            mapGridColumnsWrapper.get('AccountSource').type,
            'Unexpected Error:type is not matching'
        );
        System.assertEquals(
            'Account Source',
            mapGridColumnsWrapper.get('AccountSource').label,
            'Unexpected Error:label is not matching'
        );
        System.assertEquals(
            null,
            mapGridColumnsWrapper.get('AccountSource').typeAttributes,
            'Unexpected Error:label is not matching'
        );
        System.assertEquals(
            'Account_ID18__c',
            mapGridColumnsWrapper.get('Account_ID18__c').fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'Account_ID18__c',
            mapGridColumnsWrapper.get('Account_ID18__c').apiName,
            'Unexpected Error:Api Name is not matching'
        );
        System.assertEquals(
            'string',
            mapGridColumnsWrapper.get('Account_ID18__c').type,
            'Unexpected Error:type is not matching'
        );
        System.assertEquals(
            'Account ID18',
            mapGridColumnsWrapper.get('Account_ID18__c').label,
            'Unexpected Error:label is not matching'
        );
        System.assertEquals(
            null,
            mapGridColumnsWrapper.get('Account_ID18__c').typeAttributes,
            'Unexpected Error:type attributes is not matching'
        );
        System.assertEquals(
            'Id',
            gridColumnsWrapper[0].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'Id',
            gridColumnsWrapper[0].apiName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'id',
            gridColumnsWrapper[0].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Account ID',
            gridColumnsWrapper[0].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            null,
            gridColumnsWrapper[0].sortable,
            'Unexpected Error: Field sort attribute is not matching'
        );
        System.assertEquals(
            null,
            gridColumnsWrapper[0].hideDefaultActions,
            'Unexpected Error: Field default action is not matching'
        );
        System.assertNotEquals(null, jsonData, 'Unexpected Error: jsonData is Null ');
    }

    /**
     * @description Test to retrieve default fields for an object.
     */
    @isTest
    private static void testWhenRetrievingDefaultColumnsForGivenSObjectThenReturnDefaultFieldsAndTheirAttributesInJsonFormat() {
        String jsonData = DynamicColumnsController.getDefaultFields(
            'Account',
            'Account_Hierarchy_Default_Fields'
        );
        List<DynamicColumn> gridColumnsWrapper = (List<DynamicColumn>) JSON.deserialize(
            jsonData,
            List<DynamicColumn>.class
        );
        System.assertEquals(
            'Name',
            gridColumnsWrapper[0].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'Name',
            gridColumnsWrapper[0].apiName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            gridColumnsWrapper[0].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Account Name',
            gridColumnsWrapper[0].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'AccountName',
            gridColumnsWrapper[0].typeAttributes.label.FieldName,
            'Unexpected Error: type Attributes is not matching'
        );
        System.assertEquals(
            'Type',
            gridColumnsWrapper[1].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'Type',
            gridColumnsWrapper[1].apiName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'picklist',
            gridColumnsWrapper[1].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            null,
            gridColumnsWrapper[1].typeAttributes,
            'Unexpected Error: type Attributes is not matching'
        );
        System.assertEquals(
            'Account Type',
            gridColumnsWrapper[1].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'RecordTypeId',
            gridColumnsWrapper[2].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'RecordType.Name',
            gridColumnsWrapper[2].apiName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'string',
            gridColumnsWrapper[2].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Record Type Name',
            gridColumnsWrapper[2].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'AccountRecordTypeId',
            gridColumnsWrapper[2].typeAttributes.label.fieldName,
            'Unexpected Error: type Attributes is not matching'
        );
        System.assertEquals(
            'Total_Number_Of_Stores__c',
            gridColumnsWrapper[6].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'Total_Number_Of_Stores__c',
            gridColumnsWrapper[6].apiName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            gridColumnsWrapper[6].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Total Number of Stores',
            gridColumnsWrapper[6].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'AccountTotal_Number_Of_Stores__c',
            gridColumnsWrapper[6].typeAttributes.label.fieldName,
            'Unexpected Error: type Attributes is not matching'
        );
    }

    /**
     * @description To test when there are no default columns configured.
     */
    @isTest
    private static void testWhenToGetNoDefaultColumnsThenReturnStringFormat() {
        String jsonData = DynamicColumnsController.getDefaultFields('Account', 'AccountColumns');
        System.assertEquals(null, jsonData, 'Unexpected Error: jsonData is Null ');
    }
}