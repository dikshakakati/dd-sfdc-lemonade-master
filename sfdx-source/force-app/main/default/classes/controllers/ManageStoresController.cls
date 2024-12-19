/**
 * @author atg
 * @date 05/03/2022
 * @description Class to get data for the Manage Stores lightning component.
 */
public with sharing class ManageStoresController {
    @testVisible
    private static final String ACCOUNT_HIERARCHY_EXCEPTION_START = 'The following Store or Business accounts are not in the account hierarchy. ';
    @testVisible
    private static final String ACCOUNT_COVERAGE_EXCEPTION_START = 'The following Store or Business accounts are not in Coverage. ';
    @testVisible
    private static final String STORES_WITHOUT_SERVICE_ERROR_MESSAGE = Label.Store_Validation_Error_Message;
    private static final String ACCOUNT_ADDRESS_VERIFICATION_EXCEPTION_START = 'The following Store or Business accounts Addresses are not verified. ';
    private static final String WORK_ORDER_TYPE_POS = 'POS';
    private static final String ACCOUNT_VERIFICATION_STATUS_VERIFIED = 'Verified';
    private static final String ACCOUNT_IN_COVERAGE = 'In Coverage';
    public static final Map<String, String> INVALID_KEY_TO_ERROR_MESSAGE_PREFIX = new Map<String, String>{
        'INVALID_ACCOUNTS_IN_HIERARCHY' => ACCOUNT_HIERARCHY_EXCEPTION_START,
        'INVALID_ACCOUNTS_IN_COVERAGE' => ACCOUNT_COVERAGE_EXCEPTION_START,
        'INVALID_ACCOUNTS_NOT_ADDRESS_VERIFIED' => ACCOUNT_ADDRESS_VERIFICATION_EXCEPTION_START,
        'INVALID_STORES_WITHOUT_SERVICE' => STORES_WITHOUT_SERVICE_ERROR_MESSAGE
    };

    private static final String ACCOUNT_EXCEPTION_END = '. Please review.';
    private static final String ACCOUNT_RECORDTYPE_CHANNEL_PARTNER = 'Channel_Partner';
    @testVisible
    private static final String ACCOUNT_RECORDTYPE_BUSINESS = 'Business';

    /**
     * @description Get Associated Accounts
     * @param parentId
     * @return List<Account>
     */
    @AuraEnabled
    public static List<Account> selectAssociatedAccounts(String parentId) {
        try {
            List<Account> returnList = new List<Account>();

            Set<Id> associatedAccountIds = getAssociatedAccountIdsForParent(parentId);
            if (!associatedAccountIds.isEmpty()) {
                returnList = AccountsSelector.newInstance().selectById(associatedAccountIds);
            }

            return returnList;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

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
            Set<Id> associatedAccountIds = getAssociatedAccountIdsForParent(parentId);
            Id parentAccountId = (ID) parentSObj.get('AccountId');

            Map<String, List<Account>> invalidAccountsByCriteria = new Map<String, List<Account>>();
            List<Account> accounts = AccountsSelector.newInstance()
                .selectAccountsWithParentDetailsById(new Set<Id>((List<Id>) accountIds));
            // validate the Accounts
            invalidAccountsByCriteria = validateAccounts(accounts, parentAccountId, parentSObj);
            String errorMessage = getErrorMessage(invalidAccountsByCriteria);
            // throw exception if inValid accounts are present in the csv file upload
            if (String.isNotBlank(errorMessage)) {
                errorMessage = +errorMessage + ACCOUNT_EXCEPTION_END;
                throw new ManageStoresException(errorMessage);
            }
            List<Account> returnList = new List<Account>();

            accountIds = associatedAccountIds.isEmpty()
                ? accountIds
                : removeAssociatedAccounts(associatedAccountIds, accountIds);

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
        Schema.SObjectType parentSObjectType = parentSobj.getSObjectType();
        Map<String, List<Account>> invalidAccountsByCriteria = new Map<String, List<Account>>();
        // checking for accounts are in Hierarchy
        invalidAccountsByCriteria.put(
            'INVALID_ACCOUNTS_IN_HIERARCHY',
            validateAccountHierarchy(accounts, parentAccountId, parentSobj)
        );
        // the Address Verification and In Coverage validations are applicable for SObject = WoKrOrder
        // and Type != POS parentSObjectType == Contract.SObjectType
        if (
            parentSObjectType == WorkOrder.SObjectType &&
            !WORK_ORDER_TYPE_POS.equals((String) parentSObj.get('Type__c'))
        ) {
            invalidAccountsByCriteria.put(
                'INVALID_ACCOUNTS_IN_COVERAGE',
                validateAccountsForInCoverage(accounts)
            );
            invalidAccountsByCriteria.put(
                'INVALID_ACCOUNTS_NOT_ADDRESS_VERIFIED',
                validateAccountsForAddressVerification(accounts)
            );
            invalidAccountsByCriteria.put(
                'INVALID_STORES_WITHOUT_SERVICE',
                new AddStoresOnWorkOrderServiceImpl()
                    .checkStoreAccounts((new Map<Id, SObject>(accounts)).keySet())
            );
        }
        return invalidAccountsByCriteria;
    }

    /**
     * @description Check the accounts Coverage = 'In Coverage'
     * Only applies to SObject = WorkOder and Type__c != 'POS'
     * @param accounts
     * @return List<Account>
     */
    private static List<Account> validateAccountsForInCoverage(List<Account> accounts) {
        List<Account> accountsNotInCoverage = new List<Account>();
        for (Account eachAccount : accounts) {
            if (!ACCOUNT_IN_COVERAGE.equals(eachAccount.Coverage__c)) {
                accountsNotInCoverage.add(eachAccount);
            }
        }
        return accountsNotInCoverage;
    }

    /**
     * @description Check the accounts AddressVerification Status = 'Verified'
     * Only applies to SObject = WorkOder and Type__c != 'POS'
     * @param accounts
     * @return List<Account>
     */
    private static List<Account> validateAccountsForAddressVerification(List<Account> accounts) {
        List<Account> accountsAddressNotVerified = new List<Account>();
        for (Account eachAccount : accounts) {
            if (
                !ACCOUNT_VERIFICATION_STATUS_VERIFIED.equals(
                    eachAccount.Address_Verification_Status__c
                )
            ) {
                accountsAddressNotVerified.add(eachAccount);
            }
        }
        return accountsAddressNotVerified;
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

    private static List<string> removeAssociatedAccounts(
        Set<Id> associatedAccountIds,
        List<String> accountIds
    ) {
        // Remove any Accounts that are already associated.
        for (Id associatedAccountId : associatedAccountIds) {
            Integer index = accountIds.indexOf(associatedAccountId);
            if (index >= 0) {
                accountIds.remove(index);
            }
        }
        return accountIds;
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
     * @description Save new Account Ids to be associated to a sobject.
     * @param parentId
     * @param accounts
     */
    @AuraEnabled
    public static void saveAssociatedAccounts(String parentId, String accounts) {
        try {
            String parentName = Id.valueOf(parentId).getSObjectType().getDescribe().getName();

            switch on parentName {
                when 'WorkOrder' {
                    WorkOrdersService.setAssociatedAccounts(
                        new Map<Id, String>{ parentId => accounts }
                    );
                }
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description private function to retrieve parent Info for a given parent Id.
     * @param parentId
     * @return String
     */
    private static SObject getParent(String parentId) {
        List<SObject> parentList;
        SObjectType parentType = Id.valueOf(parentId).getSObjectType();
        String parentName = parentType.getDescribe().getName();

        switch on parentName {
            when 'Contract' {
                parentList = ContractsSelector.newInstance()
                    .selectById(new Set<Id>{ Id.valueOf(parentId) });
            }
            when 'WorkOrder' {
                parentList = WorkOrdersSelector.newInstance()
                    .selectManageableById(new Set<Id>{ Id.valueOf(parentId) });
            }
        }
        return parentList.isEmpty() ? parentType.newSObject() : parentList[0];
    }

    /**
     * @description Converts a generic SObject ID to a Set<Id> of its related Account IDs
     * @param parentId
     * @return Set<Id>
     **/
    private static Set<Id> getAssociatedAccountIdsForParent(Id parentId) {
        Set<Id> accountIds = new Set<Id>();

        SObject parentSObj = getParent(parentId);
        String parentName = Id.valueOf(parentId).getSObjectType().getDescribe().getName();

        switch on parentName {
            when 'WorkOrder' {
                String associatedAccountsString = (String) parentSObj.get(
                    'Associated_Account_Ids__c'
                );

                if (!String.isBlank(associatedAccountsString)) {
                    List<String> associatedAccountIdList = associatedAccountsString.split(',');
                    accountIds = new Set<Id>((List<Id>) associatedAccountIdList);
                }
            }
        }

        return accountIds;
    }

    /**
     * @description Creates a content version from a given file's base64 and name
     * @param base64
     * @param filename filename - full file name with extension, i.e. 'products.csv'
     * @param recordId - Id of the record you want to attach this file to
     */
    @AuraEnabled
    public static void uploadFile(String base64, String filename, Id recordId) {
        try {
            ContentVersionService.createContentVersion(base64, filename, recordId);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    private class ManageStoresException extends Exception {
    }
}