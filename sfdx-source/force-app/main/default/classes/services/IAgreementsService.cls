/**
 * @description IAgreementService for Agreement Object
 * @author QTC
 * @date 2022-05-15
 */
public interface IAgreementsService {
    /**
     * @description - Create Agreements on Contract with group
     * @param contractList
     * @param contractIdWithAssociatedAccountIdsMap
     * @param associatedAccountIdGroupIdMapWithEntitlements
     */
    void createAgreementsfromContractsWithGroup(
        List<Contract> contractList,
        Map<Id, Set<String>> contractIdWithAssociatedAccountIdsMap,
        Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements
    );

    /**
     * @description - Update Agreements on Contract with Serialized Entitlements Data
     * @param associatedAccountIdGroupIdMapWithEntitlements
     */
    void updateAgreementsForExistingStoresWithGroups(
        Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements
    );

    /**
     * @description activate the agreements by publishing agreement activation events
     * LEM-10729: throttling the number of store agreements to activated at one time.
     * @JIRA #LEM-15980
     * @param storeAgreements
     * @param isExistingProcess
     */
    void publishAgreementActivationEvents(
        List<Agreement__c> storeAgreements,
        Boolean isExistingProcess
    );

    /**
     * @description returns all records that have status cancelled on update and deactivation date.
     * @param deactivatedAgreements to check
     * @return active agreements
     * @JIRA #LEM-15980
     */
    Set<Id> getDeactivatedAndCancelledAgreementAccountIds(List<Agreement__c> deactivatedAgreements);

    /**
     * @description Update mx services in single transaction or Platform event based on Records Count
     * @JIRA #LEM-15980
     * @param deactivatedAgreementsList
     * @param isProcessingAsync
     */
    void updateMxServicesBasedOnRecordsCount(
        List<Agreement__c> deactivatedAgreementsList,
        Boolean isProcessingAsync
    );
    /**
     * @description It is used to delete churned Mx agreements for the passed contract Ids.
     * Additionally, it also initiates the associated Merchant Services deletion and deactivation of
     * associated Xref records.
     * @param contractIds
     * @return fflib_ISObjectUnitOfWork
     */
    fflib_ISObjectUnitOfWork deleteChurnedMxAgreements(Set<Id> contractIds);
}