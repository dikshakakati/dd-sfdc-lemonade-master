/**
 * @author Deloitte
 * @date 04/16/2023
 * @description Controller class to display Briefs related list.
 */
public with sharing class DisplayBriefsController {
    private static final String BRIEF_FIELD_SET = 'Brief_Related_List_Fields';
    private static final String BRIEF_NAME = 'Name';
    private static final String BRIEF_NAME_HYPERLINK = 'briefNameHyperlink';
    private static final String BRIEF_OBJECT = 'Brief__c';
    private static final String TYPE_STRING = 'string';
    private static final String TYPE_URL = 'url';

    /**
     * @description It is used to get Brief object's fields from fieldset.
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String getFields() {
        Schema.FieldSet fieldSet = Schema.getGlobalDescribe()
            .get(BRIEF_OBJECT)
            .getDescribe()
            .FieldSets.getMap()
            .get(BRIEF_FIELD_SET);
        // Return if no field set found
        if (fieldSet == null) {
            return null;
        }
        // Store all field set member fields
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        List<DynamicColumn> columns = new List<DynamicColumn>();
        String fieldName;
        // Iterate over field set members
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            fieldName = fieldSetMember.getFieldPath();
            DynamicColumn columnData = new DynamicColumn();
            if (fieldName == BRIEF_NAME) {
                columnData = addLookupFields(
                    BRIEF_NAME_HYPERLINK,
                    fieldSetMember.getLabel(),
                    fieldSetMember.getFieldPath()
                );
            } else {
                columnData = new DynamicColumn();
                columnData.type = TYPE_STRING;
                columnData.fieldName = fieldName;
                columnData.label = fieldSetMember.getLabel();
                columnData.hideDefaultActions = true;
            }
            columns.add(columnData);
        }
        return JSON.serialize(columns);
    }

    /**
     * @description  It is used to set all lookup fields for Brief field set.
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
        columnData.typeAttributes = typeAttribute;
        return columnData;
    }

    /**
     * @description It is used to get all Briefs associated by the object with passed recordId.
     * @param recordId
     * @return List<Brief__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<Brief__c> getBriefDetails(Id recordId) {
        if (recordId.getSObjectType() == Opportunity.SObjectType) {
            return getBriefDetailsFromOpportunity(recordId);
        } else {
            throw new AuraHandledException(
                'Unsupported object type for recordId: ' + String.valueOf(recordId.getSObjectType())
            );
        }
    }

    /**
     * @description This method is used to get all Briefs related to Opportunities by Quote Brief
     * Relationship
     * @param opportunityId
     * @return List<Brief__c>
     */
    public static List<Brief__c> getBriefDetailsFromOpportunity(Id opportunityId) {
        return (List<Brief__c>) Security.stripInaccessible(
                AccessType.READABLE,
                removeDuplicates(
                    BriefsSelector.newInstance().selectByOpportunities(new Set<Id>{ opportunityId })
                )
            )
            .getRecords();
    }

    /**
     * @description This method is used to retrieve only unique Brief records.
     * @param allBriefs
     * @return List<Brief__c>
     */
    private static List<Brief__c> removeDuplicates(List<Brief__c> allBriefs) {
        return new Map<Id, Brief__c>(allBriefs).values();
    }
}