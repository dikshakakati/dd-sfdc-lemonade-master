/**
 * @author Deloitte
 * @date 07/07/2024
 * @description It is used to consolidate wrappers used in the Mx Portal ingestion process.
 */
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields')
public class MxPortalPayloadParser {
    public String id;
    public String createdAt;
    public String uuid;
    public String eventType;
    public StoreDetails store;
    public String promoType;
    public String campaignId;
    public Contact contact;

    /**
     * @description Wrapper for contact information received from the
     * mx portal payload. It is used to create contacts in Salesforce.
     */
    public class Contact {
        public String sfdcId;
        public String phone;
        public String firstName;
        public String lastName;
        public String email;
        public String mobilePhone;
    }

    /**
     * @description Wrapper for store account information received from the
     * mx portal payload. It is used to create store accounts in Salesforce.
     */
    public class StoreDetails {
        public String storeId;
        public Boolean isTest;
        public String businessId;
        public String storeName;
        public String vendorContractType;
        public String vendorActivityId;
        public String vendorContractRecord;
        public OrderProductsDetails orderProducts;
    }

    /**
     * @description Wrapper for product information received from the
     * mx portal payload. It is used to create quote lines in Salesforce.
     */
    public class OrderProductsDetails {
        public String name;
        public String bundleUuid;
        public String productCode;
        public String budget = '0.0';
        // public String currency;
        public Decimal marketingFee = 0.0;
        public String maxMarketingPercent = '0.0';
        public Decimal discountPercent;
        public String additionalMarketingFeeRate = '0.0';
        public Decimal maxDiscountAmount;
        public Decimal minOrderAmount;
        public Decimal flatDiscountAmount;
        public String targetAudience;
        public Decimal estimatedTotalInvestment;
        public String promoEndDate;
        public String promoStartDate;
        public Decimal orderCartMin = 0.0;
        public String storeTargeting;
        public String flatDiscountConsumer = '0.0';
        public String itemDiscountPercent = '0.0';
        public String maxDiscountConsumer = '0.0';
        public String visitThreshold;
        public String spentThreshold;
        public String trialCreditAmount = '0';
        public String budgetPeriod;
        public String daysOfWeek;
        public String dayTimeConstraints;
        public String daysUntilExpiry;
        public String diningSpendMinimum = '0.0';
        public String discountPercentConsumer = '0.0';
        public String discountedDeliveryFee = '0.0';
        public Decimal maxNumberOfRedemptions;
        public String menuItemNameItemIDOptionID;
        public String menuItemMinimumQuantity = '0.0';
        public String offerDetailedDescription;
        public String offerTitle;
        public String orderServiceType;
        public String promotionCode;
        public String timeOfDay;
        public String menuItemIDsOptionIDsItemsInListA;
        public String menuItemIDsOptionIDsItemsInListB;

        public List<ProductOptionsDetails> productOptions;
    }

    /**
     * @description Wrapper for product information received from the
     * mx portal payload. It is used to create quote line options in Salesforce.
     */
    public class ProductOptionsDetails {
        public String name;
        public String productCode;
        public String fee;
        public String commission;
        public String trialCommission;
        public String trialFee;
    }
}