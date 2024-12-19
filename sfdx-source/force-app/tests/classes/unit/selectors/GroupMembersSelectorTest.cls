/**
 * @author atg
 * @date 05/17/2022
 * @description This is test class for GroupMembersSelector class
 */
@isTest
private class GroupMembersSelectorTest {
    private static final String GROUP_NAME = 'COO';
    private static final String GROUP_TYPE_QUEUE = 'Queue';

    /**
     * @description This is method used to test GroupMembersSelector class
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        GroupMembersSelector selectorInstance = new GroupMembersSelector();
        Schema.SObjectType typeOfObj = selectorInstance.getSObjectType();
        System.assertEquals(
            Schema.GroupMember.SObjectType,
            typeOfObj,
            'The object type must be GroupMember'
        );

        List<Schema.SObjectField> fieldList = selectorInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                GroupMember.Id,
                GroupMember.GroupId,
                GroupMember.UserOrGroupId
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    /**
     * @description This is method used to test EmailTemplateSelector SelectByFolderName
     */
    @isTest
    private static void testWhenSelectByFolderNameThenReturnRecords() {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            Alias = 'test',
            Email = 'testUser1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestLastName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'userEmail4306@test.com'
        );
        insert testUser;
        //add user to a group
        Group testGroup1 = new Group(Name = 'testGroup1');
        insert testGroup1;
        Group testGroup2 = new Group(Name = 'testGroup2');
        insert testGroup2;
        GroupMember testMember1 = new GroupMember(
            GroupId = testGroup1.Id,
            UserOrGroupId = testUser.Id
        );
        insert testMember1;
        GroupMember testMember2 = new GroupMember(
            GroupId = testGroup2.Id,
            UserOrGroupId = testUser.Id
        );
        insert testMember2;

        List<GroupMember> groupMemberList = GroupMembersSelector.newInstance()
            .selectGroupMembersByUserId(new Set<Id>{ testUser.Id });
        System.assertEquals(groupMemberList.size(), 2, 'List should have 2 Records');
    }

    /**
     * @description This is method used to test EmailTemplateSelector SelectByFolderName
     */
    @isTest
    private static void testWhenGroupNamePassedThenReturnGroupMembers() {
        User newUser = TestDataFactory.createUser(false);
        User testUser = TestDataFactory.createUser(false);
        insert new List<User>{ newUser, testUser };
        Group testGroup = new Group(Name = 'testGroup');
        insert testGroup;
        List<GroupMember> testMembers = new List<GroupMember>{
            new GroupMember(GroupId = testGroup.Id, UserOrGroupId = newUser.Id),
            new GroupMember(GroupId = testGroup.Id, UserOrGroupId = testUser.Id)
        };
        insert testMembers;
        List<GroupMember> groupMemberList = GroupMembersSelector.newInstance()
            .selectGroupMembersByQueueName('testGroup');
        System.assertEquals(groupMemberList.size(), 2, 'List should have 2 Records');
    }
    /**
     * @description It is used to update Users Approval Groups on  Quotes based on Quote Qwner
     * @JIRA# LEM-14013
     */
    @isTest
    private static void testWhenGroupNamesAndUserIDsPassedThenReturnGroupMembers() {
        User firstUser = TestDataFactory.createUser(false);
        insert firstUser;
        Group approvalGroup = new Group(Name = GROUP_NAME);
        insert approvalGroup;
        List<GroupMember> groupMembers = new List<GroupMember>{
            new GroupMember(GroupId = approvalGroup.Id, UserOrGroupId = firstUser.Id)
        };
        insert groupMembers;
        List<GroupMember> groupMemberList = GroupMembersSelector.newInstance()
            .selectGroupMembersByGroupNamesAndUserIds(
                new List<String>{ GROUP_NAME },
                new Set<Id>{ firstUser.Id }
            );
        System.assertEquals(groupMemberList.size(), 1, 'List should have 1 Records');
    }
}