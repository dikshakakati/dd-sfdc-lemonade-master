/**
 * @author Deloitte
 * @date 29/04/2022
 * @description Selector class for Stores_List_View_Configuration__mdt custom metadata.
 */
public inherited sharing class StoresListViewConfigurationsSelector extends fflib_SObjectSelector implements IStoresListViewConfigurationsSelector {
    private static final String TYPE_ALL = '%All%';
    /**
     * @description default constructor for the class.
     * @return IStoresListViewConfigurationsSelector - interface of IStoresListViewConfigurationsSelector
     */
    public static IStoresListViewConfigurationsSelector newInstance() {
        return (IStoresListViewConfigurationsSelector) Application.Selector.newInstance(
            Stores_List_View_Configuration__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting Object type.
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Stores_List_View_Configuration__mdt.SObjectType;
    }

    /**
     * @description It is for getting the fields on Stores_List_View_Configuration__mdt.
     * @return List<Schema.SObjectField>- Stores_List_View_Configuration__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Stores_List_View_Configuration__mdt.Applicable_Account_Record_Type__c,
            Stores_List_View_Configuration__mdt.DeveloperName,
            Stores_List_View_Configuration__mdt.FieldSet_Name__c,
            Stores_List_View_Configuration__mdt.Is_Active__c,
            Stores_List_View_Configuration__mdt.Object_Name__c,
            Stores_List_View_Configuration__mdt.Section_Name__c,
            Stores_List_View_Configuration__mdt.Section_Sequence__c,
            Stores_List_View_Configuration__mdt.Show_Section_Header__c,
            Stores_List_View_Configuration__mdt.Type__c,
            Stores_List_View_Configuration__mdt.Types_To_Exclude__c
        };
    }

    /**
     * @description It is for getting all field values on basis of Work Plan type
     * and Account record type for Stores_List_View_Configuration__mdt.
     * Salesforce truncates 255 charaters for long text area hence quering records.
     * Suppressed warnings since typeMatcher variable is used to set the condition of dynamic SOQL.
     * @JIRA# LEM-1158 and LEM-2516
     * @param type - Type of WorkPlan
     * @param accountRecordType - Account record type
     * @return List<Stores_List_View_Configuration__mdt> - List of metadata records with values
     */
    @SuppressWarnings('PMD.UnusedLocalVariable')
    public List<Stores_List_View_Configuration__mdt> selectByWorkPlanTypeAndAccountRecordType(
        String type,
        String accountRecordType
    ) {
        String typeMatcher = '%' + type + '%';
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Is_Active__c = true AND ' +
                '(Type__c LIKE :typeMatcher OR Type__c LIKE :TYPE_ALL) AND ' +
                'Applicable_Account_Record_Type__c = :accountRecordType'
            )
            .setOrdering('Section_Sequence__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Stores_List_View_Configuration__mdt>) Database.query(query.toSOQL());
    }
}