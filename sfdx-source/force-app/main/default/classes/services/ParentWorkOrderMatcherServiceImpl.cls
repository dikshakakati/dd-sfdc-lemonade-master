/**
 * @author Deloitte
 * @date 10/19/2022
 * @description Service implementation class for parent Work Order matching related logic.
 */
public inherited sharing class ParentWorkOrderMatcherServiceImpl implements IParentWorkOrderMatcherService {
    private static final String DRIVE_NINTEX_ID_FIELD = 'Drive_Nintex_Id__c';
    private static final String MARKETPLACE_NINTEX_ID_FIELD = 'Marketplace_Nintex_Id__c';
    private static final String NONE_USE_CASE = System.Label.NintexUseCaseNone;
    private static final String OBJECT_INSTANCE_MAP_EMPTY = '{}';
    private static final String OBJECT_INSTANCE_NULL = 'null';
    private static final String OBJECT_INSTANCE_LIST_OR_SET_EMTPY = '[]';
    private static final String OPPORTUNITY_SUB_TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String OPPORTUNITY_SUB_TYPE_DOWNGRADE = 'Downgrade';
    private static final String OPPORTUNITY_SUB_TYPE_UPGRADE = 'Upgrade';
    private static final Set<String> OPPORTUNITY_SUB_TYPES = new Set<String>{
        OPPORTUNITY_SUB_TYPE_DOWNGRADE,
        OPPORTUNITY_SUB_TYPE_UPGRADE
    };
    private static final String OPPORTUNITY_TYPE_EXISTING = 'Existing';
    private static final String PARENT_WORK_ORDER_MATCHED_BY_CONTRACT = 'Contract';
    private static final String PARENT_WORK_ORDER_MATCHED_BY_NINTEX_ID = 'Nintex Id';
    private static final String PARENT_WORK_ORDER_MATCHED_BY_PDOA = 'PDOA';
    private static final String PARENT_WORK_ORDER_MATCHED_BY_TYPE = 'Type';
    private static final String PARENT_WORK_ORDER_MATCHED_BY_MX_ONBOARDING_LINK = 'Onboarding Link';
    private static final String PDOA_DATE_RANGE_STATIC_CONFIG = 'PDOADateRange';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String SUB_TYPE_ADS_AND_PROMOS = 'Ads and Promo - Activate';
    private static final String SUB_TYPE_RATE_CHANGE = 'Rate Change';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_POST_SALES = 'Post-Sales';
    private static final String TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String MANAGE_PRICING_CREATION_SOURCE = 'Manage Pricing';
    private static final String SEGMENT_SMB = 'SMB';
    private Integer pdoaDateRange;
    private static final Set<String> OPPORTUNITY_SUB_TYPES_ELIGIBLE_FOR_ADS_AND_PROMOS = new Set<String>{
        OPPORTUNITY_SUB_TYPE_UPGRADE,
        OPPORTUNITY_SUB_TYPE_ADS_AND_PROMOS
    };
    private static final Set<String> WORK_ORDER_TYPES = new Set<String>{
        TYPE_MARKETPLACE,
        TYPE_STOREFRONT
    };
    private enum WorkOrderTypes {
        ADS_AND_PROMOS
    }
    private static final Map<String, WorkOrderTypes> WORKORDERTYPESMAPPINGS = new Map<String, WorkOrderTypes>{
        TYPE_ADS_AND_PROMOS => WorkOrderTypes.ADS_AND_PROMOS
    };
    private static final Set<String> WORK_ORDER_TYPES_ELIGIBLE_FOR_MATCH_BY_NINTEX_ID = new Set<String>{
        TYPE_MARKETPLACE,
        TYPE_DRIVE,
        TYPE_STOREFRONT
    };

    /**
     * @description Default constructor to instantiate variables.
     */
    public ParentWorkOrderMatcherServiceImpl() {
        collectStaticConfigurations();
    }

    /**
     * @description It is used to get parent Work Order record by matching Contract
     * against Order Product for "Post-Sales - Rate Change" Work Order where
     * Opportunity will be populated.
     * @JIRA# LEM-3357 & LEM-5118
     * @param orderItem
     * @param contractIdToParentWorkOrders
     * @return WorkOrder
     */
    public WorkOrder matchByContractOnRateChange(
        OrderItem orderItem,
        Map<Id, List<WorkOrder>> contractIdToParentWorkOrders
    ) {
        WorkOrder matchingParentWorkOrder;
        Id contractIdToCompare = getContractIdByOrderProduct(orderItem);
        if (!contractIdToParentWorkOrders.containsKey(contractIdToCompare)) {
            return matchingParentWorkOrder;
        }
        for (WorkOrder eachWorkOrder : contractIdToParentWorkOrders.get(contractIdToCompare)) {
            if (
                eachWorkOrder.Contract__c == contractIdToCompare &&
                isEligibleWorkOrderMatchByContractOnRateChange(orderItem, eachWorkOrder)
            ) {
                matchingParentWorkOrder = eachWorkOrder;
                break;
            }
        }
        if (!isEmptyOrNull(matchingParentWorkOrder)) {
            matchingParentWorkOrder.Matched_By__c = PARENT_WORK_ORDER_MATCHED_BY_CONTRACT;
        }
        return matchingParentWorkOrder;
    }

    /**
     * @description It is used to get parent Work Order record
     * by matching Nintex Id against Nintex Id of Opportunity associated
     * with Order of Order Product.
     * @JIRA# LEM-3357
     * @param orderItem
     * @param nintexIdToParentWorkOrders
     * @return WorkOrder
     */
    public WorkOrder matchByNintexId(
        OrderItem orderItem,
        Map<String, List<WorkOrder>> nintexIdToParentWorkOrders
    ) {
        WorkOrder matchingParentWorkOrder;
        String driveNintexId = orderItem.Order.Account.Drive_Nintex_Id__c;
        String marketplaceNintexId = orderItem.Order.Account.Marketplace_Nintex_Id__c;
        String workOrderType = orderItem.Product2.Work_Order_Type__c;
        if (!WORK_ORDER_TYPES_ELIGIBLE_FOR_MATCH_BY_NINTEX_ID.contains(workOrderType)) {
            return matchingParentWorkOrder;
        }
        Set<WorkOrder> parentWorkOrders = new Set<WorkOrder>();
        if (nintexIdToParentWorkOrders.containsKey(driveNintexId)) {
            parentWorkOrders.addAll(nintexIdToParentWorkOrders.get(driveNintexId));
        }
        if (nintexIdToParentWorkOrders.containsKey(marketplaceNintexId)) {
            parentWorkOrders.addAll(nintexIdToParentWorkOrders.get(marketplaceNintexId));
        }
        if (parentWorkOrders.isEmpty()) {
            return matchingParentWorkOrder;
        }
        for (WorkOrder eachWorkOrder : parentWorkOrders) {
            if (isEligibleWorkOrderMatchByNintexId(orderItem, eachWorkOrder)) {
                matchingParentWorkOrder = eachWorkOrder;
                break;
            }
        }
        if (!isEmptyOrNull(matchingParentWorkOrder)) {
            matchingParentWorkOrder.Matched_By__c = PARENT_WORK_ORDER_MATCHED_BY_NINTEX_ID;
        }
        return matchingParentWorkOrder;
    }

    /**
     * @description It is used to get parent Work Order record
     * by matching PDOA criteria against Order Product.
     * @JIRA# LEM-3357
     * @param orderItem
     * @param businessAccountIdToParentWorkOrders
     * @return WorkOrder
     */
    public WorkOrder matchByPDOA(
        OrderItem orderItem,
        Map<Id, List<WorkOrder>> businessAccountIdToParentWorkOrders
    ) {
        Integer closestPDOADifference;
        Integer currentPDOADifference;
        WorkOrder matchingParentWorkOrder;
        Date accountPDOA = orderItem.Order.Account.Proposed_Date_of_Activation__c;
        Date workOrderPDOA;
        for (
            WorkOrder eachWorkOrder : businessAccountIdToParentWorkOrders.get(
                orderItem.Primary_Order_Product__r.SBQQ__Contract__r.AccountId
            )
        ) {
            if (!isEligibleWorkOrder(orderItem, eachWorkorder)) {
                continue;
            }
            if (
                eachWorkorder.Proposed_Date_of_Activation__c == null ||
                eachWorkOrder.Proposed_Date_of_Activation__c < System.today()
            ) {
                continue;
            }
            workOrderPDOA = eachWorkOrder.Proposed_Date_of_Activation__c;
            if (isPDOAWithinTimeFrame(workOrderPDOA, accountPDOA)) {
                matchingParentWorkOrder = eachWorkorder;
                break;
            }
            currentPDOADifference = Math.abs(
                eachWorkOrder.Proposed_Date_of_Activation__c.daysBetween(
                    orderItem.Order.Account.Proposed_Date_of_Activation__c
                )
            );
            if (currentPDOADifference < closestPDOADifference || closestPDOADifference == null) {
                matchingParentWorkOrder = eachWorkorder;
                closestPDOADifference = currentPDOADifference;
            }
        }
        if (!isEmptyOrNull(matchingParentWorkOrder)) {
            matchingParentWorkOrder.Matched_By__c = PARENT_WORK_ORDER_MATCHED_BY_PDOA;
        }
        return matchingParentWorkOrder;
    }

    /**
     * @description It is used to get parent Work Order record
     * by matching type criteria.
     * @JIRA# LEM-12932
     * @param orderItem
     * @param businessAccountIdToParentWorkOrders
     * @return WorkOrder
     */
    public WorkOrder matchByRateChangeTypeFromRateChangeRequest(
        OrderItem orderItem,
        Map<Id, List<WorkOrder>> businessAccountIdToParentWorkOrders
    ) {
        WorkOrder matchingParentWorkOrder;
        if (orderItem == null || businessAccountIdToParentWorkOrders.isEmpty()) {
            return matchingParentWorkOrder;
        }
        for (
            WorkOrder eachWorkOrder : businessAccountIdToParentWorkOrders.get(
                orderItem.Primary_Order_Product__r.SBQQ__Contract__r.AccountId
            )
        ) {
            if (isEligibleWorkOrderMatchByTypeRateChangeForRcr(orderItem, eachWorkorder)) {
                matchingParentWorkOrder = eachWorkorder;
            }
        }
        if (!isEmptyOrNull(matchingParentWorkOrder)) {
            matchingParentWorkOrder.Matched_By__c = PARENT_WORK_ORDER_MATCHED_BY_TYPE;
        }
        return matchingParentWorkOrder;
    }

    /**
     * @description It is used to get parent Work Order record for Order Product
     * by matching type without matching PDOA.
     * @JIRA# LEM-3357, LEM-3384
     * @param orderItem
     * @param businessAccountIdToParentWorkOrders
     * @return WorkOrder
     */
    public WorkOrder matchByType(
        OrderItem orderItem,
        Map<Id, List<WorkOrder>> businessAccountIdToParentWorkOrders
    ) {
        WorkOrder matchingParentWorkOrder;
        if (
            WorkOrderSettingsService.isMatchByTypeDisabled(orderItem.Product2.Work_Order_Type__c) ||
            !businessAccountIdToParentWorkOrders.containsKey(
                orderItem.Primary_Order_Product__r.SBQQ__Contract__r.AccountId
            )
        ) {
            return matchingParentWorkOrder;
        }
        for (
            WorkOrder eachWorkOrder : businessAccountIdToParentWorkOrders.get(
                orderItem.Primary_Order_Product__r.SBQQ__Contract__r.AccountId
            )
        ) {
            if (!isEligibleWorkOrder(orderItem, eachWorkorder)) {
                continue;
            }
            matchingParentWorkOrder = eachWorkOrder;
            break;
        }
        if (!isEmptyOrNull(matchingParentWorkOrder)) {
            matchingParentWorkOrder.Matched_By__c = PARENT_WORK_ORDER_MATCHED_BY_TYPE;
        }
        return matchingParentWorkOrder;
    }

    /**
     * @description It is used to get parent Work Order record
     * by matching Unique Identifier.
     * @param orderItem
     * @param uniqueIdentifierToParentWorkOrders
     * @return WorkOrder
     */
    public WorkOrder matchByMxOnboardingLink(
        OrderItem orderItem,
        Map<String, List<WorkOrder>> uniqueIdentifierToParentWorkOrders
    ) {
        WorkOrder matchingParentWorkOrder;
        if (
            isEmptyOrNull(orderItem) ||
            uniqueIdentifierToParentWorkOrders.isEmpty() ||
            !uniqueIdentifierToParentWorkOrders.containsKey(
                orderItem.Order.Account.Mx_Onboarding_Link_Id__c
            )
        ) {
            return matchingParentWorkOrder;
        }
        for (
            WorkOrder eachWorkOrder : uniqueIdentifierToParentWorkOrders.get(
                orderItem.Order.Account.Mx_Onboarding_Link_Id__c
            )
        ) {
            if (isEligibleWorkOrderCreationByOnboardingInputs(orderItem, eachWorkOrder)) {
                matchingParentWorkOrder = eachWorkOrder;
                matchingParentWorkOrder.Matched_By__c = PARENT_WORK_ORDER_MATCHED_BY_MX_ONBOARDING_LINK;
                break;
            }
        }
        return matchingParentWorkOrder;
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.pdoaDateRange = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PDOA_DATE_RANGE_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It returns the Contract Id by comparing Activation Order Product
     * and Primary Order Product.
     * @param orderProduct
     * @return String
     */
    private String getContractIdByOrderProduct(OrderItem orderProduct) {
        return orderProduct.SBQQ__Contract__c == null
            ? orderProduct.Primary_Order_Product__r.SBQQ__Contract__c
            : orderProduct.SBQQ__Contract__c;
    }

    /**
     * @description It is used to get Drive or Marketplace Nintex Id from the passed Opportunity.
     * @param sObjectInstance
     * @return String
     */
    private String getNintexId(Sobject sObjectInstance) {
        return String.isNotBlank(String.valueOf(sObjectInstance?.get(MARKETPLACE_NINTEX_ID_FIELD)))
            ? String.valueOf(sObjectInstance?.get(MARKETPLACE_NINTEX_ID_FIELD))
            : String.valueOf(sObjectInstance?.get(DRIVE_NINTEX_ID_FIELD));
    }

    /**
     * @description To check whether the passed list or set or map is null or empty.
     * @param objectInstance - List/Set/Map
     * @return Boolean
     */
    private Boolean isEmptyOrNull(Object objectInstance) {
        return (JSON.serialize(objectInstance) == OBJECT_INSTANCE_NULL) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_LIST_OR_SET_EMTPY) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_MAP_EMPTY);
    }

    /**
     * @description It validates parent Work Order related opportunity eligibility based on
     * critieria as below:
     * Type should be 'Existing' AND
     * Sub-Type of Opportunity should be either 'Downgrade' OR
     * Sub-Type of Opportunity should be 'Upgrade'.
     * @param opportunityToValidate
     * @return Boolean
     */
    private Boolean isEligibleOpportunity(Opportunity opportunityToValidate) {
        return (opportunityToValidate.Type == OPPORTUNITY_TYPE_EXISTING &&
        OPPORTUNITY_SUB_TYPES.contains(opportunityToValidate.Opportunity_Sub_Type__c));
    }

    /**
     * @description It validates parent Work Order related opportunity eligibility based on
     * critieria as below:
     * Type should be 'Existing' AND
     * Sub-Type of Opportunity should be either 'Ads & Promos' OR
     * Sub-Type of Opportunity should be 'Upgrade'
     * @param opportunityToValidate
     * @return Boolean
     */
    private Boolean isEligibleOpportunityForAdsPromos(Opportunity opportunityToValidate) {
        return opportunityToValidate.Type == OPPORTUNITY_TYPE_EXISTING &&
            OPPORTUNITY_SUB_TYPES_ELIGIBLE_FOR_ADS_AND_PROMOS.contains(
                opportunityToValidate.Opportunity_Sub_Type__c
            );
    }

    /**
     * @description It validates parent Work Order eligibility on basis of the critieria as below:
     * Proposed Date of Activation must be populated AND
     * Work Order Type should be 'COO' when Sub-Type of Opportunity related to Order is 'COO' OR
     * Work Order Type and Sub-Type should match with Type and Sub-Type on Product related to
     * Order Product.
     * @param orderItem
     * @param workOrder
     * @return Boolean
     */
    private Boolean isEligibleWorkOrder(OrderItem orderItem, WorkOrder workOrder) {
        Boolean isEligible = false;
        if (
            orderItem.Primary_Order_Product__r.Order.Opportunity.Opportunity_Sub_Type__c ==
            TYPE_COO &&
            workOrder.Type__c == TYPE_COO
        ) {
            isEligible = true;
        } else if (orderItem.Order.Opportunity.Opportunity_Sub_Type__c != TYPE_COO) {
            isEligible =
                workOrder.Type__c == orderItem.Product2.Work_Order_Type__c &&
                (orderItem.Product2.Work_Order_Sub_Type__c == null ||
                workOrder.Sub_Type__c == orderItem.Product2.Work_Order_Sub_Type__c);
        }
        return isEligible;
    }

    /**
     * @description It validates eligiblity of parent Work Order on the basis of criteria as below:
     * Work Order should be Ads and Promos when Work Order Sub Type is 'Ads & Promos - Activate'.
     * For other WorkOrder Types Work Order Type and Product Work Order Type should match.
     * @param orderItem
     * @param workOrder
     * @return Boolean
     */
    private Boolean isEligibleWorkOrderCreationByOnboardingInputs(
        OrderItem orderItem,
        WorkOrder workOrder
    ) {
        Boolean isEligible;
        switch on WORKORDERTYPESMAPPINGS.get(workOrder.Type__c) {
            when ADS_AND_PROMOS {
                isEligible =
                    !isEmptyOrNull(orderItem.Product2.Work_Order_Type__c) &&
                    orderItem.Product2.Work_Order_Type__c == TYPE_POST_SALES &&
                    orderItem.Product2.Work_Order_Sub_Type__c == SUB_TYPE_ADS_AND_PROMOS;
            }
            when else {
                isEligible =
                    !isEmptyOrNull(orderItem.Product2.Work_Order_Type__c) &&
                    orderItem.Product2.Work_Order_Type__c == workOrder.Type__c;
            }
        }
        return isEligible;
    }

    /**
     * @description It validates parent Work Order eligibility on basis of the critieria as below:
     * Work Order Type and Sub-Type should be 'Post-Sales' and 'Rate Change' when
     * there is an Opportunity associated with Work Order.
     * @param orderItem
     * @param workOrder
     * @return Boolean
     */
    private Boolean isEligibleWorkOrderMatchByContractOnRateChange(
        OrderItem orderItem,
        WorkOrder workOrder
    ) {
        Boolean isEligible = false;
        String workOrderType = getWorkOrderTypeByOrderItem(orderItem);
        String workOrderSubType = getWorkOrderTypeByOrderItem(orderItem);
        if (
            workOrder.Opportunity__c != null &&
            // JIRA#: LEM-4459 - excluded Franchise scenario to prevent duplicate child WO creation.
            // NintexWorkOrdersProcessorBatch associates stores with parent WO in the Nintex flow.
            workOrder.Nintex_Use_Case__c == NONE_USE_CASE &&
            workOrder.Type__c == TYPE_POST_SALES &&
            workOrder.Sub_Type__c == SUB_TYPE_RATE_CHANGE &&
            //JIRA#: LEM-5118 - Added extra checks to match Opportunity criteria.
            (WORK_ORDER_TYPES.contains(workOrderType) &&
            workOrderSubType != SUB_TYPE_ADS_AND_PROMOS &&
            isEligibleOpportunity(workOrder.Opportunity__r))
        ) {
            isEligible = true;
        } else if (isEligibleMatchByAdsPromos(orderItem, workOrder)) {
            // LEM-15365
            isEligible = true;
        }
        return isEligible;
    }

    /**
     * @description It returns the Work Order Sub Type based on passed Order Item.
     * @param orderItem
     * @return String
     */
    private String getWorkOrderSubTypeByOrderItem(OrderItem orderItem) {
        return orderItem?.Product2?.Work_Order_Sub_Type__c == null
            ? orderItem
                  ?.SBQQ__QuoteLine__r
                  ?.SBQQ__RequiredBy__r
                  ?.SBQQ__Product__r
                  ?.Work_Order_Sub_Type__c
            : orderItem?.Product2?.Work_Order_Sub_Type__c;
    }

    /**
     * @description It returns the Work Order Type based on passed Order Item.
     * @param orderItem
     * @return String
     */
    private String getWorkOrderTypeByOrderItem(OrderItem orderItem) {
        return orderItem?.Product2?.Work_Order_Type__c == null
            ? orderItem
                  ?.SBQQ__QuoteLine__r
                  ?.SBQQ__RequiredBy__r
                  ?.SBQQ__Product__r
                  ?.Work_Order_Type__c
            : orderItem?.Product2?.Work_Order_Type__c;
    }

    /**
     * @description It checks whether store Account 'Proposed Date of Activation'
     * is within time frame.
     * @param workOrderPDOA
     * @param storeAccountPDOA
     * @return Boolean
     */
    private Boolean isPDOAWithinTimeFrame(Date workOrderPDOA, Date storeAccountPDOA) {
        return (workOrderPDOA.addDays(-pdoaDateRange) <= storeAccountPDOA) &&
            (storeAccountPDOA <= workOrderPDOA.addDays(pdoaDateRange));
    }

    /**
     * @description It validates parent Work Order eligibility on basis of the critieria as below:
     * Work Order Type and Sub-Type should be 'Post-Sales' and 'Rate Change'.
     * @param orderItem
     * @param workOrder
     * @return Boolean
     */
    private Boolean isEligibleWorkOrderMatchByTypeRateChangeForRcr(
        OrderItem orderItem,
        WorkOrder workOrder
    ) {
        Boolean isEligible = false;
        if (
            workOrder.Type__c == TYPE_POST_SALES &&
            workOrder.Sub_Type__c == SUB_TYPE_RATE_CHANGE &&
            workOrder.Creation_Source__c == MANAGE_PRICING_CREATION_SOURCE
        ) {
            isEligible = true;
        }
        return isEligible;
    }

    /**
     * @description It validates parent Work Order eligibility on basis of the criteria as below :
     * matching Nintex Id
     * Work Order Type
     * @JIRA# LEM-21419
     * @param orderItem
     * @param workOrderInstance
     * @return Boolean
     */
    private Boolean isEligibleWorkOrderMatchByNintexId(
        OrderItem orderItem,
        WorkOrder workOrderInstance
    ) {
        String nintexIdToMatch = getNintexId(workOrderInstance.Opportunity__r);
        String driveNintexId = orderItem.Order.Account.Drive_Nintex_Id__c;
        String marketplaceNintexId = orderItem.Order.Account.Marketplace_Nintex_Id__c;
        String workOrderType = orderItem.Product2.Work_Order_Type__c;
        return (nintexIdToMatch == driveNintexId || nintexIdToMatch == marketplaceNintexId) &&
            (workOrderType == workOrderInstance.Type__c ||
             workOrderInstance.Type__c == TYPE_COO);
    }

    /**
     * @description It validates parent Work Order eligibility on basis of the critieria as below:
     * Segment should be 'SMB', Work Order Type should be 'Ads & Promos'.
     * @param orderItem
     * @param workOrder
     * @return Boolean
     */
    private Boolean isEligibleMatchByAdsPromos(OrderItem orderItem, WorkOrder workOrder) {
        return workOrder.Nintex_Use_Case__c == NONE_USE_CASE &&
            workOrder.Segment__c == SEGMENT_SMB &&
            workOrder.Type__c == TYPE_ADS_AND_PROMOS &&
            TYPE_POST_SALES == getWorkOrderTypeByOrderItem(orderItem) &&
            SUB_TYPE_ADS_AND_PROMOS == getWorkOrderSubTypeByOrderItem(orderItem) &&
            isEligibleOpportunityForAdsPromos(workOrder.Opportunity__r);
    }
}