/**
 * @author Deloitte
 * @date 27/06/2022
 * @description Service implementation class for AddStoresOnWorkOrderController related logic.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class AddStoresOnWorkOrderServiceImpl implements IAddStoresOnWorkOrderService {
    private static final String ACCOUNT_TYPE_FRANCHISEE = 'Franchisee';
    private static final String AGREEMENT_STATUS_ACTIVE = 'Active';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String CPU_TIME_ALLOWED_LIMIT_STATIC_CONFIG = 'CPU_Time_Allowed_Limit';
    private static final String DELIMITER = ',';
    private static final String EXTERNAL_ID = 'External_ID__c';
    private static final String OBJECT_INSTANCE_MAP_EMPTY = '{}';
    private static final String OBJECT_INSTANCE_NULL = 'null';
    private static final String OBJECT_INSTANCE_LIST_OR_SET_EMTPY = '[]';
    private static final String QUERIES_ALLOWED_LIMIT_STATIC_CONFIG = 'Queries_Allowed_Limit';
    private static final String QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG = 'Query_Rows_Allowed_Limit';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_TYPE_POST_SALES = 'Post-Sales';
    private static final String WORK_ORDER_SUB_TYPE_RATE_CHANGE = 'Rate Change';
    private static final String TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_POS = 'POS';
    private static final Set<String> WORK_ORDER_TYPES = new Set<String>{
        WORK_ORDER_TYPE_MARKETPLACE,
        WORK_ORDER_TYPE_STOREFRONT
    };
    private static final String XREF_OBJECT_NAME = 'Xref__c';
    private static final String XREF_RELATIONSHIP_NAME = 'Xrefs__r';
    private enum ObjectNames {
        XREF
    }
    private static final Map<String, ObjectNames> OBJECTNAMETOOBJECTNAMEENUMVALUES = new Map<String, ObjectNames>{
        XREF_OBJECT_NAME => ObjectNames.XREF
    };
    private static final Map<ObjectNames, String> SOBJECTTYPETORELATIONSHIP = new Map<ObjectNames, String>{
        ObjectNames.XREF => XREF_RELATIONSHIP_NAME
    };
    private static final Set<String> WORK_ORDER_TYPES_TO_SKIP_IN_PROGRESS_MARKETPLACE_WO_VALIDATION = new Set<String>{
        TYPE_DRIVE,
        TYPE_POS,
        WORK_ORDER_TYPE_STOREFRONT
    };
    private static final Set<String> WORK_ORDER_TYPES_SUBTYPE_TO_SKIP_IN_PROGRESS_MARKETPLACE_WORK_ORDER_VALIDATION_FOR_SMB = new Set<String>{
        TYPE_ADS_AND_PROMOS + null,
        WORK_ORDER_TYPE_POST_SALES + WORK_ORDER_SUB_TYPE_RATE_CHANGE
    };
    private Integer cpuTimeAllowedLimit;
    private Set<Id> lastReturnedParentIds;
    private Set<Id> parentIds;
    private String parentWorkOrderContractId;
    private Integer queriesAllowedLimit;
    private Integer queryRowsAllowedLimit;
    private List<AccountWrapper> storeAccountWrappers;
    private Set<Id> storeIdsWithoutBundledProducts;

    /**
     * @description Default constructor to instantiate variables.
     */
    public AddStoresOnWorkOrderServiceImpl() {
        lastReturnedParentIds = new Set<Id>();
        parentIds = new Set<Id>();
        storeIdsWithoutBundledProducts = new Set<Id>();
        storeAccountWrappers = new List<AccountWrapper>();
        collectStaticConfigurations();
    }

    /**
     * @description It creates child Work Orders on passed parent Work Order
     * for the selected stores.
     * @JIRA# LEM-2013
     * @param parentWorkOrderId
     * @param storeAccountIds
     * @return String
     */
    public String createChildWorkOrders(Id parentWorkOrderId, String storeAccountIds) {
        Set<Id> selectedStoreAccountIds = new Set<Id>((List<Id>) storeAccountIds.split(DELIMITER));
        Map<Id, Set<Id>> parentWorkOrderIdToSelectedStoreAccountIds = new Map<Id, Set<Id>>{
            parentWorkOrderId => selectedStoreAccountIds
        };
        return processParentWorkOrderWithSelectedStores(parentWorkOrderIdToSelectedStoreAccountIds);
    }

    /**
     * @description It validates if there is Marketplace Work Order for Store Account when trying
     * to create new Work order other than Drive and POS and selected stores passed parent Work Order
     * for the selected stores. It also validates if an active xref is present for the stores being
     * added to the Work Order.
     * @JIRA# LEM-5594, LEM-7912 and LEM-11611
     * @param parentWorkOrderId
     * @param storeAccountIds
     * @return Map<String, List<String>>
     */
    public Map<String, List<String>> validateStores(Id parentWorkOrderId, String storeAccountIds) {
        List<Account> accountsWithMarketplaceWorkOrder = new List<Account>();
        List<String> failureMessages = new List<String>{ 'Failure' };
        Set<Id> parentWorkOrderIds = new Set<Id>{ parentWorkOrderId };
        Map<String, List<String>> returnMap = new Map<String, List<String>>();
        Set<Id> selectedStoreAccountIds = new Set<Id>((List<Id>) storeAccountIds.split(DELIMITER));
        List<String> successMessages = new List<String>{ 'Success' };
        List<String> validationErrorMessages = new List<String>();
        Map<Id, WorkOrder> parentWorkOrders = new Map<Id, WorkOrder>(
            WorkOrdersSelector.newInstance().selectById(parentWorkOrderIds)
        );
        parentWorkOrderContractId = parentWorkOrders.values()[0].Contract__c;
        if (
            isEligibleWorkOrderTypeSubTypeToSkipOpenMarketplaceWorkOrderValidation(
                parentWorkOrders.get(parentWorkOrderId)
            )
        ) {
            accountsWithMarketplaceWorkOrder = validateAccountHavingInProgressMarketPlaceWO(
                selectedStoreAccountIds
            );
        }
        List<Account> validatedStoreAccounts = checkStoreAccounts(selectedStoreAccountIds);
        List<Account> storeAccountsWithoutActiveXrefs = getStoresAccountsWithoutActiveMDSXrefs(
            parentWorkOrders.get(parentWorkOrderId),
            selectedStoreAccountIds
        );
        if (
            isEmptyOrNull(validatedStoreAccounts) &&
            isEmptyOrNull(storeAccountsWithoutActiveXrefs) &&
            isEmptyOrNull(accountsWithMarketplaceWorkOrder)
        ) {
            returnMap.put('validation', successMessages);
            returnMap.put('validation-message', successMessages);
        } else {
            validationErrorMessages.add(
                getValidationErrorMessageByStoreAccounts(
                    Label.Store_Validation_Error_Message,
                    validatedStoreAccounts
                )
            );
            validationErrorMessages.add(
                getValidationErrorMessageByStoreAccounts(
                    Label.Active_MDS_Xref_Validation_Error_Message,
                    storeAccountsWithoutActiveXrefs
                )
            );
            validationErrorMessages.add(
                getValidationErrorMessageByStoreAccounts(
                    Label.Child_Marketplace_Work_Order_Validation_Message,
                    accountsWithMarketplaceWorkOrder
                )
            );
            returnMap.put('validation', failureMessages);
            returnMap.put('validation-message', validationErrorMessages);
        }
        return returnMap;
    }

    /**
     * @description Logic to validate if there is Marketplace Work Order for Store Account when trying
     * to create new Work order other than Drive and POS.
     * @JIRA# LEM-7912
     * @param accountIds
     * @return List<Account>
     */
    private List<Account> validateAccountHavingInProgressMarketPlaceWO(Set<Id> accountIds) {
        List<Account> lstAcc = new List<Account>();
        Set<Id> accountIdsWithMarketplaceWO = new Set<Id>();
        List<WorkOrder> childWorkOrders = WorkOrdersSelector.newInstance()
            .selectOpenMarketPlaceWorkOrdersByAccountIds(accountIds);
        if (childWorkOrders != null && !childWorkOrders.isEmpty()) {
            for (WorkOrder eachWorkOrder : childWorkOrders) {
                accountIdsWithMarketplaceWO.add(eachWorkOrder.AccountId);
            }
        }
        if (!accountIdsWithMarketplaceWO.isEmpty()) {
            lstAcc = AccountsSelector.newInstance().selectById(accountIdsWithMarketplaceWO);
        }
        return lstAcc;
    }

    /**
     * @description logic to validate Store accounts
     *
     * @param selectedStoreAccountIds
     * @return List<Account>
     */
    public List<Account> checkStoreAccounts(Set<Id> selectedStoreAccountIds) {
        List<Account> lstAcc = new List<Account>();

        Map<Id, Account> accountMap = new Map<Id, Account>(
            AccountsSelector.newInstance().selectById(selectedStoreAccountIds)
        );

        List<Agreement__c> agreementsList = AgreementsSelector.newInstance()
            .selectAgreementsByAccounts(selectedStoreAccountIds);

        Set<Id> storeAccountsAssociatedWithParentWorkOrderContracts = collectStoreAccountIdsByParentWorkOrderContract(
            agreementsList
        );

        Set<Id> eixstingAgreements = getAccountIds(agreementsList, 'Account__c');

        List<Merchant_Service__c> servicesList = MerchantSelector.newInstance()
            .queryMerchantRecordsWithAccountIds(selectedStoreAccountIds);

        Set<Id> eixstingServices = getAccountIds(servicesList, 'Account__c');

        List<Order> ordersList = OrdersSelector.newInstance()
            .selectOrdersByAccountIds(selectedStoreAccountIds);

        Set<Id> eixstingOrders = getAccountIds(ordersList, 'AccountId');

        for (Id accId : selectedStoreAccountIds) {
            if (
                accountMap.containsKey(accId) &&
                (!eixstingAgreements.contains(accId) ||
                !eixstingServices.contains(accId) ||
                !eixstingOrders.contains(accId) ||
                !storeAccountsAssociatedWithParentWorkOrderContracts.contains(accId))
            ) {
                lstAcc.add(accountMap.get(accId));
            }
        }

        return lstAcc;
    }

    /**
     * @description It processes the list and get account ids and store it in set
     * and return the set<Id>.
     * @param recordsList
     * @param fieldAPI
     * @return set<Id>
     */
    public Set<Id> getAccountIds(List<sObject> recordsList, string fieldAPI) {
        Set<Id> accountIds = new Set<Id>();
        for (sObject rec : recordsList) {
            accountIds.add((Id) rec.get(fieldAPI));
        }
        return accountIds;
    }

    /**
     * @description It fetches in-coverage verified store Accounts and associated Xrefs
     * which are related to the business Account attached to parent Work Order and doesn't have
     * any child Work Orders.
     * @JIRA# LEM-2013, LEM-3495, LEM-3672
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    public AddStoresContainer fetchVerifiedStores(String addStoresContainerJSON) {
        AddStoresContainer originalParentWrapper = (AddStoresContainer) JSON.deserialize(
            addStoresContainerJSON,
            AddStoresContainer.class
        );
        parentIds.addAll(new Set<Id>(originalParentWrapper.parentIds));
        lastReturnedParentIds.addAll(new Set<Id>(originalParentWrapper.lastReturnedParentIds));
        for (
            Account eachStoreAccount : getVerifiedStoreAccounts(
                originalParentWrapper.parentWorkOrder,
                originalParentWrapper.lastReturnedStoreAccountId
            )
        ) {
            storeAccountWrappers.add(getAccountWrapper(eachStoreAccount));
        }
        return getParentWrapper();
    }

    /**
     * @description It is used to search in-coverage and verified store Accounts and related Xrefs
     * which are related to the business Account attached to parent Work Order and doesn't have
     * any child Work Order by matching the passed search key with the Account's Name or Address
     * or Xref's External Id.
     * @JIRA# LEM-3495, LEM-3672
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    public AddStoresContainer findVerifiedStoresBySearchKey(String addStoresContainerJSON) {
        AddStoresContainer originalParentWrapper = (AddStoresContainer) JSON.deserialize(
            addStoresContainerJSON,
            AddStoresContainer.class
        );
        parentIds.addAll(new Set<Id>(originalParentWrapper.parentIds));
        WorkOrder parentWorkOrder = originalParentWrapper.parentWorkOrder;
        String searchKey = originalParentWrapper.searchKey;
        Set<Id> storeIds = new Set<Id>();
        Schema.SObjectField parentField = Account.ParentId;
        if (parentWorkOrder.Account_Type__c == ACCOUNT_TYPE_FRANCHISEE) {
            parentField = Account.Franchise_Parent__c;
        }
        // Find Xref__c records by search key
        for (Xref__c eachXref : XrefsSelector.newInstance().selectBySearchKey(searchKey)) {
            storeIds.add(eachXref.Salesforce_Account_Name__c);
        }
        for (
            Account eachStoreAccount : AccountsSelector.newInstance()
                .selectVerifiedStoreAccountsByBusinessIdAndSearchKey(
                    parentIds,
                    parentWorkOrder.Id,
                    parentField,
                    searchKey,
                    storeIds
                )
        ) {
            storeAccountWrappers.add(getAccountWrapper(eachStoreAccount));
        }
        return getParentWrapper();
    }

    /**
     * @description It fetches store Accounts which are related to the parent Work Order
     * @JIRA# LEM-5343
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    public AddStoresContainer fetchStoresAdded(String addStoresContainerJSON) {
        AddStoresContainer originalParentWrapper = (AddStoresContainer) JSON.deserialize(
            addStoresContainerJSON,
            AddStoresContainer.class
        );
        parentIds.addAll(new Set<Id>(originalParentWrapper.parentIds));
        lastReturnedParentIds.addAll(new Set<Id>(originalParentWrapper.lastReturnedParentIds));
        List<Account> storeAccounts = new List<Account>();
        if (String.isBlank(originalParentWrapper.lastReturnedStoreAccountId)) {
            storeAccounts = AccountsSelector.newInstance()
                .selectRelatedStoreAccounts(originalParentWrapper.parentWorkOrder.Id);
        } else {
            storeAccounts = AccountsSelector.newInstance()
                .selectRelatedStoreAccountsChunk(
                    originalParentWrapper.parentWorkOrder.Id,
                    originalParentWrapper.lastReturnedStoreAccountId
                );
        }

        for (Account eachStoreAccount : storeAccounts) {
            storeAccountWrappers.add(getAccountWrapper(eachStoreAccount));
        }
        return getParentWrapper();
    }

    /**
     * @description It fetches store Accounts which are related to the parent Work Order
     * by matching the passed search key with the Account's Name or Address or Xref's External Id.
     * @JIRA# LEM-5343
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    public AddStoresContainer findStoresAddedBySearchKey(String addStoresContainerJSON) {
        AddStoresContainer originalParentWrapper = (AddStoresContainer) JSON.deserialize(
            addStoresContainerJSON,
            AddStoresContainer.class
        );
        parentIds.addAll(new Set<Id>(originalParentWrapper.parentIds));
        WorkOrder parentWorkOrder = originalParentWrapper.parentWorkOrder;
        String searchKey = originalParentWrapper.searchKey;
        Set<Id> storeIds = new Set<Id>();
        // Find Xref__c records by search key
        for (Xref__c eachXref : XrefsSelector.newInstance().selectBySearchKey(searchKey)) {
            storeIds.add(eachXref.Salesforce_Account_Name__c);
        }
        for (
            Account eachStoreAccount : AccountsSelector.newInstance()
                .selectRelatedStoreAccountsBySearchKey(parentWorkOrder.Id, searchKey, storeIds)
        ) {
            storeAccountWrappers.add(getAccountWrapper(eachStoreAccount));
        }
        return getParentWrapper();
    }

    /**
     * @description It collects Store Accounts without active 'MDS' Xrefs as per the criteria below:
     * Work Order Type = Storefront and Store Account doesn't have bundled products OR
     * Work Order Type = Post-Sales and Work Order Sub Type = Rate Change
     * @JIRA# LEM-11611
     * @param parentWorkOrder
     * @param storeAccountIds
     * @return List<Account>
     */
    public List<Account> getStoresAccountsWithoutActiveMDSXrefs(
        WorkOrder parentWorkOrder,
        Set<Id> storeAccountIds
    ) {
        Set<Id> storeAccountIdsWithActiveMDSXref = new Set<Id>();
        Set<Id> storeAccountIdsWithoutActiveMDSXref = new Set<Id>();
        Map<Id, Boolean> storeAccountIdToHasBundledProducts = OrderItemsService.getStoresWithBundledOrderProducts(
            OrderItemsSelector.newInstance()
                .selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    storeAccountIds,
                    WORK_ORDER_TYPES
                )
        );
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectActiveMDSXrefsByStoreIds(storeAccountIds)
        ) {
            storeAccountIdsWithActiveMDSXref.add(eachXref.Salesforce_Account_Name__c);
        }

        for (Id eachStoreId : storeAccountIds) {
            if (
                (!storeAccountIdsWithActiveMDSXref.contains(eachStoreId)) &&
                ((parentWorkOrder.Type__c == WORK_ORDER_TYPE_STOREFRONT &&
                !storeAccountIdToHasBundledProducts.containsKey(eachStoreId)) ||
                (parentWorkOrder.Type__c == WORK_ORDER_TYPE_POST_SALES &&
                parentWorkOrder.Sub_Type__c == WORK_ORDER_SUB_TYPE_RATE_CHANGE))
            ) {
                storeAccountIdsWithoutActiveMDSXref.add(eachStoreId);
            }
        }
        return AccountsSelector.newInstance().selectById(storeAccountIdsWithoutActiveMDSXref);
    }

    /**
     * @description It returns the concatenation of the passed validation error message
     * and store account names.
     * @JIRA# LEM-11611
     * @param validationErrorMessage
     * @param accountsWithValidationError
     * @return String
     */
    public String getValidationErrorMessageByStoreAccounts(
        String validationErrorMessage,
        List<Account> accountsWithValidationError
    ) {
        String storeAccoutNames = '';
        if (isEmptyOrNull(accountsWithValidationError)) {
            return '';
        }
        for (Account eachAccount : accountsWithValidationError) {
            storeAccoutNames += '<br/>' + eachAccount.Name;
        }
        return validationErrorMessage + storeAccoutNames;
    }

    /**
     * @description It collects external Ids from Xref records & adds in comma separated string.
     * @JIRA# LEM-2013
     * @param fieldName
     * @param sObjects
     * @return String
     */
    private String collectAllExternalIds(String fieldName, List<sObject> sObjects) {
        List<String> externalIds = new List<String>();
        for (sObject eachSObject : sObjects) {
            if (isEmptyOrNull(eachSObject.get(fieldName))) {
                continue;
            }
            externalIds.add(String.valueOf(eachSObject.get(fieldName)));
        }
        return String.join(externalIds, DELIMITER);
    }

    /**
     * @description It is used to get static configurations for limits.
     * @JIRA# LEM-3672
     */
    private void collectStaticConfigurations() {
        this.cpuTimeAllowedLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(CPU_TIME_ALLOWED_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
        this.queriesAllowedLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(QUERIES_ALLOWED_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
        this.queryRowsAllowedLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It collects Store Account Ids with Agreement on Contract matching
     * with parent Work Order's Contract.
     * @param storeAgreements
     * @return Set<Id>
     */
    private Set<Id> collectStoreAccountIdsByParentWorkOrderContract(
        List<Agreement__c> storeAgreements
    ) {
        Set<Id> storeAccountsAssociatedWithParentWorkOrderContracts = new Set<Id>();
        for (Agreement__c eachAgreement : storeAgreements) {
            if (
                eachAgreement.Contract__c == parentWorkOrderContractId &&
                eachAgreement.Status__c == AGREEMENT_STATUS_ACTIVE
            ) {
                storeAccountsAssociatedWithParentWorkOrderContracts.add(eachAgreement.Account__c);
            }
        }
        return storeAccountsAssociatedWithParentWorkOrderContracts;
    }

    /**
     * @description To generate account wrapper for the passed store Account.
     * @param storeAccount
     * @return AccountWrapper
     */
    private AccountWrapper getAccountWrapper(Account storeAccount) {
        AccountWrapper accountWrapper = new AccountWrapper(
            storeAccount.Id,
            storeAccount.Name,
            storeAccount.Activation_Status__c != null ? storeAccount.Activation_Status__c : '',
            storeAccount.Account_Address__c != null ? storeAccount.Account_Address__c : '',
            getExternalIds(storeAccount, XREF_OBJECT_NAME)
        );
        return accountWrapper;
    }

    /**
     * @description It fetches external id from Xref object.
     * @JIRA# LEM-2013
     * @param account - Account Record with related Xrefs
     * @param objectName - Object Name
     * @return String - comma separated external ids
     */
    private String getExternalIds(Account account, String objectName) {
        String relationshipType = SOBJECTTYPETORELATIONSHIP.get(
            OBJECTNAMETOOBJECTNAMEENUMVALUES.get(objectName)
        );
        if (relationshipType != XREF_RELATIONSHIP_NAME) {
            return '';
        }
        SObject[] sObjects = account.getSObjects(relationshipType);
        return isEmptyOrNull(sObjects) ? '' : collectAllExternalIds(EXTERNAL_ID, sObjects);
    }

    /**
     * @description It fetches verified stores on basis of the passed lastReturnedId and
     * parentField on Work Order.
     * @param parentWorkOrder
     * @param lastReturnedId
     * @return List<Account>
     */
    private List<Account> getVerifiedStoreAccounts(
        WorkOrder parentWorkOrder,
        String lastReturnedId
    ) {
        List<Account> verifiedStoreAccounts = new List<Account>();
        Schema.SObjectField parentField = Account.ParentId;
        if (parentWorkOrder.Account_Type__c == ACCOUNT_TYPE_FRANCHISEE) {
            parentField = Account.Franchise_Parent__c;
        }
        if (String.isBlank(lastReturnedId)) {
            fetchParentAccountsHierarchy(parentField, new Set<Id>{ parentWorkOrder.AccountId });
            verifiedStoreAccounts = AccountsSelector.newInstance()
                .selectVerifiedStoreAccountsByBusinessId(
                    parentIds,
                    parentWorkOrder.Id,
                    parentField
                );
        } else {
            verifiedStoreAccounts = AccountsSelector.newInstance()
                .selectVerifiedStoreAccountsById(
                    parentIds,
                    parentWorkOrder.Id,
                    parentField,
                    (Id) lastReturnedId
                );
            /* Added safe check for retrieving parent Ids in-case first iteration of
             * recursive retrieval fails to collect all parent Ids due to governor limits.
             */
            if (verifiedStoreAccounts.isEmpty() && !lastReturnedParentIds.isEmpty()) {
                fetchParentAccountsHierarchy(parentField, lastReturnedParentIds);
                verifiedStoreAccounts = AccountsSelector.newInstance()
                    .selectVerifiedStoreAccountsById(
                        parentIds,
                        parentWorkOrder.Id,
                        parentField,
                        (Id) lastReturnedId
                    );
            }
        }
        return verifiedStoreAccounts;
    }
    /**
     * @description To check whether the passed list or set or map is null or empty.
     * @JIRA# LEM-2013
     * @param objectInstance - List/Set/Map
     * @return Boolean
     */
    private Boolean isEmptyOrNull(Object objectInstance) {
        return (JSON.serialize(objectInstance) == OBJECT_INSTANCE_NULL) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_LIST_OR_SET_EMTPY) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_MAP_EMPTY);
    }

    /**
     * @description It fetches parent Work Order and selected stores details to trigger
     * child Work Orders creation on stores.
     * @JIRA# LEM-2013
     * @param parentWorkOrderIdToSelectedStoreAccountIds
     * @return String
     */
    private String processParentWorkOrderWithSelectedStores(
        Map<Id, Set<Id>> parentWorkOrderIdToSelectedStoreAccountIds
    ) {
        String message;
        List<WorkOrder> parentWorkOrders = WorkOrdersSelector.newInstance()
            .selectById(parentWorkOrderIdToSelectedStoreAccountIds.keySet());
        List<Account> filteredAccounts = filterStoreAccountsByProducts(
            parentWorkOrderIdToSelectedStoreAccountIds,
            parentWorkOrders
        );
        WorkOrdersCreationService.createChildWorkOrdersOnStoreAccounts(
            parentWorkOrders[0],
            filteredAccounts
        );
        if (!isEmptyOrNull(storeIdsWithoutBundledProducts)) {
            message = System.Label.StoreWithoutBundledProductsErrorMessage;
        }
        return message;
    }

    /**
     * @description It collects business/franchise parent Accounts' hierarchy
     * from the passed parent Ids till bottom.
     * @JIRA# LEM-3672
     * @param parentField
     * @param topParentIds
     */
    private void fetchParentAccountsHierarchy(
        Schema.SObjectField parentField,
        Set<Id> topParentIds
    ) {
        Boolean fetchRecursively = true;
        Set<Id> currentParentIds = topParentIds;
        // To avoid infinite recursion due to last returned parent Ids
        if (this.lastReturnedParentIds.equals(topParentIds)) {
            this.lastReturnedParentIds.clear();
        }
        do {
            currentParentIds = new Set<Id>(getChildParentAccountIds(parentField, currentParentIds));
            currentParentIds.remove(null);
            this.parentIds.addAll(currentParentIds);
            if (currentParentIds.isEmpty()) {
                fetchRecursively = false;
            } else if (isLimitExceeded()) {
                fetchRecursively = false;
                this.lastReturnedParentIds.addAll(currentParentIds);
            }
        } while (fetchRecursively);
    }

    /**
     * @description It collects the Products purchased for given store Accounts.
     * @JIRA# LEM-2132
     * @param parentWorkOrderIdToStoreAccountIds
     * @param parentWorkOrders
     * @return List<Account>
     */
    private List<Account> filterStoreAccountsByProducts(
        Map<Id, Set<Id>> parentWorkOrderIdToStoreAccountIds,
        List<WorkOrder> parentWorkOrders
    ) {
        Set<Id> storeAccountIds = new Set<Id>();
        for (Id eachParentWorkOrderId : parentWorkOrderIdToStoreAccountIds.keySet()) {
            storeAccountIds.addAll(parentWorkOrderIdToStoreAccountIds.get(eachParentWorkOrderId));
        }
        Map<Id, Account> storesToProcess = new Map<Id, Account>(
            AccountsSelector.newInstance().selectAccountsWithParentDetailsById(storeAccountIds)
        );
        Map<Id, Boolean> storeAccountIdToHasBundledProducts = OrderItemsService.getStoresWithBundledOrderProducts(
            OrderItemsSelector.newInstance()
                .selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    storeAccountIds,
                    WORK_ORDER_TYPES
                )
        );
        for (WorkOrder eachWorkOrder : parentWorkOrders) {
            // Parent Work Order has Storefront Bundled Work Plan
            if (
                eachWorkOrder.Type__c == WORK_ORDER_TYPE_STOREFRONT &&
                eachWorkOrder.Bundled_with_Marketplace__c == BUNDLED_WITH_MARKETPLACE_YES
            ) {
                for (
                    Id eachStoreAccountId : parentWorkOrderIdToStoreAccountIds.get(eachWorkOrder.Id)
                ) {
                    /* Check whether the store Account has Marketplace & Storefront products sold
                     * together.
                     */
                    if (!storeAccountIdToHasBundledProducts.containsKey(eachStoreAccountId)) {
                        storeIdsWithoutBundledProducts.add(eachStoreAccountId);
                        storesToProcess.remove(eachStoreAccountId);
                    }
                }
            }
        }
        return storesToProcess.values();
    }
    /**
     * @description It fetches business Account Ids from the passed set of Ids
     * @JIRA# LEM-3672
     * @param parentField
     * @param parentIds
     * @return Set<Id>
     */
    private Set<Id> getChildParentAccountIds(Schema.SObjectField parentField, Set<Id> parentIds) {
        Map<Id, Account> childParentAccounts = new Map<Id, Account>(
            AccountsSelector.newInstance().selectBusinessAccountsByParentIds(parentField, parentIds)
        );
        return childParentAccounts.keySet();
    }

    /**
     * @description It checks whether Query rows & SOQL limits exceeded.
     * @JIRA# LEM-3672
     * @return Boolean
     */
    private Boolean isLimitExceeded() {
        return (Limits.getLimitQueries() - Limits.getQueries()) < queriesAllowedLimit ||
            (Limits.getLimitQueryRows() - Limits.getQueryRows()) < queryRowsAllowedLimit ||
            (Limits.getLimitCpuTime() - Limits.getCpuTime()) < 500;
    }

    /**
     * @description It create an instance of AddStoresContainer using the required values.
     * @JIRA# LEM-3672
     * @return AddStoresContainer
     */
    private AddStoresContainer getParentWrapper() {
        AddStoresContainer parentWrapper = new AddStoresContainer(
            new List<Id>(parentIds),
            storeAccountWrappers
        );
        parentWrapper.lastReturnedParentIds = new List<Id>(this.lastReturnedParentIds);
        return parentWrapper;
    }

    /**
     * @description It validates the passed Work Order segment is SMB and Type is either "Ads & Promos" or Sub-Type is "Rate Change".
     * @param workOrderToEvaluate
     * @return Boolean
     */
    private Boolean isEligibleWorkOrderTypeSubTypeToSkipOpenMarketplaceWorkOrderValidation(
        WorkOrder workOrderToEvaluate
    ) {
        Boolean isWorkOrderEligible = true;
        if (
            workOrderToEvaluate.Segment__c == SEGMENT_SMB &&
            WORK_ORDER_TYPES_SUBTYPE_TO_SKIP_IN_PROGRESS_MARKETPLACE_WORK_ORDER_VALIDATION_FOR_SMB.contains(
                workOrderToEvaluate.Type__c + workOrderToEvaluate.Sub_Type__c
            )
        ) {
            isWorkOrderEligible = false;
        }
        return !WORK_ORDER_TYPES_TO_SKIP_IN_PROGRESS_MARKETPLACE_WO_VALIDATION.contains(
                (workOrderToEvaluate.Type__c)
            ) && isWorkOrderEligible;
    }
}