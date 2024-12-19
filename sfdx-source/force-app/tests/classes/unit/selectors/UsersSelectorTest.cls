/**
 * @author DoorDash QTC
 * @date 08/02/2022
 * @description This is test class for UserSelector class
 */
@isTest
private class UsersSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_LIST = 'Unexpected result: There is a mismatch in user list';
    @TestSetup
    private static void setupUserData() {
        User userInstance = TestDataFactory.createUser(false);
        userInstance.Manager_ID_Okta__c = '12345';
        userInstance.Employee_ID_Okta__c = '943828';
        insert userInstance;
    }

    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Schema.SObjectField> userFieldsMock = new List<Schema.SObjectField>{
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

        Schema.SObjectType typeOfObject = UsersSelector.newInstance().SObjectType();
        List<Schema.SObjectField> sObjectFields = UsersSelector.newInstance().getSObjectFieldList();

        System.assertEquals(
            User.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be User'
        );
        System.assertEquals(
            userFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }
    @isTest
    private static void testWhenAllSelectorMethodsIsCalledThenReturnUsersList() {
        User newUser = TestDataFactory.createUser(false);
        newUser.UserName = 'DoordashUser1@test.com.xxx';

        User testUser = TestDataFactory.createUser(false);
        insert new List<User>{ newUser, testUser };

        List<User> usersList = UsersSelector.newInstance()
            .selectUserIdsByEmailAddressAndIds(
                'DoordashUser1@test.com.xxx',
                new Set<Id>{ testUser.Id }
            );
        System.assertEquals(usersList.size(), 2, 'Should return 2 user records');
    }

    /**
     * @description This method is used for getting subordinate user records
     */
    @isTest
    private static void testWhenGetSubordinateUsersThenReturnUsersList() {
        User managerUser = [SELECT Id FROM User LIMIT 1];
        User userWithWorkersManager = TestDataFactory.createUser(false);
        userWithWorkersManager.Worker_s_Manager__c = managerUser.Id;
        insert userWithWorkersManager;

        User userWithRosterManager = TestDataFactory.createUser(false);
        userWithRosterManager.Roster_Manager__c = managerUser.Id;
        insert userWithRosterManager;

        List<User> usersList = UsersSelector.newInstance()
            .getSubordinateUsers(new Set<Id>{ managerUser.Id });
        System.assertEquals(usersList.size(), 2, 'Should return 2 user record');
    }

    /**
     * @description This method is used to test retrieve active users by okta manager id
     */
    @isTest
    private static void testWhenOktaManagerIdPassedThenReturnSubordinateUsersList() {
        User subordinateUser = [SELECT Id FROM User WHERE Manager_ID_Okta__c = '12345'];
        List<User> usersList = UsersSelector.newInstance()
            .selectActiveUsersByManagerIdOkta(new Set<String>{ '12345' });
        System.assertEquals(usersList.size(), 1, 'Should return 1 user record');
        System.assertEquals(
            usersList[0].Id,
            subordinateUser.Id,
            'Should return subordinate record'
        );
    }

    /**
     * @description This method is used to test retrieve active users by okta employee id
     */
    @isTest
    private static void testWhenOktaEmployeeIdPassedThenReturnUserManager() {
        User managerUser = [SELECT Id FROM User WHERE Employee_ID_Okta__c = '943828'];
        List<User> usersList = UsersSelector.newInstance()
            .selectActiveUsersByEmployeeIdOkta(new Set<String>{ '943828' });
        System.assertEquals(usersList.size(), 1, 'Should return 1 user record');
        System.assertEquals(usersList[0].Id, managerUser.Id, 'Should return manager record');
    }

    /**
     * @description This method is used to test retrieve users by id
     */
    @isTest
    private static void testWhenUserIdsArePassedThenReturnUsersList() {
        User newUser = TestDataFactory.createUser(false);
        User testUser = TestDataFactory.createUser(false);
        insert new List<User>{ newUser, testUser };

        List<User> usersList = UsersSelector.newInstance()
            .selectUsersById(new Set<Id>{ testUser.Id, newUser.Id });
        System.assertEquals(usersList.size(), 2, 'Should return 2 user records');
    }
    /**
     * @description To test query on user to return user details when username is passed.
     */
    @isTest
    private static void testWhenUserNamePassedThenReturnUsersList() {
        User testUser = [SELECT Id, Name FROM User LIMIT 1];
        List<User> usersList = UsersSelector.newInstance().selectUserByName(testUser.Name);
        System.assertEquals(usersList.size(), 1, ASSERT_MESSAGE_MISMATCH_IN_LIST);
        System.assertEquals(usersList[0].Id, testUser.Id, ASSERT_MESSAGE_MISMATCH_IN_LIST);
    }
}