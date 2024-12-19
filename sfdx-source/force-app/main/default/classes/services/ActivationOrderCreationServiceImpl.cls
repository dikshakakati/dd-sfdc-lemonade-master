/**
 * @author atg
 * @date   08/09/2022
 * @description This is the service implementation class for Activation Orders Creation related logic.
 *              Activation Orders and Activation OrderItems are used integrating at the store level.
 *              We don't need opportunities and quotes for the children store accounts, only the Parent Business Accounts.
 *              Multiple Jira tickets have been added to the logic here, this class was created to reduce CyclomaticComplexity.
 *              This is definitely not a helper class
 */
@SuppressWarnings(
    'PMD.CyclomaticComplexity,PMD.ExcessiveParameterList,PMD.NcssMethodCount,PMD.ExcessiveClassLength,PMD.StdCyclomaticComplexity'
)
public inherited sharing class ActivationOrderCreationServiceImpl implements IActivationOrderCreationService {
    @testVisible
    private static final String ORDERITEM_BUNDLEROOT_PRODUCTCODE_MARKETPLACEDELIVERY = '10017';
    @testVisible
    private static final String ORDERITEM_PRODUCTCODE_MARKETPLACEDELIVERY =
        ORDERITEM_BUNDLEROOT_PRODUCTCODE_MARKETPLACEDELIVERY + '-10033';

    public static final String ACTIVE = 'Active';
    public static final String STATUS_DRAFT = 'Draft';
    public static final String STATUS_ACTIVATED = 'Activated';
    public static final String ORDER_TYPE_A_P = 'A&P';
    public static final String CONTRACTING_METHOD = 'By Subscription End Date';
    public static final String ACTIVATION_ORDER_TYPE = 'Activation_Order';
    public static final Schema.Fieldset ORDER_ITEM_FIELD_SET = SObjectType.OrderItem.FieldSets.Activation_Order_Item_List;
    public static final String MX_AGREED_YES = 'Yes';
    public static final String MX_AGREED_NO = 'No';
    public static final String PRODUCT_NAME_DELIVERY = 'Delivery';
    public static final String PRODUCT_NAME_PICKUP = 'Pickup';
    public static final String PRODUCT_NAME_ALCOHOL_DELIVERY = 'Alcohol Delivery';
    public static final String PRODUCT_NAME_ALCOHOL_PICKUP = 'Alcohol Pickup';
    public static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    public static final String BILLING_STATE_CODE_CA = 'CA';
    public static final String PRODCODE_SERVICE_RATE = System.Label.ServiceRateProductCode;
    public static final String PRODCODE_SERVICE_RATE_CA = System.Label.ServiceRateCAProductCode;
    public static final String SERVICE_RATE_CA = 'Service Rate - CA';
    public static final String SERVICE_RATE = 'Service Rate';
    private static final String AGREED_TO_SERVICES_ALL = 'All';
    private static final String AGREED_TO_SERVICES_DRIVE = 'Drive';
    private static final String AGREED_TO_SERVICES_MARKETPLACE = 'Marketplace';
    private static final String STOREFRONT_PACKAGE = 'Storefront';
    private static final String STORE_RECORD_TYPE = 'Store';
    private static final String SOURCE_RESSMO = 'RESSMO';
    private static final String INTEGRATION_SOURCE_MX_PORTAL = 'MX Portal';

    private static final Set<String> NINTEX_USE_CASES_TO_ALLOW_DRIVE_SERVICES_CREATION_ON_STORE_ACCOUNTS = new Set<String>{
        'Drive Form - Franchise'
    };

    private static final Set<String> MARKETPLACE_PRODUCT_CODES = new Set<String>{
        '10007',
        '10017',
        '10027',
        '10047',
        '10056',
        '10057'
    };

    private static final Set<String> DRIVE_PRODUCT_CODES = new Set<String>{ '10012', '10044' };
    private static Map<String, Merchant_Service__c> existingServicesMap = new Map<String, Merchant_Service__c>();
    private static Map<Id, Boolean> amendedAccountIdToAutoProvisionValueMap = new Map<Id, Boolean>();
    private static Map<Id, Map<String, List<String>>> accountIdsToSelectedPckgIdToDeselectedProdListMap = new Map<Id, Map<String, List<String>>>();
    private static Map<Id, Map<Id, Merchant_Service__c>> serviceIdToActivationOrderProductIdsMap = new Map<Id, Map<Id, Merchant_Service__c>>();
    private static Map<Id, Map<Id, Merchant_Service__c>> accountIdToPrimaryOrderProductToServicesMap = new Map<Id, Map<Id, Merchant_Service__c>>();
    private static Boolean arpApplied = false;
    private static final String TRUE_VALUE = 'true';
    private static final String HYPEN = '-';
    private static final String READY_FOR_ACTIVATION = 'Ready For Activation';
    private static Map<Id, Account> storeAccountMap;

    /**
     * @description Default Constructor to initialize class variables.
     */
    public ActivationOrderCreationServiceImpl() {
        existingServicesMap = new Map<String, Merchant_Service__c>();
        amendedAccountIdToAutoProvisionValueMap = new Map<Id, Boolean>();
        accountIdsToSelectedPckgIdToDeselectedProdListMap = new Map<Id, Map<String, List<String>>>();
        serviceIdToActivationOrderProductIdsMap = new Map<Id, Map<Id, Merchant_Service__c>>();
        accountIdToPrimaryOrderProductToServicesMap = new Map<Id, Map<Id, Merchant_Service__c>>();
        arpApplied = false;
        storeAccountMap = new Map<Id, Account>();
    }

    /**
     * @description Create Activation Orders for all Accounts in the Map.
     * @param accountAgreementStringContractIdMap
     * @param accountIdToFranchiseParentIdMap
     * @param accountIdToDeselectedServicesMap
     * @param accountIdToAgreedToServicesMap
     * @param amendedAccountIdToAutoProvisionValueMaps
     * @param accountIdsToSelectedPckgIdToDeselectedProdListMaps
     * @param uow
     * @return Boolean work committed
     */
    public Boolean createActivationOrdersForAccountContractMap(
        Map<String, Id> accountAgreementStringContractIdMap,
        Map<Id, Id> accountIdToFranchiseParentIdMap,
        Map<Id, Map<String, String>> accountIdToDeselectedServicesMap,
        Map<Id, String> accountIdToAgreedToServicesMap,
        Map<Id, Boolean> amendedAccountIdToAutoProvisionValueMaps,
        Map<Id, Map<String, List<String>>> accountIdsToSelectedPckgIdToDeselectedProdListMaps,
        fflib_ISObjectUnitOfWork uow
    ) {
        Boolean workCommitted = false;
        if (amendedAccountIdToAutoProvisionValueMaps != null) {
            amendedAccountIdToAutoProvisionValueMap.putAll(
                amendedAccountIdToAutoProvisionValueMaps
            );
        }
        if (accountIdsToSelectedPckgIdToDeselectedProdListMaps != null) {
            accountIdsToSelectedPckgIdToDeselectedProdListMap.putAll(
                accountIdsToSelectedPckgIdToDeselectedProdListMaps
            );
        }

        List<Schema.FieldSetMember> fieldSetMemberList = ORDER_ITEM_FIELD_SET.getFields();
        String activationOrderRecordTypeID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get(ACTIVATION_ORDER_TYPE)
            .getRecordTypeId();
        Set<Id> accountIdSet = getAccountIdSet(accountAgreementStringContractIdMap);
        getArpIndicator(accountAgreementStringContractIdMap);
        Set<Id> contractIds = new Set<Id>(accountAgreementStringContractIdMap.values());
        Map<Id, Contract> contractMap = new Map<Id, Contract>(
            ContractsSelector.newInstance().selectById(contractIds)
        );

        Map<Id, SBQQ__Subscription__c> activeSubMap = new Map<Id, SBQQ__Subscription__c>(
            SubscriptionSelector.newInstance().selectActiveSubscriptionsList(contractIds, false)
        );
        Map<Id, Id> orderItemIdSubscriptionIdMap = createOrderIdToSubscriptionIdMap(
            activeSubMap.Values()
        );
        Map<Id, Set<Id>> orderIdToOrderItemIdSetMap = createOrderIdToOrderItemSetMap(
            activeSubMap.Values()
        );
        Map<Id, Id> orderItemIdContractIdMap = createOrderIdToContractIdMap(activeSubMap.Values());

        List<OrderItem> orderItemList = OrderItemsSelector.newInstance()
            .selectOrderItemFieldSetById(
                (Schema.FieldSet) ORDER_ITEM_FIELD_SET,
                (Set<Id>) orderItemIdSubscriptionIdMap.keySet()
            );
        Map<Id, Set<Id>> contractIdToOrderItemIdSetMap = createContractIdToOrderItemSetMap(
            orderItemList,
            orderItemIdContractIdMap
        );
        List<Merchant_Service__c> existingServicesList = MerchantSelector.newInstance()
            .queryMerchantRecordsWithAccountIds(accountIdSet);
        existingServicesMap.putAll(createExistingServicesMap(existingServicesList));
        createServiceIdToActivationOrderProductIdsMap(existingServicesList);

        if ((orderItemList == null) || (orderItemList.isEmpty())) {
            return workCommitted;
        }

        Map<Id, Account> accountMap = new Map<Id, Account>(
            AccountsSelector.newInstance().selectById(accountIdSet)
        );
        storeAccountMap = accountMap;

        Map<String, Rate_Card__c> rateCardMap = getRateCards(orderItemList);

        Map<Id, OrderItem> orderItemsToCopyFromMap = new Map<Id, OrderItem>(orderItemList);
        Set<Id> originalOrderIdSet = new Set<Id>();
        Map<String, Map<Id, OrderItem>> accountToOldOrderItemIdNewObjectMap = new Map<String, Map<Id, OrderItem>>();
        Map<String, List<OrderItem>> accountToNewOrderItemsListMap = new Map<String, List<OrderItem>>();
        for (String agreementAccountString : accountAgreementStringContractIdMap.keyset()) {
            String accountIdString = agreementAccountString.substring(
                0,
                agreementAccountString.indexOf(HYPEN)
            );

            Id contractId = accountAgreementStringContractIdMap.get(agreementAccountString);
            Contract contract = contractMap.get(contractId);
            if ((contract == null) || (String.IsBlank(accountIdString))) {
                continue;
            }

            //logic to create AO is moved to a  new method
            Order newActivationOrder = createActivationOrder(
                accountIdString,
                contract,
                activationOrderRecordTypeID
            );
            newActivationOrder.Type = contract.SBQQ__Order__r.Type;

            originalOrderIdSet.add(contract.SBQQ__Order__c);

            uow.registerNew(newActivationOrder);

            Set<Id> orderItemsToCopySet = getOrderItemsToCopy(
                contractIdToOrderItemIdSetMap,
                orderIdToOrderItemIdSetMap,
                contract,
                amendedAccountIdToAutoProvisionValueMaps.containsKey(Id.valueOf(accountIdString))
            );

            Map<Id, OrderItem> oldOrderIdToNewObjectMap = new Map<Id, OrderItem>();
            List<OrderItem> newOrderItemsList = new List<OrderItem>();

            Decimal quantitySum = 0;
            Decimal finalCommission = null;
            for (Id oldOrderItemId : orderItemsToCopySet) {
                if (!orderItemsToCopyFromMap.containsKey(oldOrderItemId)) {
                    continue;
                }
                OrderItem existingOrderItem = orderItemsToCopyFromMap.get(oldOrderItemId);
                //Create New OrderItem
                OrderItem orderItemToAdd = createOrderItem(
                    oldOrderItemId,
                    existingOrderItem,
                    fieldSetMemberList,
                    newActivationOrder.EffectiveDate,
                    Id.valueOf(accountIdString)
                );

                if (existingOrderItem.Quantity != null) {
                    quantitySum += existingOrderItem.Quantity;
                    finalCommission = getFinalCommission(existingOrderItem, finalCommission); // LEM-1851
                }

                uow.registerNew(orderItemToAdd, OrderItem.OrderId, newActivationOrder);
                oldOrderIdToNewObjectMap.put(oldOrderItemId, orderItemToAdd);
                newOrderItemsList.add(orderItemToAdd);

                Id subscriptionId = getSubscriptionId(orderItemIdSubscriptionIdMap, oldOrderItemId);

                //Before creating merchant service, check for billing state CA and service rate product
                //if it satisfies the condition, then skip this iteration.

                if (
                    !accountMap.isEmpty() &&
                    accountMap.containsKey(Id.valueOf(accountIdString)) &&
                    accountMap.get(Id.valueOf(accountIdString)).Segment__c == ACCOUNT_SEGMENT_SMB &&
                    ((accountMap.get(Id.valueOf(accountIdString)).BillingStateCode ==
                    BILLING_STATE_CODE_CA &&
                    existingOrderItem.Product2.Name == SERVICE_RATE) ||
                    (accountMap.get(Id.valueOf(accountIdString)).BillingStateCode !=
                    BILLING_STATE_CODE_CA &&
                    existingOrderItem.Product2.Name == SERVICE_RATE_CA))
                ) {
                    continue;
                }
                if (
                    isDriveServiceCreationRestrictedOnStoreAccounts(
                        accountMap,
                        existingOrderItem,
                        accountIdString
                    )
                ) {
                    continue;
                }

                Merchant_Service__c mxService = createOrUpdateMerchantService(
                    Id.valueOf(accountIdString),
                    subscriptionId,
                    existingOrderItem,
                    contract.CurrencyIsoCode
                );
                mxService.Mx_Agreed_to_Product__c = getAgreedToProduct(
                    Id.valueOf(accountIdString),
                    accountIdToFranchiseParentIdMap,
                    accountIdToDeselectedServicesMap,
                    accountIdToAgreedToServicesMap,
                    existingOrderItem,
                    mxService,
                    activeSubMap.get(subscriptionId)
                );
                mxService.Rate_Card__c = getRateCard(
                    Id.valueOf(accountIdString),
                    existingOrderItem,
                    accountMap,
                    rateCardMap,
                    mxService
                );

                upsertMerchantService(mxService, orderItemToAdd, subscriptionId, uow);
            }

            setFinalCommission(newActivationOrder, finalCommission, quantitySum); // LEM-1581

            accountToOldOrderItemIdNewObjectMap.put(accountIdString, oldOrderIdToNewObjectMap);
            accountToNewOrderItemsListMap.put(accountIdString, newOrderItemsList);
        }

        setOrderItemRelationships(
            accountToNewOrderItemsListMap,
            accountToOldOrderItemIdNewObjectMap
        );
        return workCommitted;
    }
    /**
     * @description Commit method
     * @param workComitted
     * @param uow
     * @return workComitted
     */
    private boolean commitWork(Boolean workComitted, fflib_ISObjectUnitOfWork uow) {
        if (!workComitted) {
            //Turn off CPQ Triggers to avoid SBQQ__Quote__c being set.
            SBQQ.TriggerControl.disable();
            uow.commitWork();
            workComitted = true;
            SBQQ.TriggerControl.enable();
        }
        return workComitted;
    }
    /**
     * @description Inserts or upserts Merchant_Service__c records.
     * @param merchantService (Merchant_Service__c)
     * @param toAssociate (OrderItem)
     * @param subscriptionId
     * @param uow (fflib_ISObjectUnitOfWork)
     * @return Merchant_Service__c
     */
    private static Merchant_Service__c upsertMerchantService(
        Merchant_Service__c merchantService,
        OrderItem toAssociate,
        Id subscriptionId,
        fflib_ISObjectUnitOfWork uow
    ) {
        if (merchantService.Id == null) {
            uow.registerNew(merchantService, Merchant_Service__c.Order_Product__c, toAssociate);
        } else {
            if (!arpApplied) {
                merchantService.Subscription__c = subscriptionId;
                merchantService.Group__c = toAssociate.Quote_Line_Group__c;
                merchantService.Active_Rates_Applied__c = false;
            } else {
                merchantService.Active_Rates_Applied__c = true;
            }
            uow.registerDirty(merchantService, Merchant_Service__c.Order_Product__c, toAssociate);
        }

        return merchantService;
    }

    /**
     * @description LEM-1851 helper function to set Delivery_Commission__c if the
     *  provided final commission is set and quantitySum > 0.
     * @param newActivation (Order)
     * @param finalCommission (Decimal)
     * @param quantitySum (Decimal)
     * @return (Order)
     */
    private static Order setFinalCommission(
        Order newActivation,
        Decimal finalCommission,
        Decimal quantitySum
    ) {
        if (finalCommission != null && quantitySum > 0) {
            newActivation.Delivery_Commission__c = finalCommission;
        }

        return newActivation;
    }

    /**
     * @description LEM-1851 helper function to get Final_Commission__c from the provided OrderItem
     *  record if the order item's quantity is 1 and it is a Marketplace Delivery order item
     *  (and the current final commission hasn't already been set).
     * @param currentOrderItem (OrderItem)
     * @param currentFinalCommission (Decimal)
     * @return Decimal
     */
    private static Decimal getFinalCommission(
        OrderItem currentOrderItem,
        Decimal currentFinalCommission
    ) {
        if (
            currentFinalCommission == null &&
            currentOrderItem.Quantity == 1 &&
            currentOrderItem.Product_Code__c == ORDERITEM_PRODUCTCODE_MARKETPLACEDELIVERY &&
            currentOrderItem.SBQQ__BundleRoot__r.Product_Code__c ==
            ORDERITEM_BUNDLEROOT_PRODUCTCODE_MARKETPLACEDELIVERY
        ) {
            return currentOrderItem.Final_Commission__c;
        }

        return currentFinalCommission;
    }

    /**
     * @description Gets the Order Items for the Contract.
     * @param contractIdToOrderItemIdSetMap
     * @param orderIdToOrderItemIdSetMap
     * @param con
     * @param amendment
     * @return Set<Id>
     */
    private static Set<Id> getOrderItemsToCopy(
        Map<Id, Set<Id>> contractIdToOrderItemIdSetMap,
        Map<Id, Set<Id>> orderIdToOrderItemIdSetMap,
        Contract con,
        Boolean amendment
    ) {
        Set<Id> orderItemsToCopySet = new Set<Id>();
        if (amendment && !arpApplied) {
            if (orderIdToOrderItemIdSetMap.containsKey(con.SBQQ__Order__c)) {
                orderItemsToCopySet = orderIdToOrderItemIdSetMap.get(con.SBQQ__Order__c);
            }
        } else {
            if (contractIdToOrderItemIdSetMap.containsKey(con.Id)) {
                orderItemsToCopySet = contractIdToOrderItemIdSetMap.get(con.Id);
            }
        }
        return orderItemsToCopySet;
    }

    /**
     * @description Creates an Activation Order
     * @param accountIdString
     * @param contract
     * @param activationOrderRecordTypeID
     * @return Order
     */
    @TestVisible
    private static Order createActivationOrder(
        String accountIdString,
        Contract contract,
        String activationOrderRecordTypeID
    ) {
        Order newActivationOrder = new Order(
            Status = STATUS_DRAFT,
            SBQQ__Contracted__c = false,
            SBQQ__ContractingMethod__c = CONTRACTING_METHOD,
            RecordTypeId = activationOrderRecordTypeID,
            AccountId = Id.valueOf(accountIdString),
            BillingCountry = contract.Account.BillingCountry,
            BillingCountryCode = contract.Account.BillingCountryCode,
            CurrencyIsoCode = contract.CurrencyIsoCode,
            EffectiveDate = arpApplied ? System.today() : contract.SBQQ__Order__r.EffectiveDate,
            OwnerId = contract.SBQQ__Order__r.OwnerId,
            SBQQ__PaymentTerm__c = contract.SBQQ__Order__r.SBQQ__PaymentTerm__c,
            Pricebook2Id = contract.SBQQ__Order__r.Pricebook2Id,
            SBQQ__PriceCalcStatus__c = contract.SBQQ__Order__r.SBQQ__PriceCalcStatus__c,
            ShippingCountry = contract.Account.ShippingCountry,
            ShippingCountryCode = contract.Account.ShippingCountryCode,
            Primary_Order__c = contract.SBQQ__Order__c,
            SBQQ__Quote__c = null,
            OpportunityId = contract.SBQQ__Opportunity__c,
            Delivery_Commission__c = null // LEM-1851; default to null
        );
        if (
            storeAccountMap.containsKey(Id.valueOf(accountIdString)) &&
            storeAccountMap.get(Id.valueOf(accountIdString)).Unique_Identifier__c != null
        ) {
            newActivationOrder.Unique_Identifier__c = contract.SBQQ__Order__r.Unique_Identifier__c;
        }
        return newActivationOrder;
    }

    /**
     * @description Creates an order Item.
     * @param oldOrderItemId
     * @param existingOrderItem
     * @param fieldSetMemberList
     * @param orderStartDate
     * @param accountId
     * @return OrderItem
     */
    @TestVisible
    private static OrderItem createOrderItem(
        Id oldOrderItemId,
        OrderItem existingOrderItem,
        List<Schema.FieldSetMember> fieldSetMemberList,
        Date orderStartDate,
        Id accountId
    ) {
        OrderItem orderItemToAdd = new OrderItem();
        orderItemToAdd.SBQQ__Activated__c = false;
        orderItemToAdd.SBQQ__Contracted__c = false;
        orderItemToAdd.Primary_Order_Product__c = oldOrderItemId;
        orderItemToAdd.SBQQ__Contract__c = existingOrderItem.SBQQ__Contract__c;
        orderItemToAdd.Quote_Line_Group__c = existingOrderItem.Quote_Line_Group__c;
        orderItemToAdd.SBQQ__Status__c = (existingOrderItem.Split_Category__c == ORDER_TYPE_A_P ||
            existingOrderItem.Unique_Identifier__c != null)
            ? STATUS_ACTIVATED
            : STATUS_DRAFT;
        orderItemToAdd.Split_Category__c = existingOrderItem.Split_Category__c;
        if (
            storeAccountMap.containsKey(accountId) &&
            storeAccountMap.get(accountId).Unique_Identifier__c == null
        ) {
            orderItemToAdd.SBQQ__Status__c = STATUS_DRAFT;
        }
        for (Schema.FieldSetMember f : fieldSetMemberList) {
            // LEM-1851 can't set formula fields
            if (f.getSObjectField().getDescribe().isCalculated()) {
                continue;
            }

            orderItemToAdd.put(f.getFieldPath(), existingOrderItem.get(f.getFieldPath()));
        }
        if (serviceIdToActivationOrderProductIdsMap.containsKey(accountId)) {
            Merchant_Service__c tempMxService = serviceIdToActivationOrderProductIdsMap.get(
                    accountId
                )
                .get(existingOrderItem.Id);
            orderItemToAdd.Original_Provisioned_Date__c = populateOriginalProvisioningDate(
                tempMxService
            );
            orderItemToAdd.Active_Rate_Change_Start_Date__c = populateArpStartDate(
                tempMxService,
                accountId,
                existingOrderItem
            );
        }

        //ServiceDate must be in the field set.
        if (orderItemToAdd.ServiceDate < orderStartDate) {
            orderItemToAdd.ServiceDate = orderStartDate;
        }
        return orderItemToAdd;
    }

    private static Date populateOriginalProvisioningDate(Merchant_Service__c mxService) {
        if (mxService == null) {
            return System.today();
        }
        Date provisioningDate = mxService.Order_Product__r.Original_Provisioned_Date__c == null
            ? mxService.Order_Product__r.ServiceDate
            : mxService.Order_Product__r.Original_Provisioned_Date__c;
        return provisioningDate;
    }

    private static Date populateArpStartDate(
        Merchant_Service__c mxService,
        Id accountId,
        OrderItem existingOrderItem
    ) {
        if (
            (!accountIdToPrimaryOrderProductToServicesMap.isEmpty() &&
            accountIdToPrimaryOrderProductToServicesMap.get(accountId)
                .containsKey(existingOrderItem.Id)) || mxService == null
        ) {
            return System.today();
        }
        return mxService.Order_Product__r.Active_Rate_Change_Start_Date__c;
    }

    /**
     * @description Gets the subscription Id from a map to get around PMD message.
     * @param orderItemIdSubscriptionIdMap
     * @param orderItemId
     * @return Id
     */
    private static Id getSubscriptionId(Map<Id, Id> orderItemIdSubscriptionIdMap, Id orderItemId) {
        return orderItemIdSubscriptionIdMap.containsKey(orderItemId)
            ? orderItemIdSubscriptionIdMap.get(orderItemId)
            : null;
    }

    /**
     * @description Determies if the Mx_Agreed_to_Product__c field should be Yes or No
     * @param accountId
     * @param accountIdToFranchiseParentIdMap
     * @param accountIdToDeselectedServicesMap
     * @param accountIdToAgreedToServicesMap
     * @param existingOrderItem
     * @param mxService
     * @param sub
     * @return String
     */
    @TestVisible
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static String getAgreedToProduct(
        Id accountId,
        Map<Id, Id> accountIdToFranchiseParentIdMap,
        Map<Id, Map<String, String>> accountIdToDeselectedServicesMap,
        Map<Id, String> accountIdToAgreedToServicesMap,
        OrderItem existingOrderItem,
        Merchant_Service__c mxService,
        SBQQ__Subscription__c sub
    ) {
        if (
            !storeAccountMap.isEmpty() &&
            mxService.Mx_Agreed_to_Product__c != MX_AGREED_YES &&
            storeAccountMap.containsKey(accountId) &&
            sub?.SBQQ__Contract__r?.SBQQ__Order__r.SBQQ__Quote__r.Opportunity_Source__c == INTEGRATION_SOURCE_MX_PORTAL &&
            (sub.Package__c == STOREFRONT_PACKAGE ||
            sub.SBQQ__ProductName__c == STOREFRONT_PACKAGE)) {
                if (storeAccountMap.get(accountId).Unique_Identifier__c ==  sub?.SBQQ__Contract__r?.SBQQ__Order__r.Unique_Identifier__c) {
                    return MX_AGREED_YES;
                }
                else {
                    return MX_AGREED_NO;
                }
            }
        //Added as part of LEM-18127 to create the services in "Yes" for SMB for Nintex forms use cases.
        if (
            !storeAccountMap.isEmpty() &&
            storeAccountMap.containsKey(accountId) &&
            storeAccountMap.get(accountId).Most_Recent_Nintex_Use_Case__c != null &&
            storeAccountMap.get(accountId).Segment__c == ACCOUNT_SEGMENT_SMB
        ) {
            return MX_AGREED_YES;
        }
        if (arpApplied) {
            return mxService.Mx_Agreed_To_Product__c;
        }

        //Set default based off of existing value if already in the DB or off of AgreedToServices.
        String returnString = getStatusBasedOffOfAgreedTo(
            accountId,
            accountIdToAgreedToServicesMap,
            existingOrderItem
        );

        // Check if it's an amendment scenario
        if (amendedAccountIdToAutoProvisionValueMap.containsKey(accountId)) {
            returnString = getStatusInAmendmentScenarios(
                mxService,
                accountId,
                existingOrderItem,
                returnString
            );
        } else {
            // Check if it's a new store flow
            returnString = getStatusForNewStoreFlow(mxService, accountId, sub, returnString);
        }

        // Check if it's a franchise parent and set the returnString accordingly
        if (
            accountIdToFranchiseParentIdMap.containsKey(accountId) &&
            accountIdToFranchiseParentIdMap.get(accountId) != null
        ) {
            return MX_AGREED_NO;
        }
        // Check if any service is deselected and set the returnString accordingly
        //@JIRA# LEM-13995
        if (accountIdToDeselectedServicesMap.containsKey(accountId)) {
            Map<String, String> deselectedServicesMap = new Map<String, String>();
            deselectedServicesMap = accountIdToDeselectedServicesMap.get(accountId);
            Boolean packageEligible = existingOrderItem.SBQQ__BundleRoot__c == null
                ? existingOrderItem.Product2.Package_Eligible_For_Nintex_Options__c
                : existingOrderItem.SBQQ__BundleRoot__r.Product2.Package_Eligible_For_Nintex_Options__c;
            if (deselectedServicesMap.isEmpty() || !packageEligible) {
                return returnString;
            }

            // Call the private method for checking deselected services
            returnString = checkDeselectedServices(
                returnString,
                existingOrderItem,
                deselectedServicesMap
            );
        }
        return returnString;
    }

    /**
     * @description check the deselected products and selected packages gets selected.
     * @JIRA# LEM-13995
     * @param returnString
     * @param existingOrderItem
     * @param deselectedServicesMap
     * @return String
     */
    private static String checkDeselectedServices(
        String returnString,
        OrderItem existingOrderItem,
        Map<String, String> deselectedServicesMap
    ) {
        String packageName = existingOrderItem.SBQQ__BundleRoot__c == null
            ? existingOrderItem.Product2.Name
            : existingOrderItem.SBQQ__BundleRoot__r.Product2.Name;
        String shortenedProduct2Name = getShortenedProductName(existingOrderItem.Product2.Name);
        if (deselectedServicesMap.containsKey(packageName)) {
            String deselectedServices = deselectedServicesMap.get(packageName);
            if (
                deselectedServices != null &&
                deselectedServices.containsIgnoreCase(shortenedProduct2Name)
            ) {
                return MX_AGREED_NO;
            }
        } else {
            return MX_AGREED_NO;
        }
        return returnString;
    }

    /**
     * @description Gets the account Ids from the map
     * @param accountId
     * @param accountIdToAgreedToServicesMap
     * @param existingOrderItem
     * @return String
     */
    private static String getStatusBasedOffOfAgreedTo(
        Id accountId,
        Map<Id, String> accountIdToAgreedToServicesMap,
        OrderItem existingOrderItem
    ) {
        String returnString = MX_AGREED_NO;
        String agreedToProducts = accountIdToAgreedToServicesMap.containsKey(accountId)
            ? accountIdToAgreedToServicesMap.get(accountId)
            : null;
        if (agreedToProducts != null) {
            if (agreedToProducts == AGREED_TO_SERVICES_ALL) {
                returnString = MX_AGREED_YES;
            } else {
                returnString = isOrderItemOfType(agreedToProducts, existingOrderItem);
            }
        }
        return returnString;
    }

    /**
     * @description Gets the account Ids from the map
     * @param agreedToProducts
     * @param existingOrderItem
     * @return String
     */
    private static String isOrderItemOfType(String agreedToProducts, OrderItem existingOrderItem) {
        String returnString = MX_AGREED_NO;
        if (agreedToProducts == AGREED_TO_SERVICES_DRIVE) {
            returnString = DRIVE_PRODUCT_CODES.contains(
                    existingOrderItem.Product_Code__c.substring(0, 5)
                )
                ? MX_AGREED_YES
                : MX_AGREED_NO;
        } else if (agreedToProducts == AGREED_TO_SERVICES_MARKETPLACE) {
            returnString = MARKETPLACE_PRODUCT_CODES.contains(
                    existingOrderItem.Product_Code__c.substring(0, 5)
                )
                ? MX_AGREED_YES
                : MX_AGREED_NO;
        }
        return returnString;
    }

    /**
     * @description  See if we need to Update a No to Yes based off of Default, but don't update an existing Yes to No based off of default.
     * @param mxService
     * @param defaultStatus
     * @return String
     */
    private static String getUpdatedStatus(Merchant_Service__c mxService, String defaultStatus) {
        String updatedStatus = defaultStatus;
        if (
            (mxService != null) &&
            (mxService.Id != null) &&
            ((mxService.Mx_Agreed_to_Product__c == MX_AGREED_YES) ||
            (defaultStatus == MX_AGREED_YES))
        ) {
            updatedStatus = MX_AGREED_YES;
        }
        return updatedStatus;
    }

    /**
     * @description returns status for amended store flow
     * @param mxService
     * @param accountId
     * @param existingOrderItem
     * @param returnString
     * @return String
     */
    private static String getStatusInAmendmentScenarios(
        Merchant_Service__c mxService,
        Id accountId,
        OrderItem existingOrderItem,
        String returnString
    ) {
        String statusInAmendmentFlow;
        Boolean autoProvision = amendedAccountIdToAutoProvisionValueMap.get(accountId);

        if (
            existingOrderItem.OrderItem_Type__c != 'New' &&
            existingOrderItem.OrderItem_Type__c != 'New Package'
        ) {
            statusInAmendmentFlow = mxService.Mx_Agreed_to_Product__c;
        } else if (autoProvision == false) {
            statusInAmendmentFlow = MX_AGREED_NO;
        } else if (autoProvision == true && existingOrderItem.OrderItem_Type__c == 'New Package') {
            statusInAmendmentFlow = MX_AGREED_YES;
        } else {
            //if SBQQ__RequiredBy__c and SBQQ__BundleRoot__c is same that means 1st level product OR if SBQQ__RequiredBy__c
            //and SBQQ__BundleRoot__c is diff that means sub prod (2nd level) AND SBQQ__RequiredBy__c is new that means its
            //immediate parent will also have same status as of bundle hence, return SBQQ__BundleRoot__c service status
            if (
                (existingOrderItem.SBQQ__RequiredBy__c == existingOrderItem.SBQQ__BundleRoot__c) ||
                (existingOrderItem.SBQQ__RequiredBy__c != existingOrderItem.SBQQ__BundleRoot__c &&
                existingOrderItem.SBQQ__RequiredBy__r.OrderItem_Type__c == 'New')
            ) {
                statusInAmendmentFlow = getRootOrParentServiceStatus(
                    existingOrderItem.SBQQ__BundleRoot__r.Product_Code__c,
                    accountId,
                    returnString
                );
            } else {
                statusInAmendmentFlow = getRootOrParentServiceStatus(
                    existingOrderItem.SBQQ__RequiredBy__r.Product_Code__c,
                    accountId,
                    returnString
                );
            }
        }
        return statusInAmendmentFlow;
    }

    /**
     * @description It checks if the passed Root or Parent Order Item and product code is not null then it finds the service
     * @description for it and returns its Mx_Agreed_to_Product__c
     * @param rootOrParentProdCode
     * @param accountId
     * @param returnString
     * @return String
     */
    private static String getRootOrParentServiceStatus(
        String rootOrParentProdCode,
        Id accountId,
        String returnString
    ) {
        if (accountId != null && String.isNotBlank(rootOrParentProdCode)) {
            String key = Id.valueOf(accountId) + HYPEN + rootOrParentProdCode;
            if (existingServicesMap.containsKey(key)) {
                returnString = existingServicesMap.get(key).Mx_Agreed_to_Product__c;
            }
        }
        return returnString;
    }

    /**
     * @description returns status for new store flow
     * @param mxService
     * @param accountId
     * @param sub
     * @param returnString
     * @return String
     */
    private static String getStatusForNewStoreFlow(
        Merchant_Service__c mxService,
        Id accountId,
        SBQQ__Subscription__c sub,
        String returnString
    ) {
        if (
            accountIdsToSelectedPckgIdToDeselectedProdListMap == null ||
            !accountIdsToSelectedPckgIdToDeselectedProdListMap.containsKey(accountId)
        ) {
			//See if we need to Update a No to Yes based off of Default, but don't update an existing Yes to No based off of default.
            return getUpdatedStatus(mxService, returnString);
        }
        Map<String, List<String>> selectedPckgToDeselectedProdMap = accountIdsToSelectedPckgIdToDeselectedProdListMap.get(
            accountId
        );
        //if the inner map is null then it is an anso flow or integrated franchise, we don't need to activate services based on json
        if (selectedPckgToDeselectedProdMap == null || selectedPckgToDeselectedProdMap.isEmpty()) {
            //See if we need to Update a No to Yes based off of Default, but don't update an existing Yes to No based off of default.
            return getUpdatedStatus(mxService, returnString);
        }

		String statusInNewFlow;
        //check package level
        if (
            returnString != 'No' &&
            sub.SBQQ__RequiredById__c == null &&
            selectedPckgToDeselectedProdMap.containsKey(sub.Id)
        ) {
            statusInNewFlow = MX_AGREED_YES;
        }
        //check products and sub products
        else if (
            returnString != 'No' &&
            selectedPckgToDeselectedProdMap.containsKey(sub.SBQQ__RootId__c) &&
            !selectedPckgToDeselectedProdMap.get(sub.SBQQ__RootId__c).contains(sub.Id) &&
            !selectedPckgToDeselectedProdMap.get(sub.SBQQ__RootId__c)
                .contains(sub.SBQQ__RequiredById__c)
        ) {
            statusInNewFlow = MX_AGREED_YES;
        } else {
            statusInNewFlow = MX_AGREED_NO;
        }
        return statusInNewFlow;
    }

    /**
     * @description Gets the account Ids from the map
     * @param productName
     * @return String
     */
    private static String getShortenedProductName(String productName) {
        String shortenedProduct2Name = productName;
        if (shortenedProduct2Name == PRODUCT_NAME_ALCOHOL_DELIVERY) {
            shortenedProduct2Name = PRODUCT_NAME_DELIVERY;
        }
        if (shortenedProduct2Name == PRODUCT_NAME_ALCOHOL_PICKUP) {
            shortenedProduct2Name = PRODUCT_NAME_PICKUP;
        }
        return shortenedProduct2Name;
    }

    /**
     * @description Gets the account Ids from the map
     * @param accountAgreementStringContractIdMap
     * @return Set<Id>
     */
    private static Set<Id> getAccountIdSet(Map<String, Id> accountAgreementStringContractIdMap) {
        Set<Id> accountIdSet = new Set<Id>();
        for (String agreementAccountString : accountAgreementStringContractIdMap.keyset()) {
            String accountIdString = agreementAccountString.substring(
                0,
                agreementAccountString.indexOf(HYPEN)
            );
            accountIdSet.add(Id.valueOf(accountIdString));
        }
        return accountIdSet;
    }

    /**
     * @description It is used to validate whether the services related to drive products are applicable
     * for creation on SMB store accounts.
     * @param accountMap
     * @param existingOrderItem
     * @param accountIdString
     * @return Boolean
     */
    private Boolean isDriveServiceCreationRestrictedOnStoreAccounts(
        Map<Id, Account> accountMap,
        OrderItem existingOrderItem,
        String accountIdString
    ) {
        Id accountId = Id.valueOf(accountIdString);
        return (!accountMap.isEmpty() &&
        accountMap.containsKey(accountId) &&
        accountMap.get(accountId).Segment__c == ACCOUNT_SEGMENT_SMB &&
        accountMap.get(accountId).Record_Type_Name__c == STORE_RECORD_TYPE &&
        !NINTEX_USE_CASES_TO_ALLOW_DRIVE_SERVICES_CREATION_ON_STORE_ACCOUNTS.contains(
            accountMap.get(accountId).Most_Recent_Nintex_Use_Case__c
        ) &&
        (DRIVE_PRODUCT_CODES.contains(existingOrderItem.Product_Code__c) ||
        DRIVE_PRODUCT_CODES.contains(existingOrderItem.SBQQ__QuoteLine__r.Package_Code__c)));
    }

    /**
     * @description The original OrderItems had Bundle and RequiredBy lookups set to other Order Items.
     *              Since we just copied the OrderItems, make sure these lookups are set to the new OrderItems that were just created.
     * @param accountToNewOrderItemsListMap
     * @param accountToOldOrderItemIdNewObjectMap
     */
    @TestVisible
    private static void setOrderItemRelationships(
        Map<String, List<OrderItem>> accountToNewOrderItemsListMap,
        Map<String, Map<Id, OrderItem>> accountToOldOrderItemIdNewObjectMap
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        //Set relationships for SBQQ__BundleRoot__c and SBQQ__RequiredBy__c
        for (String accountIdString : accountToNewOrderItemsListMap.keySet()) {
            Map<Id, OrderItem> oldIdToNewObjectMap = accountToOldOrderItemIdNewObjectMap.get(
                accountIdString
            );
            List<OrderItem> newOrderItemsList = accountToNewOrderItemsListMap.get(accountIdString);
            if ((oldIdToNewObjectMap == null) || (newOrderItemsList == null)) {
                continue;
            }
            for (OrderItem newOrderItem : newOrderItemsList) {
                setRequiredByAndBundleRoot(newOrderItem, oldIdToNewObjectMap, uow);
            }
        }

        //Turn off CPQ Triggers to avoid SBQQ__Quote__c being set.
        SBQQ.TriggerControl.disable();
        uow.commitWork();
        SBQQ.TriggerControl.enable();
    }

    /**
     * @description The original OrderItems had Bundle and RequiredBy lookups set to other Order Items.
     *              Since we just copied the OrderItems, make sure these lookups are set to the new OrderItems that were just created.
     * @param newOrderItem
     * @param oldIdToNewObjectMap
     * @param uow
     */
    @TestVisible
    private static void setRequiredByAndBundleRoot(
        OrderItem newOrderItem,
        Map<Id, OrderItem> oldIdToNewObjectMap,
        fflib_ISObjectUnitOfWork uow
    ) {
        //Moved to private function to reduce complexity of calling function.
        Boolean registerDirty = false;
        if (
            (newOrderItem.SBQQ__BundleRoot__c != null) &&
            (oldIdToNewObjectMap.containsKey(newOrderItem.SBQQ__BundleRoot__c)) &&
            (oldIdToNewObjectMap.get(newOrderItem.SBQQ__BundleRoot__c).Id != null)
        ) {
            newOrderItem.SBQQ__BundleRoot__c = oldIdToNewObjectMap.get(
                    newOrderItem.SBQQ__BundleRoot__c
                )
                .Id;
            registerDirty = true;
        }
        if (
            (newOrderItem.SBQQ__RequiredBy__c != null) &&
            (oldIdToNewObjectMap.containsKey(newOrderItem.SBQQ__RequiredBy__c)) &&
            (oldIdToNewObjectMap.get(newOrderItem.SBQQ__RequiredBy__c).Id != null)
        ) {
            newOrderItem.SBQQ__RequiredBy__c = oldIdToNewObjectMap.get(
                    newOrderItem.SBQQ__RequiredBy__c
                )
                .Id;
            registerDirty = true;
        }

        if (registerDirty) {
            uow.registerDirty(newOrderItem);
        }
    }

    /**
     * @description Creates a map of OrderItemId to SubscriptionId
     * @param activeSubscriptionsList
     * @return static Map<Id, Set<Id>>
     */
    private static Map<Id, Id> createOrderIdToSubscriptionIdMap(
        List<SBQQ__Subscription__c> activeSubscriptionsList
    ) {
        Map<Id, Id> orderItemIdSubscriptionIdMap = new Map<Id, Id>();
        for (SBQQ__Subscription__c sub : activeSubscriptionsList) {
            if (
                (sub.SBQQ__OrderProduct__c != null) && (sub.SBQQ__OrderProduct__r.OrderId != null)
            ) {
                orderItemIdSubscriptionIdMap.put(sub.SBQQ__OrderProduct__c, sub.Id);
            }
        }
        return orderItemIdSubscriptionIdMap;
    }

    /**
     * @description Creates a map of OrderItemId to SubscriptionId
     * @param activeSubscriptionsList
     * @return static Map<Id, Set<Id>>
     */
    private static Map<Id, Id> createOrderIdToContractIdMap(
        List<SBQQ__Subscription__c> activeSubscriptionsList
    ) {
        Map<Id, Id> orderItemIdContractIdMap = new Map<Id, Id>();
        for (SBQQ__Subscription__c sub : activeSubscriptionsList) {
            if (sub.SBQQ__Contract__c != null) {
                orderItemIdContractIdMap.put(sub.SBQQ__OrderProduct__c, sub.SBQQ__Contract__c);
            }
        }
        return orderItemIdContractIdMap;
    }
    /**
     * @description Creates a map of Sets of OrderItems keyed by Order
     * @param orderItemList
     * @param orderItemIdContractIdMap
     * @return static Map<Id, Set<Id>>
     */
    private static Map<Id, Set<Id>> createContractIdToOrderItemSetMap(
        List<OrderItem> orderItemList,
        Map<Id, Id> orderItemIdContractIdMap
    ) {
        Map<Id, Set<Id>> contractIdToOrderItemIdSetMap = new Map<Id, Set<Id>>();
        for (OrderItem oi : orderItemList) {
            Id contractId = orderItemIdContractIdMap.containsKey(oi.Id)
                ? orderItemIdContractIdMap.get(oi.Id)
                : null;
            if (contractId == null) {
                continue;
            }

            Set<Id> orderItemIdSet = new Set<Id>();
            if (contractIdToOrderItemIdSetMap.containsKey(contractId)) {
                orderItemIdSet = contractIdToOrderItemIdSetMap.get(contractId);
            }
            orderItemIdSet.add(oi.Id);
            contractIdToOrderItemIdSetMap.put(contractId, orderItemIdSet);
        }
        return contractIdToOrderItemIdSetMap;
    }

    /**
     * @description Creates a map of Sets of OrderItems keyed by Order
     * @param activeSubscriptionsList
     * @return static Map<Id, Set<Id>>
     */
    private static Map<Id, Set<Id>> createOrderIdToOrderItemSetMap(
        List<SBQQ__Subscription__c> activeSubscriptionsList
    ) {
        Map<Id, Set<Id>> orderIdToOrderItemIdSetMap = new Map<Id, Set<Id>>();
        for (SBQQ__Subscription__c sub : activeSubscriptionsList) {
            if (
                (sub.SBQQ__OrderProduct__c != null) && (sub.SBQQ__OrderProduct__r.OrderId != null)
            ) {
                Set<Id> orderItemIdSet = new Set<Id>();
                if (orderIdToOrderItemIdSetMap.containsKey(sub.SBQQ__OrderProduct__r.OrderId)) {
                    orderItemIdSet = orderIdToOrderItemIdSetMap.get(
                        sub.SBQQ__OrderProduct__r.OrderId
                    );
                }
                orderItemIdSet.add(sub.SBQQ__OrderProduct__c);
                orderIdToOrderItemIdSetMap.put(sub.SBQQ__OrderProduct__r.OrderId, orderItemIdSet);
            }
        }
        return orderIdToOrderItemIdSetMap;
    }

    /**
     * @description Creates or returns an existing Service Instance
     * @param accountId
     * @param subscriptionId
     * @param orderItem
     * @param currencyISOCode
     * @return Merchant_Service__c
     */
    @TestVisible
    private static Merchant_Service__c createOrUpdateMerchantService(
        Id accountId,
        Id subscriptionId,
        OrderItem orderItem,
        String currencyISOCode
    ) {
        if ((accountId != null) && String.isNotBlank(orderItem.Product_Code__c)) {
            String key = Id.valueOf(accountId) + HYPEN + orderItem.Product_Code__c;
            if (existingServicesMap.containsKey(key)) {
                return existingServicesMap.get(key);
            }
        }
        Merchant_Service__c mxService = new Merchant_Service__c();
        mxService.Account__c = accountId;
        mxService.Subscription__c = subscriptionId;
        mxService.Name = orderItem.Product2.Name;
        mxService.CurrencyIsoCode = currencyISOCode;
        mxService.Order_Product__c = orderItem.Id;
        mxService.Product__c = orderItem.Product2Id;
        mxService.Product_Code__c = orderItem.Product_Code__c;
        mxService.Status__c = 'Active';
        mxService.Bundle__c = orderItem.SBQQ__BundleRoot__r.Product2.Name;
        mxService.Discount_Schedule__c = orderItem.SBQQ__DiscountSchedule__c;
        mxService.Group__c = orderItem.Quote_Line_Group__c;
        mxService.Active_Rates_Applied__c = false;
        return mxService;
    }

    /**
     * @description Creates a Map of existing Services so don't have to walk the list each time.
     * @param existingServicesList
     * @return Map<String, Merchant_Service__c>
     */
    private static Map<String, Merchant_Service__c> createExistingServicesMap(
        List<Merchant_Service__c> existingServicesList
    ) {
        Map<String, Merchant_Service__c> returnMap = new Map<String, Merchant_Service__c>();
        for (Merchant_Service__c existingService : existingServicesList) {
            if (
                (existingService == null) ||
                (existingService.Account__c == null) ||
                (existingService.Product__c == null)
            ) {
                continue;
            }
            String key =
                Id.valueOf(existingService.Account__c) +
                HYPEN +
                existingService.Product_Code__c;
            returnMap.put(key, existingService);
        }
        return returnMap;
    }

    /**
     * @description Creates A Map of existing Services so don't have to walk the list each time.
     * @param orderItems
     * @return Map<String, Rate_Card__c>
     */
    @TestVisible
    private static Map<String, Rate_Card__c> getRateCards(List<OrderItem> orderItems) {
        Map<String, Rate_Card__c> rateCardMap = new Map<String, Rate_Card__c>();
        Set<Id> quoteLineIdSet = new Set<Id>();
        for (OrderItem orderItemRec : orderItems) {
            quoteLineIdSet.add(orderItemRec.SBQQ__QuoteLine__c);
        }
        List<Rate_Card__c> rateCardList = RateCardsSelector.newInstance()
            .selectByQuoteLineIds(quoteLineIdSet);
        for (Rate_Card__c rateCard : rateCardList) {
            if (String.isBlank(rateCard.State__c)) {
                continue;
            }
            String state = rateCard.State__c.right(2).trim();
            rateCardMap.put(state + rateCard.Quote_Line__c, rateCard);
        }
        return rateCardMap;
    }

    /**
     * @description Creates A Map of existing Services so don't have to walk the list each time.
     * @param accountId
     * @param orderItem
     * @param accountMap
     * @param rateCardMap
     * @param mxService
     * @return Id
     */
    @TestVisible
    private static Id getRateCard(
        Id accountId,
        OrderItem orderItem,
        Map<Id, Account> accountMap,
        Map<String, Rate_Card__c> rateCardMap,
        Merchant_Service__c mxService
    ) {
        if (arpApplied) {
            return mxService.Rate_Card__c;
        }
        String state = accountMap.get(accountId)?.BillingStateCode;
        Rate_Card__c rateCard = rateCardMap.get(state + orderItem.SBQQ__QuoteLine__c);
        return rateCard?.Id;
    }

    /**
     * @description Creates A Map of existing Services so don't have to walk the list each time.
     * @param accountAgreementStringContractIdMap
     */
    private void getArpIndicator(Map<String, Id> accountAgreementStringContractIdMap) {
        for (String agreementAccountString : accountAgreementStringContractIdMap.keyset()) {
            if (agreementAccountString.contains(TRUE_VALUE)) {
                arpApplied = true;
            }
        }
    }

    /**
     * @description Creates map of Primary Order Product Id to Recently Created Activation Order Product.
     * @param existingServicesList
     */
    private void createServiceIdToActivationOrderProductIdsMap(
        List<Merchant_Service__c> existingServicesList
    ) {
        if (existingServicesList.isEmpty()) {
            return;
        }
        for (Merchant_Service__c eachService : existingServicesList) {
            if (serviceIdToActivationOrderProductIdsMap.get(eachService.Account__c) == null) {
                serviceIdToActivationOrderProductIdsMap.put(
                    eachService.Account__c,
                    new Map<Id, Merchant_Service__c>{
                        eachService.Subscription__r.SBQQ__OrderProduct__c => eachService
                    }
                );
            } else if (
                !serviceIdToActivationOrderProductIdsMap.get(eachService.Account__c)
                    .containsKey(eachService.Subscription__r.SBQQ__OrderProduct__c)
            ) {
                serviceIdToActivationOrderProductIdsMap.get(eachService.Account__c)
                    .put(eachService.Subscription__r.SBQQ__OrderProduct__c, eachService);
            }
            if (
                eachService.Subscription__r.Subscription_Rate_Change__c == null ||
                eachService.Subscription__r.SBQQ__ProductOption__c == null
            ) {
                continue;
            }
            createAccountIdToOrderProductIdToServicesMap(eachService);
        }
    }

    /**
     * @description Creates map of AccountId to Primary Order Product Id to Services based on if ARP has been applied
     * for this product, if corresponding Rate Change Request is Ready For Activation and if product is Active Rate Eligible.
     * @param eachService
     */
    private void createAccountIdToOrderProductIdToServicesMap(Merchant_Service__c eachService) {
        if (
            eachService.Subscription__r.Subscription_Rate_Change__r.Rate_Change_Request__r.Activation_Status__c ==
            READY_FOR_ACTIVATION &&
            eachService.Subscription__r.SBQQ__ProductOption__r.Active_Rate_Eligible__c
        ) {
            if (accountIdToPrimaryOrderProductToServicesMap.get(eachService.Account__c) == null) {
                accountIdToPrimaryOrderProductToServicesMap.put(
                    eachService.Account__c,
                    new Map<Id, Merchant_Service__c>{
                        eachService.Subscription__r.SBQQ__OrderProduct__c => eachService
                    }
                );
            } else if (
                !accountIdToPrimaryOrderProductToServicesMap.get(eachService.Account__c)
                    .containsKey(eachService.Subscription__r.SBQQ__OrderProduct__c)
            ) {
                accountIdToPrimaryOrderProductToServicesMap.get(eachService.Account__c)
                    .put(eachService.Subscription__r.SBQQ__OrderProduct__c, eachService);
            }
        }
    }
}