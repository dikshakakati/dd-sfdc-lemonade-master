/**
 * @author Deloitte
 * @date 07/22/2022
 * @description Service class for sObject deletion related logic.
 * A separate class is required to trigger sObject record deletion in
 * without sharing (system) context to overcome Salesforce limitation with
 * deletion without ModifyAllData system permission:
 * https://help.salesforce.com/s/articleView?id=000327316&type=1.
 * Refer https://doordash.atlassian.net/browse/LEM-2394 for without sharing deletion use-case.
 * Caution: It's without sharing class DO NOT add any functionality except record deletion.
 */
public without sharing class SobjectDeletionService {
    /**
     * @description It is used for deleting the passed sObject records.
     * @param sObjects
     */
    public static void fireRecordsDeletion(List<sObject> sObjects) {
        service().fireRecordsDeletion(sObjects);
    }

    /**
     * @description It creates instance of SobjectDeletionServiceImpl class.
     * @return ISobjectDeletionService - return instance of SobjectDeletionServiceImpl
     */
    private static ISobjectDeletionService service() {
        return (ISobjectDeletionService) Application.Service.newInstance(
            ISobjectDeletionService.class
        );
    }
}