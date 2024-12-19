/**
 * @author Deloitte
 * @date 07/24/2024
 * @description It is used to consolidate wrappers used in the SSOB ingestion process.
 *
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public class SSOBOnboardingPayloadParser {
    public String uuid;
    public AccountDetails account;
    public ContactDetails contact;
    public OpportunityDetails opportunity;

    /**
     * @description Wrapper for storing business account information received from the
     * instant ingestion payload. It is used to create business accounts in Salesforce.
     */
    public class AccountDetails {
        public Boolean isTestStore;
        public String name;
        public String phone;
        public String businessId;
        public Address address;
    }

    /**
     * @description Wrapper for contact information received from the
     * instant ingestion payload. It is used to create contacts in Salesforce.
     */
    public class ContactDetails {
        public DecisionMaker decisionMaker;
        public Accounting accounting;
    }
    /**
     * @description Wrapper for descision maker role information received from the
     * instant ingestion payload. It is used to create contacts in Salesforce.
     */
    public class DecisionMaker {
        public String firstName;
        public String lastName;
        public String email;
        public String mobilePhone;
        public String phone;
        public String title;
    }
    /**
     * @description Wrapper for Accounting role information received from the
     * instant ingestion payload. It is used to create contacts in Salesforce.
     */
    public class Accounting {
        public String firstName;
        public String lastName;
        public String email;
        public String mobilePhone;
        public String phone;
        public String title;
        public Address address;
    }
    /**
     * @description Wrapper for storing address for business account information received from the
     * instant ingestion payload. It is used to add address in  business accounts in Salesforce.
     */
    public class Address {
        public String street;
        public String postalCode;
        public String city;
        public String state;
        public String country;
    }

    /**
     * @description Wrapper for opportunity information received from the
     * instant ingestion payload. It is used to create opportunity in Salesforce.
     */
    public class OpportunityDetails {
        public String name;
        public String preferredLanguage;
        public String activationNotes;
        public Middleware middleware;
        public ContractDetails contractDetails;
        public String paymentProtocol;
        public String invoicingInformation;
        public MatchedRecords matchedRecords;
        public Boolean hasValidEmail;
        public AddressVerificationInfo addressVerificationInfo;
        public OrderProductsDetails orderProducts;
    }
    /**
     * @description Wrapper for Account information received from the
     * instant ingestion payload. It is used to add POS sytem information in Account in Salesforce.
     */
    public class Middleware {
        public String middlewareProvider;
    }
    /**
     * @description Wrapper for opportunity information received from the
     * instant ingestion payload. It is used to create opportunity in Salesforce.
     */
    public class ContractDetails {
        public Integer ofAddressableLocations;
        public String vendorContractRecord;
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
    @SuppressWarnings('PMD.TooManyFields')
    public class ProductOptionsDetails {
        public String name;
        public String productCode;
        public Decimal commission;
        public Decimal fee;
        public Integer deliveryRadiusMiles;
        public Decimal costPerMile;
        public Integer maxDeliveryDistanceRadius;
        public String volumeTimePeriod;
        public String numberOfVolumeTiers;
        public String businessLevelForVolumeTier1;
        public Integer volumeTierCommitmentTier1;
        public Decimal volumeTierFeeReductionTier1;
        public String businessLevelForVolumeDiscTier2;
        public Integer volumeTierCommitmentTier2;
        public Decimal volumeTierFeeReductionTier2;
        public String businessLevelForVolumeDiscTier3;
        public Integer volumeTierCommitmentTier3;
        public Decimal volumeTierFeeReductionTier3;
        public String businessLevelForVolumeDiscTier4;
        public Integer volumeTierCommitmentTier4;
        public Decimal volumeTierFeeReductionTier4;
    }

    /**
     * @description Wrapper for Address Verifcation information received from the
     * instant ingestion payload.
     */
    public class AddressVerificationInfo {
        public String addressVerificationStatus;
        public String rejectedReason;
        public Datetime addressVerificationDate;
        public ValidatedAddress validatedAddress;
        public Submarket submarket;
        public StartingPoint startingPoint;
        public AlcoholRules alcoholRules;
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