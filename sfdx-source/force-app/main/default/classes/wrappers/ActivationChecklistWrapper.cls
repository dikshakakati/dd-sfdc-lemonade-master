/**
 * @author Deloitte
 * @date 04/08/2024
 * @description Wrapper Class for Activation Checklist Response.
 **/
@SuppressWarnings(
    'PMD.EmptyStatementBlock, PMD.ExcessivePublicCount, PMD.TooManyFields, PMD.FieldNamingConventions, PMD.FormalParameterNamingConventions'
)
public inherited sharing class ActivationChecklistWrapper {
    /**
     * @description Wrapper for storing information pertinent to the CSV validation/Readiness
     * Check results that happen when an AO uploads a Store CSV.
     **/
    public String source;
    public Integer storeId;
    public String accountSalesforceId;
    public String xrefSalesforceId;
    public String businessRefSalesforceId;
    public String workStepSalesforceId;
    public Error[] errors;
    public GetStore storeInformation;
    public GetPayment paymentAccountInformation;
    public GetBusinessDetails businessInformation;
    public GetMenu menuInformation;
    public List<GetPricingPrograms> pricingPrograms;
    public GetPointOfSales posInformation;

    /**
     * @description Constructor to initialize the variables.
     * @param storeId
     * @param accountSalesforceId
     * @param xrefSalesforceId
     * @param businessRefSalesforceId
     * @param workStepSalesforceId
     **/
    public ActivationChecklistWrapper(
        Integer storeId,
        String accountSalesforceId,
        String xrefSalesforceId,
        String businessRefSalesforceId,
        String workStepSalesforceId
    ) {
        this.storeId = storeId;
        this.accountSalesforceId = accountSalesforceId;
        this.xrefSalesforceId = xrefSalesforceId;
        this.businessRefSalesforceId = businessRefSalesforceId;
        this.workStepSalesforceId = workStepSalesforceId;
        this.errors = new List<Error>();
        this.storeInformation = new GetStore();
        this.paymentAccountInformation = new GetPayment();
        this.businessInformation = new GetBusinessDetails();
        this.menuInformation = new GetMenu();
        this.pricingPrograms = new List<GetPricingPrograms>();
        this.posInformation = new GetPointOfSales();
    }

    /**
     * @description Wrapper to store error details.
     **/
    public class Error {
        public String errorStage;
        public String description;
        public String errorType;

        /**
         * @description Constructor to initialize the variables.
         * @param errorStage
         * @param description
         * @param errorType
         **/
        public Error(String errorStage, String description, String errorType) {
            this.errorStage = errorStage;
            this.description = description;
            this.errorType = errorType;
        }
    }

    /**
     * @description Wrapper to contain store details.
     **/
    public class GetStore {
        public String storeId;
        public String name;
        public String isActive;
        public String email;
        public String contactEmails;
        public String addressId;
        public String businessId;
        public String submarketId;
        public String startingPointId;
        public String tierLevel;
        public String paymentAccountId;
        public String confirmProtocol;
        public String orderProtocol;
        public String merchantSuppliedId;
        public String paymentProtocolId;
        public String offersPickup;
        public String offersDelivery;
        public String isConsumerSubscriptionEligible;
        public String salesforceId;
        public String experience;

        /**
         * @description Default Constructor to initialize wrapper.
         **/
        public GetStore() {
        }
    }

    /**
     * @description Wrapper to store Payment details.
     */
    public class GetPayment {
        public String charges_enabled;
        public String transfers_enabled;

        /**
         * @description Default Constructor to initialize wrapper.
         */
        public GetPayment() {
        }

        /**
         * @description Constructor to intialize the variables.
         * @param charges_enabled
         * @param transfers_enabled
         */
        public GetPayment(String charges_enabled, String transfers_enabled) {
            this.charges_enabled = charges_enabled;
            this.transfers_enabled = transfers_enabled;
        }
    }

    /**
     * @description Wrapper to store Business details.
     */
    public class GetBusinessDetails {
        public String businessId;
        public String businessName;
        public String description;
        public String active;
        public String menuLocked;

        /**
         * @description Default Constructor to initialize wrapper.
         */
        public GetBusinessDetails() {
        }

        /**
         * @description Constructor to intialize the variables.
         * @param businessId
         * @param businessName
         * @param description
         * @param active
         * @param menuLocked
         */
        public GetBusinessDetails(
            String businessId,
            String businessName,
            String description,
            String active,
            String menuLocked
        ) {
            this.businessId = businessId;
            this.businessName = businessName;
            this.description = description;
            this.active = active;
            this.menuLocked = menuLocked;
        }
    }

    /**
     * @description Wrapper to store Menu details.
     */
    public class GetMenu {
        public String isMenuActive;

        /**
         * @description Default Constructor to initialize wrapper.
         */
        public GetMenu() {
        }

        /**
         * @description Constructor to intialize the variables.
         * @param isMenuActive
         */
        public GetMenu(String isMenuActive) {
            this.isMenuActive = isMenuActive;
        }
    }

    /**
     * @description Wrapper to store pricing program details.
     */
    public class GetPricingPrograms {
        public GetProducts productInformation;
        public GetPricing pricingInformation;
        public Boolean isActive;
        public Boolean isTrial;
        public Boolean isPostTrial;
        public Boolean isPartner;
        public String partnerShipId;
        public String sourceId;

        /**
         * @description Default Constructor to initialize wrapper.
         */
        public GetPricingPrograms() {
        }
    }

    /**
     * @description Wrapper to store product details.
     */
    public class GetProducts {
        public String experience;
        public String channel;
        public String fulfillmentType;
        public String audience;

        /**
         * @description Default Constructor to initialize wrapper.
         */
        public GetProducts() {
        }

        /**
         * @description Constructor to intialize the variables.
         * @param experience
         * @param channel
         * @param fulfillmentType
         * @param audience
         */
        public GetProducts(
            String experience,
            String channel,
            String fulfillmentType,
            String audience
        ) {
            this.experience = experience;
            this.channel = channel;
            this.fulfillmentType = fulfillmentType;
            this.audience = audience;
        }
    }

    /**
     * @description Wrapper to store pricing details.
     */
    public class GetPricing {
        public List<FeeAttributes> feeAttributesInformation;
        public Double tabletSubscriptionFee;
        public Double printerSubscriptionFee;

        /**
         * @description Default Constructor to initialize wrapper.
         */
        public GetPricing() {
            feeAttributesInformation = new List<FeeAttributes>();
        }
    }

    /**
     * @description Wrapper to store Fee attribute details.
     */
    public class FeeAttributes {
        public Double flatFee;
        public String feeType;
        public Double feeRate;
        public String startTime;
        public String endTime;

        /**
         * @description Default Constructor to initialize wrapper.
         */
        public FeeAttributes() {
        }
    }

    /**
     * @description Wrapper to store POS details.
     */
    public class GetPointOfSales {
        public String store_id;
        public String provider_type;
        public String location_id;
        public String will_pull_store_hours;

        /**
         * @description Default Constructor to initialize wrapper.
         */
        public GetPointOfSales() {
        }

        /**
         * @description Constructor to intialize the variables.
         * @param store_id
         * @param provider_type
         * @param location_id
         * @param will_pull_store_hours
         */
        public GetPointOfSales(
            String store_id,
            String provider_type,
            String location_id,
            String will_pull_store_hours
        ) {
            this.store_id = store_id;
            this.provider_type = provider_type;
            this.location_id = location_id;
            this.will_pull_store_hours = will_pull_store_hours;
        }
    }
}
