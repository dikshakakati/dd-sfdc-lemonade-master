/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Domain Class for User Object.
 */
public inherited sharing class Users extends fflib_SObjects implements IUsers {

    private static final String LOG_DOMAIN = 'Sales';
    private static final String LOG_UPDATE_USER_ROLEID_SERVICE = 'Update User Role Id';
    private static final String OKTA_INTEGRATION='Okta_Integration';
    /**
     * @description This method is used to return the IUsers interface
     * @param recordList - User record list
     * @return IUsers - Returns IUsers Interface
     */
    public static IUsers newInstance(List<User> recordList) {
        return (IUsers) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public Users(List<User> sObjectList) {
        super(sObjectList, Schema.User.SObjectType);
    }

    /**
     * @description To populate worker's manager when user is reactivated or manager id okta is updated
     */
    public void populateWorkersManager() {
        Set<String> oktaManagerIds = new Set<String>();
        Map<String, Id> oktaManagerIdBySalesforceId = new Map<String, Id>();

        for (User eachUser : (List<User>) getRecords()) {
            if (eachUser.Manager_ID_Okta__c != null && eachUser.isActive) {
                oktaManagerIds.add(eachUser.Manager_ID_Okta__c);
            }
        }

        if (oktaManagerIds.isEmpty()) {
            return;
        }

        for (
            User eachManager : UsersSelector.newInstance()
                .selectActiveUsersByEmployeeIdOkta(oktaManagerIds)
        ) {
            oktaManagerIdBySalesforceId.put(eachManager.Employee_ID_Okta__c, eachManager.Id);
        }

        for (User eachUser : (List<User>) getRecords()) {
            if (oktaManagerIdBySalesforceId.containsKey(eachUser.Manager_ID_Okta__c)) {
                updateWorkersManagerAndManagerId(eachUser, oktaManagerIdBySalesforceId);
            }
        }
    }

    /**
     * @description To populate manager id when roster manager is updated
     */
    public void updateManagerId() {
        for (User eachUser : (List<User>) getRecords()) {
            eachUser.ManagerId = getManagerId(eachUser);
        }
    }

    /**
     * @description To populate worker's manager for subordinate users
     */
    public void populateWorkersManagerOnSubordinateUsers() {
        Map<String, Id> oktaEmployeeIdBySalesforceId = new Map<String, Id>();
        fflib_ISObjectUnitOfWork uowToUpdateUsers = Application.UnitOfWork.newInstance();

        for (User eachUser : (List<User>) getRecords()) {
            if (eachUser.Employee_ID_Okta__c != null && eachUser.IsActive) {
                oktaEmployeeIdBySalesforceId.put(eachUser.Employee_ID_Okta__c, eachUser.Id);
            }
        }
        if (oktaEmployeeIdBySalesforceId.isEmpty()) {
            return;
        }

        for (
            User eachSubordinateUser : UsersSelector.newInstance()
                .selectActiveUsersByManagerIdOkta(oktaEmployeeIdBySalesforceId.keySet())
        ) {
            if (oktaEmployeeIdBySalesforceId.containsKey(eachSubordinateUser.Manager_ID_Okta__c)) {
                updateWorkersManagerAndManagerId(eachSubordinateUser, oktaEmployeeIdBySalesforceId);
                uowToUpdateUsers.registerDirty(eachSubordinateUser);
            }
        }
        uowToUpdateUsers.commitWork();
    }

    /**
     * @description To nullify hierarchy lookup fields
     */
    public void updateHierarchyLookupFields() {
        Set<Id> inactivatedUsers = new Set<Id>();
        fflib_ISObjectUnitOfWork uowToUpdateUsers = Application.UnitOfWork.newInstance();

        for (User eachUser : (List<User>) getRecords()) {
            if (!eachUser.isActive) {
                inactivatedUsers.add(eachUser.Id);
            }
        }

        if (inactivatedUsers.isEmpty()) {
            return;
        }

        for (User eachUser : UsersSelector.newInstance().getSubordinateUsers(inactivatedUsers)) {
            if (inactivatedUsers.contains(eachUser.Worker_s_Manager__c)) {
                eachUser.Worker_s_Manager__c = null;
                eachUser.ManagerId = getManagerId(eachUser);
            }
            if (inactivatedUsers.contains(eachUser.Roster_Manager__c)) {
                eachUser.Roster_Manager__c = null;
                eachUser.ManagerId = getManagerId(eachUser);
            }
            if (!inactivatedUsers.contains(eachUser.Id)) {
                uowToUpdateUsers.registerDirty(eachUser);
            }
        }
        uowToUpdateUsers.commitWork();
    }

    /**
     * @description To remove permission set, permission set license and package license from users
     */
    public void removeUserPermissionsAndLicenseAssignments() {
        Set<Id> inactivatedUsers = new Set<Id>();
        fflib_ISObjectUnitOfWork uowPermissionSets = Application.UnitOfWork.newInstance();
        fflib_ISObjectUnitOfWork uowLicenses = Application.UnitOfWork.newInstance();

        for (User eachUser : (List<User>) getRecords()) {
            if (!eachUser.isActive) {
                inactivatedUsers.add(eachUser.Id);
            }
        }

        if (inactivatedUsers.isEmpty()) {
            return;
        }

        for (
            PermissionSetAssignment eachPermissionSetAssignment : PermissionSetAssignmentsSelector.newInstance()
                .selectByAssigneeIds(inactivatedUsers)
        ) {
            uowPermissionSets.registerDeleted(eachPermissionSetAssignment);
        }
        uowPermissionSets.commitWork();

        for (
            PermissionSetLicenseAssign eachPermissionSetLicenseAssign : PermissionSetLicenseAssignmentsSelector.newInstance()
                .selectByAssigneeIds(inactivatedUsers)
        ) {
            uowLicenses.registerDeleted(eachPermissionSetLicenseAssign);
        }

        for (
            UserPackageLicense eachUserPackageLicense : UserPackageLicensesSelector.newInstance()
                .selectByUserIds(inactivatedUsers)
        ) {
            uowLicenses.registerDeleted(eachUserPackageLicense);
        }
        uowLicenses.commitWork();
    }

    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return Users - List of Users
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (Users.constructorMock != null) {
                return (fflib_SObjects) Users.constructorMock.construct(objectList);
            }
            return new Users((List<SObject>) objectList);
        }
    }

    /**
     * @description To populate worker's manager and manager id
     * @param eachUser
     * @param oktaEmployeeIdBySalesforceId
     */
    private void updateWorkersManagerAndManagerId(
        User eachUser,
        Map<String, Id> oktaEmployeeIdBySalesforceId
    ) {
        eachUser.Worker_s_Manager__c = oktaEmployeeIdBySalesforceId.get(
            eachUser.Manager_ID_Okta__c
        );
        eachUser.ManagerId = getManagerId(eachUser);
    }

    /**
     * @description To get user manager id
     * @param eachUser
     * @return Id
     */
    private Id getManagerId(User eachUser) {
        if (eachUser.Roster_Manager__c != null) {
            return eachUser.Roster_Manager__c;
        } else if (eachUser.Worker_s_Manager__c != null) {
            return eachUser.Worker_s_Manager__c;
        } else {
            return null;
        }
    }

    /**
     * @description It initiates future method to revert the user role id when it is updated to blank
     * @param newUsers
     * @param oldUserIdToUser
     */
    public void initiateUserRoleUpdate(List<User> newUsers, Map<Id, SObject> oldUserIdToUser) {
        Set<Id> userIds = new Set<Id>();
        if (newUsers.isEmpty()) {
            return;
        }
        for(User userRecord: newUsers){
            if(userRecord.UserRoleId == null && FeatureManagement.checkPermission(OKTA_INTEGRATION)){
                userIds.add(userRecord.Id);
            }
        }
        if(!userIds.isEmpty() && userIds != null){
            String strUserOldMap = JSON.serialize(oldUserIdToUser);
            if (!System.isFuture()) {
                updateUserRoleFuture(userIds,strUserOldMap);
            }
        }
    }

    /**
     * @description Future method to revert user role id when it is updated to blank
     * @param userIds
     * @param strUserOldMap
     */
    @future
    public static void updateUserRoleFuture(Set<Id> userIds, String strUserOldMap ) {
       fflib_ISObjectUnitOfWork uowToUpdateUsers = Application.UnitOfWork.newInstance();
       map<id, sobject> oldUserRecords = (Map<id, sObject>) JSON.deserialize(strUserOldMap, map<id, sobject>.class);
       if(!userIds.isEmpty() && userIds != null){
            for(User eachUser: UsersSelector.newInstance().selectUsersById(userIds)){
                User oldUser = (User) oldUserRecords.get(eachUser.Id);
                if (oldUser.UserRoleId != eachUser.UserRoleId && oldUser.UserRoleId != null && eachUser.UserRoleId == null ) {
                    eachUser.UserRoleId = oldUser.UserRoleId;
                    uowToUpdateUsers.registerDirty(eachUser);
                }
            }
        }
        try {
           uowToUpdateUsers.commitWork();
        } catch (Exception userUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(userUpdateException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_UPDATE_USER_ROLEID_SERVICE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(userUpdateException)
            );
        }
    }

}