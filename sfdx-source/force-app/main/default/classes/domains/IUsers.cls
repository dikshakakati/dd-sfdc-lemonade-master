/**
 * @author Deloitte
 * @date 02/12/2022
 * @description Interface to add User domain class methods.
 */
public interface IUsers extends fflib_ISObjects {
    /**
     * @description To nullify hierarchy lookup fields
     */
    void updateHierarchyLookupFields();

    /**
     * @description To populate worker's manager when user is reactivated or manager id okta is updated
     */
    void populateWorkersManager();

    /**
     * @description To populate manager id when roster manager is updated
     */
    void updateManagerId();

    /**
     * @description To populate worker's manager for subordinate users
     */
    void populateWorkersManagerOnSubordinateUsers();

    /**
     * @description To remove permission set, permission set license and package license from users
     */
    void removeUserPermissionsAndLicenseAssignments();

    /**
     * @description It initiates future method to revert the user role id when it is updated to blank
     * @param newUsers
     * @param oldUserIdToUser
     */
    void initiateUserRoleUpdate(List<User> newUsers,Map<Id, SObject> oldUserIdToUser);
}