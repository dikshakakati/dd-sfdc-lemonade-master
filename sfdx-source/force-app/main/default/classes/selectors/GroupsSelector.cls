/**
 * @author Deloitte
 * @date 15/06/2022
 * @description Selector class for Group object.
 */
public inherited sharing class GroupsSelector extends fflib_SObjectSelector implements IGroupsSelector {
    private static final String SOBJECT_TYPE = 'WorkPlan';
    private static final String GROUP_TYPE = 'Queue';

    /**
     * @description Default constructor for this class.
     * @return IGroupsSelector - interface of GroupsSelector
     */
    public static IGroupsSelector newInstance() {
        return (IGroupsSelector) Application.Selector.newInstance(Group.SObjectType);
    }

    /**
     * @description It is for getting the fields on Group object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ Group.Id, Group.Name, Group.DeveloperName };
    }

    /**
     * @description It is used for getting Object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Group.SObjectType;
    }

    /**
     * @description It gets Group records filtered by QueuesSobject records for WorkPlan object.
     * @return List<Group>
     */
    public List<Group> selectByWorkPlanQueueIds() {
        fflib_QueryFactory groupQuery = newQueryFactory()
            .setCondition(
                'Id IN (SELECT QueueId FROM QueueSobject WHERE SobjectType = :SOBJECT_TYPE)'
            );
        return (List<Group>) Database.query(groupQuery.toSOQL());
    }

    /**
     * @description Used to check the groups to which user belong.To further validate approvals required on Quotes created by User.
     * @param groupMemberIds
     * @return List<Group>
     */
    public List<Group> selectByGroupMemberIds(Set<ID> groupMemberIds) {
        fflib_QueryFactory groupsQuery = newQueryFactory()
            .setCondition(
                'Id IN (SELECT GroupId FROM GroupMember WHERE UserOrGroupId IN :groupMemberIds)'
            );
        new GroupMembersSelector()
            .addQueryFactorySubselect(groupsQuery, 'GroupMembers')
            .setCondition('UserOrGroupId IN :groupMemberIds');
        return (List<Group>) Database.query(groupsQuery.toSOQL());
    }
    /**
     * @description It gets Group records filtered by Queuename.
     * @param queueName
     * @return List<Group>
     */
    public List<Group> selectQueueByName(String queueName) {
        fflib_QueryFactory groupQuery = newQueryFactory();
        groupQuery.setCondition('Type = :GROUP_TYPE AND Name = :queueName');
        return (List<Group>) Database.query(groupQuery.toSOQL());
    }
}