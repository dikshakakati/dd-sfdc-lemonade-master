/**
 * @description       :
 * @author            : Gaurav
 * @group             :
 * @last modified on  : 05-30-2024
 * @last modified by  : Gaurav
 **/
public inherited sharing class ContractsSummaryController {
    private static final String ENTERPRISE_FIELD_SET = 'Contract_Table_Mapping__mdt';
    private static final String SMB_FIELD_SET = 'SMB_Contract_Field_Set';
    private static final String OPPORTUNITY = 'Opportunity';
    private static final String ACCOUNT = 'Account';
    private static final String TYPE_REPORT = 'Report';
    private static final String AGGREGATE_CONTRACT_KEY = 'Contract__c';
    private static final String AGGREGATE_STORE_COUNT_KEY = 'agreementsCount';
    private static final Integer COUNT_ZERO = 0;
    private static final String MID_MARKET = 'Mid-Market';
    private static final String ADS_PROMOS = 'Ads & Promos';
    private static final String SPLIT_CATEGORY_AP = 'A&P';
    private static final String SPLIT_CATEGORY_CORE = 'Core';
    private static final String ACCOUNT_SEGEMENT_SMB = 'SMB';

    /**
     * @description It fetches custom metadata and map the rows and columns.
     * validates if the component initiated from account or opportunity, and based on record id populates the wrapper.
     * @param recordId
     * @return List<Contract>
     **/
    @AuraEnabled
    public static ContractDataWrapper getAllContracts(Id recordId) {
        Schema.SObjectType sobjectApiName = recordId.getsobjecttype();
        Schema.SObjectType accountObject = Schema.Account.getSObjectType();
        Schema.SObjectType opportunityObject = Schema.Opportunity.getSObjectType();

        ContractDataWrapper contractWrapper = new ContractDataWrapper();

        String accountId = '';
        if (sobjectApiName == opportunityObject) {
            List<Opportunity> oppList = OpportunitiesSelector.newInstance()
                .selectById(new Set<Id>{ recordId });
            if (!oppList.isEmpty() && oppList[0].AccountId != null) {
                accountId = oppList[0].AccountId;
                contractWrapper.recordDetails.addAll(oppList);
            }
            contractWrapper.initiatedFromSobject = OPPORTUNITY;
        } else if (sobjectApiName == accountObject) {
            accountId = recordId;
            contractWrapper.initiatedFromSobject = ACCOUNT;
        }

        List<Account> accounts = AccountsSelector.newInstance().selectById(new Set<Id>{accountId});

        // LEM-18324 if the segment is mid-market, then process it similar to enterprise accounts.
        contractWrapper.segment = accounts[0].Segment__c == MID_MARKET ? 'Enterprise' : accounts[0].Segment__c;
        if(sobjectApiName == accountObject){
            contractWrapper.recordDetails.addAll(accounts);
        }

        fetchContractDetails(contractWrapper, contractWrapper.segment, accountId);
        return contractWrapper;
    }

     /**
        List<Account> accounts = AccountsSelector.newInstance()
            .selectById(new Set<Id>{ accountId });

        contractWrapper.segment = accounts[0].Segment__c;
        if (sobjectApiName == accountObject) {
            contractWrapper.recordDetails.addAll(accounts);
        }
        fetchContractDetails(contractWrapper, accounts[0].Segment__c, accountId);
        return contractWrapper;
    }
    /**
     * @description It is used to fetch the subscription columns from Contract_Table_Mapping__mdt.
     * @param contractId
     * @param splitCategory
     * @return ContractDataWrapper
     **/
    @AuraEnabled
    public static ContractDataWrapper getAllSubscriptionColumns(
        Id contractId,
        String splitCategory
    ) {
        String splitCategoryValue = splitCategory == ADS_PROMOS
            ? SPLIT_CATEGORY_AP
            : SPLIT_CATEGORY_CORE;
        ContractDataWrapper contractWrapper = new ContractDataWrapper();

        fetchSubscriptionDetails(contractWrapper, ACCOUNT_SEGEMENT_SMB, splitCategoryValue);
        return contractWrapper;
    }

    /**
     * @description It is used to fetch  the merchant services columns from Contract_Table_Mapping__mdt.
     * @param businessAccountId
     * @return contractWrapper
     **/
    @AuraEnabled
    public static ContractDataWrapper getAllMerchantServicesColumns(Id businessAccountId) {
        ContractDataWrapper contractWrapper = new ContractDataWrapper();
        fetchMerchantServicesDetails(contractWrapper, ACCOUNT_SEGEMENT_SMB);
        return contractWrapper;
    }

    /**
     * @description It is used to return report Id.
     * @return REPORT_ID
     **/
    @AuraEnabled
    public static String getReportId() {
        return System.Label.ReportIDMXAgreed;
    }

    /**
     * @description It is used to fetch records related to merchant services columns based on the business account and contract.
     * @param businessAccountId
     * @param contractId
     * @return merchantServicesDetails
     **/
    @AuraEnabled
    public static List<Merchant_Service__c> getAllMerchantServicesDetails(
        Id businessAccountId,
        Id contractId
    ) {
        List<Merchant_Service__c> merchantServicesDetails = MerchantSelector.newInstance()
            .selectMerchantServiceToShowUnderContractsAmendment(businessAccountId, contractId);
        return merchantServicesDetails;
    }

    /**
     * @description Populates account field sets, It accept wrapper, customer segment and account id.
     * It fetches contract table mapping custom metadata and stores all the columns needs to be shown in the table.
     * @param contractWrapper
     * @param customerSegment
     * @param accountId
     */
    @TestVisible
    private static void fetchContractDetails(ContractDataWrapper contractWrapper,String customerSegment,Id accountId) {

         List<Contract_Table_Mapping__mdt> contractTableMappings = ContractTableMappingSelector.newInstance().selectContractTableMappingSortedByOrder(contractWrapper.initiatedFromSobject,customerSegment);
         Map<Id,Integer> contractVsStoreCount = new Map<Id,Integer>();
        contractWrapper.contractDataTableMap.addAll(contractTableMappings) ;

        for(Contract_Table_Mapping__mdt tableMapping : contractTableMappings ){
            if(tableMapping.Type__c == TYPE_REPORT){
                switch on tableMapping.Hyper_Link_Display_Field__c{
                    when 'storeCount'{
                         contractVsStoreCount = fetchStoresCount(accountID);
                    }
                }
            }
        }

        populateContracts(contractWrapper,accountId,contractVsStoreCount);
    }

    /**
        populateContracts(contractWrapper, accountId, contractVsStoreCount);
    }

    /**
     * @description Populates stores count.
     * @param accountId
     * @return Map<Id,Integer>
     */
    @TestVisible
    private static Map<Id,Integer> fetchStoresCount(Id accountId) {

        Map<Id,Integer> contractVsStoreCount = new Map<Id,Integer>();
        for(Aggregate aggResult :  AgreementsSelector.newInstance()
            .selectCountOfStoresAccountsByStoreAgreements(accountID)){
                contractVsStoreCount.put((ID) aggResult.get(AGGREGATE_CONTRACT_KEY),(Integer) aggResult.get(AGGREGATE_STORE_COUNT_KEY));
        }
        return contractVsStoreCount;
    }


     /**
    private static Map<Id, Integer> fetchStoresCount(Id accountId) {
        Map<Id, Integer> contractVsStoreCount = new Map<Id, Integer>();
        for (
            Aggregate aggResult : AgreementsSelector.newInstance()
                .selectCountOfStoresAccountsByStoreAgreements(accountID)
        ) {
            contractVsStoreCount.put(
                (ID) aggResult.get(AGGREGATE_CONTRACT_KEY),
                (Integer) aggResult.get(AGGREGATE_STORE_COUNT_KEY)
            );
        }
        return contractVsStoreCount;
    }
    /**
     * @description It is used to fetch the subscription columns based on the customer segment for SMB.
     * @param contractWrapper
     * @param customerSegment
     * @param splitCategory
     */
    private static void fetchSubscriptionDetails(
        ContractDataWrapper contractWrapper,
        String customerSegment,
        String splitCategory
    ) {
        List<Contract_Table_Mapping__mdt> contractTableMappings = ContractTableMappingSelector.newInstance()
            .selectSubscriptionObjectContractTableMappingsBySegmentAndApplicableProductsSortedByOrder(
                customerSegment,
                splitCategory
            );
        contractWrapper.contractDataTableMap.addAll(contractTableMappings);
    }

    /**
     * @description It fetches the merchant services columns based on the customer segment.
     * @param contractWrapper
     * @param customerSegment
     */
    private static void fetchMerchantServicesDetails(
        ContractDataWrapper contractWrapper,
        String customerSegment
    ) {
        List<Contract_Table_Mapping__mdt> contractTableMappings = ContractTableMappingSelector.newInstance()
            .selectMerchantServicesContractTableMappingByCustomerSegmentAndServiceObject(
                customerSegment
            );
        contractWrapper.contractDataTableMap.addAll(contractTableMappings);
    }

    /**
     * @description Populates contract records and map those records in the wrapper, which are further mapped to rows for the table.
     * @param contractWrapper
     * @param accountID
     * @param contractVsStoreCount
     */
    @TestVisible
    private static void populateContracts(
        ContractDataWrapper contractWrapper,
        Id accountID,
        Map<Id, Integer> contractVsStoreCount
    ) {
        Set<String> fieldNames = new Set<String>();

        for (Contract_Table_Mapping__mdt tableMapping : contractWrapper.contractDataTableMap) {
            if (tableMapping.Type__c != TYPE_REPORT && tableMapping.API_Name__c != null) {
                fieldNames.add(tableMapping.API_Name__c);
            }
            if (
                tableMapping.Type__c != TYPE_REPORT &&
                tableMapping.Hyper_Link_Display_Field__c != null
            ) {
                fieldNames.add(tableMapping.Hyper_Link_Display_Field__c);
            }
        }

        for (
            Contract eachContract : ContractsSelector.newInstance()
                .selectContractsWithDynamicFields(fieldNames, accountID)
        ) {
            ContractInfo contractDetail = new ContractInfo();
            contractDetail.storeCount = contractVsStoreCount.containsKey(eachContract.Id)
                ? contractVsStoreCount.get(eachContract.Id)
                : COUNT_ZERO;
            if (eachContract.Is_This_Ads_Or_Promo__c) {
                contractDetail.contract = eachContract;
                contractWrapper.promoProducts.add(contractDetail);
            } else {
                contractDetail.contract = eachContract;
                contractWrapper.coreProducts.add(contractDetail);
            }
        }
    }

     /**
     * @description It is used for getting Subscriptions by passing in the contract Id and further populates the wrapper.
     * LEM-15902
     * @param contractId
     * @return List<SBQQ__Subscription__c>
     */
    @AuraEnabled
    public static List<Packages> fetchAllSubscriptions(String contractId) {
        List<Packages> packages = new List<Packages>();
        Map<String,Packages> packageVsRates = new Map<String,Packages>();

        for(SBQQ__Subscription__c subscription : SubscriptionSelector.newInstance().selectByContractId(contractId)) {
            if(subscription.Package__c == NULL){
                continue;
            }
            String packageName = subscription.Package__c;
            Boolean isHistorical = subscription.SBQQ__TerminatedDate__c != NULL;

            if (packageName != null && !isHistorical) {
                if (!packageVsRates.containsKey(packageName)) {
                    packageVsRates.put(packageName, new Packages());
                }
                packageVsRates.get(packageName).activeSubscriptions.add(subscription);
            }

        }

        // populate the wrapper grouped with packages, having active and historical rates.
        for(String packageName : packageVsRates.keySet()){
            Packages rate = new Packages();
            rate.packageName = packageName;
            rate.activeSubscriptions = packageVsRates.get(packageName).activeSubscriptions;
            packages.add(rate);
        }

        return packages;
    }

     /**
     * Wrapper class for amend contract data.
     * @description This class is used to wrap the data.
     */
    public class ContractDataWrapper{
        @AuraEnabled
        public List<Contract_Table_Mapping__mdt> contractDataTableMap = new List<Contract_Table_Mapping__mdt>();

        @AuraEnabled
        public List<ContractInfo> coreProducts = new List<ContractInfo>();

        @AuraEnabled
        public List<ContractInfo> promoProducts = new List<ContractInfo>();

        @AuraEnabled
        public List<Sobject> recordDetails = new List<Sobject>();

        @AuraEnabled
        public String initiatedFromSobject;

        @AuraEnabled
        public String segment;
    }

    /**
     * Wrapper class for amend contract data.
     * @description This class is used to wrap the data.
     */
    public class ContractInfo {
        @AuraEnabled
        public Contract contract = new Contract();

        @AuraEnabled
        public Integer storeCount ;
    }


    /**
     * @description Wrapper class for subscription details
     */
    public class Packages {
        @AuraEnabled
        public String packageName;

        @AuraEnabled
        public List<SBQQ__Subscription__c> activeSubscriptions = new List<SBQQ__Subscription__c>();
    }

}
