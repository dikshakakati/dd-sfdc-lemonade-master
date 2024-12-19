/**
 * @author Deloitte
 * @date 10/10/2024
 * @description Interface class for ApproversService.
 */
public interface IApproversService {
    /**
     * @description It is used to create approver records by the passed user ids.
     * @param userIds
     */
    void createApproversByUserIds(Set<Id> userIds);
}