/**
 * @author Deloitte
 * @date 04/09/2024
 * @description Interface to add Selector class methods
 */
public interface ITimeZoneValueSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is for getting the field list on Time_Zone_Value__mdt
     * @return List<Schema.SObjectField>
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description This method is for getting the time zone abbrevation on
     * Time_Zone_Value__mdt record.
     * @return List<Schema.SObjectField>
     * @param gmtTimeZone
     */
    List<Time_Zone_Value__mdt> selectTimeZoneAbbreviation(String gmtTimeZone);
}