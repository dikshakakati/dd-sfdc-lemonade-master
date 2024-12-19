/**
 * @author Deloitte
 * @date 10/06/2022
 * @description Selector class for static configurations metadata
 */
public with sharing class StaticConfigurationsSelector extends fflib_SObjectSelector implements IStaticConfigurationsSelector {
    /**
     * @description default constructor for the class
     * @return IStaticConfigurationsSelector - interface of StaticConfigurationsSelector
     */
    public static IStaticConfigurationsSelector newInstance() {
        return (IStaticConfigurationsSelector) Application.Selector.newInstance(
            Static_Configurations__mdt.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Static_Configurations__mdt.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Static_Configurations__mdt
     * @return List<Schema.SObjectField>- Static_Configurations__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Static_Configurations__mdt.Label,
            Static_Configurations__mdt.DeveloperName,
            Static_Configurations__mdt.Configuration_Value__c
        };
    }

    /**
     * @description It is used for getting the instance on basis of the passed
     * developer name.
     * @param developerName
     * @return Static_Configurations__mdt
     */
    public Static_Configurations__mdt getInstanceValue(String developerName) {
        return Static_Configurations__mdt.getInstance(developerName);
    }

    /**
     * @description Method fetches metadata record based on label
     * @param name
     * @return List<Static_Configurations__mdt>
     */
    public List<Static_Configurations__mdt> selectByDeveloperName(String name) {
        fflib_QueryFactory query = newQueryFactory().setCondition('DeveloperName = :name');
        return (List<Static_Configurations__mdt>) Database.query(query.toSOQL());
    }
}