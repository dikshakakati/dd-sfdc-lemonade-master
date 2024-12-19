/**
 * @author deloitte
 * @date 26/03/2024
 * @description Class to get data for the Manage Pricing Upload Screen lightning component.
 */
public with sharing class ManagePricingUploadScreenController {
    @testVisible
    private static final String ACCOUNT_HIERARCHY_EXCEPTION = 'The following Store accounts are not in the account hierarchy. ';
    @testVisible
    private static final String ACCOUNT_WITHOUT_AGREEMENT_EXCEPTION = 'Please upload accounts which have active agreement on this contract. ';
    @testVisible
    private static final String BUSINESS_ACCOUNT_EXCEPTION = 'The following accounts are Business accounts, Please only upload store accounts. ';

    public static final Map<String, String> INVALID_KEY_TO_ERROR_MESSAGE_PREFIX = new Map<String, String>{
        'INVALID_ACCOUNTS_IN_HIERARCHY' => ACCOUNT_HIERARCHY_EXCEPTION,
        'INVALID_ACCOUNTS_WITHOUT_ACTIVE_AGREEMENT' => ACCOUNT_WITHOUT_AGREEMENT_EXCEPTION,
        'INVALID_ACCOUNTS_OF_BUSINESS_RECORD_TYPE' => BUSINESS_ACCOUNT_EXCEPTION
    };

    private static final String ACCOUNT_RECORDTYPE_CHANNEL_PARTNER = 'Channel_Partner';
    @testVisible
    private static final String ACCOUNT_RECORDTYPE_BUSINESS = 'Business';

    /**
     * @description Get Associated Accounts
     * @param accountIds
     * @param parentId
     * @return List<Account>
     */
    @AuraEnabled
    public static List<Account> selectNonAssociatedAccountsById(
        List<String> accountIds,
        String parentId
    ) {
        return selectNonAssociatedAccountsByAccountId(accountIds, parentId);
    }

    /**
     * @description Get Associated Store Accounts
     * @param storeIds
     * @param parentId
     * @return List<Account>
     */
    @AuraEnabled
    public static List<Account> selectNonAssociatedAccountsByStoreId(
        List<String> storeIds,
        String parentId
    ) {
        List<Xref__c> xrefs = XrefsSelector.newInstance().selectXrefByExternalId(storeIds);
        List<String> accountIds = new List<String>();
        accountIds.addAll(getXrefsAccounts(xrefs));
        return selectNonAssociatedAccountsByAccountId(accountIds, parentId);
    }

    /**
     * @description Get Associated Business Accounts
     * @param businessIds
     * @param parentId
     * @return List<Account>
     */
    @AuraEnabled
    public static List<Account> selectNonAssociatedAccountsByBusinessId(
        List<String> businessIds,
        String parentId
    ) {
        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectXrefByBusinessReferenceExternalId(businessIds);
        List<String> accountIds = new List<String>();
        accountIds.addAll(getXrefsAccounts(xrefs));
        return selectNonAssociatedAccountsByAccountId(accountIds, parentId);
    }

    private static Set<String> getXrefsAccounts(List<Xref__c> xrefs) {
        set<String> accounIdSet = new Set<String>();
        for (Xref__c xref : xrefs) {
            accounIdSet.add(xref.Salesforce_Account_Name__c);
        }
        return accounIdSet;
    }

    private static List<Account> selectNonAssociatedAccountsByAccountId(
        List<String> accountIds,
        String parentId
    ) {
        try {
            SObject parentSObj = getParent(parentId);
            Id parentAccountId = (ID) parentSObj.get('AccountId');

            Map<String, List<Account>> invalidAccountsByCriteria = new Map<String, List<Account>>();
            List<Account> accounts = AccountsSelector.newInstance()
                .selectAccountsWithParentDetailsById(new Set<Id>((List<Id>) accountIds));
            // validate the Accounts
            invalidAccountsByCriteria = validateAccounts(accounts, parentAccountId, parentSObj);
            String errorMessage = getErrorMessage(invalidAccountsByCriteria);
            // throw exception if inValid accounts are present in the csv file upload
            if (String.isNotBlank(errorMessage)) {
                errorMessage = +errorMessage;
                throw new ManageStoresException(errorMessage);
            }
            List<Account> returnList = new List<Account>();

            if (!accountIds.isEmpty()) {
                returnList = AccountsSelector.newInstance()
                    .selectById(new Set<Id>((List<Id>) accountIds));
            }
            return returnList;
        } catch (Exception ex) {
            if (Test.isRunningTest()) {
                throw new ManageStoresException(ex.getMessage());
            } else {
                throw new AuraHandledException(ex.getMessage());
            }
        }
    }

    /**
     * @description Check the accounts for (AccountHierarchy, InCoverage, Address Verification)
     * (InCoverage, Address Verification)Only applies to SObject = WorkOder and Type__c != 'POS'
     * @param accounts
     * @param parentAccountId
     * @param parentSObj
     * @return List<Account>
     */
    private static Map<String, List<Account>> validateAccounts(
        List<Account> accounts,
        Id parentAccountId,
        SObject parentSObj
    ) {
        Map<String, List<Account>> invalidAccountsByCriteria = new Map<String, List<Account>>();
        Id parentId = parentSobj.Id;

        // checking for accounts are in Hierarchy
        invalidAccountsByCriteria.put(
            'INVALID_ACCOUNTS_IN_HIERARCHY',
            validateAccountHierarchy(accounts, parentAccountId, parentSobj)
        );

        // checking if accounts should be of store record type only
        invalidAccountsByCriteria.put(
            'INVALID_ACCOUNTS_OF_BUSINESS_RECORD_TYPE',
            validateAccountsForStoreRecordType(accounts)
        );

        // checking if accounts have active agreement on the contract
        invalidAccountsByCriteria.put(
            'INVALID_ACCOUNTS_WITHOUT_ACTIVE_AGREEMENT',
            validateAccountsForActiveAgreement(accounts, parentId)
        );

        return invalidAccountsByCriteria;
    }

    /**
     * @description Check if accounts have active agreement with the contract
     * @param accounts
     * @param parentId
     * @return List<Account>
     */
    private static List<Account> validateAccountsForActiveAgreement(List<Account> accounts, Id parentId) {
        List<Account> invalidAccounts = new List<Account>();
        Set<Id> activeAgreementAccountIds = getAllActiveAgreementAccountIdsForContract(accounts, parentId);

        // Check each account for active agreements and mark them as invalid
        for (Account acct : accounts) {
            if (!activeAgreementAccountIds.contains(acct.id)){
                invalidAccounts.add(acct);
            }
        }
        return invalidAccounts;
    }

    /**
     * @description Retrieves a set of active agreement Account IDs associated with the uploaded Accounts and contract.
     * @param uploadedAccounts List of uploaded Accounts.
     * @param contractId Id of current contract
     * @return Set<Id> Set of active agreement Account IDs.
     * JIRA : LEM-11329
     */
    private static Set<Id> getAllActiveAgreementAccountIdsForContract(
        List<Account> uploadedAccounts,
        Id contractId
    ) {
        Set<Id> activeAgreementAccountIds = new Set<Id>();
        Set<Id> uploadedAccountIds = new Set<Id>();
        for (Account accountRec : uploadedAccounts) {
            uploadedAccountIds.add(accountRec.Id);
        }
        List<Agreement__c> agreementsList = AgreementsSelector.newInstance()
            .selectActiveAgreementsByAccountContractIds(uploadedAccountIds, contractId);
        for (Agreement__c agreementRec : agreementsList) {
            if (uploadedAccountIds.contains(agreementRec.Account__c)) {
                activeAgreementAccountIds.add(agreementRec.Account__c);
            }
        }
        return activeAgreementAccountIds;
    }

    /**
     * @description Check if accounts have active agreement with the contract
     * @param accounts
     * @return List<Account>
     */
    private static List<Account> validateAccountsForStoreRecordType(List<Account> accounts) {
        List<Account> invalidAccounts = new List<Account>();

        // Check each account for business record type and mark them as invalid
        for (Account acct : accounts) {
            if (acct.Recordtype.Name == ACCOUNT_RECORDTYPE_BUSINESS){
                invalidAccounts.add(acct);
            }
        }
        return invalidAccounts;
    }

    /**
     * @description get the error message for invalid accounts
     * @param invalidAccountsByCriteria
     * @return errorMessage
     */
    private static String getErrorMessage(Map<String, List<Account>> invalidAccountsByCriteria) {
        String errorMessage = '';
        for (String invalidKey : invalidAccountsByCriteria.keyset()) {
            if (invalidAccountsByCriteria.get(invalidKey).size() > 0) {
                errorMessage =
                    errorMessage +
                    INVALID_KEY_TO_ERROR_MESSAGE_PREFIX.get(invalidKey) +
                    getInvalidAccountsString(invalidAccountsByCriteria.get(invalidKey)) +
                    '\n';
            }
        }
        return errorMessage;
    }

    private static String getInvalidAccountsString(List<Account> invalidAccounts) {
        String accountIdString = '';
        for (Account acc : invalidAccounts) {
            if (accountIdString != '') {
                accountIdString += ', ';
            }
            accountIdString += String.valueOf(acc.Id);
        }
        return accountIdString;
    }

    @testVisible
    private static List<Account> validateAccountHierarchy(
        List<Account> accounts,
        Id parentAccountId,
        SObject parentSobj
    ) {
        List<Account> invalidAccounts = new List<Account>();
        //LEM-4772 Re: ManageStores on contract object; channel Partners can add accounts from outside of the Hierarchy
        Schema.SObjectType parentSObjectType = parentSobj.getSObjectType();
        SObject accountObj = parentSObj.getSObject('Account');
        Boolean canSkipHierarchyValidation =
            parentSObjectType == Contract.SObjectType &&
            accountObj != null &&
            accountObj.get('Record_Type_Name__c') != null &&
            accountObj.get('Record_Type_Name__c') == ACCOUNT_RECORDTYPE_CHANNEL_PARTNER;

        if (canSkipHierarchyValidation) {
            return invalidAccounts;
        }
        for (Account accnt : accounts) {
            if (
                parentSObjectType == Contract.SObjectType &&
                accnt.Recordtype.Name == ACCOUNT_RECORDTYPE_BUSINESS
            ) {
                continue;
            }
            Set<Id> parentAccountIds = new Set<Id>();
            parentAccountIds.add(accnt.ParentId);
            parentAccountIds.add(accnt.Parent.ParentId);
            parentAccountIds.add(accnt.Parent.Parent.ParentId);
            parentAccountIds.add(accnt.Parent.Parent.Parent.ParentId);
            parentAccountIds.add(accnt.Parent.Parent.Parent.Parent.ParentId);
            parentAccountIds.add(accnt.Parent.Parent.Parent.Parent.Parent.ParentId);
            if ((!parentAccountIds.contains(parentAccountId)) && (accnt.Id != parentAccountId)) {
                invalidAccounts.add(accnt);
            }
        }
        return invalidAccounts;
    }

    /**
     * @description private function to retrieve parent Info for a given parent Id.
     * @param parentId
     * @return String
     */
    private static SObject getParent(String parentId) {
        List<SObject> parentList;
        SObjectType parentType = Id.valueOf(parentId).getSObjectType();

        If(parentId != null) {
            parentList = ContractsSelector.newInstance().selectById(new Set<Id>{ Id.valueOf(parentId) });
        }
        return parentList.isEmpty() ? parentType.newSObject() : parentList[0];
    }

    private class ManageStoresException extends Exception {
    }
}