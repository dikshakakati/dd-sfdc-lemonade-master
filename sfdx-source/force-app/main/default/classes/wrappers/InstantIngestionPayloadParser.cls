/**
 * @author Deloitte
 * @date 05/07/2024
 * @description It is used to consolidate wrappers used in the SSMO and SSOB ingestion process.
 *
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public class InstantIngestionPayloadParser {
    public String uuid;
    public String signupType;
    public string onboardingSource;
    public BusinessDetails business;
    public MerchantOwnerDetails merchantOwner;
    public StoreDetails store;
    public DateTime createdAt;
    public BusinessGroup businessGroup;

    /**
     * @description Wrapper for storing business Group Details
     */
    public class BusinessGroup {
        public Boolean isNewBusinessGroup ;
        public String businessGroupName ;
        public String businessGroupId ;
    }
    /**
     * @description Wrapper for storing business account information received from the
     * instant ingestion payload. It is used to create business accounts in Salesforce.
     */
    public class BusinessDetails {
        public String businessId;
        public Boolean isTest;
        public String name;
        public String legalBusinessName;
        public String businessPhone;
        public String headerImage;
    }

    /**
     * @description Wrapper for contact information received from the
     * instant ingestion payload. It is used to create contacts in Salesforce.
     */
    public class MerchantOwnerDetails {
        public String firstName;
        public String lastName;
        public String email;
        public String mobilePhone;
    }

    /**
     * @description Wrapper for store account information received from the
     * instant ingestion payload. It is used to create store accounts in Salesforce.
     */
    @SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields,PMD.FieldNamingConventions')
    public class StoreDetails {
        public String storeId;
        public Boolean hasValidEmail;
        public String storeType;
        public String storeName;
        public String street;
        public String postalCode;
        public String city;
        public MatchedRecords matchedRecords;
        public List<String> treatmentGroup;
        public String deckRank;
        public String ipadUsername;
        public String ipadPassword;
        public String state;
        public String merchantTaxId;
        public String country;
        public String phone;
        public String vertical;
        public String segmentType;
        public String sfdcCampaignId;
        public List<String> menuUrls;
        public String orderProtocol;
        public String orderProtocol_fax;
        public String orderProtocol_email;
        public String menuCompletedBy;
        public String menuSetupMethod;
        public String numberOfAddressableLocations;
        public String hoursOfOperation;
        public String posIntegrationType;
        public String preferredLanguage;
        public String vendorContractType;
        public String vendorActivityId;
        public String vendorContractRecord;
        public Boolean isFranchisee;
        public Decimal numberOfFranchisee;
        public Boolean isAdditionalStore;
        public String mxRequestingPhotoshoot;
        public List<OrderProductsDetails> orderProducts;
        public AddressVerificationInfo addressVerificationInfo;
        public String storeAccountId;
        public String contractNumber;
        public String merchantLink;
        public Boolean isPartnershipDetailsAccepted;
    }

    /**
     * @description Wrapper for Matched records received from the
     * instant ingestion payload.
     */
    public class MatchedRecords {
        public List<Lead> lead;
        public List<Contact> contact;
        public List<Account> account;
    }

    /**
     * @description Wrapper for product information received from the
     * instant ingestion payload. It is used to create quote lines in Salesforce.
     */
    public class OrderProductsDetails {
        public String name;
        public String productCode;
        public List<ProductOptionsDetails> productOptions;
    }

    /**
     * @description Wrapper for product information received from the
     * instant ingestion payload. It is used to create quote line options in Salesforce.
     */
    public class ProductOptionsDetails {
        public String name;
        public String productCode;
        public String commission;
        public String trialDuration;
        public String trialCommission;
        public String fee;
        public String trialFee;
        public String productOptions;
    }

    /**
     * @description Wrapper for Address Verifcation information received from the
     * instant ingestion payload.
     */
    public class AddressVerificationInfo {
        public String addressVerificationStatus;
        public String rejectedReason;
        public Datetime addressVerificationDate;
        public Submarket submarket;
        public StartingPoint startingPoint;
        public AlcoholRules alcoholRules;
        public ValidatedAddress validatedAddress;
    }

    /**
     * @description Wrapper for Submarket information received from the
     * instant ingestion payload.
     */
    public class Submarket {
        public String id;
        public String name;
    }

    /**
     * @description Wrapper for Starting Point information received from the
     * instant ingestion payload.
     */
    public class StartingPoint {
        public Integer id;
        public String startingPoint;
    }

    /**
     * @description Wrapper for Alcohol Rules information received from the
     * instant ingestion payload.
     */
    public class AlcoholRules {
        public String alcoholAllowanceCategory;
    }

    /**
     * @description Wrapper for Validated Address information received from the
     * instant ingestion payload.
     */
    public class ValidatedAddress {
        public Double latitude;
        public Double longitude;
        public String addressLine1;
        public String addressLine2;
        public String city;
        public String country;
        public String state;
        public String stateCode;
        public String countryShortname;
        public String postalCode;
        public String addressId;
        public String timezone;
    }
}