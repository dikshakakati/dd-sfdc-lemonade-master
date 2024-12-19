/**
 * @description This is the service class for Account provisioning logic
 */

public inherited sharing class AccountsProvisioningServiceImpl implements IAccountsProvisioningService {
    private static final String CANNOT_FIND_BUS_REF_ERROR_MESSAGE = 'A Business Reference with the following criteria could not be found: ';
    private static final String DASH_STRING = '-'; //Make the matching criteria easier to read for the error message.
    private static final String CREATION_METHOD_MANUAL = 'Manual';
    private static final String CREATION_METHOD_AUTOMATIC = 'Automatic';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String INACTIVE = 'Inactive';
    private static final Set<String> INELIGIBLE_WORK_ORDERS = new Set<String>{
        'Dead',
        'Onboarding Complete'
    };
    private static final String INTEGRATION_STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String INTEGRATION_STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String INTEGRATION_STATUS_READY_FOR_COO_INTEGRATION = 'Ready for COO Integration';
    private static final String INTEGRATION_STATUS_FAILURE = 'Failure';
    private static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    private static final String INTEGRATION_STATUS_COO_SUCCESS = 'COO Success';
    private static final String EXTERNAL_DB_SOURCE_DRIVE = 'DriveDb';
    private static final String EXTERNAL_DB_SOURCE_MDS = 'MDS';
    private static final String ORDER_BACKENDSYSTEM_DRIVEDB = 'DriveDB';
    private static final string STORE_RECORD_TYPE = 'Store';
    private static final string BUSINESS_RECORD_TYPE = 'Business';
    private static final string NEW_STATUS = 'NEW';
    private static final List<String> XREF_EXTERNAL_DB_SOURCES = new List<String>{
        'MDS',
        'MDS- Catering'
    };
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String BUSINESS_REFERENCE_CORPORATE = 'Corporate';
    private static final String BUSINESS_REFERENCE_FRANCHISE = 'Franchise';
    private static final String AUTO_ACTIVATIONS_SUB_TYPE = 'Auto-Activations';
    private static final String NET_NEW_SUB_TYPE = 'Net-new Business';
    private static final String BUSINESS_REFERENCE_GRAVEYARD = 'Graveyard';
    private static final String LOG_SERVICE_ACCOUNT_SERVICE = 'Account Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';

    private enum CREATION_METHOD {
        MANUAL,
        AUTOMATIC
    }

    private static Map<String, CREATION_METHOD> creationMethodMap = new Map<String, CREATION_METHOD>{
        'Manual' => CREATION_METHOD.MANUAL,
        'Automatic' => CREATION_METHOD.AUTOMATIC
    };
    private static Set<Id> businessReferenceIds;
    private static Boolean isAmendmentProvisioning;
    private static Map<Id, String> storeAccountIdToBusinessId;

    //To initialize static variables.
    static {
        businessReferenceIds = new Set<Id>();
        isAmendmentProvisioning = false;
        storeAccountIdToBusinessId = new Map<Id, String>();
    }

    /**
     * @description Generic method to provision Marketplace accounts by creation method
     * @param accountIdsByCreationMethod
     */
    public static void provisionMarketplaceAccountsByCreationMethod(
        Map<String, Set<Id>> accountIdsByCreationMethod
    ) {
        if (accountIdsByCreationMethod.isEmpty()) {
            return;
        }
        Set<Id> matchingSMBAccountIds = new Set<Id>();
        if (accountIdsByCreationMethod.containsKey(CREATION_METHOD_AUTOMATIC)) {
            collectSMBWorkOrdersDetails(
                accountIdsByCreationMethod.get(CREATION_METHOD_AUTOMATIC),
                matchingSMBAccountIds
            );
            if (!matchingSMBAccountIds.isEmpty()) {
                createXrefAndBizRefForSMB(matchingSMBAccountIds);
            }
            if (
                matchingSMBAccountIds.isEmpty() ||
                (!matchingSMBAccountIds.isEmpty() &&
                !matchingSMBAccountIds.containsAll(
                    accountIdsByCreationMethod.get(CREATION_METHOD_AUTOMATIC)
                ))
            ) {
                accountIdsByCreationMethod.get(CREATION_METHOD_AUTOMATIC)
                    .removeAll(matchingSMBAccountIds);
                provisionAccountsWithAutomaticCreationMethod(
                    accountIdsByCreationMethod.get(CREATION_METHOD_AUTOMATIC)
                );
            }
        }
        if (accountIdsByCreationMethod.containsKey(CREATION_METHOD_MANUAL)) {
            provisionAccountsWithManualCreationMethod(
                accountIdsByCreationMethod.get(CREATION_METHOD_MANUAL)
            );
        }
    }

    /**
     * @description It is used for creation of Xref and BizRef for SMB Accounts.
     * @JIRA# LEM-13551
     * @param matchingSMBAccountIds
     */
    private static void createXrefAndBizRefForSMB(Set<Id> matchingSMBAccountIds) {
        if (matchingSMBAccountIds.isEmpty()) {
            return;
        }
        Set<Id> accountIdsWithoutBusinessIds = new Set<Id>();
        /*
            LEM-18435: 'isAmendmentProvisioning' check is added to not create new Xref
                when Xref already exists on Store and update the existing Xref for SMB Scenario.
            LEM-18690: Store Accounts with Business Id value on parent Work Order are processed
                to fetch existing Business Reference and associate to Xref.
        */
        if (isAmendmentProvisioning) {
            provisionAccountsWithAutomaticCreationMethod(matchingSMBAccountIds);
        } else {
            accountIdsWithoutBusinessIds.addAll(matchingSMBAccountIds);
            accountIdsWithoutBusinessIds.removeAll(storeAccountIdToBusinessId.keySet());
            if (!accountIdsWithoutBusinessIds.isEmpty()) {
                XrefAndBizRefService.createXrefsAndBusinessRefsForSMB(
                    accountIdsWithoutBusinessIds,
                    INTEGRATION_STATUS_READY_FOR_INTEGRATION,
                    INTEGRATION_STATUS_WAITING_FOR_BUSINESS,
                    false,
                    false
                );
            }
            if (!storeAccountIdToBusinessId.isEmpty()) {
                provisionAccountsWithAutomaticCreationMethod(storeAccountIdToBusinessId.keySet());
            }
        }
    }

    /**
     * @description Generic method for provisioning the amendments through existing Xrefs.
     * @param accountIdsByCreationMethod
     * @param isAmendment
     */
    public static void provisionMarketplaceAccountsByCreationMethod(
        Map<String, Set<Id>> accountIdsByCreationMethod,
        Boolean isAmendment
    ) {
        isAmendmentProvisioning = isAmendment;
        provisionMarketplaceAccountsByCreationMethod(accountIdsByCreationMethod);
    }

    /**
     * @description manually provision accounts with manual creation method
     * @param accountsToProvision
     */
    private static void provisionAccountsWithManualCreationMethod(Set<Id> accountsToProvision) {
        if (accountsToProvision == null) {
            return;
        }
        updateIntegrationStatusOnActiveXrefs(
            XrefsSelector.newInstance().selectBySalesforceAccountName(accountsToProvision)
        );
    }

    /**
     * @description Provision accounts with Automatic creation method
     * @param accountsToProvision
     */
    private static void provisionAccountsWithAutomaticCreationMethod(Set<Id> accountsToProvision) {
        if (accountsToProvision.isEmpty()) {
            return;
        }
        processMarketPlaceWorkOrders(accountsToProvision);
    }

    /**
     * @description LEM-2306 Process Marketplace work Orders to Create Xrefs and Business Reference Records
     * @param accountIdSet
     */
    private static void processMarketPlaceWorkOrders(Set<Id> accountIdSet) {
        Map<Id, Set<String>> accountIdWithBackEndSystems = new Map<Id, Set<String>>();
        Set<String> orderBackEndSystemsWithoutDriveDB; // = new Set<String>();
        for (
            Order eachOrder : OrdersSelector.newInstance().selectOrdersByAccountIds(accountIdSet)
        ) {
            if (string.isNotBlank(eachOrder.Backend_Systems__c)) {
                orderBackEndSystemsWithoutDriveDB = new Set<String>();
                orderBackEndSystemsWithoutDriveDB.addAll(eachOrder.Backend_Systems__c.split(';'));
                if (orderBackEndSystemsWithoutDriveDB.contains(ORDER_BACKENDSYSTEM_DRIVEDB)) {
                    orderBackEndSystemsWithoutDriveDB.remove(ORDER_BACKENDSYSTEM_DRIVEDB);
                    orderBackEndSystemsWithoutDriveDB.remove('');
                }
                //LEM-5355 Do not set empty set for already existing accounts.
                if (accountIdWithBackEndSystems.containsKey(eachOrder.AccountId)) {
                    accountIdWithBackEndSystems.get(eachOrder.AccountId)
                        .addAll(orderBackEndSystemsWithoutDriveDB);
                } else {
                    accountIdWithBackEndSystems.put(
                        eachOrder.AccountId,
                        orderBackEndSystemsWithoutDriveDB
                    );
                }
            }
        }
        findMatchingXrefsForAccountIds(accountIdWithBackEndSystems);
    }

    /**
     * @description LEM-2306 Process to find the Matching Xrefs for Accounts With Activation Orders.
     * @param accountIdWithBackEndSystems
     */
    private static void findMatchingXrefsForAccountIds(
        Map<Id, Set<String>> accountIdWithBackEndSystems
    ) {
        Map<Id, Set<String>> externalIdSourceWithAccountId = new Map<Id, Set<String>>();
        Set<String> accountPrimaryVerticals = new Set<String>();
        Map<Id, Xref__c> activeMDSXefsOnAutomaticWorkOrders = new Map<Id, Xref__c>();
        Set<String> externalIdsourcesSet = new Set<String>();
        List<Account> storeAccountsToCreateXref = new List<Account>();
        if (accountIdWithBackEndSystems.isEmpty()) {
            return;
        }
        for (
            Account accObj : AccountsSelector.newInstance()
                .selectAccountsWithXrefs(accountIdWithBackEndSystems.keySet())
        ) {
            storeAccountsToCreateXref.add(accObj);
            accountPrimaryVerticals.add(accObj.Primary_Vertical__c);
            externalIdSourceWithAccountId.put(accObj.Id, new Set<String>());
            externalIdsourcesSet.addAll(accountIdWithBackEndSystems.get(accObj.Id));
            if (!accObj.Xrefs__r.isEmpty()) {
                for (Xref__c xrefObj : accObj.Xrefs__r) {
                    if (isAccountEligibleForReprovisioning(accObj) || isAmendmentProvisioning) {
                        activeMDSXefsOnAutomaticWorkOrders.put(xrefObj.Id, xrefObj);
                    }
                    externalIdsourcesSet.remove(xrefObj.External_ID_Source__c);
                }
                if (externalIdSourceWithAccountId.containsKey(accObj.Id)) {
                    externalIdSourceWithAccountId.get(accObj.Id).addAll(externalIdsourcesSet);
                }
            } else {
                //Add eachSource if there is no Xref for the give AccountId
                externalIdSourceWithAccountId.put(
                    accObj.Id,
                    accountIdWithBackEndSystems.get(accObj.Id)
                );
            }
        }
        if (!isAmendmentProvisioning) {
            createXrefsForAccounts(
                externalIdSourceWithAccountId,
                getMatchingBusinessRefernces(storeAccountsToCreateXref)
            );
        }
        updateIntegrationStatusOnActiveXrefs(activeMDSXefsOnAutomaticWorkOrders.values());
    }

    /**
     * @description LEM-2306 Process to Create Xrefs and Business Reference Records
     * @param externalIdSourceWithAccountIdMap
     * @param businessRefMap
     */
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
    private static void createXrefsForAccounts(
        Map<Id, Set<String>> externalIdSourceWithAccountIdMap,
        Map<String, Business_Reference__c> businessRefMap
    ) {
        Set<Id> accountIdSet = new Set<Id>();
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        if (externalIdSourceWithAccountIdMap.isEmpty()) {
            return;
        }
        accountIdSet.addAll(externalIdSourceWithAccountIdMap.keySet());
        if (!accountIdSet.isEmpty()) {
            for (
                Account accountVar : AccountsSelector.newInstance()
                    .selectAccountsWithXrefs(accountIdSet)
            ) {
                if (externalIdSourceWithAccountIdMap.get(accountVar.Id).size() > 0) {
                    for (String eachSource : externalIdSourceWithAccountIdMap.get(accountVar.Id)) {
                        Business_Reference__c businessObj;
                        if (storeAccountIdToBusinessId.containsKey(accountVar.Id)) {
                            businessObj = businessRefMap.get(
                                storeAccountIdToBusinessId.get(accountVar.Id)
                            );
                        } else {
                            businessObj = XrefAndBizRefMatchingService.matchTheBizRefWithAccountByExternalSource(
                                accountVar,
                                businessRefMap,
                                eachSource
                            );
                        }
                        String integrationMessage = '';
                        if (businessRefMap != null) {
                            integrationMessage = XrefAndBizRefMatchingService.getBizRefMatchingErrorDisplayMessage(
                                accountVar,
                                eachSource
                            );
                        }
                        Xref__c xrefObj = new Xref__c();
                        xrefObj.Salesforce_Account_Name__C = accountVar.Id;
                        xrefObj.CurrencyIsoCode = accountVar.CurrencyIsoCode;
                        xrefObj.Xref_Status__c = XREF_STATUS_ACTIVE;
                        xrefObj.External_ID_Source__c = eachSource;
                        xrefObj.Business_Reference__c = businessObj != null ? businessObj.Id : null;
                        xrefObj.Integration_Status__c = getIntegrationStatus(businessObj);
                        xrefObj.Integration_Message__c = integrationMessage;
                        uow.registerNew(xrefObj);
                    }
                }
            }
        }

        commitWork(uow);
    }

    private static String getIntegrationStatus(Business_Reference__c businessObj) {
        String integrationStatus;
        if (businessObj == null) {
            integrationStatus = INTEGRATION_STATUS_FAILURE;
        } else if (
            businessObj != null &&
            businessObj.Integration_Status__c == INTEGRATION_STATUS_SUCCESS
        ) {
            integrationStatus = INTEGRATION_STATUS_READY_FOR_INTEGRATION;
        } else {
            businessReferenceIds.add(businessObj.Id);
            integrationStatus = INTEGRATION_STATUS_WAITING_FOR_BUSINESS;
        }
        return integrationStatus;
    }

    /**
     * @description It is used to collect Business References based on Business Id or matching key.
     * @JIRA# LEM-18690
     * @param storeAccountsToCreateXref
     * @return Map<String, Business_Reference__c>
     */
    private static Map<String, Business_Reference__c> getMatchingBusinessRefernces(
        List<Account> storeAccountsToCreateXref
    ) {
        Map<String, Business_Reference__c> businessRefMap = new Map<String, Business_Reference__c>();
        if (storeAccountIdToBusinessId.isEmpty()) {
            businessRefMap = XrefAndBizRefMatchingService.getBusinessReferencesByMatchingKey(
                storeAccountsToCreateXref
            );
        } else {
            businessRefMap = XrefAndBizRefMatchingService.getBusinessReferencesByMatchingBusinessId(
                new Set<String>(storeAccountIdToBusinessId.values())
            );
        }
        return businessRefMap;
    }

    /**
     * @description It checks whether the passed Account is eligible to re-trigger provisioning.
     * @JIRA# LEM-11254
     * @param accountToValidate
     * @return Boolean
     */
    public static Boolean isAccountEligibleForReprovisioning(Account accountToValidate) {
        return accountToValidate.Activation_Status__c == INACTIVE &&
            (accountToValidate.Most_Recent_Activation_Date__c == null) &&
            (accountToValidate.Most_Recent_Deactivation_Date__c == null);
    }

    /**
     * @description A common method to commit unit of work.
     * @param unitOfWork
     */
    private static void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_ACCOUNT_SERVICE,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(unitOfWorkException)
            );
        }
    }

    /**
     * @description It is used to update Xref’s Integration Status to the passed value and returns
     * the Ids of Business Reference associated with the passed Xrefs.
     * @JIRA# LEM-11254
     * @param xrefsToUpdate
     */
    private static void updateIntegrationStatusOnActiveXrefs(List<Xref__c> xrefsToUpdate) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Xref__c eachXref : xrefsToUpdate) {
            if (eachXref.External_ID_Source__c != EXTERNAL_DB_SOURCE_MDS) {
                continue;
            }
            eachXref.Integration_Status__c = getIntegrationStatus(eachXref.Business_Reference__r);
            uow.registerDirty(eachXref);
        }
        updateIntegrationStatusOnBusinessReferences(
            businessReferenceIds,
            INTEGRATION_STATUS_READY_FOR_INTEGRATION,
            uow
        );
        commitWork(uow);
    }

    /**
     * @description It is used to update Business Reference's Integration Status to the passed value.
     * @JIRA# LEM-11254
     * @param businessReferenceIds
     * @param bizRefIntegrationStatusToUpdate
     * @param uow
     */
    private static void updateIntegrationStatusOnBusinessReferences(
        Set<Id> businessReferenceIds,
        String bizRefIntegrationStatusToUpdate,
        fflib_ISobjectUnitOfWork uow
    ) {
        if (businessReferenceIds == null || businessReferenceIds.isEmpty()) {
            return;
        }
        for (Id businessReferenceId : businessReferenceIds) {
            uow.registerDirty(
                new Business_Reference__c(
                    Id = businessReferenceId,
                    Integration_Status__c = bizRefIntegrationStatusToUpdate
                )
            );
        }
    }

    /**
     * @description It is used to get all Account's Ids with Segment as 'SMB'.
     * @JIRA# LEM-13551
     * @param workOrderAccountIds
     * @param matchingSMBAccountIds
     */
    private static void collectSMBWorkOrdersDetails(
        Set<Id> workOrderAccountIds,
        Set<Id> matchingSMBAccountIds
    ) {
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrdersBySegment(workOrderAccountIds)
        ) {
            if (eachWorkOrder != null) {
                matchingSMBAccountIds.add(eachWorkOrder.AccountId);
                if (
                    eachWorkOrder?.ParentWorkOrder?.Business_Id__c != null &&
                    !INELIGIBLE_WORK_ORDERS.contains(eachWorkOrder.Status)
                ) {
                    storeAccountIdToBusinessId.put(
                        eachWorkOrder.AccountId,
                        eachWorkOrder.ParentWorkOrder.Business_Id__c
                    );
                }
            }
        }
    }
}