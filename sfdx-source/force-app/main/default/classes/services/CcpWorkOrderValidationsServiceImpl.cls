/**
 * @author Deloitte
 * @date 5/2/2024
 * @description Service implementation class for cpWorkOrderValidations
 * LEM-11830
 */
public inherited sharing class CcpWorkOrderValidationsServiceImpl implements ICcpWorkOrderValidationsService {
    private enum MethodTypes {
        EXISTINGBUSINESSACCOUNTSDRIVE,
        EXISTINGSTOREACCOUNTSMARKETPLACE,
        EXISTINGSTOREACCOUNTSSTOREFRONT,
        NEWBUSINESSACCOUNTSDRIVE,
        NEWSTOREACCOUNTSMARKETPLACE,
        NEWSTOREACCOUNTSSTOREFRONT,
        NEWSTOREACCOUNTSCOO
    }
    private static final Map<String, MethodTypes> METHODNAMETOMETHODTYPES = new Map<String, MethodTypes>{
        'ExistingBusinessAccountsDrive' => MethodTypes.EXISTINGBUSINESSACCOUNTSDRIVE,
        'ExistingStoreAccountsMarketPlace' => MethodTypes.EXISTINGSTOREACCOUNTSMARKETPLACE,
        'ExistingStoreAccountsStorefront' => MethodTypes.EXISTINGSTOREACCOUNTSSTOREFRONT,
        'NewBusinessAccountsDrive' => MethodTypes.NEWBUSINESSACCOUNTSDRIVE,
        'NewStoreAccountsMarketPlace' => MethodTypes.NEWSTOREACCOUNTSMARKETPLACE,
        'NewStoreAccountsStorefront' => MethodTypes.NEWSTOREACCOUNTSSTOREFRONT,
        'NewStoreAccountsCOO' => MethodTypes.NEWSTOREACCOUNTSCOO
    };

    private static final Map<String, String> SUBSCRIPTION_PACKAGE_TO_WORKORDER_TYPE = new Map<String, String>{
        'Marketplace' => 'Marketplace',
        'Storefront' => 'Storefront',
        'Large Order Fulfillment (LOF)' => 'Drive',
        'Small Order Fulfillment (SOF)' => 'Drive',
        'COO' => 'COO'
    };
    String workOrderErrorPackages = '';
    List<SBQQ__Subscription__c> subscriptionPackageList;
    Map<String, String> workOrderTypeAndSubTypesMap;
    Boolean isBusinessAccount;
    Boolean isProcessingExistingAccounts;
    Boolean isProcessingNewAndCoo;
    Boolean isProcessingOnlyCoo;
    Boolean isProcessingOnlyNew;
    Map<String, SBQQ__Subscription__c> uniqueSubscriptionRefMap;
    Map<String, String> productNameAndWorkOrderTypeMap;
    @testVisible
    private static final String WORKORDER_EXCEPTION_START = 'There is an ongoing Work Order for these stores, please complete the provisioning process before proceeding or exclude the specific stores and retry Or There are no workorder for ';
    private static final String WORKORDER_EXCEPTION_END = '. Please Create and retry';
    private static final String MARKETPLACE_PACKAGE_NAME = 'Marketplace';
    private static final String POST_SALES_WORKORDER_TYPE = 'Post-Sales';
    private static final String CCP_READONLY_SELECTED_PACKAGES = 'CCP_Readonly_Selected_Packages';
    private static final List<string> PACKAGES_FOR_COO = new List<string>{ 'COO' };
    /**
     * @description Default Constructor to initialize class variables
     * LEM-11830
     */
    public CcpWorkOrderValidationsServiceImpl() {
        this.workOrderErrorPackages = '';
        this.subscriptionPackageList = new List<SBQQ__Subscription__c>();
        this.workOrderTypeAndSubTypesMap = new Map<String, String>();
        this.isBusinessAccount = false;
        this.isProcessingExistingAccounts = false;
        this.isProcessingNewAndCoo = false;
        this.isProcessingOnlyCoo = false;
        this.isProcessingOnlyNew = false;
        this.uniqueSubscriptionRefMap = new Map<String, SBQQ__Subscription__c>();
        this.productNameAndWorkOrderTypeMap = new Map<String, String>();
    }
    /**
     * @description validating a list of Salesforce Subscription records based on specified criteria
     * @param subscriptionPackageList - List of Salesforce Subscription records to be validated.
     * @param workOrderTypeAndSubTypesMap - Mapping of work order types to their subtypes.
     * @param isBusinessAccount - Flag indicating whether the current account is a business account.
     * @param booleanWrapper - Indicating Variables and values related
     * @return String - A string containing information about any encountered errors during validation.
     * LEM-11830
     */
    public String validateWorkOrders(
        List<SBQQ__Subscription__c> subscriptionPackageList,
        Map<String, String> workOrderTypeAndSubTypesMap,
        Boolean isBusinessAccount,
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper
    ) {
        List<CCP_Workorder_Validation__mdt> workOrderValidationChecks = CcpWorkOrderValidationsSelector.newInstance()
            .selectAllWorkOrderValidationRules();
        this.isProcessingExistingAccounts = booleanWrapper.isProcessingExistingAccounts;
        this.isProcessingNewAndCoo = booleanWrapper.isProcessingNewAndCoo;
        this.isProcessingOnlyCoo = booleanWrapper.isProcessingOnlyCoo;
        this.isProcessingOnlyNew = booleanWrapper.isProcessingOnlyNew;
        this.isBusinessAccount = isBusinessAccount;
        this.workOrderTypeAndSubTypesMap = workOrderTypeAndSubTypesMap;
        // Mapping the subscription package list
        subscriptionPackageListMapping(subscriptionPackageList);
        // Running validations based on retrieved rules
        runValidations(workOrderValidationChecks);
        // Returning a string containing information about any errors during validation
        return workOrderErrorPackages;
    }

    /**
     * @description Maps subscriptions to product names unique id.
     * @param subscriptionPackageList - List of Salesforce Subscription records to be mapped.
     * LEM-11830
     */
    public void subscriptionPackageListMapping(
        List<SBQQ__Subscription__c> subscriptionPackageList
    ) {
        if (isProcessingNewAndCoo) {
            processSubscriptionPackages(subscriptionPackageList);
            processCooPackages();
        } else if (isProcessingOnlyCoo) {
            processCooPackages();
        } else if (isProcessingOnlyNew || isProcessingExistingAccounts) {
            processSubscriptionPackages(subscriptionPackageList);
        }
    }

    private void processCooPackages() {
        for (String eachPackage : PACKAGES_FOR_COO) {
            String uniqueSubscriptionRefString = buildUniqueSubscriptionRefString(eachPackage);
            this.uniqueSubscriptionRefMap.put(uniqueSubscriptionRefString, null);
            this.productNameAndWorkOrderTypeMap.put(eachPackage, eachPackage);
        }
    }

    private void processSubscriptionPackages(List<SBQQ__Subscription__c> subscriptionPackageList) {
        for (SBQQ__Subscription__c eachSubscription : subscriptionPackageList) {
            String productName = eachSubscription.SBQQ__ProductName__c;
            String productNameMap = SUBSCRIPTION_PACKAGE_TO_WORKORDER_TYPE.get(productName);

            if (productNameMap != null) {
                Static_Configurations__mdt ccpReadonlyPackages = Static_Configurations__mdt.getInstance(
                    CCP_READONLY_SELECTED_PACKAGES
                );
                Boolean checkDrivePackage = ccpReadonlyPackages.Configuration_Value__c.contains(
                        productNameMap
                    )
                    ? true
                    : false;

                if (checkDrivePackage) {
                    productName = productNameMap;
                }
            }

            String uniqueSubscriptionRefString = buildUniqueSubscriptionRefString(productName);
            this.uniqueSubscriptionRefMap.put(uniqueSubscriptionRefString, eachSubscription);
            this.productNameAndWorkOrderTypeMap.put(productName, productNameMap);
        }
    }

    /**
     * @description Builds a unique reference string based on package name and validation checks metadata.
     *
     * @param productName - The name of the package.
     * @return String - A unique reference string.
     * LEM-11830
     */
    private String buildUniqueSubscriptionRefString(String productName) {
        return productName + this.isBusinessAccount + this.isProcessingExistingAccounts;
    }

    /**
     * @description Builds a unique reference string based on package name and validation checks metadata.
     *
     * @param packageName - The name of the package.
     * @param validationChecks - Metadata containing validation checks.
     * @return String - A unique reference string.
     * LEM-11830
     */
    private String buildMetadataUniqueReference(
        String packageName,
        CCP_Workorder_Validation__mdt validationChecks
    ) {
        return packageName +
            validationChecks.isBusinessAccount__c +
            validationChecks.isProcessingExistingAccounts__c;
    }

    /**
     * @description  Validates existing business accounts based on the provided work order validation checks.
     * @param workOrderValidationChecks
     * LEM-11830
     */
    private void validateExistingBusinessAccountsDrive(
        CCP_Workorder_Validation__mdt workOrderValidationChecks
    ) {
        String packageName = workOrderValidationChecks.Package_Name__c;
        String metadataUniqueReference = buildMetadataUniqueReference(
            packageName,
            workOrderValidationChecks
        );
        SBQQ__Subscription__c sub = uniqueSubscriptionRefMap.get(metadataUniqueReference);
        if (sub != null) {
            checkDriveWorkOrders(packageName, workOrderValidationChecks.Work_Order_SubType__c);
        }
    }

    /**
     * @description  Validates existing store accounts with the marketplace package based on the provided work order validation checks.
     * @param workOrderValidationChecks
     * LEM-11830
     */
    private void validateExistingStoreAccountsMarketPlace(
        CCP_Workorder_Validation__mdt workOrderValidationChecks
    ) {
        // Building a unique reference for the package
        String metadataUniqueReference = buildMetadataUniqueReference(
            workOrderValidationChecks.Package_Name__c,
            workOrderValidationChecks
        );
        // Retrieving subscription using the unique reference
        SBQQ__Subscription__c sub = uniqueSubscriptionRefMap.get(metadataUniqueReference);
        if (sub != null) {
            checkMarketplaceAndStorefrontWorkOrders(
                productNameAndWorkOrderTypeMap.get(workOrderValidationChecks.Package_Name__c)
            );
        }
    }

    /**
     * @description  Validates existing store accounts with the storefront package based on the provided work order validation checks.
     * @JIRA# LEM-1684
     * @param workOrderValidationChecks
     * LEM-11830
     */
    private void validateExistingStoreAccountsStorefront(
        CCP_Workorder_Validation__mdt workOrderValidationChecks
    ) {
        String metadataUniqueReference = buildMetadataUniqueReference(
            workOrderValidationChecks.Package_Name__c,
            workOrderValidationChecks
        );
        SBQQ__Subscription__c sub = uniqueSubscriptionRefMap.get(metadataUniqueReference);
        if (sub != null) {
            checkMarketplaceAndStorefrontWorkOrders(
                productNameAndWorkOrderTypeMap.get(workOrderValidationChecks.Package_Name__c)
            );
        }
    }

    /**
     * @description  Validates new business accounts based on the provided work order validation checks.
     * @JIRA# LEM-1684
     * @param workOrderValidationChecks
     * LEM-11830
     */
    private void validateNewBusinessAccountsDrive(
        CCP_Workorder_Validation__mdt workOrderValidationChecks
    ) {
        String packageName = workOrderValidationChecks.Package_Name__c;
        String metadataUniqueReference = buildMetadataUniqueReference(
            packageName,
            workOrderValidationChecks
        );
        SBQQ__Subscription__c sub = uniqueSubscriptionRefMap.get(metadataUniqueReference);
        if (sub != null) {
            checkDriveWorkOrders(packageName, workOrderValidationChecks.Work_Order_SubType__c);
        }
    }

    /**
     * @description  Validates new store accounts with the marketplace package based on the provided work order validation checks.
     * @param workOrderValidationChecks
     * LEM-11830
     */
    private void validateNewStoreAccountsMarketPlace(
        CCP_Workorder_Validation__mdt workOrderValidationChecks
    ) {
        String metadataUniqueReference = buildMetadataUniqueReference(
            workOrderValidationChecks.Package_Name__c,
            workOrderValidationChecks
        );
        SBQQ__Subscription__c sub = uniqueSubscriptionRefMap.get(metadataUniqueReference);
        if (sub != null || uniqueSubscriptionRefMap.KeySet().contains(metadataUniqueReference)) {
            checkMarketplaceAndStorefrontWorkOrders(
                productNameAndWorkOrderTypeMap.get(workOrderValidationChecks.Package_Name__c)
            );
        }
    }

    /**
     * @description  Validates new store accounts with the storefront package based on the provided work order validation checks.
     * @param workOrderValidationChecks
     * LEM-11830
     */
    private void validateNewStoreAccountsStorefront(
        CCP_Workorder_Validation__mdt workOrderValidationChecks
    ) {
        String metadataUniqueReference = buildMetadataUniqueReference(
            workOrderValidationChecks.Package_Name__c,
            workOrderValidationChecks
        );
        SBQQ__Subscription__c sub = uniqueSubscriptionRefMap.get(metadataUniqueReference);
        if (sub != null) {
            checkMarketplaceAndStorefrontWorkOrders(
                productNameAndWorkOrderTypeMap.get(workOrderValidationChecks.Package_Name__c)
            );
        }
    }

    /**
     * @description  Validates new store accounts with the marketplace package based on the provided work order validation checks.
     * @param workOrderValidationChecks
     * LEM-11830
     */
    private void validateNewStoreAccountsCOO(
        CCP_Workorder_Validation__mdt workOrderValidationChecks
    ) {
        String metadataUniqueReference = buildMetadataUniqueReference(
            workOrderValidationChecks.Package_Name__c,
            workOrderValidationChecks
        );

        //SBQQ__Subscription__c sub = uniqueSubscriptionRefMap.get(metadataUniqueReference);
        if (uniqueSubscriptionRefMap.KeySet().contains(metadataUniqueReference)) {
            checkCOOWorkOrders(
                productNameAndWorkOrderTypeMap.get(workOrderValidationChecks.Package_Name__c)
            );
        }
    }
    /**
     * @description Checks drive work orders based on the provided product name mapping and subtype.
     * @param productNameMap - Product name mapping associated with the subscription.
     * @param subType - Work order subtype to be checked.
     * LEM-11830
     */
    private void checkDriveWorkOrders(String productNameMap, String subType) {
        // Checking if the work order type and subtypes map is null or does not contain the product name mapping
        // or the provided subtype does not match the expected subtype
        if (
            workOrderTypeAndSubTypesMap == null ||
            !workOrderTypeAndSubTypesMap.containsKey(productNameMap) ||
            (subType != null && !workOrderTypeAndSubTypesMap.get(productNameMap).equals(subType))
        ) {
            logCheckFailurePackageNames(productNameMap);
        }
    }

    /**
     * @description Checks marketplace and storefront work orders based on the provided product name mapping.
     * @param packageName - Product name mapping associated with the subscription.
     * LEM-11830
     */
    private void checkMarketplaceAndStorefrontWorkOrders(String packageName) {
        String workOrderType;
        if (isProcessingExistingAccounts && packageName.equals(MARKETPLACE_PACKAGE_NAME)) {
            workOrderType = POST_SALES_WORKORDER_TYPE;
        } else {
            workOrderType = packageName;
        }
        // Checking if the work order type and subtypes map does not contain the product name mapping
        // and the product name mapping is not null or empty
        if (
            workOrderTypeAndSubTypesMap == null ||
            !workOrderTypeAndSubTypesMap.containsKey(workOrderType) &&
            !String.isBlank(workOrderType) && workOrderType.trim().length() > 0
        ) {
            logCheckFailurePackageNames(workOrderType);
        }
    }

    /**
     * @description Checks COO work orders based on the provided product name mapping.
     * @param packageName - Product name mapping associated with the subscription.
     * LEM-11830
     */
    private void checkCOOWorkOrders(String packageName) {
        String workOrderType;
        workOrderType = packageName;

        if (
            workOrderTypeAndSubTypesMap == null ||
            !workOrderTypeAndSubTypesMap.containsKey(workOrderType) &&
            !String.isBlank(workOrderType) && workOrderType.trim().length() > 0
        ) {
            logCheckFailurePackageNames(workOrderType);
        }
    }

    /**
     * @description Logs check failure for package names and updates the work order error packages.
     * @param productNameMap
     * LEM-11830
     */
    private void logCheckFailurePackageNames(String productNameMap) {
        // Updating the work order error packages based on the check failure
        workOrderErrorPackages = (workOrderErrorPackages == null ||
            workOrderErrorPackages.trim().length() == 0)
            ? productNameMap
            : workOrderErrorPackages + ', ' + productNameMap;
    }

    /**
     * @description Runs validations based on the provided list of work order validation checks.
     * @param workOrderValidationChecks - List of work order validation checks metadata.
     * LEM-11830
     */
    private void runValidations(List<CCP_Workorder_Validation__mdt> workOrderValidationChecks) {
        for (
            CCP_Workorder_Validation__mdt eachWorkOrderValidationChecks : workOrderValidationChecks
        ) {
            switch on METHODNAMETOMETHODTYPES.get(eachWorkOrderValidationChecks.Name__c) {
                when EXISTINGBUSINESSACCOUNTSDRIVE {
                    validateExistingBusinessAccountsDrive(eachWorkOrderValidationChecks);
                }
                when EXISTINGSTOREACCOUNTSMARKETPLACE {
                    validateExistingStoreAccountsMarketPlace(eachWorkOrderValidationChecks);
                }
                when EXISTINGSTOREACCOUNTSSTOREFRONT {
                    validateExistingStoreAccountsStorefront(eachWorkOrderValidationChecks);
                }
                when NEWBUSINESSACCOUNTSDRIVE {
                    validateNewBusinessAccountsDrive(eachWorkOrderValidationChecks);
                }
                when NEWSTOREACCOUNTSMARKETPLACE {
                    validateNewStoreAccountsMarketPlace(eachWorkOrderValidationChecks);
                }
                when NEWSTOREACCOUNTSSTOREFRONT {
                    validateNewStoreAccountsStorefront(eachWorkOrderValidationChecks);
                }
                when NEWSTOREACCOUNTSCOO {
                    validateNewStoreAccountsCOO(eachWorkOrderValidationChecks);
                }
            }
        }
    }

    private class CcpWorkOrderValidationsServiceImplException extends Exception {
    }
}