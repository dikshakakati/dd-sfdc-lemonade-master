/**
 * @author DoorDash
 * @date 03/09/2023
 * @description Selector class for Bat_To_WorkSteps_Status_Mapping__mdt custom metadata.
 */
public inherited sharing class BatToWorkStepsStatusMappingSelector extends fflib_SObjectSelector implements IBatToWorkStepsStatusMappingSelector {
    /**
     * @description Default constructor for the class.
     * @return IBatToWorkStepsStatusMappingSelector - Returns interface of BatToWorkStepsStatusMappingSelector
     */
    public static IBatToWorkStepsStatusMappingSelector newInstance() {
        return (IBatToWorkStepsStatusMappingSelector) Application.Selector.newInstance(
            Bat_To_WorkSteps_Status_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting object type.
     * @return SObjectType - Returns object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Bat_To_WorkSteps_Status_Mapping__mdt.SObjectType;
    }

    /**
     * @description It is for getting the fields of Bat_To_WorkSteps_Status_Mapping__mdt.
     * @return List<Schema.SObjectField> - Bat_To_WorkSteps_Status_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Bat_To_WorkSteps_Status_Mapping__mdt.Bat_Status__c,
            Bat_To_WorkSteps_Status_Mapping__mdt.Exclusion_Code__c,
            Bat_To_WorkSteps_Status_Mapping__mdt.Work_Step_Status__c,
            Bat_To_WorkSteps_Status_Mapping__mdt.Work_Step_Type__c,
            Bat_To_WorkSteps_Status_Mapping__mdt.Status_Reason__c,
            Bat_To_WorkSteps_Status_Mapping__mdt.Work_Plan_Status__c
        };
    }

    /**
     * @description It is for getting all records in Bat_To_WorkSteps_Status_Mapping__mdt.
     * @return List<Bat_To_WorkSteps_Status_Mapping__mdt> - List of metadata records with values
     */
    public List<Bat_To_WorkSteps_Status_Mapping__mdt> getAllValues() {
    	return Bat_To_WorkSteps_Status_Mapping__mdt.getall().values();
    }
}