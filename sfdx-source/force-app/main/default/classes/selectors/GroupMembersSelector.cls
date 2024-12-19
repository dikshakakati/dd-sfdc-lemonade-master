/**
 * @author atg
 * @date 05/17/2022
 * @description Selector class for GroupMember object.
 */
public inherited sharing class GroupMembersSelector extends fflib_SObjectSelector implements IGroupMembersSelector {
    /**
     * @description Default constructor for the Groups selector class.
     * @return IGroupMembersSelector
     */
    public static IGroupMembersSelector newInstance() {
        return (IGroupMembersSelector) Application.Selector.newInstance(GroupMember.SObjectType);
    }

    /**
     * @description It is for getting the fields on GroupMember object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            GroupMember.Id,
            GroupMember.GroupId,
            GroupMember.UserOrGroupId
        };
    }

    /**
     * @description It is used for getting object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return GroupMember.SObjectType;
    }

    /**
     * @description It is used for getting list of Queues by Name.
     * @param userIds
     * @return List<GroupMember>
     */
    public List<GroupMember> selectGroupMembersByUserId(Set<Id> userIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('UserOrGroupId IN: userIds');
        return (List<GroupMember>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used for getting list of members by Group Names and User Ids.
     * @param groupNames
     * @param userIds
     * @return List<GroupMember>
     */
    public List<GroupMember> selectGroupMembersByGroupNamesAndUserIds(
        List<String> groupNames,
        Set<Id> userIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Group.DeveloperName');
        query.setCondition('UserOrGroupId IN : userIds AND Group.DeveloperName IN : groupNames');
        return (List<GroupMember>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting list of queue members by queue name.
     * @param queueName
     * @return List<GroupMember>
     */
    public List<GroupMember> selectGroupMembersByQueueName(String queueName) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Group.DeveloperName =: queueName');
        return (List<GroupMember>) Database.query(query.toSOQL());
    }
}