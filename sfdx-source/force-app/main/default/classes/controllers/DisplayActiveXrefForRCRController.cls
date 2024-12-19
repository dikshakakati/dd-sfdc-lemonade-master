/**
 * @author Deloitte
 * @date 26/09/2023
 * @description Controller class for DisplayActiveXrefForRCRController LWC component.
 */

public class DisplayActiveXrefForRCRController {
    private static final Map<String, String> FIELD_HYPERLINK_TO_MATCH = new Map<String, String>{
        'Salesforce_Account_Name__c' => 'accountNameHyperLink',
        'Business_Reference__c' => 'businessReferenceHyperlink',
        'Name' => 'xrefHyperLink'
    };
    private static final Map<String, String> FIELD_API_NAME_TO_FIELD_LABEL = new Map<String, String>{
        'External_ID__c' => 'External ID',
        'External_ID_Source__c' => 'External Source',
        'Integration_Status__c' => 'Integration Status',
        'BusinessID__c' => 'Business ID'
    };
    private static final Set<String> FIELD_TO_WRAP_TEXT = new Set<String>{
        'Salesforce Account Name'
    };
    private static final String XREF_FIELD_SET = 'Xref_Rate_Change_Field_Set';
    private static final String XREF_OBJECT = 'Xref__c';
    private static final String TYPE_STRING = 'string';
    private static final String TYPE_URL = 'url';
    /**
     * @description This method is used to get fields.
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String getFields() {
        Schema.FieldSet fieldSetObj = Schema.getGlobalDescribe()
            .get(XREF_OBJECT)
            .getDescribe()
            .FieldSets.getMap()
            .get(XREF_FIELD_SET);
        // Return if no field set found
        if (fieldSetObj == null) {
            return null;
        }

        List<Schema.FieldSetMember> fieldSetMembers = fieldSetObj.getFields();
        List<DynamicColumn> columns = new List<DynamicColumn>();

        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            String fieldName = fieldSetMember.getFieldPath();
            DynamicColumn columnData = new DynamicColumn();
            if (FIELD_HYPERLINK_TO_MATCH.get(fieldName) != null) {
                columnData = addLookupFields(
                    FIELD_HYPERLINK_TO_MATCH.get(fieldName),
                    fieldSetMember.getLabel(),
                    fieldSetMember.getFieldPath()
                );
                columns.add(columnData);
                continue;
            } else {
                columnData.type = TYPE_STRING;
                columnData.fieldName = fieldName;
                columnData.label = FIELD_API_NAME_TO_FIELD_LABEL.get(fieldName);
                columnData.hideDefaultActions = true;
                columns.add(columnData);
            }
        }
        return JSON.serialize(columns);
    }

    /**
     * @description  This method is used to set all lookupfields for work order field set
     * @param hyperlink
     * @param fieldLabel
     * @param fieldName
     * @return DynamicColumn
     */
    private static DynamicColumn addLookupFields(
        String hyperlink,
        String fieldLabel,
        String fieldName
    ) {
        DynamicColumn columnData = new DynamicColumn();
        columnData.type = TYPE_URL;
        columnData.fieldName = hyperlink;
        columnData.label = fieldLabel;
        columnData.hideDefaultActions = true;
        DynamicColumn.TypeAttributes typeAttribute = new DynamicColumn.TypeAttributes();
        DynamicColumn.Label labelName = new DynamicColumn.Label();
        labelName.fieldName = fieldName;
        typeAttribute.label = labelName;
        if (FIELD_TO_WRAP_TEXT.contains(fieldLabel)) {
            columnData.wrapText = true;
        }
        columnData.typeAttributes = typeAttribute;
        return columnData;
    }
    /**
     * @description To get selected xref details
     * @param recordId
     * @return List<Xref__c>
     */

    @AuraEnabled(cacheable=true)
    public static List<Xref__c> getXrefDetails(Id recordId) {
        return (List<Xref__c>) Security.stripInaccessible(
                AccessType.READABLE,
                XrefsSelector.newInstance().selectRelatedRateChangeIds(new Set<Id>{ recordId })
            )
            .getRecords();
    }
}