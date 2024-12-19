/**
 * @author Deloitte
 * @date 05/25/2024
 * @description SSMOFalloutWrapper class.
 */
@SuppressWarnings('PMD.TooManyFields, PMD.ExcessivePublicCount')
public class SSMOFalloutWrapper {
    /**
     * @description class method to capture Store Address.
     */
    public class StoreAddress {
        public String addressLine1;
        public String addressLine2;
        public String city;
        public String state;
        public String country;
        public String postalCode;
    }
    /**
     * @description Wrapper class to capture AddressVerificationInfo.
     */
    public class AddressVerificationInfo {
        public String addressVerificationStatus;
        public String rejectedReason;
        public String addressVerificationDate;
        public ValidatedAddress validatedAddress;
        public Submarket submarket;
        public StartingPoint startingPoint;
        public AlcoholRules alcoholRules;
    }
    public String id;
    public String sourceUniqueId;
    public DateTime createdAt;
    public String storeName;
    public String storeType;
    public String signupType;
    public String ownerFirstName;
    public String ownerLastName;
    public String businessPhone;
    public String ownerPhone;
    public String email;
    public String verticalType;
    public String locale;
    public List<String> experiences;
    public StoreAddress storeAddress;
    public String deckRank;
    public Integer storeId;
    public Integer businessId;
    public String orderProtocol;
    public String orderProtocolPosProviderType;
    public String orderProtocolEmail;
    public String orderProtocolPhone;
    public String storeHours;
    public List<String> menuLinks;
    public String selectedPackageuuid;
    public String selfServeStep;
    public String legalBusinessName;
    public String merchantType;
    public String numberOfLocations;
    public List<String> treatmentGroups;
    public MatchedRecords matchedRecords;
    public Boolean hasValidEmail;
    public AddressVerificationInfo addressVerificationInfo;
    /**
     * @description Wrapper class to capture Submarket.
     */
    public class Submarket {
        public String id;
        public String name;
    }
    /**
     * @description Wrapper class to capture StartingPoint.
     */
    public class StartingPoint {
        public Integer id;
        public String startingPoint;
    }
    /**
     * @description Wrapper class to capture MatchedRecords.
     */
    public class MatchedRecords {
        public List<Lead> lead;
        public List<Contact> contact;
        public List<Account> account;
    }
    /**
     * @description Wrapper class to capture ValidatedAddress.
     */
    public class ValidatedAddress {
        public Double latitude;
        public Double longitude;
        public String addressLine1;
        public String addressLine2;
        public String city;
        public String country;
        public String state;
        public String countryShortname;
        public String postalCode;
        public String addressId;
        public String timezone;
    }
    /**
     * @description Wrapper class to capture AlcoholRules.
     */
    public class AlcoholRules {
        public String alcoholAllowanceCategory;
    }

    public static final Map<String, String> ORDER_PROTOCOL_MAPPING = new Map<String, String>{
        'ORDER_PROTOCOL_TABLET_PRINTER' => 'Tablet and Printer (DoorDash Owns)',
        'ORDER_PROTOCOL_TABLET' => 'Tablet (DoorDash Owns)',
        'ORDER_PROTOCOL_EMAIL' => 'Email',
        'ORDER_PROTOCOL_FAX' => 'Fax',
        'ORDER_PROTOCOL_POINT_OF_SALE' => 'POS',
        'ORDER_PROTOCOL_INDICATOR_UNSPECIFIED' => 'Indicator Unspecified',
        'ORDER_PROTOCOL_PHONE' => 'Phone'
    };

    public static final Map<String, String> LOCALE_LANGUAGE_MAPPING = new Map<String, String>{
        'fr-CA' => 'French',
        'ja-JP' => 'Other',
        'en-US' => 'English',
        'de-DE' => 'Other',
        'es-US' => 'Spanish'
    };
    public static final Map<String, String> PRIMARY_VERTICAL_MAPPING = new Map<String, String>{
        'VERTICAL_TYPE_UNSPECIFIED' => 'Rx',
        'VERTICAL_TYPE_RESTAURANT' => 'Rx',
        'VERTICAL_TYPE_FLOWERS' => 'Floral'
    };
    private static final Map<String, String> PACKAGE_TYPE_MAPPING = new Map<String, String>{
        'PACKAGE_TYPE_UNSPECIFIED' => 'Unspecified',
        'PACKAGE_TYPE_BASIC' => 'Basic',
        'PACKAGE_TYPE_PLUS' => 'Plus',
        'PACKAGE_TYPE_PREMIER' => 'Premier',
        'PACKAGE_TYPE_MARKETPLACE' => 'Marketplace'
    };
    public static final Map<String, String> UUID_TO_PACKAGE_TYPE_MAPPING = new Map<String, String>{
        '28be4f9c-44c4-44e5-9781-9fa0aa983d45' => 'Premier',
        '4e3dc12d-2f89-421e-a71b-a8f96740bf48' => 'Basic',
        '9ab0a29c-743d-45e2-bf0e-5707e3af3454' => 'Plus',
        '9b5856e7-3d27-4539-8a97-280118a5266c' => 'Premier',
        'a436236c-595d-4891-99d8-3d8c931d9f82' => 'Premier',
        'cbe5798e-c0c9-4285-aeed-19c385310c8a' => 'Basic',
        'cc97cd94-e1f5-4c1a-a873-970225dbf589' => 'Plus',
        'e1bba653-f4e2-4118-8a6d-5f331a94cdf2' => 'Basic',
        'e6f75fae-b09e-4728-bd96-124154bacbc7' => 'Basic',
        'fb1e7ea6-a643-4072-a341-da7c4355b4c2' => 'Plus',
        'fe5b1c02-f8ea-434f-bcb0-52ae7b835db8' => 'Basic'
    };
    public static final Map<String, String> SELF_SERVE_STEP_MAPPING = new Map<String, String>{
        'SELF_SERVE_STEP_UNSPECIFIED' => 'Unspecified',
        'SELF_SERVE_STEP_MARKETING' => 'Marketing',
        'SELF_SERVE_STEP_IDENTITY'=>'Identity',
        'SELF_SERVE_STEP_ORDER_PROTOCOL' =>'Order Protocol',
        'SELF_SERVE_STEP_STORE_HOURS' => 'Store Hours',
        'SELF_SERVE_STEP_MENU' => 'Menu',
        'SELF_SERVE_STEP_PRICING_PLAN' => 'Pricing Plan',
        'SELF_SERVE_STEP_BANKING_INFORMATION' => 'Banking Information'
    };
}