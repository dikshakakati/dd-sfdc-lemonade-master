/**
 * @author Deloitte
 * @date 19/05/2022
 * @description Selector class for Work_Step_Status_Mapping__mdt custom metadata.
 */
public inherited sharing class WorkStepStatusMappingsSelector extends fflib_SObjectSelector implements IWorkStepStatusMappingsSelector {
    /**
     * @description Default constructor for the class.
     * @return IWorkStepStatusMappingsSelector - Returns interface of WorkStepStatusMappingsSelector
     */
    public static IWorkStepStatusMappingsSelector newInstance() {
        return (IWorkStepStatusMappingsSelector) Application.Selector.newInstance(
            Work_Step_Status_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting object type.
     * @return SObjectType - Returns object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Work_Step_Status_Mapping__mdt.SObjectType;
    }

    /**
     * @description It is for getting the fields of Work_Step_Status_Mapping__mdt.
     * @return List<Schema.SObjectField> - Work_Step_Status_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Work_Step_Status_Mapping__mdt.Sequence__c,
            Work_Step_Status_Mapping__mdt.Status__c,
            Work_Step_Status_Mapping__mdt.Operator__c,
            Work_Step_Status_Mapping__mdt.Status_To_Apply__c
        };
    }

    /**
     * @description It is for getting all records in ascending sequence for Work_Step_Status_Mapping__mdt.
     * Quering record to avoid default sorting order and there is no long text area field
     * hence will not be included in the usage calculation.
     * @JIRA# LEM-1273
     * @return List<Work_Step_Status_Mapping__mdt> - List of metadata records with values
     */
    public List<Work_Step_Status_Mapping__mdt> getAllValues() {
        fflib_QueryFactory query = newQueryFactory();
        query.addOrdering('Sequence__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Work_Step_Status_Mapping__mdt>) Database.query(query.toSOQL());
    }
}