/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Wrapper Class to store Merchat Order details for Inbound and Outbound Integrations.
 **/
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity, PMD.ExcessiveClassLength')
public class MerchantOrdersPayloads {
    private static final String MX_ORDER_PAYLOAD_CONTENT_TYPE = 'application/json';
    private static final String MX_ORDER_PAYLOAD_PHOTOSHOOT_EVENT = 'photoshoot-order-create-event';
    private static final String MX_ORDER_SOURCE = 'ddmx';
    private static final String PRODUCT_BUNDLE_KEY_HOUR = 'hour';
    private static final String TIMEFORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    private static final String TIMESTAMPZONE = 'GMT';
    private static final String VERSION_VALUE = '1.0';

    private static Map<Id, MerchantOrdersWrapper> interfaceTransactionIdToPayLoad;

    /**
     * @description Default constructor for the class.
     */
    public MerchantOrdersPayloads() {
        interfaceTransactionIdToPayLoad = new Map<Id, MerchantOrdersWrapper>();
    }

    /**
     * @description Wrapper Class to store Merchat Order details for Inbound and Outbound Integrations.
     */
    public class MerchantOrdersWrapper {
        private String eventId;
        private String eventName;
        private String sourceSystem;
        private String timeStamp;
        private String version;
        private List<MxOrdersOutboundWrapper> order;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         * @param eventId
         * @param eventName
         */
        public MerchantOrdersWrapper(String eventId, String eventName) {
            this.eventId = eventId;
            this.eventName = eventName;
            this.order = new List<MxOrdersOutboundWrapper>();
            this.sourceSystem = MX_ORDER_SOURCE;
            this.timeStamp = System.Now().format(TIMEFORMAT, TIMESTAMPZONE);
            this.version = VERSION_VALUE;
        }
    }

    /**
     * @description Wrapper Class to store Merchat Order details for Inbound and Outbound Photoshoot Integrations.
     */
    public class PhotoshootMerchantOrdersWrapper {
        private String eventId;
        private String eventName;
        private String sourceSystem;
        private String timeStamp;
        private String version;
        private List<PhotoshootMxOrdersOutboundWrapper> order;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         * @param eventId
         */
        public PhotoshootMerchantOrdersWrapper(String eventId) {
            this.eventId = eventId;
            this.eventName = MX_ORDER_PAYLOAD_PHOTOSHOOT_EVENT;
            this.order = new List<PhotoshootMxOrdersOutboundWrapper>();
            this.sourceSystem = MX_ORDER_SOURCE;
            this.timeStamp = System.Now().format(TIMEFORMAT, TIMESTAMPZONE);
            this.version = VERSION_VALUE;
        }
    }

    /**
     * @description Wrapper Class to store Photoshoot Merchat Order details for outbound integrations.
     **/
    public class PhotoshootMxOrdersOutboundWrapper {
        private String mxOrderNumber;
        private String orderSFID;
        private String accountSFID;
        private String shootType;
        private String vendorName;
        private String title;
        private String notes;
        private String storeName;
        private String bundleName;
        private String menuSource;
        private List<PhotoshootAppointmentDetails> items;
        private List<AddressDetails> storeInfo;
        private String accountTimeZone;
        private String accountTimeZoneBackEnd;

        /**
         * @description Constructs a new MxOrdersOutboundWrapper object.
         */
        public PhotoshootMxOrdersOutboundWrapper() {
            this.items = new List<PhotoshootAppointmentDetails>();
            this.storeInfo = new List<AddressDetails>();
        }
    }

    /**
     * @description Wrapper Class to store photoshoot appointment details for outbound integrations.
     **/
    public class PhotoshootAppointmentDetails {
        private List<AppointmentSlots> appointmentSlots;
        /**
         * @description Constructs a new PhotoshootAppointmentDetails object.
         */
        public PhotoshootAppointmentDetails() {
            this.appointmentSlots = new List<AppointmentSlots>();
        }
    }

    /**
     * @description Wrapper Class to store appointment slots details for outbound integrations.
     **/
    public class AppointmentSlots {
        private String requestedDate;
        private String requestedTime;
        private Integer duration;
        /**
         * @description Constructs a new AppointmentSlots object.
         */
        public AppointmentSlots() {
            this.requestedDate = '';
            this.requestedTime = '';
            this.duration = 0;
        }
    }

