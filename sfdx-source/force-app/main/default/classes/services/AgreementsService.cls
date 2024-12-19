/**
 * @author DoorDash QTC
 * @date   05/15/2022
 * @description LEM-637 This is the service class for Agreements related logic
 */
public inherited sharing class AgreementsService {
    /**
     * @description - Create Agreements on Contract with group
     * @param contractList
     * @param contractIdWithAssociatedAccountIdsMap
     * @param associatedAccountIdGroupIdMapWithEntitlements
     */
    public static void createAgreementsfromContractsWithGroup(
        List<Contract> contractList,
        Map<Id, Set<String>> contractIdWithAssociatedAccountIdsMap,
        Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements
    ) {
        service()
            .createAgreementsfromContractsWithGroup(
                contractList,
                contractIdWithAssociatedAccountIdsMap,
                associatedAccountIdGroupIdMapWithEntitlements
            );
    }

    /**
     * @description - Update Agreements on Contract with Serialized Entitlements Data
     * @param associatedAccountIdGroupIdMapWithEntitlements
     */
    public static void updateAgreementsForExistingStoresWithGroups(
        Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements
    ) {
        service()
            .updateAgreementsForExistingStoresWithGroups(
                associatedAccountIdGroupIdMapWithEntitlements
            );
    }

    /**
     * @description activate the agreements by publishing agreement activation events
     * LEM-2718: throttling the number of store agreements to activated at one time.
     * @param storeAgreements
     * @param isExistingProcess
     */
    public static void publishAgreementActivationEvents(
        List<Agreement__c> storeAgreements,
        Boolean isExistingProcess
    ) {
        service().publishAgreementActivationEvents(storeAgreements, isExistingProcess);
    }

    /**
     * @description returns all records that have status cancelled on update and deactivation date.
     * @param deactivatedAgreements to check
     * @return set of accountids
     * @JIRA #LEM-15980
     */
    public static Set<Id> getDeactivatedAndCancelledAgreementAccountIds(
        List<Agreement__c> deactivatedAgreements
    ) {
        return service().getDeactivatedAndCancelledAgreementAccountIds(deactivatedAgreements);
    }

    /**
     * @description Update mx services in single transaction or Platform event based on Records Count
     * @JIRA #LEM-15980
     * @param deactivatedAgreementsList
     * @param isProcessingAsync
     */
    public static void updateMxServicesBasedOnRecordsCount(
        List<Agreement__c> deactivatedAgreementsList,
        Boolean isProcessingAsync
    ) {
        service().updateMxServicesBasedOnRecordsCount(deactivatedAgreementsList, isProcessingAsync);
    }

    /**
     * @description It is used to delete churned Mx agreements for the passed contract Ids.
     * Additionally, it also initiates the associated Merchant Services deletion and deactivation of
     * associated Xref records.
     * @JIRA #LEM-23780
     * @param contractIds
     * @return fflib_ISObjectUnitOfWork
     */
    public static fflib_ISObjectUnitOfWork deleteChurnedMxAgreements(Set<Id> contractIds) {
        return service().deleteChurnedMxAgreements(contractIds);
    }

    private static IAgreementsService service() {
        return (IAgreementsService) Application.Service.newInstance(IAgreementsService.class);
    }
}