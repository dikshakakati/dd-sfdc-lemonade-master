/**
 * @author Deloitte
 * @date   04/03/2022
 * @description This is the service interface for Account related logic
 */
public interface IAccountsService {
    /**
     * @description It is used to update "Proposed Date of Activation"/"Proposed Date of Menu"/
     * "Proposed Date of Tablet" fields from parent Work Order on store Account where
     * "User Sets PDOA Value?"/"User Sets PDOM Value?"/"User Sets PDOT Value?" is 'No' or null.
     *
     * @param storeAccountsToCopyPDOX
     */
    void populatePDOXOnStoreAccounts(List<Account> storeAccountsToCopyPDOX);

    /**
     * @description Constructor to perform before update processing\
     * @param referenceAccounts
     */
    void updateUltimateParent(List<Account> referenceAccounts);

    /**
     * @description Update accounts method
     * @param accountsToUpdate
     */
    void updateAccounts(List<Account> accountsToUpdate);

    /**
     * @description It is used to update the MDS Activation on Account to true whenever the
     * related Xref is created or updated
     * @param accountsToBeUpdated
     */
    void updateAccountsForActivatingAndDeactivatingMDSXrefs(List<Account> accountsToBeUpdated);

    /**
     * @description This method is used to update Account life cycle status to Unvetted.
     * @param accountIds passing Account ids of the related opportunitties.
     * @param accountIdsOfTheExistingOpportunities
     */
    void updateAcountLifeCycleStatusToUnvetted(
        Set<Id> accountIds,
        Set<Id> accountIdsOfTheExistingOpportunities
    );

    /**
     * @description It is used to update the MDS Activation on Account to true whenever the
     * related Xref is created or updated
     * @param accountsToBeDeactivated
     * @return Set<Id>
     */
    Set<Id> checkAccountsForDeactivation(Set<Id> accountsToBeDeactivated);

    /**
     * @description This method is used to update Account attributes in top down automation
     * @param accountRecord passing Accounts.
     */
    void updateAccountAttributesTopDownAutomation(List<Account> accountRecord);

    /**
     * @description This method is used to update Account life cycle status to In Pursuit.
     * @param accountIds passing Account ids of the related opportunitties.
     */
    void updateAcountLifeCycleStatusToInPursuit(Set<Id> accountIds);

    /**
     * @description This method is used to handle the published Notifier events.
     * @param notifierEvents
     */
    void handleNotifierEvents(List<Notifier__e> notifierEvents);

    /**
     * @description To process merged account child records
     * @param accountsToUpdate
     */
    void processMergedAccountsRelatedRecords(List<Account> accountsToUpdate);

    /**
     * @description To process merged accounts
     * @param accountIds
     */
    void processMergedParentAccounts(Set<Id> accountIds);

    /**
     * @description It is used to stamp the date after a configured number of business days
     * on "Withholding Opt-out Expiry Date" field on the passed corporate accounts.
     * @param corporateAccountIds
     */
    void stampWithholdingExpiryDateOnCorporateAccounts(Set<Id> corporateAccountIds);

    /**
     * @description To stamp Parent Account Updates On Child Accounts
     * @JIRA# LEM-8322
     * @param parentAccounts
     * @param fieldApiName
     */
    void stampFieldValueOnChildAccounts(List<Account> parentAccounts, String fieldApiName);

    /**
     * @description This method is used to update Rate_Change_Request__c on accounts
     * @param storeAccounts
     * @param rateChangeRequestId
     */
    void updateRateChangeRequestOnAccount(List<Account> storeAccounts, Id rateChangeRequestId);

    /**
     * @description To update Owner on Franchise accounts
     * @param franchiseAccounts
     */
    void fetchAndPopulateOwnerOnFranchiseAccounts(List<Account> franchiseAccounts);

    /**
     * @description This method is used to update the Activation Status on store accounts based on the MDS is_Active flag updates/sync
     * @param accountIdsTobeActivated
     * @param accountIdsEligibleForDeactivation
     */
    void processStoreAccountsMdsActivationStatus(
        Set<Id> accountIdsTobeActivated,
        Set<Id> accountIdsEligibleForDeactivation
    );

    /**
     * @description It is used to update fields on Account.
     * @param accountIds
     */
    void updateFieldsOnAccount(Set<Id> accountIds);
    /**
     * @description It is used to update Partnership Level and Partnership expiration date
     * on the account.
     * @param mapIdToQuote
     */
    void populatePartnershipLevelOnAccount(Map<Id, SBQQ__Quote__c> mapIdToQuote);

    /**
     * @description It is used to nullify Renewal Opportunity lookup on Account when
     * Partnership Expiration Date is updated on the account.
     * @param accountToUpdateRenewalOpp
     */
    void updateRenewalOpportunityOnAccount(List<Account> accountToUpdateRenewalOpp);

    /**
     * @description It is used to populate Renewal Opportunity lookup on Account when
     * renewal opportunity is created using batch on the account.
     * @param accountIdToOppMap
     */
    void updateRenewalOpportunityCreatedFromBatchLookupOnAccount(
        Map<Id, Opportunity> accountIdToOppMap
    );
}