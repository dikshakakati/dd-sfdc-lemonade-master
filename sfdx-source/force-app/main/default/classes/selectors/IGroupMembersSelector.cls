/**
 * @author atg
 * @date 05/17/2022
 * @description Interface for GroupMember selector class methods.
 */
public interface IGroupMembersSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting GroupMemebrs by UserId
     * @param userIds
     * @return List<GroupMember>
     */
    List<GroupMember> selectGroupMembersByUserId(Set<Id> userIds);

    /**
     * @description It is used for getting list of queue members by queue name.
     * @param queueName
     * @return List<GroupMember>
     */
    List<GroupMember> selectGroupMembersByQueueName(String queueName);

    /**
     * @description It is used for getting list of members by Group Names and User Ids.
     * @param groupNames
     * @param userIds
     * @return List<GroupMember>
     */
    List<GroupMember> selectGroupMembersByGroupNamesAndUserIds(
        List<String> groupNames,
        Set<Id> userIds
    );
}