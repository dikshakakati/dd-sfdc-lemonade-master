/**
 * @author Deloitte
 * @date 10/06/2022
 * @description Interface to add selector class methods
 */
public interface IStaticConfigurationsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting the instance on basis of the passed
     * developer name.
     * @param developerName
     * @return Static_Configurations__mdt
     */
    Static_Configurations__mdt getInstanceValue(String developerName);

    /**
     * @description This method is for getting the fields on Static_Configurations__mdt
     * @return List<Schema.SObjectField>- Static_Configurations__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description Method fetches metadata record based on name
     * @param name
     * @return List<Static_Configurations__mdt>
     */
    List<Static_Configurations__mdt> selectByDeveloperName(String name);
}