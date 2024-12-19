/**
 * @author atg
 * @date   09/29/2022
 * @description This is the service implementation class for Xref__c integration.
 */
public inherited sharing class XrefIntegrationServiceImpl implements IXrefIntegrationService {
    private static final String EXTERNAL_NOTIFIER_EVENT_XREF_INTEGRATION = 'XREF_INTEGRATE';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String STATUS_FAILURE = 'Failure';
    private static final String STATUS_COO_SUCCESS = 'COO Success';
    private static final String STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String STATUS_READY_FOR_COO_INTEGRATION = 'Ready for COO Integration';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String XREF_STATUS_INACTIVE = 'Inactive';
    private static final String EXTERNAL_DB_SOURCE_MDS = 'MDS';
    private static final String EXTERNAL_DB_SOURCE_DRIVE = 'DriveDb';
    private static final String CANNOT_FIND_DEFAULT_BUSINESS_REF = 'Default Business Reference cannot be found.';
    private static final String LOG_SERVICE_XREF_SERVICE = 'Xref Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final String SEGEMENT_SMB = 'SMB';

    /**
     * @description create platform Events to integrate Xref__c objects
     * @param xrefList
     * @param topic
     */
    public void createIntegrationPlatformEvents(List<Xref__c> xrefList, String topic) {
        if (xrefList.isEmpty()) {
            return;
        }
        Set<Id> xrefIdSet = new Set<Id>();
        for (Xref__c xref : xrefList) {
            xrefIdSet.add(xref.Id);
        }
        List<Xref__c> xrefsWithAllInfo = XrefsSelector.newInstance().selectAllInfoNeededForPlatformEvent(xrefIdSet);

        //LEM-4502 Don't call commit work for each platform event.
        List<String> payloadsList = new List<String>();
        for (Xref__c xref : xrefsWithAllInfo) {
            payloadsList.add(JSON.serialize(new List<XrefIntegration>{new XrefIntegration(xref)}));
        }
        ExternalNotifierEventsService.publishEventsFromList(topic, payloadsList);
    }

    /**
     * @description when Business_Reference__c records are updated to Success, update any xref records that
     * had a status of 'Waiting for Business'
     * @param businessReferenceList
     * @param changeOfOwnership
     */
    public void updateStatusToReadyForIntegration(
        List<Business_Reference__c> businessReferenceList,
        Boolean changeOfOwnership
    ) {
        String compareAgainstStatus = changeOfOwnership ? STATUS_COO_SUCCESS : STATUS_SUCCESS;
        String statusToSet = changeOfOwnership
            ? STATUS_READY_FOR_COO_INTEGRATION
            : STATUS_READY_FOR_INTEGRATION;

        Set<Id> busRefIdSet = new Set<Id>();
        for (Business_Reference__c busRef : businessReferenceList) {
            if (busRef.Integration_Status__c == compareAgainstStatus) {
                busRefIdSet.add(busRef.Id);
            }
        }

        List<Xref__c> xrefsToUpdate = XrefsSelector.newInstance()
            .selectAllMatchingBusinessReference(busRefIdSet);

        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Xref__c xref : xrefsToUpdate) {
            if (xref.Integration_Status__c != STATUS_WAITING_FOR_BUSINESS) {
                continue;
            }
            Xref__c updatedXref = new Xref__c(Id = xref.Id, Integration_Status__c = statusToSet);
            uow.registerDirty(updatedXref);
        }
        commitWork(uow);
    }

    /**
     * @description when an Xref record has been deactivated, we will receive a COO Success Integration Status.
     * @param xrefList
     */
    public void processCOOSuccess(List<Xref__c> xrefList) {
        if (xrefList.isEmpty()) {
            return;
        }
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Set<Id> accountIdsToFindBusinessRefs = new Set<Id>();
        for (Xref__c xref : xrefList) {
            accountIdsToFindBusinessRefs.add(xref.Salesforce_Account_Name__c);
            Xref__c updatedXref = new Xref__c(Id = xref.Id, Xref_Status__c = XREF_STATUS_INACTIVE);
            uow.registerDirty(updatedXref);
        }

        Map<Id, Business_Reference__c> accountIdDefaultBusRefIdMap = ChangeOfOwnershipService.getDefaultBusinessReferenceForCOO(
            accountIdsToFindBusinessRefs
        );
        for (Xref__c xref : xrefList) {
            //Create New Xref
            String integrationStatusToSet = STATUS_FAILURE;
            String integrationFailureMessage = CANNOT_FIND_DEFAULT_BUSINESS_REF;
            Id businessReferenceId = null;
            if (accountIdDefaultBusRefIdMap.containsKey(xref.Salesforce_Account_Name__c)) {
                Business_Reference__c defaultBusRef = accountIdDefaultBusRefIdMap.get(
                    xref.Salesforce_Account_Name__c
                );
                businessReferenceId = defaultBusRef.Id;
                integrationStatusToSet = defaultBusRef.Integration_Status__c == STATUS_SUCCESS
                    ? STATUS_READY_FOR_INTEGRATION
                    : STATUS_WAITING_FOR_BUSINESS;
                integrationFailureMessage = null;
            }
            Xref__c newXref = new Xref__c(
                Business_Reference__c = businessReferenceId,
                Salesforce_Account_Name__c = xref.Salesforce_Account_Name__c,
                CurrencyIsoCode = xref.CurrencyIsoCode,
                External_ID_Source__c = EXTERNAL_DB_SOURCE_MDS,
                Xref_Status__c = XREF_STATUS_ACTIVE,
                Inactive_Xref__c = xref.Id,
                Integration_Message__c = integrationFailureMessage,
                Integration_Status__c = integrationStatusToSet
            );

            uow.registerNew(newXref);
        }

        commitWork(uow);
    }
    /**
     * @description [LEM-3170] Update the Existing Xrefs which are already Provisioned.
     * @param accountsIdSet
     */
    public void updateExistingXrefsForAmendaments(Set<Id> accountsIdSet) {
        Set<Id> businessReferenceIds = new Set<Id>();
        if (accountsIdSet.isEmpty()) {
            return;
        }
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for (
            Xref__c xref : XrefsSelector.newInstance().selectBySalesforceAccountName(accountsIdSet)
        ) {
            //LEM-4566 Do not reset DriveDB Xrefs or Business Refs on Amendment.
            if (xref.External_ID_Source__c != EXTERNAL_DB_SOURCE_DRIVE) {
                businessReferenceIds.add(xref.Business_Reference__c);
                xref.Integration_Status__c = STATUS_WAITING_FOR_BUSINESS;
                uow.registerDirty(xref);
            }
        }

        for (Id businessReferenceId : businessReferenceIds) {
            uow.registerDirty(
                new Business_Reference__c(
                    Id = businessReferenceId,
                    Integration_Status__c = STATUS_READY_FOR_INTEGRATION
                )
            );
        }

        commitWork(uow);
    }

    /**
     * @description A common method to commit unit of work.
     * @param unitOfWork
     */
    private void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE_XREF_SERVICE,LOG_DOMAIN_PROVISIONING,GenericLogEntry.SeverityLevel.HIGH
                ).logException(ex)
            );
        }
        }
    /**
     * @description Update the TotalNoOfActiveDriveStoresCalculate__c & TotalNoOfActiveMarketplaceStoreCalculate__c fields on Business Account
     * @param xrefList
     */
    public void updateBusinessAccountsForXrefs(List<Xref__c> xrefList) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Set<Id> storeAccountIdSet = new Set<Id>();
        List<Account> lstAccountToBeUpdated = new List<Account>();
        for (Xref__c objXref : xrefList) {
            //LEM-22629 - Adding Segment check to stop running these calculations for 'ENT' Segment
            // till the long term fix is deployed (TODO: LEM-22661).
            if (objXref.Account_Segment__c == SEGEMENT_SMB) {
                storeAccountIdSet.add(objXref.Salesforce_Account_Name__c);
            }
        }
        if (!storeAccountIdSet.isEmpty()) {
            List<Account> parentAccountList = AccountsSelector.newInstance()
                .selectBusinessAccountIdsFromStoreAccountId(storeAccountIdSet);
            set<Id> setParentId = new Set<Id>();
            for (Account objAccount : parentAccountList) {
                setParentId.add(objAccount.ParentId);
            }
            List<Account> accountsWithXrefs = AccountsSelector.newInstance()
                .selectAccountsWithMDSXrefs(setParentId);
            List<Account> accountsWithNonMDSXrefs = AccountsSelector.newInstance()
                .selectAccountsWithNonMDSXrefs(setParentId);
            Map<Id, List<Id>> accountIdToListOfMDSstoreAccountMap = new Map<Id, List<Id>>();
            Map<Id, List<Id>> accountIdToListOfNonMDSstoreAccountMap = new Map<Id, List<Id>>();
            if (accountsWithXrefs != null) {
                accountIdToListOfMDSstoreAccountMap = constructMapOfAccountIdToXrefs(
                    accountsWithXrefs
                );
            }
            if (accountsWithNonMDSXrefs != null) {
                accountIdToListOfNonMDSstoreAccountMap = constructMapOfAccountIdToXrefs(
                    accountsWithNonMDSXrefs
                );
            }
            Aggregate[] accountSumOfChildStoreCount = AccountsSelector.newInstance()
                .selectSumOfChildStoreCount(setParentId);
            Map<Id, Aggregate> mapChildStoreCountsByAccountId = Aggregate.mapBy(
                'Id',
                accountSumOfChildStoreCount
            );
            for (Id accountId : setParentId) {
                Account objAccount = new Account(Id = accountId);
                objAccount.TotalNoOfActiveDriveStoresCalculate__c = calculateActiveDriveStores(
                    accountIdToListOfNonMDSstoreAccountMap,
                    mapChildStoreCountsByAccountId,
                    accountId
                );
                objAccount.TotalNoOfActiveMarketplaceStoreCalculate__c = calculateActiveMPStores(
                    accountIdToListOfMDSstoreAccountMap,
                    mapChildStoreCountsByAccountId,
                    accountId
                );
                lstAccountToBeUpdated.add(objAccount);
                uow.registerDirty(lstAccountToBeUpdated);
            }
            uow.commitWork();
        }
    }
    /**
     * @description constructMapOfAccountIdToXrefs
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
     * @description calculateActiceDriveStores
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
     * @description calculateActiceMPStores
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
            totalNumberOfActiveMPStores = summarizeActiveMDSXREFs(
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
     * @description To get Active Drive store count
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
     * @description check if null
     * @param value
     * @param defaultValue
     * @return Object
     */
    private Object ifNull(Object value, Object defaultValue) {
        if (value != null) {
            return value;
        }
        return defaultValue;
    }
}