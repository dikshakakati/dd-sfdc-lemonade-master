/**
 * @author Deloitte
 * @date 15/06/2022
 * @description Interface to add selector class methods.
 */
public interface IGroupsSelector extends fflib_ISObjectSelector {
    /**
     * @description It gets Group records filtered by QueuesSobject records for WorkPlan object.
     * @return List<Group>
     */
    List<Group> selectByWorkPlanQueueIds();

    /**
     * @description It gets Group records filtered by Group Members records for Approvals.
     * @param groupMemberIds
     * @return List<Group>
     */
    List<Group> selectByGroupMemberIds(Set<ID> groupMemberIds);

    /**
     * @description description It gets Group records filtered by Queuename.
     * @param queueName
     * @return List<Group>
     */
    List<Group> selectQueueByName(String queueName);
}