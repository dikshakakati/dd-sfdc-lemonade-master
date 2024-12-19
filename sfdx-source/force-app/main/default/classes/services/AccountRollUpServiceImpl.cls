/**
 * @author Deloitte
 * @date   14/03/2022
 * @description This is the service implementation class for Account roll up related logic
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.StdCyclomaticComplexity')
public inherited sharing class AccountRollUpServiceImpl implements IAccountRollUpService {
    private static final String STORE_COUNT = 'Store Count';
    private static final String STORE = 'Store';
    private static final String VERTICAL = 'Vertical';
    private static final String VERTICAL_STORE = 'StoreVertical';
    private static final String FRANCHISE = 'Franchise';
    private static final String BUSINESS = 'Business';
    private static final String PARTNERSHIP_STATUS = 'Partnership Status';
    private static final String PROSPECTIVE_PARTNER = 'Prospective Partner';
    private static final String EXISTING_PARTNER = 'Existing Partner';
    private static final String FORMER_PARTNER = 'Former Partner';
    private static final String DEACTIVATED = 'Deactivated';
    private static final String ACTIVE = 'Active';
    private static final String SEMICOLON_DELIMITER = ';';
    private static final String MEDAL_RANK = 'Medal Rank';
    private static final String MEDAL_RANK_PLATINUM = 'Platinum';
    private static final String MEDAL_RANK_GOLD = 'Gold';
    private static final String MEDAL_RANK_SILVER = 'Silver';
    private static final String MEDAL_RANK_BRONZE = 'Bronze';
    private static final String MEDAL_RANK_TIN = 'Tin';
    private static final List<String> MEDAL_RANK_PRIORITY = new List<String>{
        MEDAL_RANK_PLATINUM,
        MEDAL_RANK_GOLD,
        MEDAL_RANK_SILVER,
        MEDAL_RANK_BRONZE,
        MEDAL_RANK_TIN
    };

    /**
     * @description Roll up accounts method
     * @param accountsToRollup
     */
    public void publishStoreRollUpEvents(Set<Id> accountsToRollup) {
        if (accountsToRollup.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Id parentId : accountsToRollup) {
            RollUpEvent__e evt = new RollUpEvent__e();
            evt.RecordId__c = parentId;
            evt.Type__c = STORE_COUNT;
            uow.registerPublishAfterSuccessTransaction(evt);
        }
        commitWork(uow);
    }

    /**
     * @description Roll up accounts method for Vertical
     * @param accountsToRollup
     */
    public void publishVerticalRollUpEvents(Set<Id> accountsToRollup) {
        if (accountsToRollup.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Id accId : accountsToRollup) {
            RollUpEvent__e evt = new RollUpEvent__e();
            evt.RecordId__c = accId;
            evt.Type__c = VERTICAL;
            uow.registerPublishAfterSuccessTransaction(evt);
        }
        commitWork(uow);
    }

    /**
     * @description It is used to publish Roll Up events for Primary Vertical roll up from Store
     * Accounts.
     * @param accountsToRollup
     */
    public void publishStoreVerticalRollUpEvents(Set<Id> accountsToRollup) {
        if (accountsToRollup.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Id eachAccountId : accountsToRollup) {
            uow.registerPublishAfterSuccessTransaction(
                new RollUpEvent__e(RecordId__c = eachAccountId, Type__c = VERTICAL_STORE)
            );
        }
        commitWork(uow);
    }

    /**
     * @description It is used to publish Roll Up events for Primary Vertical Roll up to Franchise Accounts from Store
     * Accounts.
     * @param accountsToRollup
     */
    public void publishStoreVerticalRollUpToFranchiseEvents(Set<Id> accountsToRollup) {
        if (accountsToRollup.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Id eachAccountId : accountsToRollup) {
            uow.registerPublishAfterSuccessTransaction(
                new RollUpEvent__e(RecordId__c = eachAccountId, Type__c = FRANCHISE)
            );
        }
        commitWork(uow);
    }

    /**
     * @description Publish event for partnership status calculation
     * @param accountsToRollup
     */
    public void publishPartnershipStatusRollUpEvents(Set<Id> accountsToRollup) {
        if (accountsToRollup.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Id accId : accountsToRollup) {
            RollUpEvent__e evt = new RollUpEvent__e();
            evt.RecordId__c = accId;
            evt.Type__c = PARTNERSHIP_STATUS;
            uow.registerPublishAfterSuccessTransaction(evt);
        }
        commitWork(uow);
    }

    /**
     * @description Generic method to redirect to appropriate roll up calculation
     * @param accountIdsByType
     */
    public void calculateRollupsByType(Map<String, Set<Id>> accountIdsByType) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        rollUpStores(accountIdsByType.get(STORE_COUNT), uow);
        rollUpStoreVerticals(accountIdsByType.get(VERTICAL_STORE), uow);
        rollUpVerticals(accountIdsByType.get(VERTICAL), uow);
        rollUpPartnershipStatus(accountIdsByType.get(PARTNERSHIP_STATUS), uow);
        rollUpMedalRank(accountIdsByType.get(MEDAL_RANK), uow);
        commitWork(uow);
    }

    /**
     * @description It is used to populate Additional Vertical field on the direct parent Account.
     * @param franchiseAccountIds
     */
    public void aggregateVerticalOnFranchiseParents(Set<Id> franchiseAccountIds) {
        List<Account> accounts = AccountsSelector.newInstance()
            .getCorporateAccountIdsByFranchiseAccount(franchiseAccountIds);

        Map<Id, Set<String>> aggregateValuesByFranchiseParentId = new Map<Id, Set<String>>();

        for (Id accountId : franchiseAccountIds) {
            aggregateValuesByFranchiseParentId.put(accountId, new Set<String>());
        }
        for (Account eachAccount : accounts) {
            aggregateValuesByFranchiseParentId.get(eachAccount.Franchise_Parent__c)
                .add(eachAccount.Primary_Vertical__c);
            aggregateValuesByFranchiseParentId.get(eachAccount.Franchise_Parent__c)
                .add(eachAccount.Franchise_Parent__r.Primary_Vertical__c);
            aggregateValuesByFranchiseParentId.get(eachAccount.Franchise_Parent__c).remove(null);
            aggregateValuesByFranchiseParentId.remove(null);
        }

        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Id franchiseParentId : aggregateValuesByFranchiseParentId.keySet()) {
            String verticals = String.join(
                new List<String>(aggregateValuesByFranchiseParentId.get(franchiseParentId)),
                SEMICOLON_DELIMITER
            );
            uow.registerDirty(
                new Account(Id = franchiseParentId, Additional_Verticals__c = verticals),
                new List<SObjectField>{ Account.Additional_Verticals__c }
            );
        }
        commitWork(uow);
    }

    /**
     * @description To perform roll up calculation
     * @param accountIds
     * @param uow
     */
    private void rollUpStores(Set<Id> accountIds, fflib_ISObjectUnitOfWork uow) {
        Map<Id, Account> summarizedAccountsById = new Map<Id, Account>();
        if (isEmptyOrNull(accountIds)) {
            return;
        }

        // To handle count when child account is deleted
        for (Id accountId : accountIds) {
            summarizedAccountsById.put(
                accountId,
                new Account(
                    Id = accountId,
                    Franchise_Owned_Store_Count__c = 0,
                    Corporate_Owned_Store_Count__c = 0,
                    Total_Number_Of_Active_Stores_Calculate__c = 0,
                    NumberOfMxStoresNotonDoorDashCalculate__c = 0,
                    TotalNoOfActiveMarketplaceStoreCalculate__c = 0,
                    TotalNoOfActiveDriveStoresCalculate__c = 0
                )
            );
        }

        Aggregate[] accountSumOfChildStoreCount = AccountsSelector.newInstance()
            .selectSumOfChildStoreCount(summarizedAccountsById.keySet());
        Map<Id, Aggregate> mapChildStoreCountsByAccountId = Aggregate.mapBy(
            'Id',
            accountSumOfChildStoreCount
        );

        Aggregate[] franchiseOwnedViaParentCount = AccountsSelector.newInstance()
            .selectFranchiseOwnedViaParentCount(summarizedAccountsById.keySet());
        Map<Id, Aggregate> mapFranchiseOwnedViaParentByAccountId = Aggregate.mapBy(
            'Id',
            franchiseOwnedViaParentCount
        );

        Aggregate[] franchiseOwnedViaFranchiseCount = AccountsSelector.newInstance()
            .selectFranchiseOwnedViaFranchiseCount(summarizedAccountsById.keySet());
        Map<Id, Aggregate> mapFranchiseOwnedViaFranchiseByAccountId = Aggregate.mapBy(
            'Id',
            franchiseOwnedViaFranchiseCount
        );

        Aggregate[] corporateCount = AccountsSelector.newInstance()
            .selectCorporateCount(summarizedAccountsById.keySet());
        Map<Id, Aggregate> mapCorporateCountByAccountId = Aggregate.mapBy('Id', corporateCount);

        Aggregate[] corporateActiveStoreCount = AccountsSelector.newInstance()
            .selectActiveCorporateCount(summarizedAccountsById.keySet());

        Map<Id, Aggregate> mapActiveCorporateCountByAccountId = Aggregate.mapBy(
            'Id',
            corporateActiveStoreCount
        );
        Aggregate[] corporateInActiveStoreCount = AccountsSelector.newInstance()
            .selectInActiveCorporateCount(summarizedAccountsById.keySet());

        Map<Id, Aggregate> mapInActiveCorporateCountByAccountId = Aggregate.mapBy(
            'Id',
            corporateInActiveStoreCount
        );

        List<Account> accountsWithXrefs = AccountsSelector.newInstance()
            .selectAccountsWithMDSXrefs(summarizedAccountsById.keySet());
        List<Account> accountsWithNonMDSXrefs = AccountsSelector.newInstance()
            .selectAccountsWithNonMDSXrefs(summarizedAccountsById.keySet());

        Map<Id, List<Id>> accountIdToListOfMDSstoreAccountMap = constructMapOfAccountIdToXrefs(
            accountsWithXrefs
        );
        Map<Id, List<Id>> accountIdToListOfNonMDSstoreAccountMap = constructMapOfAccountIdToXrefs(
            accountsWithNonMDSXrefs
        );

        for (Account objAccount : summarizedAccountsById.values()) {
            objAccount.TotalNoOfActiveDriveStoresCalculate__c = calculateActiveDriveStores(
                accountIdToListOfNonMDSstoreAccountMap,
                mapChildStoreCountsByAccountId,
                objAccount.Id
            );

            objAccount.TotalNoOfActiveMarketplaceStoreCalculate__c = calculateActiveMPStores(
                accountIdToListOfMDSstoreAccountMap,
                mapChildStoreCountsByAccountId,
                objAccount.Id
            );

            objAccount.NumberOfMxStoresNotonDoorDashCalculate__c = summarizeInActiveStoreAccounts(
                mapInActiveCorporateCountByAccountId.get(objAccount.Id),
                mapChildStoreCountsByAccountId.get(objAccount.Id)
            );
            objAccount.Total_Number_Of_Active_Stores_Calculate__c = summarizeActiveStoreAccounts(
                mapActiveCorporateCountByAccountId.get(objAccount.Id),
                mapChildStoreCountsByAccountId.get(objAccount.Id)
            );
            objAccount.Franchise_Owned_Store_Count__c = summarizeFranchiseStoreAccounts(
                mapFranchiseOwnedViaParentByAccountId.get(objAccount.Id),
                mapFranchiseOwnedViaFranchiseByAccountId.get(objAccount.Id),
                mapChildStoreCountsByAccountId.get(objAccount.Id)
            );
            objAccount.Corporate_Owned_Store_Count__c = summarizeCorporateStoreAccounts(
                mapCorporateCountByAccountId.get(objAccount.Id),
                mapChildStoreCountsByAccountId.get(objAccount.Id)
            );
            uow.registerDirty(
                objAccount,
                new List<SObjectField>{
                    Account.Franchise_Owned_Store_Count__c,
                    Account.Corporate_Owned_Store_Count__c,
                    Account.Total_Number_Of_Active_Stores_Calculate__c,
                    Account.NumberOfMxStoresNotonDoorDashCalculate__c,
                    Account.TotalNoOfActiveMarketplaceStoreCalculate__c,
                    Account.TotalNoOfActiveDriveStoresCalculate__c
                }
            );
        }
    }

    /**
     * @description To construct Map Of AccountId To Xrefs
     * @param accountList
     * @return accountIdToListOfMDSORStoretoreAccountMap
     */
    private Map<Id, List<Id>> constructMapOfAccountIdToXrefs(List<Account> accountList) {
        Map<Id, List<Id>> accountIdToListOfMDSORStoretoreAccountMap = new Map<Id, List<Id>>();
        if (accountList != null && !accountList.isEmpty()) {
            for (Account objAccount : accountList) {
                if (!accountIdToListOfMDSORStoretoreAccountMap.containsKey(objAccount.parentId)) {
                    accountIdToListOfMDSORStoretoreAccountMap.put(
                        objAccount.parentId,
                        new List<Id>{ objAccount.Id }
                    );
                } else {
                    accountIdToListOfMDSORStoretoreAccountMap.get(objAccount.parentId)
                        .add(objAccount.Id);
                }
            }
        }
        return accountIdToListOfMDSORStoretoreAccountMap;
    }

    /**
     * @description It is used to calculate actice drive stores
     * @param accountIdToListOfNonMDSstoreAccountMap
     * @param mapChildStoreCountsByAccountId
     * @param accountId
     * @return totalNumberOfActiveDriveStores
     */
    private Integer calculateActiveDriveStores(
        Map<Id, List<Id>> accountIdToListOfNonMDSstoreAccountMap,
        Map<Id, Aggregate> mapChildStoreCountsByAccountId,
        Id accountId
    ) {
        Integer totalNumberOfActiveDriveStores = 0;
        if (accountIdToListOfNonMDSstoreAccountMap.containsKey(accountId)) {
            totalNumberOfActiveDriveStores = summarizeActiveNonMDSXREFs(
                accountIdToListOfNonMDSstoreAccountMap.get(accountId).size(),
                mapChildStoreCountsByAccountId.get(accountId)
            );
        } else if (
            !accountIdToListOfNonMDSstoreAccountMap.containsKey(accountId) &&
            mapChildStoreCountsByAccountId.containsKey(accountId)
        ) {
            totalNumberOfActiveDriveStores = summarizeActiveNonMDSXREFs(
                0,
                mapChildStoreCountsByAccountId.get(accountId)
            );
        }
        return totalNumberOfActiveDriveStores;
    }

    /**
     * @description Calculates Actice MP Stores
     * @param accountIdToListOfMDSstoreAccountMap
     * @param mapChildStoreCountsByAccountId
     * @param accountId
     * @return totalNumberOfActiveMPStores
     */
    private Integer calculateActiveMPStores(
        Map<Id, List<Id>> accountIdToListOfMDSstoreAccountMap,
        Map<Id, Aggregate> mapChildStoreCountsByAccountId,
        Id accountId
    ) {
        Integer totalNumberOfActiveMPStores = 0;
        if (accountIdToListOfMDSstoreAccountMap.containsKey(accountId)) {
            totalNumberOfActiveMPStores = summarizeActiveNonMDSXREFs(
                accountIdToListOfMDSstoreAccountMap.get(accountId).size(),
                mapChildStoreCountsByAccountId.get(accountId)
            );
        } else if (
            !accountIdToListOfMDSstoreAccountMap.containsKey(accountId) &&
            mapChildStoreCountsByAccountId.containsKey(accountId)
        ) {
            totalNumberOfActiveMPStores = summarizeActiveMDSXREFs(
                0,
                mapChildStoreCountsByAccountId.get(accountId)
            );
        }
        return totalNumberOfActiveMPStores;
    }

    /**
     * @description To get Active Drive store count
     * @param activeNonMDXCount
     * @param sumOfChildStoreCount
     * @return Integer
     */
    private Integer summarizeActiveNonMDSXREFs(
        Integer activeNonMDXCount,
        Aggregate sumOfChildStoreCount
    ) {
        Integer summary = 0;
        summary += Integer.valueOf(ifNull(sumOfChildStoreCount?.get('DriveStores'), 0));
        summary += activeNonMDXCount;
        return summary;
    }

    /**
     * @description To get active MDS store count
     * @param activeMDXCount
     * @param sumOfChildStoreCount
     * @return Integer
     */
    private Integer summarizeActiveMDSXREFs(
        Integer activeMDXCount,
        Aggregate sumOfChildStoreCount
    ) {
        Integer summary = 0;
        summary += Integer.valueOf(ifNull(sumOfChildStoreCount?.get('MDXStores'), 0));
        summary += activeMDXCount;
        return summary;
    }

    /**
     * @description To get store count
     * @param activeCorporateCount
     * @param sumOfChildStoreCount
     * @return Integer
     */
    private Integer summarizeActiveStoreAccounts(
        Aggregate activeCorporateCount,
        Aggregate sumOfChildStoreCount
    ) {
        Integer summary = 0;
        summary += Integer.valueOf(ifNull(sumOfChildStoreCount?.get('activeStores'), 0));
        summary += Integer.valueOf(ifNull(activeCorporateCount?.get('countIds'), 0));
        return summary;
    }

    /**
     * @description To get Inactive store count
     * @param activeCorporateCount
     * @param sumOfChildStoreCount
     * @return Integer
     */
    private Integer summarizeInActiveStoreAccounts(
        Aggregate activeCorporateCount,
        Aggregate sumOfChildStoreCount
    ) {
        Integer summary = 0;
        summary += Integer.valueOf(ifNull(sumOfChildStoreCount?.get('inactiveStores'), 0));
        summary += Integer.valueOf(ifNull(activeCorporateCount?.get('countIds'), 0));
        return summary;
    }

    /**
     * @description To get franchise store count
     * @param franchiseOwnedViaParentCount
     * @param franchiseOwnedViaFranchiseCount
     * @param accountSumOfChildStoreCount
     * @return Integer
     */
    private Integer summarizeFranchiseStoreAccounts(
        Aggregate franchiseOwnedViaParentCount,
        Aggregate franchiseOwnedViaFranchiseCount,
        Aggregate accountSumOfChildStoreCount
    ) {
        Integer summary = 0;
        summary += Integer.valueOf(ifNull(franchiseOwnedViaParentCount?.get('countIds'), 0));
        summary += Integer.valueOf(ifNull(franchiseOwnedViaFranchiseCount?.get('countIds'), 0));
        summary += Integer.valueOf(ifNull(accountSumOfChildStoreCount?.get('franchiseCount'), 0));
        return summary;
    }

    /**
     * @description To get franchise store count
     * @param corporateCount
     * @param sumOfChildStoreCount
     * @return Integer
     */
    private Integer summarizeCorporateStoreAccounts(
        Aggregate corporateCount,
        Aggregate sumOfChildStoreCount
    ) {
        Integer summary = 0;
        summary += Integer.valueOf(ifNull(sumOfChildStoreCount?.get('corporateCount'), 0));
        summary += Integer.valueOf(ifNull(corporateCount?.get('countIds'), 0));
        return summary;
    }

    /**
     * @description Roll up Additional Verticals from the child Business Accounts.
     * @param accountIds
     * @param uow
     */
    private void rollUpVerticals(Set<Id> accountIds, fflib_ISObjectUnitOfWork uow) {
        if (isEmptyOrNull(accountIds)) {
            return;
        }

        aggregateVerticalValues(
            AccountsSelector.newInstance().selectChildMerchantVerticals(accountIds),
            accountIds,
            BUSINESS,
            uow
        );
    }

    /**
     * @description Roll up the Primary Vertical value from the Store Accounts.
     * @param accountIds
     * @param uow
     */
    private void rollUpStoreVerticals(Set<Id> accountIds, fflib_ISObjectUnitOfWork uow) {
        if (isEmptyOrNull(accountIds)) {
            return;
        }

        aggregateVerticalValues(
            AccountsSelector.newInstance()
                .selectStoreAccountsWithPrimaryVerticalByParentAccount(accountIds),
            accountIds,
            STORE,
            uow
        );
    }

    /**
     * @description It is used to populate Additional Vertical field on the direct parent Account.
     * @param accounts
     * @param accountIds
     * @param typeOfAccounts
     * @param uow
     */
    private void aggregateVerticalValues(
        List<Account> accounts,
        Set<Id> accountIds,
        String typeOfAccounts,
        fflib_ISObjectUnitOfWork uow
    ) {
        Map<Id, Set<String>> parentValuesByParentId = new Map<Id, Set<String>>();
        Map<Id, Set<String>> aggregateValuesByParentId = new Map<Id, Set<String>>();

        for (Id accountId : accountIds) {
            parentValuesByParentId.put(accountId, new Set<String>());
            aggregateValuesByParentId.put(accountId, new Set<String>());
        }

        //Adding all the child merchant verticals to merchant vertical map
        for (Account eachAccount : accounts) {
            parentValuesByParentId.get(eachAccount.ParentId)
                .add(eachAccount.Parent.Primary_Vertical__c);
            parentValuesByParentId.get(eachAccount.ParentId)
                .addAll(getAdditionalVerticalsSet(eachAccount.Parent.Additional_Verticals__c));
            parentValuesByParentId.get(eachAccount.ParentId).remove(null);

            if (typeOfAccounts == STORE) {
                aggregateValuesByParentId.get(eachAccount.ParentId)
                    .add(eachAccount.Primary_Vertical__c);
            } else {
                aggregateValuesByParentId.get(eachAccount.ParentId)
                    .addAll(getAdditionalVerticalsSet(eachAccount.Additional_Verticals__c));
            }
            aggregateValuesByParentId.get(eachAccount.ParentId)
                .add(eachAccount.Parent.Primary_Vertical__c);
            aggregateValuesByParentId.get(eachAccount.ParentId).remove(null);
            aggregateValuesByParentId.remove(null);
            parentValuesByParentId.remove(null);
        }
        // Update Merchant Verticals only if it has updated via new roll up calculation
        for (Id parentId : aggregateValuesByParentId.keySet()) {
            if (
                aggregateValuesByParentId.get(parentId).isEmpty() ||
                setsDoNotMatch(
                    parentValuesByParentId.get(parentId),
                    aggregateValuesByParentId.get(parentId)
                )
            ) {
                String verticals = String.join(
                    new List<String>(aggregateValuesByParentId.get(parentId)),
                    SEMICOLON_DELIMITER
                );
                uow.registerDirty(
                    new Account(Id = parentId, Additional_Verticals__c = verticals),
                    new List<SObjectField>{ Account.Additional_Verticals__c }
                );
            }
        }
    }

    /**
     * @description It is used to convert the multi select values of Additional Verticals into a
     * set of individual values.
     * @param additionalVerticals
     * @return Set<String>
     */
    private Set<String> getAdditionalVerticalsSet(String additionalVerticals) {
        return String.isNotBlank(additionalVerticals)
            ? new Set<String>(additionalVerticals.split(SEMICOLON_DELIMITER))
            : new Set<String>();
    }

    private Boolean setsDoNotMatch(Set<String> setValues, Set<String> aggregateValues) {
        return !setValues.containsAll(aggregateValues) || !aggregateValues.containsAll(setValues);
    }

    /**
     * @description To perform roll up calculation on partnership status
     * @param accountIds
     * @param uow
     */
    private void rollUpPartnershipStatus(Set<Id> accountIds, fflib_ISObjectUnitOfWork uow) {
        if (isEmptyOrNull(accountIds)) {
            return;
        }

        Map<Id, Map<String, Integer>> countOfChildAccountsByStatus = new Map<Id, Map<String, Integer>>();

        // Summarize the aggregate results by parent account and calculate a total count by partnership status
        for (
            Aggregate aggr : AccountsSelector.newInstance()
                .selectCountOfChildrenBusinessAccountsByPartnershipStatus(accountIds)
        ) {
            Id parentAccountId = (Id) aggr.get('Id');
            if (!countOfChildAccountsByStatus.containsKey(parentAccountId)) {
                countOfChildAccountsByStatus.put(parentAccountId, new Map<String, Integer>());
            }
            countOfChildAccountsByStatus.get(parentAccountId)
                .put((String) aggr.get('status'), (Integer) aggr.get('countIds'));
        }

        // Summarize the aggregate results by parent account and calculate a total count by activation status
        for (
            Aggregate aggr : AccountsSelector.newInstance()
                .selectCountOfChildrenStoreAccountsByActivationStatus(accountIds)
        ) {
            Id parentAccountId = (Id) aggr.get('Id');
            if (!countOfChildAccountsByStatus.containsKey(parentAccountId)) {
                countOfChildAccountsByStatus.put(parentAccountId, new Map<String, Integer>());
            }
            countOfChildAccountsByStatus.get(parentAccountId)
                .put((String) aggr.get('status'), (Integer) aggr.get('countIds'));
        }

        // Set the partnership status on the parent account based on the combination of the partnership statuses on the children
        for (Id accountId : countOfChildAccountsByStatus.keySet()) {
            Map<String, Integer> childAccountsByStatus = countOfChildAccountsByStatus.get(
                accountId
            );
            String partnershipStatus = getPartnershipStatus(childAccountsByStatus);
            uow.registerDirty(
                new Account(Id = accountId, Partnership_Status__c = partnershipStatus),
                new List<SObjectField>{ Account.Partnership_Status__c }
            );
        }
    }

    private String getPartnershipStatus(Map<String, Integer> countsByStatus) {
        Integer totalCount = 0;
        Integer sumOfDeactivateAndFormerPartnerStore = 0;
        for (String status : countsByStatus.keySet()) {
            totalCount = (Integer) countsByStatus.get(status) + totalCount;
            if (status == FORMER_PARTNER || status == DEACTIVATED) {
                sumOfDeactivateAndFormerPartnerStore =
                    (Integer) countsByStatus.get(status) + sumOfDeactivateAndFormerPartnerStore;
            }
        }

        // default the partnership status to prospective partner
        String status = PROSPECTIVE_PARTNER;

        // If ALL the child accounts are former partners or deactivated, the parent partnership status becomes a former partner
        if (sumOfDeactivateAndFormerPartnerStore == totalCount) {
            status = FORMER_PARTNER;
        }

        //If ANY of the child accounts are existing partners, the parent partnership status becomes an existing partner
        if (
            (countsByStatus.containsKey(EXISTING_PARTNER) &&
            countsByStatus.get(EXISTING_PARTNER) > 0) ||
            (countsByStatus.containsKey(ACTIVE) && countsByStatus.get(ACTIVE) > 0)
        ) {
            status = EXISTING_PARTNER;
        }

        return status;
    }

    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            throw ex;
        }
    }

    /**
     * @description Returns a known default value if the given value is null
     * @param value
     * @param defaultValue
     * @return the given value unless it is null
     */
    private Object ifNull(Object value, Object defaultValue) {
        if (value != null) {
            return value;
        }
        return defaultValue;
    }

    private Boolean isEmptyOrNull(Set<Id> setIds) {
        return setIds == null || setIds.isEmpty();
    }

    /**
     * @description Publish event for Medal Rank calculation.
     * @param accountsToRollup
     */
    public void publishMedalRankRollUpEvents(Set<Id> accountsToRollup) {
        if (accountsToRollup.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Id eachAccountId : accountsToRollup) {
            RollUpEvent__e rollupEvent = new RollUpEvent__e();
            rollupEvent.RecordId__c = eachAccountId;
            rollupEvent.Type__c = MEDAL_RANK;
            uow.registerPublishAfterSuccessTransaction(rollupEvent);
        }
        commitWork(uow);
    }

    /**
     * @description Medal rank calculation by rollup on parent Accounts.
     * @param accountIds
     * @param uow
     */
    private void rollUpMedalRank(Set<Id> accountIds, fflib_ISObjectUnitOfWork uow) {
        Map<Id, Map<String, Integer>> countOfStoreAccountsByMedalRank = new Map<Id, Map<String, Integer>>();
        Map<String, Integer> medalRankByCountOfStores = new Map<String, Integer>();
        String medalRank;
        Id parentAccountId;
        if (isEmptyOrNull(accountIds)) {
            return;
        }
        // Summarize the aggregate results by parent account and calculate a total count by medal rank
        for (
            Aggregate eachAggregate : AccountsSelector.newInstance()
                .selectCountOfStoreAccountsByMedalRank(accountIds)
        ) {
            parentAccountId = (Id) eachAggregate.get('Id');
            if (!countOfStoreAccountsByMedalRank.containsKey(parentAccountId)) {
                countOfStoreAccountsByMedalRank.put(parentAccountId, new Map<String, Integer>());
            }
            countOfStoreAccountsByMedalRank.get(parentAccountId)
                .put(
                    (String) eachAggregate.get('medalRank'),
                    (Integer) eachAggregate.get('countIds')
                );
        }

        // Set the partnership status on the parent account based on the combination of the partnership statuses on the children
        for (Id accountId : countOfStoreAccountsByMedalRank.keySet()) {
            medalRankByCountOfStores = countOfStoreAccountsByMedalRank.get(accountId);
            medalRank = getMedalRank(medalRankByCountOfStores);
            uow.registerDirty(
                new Account(Id = accountId, Medal_Rank__c = medalRank),
                new List<SObjectField>{ Account.Medal_Rank__c }
            );
        }
    }

    /**
     * @description It is used to get the Medal rank based on the count and priority.
     * @param countsByMedalRank
     * @return String
     */
    private String getMedalRank(Map<String, Integer> countsByMedalRank) {
        String highestMedalRank;
        Integer currentMedalIndex;
        Integer highestMedalRankIndex;
        Integer highestCount = 0;

        for (string medalRank : countsByMedalRank.keySet()) {
            currentMedalIndex = MEDAL_RANK_PRIORITY.indexOf(medalRank);
            if (currentMedalIndex < 0) {
                continue;
            }
            if (countsByMedalRank.get(medalRank) > highestCount) {
                highestCount = countsByMedalRank.get(medalRank);
                highestMedalRank = medalRank;
            } else if (countsByMedalRank.get(medalRank) == highestCount) {
                highestMedalRankIndex = MEDAL_RANK_PRIORITY.indexOf(highestMedalRank);
                if (currentMedalIndex < highestMedalRankIndex) {
                    highestMedalRank = medalRank;
                }
            }
        }
        return highestMedalRank;
    }
}