/**
 * @author Deloitte
 * @date 07/22/2022
 * @description Interface of service class for sObject deletion related logic.
 */
public interface ISobjectDeletionService {
    /**
     * @description It is used for deleting the passed sObject records.
     * @param sObjects
     */
    void fireRecordsDeletion(List<sObject> sObjects);
}