    /**
     * @description Wrapper Class to store Merchat Order details for outbound Integrations.
     **/
    public class MxOrdersOutboundWrapper {
        private String mxOrderNumber;
        private String storeID;
        private String orderSFID;
        private String accountSFID;
        private String figmentAccountSFID;
        private String orderType;
        private String vendorName;
        private String returnReason;
        private String returnReasonOther;
        private String notes;
        private String deckRank;
        private String bundleName;
        private List<MxOrderItemsWrapper> items;
        private List<AddressDetails> shippingInfo;
        private ShipmentDetails shipmentDetails;
        private String vendorOrderId;

        /**
         * @description Constructs a new MxOrdersOutboundWrapper object.
         */
        public MxOrdersOutboundWrapper() {
            this.items = new List<MxOrderItemsWrapper>();
            this.shippingInfo = new List<AddressDetails>();
        }
    }

    /**
     * @description Wrapper Class to store Merchat Order Items details for outbound integrations.
     **/
    public class MxOrderItemsWrapper {
        private String productId;
        private String orderItemSFID;
        private String quantity;
        private String sku;
        private String productFamily;
        private String productName;
        private ProductLoginDetails productLoginInfo;
        private List<String> identifiers;

        /**
         * @description Constructs a new MxOrderItemsWrapper object.
         */
        public MxOrderItemsWrapper() {
            this.identifiers = new List<String>();
        }
    }

    /**
     * @description Wrapper Class to store product login details for outbound integrations.
     **/
    public class ProductLoginDetails {
        private String username;
        private String password;
        private String language;
        /**
         * @description Constructs a new ProductLoginDetails object.
         */
        public ProductLoginDetails() {
            this.username = '';
            this.password = '';
            this.language = '';
        }
    }

    /**
     * @description Wrapper Class to store address details for outbound integrations.
     **/
    public class AddressDetails {
        private String name;
        private String addressType;
        private String contactFirstName;
        private String contactLastName;
        private String phoneNumber;
        private String email;
        private String longitude;
        private String latitude;
        private String notes;
        private String address1;
        private String address2;
        private String city;
        private String postalCode;
        private String state;
        private String countryCode;
        private String country;
        /**
         * @description Constructs a new AddressDetails object.
         */
        public AddressDetails() {
            this.name = '';
            this.addressType = '';
            this.contactFirstName = '';
            this.contactLastName = '';
            this.phoneNumber = '';
            this.email = '';
            this.longitude = '';
            this.latitude = '';
            this.notes = '';
            this.address1 = '';
            this.address2 = '';
            this.city = '';
            this.postalCode = '';
            this.state = '';
            this.countryCode = '';
            this.country = '';
        }
    }

    /**
     * @description Wrapper Class to store shipment details for outbound integrations.
     **/
    public class ShipmentDetails {
        private String trackingNumber;
        private String carrier;
        private String carrierService;
        private String preferredMethod;
        /**
         * @description Constructs a new ShipmentDetails object.
         */
        public ShipmentDetails() {
            this.trackingNumber = '';
            this.carrier = '';
            this.carrierService = '';
            this.preferredMethod = '';
        }
    }

    /**
     * @description It gets the salesforce Account Id value in the wrapper for creating payload
     * @param mxOrdersWrapperInstance
     * @return String
     */
    public String getAccountSFID(MerchantOrdersWrapper mxOrdersWrapperInstance) {
        String accountSFIDValue = mxOrdersWrapperInstance.order[0].accountSFID;
        return String.isNotBlank(accountSFIDValue) ? accountSFIDValue : '';
    }

    /**
     * @description It gets the salesforce Account Id value in the wrapper for creating payload
     * @param mxOrdersWrapperInstance
     * @return String
     */
    public String getVendorOrderId(MxOrdersOutboundWrapper mxOrdersWrapperInstance) {
        String vendorOrderIdvalue;
        if (mxOrdersWrapperInstance != null) {
            vendorOrderIdvalue = mxOrdersWrapperInstance?.vendorOrderId;
        }
        return String.isNotBlank(vendorOrderIdvalue) ? vendorOrderIdvalue : '';
    }

    /**
     * @description It gets the salesforce Order Id value in the wrapper for creating payload
     * @param mxOrdersWrapperInstance
     * @return String
     */
    public String getOrderSFID(MerchantOrdersWrapper mxOrdersWrapperInstance) {
        String orderSFIDValue = mxOrdersWrapperInstance.order[0].orderSFID;
        return String.isNotBlank(orderSFIDValue) ? orderSFIDValue : '';
    }

