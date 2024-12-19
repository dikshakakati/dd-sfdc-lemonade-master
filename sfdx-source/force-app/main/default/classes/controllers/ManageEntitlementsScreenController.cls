/**
 * @author deloitte
 * @date 12/18/2023
 * @description Class to get data for the Manage Pricing lightning component.
 * JIRA @ LEM-11556
 */
public with sharing class ManageEntitlementsScreenController {
    @testVisible
    private static final String ACCOUNT_RECORDTYPE_BUSINESS = 'Business';
    private static final String CCP_READONLY_SELECTED_PACKAGES = 'CCP_Readonly_Selected_Packages';
    private static final Set<String> ELIGIBLE_WORK_ORDER_PROVISIONING_STATUS = new Set<String>{
        'Not Started'
    };
    private static final List<String> PRODUCT_LIST = new List<String>{
        'Dashpass',
        'Delivery',
        'Pickup'
    };
    private static final String SEGMENT_SMB = 'SMB';
    private static final Map<String, String> SUBSCRIPTION_PACKAGE_TO_WORKORDER_TYPE = new Map<String, String>{
        'Marketplace' => 'Marketplace',
        'Storefront' => 'Storefront',
        'Large Order Fulfillment (LOF)' => 'Drive',
        'Small Order Fulfillment (SOF)' => 'Drive'
    };
    @testVisible
    private static final String WORKORDER_EXCEPTION_START = System.label.Manage_Stores_work_order_exception_start;
    private static final String WORKORDER_EXCEPTION_END = System.label.Manage_Stores_work_order_exception_end;
    private static Boolean isSMBBusinessAccount;

    /**
     * @description Selects existing subscriptions with group information.
     * @param mapofSelectedAccounts Comma-separated String of selected account Ids
     * @param contractId Contract Id
     * @return List of ManageEntitlementsSelectionWrapper
     * JIRA @ LEM-11556
     */
    @AuraEnabled(cacheable=true)
    public static List<ManageEntitlementsSelectionWrapper> selectExistingSubscriptionsWithGroup(
        String mapofSelectedAccounts,
        Id contractId
    ) {
        Map<String, List<Id>> mapGroupIdAccountIds = new Map<String, List<Id>>();
        Id groupId = getGroupIdbyContract(contractId);
        mapGroupIdAccountIds.put(groupId, mapofSelectedAccounts.split(','));
        return buildEntitlementsSelectionWrapper(groupId, mapGroupIdAccountIds);
    }

    private static List<ManageEntitlementsSelectionWrapper> buildEntitlementsSelectionWrapper(
        Id groupId,
        Map<String, List<Id>> mapGroupIdAccountIds
    ) {
        List<ManageEntitlementsSelectionWrapper> groupWrapperList = new List<ManageEntitlementsSelectionWrapper>();
        try {
            List<SBQQ__Subscription__c> subsList = getSubscriptionRecordsByGroup(
                new List<Id>{ groupId }
            );
            Map<String, List<SBQQ__Subscription__c>> collectSubscriptionByGroup = groupSubscriptionsByGroup(
                subsList
            );
            for (String groups : collectSubscriptionByGroup.keySet()) {
                List<ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper> packageWrapperList = buildPackageSelectionWrapper(
                    collectSubscriptionByGroup.get(groupId)
                );
                groupWrapperList.add(
                    new ManageEntitlementsSelectionWrapper(
                        groups,
                        mapGroupIdAccountIds.get(groups),
                        packageWrapperList
                    )
                );
            }
            groupWrapperList = sortPackageList(groupWrapperList);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return groupWrapperList;
    }

    /**
     * @description Groups subscriptions by group
     * @param returnList - Subscription List
     * @return Map<String, List<SBQQ__Subscription__c>> A mapping of subscription groups to a list of subscriptions
     * JIRA @ LEM-11556
     */
    private static Map<String, List<SBQQ__Subscription__c>> groupSubscriptionsByGroup(
        List<SBQQ__Subscription__c> returnList
    ) {
        Map<String, List<SBQQ__Subscription__c>> collectSubscriptionByGroup = new Map<String, List<SBQQ__Subscription__c>>();
        for (SBQQ__Subscription__c subs : returnList) {
            String subsGroup = subs.Quote_Line_Group__c;
            if (!collectSubscriptionByGroup.containsKey(subsGroup)) {
                collectSubscriptionByGroup.put(subsGroup, new List<SBQQ__Subscription__c>{ subs });
            } else {
                collectSubscriptionByGroup.get(subsGroup).add(subs);
            }
        }
        return collectSubscriptionByGroup;
    }

    /**
     * @description Groups subscriptions by package and builds a wrapper for package selection
     * @param subscriptions List<SBQQ__Subscription__c> - List of subscriptions
     * @return List<ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper> A list of package selection wrappers
     * JIRA @ LEM-11556
     */
    private static List<ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper> buildPackageSelectionWrapper(
        List<SBQQ__Subscription__c> subscriptions
    ) {
        List<ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper> packageWrapperList = new List<ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper>();
        Map<Id, SBQQ__Subscription__c> mapPackageIdDetail = getPackageIdandDetailsMap(
            subscriptions
        );
        for (Id packageId : mapPackageIdDetail.keySet()) {
            String packageName = mapPackageIdDetail.get(packageId).SBQQ__ProductName__c;
            String productNameMap = SUBSCRIPTION_PACKAGE_TO_WORKORDER_TYPE.get(packageName);
            Boolean subsIsSelectionEnabled = mapPackageIdDetail.get(packageId)
                .SBQQ__Product__r.Package_Eligible_For_Entitlement__c;
            packageWrapperList.add(
                new ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper(
                    packageId,
                    packageName,
                    subsIsSelectionEnabled,
                    getSubscriptionsForPackage(packageId, subscriptions),
                    evaluateDrivePackage(productNameMap)
                )
            );
        }
        return packageWrapperList;
    }

    /**
     * @description Groups subscriptions by package and builds a wrapper for package selection
     * @param @param packageId
     * @param subscriptions List<SBQQ__Subscription__c> - List of subscriptions
     * @return List<SBQQ__Subscription__c> A list of package selection wrappers
     * JIRA @ LEM-11556
     */
    private static List<SBQQ__Subscription__c> getSubscriptionsForPackage(
        Id packageId,
        List<SBQQ__Subscription__c> subscriptions
    ) {
        List<SBQQ__Subscription__c> packageSubscriptions = new List<SBQQ__Subscription__c>();
        for (SBQQ__Subscription__c groupSubs : subscriptions) {
            if (
                groupSubs.SBQQ__RequiredById__c == packageId &&
                PRODUCT_LIST.contains(groupSubs.SBQQ__ProductName__c) &&
                groupSubs.SBQQ__ProductOption__r.Product_Eligible_For_Entitlement__c
            ) {
                packageSubscriptions.add(groupSubs);
            }
        }
        return packageSubscriptions;
    }

    /**
     * @description Retrieves a map of packageId and corresponding subscription details
     * @param subscriptionList List<SBQQ__Subscription__c> - List of subscriptions
     * @return Map<Id, SBQQ__Subscription__c> - A mapping of packageId to subscription details
     * JIRA @ LEM-11556
     */
    @AuraEnabled
    public static Map<Id, SBQQ__Subscription__c> getPackageIdandDetailsMap(
        List<SBQQ__Subscription__c> subscriptionList
    ) {
        Map<Id, SBQQ__Subscription__c> mapPackageIdDetail = new Map<Id, SBQQ__Subscription__c>();
        Map<Id, List<SBQQ__Subscription__c>> mapPackageSubscription = new Map<Id, List<SBQQ__Subscription__c>>();
        for (SBQQ__Subscription__c eachSub : subscriptionList) {
            if (
                eachSub.SBQQ__RequiredById__c == null &&
                !mapPackageSubscription.containsKey(eachSub.Id) &&
                eachSub.SBQQ__Product__r.Package_Eligible_For_Entitlement__c
            ) {
                mapPackageSubscription.put(eachSub.Id, new List<SBQQ__Subscription__c>());
                mapPackageIdDetail.put(eachSub.Id, eachSub);
            }
        }
        return mapPackageIdDetail;
    }

    /**
     * @description Retrieves all subscriptions associated with a contract
     * @param contractId Id - The Id of the contract
     * @return List<SBQQ__Subscription__c> - A list of subscription records
     * JIRA @ LEM-11556
     */
    @AuraEnabled
    public static List<SBQQ__Subscription__c> getAllSubscriptionFromContract(Id contractId) {
        Id groupId = getGroupIdbyContract(contractId);
        List<SBQQ__Subscription__c> returnList = getSubscriptionRecordsByGroup(
            new List<Id>{ groupId }
        );
        return returnList;
    }

    /**
     * @description Retrieves the group Id associated with a contract's subscription
     * @param contractId Id - The Id of the contract
     * @return Id - The Id of the subscription group
     * JIRA @ LEM-11556
     */
    @AuraEnabled
    public static Id getGroupIdbyContract(Id contractId) {
        Id groupId;
        try {
            groupId = SubscriptionSelector.newInstance()
                .selectQuoteLineGroupOnSubscription(contractId);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return groupId;
    }

    /**
     * @description Processes data from the submit button.
     * @param mapofSelectedSubscriptions Serialized JSON string containing subscription data
     * @param parentId Parent Id is the contractId
     * @param ccpApplied Boolean if user has modified product/package selection/deselection
     * JIRA @ LEM-11556
     */
    @AuraEnabled
    public static void processSubmitButtonData(
        String mapofSelectedSubscriptions,
        String parentId,
        Boolean ccpApplied
    ) {
        AssociatedAccountsWrapper[] wrappers = (List<AssociatedAccountsWrapper>) JSON.deserialize(
            mapofSelectedSubscriptions,
            List<AssociatedAccountsWrapper>.class
        );
        Contracts.newInstance(new List<Contract>{ new Contract(Id = parentId) })
            .setAssociatedAccountsWithGroups(wrappers, ccpApplied, 'No');
    }

    /**
     * @description Creates a content version from a given file's base64 and name
     * @param base64
     * @param filename filename - full file name with extension, i.e. 'products.csv'
     * @param recordId - Id of the record you want to attach this file to
     * JIRA @ LEM-11556
     */
    @AuraEnabled
    public static void uploadFile(String base64, String filename, Id recordId) {
        try {
            ContentVersionService.createContentVersion(base64, filename, recordId);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description If the resppective package work order is not present then raising an exception
     * @param mapofSelectedAccounts String - Comma-separated String of selected account Ids
     * @param contractId String - Contract Id
     * @param selectedPackages List<String> - List of selected package Ids
     * @param resultVariableToBooleanMap Boolean - Indicates varaible and result
     * JIRA @ LEM-11830
     */
    @AuraEnabled
    public static void selectWorkOrdersByAccountId(
        String mapofSelectedAccounts,
        String contractId,
        List<String> selectedPackages,
        String resultVariableToBooleanMap
    ) {
        try {
            ResultVariableWrapper booleanWrapper = (ResultVariableWrapper) JSON.deserialize(
                resultVariableToBooleanMap,
                ResultVariableWrapper.class
            );
            List<Id> storeIds = mapofSelectedAccounts.split(',');
            String workOrderErrorPackages = '';
            Set<Id> selectedPackagesIdsSet = new Set<Id>();
            selectedPackagesIdsSet.addAll((List<Id>) selectedPackages);
            isSMBBusinessAccount = false;
            List<Contract> contractList = ContractsSelector.newInstance()
                .selectById(new Set<Id>{ Id.valueOf(contractId) });

            List<Account> uploadedAccountDetails = AccountsSelector.newInstance()
                .selectAccountsWithParentDetailsById(new Set<Id>(storeIds));

            List<Account> franchiseeStoreAccounts = AccountsSelector.newInstance()
                .selectFranchiseeStoreAccountsById(new Set<Id>(storeIds));

            if (areFranchiseeStores(franchiseeStoreAccounts, uploadedAccountDetails)) {
                return;
            }

            Boolean isBusinessAccount = isBusinessAccount(uploadedAccountDetails);
            if(isSMBBusinessAccount){
                return;
            }

            Map<String, String> workOrderTypeAndSubTypesMap = workOrderMapping(
                new Set<Id>{ (ID) ContractList[0].get('AccountId') }
            );
            List<SBQQ__Subscription__c> subscriptionPackageList = new List<SBQQ__Subscription__c>();

            subscriptionPackageList = SubscriptionSelector.newInstance()
                .querySubscriptionRecords(selectedPackagesIdsSet);

            //Method for work order logic check
            CcpWorkOrderValidationsService ccpService = new CcpWorkOrderValidationsService();
            workOrderErrorPackages = ccpService.validateWorkOrders(
                subscriptionPackageList,
                workOrderTypeAndSubTypesMap,
                isBusinessAccount,
                booleanWrapper
            );
            if (String.isBlank(workOrderErrorPackages)) {
                return;
            }
            handleWorkOrderErrors(workOrderErrorPackages);
        } catch (Exception ex) {
            if (Test.isRunningTest()) {
                throw new ManageEntitlementsScreenControllerException(ex.getMessage());
            } else {
                throw new AuraHandledException(ex.getMessage());
            }
        }
    }

    private static void handleWorkOrderErrors(String workOrderErrorPackages) {
        String errorMessage =
            WORKORDER_EXCEPTION_START +
            ' "' +
            workOrderErrorPackages +
            '" ' +
            WORKORDER_EXCEPTION_END;
        throw new ManageEntitlementsScreenControllerException(errorMessage);
    }

    private static boolean areFranchiseeStores(
        List<Account> franchiseeStoreAccounts,
        List<Account> uploadedAccountDetails
    ) {
        return !franchiseeStoreAccounts.isEmpty() &&
            franchiseeStoreAccounts.size() == uploadedAccountDetails.size();
    }

    private static List<ManageEntitlementsSelectionWrapper> sortPackageList(
        List<ManageEntitlementsSelectionWrapper> wrapperList
    ) {
        for (ManageEntitlementsSelectionWrapper wrapper : wrapperList) {
            bubbleSort(wrapper.packageList);
        }

        return wrapperList;
    }

    private static void bubbleSort(
        List<ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper> packageList
    ) {
        Integer n = packageList.size();

        for (Integer i = 0; i < n - 1; i++) {
            for (Integer j = 0; j < n - i - 1; j++) {
                ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper a = packageList[
                    j
                ];
                ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper b = packageList[
                    j + 1
                ];

                // Compare based on custom criteria
                if (compare(a, b) > 0) {
                    // Swap elements
                    packageList[j] = b;
                    packageList[j + 1] = a;
                }
            }
        }
    }

    private static Integer compare(
        ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper a,
        ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper b
    ) {
        // Compare based on the existence of subsList and the count of elements in subsList
        Boolean hasSubsA = hasSubsList(a);
        Boolean hasSubsB = hasSubsList(b);

        // Ensure products with packages come first
        if (hasSubsA && !hasSubsB) {
            return -1;
        } else if (!hasSubsA && hasSubsB) {
            return 1;
        }

        Integer numSubsA = hasSubsA ? getNumSubsListElements(a) : 0;
        Integer numSubsB = hasSubsB ? getNumSubsListElements(b) : 0;

        return numSubsB - numSubsA;
    }

    private static Boolean hasSubsList(
        ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper pkg
    ) {
        return pkg.subsList != null && !pkg.subsList.isEmpty();
    }

    private static Integer getNumSubsListElements(
        ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper pkg
    ) {
        return pkg.subsList != null ? pkg.subsList.size() : 0;
    }
    /**
     * @description calculates all the uploaded accounts are business ids or not.
     * @param uploadedAccountsList
     * @return Set<Id>
     * JIRA @ LEM-11830
     */
    private static Boolean isBusinessAccount(List<Account> uploadedAccountsList) {
        Boolean isBusinessAccount = false;
        Integer businessCount = 0;
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> smbBusinessAccountIds = new Set<Id>();

        for(Account eachAccount : uploadedAccountsList){
            accountIdSet.add(eachAccount.Id);
            // @JIRA# LEM-20322 - Collecting SMB Business Account Ids
            if(eachAccount.Segment__c == SEGMENT_SMB){
                smbBusinessAccountIds.add(eachAccount.Id);
            }
        }
        if(smbBusinessAccountIds.size() > 0){
            isSMBBusinessAccount = true;
        }

        // Utilize the selector to fetch count of bussiness accounts
        Aggregate[] businessAccountsCount = AccountsSelector.newInstance()
            .selectCountOfAccounts(accountIdSet);
        if (businessAccountsCount != null && businessAccountsCount.size() > 0) {
            businessCount = (Integer) businessAccountsCount[0].get('accountIdCount');
        }

        if (businessCount == accountIdSet.size()) {
            isBusinessAccount = true;
        }
        return isBusinessAccount;
    }

    /**
     * @description Retrieves the mapping of work order types to their subtypes for a given set of parent account IDs
     * @param parentAccountIdSet Set<Id> - Set of parent account IDs
     * @return Map<String, String> - Mapping of work order types to their subtypes
     * JIRA @ LEM-11830
     */
    private static Map<String, String> workOrderMapping(Set<Id> parentAccountIdSet) {
        Map<String, String> workOrderTypeAndSubTypesMap = new Map<String, String>();
        List<WorkOrder> workorderList = new List<WorkOrder>();
        workorderList = WorkOrdersSelector.newInstance().selectByAccountIds(parentAccountIdSet);
        //collect the workorder type which are in "not started" status.
        if (workorderList.isEmpty()) {
            return workOrderTypeAndSubTypesMap;
        }
        for (WorkOrder workOrderRec : workorderList) {
            if (ELIGIBLE_WORK_ORDER_PROVISIONING_STATUS.contains(workOrderRec.Provisioning_Status__c)) {
                workOrderTypeAndSubTypesMap.put(workOrderRec.Type__c, workOrderRec.Sub_Type__c);
            }
        }
        return workOrderTypeAndSubTypesMap;
    }

    /**
     * @description Get list of susbscriptions using group id
     * @param groupIdList
     * @return List<SBQQ__Subscription__c>
     * JIRA @ LEM-11556
     */
    @AuraEnabled
    public static List<SBQQ__Subscription__c> getSubscriptionRecordsByGroup(List<Id> groupIdList) {
        List<SBQQ__Subscription__c> returnList = new List<SBQQ__Subscription__c>();
        try {
            returnList = SubscriptionSelector.newInstance()
                .selectSubscriptionRecordsByGroup(groupIdList);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return returnList;
    }

    /**
     * @description Evaluates whether the product belongs to a drive package
     * @param productNameMap String - The product name map
     * @return Boolean - True if the product belongs to a drive package, otherwise false
     * JIRA @ LEM-11556
     */
    @AuraEnabled
    public static Boolean evaluateDrivePackage(String productNameMap) {
        Boolean checkDrivePackage = false;
        if (productNameMap != null) {
            Static_Configurations__mdt ccpReadonlyPackages = Static_Configurations__mdt.getInstance(
                CCP_READONLY_SELECTED_PACKAGES
            );
            checkDrivePackage = ccpReadonlyPackages.Configuration_Value__c.contains(productNameMap)
                ? true
                : false;
        }
        return checkDrivePackage;
    }

    /**
     * @description The ResultVariableWrapper class is a container for boolean flags indicating different processing states.
     * It facilitates the transfer of multiple state variables in a structured and organized manner.
     * JIRA @LEM-14852
     */
    public class ResultVariableWrapper {
        /**
         * @description Indicates whether the system is currently processing existing accounts.
         * This flag can be used to trigger or control logic related to existing account records.
         * @type Boolean
         */
        public Boolean isProcessingExistingAccounts { get; set; }
        /**
         * @description Indicates whether the system is processing both new accounts and COO (Chief Operating Officer) packages.
         * This flag is useful for workflows or operations that handle both new account onboarding and COO-specific processes.
         * @type Boolean
         */
        public Boolean isProcessingNewAndCoo { get; set; }
        /**
         * @description Indicates whether the system is processing only COO (Chief Operating Officer) packages.
         * This flag can be used to trigger or control logic that exclusively deals with COO-related operations, bypassing new account processing.
         * @type Boolean
         */
        public Boolean isProcessingOnlyCoo { get; set; }
        /**
         * @description Indicates whether the system is processing only new accounts.
         * This flag is useful for workflows or operations that are focused solely on the onboarding of new accounts, without involving any COO-specific logic.
         * @type Boolean
         */
        public Boolean isProcessingOnlyNew { get; set; }

        /**
         * @description Constructor
         * @param isProcessingExistingAccounts
         * @param isProcessingNewAndCoo
         * @param isProcessingOnlyCoo
         * @param isProcessingOnlyNew
         */
        public ResultVariableWrapper(
            Boolean isProcessingExistingAccounts,
            Boolean isProcessingNewAndCoo,
            Boolean isProcessingOnlyCoo,
            Boolean isProcessingOnlyNew
        ) {
            this.isProcessingExistingAccounts = isProcessingExistingAccounts;
            this.isProcessingNewAndCoo = isProcessingNewAndCoo;
            this.isProcessingOnlyCoo = isProcessingOnlyCoo;
            this.isProcessingOnlyNew = isProcessingOnlyNew;
        }
    }

    private class ManageEntitlementsScreenControllerException extends Exception {
    }
}