/**
 * @author Deloitte
 * @date 28/02/2022
 * @description This is test class for Users domain class
 */
@isTest(seeAllData=false)
private class UsersTest {
    /**
     * @description This method is used to test Users class
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<User> usersList = new List<User>();
        //IUsers Instance Creation Call
        Users.newInstance(usersList);
        //Default Constructor Call
        Users usersObject = new Users(usersList);
        //fflib_IDomainConstructor call
        Users.Constructor constructorObject = new Users.Constructor();
        constructorObject.construct(usersList);
        System.assertNotEquals(
            Users.newInstance(usersList),
            usersObject,
            'These objects should not be similar'
        );
    }

    /*
     * @description This method is used for checking if manager is deactivated then subordinate users are updated
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUserDeactivatedThenUpdateSubordinateLookups() {
        Id workersManager = Fake.generateId(User.class);
        Id rosterManager = Fake.generateId(User.class);
        Id userRecordIdWithWorkersManager = Fake.generateId(User.class);
        Id userRecordIdWithRosterManager = Fake.generateId(User.class);

        User[] parentUsers = new List<User>{
            new User(Id = workersManager, isActive = false),
            new User(Id = rosterManager, isActive = false)
        };

        User[] subordinateUsers = new List<User>{
            new User(
                Id = userRecordIdWithWorkersManager,
                LastName = 'Test 1',
                isActive = false,
                Worker_s_Manager__c = workersManager,
                ManagerId = workersManager
            ),
            new User(
                Id = userRecordIdWithRosterManager,
                LastName = 'Test 2',
                isActive = true,
                Roster_Manager__c = rosterManager,
                ManagerId = rosterManager
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IUsersSelector selectorMock = (IUsersSelector) mocks.mock(IUsersSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(User.SObjectType);
        mocks.when(selectorMock.getSubordinateUsers(new Set<Id>{ workersManager, rosterManager }))
            .thenReturn(subordinateUsers);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Users.newInstance(parentUsers).updateHierarchyLookupFields();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        User.Id => userRecordIdWithWorkersManager,
                        User.Worker_s_Manager__c => null,
                        User.ManagerId => null
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        User.Id => userRecordIdWithRosterManager,
                        User.Roster_Manager__c => null,
                        User.ManagerId => null
                    }
                )
            );
    }

    /*
     * @description This method is used to test workers manager population
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUserUpdatedThenPopulateManagerId() {
        Id managerUser1 = Fake.generateId(User.class);
        Id managerUser2 = Fake.generateId(User.class);
        Id subordinateUser1 = Fake.generateId(User.class);
        Id subordinateUser2 = Fake.generateId(User.class);

        User[] parentUsers = new List<User>{
            new User(Id = managerUser1, isActive = true, Employee_ID_Okta__c = '12345'),
            new User(Id = managerUser2, isActive = true, Employee_ID_Okta__c = '56789')
        };

        User[] subordinateUsers = new List<User>{
            new User(
                Id = subordinateUser1,
                LastName = 'Test 1',
                isActive = true,
                Manager_ID_Okta__c = '12345'
            ),
            new User(
                Id = subordinateUser2,
                LastName = 'Test 2',
                isActive = true,
                Manager_ID_Okta__c = '56789'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IUsersSelector selectorMock = (IUsersSelector) mocks.mock(IUsersSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(User.SObjectType);
        mocks.when(
                selectorMock.selectActiveUsersByEmployeeIdOkta(new Set<String>{ '12345', '56789' })
            )
            .thenReturn(parentUsers);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Users.newInstance(subordinateUsers).populateWorkersManager();

        System.assertNotEquals(
            null,
            subordinateUsers[0].Worker_s_Manager__c,
            'Workers Manager should be populated'
        );
        System.assertNotEquals(
            null,
            subordinateUsers[1].Worker_s_Manager__c,
            'Workers Manager should be populated'
        );
        System.assertNotEquals(
            null,
            subordinateUsers[0].ManagerId,
            'Manager Id should be populated'
        );
        System.assertNotEquals(
            null,
            subordinateUsers[1].ManagerId,
            'Manager Id should be populated'
        );
    }

    /*
     * @description This method is used to test manager id population when roster manager is updated
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRosterManagerUpdatedThenPopulateManagerId() {
        Id managerUser = Fake.generateId(User.class);
        Id subordinateUser1 = Fake.generateId(User.class);
        Id subordinateUser2 = Fake.generateId(User.class);

        User[] subordinateUsers = new List<User>{
            new User(
                Id = subordinateUser1,
                LastName = 'Test 1',
                isActive = true,
                Roster_Manager__c = managerUser
            ),
            new User(
                Id = subordinateUser2,
                LastName = 'Test 2',
                isActive = true,
                Roster_Manager__c = managerUser
            )
        };

        Users.newInstance(subordinateUsers).updateManagerId();

        System.assertEquals(
            managerUser,
            subordinateUsers[0].ManagerId,
            'Manager Id should be populated'
        );
        System.assertEquals(
            managerUser,
            subordinateUsers[1].ManagerId,
            'Manager Id should be populated'
        );
    }

    /*
     * @description This method is used to test manager id population on subordinate users.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenManagerActivatedThenPopulateSubordinateLookups() {
        Id workersManager = Fake.generateId(User.class);
        Id rosterManager = Fake.generateId(User.class);
        Id userRecordIdWithWorkersManager = Fake.generateId(User.class);
        Id userRecordIdWithRosterManager = Fake.generateId(User.class);

        User[] parentUsers = new List<User>{
            new User(Id = workersManager, isActive = true, Employee_ID_Okta__c = '12345'),
            new User(Id = rosterManager, isActive = true)
        };

        User[] subordinateUsers = new List<User>{
            new User(
                Id = userRecordIdWithWorkersManager,
                LastName = 'Test 1',
                isActive = true,
                Manager_ID_Okta__c = '12345'
            ),
            new User(
                Id = userRecordIdWithRosterManager,
                LastName = 'Test 2',
                isActive = true,
                Roster_Manager__c = rosterManager,
                Manager_ID_Okta__c = '12345'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IUsersSelector selectorMock = (IUsersSelector) mocks.mock(IUsersSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(User.SObjectType);
        mocks.when(selectorMock.selectActiveUsersByManagerIdOkta(new Set<String>{ '12345' }))
            .thenReturn(subordinateUsers);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Users.newInstance(parentUsers).populateWorkersManagerOnSubordinateUsers();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        User.Id => userRecordIdWithWorkersManager,
                        User.Worker_s_Manager__c => workersManager,
                        User.ManagerId => workersManager
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        User.Id => userRecordIdWithRosterManager,
                        User.Worker_s_Manager__c => workersManager,
                        User.Roster_Manager__c => rosterManager,
                        User.ManagerId => rosterManager
                    }
                )
            );
    }

    /*
     * @description This method is used to test if permission set assignments, permission set licenses, user licenses
     * are removed from user, when user is deactvated
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUserDeactivatedThenPermissionsAndLicenseAssignmentsDeleted() {
        Id userRecord1 = Fake.generateId(User.class);
        Id userRecord2 = Fake.generateId(User.class);
        Id permissionSet1 = Fake.generateId(PermissionSet.class);
        Id permissionSet2 = Fake.generateId(PermissionSet.class);
        Id permissionSetGroup1 = Fake.generateId(PermissionSetGroup.class);
        Id permissionSetGroup2 = Fake.generateId(PermissionSetGroup.class);
        Id permissionSetLicense1 = Fake.generateId(PermissionSetLicense.class);
        Id permissionSetLicense2 = Fake.generateId(PermissionSetLicense.class);
        Id userPackageLicense1 = Fake.generateId(UserPackageLicense.class);
        Id userPackageLicense2 = Fake.generateId(UserPackageLicense.class);

        User[] inactiveUsers = new List<User>{
            new User(Id = userRecord1, LastName = 'Test 1', isActive = false),
            new User(Id = userRecord2, LastName = 'Test 2', isActive = false)
        };

        PermissionSetAssignment[] permissionSetAssignments = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(PermissionSetId = permissionSet1, AssigneeId = userRecord1),
            new PermissionSetAssignment(PermissionSetId = permissionSet2, AssigneeId = userRecord2),
            new PermissionSetAssignment(
                PermissionSetGroupId = permissionSetGroup1,
                AssigneeId = userRecord1
            ),
            new PermissionSetAssignment(
                PermissionSetGroupId = permissionSetGroup2,
                AssigneeId = userRecord2
            )
        };

        PermissionSetLicenseAssign[] permissionSetLicenseAssignments = new List<PermissionSetLicenseAssign>{
            new PermissionSetLicenseAssign(
                PermissionSetLicenseId = permissionSetLicense1,
                AssigneeId = userRecord1
            ),
            new PermissionSetLicenseAssign(
                PermissionSetLicenseId = permissionSetLicense2,
                AssigneeId = userRecord2
            )
        };

        UserPackageLicense[] userPackageLicenses = new List<UserPackageLicense>{
            new UserPackageLicense(PackageLicenseId = userPackageLicense1, UserId = userRecord1),
            new UserPackageLicense(PackageLicenseId = userPackageLicense2, UserId = userRecord2)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPermissionSetAssignmentsSelector permissionSetAssignmentsSelectorMock = (IPermissionSetAssignmentsSelector) mocks.mock(
            IPermissionSetAssignmentsSelector.class
        );
        IPermissionSetLicenseAssignmentsSelector permissionSetLicenseAssignmentsSelectorMock = (IPermissionSetLicenseAssignmentsSelector) mocks.mock(
            IPermissionSetLicenseAssignmentsSelector.class
        );
        IUserPackageLicensesSelector userPackageLicensesSelectorMock = (IUserPackageLicensesSelector) mocks.mock(
            IUserPackageLicensesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(permissionSetAssignmentsSelectorMock.sObjectType())
            .thenReturn(PermissionSetAssignment.SObjectType);
        mocks.when(permissionSetLicenseAssignmentsSelectorMock.sObjectType())
            .thenReturn(PermissionSetLicenseAssign.SObjectType);
        mocks.when(userPackageLicensesSelectorMock.sObjectType())
            .thenReturn(UserPackageLicense.SObjectType);
        mocks.when(
                permissionSetAssignmentsSelectorMock.selectByAssigneeIds(
                    new Set<Id>{ userRecord1, userRecord2 }
                )
            )
            .thenReturn(permissionSetAssignments);
        mocks.when(
                permissionSetLicenseAssignmentsSelectorMock.selectByAssigneeIds(
                    new Set<Id>{ userRecord1, userRecord2 }
                )
            )
            .thenReturn(permissionSetLicenseAssignments);
        mocks.when(
                userPackageLicensesSelectorMock.selectByUserIds(
                    new Set<Id>{ userRecord1, userRecord2 }
                )
            )
            .thenReturn(userPackageLicenses);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(permissionSetAssignmentsSelectorMock);
        Application.SELECTOR.setMock(permissionSetLicenseAssignmentsSelectorMock);
        Application.SELECTOR.setMock(userPackageLicensesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Users.newInstance(inactiveUsers).removeUserPermissionsAndLicenseAssignments();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 8))
            .registerDeleted(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDeleted(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        PermissionSetAssignment.PermissionSetId => permissionSet1,
                        PermissionSetAssignment.AssigneeId => userRecord1
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDeleted(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        PermissionSetAssignment.PermissionSetId => permissionSet2,
                        PermissionSetAssignment.AssigneeId => userRecord2
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDeleted(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        PermissionSetAssignment.PermissionSetGroupId => PermissionSetGroup1,
                        PermissionSetAssignment.AssigneeId => userRecord1
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDeleted(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        PermissionSetAssignment.PermissionSetGroupId => PermissionSetGroup2,
                        PermissionSetAssignment.AssigneeId => userRecord2
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDeleted(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        PermissionSetLicenseAssign.PermissionSetLicenseId => permissionSetLicense1,
                        PermissionSetLicenseAssign.AssigneeId => userRecord1
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDeleted(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        PermissionSetLicenseAssign.PermissionSetLicenseId => permissionSetLicense2,
                        PermissionSetLicenseAssign.AssigneeId => userRecord2
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDeleted(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        UserPackageLicense.PackageLicenseId => userPackageLicense1,
                        UserPackageLicense.UserId => userRecord1
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDeleted(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        UserPackageLicense.PackageLicenseId => userPackageLicense2,
                        UserPackageLicense.UserId => userRecord2
                    }
                )
            );
    }
     /*
     * @description This method is used to test the revert role id when role is updated to blank.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRoleIdUpdatedToBlankThenRevertUserRoleId() {
        Id workersManager = Fake.generateId(User.class);
        Id userRoleId = Fake.generateId(UserRole.class);
        Profile p = [SELECT Id, Name FROM Profile WHERE Name ='Okta Integration'];
        String uniqueness = DateTime.now() + ':' + Math.random();
        User testUser = new User(
            username = UserInfo.getUserId() + '.' + uniqueness.HashCode() + '@' + UserInfo.getOrganizationId() + '.sfdcOrg',
            alias = 'testExec',
            email = 'apextests@example.com',
            emailencodingkey = 'UTF-8',
            lastname = 'Testing',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles'
        );
        insert testUser;

        System.runAs( testUser ) {
            User[] newUsers = new List<User>{
                new User(Id = workersManager, isActive = true)
            };
            User[] oldUsers = new List<User>{
                new User(Id = workersManager, isActive = true, UserRoleId= userRoleId)
            };
            Map<Id, User> oldUsersMap = new  Map<Id, User>();
            oldUsersMap.put(oldUsers[0].Id,oldUsers[0]);
            Set<Id> userIds = (new Map<Id, SObject>(newUsers)).keySet();
            String jsonOldMap = JSON.serialize(oldUsersMap);
            Users.newInstance(newUsers).initiateUserRoleUpdate(newUsers,oldUsersMap);
            Users.updateUserRoleFuture(userIds,jsonOldMap);
            System.assertEquals( userRoleId,oldUsersMap.get(oldUsers[0].Id).UserRoleId,'UserRoleId should be populated');
        }
    }
}