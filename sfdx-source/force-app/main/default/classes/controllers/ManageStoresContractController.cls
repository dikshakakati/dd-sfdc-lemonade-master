/**
 * @author Deloitte
 * @date 10/18/2023
 * @description Class to communicate data for the Manage Stores contract ccp lightning web component.
 * JIRA : LEM-11329
 */
public inherited sharing class ManageStoresContractController {
    @testVisible
    private static final String ACCOUNT_HIERARCHY_EXCEPTION_START = System.Label.Manage_Stores_Account_Hierarchy_Exception;
    @testVisible
    private static final String EXISTING_ACCOUNT_EXCEPTION_ON_NEW_ACCOUNT = System.Label.Manage_Stores_Existing_Account_Exception_on_new_Account;
    @testVisible
    private static final String NEW_ACCOUNT_EXCEPTION_ON_EXISTING_ACCOUNT = System.Label.Manage_Stores_New_Accounts_exception_on_existing_stores;
    @testVisible
    private static final String COMBO_OF_BUSINESS_AND_STORE_ACCOUNTS_EXCEPTION = System.Label.Manage_stores_combo_of_new_and_existing_stores_exception;
    @testVisible
    private static final String INVALID_A_P_STORE_ASSOCIATION_EXCEPTION = System.Label.Invalid_A_P_Store_Association_Exception;

    public static final Map<String, String> INVALID_KEY_TO_ERROR_MESSAGE_PREFIX = new Map<String, String>{
        'INVALID_ACCOUNTS_IN_HIERARCHY' => ACCOUNT_HIERARCHY_EXCEPTION_START,
        'INVALID_EXISTING_ACCOUNTS_ON_NEW_ACCOUNTS' => EXISTING_ACCOUNT_EXCEPTION_ON_NEW_ACCOUNT,
        'INVALID_NEW_ACCOUNTS_ON_EXISTING_ACCOUNTS' => NEW_ACCOUNT_EXCEPTION_ON_EXISTING_ACCOUNT,
        'INVALID_COMBO_OF_BUSINESS_AND_STORE_ACCOUNTS' => COMBO_OF_BUSINESS_AND_STORE_ACCOUNTS_EXCEPTION,
        'INVALID_ASSOCIATION_A_P_STORE_ACCOUNTS' => INVALID_A_P_STORE_ASSOCIATION_EXCEPTION
    };

    private static final String ACCOUNT_RECORDTYPE_CHANNEL_PARTNER = 'Channel_Partner';
    @testVisible
    private static final String ACCOUNT_RECORDTYPE_BUSINESS = 'Business';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_CANCELLED = 'Cancelled';
    private static final String A_AND_P = 'A&P';

    public Set<Id> activeAgreementAccountIds;
    public Set<Id> cancelledAgreementAccountIds;
    public Boolean isCOOProcess;

    /**
     * @description Default constructor to instantiate variables.
     */
    public ManageStoresContractController() {
        this.activeAgreementAccountIds = new Set<Id>();
        this.cancelledAgreementAccountIds = new Set<Id>();
    }

    /**
     * @description Retrieves associated accounts for a given contract.
     * @param contractId The ID of the contract.
     * @return List<Account> The list of associated accounts.
     * JIRA : LEM-11329
     */
    @AuraEnabled
    public static List<Account> selectAssociatedAccounts(String contractId) {
        try {
            List<Account> associatedAccounts = new List<Account>();
            Set<Id> associatedAccountIds = ContractAssociatedAccountsServiceImpl.getAssociatedAccountIdsForContract(
                contractId
            );

            if (!associatedAccountIds.isEmpty()) {
                associatedAccounts = AccountsSelector.newInstance()
                    .selectById(associatedAccountIds);
            }

            return associatedAccounts;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Retrieves associated Store Accounts based on external Store IDs.
     * @param storeIds List of external Store IDs.
     * @param contractId ID of the Contract associated with the Accounts.
     * @param isProcessingExistingAccounts Flag indicating if existing Accounts are being processed.
     * @return List<Account> List of associated Store Accounts.
     * JIRA : LEM-11329
     */
    @AuraEnabled
    public static List<Account> selectAccountsByStoreId(
        List<String> storeIds,
        String contractId,
        Boolean isProcessingExistingAccounts
    ) {
        List<Xref__c> xrefs = XrefsSelector.newInstance().selectXrefByExternalId(storeIds);
        List<String> accountIds = new List<String>();
        accountIds.addAll(getXrefsAccounts(xrefs));
        return selectAccountsByAccountId(accountIds, contractId, isProcessingExistingAccounts);
    }
    /**
     * @description Retrieves associated Business Accounts based on external Business IDs.
     * @param businessIds List of external Business IDs.
     * @param contractId ID of the Contract associated with the Accounts.
     * @param isProcessingExistingAccounts Flag indicating if existing Accounts are being processed.
     * @return List<Account> List of associated Accounts.
     * JIRA : LEM-11329
     */
    @AuraEnabled
    public static List<Account> selectAccountsByBusinessId(
        List<String> businessIds,
        String contractId,
        Boolean isProcessingExistingAccounts
    ) {
        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectXrefByBusinessReferenceExternalId(businessIds);
        List<String> accountIds = getXrefsAccounts(xrefs);
        return selectAccountsByAccountId(accountIds, contractId, isProcessingExistingAccounts);
    }

    /**
     * @description Get Associated Accounts based on their IDs.
     * @param accountIds List of Account IDs.
     * @param contractId ID of the associated Contract.
     * @param isProcessingExistingAccounts Flag indicating if existing Accounts are being processed.
     * @return List<Account> List of associated Accounts.
     * JIRA : LEM-11329
     */
    @AuraEnabled
    public static List<Account> selectAccountsById(
        List<String> accountIds,
        String contractId,
        Boolean isProcessingExistingAccounts
    ) {
        return selectAccountsByAccountId(accountIds, contractId, isProcessingExistingAccounts);
    }

    /**
     * @description performs validation on all uploaded account IDs, and in the event of an error, it raises an exception.
     * @param accountIds List of Account IDs.
     * @param contractId ID of the associated Contract.
     * @param isProcessingExistingAccounts Flag indicating if existing Accounts are being processed.
     * @return List<Account> List of associated Accounts.
     * JIRA : LEM-11329
     */
    private static List<Account> selectAccountsByAccountId(
        List<String> accountIds,
        String contractId,
        Boolean isProcessingExistingAccounts
    ) {
        try {
            List<Contract> contractList = ContractsSelector.newInstance()
                .selectById(new Set<Id>{ Id.valueOf(contractId) });
            Id parentAccountIdFromContract = (ID) ContractList[0].get('AccountId');
            checkForNullStrings(accountIds);
            // Validate and process uploaded Account details
            processUploadedAccountDetailsAndValidates(
                accountIds,
                parentAccountIdFromContract,
                contractList[0],
                isProcessingExistingAccounts
            );
            List<Account> accountsList = AccountsSelector.newInstance()
                .selectById(new Set<Id>((List<Id>) accountIds));

            return accountsList;
        } catch (Exception ex) {
            if (Test.isRunningTest()) {
                throw new ManageStoresException(ex.getMessage());
            } else {
                throw new AuraHandledException(ex.getMessage());
            }
        }
    }

    /**
     * @description Process uploaded Account details, validate them, and throw an exception if necessary.
     * @param accountIds List of Account IDs.
     * @param parentAccountIdFromContract Parent Account ID from the associated Contract.
     * @param contract Associated Contract.
     * @param isProcessingExistingAccounts Flag indicating if existing Accounts are being processed.
     * JIRA : LEM-11329
     */
    private static void processUploadedAccountDetailsAndValidates(
        List<String> accountIds,
        Id parentAccountIdFromContract,
        Contract contract,
        Boolean isProcessingExistingAccounts
    ) {
        List<Account> uploadedAccountDetails = AccountsSelector.newInstance()
            .selectAccountsWithParentDetailsById(new Set<Id>((List<Id>) accountIds));

        // Validate the Accounts
        Map<String, List<Account>> invalidAccountsByCriteria = validateAccounts(
            uploadedAccountDetails,
            parentAccountIdFromContract,
            contract,
            isProcessingExistingAccounts
        );
        String errorMessage = getErrorMessage(invalidAccountsByCriteria);

        // Throw exception if invalid accounts are present in the CSV file upload
        if (String.isNotBlank(errorMessage)) {
            throw new ManageStoresException(errorMessage);
        }
    }

    /**
     * @description Retrieves a set of active and cancelled agreement Account IDs associated with the uploaded Accounts.
     * @param uploadedAccounts List of uploaded Accounts.
     * JIRA : LEM-11329
     */
    private void getSetOfActiveAgreementAccountIdsForContract(List<Account> uploadedAccounts) {
        Set<Id> uploadedAccountIds = new Set<Id>();
        for (Account accountRec : uploadedAccounts) {
            uploadedAccountIds.add(accountRec.Id);
        }

        List<Agreement__c> agreementsList = AgreementsSelector.newInstance()
            .selectActiveAndCancelledAgreementsByAccountIds(uploadedAccountIds);
        if (agreementsList.isEmpty()) {
            return;
        }
        for (Agreement__c agreementRec : agreementsList) {
            if (!uploadedAccountIds.contains(agreementRec.Account__c)) {
                return;
            }
            if (agreementRec.Status__c == STATUS_ACTIVE) {
                activeAgreementAccountIds.add(agreementRec.Account__c);
            } else if (agreementRec.Status__c == STATUS_CANCELLED) {
                cancelledAgreementAccountIds.add(agreementRec.Account__c);
            }
        }
    }

    /**
     * @description Validates accounts based on different criteria such as
     * Account Hierarchy, Business and Store combination and
     * checks for invalid accounts in the context of new or existing stores.
     * @param accounts List of accounts to validate.
     * @param parentAccountIdFromContract Parent account ID from the contract.
     * @param contractList Contract information.
     * @param isProcessingExistingAccounts Boolean flag indicating whether existing accounts are being processed.
     * @return Map<String, List<Account>> A map of different categories of invalid accounts.
     * JIRA : LEM-11329
     */
    private static Map<String, List<Account>> validateAccounts(
        List<Account> accounts,
        Id parentAccountIdFromContract,
        Contract contractList,
        Boolean isProcessingExistingAccounts
    ) {
        Map<String, List<Account>> invalidAccountsByCriteria = new Map<String, List<Account>>();
        // Validate accounts in the context of hierarchy
        invalidAccountsByCriteria.put(
            'INVALID_ACCOUNTS_IN_HIERARCHY',
            validateAccountHierarchy(accounts, parentAccountIdFromContract, contractList)
        );
        // Validate accounts for A&P Association if there is atleast a Core Contract Associated
        if(contractList.Contract_Split_Category__c == A_AND_P){
            invalidAccountsByCriteria.put(
                'INVALID_ASSOCIATION_A_P_STORE_ACCOUNTS',
                validateStoreAssociationForAPContracts(accounts,contractList)
            );
        }
        // Validate for an invalid combination of Business and Store accounts
        invalidAccountsByCriteria.put(
            'INVALID_COMBO_OF_BUSINESS_AND_STORE_ACCOUNTS',
            validateStoreAndBusinessAccounts(accounts)
        );
        // Validate accounts based on the processing of existing or new stores
        if (!isProcessingExistingAccounts) {
            invalidAccountsByCriteria.put(
                'INVALID_EXISTING_ACCOUNTS_ON_NEW_ACCOUNTS',
                validateExistingAccountsOnNewStoresAndNewAccountsOnExistingStores(
                    accounts,
                    isProcessingExistingAccounts
                )
            );
        } else {
            invalidAccountsByCriteria.put(
                'INVALID_NEW_ACCOUNTS_ON_EXISTING_ACCOUNTS',
                validateExistingAccountsOnNewStoresAndNewAccountsOnExistingStores(
                    accounts,
                    isProcessingExistingAccounts
                )
            );
        }

        return invalidAccountsByCriteria;
    }

    /**
     * @description Validates accounts based on the Account Hierarchy.
     * For Business accounts, the validation is skipped.
     * For Channel Partners adding accounts from outside the Hierarchy (LEM-4772),
     * the validation is skipped.
     *
     * @param accounts List of accounts to validate.
     * @param parentAccountIdFromContract Parent account ID from the contract.
     * @param contractRec Contract record.
     * @return List<Account> List of invalid accounts in the hierarchy.
     * JIRA : LEM-11329
     */
    @testVisible
    private static List<Account> validateAccountHierarchy(
        List<Account> accounts,
        Id parentAccountIdFromContract,
        Contract contractRec
    ) {
        List<Account> invalidAccounts = new List<Account>();
        //LEM-4772 Re: ManageStores on contract object; channel Partners can add accounts from outside of the Hierarchy
        SObject accountObj = contractRec.getSObject('Account');
        Boolean canSkipHierarchyValidation =
            accountObj != null &&
            accountObj.get('Record_Type_Name__c') != null &&
            accountObj.get('Record_Type_Name__c') == ACCOUNT_RECORDTYPE_CHANNEL_PARTNER;

        // Skip validation for Business accounts
        if (canSkipHierarchyValidation) {
            return invalidAccounts;
        }
        for (Account accnt : accounts) {
            if (accnt.Recordtype.Name == ACCOUNT_RECORDTYPE_BUSINESS) {
                continue;
            }
            // Check if the account is not in the hierarchy of the parent account from the contract
            Set<Id> parentAccountIds = new Set<Id>();
            parentAccountIds.add(accnt.ParentId);
            parentAccountIds.add(accnt.Parent.ParentId);
            parentAccountIds.add(accnt.Parent.Parent.ParentId);
            parentAccountIds.add(accnt.Parent.Parent.Parent.ParentId);
            parentAccountIds.add(accnt.Parent.Parent.Parent.Parent.ParentId);
            parentAccountIds.add(accnt.Parent.Parent.Parent.Parent.Parent.ParentId);
            if (
                (!parentAccountIds.contains(parentAccountIdFromContract)) &&
                (accnt.Id != parentAccountIdFromContract)
            ) {
                invalidAccounts.add(accnt);
            }
        }
        return invalidAccounts;
    }

    /**
     * @description Validates existing accounts on new stores based on active agreements.
     * If an account has an active agreement, it is considered invalid.
     * @param accounts List of accounts to validate.
     * @param isProcessingExistingAccounts
     * @return List<Account> List of invalid accounts with active agreements.
     * JIRA : LEM-11329
     */
    @testVisible
    private static List<Account> validateExistingAccountsOnNewStoresAndNewAccountsOnExistingStores(
        List<Account> accounts,
        Boolean isProcessingExistingAccounts
    ) {
        List<Account> invalidAccounts = new List<Account>();
        ManageStoresContractController controller = new ManageStoresContractController();
        controller.getSetOfActiveAgreementAccountIdsForContract(accounts);
        Set<Id> activeIds = controller.activeAgreementAccountIds;

        // Check each account for active agreements and mark them as invalid
        for (Account acct : accounts) {
            //New and COO
            if (activeIds.contains(acct.id) && !isProcessingExistingAccounts) {
                invalidAccounts.add(acct);
            }
            //Exisitng Stores
            else if (!activeIds.contains(acct.id) && isProcessingExistingAccounts) {
                invalidAccounts.add(acct);
            }
        }
        return invalidAccounts;
    }

    @testVisible
    private static List<Account> validateStoreAndBusinessAccounts(List<Account> accountsList) {
        List<Account> invalidAccounts = new List<Account>();
        Integer storeAccounts = 0;
        Integer businessAccounts = 0;
        for (Account accountRec : accountsList) {
            // Check the RecordType to distinguish between business and store accounts
            if (
                accountRec.RecordType != null &&
                accountRec.RecordType.Name == ACCOUNT_RECORDTYPE_BUSINESS
            ) {
                businessAccounts++;
            } else {
                storeAccounts++;
            }
        }
        // If both business and store accounts are present, add them to the invalid accounts list
        if (businessAccounts > 0 && storeAccounts > 0) {
            invalidAccounts.addAll(accountsList);
        }

        return invalidAccounts;
    }

     /**
     * @description Validates Store Accounts During A&P Contract Association.
     * If the uploaded store accounts doesnt have a Core Contract Association.
     * Return Error, Otherwise, the validation is skipped.
     *
     * @param accounts List of accounts to validate.
     * @param contractList Contract to validate.
     * @return List<Account> List of invalid accounts based on Core Contract Association.
     * JIRA : LEM-11329
     */
    @testVisible
    private static List<Account> validateStoreAssociationForAPContracts(
        List<Account> accounts,
        Contract contractList
    ) {
    	Set<Id> storeAccountIds = new Map<Id, Account>((List<Account>) accounts).keySet();
    	Set<Id> validStoreAccountIds = new Set<Id>();
    	Map<Id,Contract> contracts = new Map<Id,Contract>(ContractsSelector.newInstance().selectCoreContractsByAccountIds(new Set<Id>{contractList.accountId}));
  		for (Agreement__c eachAgreement : AgreementsSelector.newInstance().selectActiveAgreementsByCoreContractIds(contracts.keySet())) {
        if (storeAccountIds.contains(eachAgreement.Account__c)) {
              validStoreAccountIds.add(eachAgreement.Account__c);
        }
    	}
    	storeAccountIds.removeAll(validStoreAccountIds);
    	List<Account> invalidAccounts = AccountsSelector.newInstance()
            .selectAccountsWithParentDetailsById(storeAccountIds);
    	return invalidAccounts;
    }

    /**
     * @description Get the error message for invalid accounts
     * @param invalidAccountsByCriteria Map containing invalid accounts grouped by criteria
     * @return errorMessage Concatenated error messages for invalid accounts
     * JIRA : LEM-11329
     */
    private static String getErrorMessage(Map<String, List<Account>> invalidAccountsByCriteria) {
        String errorMessage = '';
        for (String invalidKey : invalidAccountsByCriteria.keySet()) {
            List<Account> invalidAccounts = invalidAccountsByCriteria.get(invalidKey);

            if (!invalidAccounts.isEmpty()) {
                String errorPrefix = INVALID_KEY_TO_ERROR_MESSAGE_PREFIX.get(invalidKey);
                errorMessage +=
                    errorPrefix +
                    ' ' +
                    getInvalidAccountsString(invalidAccountsByCriteria.get(invalidKey)) +
                    '\n';
            }
        }
        return errorMessage;
    }

    /**
     * @description Get a set of Salesforce Account IDs from a list of Xref__c records
     * @param xrefs List of Xref__c records
     * @return List of Salesforce Account IDs
     * JIRA : LEM-11329
     */
    private static List<String> getXrefsAccounts(List<Xref__c> xrefs) {
        List<String> accounIdSet = new List<String>();
        for (Xref__c xref : xrefs) {
            // Ensure that the Salesforce_Account_Name__c is not null before adding to the set
            if (xref.Salesforce_Account_Name__c != null) {
                accounIdSet.add(xref.Salesforce_Account_Name__c);
            }
        }
        return accounIdSet;
    }

    /**
     * @description Get a comma-separated string of invalid Account IDs
     * @param invalidAccounts List of invalid Account records
     * @return Comma-separated string of Account IDs
     * JIRA : LEM-11329
     */
    private static String getInvalidAccountsString(List<Account> invalidAccounts) {
        String accountIdString = '';
        for (Account acc : invalidAccounts) {
            if (!String.isBlank(accountIdString)) {
                accountIdString += ', ';
            }
            accountIdString += String.valueOf(acc.Id);
        }
        return accountIdString;
    }

    /**
     * @description Creates a content version from a given file's base64 and name
     * @param base64
     * @param filename filename - full file name with extension, i.e. 'products.csv'
     * @param recordId - Id of the record you want to attach this file to
     * JIRA : LEM-11329
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
     * @description Check for null or empty strings in a list of account IDs
     * @param accountIds List of account IDs
     * @throws ManageStoresException if any account ID is null or empty
     * JIRA : LEM-11329
     */
    public static void checkForNullStrings(List<String> accountIds) {
        if (accountIds != null) {
            for (String accountId : accountIds) {
                if (accountId == null || accountId == '' || String.isEmpty(accountId)) {
                    throw new ManageStoresException('Please provide the account ID in CSV.');
                }
            }
        }
    }

    /**
     * @description Determines whether all associated accounts for the given IDs
     * are exclusively business accounts.
     * @param accountIds List of SObject IDs to be evaluated
     * @return Boolean True if all accounts are business accounts, otherwise false
     * JIRA : LEM-11329
     */
    @AuraEnabled
    public static Boolean areAllBusinessAccounts(List<String> accountIds) {
        Boolean businessAccountsOnly = false;
        Integer businesscount = 0;
        List<Id> idList = new List<Id>((List<Id>) accountIds);
        Set<Id> accountIdSet = new Set<Id>(idList);
        // Ensure the input list is not null or empty
        checkForNullStrings(accountIds);
        // Utilize the selector to fetch count of bussiness accounts
        Aggregate[] businessAccountsCount = AccountsSelector.newInstance()
            .selectCountOfAccounts(accountIdSet);
        if (businessAccountsCount != null && businessAccountsCount.size() > 0) {
            businesscount = (Integer) businessAccountsCount[0].get('accountIdCount');
        }
        if (businesscount == accountIdSet.size()) {
            businessAccountsOnly = true;
        }
        //check count
        // Return the Boolean value indicating whether all accounts are business accounts
        return businessAccountsOnly;
    }

    /**
     * @description Determines whether all associated accounts for the given IDs
     * are processing COO or new Stores.
     * @param accountIds List of SObject IDs to be evaluated
     * @return Boolean True if all accounts are business accounts, otherwise false
     * JIRA : LEM-11329
     */
    @AuraEnabled
    public static Map<String, Boolean> calculateNewStoresAndCOO(List<String> accountIds) {
        Boolean isProcessingNewAndCoo = false;
        Boolean isProcessingOnlyCoo = false;
        Boolean isProcessingOnlyNew = false;
        List<Id> idList = new List<Id>((List<Id>) accountIds);
        Set<Id> accountIdSet = new Set<Id>(idList);
        Map<String, Boolean> resultMap = new Map<String, Boolean>();
        // Ensure the input list is not null or empty
        checkForNullStrings(accountIds);

        List<Agreement__c> agreementsList = AgreementsSelector.newInstance()
            .selectActiveAndCancelledAgreementsByAccountIds(accountIdSet);
        if (agreementsList.isEmpty()) {
            isProcessingOnlyNew = true;
        } else {
            Set<Id> fetchedCancelledAccountIdsSet = new Set<Id>();

            for (Agreement__c agreementRec : agreementsList) {
                if (
                    agreementRec.Status__c == STATUS_CANCELLED ||
                    (agreementRec.Deactivation_Date__c != null &&
                    agreementRec.Deactivation_Date__c <= system.today())
                ) {
                    fetchedCancelledAccountIdsSet.add(agreementRec.Account__c);
                }
            }

            Integer cooOnlyAccountCount = fetchedCancelledAccountIdsSet.size();
            if (cooOnlyAccountCount == accountIdSet.size()) {
                isProcessingOnlyCoo = true;
            } else if (cooOnlyAccountCount < accountIdSet.size() && cooOnlyAccountCount != 0) {
                isProcessingNewAndCoo = true;
            }
        }
        resultMap.put('isProcessingOnlyCoo', isProcessingOnlyCoo);
        resultMap.put('isProcessingOnlyNew', isProcessingOnlyNew);
        resultMap.put('isProcessingNewAndCoo', isProcessingNewAndCoo);
        return resultMap;
    }

    private class ManageStoresException extends Exception {
    }
}