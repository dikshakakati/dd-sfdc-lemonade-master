/**
 * @author Deloitte
 * @date 15/06/2022
 * @description Test class for GroupsSelector class.
 */
@isTest(seeAllData=false)
private class GroupsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Group';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_LIST = 'Unexpected result: The Group is empty';
    private static final string GROUP_DEVELOPER_NAME = 'Test_COO_Queue';
    private static final string GROUP_NAME = 'Test COO Queue';
    private static final string GROUP_TYPE = 'Queue';
    private static final String SOBJECT_TYPE = 'WorkPlan';
    private static final String QUEUE_SOBJECT_OBJECT_NAME = 'QueueSobject';
    private static final String GROUP_NAME_QUEUE = 'SSMO Holding Queue';
    private static final String GROUP_NAME_NONSSMOQUEUE1 = 'BCD Queue';
    private static final String GROUP_NAME_NONSSMOQUEUE2 = 'ABC Queue';


    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        GroupsSelector groupsInstance = new GroupsSelector();
        Schema.SObjectType typeOfObject = groupsInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = groupsInstance.getSObjectFieldList();
        GroupsSelector.newInstance();
        System.assertEquals(
            Schema.Group.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{ Group.Id, Group.Name, Group.DeveloperName },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test Group query for WorkPlan Queues.
     */
    @isTest
    private static void testWhenQueueIdsArePassedThenRetrieveRecords() {
        List<Group> cooQueueGroups = new List<Group>{
            new Group(DeveloperName = GROUP_DEVELOPER_NAME, Name = GROUP_NAME, Type = GROUP_TYPE)
        };
        insert cooQueueGroups;
        QueueSobject queueSobject = new QueueSobject(
            QueueId = cooQueueGroups[0].Id,
            SObjectType = SOBJECT_TYPE
        );
        insert queueSobject;
        GroupsSelector groupsInstance = new GroupsSelector();
        List<Group> groups = groupsInstance.selectByWorkPlanQueueIds();
        System.assertEquals(true, groups.size() != null, ASSERT_MESSAGE_MISMATCH_IN_LIST);
    }
    /**
     * @description To test Group query for groups related to Quote Owner.
     */
    @isTest
    private static void testWhenUserIdPassedThenAssociatedGroupsSelected() {
        User newUser = TestDataFactory.createUser(true);
        //add user to a group
        Group approvalsGroup = new Group(Name = 'Approvals');
        insert approvalsGroup;
        Group submarketGroup = new Group(Name = 'Submarket Approvals');
        insert submarketGroup;
        GroupMember approvalMember = new GroupMember(
            GroupId = approvalsGroup.Id,
            UserOrGroupId = newUser.Id
        );
        insert approvalMember;
        GroupMember submarketMember = new GroupMember(
            GroupId = submarketGroup.Id,
            UserOrGroupId = newUser.Id
        );
        insert submarketMember;
        List<Group> groupMemberList = GroupsSelector.newInstance()
            .selectByGroupMemberIds(new Set<Id>{ newUser.Id });
        System.assertEquals(groupMemberList.size(), 2, 'List should have 2 Records');
    }

    /**
     * @description To test Group query by queue name.
     */
    @isTest
    private static void testWhenQueueNamesIsPassedThenRetrieveRecords() {
        List<Group> queueGroups = new List<Group>{
            new Group(Name = GROUP_NAME_QUEUE, Type = GROUP_TYPE)
        };
        insert queueGroups;
        GroupsSelector groupInstance = new GroupsSelector();
        List<Group> groups = groupInstance.selectQueueByName(GROUP_NAME_QUEUE);
        System.assertEquals(true, groups.size() != null, ASSERT_MESSAGE_MISMATCH_IN_LIST);


    }
    /**
     * @description To Negative test Group query by queue name.
     */
    @isTest
    private static void testWhenQueueNamesIsPassedThenRetrieveRecordsNegative() {

        List<Group> queuesGroups = new List<Group>{
            new Group(Name = GROUP_NAME_NONSSMOQUEUE2, Type = GROUP_TYPE)
        };
        insert queuesGroups;
        GroupsSelector groupsInstance = new GroupsSelector();
        List<Group> emptyGroups = groupsInstance.selectQueueByName(GROUP_NAME_NONSSMOQUEUE1);
        System.assertEquals(0, emptyGroups.size(), ASSERT_MESSAGE_MISMATCH_IN_LIST);

    }
}