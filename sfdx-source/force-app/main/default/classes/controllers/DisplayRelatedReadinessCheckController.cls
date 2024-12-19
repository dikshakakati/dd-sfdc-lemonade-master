/**
* @author Deloitte
* @date 26 June 2024
* @description Controller class for DisplayRelatedReadinessCheckController LWC component
*/
public class DisplayRelatedReadinessCheckController {
    private static final String READINESS_CHECK_OBJECT = 'Readiness_Check_Failure__c';
    private static final String TYPE_STRING = 'string';
    private static final String READINESS_CHECK_FIELD_SET = 'Readiness_Check_Field_Set';
    private static final String ACCOUNT_NAME = 'Account_Name__c';
    private static final String OBJECT_NAME ='Object_Link__c';
    private static final String FIX_ERROR_LINK ='Fix_Error_Link__c';
    private static final String TYPE_URL = 'url';
    private static final String ACCOUNT_NAME_HYPERLINK = 'accountNameHyperlink';
    private static final String OBJECT_NAME_HYPERLINK = 'objectNameHyperlink';
    private static final String FIX_ERROR_LINK_HYPERLINK = 'fixErrorLinkHyperlink';
    private static final String COLUMNS_TO_DISPLAY_STATIC_CONFIG = 'RelatedReadinessCheckColumnsViewOrder';
    private static final String COMMA_SEPARATOR = ',';
    private static final Map<String, String> FIELD_API_NAME_TO_FIELD_LABEL = new Map<String, String>{'Account_Name__c' => 'Account Name','Object_Link__c' => 'Object Name','Fix_Error_Link__c' => 'Fix Error Link'};
    private enum FieldNames {ACCOUNT_NAME,OBJECT_NAME,FIX_ERROR_LINK}
    private static final Map<String, FieldNames> FIELDNAMES_TO_FIELDNAMEENUMVALUES = new Map<String, FieldNames>{ACCOUNT_NAME => FieldNames.ACCOUNT_NAME,OBJECT_NAME => FieldNames.OBJECT_NAME,FIX_ERROR_LINK => FieldNames.FIX_ERROR_LINK};


    /**
    * @description It is used to set up the Columns for the Lightining Datatable using
    * the fields from field set.
    * @JIRA# LEM-16419
    * @return String
    */
    @AuraEnabled(cacheable=true)
    public static String getFields() {
        Schema.FieldSet readinessCheckFieldSet = ((SObject)Type.forName(READINESS_CHECK_OBJECT).newInstance())
            .getSObjectType()
            .getDescribe()
            .getSObjectType()
            .getDescribe()
            .FieldSets.getMap()
            .get(READINESS_CHECK_FIELD_SET);
        // Return if no field set found
        if (readinessCheckFieldSet == null) {
            return null;
        }
        String columnsToDisplay = StaticConfigurationsSelector.newInstance().getInstanceValue(COLUMNS_TO_DISPLAY_STATIC_CONFIG).Configuration_Value__c;
        Map<String, DynamicColumn> fieldLabelToColumnData = new Map<String, DynamicColumn>();
        // Iterate over field set members
        for (Schema.FieldSetMember fieldSetMember : readinessCheckFieldSet.getFields()) {
            DynamicColumn columnData = new DynamicColumn();
            String fieldApiName = fieldSetMember.getFieldPath();
            switch on FIELDNAMES_TO_FIELDNAMEENUMVALUES.get(fieldApiName) {
                when ACCOUNT_NAME {
                    columnData = getUrlColumns(ACCOUNT_NAME_HYPERLINK, fieldApiName);
                }
                when OBJECT_NAME {
                    columnData = getUrlColumns(OBJECT_NAME_HYPERLINK, fieldApiName);
                }
                when FIX_ERROR_LINK {
                    columnData = getUrlColumns(FIX_ERROR_LINK_HYPERLINK, fieldApiName);
                }
                //for text column
                when else {
                    columnData = new DynamicColumn();
                    columnData.type = TYPE_STRING;
                    columnData.fieldName = fieldApiName;
                    columnData.label = fieldSetMember.getLabel();
                }
            }
            columnData.wrapText = true;
            fieldLabelToColumnData.put(columnData.label, columnData);
        }
        return JSON.serialize(getColumnsByDisplayOrder(fieldLabelToColumnData, columnsToDisplay));
    }


    /**
    * @description It is used to get the readiness check failure record details.
    * @JIRA# LEM-16419
    * @param recordId
    * @return List<Readiness_Check_Failure__c>
    */
    @AuraEnabled(cacheable=true)
    public static List<Readiness_Check_Failure__c> getReadinessCheckFailureDetails(Id recordId) {
        List<Readiness_Check_Failure__c> readinessCheckFailureDetails = ReadinessCheckFailuresSelector.newInstance()
            .selectByParentWorkOrderIds(new Set<Id>{ recordId });
        return readinessCheckFailureDetails;
    }

    /**
    * @description It is used to get updated readiness check failure record details.
    * @JIRA# LEM-16419
    * @param recordId
    * @return List<Readiness_Check_Failure__c>
    */
    @AuraEnabled
    public static List<Readiness_Check_Failure__c> getReadinessCheckFailureUpdatedDetails(Id recordId) {
        List<Readiness_Check_Failure__c> readinessCheckFailureDetails = ReadinessCheckFailuresSelector.newInstance()
            .selectByParentWorkOrderIds(new Set<Id>{ recordId });
        return readinessCheckFailureDetails;
    }


    /**
    * @description  This method is used set up the 'url' type columns in Lightining Datatable.
    * @JIRA# LEM-16419
    * @param hyperlink
    * @param fieldName
    * @return DynamicColumn
    */
    private static DynamicColumn getUrlColumns(String hyperlink, String fieldName) {
        DynamicColumn columnData = new DynamicColumn();
        columnData.type = TYPE_URL;
        columnData.fieldName = hyperlink;
        columnData.label = FIELD_API_NAME_TO_FIELD_LABEL.get(fieldName);
        columnData.hideDefaultActions = true;
        DynamicColumn.TypeAttributes typeAttribute = new DynamicColumn.TypeAttributes();
        DynamicColumn.Label labelName = new DynamicColumn.Label();
        labelName.fieldName = fieldName;
        typeAttribute.label = labelName;
        columnData.typeAttributes = typeAttribute;
        return columnData;
    }

    /**
    * @description It is used to get the passed columns in the order
    * for displaying in the related list.
    * @JIRA# LEM-16419
    * @param columns
    * @param columnsToDisplay
    * @return List<DynamicColumn>
    */
    private static List<DynamicColumn> getColumnsByDisplayOrder(Map<String, DynamicColumn> columns,String columnsToDisplay) {
        List<DynamicColumn> dynamicColumnsToDisplay = new List<DynamicColumn>();
        if (columns.isEmpty() || String.isBlank(columnsToDisplay)) {
            return dynamicColumnsToDisplay;
        }
        for (String eachColumnToDisplay : (List<String>) columnsToDisplay.split(COMMA_SEPARATOR)) {
            if (columns.containsKey(eachColumnToDisplay)) {
                dynamicColumnsToDisplay.add(columns.get(eachColumnToDisplay));
            }
        }
        return dynamicColumnsToDisplay;
    }
}