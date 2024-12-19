/**
 * @author Deloitte
 * @date 28/02/2022
 * @description This is test class for User Trigger handler class.
 */
@isTest(seeAllData=false)
private class UsersHandlerTest {
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        //Constructor Call
        List<User> userList = new List<User>();
        UsersHandler userHandlerObject = new UsersHandler(userList);
        //Inner Class Constructor Call
        UsersHandler.Constructor objConstructor = new UsersHandler.Constructor();
        objConstructor.construct(userList);
        System.assertNotEquals(
            userHandlerObject,
            objConstructor.construct(userList),
            'The two constructs should not be similar'
        );
    }

    /**
     * @description To test method call domain class methods on user update
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUserUpdatedThenCall() {
        Id activeUser = Fake.generateId(User.class);
        Id inactiveUser = Fake.generateId(User.class);
        Id userWithRosterManager = Fake.generateId(User.class);

        User[] oldUsers = new List<User>{
            new User(Id = inactiveUser, LastName = 'Test 1', isActive = true),
            new User(Id = activeUser, LastName = 'Test 2', isActive = true),
            new User(Id = userWithRosterManager, LastName = 'Test 3', isActive = true)
        };

        User[] newUsers = new List<User>{
            new User(Id = inactiveUser, LastName = 'Test 1', isActive = false),
            new User(Id = activeUser, LastName = 'Test 2', isActive = true),
            new User(
                Id = userWithRosterManager,
                LastName = 'Test 3',
                isActive = true,
                Roster_Manager__c = activeUser
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IUsers usersMock = (IUsers) mocks.mock(IUsers.class);
        mocks.startStubbing();
        mocks.when(usersMock.getType()).thenReturn(Schema.User.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(usersMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newUsers, new Map<Id, SObject>(oldUsers));
        fflib_SObjectDomain.triggerHandler(UsersHandler.class);

        ((IUsers) mocks.verify(usersMock, 1)).updateHierarchyLookupFields();
        ((IUsers) mocks.verify(usersMock, 1)).populateWorkersManager();
        ((IUsers) mocks.verify(usersMock, 1)).updateManagerId();
        ((IUsers) mocks.verify(usersMock, 1)).removeUserPermissionsAndLicenseAssignments();
        ((IUsers) mocks.verify(usersMock, 1)).populateWorkersManagerOnSubordinateUsers();
    }

    /**
     * @description To test method call domain class methods on user update
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUserInsertedThenCall() {
        Id activeUser = Fake.generateId(User.class);
        Id inactiveUser = Fake.generateId(User.class);
        Id userWithRosterManager = Fake.generateId(User.class);

        User[] newUsers = new List<User>{
            new User(Id = inactiveUser, LastName = 'Test 1', isActive = false),
            new User(Id = activeUser, LastName = 'Test 2', isActive = true),
            new User(
                Id = userWithRosterManager,
                LastName = 'Test 3',
                isActive = true,
                Roster_Manager__c = activeUser
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IUsers usersMock = (IUsers) mocks.mock(IUsers.class);
        mocks.startStubbing();
        mocks.when(usersMock.getType()).thenReturn(Schema.User.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(usersMock);

        fflib_SObjectDomain.Test.Database.onInsert(newUsers);
        fflib_SObjectDomain.triggerHandler(UsersHandler.class);

        ((IUsers) mocks.verify(usersMock, 1)).populateWorkersManager();
        ((IUsers) mocks.verify(usersMock, 1)).populateWorkersManagerOnSubordinateUsers();
    }
}