    /**
     * @description It gets the salesforce Account Ids value in the wrapper for creating payload
     * @param mxOrdersWrapperInstance
     * @return Set<String>
     */
    public Set<String> getAccountSFIDs(MerchantOrdersWrapper mxOrdersWrapperInstance) {
        Set<String> accountIds = new Set<String>();
        for (MxOrdersOutboundWrapper eachMxOrdersOutboundWrapper : mxOrdersWrapperInstance.order) {
            if (String.isNotBlank(eachMxOrdersOutboundWrapper.accountSFID)) {
                accountIds.add(eachMxOrdersOutboundWrapper.accountSFID);
            }
        }
        return accountIds;
    }

    /**
     * @description It gets the salesforce Account Ids value from photoshoot payload.
     * @param mxOrdersWrapperInstance
     * @return Set<String>
     */
    public Set<String> getPhotoshootAccountSFIDs(
        PhotoshootMerchantOrdersWrapper mxOrdersWrapperInstance
    ) {
        Set<String> accountIds = new Set<String>();
        for (
            PhotoshootMxOrdersOutboundWrapper eachMxOrdersOutboundWrapper : mxOrdersWrapperInstance.order
        ) {
            if (String.isNotBlank(eachMxOrdersOutboundWrapper.accountSFID)) {
                accountIds.add(eachMxOrdersOutboundWrapper.accountSFID);
            }
        }
        return accountIds;
    }

    /**
     * @description It gets the salesforce Order Ids value from photoshoot payload.
     * @param mxOrdersWrapperInstance
     * @return Set<String>
     */
    public Set<String> getPhotoshootOrderSFIDs(
        PhotoshootMerchantOrdersWrapper mxOrdersWrapperInstance
    ) {
        Set<String> orderIds = new Set<String>();
        for (
            PhotoshootMxOrdersOutboundWrapper eachMxOrdersOutboundWrapper : mxOrdersWrapperInstance.order
        ) {
            if (String.isNotBlank(eachMxOrdersOutboundWrapper.orderSFID)) {
                orderIds.add(eachMxOrdersOutboundWrapper.orderSFID);
            }
        }
        return orderIds;
    }

    /**
     * @description It gets the salesforce Order Ids value in the wrapper for creating payload
     * @param mxOrdersWrapperInstance
     * @return Set<String>
     */
    public Set<String> getOrderSFIDs(MerchantOrdersWrapper mxOrdersWrapperInstance) {
        Set<String> orderIds = new Set<String>();
        for (MxOrdersOutboundWrapper eachMxOrdersOutboundWrapper : mxOrdersWrapperInstance.order) {
            if (String.isNotBlank(eachMxOrdersOutboundWrapper.orderSFID)) {
                orderIds.add(eachMxOrdersOutboundWrapper.orderSFID);
            }
        }
        return orderIds;
    }

    /**
     * @description It sets the trackingNumber value in the wrapper for creating payload
     * @param shipmentDetails
     * @param valueToSet
     */
    public void setTrackingNumber(ShipmentDetails shipmentDetails, String valueToSet) {
        shipmentDetails.trackingNumber = valueToSet;
    }

    /**
     * @description It sets the carrier value in the wrapper for creating payload
     * @param shipmentDetails
     * @param valueToSet
     */
    public void setCarrier(ShipmentDetails shipmentDetails, String valueToSet) {
        shipmentDetails.carrier = valueToSet;
    }

    /**
     * @description It sets the carrierService value in the wrapper for creating payload
     * @param shipmentDetails
     * @param valueToSet
     */
    public void setCarrierService(ShipmentDetails shipmentDetails, String valueToSet) {
        shipmentDetails.carrierService = valueToSet;
    }

    /**
     * @description It sets the preferredMethod value in the wrapper for creating payload
     * @param shipmentDetails
     * @param valueToSet
     */
    public void setPreferredMethod(ShipmentDetails shipmentDetails, String valueToSet) {
        shipmentDetails.preferredMethod = valueToSet;
    }

