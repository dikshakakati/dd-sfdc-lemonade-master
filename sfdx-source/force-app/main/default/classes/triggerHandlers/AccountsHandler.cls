/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Account Object Trigger Handler
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.ExcessiveClassLength')
public class AccountsHandler extends ApplicationDomainHandler {
    private static final String BUSINESS = 'Business';
    private static final String EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER = 'UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER';
    private static final String EVENT_TOPIC_UPDATE_ACCOUNT_CURRENCY_ON_OPPORTUNITY = 'UPDATE_ACCOUNT_CURRENCY_ON_OPPORTUNITY';
    private static final String EVENT_TOPIC_UPDATE_ACCOUNT_ISMERGED_FLAG = 'UPDATE_ACCOUNT_ISMERGED_FLAG';
    private static final String STORE = 'Store';
    private static final String SYSTEM_ADMINISTRATOR = 'System Administrator';
    private static final String STORE_LEVEL_WORK_PLANS_INDICATOR_FIELDS_STATIC_CONFIG = 'Store_Level_Work_Plans_Indicator_Fields';
    private static final String STORE_LEVEL_PDOX_FIELDS_INDICATOR_FIELDS_STATIC_CONFIG = 'Store_Level_PDOx_Indicator_Fields';
    private static final String UNVERIFIED = 'Unverified';
    private static final String VERIFIED = 'Verified';
    private static final Id BUSINESS_RECORD_TYPE_ID;
    private static final Id STORE_RECORD_TYPE_ID;
    private static final String AUTOMATED_PROCESS_USER = 'Automated Process';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String CREATE_EVENT = 'CREATE';
    private static final String UPDATE_EVENT = 'UPDATE';

    static {
        STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
    }

