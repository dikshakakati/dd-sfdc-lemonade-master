/**
 * @author Deloitte
 * @date 10/10/2024
 * @description Service class for ApproversService.
 */
public inherited sharing class ApproversService {
    /**
     * @description It is used to create approver records by the passed user ids.
     * @param userIds
     */
    public static void createApproversByUserIds(
        Set<Id> userIds
    ) {
        service().createApproversByUserIds(userIds);
    }

    /**
     * @description It is used to create an instance of ApproversServiceImpl class.
     * @return ApproversService - return instance of ApproversServiceImpl
     */
    private static IApproversService service() {
        return (IApproversService) Application.Service.newInstance(
            IApproversService.class
        );
    }
}