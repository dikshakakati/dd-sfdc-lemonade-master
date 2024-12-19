/**
 * @author Deloitte
 * @date 16/05/2022
 * @description Controller class for DisplayUniqueXref LWC component.
 */

public with sharing class DisplayUniqueXrefController {
    private static final String XREF_OBJECT = 'Xref__c';
    private static final String XREF_FIELD_SET = 'Visualizing_Xref_Fields';
    private static final String SMB_XREF_FIELD_SET = 'Visualizing_SMB_Business_Xref_Fields';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String TYPE_STRING = 'string';
    private static final String TYPE_URL = 'url';
    private static final String BUSINESS_REFERENCE_FIELD_NAME = 'Business_Reference__c';
    private static final String BUSINESS_REFERENCE_HYPERLINK = 'businessReferenceHyperlink';
    private static final String MX_REFERENCE_HYPERLINK = 'mxReferenceHyperlink';
    private static final String MX_PORTAL_FIELD_NAME = 'Mint_Business_Portal_Page__c';
    private static final String MX_PORTAL_HYPERLINK = 'merchantPortalHyperlink';
    private static final String MINT_BUSINESS_PAGE_FIELD_NAME = 'Mint_BusinessPage__c';
    private static final String MINT_BUSINESS_PAGE_FIELD_HYPERLINK = 'merchantBusinessPageHyperlink';
    private static final String MX_PORTAL_FIELD_LABEL = 'Mx Portal';
    private static final String ONLINE_ORDERING_BUSINESS_FIELD_LABEL = 'Biz OO Tool';
    private static final String ONLINE_ORDERING_BUSINESS_HYPERLINK = 'onlineOrderingBusinessPageHyperlink';
    private static final String ONLINE_ORDERING_BUSINESS_PAGE = 'Online_Ordering_Business_Page__c';

    private static final Map<String, String> FIELD_API_NAME_TO_FIELD_LABEL = new Map<String, String>{
        'Business_GroupID__c' => 'BGID',
        'External_ID_Source__c' => 'Source',
        'Business_Name__c' => 'BizName',
        'Account_Type__c' => 'Type'
    };
    private static final String MINT_BUSINESS_PAGE_FIELD_LABEL = 'MINT';
    private static final String BUSINESS_REFERENCE_FIELD_LABEL = 'Business Reference';

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
        /* if Business Id column selected in field set then it will set two columns
         *  1. MINT Business Page - if MINT Business Page link is available then it will show the link.
         *  2. Business Id - It will show the Business Id.
         */
        // Iterate over field set members
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            String fieldName = fieldSetMember.getFieldPath();
            if (fieldName == MINT_BUSINESS_PAGE_FIELD_NAME) {
                DynamicColumn columnData = new DynamicColumn();
                columnData.type = TYPE_URL;
                columnData.fieldName = MINT_BUSINESS_PAGE_FIELD_HYPERLINK;
                columnData.label = MINT_BUSINESS_PAGE_FIELD_LABEL;
                columnData.hideDefaultActions = true;
                DynamicColumn.TypeAttributes typeAttribute = new DynamicColumn.TypeAttributes();
                DynamicColumn.Label labelName = new DynamicColumn.Label();
                labelName.fieldName = fieldName;
                typeAttribute.label = labelName;
                columnData.typeAttributes = typeAttribute;
                columns.add(columnData);
                continue;
            } else if (fieldName == BUSINESS_REFERENCE_FIELD_NAME) {
                DynamicColumn columnData = new DynamicColumn();
                columnData.type = TYPE_URL;
                columnData.fieldName = BUSINESS_REFERENCE_HYPERLINK;
                columnData.label = BUSINESS_REFERENCE_FIELD_LABEL;
                columnData.hideDefaultActions = true;
                DynamicColumn.TypeAttributes typeAttribute = new DynamicColumn.TypeAttributes();
                DynamicColumn.Label labelName = new DynamicColumn.Label();
                labelName.fieldName = fieldName;
                typeAttribute.label = labelName;
                columnData.typeAttributes = typeAttribute;
                columns.add(columnData);
                continue;
            } else if (fieldName == MX_PORTAL_FIELD_NAME) {
                DynamicColumn columnData = new DynamicColumn();
                columnData.type = TYPE_URL;
                columnData.fieldName = MX_PORTAL_HYPERLINK;
                columnData.label = MX_PORTAL_FIELD_LABEL;
                columnData.hideDefaultActions = true;
                DynamicColumn.TypeAttributes typeAttribute = new DynamicColumn.TypeAttributes();
                DynamicColumn.Label labelName = new DynamicColumn.Label();
                labelName.fieldName = fieldName;
                typeAttribute.label = labelName;
                columnData.typeAttributes = typeAttribute;
                columns.add(columnData);
                continue;
            }else if (fieldName == ONLINE_ORDERING_BUSINESS_PAGE) {
                DynamicColumn columnData = new DynamicColumn();
                columnData.type = TYPE_URL;
                columnData.fieldName = ONLINE_ORDERING_BUSINESS_HYPERLINK;
                columnData.label = ONLINE_ORDERING_BUSINESS_FIELD_LABEL;
                columnData.hideDefaultActions = true;
                DynamicColumn.TypeAttributes typeAttribute = new DynamicColumn.TypeAttributes();
                DynamicColumn.Label labelName = new DynamicColumn.Label();
                labelName.fieldName = fieldName;
                typeAttribute.label = labelName;
                columnData.typeAttributes = typeAttribute;
                columns.add(columnData);
                continue;
            }
            DynamicColumn columnData = new DynamicColumn();
            columnData.type = TYPE_STRING;
            columnData.fieldName = fieldName;
            columnData.label = FIELD_API_NAME_TO_FIELD_LABEL.get(fieldName);
            columnData.hideDefaultActions = true;
            columns.add(columnData);
        }

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
                duplicateRemover(XrefsSelector.newInstance().selectAllInAccountHierarchy(recordId))
            )
            .getRecords();
    }

    /**
     * @description This method will retrive unique xref records.
     * @param xrefs
     * @return List<Xref__c>
     */
    private static List<Xref__c> duplicateRemover(List<Xref__c> xrefs) {
        Map<String, Xref__c> keyToXrefRecord = new Map<String, Xref__c>();
        for (Xref__c xref : xrefs) {
            String key =
                String.valueOf(xref.Business_GroupID__c) + String.valueOf(xref.BusinessID__c);
            Boolean isUniqueXref =
                (xref.Business_GroupID__c != null || xref.BusinessID__c != null) &&
                (!keyToXrefRecord.containsKey(key));
            if (isUniqueXref) {
                keyToXrefRecord.put(key, xref);
            }
        }
        return keyToXrefRecord.values();
    }
}