    /**
     * @description It sets the name value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setName(AddressDetails addressDetails, String valueToSet) {
        addressDetails.name = valueToSet;
    }

    /**
     * @description It sets the notes value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setAddressNotes(AddressDetails addressDetails, String valueToSet) {
        addressDetails.notes = valueToSet;
    }

    /**
     * @description It sets the latitude value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setLatitude(AddressDetails addressDetails, String valueToSet) {
        addressDetails.latitude = valueToSet;
    }

    /**
     * @description It sets the longitude value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setLongitude(AddressDetails addressDetails, String valueToSet) {
        addressDetails.longitude = valueToSet;
    }

    /**
     * @description It sets the addressType value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setAddressType(AddressDetails addressDetails, String valueToSet) {
        addressDetails.addressType = valueToSet;
    }

    /**
     * @description It sets the contactFirstName value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setContactFirstName(AddressDetails addressDetails, String valueToSet) {
        addressDetails.contactFirstName = valueToSet;
    }

    /**
     * @description It sets the contactLastName value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setContactLastName(AddressDetails addressDetails, String valueToSet) {
        addressDetails.contactLastName = valueToSet;
    }

    /**
     * @description It sets the phoneNumber value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setPhoneNumber(AddressDetails addressDetails, String valueToSet) {
        addressDetails.phoneNumber = valueToSet;
    }

    /**
     * @description It sets the email value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setEmail(AddressDetails addressDetails, String valueToSet) {
        addressDetails.email = valueToSet;
    }

    /**
     * @description It sets the address1 value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setAddress1(AddressDetails addressDetails, String valueToSet) {
        addressDetails.address1 = valueToSet;
    }

    /**
     * @description It sets the address2 value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setAddress2(AddressDetails addressDetails, String valueToSet) {
        addressDetails.address2 = valueToSet;
    }

    /**
     * @description It sets the city value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setCity(AddressDetails addressDetails, String valueToSet) {
        addressDetails.city = valueToSet;
    }

    /**
     * @description It sets the postalCode value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setPostalCode(AddressDetails addressDetails, String valueToSet) {
        addressDetails.postalCode = valueToSet;
    }

    /**
     * @description It sets the state value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setState(AddressDetails addressDetails, String valueToSet) {
        addressDetails.state = valueToSet;
    }

    /**
     * @description It sets the countryCode value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setCountryCode(AddressDetails addressDetails, String valueToSet) {
        addressDetails.countryCode = valueToSet;
    }

    /**
     * @description It sets the country value in the wrapper for creating payload
     * @param addressDetails
     * @param valueToSet
     */
    public void setCountry(AddressDetails addressDetails, String valueToSet) {
        addressDetails.country = valueToSet;
    }

    /**
     * @description It sets the username value in the wrapper for creating payload
     * @param productLoginDetails
     * @param valueToSet
     */
    public void setUsername(ProductLoginDetails productLoginDetails, String valueToSet) {
        productLoginDetails.username = valueToSet;
    }

    /**
     * @description It sets the password value in the wrapper for creating payload
     * @param productLoginDetails
     * @param valueToSet
     */
    public void setPassword(ProductLoginDetails productLoginDetails, String valueToSet) {
        productLoginDetails.password = valueToSet;
    }

    /**
     * @description It sets the language value in the wrapper for creating payload
     * @param productLoginDetails
     * @param valueToSet
     */
    public void setLanguage(ProductLoginDetails productLoginDetails, String valueToSet) {
        productLoginDetails.language = valueToSet;
    }

    /**
     * @description It sets the productId value in the wrapper for creating payload
     * @param mxOrderItemsWrapper
     * @param valueToSet
     */
    public void setProductId(MxOrderItemsWrapper mxOrderItemsWrapper, String valueToSet) {
        mxOrderItemsWrapper.productId = valueToSet;
    }

    /**
     * @description It sets the orderItemSFID value in the wrapper for creating payload
     * @param mxOrderItemsWrapper
     * @param valueToSet
     */
    public void setOrderItemSFID(MxOrderItemsWrapper mxOrderItemsWrapper, String valueToSet) {
        mxOrderItemsWrapper.orderItemSFID = valueToSet;
    }

    /**
     * @description It sets the quantity value in the wrapper for creating payload
     * @param mxOrderItemsWrapper
     * @param valueToSet
     */
    public void setQuantity(MxOrderItemsWrapper mxOrderItemsWrapper, String valueToSet) {
        mxOrderItemsWrapper.quantity = valueToSet;
    }

    /**
     * @description It sets the product SKU value in the wrapper for creating payload
     * @param mxOrderItemsWrapper
     * @param valueToSet
     */
    public void setSKU(MxOrderItemsWrapper mxOrderItemsWrapper, String valueToSet) {
        mxOrderItemsWrapper.sku = valueToSet;
    }

    /**
     * @description It sets the productFamily value in the wrapper for creating payload
     * @param mxOrderItemsWrapper
     * @param valueToSet
     */
    public void setProductFamily(MxOrderItemsWrapper mxOrderItemsWrapper, String valueToSet) {
        mxOrderItemsWrapper.productFamily = valueToSet;
    }

    /**
     * @description It sets the productName value in the wrapper for creating payload
     * @param mxOrderItemsWrapper
     * @param valueToSet
     */
    public void setProductName(MxOrderItemsWrapper mxOrderItemsWrapper, String valueToSet) {
        mxOrderItemsWrapper.productName = valueToSet;
    }

