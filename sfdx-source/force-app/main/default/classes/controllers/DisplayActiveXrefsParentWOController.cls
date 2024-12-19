/**
 * @author Deloitte
 * @date 07/05/2023
 * @description Controller class for DisplayActiveXrefsParentWOController LWC component.
 */
public with sharing class DisplayActiveXrefsParentWOController {
    private static final Map<String, String> FIELD_HYPERLINK_TO_MATCH = new Map<String, String>{
        'Salesforce_Account_Name__c' => 'accountNameHyperLink',
        'Business_Reference__c' => 'businessReferenceHyperlink',
        'Name' => 'xrefHyperLink'
    };
    private static final Map<String, String> FIELD_API_NAME_TO_FIELD_LABEL = new Map<String, String>{
        'External_ID__c' => 'External ID',
        'External_ID_Source__c' => 'External Source',
        'Integration_Status__c' => 'Integration Status',
        'Integration_Message__c' => 'Integration Message'
    };
    private static final Set<String> FIELD_TO_WRAP_TEXT = new Set<String>{
        'Salesforce Account Name'
    };
    private static final String XREF_FIELD_SET = 'Parent_WorkOrder_Xref_Related_List';
    private static final String XREF_OBJECT = 'Xref__c';
    private static final String TYPE_STRING = 'string';
    private static final String TYPE_URL = 'url';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';

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
        Boolean parentWoForDrive = false;
        Set<Id> accountIds = new Set<Id>();
        List<WorkOrder> childWorkOrders = new List<WorkOrder>(
            WorkOrdersSelector.newInstance().selectParentAndChildWOsByWorkOrderIds(recordId)
        );
        for (WorkOrder eachWorkOrder : childWorkOrders) {
            if (eachWorkOrder.AccountId == null) {
                continue;
            }
            if (eachWorkOrder.Type__c != WORK_ORDER_TYPE_DRIVE) {
                accountIds.add(eachWorkOrder.AccountId);
            } else if (eachWorkOrder.ParentWorkOrderId != null) {
                parentWoForDrive = true;
                accountIds.add(eachWorkOrder.AccountId);
            } else if (!parentWoForDrive) {
                accountIds.add(eachWorkOrder.AccountId);
            }
        }
        return (List<Xref__c>) Security.stripInaccessible(
                AccessType.READABLE,
                XrefsSelector.newInstance().selectActiveXrefsBySalesforceAccountName(accountIds)
            )
            .getRecords();
    }
}