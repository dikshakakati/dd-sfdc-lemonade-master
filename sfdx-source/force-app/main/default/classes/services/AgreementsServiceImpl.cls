/**
 * @description LEM-637 This is the service class for Agreements related logic
 * @author DoorDash QTC
 * @date 05/15/2022
 */
public inherited sharing class AgreementsServiceImpl implements IAgreementsService {
    static final String STORE_AGREEMENT = 'Store Agreement';
    static final String BUSINESS_AGREEMENT = 'Business Agreement';
    static final String PENDING_STATUS = 'Pending';
    static final String ACTIVE_STATUS = 'Active';
    static final String AGREED_TO_SERVICES_ALL = 'All';
    static final String AGREED_TO_SERVICES_DRIVE = 'Drive';
    static final String CORE_CONTRACT = 'Core';
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final String AGREEMENT_EVENTS_CHUNK_SIZE = 'Agreement_Events_Chunk_Size';
    private static final String UPDATE_ACTIVATION_ORDERS_AND_PRODUCTS_FOR_EXISTING_STORES = 'Update Activation Order And Products For Existing Process';
    private static final String EVENT_TOPIC_CREATE_ACTIVATION_ORDER = 'Create_Activation_Order_Products';
    private static final String EVENT_TOPIC_UPDATE_MERCHANT_SERVICES = 'Update_Merchant_Services'; //@JIRA #LEM-15980
    private static final String STATUS_CANCELLED = 'Cancelled'; //@JIRA #LEM-15980
    private static final String AGREEMENT_TYPE_STORE = 'Store Agreement'; //@JIRA #LEM-15980
    private static final Integer MAX_RECORD_PER_TRANSACTION = 1000; //LEM-15980
    private static final Integer AGREEMENT_CHUNK_SIZE = 100; //LEM-15980
    private static final String SOURCE_RESSMO = 'RESSMO'; //LEM-23331
    @TestVisible
    private static Set<String> alreadyProcessedContractsWithStore = new Set<String>();

    /**
     * @description Generate the Agreement Name
     * LEM-4514
     * @param accountMap
     * @param accId
     * @return String
     */
    public String getAccountName(Map<Id, Account> accountMap, Id accId) {
        String agreementName = (!accountMap.isEmpty() && accountMap.containsKey(accId))
            ? accountMap.get(accId).Name
            : '';
        String shortAgreementName = agreementName.substring(
            0,
            agreementName.length() > 60 ? 60 : agreementName.length()
        );
        return shortAgreementName;
    }

    /**
     * @description - Create Agreements on Contract with group
     * @param contractList
     * @param contractIdWithAssociatedAccountIdsMap
     * @param associatedAccountIdGroupIdMapWithEntitlements
     */
    public void createAgreementsfromContractsWithGroup(
        List<Contract> contractList,
        Map<Id, Set<String>> contractIdWithAssociatedAccountIdsMap,
        Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements
    ) {
        Set<Id> quoteIds = new Set<Id>();
        Map<Id, Set<String>> contractIdToStoreAccountIds = new Map<Id, Set<String>>();
        Map<Id, Id> contractIdToBusinessAccountIds = new Map<Id, Id>();

        String storeAgreementName = '';
        if (
            (contractIdWithAssociatedAccountIdsMap == null) ||
            (contractIdWithAssociatedAccountIdsMap.isEmpty())
        ) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Set<Id> allAccountsIdsSet = getAllAccountIds(
            contractIdWithAssociatedAccountIdsMap.values()
        );

        //Get the all the store or Business Accounts for the given Id's
        List<Account> allAccountsList = AccountsSelector.newInstance()
            .selectById(allAccountsIdsSet);
        Map<Id, Account> accountMap = new Map<Id, Account>(allAccountsList);

        for (Contract eachContract : contractList) {
            getCoreContracts(
                eachContract,
                contractIdWithAssociatedAccountIdsMap,
                quoteIds,
                contractIdToStoreAccountIds,
                contractIdToBusinessAccountIds
            );

            // Create the set of store account ids to iterate over before the loop
            Set<String> associatedAccountIdStrings = contractIdWithAssociatedAccountIdsMap.get(
                eachContract.Id
            );

            Set<Id> associatedAccountIdSet = getIdSetFromStringSet(associatedAccountIdStrings);
            associatedAccountIdSet.retainAll(accountMap.keySet());

            for (Id accId : associatedAccountIdSet) {
                String typeToAdd = BUSINESS_AGREEMENT;
                String agreedToServicesToAdd = AGREED_TO_SERVICES_DRIVE;
                Id groupId;
                String entitlementsData;
                storeAgreementName = getAccountName(accountMap, accId);
                if (
                    (accountMap.containsKey(accId)) &&
                    (accountMap.get(accId).RecordTypeId == STORE_RECORD_TYPE_ID)
                ) {
                    typeToAdd = STORE_AGREEMENT;
                    agreedToServicesToAdd = AGREED_TO_SERVICES_ALL;
                }
                // Retrieving data from the nested map
                if (associatedAccountIdGroupIdMapWithEntitlements.containsKey(accId)) {
                    Set<Id> innerKeys = associatedAccountIdGroupIdMapWithEntitlements.get(accId)
                        .keySet();
                    for (Id innerKey : innerKeys) {
                        groupId = innerKey;
                    }
                    entitlementsData = associatedAccountIdGroupIdMapWithEntitlements.get(accId)
                        .get(groupId);
                }
                Agreement__c agreementItem = new Agreement__c(
                    Name = storeAgreementName + ' - ' + typeToAdd,
                    Account__c = accId,
                    group__c = groupId,
                    Agreed_To_Services__c = agreedToServicesToAdd,
                    Contract__c = eachContract.Id,
                    CurrencyIsoCode = eachContract.CurrencyIsoCode,
                    Status__c = ACTIVE_STATUS,
                    Type__c = typeToAdd,
                    Start_Date__c = System.today(),
                    Source_Quote__c = eachContract.SBQQ__Quote__c,
                    Serialized_Entitlements_Data__c = entitlementsData
                );
                registerAgreement(agreementItem, eachContract.Id+'|'+accId+'|'+typeToAdd, uow, eachContract);
            }
        }
        commitWork(uow);
        createAgreementsForAdsAndPromos(
            quoteIds,
            contractIdToStoreAccountIds,
            contractIdToBusinessAccountIds
        );
    }

    /**
    * @description Agreement will be registered if we haven't processed it
    * @author VenkateshDD | 10-30-2024
    * @param agreementItem
    * @param agreementKey
    * @param uow
    * @param contract
    **/
    @TestVisible
    private void registerAgreement(Agreement__c agreementItem, String agreementKey, fflib_ISObjectUnitOfWork uow, Contract contract){
        try{
            if(contract.Integration_Source__c == SOURCE_RESSMO && alreadyProcessedContractsWithStore.contains(agreementKey)){
                return;
            }
            alreadyProcessedContractsWithStore.add(agreementKey);
            uow.registerNew(agreementItem);
        }
        catch(Exception e){
            Logger.publish(e, LogEntry.SeverityLevel.HIGH);
        }
    }

    /**
     * @description Its used to filter Ads and Promo Contracts applicable for store association.
     * @JIRA #LEM-16431
     * @param coreContract
     * @param contractIdWithAssociatedAccountIdsMap
     * @param quoteIds
     * @param contractIdToStoreAccountIds
     * @param contractIdToBusinessAccountIds
     */
    private void getCoreContracts(
        Contract coreContract,
        Map<Id, Set<String>> contractIdWithAssociatedAccountIdsMap,
        Set<Id> quoteIds,
        Map<Id, Set<String>> contractIdToStoreAccountIds,
        Map<Id, Id> contractIdToBusinessAccountIds
    ) {
        if (
            coreContract.Contract_Split_Category__c == CORE_CONTRACT &&
            contractIdWithAssociatedAccountIdsMap.containsKey(coreContract.Id)
        ) {
            quoteIds.add(coreContract.SBQQ__Quote__c);
            contractIdToStoreAccountIds.put(
                coreContract.Id,
                contractIdWithAssociatedAccountIdsMap.get(coreContract.Id)
            );
            contractIdToBusinessAccountIds.put(coreContract.Account.Id, coreContract.Id);
        }
    }
    /**
     * @description Its used to filter Ads and Promo Contracts applicable for store association.
     * @JIRA #LEM-16431
     * @param quoteIds
     * @param contractIdToStoreAccountIds
     * @param contractIdToBusinessAccountIds
     */
    private void createAgreementsForAdsAndPromos(
        Set<Id> quoteIds,
        Map<Id, Set<String>> contractIdToStoreAccountIds,
        Map<Id, Id> contractIdToBusinessAccountIds
    ) {
        if (
            quoteIds.IsEmpty() ||
            contractIdToStoreAccountIds.IsEmpty() ||
            contractIdToBusinessAccountIds.isEmpty()
        ) {
            return;
        }

        List<Contract> adsAndPromosContracts = ContractsSelector.newInstance()
            .selectAdsAndPromosContractsByAccountIds(contractIdToBusinessAccountIds.keySet());

        Map<Id, Set<String>> contractIdToAccountIds = new Map<Id, Set<String>>();

        for (Contract eachContract : adsAndPromosContracts) {
            if (contractIdToBusinessAccountIds.containsKey(eachContract.accountId)) {
                Id contractId = contractIdToBusinessAccountIds.get(eachContract.accountId);
                contractIdToAccountIds.put(
                    eachContract.Id,
                    contractIdToStoreAccountIds.get(contractId)
                );
            }
        }
        if (adsAndPromosContracts.IsEmpty() || contractIdToAccountIds.IsEmpty()) {
            return;
        }
        AgreementsService.createAgreementsfromContractsWithGroup(
            adsAndPromosContracts,
            contractIdToAccountIds,
            new Map<Id, Map<Id, String>>()
        );
    }
    /**
     * @description - Update Agreements on Contract with Serialized Entitlements Data
     * @param associatedAccountIdGroupIdMapWithEntitlements
     */
    public void updateAgreementsForExistingStoresWithGroups(
        Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements
    ) {
        if (
            (associatedAccountIdGroupIdMapWithEntitlements == null) ||
            (associatedAccountIdGroupIdMapWithEntitlements.isEmpty())
        ) {
            return;
        }

        List<Agreement__c> agreementsToUpdate = new List<Agreement__c>();
        Map<Id, String> groupIdToEntitlements = new Map<Id, String>();

        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();

        Set<Id> allAccountsIdsSet = associatedAccountIdGroupIdMapWithEntitlements.keySet();

        List<Agreement__c> agreements = AgreementsSelector.newInstance()
            .selectActiveAgreementsByAccountIds(allAccountsIdsSet);

        if (agreements.isEmpty()) {
            return;
        }

        Map<Id, Agreement__c> accIdToAgreementMap = createAccidToAgreementsMap(agreements);

        for (Id eachAccountId : allAccountsIdsSet) {
            groupIdToEntitlements = associatedAccountIdGroupIdMapWithEntitlements.get(
                eachAccountId
            );
            if (
                groupIdToEntitlements.get(accIdToAgreementMap.get(eachAccountId).Group__c) !=
                null &&
                accIdToAgreementMap.get(eachAccountId) != null &&
                accIdToAgreementMap.get(eachAccountId).Status__c == ACTIVE_STATUS
            ) {
                Agreement__c newAgreement = new Agreement__c(
                    Id = accIdToAgreementMap.get(eachAccountId).Id,
                    Serialized_Entitlements_Data__c = groupIdToEntitlements.get(
                        accIdToAgreementMap.get(eachAccountId).Group__c
                    )
                );
                agreementsToUpdate.add(newAgreement);
            }
        }

        if (!agreementsToUpdate.isEmpty()) {
            unitOfWorkInstance.registerDirty(agreementsToUpdate);
        }

        commitWork(unitOfWorkInstance);
    }

    /**
     * @description returns all records that have status cancelled on update and deactivation date.
     * @param deactivatedAgreements to check
     * @return active agreements
     * @JIRA #LEM-15980
     */
    public Set<Id> getDeactivatedAndCancelledAgreementAccountIds(
        List<Agreement__c> deactivatedAgreements
    ) {
        Set<Id> deactivatedAgreementsAccountIds = new Set<Id>();
        for (Agreement__c agreement : deactivatedAgreements) {
            if (
                (agreement.Status__c == STATUS_CANCELLED) &&
                (agreement.Deactivation_Date__c <= System.today()) &&
                (agreement.Type__c == AGREEMENT_TYPE_STORE)
            ) {
                deactivatedAgreementsAccountIds.add(agreement.Account__c);
            }
        }
        return deactivatedAgreementsAccountIds;
    }

    /**
     * @description activate the agreements by publishing agreement activation events
     *     LEM-2718: throttling the number of store agreements to activated at one time.
     * @param storeAgreements
     * @param isExisting
     */
    public void publishAgreementActivationEvents(
        List<Agreement__c> storeAgreements,
        Boolean isExisting
    ) {
        if (storeAgreements.isEmpty()) {
            return;
        }
        Set<Id> agreementIds = new Map<Id, Agreement__c>(storeAgreements).keyset();
        Integer agreementChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(AGREEMENT_EVENTS_CHUNK_SIZE)
                .Configuration_Value__c
        );

        if (!isExisting) {
            publishBulkAgreementEvents(
                NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    agreementIds,
                    agreementChunkSize
                )
            );
        } else {
            publishBulkAgreementEventsForExistingProcess(
                NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    agreementIds,
                    agreementChunkSize
                )
            );
        }
    }

    private Map<Id, Agreement__c> createAccidToAgreementsMap(List<Agreement__c> agreements) {
        Map<Id, Agreement__c> accIdToAgreementMap = new Map<Id, Agreement__c>();
        for (Agreement__c eachAgreement : agreements) {
            if (eachAgreement.Account__c != null && eachAgreement.Status__c == ACTIVE_STATUS) {
                accIdToAgreementMap.put(eachAgreement.Account__c, eachAgreement);
            }
        }
        return accIdToAgreementMap;
    }

    /**
     * @description Gets all of the AccountIds from the Sets of Strings.
     * @param stringSet
     * @return Set<Id>
     */
    private Set<Id> getIdSetFromStringSet(Set<String> stringSet) {
        Set<Id> idSet = new Set<Id>();
        for (String idAsString : stringSet) {
            idSet.add(Id.valueOf(idAsString));
        }
        return idSet;
    }

    /**
     * @description Gets all of the AccountIds from the List of Sets of Strings.
     * @param stringSetList
     * @return Set<Id>
     */
    private Set<Id> getAllAccountIds(List<Set<String>> stringSetList) {
        Set<Id> idSet = new Set<Id>();
        for (Set<String> stringSet : stringSetList) {
            for (String stringId : stringSet) {
                idSet.add(Id.valueOf(stringId));
            }
        }
        return idSet;
    }

    /**
     * @description A common method to commit unit of work.
     * @param uow
     */
    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception e) {
            Logger.publish(e, LogEntry.SeverityLevel.HIGH);
        }
    }

    /**
     * @description It creates Agreement ACtivation Event with passed payloads
     * @JIRA# LEM-9902
     * @param payloads
     */
    private void publishBulkAgreementEvents(List<String> payloads) {
        if (payloads == null) {
            return;
        }
        fflib_ISObjectUnitOfWork eventsUOW = Application.UNITOFWORK.newInstance();
        for (String eachPayload : payloads) {
            eventsUOW.registerPublishAfterSuccessTransaction(
                new Agreement_Activation_Event__e(
                    Agreement_Ids__c = eachPayload,
                    Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_ORDER
                )
            );
        }
        commitWork(eventsUOW);
    }

    /**
     * @description It creates Agreement Activation Event with passed payloads for updating merchant services
     * @JIRA #LEM-15980
     * @param payloads
     */
    public void publishBulkMerchantServiceUpdateEvents(List<String> payloads) {
        if (payloads == null) {
            return;
        }
        fflib_ISObjectUnitOfWork eventsUOW = Application.UNITOFWORK.newInstance();
        for (String eachPayload : payloads) {
            eventsUOW.registerPublishAfterSuccessTransaction(
                new Agreement_Activation_Event__e(
                    Agreement_Ids__c = eachPayload,
                    Topic__c = EVENT_TOPIC_UPDATE_MERCHANT_SERVICES
                )
            );
        }
        commitWork(eventsUOW);
    }

    /**
     * @description It creates Agreement Activation Event with passed payloads
     * @param payloads
     */
    private void publishBulkAgreementEventsForExistingProcess(List<String> payloads) {
        if (payloads == null) {
            return;
        }
        fflib_ISObjectUnitOfWork eventsUOW = Application.UNITOFWORK.newInstance();
        for (String eachPayload : payloads) {
            eventsUOW.registerPublishAfterSuccessTransaction(
                new Agreement_Activation_Event__e(
                    Agreement_Ids__c = eachPayload,
                    Topic__c = UPDATE_ACTIVATION_ORDERS_AND_PRODUCTS_FOR_EXISTING_STORES
                )
            );
        }
        commitWork(eventsUOW);
    }

    /**
     * @description Update mx services in single transaction or Platform event based on Records Count
     * @JIRA #LEM-15980
     * @param deactivatedAgreementsList
     * @param isProcessingAsync
     */
    public void updateMxServicesBasedOnRecordsCount(
        List<Agreement__c> deactivatedAgreementsList,
        Boolean isProcessingAsync
    ) {
        if (deactivatedAgreementsList == null) {
            return;
        }
        Set<Id> contractIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> allAccountIdSet = new Set<Id>();
        List<Agreement__c> filteredAgreements = new List<Agreement__c>();
        // Fetch contractIds from deactivatedAgreementsList
        for (Agreement__c agreement : deactivatedAgreementsList) {
            if (!agreement.Expiring_Agmt_Nintex_COO__c) {
                contractIds.add(agreement.Contract__c);
                filteredAgreements.add(agreement);
            }
            allAccountIdSet.add(agreement.Account__c);
        }
        accountIds = getDeactivatedAndCancelledAgreementAccountIds(filteredAgreements);
        if (accountIds == null) {
            return;
        }
        List<Merchant_Service__c> mxServicesList = MerchantSelector.newInstance()
            .selectActiveServicesByAccountIds(accountIds, contractIds);

        if (mxServicesList.size() <= MAX_RECORD_PER_TRANSACTION || isProcessingAsync) {
            //Update Merchant Services
            MerchantServicesService.setMxAgreedToProductValueNo(mxServicesList,  allAccountIdSet);
        } else if (mxServicesList.size() > MAX_RECORD_PER_TRANSACTION && !isProcessingAsync) {
            //Publish event
            publishBulkMerchantServiceUpdateEvents(
                NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    new Map<Id, Agreement__c>(deactivatedAgreementsList).keyset(),
                    AGREEMENT_CHUNK_SIZE
                )
            );
        }
    }

    /**
     * @description It is used to delete churned Mx agreements for the passed contract Ids.
     * Additionally, it also initiates the associated Merchant Services deletion and deactivation of
     * associated Xref records.
     * @JIRA #LEM-23780
     * @param contractIds
     * @return fflib_ISObjectUnitOfWork
     */
    public fflib_ISObjectUnitOfWork deleteChurnedMxAgreements(Set<Id> contractIds) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Set<Id> storeAccountIds = new Set<Id>();
        for (
            Agreement__c eachAgreementForDeletion : AgreementsSelector.newInstance()
                .selectChurnedMxAgreementsByContractIds(contractIds)
        ) {
            storeAccountIds.add(eachAgreementForDeletion.Account__c);
            uow.registerDeleted(eachAgreementForDeletion);
        }
        uow = XrefAndBizRefService.deactivateChurnedMxXrefs(storeAccountIds, uow);
        return uow;
    }
}