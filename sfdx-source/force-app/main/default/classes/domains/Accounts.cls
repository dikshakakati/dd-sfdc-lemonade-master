/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Domain Class for Account Object.
 * Suppressed warnings since domain class contains multiple public methods.
 */
@SuppressWarnings(
    'PMD.CyclomaticComplexity, PMD.ExcessivePublicCount,PMD.StdCyclomaticComplexity,PMD.ExcessiveClassLength,PMD.NcssTypeCount'
)
public inherited sharing class Accounts extends SObjects implements IAccounts {
    private static final String ACCOUNT_SOBJECT = 'Account';
    private static final String ACCOUNT_OWNER = 'OwnerId';
    private static final String ACCOUNT_SEGMENT = 'Segment__c';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    static final String ACTIVE = 'Active';
    private static final String AGGREGATE_BUSINESSACCOUNTNAME_FIELD_ALIAS = 'businessAccountName';
    private static final String AGGREGATE_BRANDNAME_FIELD_ALIAS = 'brandName';
    public static final String BUSINESS = 'Business';
    private static final Id BUSINESS_RECORD_TYPE_ID;
    private static final Id CHANNEL_PARTNER_RECORD_TYPE_ID;
    static final String BYPASS_ACCOUNT_ADDRESS_UPDATE_FUNCTIONALITY = 'Bypass_Account_Address_Update_Functionality';
    private static final String CORPORATE = 'Corporate';
    static final String DEACTIVATED = 'Deactivated';
    private static final String SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String EVENT_TOPIC_TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS = 'TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS';
    static final String FRANCHISEE = 'Franchisee';
    private static final String HOLDING_GROUP = 'Holding Group';
    private static final String KING_OF_SPADES_DECK_RANK = 'King of Spades';
    private static final String LOG_CURRENCY_SERVICE = 'Update Payment Account Currency';
    private static final String LOG_FRANCHISE_SERVICE = 'Corporate Account On Franchise';
    private static final String LOG_UPDATE_FRANCHISE_PARENT_SERVICE = 'Update Franchise Parent Subtype';
    private static final String LOG_TAX_ID_SERVICE = 'Tax Id Encryption';
    private static final String LOG_DOMAIN = 'Sales';
    private static final String SEGMENT_MID_MARKET = 'Mid-Market';
    static final String REJECTED = 'Rejected';
    public static final String STORE = 'Store';
    private static final Id STORE_RECORD_TYPE_ID;
    public static final String UNVERIFIED = 'Unverified';
    static final String VERIFIED = 'Verified';
    private static final String STOREFRONT_WORK_STEPS_STATUS_UPDATE = 'STOREFRONT_WORK_STEPS_STATUS_UPDATE';
    private static final String ALGORITHM_NAME = 'AES256';
    private static final String KEY_VALUE_NAME = 'AES-256';
    private static final Set<String> PRIMARY_VERTICAL_VALUES = new Set<String>{
        'Alcohol',
        'Grocery',
        'Convenience'
    };
    private Integer parentAccountIdsChunkSizeToTrickleDownAccountFields;
    private static final Set<String> COUNTRY_VALUES = new Set<String>{ 'AU', 'NZ' };
    private static final String COMMA = ',';
    private static final String CONTACT_SOBJECT_TYPE = 'Contact';
    private static final String CREATION_SOURCE_LEAD = 'Lead';
    private static final String CREATION_SOURCE_MANUAL = 'Manual';
    private static final String CREATION_SOURCE_SSMO = 'SSMO';
    private static final String CREATION_SOURCE_SELECTION_INTEL = 'Selection Intel';
    static final String DRY = 'Dry';
    static final String NOT_ELIGIBLE = 'Not Eligible';
    static final String DELIVERY_PICKUP_SELFDELIVERY = 'Delivery;Pickup;Self-Delivery';
    static final String DELIVERY_PICKUP = 'Delivery;Pickup';
    private static final String EVENT_TOPIC_UPDATE_DUPLICATE_STATUS = 'UPDATE_ACCOUNT_DUPLICATE_STATUS';
    private static final String FORWARDSLASH_R = '\r';
    private static final String FORWARDSLASH_N = '\n';
    private static final String FORWARDSLASH_R_N = '\r\n';
    private static final String DUPLICATE_CHECK_PAYLOAD_CHUNK_SIZE = 'Duplicate_Check_Payload_Chunk_Size';
    private static final String CURRENCY_CODE_USD = 'USD';
    private static final String MERCHANT = 'Merchant';
    private static final String AUTOMATED_PROCESS_USER = 'Automated Process';
    private static final String ROE_NO_ACCESS_ERROR_MESSAGE = 'You do not have access to change Rules of Engagement';
    private static final String MX_PORTAL = 'Mx Portal';
    private static final String LOG_FIELD_MAPPING_ERROR = 'Lead to Account conversion field mapping is empty.';
    private static final string TRIGGER_CONTEXT_AFTER = 'After';
    static {
        STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        CHANNEL_PARTNER_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Channel_Partner')
            .getRecordTypeId();
    }
    private static final Set<String> ACCOUNT_TYPES_TO_ALLOW_ACCOUNT_OWNER_AND_CONTROL_OF_PRICE_TRICKLE_DOWN = new Set<String>{
        CORPORATE
    };
    private static final Set<String> ACCOUNT_SEGMENT_TO_ALLOW_DECK_RANK_TRICKLE_DOWN = new Set<String>{
        ACCOUNT_SEGMENT_SMB
    };
    private static final Set<String> ACCOUNT_SEGMENT_TO_ALLOW_LEGAL_BUSINESS_NAME_TRICKLE_DOWN = new Set<String>{
        ACCOUNT_SEGMENT_SMB
    };
    private static final string ACCOUNT_LIFECYCLE_STATUS_CHURNED = 'Churned';
    private static final string ACCOUNT_LIFECYCLE_STATUS_NURTURE = 'Nurture';
    private static final string ACCOUNT_LIFECYCLE_STATUS_UNVETTED = 'Unvetted';
    private static final String ACCOUNT_CONTROL_OF_PRICE = 'Control_of_Price__c';
    private static final String ACCOUNT_TAX_ID = 'TaxID__c';
    private static final String ACCOUNT_DECK_RANK = 'Deck_Rank__c';
    private static final String ACCOUNT_LEGAL_BUSINESS_NAME = 'Legal_Business_Name__c';
    private static final string STORE_ACCOUNT_ACTIVATION_STATUS_ACTIVE = 'Active';
    private static final string STORE_ACCOUNT_ACTIVATION_STATUS_DEACTIVETED = 'Deactivated';
    private static final string STORE_ACCOUNT_ACTIVATION_STATUS_INACTIVE = 'Inactive';
    private static final Set<String> ACCOUNT_CREATION_SOURCE_ELIGIBLE_FOR_DATA_VERIFICATION_STATUS_UPDATE = new Set<String>{
        CREATION_SOURCE_LEAD,
        CREATION_SOURCE_MANUAL,
        CREATION_SOURCE_SELECTION_INTEL,
        CREATION_SOURCE_SSMO
    };
    private static final Set<String> ACCOUNT_BILLING_COUNTRY_CODE_ELIGIBLE_FOR_DATA_VERIFICATION_STATUS_UPDATE = new Set<String>{
        'US',
        'CA',
        'NZ',
        'AU'
    };
    private enum FIELDS_TO_UPDATE {
        SEGMENT,
        TAXID,
        OWNER,
        CONTROLOFPRICE,
        DECKRANK,
        LEGALBUSINESSNAME
    }
    public enum STORE_ACTIVATION_STATUS {
        ACTIVE,
        DEACTIVATED,
        INACTIVE
    }
    private static final Map<String, FIELDS_TO_UPDATE> FIELD_TO_UPDATE_MAPPINGS = new Map<String, FIELDS_TO_UPDATE>{
        ACCOUNT_CONTROL_OF_PRICE => FIELDS_TO_UPDATE.CONTROLOFPRICE,
        ACCOUNT_SEGMENT => FIELDS_TO_UPDATE.SEGMENT,
        ACCOUNT_TAX_ID => FIELDS_TO_UPDATE.TAXID,
        ACCOUNT_OWNER => FIELDS_TO_UPDATE.OWNER,
        ACCOUNT_DECK_RANK => FIELDS_TO_UPDATE.DECKRANK,
        ACCOUNT_LEGAL_BUSINESS_NAME => FIELDS_TO_UPDATE.LEGALBUSINESSNAME
    };
    private static final Map<String, STORE_ACTIVATION_STATUS> STORE_ACTIVATION_STATUS_MAPPINGS = new Map<String, STORE_ACTIVATION_STATUS>{
        STORE_ACCOUNT_ACTIVATION_STATUS_ACTIVE => STORE_ACTIVATION_STATUS.ACTIVE,
        STORE_ACCOUNT_ACTIVATION_STATUS_DEACTIVETED => STORE_ACTIVATION_STATUS.DEACTIVATED,
        STORE_ACCOUNT_ACTIVATION_STATUS_INACTIVE => STORE_ACTIVATION_STATUS.INACTIVE
    };
    private static final Map<String, String> COUNTRY_TO_COUNTRY_CODE = new Map<String, String>{
        'Australia' => 'AU',
        'Canada' => 'CA',
        'New Zealand' => 'NZ',
        'United States' => 'US'
    };
    private static final String CREATE_EVENT = 'CREATE';
    private static final String UPDATE_EVENT = 'UPDATE';
    private enum TRIGGER_EVENT {
        CREATE_EVENT,
        UPDATE_EVENT
    }
    private static final Map<String, TRIGGER_EVENT> TRIGGER_EVENT_MAPPINGS = new Map<String, TRIGGER_EVENT>{
        CREATE_EVENT => TRIGGER_EVENT.CREATE_EVENT,
        UPDATE_EVENT => TRIGGER_EVENT.UPDATE_EVENT
    };
    private static final String TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Trickle_Down_Parent_Account_Fields';
    private static final String TRIGGER_CONTEXT_BEFORE_UPDATE = 'before_update';
    fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();

    /**
     * @description This method is used to return the IAccounts interface
     * @param recordList - Accounts record list
     * @return IAccounts - Returns IAccounts Interface
     */
    public static IAccounts newInstance(List<Account> recordList) {
        return (IAccounts) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public Accounts(List<Account> sObjectList) {
        super(sObjectList, Schema.Account.SObjectType);
    }

    /**
     * @description Method to return all of the record Ids
     * @return Set of record ids
     */
    public Set<Id> getIds() {
        return new Map<Id, Account>((Account[]) getRecords()).keySet();
    }

    /**
     * @description It updates Mastered In Figment on Business Reference when Primary Vertical is updated on Account.
     */
    public void initiateUpdateOnBusinessReferenceOnPrimaryVerticalChange() {
        Set<Id> accountIds = getIds();
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }
        BusinessReferences.newInstance(
                BusinessReferencesSelector.newInstance().selectByBrandOwnerId(accountIds)
            )
            .updateMasteredInFigment(TRIGGER_CONTEXT_AFTER);
    }

    /**
     * @description It associates store Accounts with 'Brand' same as business Account
     * where business Account 'Segment' is "SMB".
     * @JIRA# LEM-13447
     */
    public void associateBrandToStoreAccounts() {
        Id parentAccountId;
        Set<Id> parentAccountIds = new Set<Id>();
        Map<Id, Id> parentAccountIdToBrandId = new Map<Id, Id>();
        List<Account> storeAccounts = new List<Account>();
        for (
            Account eachAccount : (List<Account>) getRecordsByFieldValue(
                Account.RecordtypeId,
                STORE_RECORD_TYPE_ID
            )
        ) {
            if (eachAccount.Segment__c == ACCOUNT_SEGMENT_SMB) {
                storeAccounts.add(eachAccount);
                parentAccountIds.add(eachAccount.ParentId);
            }
        }
        if (parentAccountIds.isEmpty()) {
            return;
        }
        for (
            Account eachAccount : AccountsSelector.newInstance()
                .getAccountsWithBrandAssociationsbyAccountIds(parentAccountIds)
        ) {
            if (eachAccount.Brand_Associations__r.size() == 1) {
                parentAccountIdToBrandId.put(
                    eachAccount.Id,
                    eachAccount.Brand_Associations__r[0].Brand_Name__c
                );
            }
        }
        for (Account eachStoreAccountToUpdate : storeAccounts) {
            parentAccountId = eachStoreAccountToUpdate.ParentId;
            if (
                parentAccountIdToBrandId.containsKey(parentAccountId) &&
                parentAccountIdToBrandId.get(parentAccountId) != null
            ) {
                //LEM-17379 : Code optimization
                eachStoreAccountToUpdate.Brand__c = parentAccountIdToBrandId.get(parentAccountId);
            }
        }
    }

    /**
     * @description Calculate total number of stores
     */
    public void calculateTotalNumberOfStores() {
        for (Account account : (List<Account>) getRecords()) {
            if (account.Corporate_Owned_Store_Count__c == null) {
                account.Corporate_Owned_Store_Count__c = 0;
            }
            if (account.Franchise_Owned_Store_Count__c == null) {
                account.Franchise_Owned_Store_Count__c = 0;
            }
            Decimal totalNumberOfStores =
                account.Corporate_Owned_Store_Count__c + account.Franchise_Owned_Store_Count__c;
            if (account.Total_Number_Of_Stores__c != totalNumberOfStores) {
                account.Total_Number_Of_Stores__c =
                    account.Corporate_Owned_Store_Count__c + account.Franchise_Owned_Store_Count__c;
            }
        }
    }

    /**
     * @description It collects store Accounts with Activation Status as "Active"
     * and triggers update on related WorkSteps.
     * @JIRA# LEM-2132
     */
    public void collectActivatedStoreAccountsAndTriggerUpdateOnRelatedWorkPlansAndWorkSteps() {
        Set<Id> activatedStoreAccountIds = new Set<Id>();
        for (Account eachAccount : (List<Account>) getRecords()) {
            if (
                eachAccount.RecordTypeId == STORE_RECORD_TYPE_ID &&
                eachAccount.Activation_Status__c == ACTIVE
            ) {
                activatedStoreAccountIds.add(eachAccount.Id);
            }
        }
        if (!activatedStoreAccountIds.isEmpty()) {
            NotifierEventsService.publishEvents(
                new Map<String, String>{
                    STOREFRONT_WORK_STEPS_STATUS_UPDATE => JSON.serialize(activatedStoreAccountIds)
                }
            );
        }
    }

    /**
     * @description It is used for enabling indiactor on parent Work Order for the
     * following Work Plans generation criteria when POS_Integration_Type__c or
     * Tablet_Delivery_Method__c field is updated on the store Account:
     * a. POS
     * b. Tablet
     * @JIRA# LEM-2683
     */
    public void enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder() {
        Set<Id> storeAccountIds = new Map<Id, Account>((List<Account>) getRecords()).keySet();
        // enables POS and Tablet Work Plan indicators on parent Work Order
        ParentWorkOrderSyncService.enableStoreLevelWorkPlanIndicatorsOnParentWorkOrderByStoreAccounts(
            storeAccountIds
        );
    }

    /**
     * @description Update franchise parent subtype
     */
    public void updateFranchiseParentSubtype() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(STORE)
            .getRecordTypeId();
        Set<Id> parentAccounts = new Set<Id>();
        // To set parentAccounts values if record type is store and franchise parent is not null
        for (Account updateAccount : (List<Account>) getRecords()) {
            if (
                updateAccount.RecordTypeId == accRecordType &&
                updateAccount.Franchise_Parent__c != null
            ) {
                parentAccounts.add(updateAccount.Franchise_Parent__c);
            }
        }
        if (parentAccounts.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        // To update subtype to franchise
        for (
            Account franchiseAccount : AccountsSelector.newInstance()
                .selectNonFranchiseeAccountsById(parentAccounts)
        ) {
            franchiseAccount.Type = FRANCHISEE;
            uow.registerDirty(franchiseAccount);
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_UPDATE_FRANCHISE_PARENT_SERVICE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description Update Address verification status and date
     */
    public void resetAddressAttributes() {
        if (
            FeatureManagement.checkPermission(BYPASS_ACCOUNT_ADDRESS_UPDATE_FUNCTIONALITY) ||
            UserInfo.getName() == AUTOMATED_PROCESS_USER
        ) {
            return;
        }
        for (Account accounts : (List<Account>) getRecords()) {
            accounts.Address_Verification_Status__c = UNVERIFIED;
            accounts.Coverage__c = null;
            accounts.Starting_Point__c = null;
            accounts.SubMarket__c = null;
            accounts.Starting_Point_ID__c = null;
            accounts.Alcohol_Eligibility__c = null;
            accounts.Time_Zone_Backend__c = null;
        }
    }

    /**
     * @description Update Address verification date
     */
    public void updateAddressVerificationDate() {
        for (Account accounts : (List<Account>) getRecords()) {
            if (
                accounts.Address_Verification_Status__c == VERIFIED ||
                accounts.Address_Verification_Status__c == REJECTED
            ) {
                accounts.Address_Verification_Date__c = System.now();
            }
        }
    }

    /**
     * @description will stamp the Last_Updated_By_MINT__c on parent work order of the store account
     */
    public void stampLastUpdatedByMintOnParentWorkOrder() {
        Set<Id> storeAccountIds = (new Map<Id, Account>(
                (List<Account>) getRecordsByFieldValue(Account.RecordtypeId, STORE_RECORD_TYPE_ID)
            ))
            .keyset();
        if (!storeAccountIds.isEmpty()) {
            List<WorkOrder> storeWorkOrders = WorkOrdersSelector.newInstance()
                .selectWorkOrdersWithParentWorkOrderIdByAccountIds(storeAccountIds);
            if (!storeWorkOrders.isEmpty()) {
                Set<Id> parentWorkOrderIds = new Set<Id>();
                for (WorkOrder wo : storeWorkOrders) {
                    parentWorkOrderIds.add(wo.ParentWorkOrderId);
                }
                WorkOrdersService.setLastUpdatedByMintToNow(parentWorkOrderIds);
            }
        }
    }

    /**
     * @description Concatenate Primary verical with merchant vertical on all Business accounts
     */
    public void stampPrimaryVerticalOnMerchantVertical() {
        Id recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS)
            .getRecordTypeId();
        //Iterate only on the business accounts to update the Merchant vertical
        for (
            Account acc : (List<Account>) getRecordsByFieldValue(Account.RecordtypeId, recordtypeId)
        ) {
            if (!String.isBlank(acc.Primary_Vertical__c)) {
                if (acc.Additional_Verticals__c == null) {
                    acc.Additional_Verticals__c = acc.Primary_Vertical__c;
                } else {
                    //Concatenate the Primary vertical value with the Merchant verticals only if it is unique
                    List<String> selections = acc.Additional_Verticals__c.split(';');
                    if (selections != null && !(selections.contains(acc.Primary_Vertical__c))) {
                        acc.Additional_Verticals__c += ';' + acc.Primary_Vertical__c;
                    }
                }
            }
        }
    }

    /**
     * @description Method to populate the Store Name
     */
    public void populateStoreName() {
        Set<Id> parentAccountIds = new Set<Id>();
        Set<Id> brandIds = new Set<Id>();
        List<Account> storeWithBrandOrParentAccounts = new List<Account>();
        for (
            Account storeAccount : (List<Account>) getRecordsByFieldValue(
                Account.RecordtypeId,
                STORE_RECORD_TYPE_ID
            )
        ) {
            if (storeAccount.parentId != null || storeAccount.Brand__c != null) {
                parentAccountIds.add(storeAccount.ParentId);
                brandIds.add(storeAccount.Brand__c);
                storeWithBrandOrParentAccounts.add(storeAccount);
            }
        }
        if (parentAccountIds.isEmpty() && brandIds.isEmpty()) {
            return;
        }
        Map<Id, Account> accountToIdMap = new Map<Id, Account>(
            AccountsSelector.newInstance().selectById(parentAccountIds)
        );
        Map<Id, Brand__c> brandToIdMap = new Map<Id, Brand__c>(
            BrandsSelector.newInstance().selectById(brandIds)
        );
        for (Account store : storeWithBrandOrParentAccounts) {
            String brandName = brandToIdMap.get(store.Brand__c) != null
                ? (String) brandToIdMap.get(store.Brand__c).get('Name')
                : '';
            String parentAccountName = accountToIdMap.get(store.ParentId) != null
                ? (String) accountToIdMap.get(store.ParentId).get('Name')
                : '';
            String fieldVal = String.isBlank(brandName) ? parentAccountName : brandName;
            if (
                (String.isBlank(store.Merchant_Supplied_ID__c)) &&
                (String.isBlank(store.BillingStreet))
            ) {
                store.Name = fieldVal;
            } else if (!(String.isBlank(store.Merchant_Supplied_ID__c))) {
                store.Name = fieldVal + ' - ' + store.Merchant_Supplied_ID__c;
            } else {
                store.Name = fieldVal + ' - ' + store.BillingStreet;
            }
        }
    }

    /**
     * @description This method used to validate phone number.
     */
    public void validateAndNormalizePhoneNumberFormat() {
        Set<Schema.SObjectField> phoneFields = SObjectDescribeService.getFieldsByDisplayType(
            Account.SObjectType,
            schema.displaytype.Phone
        );
        List<Country_Attributes_Mapping__mdt> countryAttributes = CountryAttributesMappingSelector.newInstance()
            .getAllValues();
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : countryAttributes) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        for (Account objAccount : (List<Account>) getRecordsWithNotBlankFieldValues(phoneFields)) {
            for (SObjectField phoneField : phoneFields) {
                if (objAccount.get(phoneField) != null) {
                    PhoneValidation.validationOnPhoneFields(
                        objAccount,
                        phoneField,
                        countryToCountryAttributes,
                        phoneCodesToCountryAttributes,
                        null
                    );
                }
            }
        }
    }
    /**
     * @description populate Menu UI Type and Primary Vertical
     */

    public void populateBVIDonStoreAccounts() {
        List<Account> storeAccounts = new List<Account>();
        for (
            Account acc : (List<Account>) getRecordsByFieldValue(
                Account.RecordtypeId,
                STORE_RECORD_TYPE_ID
            )
        ) {
            if (acc.Business_Vertical__c != null) {
                storeAccounts.add(acc);
            }
        }
        if (!storeAccounts.isEmpty()) {
            //LEM-17379 : Code optimization
            BusinessVerticalsService.populateBusinessVerticalDetails(storeAccounts);
        }
    }

    /**
     * @description Check if updated BVID matches at least 1 active
     *  business ref by querying xref records
     * If they do not match, throw error message
     */
    public void checkForMatchingBusinessReferenceRecords() {
        Map<Id, Id> storeAccountBusinessVertical = new Map<Id, Id>();
        Set<Id> accountsWithMismatchedBusinessVertical = new Set<Id>();
        Map<Id, Account> storeAccountMap = new Map<Id, Account>();
        List<Account> storeAccountsToPopulate = new List<Account>();

        for (Account storeAccount : (List<Account>) getRecords()) {
            if (storeAccount.Business_Vertical__c != null) {
                storeAccountBusinessVertical.put(
                    storeAccount.id,
                    storeAccount.Business_Vertical__c
                );
                storeAccountMap.put(storeAccount.id, storeAccount);
            }
        }
        if (storeAccountBusinessVertical.isEmpty()) {
            return;
        }
        List<Xref__c> xrefList = XrefsSelector.newInstance()
            .selectBySalesforceAccountName(storeAccountBusinessVertical.keySet());
        Map<Id, List<Id>> idToBVIDMap = new Map<Id, List<Id>>();

        if (!xrefList.isEmpty()) {
            for (Xref__c xref : xrefList) {
                if (
                    !idToBVIDMap.containsKey(xref.Salesforce_Account_Name__c) &&
                    (xref.Business_Reference__r.Business_Vertical__c != null)
                ) {
                    idToBVIDMap.put(xref.Salesforce_Account_Name__c, new List<Id>());
                }
                if (!idToBVIDMap.isEmpty()) {
                    idToBVIDMap.get(xref.Salesforce_Account_Name__c)
                        .add(xref.Business_Reference__r.Business_Vertical__c);
                }
            }
        }
        for (Id storeAccountId : storeAccountBusinessVertical.keySet()) {
            if (idToBVIDMap.containsKey(storeAccountId)) {
                List<Id> bizIdList = idToBVIDMap.get(storeAccountId);
                Id storeAccountBizId = storeAccountBusinessVertical.get(storeAccountId);
                if (!bizIdList.contains(storeAccountBizId)) {
                    accountsWithMismatchedBusinessVertical.add(storeAccountId);
                } else {
                    storeAccountsToPopulate.add(storeAccountMap.get(storeAccountId));
                }
            }
        }
        for (Account storeAccount : (List<Account>) getRecords()) {
            if (accountsWithMismatchedBusinessVertical.contains(storeAccount.Id)) {
                storeAccount.addError(System.Label.Store_Account_BIVD_Mismatch_Error);
            }
        }

        if (!storeAccountBusinessVertical.isEmpty()) {
            BusinessVerticalsService.populateBusinessVerticalDetails(storeAccountsToPopulate);
        }
    }

    /**
     * @description To update most recent date for store accounts
     */
    public void updateMostRecentDateForStoreAccount() {
        if (FeatureManagement.checkPermission(BYPASS_ACCOUNT_ADDRESS_UPDATE_FUNCTIONALITY)) {
            return;
        }
        for (
            Account storeAccount : (List<Account>) getRecordsByFieldValue(
                Account.RecordtypeId,
                STORE_RECORD_TYPE_ID
            )
        ) {
            if (storeAccount.Activation_Status__c == ACTIVE) {
                storeAccount.Most_Recent_Activation_Date__c = System.now();
            } else if (storeAccount.Activation_Status__c == DEACTIVATED) {
                //LEM-17379 : Code optimization
                storeAccount.Most_Recent_Deactivation_Date__c = System.now();
            }
        }
    }

    /**
     * @description Method to populate the currency based on the country
     * @param oldAccounts
     */
    public void populateCurrency(Map<Id, SObject> oldAccounts) {
        Map<String, String> countryToCurrencyCode = new Map<String, String>();
        Map<String, String> countryCodeToCurrencyCode = new Map<String, String>();
        String currencyCode;

        for (
            Country_Attributes_Mapping__mdt countryRecord : CountryAttributesMappingSelector.newInstance()
                .getAllValues()
        ) {
            countryCodeToCurrencyCode.put(
                countryRecord.Country_Code__c,
                countryRecord.Currency_Code__c
            );
            countryToCurrencyCode.put(countryRecord.Country__c, countryRecord.Currency_Code__c);
        }
        for (Account eachAccount : (List<Account>) getRecords()) {
            Account oldAccount = (Account) oldAccounts.get(eachAccount.Id);
            currencyCode = CURRENCY_CODE_USD;
            if (oldAccount?.BillingCountry != eachAccount.BillingCountry) {
                currencyCode = countryToCurrencyCode.get(eachAccount.BillingCountry);
            } else if (oldAccount?.BillingCountryCode != eachAccount.BillingCountryCode) {
                currencyCode = countryCodeToCurrencyCode.get(eachAccount.BillingCountryCode);
            }
            eachAccount.CurrencyIsoCode = currencyCode;
        }
    }

    /**
     * @description Publish Notifier platform event using passed topic and prepared JSON payload.
     * @param topicName
     */
    public void publishNotifierEvent(String topicName) {
        Set<Id> accountIds = new Set<Id>();
        for (Account eachAccount : (List<Account>) getRecords()) {
            accountIds.add(eachAccount.Id);
        }
        if (accountIds.isEmpty()) {
            return;
        }
        NotifierEventsService.publishEvents(
            new Map<String, String>{ topicName => JSON.serialize(accountIds) }
        );
    }

    /**
     * @description Publish Duplicate Status Notifier platform event with batch size as 50.
     */
    public void publishDuplicateStatusNotifierEvent() {
        Set<Id> accountIds = new Set<Id>();
        for (Account eachAccount : (List<Account>) getRecords()) {
            if (
                eachAccount.Segment__c == ACCOUNT_SEGMENT_SMB &&
                eachAccount.Marketplace_Nintex_Id__c == null &&
                eachAccount.Drive_Nintex_Id__c == null
            ) {
                continue;
            }
            accountIds.add(eachAccount.Id);
        }
        if (accountIds.isEmpty()) {
            return;
        }
        Integer duplicateCheckPayloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(DUPLICATE_CHECK_PAYLOAD_CHUNK_SIZE)
                .Configuration_Value__c
        );

        NotifierEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_UPDATE_DUPLICATE_STATUS => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    accountIds,
                    duplicateCheckPayloadChunkSize
                )
            }
        );
    }

    /**
     * @description To populate legal entity name on account
     * @param triggerContext
     */
    public void updateDoordashLegalEntityAndControlOfPrice(String triggerContext) {
        List<Account> accountsToEvaluate = (List<Account>) getRecords();
        if (accountsToEvaluate == null || accountsToEvaluate.isEmpty()) {
            return;
        }
        Boolean legalEntityPopulated;

        Map<String, Legal_Entity_Mapping__mdt> mapLegalEntityToMetadata = new Map<String, Legal_Entity_Mapping__mdt>();
        for (
            Legal_Entity_Mapping__mdt mappingRecord : LegalEntityMappingSelector.newInstance()
                .getAllValues()
        ) {
            mapLegalEntityToMetadata.put(mappingRecord.DeveloperName, mappingRecord);
        }

        for (Account account : (List<Account>) getRecords()) {
            legalEntityPopulated = false;
            for (String developerName : mapLegalEntityToMetadata.keySet()) {
                List<String> primaryVerticalValues = mapLegalEntityToMetadata.get(developerName)
                    .Primary_Vertical__c
                    ?.split(';');
                switch on TRIGGER_EVENT_MAPPINGS.get(triggerContext){
                    when CREATE_EVENT {
                        if (
                            (account.BillingCountryCode ==
                            mapLegalEntityToMetadata.get(developerName).Label ||
                            COUNTRY_TO_COUNTRY_CODE.get(account.BillingCountry) ==
                            mapLegalEntityToMetadata.get(developerName).Label) &&
                            isEligibleToPopulateLegalEntity(
                                account,
                                mapLegalEntityToMetadata,
                                developerName,
                                primaryVerticalValues
                            )
                        ) {
                            account.DoorDash_Legal_Entity__c = mapLegalEntityToMetadata.get(developerName)
                                .Legal_Entity_Name__c;
                            legalEntityPopulated = true;
                            break;
                        }
                    }
                    when UPDATE_EVENT {
                        if (
                            account.BillingCountryCode ==
                            mapLegalEntityToMetadata.get(developerName).Label &&
                            isEligibleToPopulateLegalEntity(
                                account,
                                mapLegalEntityToMetadata,
                                developerName,
                                primaryVerticalValues
                            )
                        ) {
                            account.DoorDash_Legal_Entity__c = mapLegalEntityToMetadata.get(developerName)
                                .Legal_Entity_Name__c;
                            legalEntityPopulated = true;
                            break;
                        }
                    }
                }
            }

            if (!legalEntityPopulated) {
                account.DoorDash_Legal_Entity__c = null;
            }
            if (
                account.Record_Type_Name__c == BUSINESS &&
                (account.DoorDash_Legal_Entity__c == null ||
                account.DoorDash_Legal_Entity__c != System.Label.DoorDash_Legal_Entity)
            ) {
                account.Control_of_price__c = MERCHANT;
            }
        }
    }

    /**
     * @description It checks whether the metadata record satisfies the criteria
     * to populate the Doordash Legal Entity on the passed account.
     * @param accountInstance
     * @param mapLegalEntityToMetadata
     * @param developerName
     * @param primaryVerticalValues
     * @return Boolean
     */
    private Boolean isEligibleToPopulateLegalEntity(
        Account accountInstance,
        Map<String, Legal_Entity_Mapping__mdt> mapLegalEntityToMetadata,
        String developerName,
        List<String> primaryVerticalValues
    ) {
        return
        (
            accountInstance.Record_Type_Name__c ==
            mapLegalEntityToMetadata.get(developerName).Record_Type_Name__c &&
            ((mapLegalEntityToMetadata.get(developerName).Billing_State_Code__c == null &&
            mapLegalEntityToMetadata.get(developerName).Primary_Vertical__c == null) ||
            (accountInstance.BillingStateCode != null &&
            accountInstance.BillingStateCode ==
            mapLegalEntityToMetadata.get(developerName).Billing_State_Code__c) ||
            (primaryVerticalValues != null &&
            primaryVerticalValues.contains(accountInstance.Primary_Vertical__c)))
        );
    }

    /**
     * @description To update Developer ID or Developer ID Backend
     * @param oldAccountRecords
     * @JIRA# LEM-3061
     */
    public void updateDeveloperIDOrDeveloperIDBackend(Map<Id, SObject> oldAccountRecords) {
        for (Account account : (List<Account>) getRecords()) {
            Account oldAccount = (Account) oldAccountRecords.get(account.Id);
            String developerIdBackend = account.Developer_ID_Backend__c;
            String developerId = account.Developer_ID__c;
            if (
                developerIdBackend != null &&
                (oldAccount == null || (oldAccount.Developer_ID_Backend__c != developerIdBackend))
            ) {
                Map<String, String> developerIDToDeveloperIDBackendMap = getDeveloperIDPicklistValues();
                account.Developer_ID__c = developerIDToDeveloperIDBackendMap.get(
                    developerIdBackend
                );
            } else if (
                developerId != null &&
                (oldAccount == null || (oldAccount.Developer_ID__c != developerId))
            ) {
                List<String> developerIdSplit = developerId.split(' - ');
                account.Developer_ID_Backend__c = developerIdSplit.get(developerIdSplit.size() - 1);
            }
        }
    }

    /**
     * @description To get Developer ID Picklist Values
     * @return Map<String, String>
     * @JIRA# LEM-3061
     */
    private Map<String, String> getDeveloperIDPicklistValues() {
        Map<String, String> developerIDToDeveloperIDBackendMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Account.Developer_ID__c.getDescribe();
        List<Schema.PicklistEntry> developerIdPicklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistVal : developerIdPicklistValues) {
            List<String> developerIdSplit = picklistVal.getValue().split(' - ');
            developerIDToDeveloperIDBackendMap.put(
                developerIdSplit.get(developerIdSplit.size() - 1),
                picklistVal.getValue()
            );
        }
        return developerIDToDeveloperIDBackendMap;
    }

    /**
     * @description It initiates Tax Id field encryption process on the received Account Ids
     * in future method.
     * @JIRA# LEM-2144
     * @param accounts
     */
    public void initiateTaxIdEncryption(List<Account> accounts) {
        if (accounts.isEmpty()) {
            return;
        }
        Set<Id> accountIds = (new Map<Id, SObject>(accounts)).keySet();
        if (!System.isFuture()) {
            setEncryptedTaxIdOnAccounts(accountIds);
        }
    }

    /**
     * @description It encrypts Tax Id field using encryptWithManagedIV method of crypto class
     * and stores the encrypted value in Encrypted_Tax_Id__c field of the received Account Ids.
     * @JIRA# LEM-2144
     * @param accountIds
     */
    @future
    private static void setEncryptedTaxIdOnAccounts(Set<Id> accountIds) {
        List<Encrypted_Value__c> encryptedKeyValue = (List<Encrypted_Value__c>) (EncryptedValuesSelector.newInstance()
            .selectByName(KEY_VALUE_NAME));
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        if (encryptedKeyValue.isEmpty()) {
            return;
        }
        Blob encryptionKey = EncodingUtil.base64Decode(encryptedKeyValue[0].Value__c);
        Blob encryptedTaxIdBlob;
        for (Account eachAccount : AccountsSelector.newInstance().selectById(accountIds)) {
            if (eachAccount.TaxID__c != null) {
                encryptedTaxIdBlob = encryptValue(
                    ALGORITHM_NAME,
                    encryptionKey,
                    eachAccount.TaxID__c.right(4)
                );
                eachAccount.Encrypted_Tax_Id__c = EncodingUtil.base64Encode(encryptedTaxIdBlob);
                uow.registerDirty(eachAccount);
            }
        }
        try {
            uow.commitWork();
        } catch (Exception accountUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(accountUpdateException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_TAX_ID_SERVICE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(accountUpdateException)
            );
        }
    }

    /**
     * @description To update the currency of the payment account when account currency is updated
     * @JIRA# LEM-3121
     */
    public void updateCurrencyOfPaymentAccount() {
        List<Account> eligibleAccounts = (List<Account>) getRecords();
        if (eligibleAccounts == null || eligibleAccounts.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            Payment_Account__c paymentAccount : PaymentAccountsSelector.newInstance()
                .selectRelatedBusinessAccounts(new Map<Id, Account>(eligibleAccounts).keySet())
        ) {
            paymentAccount.CurrencyIsoCode = paymentAccount.Business_Account__r.CurrencyIsoCode;
            uow.registerDirty(paymentAccount);
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_CURRENCY_SERVICE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description It encrypts input value using crypto class with specific algorithm and key.
     * @JIRA# LEM-2144
     * @param algorithm
     * @param encryptionKey
     * @param valueToEncrypt
     * @return encryptedBlobTypeValue
     */
    private static Blob encryptValue(String algorithm, Blob encryptionKey, String valueToEncrypt) {
        return Crypto.encryptWithManagedIV(algorithm, encryptionKey, Blob.valueOf(valueToEncrypt));
    }

    /**
     * @description To update Alcohol Product Eligibility
     * @JIRA# LEM-3434
     */
    public void updateAlcoholProductEligibility() {
        for (Account account : (List<Account>) getRecords()) {
            if (
                COUNTRY_VALUES.contains(account.BillingCountryCode) &&
                (PRIMARY_VERTICAL_VALUES.contains(account.Primary_Vertical__c) ||
                (!(PRIMARY_VERTICAL_VALUES.contains(account.Primary_Vertical__c)) &&
                account.Alcohol_Eligibility__c != DRY))
            ) {
                account.Alcohol_Product_Eligibility__c = DELIVERY_PICKUP;
            } else if (
                !COUNTRY_VALUES.contains(account.BillingCountryCode) &&
                (PRIMARY_VERTICAL_VALUES.contains(account.Primary_Vertical__c) ||
                (!(PRIMARY_VERTICAL_VALUES.contains(account.Primary_Vertical__c)) &&
                account.Alcohol_Eligibility__c != DRY))
            ) {
                account.Alcohol_Product_Eligibility__c = DELIVERY_PICKUP_SELFDELIVERY;
            } else {
                account.Alcohol_Product_Eligibility__c = NOT_ELIGIBLE;
            }
        }
    }

    /**
     * @description To update duplicate status modified by and duplicate status modified at
     * @JIRA# LEM-3673
     */
    public void updateRelatedDuplicateStatusFields() {
        for (Account eachAccount : (List<Account>) getRecords()) {
            eachAccount.Duplicate_Status_Modified_At__c = System.now();
            eachAccount.Duplicate_Status_Modified_By__c = eachAccount.LastModifiedById;
        }
    }

    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return Accounts - List of Accounts
         */
        public SObjects construct(List<Object> objectList) {
            if (Accounts.constructorMock != null) {
                return (SObjects) Accounts.constructorMock.construct(objectList);
            }
            return new Accounts((List<SObject>) objectList);
        }
    }

    /**
     * @description It is used to update store level PDOx indicators on parent Work Order.
     * @JIRA# LEM-5126
     */
    public void updateStoreLevelPDOxIndicatorOnParentWorkOrder() {
        ParentWorkOrderSyncService.updateStoreLevelPDOxIndicatorOnParentWorkOrder(
            new Map<Id, Account>((List<Account>) getRecords()).keySet()
        );
    }

    /**
     * @description It is used to update Corporate Accounts Ids on Franchise Account.
     * @JIRA# LEM-6845
     */
    public void updateCorporateAccountOnFranchise() {
        Set<Id> franchiseAccounts = new Set<Id>();
        Map<Id, Set<Id>> corporateMap = new Map<Id, Set<Id>>();
        List<Account> updateFranchiseList = new List<Account>();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        for (Account account : (List<Account>) getRecordsByFieldValue(Account.Type, FRANCHISEE)) {
            franchiseAccounts.add(account.Id);
            if (account.Total_Number_Of_Stores__c == 0) {
                Account updateFranchise = new Account(
                    Id = account.id,
                    Corporate_Account_Ids__c = ''
                );
                updateFranchiseList.add(updateFranchise);
            }
        }
        if (franchiseAccounts.isEmpty()) {
            return;
        }
        uow.registerDirty(updateFranchiseList);
        // To update Corporate Account Id to franchise Account
        for (
            Account franchiseAccount : AccountsSelector.newInstance()
                .getCorporateAccountIdsByFranchiseAccount(franchiseAccounts)
        ) {
            if (!corporateMap.containsKey(franchiseAccount.Franchise_Parent__c)) {
                corporateMap.put(
                    franchiseAccount.Franchise_Parent__c,
                    new Set<Id>{ franchiseAccount.ParentId }
                );
            } else if (
                (corporateMap.get(franchiseAccount.Franchise_Parent__c).size() <
                Integer.valueOf(System.Label.Corporate_Account_Ids_Limit))
            ) {
                corporateMap.get(franchiseAccount.Franchise_Parent__c)
                    .add(franchiseAccount.ParentId);
            }
        }

        for (Id franchiseId : corporateMap.keySet()) {
            Account updateCorporateId = new Account(
                Id = franchiseId,
                Corporate_Account_Ids__c = string.join(
                    new List<Id>(corporateMap.get(franchiseId)),
                    ';'
                )
            );
            updateFranchiseList.add(updateCorporateId);
        }
        uow.registerDirty(updateFranchiseList);
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));

            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_FRANCHISE_SERVICE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description It is used to populate the given defined fields on the child (Business/Store)
     * accounts from the associated parent account.
     * @JIRA# LEM-11918
     */
    public void populateFieldsOnChildAccountsByParent() {
        List<Account> childAccounts = new List<Account>(
            (List<Account>) getRecordsByFieldValues(
                Account.RecordtypeId,
                new Set<Object>{ STORE_RECORD_TYPE_ID, BUSINESS_RECORD_TYPE_ID }
            )
        );
        if (childAccounts.isEmpty()) {
            return;
        }
        Map<Id, Account> parentAccounts = collectParentAccounts(childAccounts);
        Map<Id, Account> franchiseParentAccounts = collectFranchiseParentAccounts(childAccounts);
        for (Account eachChildAccount : childAccounts) {
            if (
                String.isNotBlank(eachChildAccount.ParentId) &&
                parentAccounts?.containsKey(eachChildAccount.ParentId)
            ) {
                applyFieldValuesByParent(
                    parentAccounts.get(eachChildAccount.ParentId),
                    eachChildAccount,
                    franchiseParentAccounts.get(eachChildAccount.Franchise_Parent__c)
                );
            }
        }
    }

    /**
     * @description It initiates the trickle down of eligible parent account's fields
     * on child accounts.
     * The currently configured fields:
     * 1. OwnerId
     * 2. Control_of_Price__c
     * @JIRA# LEM-12375
     */
    public void initiateTrickleDownOnChildAccounts() {
        Set<Id> eligibleParentAccountIds = new Set<Id>();
        for (Account eachParentAccount : (List<Account>) getRecords()) {
            if (isEligibleToTrickleDownAccountOwnershipAndControlOfPrice(eachParentAccount)) {
                eligibleParentAccountIds.add(eachParentAccount.Id);
            }
            if (isEligibleToTrickleDownDeckRank(eachParentAccount)) {
                eligibleParentAccountIds.add(eachParentAccount.Id);
            }
        }
        if (eligibleParentAccountIds.isEmpty()) {
            return;
        }
        publishNotifierEventToTriggerTrickleDown(eligibleParentAccountIds);
    }

    /**
     * @description It checks whether the child account satisfies the criteria to copy the
     * legal business name from parent account or franchise parent account
     * @param accountInstance
     * @return Boolean
     */
    private Boolean isEligibleToTrickleDownLegalBusinessName(Account accountInstance) {
        return (accountInstance.Record_Type_Name__c == STORE &&
        accountInstance.Mx_Onboarding_Link_Id__c == null &&
        ACCOUNT_SEGMENT_TO_ALLOW_LEGAL_BUSINESS_NAME_TRICKLE_DOWN.contains(
            accountInstance.Segment__c
        ));
    }

    /**
     * @description It defaults the Deck Rank as King of Spades for Accounts having
     * Enterprise and Mid-Market segment.
     * @JIRA# LEM-14098
     * @param accountsToBeDefaulted
     */
    public void initiateDefaultOfDeckRankForEnterpriseAndMidMarket(
        List<Account> accountsToBeDefaulted
    ) {
        for (Account eachParentAccount : accountsToBeDefaulted) {
            if (
                (eachParentAccount.Segment__c == SEGMENT_ENTERPRISE ||
                eachParentAccount.Segment__c == SEGMENT_MID_MARKET) &&
                eachParentAccount.Deck_Rank__c == null
            ) {
                //LEM-17379 : Code optimization
                eachParentAccount.Deck_Rank__c = KING_OF_SPADES_DECK_RANK;
            }
        }
    }

    /**
     * @description It applies the defined field’s value on the eligible child account from the
     * associated parent account.
     * @JIRA# LEM-11918
     * @param parentAccount
     * @param childAccount
     * @param franchiseParent
     */
    private void applyFieldValuesByParent(
        Account parentAccount,
        Account childAccount,
        Account franchiseParent
    ) {
        for (String eachField : collectFieldsToUpdate(parentAccount, franchiseParent)) {
            switch on FIELD_TO_UPDATE_MAPPINGS.get(eachField) {
                when CONTROLOFPRICE {
                    if (isEligibleToCopyAccountOwnershipAndControlOfPrice(childAccount)) {
                        copyFieldByParent(parentAccount, childAccount, eachField);
                    }
                }
                when OWNER {
                    if (isEligibleToCopyAccountOwnershipAndControlOfPrice(childAccount)) {
                        copyFieldByParent(parentAccount, childAccount, eachField);
                    }
                }
                when SEGMENT {
                    copyFieldByParent(parentAccount, childAccount, eachField);
                }
                when TAXID {
                    if (isEligibleToCopyAccountTaxId(childAccount)) {
                        copyFieldByParent(parentAccount, childAccount, eachField);
                    }
                }
                when DECKRANK {
                    if (isEligibleToTrickleDownDeckRank(childAccount)) {
                        copyFieldByParent(parentAccount, childAccount, eachField);
                    }
                }
                when LEGALBUSINESSNAME {
                    if (isEligibleToTrickleDownLegalBusinessName(childAccount)) {
                        if (franchiseParent != null) {
                            copyFieldByParent(franchiseParent, childAccount, eachField);
                        } else {
                            copyFieldByParent(parentAccount, childAccount, eachField);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description It is used to collect the parent accounts by the passed child accounts.
     * @param childAccounts
     * @return Map<Id, Account>
     */
    private Map<Id, Account> collectParentAccounts(List<Account> childAccounts) {
        Set<Id> parentAccountIds = new Set<Id>();
        for (Account childAccount : childAccounts) {
            if (String.isNotBlank(childAccount.parentId)) {
                parentAccountIds.add(childAccount.ParentId);
            }
        }
        if (parentAccountIds.isEmpty()) {
            return new Map<Id, Account>();
        }
        return (new Map<Id, Account>(AccountsSelector.newInstance().selectById(parentAccountIds)));
    }

    /**
     * @description It is used to collect the parent accounts by the passed child accounts.
     * @param childAccounts
     * @return Map<Id, Account>
     */
    private Map<Id, Account> collectFranchiseParentAccounts(List<Account> childAccounts) {
        Set<Id> franchiseParentAccountIds = new Set<Id>();
        for (Account childAccount : childAccounts) {
            if (String.isNotBlank(childAccount.Franchise_Parent__c)) {
                franchiseParentAccountIds.add(childAccount.Franchise_Parent__c);
            }
        }
        if (franchiseParentAccountIds.isEmpty()) {
            return new Map<Id, Account>();
        }
        return (new Map<Id, Account>(
            AccountsSelector.newInstance().selectById(franchiseParentAccountIds)
        ));
    }

    /**
     * @description It is used to collect the fields that requires to be updated on child Account
     * from the associated parent Account.
     * @param parentAccount
     * @param franchiseParent
     * @return Set<String>
     */
    private Set<String> collectFieldsToUpdate(Account parentAccount, Account franchiseParent) {
        Set<String> fieldsToUpdate = new Set<String>();
        if (String.isNotBlank(parentAccount.Control_of_Price__c)) {
            fieldsToUpdate.add(ACCOUNT_CONTROL_OF_PRICE);
        }
        if (String.isNotBlank(parentAccount.Segment__c)) {
            fieldsToUpdate.add(ACCOUNT_SEGMENT);
        }
        if (String.isNotBlank(parentAccount.TaxID__c)) {
            fieldsToUpdate.add(ACCOUNT_TAX_ID);
        }
        if (String.isNotBlank(parentAccount.OwnerId)) {
            fieldsToUpdate.add(ACCOUNT_OWNER);
        }
        if (String.isNotBlank(parentAccount.Deck_Rank__c)) {
            fieldsToUpdate.add(ACCOUNT_DECK_RANK);
        }
        if (
            String.isNotBlank(parentAccount.Legal_Business_Name__c) ||
            String.isNotBlank(franchiseParent?.Legal_Business_Name__c)
        ) {
            fieldsToUpdate.add(ACCOUNT_LEGAL_BUSINESS_NAME);
        }
        return fieldsToUpdate;
    }

    /**
     * @description It is used to collect the child account's fields that requires to be updated
     * with the parent account's fields.
     * @param parentAccount
     * @param childAccount
     * @param fieldToCopy
     */
    private void copyFieldByParent(
        Account parentAccount,
        Account childAccount,
        String fieldToCopy
    ) {
        childAccount.put(fieldToCopy, parentAccount.get(fieldToCopy));
    }

    /**
     * @description It checks whether the child account satisfies the criteria to copy the owner
     * from parent account.
     * @JIRA# LEM-11918
     * @param childAccount
     * @return Boolean
     */
    private Boolean isEligibleToCopyAccountOwnershipAndControlOfPrice(Account childAccount) {
        return (childAccount.RecordtypeId == BUSINESS_RECORD_TYPE_ID &&
            ACCOUNT_TYPES_TO_ALLOW_ACCOUNT_OWNER_AND_CONTROL_OF_PRICE_TRICKLE_DOWN.contains(
                childAccount.Type
            )) ||
            (childAccount.RecordtypeId == STORE_RECORD_TYPE_ID &&
            childAccount.Franchise_Parent__c == null);
    }

    /**
     * @description It checks whether the child account satisfies the criteria to copy the tax id
     * from parent account.
     * @JIRA# LEM-11918
     * @param childAccount
     * @return Boolean
     */
    private Boolean isEligibleToCopyAccountTaxId(Account childAccount) {
        System.TriggerOperation triggerContext = SystemFacade.getTriggerContext();
        return ((childAccount.RecordtypeId == BUSINESS_RECORD_TYPE_ID) &&
        (String.isBlank(childAccount.TaxID__c) ||
        triggerContext.name().equalsIgnoreCase(TRIGGER_CONTEXT_BEFORE_UPDATE)));
    }

    /**
     * @description It checks whether the child account satisfies the criteria to copy the
     * control of price and ownerId from parent account.
     * @param accountInstance
     * @return Boolean
     */
    private Boolean isEligibleToTrickleDownAccountOwnershipAndControlOfPrice(
        Account accountInstance
    ) {
        return accountInstance.Record_Type_Name__c == BUSINESS &&
            ACCOUNT_TYPES_TO_ALLOW_ACCOUNT_OWNER_AND_CONTROL_OF_PRICE_TRICKLE_DOWN.contains(
                accountInstance.Type
            );
    }
    /**
     * @description It checks whether the child account satisfies the criteria to copy the
     * deck rank from parent account.
     * @param accountInstance
     * @return Boolean
     */
    private Boolean isEligibleToTrickleDownDeckRank(Account accountInstance) {
        return (accountInstance.Record_Type_Name__c == STORE &&
            ACCOUNT_SEGMENT_TO_ALLOW_DECK_RANK_TRICKLE_DOWN.contains(accountInstance.Segment__c)) ||
            (accountInstance.Record_Type_Name__c == BUSINESS &&
            ACCOUNT_SEGMENT_TO_ALLOW_DECK_RANK_TRICKLE_DOWN.contains(accountInstance.Segment__c));
    }

    /**
     * @description It fires the Notifer Events to trigger the trickle down of
     * parent Account fields.
     * @JIRA# LEM-12375
     * @param eligibleParentAccountIds
     */
    private void publishNotifierEventToTriggerTrickleDown(Set<Id> eligibleParentAccountIds) {
        this.parentAccountIdsChunkSizeToTrickleDownAccountFields = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(
                    TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
                .Configuration_Value__c
        );
        NotifierEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    eligibleParentAccountIds,
                    parentAccountIdsChunkSizeToTrickleDownAccountFields
                )
            }
        );
    }

    /**
     * @description update Owner On Franchise Account
     * @author rishab.goyal | 03-18-2024
     **/
    public void populateOwnerOnFranchiseAccount() {
        //Contains Store and Business Account.
        List<Account> franchiseAccounts = new List<Account>();
        for (Account acc : (List<Account>) getRecords()) {
            if (
                (acc.RecordTypeId == STORE_RECORD_TYPE_ID && acc.Franchise_Parent__c != null) ||
                (acc.RecordTypeId == BUSINESS_RECORD_TYPE_ID &&
                acc.Type == FRANCHISEE &&
                acc.parentId != null)
            ) {
                franchiseAccounts.add(acc);
            }
        }
        if (franchiseAccounts.isEmpty()) {
            return;
        }
        AccountsService.fetchAndPopulateOwnerOnFranchiseAccounts(franchiseAccounts);
    }

    /**
     * @description Validate Accessibilities format
     * @param accounts
     * @JIRA# LEM-12908
     */
    public void validateAccessibilities(List<Account> accounts) {
        String seattleZipCodesString = System.Label.Seattle_Zipcodes;
        List<String> seattleZipCodes = seattleZipCodesString.split(',');
        String errMessage = System.Label.Seattle_Accessibilities_Validation_Message;
        String errMessageNonSeattle = System.Label.Non_Seattle_Accessibilities_Validation_Message;
        for (Account account : accounts) {
            if (
                string.isNotBlank(account.Accessibilities__c) &&
                (String.isBlank(account.BillingPostalCode) ||
                String.isNotBlank(account.BillingPostalCode) &&
                !seattleZipCodes.contains(account.BillingPostalCode.trim()))
            ) {
                account.Accessibilities__c.addError(errMessageNonSeattle);
            } else if (
                string.isNotBlank(account.Accessibilities__c) &&
                !('not provided'.equalsIgnoreCase(account.Accessibilities__c)) &&
                String.isNotBlank(account.BillingPostalCode) &&
                seattleZipCodes.contains(account.BillingPostalCode.trim())
            ) {
                try {
                    account.Accessibilities__c = account.Accessibilities__c.replaceAll(
                            '(?i)true',
                            'true'
                        )
                        .replaceAll('(?i)false', 'false');
                    Map<String, Object> accessibilityMap = (Map<String, Object>) JSON.deserializeUntyped(
                        account.Accessibilities__c
                    );
                    if (!accessibilityMap.containsKey('accessibilities')) {
                        account.Accessibilities__c.addError(errMessage);
                    }
                    Map<String, Object> accessibilities = (Map<String, Object>) accessibilityMap.get(
                        'accessibilities'
                    );
                    if (
                        !accessibilities.containsKey('needToClimb') ||
                        !(accessibilities.get('needToClimb') instanceof Boolean)
                    ) {
                        account.Accessibilities__c.addError(errMessage);
                    }
                    if (
                        !accessibilities.containsKey('hasElevatorsOrRamps') ||
                        !(accessibilities.get('hasElevatorsOrRamps') instanceof Boolean)
                    ) {
                        account.Accessibilities__c.addError(errMessage);
                    }
                } catch (Exception e) {
                    account.Accessibilities__c.addError(errMessage);
                }
            }
        }
    }

    /**
     * @description Populate Data Verification Status to verified if data is correct
     * @author ila.maheshwari | 25-06-2024
     **/
    public void populateDataVerificationStatus() {
        for (Account eachAccount : (List<Account>) getRecords()) {
            if (
                checkIfBusinessOrChannelPartnerAccountHasAllFields(eachAccount) ||
                checkIfBusinessFranchiseAccountHasAllFields(eachAccount) ||
                checkIfStoreAccountHasAllFields(eachAccount)
            ) {
                eachAccount.Data_Verification_Status__c = VERIFIED;
            }
        }
    }
    /**
     * @description It is used to validate if the ROE Fields are updated by Account Owner or Account Owner's Manager.
     * LEM-14107
     */
    public void validateROEFieldsChangedByOwnerOrOwnersManager() {
        Id currentUserID = UserInfo.getUserID();
        Set<Id> ownerIds = new Set<Id>();
        if (
            FeatureManagement.checkPermission('Can_Modify_Rules_Of_Engagement') ||
            ((List<Account>) getRecords()).isEmpty()
        ) {
            //LEM-17379 : Code optimization
            return;
        }
        for (Account eachAccount : (List<Account>) getRecords()) {
            ownerIds.add(eachAccount.OwnerId);
        }
        Map<Id, Id> accountOwnerToOwnerManager = new Map<Id, Id>();
        for (User eachUser : UsersSelector.newInstance().selectUsersById(ownerIds)) {
            accountOwnerToOwnerManager.put(eachUser.id, eachUser.ManagerID);
        }
        for (Account eachChangedAccount : (List<Account>) getRecords()) {
            if (
                currentUserID != eachChangedAccount.OwnerId &&
                currentUserID != accountOwnerToOwnerManager.get(eachChangedAccount.OwnerId)
            ) {
                eachChangedAccount.addError(ROE_NO_ACCESS_ERROR_MESSAGE);
            }
        }
    }

    /* @description It Checks if fields are populated for Business and Channel Partner non Franchisee account
     * @param accountInstance
     * @return Boolean
     */
    private Boolean checkIfBusinessOrChannelPartnerAccountHasAllFields(Account accountInstance) {
        return (accountInstance.RecordTypeId == BUSINESS_RECORD_TYPE_ID ||
            accountInstance.RecordTypeId == CHANNEL_PARTNER_RECORD_TYPE_ID) &&
            accountInstance.Type != FRANCHISEE &&
            accountInstance.Segment__c != null &&
            accountInstance.Primary_Vertical__c != null &&
            accountInstance.BillingCountry != null &&
            accountInstance.Legal_Business_Name__c != null;
    }

    /* @description It Checks if fields are populated for Business Franchisee account
     * @param accountInstance
     * @return Boolean
     */
    private Boolean checkIfBusinessFranchiseAccountHasAllFields(Account accountInstance) {
        return accountInstance.RecordTypeId == BUSINESS_RECORD_TYPE_ID &&
            accountInstance.Type == FRANCHISEE &&
            accountInstance.DoorDash_Legal_Entity__c == System.Label.DoorDash_Legal_Entity &&
            accountInstance.Segment__c != null &&
            accountInstance.Primary_Vertical__c != null &&
            accountInstance.BillingCountry != null &&
            accountInstance.Control_of_Price__c != null &&
            accountInstance.Legal_Business_Name__c != null &&
            accountInstance.Commission_Calculation_Methodology__c != null;
    }

    /* @description It Checks if fields are populated for store account
     * @param accountInstance
     * @return Boolean
     */
    private Boolean checkIfStoreAccountHasAllFields(Account accountInstance) {
        return accountInstance.RecordTypeId == STORE_RECORD_TYPE_ID &&
            accountInstance.Segment__c != null &&
            accountInstance.Type != null &&
            accountInstance.Brand__c != null &&
            accountInstance.BillingPostalCode != null &&
            accountInstance.BillingCountry != null &&
            accountInstance.BillingStreet != null &&
            accountInstance.BillingState != null &&
            accountInstance.BillingCity != null;
    }

    /**
     *  @description It is used to populate Segment as SMB on the Accounts when the creation source is Mx Portal
     * and Ultimate Parent Account is blank.
     */
    public void populateSegmentOnAccount() {
        for (Account eachAccount : (List<Account>) getRecords()) {
            if (
                eachAccount.Record_Type_Name__c == BUSINESS &&
                eachAccount.Ultimate_Parent_Account__c == null &&
                eachAccount.Creation_Source__c == MX_PORTAL
            ) {
                eachAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
            }
            //Checking if lead conversion scenario then default following fields on account creation.
            if (String.isNotBlank(eachAccount.Converted_Lead_Id__c)) {
                eachAccount.Type = CORPORATE;
                if (eachAccount.OwnerId != UserInfo.getUserId()) {
                    eachAccount.OwnerId = UserInfo.getUserId();
                }
            }
        }
    }

    /**
     * @description It is used to process accounts post lead conversion.
     * @param existing
     */
    public void processAccountsOnLeadConversion(Map<Id, SObject> existing) {
        Map<String, String> accountFieldToIsUpdatable = new Map<String, String>();
        if (((List<Account>) getRecords()).isEmpty()) {
            return;
        }
        List<StaticResource> leadConversionFieldsMappingStaticResource = StaticResourcesSelector.newInstance()
            .selectByName(System.Label.LeadConversionFieldsMapping);
        Blob leadMappingsCSV = leadConversionFieldsMappingStaticResource[0].Body;
        accountFieldToIsUpdatable = LeadConversionMappingService.collectFieldValueMappings(
            LeadConversionMappingService.collectFields(leadMappingsCSV),
            'Account'
        );
        for (Account eachAccount : (List<Account>) getRecords()) {
            if (eachAccount.Converted_Lead_Id__c != null) {
                eachAccount.Is_Lead_Converted_To_Existing_Account__c = true;
                if (
                    eachAccount.Converted_Lead_Id__c !=
                    ((Account) existing.get(eachAccount.Id)).Converted_Lead_Id__c
                ) {
                    mapAccountFields(eachAccount, accountFieldToIsUpdatable, existing);
                }
            }
        }
    }

    /**
     * @description It is used to call the class to create brand and brand association
     * post lead conversion.
     */
    public void invokeCreateBrandsAndBrandAssociation() {
        List<Account> accountsFromConvertedLeads = new List<Account>(
            (List<Account>) getRecordsWithAllNotNullFieldValues(
                new Set<SObjectField>{ Account.Converted_Lead_Id__c }
            )
        );
        if (accountsFromConvertedLeads.isEmpty()) {
            return;
        }
        Brands.createBrandAndBrandAssociation(
            new Map<Id, Account>(accountsFromConvertedLeads).keySet()
        );
    }

    /**
     * @description It is used to update the Data Verification Status to "Verified" on eligible Accounts.
     */
    public void updateDataVerificationStatus() {
        for (Account eachAccount : (List<Account>) getRecords()) {
            if (
                eachAccount.Record_Type_Name__c == BUSINESS &&
                ACCOUNT_CREATION_SOURCE_ELIGIBLE_FOR_DATA_VERIFICATION_STATUS_UPDATE.contains(
                    eachAccount.Creation_Source__c
                ) &&
                ACCOUNT_BILLING_COUNTRY_CODE_ELIGIBLE_FOR_DATA_VERIFICATION_STATUS_UPDATE.contains(
                    eachAccount.BillingCountryCode
                )
            ) {
                eachAccount.Data_Verification_Status__c = VERIFIED;
            } else {
                eachAccount.Data_Verification_Status__c = UNVERIFIED;
            }
        }
    }
    /**
     * @description It is used to map the Account field values on lead Conversion.
     * @param eachAccount
     * @param accountFieldToIsUpdatable
     * @param existing
     */
    public void mapAccountFields(
        Account eachAccount,
        Map<String, String> accountFieldToIsUpdatable,
        Map<Id, SObject> existing
    ) {
        for (String eachAccountField : accountFieldToIsUpdatable.keySet()) {
            if (
                Boolean.valueOf(accountFieldToIsUpdatable.get(eachAccountField)) &&
                (((Account) existing.get(eachAccount.Id)).get(eachAccountField) == '' ||
                ((Account) existing.get(eachAccount.Id)).get(eachAccountField) == null)
            ) {
                //LEM-17379 : Code optimization
                continue;
            }
            eachAccount.put(
                eachAccountField,
                ((Account) existing.get(eachAccount.Id)).get(eachAccountField)
            );
        }
    }

    /**
     * @description It updates "Account Lifecycle Status" field on the Store Account based on the
     * Activation Status.
     * @JIRA# LEM-24604
     */
    public void setAccountLifecycleStatusOnSMBStoreAccounts() {
        List<Account> accountToUpdate = (List<Account>) getRecords();
        if ((accountToUpdate == null || accountToUpdate.isEmpty())) {
            return;
        }
        for (Account eachAccount : accountToUpdate) {
            if (
                eachAccount.RecordTypeId != STORE_RECORD_TYPE_ID ||
                eachAccount.Segment__c != ACCOUNT_SEGMENT_SMB
            ) {
                continue;
            }
            switch on STORE_ACTIVATION_STATUS_MAPPINGS.get(eachAccount.Activation_Status__c) {
                when ACTIVE {
                    eachAccount.Account_Lifecycle_Status__c = ACCOUNT_LIFECYCLE_STATUS_NURTURE;
                }
                when DEACTIVATED {
                    eachAccount.Account_Lifecycle_Status__c = ACCOUNT_LIFECYCLE_STATUS_CHURNED;
                }
                when INACTIVE {
                    eachAccount.Account_Lifecycle_Status__c = ACCOUNT_LIFECYCLE_STATUS_UNVETTED;
                }
                when else {
                    eachAccount.Account_Lifecycle_Status__c = ACCOUNT_LIFECYCLE_STATUS_UNVETTED;
                }
            }
        }
    }

    /**
     * @description It invokes 'Experience' field update on Store Accounts.
     * @JIRA# LEM-25063
     */
    public void invokeExperienceFieldUpdateOnStoreAccounts() {
        Set<Id> storeAccountIdsToUpdate = new Set<Id>();
        for (Account eachAccount : (List<Account>) getRecords()) {
            if (eachAccount.RecordTypeId == STORE_RECORD_TYPE_ID) {
                storeAccountIdsToUpdate.add(eachAccount.Id);
            }
        }
        if (!storeAccountIdsToUpdate.isEmpty()) {
            AccountsService.updateFieldsOnAccount(storeAccountIdsToUpdate);
        }
    }
}