    /**
     * @description It sets the productLoginInfo value in the wrapper for creating payload
     * @param mxOrderItemsWrapper
     * @param productLoginDetails
     */
    public void setProductLoginInfo(
        MxOrderItemsWrapper mxOrderItemsWrapper,
        ProductLoginDetails productLoginDetails
    ) {
        mxOrderItemsWrapper.productLoginInfo = productLoginDetails;
    }

    /**
     * @description It sets the identifiers value in the wrapper for creating payload
     * @param mxOrderItemsWrapper
     * @param valueToSet
     */
    public void setIdentifiers(MxOrderItemsWrapper mxOrderItemsWrapper, String valueToSet) {
        mxOrderItemsWrapper.identifiers.add(valueToSet);
    }

    /**
     * @description It sets the identifiers value in the wrapper for creating payload
     * @param mxOrderItemsWrapper
     * @param valueToSet
     */
    public void setIdentifiers(MxOrderItemsWrapper mxOrderItemsWrapper, List<String> valueToSet) {
        mxOrderItemsWrapper.identifiers.addAll(valueToSet);
    }

    /**
     * @description LEM-15028 It sets the vendorOrderId value in the wrapper for creating payload
     * @param mxOrdersOutboundWrapper
     * @param valueToSet
     **/
    public void setVendorOrderId(
        MxOrdersOutboundWrapper mxOrdersOutboundWrapper,
        String valueToSet
    ) {
        mxOrdersOutboundWrapper.vendorOrderId = valueToSet;
    }

    /**
     * @description It sets the shipmentDetails value in the wrapper for creating payload
     * @param shipmentDetails
     * @param mxOrdersOutboundWrapper
     */
    public void setShipmentDetails(
        ShipmentDetails shipmentDetails,
        MxOrdersOutboundWrapper mxOrdersOutboundWrapper
    ) {
        mxOrdersOutboundWrapper.shipmentDetails = shipmentDetails;
    }

    /**
     * @description It sets the shippingInfo value in the wrapper for creating payload
     * @param addressDetails
     * @param mxOrdersOutboundWrapper
     */
    public void setShippingInfo(
        List<AddressDetails> addressDetails,
        MxOrdersOutboundWrapper mxOrdersOutboundWrapper
    ) {
        mxOrdersOutboundWrapper.shippingInfo.addAll(addressDetails);
    }

    /**
     * @description It sets the items value in the wrapper for creating payload
     * @param mxOrderItemsWrappers
     * @param mxOrdersOutboundWrapper
     */
    public void setItems(
        List<MxOrderItemsWrapper> mxOrderItemsWrappers,
        MxOrdersOutboundWrapper mxOrdersOutboundWrapper
    ) {
        mxOrdersOutboundWrapper.items.addAll(mxOrderItemsWrappers);
    }

    /**
     * @description It sets the shippingInfo value in the wrapper for creating payload
     * @param addressDetails
     * @param mxOrdersOutboundWrapper
     */
    public void setShippingInfo(
        AddressDetails addressDetails,
        MxOrdersOutboundWrapper mxOrdersOutboundWrapper
    ) {
        mxOrdersOutboundWrapper.shippingInfo.add(addressDetails);
    }

    /**
     * @description It sets the items value in the wrapper for creating payload
     * @param mxOrderItemsWrapper
     * @param mxOrdersOutboundWrapper
     */
    public void setItems(
        MxOrderItemsWrapper mxOrderItemsWrapper,
        MxOrdersOutboundWrapper mxOrdersOutboundWrapper
    ) {
        mxOrdersOutboundWrapper.items.add(mxOrderItemsWrapper);
    }

    /**
     * @description It sets the mxOrderNumber value in the wrapper for creating payload
     * @param merchantOrdersWrapper
     * @param mxOrdersOutboundWrapper
     */
    public void setOrder(
        MerchantOrdersWrapper merchantOrdersWrapper,
        MxOrdersOutboundWrapper mxOrdersOutboundWrapper
    ) {
        merchantOrdersWrapper.order.add(mxOrdersOutboundWrapper);
    }

    /**
     * @description It sets the mxOrderNumber value in the wrapper for creating payload
     * @param merchantOrdersWrapper
     * @param mxOrdersOutboundWrappers
     */
    public void setOrder(
        MerchantOrdersWrapper merchantOrdersWrapper,
        List<MxOrdersOutboundWrapper> mxOrdersOutboundWrappers
    ) {
        merchantOrdersWrapper.order.addAll(mxOrdersOutboundWrappers);
    }

