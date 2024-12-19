/**
 * @author DoorDash QTC
 * @date 08/01/2022
 * @description Interface for User selector class methods.
 */
public interface IUsersSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is for getting the fields on User Object
     * @return List<Schema.SObjectField>- User Object fields
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description This method is used for getting User based on the Email Address
     * @param userName
     * @param userIds
     * @return List<User>
     */
    List<User> selectUserIdsByEmailAddressAndIds(String userName, Set<Id> userIds);

    /**
     * @description This method is used for getting subordinate user records
     * @param userIds
     * @return Set<Id>
     */
    List<User> getSubordinateUsers(Set<Id> userIds);

    /**
     * @description It is used for getting active users by okta employee id
     * @param employeeIds
     * @return List<User>
     */
    List<User> selectActiveUsersByEmployeeIdOkta(Set<String> employeeIds);

    /**
     * @description It is used for getting active users by okta manager id
     * @param employeeIds
     * @return List<User>
     */
    List<User> selectActiveUsersByManagerIdOkta(Set<String> employeeIds);

    /**
     * @description It is used for getting users by id
     * @param userIds
     * @return List<User>
     */
    List<User> selectUsersById(Set<Id> userIds);

    /**
     * @description It is used for get the Holding User.
     * @param userName
     * @return List<User>
     */
    List<User> selectUserByName(String userName);

    /**
     * @description Utilized to return Users by their `Title` attribute
     * @param titles
     * @return List<User>
     **/
    List<User> selectActiveUsersByJobTitleFuzzyMatch(Set<String> titles);
}