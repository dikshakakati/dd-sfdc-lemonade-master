/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Interface to add domain class methods
 */
public interface IAccounts extends fflib_ISObjects {
    /**
     * @description Method to return all of the record Ids
     * @return Set of record ids
     */
    Set<Id> getIds();

    /**
     * @description It associates store Accounts with 'Brand' same as business Account
     * where business Account 'Segment' is "SMB".
     */
    void associateBrandToStoreAccounts();

    /**
     * @description Update Address verification status and date
     */
    void resetAddressAttributes();

    /**
     * @description Update Address verification date
     */
    void updateAddressVerificationDate();

    /**
     * @description Calculate total number of stores
     */
    void calculateTotalNumberOfStores();

    /**
     * @description It collects Store Accounts with Activation Status as "Active"
     * and triggers update on related WorkPlans and WorkSteps.
     */
    void collectActivatedStoreAccountsAndTriggerUpdateOnRelatedWorkPlansAndWorkSteps();

    /**
     * @description It is used for enabling indiactor on parent Work Order for the
     * following Work Plans generation criteria when POS_Integration_Type__c or
     * Tablet_Delivery_Method__c field is updated on the store Account:
     * a. POS
     * b. Tablet
     */
    void enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder();

    /**
     * @description Update franchise parent subtype
     */
    void updateFranchiseParentSubtype();

    /**
     * @description Concatenate Primary verical with merchangt vertical
     */
    void stampPrimaryVerticalOnMerchantVertical();

    /**
     * @description Populate Store Name of the store accounts
     */
    void populateStoreName();

    /**
     * @description This method used to validate phone number.
     */
    void validateAndNormalizePhoneNumberFormat();

    /**
     * @description Populate Store Name of the store accounts
     * @param oldAccounts
     */
    void populateCurrency(Map<Id, SObject> oldAccounts);

    /**
     * @description To update most recent date for store accounts
     */
    void updateMostRecentDateForStoreAccount();

    /**
     * @description Publish Notifier platform event using
     * the passed topic and prepared JSON payload.
     * @param topicName
     */
    void publishNotifierEvent(String topicName);

    /**
     * @description Publish Duplicate Status Notifier platform event with batch size as 50.
     */
    void publishDuplicateStatusNotifierEvent();

    /**
     * @description To populate legal entity name on account
     * @param triggerContext
     */
    void updateDoordashLegalEntityAndControlOfPrice(String triggerContext);

    /**
     * @description To update Developer ID or Developer ID Backend
     * @param oldAccountRecords
     */
    void updateDeveloperIDOrDeveloperIDBackend(Map<Id, SObject> oldAccountRecords);

    /**
     * @description It initiates Tax Id field encryption process on the received Account Ids in future method.
     * @param accounts
     */
    void initiateTaxIdEncryption(List<Account> accounts);

    /**
     * @description To update currency of the payment account
     * @JIRA# LEM-3121
     */
    void updateCurrencyOfPaymentAccount();

    /**
     * @description To update Alcohol Product Eligibility
     * @JIRA# LEM-3434
     */
    void updateAlcoholProductEligibility();

    /**
     * @description To update duplicate status by and duplicate status modified at
     * @JIRA# LEM-3673
     */
    void updateRelatedDuplicateStatusFields();

    /**
     * @description It is used to update store level PDOx indicators on parent Work Order.
     */
    void updateStoreLevelPDOxIndicatorOnParentWorkOrder();

    /**
     * @description It is used to update Corporate Accounts Ids on Franchise Account.
     * @JIRA# LEM-6845
     */
    void updateCorporateAccountOnFranchise();

    /**
     * @description Update Business Vertical if the bvid on bizref matches on the account
     */
    void checkForMatchingBusinessReferenceRecords();

    /**
     * @description populate BVID on store account during insert
     */
    void populateBVIDonStoreAccounts();

    /**
     * @description It is used to populate fields on child accounts by the associated parent account.
     * @JIRA# LEM-11918
     */
    void populateFieldsOnChildAccountsByParent();
    /**
     * @description Validate Accessibilities format
     * @param accounts
     * @JIRA# LEM-12908
     */
    void validateAccessibilities(List<Account> accounts);

    /**
     * @description It is used to update the last updated by mint field on parent work order.
     */
    void stampLastUpdatedByMintOnParentWorkOrder();

    /**
     * @description populate Owner on Franchise Account from Account Team Member
     * @JIRA# LEM-12990
     */
    void populateOwnerOnFranchiseAccount();

    /**
     * @description  It initiates the trickle down of parent account's fields on child accounts
     * @JIRA# LEM-12375
     */
    void initiateTrickleDownOnChildAccounts();
    /**
     * @description It is used to validate if the ROE Fields are updated by Account Owner or Account Owner's Manager.
     * LEM-14107
     */
    void validateROEFieldsChangedByOwnerOrOwnersManager();

     /**
     * @description  It populate Data Verification Status to verified if data is correct
     * @JIRA# LEM-15901
     */
    void populateDataVerificationStatus();
    /**
     * @description It defaults the Deck Rank as King for Accounts having
     * Enterprise and Mid-Market segment.
     * @JIRA# LEM-14098
     * @param accountsToBeDefaulted
     */
    void initiateDefaultOfDeckRankForEnterpriseAndMidMarket(List<Account> accountsToBeDefaulted);
    /**
     * @description It is used to populate Segment as SMB on the Accounts when the creation source is Mx Portal
     * and Ultimate Parent Account is blank.
     */
    void populateSegmentOnAccount();
    /**
     * @description It is used to process accounts post lead conversion.
     * @param existing
     */
    void processAccountsOnLeadConversion(Map<Id, SObject> existing);
    /**
     * @description It is used to call the class to create brand and brand association
     * post lead conversion.
     */
    void invokeCreateBrandsAndBrandAssociation();

    /**
     * @description It is used to update the Data Verification Status to Verified on Eligible Accounts.
     */
    void updateDataVerificationStatus();

    /**
     * @description It updates Mastered In Figment on Business Reference when Primary Vertical is updated on Account.
     */
    void initiateUpdateOnBusinessReferenceOnPrimaryVerticalChange();
    /**
     * @description It updates Account Lifecycle Status based on Store Activation Status for SMB Accounts.
     */
    void setAccountLifecycleStatusOnSMBStoreAccounts();
    /**
    * @description It invokes 'Experience' field update on Store Accounts.
    * @JIRA# LEM-25063
    */
    void invokeExperienceFieldUpdateOnStoreAccounts();
}