    /**
     * @description It sets the mxOrderNumber value in the wrapper for creating payload
     * @param mxOrdersOutboundWrapper
     * @param valueToSet
     */
    public void setMxOrderNumber(
        MxOrdersOutboundWrapper mxOrdersOutboundWrapper,
        String valueToSet
    ) {
        mxOrdersOutboundWrapper.mxOrderNumber = valueToSet;
    }

    /**
     * @description It sets the storeID value in the wrapper for creating payload
     * @param mxOrdersOutboundWrapper
     * @param valueToSet
     */
    public void setStoreId(MxOrdersOutboundWrapper mxOrdersOutboundWrapper, String valueToSet) {
        mxOrdersOutboundWrapper.storeID = valueToSet;
    }

    /**
     * @description It sets the orderSFID value in the wrapper for creating payload
     * @param mxOrdersOutboundWrapper
     * @param valueToSet
     */
    public void setOrderSFID(MxOrdersOutboundWrapper mxOrdersOutboundWrapper, String valueToSet) {
        mxOrdersOutboundWrapper.orderSFID = valueToSet;
    }

    /**
     * @description It sets the accountSFID value in the wrapper for creating payload
     * @param mxOrdersOutboundWrapper
     * @param valueToSet
     */
    public void setAccountSFID(MxOrdersOutboundWrapper mxOrdersOutboundWrapper, String valueToSet) {
        mxOrdersOutboundWrapper.accountSFID = valueToSet;
    }

    /**
     * @description It sets the figmentAccountSFID value in the wrapper for creating payload
     * @param mxOrdersOutboundWrapper
     * @param valueToSet
     */
    public void setFigmentAccountSFID(
        MxOrdersOutboundWrapper mxOrdersOutboundWrapper,
        String valueToSet
    ) {
        mxOrdersOutboundWrapper.figmentAccountSFID = valueToSet;
    }

    /**
     * @description It sets the orderType value in the wrapper for creating payload
     * @param mxOrdersOutboundWrapper
     * @param valueToSet
     */
    public void setOrderType(MxOrdersOutboundWrapper mxOrdersOutboundWrapper, String valueToSet) {
        mxOrdersOutboundWrapper.orderType = valueToSet;
    }

    /**
     * @description It sets the vendorName value in the wrapper for creating payload
     * @param mxOrdersOutboundWrapper
     * @param valueToSet
     */
    public void setVendorName(MxOrdersOutboundWrapper mxOrdersOutboundWrapper, String valueToSet) {
        mxOrdersOutboundWrapper.vendorName = valueToSet;
    }

    /**
     * @description It sets the returnReason value in the wrapper for creating payload
     * @param mxOrdersOutboundWrapper
     * @param valueToSet
     */
    public void setReturnReason(
        MxOrdersOutboundWrapper mxOrdersOutboundWrapper,
        String valueToSet
    ) {
        mxOrdersOutboundWrapper.returnReason = valueToSet;
    }

    /**
     * @description It sets the Replacement Reason (Other) value in the wrapper for creating payload
     * @param mxOrdersOutboundWrapper
     * @param valueToSet
     */
    public void setReturnReasonOther(
        MxOrdersOutboundWrapper mxOrdersOutboundWrapper,
        String valueToSet
    ) {
        mxOrdersOutboundWrapper.returnReasonOther = valueToSet;
    }

    /**
     * @description It sets the Notes value in the wrapper for creating payload
     * @param mxOrdersOutboundWrapper
     * @param valueToSet
     */
    public void setNotes(MxOrdersOutboundWrapper mxOrdersOutboundWrapper, String valueToSet) {
        mxOrdersOutboundWrapper.notes = valueToSet;
    }

    /**
     * @description It sets the deckRank value in the wrapper for creating payload
     * @param mxOrdersOutboundWrapper
     * @param valueToSet
     */
    public void setDeckRank(MxOrdersOutboundWrapper mxOrdersOutboundWrapper, String valueToSet) {
        mxOrdersOutboundWrapper.deckRank = valueToSet;
    }

    /**
     * @description It sets the bundleName value in the wrapper for creating payload
     * @param mxOrdersOutboundWrapper
     * @param valueToSet
     */
    public void setBundleName(MxOrdersOutboundWrapper mxOrdersOutboundWrapper, String valueToSet) {
        mxOrdersOutboundWrapper.bundleName = valueToSet;
    }

