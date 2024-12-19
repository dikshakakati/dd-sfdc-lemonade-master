/**
 * @author Deloitte
 * @date 08/22/2022
 * @description Service implementation class for OrderItem related logic.
 */
public inherited sharing class OrderItemsServiceImpl implements IOrderItemsService {
    private static final String AGGREGATE_CONTRACT_FIELD_ALIAS = 'contractId';
    private static final String AGGREGATE_PARENT_ACCOUNT_FIELD_ALIAS = 'parentAccountId';
    private static final String EVENT_TOPIC_INITIATE_WORK_ORDERS_CREATION = 'INITIATE_CHILD_WORK_ORDERS_CREATION';
    private static final String EVENT_TOPIC_ARP_INITIATE_WORK_ORDERS_CREATION = 'ARP_INITIATE_CHILD_WORK_ORDERS_CREATION';
    private static final String ORDER_ITEM_IDS_CHUNK_SIZE_STATIC_CONFIG = 'OrderItem_Ids_Payload_Chunk_Size';
    private static final String SEPARATOR = System.Label.Separator;
    private static final Set<String> STOREFRONT_BUNDLED_ORDER_PRODUCTS = new Set<String>{
        'Marketplace',
        'Storefront'
    };
    private static final String TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_TYPE_POST_SALES = 'Post-Sales';
    private static final String WORK_ORDER_SUB_TYPE_ADS_AND_PROMOS_ACTIVATE = 'Ads and Promo - Activate';
    private Integer orderItemIdsChunkSize;

    /**
     * @description Default constructor to instantiate variables.
     */
    public OrderItemsServiceImpl() {
        collectStaticConfigurations();
    }

    /**
     * @description It is used to collect store Accounts having Storefront Product sold together
     * with Markteplace Product from the passed Order Products by checking Products attached
     * to Activation Order Product's Order.
     * @JIRA# LEM-2132, LEM-19861
     * @param activatedOrderItems
     * @return  Map<Id, Boolean>
     */
    public Map<Id, Boolean> getStoresWithBundledOrderProducts(List<OrderItem> activatedOrderItems) {
        Map<Id, Boolean> storeAccountIdToHasBundledProducts = new Map<Id, Boolean>();
        storeAccountIdToHasBundledProducts = getStoreAccountIdsToHasBundledProducts(
            collectActivationOrderProducts(activatedOrderItems)
        );
        return storeAccountIdToHasBundledProducts;
    }

    /**
     * @description It gets OrderItem Ids from the payload received via platform event
     * and initiates child Work Orders creation.
     * @JIRA# LEM-3255
     * @param events
     */
    public void handleNotifierEvents(List<Notifier__e> events) {
        Set<Id> recordIdsByPayload;
        Set<Id> orderItemIds = new Set<Id>();
        Boolean isManagePricingProcess = false;
        for (Notifier__e eachEvent : events) {
            if (String.isBlank(eachEvent.Payload__c)) {
                continue;
            }
            recordIdsByPayload = (Set<Id>) JSON.deserialize(eachEvent.Payload__c, Set<Id>.class);
            if (eachEvent.Topic__c == EVENT_TOPIC_INITIATE_WORK_ORDERS_CREATION) {
                orderItemIds.addAll(recordIdsByPayload);
            } else if (eachEvent.Topic__c == EVENT_TOPIC_ARP_INITIATE_WORK_ORDERS_CREATION) {
                orderItemIds.addAll(recordIdsByPayload);
                isManagePricingProcess = true;
            }
        }
        WorkOrdersCreationService.createWorkOrders(orderItemIds, isManagePricingProcess);
    }

    /**
     * @description It sends notifier events for initiating child Work Orders creation from
     * the passed orderItemIds.
     * @JIRA# LEM-3255
     * @param orderItemIds
     * @param isManagePricingProcess
     */
    public void initiateChildWorkOrdersCreation(
        Set<Id> orderItemIds,
        Boolean isManagePricingProcess
    ) {
        if (orderItemIds.isEmpty()) {
            return;
        }
        if (!isManagePricingProcess) {
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_INITIATE_WORK_ORDERS_CREATION => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        orderItemIds,
                        orderItemIdsChunkSize
                    )
                }
            );
        } else {
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_ARP_INITIATE_WORK_ORDERS_CREATION => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        orderItemIds,
                        orderItemIdsChunkSize
                    )
                }
            );
        }
    }

    /**
     * @description It collects Contracts linked to Order Items associated with Primary Order
     * to associate on parent Work Orders.
     * @JIRA# LEM-4005
     * @param orderItemIds
     */
    public static void invokeContractAssociationOnParentWorkOrdersByPrimaryOrders(
        Set<Id> orderItemIds
    ) {
        if (orderItemIds.isEmpty()) {
            return;
        }
        Map<Id, Id> parentAccountIdToContractId = new Map<Id, Id>();
        Id parentAccountId;
        for (
            Aggregate eachAggregate : OrderItemsSelector.newInstance()
                .selectByIdsGroupedByAccountContractIds(orderItemIds)
        ) {
            parentAccountId = (Id) eachAggregate.get(AGGREGATE_PARENT_ACCOUNT_FIELD_ALIAS);
            if (parentAccountIdToContractId.containsKey(parentAccountId)) {
                continue;
            }
            parentAccountIdToContractId.put(
                parentAccountId,
                (Id) eachAggregate.get(AGGREGATE_CONTRACT_FIELD_ALIAS)
            );
        }
        if (parentAccountIdToContractId.isEmpty()) {
            return;
        }
        WorkOrdersService.associateContractsOnParentWorkOrders(parentAccountIdToContractId);
    }

    /**
     * @description It is used to populate parent Work Order on the passed Order Products
     * by matching associated OrderId and Work Order Type & Sub-Type of associated Product.
     * @JIRA# LEM-2445, LEM-3200
     * @param orderItemIdentifierToWorkOrder
     * @param orderItems
     */
    public void populateWorkOrderOnOrderItems(
        Map<String, WorkOrder> orderItemIdentifierToWorkOrder,
        List<OrderItem> orderItems
    ) {
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        Set<Id> orderIds = new Set<Id>();
        for (OrderItem eachOrderItem : orderItems) {
            orderIds.add(eachOrderItem.OrderId);
        }
        for (
            OrderItem eachOrderItem : OrderItemsSelector.newInstance()
                .selectOrderItemsWithProductWorkOrderTypeMappingByOrderIds(orderIds)
        ) {
            // match by Work Order Type & Sub-Type on Product
            eachOrderItem.Work_Order__c = orderItemIdentifierToWorkOrder
                ?.get(
                    eachOrderItem.Order.Id +
                        SEPARATOR +
                        eachOrderItem.Product2.Work_Order_Type__c +
                        SEPARATOR +
                        eachOrderItem.Product2.Work_Order_Sub_Type__c
                )
                ?.Id;
            if (eachOrderItem.Work_Order__c == null) {
                // match by COO and Ads & Promos Work Order Type
                eachOrderItem.Work_Order__c = (eachOrderItem.Product2.Work_Order_Type__c ==
                    WORK_ORDER_TYPE_POST_SALES &&
                    eachOrderItem.Product2.Work_Order_Sub_Type__c ==
                    WORK_ORDER_SUB_TYPE_ADS_AND_PROMOS_ACTIVATE)
                    ? orderItemIdentifierToWorkOrder
                          ?.get(
                              eachOrderItem.Order.Id +
                                  SEPARATOR +
                                  TYPE_ADS_AND_PROMOS +
                                  SEPARATOR +
                                  null
                          )
                          ?.Id
                    : orderItemIdentifierToWorkOrder
                          ?.get(eachOrderItem.Order.Id + SEPARATOR + TYPE_COO + SEPARATOR + null)
                          ?.Id;
            }
            unitOfWorkInstance.registerDirty(eachOrderItem);
        }
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception populateWorkOrderOnOrderItemsException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    populateWorkOrderOnOrderItemsException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
        }
    }

    /**
     * @description It collects all the Activation Order Products by Order Id and store Account Id .
     * @JIRA# LEM-2132
     * @param activatedOrderItems
     * @return Map<Id, Map<Id, Set<String>>>
     */
    private Map<Id, Map<Id, Set<String>>> collectActivationOrderProducts(
        List<OrderItem> activatedOrderItems
    ) {
        Id activationOrderId;
        Map<Id, Set<String>> activationOrderIdToProductTypes = new Map<Id, Set<String>>();
        Id storeAccountId;
        Map<Id, Map<Id, Set<String>>> storeAccountIdToActivationOrderIdToProductTypes = new Map<Id, Map<Id, Set<String>>>();
        for (OrderItem eachActivatedOrderItem : activatedOrderItems) {
            activationOrderId = eachActivatedOrderItem.OrderId;
            storeAccountId = eachActivatedOrderItem.Order.AccountId;
            if (!storeAccountIdToActivationOrderIdToProductTypes.containsKey(storeAccountId)) {
                storeAccountIdToActivationOrderIdToProductTypes.put(
                    storeAccountId,
                    activationOrderIdToProductTypes
                );
            }
            activationOrderIdToProductTypes = storeAccountIdToActivationOrderIdToProductTypes.get(
                storeAccountId
            );
            if (!activationOrderIdToProductTypes.containsKey(activationOrderId)) {
                activationOrderIdToProductTypes.put(activationOrderId, new Set<String>());
            }
            storeAccountIdToActivationOrderIdToProductTypes.get(storeAccountId)
                .get(activationOrderId)
                .add(eachActivatedOrderItem.Product2.Work_Order_Type__c);
        }
        return storeAccountIdToActivationOrderIdToProductTypes;
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.orderItemIdsChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(ORDER_ITEM_IDS_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It collects store Accounts having Storefront Product sold together
     * with Markteplace Product by checking the Activation Order Product's Order.
     * @JIRA# LEM-2132
     * @param storeAccountIdToActivationOrderIdToProductTypes
     * @return  Map<Id, Boolean>
     */
    private Map<Id, Boolean> getStoreAccountIdsToHasBundledProducts(
        Map<Id, Map<Id, Set<String>>> storeAccountIdToActivationOrderIdToProductTypes
    ) {
        Map<Id, Boolean> storeAccountIdToHasBundledProducts = new Map<Id, Boolean>();
        if (storeAccountIdToActivationOrderIdToProductTypes.isEmpty()) {
            return storeAccountIdToHasBundledProducts;
        }
        for (Id eachStoreAccountId : storeAccountIdToActivationOrderIdToProductTypes.keySet()) {
            Map<Id, Set<String>> activationOrderIdToProductTypes = storeAccountIdToActivationOrderIdToProductTypes.get(
                eachStoreAccountId
            );
            for (Id eachActivationOrderId : activationOrderIdToProductTypes?.keySet()) {
                if (
                    activationOrderIdToProductTypes.get(eachActivationOrderId)
                        ?.containsAll(STOREFRONT_BUNDLED_ORDER_PRODUCTS)
                ) {
                    storeAccountIdToHasBundledProducts.put(eachStoreAccountId, true);
                    break;
                }
            }
        }
        return storeAccountIdToHasBundledProducts;
    }

    /**
     * @description It populates the Active rates on primary order products
     * from the passed list of subscriptions
     * @param activeRatesAppliedSubscriptions
     */
    public void populateActiveRatesOnPrimaryOrderItems(
        List<SBQQ__Subscription__c> activeRatesAppliedSubscriptions
    ) {
        Set<Id> primaryOrderItemIds = new Set<Id>();
        List<OrderItem> primaryOrderItemsToUpdate = new List<OrderItem>();
        for (SBQQ__Subscription__c eachSubscription : activeRatesAppliedSubscriptions) {
            if (
                eachSubscription.Subscription_Rate_Change__c != null &&
                eachSubscription.SBQQ__OrderProduct__r.Primary_Order_Product__c == null
            ) {
                primaryOrderItemIds.add(eachSubscription.SBQQ__OrderProduct__c);
            }
        }
        if (primaryOrderItemIds.isEmpty()) {
            return;
        }
        Map<Id, OrderItem> primaryOrderProductsMap = new Map<Id, OrderItem>(
            OrderItemsSelector.newInstance().selectById(primaryOrderItemIds)
        );

        for (SBQQ__Subscription__c eachSubscription : activeRatesAppliedSubscriptions) {
            OrderItem primaryOrderItem = primaryOrderProductsMap.get(
                eachSubscription.SBQQ__OrderProduct__c
            );
            if (primaryOrderItem.Quote_Line_Group__c == eachSubscription.Quote_Line_Group__c) {
                OrderItem newOrderItem = new OrderItem(
                    Id = primaryOrderItem.Id,
                    Active_Fee__c = eachSubscription.Active_Fee__c,
                    Active_Commission__c = eachSubscription.Active_Commission__c,
                    Subscription_Rate_Change__c = eachSubscription.Subscription_Rate_Change__c,
                    Final_Fee__c = eachSubscription.Active_Fee__c,
                    Final_Commission__c = eachSubscription.Active_Commission__c
                );
                primaryOrderItemsToUpdate.add(newOrderItem);
            }
        }
        updatePrimaryOrderProducts(primaryOrderItemsToUpdate);
    }

    /**
     * @description Update Primary Order Products
     * @param primaryOrderItemsToUpdate
     */
    private void updatePrimaryOrderProducts(List<OrderItem> primaryOrderItemsToUpdate) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(primaryOrderItemsToUpdate);
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description It is used to populate quote line group on the passed Order Items
     * @param orderItemList
     */
    public static void populateQuoteLineGroup(List<OrderItem> orderItemList) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (OrderItem item : orderItemList) {
            if (item.SBQQ__QuoteLine__r.SBQQ__Group__c == null) {
                continue;
            } else if (
                String.isBlank(item.SBQQ__QuoteLine__r.SBQQ__Group__r.CCP_Unique_Group_Id__c)
            ) {
                item.Quote_Line_Group__c = item.SBQQ__QuoteLine__r.SBQQ__Group__c;
            } else {
                item.Quote_Line_Group__c = Id.valueOf(
                    item.SBQQ__QuoteLine__r.SBQQ__Group__r.CCP_Unique_Group_Id__c
                );
            }
            uow.registerDirty(item);
        }
        try {
            uow.commitWork();
        } catch (Exception e) {
            Logger.publish(e, LogEntry.SeverityLevel.HIGH);
        }
    }
}