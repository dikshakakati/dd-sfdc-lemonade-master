/**
 * @author DoorDash
 * @date 06/01/2022
 * @description Interface to add domain class methods
 */
public interface IAgreements extends fflib_ISObjects {
    /**
     * @description Method for retrieving all of the Account Ids from the records
     * @return Set of Account Ids
     */
    Set<Id> getAccountIds();

    /**
     * @description It update Agreement related records on After Insert trigger event.
     * @param agreements
     */
    void onAfterInsertHandleRelatedRecords(List<Agreement__c> agreements);

    /**
     * @description To update address deactivation date or status
     * @param agreementList
     * @JIRA #LEM-15980
     */
    void updateDeactivationDateOrStatus(List<Agreement__c> agreementList);
}