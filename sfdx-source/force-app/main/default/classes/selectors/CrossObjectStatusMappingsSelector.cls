/**
 * @author Deloitte
 * @date 05/06/2024
 * @description Selector class for "Cross Object Status Mappings" custom metadata.
 */
public inherited sharing class CrossObjectStatusMappingsSelector extends fflib_SObjectSelector implements ICrossObjectStatusMappingsSelector {
    /**
     * @description Default constructor for the class
     * @return ICrossObjectStatusMappingsSelector
     */
    public static ICrossObjectStatusMappingsSelector newInstance() {
        return (ICrossObjectStatusMappingsSelector) Application.Selector.newInstance(
            Cross_Object_Status_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting the fields on Cross_Object_Status_Mapping__mdt
     * @return List<Schema.SObjectField>- Cross_Object_Status_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Cross_Object_Status_Mapping__mdt.Target_Status__c,
            Cross_Object_Status_Mapping__mdt.Source_Status__c,
            Cross_Object_Status_Mapping__mdt.Process__c,
            Cross_Object_Status_Mapping__mdt.Active__c,
            Cross_Object_Status_Mapping__mdt.Type__c
        };
    }

    /**
     * @description Override Default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Cross_Object_Status_Mapping__mdt.SObjectType;
    }

    /**
     * @description It is used to fetch the Cross Object Status Mapping records with the
     * passed Process Name.
     * @param processName
     * @return List<Cross_Object_Status_Mapping__mdt>
     */
    public list<Cross_Object_Status_Mapping__mdt> selectActiveStatusMappingsByProcessName(
        String processName
    ) {
        String.escapeSingleQuotes(processName);
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Process__c = :processName AND Active__c = true');
        return (List<Cross_Object_Status_Mapping__mdt>) Database.query(query.toSOQL());
    }
}