    /**
     * @description Constructor Method
     * @param sObjectList - Accounts Record List
     */
    public AccountsHandler(List<Account> sObjectList) {
        super(sObjectList);
        setContextBypass(Account.SObjectType, AccountsHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return AccountHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AccountsHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        callRollUpServiceOnBeforeUpdate();
        checkForMatchingBusinessReferenceRecords(existing);
        List<Account> changedAccountsROE = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{
                    Account.Mx_Contact_Status__c,
                    Account.Mx_Management_Requested__c,
                    Account.Mx_Interest_in_Co_Funded_Marketing_Ops__c,
                    Account.DoorDash_Social_Media_Marketing_Feature__c,
                    Account.Pilot_New_Initiatives_Interest__c,
                    Account.Product_Priority__c,
                    Account.Outreach_Strategy__c,
                    Account.Vendor_Outreach__c,
                    Account.Marketing_Outreach__c,
                    Account.MQOS_Outreach__c
                }
            )
        );
        Accounts.newInstance(changedAccountsROE).validateROEFieldsChangedByOwnerOrOwnersManager();
        Accounts.newInstance(
                new List<Account>(
                    (List<Account>) getChangedRecords(
                        new Set<SObjectField>{ Account.Activation_Status__c }
                    )
                )
            )
            .setAccountLifecycleStatusOnSMBStoreAccounts();
        Accounts.newInstance(
                new List<Account>(
                    (List<Account>) getChangedRecords(
                        new Set<SObjectField>{ Account.Business_Vertical__c }
                    )
                )
            )
            .populateBVIDonStoreAccounts();
        updateAddressVerificationDate(existing);
        Accounts.newInstance(accountsWithUpdatedAddresses()).resetAddressAttributes();
        Accounts.newInstance(recordsWithUpdatedParent()).populateFieldsOnChildAccountsByParent();
        stampPrimaryVerticalOnMerchantVertical(recordsWithUpdatedVertical());
        Accounts.newInstance(
                new List<Account>(
                    (List<Account>) getChangedRecords(
                        new Set<SObjectField>{ Account.Segment__c, Account.ParentId }
                    )
                )
            )
            .associateBrandToStoreAccounts();
        checkIfAccountUpdatedForStoreName(existing);
        Accounts.newInstance(accountsWithUpdatedPhoneNumbers())
            .validateAndNormalizePhoneNumberFormat();
        populateCurrencyOnBeforeUpdate(existing);
        updateMostRecentDateForStoreAccount();
        updateDoordashLegalEntityOnUpdate();
        updateDeveloperIdBackendOnUpdate(existing);
        Accounts.newInstance(accountsWithUpdatedCountryOrVerticalOrAlcoholEligibility())
            .updateAlcoholProductEligibility();
        setAccountIsParentAccountMergedToFalse();
        Accounts.newInstance(accountsWithUpdatedDuplicateStatus())
            .updateRelatedDuplicateStatusFields();
        List<Account> changedAccessibilitiesAccounts = new List<Account>(
            (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.Accessibilities__c })
        );
        Accounts.newInstance(this.records).validateAccessibilities(changedAccessibilitiesAccounts);
        Accounts.newInstance(filterAccountsForPopulateDataVerificationStatus())
            .populateDataVerificationStatus();
        //TODO: Handle the scenario when Account segment is updated to SMB later.
        TimeZoneCalculationService.calculateTimeZone(recordsWithUpdatedTimeZone());
        Accounts.newInstance(this.records).processAccountsOnLeadConversion(existing);
        List<Account> accountsForDataVerificationStatusUpdate = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{
                    Account.Segment__c,
                    Account.RecordTypeId,
                    Account.BillingCountryCode
                }
            )
        );
        Accounts.newInstance(accountsForDataVerificationStatusUpdate)
            .updateDataVerificationStatus();
        AccountsService.updateRenewalOpportunityOnAccount(
            new List<Account>(
                (List<Account>) getChangedRecords(
                    new Set<SObjectField>{ Account.Partnership_Expiration_Date__c }
                )
            )
        );
    }

    /**
     * @description To set IsParentAccountMerged field as false
     */
    private void setAccountIsParentAccountMergedToFalse() {
        for (Account eachAccount : (List<Account>) this.records) {
            eachAccount.Is_Parent_Account_Merged__c = false;
        }
    }

    /**
     * @description Called to perform before insert processing
     */
    public override void onBeforeInsert() {
        Accounts.newInstance(this.records).populateFieldsOnChildAccountsByParent();
        stampPrimaryVerticalOnMerchantVertical(this.records);
        populateStoreName(this.records);
        Accounts.newInstance(this.records).validateAndNormalizePhoneNumberFormat();
        Accounts.newInstance(this.records).populateCurrency(new Map<Id, SObject>());
        Accounts.newInstance(this.records).updateMostRecentDateForStoreAccount();
        Accounts.newInstance(this.records).updateDoordashLegalEntityAndControlOfPrice(CREATE_EVENT);
        Accounts.newInstance(this.records)
            .updateDeveloperIDOrDeveloperIDBackend(new Map<Id, SObject>());
        Accounts.newInstance(this.records).updateAlcoholProductEligibility();
        Accounts.newInstance(this.records).updateRelatedDuplicateStatusFields();
        Accounts.newInstance(this.records).populateBVIDonStoreAccounts();
        Accounts.newInstance(this.records).validateAccessibilities(this.records);
        Accounts.newInstance(this.records).populateOwnerOnFranchiseAccount();
        Accounts.newInstance(filterAccountsForPopulateDataVerificationStatus())
            .populateDataVerificationStatus();
        //TODO: Handle the scenario when Account segment is updated to SMB later.
        Accounts.newInstance(this.records).populateSegmentOnAccount();
        Accounts.newInstance(this.records).associateBrandToStoreAccounts();
        Accounts.newInstance(this.records)
            .initiateDefaultOfDeckRankForEnterpriseAndMidmarket(this.records);
        TimeZoneCalculationService.calculateTimeZone(this.records);
        callRollUpServiceForMedalRankOnAfterInsert(this.records);
        Accounts.newInstance(this.records).updateDataVerificationStatus();
        Accounts.newInstance(this.records).setAccountLifecycleStatusOnSMBStoreAccounts();
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        callRollUpServiceOnAfterInsert();
        populateUltimateParentAccount(this.records);
        callRollupServiceForVerticalOnAfterInsert(this.records);
        Accounts.newInstance(this.records).updateFranchiseParentSubtype();
        Accounts.newInstance(this.records).initiateTaxIdEncryption(this.records);
        callPartnershipStatusRollUpServiceOnAfterInsertDeleteUndelete(this.records);
        AddressVerificationService.publishAddressVerificationEvent(this.records);
        List<Account> storeAccountsWithUpdatedBrands = new List<Account>(
            (List<Account>) getRecordsByFieldValue(Account.RecordtypeId, STORE_RECORD_TYPE_ID)
        );
        BrandAssociationsService.associateBrandsOnParentAccountsByBrandValueOnStoreAccounts(
            storeAccountsWithUpdatedBrands
        );
        //call brand and brand association creation method.
        Accounts.newInstance(this.records).invokeCreateBrandsAndBrandAssociation();
        Accounts.newInstance(this.records).publishDuplicateStatusNotifierEvent();
    }

    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        Accounts.newInstance(
                new List<Account>(
                    (List<Account>) getChangedRecords(
                        new Set<SObjectField>{ Account.Primary_Vertical__c }
                    )
                )
            )
            .initiateUpdateOnBusinessReferenceOnPrimaryVerticalChange();

        List<Account> changedFranchiseAccounts = new List<Account>(
            (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.Franchise_Parent__c })
        );
        Accounts.newInstance(changedFranchiseAccounts).updateFranchiseParentSubtype();

        List<Account> changedAccounts = new List<Account>(
            (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.ParentId })
        );

        // Adding check for not running logic for ProcessMergedAccChildRecIntegrationTest integration test related to active prime merge operation
        if (!System.isBatch()) {
            populateUltimateParentAccount(changedAccounts);
        }

        List<Account> accountsWithChangedOwnerId = new List<Account>(
            (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.OwnerId })
        );
        Accounts.newInstance(accountsWithChangedOwnerId)
            .publishNotifierEvent(EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER);
        callRollUpServiceOnAfterUpdate();
        AddressVerificationService.publishAddressVerificationEvent(
            accountsWithUpdatedAddressesOrStatus()
        );
        callRollupServiceForStoreVerticalOnAfterUpdate(existing);
        callAggregateVerticalsOnFranchiseAccounts(existing);
        List<Account> changedAccountsEligibleToTrickleDown = new List<Account>(
            (List<Account>) getChangedRecords(getFieldsToTriggerTrickleDown())
        );
        Accounts.newInstance(changedAccountsEligibleToTrickleDown)
            .initiateTrickleDownOnChildAccounts();
        callRollupServiceForVerticalOnAfterUpdate(existing);
        callPartnershipStatusRollUpServiceOnAfterUpdate();
        callUpdateOnRelatedWorkPlanAndWorkStepsOnStoreAccountActivation(existing);

        List<Account> accountsWithChangedCurrency = new List<Account>(
            (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.CurrencyIsoCode })
        );
        Accounts.newInstance(accountsWithChangedCurrency)
            .publishNotifierEvent(EVENT_TOPIC_UPDATE_ACCOUNT_CURRENCY_ON_OPPORTUNITY);
        /*
         * enables store level Work Plan indiactors on parent Work Order when
         * POS_Integration_Type__c/Tablet_Delivery_Method__c/Menu_UI_Type__c field
         * updates on store Account
         */
        List<Account> accountsWithChangedStoreLevelWorkPlansIndicatorFields = new List<Account>(
            (List<Account>) getChangedRecords(getStoreLevelWorkPlansIndicatorEligibilityFields())
        );
        Accounts.newInstance(accountsWithChangedStoreLevelWorkPlansIndicatorFields)
            .enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder();
        List<Account> accountsWithChangedStoreLevelPDOxIndicatorFields = new List<Account>(
            (List<Account>) getChangedRecords(getStoreLevelPDOxFields())
        );
        Accounts.newInstance(accountsWithChangedStoreLevelPDOxIndicatorFields)
            .updateStoreLevelPDOxIndicatorOnParentWorkOrder();

        List<Account> accountsWithChangedTaxId = new List<Account>(
            (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.TaxID__c })
        );
        Accounts.newInstance(this.records).initiateTaxIdEncryption(accountsWithChangedTaxId);
        Accounts.newInstance(accountsWithChangedCurrency).updateCurrencyOfPaymentAccount();
        BrandAssociationsService.associateBrandsOnParentAccountsByBrandValueOnStoreAccounts(
            getStoreAccountsWithChangedBrand()
        );
        Accounts.newInstance(accountsWithUpdatedNameBillingStreetBillingPostalCodeType())
            .publishDuplicateStatusNotifierEvent();

        List<Account> changedFranchiseAccountsWithStore = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{ Account.Total_Number_Of_Stores__c }
            )
        );
        Accounts.newInstance(changedFranchiseAccountsWithStore).updateCorporateAccountOnFranchise();

        if (Label.MINT_Upate_Users.contains(UserInfo.getUserId()) || System.Test.isRunningTest()) {
            Set<String> mintFieldAPINames = new Set<String>();
            for (
                FieldSetMember member : SObjectType.Account
                    .FieldSets.getMap()
                    .get('MINT_Histories')
                    .getFields()
            ) {
                mintFieldAPINames.add(member.getFieldPath());
            }

            List<Account> accountsWithMintFieldsUpdated = new List<Account>(
                (List<Account>) getChangedRecords(mintFieldAPINames)
            );

            Accounts.newInstance(accountsWithMintFieldsUpdated)
                .stampLastUpdatedByMintOnParentWorkOrder();
        }
        //added this method for propagating the Order Protocol updates to WO's and WPs' @LEM-11258 ticket
        callOrderProtocolUpdatesOnStoreAccount(existing);
        callRollUpServiceForMedalRankOnAfterUpdate(existing);
        Xrefs.newInstance(new List<Xref__c>{})
            .invokeBrandOnBusinessReferencesByXrefs(
                new Map<Id, Account>(
                        (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.Brand__c })
                    )
                    .keySet()
            );
     	Accounts.newInstance(
            new List<Account>(
              (List<Account>) getChangedRecords(
                new Set<SObjectField>{
                  Account.Self_Delivery__c,
                  Account.Order_Protocol__c,
                  Account.Alcohol_Product_Eligibility__c
                }
              )
            )
          )
          .invokeExperienceFieldUpdateOnStoreAccounts();
    }

    /**
     * @description Called to perform after delete processing
     */
    public override void onAfterDelete() {
        callRollUpServiceOnAfterDelete();
        callPartnershipStatusRollUpServiceOnAfterInsertDeleteUndelete(existingRecords.values());
        getAllWinningAccountRecords();
    }

    /**
     * @description Called to perform before delete processing
     */
    public override void onBeforeDelete() {
        Set<Id> contractSignedQuoteAccountIds = new Set<Id>();
        for (
            SBQQ__Quote__c contractSignedQuote : QuotesSelector.newInstance()
                .selectByAccounts(getRecordIds())
        ) {
            contractSignedQuoteAccountIds.add(contractSignedQuote.SBQQ__Account__c);
        }
        for (Account deletedAccount : (List<Account>) existingRecords.values()) {
            if (contractSignedQuoteAccountIds.contains(deletedAccount.Id)) {
                deletedAccount.addError(System.Label.Quote_Contract_Signed_Validation_Message);
            }
        }
    }

    /**
     * @description To get winning account id and publish platform event to update IsMerged Flag
     */
    public void getAllWinningAccountRecords() {
        Set<Id> winningAccountIds = new Set<Id>();
        for (Account deletedAccount : (List<Account>) existingRecords.values()) {
            if (String.isNotBlank(deletedAccount.MasterRecordId)) {
                winningAccountIds.add(deletedAccount.MasterRecordId);
            }
        }

        if (!winningAccountIds.isEmpty()) {
            NotifierEventsService.publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_UPDATE_ACCOUNT_ISMERGED_FLAG => JSON.serialize(winningAccountIds)
                }
            );
        }
    }

    /**
     * @description Called to perform before update processing
     */
    public override void onAfterUndelete() {
        populateUltimateParentAccount(this.records);
        callRollUpServiceOnAfterUndelete();
        Accounts.newInstance(this.records).updateFranchiseParentSubtype();
        callPartnershipStatusRollUpServiceOnAfterInsertDeleteUndelete(this.records);
        AddressVerificationService.publishAddressVerificationEvent(this.records);
    }

    /**
     * @description To invoke the batch method to poulate the ultimate parent
     * @param accounts
     */
    private void populateUltimateParentAccount(List<Account> accounts) {
        Map<Id, Account> mapAccounts = new Map<Id, Account>(accounts);
        if (mapAccounts.size() > 0) {
            UltimateParentUpdateBatchable batchable = new UltimateParentUpdateBatchable(
                mapAccounts.keySet()
            );
            AsyncBatchRunner.executeBatch(batchable);
        }
    }

    /**
     * @description To update address verification status and date
     * @return List<Account> - The list of updated accounts
     */
    private List<Account> accountsWithUpdatedAddresses() {
        return new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{
                    Account.BillingCountry,
                    Account.BillingCountryCode,
                    Account.BillingState,
                    Account.BillingStateCode,
                    Account.BillingCity,
                    Account.BillingPostalCode,
                    Account.BillingStreet
                }
            )
        );
    }

    /**
     * @description To update BVID, Menu UI Type, Primary Vertical on Store Account
     * @param existing
     */

    private void checkForMatchingBusinessReferenceRecords(Map<Id, SObject> existing) {
        List<Account> storeAccountList = new List<Account>();
        List<Account> changedAccounts = new List<Account>(
            (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.Business_Vertical__c })
        );
        for (Account acc : changedAccounts) {
            if (acc.RecordtypeId == STORE_RECORD_TYPE_ID) {
                storeAccountList.add(acc);
            }
        }
        Accounts.newInstance(storeAccountList).checkForMatchingBusinessReferenceRecords();
    }

    /**
     * @description To update address verification date
     * @param existing - The map of old requests
     */
    private void updateAddressVerificationDate(Map<Id, SObject> existing) {
        List<Account> changedAccounts = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{ Account.Address_Verification_Status__c }
            )
        );
        Accounts.newInstance(changedAccounts).updateAddressVerificationDate();
    }
    /**
     * @description To update Store Name
     * @param insertedAccounts
     */
    private void populateStoreName(List<Account> insertedAccounts) {
        Accounts.newInstance(insertedAccounts).populateStoreName();
    }

    /**
     * @description To check if account is updated for Store Name
     * @param existing
     */
    private void checkIfAccountUpdatedForStoreName(Map<Id, SObject> existing) {
        List<Account> changedStoreAccounts = new List<Account>(
            (List<Account>) getChangedRecords(new Set<SobjectField>{ Account.Name })
        );
        List<Account> storeAccountList = new List<Account>();
        for (Account accRec : changedStoreAccounts) {
            if (accRec.RecordtypeId == STORE_RECORD_TYPE_ID) {
                storeAccountList.add(accRec);
            }
        }
        if (
            !storeAccountList.isEmpty() &&
            checkPermissionToEditAccountFields(storeAccountList, System.Label.Edit_Store_Name_Label)
        ) {
            return;
        }
        List<Account> changedAccounts = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{
                    Account.BillingStreet,
                    Account.Merchant_Supplied_ID__c,
                    Account.ParentId,
                    Account.Brand__c,
                    Account.Is_Parent_Account_Merged__c,
                    Account.Mx_Onboarding_Link_Id__c
                }
            )
        );
        populateStoreName(changedAccounts);
    }
    /**
     * @description To call roll up service
     */
    private void callRollUpServiceOnBeforeUpdate() {
        Accounts.newInstance(this.records).calculateTotalNumberOfStores();
    }

    /**
     * @description To check if User is allowed to update store name
     * @param accountList
     * @param errorMsg
     * @return Boolean value
     **/
    private Boolean checkPermissionToEditAccountFields(List<Account> accountList, String errorMsg) {
        Boolean hasEditAccountFieldsPermission = FeatureManagement.checkPermission(
            'Edit_Account_Fields'
        );
        String profileName;
        List<Profile> profiles = ProfilesSelector.newInstance()
            .selectById(new Set<Id>{ UserInfo.getProfileId() });
        if (!profiles.isEmpty()) {
            profileName = profiles[0].Name;
        }
        //Automated Process user should be able to edit the account Name, since this update will be happening from MDS Sync Process
        //@LEM-11258 ticket
        Boolean isSystemAdmin = (profileName == SYSTEM_ADMINISTRATOR) ||
            (UserInfo.getName() == AUTOMATED_PROCESS_USER)
            ? true
            : false;
        if (hasEditAccountFieldsPermission || isSystemAdmin) {
            return true;
        }
        for (Account accountRec : accountList) {
            accountRec.addError(errorMsg);
        }
        return false;
    }

    /**
     * @description To call roll up service on franchise and parent account on account insert
     */
    private void callRollUpServiceOnAfterInsert() {
        Set<Id> parentIds = new Set<Id>();
        Set<Id> parentIdsForVertical = new Set<Id>();
        for (
            Account account : (List<Account>) getRecordsByFieldValue(
                Account.RecordTypeId,
                STORE_RECORD_TYPE_ID
            )
        ) {
            parentIds.add(account.ParentId);
            parentIdsForVertical.add(account.ParentId);
            parentIds.add(account.Franchise_Parent__c);
        }
        parentIds.remove(null);
        parentIdsForVertical.remove(null);
        AccountRollupService.publishStoreRollUpEvents(parentIds);
        AccountRollupService.publishStoreVerticalRollUpEvents(parentIds);
    }

    /**
     * @description To call roll up service on old/new franchise and old/new parent account on account update
     */
    private void callRollUpServiceOnAfterUpdate() {
        Set<Id> parentIds = new Set<Id>();
        List<Account> changedAccounts = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{
                    Account.RecordTypeId,
                    Account.Corporate_Owned_Store_Count__c,
                    Account.Franchise_Owned_Store_Count__c,
                    Account.Total_Number_Of_Active_Stores_Calculate__c,
                    Account.NumberOfMxStoresNotonDoorDashCalculate__c,
                    Account.TotalNoOfActiveMarketplaceStoreCalculate__c,
                    Account.TotalNoOfActiveDriveStoresCalculate__c,
                    Account.ParentId,
                    Account.Activation_Status__c,
                    Account.Franchise_Parent__c
                }
            )
        );
        for (Account account : changedAccounts) {
            Account oldAccount = (Account) existingRecords.get(account.Id);
            parentIds.add(account.ParentId);
            if (account.ParentId != oldAccount.ParentId) {
                parentIds.add(oldAccount.ParentId);
            }
            if (account.RecordTypeId != oldAccount.RecordTypeId) {
                parentIds.add(account.Franchise_Parent__c);
            }
            if (account.Franchise_Parent__c != oldAccount.Franchise_Parent__c) {
                parentIds.add(account.Franchise_Parent__c);
                parentIds.add(oldAccount.Franchise_Parent__c);
            }
        }
        parentIds.remove(null);
        AccountRollupService.publishStoreRollUpEvents(parentIds);
    }

    /**
     * @description To call roll up service on franchise and parent account on account delete
     */
    private void callRollUpServiceOnAfterDelete() {
        Set<Id> parentIds = new Set<Id>();
        for (Account account : (List<Account>) existingRecords.values()) {
            parentIds.add(account.ParentId);
            parentIds.add(account.Franchise_Parent__c);
        }
        parentIds.remove(null);
        AccountRollupService.publishStoreRollUpEvents(parentIds);
    }

    /**
     * @description To call roll up service on franchise and parent account on account undelete
     */
    private void callRollUpServiceOnAfterUndelete() {
        Set<Id> parentIds = new Set<Id>();
        for (Account account : (List<Account>) this.records) {
            parentIds.add(account.ParentId);
            parentIds.add(account.Franchise_Parent__c);
        }
        parentIds.remove(null);
        AccountRollupService.publishStoreRollUpEvents(parentIds);
    }

    /**
     * @description To get store level Work Plans indicator eligibility fields from custom label
     * in set of Sobject field format.
     * @return Set<SObjectField>
     */
    private Set<SObjectField> getStoreLevelWorkPlansIndicatorEligibilityFields() {
        Map<String, Schema.SObjectField> accountSobjectFields = Account.SObjectType.getDescribe()
            .fields.getMap();
        Set<SObjectField> storeLevelWorkPlansIndicatorFields = new Set<SObjectField>();
        for (
            String eachEligibleField : StaticConfigurationsSelector.newInstance()
                .getInstanceValue(STORE_LEVEL_WORK_PLANS_INDICATOR_FIELDS_STATIC_CONFIG)
                .Configuration_Value__c.split(System.Label.Separator)
        ) {
            storeLevelWorkPlansIndicatorFields.add(accountSobjectFields.get(eachEligibleField));
        }
        return storeLevelWorkPlansIndicatorFields;
    }

    /**
     * @description To check if parent Id is updated
     * @return List<Account>
     */
    private List<Account> recordsWithUpdatedParent() {
        return new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{ Account.ParentId, Account.Is_Parent_Account_Merged__c }
            )
        );
    }

    /**
     * @description To check if primary vertical is updated
     * @return List<Account>
     */
    private List<Account> recordsWithUpdatedVertical() {
        return new List<Account>(
            (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.Primary_Vertical__c })
        );
    }

    /**
     * @description To concateate Primary Vertical with the Merchant vertical values
     * @param insertedAccounts - List of Accounts.
     */
    private void stampPrimaryVerticalOnMerchantVertical(List<Account> insertedAccounts) {
        Accounts.newInstance(insertedAccounts).stampPrimaryVerticalOnMerchantVertical();
    }

    /**
     * @description To call roll up service for vertical rollup on after insert
     * @param insertedAccounts
     */
    private void callRollupServiceForVerticalOnAfterInsert(List<Account> insertedAccounts) {
        Set<Id> parentIds = new Set<Id>();
        for (
            Account newBusinessAccount : (List<Account>) getRecordsByFieldValue(
                Account.RecordTypeId,
                BUSINESS_RECORD_TYPE_ID
            )
        ) {
            if (newBusinessAccount.ParentId != null) {
                parentIds.add(newBusinessAccount.ParentId);
            }
        }
        AccountRollUpService.publishVerticalRollUpEvents(parentIds);
    }

    /**
     * @description To call address verification service after update
     * @return List<account>
     */
    private List<Account> accountsWithUpdatedAddressesOrStatus() {
        return new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{
                    Account.BillingCountry,
                    Account.BillingCountryCode,
                    Account.BillingState,
                    Account.BillingStateCode,
                    Account.BillingCity,
                    Account.BillingPostalCode,
                    Account.BillingStreet,
                    Account.Address_Verification_Status__c
                }
            )
        );
    }

    /**
     * @description To call roll up service for vertical rollup on after update
     * @param existing Map of old Accounts
     */
    private void callRollupServiceForVerticalOnAfterUpdate(Map<Id, SObject> existing) {
        Set<Id> parentIds = new Set<Id>();
        List<Account> changedParentAccounts = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{ Account.ParentId, Account.Additional_Verticals__c }
            )
        );
        for (Account acc : changedParentAccounts) {
            if (acc.RecordTypeId == BUSINESS_RECORD_TYPE_ID) {
                Account oldAccount = (Account) existing.get(acc.Id);
                if (oldAccount.ParentId != null) {
                    parentIds.add(oldAccount.ParentId);
                }
                if (acc.ParentId != null) {
                    parentIds.add(acc.ParentId);
                }
            }
        }
        AccountRollUpService.publishVerticalRollUpEvents(parentIds);
    }

    /**
     * @description To call roll up service for vertical rollup from Store Accounts on after update.
     * @param existing Map of old Accounts
     */
    private void callRollupServiceForStoreVerticalOnAfterUpdate(Map<Id, SObject> existing) {
        Set<Id> parentIds = new Set<Id>();
        Account oldAccount = new Account();
        List<Account> changedParentAccounts = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{ Account.ParentId, Account.Primary_Vertical__c }
            )
        );
        for (Account eachParentAccount : changedParentAccounts) {
            if (eachParentAccount.RecordTypeId == STORE_RECORD_TYPE_ID) {
                oldAccount = (Account) existing.get(eachParentAccount.Id);
                if (oldAccount.ParentId != null) {
                    parentIds.add(oldAccount.ParentId);
                }
                if (eachParentAccount.ParentId != null) {
                    parentIds.add(eachParentAccount.ParentId);
                }
            }
        }
        AccountRollUpService.publishStoreVerticalRollUpEvents(parentIds);
    }

    /**
     * @description To aggregate Verticals on Franchise Accounts after update
     * @param existing Map of old Accounts
     */
    private void callAggregateVerticalsOnFranchiseAccounts(Map<Id, SObject> existing) {
        Set<Id> franchiseParentIds = new Set<Id>();
        List<Account> changedFranchiseParentAccounts = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{ Account.Franchise_Parent__c, Account.Primary_Vertical__c }
            )
        );
        for (Account account : changedFranchiseParentAccounts) {
            if (account.RecordTypeId == STORE_RECORD_TYPE_ID) {
                Account oldAccount = (Account) existing.get(account.Id);
                if (oldAccount.Franchise_Parent__c != null) {
                    franchiseParentIds.add(oldAccount.Franchise_Parent__c);
                }
                if (account.Franchise_Parent__c != null) {
                    franchiseParentIds.add(account.Franchise_Parent__c);
                }
            }
        }
        AccountRollUpService.publishStoreVerticalRollUpToFranchiseEvents(franchiseParentIds);
    }

    /**
     * @description To call partnership roll up service on after insert/delete/undelete
     * @param modifiedAccounts
     */
    private void callPartnershipStatusRollUpServiceOnAfterInsertDeleteUndelete(
        List<Account> modifiedAccounts
    ) {
        Set<Id> parentIds = new Set<Id>();
        for (Account account : modifiedAccounts) {
            if (
                account.ParentId != null &&
                (account.RecordTypeId == BUSINESS_RECORD_TYPE_ID ||
                account.RecordTypeId == STORE_RECORD_TYPE_ID)
            ) {
                parentIds.add(account.ParentId);
            }
        }
        AccountRollUpService.publishPartnershipStatusRollUpEvents(parentIds);
    }

    /**
     * @description To call partnership roll up service on after update
     */
    private void callPartnershipStatusRollUpServiceOnAfterUpdate() {
        Set<Id> parentIds = new Set<Id>();
        List<Account> changedAccounts = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{
                    Account.ParentId,
                    Account.Partnership_Status__c,
                    Account.Activation_Status__c
                }
            )
        );
        for (Account account : changedAccounts) {
            if (
                account.RecordTypeId == BUSINESS_RECORD_TYPE_ID ||
                account.RecordTypeId == STORE_RECORD_TYPE_ID
            ) {
                Account oldAccount = (Account) existingRecords.get(account.Id);
                if (oldAccount.ParentId != null) {
                    parentIds.add(oldAccount.ParentId);
                }
                if (account.ParentId != null) {
                    parentIds.add(account.ParentId);
                }
            }
        }
        AccountRollUpService.publishPartnershipStatusRollUpEvents(parentIds);
    }

    /**
     * @description It gets Account records where Activation Status has changed
     * and calls instance of Accounts for further processing.
     * @JIRA# LEM-1161
     * @param existing - map of old Accounts
     */
    private void callUpdateOnRelatedWorkPlanAndWorkStepsOnStoreAccountActivation(
        Map<Id, SObject> existing
    ) {
        List<Account> accountsWithChangedActivationStatus = new List<Account>(
            (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.Activation_Status__c })
        );
        Accounts.newInstance(accountsWithChangedActivationStatus)
            .collectActivatedStoreAccountsAndTriggerUpdateOnRelatedWorkPlansAndWorkSteps();
    }

    /**
     * @description To update the currency based on the country on updation
     * @param existing
     */
    private void populateCurrencyOnBeforeUpdate(Map<Id, SObject> existing) {
        List<Account> changedCurrencyAccounts = new List<Account>(
            (List<Account>) getChangedRecords(new Set<SobjectField>{ Account.CurrencyISOCode })
        );
        if (
            !changedCurrencyAccounts.isEmpty() &&
            checkPermissionToEditAccountFields(
                changedCurrencyAccounts,
                System.Label.Edit_Currency_Error_Message
            )
        ) {
            return;
        }
        List<Account> changedAccounts = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{ Account.BillingCountry, Account.BillingCountryCode }
            )
        );
        Accounts.newInstance(changedAccounts).populateCurrency(existing);
    }

    /**
     * @description this method used to get changed records.
     * @return List<Account>
     */
    private List<Account> accountsWithUpdatedPhoneNumbers() {
        Set<SObjectField> phoneFields = SObjectDescribeService.getFieldsByDisplayType(
            Account.SObjectType,
            Schema.DisplayType.Phone
        );
        return new List<Account>((List<Account>) getChangedRecords(phoneFields));
    }

    /**
     * @description To update partnership status for store accounts
     */
    private void updateMostRecentDateForStoreAccount() {
        List<Account> changedActivationStatus = new List<Account>(
            (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.Activation_Status__c })
        );
        Accounts.newInstance(changedActivationStatus).updateMostRecentDateForStoreAccount();
    }

    /**
     * @description To update legal entity name where country, state, primary vertical has changed
     */
    private void updateDoordashLegalEntityOnUpdate() {
        List<Account> changedAccounts = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{
                    Account.BillingCountryCode,
                    Account.BillingStateCode,
                    Account.Primary_Vertical__c
                }
            )
        );
        Accounts.newInstance(changedAccounts).updateDoordashLegalEntityAndControlOfPrice(UPDATE_EVENT);
    }

    /**
     * @description To update Developer ID Backend when Developer ID has changed
     * @param existing - The map of old requests
     */
    private void updateDeveloperIdBackendOnUpdate(Map<Id, SObject> existing) {
        List<Account> changedAccounts = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{ Account.Developer_ID__c, Account.Developer_ID_Backend__c }
            )
        );
        Accounts.newInstance(changedAccounts).updateDeveloperIDOrDeveloperIDBackend(existing);
    }

    /**
     * @description It is used to get store Accounts with changed Brand value.
     * @return List<Account>
     */
    private List<Account> getStoreAccountsWithChangedBrand() {
        List<Account> storeAccountsWithChangedBrand = new List<Account>();
        for (
            Account eachStoreAccount : (List<Account>) getChangedRecords(
                new Set<SObjectField>{ Account.Brand__c, Account.Franchise_Parent__c }
            )
        ) {
            if (
                eachStoreAccount.RecordtypeId == STORE_RECORD_TYPE_ID &&
                eachStoreAccount.Segment__c != ACCOUNT_SEGMENT_SMB
            ) {
                storeAccountsWithChangedBrand.add(eachStoreAccount);
            }
        }
        return storeAccountsWithChangedBrand;
    }

    /**
     * @description To update Alcohol Product Eligibility when Country,Primary Vertical or Alcohol Eligibility has changed
     * @return List<Account>
     */
    private List<Account> accountsWithUpdatedCountryOrVerticalOrAlcoholEligibility() {
        List<Account> changedAccounts = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{
                    Account.BillingCountryCode,
                    Account.Primary_Vertical__c,
                    Account.Alcohol_Eligibility__c
                }
            )
        );
        return changedAccounts;
    }

    /**
     * @description To check if Duplicate Status is updated
     * @return List<Account>
     * @JIRA# LEM-3673
     */
    private List<Account> accountsWithUpdatedDuplicateStatus() {
        List<Account> changedAccounts = new List<Account>(
            (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.Duplicate_Status__c })
        );
        return changedAccounts;
    }

    /**
     * @description To check if Data Verification Status is not Verified
     * @return List<Account>
     * @JIRA# LEM-15901
     */
    private List<Account> filterAccountsForPopulateDataVerificationStatus() {
        List<Account> accountsToValidate = new List<Account>();

        for (Account eachAccount : (List<Account>) this.records) {
            if (eachAccount.Data_Verification_Status__c != VERIFIED) {
                accountsToValidate.add(eachAccount);
            }
        }
        return accountsToValidate;
    }

    /**
     * @description To check if Name, BillingStreet, BillingPostalCode, Type  is updated
     * @return List<Account>
     * @JIRA# LEM-3673
     */
    private List<Account> accountsWithUpdatedNameBillingStreetBillingPostalCodeType() {
        List<Account> changedAccounts = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{
                    Account.Name,
                    Account.BillingStreet,
                    Account.BillingPostalCode,
                    Account.Type
                }
            )
        );
        return changedAccounts;
    }

    /**
     * @description To get store level PDOx indicator eligibility fields from custom metadata
     * in set of Sobject field format.
     * @return Set<SObjectField>
     * @JIRA# LEM-5126
     */
    private Set<SObjectField> getStoreLevelPDOxFields() {
        Map<String, Schema.SObjectField> accountSobjectFields = Account.SObjectType.getDescribe()
            .fields.getMap();
        Set<SObjectField> storeLevelPDOxFields = new Set<SObjectField>();
        for (
            String eachEligibleField : StaticConfigurationsSelector.newInstance()
                .getInstanceValue(STORE_LEVEL_PDOX_FIELDS_INDICATOR_FIELDS_STATIC_CONFIG)
                .Configuration_Value__c.split(System.Label.Separator)
        ) {
            storeLevelPDOxFields.add(accountSobjectFields.get(eachEligibleField));
        }
        return storeLevelPDOxFields;
    }

    /**
     * @description It is used to collect Accounts with updated Time Zone backend field
     * @return List<Account>
     */
    private List<Account> recordsWithUpdatedTimeZone() {
        return new List<Account>(
            (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.Time_Zone_Backend__c })
        );
    }

    /**
     * @description To get fields to determine Account’s eligibitly for trickle down.
     * The currently configured fields:
     * 1. OwnerId
     * 2. Control_of_Price__c
     * @JIRA# LEM-12375
     * @return Set<SObjectField>
     */
    private Set<SObjectField> getFieldsToTriggerTrickleDown() {
        Map<String, Schema.SObjectField> accountSobjectFields = Account.SObjectType.getDescribe()
            .fields.getMap();
        Set<SObjectField> accountFields = new Set<SObjectField>();
        String fieldName;
        for (
            Schema.FieldSetMember eachFieldSetMember : (SObjectType.Account.FieldSets.Parent_Fields_To_Trickle_Down)
                .getFields()
        ) {
            fieldName = String.valueOf(eachFieldSetMember.getSObjectField());
            if (String.isNotBlank(accountSobjectFields.get(fieldName).toString())) {
                accountFields.add(accountSobjectFields.get(fieldName));
            }
        }
        return accountFields;
    }

    /**
     * @description To update Order Protocol on related WOs
     * @param existing Map of old Accounts
     */
    private void callOrderProtocolUpdatesOnStoreAccount(Map<Id, SObject> existing) {
        Map<Id, Account> accountMap = new Map<Id, Account>();
        List<Account> orderProtocolChangedAccounts = new List<Account>(
            (List<Account>) getChangedRecords(new Set<SObjectField>{ Account.Order_Protocol__c })
        );

        for (Account account : orderProtocolChangedAccounts) {
            if (account.RecordTypeId == STORE_RECORD_TYPE_ID) {
                Account oldAccount = (Account) existing.get(account.Id);
                if (oldAccount.MDS_Last_Synced__c <> account.MDS_Last_Synced__c) {
                    accountMap.put(account.Id, account);
                }
            }
        }
        OrderProtocolUpdatesService.processOrderProtocolUpdatesOnStoreAccounts(accountMap);
    }

    /* @description It calls roll up service for Medal Rank rollup on after insert
     * @param insertedAccounts
     */
    private void callRollUpServiceForMedalRankOnAfterInsert(List<Account> insertedAccounts) {
        Set<Id> parentIds = new Set<Id>();
        for (
            Account eachAccount : (List<Account>) getRecordsByFieldValue(
                Account.RecordTypeId,
                STORE_RECORD_TYPE_ID
            )
        ) {
            if (eachAccount.ParentId != null && eachAccount.Medal_Rank__c != null) {
                parentIds.add(eachAccount.ParentId);
            }
        }
        if (!parentIds.isEmpty()) {
            AccountRollUpService.publishMedalRankRollUpEvents(parentIds);
        }
    }

    /**
     * @description To call roll up service for Medal Rank rollup on after update
     * @param existing Map of old Accounts
     */
    private void callRollUpServiceForMedalRankOnAfterUpdate(Map<Id, SObject> existing) {
        Set<Id> parentIds = new Set<Id>();
        List<Account> changedStoreAccounts = new List<Account>(
            (List<Account>) getChangedRecords(
                new Set<SObjectField>{ Account.Medal_Rank__c, Account.ParentId }
            )
        );
        for (Account account : changedStoreAccounts) {
            if (account.RecordTypeId == STORE_RECORD_TYPE_ID && account.ParentId != null) {
                parentIds.add(account.ParentId);
            }
        }
        if (!parentIds.isEmpty()) {
            AccountRollUpService.publishMedalRankRollUpEvents(parentIds);
        }
    }
}