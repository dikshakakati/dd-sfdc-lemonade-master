/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Service implementation class for Account creation from payload related records logic
 */
public inherited sharing class InstantIngestionAccountServiceImpl implements IInstantIngestionAccountService {
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final Id BUSNINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final String TYPE = 'Corporate';
    private static final String NSE = 'Mx Portal New Store Expansion';
    private static final String A_P = 'Mx Portal Ads And Promos';
    private static final String STORE_PRICING_TYPE = 'Store Specific Pricing';
    private static final String PRIMARY_VERTICAL = 'Rx';
    private static final String CREATION_SOURCE = 'Integration';
    private static final String ACCOUNT_LIFECYCLE_STATUS = 'In Pursuit';
    private static final String PRICE_RANGE = '$';
    private static final String SEMI_COLON = ';';
    private static final String ACCOUNT = 'account';
    private static final String ADDRESS = 'address';
    private static final String SOURCE_SSOB = 'SSOB';
    private static final String STRING_TYPE = 'String';
    private static final String DECIMAL_TYPE = 'Decimal';
    private static final String INTEGER_TYPE = 'Integer';
    private static final String SMB = 'SMB';
    private static final String NA = 'N/A';
    private static final String DROP_SHIP = 'Drop-Ship';
    private static final String TABLET = 'Tablet';
    private static final String SOURCE_RESSMO = 'RESSMO';
    private static final String YES = 'Yes';
    private static final String STATUS_VERIFIED = 'Verified';
    private static final String MENU_UI_TYPE_RESTAURANT = 'Restaurant';

    /**
     * @description It is used to create the Business Account from the Payload.
     * @param payload
     * @param submarketId
     * @param integrationTypeByUUID
     * @return Account
     */
    public Account createBusinessAccount(
        InstantIngestionPayloadParser payload,
        String submarketId,
        String integrationTypeByUUID
    ) {
        Account businessAccount = new Account();
        businessAccount.Name = payload.business.name;
        businessAccount.RecordTypeId = BUSNINESS_RECORD_TYPE_ID;
        businessAccount.Type = TYPE;
        businessAccount.Unique_Identifier__c = payload.Uuid;
        businessAccount.Segment__c = payload.store.segmentType;
        businessAccount.Primary_Vertical__c = InstantIngestionEnumMappingsService.getPrimaryVertical(
            payload.store.vertical
        );
        businessAccount.Order_Protocol__c = InstantIngestionEnumMappingsService.getOrderProtocol(
            payload.store.orderProtocol
        );
        if (integrationTypeByUUID == NSE || integrationTypeByUUID == A_P) {
            businessAccount.Pricing_Type__c = STORE_PRICING_TYPE;
        }
        businessAccount.Creation_Source__c = CREATION_SOURCE;
        businessAccount.Account_Lifecycle_Status__c = ACCOUNT_LIFECYCLE_STATUS;
        businessAccount.Is_Test__c = payload.business.isTest;
        businessAccount.Legal_Business_Name__c = payload.business.legalBusinessName;
        businessAccount.TaxID__c = payload.store.merchantTaxId;
        businessAccount.Phone = payload.business.BusinessPhone != null
            ? payload.business.BusinessPhone
            : payload.store.Phone;
        if (
            payload.store.addressVerificationInfo?.addressVerificationStatus == STATUS_VERIFIED &&
            payload.store.addressVerificationInfo.validatedAddress != null
        ) {
            businessAccount.BillingStreet =
                payload.store.addressVerificationInfo?.validatedAddress?.addressLine1 +
                payload.store.addressVerificationInfo?.validatedAddress?.addressLine2;
            businessAccount.BillingPostalCode = payload.store.addressVerificationInfo
                ?.validatedAddress
                ?.postalCode;
            businessAccount.BillingCity = payload.store.addressVerificationInfo
                ?.validatedAddress
                ?.city;
            businessAccount.BillingCountryCode = payload.store.addressVerificationInfo
                ?.validatedAddress
                ?.countryShortname;
            if (payload.store.addressVerificationInfo?.validatedAddress?.stateCode.length() > 3) {
                businessAccount.BillingState = payload.store.addressVerificationInfo
                    ?.validatedAddress
                    ?.stateCode;
            } else {
                businessAccount.BillingStateCode = payload.store.addressVerificationInfo
                    ?.validatedAddress
                    ?.stateCode;
            }
        } else {
            businessAccount.BillingStreet = payload.store.street;
            businessAccount.BillingPostalCode = payload.store.postalCode;
            businessAccount.BillingCity = payload.store.city;
            businessAccount.BillingCountryCode = payload.store.country;
            getBillingStateValue(payload, businessAccount);
        }
        businessAccount.Deck_Rank__c = payload.store.deckRank;
        //businessAccount.photourl  = payload.Account.headerImage;
        return businessAccount;
    }
    /**
     * @description It is used to create the Brand using the Payload and Account.
     * @param account
     * @return Brand__c
     */
    public Brand__c createBrand(Account account) {
        Brand__c brand = new Brand__c();
        brand.Brand_Owner__c = account.Id;
        brand.Unique_Identifier__c = account.Unique_Identifier__c;
        brand.Name = account.Name;
        brand.Price_Range__c = PRICE_RANGE;
        return brand;
    }

    /**
     * @description It is used to create Store Account using the Payload and BrandId.
     * @param payload
     * @param brandId
     * @param businessAccount
     * @param businessVertical
     * @param submarketId
     * @return Account
     */
    public Account createStoreAccount(
        InstantIngestionPayloadParser payload,
        Id brandId,
        Account businessAccount,
        Business_Vertical__c businessVertical,
        String submarketId
    ) {
        Account storeAccount = new Account();
        storeAccount.RecordTypeId = STORE_RECORD_TYPE_ID;
        //storeAccount.Type = payload.Account.Kitchen_Concept?'Virtual':'Brick and Mortar';
        storeAccount.Business_Vertical__c = businessVertical.Id;
        storeAccount.Brand__c = BrandId;
        storeAccount.Name = payload.store.storeName;
        storeAccount.TaxID__c = payload.store.merchantTaxId;
        storeAccount.Legal_Business_Name__c = payload.business?.legalBusinessName;
        storeAccount.Unique_Identifier__c = payload.Uuid;
        storeAccount.ParentId = businessAccount.Id;
        storeAccount.Creation_Source__c = CREATION_SOURCE;
        if (
            payload.store.addressVerificationInfo?.addressVerificationStatus == STATUS_VERIFIED &&
            payload.store.addressVerificationInfo.validatedAddress != null
        ) {
            storeAccount.BillingStreet =
                payload.store.addressVerificationInfo?.validatedAddress?.addressLine1 +
                payload.store.addressVerificationInfo?.validatedAddress?.addressLine2;
            storeAccount.BillingPostalCode = payload.store.addressVerificationInfo
                ?.validatedAddress
                ?.postalCode;
            storeAccount.BillingCity = payload.store.addressVerificationInfo
                ?.validatedAddress
                ?.city;
            storeAccount.BillingCountryCode = payload.store.addressVerificationInfo
                ?.validatedAddress
                ?.countryShortname;
            if (payload.store.addressVerificationInfo?.validatedAddress?.stateCode.length() > 3) {
                storeAccount.BillingState = payload.store.addressVerificationInfo
                    ?.validatedAddress
                    ?.stateCode;
            } else {
                storeAccount.BillingStateCode = payload.store.addressVerificationInfo
                    ?.validatedAddress
                    ?.stateCode;
            }
        } else {
            storeAccount.BillingStreet = payload.store.street;
            storeAccount.BillingPostalCode = payload.store.postalCode;
            storeAccount.BillingCity = payload.store.city;
            storeAccount.BillingCountryCode = payload.store.country;
            getBillingStateValue(payload, storeAccount);
        }
        storeAccount.Menu_URL__c = payload.store.menuUrls != null
            ? String.join(payload.store.menuUrls, SEMI_COLON)
            : '';
        storeAccount.Menu_to_be_Completed_By__c = payload.store.menuCompletedBy;
        storeAccount.Is_Additional_Store__c = payload.store.isAdditionalStore;
        storeAccount.Menu_Setup_Method__c = payload.Store.menuSetupMethod;
        storeAccount.Tablet_User_Name__c = payload.store.ipadUserName;
        storeAccount.Tablet_Password__c = payload.store.ipadPassword;
        //storeAccount.Total_Number_Of_Stores__c = payload.store.numberOfAddressableLocations;
        storeAccount.Hours_of_Operation__c = payload.store.hoursOfOperation;
        storeAccount.POS_Integration_Type__c = payload.store.posIntegrationType;
        storeAccount.Preferred_Language__c = payload.store.preferredLanguage;
        storeAccount.Franchise_Owned_Store_Count__c = payload.store.numberOfFranchisee;
        storeAccount.Address_Verification_Status__c = payload.store.addressVerificationInfo.addressVerificationStatus;
        storeAccount.Rejected_Reason__c = payload.store.addressVerificationInfo.rejectedReason;
        storeAccount.Address_Verification_Date__c = payload.store.addressVerificationInfo.addressVerificationDate;
        storeAccount.SubMarket__c = submarketId;
        storeAccount.Starting_Point_ID__c = payload.store.addressVerificationInfo
            ?.startingPoint
            ?.id;
        storeAccount.Starting_Point__c = payload.store.addressVerificationInfo
            ?.startingPoint
            ?.startingPoint;
        storeAccount.Alcohol_Eligibility__c = payload.store.addressVerificationInfo
            ?.alcoholRules
            ?.alcoholAllowanceCategory;
        storeAccount.Primary_Vertical__c = InstantIngestionEnumMappingsService.getPrimaryVertical(
            payload.store.vertical
        );
        storeAccount.Order_Protocol__c = InstantIngestionEnumMappingsService.getOrderProtocol(
            payload.store.orderProtocol
        );

        if (
            storeAccount.Order_Protocol__c != null &&
            storeAccount.Order_Protocol__c.containsIgnoreCase(TABLET)
        ) {
            storeAccount.Tablet_Delivery_Method__c = DROP_SHIP;
        }

        storeAccount.Type = InstantIngestionEnumMappingsService.getStoreType(
            payload.store.storeType
        );
        if (payload.store.treatmentGroup != null) {
            storeAccount.Treatment_Group__c = getTreatmentGroupValues(payload.store.treatmentGroup);
        }
        updateStoreAccountFields(storeAccount, payload);
        return storeAccount;
    }

    /**
    * @description
    * @param storeAccount
    * @param payload
    **/
    public void updateStoreAccountFields(Account storeAccount, InstantIngestionPayloadParser payload) {
        storeAccount.Activated_Centrally_AC__c = payload.onboardingSource == SOURCE_RESSMO
            ? YES
            : null;
        storeAccount.Menu_UI_Type__c = payload.onboardingSource == SOURCE_RESSMO
            ? MENU_UI_TYPE_RESTAURANT
            : null;
    }

    /**
     * @description It is used to get Billing State Code for the received payload.
     * @param payload
     * @param businessAccount
     */
    private void getBillingStateValue(
        InstantIngestionPayloadParser payload,
        Account businessAccount
    ) {
        if (payload.store.state.length() > 3) {
            businessAccount.BillingState = payload.store.state;
        } else {
            businessAccount.BillingStateCode = payload.store.state;
        }
    }

    /**
     * @description It is used to get Treatment Group values received in payload.
     * @param receivedTreatmentGroups
     * @return String
     */
    private String getTreatmentGroupValues(List<String> receivedTreatmentGroups) {
        Set<String> formattedTreatmentGroups = new Set<String>();
        for (String eachTreatmentGroup : receivedTreatmentGroups) {
            formattedTreatmentGroups.add(
                InstantIngestionEnumMappingsService.getTreatmentGroup(eachTreatmentGroup)
            );
        }
        return String.join(new List<String>(formattedTreatmentGroups), SEMI_COLON);
    }

    /**
     * @description It is used to create the Business Account from the SSOB Payload.
     * @param payload
     * @param parsedpayload
     * @return Account
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public Account createBusinessAccountSSOB(
        String payload,
        SSOBOnboardingPayloadParser parsedpayload
    ) {
        Map<String, Object> jsonPayloadKeyToValue = (Map<String, Object>) JSON.deserializeUntyped(
            payload
        );
        Map<String, Object> accountPayloadKeyToValue = (Map<String, Object>) jsonPayloadKeyToValue.get(
            ACCOUNT
        );
        Map<String, Object> addressPayloadKeyToValue = (Map<String, Object>) accountPayloadKeyToValue.get(
            ADDRESS
        );
        Account ssobAccount = new Account();
        for (
            Inbound_Ingestion_Payload_Mapping__mdt eachmdt : InstantIngestionFieldMappingSelector.newInstance()
                .getAllValues()
        ) {
            if (eachmdt.Integration_Type__c != SOURCE_SSOB || eachmdt.Object__c != ACCOUNT) {
                continue;
            }

            if (eachmdt.Payload_Attribute__c != null) {
                ssobAccount.put(
                    eachmdt.Field_Name__c,
                    (String) accountPayloadKeyToValue.get(eachmdt.Payload_Attribute__c)
                );
            }

            if (eachmdt.Default_Value__c != null) {
                ssobAccount.put(
                    eachmdt.Field_Name__c,
                    (String) accountPayloadKeyToValue.get(eachmdt.Default_Value__c)
                );
            }
            if (eachmdt.Attribute_Key__c == ADDRESS) {
                ssobAccount.put(
                    eachmdt.Field_Name__c,
                    (String) addressPayloadKeyToValue.get(eachmdt.Payload_Attribute__c)
                );
            }
        }
        ssobAccount.put('RecordTypeId', BUSNINESS_RECORD_TYPE_ID);
        ssobAccount.put(
            'Address_Verification_Status__c',
            parsedpayload.opportunity.addressVerificationInfo.addressVerificationStatus
        );
        ssobAccount.put(
            'Rejected_Reason__c',
            parsedpayload.opportunity.addressVerificationInfo.rejectedReason
        );
        ssobAccount.put(
            'Address_Verification_Date__c',
            parsedpayload.opportunity.addressVerificationInfo.addressVerificationDate
        );
        ssobAccount.put('Creation_Source__c', CREATION_SOURCE);
        ssobAccount.put('Preferred_Language__c', parsedpayload.opportunity.preferredLanguage);
        if (parsedpayload.opportunity.middleware.middlewareProvider != NA) {
            ssobAccount.put(
                'POS_System__c',
                parsedpayload.opportunity.middleware.middlewareProvider
            );
        }
        ssobAccount.put('Unique_Identifier__c', parsedpayload.Uuid);
        ssobAccount.put('Type', TYPE);
        ssobAccount.put('Segment__c', SMB);
        ssobAccount.put('Primary_Vertical__c', PRIMARY_VERTICAL);
        String billingCountryCode = (parsedpayload.opportunity
                ?.addressVerificationInfo
                ?.addressVerificationStatus == STATUS_VERIFIED)
            ? parsedpayload.opportunity?.addressVerificationInfo?.validatedAddress?.countryShortname
            : getCountryCode(parsedpayload.account.address.country);
        ssobAccount.put('BillingCountryCode', billingCountryCode);

        if (parsedpayload.account.address.state.length() > 3) {
            ssobAccount.put('BillingState', parsedpayload.account.address.state);
        } else {
            ssobAccount.put('BillingStateCode', parsedpayload.account.address.state);
        }
        ssobAccount.put('Creation_Source__c', CREATION_SOURCE);
        return ssobAccount;
    }
    /**
     * @description It is used to fetch the billingCountryCode based on the provided country name.
     * @param billingCountry
     * @return String
     */
    private String getCountryCode(String billingCountry) {
        String countryCode = '';
        //Account billingcountry field was not accessible so we are using User object's country code
        Schema.DescribeFieldResult billingCountryfield = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> billingCountryPicklistEntries = billingCountryfield.getPicklistValues();
        for (Schema.PicklistEntry eachBillingCountryPicklistEntry : billingCountryPicklistEntries) {
            if (eachBillingCountryPicklistEntry.getLabel() == billingCountry) {
                countryCode = String.valueof(eachBillingCountryPicklistEntry.getValue());
                break;
            }
        }
        return countryCode;
    }
}