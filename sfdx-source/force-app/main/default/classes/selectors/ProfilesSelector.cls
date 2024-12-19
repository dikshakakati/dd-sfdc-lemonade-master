/**
 * @author Deloitte
 * @date 02/03/2022
 * @description Selector Class for Profile Object
 */
public inherited sharing class ProfilesSelector extends fflib_SObjectSelector implements IProfilesSelector {
    /**
     * @description default constructor for the class
     * @return IProfilesSelector - interface of ProfilesSelector
     */
    public static IProfilesSelector newInstance() {
        return (IProfilesSelector) Application.Selector.newInstance(Profile.SObjectType);
    }

    /**
     * @description Method used to fetch list of SObjectFields
     * @return List<Schema.SObjectField> - returns list of sObject fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ Profile.Id, Profile.Name };
    }

    /**
     * @description Method provides the SObjectType for the object of the Selector
     * @return Schema.SObjectType - returns sObject type
     */
    public Schema.SObjectType getSObjectType() {
        return Profile.SObjectType;
    }

    /**
     * @description This method is used for getting the profile based on id
     * @param ids
     * @return List<Profile> - list of Profiles
     */
    public List<Profile> selectByID(Set<Id> ids) {
        // LEM-672: Added to ignore CRUD check while querying Profile object
        ignoreCRUD();
        return (List<Profile>) selectSObjectsById(ids);
    }

    /**
     * @description Returns Profiles by their Names
     * @param profileNames
     * @return List<Profile> - list of Profiles
     **/
    public List<Profile> selectByNames(Set<String> profileNames) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Name IN :profileNames');
        return (List<Profile>) Database.query(query.toSOQL());
    }
}