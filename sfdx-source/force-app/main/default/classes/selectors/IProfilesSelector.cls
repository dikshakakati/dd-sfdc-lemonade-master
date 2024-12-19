/**
 * @author Deloitte
 * @date 02/03/2022
 * @description Selector Class for Profiled Object
 */
public interface IProfilesSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is for getting the fields on Profile
     * @return List<Schema.SObjectField>
     **/
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description This method in selector is used for getting the profile name based on id
     * @param ids
     * @return List<Profile> - list of Profiles
     */
    List<Profile> selectByID(Set<Id> ids);

    /**
     * @description Returns Profiles by their Names
     * @param profileNames
     * @return List<Profile> - list of Profiles
     **/
    List<Profile> selectByNames(Set<String> profileNames);
}