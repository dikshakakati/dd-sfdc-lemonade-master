/**
 * @author Deloitte
 * @date 03/15/2023
 * @description Controller class for DisplayActiveXref LWC component.
 */

public with sharing class DisplayActiveXrefController {
    private static final String XREF_OBJECT = 'Xref__c';
    private static final String XREF_FIELD_SET = 'Store_Account_Related_List_Fields';
    private static final String TYPE_STRING = 'string';
    private static final String TYPE_URL = 'url';
    private static final String MINT_STORE_FIELD_NAME = 'MINT_Store_Page__c';
    private static final String MX_PORTAL_FIELD_NAME = 'Merchant_Portal__c';
    private static final String SMB_XREF_FIELD_SET = 'Visualizing_SMB_Store_Xref_Fields';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String MINT_BUSINESS_PAGE_FIELD_NAME = 'Mint_BusinessPage__c';
    private static final String BUSINESS_REFERENCE_FIELD_NAME = 'Business_Reference__c';
    private static final String MINT_STORE_HYPERLINK = 'mintStorePageHyperlink';
    private static final String MX_PORTAL_HYPERLINK = 'merchantPortalHyperlink';
    private static final String MINT_BUSINESS_PAGE_HYPERLINK = 'mintBusinessPageHyperlink';
    private static final String BUSINESS_REFERENCE_HYPERLINK = 'businessReferenceHyperlink';
    private static final String ONLINE_ORDERING_STORE_HYPERLINK = 'onlineOrderingStorePageHyperlink';
    private static final String ONLINE_ORDERING_STORE_FIELD_NAME = 'Online_Ordering_Store_Page__c';
    private static final String ONLINE_ORDERING_BUSINESS_HYPERLINK = 'onlineOrderingBusinessPageHyperlink';
    private static final String ONLINE_ORDERING_BUSINESS_FIELD_NAME = 'Online_Ordering_Business_Page__c';
    private static final Map<String, String> FIELD_API_NAME_TO_FIELD_LABEL = new Map<String, String>{
        'MINT_Store_Page__c' => 'MINT',
        'Merchant_Portal__c' => 'Mx Portal',
        'BusinessID__c' => 'BizID',
        'Business_GroupID__c' => 'BGID',
        'Mint_BusinessPage__c' => 'MINT BizID',
        'External_ID_Source__c' => 'Source',
        'Account_Type__c' => 'Type',
        'Online_Ordering_Business_Page__c' => 'Biz OO Tool',
        'Online_Ordering_Store_Page__c' => 'Store OO Tool',
        'Business_Reference__c' => 'Business Reference'
    };

    /**
     * @description This method is used to get fields.
     * @param segment
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String getFields(String segment) {
        Schema.FieldSet fieldSetObj;
        if (segment == SEGMENT_SMB) {
            fieldSetObj = Schema.getGlobalDescribe()
                .get(XREF_OBJECT)
                .getDescribe()
                .FieldSets.getMap()
                .get(SMB_XREF_FIELD_SET);
        } else {
            fieldSetObj = Schema.getGlobalDescribe()
                .get(XREF_OBJECT)
                .getDescribe()
                .FieldSets.getMap()
                .get(XREF_FIELD_SET);
        }
        // Return if no field set found
        if (fieldSetObj == null) {
            return null;
        }

        // Store all field set member fields
        List<Schema.FieldSetMember> fieldSetMembers = fieldSetObj.getFields();
        List<DynamicColumn> columns = new List<DynamicColumn>();

        addColumns(columns,fieldSetMembers);
        return JSON.serialize(columns);
    }

    /**
     * @description  This method is used to dynamically add columns based on the fieldSetMembers
     * @param columns
     * @param fieldSetMembers
     */
    public static void addColumns(List<DynamicColumn> columns,List<Schema.FieldSetMember> fieldSetMembers)
    {
        // Iterate over field set members
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            String fieldName = fieldSetMember.getFieldPath();
            DynamicColumn columnData = new DynamicColumn();
            if (fieldName == MINT_STORE_FIELD_NAME) {
                columnData = addLookupFields(MINT_STORE_HYPERLINK, fieldName);
                columns.add(columnData);
                continue;
            } else if (fieldName == MX_PORTAL_FIELD_NAME) {
                columnData = addLookupFields(MX_PORTAL_HYPERLINK, fieldName);
                columns.add(columnData);
                continue;
            } else if (fieldName == MINT_BUSINESS_PAGE_FIELD_NAME) {
                columnData = addLookupFields(MINT_BUSINESS_PAGE_HYPERLINK, fieldName);
                columns.add(columnData);
                continue;
            } else if (fieldName == BUSINESS_REFERENCE_FIELD_NAME) {
                columnData = addLookupFields(BUSINESS_REFERENCE_HYPERLINK, fieldName);
                columns.add(columnData);
                continue;
            } else if (fieldName == ONLINE_ORDERING_STORE_FIELD_NAME) {
                columnData = addLookupFields(ONLINE_ORDERING_STORE_HYPERLINK, fieldName);
                columns.add(columnData);
                continue;
            } else if (fieldName == ONLINE_ORDERING_BUSINESS_FIELD_NAME) {
                columnData = addLookupFields(ONLINE_ORDERING_BUSINESS_HYPERLINK, fieldName);
                columns.add(columnData);
                continue;
            } else {
                columnData = new DynamicColumn();
                columnData.type = TYPE_STRING;
                columnData.fieldName = fieldName;
                columnData.label = FIELD_API_NAME_TO_FIELD_LABEL.get(fieldName);
                columnData.hideDefaultActions = true;
                columns.add(columnData);
            }
        }
    }

    /**
     * @description  This method is used to set all lookupfields for work order field set
     * @param hyperlink
     * @param fieldName
     * @return DynamicColumn
     */
    private static DynamicColumn addLookupFields(String hyperlink, String fieldName) {
        DynamicColumn columnData = new DynamicColumn();
        columnData.type = TYPE_URL;
        columnData.fieldName = hyperlink;
        columnData.label = columnData.label = FIELD_API_NAME_TO_FIELD_LABEL.get(fieldName);
        columnData.hideDefaultActions = true;
        DynamicColumn.TypeAttributes typeAttribute = new DynamicColumn.TypeAttributes();
        DynamicColumn.Label labelName = new DynamicColumn.Label();
        labelName.fieldName = fieldName;
        typeAttribute.label = labelName;
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
                XrefsSelector.newInstance().selectActiveXrefsByAccountId(recordId)
            )
            .getRecords();
    }
}
