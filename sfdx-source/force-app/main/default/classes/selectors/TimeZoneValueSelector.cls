/**
 * @author Deloitte
 * @date 04/09/2024
 * @description Selector Class for Time_Zone_Value__mdt custom metadata
 */
public inherited sharing class TimeZoneValueSelector extends fflib_SObjectSelector implements ITimeZoneValueSelector {
    /**
     * @description Default constructor for the class
     * @return Time_Zone_Value__mdt
     */
    public static ITimeZoneValueSelector newInstance() {
        return (ITimeZoneValueSelector) Application.Selector.newInstance(
            Time_Zone_Value__mdt.SObjectType
        );
    }

    /**
     * @description Override default getSObjectType method
     * @return SObjectType -
     */
    public Schema.SObjectType getSObjectType() {
        return Time_Zone_Value__mdt.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Time_Zone_Value__mdt
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Time_Zone_Value__mdt.Label,
            Time_Zone_Value__mdt.Time_Zone_Abbreviation__c
        };
    }

    /**
     * @description This method is for querying abbreviated time zone from GMT.
     * @param gmtTimeZone
     * @return List<Time_Zone_Value__mdt>
     */
    public List<Time_Zone_Value__mdt> selectTimeZoneAbbreviation(String gmtTimeZone) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('label =: gmtTimeZone');
        return (List<Time_Zone_Value__mdt>) Database.query(query.toSOQL());
    }
}