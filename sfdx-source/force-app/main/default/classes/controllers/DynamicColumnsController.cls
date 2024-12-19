/**
 * @author Deloitte
 * @date 27/04/2022
 * @description Controller class for DynamicColumns LWC component.
 */

public with sharing class DynamicColumnsController {
    static final String REFERENCE = 'REFERENCE';
    static final String TYPEDOUBLE = 'DOUBLE';
    static final String TYPENUMBER = 'number';
    static final String NAME = 'Name';
    static final String RECORDTYPEID = 'RecordTypeID';
    static final String TYPESTRING = 'string';
    static final String URL = 'url';
    static final String ID = 'ID';
    static final String TOTAL_NUMBER_OF_STORES = 'Total_Number_Of_Stores__c';

    /**
     * @description This method used to get all fields for object passed.
     * @param objectApiName
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String getAllColumnsDetail(String objectApiName) {
        Schema.SObjectType loadSchema = Schema.getGlobalDescribe().get(objectApiName);
        Map<String, Schema.SObjectField> fieldMap = loadSchema.getDescribe().fields.getMap();
        List<Schema.SObjectField> lookUpFields = new List<Schema.SObjectField>();
        List<DynamicColumn> gridColumns = new List<DynamicColumn>();

        // Iterate over all fields and store in gridColumns wrapper
        for (Schema.SObjectField fieldName : fieldMap.values()) {
            Schema.DescribeFieldResult fieldResult = fieldName.getDescribe();
            if (!fieldResult.isAccessible()) {
                continue;
            }

            DynamicColumn columnData = new DynamicColumn();
            String fieldType = String.valueOf(fieldResult.getType());
            // Store lookup fields
            if (
                fieldType == REFERENCE ||
                fieldResult.getName() == NAME ||
                fieldResult.getName() == TOTAL_NUMBER_OF_STORES
            ) {
                lookUpFields.add(fieldName);
                continue;
            }
            columnData.type = fieldType == TYPEDOUBLE ? TYPENUMBER : fieldType.toLowercase();
            columnData.fieldName = fieldResult.getName();
            columnData.value = fieldResult.getName();
            columnData.apiName = fieldResult.getName();
            columnData.label = fieldResult.getLabel();
            gridColumns.add(columnData);
        }
        addLookupFields(gridColumns, objectApiName, lookUpFields);

        return JSON.serialize(gridColumns);
    }

    /**
     * @description This method is used to get default fields using metadata name passed.
     * @param objectName
     * @param fieldSetName
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String getDefaultFields(String objectName, String fieldSetName) {
        List<DynamicColumn> gridColumns = new List<DynamicColumn>();

        Schema.SObjectType sObjectTypeObj = Schema.getGlobalDescribe().get(objectName);
        Schema.FieldSet fieldSetObj = sObjectTypeObj.getDescribe()
            .FieldSets.getMap()
            .get(fieldSetName);

        // Return if no field set found
        if (fieldSetObj == null) {
            return null;
        }

        // Store all field set member fields
        List<Schema.FieldSetMember> fieldSetMembers = fieldSetObj.getFields();
        // Store all fields map for sobject
        Map<String, Schema.SObjectField> allFieldsMap = sObjectTypeObj.getDescribe()
            .fields.getMap();
        List<Schema.SObjectField> lookUpFields = new List<Schema.SObjectField>();

        // Iterate over field set members
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            DynamicColumn columnData = new DynamicColumn();

            String fieldType = String.valueOf(fieldSetMember.getType());
            // Store lookup fields
            if (
                fieldType == REFERENCE ||
                fieldSetMember.getFieldPath() == NAME ||
                fieldSetMember.getFieldPath() == TOTAL_NUMBER_OF_STORES
            ) {
                lookUpFields.add(allFieldsMap.get(fieldSetMember.getFieldPath()));
                continue;
            }

            columnData.type = fieldType == TYPEDOUBLE ? TYPENUMBER : fieldType.toLowercase();
            columnData.fieldName = fieldSetMember.getFieldPath();
            columnData.value = fieldSetMember.getFieldPath();
            columnData.apiName = fieldSetMember.getFieldPath();
            columnData.label = fieldSetMember.getLabel();
            gridColumns.add(columnData);
        }

        // To iterate over lookup fields
        addLookupFields(gridColumns, objectName, lookUpFields);

        return orderDefaultFields(gridColumns, fieldSetMembers, allFieldsMap);
    }

    /**
     * @description This method used to order default fields
     * @param gridColumns
     * @param fieldSetMembers
     * @param allFieldsMap
     * @return
     */
    private static String orderDefaultFields(
        List<DynamicColumn> gridColumns,
        List<Schema.FieldSetMember> fieldSetMembers,
        Map<String, Schema.SObjectField> allFieldsMap
    ) {
        Map<String, DynamicColumn> gridColumnsMap = new Map<String, DynamicColumn>();
        List<DynamicColumn> orderedColumns = new List<DynamicColumn>();

        // Create map of DynamicColumn
        for (DynamicColumn column : gridColumns) {
            gridColumnsMap.put(column.fieldName, column);
        }

        // Iterate over fieldSetMembers to order default fields and check accessibility
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            String key = String.valueOf(fieldSetMember.getFieldPath());
            if (
                gridColumnsMap.containsKey(key) &&
                allFieldsMap.get(fieldSetMember.getFieldPath()).getDescribe().isAccessible()
            ) {
                orderedColumns.add(gridColumnsMap.get(key));
            }
        }
        return JSON.serialize(orderedColumns);
    }

    /**
     * @description This method used to set all lookupfields for DynamicColumn
     * @param gridColumns
     * @param objectApiName
     * @param lookUpFields
     */
    private static void addLookupFields(
        List<DynamicColumn> gridColumns,
        String objectApiName,
        List<Schema.SObjectField> lookUpFields
    ) {
        for (Schema.SObjectField lookupField : lookUpFields) {
            DynamicColumn columnData = new DynamicColumn();
            Schema.DescribeFieldResult fieldResult = lookupField.getDescribe();
            columnData.label = fieldResult.getLabel().replace(ID, NAME);
            columnData.fieldName = fieldResult.getName();
            columnData.value = fieldResult.getName();
            columnData.apiName = fieldResult.getRelationshipName() == null
                ? fieldResult.getName()
                : fieldResult.getRelationshipName() + '.' + NAME;
            columnData.type = columnData.fieldName == RECORDTYPEID ? TYPESTRING : URL;
            DynamicColumn.Label labelName = new DynamicColumn.Label();
            labelName.fieldName = objectApiName + fieldResult.getName();
            DynamicColumn.TypeAttributes typeAttribute = new DynamicColumn.TypeAttributes();
            typeAttribute.label = labelName;

            columnData.typeAttributes = typeAttribute;
            gridColumns.add(columnData);
        }
    }
}