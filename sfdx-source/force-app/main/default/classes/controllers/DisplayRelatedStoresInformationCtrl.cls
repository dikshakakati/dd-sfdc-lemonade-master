/**
 * @author Deloitte
 * @date 12/12/2023
 * @description Controller class for displayRelatedStoresInformation LWC component
 */
public with sharing class DisplayRelatedStoresInformationCtrl {
    private static final String ACCOUNT_FIELD_SET = 'Store_Account_Information';
    private static final String ACCOUNT_NAME = 'Name';
    private static final String ACCOUNT_NAME_HYPERLINK = 'accountNameHyperlink';
    private static final String ACCOUNT_OBJECT = 'Account';
    private static final Map<String, String> FIELD_API_NAME_TO_FIELD_LABEL = new Map<String, String>{
        'MINT_Store_Page__c' => 'Store ID',
        'Mint_BusinessPage__c' => 'Business ID',
        'Name' => 'Account Name',
        'POS_Integration_ID__c' => 'Location ID',
        'POS_Page__c' => 'POS Page'
    };
    private static final String COLUMNS_TO_DISPLAY_STATIC_CONFIG = 'RelatedStoresInformationColumnsViewOrder';
    private static final String COMMA_SEPARATOR = ',';
    private static final Schema.Fieldset FIELDS_TO_QUERY = SObjectType.Account.FieldSets.Store_Account_Information;
    private static final String MINT_BUSINESS_PAGE_FIELD_NAME = 'Mint_BusinessPage__c';
    private static final String MINT_BUSINESS_PAGE_HYPERLINK = 'mintBusinessPageHyperlink';
    private static final String MINT_STORE_FIELD_NAME = 'MINT_Store_Page__c';
    private static final String MINT_STORE_HYPERLINK = 'mintStorePageHyperlink';
    private static final String POS_PAGE_FIELD_NAME = 'POS_Page__c';
    private static final String POS_PAGE_HYPERLINK = 'posPageHyperlink';
    private static final String SUBMARKET_HYPERLINK = 'subMarketHyperlink';
    private static final String TYPE_STRING = 'string';
    private static final String TYPE_URL = 'url';
    private static final String XREF_FIELD_SET = 'Xref_Store_Information';
    private static final String XREF_OBJECT = 'Xref__c';
    private enum FieldNames {
        ACCOUNT_NAME,
        MINT_STORE_FIELD_NAME,
        MINT_BUSINESS_PAGE_FIELD_NAME,
        POS_PAGE_FIELD_NAME
    }
    private static final Map<String, FieldNames> FIELDNAMES_TO_FIELDNAMEENUMVALUES = new Map<String, FieldNames>{
        ACCOUNT_NAME => FieldNames.ACCOUNT_NAME,
        MINT_STORE_FIELD_NAME => FieldNames.MINT_STORE_FIELD_NAME,
        MINT_BUSINESS_PAGE_FIELD_NAME => FieldNames.MINT_BUSINESS_PAGE_FIELD_NAME,
        POS_PAGE_FIELD_NAME => FieldNames.POS_PAGE_FIELD_NAME
    };

    /**
     * @description It is used to set up the Columns for the Lightining Datatable using
     * the fields from field set.
     * @JIRA# LEM-11509
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String getFields() {
        Schema.FieldSet accountFieldSet = ((SObject) Type.forName(ACCOUNT_OBJECT).newInstance())
            .getSObjectType()
            .getDescribe()
            .getSObjectType()
            .getDescribe()
            .FieldSets.getMap()
            .get(ACCOUNT_FIELD_SET);
        Schema.FieldSet xrefFieldSet = ((SObject) Type.forName(XREF_OBJECT).newInstance())
            .getSObjectType()
            .getDescribe()
            .getSObjectType()
            .getDescribe()
            .FieldSets.getMap()
            .get(XREF_FIELD_SET);
        String columnsToDisplay = StaticConfigurationsSelector.newInstance()
            .getInstanceValue(COLUMNS_TO_DISPLAY_STATIC_CONFIG)
            .Configuration_Value__c;
        // Return if no field set found
        if (accountFieldSet == null || xrefFieldSet == null) {
            return null;
        }
        Map<String, DynamicColumn> fieldLabelToColumnData = new Map<String, DynamicColumn>();
        String fieldApiName;
        // Iterate over field set members
        for (Schema.FieldSetMember fieldSetMember : accountFieldSet.getFields()) {
            DynamicColumn columnData = new DynamicColumn();
            fieldApiName = fieldSetMember.getFieldPath();
            switch on FIELDNAMES_TO_FIELDNAMEENUMVALUES.get(fieldApiName) {
                when ACCOUNT_NAME {
                    columnData = getUrlColumns(ACCOUNT_NAME_HYPERLINK, fieldApiName);
                }
                when else {
                    columnData = new DynamicColumn();
                    columnData.type = TYPE_STRING;
                    columnData.fieldName = fieldApiName;
                    columnData.label = FIELD_API_NAME_TO_FIELD_LABEL.containsKey(fieldApiName)
                        ? FIELD_API_NAME_TO_FIELD_LABEL.get(fieldApiName)
                        : fieldSetMember.getLabel();
                }
            }
            columnData.wrapText = true;
            fieldLabelToColumnData.put(columnData.label, columnData);
        }
        for (Schema.FieldSetMember fieldSetMember : xrefFieldSet.getFields()) {
            DynamicColumn columnData = new DynamicColumn();
            switch on FIELDNAMES_TO_FIELDNAMEENUMVALUES.get(fieldSetMember.getFieldPath()) {
                when MINT_STORE_FIELD_NAME {
                    columnData = getUrlColumns(MINT_STORE_HYPERLINK, fieldSetMember.getFieldPath());
                }
                when MINT_BUSINESS_PAGE_FIELD_NAME {
                    columnData = getUrlColumns(
                        MINT_BUSINESS_PAGE_HYPERLINK,
                        fieldSetMember.getFieldPath()
                    );
                }
                when POS_PAGE_FIELD_NAME {
                    columnData = getUrlColumns(POS_PAGE_HYPERLINK, fieldSetMember.getFieldPath());
                }
                when else {
                    columnData = new DynamicColumn();
                    columnData.type = TYPE_STRING;
                    columnData.fieldName = fieldSetMember.getFieldPath();
                    columnData.label = fieldSetMember.getLabel();
                    columnData.hideDefaultActions = true;
                }
            }
            columnData.wrapText = true;
            fieldLabelToColumnData.put(columnData.label, columnData);
        }
        return JSON.serialize(getColumnsByDisplayOrder(fieldLabelToColumnData, columnsToDisplay));
    }

    /**
     * @description It is used to get the Store Accounts Details.
     * @JIRA# LEM-11509
     * @param recordId
     * @return List<Account>
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountDetails(Id recordId) {
        List<Account> accountDetails = AccountsSelector.newInstance()
            .selectRelatedStoreAccountsInformation(FIELDS_TO_QUERY, new Set<Id>{ recordId });
        return accountDetails;
    }

    /**
     * @description  This method is used set up the 'url' type columns in Lightining Datatable.
     * @JIRA# LEM-11509
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
     * @JIRA# LEM-12132
     * @param columns
     * @param columnsToDisplay
     * @return List<DynamicColumn>
     */
    private static List<DynamicColumn> getColumnsByDisplayOrder(
        Map<String, DynamicColumn> columns,
        String columnsToDisplay
    ) {
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