    /**
     * @description It sets the order value in the wrapper for creating payload
     * @param newPhotoshootMxOrdersWrapper
     * @param newPhotoshootMxOutboundWrappers
     */
    public void setPhotoshootOrder(
        PhotoshootMerchantOrdersWrapper newPhotoshootMxOrdersWrapper,
        PhotoshootMxOrdersOutboundWrapper newPhotoshootMxOutboundWrappers
    ) {
        newPhotoshootMxOrdersWrapper.order.add(newPhotoshootMxOutboundWrappers);
    }

    /**
     * @description It sets the order values in the wrapper for creating payload
     * @param newPhotoshootMxOrdersWrapper
     * @param newPhotoshootMxOutboundWrappers
     */
    public void setPhotoshootOrder(
        PhotoshootMerchantOrdersWrapper newPhotoshootMxOrdersWrapper,
        List<PhotoshootMxOrdersOutboundWrapper> newPhotoshootMxOutboundWrappers
    ) {
        newPhotoshootMxOrdersWrapper.order.addAll(newPhotoshootMxOutboundWrappers);
    }
    /**
     * @description It sets the duration value in the wrapper for creating photoshoot payload
     * @param appointmentDetails
     * @param valueToSet
     */
    public void setPhotoshootDuration(AppointmentSlots appointmentDetails, String valueToSet) {
        if (String.isNotBlank(valueToSet) && valueToSet.contains(PRODUCT_BUNDLE_KEY_HOUR)) {
            appointmentDetails.duration = getDurationBasedOnBundleName(valueToSet);
        } else {
            appointmentDetails.duration = 0;
        }
    }

    /**
     * @description It sets the requestedTime value in the wrapper for creating photoshoot payload
     * @param appointmentDetails
     * @param valueToSet
     */
    public void setPhotoshootRequestedTime(AppointmentSlots appointmentDetails, String valueToSet) {
        appointmentDetails.requestedTime = valueToSet;
    }

    /**
     * @description It sets the requestedDate value in the wrapper for creating photoshoot payload
     * @param appointmentDetails
     * @param valueToSet
     */
    public void setPhotoshootRequestedDate(AppointmentSlots appointmentDetails, String valueToSet) {
        appointmentDetails.requestedDate = valueToSet;
    }

    /**
     * @description It sets the items value in the wrapper for creating photoshoot payload
     * @param appointmentSlots
     * @param appointmentDetails
     */
    public void setPhotoshootItems(
        List<AppointmentSlots> appointmentSlots,
        PhotoshootAppointmentDetails appointmentDetails
    ) {
        appointmentDetails.appointmentSlots.addAll(appointmentSlots);
    }

    /**
     * @description It sets the items value in the wrapper for creating photoshoot payload
     * @param appointmentSlots
     * @param appointmentDetails
     */
    public void setPhotoshootItems(
        AppointmentSlots appointmentSlots,
        PhotoshootAppointmentDetails appointmentDetails
    ) {
        appointmentDetails.appointmentSlots.add(appointmentSlots);
    }

    /**
     * @description It sets the storeInfo value in the wrapper for creating photoshoot payload
     * @param addressDetails
     * @param photoshootMxOrdersOutboundWrapper
     */
    public void setPhotoshootStoreInfo(
        List<AddressDetails> addressDetails,
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrdersOutboundWrapper
    ) {
        photoshootMxOrdersOutboundWrapper.storeInfo.addAll(addressDetails);
    }

    /**
     * @description It sets the storeInfo value in the wrapper for creating photoshoot payload
     * @param addressDetails
     * @param photoshootMxOrdersOutboundWrapper
     */
    public void setPhotoshootStoreInfo(
        AddressDetails addressDetails,
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrdersOutboundWrapper
    ) {
        photoshootMxOrdersOutboundWrapper.storeInfo.add(addressDetails);
    }

    /**
     * @description It sets the items value in the wrapper for creating photoshoot payload
     * @param mxOrderItemsWrappers
     * @param photoshootMxOrdersOutboundWrapper
     */
    public void setPhotoshootItems(
        List<PhotoshootAppointmentDetails> mxOrderItemsWrappers,
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrdersOutboundWrapper
    ) {
        photoshootMxOrdersOutboundWrapper.items.addAll(mxOrderItemsWrappers);
    }

    /**
     * @description It sets the items value in the wrapper for creating photoshoot payload
     * @param mxOrderItemsWrapper
     * @param photoshootMxOrdersOutboundWrapper
     */
    public void setPhotoshootItems(
        PhotoshootAppointmentDetails mxOrderItemsWrapper,
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrdersOutboundWrapper
    ) {
        photoshootMxOrdersOutboundWrapper.items.add(mxOrderItemsWrapper);
    }

