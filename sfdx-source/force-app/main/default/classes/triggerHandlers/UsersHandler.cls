/**
 * @author Deloitte
 * @date 22/02/2022
 * @description User Object Trigger Handler
 */
public class UsersHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method
     * @param sObjectList - Users Record List
     */
    public UsersHandler(List<User> sObjectList) {
        super(sObjectList);
        setContextBypass(User.SObjectType, UsersHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return UsersHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new UsersHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform before insert processing
     */
    public override void onBeforeInsert() {
        Users.newInstance(this.records).populateWorkersManager();
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        Users.newInstance(this.records).populateWorkersManagerOnSubordinateUsers();
    }

    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        List<User> changedUsersStatus = new List<User>(
            (List<User>) getChangedRecords(new Set<SObjectField>{ User.isActive })
        );
        Users.newInstance(changedUsersStatus).updateHierarchyLookupFields();

        List<User> changedUsersStatusOrManagerIdOkta = new List<User>(
            (List<User>) getChangedRecords(
                new Set<SObjectField>{ User.Manager_ID_Okta__c, User.isActive }
            )
        );
        Users.newInstance(changedUsersStatusOrManagerIdOkta).populateWorkersManager();

        List<User> changedRosterManager = new List<User>(
            (List<User>) getChangedRecords(new Set<SObjectField>{ User.Roster_Manager__c })
        );
        Users.newInstance(changedRosterManager).updateManagerId();
    }

    /**
     * @description Called to perform after update processing
     * @param existing - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        List<User> changedUsersStatus = new List<User>(
            (List<User>) getChangedRecords(new Set<SObjectField>{ User.isActive })
        );
        Users.newInstance(changedUsersStatus).removeUserPermissionsAndLicenseAssignments();
        Users.newInstance(changedUsersStatus).populateWorkersManagerOnSubordinateUsers();
        List<User> changedUserRole = new List<User>(
            (List<User>) getChangedRecords(new Set<SObjectField>{ User.UserRoleId })
        );
        Users.newInstance(this.records).initiateUserRoleUpdate(changedUserRole, existing);
    }
}