/**
 * @author Deloitte
 * @date   04/03/2022
 * @description This is the service class for Account related logic
 */
public inherited sharing class AccountsService implements IHandleNotifierEvents {
    /**
     * @description This method is used to handle the published Notifier events.
     * @param notifierEvents list of platform events with payload
     */
    public static void execute(List<Notifier__e> notifierEvents) {
        service().handleNotifierEvents(notifierEvents);
    }

    /**
     * @description To process child accounts on account merge.
     * @param accountsToUpdate
     */
    public static void processMergedAccountsRelatedRecords(List<Account> accountsToUpdate) {
        service().processMergedAccountsRelatedRecords(accountsToUpdate);
    }

    /**
     * @description It is used to update the MDS Activation on Account to true whenever the
     * related Xref is created or updated
     * @param accountsToBeUpdated
     */
    public static void updateAccountsForActivatingAndDeactivatingMDSXrefs(
        List<Account> accountsToBeUpdated
    ) {
        service().updateAccountsForActivatingAndDeactivatingMDSXrefs(accountsToBeUpdated);
    }

    /**
     * @description To process parent accounts on account merge
     * @param accountIds
     */
    public static void processMergedParentAccounts(Set<Id> accountIds) {
        service().processMergedParentAccounts(accountIds);
    }

    /**
     * @description It is used to update "Proposed Date of Activation"/"Proposed Date of Menu"/
     * "Proposed Date of Tablet" fields from parent Work Order on store Account where
     * "User Sets PDOA Value?"/"User Sets PDOM Value?"/"User Sets PDOT Value?" is 'No' or null.
     * @JIRA# LEM-2854, LEM-3402 & LEM-3442
     * @param storeAccountsToCopyPDOX
     */
    public static void populatePDOXOnStoreAccounts(List<Account> storeAccountsToCopyPDOX) {
        service().populatePDOXOnStoreAccounts(storeAccountsToCopyPDOX);
    }

    /**
     * @description Constructor to perform before update processing\
     * @param referenceAccounts
     */
    public static void updateUltimateParent(List<Account> referenceAccounts) {
        service().updateUltimateParent(referenceAccounts);
    }

    /**
     * @description Update accounts method
     * @param accountsToUpdate
     */
    public static void updateAccounts(List<Account> accountsToUpdate) {
        service().updateAccounts(accountsToUpdate);
    }

    /**
     * @description This method is used to update Account life cycle status to Unvetted.
     * @param accountIds passing Account ids of the related opportunitties.
     * @param accountIdsOfTheExistingOpportunities
     */
    public static void updateAcountLifeCycleStatusToUnvetted(
        Set<Id> accountIds,
        Set<Id> accountIdsOfTheExistingOpportunities
    ) {
        service()
            .updateAcountLifeCycleStatusToUnvetted(
                accountIds,
                accountIdsOfTheExistingOpportunities
            );
    }

    /**
     * @description It is used to update the MDS Activation on Account to true whenever the
     * related Xref is created or updated
     * @param accountsToBeDeactivated
     * @return Set<Id>
     */
    public static Set<Id> checkAccountsForDeactivation(Set<Id> accountsToBeDeactivated) {
        return service().checkAccountsForDeactivation(accountsToBeDeactivated);
    }

    /**
     * @description This method is used to update Account life cycle status to In Pursuit.
     * @param accountIds passing Account ids of the related opportunitties.
     */
    public static void updateAcountLifeCycleStatusToInPursuit(Set<Id> accountIds) {
        service().updateAcountLifeCycleStatusToInPursuit(accountIds);
    }
    /**
     * @description This method is used to update account attributes for top down automation.
     * @param accountsToBeUpdated passing Accounts to be updated
     */
    public static void updateAccountAttributesTopDownAutomation(List<Account> accountsToBeUpdated) {
        service().updateAccountAttributesTopDownAutomation(accountsToBeUpdated);
    }

    /**
     * @description This method is used to update Experience on accounts
     * @param accountIds
     */
    public static void updateFieldsOnAccount(Set<Id> accountIds) {
        service().updateFieldsOnAccount(accountIds);
    }

    private static IAccountsService service() {
        return (IAccountsService) Application.Service.newInstance(IAccountsService.class);
    }
    /**
     * @description To stamp Parent Account Updates On Child Accounts
     * @JIRA# LEM-8322
     * @param parentAccounts
     * @param fieldApiName
     */
    public static void stampFieldValueOnChildAccounts(
        List<Account> parentAccounts,
        String fieldApiName
    ) {
        service().stampFieldValueOnChildAccounts(parentAccounts, fieldApiName);
    }

    /**
     * @description It is used to stamp the date after a configured number of business days
     * on "Withholding Opt-out Expiry Date" field on the passed corporate accounts.
     * @JIRA# LEM-10617
     * @param corporateAccountIds
     */
    public static void stampWithholdingExpiryDateOnCorporateAccounts(Set<Id> corporateAccountIds) {
        service().stampWithholdingExpiryDateOnCorporateAccounts(corporateAccountIds);
    }

    /**
     * @description This method is used to update Rate_Change_Request__c on accounts
     * @param storeAccounts
     * @param rateChangeRequestId
     */
    public static void updateRateChangeRequestOnAccount(
        List<Account> storeAccounts,
        Id rateChangeRequestId
    ) {
        service().updateRateChangeRequestOnAccount(storeAccounts, rateChangeRequestId);
    }

    /**
    * @description Service method to find the Account Team Member for  Franchise Representative role on Parent Corporate Business Account’s Account Team then assign that person as a owner for this new Franchise Business Account
    * @author rishab.goyal | 03-18-2024
    * @param franchiseAccounts
    **/
    public static void fetchAndPopulateOwnerOnFranchiseAccounts(List<Account> franchiseAccounts){
        service().fetchAndPopulateOwnerOnFranchiseAccounts(franchiseAccounts);
    }

    /**
     * @description This method is used to update the Activation Status on store accounts based on the MDS is_Active flag updates/sync
     * @param accountIdsTobeActivated
     * @param accountIdsEligibleForDeactivation
     */
    public static void processStoreAccountsMdsActivationStatus(
        Set<Id> accountIdsTobeActivated,
        Set<Id> accountIdsEligibleForDeactivation
    ) {
        service()
            .processStoreAccountsMdsActivationStatus(
                accountIdsTobeActivated,
                accountIdsEligibleForDeactivation
            );
    }
    /**
     * @description It is used to update Partnership Level and Partnership expiration date
     * on the account.
     * @param mapIdToQuote
     */
    public static void populatePartnershipLevelOnAccount(Map<Id, SBQQ__Quote__c> mapIdToQuote) {
        service().populatePartnershipLevelOnAccount(mapIdToQuote);
    }

    /**
     * @description It is used to nullify Renewal Opportunity lookup on Account when
     * Partnership Expiration Date is updated on the account.
     * @param accountToUpdateRenewalOpp
     */
    public static void updateRenewalOpportunityOnAccount(List<Account> accountToUpdateRenewalOpp) {
        service().updateRenewalOpportunityOnAccount(accountToUpdateRenewalOpp);
    }

    /**
     * @description It is used to populate Renewal Opportunity lookup on Account when
     * renewal opportunity is created using batch on the account.
     * @param accountIdToOppMap
     */
    public static void updateRenewalOpportunityCreatedFromBatchLookupOnAccount(
        Map<Id, Opportunity> accountIdToOppMap
    ) {
        service().updateRenewalOpportunityCreatedFromBatchLookupOnAccount(accountIdToOppMap);
    }
}