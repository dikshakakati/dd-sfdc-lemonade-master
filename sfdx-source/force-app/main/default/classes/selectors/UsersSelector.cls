/**
 * @author DoorDash QTC
 * @date 08/01/2022
 * @description Selector class for User object.
 */
public inherited sharing class UsersSelector extends fflib_SObjectSelector implements IUsersSelector {
    /**
     * @description Default constructor for the Users selector class.
     * @return IUsersSelector
     */
    public static IUsersSelector newInstance() {
        return (IUsersSelector) Application.Selector.newInstance(User.SObjectType);
    }

    /**
     * @description It is for getting the fields on User object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            User.Id,
            User.UserName,
            User.IsActive,
            User.Email,
            User.Worker_s_Manager__c,
            User.Roster_Manager__c,
            User.ManagerId,
            User.Manager_ID_Okta__c,
            User.Employee_ID_Okta__c
        };
    }

    /**
     * @description It is used for getting object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return User.SObjectType;
    }

    /**
     * @description It is used for getting User Ids based on the UserNames
     * @param userName
     * @param userIds
     * @return List<User>
     */
    @SuppressWarnings('PMD.UnusedLocalVariable')
    public List<User> selectUserIdsByEmailAddressAndIds(String userName, Set<Id> userIds) {
        String userNameMatch = userName + '%';
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('(UserName LIKE :userNameMatch OR Id IN:userIds)  AND IsActive = true');
        return (List<User>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting subordinate user records
     * @param userIds
     * @return Set<Id>
     */
    public List<User> getSubordinateUsers(Set<Id> userIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Worker_s_Manager__c IN: userIds OR Roster_Manager__c IN: userIds');
        return (List<User>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting active users by okta employee id
     * @param employeeIds
     * @return List<User>
     */
    public List<User> selectActiveUsersByEmployeeIdOkta(Set<String> employeeIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Employee_ID_Okta__c IN: employeeIds AND IsActive = true');
        return (List<User>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting active users by okta manager id
     * @param employeeIds
     * @return List<User>
     */
    public List<User> selectActiveUsersByManagerIdOkta(Set<String> employeeIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Manager_ID_Okta__c IN: employeeIds AND IsActive = true');
        return (List<User>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting users by id
     * @param userIds
     * @return List<User>
     */
    public List<User> selectUsersById(Set<Id> userIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN: userIds');
        query.selectField('Manager.ManagerId');
        query.selectField('UserRoleId');
        return (List<User>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used for get the Holding User.
     * @param userName
     * @return List<User>
     */
    public List<User> selectUserByName(String userName) {
        fflib_QueryFactory query = newQueryFactory(false)
            .setCondition('Name = :userName')
            .setLimit(1);
        return (List<User>) Database.query(query.toSOQL());
    }

    /**
     * @description Utilized to return Users by their `Title` attribute
     * @param titles
     * @return List<User>
     **/
    public List<User> selectActiveUsersByJobTitleFuzzyMatch(Set<String> titles) {
        // Initialize the condition string for active users
        String conditionStr = 'IsActive = true';

        // Check if there are titles to search for
        if (!titles.isEmpty()) {
            List<String> titleConditions = new List<String>();
            for (String thisTitle : titles) {
                // For each title, add a LIKE condition. Ensure to escape single quotes to prevent SOQL injection.
                String sanitizedTitle = String.escapeSingleQuotes(thisTitle);
                titleConditions.add('Title LIKE \'%' + sanitizedTitle + '%\'');
            }
            // Append the title conditions to the main condition string
            conditionStr += ' AND (' + String.join(titleConditions, ' OR ') + ')';
        }

        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(conditionStr);
        return (List<User>) Database.query(query.toSOQL());
    }
}