    /**
     * @description It sets the bundleName value in the wrapper for creating photoshoot payload
     * @param photoshootMxOrderDetails
     * @param valueToSet
     */
    public void setPhotoshootBundleName(
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrderDetails,
        String valueToSet
    ) {
        photoshootMxOrderDetails.bundleName = valueToSet;
    }

    /**
     * @description It sets the storeName value in the wrapper for creating photoshoot payload
     * @param photoshootMxOrderDetails
     * @param valueToSet
     */
    public void setPhotoshootStoreName(
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrderDetails,
        String valueToSet
    ) {
        photoshootMxOrderDetails.storeName = valueToSet;
    }

    /**
     * @description It sets the notes value in the wrapper for creating photoshoot payload
     * @param photoshootMxOrderDetails
     * @param valueToSet
     */
    public void setPhotoshootNotes(
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrderDetails,
        String valueToSet
    ) {
        photoshootMxOrderDetails.notes = valueToSet;
    }

    /**
     * @description It sets the title value in the wrapper for creating photoshoot payload
     * @param photoshootMxOrderDetails
     * @param valueToSet
     */
    public void setPhotoshootTitle(
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrderDetails,
        String valueToSet
    ) {
        photoshootMxOrderDetails.title = valueToSet;
    }

    /**
     * @description It sets the menuSource value in the wrapper for creating photoshoot payload
     * @param photoshootMxOrderDetails
     * @param valueToSet
     */
    public void setPhotoshootMenuSource(
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrderDetails,
        String valueToSet
    ) {
        photoshootMxOrderDetails.menuSource = valueToSet;
    }

    /**
     * @description It sets the vendorName value in the wrapper for creating photoshoot payload
     * @param photoshootMxOrderDetails
     * @param valueToSet
     */
    public void setPhotoshootVendorName(
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrderDetails,
        String valueToSet
    ) {
        photoshootMxOrderDetails.vendorName = valueToSet;
    }

    /**
     * @description It sets the shootType value in the wrapper for creating photoshoot payload
     * @param photoshootMxOrderDetails
     * @param valueToSet
     */
    public void setPhotoshootType(
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrderDetails,
        String valueToSet
    ) {
        photoshootMxOrderDetails.shootType = valueToSet;
    }

    /**
     * @description It sets the accountSFID value in the wrapper for creating photoshoot payload
     * @param photoshootMxOrderDetails
     * @param valueToSet
     */
    public void setPhotoshootAccountSFID(
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrderDetails,
        String valueToSet
    ) {
        photoshootMxOrderDetails.accountSFID = valueToSet;
    }

    /**
     * @description It sets the orderSFID value in the wrapper for creating photoshoot payload
     * @param photoshootMxOrderDetails
     * @param valueToSet
     */
    public void setPhotoshootOrderSFID(
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrderDetails,
        String valueToSet
    ) {
        photoshootMxOrderDetails.orderSFID = valueToSet;
    }
     /**
     * @description It sets the Account TimeZone value in the wrapper for creating photoshoot payload
     * @param photoshootMxOrderDetails
     * @param valueToSet
    */
    public void setPhotoshootTimeZoneBackEnd(
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrderDetails,
        String valueToSet
    ) {
        photoshootMxOrderDetails.accountTimeZoneBackEnd = valueToSet;
    }
    /**
     * @description It sets the Account TimeZone Backend value in the wrapper for creating photoshoot payload
     * @param photoshootMxOrderDetails
     * @param valueToSet
    */
    public void setPhotoshootTimeZone(
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrderDetails,
        String valueToSet
    ) {
        photoshootMxOrderDetails.accountTimeZone = valueToSet;
    }

    /**
     * @description It sets the mxOrderNumber value in the wrapper for creating photoshoot payload
     * @param photoshootMxOrderDetails
     * @param valueToSet
     */
    public void setPhotoshootMxOrderNumber(
        PhotoshootMxOrdersOutboundWrapper photoshootMxOrderDetails,
        String valueToSet
    ) {
        photoshootMxOrderDetails.mxOrderNumber = valueToSet;
    }

    /**
     * @description It returns the duration value in integer based on the bundle name.
     * @param bundleName
     * @return Integer
     */
    private Integer getDurationBasedOnBundleName(String bundleName) {
        return (Integer) (Double.valueOf(bundleName.remove(PRODUCT_BUNDLE_KEY_HOUR).trim()) * 60);
    }
}