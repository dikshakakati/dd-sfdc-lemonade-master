/**
 * @author Deloitte
 * @date 11/13/2023
 * @description Controller class to manage Corporate Account Hierarchy component.
 */
public with sharing class CorporateAccountHierarchyController {
    private final static String MARKETPLACE = 'Marketplace';
    private final static String DRIVE = 'Drive';
    private final static String MDS_XREF = 'MDS';
    private final static String DRIVEDB_XREF = 'DriveDB';
    private final static String FILTER_CRITERIA_KEY = 'filterCriteria';
    private static final String KEY_TYPE_NO_FILTER = 'No Filter';
    private static final String KEY_TYPE_WITH_FILTER = 'With Filter';
    private final static String BRAND_CRITERIA_KEY = 'brands';
    private final static String VERTICAL_CRITERIA_KEY = 'verticals';
    private final static String PRODUCT_CRITERIA_KEY = 'products';
    private final static String BRAND_CRITERIA = 'Salesforce_Account_Name__r.Brand__r.Name IN: brands';
    private final static String VERTICAL_CRITERIA = 'Salesforce_Account_Name__r.Primary_Vertical__c IN: verticals';
    private final static String PRODUCT_CRITERIA = 'External_ID_Source__c IN: products';
    private final static String BLANK_CHECK = '';
    private static final String SEPARATOR = System.Label.Separator;
    private enum KeyTypes {
        NO_FILTER,
        WITH_FILTER
    }
    private static final Map<String, KeyTypes> KEYTYPESMAPPING = new Map<String, KeyTypes>{
        KEY_TYPE_NO_FILTER => KeyTypes.NO_FILTER,
        KEY_TYPE_WITH_FILTER => KeyTypes.WITH_FILTER
    };
    private static final Map<String, String> EXTERNAL_ID_SOURCE_MAPPING = new Map<String, String>{
        MARKETPLACE => MDS_XREF,
        DRIVE => DRIVEDB_XREF
    };
    private static String allBrands;
    private static String allVerticals;
    private static String allProducts;
    /**
     * @description It is used to fetch the Ultimate Parent Account by the current AccountId.
     * @param accountId
     * @return Account
     */
    @AuraEnabled(Cacheable=true)
    public static Account getUltimateParentAccount(String accountId) {
        if (accountId == null || String.isBlank(accountId)) {
            return null;
        }
        Account currentAccount = AccountsSelector.newInstance()
            .getUltimateParentAccount(new Set<String>{ accountId })[0];
        if (currentAccount.Ultimate_Parent_Account__c == null) {
            return currentAccount;
        }
        return AccountsSelector.newInstance()
            .getUltimateParentAccount(
                new Set<String>{ currentAccount.Ultimate_Parent_Account__c }
            )[0];
    }

    /**
     * @description It is used to get the brands and verticals values to display filtering options.
     * @param ultimateParentAccountId
     * @return List<FilterCriteria>
     */
    @AuraEnabled
    public static List<FilterCriteria> getBrandsAndVerticals(Id ultimateParentAccountId) {
        Set<String> storeBrands = new Set<String>();
        Set<String> storeVerticals = new Set<String>();
        FilterCriteria brandsAndVerticals = new FilterCriteria();
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectByUltimateParentAccountsForBrandsAndVerticals(
                    new Set<Id>{ ultimateParentAccountId }
                )
        ) {
            storeBrands.add(eachXref.Salesforce_Account_Name__r.Brand__r.Name);
            storeVerticals.add(eachXref.Salesforce_Account_Name__r.Primary_Vertical__c);
        }
        brandsAndVerticals.brands.addAll(storeBrands);
        brandsAndVerticals.verticals.addAll(storeVerticals);
        return new List<FilterCriteria>{ brandsAndVerticals };
    }

    /**
     * @description To get selected account details
     * @param recordId
     * @return List<Account>
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountDetails(Id recordId) {
        try {
            List<Id> recordIds = new List<Id>{ recordId };
            Set<String> fieldNames = new Set<String>();
            List<String> selectedAccountsFields = new List<String>{
                'Id',
                'RecordType.DeveloperName',
                'ParentId',
                'Parent.ParentId',
                'Parent.Parent.ParentId',
                'Parent.Parent.Parent.ParentId',
                'Ultimate_Parent_Account__c'
            };
            fieldNames.addAll(selectedAccountsFields);
            return (List<Account>) Security.stripInaccessible(
                    AccessType.READABLE,
                    AccountsSelector.newInstance().selectFilteredAccount(fieldNames, recordIds)
                )
                .getRecords();
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(
                System.Label.Failed_Retrieve_Account
            );
            ex.setMessage(System.Label.Failed_Retrieve_Account);
            throw ex;
        }
    }

    private static Map<String, List<String>> generateFilterCondition(
        String brands,
        String verticals,
        String products
    ) {
        String filterCriteria = '';
        Map<String, List<String>> keysToValues = new Map<String, List<String>>();
        keysToValues.put(FILTER_CRITERIA_KEY, new List<String>());
        if (brands != null && brands != BLANK_CHECK) {
            filterCriteria = BRAND_CRITERIA;
            keysToValues.get(FILTER_CRITERIA_KEY).add(filterCriteria);
            keysToValues.put(BRAND_CRITERIA_KEY, brands.split(SEPARATOR));
        }
        if (verticals != null && verticals != BLANK_CHECK) {
            filterCriteria = VERTICAL_CRITERIA;
            keysToValues.get(FILTER_CRITERIA_KEY).add(filterCriteria);
            keysToValues.put(VERTICAL_CRITERIA_KEY, verticals.split(SEPARATOR));
        }
        if (products != null && products != BLANK_CHECK) {
            filterCriteria = PRODUCT_CRITERIA;
            keysToValues.get(FILTER_CRITERIA_KEY).add(filterCriteria);
            Set<String> productsFromSearchKey = new Set<String>();
            for (String eachProductFilter : products.split(SEPARATOR)) {
                productsFromSearchKey.add(EXTERNAL_ID_SOURCE_MAPPING.get(eachProductFilter));
            }
            keysToValues.put(PRODUCT_CRITERIA_KEY, new List<String>(productsFromSearchKey));
        }
        return keysToValues;
    }

    /**
     * @description It is used to generate Corporate Hierarchy for a single level.
     * @param businessAccounts
     * @param parentIds
     * @param keyType
     * @return List<BusinessAccount>
     */
    public static List<BusinessAccount> getHierarchy(
        List<Account> businessAccounts,
        Set<Id> parentIds,
        String keyType
    ) {
        try {
            Map<Id, BusinessAccount> idToBusinessAccount = new Map<Id, BusinessAccount>();
            for (Account eachAccount : businessAccounts) {
                if (!idToBusinessAccount.containsKey(eachAccount.Id)) {
                    idToBusinessAccount.put(eachAccount.Id, new BusinessAccount(eachAccount));
                }
            }
            return mapStoresInHierarchy(idToBusinessAccount, parentIds, keyType).values();
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(
                System.Label.Failed_Retrieve_Child_Accounts
            );
            ex.setMessage(System.Label.Failed_Retrieve_Child_Accounts);
            throw ex;
        }
    }

    /**
     * @description To get child account records
     * @param recordIds
     * @param brands
     * @param verticals
     * @param products
     * @return List<BusinessAccount>
     */
    @AuraEnabled
    public static List<BusinessAccount> getChildAccounts(
        List<Id> recordIds,
        String brands,
        String verticals,
        String products
    ) {
        try {
            String keyType = KEY_TYPE_NO_FILTER;
            Set<String> fieldNames = new Set<String>();
            Set<Id> parentIds = new Set<Id>(recordIds);
            List<String> childAccountFields = new List<String>{
                'Id',
                'ParentId',
                'RecordType.developerName',
                'Name'
            };
            fieldNames.addAll(childAccountFields);
            if (brands != null || verticals != null || products != null) {
                keyType = KEY_TYPE_WITH_FILTER;
                allBrands = brands;
                allVerticals = verticals;
                allProducts = products;
            }
            return getHierarchy(
                (List<Account>) Security.stripInaccessible(
                        AccessType.READABLE,
                        AccountsSelector.newInstance()
                            .getCorporateAccountHierarchyByUltimateParentAccount(
                                fieldNames,
                                recordIds
                            )
                    )
                    .getRecords(),
                parentIds,
                keyType
            );
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(
                System.Label.Failed_Retrieve_Child_Accounts
            );
            ex.setMessage(System.Label.Failed_Retrieve_Child_Accounts);
            throw ex;
        }
    }

    private static Map<Id, BusinessAccount> mapStoresInHierarchy(
        Map<Id, BusinessAccount> idToBusinessAccount,
        Set<Id> parentIds,
        String keyType
    ) {
        Map<String, List<String>> keysToValues = new Map<String, List<String>>();
        List <Xref__c> xrefs = new List <Xref__c>();
        Set <Id> storeIds = new Set<Id>();
        Map <Id, Id> xrefToStoreId = new Map <Id,Id>();
        switch on KEYTYPESMAPPING.get(keyType) {
            when NO_FILTER {
                for (
                    Xref__c eachXref : XrefsSelector.newInstance().selectByStoreAccounts(parentIds)
                ) {
                    if (!xrefToStoreId.containsKey(eachXref.Id)) {
                        xrefs.add(eachXref);
                        storeIds.add(eachXref.Salesforce_Account_Name__c);
                        xrefToStoreId.put(eachXref.Id,eachXref.Salesforce_Account_Name__c);
                    }
                }
                idToBusinessAccount = CorporateAccountHierarchyController.getCoreContractsByStoreIds(storeIds, idToBusinessAccount, xrefs, xrefToStoreId);
            }
            when WITH_FILTER {
                keysToValues = generateFilterCondition(allBrands, allVerticals, allProducts);
                for (
                    Xref__c eachXref : XrefsSelector.newInstance()
                        .selectByStoreAccountsAndOtherFilters(parentIds, keysToValues)
                ) {
                    if (!xrefToStoreId.containsKey(eachXref.Id)) {
                        xrefs.add(eachXref);
                        storeIds.add(eachXref.Salesforce_Account_Name__c);
                        xrefToStoreId.put(eachXref.Id,eachXref.Salesforce_Account_Name__c);
                    }
                }
                idToBusinessAccount = CorporateAccountHierarchyController.getCoreContractsByStoreIds(storeIds, idToBusinessAccount, xrefs, xrefToStoreId);
            }
        }
        return idToBusinessAccount;
    }

    /**
     * @description It is used to get the Core Contracts associated with Store accounts.
     * @param storeIds
     * @param idToBusinessAccount
     * @param xrefs
     * @param xrefToStoreId
     * @return Map<Id, BusinessAccount>
     */
    private static Map<Id, BusinessAccount> getCoreContractsByStoreIds(
        Set<Id> storeIds,
        Map<Id, BusinessAccount> idToBusinessAccount,
        List <Xref__c> xrefs,
        Map <Id, Id> xrefToStoreId
    ) {
        Map <Id, List<Contract>> storeIdToContracts = new Map <Id, List<Contract>>();
        for(Agreement__c eachAgreement : AgreementsSelector.newInstance()
            .selectActiveAgreementsAndCoreContractsByStoreAccountIds(storeIds)){
                Contract newContract = new Contract( id = eachAgreement.Contract__c,
                Contract_Name__c = eachAgreement.Contract__r.ContractNumber);
                if(storeIdToContracts.containsKey(eachAgreement.Account__c)){
                  storeIdToContracts.get(eachAgreement.Account__c).add(newContract);
                }
                else{
                  storeIdToContracts.put(eachAgreement.Account__c,
                  new List<Contract>{newContract});
                }
        }
        for(Xref__c eachXref : xrefs){
            if (!idToBusinessAccount.containsKey(eachXref.Id)) {
                StoreAccount storeAccountWrapperInstance = new StoreAccount(eachXref,new List<Contract>{});
                if(xrefToStoreId.containsKey(eachXref.Id) && storeIdToContracts.containsKey(xrefToStoreId.get(eachXref.Id))){
                    storeAccountWrapperInstance.contracts = storeIdToContracts.get(xrefToStoreId.get(eachXref.Id));
                }
                idToBusinessAccount.put(eachXref.Id, new BusinessAccount(storeAccountWrapperInstance));
            }
        }
        return idToBusinessAccount;
    }

    /**
     * @description It is used to fetch the entire Hierarchy under the Ultimate Parent Account with
     * associated Contracts and Store information.
     * @param ultimateParentAccountId
     * @return List<BusinessAccount>
     */
    @AuraEnabled(Cacheable=true)
    public static List<BusinessAccount> getCorporateHierarchy(String ultimateParentAccountId) {
        Map<String, BusinessAccount> businessAccountsById = new Map<String, BusinessAccount>();
        return businessAccountsById.values();
    }

    /**
     * @author Deloitte
     * @date 12/07/2023
     * @description Inner Criteria object to wrap Brands and Verticals
     */
    public class FilterCriteria {
        @AuraEnabled
        public List<String> brands;

        @AuraEnabled
        public List<String> verticals;

        /**
         * @description  Constructor to set wrapper class variables.
         */
        public FilterCriteria() {
            brands = new List<String>();
            verticals = new List<String>();
        }
    }

    /**
     * @author Deloitte
     * @date 11/16/2023
     * @description Inner Account object to wrap related Xref, Contract, Store and Business Account
     * data.
     */
    public class BusinessAccount {
        /**
         * @description It is used to store the Business Account with associated Contracts and
         * Stores.
         */
        @AuraEnabled
        public Account businessAccount { get; set; }
        /**
         * @description It is used to store the associated Store Accounts.
         */
        @AuraEnabled
        public StoreAccount storeAccount { get; set; }
        /**
         * @description It is used to store the assocaited Contracts.
         */
        public Contract[] contracts { get; set; }
        /**
         * @description It is sued to store Payment Accounts associated with Business Accounts.
         */
        public Payment_Account__c[] paymentAccounts { get; set; }

        /**
         * @description Constructor to initialize Business Account.
         * @param businessAccount
         */
        public BusinessAccount(Account businessAccount) {
            this.businessAccount = businessAccount;
            this.contracts = businessAccount.Contracts == null
                ? new List<Contract>{}
                : businessAccount.Contracts;
            this.paymentAccounts = businessAccount.Payment_Accounts__r == null
                ? new List<Payment_Account__c>{}
                : businessAccount.Payment_Accounts__r;
        }

        /**
         * @description Constructor to initialize Store Account.
         * @param objStoreAccount
         */
        public BusinessAccount(StoreAccount objStoreAccount) {
            this.storeAccount = objStoreAccount;
        }
    }

    /**
     * @author Deloitte
     * @date 09/30/2024
     * @description Inner Account object to wrap related Contracts and Store Account
     * data.
     */
    public class StoreAccount {
        /**
         * @description It is used to store the associated Store Accounts.
         */
         @AuraEnabled
         public Xref__c storeAccount { get; set; }
         /**
         * @description It is used to store the associated Contracts.
         */
         @AuraEnabled
         public List <Contract> contracts { get; set; }
         /**
         * @description Constructor to initialize store Account.
         * @param storeAccount
         * @param contracts
         */
         public StoreAccount(Xref__c storeAccount, List <Contract> contracts){
             this.storeAccount = storeAccount;
             this.contracts = contracts;
         }
     }
}