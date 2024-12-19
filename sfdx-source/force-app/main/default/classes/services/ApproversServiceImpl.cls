/**
 * @author Deloitte
 * @date 10/10/2024
 * @description Service implementation class for Approvers related logic.
 *
 */
public inherited sharing class ApproversServiceImpl implements IApproversService {
    private static final String DYNAMIC_APPROVER_NAME = 'Dynamic Approver for user Id: ';
    /**
     * @description It is used to create dynamic approver records by the passed user ids.
     * It is used if the approval rule uses dynamic approver field 'sbaa__ApproverField__c'.
     * @JIRA# LEM-22071
     * @param userIds
     */
    public void createApproversByUserIds(Set<Id> userIds) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        try {
            for (
                sbaa__Approver__c eachApprover : ApproversSelector.newInstance()
                    .selectByUserIds(userIds)
            ) {
                if (userIds.contains(eachApprover.sbaa__User__c)) {
                    userIds.remove(eachApprover.sbaa__User__c);
                }
            }
            for (Id eachUserId : userIds) {
                uow.registerNew(
                    new sbaa__Approver__c(
                        sbaa__User__c = eachUserId,
                        Name = DYNAMIC_APPROVER_NAME + eachUserId
                    )
                );
            }
            uow.commitWork();
        } catch (Exception exceptionsOnInsert) {
            Logger.publish(
                LogEntry.newExceptionLog(exceptionsOnInsert, LogEntry.SeverityLevel.HIGH)
            );
        }
    }
}