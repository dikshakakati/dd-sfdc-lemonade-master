/**
 * @description This is the service class for Change Of Ownership logic
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessiveClassLength')
public inherited sharing class ChangeOfOwnershipServiceImpl implements IChangeOfOwnershipService {
    private static final String EXTERNAL_DB_SOURCE_MDS = 'MDS';
    private static final String BUSINESS_REFERENCE_FRANCHISE = 'Franchise';
    private static final String BUSINESS_REFERENCE_CORPORATE = 'Corporate';
    private static final String BUSINESS_REFERENCE_GRAVEYARD = 'Graveyard';
    private static final String INTEGRATION_STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String INTEGRATION_STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String INTEGRATION_STATUS_READY_FOR_COO_INTEGRATION = 'Ready for COO Integration';
    private static final String INTEGRATION_STATUS_COO_SUCCESS = 'COO Success';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String DEFAULT_TYPE_COO_GRAVEYARD = 'COO Graveyard';
    @testvisible
    private static final String COO_PROCESSED = 'Processed';
    private static final String COO_PROCESS_FAILED = 'Failed';
    private static final String COO_PROCESS_VIA_BATCH = 'Process via Batch Mode';
    private static final String COO_PROCESS_VIA_ASYNC = 'Process via Async Mode';
    private static final Integer ASYNC_GET_STORE_LIMIT = 50;
    private static final String LOG_SERVICE_COO = 'COO Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String SEGMENT_MID_MARKET = 'Mid-Market';
    private static List<IGenericLogEntry> genericLogList = new List<IGenericLogEntry>();

    private enum SegmentTypes {
        ENTERPRISE,
        MID_MARKET,
        SMB
    }
    private static final Map<String, SegmentTypes> SEGMENT_MAPPINGS = new Map<String, SegmentTypes>{
        SEGMENT_ENTERPRISE => SegmentTypes.ENTERPRISE,
        SEGMENT_MID_MARKET => SegmentTypes.MID_MARKET,
        SEGMENT_SMB => SegmentTypes.SMB
    };

    /**
     * @description Generic method to provision Change of Ownership (COO)
     * @param cooProvisioningEventsList
     */
    public void provisionCOO(List<Provisioning_Event__e> cooProvisioningEventsList) {
        if (cooProvisioningEventsList.isEmpty()) {
            return;
        }
        Set<String> requestedGraveyardIds = getRequestedGraveyardIds(cooProvisioningEventsList);
        Set<Id> soldAccountsIdSet = getSoldAccountIds(cooProvisioningEventsList);

        Map<String, Business_Reference__c> requestedGraveyardIdToBusRefMap = getExistingBusinessReferencesByGraveyardId(
            requestedGraveyardIds
        );

        Map<Id, Account> accountsWithActiveXrefMap = new Map<Id, Account>(
            AccountsSelector.newInstance().selectAccountsWithXrefs(soldAccountsIdSet)
        );
        Map<Id, Account> accountsWithInActiveXrefMap = new Map<Id, Account>(
            AccountsSelector.newInstance().selectAccountsWithInActiveXrefs(soldAccountsIdSet)
        );
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        List<Xref__c> xrefsForUpdate = new List<Xref__c>();
        for (Provisioning_Event__e event : cooProvisioningEventsList) {
            //find or create graveyard business Id.
            Business_Reference__c existingGraveyardBusRef = getExistingBusinessReference(
                event,
                requestedGraveyardIdToBusRefMap
            );
            Business_Reference__c newBusinessReference = null;

            List<Id> accountIdList = (List<Id>) JSON.deserialize(event.Accounts__c, List<Id>.class);
            for (Id accountId : accountIdList) {
                Account accountWithActiveXref = accountsWithActiveXrefMap.get(accountId);
                Account accountWithInActiveXref = accountsWithInActiveXrefMap.get(accountId);

                if (!accountWithActiveXref.Xrefs__r.isEmpty()) {
                    xrefsForUpdate.addAll(
                        getXrefList(accountWithActiveXref.Xrefs__r, existingGraveyardBusRef)
                    );
                } else if (!accountWithInActiveXref.Xrefs__r.isEmpty()) {
                    xrefsForUpdate.addAll(
                        getXrefList(accountWithInActiveXref.Xrefs__r, existingGraveyardBusRef)
                    );
                } else {
                    newBusinessReference = createNewBusinessReference(
                        uow,
                        existingGraveyardBusRef,
                        newBusinessReference,
                        accountWithActiveXref,
                        event
                    );
                    createCOOXref(
                        uow,
                        accountWithInactiveXref,
                        existingGraveyardBusRef,
                        newBusinessReference
                    );
                }
            }
        }
        updateXrefsCooProcessingMode(uow, xrefsForUpdate);
        commitWork(uow);
    }

    private static List<Xref__c> getXrefList(
        List<Xref__c> xrefs,
        Business_Reference__c existingGraveyardBusRef
    ) {
        List<Xref__c> returnList = new List<Xref__c>();
        for (Xref__c xref : xrefs) {
            if (existingGraveyardBusRef != null) {
                xref.COO_Graveyard_Id__c = existingGraveyardBusRef.Id;
            }
            if (xref.External_Id_Source__c == EXTERNAL_DB_SOURCE_MDS) {
                returnList.add(xref);
            }
        }
        return returnList;
    }
    private static void updateXrefsCooProcessingMode(
        fflib_ISobjectUnitOfWork uow,
        List<Xref__c> xrefsForUpdate
    ) {
        String cooProcessMode = '';
        if (!xrefsForUpdate.isEmpty()) {
            if (xrefsForUpdate.size() > ASYNC_GET_STORE_LIMIT) {
                cooProcessMode = COO_PROCESS_VIA_BATCH;
            } else if (xrefsForUpdate.size() <= ASYNC_GET_STORE_LIMIT) {
                cooProcessMode = COO_PROCESS_VIA_ASYNC;
            }
        }
        for (Xref__c xref : xrefsForUpdate) {
            Xref__c xrefToUpdate = new Xref__c(Id = xref.Id, Coo_Process__c = cooProcessMode);
            uow.registerDirty(xrefToUpdate);
        }
    }

    /**
     * @description Get the default Business Reference for COO Accounts.
     * This is used by COO, and finds the Business Reference of the Buyer.
     * @param cooSoldAccounts
     * @return Map<Id, Business_Reference__c> sold account to default Business Reference Map
     */
    public Map<Id, Business_Reference__c> getDefaultBusinessReferenceForCOO(
        Set<Id> cooSoldAccounts
    ) {
        //Query Work Orders along with the xrefs in accounts selector
        Map<Id, Account> soldAccountMap = new Map<Id, Account>(
            AccountsSelector.newInstance().selectAccountsWithXrefs(cooSoldAccounts)
        );
        Map<Id, Business_Reference__c> accountIdToDefaultBusRefMap = new Map<Id, Business_Reference__c>();
        Set<String> businessIds = new Set<String>();
        Map<String, Business_Reference__c> matchingKeyToBizRefMap = new Map<String, Business_Reference__c>();
        Map<String, Business_Reference__c> matchingBusinessIdToBizRefMap = new Map<String, Business_Reference__c>();
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        //Divide logic based on Account segment
        for (Account soldAccount : soldAccountMap.values()) {
            String externalBusinessId = getBusinessIdForBusinessReference(soldAccount);
            if (soldAccount.Segment__c == SEGMENT_SMB && externalBusinessId != null) {
                businessIds.add(externalBusinessId);
            }
        }

        //Key to Business Reference, not for SMB
        matchingKeyToBizRefMap = XrefAndBizRefMatchingService.getBusinessReferencesByMatchingKey(
            soldAccountMap.values()
        );
        matchingBusinessIdToBizRefMap = XrefAndBizRefMatchingService.getBusinessReferencesByMatchingBusinessId(
            businessIds
        );
        Business_Vertical__c businessVerticalRx = BusinessVerticalsSelector.newInstance()
            .selectPrimaryVerticalRxRecord()[0];
        for (Account act : soldAccountMap.values()) {
            Business_Reference__c businessRef;
            switch on SEGMENT_MAPPINGS.get(act.Segment__c) {
                when SMB {
                    if (getBusinessIdForBusinessReference(act) != null) {
                        businessRef = matchingBusinessIdToBizRefMap.get(
                            act.WorkOrders[0].ParentWorkOrder.Business_Id__c
                        );
                    } else {
                        businessRef = new Business_Reference__c(
                            CurrencyIsoCode = act.Parent.CurrencyIsoCode,
                            External_Id_Source__c = EXTERNAL_DB_SOURCE_MDS,
                            Business_Name__c = act.Brand__r?.Name,
                            Integration_Status__c = INTEGRATION_STATUS_READY_FOR_INTEGRATION,
                            Auto_Create_Business_Configuration__c = true,
                            Brand__c = act.Brand__c,
                            Business_Vertical__c = businessVerticalRx.Id,
                            Primary_Vertical__c = businessVerticalRx.Primary_Vertical__c,
                            Menu_UI_Type__c = businessVerticalRx.Menu_UI_Type__c
                        );
                        uow.registerNew(businessRef);
                    }
                }
                when ENTERPRISE, MID_MARKET {
                    businessRef = XrefAndBizRefMatchingService.matchTheBizRefWithAccountByExternalSource(
                        act,
                        matchingKeyToBizRefMap,
                        EXTERNAL_DB_SOURCE_MDS
                    );
                }
            }
            commitWork(uow);
            if (businessRef != null) {
                accountIdToDefaultBusRefMap.put(act.Id, businessRef);
            }
        }
        return accountIdToDefaultBusRefMap;
    }

    /**
     * @description LEM-17673: Get Business Id from Business Reference.
     * @param soldAccount
     * @return String
     */
    private String getBusinessIdForBusinessReference(Account soldAccount) {
        String businessId = null;
        if (
            !soldAccount.WorkOrders.isEmpty() &&
            soldAccount.WorkOrders[0].ParentWorkOrder.Business_Id__c != null
        ) {
            //Corporate Flow
            businessId = soldAccount.WorkOrders[0].ParentWorkOrder.Business_Id__c;
        }
        return businessId;
    }

    /**
     * @description Get requested GraveyardIds
     * @param provisioningEvents
     * @return Set<String>
     */
    private static Set<String> getRequestedGraveyardIds(
        List<Provisioning_Event__e> provisioningEvents
    ) {
        Set<String> requestedGraveyardIds = new Set<String>();
        for (Provisioning_Event__e event : provisioningEvents) {
            if (String.isNotBlank(event.COO_Graveyard_Id__c)) {
                requestedGraveyardIds.add(event.COO_Graveyard_Id__c);
            }
        }
        return requestedGraveyardIds;
    }

    /**
     * @description Get the Account Ids of the sold accounts
     * @param provisioningEvents
     * @return Set<Id>
     */
    private static Set<Id> getSoldAccountIds(List<Provisioning_Event__e> provisioningEvents) {
        Set<Id> soldAccountsIdSet = new Set<Id>();
        for (Provisioning_Event__e event : provisioningEvents) {
            List<Id> accountIdList = (List<Id>) JSON.deserialize(event.Accounts__c, List<Id>.class);
            soldAccountsIdSet.addAll(accountIdList);
        }
        return soldAccountsIdSet;
    }

    /**
     * @description Get Existing Business References by GraveyardId
     * @param requestedGraveyardIds
     * @return Map<String, Business_Reference__c>
     */
    private static Map<String, Business_Reference__c> getExistingBusinessReferencesByGraveyardId(
        Set<String> requestedGraveyardIds
    ) {
        Map<String, Business_Reference__c> returnMap = new Map<String, Business_Reference__c>();
        if (!requestedGraveyardIds.isEmpty()) {
            List<Business_Reference__c> existingGraveyardIds = BusinessReferencesSelector.newInstance()
                .selectByGraveyardIds(requestedGraveyardIds);
            //If there are more than 1 take the newest one. Soonest CreatedDate.
            for (Business_Reference__c busRef : existingGraveyardIds) {
                returnMap.put(busRef.External_Id__c, busRef);
            }
        }
        return returnMap;
    }

    /**
     * @description Get Existing Business References by GraveyardId
     * @param event
     * @param requestedGraveyardIdToBusRefMap
     * @return Business_Reference__c or null
     */
    private static Business_Reference__c getExistingBusinessReference(
        Provisioning_Event__e event,
        Map<String, Business_Reference__c> requestedGraveyardIdToBusRefMap
    ) {
        Business_Reference__c returnBusRef = null;
        if (
            String.isNotBlank(event.COO_Graveyard_Id__c) &&
            requestedGraveyardIdToBusRefMap.containsKey(event.COO_Graveyard_Id__c)
        ) {
            returnBusRef = requestedGraveyardIdToBusRefMap.get(event.COO_Graveyard_Id__c);
        }
        return returnBusRef;
    }

    /**
     * @description Creates a new Business Reference if Necessary
     * @param uow
     * @param existingGraveyardBusRef
     * @param newBusinessReference
     * @param soldAccount
     * @param event
     * @return Business_Reference__c
     */
    private static Business_Reference__c createNewBusinessReference(
        fflib_ISobjectUnitOfWork uow,
        Business_Reference__c existingGraveyardBusRef,
        Business_Reference__c newBusinessReference,
        Account soldAccount,
        Provisioning_Event__e event
    ) {
        //Need CurrencyIsoCode of the Account, so we use the one on the first Account in the list.
        if ((existingGraveyardBusRef == null) && (newBusinessReference == null)) {
            String graveyardBusinessName =
                BUSINESS_REFERENCE_GRAVEYARD +
                ' ' +
                soldAccount.Parent.Name;
            newBusinessReference = new Business_Reference__c(
                CurrencyIsoCode = soldAccount.CurrencyIsoCode,
                External_Id__c = String.isNotBlank(event.COO_Graveyard_Id__c)
                    ? event.COO_Graveyard_Id__c
                    : null,
                External_Id_Source__c = EXTERNAL_DB_SOURCE_MDS,
                Business_Name__c = graveyardBusinessName.left(255),
                Default_Type__c = DEFAULT_TYPE_COO_GRAVEYARD,
                Integration_Status__c = INTEGRATION_STATUS_READY_FOR_COO_INTEGRATION,
                Brand__c = soldAccount.Brand__c
            );

            uow.registerNew(newBusinessReference);
        }
        return newBusinessReference;
    }

    /**
     * @description Create new xref, because the account didn't previously have one.
     * @param uow
     * @param soldAccount
     * @param existingGraveyardBusRef
     * @param newBusinessReference
     */
    private static void createCOOXref(
        fflib_ISobjectUnitOfWork uow,
        Account soldAccount,
        Business_Reference__c existingGraveyardBusRef,
        Business_Reference__c newBusinessReference
    ) {
        Xref__c newXref = new Xref__c(
            CurrencyIsoCode = soldAccount.CurrencyIsoCode,
            External_ID_Source__c = EXTERNAL_DB_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            Salesforce_Account_Name__c = soldAccount.Id,
            Integration_Status__c = INTEGRATION_STATUS_WAITING_FOR_BUSINESS
        );

        if (existingGraveyardBusRef != null) {
            newXref.Business_Reference__c = existingGraveyardBusRef.Id;
            if (existingGraveyardBusRef.Integration_Status__c == INTEGRATION_STATUS_COO_SUCCESS) {
                newXref.Integration_Status__c = INTEGRATION_STATUS_READY_FOR_COO_INTEGRATION;
            }
            uow.registerNew(newXref);
        } else {
            uow.registerNew(newXref, Xref__c.Business_Reference__c, newBusinessReference);
        }
    }

    /**
     * @description A common method to commit unit of work.
     * @param unitOfWork
     */
    private static void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();

            GenericLoggerService.publish(genericLogList);
            genericLogList.clear();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_COO,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(unitOfWorkException)
            );
        }
    }

    /**
     * @description this method is used for processing the xref's via Async mode
     * @param xrefs
     */
    public void processCooXrefsMarkedForAsyncProcess(Set<Id> xrefs) {
        List<xref__c> xrefsList = XrefsSelector.newInstance()
            .selectXrefsByIdAndCooProcess(xrefs, new Set<String>{ COO_PROCESS_VIA_ASYNC });
        if (!xrefsList.isEmpty()) {
            getDriveStoreIdsForStores(xrefsList);
        }
    }
    /**
     * @description this method is used for retriveing and processing the xref's based on get store api response
     * @param xrefsList
     */
    public void getDriveStoreIdsForStores(List<Xref__c> xrefsList) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Map<Id, Map<String, String>> xrefIdsToMarkAsFailedMap = new Map<Id, Map<String, String>>();
        Map<Id, Xref__c> xrefIdsToProcessWithGraveyardBusinessRefMap = new Map<Id, Xref__c>();
        Map<Id, String> xrefIdsToProcessWithoutGraveyardBusinessRefMap = new Map<Id, String>();

        IGetStoreService getStoreSvc = new GetStoreServiceImpl();
        for (Xref__c xref : xrefsList) {
            Map<String, String> getStoreApiResponse = getStoreSvc.getDriveStoreId(
                xref.External_Id__c
            );
            String getStoreApiStatus = getStoreApiResponse.get(
                GetStoreServiceImpl.GET_STORE_API_STATUS_MAP_KEY
            );
            if (getStoreApiStatus == GetStoreServiceImpl.GET_STORE_API_STATUS_SUCCESS) {
                String driveStoreId = getStoreApiResponse.get(
                    GetStoreServiceImpl.DRIVE_STORE_ID_MAP_KEY
                );
                if (String.isBlank(driveStoreId)) {
                    xrefIdsToProcessWithGraveyardBusinessRefMap.put(xref.Id, xref);
                } else {
                    xrefIdsToProcessWithoutGraveyardBusinessRefMap.put(xref.Id, driveStoreId);
                }
            } else if (getStoreApiStatus == GetStoreServiceImpl.GET_STORE_API_STATUS_FAILURE) {
                xrefIdsToMarkAsFailedMap.put(xref.Id, getStoreApiResponse);
            }
        }

        if (!xrefIdsToProcessWithoutGraveyardBusinessRefMap.isEmpty()) {
            processCooXrefsWithoutGraveyardBusinessReferences(
                uow,
                xrefIdsToProcessWithoutGraveyardBusinessRefMap
            );
        }

        if (!xrefIdsToProcessWithGraveyardBusinessRefMap.isEmpty()) {
            processCooXrefsWithGraveyardBusinessReferences(
                uow,
                xrefIdsToProcessWithGraveyardBusinessRefMap
            );
        }

        if (!xrefIdsToMarkAsFailedMap.isEmpty()) {
            markXrefsAsFailed(uow, xrefIdsToMarkAsFailedMap);
        }

        commitWork(uow);
    }

    private static void markXrefsAsFailed(
        fflib_ISobjectUnitOfWork uow,
        Map<Id, Map<String, String>> xrefIdsToMarkAsFailedMap
    ) {
        for (Id xrefId : xrefIdsToMarkAsFailedMap.keyset()) {
            Map<String, String> getStoreApiResponse = xrefIdsToMarkAsFailedMap.get(xrefId);
            Xref__c xrefToUpdate = new Xref__c(
                Id = xrefId,
                Coo_Process__c = COO_PROCESS_FAILED,
                Integration_Message__c = getStoreApiResponse.get(
                    GetStoreServiceImpl.GET_STORE_API_RESPONSE_MAP_KEY
                )
            );
            genericLogList.add(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_COO,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logMessage(
                        xrefToUpdate.Coo_Process__c + ' ' + xrefToUpdate.Integration_Message__c
                    )
            );
            uow.registerDirty(xrefToUpdate);
        }
    }

    private static void processCooXrefsWithoutGraveyardBusinessReferences(
        fflib_ISobjectUnitOfWork uow,
        Map<Id, String> xrefIdsToProcessWithoutGraveyardBusinessRefMap
    ) {
        for (Id xrefId : xrefIdsToProcessWithoutGraveyardBusinessRefMap.keyset()) {
            Xref__c xrefToUpdate = new Xref__c(
                Id = xrefId,
                Coo_Process__c = COO_PROCESSED,
                Integration_Status__c = INTEGRATION_STATUS_READY_FOR_COO_INTEGRATION,
                Drive_Store_Id__c = xrefIdsToProcessWithoutGraveyardBusinessRefMap.get(xrefId)
            );
            uow.registerDirty(xrefToUpdate);
        }
    }

    private static Map<Id, Business_Reference__c> getStoreAccountIdToGraveyardBusinessRefMap(
        Map<Id, xref__c> xrefIdsToProcessWithGraveyardBusinessRefMap
    ) {
        Map<Id, String> storeAccountIdToExpectedGraveyardBusinessRefNameMap = new Map<Id, String>();
        for (Xref__c xref : xrefIdsToProcessWithGraveyardBusinessRefMap.values()) {
            storeAccountIdToExpectedGraveyardBusinessRefNameMap.put(
                xref.Salesforce_Account_Name__c,
                BUSINESS_REFERENCE_GRAVEYARD + ' ' + getParentName(xref)
            );
        }

        Map<String, Business_Reference__c> businessRefNameToObjectMap = new Map<String, Business_Reference__c>();
        for (
            Business_Reference__c busRef : BusinessReferencesSelector.newInstance()
                .selectByBusRefName(storeAccountIdToExpectedGraveyardBusinessRefNameMap.values())
        ) {
            if (!businessRefNameToObjectMap.containsKey(busRef.Business_Name__c)) {
                businessRefNameToObjectMap.put(busRef.Business_Name__c, busRef);
            }
        }

        Map<Id, Business_Reference__c> storeAccountIdToGraveyardBusinessRefMap = new Map<Id, Business_Reference__c>();
        for (Id accountId : storeAccountIdToExpectedGraveyardBusinessRefNameMap.keyset()) {
            String graveyardBusinessrefName = storeAccountIdToExpectedGraveyardBusinessRefNameMap.get(
                accountId
            );
            if (businessRefNameToObjectMap.containsKey(graveyardBusinessrefName)) {
                storeAccountIdToGraveyardBusinessRefMap.put(
                    accountId,
                    businessRefNameToObjectMap.get(graveyardBusinessrefName)
                );
            }
        }
        return storeAccountIdToGraveyardBusinessRefMap;
    }

    private static Map<String, Business_reference__c> getRequestedGraveyardBusinessReferences(
        Map<Id, xref__c> xrefIdsToProcessWithGraveyardBusinessRefMap
    ) {
        Map<String, Business_reference__c> retMap = new Map<String, Business_reference__c>();
        Set<string> requestedBusinessReferencesExternalIds = new Set<String>();
        for (Xref__c xref : xrefIdsToProcessWithGraveyardBusinessRefMap.values()) {
            if (String.isNotBlank(xref.COO_Graveyard_Id__c)) {
                requestedBusinessReferencesExternalIds.add(xref.COO_Graveyard_Id__c);
            }
        }
        if (!requestedBusinessReferencesExternalIds.isEmpty()) {
            retMap = getExistingBusinessReferencesByGraveyardId(
                requestedBusinessReferencesExternalIds
            );
        }
        return retMap;
    }

    private static void processCooXrefsWithGraveyardBusinessReferences(
        fflib_ISobjectUnitOfWork uow,
        Map<Id, xref__c> xrefIdsToProcessWithGraveyardBusinessRefMap
    ) {
        Map<Id, Business_Reference__c> storeAccountIdToGraveyardBusinessRefMap = getStoreAccountIdToGraveyardBusinessRefMap(
            xrefIdsToProcessWithGraveyardBusinessRefMap
        );
        Map<String, Business_Reference__c> requestedGraveyardIdToBusRefMap = getRequestedGraveyardBusinessReferences(
            xrefIdsToProcessWithGraveyardBusinessRefMap
        );
        Map<String, Business_Reference__c> newBusinessRefMap = new Map<String, Business_Reference__c>();
        for (Id xrefId : xrefIdsToProcessWithGraveyardBusinessRefMap.keyset()) {
            Xref__c xrefToProcess = xrefIdsToProcessWithGraveyardBusinessRefMap.get(xrefId);
            Id storeAccountId = xrefToProcess.Salesforce_Account_Name__c;
            Business_Reference__c existingGraveyardBusinessRef = null;

            if (
                String.isNotBlank(xrefToProcess.COO_Graveyard_Id__c) &&
                requestedGraveyardIdToBusRefMap.containsKey(xrefToProcess.COO_Graveyard_Id__c)
            ) {
                existingGraveyardBusinessRef = requestedGraveyardIdToBusRefMap.get(
                    xrefToProcess.COO_Graveyard_Id__c
                );
            } else if (storeAccountIdToGraveyardBusinessRefMap.containskey(storeAccountId)) {
                existingGraveyardBusinessRef = storeAccountIdToGraveyardBusinessRefMap.get(
                    storeAccountId
                );
            }

            String graveyardBusinessName =
                BUSINESS_REFERENCE_GRAVEYARD +
                ' ' +
                getParentName(xrefToProcess);
            Business_Reference__c newGraveyardBusinessRef = null;

            if (existingGraveyardBusinessRef == null) {
                if (newBusinessRefMap.containsKey(graveyardBusinessName)) {
                    newGraveyardBusinessRef = newBusinessRefMap.get(graveyardBusinessName);
                } else {
                    newGraveyardBusinessRef = createNewGraveyardBusinessReference(
                        uow,
                        xrefIdsToProcessWithGraveyardBusinessRefMap.get(xrefId)
                    );
                    newBusinessRefMap.put(graveyardBusinessName, newGraveyardBusinessRef);
                }
            }

            Xref__c xrefToUpdate = new Xref__c(
                Id = xrefId,
                Coo_Process__c = COO_PROCESSED,
                Integration_Status__c = INTEGRATION_STATUS_WAITING_FOR_BUSINESS
            );
            if (existingGraveyardBusinessRef != null) {
                xrefToUpdate.Business_Reference__c = existingGraveyardBusinessRef.Id;
            }

            if (
                (existingGraveyardBusinessRef != null) &&
                (existingGraveyardBusinessRef.Integration_Status__c ==
                INTEGRATION_STATUS_COO_SUCCESS)
            ) {
                xrefToUpdate.Integration_Status__c = INTEGRATION_STATUS_READY_FOR_COO_INTEGRATION;
            }

            uow.registerDirty(xrefToUpdate);
            //Set the relationship to the new Business Ref if it was just created.
            if (newGraveyardBusinessRef != null) {
                uow.registerRelationship(
                    xrefToUpdate,
                    Xref__c.Business_Reference__c,
                    newGraveyardBusinessRef
                );
            }
        }
    }

    private static Business_Reference__c createNewGraveyardBusinessReference(
        fflib_ISobjectUnitOfWork uow,
        Xref__c xref
    ) {
        //Need CurrencyIsoCode of the Account, so we use the one on the first Account in the list.
        String graveyardBusinessName = BUSINESS_REFERENCE_GRAVEYARD + ' ' + getParentName(xref);
        Business_Reference__c newBusinessReference = new Business_Reference__c(
            CurrencyIsoCode = xref.Salesforce_Account_name__r.CurrencyIsoCode,
            External_Id_Source__c = EXTERNAL_DB_SOURCE_MDS,
            Business_Name__c = graveyardBusinessName.left(255),
            Default_Type__c = DEFAULT_TYPE_COO_GRAVEYARD,
            Integration_Status__c = INTEGRATION_STATUS_READY_FOR_COO_INTEGRATION
        );
        uow.registerNew(newBusinessReference);
        return newBusinessReference;
    }

    private static string getParentName(Xref__c xref) {
        return String.isNotBlank(xref.Salesforce_Account_name__r.ParentId)
            ? xref.Salesforce_Account_name__r.Parent.Name
            : xref.Salesforce_Account_name__r.Name;
    }
}