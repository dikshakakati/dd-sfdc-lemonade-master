/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Service class for Merchant Order related logic.
 */
public inherited sharing class MerchantOrdersServiceImpl implements IMerchantOrdersService {
    private static final String ADDRESS_TYPE_SHIP_FROM = 'shipFrom';
    private static final String ADDRESS_TYPE_SHIP_TO = 'shipTo';
    private static final String DASH_SPLIT = '-';
    private static final String FAILED_RETURN_LABEL_TO_MX = 'Failed to Send to Mx';
    private static final String INTERFACE_TRANSACTION_STATUS_FAILURE = 'Failure';
    private static final String INTERFACE_TRANSACTION_STATUS_NEW = 'New';
    private static final String LOG_DOMAIN_MX_ORDER = 'Merchant Orders Update';
    private static final String LOG_SERVICE_MERCHANT_ORDERS = 'Merchant Orders Service';
    private static final String LOG_DOMAIN_TABLET_INTEGRATION = 'Tablet Outbound Integration';
    private static final String MX_ORDER_STATUS_FAILED = 'Failed';
    private static final String MX_ORDER_STATUS_INVALID = 'Invalid';
    private static final String MX_ORDER_TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String MX_ORDER_TYPE_TABLET = 'Tablet';
    private static final String MX_ORDER_TYPE_OF_REQUEST_NET_NEW = 'Net-New';
    private static final String MX_ORDER_TYPE_OF_REQUEST_RETURN = 'Return';
    private static final String MX_ORDER_VENDOR_DENALI = 'Denali';
    private static final String PHOTOSHOOT_OUTBOUND_CONFIG_NAME = 'Photoshoot_Outbound_Integration';
    private static final String PHOTOSHOOT_TITLE = 'Merchant Photoshoot';
    private static final String PHOTOSHOOT_TYPE_FOOD = 'food';
    private static final String REQUEST_TYPE_NEW = 'New';
    private static final String REQUEST_TYPE_REPLACEMENT = 'Replacement';
    private static final String RETURN_LABEL_SENT_TO_MX = 'Return Label Sent to Mx';
    private static final String TABLET_OUTBOUND_CONFIG_NAME = 'Tablet_Outbound_Integration';
    private static final String GUIDED_WORK_ORDER_SOURCE = 'Guided Flow';
    private static final Integer REVERSE_HOUR_DIFFERENCE = -1;
    private static final Map<String, String> MX_ORDER_TYPE_TO_PAYLOAD_TYPE = new Map<String, String>{
        MX_ORDER_TYPE_OF_REQUEST_NET_NEW => REQUEST_TYPE_NEW
    };
    private Boolean isVendorChanged;
    private Map<String, Integer> maximumRetryLimit;
    private Map<String, String> identifierToVendorId;
    private Map<Id, String> mxOrderIdToIdentifier;
    private Map<Id, String> mxOrdersPayloads;
    private Map<Id, String> mxOrderIdToStatus;
    private Map<Id, String> mxOrdersUseCase;
    private Set<String> orderIds;
    private Set<String> denaliReturnMxOrderIds;
    private Set<Id> tabletMxOrderIds;
    private Boolean regenarateMxPayload;
    private List<Interface_Transaction__c> updatedInterfaceTransactionsOnVendorChange;

    /**
     * @description Default Constructor to initialize class variables.
     */
    public MerchantOrdersServiceImpl() {
        denaliReturnMxOrderIds = new Set<String>();
        isVendorChanged = false;
        maximumRetryLimit = new Map<String, Integer>();
        mxOrdersPayloads = new Map<Id, String>();
        mxOrderIdToStatus = new Map<Id, String>();
        mxOrdersUseCase = new Map<Id, String>();
        orderIds = new Set<String>();
        regenarateMxPayload = false;
        mxOrderIdToIdentifier = new Map<Id, String>();
        identifierToVendorId = new Map<String, String>();
        tabletMxOrderIds = new Set<Id>();
        updatedInterfaceTransactionsOnVendorChange = new List<Interface_Transaction__c>();
        collectStaticConfigurations();
    }

    /**
     * @description It regenarates the Merchant Order payloads for outbound integration.
     * @JIRA# LEM-13497
     * @param mxOrders
     */
    public void retryPayloadGeneration(List<MX_Order__c> mxOrders) {
        regenarateMxPayload = true;
        initiateTabletIntegrationOnOrderCreation(mxOrders);
    }

    /**
     * @description It initiates the tablet integration process based on the passed orders.
     * @JIRA# LEM-13506
     * @param mxOrders
     */
    public void initiateTabletIntegrationOnOrderCreation(List<MX_Order__c> mxOrders) {
        Set<Id> photoshootMxOrderIds = new Set<Id>();
        Set<Id> tabletMxOrderStoreIds = new Set<Id>();
        Map<Id, Xref__c> storeAccountIdToXref = new Map<Id, Xref__c>();
        for (MX_Order__c eachMxOrder : mxOrders) {
            if (eachMxOrder.Status__c == MX_ORDER_STATUS_INVALID && !regenarateMxPayload) {
                continue;
            }
            if (eachMxOrder.Type__c == MX_ORDER_TYPE_TABLET) {
                tabletMxOrderIds.add(eachMxOrder.Id);
                tabletMxOrderStoreIds.add(eachMxOrder.Account__c);
                getProductIMEIFromReturnMxOrders(eachMxOrder);
            }
            if (eachMxOrder.Type__c == MX_ORDER_TYPE_PHOTOSHOOT) {
                photoshootMxOrderIds.add(eachMxOrder.Id);
            }
            orderIds.add((String) eachMxOrder.Id);
            mxOrderIdToStatus.put(eachMxOrder.Id, eachMxOrder.Status__c);
        }
        if (!tabletMxOrderIds.isEmpty()) {
            updatePayloadToSendOriginalOrderId();
            for (
                Xref__c eachXref : XrefsSelector.newInstance()
                    .selectMDSXrefsBySalesforceAccountIds(tabletMxOrderStoreIds)
            ) {
                storeAccountIdToXref.put(eachXref.Salesforce_Account_Name__c, eachXref);
            }
            generatePayloadsForOutboundIntegrationByMxOrders(
                new Map<Id, Mx_Order__c>(
                    MerchantOrdersSelector.newInstance()
                        .selectMerchantOrderRelatedDetailsById(tabletMxOrderIds)
                ),
                storeAccountIdToXref
            );
        }
        if (!photoshootMxOrderIds.isEmpty()) {
            generatePayloadsForPhotoshootOutboundIntegrationByMxOrders(
                MerchantOrdersSelector.newInstance()
                    .selectPhotoshootDetailsByMxOrderIds(photoshootMxOrderIds)
            );
        }
        updateInterfaceTransactions();
        createInterfaceTransactionsForMerchantOrderPayloads();
    }

    /**
     * @description It is used to collect Tablet/Printer IMEI from return Mx Orders
     * @JIRA# LEM-16567
     * @param tabletMxOrder
     */
    private void getProductIMEIFromReturnMxOrders(MX_Order__c tabletMxOrder) {
        if (
            tabletMxOrder.Type_Of_Request__c == MX_ORDER_TYPE_OF_REQUEST_RETURN ||
            tabletMxOrder.Type_Of_Request__c == REQUEST_TYPE_REPLACEMENT
        ) {
            if (
                tabletMxOrder.Tablet_IMEI__c != null &&
                String.isNotBlank(tabletMxOrder.Tablet_IMEI__c)
            ) {
                mxOrderIdToIdentifier.put(tabletMxOrder.Id, tabletMxOrder.Tablet_IMEI__c);
            } else if (
                tabletMxOrder.Printer_IMEI__c != null &&
                String.isNotBlank(tabletMxOrder.Printer_IMEI__c)
            ) {
                mxOrderIdToIdentifier.put(tabletMxOrder.Id, tabletMxOrder.Printer_IMEI__c);
            }
        }
    }

    /**
     * @description It reevaluates the Mx Order Items based on Vendor change.
     * @JIRA# LEM-20315
     * @param merchantOrders
     */
    public void reevaluateMerchantOrderItemsOnVendorChange(List<MX_Order__c> merchantOrders) {
        if (merchantOrders.isEmpty()) {
            return;
        }
        // It deletes the existing Mx Order Items and generates new Mx Order Items based on Vendor.
        SobjectDeletionService.fireRecordsDeletion(
            MerchantOrderItemsSelector.newInstance()
                .selectMxOrderItemWithMxOrderIds(new Map<Id, MX_Order__c>(merchantOrders).keySet())
        );
        MerchantOrderItemsService.createMxOrderItems(merchantOrders);
        regenarateMxPayload = true;
        isVendorChanged = true;
        initiateTabletIntegrationOnOrderCreation(merchantOrders);
        if (!updatedInterfaceTransactionsOnVendorChange.isEmpty()) {
            InterfaceTransactionsService.initiateOutboundIntegrationForinterfaceTransactions(
                updatedInterfaceTransactionsOnVendorChange
            );
        }
    }

    /**
     * @description It Updates the Payload to Send Original Order ID In Return Use Case
     * @JIRA# LEM-15028
     */
    private void updatePayloadToSendOriginalOrderId() {
        /* Fetching the MX order items with each Identifer */
        for (
            MX_Order_Item__c eachMxOrderItem : MerchantOrderItemsSelector.newInstance()
                .selectMxOrderItemWithMxOrderIds(tabletMxOrderIds)
        ) {
            if (eachMxOrderItem.Identifier__c == null) {
                continue;
            }
            if (!mxOrderIdToIdentifier.containsKey(eachMxOrderItem.Mx_Order__c)) {
                mxOrderIdToIdentifier.put(
                    eachMxOrderItem.Mx_Order__c,
                    eachMxOrderItem.Identifier__c
                );
            }
        }

        /* Fetching the MX order items with each IMEI for return of tablet/printer */
        Set<String> identifierValues = new Set<String>(mxOrderIdToIdentifier.values());
        for (
            MX_Order_Item__c eachMxOrderItem : MerchantOrderItemsSelector.newInstance()
                .selectMxOrderItemWithIdentifiers(identifierValues)
        ) {
            if (!tabletMxOrderIds.contains(eachMxOrderItem.Mx_Order__c)) {
                identifierToVendorId.put(
                    eachMxOrderItem.Identifier__c,
                    eachMxOrderItem.Mx_Order__r.Vendor_Order_Id__c
                );
            }
        }
    }

    /**
     * @description It updates MxOrders 'Return_Label_Status__c' value based on email results.
     * @JIRA# LEM-14703
     * @param failedMxOrderIds
     * @param passedMxOrderIds
     */
    public void updateMxOrdersReturnLabelStatusBasedOnEmailResults(
        Set<Id> failedMxOrderIds,
        Set<Id> passedMxOrderIds
    ) {
        List<MX_Order__c> mxOrdersToUpdate = new List<MX_Order__c>();
        Set<Id> mxOrderIds = new Set<Id>();
        mxOrderIds.addAll(failedMxOrderIds);
        mxOrderIds.addAll(passedMxOrderIds);
        for (Id eachMxOrderId : mxOrderIds) {
            mxOrdersToUpdate.add(
                new MX_Order__c(
                    Id = eachMxOrderId,
                    Return_Label_Status__c = passedMxOrderIds.contains(eachMxOrderId)
                        ? RETURN_LABEL_SENT_TO_MX
                        : FAILED_RETURN_LABEL_TO_MX
                )
            );
        }
        fireUpdateOnMxOrders(mxOrdersToUpdate);
    }

    /**
     * @description It is used to update last modified date of Merchant Order status.
     * @param merchantOrders
     */
    public void updateStatusModifiedDate(List<MX_Order__c> merchantOrders) {
        List<MX_Order__c> mxOrdersToUpdate = new List<MX_Order__c>();
        for (MX_Order__c eachMerchantOrder : merchantOrders) {
            mxOrdersToUpdate.add(
                new Mx_Order__c(
                    Id = eachMerchantOrder.Id,
                    Order_Status_Modified_Date__c = System.now()
                )
            );
        }
        fireUpdateOnMxOrders(mxOrdersToUpdate);
    }

    /**
     * @description It updates Mx Orders.
     * @JIRA# LEM-14703
     * @param mxOrdersToUpdate
     */
    private void fireUpdateOnMxOrders(List<MX_Order__c> mxOrdersToUpdate) {
        if (mxOrdersToUpdate.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowRecordsUpdate = Application.UnitOfWork.newInstance();
        uowRecordsUpdate.registerDirty(mxOrdersToUpdate);
        commitRecords(uowRecordsUpdate);
    }

    /**
     * @description It is used to update the new Interface Transaction records
     * with regenerated payload.
     */
    private void updateInterfaceTransactions() {
        fflib_ISObjectUnitOfWork uowUpdateTransactions = Application.UnitOfWork.newInstance();
        orderIds.removeAll(denaliReturnMxOrderIds);
        for (
            Interface_Transaction__c eachTransaction : InterfaceTransactionSelector.newInstance()
                .selectByOriginRecordIds(orderIds)
        ) {
            orderIds.remove(eachTransaction.Record_Id__c);
            eachTransaction.Payload__c = mxOrdersPayloads.get(eachTransaction.Record_Id__c);
            if (
                mxOrderIdToStatus.get(eachTransaction.Record_Id__c) == MX_ORDER_STATUS_FAILED &&
                !System.isBatch()
            ) {
                eachTransaction.Remaining_Retry_Attempts__c = maximumRetryLimit.get(
                    mxOrdersUseCase.get(eachTransaction.Record_Id__c)
                );
                eachTransaction.Status__c = INTERFACE_TRANSACTION_STATUS_FAILURE;
            }
            if (isVendorChanged) {
                eachTransaction.Remaining_Retry_Attempts__c = maximumRetryLimit.get(
                    mxOrdersUseCase.get(eachTransaction.Record_Id__c)
                );
                eachTransaction.Status__c = INTERFACE_TRANSACTION_STATUS_NEW;
            }
            uowUpdateTransactions.registerDirty(eachTransaction);
            updatedInterfaceTransactionsOnVendorChange.add(eachTransaction);
        }
        commitRecords(uowUpdateTransactions);
    }

    /**
     * @description It creates Interface Transaction records based on generated payloads
     * @JIRA# LEM-13506
     */
    private void createInterfaceTransactionsForMerchantOrderPayloads() {
        List<Interface_Transaction__c> interfaceTransactionsToInsert = new List<Interface_Transaction__c>();
        for (Id eachRecordId : mxOrdersPayloads.keySet()) {
            if (!orderIds.contains(eachRecordId)) {
                continue;
            }
            interfaceTransactionsToInsert.add(
                new Interface_Transaction__c(
                    Interface_Transaction_Configuration_Name__c = mxOrdersUseCase.get(eachRecordId),
                    Payload__c = mxOrdersPayloads.get(eachRecordId),
                    Record_Id__c = (String) eachRecordId,
                    Remaining_Retry_Attempts__c = maximumRetryLimit.get(
                        mxOrdersUseCase.get(eachRecordId)
                    ),
                    Status__c = INTERFACE_TRANSACTION_STATUS_NEW
                )
            );
        }
        if (interfaceTransactionsToInsert.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowRecordsCreation = Application.UnitOfWork.newInstance();
        uowRecordsCreation.registerNew(interfaceTransactionsToInsert);
        commitRecords(uowRecordsCreation);
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.maximumRetryLimit.put(
            TABLET_OUTBOUND_CONFIG_NAME,
            Integer.valueOf(
                InterfaceTransactionConfigSelector.newInstance()
                    .getInstanceValue(TABLET_OUTBOUND_CONFIG_NAME)
                    .Retry_Limit__c
            )
        );
        this.maximumRetryLimit.put(
            PHOTOSHOOT_OUTBOUND_CONFIG_NAME,
            Integer.valueOf(
                InterfaceTransactionConfigSelector.newInstance()
                    .getInstanceValue(PHOTOSHOOT_OUTBOUND_CONFIG_NAME)
                    .Retry_Limit__c
            )
        );
    }

    /**
     * @description It generates payload based on passed Mx Orders
     * @JIRA# LEM-13506
     * @param mxOrders
     * @param storeAccountIdToXref
     */
    private void generatePayloadsForOutboundIntegrationByMxOrders(
        Map<Id, MX_Order__c> mxOrders,
        Map<Id, Xref__c> storeAccountIdToXref
    ) {
        MerchantOrdersPayloads mxOrdersPayloadsInstance = new MerchantOrdersPayloads();
        MerchantOrdersPayloads.MxOrderItemsWrapper newMxOrderItemsWrapper = new MerchantOrdersPayloads.MxOrderItemsWrapper();
        MerchantOrdersPayloads.MxOrdersOutboundWrapper mxOrdersOutboundWrapperInstance = new MerchantOrdersPayloads.MxOrdersOutboundWrapper();
        MerchantOrdersPayloads.ProductLoginDetails productLoginDetailsInstance = new MerchantOrdersPayloads.ProductLoginDetails();
        MerchantOrdersPayloads.AddressDetails addressDetailsInstance = new MerchantOrdersPayloads.AddressDetails();
        MerchantOrdersPayloads.ShipmentDetails shipmentDetailsInstance = new MerchantOrdersPayloads.ShipmentDetails();
        MX_Order__c eachmxOrder;
        for (Id eachMxOrderId : mxOrders.keySet()) {
            eachmxOrder = mxOrders.get(eachMxOrderId);
            //For LEM-14703, to not generate payload for 'Return' and 'Denali' Mx Orders.
            if (
                eachmxOrder.Type_Of_Request__c == MX_ORDER_TYPE_OF_REQUEST_RETURN &&
                eachmxOrder.Vendor__c == MX_ORDER_VENDOR_DENALI &&
                eachmxOrder.Work_Order_Sub_Type__c == REQUEST_TYPE_REPLACEMENT
            ) {
                denaliReturnMxOrderIds.add((String) eachMxOrderId);
                continue;
            }
            updateOrderInformationOnPayload(
                mxOrdersPayloadsInstance,
                mxOrdersOutboundWrapperInstance,
                eachmxOrder,
                storeAccountIdToXref.get(eachmxOrder?.Account__c)
            );
            for (MX_Order_Item__c eachOrderItem : eachmxOrder.Merchant_Order_Items__r) {
                updateOrderItemDetailsOnPayload(
                    mxOrdersPayloadsInstance,
                    newMxOrderItemsWrapper,
                    eachOrderItem
                );
                updateProductLoginDetailsOnPayload(
                    mxOrdersPayloadsInstance,
                    productLoginDetailsInstance,
                    eachOrderItem
                );
                mxOrdersPayloadsInstance.setProductLoginInfo(
                    newMxOrderItemsWrapper,
                    productLoginDetailsInstance
                );
                mxOrdersPayloadsInstance.setItems(
                    newMxOrderItemsWrapper,
                    mxOrdersOutboundWrapperInstance
                );
                productLoginDetailsInstance = new MerchantOrdersPayloads.ProductLoginDetails();
                newMxOrderItemsWrapper = new MerchantOrdersPayloads.MxOrderItemsWrapper();
            }
            updateAddressDetailsOnPayload(
                mxOrdersPayloadsInstance,
                addressDetailsInstance,
                eachmxOrder
            );
            mxOrdersPayloadsInstance.setShippingInfo(
                addressDetailsInstance,
                mxOrdersOutboundWrapperInstance
            );
            addressDetailsInstance = new MerchantOrdersPayloads.AddressDetails();
            updateShipmentDetailsOnPayload(
                mxOrdersPayloadsInstance,
                shipmentDetailsInstance,
                eachmxOrder
            );
            mxOrdersPayloadsInstance.setShipmentDetails(
                shipmentDetailsInstance,
                mxOrdersOutboundWrapperInstance
            );
            shipmentDetailsInstance = new MerchantOrdersPayloads.ShipmentDetails();
            mxOrdersPayloads.put(eachMxOrderId, JSON.serialize(mxOrdersOutboundWrapperInstance));
            mxOrdersUseCase.put(eachMxOrderId, TABLET_OUTBOUND_CONFIG_NAME);
            mxOrdersOutboundWrapperInstance = new MerchantOrdersPayloads.MxOrdersOutboundWrapper();
        }
    }

    /**
     * @description It generates payload based on passed Mx Orders
     * @JIRA# LEM-13506
     * @param mxOrders
     */
    private void generatePayloadsForPhotoshootOutboundIntegrationByMxOrders(
        List<MX_Order__c> mxOrders
    ) {
        MerchantOrdersPayloads mxOrdersPayloadsInstance = new MerchantOrdersPayloads();
        MerchantOrdersPayloads.PhotoshootMxOrdersOutboundWrapper newPhotoshootOutboundWrapper = new MerchantOrdersPayloads.PhotoshootMxOrdersOutboundWrapper();
        MerchantOrdersPayloads.PhotoshootAppointmentDetails newPhotoshootAppointmentDetails = new MerchantOrdersPayloads.PhotoshootAppointmentDetails();
        MerchantOrdersPayloads.AppointmentSlots appointmentSlotsInstance = new MerchantOrdersPayloads.AppointmentSlots();
        MerchantOrdersPayloads.AddressDetails addressDetailsInstance = new MerchantOrdersPayloads.AddressDetails();
        Address photoshootStoreAddress;
        Date photoShootDate;
        Time photoShootTime;
        Datetime photoShootDateTimeInGMT;
        for (MX_Order__c eachMxOrder : mxOrders) {
            mxOrdersPayloadsInstance.setPhotoshootMxOrderNumber(
                newPhotoshootOutboundWrapper,
                eachMxOrder?.Name
            );
            mxOrdersPayloadsInstance.setPhotoshootOrderSFID(
                newPhotoshootOutboundWrapper,
                eachMxOrder.Id
            );
            mxOrdersPayloadsInstance.setPhotoshootAccountSFID(
                newPhotoshootOutboundWrapper,
                eachMxOrder?.Account__c
            );
            mxOrdersPayloadsInstance.setPhotoshootType(
                newPhotoshootOutboundWrapper,
                PHOTOSHOOT_TYPE_FOOD
            );
            mxOrdersPayloadsInstance.setPhotoshootVendorName(
                newPhotoshootOutboundWrapper,
                eachMxOrder?.Vendor__c
            );
            mxOrdersPayloadsInstance.setPhotoshootTitle(
                newPhotoshootOutboundWrapper,
                PHOTOSHOOT_TITLE
            );
            mxOrdersPayloadsInstance.setPhotoshootMenuSource(
                newPhotoshootOutboundWrapper,
                eachMxOrder?.Menu_Source_for_Photoshoot__c
            );
            mxOrdersPayloadsInstance.setPhotoshootNotes(
                newPhotoshootOutboundWrapper,
                eachMxOrder?.Photoshoot_Review_Notes_Tags__c
            );
            mxOrdersPayloadsInstance.setPhotoshootStoreName(
                newPhotoshootOutboundWrapper,
                eachMxOrder?.Work_Order__r?.Store_Location_for_Photoshoot__r?.Name
            );
            mxOrdersPayloadsInstance.setPhotoshootBundleName(
                newPhotoshootOutboundWrapper,
                eachMxOrder?.Product_Bundle__r?.Name
            );
            mxOrdersPayloadsInstance.setPhotoshootTimeZone(
                newPhotoshootOutboundWrapper,
                eachMxOrder?.Account__r?.Time_Zone__c
            );
            mxOrdersPayloadsInstance.setPhotoshootTimeZoneBackEnd(
                newPhotoshootOutboundWrapper,
                eachMxOrder?.Account__r?.Time_Zone_Backend__c
            );
            //LEM-17067- Convert into UTC Format - guided Flow
            if (eachMxOrder.Work_Order__r.Creation_Source__c == GUIDED_WORK_ORDER_SOURCE) {
                photoShootDate = eachMxOrder?.Work_Order__r?.Photoshoot_Date__c;
                photoShootTime = eachMxOrder?.Work_Order__r?.Photoshoot_Time__c;
                if (photoShootDate != null && photoShootTime != null) {
                    photoShootDateTimeInGMT = Datetime.newInstance(
                            eachMxOrder?.Work_Order__r?.Photoshoot_Date__c,
                            eachMxOrder?.Work_Order__r?.Photoshoot_Time__c
                        );
                    mxOrdersPayloadsInstance.setPhotoshootRequestedDate(
                        appointmentSlotsInstance,
                        String.valueOf(photoShootDateTimeInGMT.date())
                    );
                    mxOrdersPayloadsInstance.setPhotoshootRequestedTime(
                        appointmentSlotsInstance,
                        String.valueOf(photoShootDateTimeInGMT.time())
                    );
                }
            } else {
                mxOrdersPayloadsInstance.setPhotoshootRequestedDate(
                    appointmentSlotsInstance,
                    String.valueOf(eachMxOrder?.Work_Order__r?.Photoshoot_Date__c)
                );
                mxOrdersPayloadsInstance.setPhotoshootRequestedTime(
                    appointmentSlotsInstance,
                    String.valueOf(eachMxOrder?.Work_Order__r?.Photoshoot_Time__c)
                );
            }
            mxOrdersPayloadsInstance.setPhotoshootDuration(
                appointmentSlotsInstance,
                String.valueOf(eachMxOrder?.Product_Bundle__r?.Name)
            );
            mxOrdersPayloadsInstance.setPhotoshootItems(
                appointmentSlotsInstance,
                newPhotoshootAppointmentDetails
            );
            appointmentSlotsInstance = new MerchantOrdersPayloads.AppointmentSlots();
            mxOrdersPayloadsInstance.setPhotoshootItems(
                newPhotoshootAppointmentDetails,
                newPhotoshootOutboundWrapper
            );
            newPhotoshootAppointmentDetails = new MerchantOrdersPayloads.PhotoshootAppointmentDetails();
            photoshootStoreAddress = eachMxOrder?.Merchant_Address__c;
            mxOrdersPayloadsInstance.setContactFirstName(
                addressDetailsInstance,
                eachMxOrder?.Contact__r?.FirstName
            );
            mxOrdersPayloadsInstance.setContactLastName(
                addressDetailsInstance,
                eachMxOrder?.Contact__r?.LastName
            );
            mxOrdersPayloadsInstance.setPhoneNumber(
                addressDetailsInstance,
                getContactPhoneNumberByMxOrder(eachMxOrder)
            );
            mxOrdersPayloadsInstance.setEmail(
                addressDetailsInstance,
                eachMxOrder?.Contact__r?.Email
            );
            if (photoshootStoreAddress != null) {
                mxOrdersPayloadsInstance.setAddress1(
                    addressDetailsInstance,
                    String.valueOf(photoshootStoreAddress.Street)
                );
                mxOrdersPayloadsInstance.setAddress2(addressDetailsInstance, String.valueOf(''));
                mxOrdersPayloadsInstance.setAddressNotes(
                    addressDetailsInstance,
                    String.valueOf('')
                );
                mxOrdersPayloadsInstance.setLatitude(
                    addressDetailsInstance,
                    String.valueOf(photoshootStoreAddress.latitude)
                );
                mxOrdersPayloadsInstance.setLongitude(
                    addressDetailsInstance,
                    String.valueOf(photoshootStoreAddress.longitude)
                );
                mxOrdersPayloadsInstance.setCity(
                    addressDetailsInstance,
                    photoshootStoreAddress.City
                );
                mxOrdersPayloadsInstance.setPostalCode(
                    addressDetailsInstance,
                    photoshootStoreAddress.PostalCode
                );
                mxOrdersPayloadsInstance.setState(
                    addressDetailsInstance,
                    photoshootStoreAddress.State
                );
                mxOrdersPayloadsInstance.setCountryCode(
                    addressDetailsInstance,
                    photoshootStoreAddress.CountryCode
                );
                mxOrdersPayloadsInstance.setCountry(
                    addressDetailsInstance,
                    photoshootStoreAddress.Country
                );
            }
            mxOrdersPayloadsInstance.setPhotoshootStoreInfo(
                addressDetailsInstance,
                newPhotoshootOutboundWrapper
            );
            addressDetailsInstance = new MerchantOrdersPayloads.AddressDetails();
            mxOrdersPayloads.put(eachMxOrder.Id, JSON.serialize(newPhotoshootOutboundWrapper));
            mxOrdersUseCase.put(eachMxOrder.Id, PHOTOSHOOT_OUTBOUND_CONFIG_NAME);
            newPhotoshootOutboundWrapper = new MerchantOrdersPayloads.PhotoshootMxOrdersOutboundWrapper();
        }
    }

    /**
     * @description It creates Interface Transaction records based on generated payloads
     * @JIRA# LEM-13506
     * @param mxOrdersPayloadsInstance
     * @param addressDetailsWrapper
     * @param mxOrder
     */
    private void updateAddressDetailsOnPayload(
        MerchantOrdersPayloads mxOrdersPayloadsInstance,
        MerchantOrdersPayloads.AddressDetails addressDetailsWrapper,
        MX_Order__c mxOrder
    ) {
        String addressType = mxOrder.Type_Of_Request__c == MX_ORDER_TYPE_OF_REQUEST_RETURN
            ? ADDRESS_TYPE_SHIP_FROM
            : ADDRESS_TYPE_SHIP_TO;
        Address mxOrderShippingAddress = mxOrder?.Merchant_Address__c;
        mxOrdersPayloadsInstance.setName(addressDetailsWrapper, mxOrder?.Account__r?.Name);
        mxOrdersPayloadsInstance.setAddressType(addressDetailsWrapper, addressType);
        mxOrdersPayloadsInstance.setContactFirstName(
            addressDetailsWrapper,
            mxOrder?.Contact__r?.FirstName
        );
        mxOrdersPayloadsInstance.setContactLastName(
            addressDetailsWrapper,
            mxOrder?.Contact__r?.LastName
        );
        mxOrdersPayloadsInstance.setPhoneNumber(
            addressDetailsWrapper,
            getContactPhoneNumberByMxOrder(mxOrder)
        );
        mxOrdersPayloadsInstance.setEmail(addressDetailsWrapper, mxOrder?.Contact__r?.Email);
        if (mxOrderShippingAddress != null) {
            mxOrdersPayloadsInstance.setAddress1(
                addressDetailsWrapper,
                String.valueOf(mxOrderShippingAddress.Street)
            );
            mxOrdersPayloadsInstance.setAddress2(addressDetailsWrapper, String.valueOf(''));
            mxOrdersPayloadsInstance.setCity(addressDetailsWrapper, mxOrderShippingAddress.City);
            mxOrdersPayloadsInstance.setPostalCode(
                addressDetailsWrapper,
                mxOrderShippingAddress.PostalCode
            );
            mxOrdersPayloadsInstance.setState(addressDetailsWrapper, mxOrderShippingAddress.State);
            mxOrdersPayloadsInstance.setCountryCode(
                addressDetailsWrapper,
                mxOrderShippingAddress.CountryCode
            );
            mxOrdersPayloadsInstance.setCountry(
                addressDetailsWrapper,
                mxOrderShippingAddress.Country
            );
        }
    }

    /**
     * @description It creates Interface Transaction records based on generated payloads
     * @JIRA# LEM-13506
     * @param mxOrdersPayloadsInstance
     * @param mxOrdersOutboundWrapper
     * @param mxOrder
     * @param xref
     */
    private void updateOrderInformationOnPayload(
        MerchantOrdersPayloads mxOrdersPayloadsInstance,
        MerchantOrdersPayloads.MxOrdersOutboundWrapper mxOrdersOutboundWrapper,
        MX_Order__c mxOrder,
        Xref__c xref
    ) {
        String orderType = MX_ORDER_TYPE_TO_PAYLOAD_TYPE.containsKey(mxOrder?.Type_Of_Request__c)
            ? MX_ORDER_TYPE_TO_PAYLOAD_TYPE.get(mxOrder?.Type_Of_Request__c)
            : mxOrder?.Type_Of_Request__c;
        mxOrdersPayloadsInstance.setMxOrderNumber(mxOrdersOutboundWrapper, mxOrder?.Name);
        mxOrdersPayloadsInstance.setStoreId(mxOrdersOutboundWrapper, xref?.External_ID__c);
        mxOrdersPayloadsInstance.setOrderSFID(mxOrdersOutboundWrapper, mxOrder?.Id);
        mxOrdersPayloadsInstance.setAccountSFID(mxOrdersOutboundWrapper, mxOrder?.Account__c);
        mxOrdersPayloadsInstance.setFigmentAccountSFID(
            mxOrdersOutboundWrapper,
            xref?.Figment_ID__c
        );
        mxOrdersPayloadsInstance.setOrderType(mxOrdersOutboundWrapper, orderType);
        mxOrdersPayloadsInstance.setVendorName(mxOrdersOutboundWrapper, mxOrder?.Vendor__c);
        mxOrdersPayloadsInstance.setReturnReason(
            mxOrdersOutboundWrapper,
            mxOrder?.Reason_for_Replacement__c
        );
        mxOrdersPayloadsInstance.setReturnReasonOther(
            mxOrdersOutboundWrapper,
            mxOrder?.Replacement_Reason_Other__c
        );
        mxOrdersPayloadsInstance.setNotes(
            mxOrdersOutboundWrapper,
            mxOrder?.Replacement_Reason_Other__c
        );
        mxOrdersPayloadsInstance.setDeckRank(
            mxOrdersOutboundWrapper,
            mxOrder?.Account__r?.Deck_Rank__c
        );
        mxOrdersPayloadsInstance.setBundleName(
            mxOrdersOutboundWrapper,
            mxOrder?.Product_Bundle__r?.Name
        );
        if (
            (mxOrder.Type_Of_Request__c == MX_ORDER_TYPE_OF_REQUEST_RETURN ||
            mxOrder.Type_Of_Request__c == REQUEST_TYPE_REPLACEMENT) &&
            mxOrder.Vendor__c != MX_ORDER_VENDOR_DENALI
        ) {
            mxOrdersPayloadsInstance.setVendorOrderId(
                mxOrdersOutboundWrapper,
                identifierToVendorId.get(mxOrderIdToIdentifier.get(mxOrder.Id))
            );
        }
    }

    /**
     * @description It creates Interface Transaction records based on generated payloads
     * @JIRA# LEM-13506
     * @param mxOrdersPayloadsInstance
     * @param mxOrderItemsWrapper
     * @param mxOrderItem
     */
    private void updateOrderItemDetailsOnPayload(
        MerchantOrdersPayloads mxOrdersPayloadsInstance,
        MerchantOrdersPayloads.MxOrderItemsWrapper mxOrderItemsWrapper,
        MX_Order_Item__c mxOrderItem
    ) {
        mxOrdersPayloadsInstance.setProductId(
            mxOrderItemsWrapper,
            mxOrderItem?.Product__r?.StockKeepingUnit
        );
        mxOrdersPayloadsInstance.setOrderItemSFID(mxOrderItemsWrapper, mxOrderItem?.Id);
        mxOrdersPayloadsInstance.setQuantity(
            mxOrderItemsWrapper,
            String.valueOf(mxOrderItem?.Quantity__c)
        );
        mxOrdersPayloadsInstance.setSKU(
            mxOrderItemsWrapper,
            String.valueOf(mxOrderItem?.Product__r?.StockKeepingUnit)
        );
        mxOrdersPayloadsInstance.setProductFamily(
            mxOrderItemsWrapper,
            mxOrderItem?.Product__r?.Family
        );
        mxOrdersPayloadsInstance.setProductName(mxOrderItemsWrapper, mxOrderItem?.Product__r?.Name);
        mxOrdersPayloadsInstance.setIdentifiers(mxOrderItemsWrapper, mxOrderItem?.Identifier__c);
    }

    /**
     * @description It creates Interface Transaction records based on generated payloads
     * @JIRA# LEM-13506
     * @param mxOrdersPayloadsInstance
     * @param productLoginDetailsWrapper
     * @param mxOrderItem
     */
    private void updateProductLoginDetailsOnPayload(
        MerchantOrdersPayloads mxOrdersPayloadsInstance,
        MerchantOrdersPayloads.ProductLoginDetails productLoginDetailsWrapper,
        MX_Order_Item__c mxOrderItem
    ) {
        mxOrdersPayloadsInstance.setUsername(productLoginDetailsWrapper, mxOrderItem?.Username__c);
        mxOrdersPayloadsInstance.setPassword(productLoginDetailsWrapper, mxOrderItem?.Password__c);
        mxOrdersPayloadsInstance.setLanguage(productLoginDetailsWrapper, mxOrderItem?.Language__c);
    }

    /**
     * @description It creates Interface Transaction records based on generated payloads
     * @JIRA# LEM-13506
     * @param mxOrdersPayloadsInstance
     * @param shipmentDetailsWrapper
     * @param mxOrder
     */
    private void updateShipmentDetailsOnPayload(
        MerchantOrdersPayloads mxOrdersPayloadsInstance,
        MerchantOrdersPayloads.ShipmentDetails shipmentDetailsWrapper,
        MX_Order__c mxOrder
    ) {
        mxOrdersPayloadsInstance.setTrackingNumber(
            shipmentDetailsWrapper,
            mxOrder?.Tracking_Number__c
        );
        mxOrdersPayloadsInstance.setCarrier(shipmentDetailsWrapper, mxOrder?.Shipping_Carrier__c);
        mxOrdersPayloadsInstance.setCarrierService(shipmentDetailsWrapper, null);
        mxOrdersPayloadsInstance.setPreferredMethod(
            shipmentDetailsWrapper,
            mxOrder?.Shipping_Type__c
        );
    }

    /**
     * @description It gets the Contact's Phone Number from MobilePhone, Phone field values.
     * @JIRA# LEM-21058
     * @param mxOrder
     * @return String
     */
    private String getContactPhoneNumberByMxOrder(MX_Order__c mxOrder) {
        return (mxOrder?.Contact__r?.MobilePhone == null ||
            String.isBlank(mxOrder?.Contact__r?.MobilePhone))
            ? mxOrder?.Contact__r?.Phone
            : mxOrder?.Contact__r?.MobilePhone;
    }

    /**
     * @description It is used to perform commit operations.
     * @param uow
     */
    private void commitRecords(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception commitException) {
            Logger.publish(LogEntry.newExceptionLog(commitException, LogEntry.SeverityLevel.HIGH));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_MERCHANT_ORDERS,
                        LOG_DOMAIN_TABLET_INTEGRATION,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(commitException)
            );
        }
    }
}