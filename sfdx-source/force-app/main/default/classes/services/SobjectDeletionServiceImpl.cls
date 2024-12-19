/**
 * @author Deloitte
 * @date 07/22/2022
 * @description Service implementation class for sObject deletion related logic.
 * TODO: Add methods for records permanent deletion.
 */
public inherited sharing class SobjectDeletionServiceImpl implements ISobjectDeletionService {
    /**
     * @description It is used for deleting the passed sObject records.
     * @JIRA# LEM-2394
     * @param sObjects
     */
    public void fireRecordsDeletion(List<sObject> sObjects) {
        if (sObjects == null || sObjects.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowRecordsDeletion = Application.UnitOfWork.newInstance();
        uowRecordsDeletion.registerDeleted(sObjects);
        commitWork(uowRecordsDeletion);
    }

    /**
     * @description It commits unit of work for delete operation.
     * @JIRA# LEM-2394
     * @param unitOfWorkInstance
     */
    private void commitWork(fflib_ISObjectUnitOfWork unitOfWorkInstance) {
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception uowException) {
            Logger.publish(LogEntry.newExceptionLog(uowException, LogEntry.SeverityLevel.HIGH));
        }
    }
}