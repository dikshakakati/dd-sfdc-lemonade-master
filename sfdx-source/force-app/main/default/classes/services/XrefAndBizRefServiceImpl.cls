/**
 * @author Deloitte
 * @date 07/11/2022
 * @description Service Implementation for Xrefs and Business Reference.
 */
public class XrefAndBizRefServiceImpl implements IXrefAndBizRefService {
    private static final String CREATION_METHOD_MANUAL = 'Manual';
    private static final String CREATION_METHOD_AUTOMATIC = 'Automatic';
    private static final String EXTERNAL_DB_SOURCE_DRIVE = 'DriveDb';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final Set<String> INELIGIBLE_BUSINESS_REFERENCE_INTEGRATION_STATUSES = new Set<String>{
        'COO Success',
        'Ready for COO Integration'
    };
    private static final String INTEGRATION_STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String INTEGRATION_STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    private static final string STORE_RECORD_TYPE = 'Store';
    private static final string BUSINESS_RECORD_TYPE = 'Business';
    private static final String LOG_SERVICE_XREF = 'Xref and Businessref creation';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final string NEW_STATUS = 'NEW';
    private static final String PROVISIONING_STATUS_PROVISIONING_FAILED = 'Provisioning Failed';
    private static final String PROVISIONING_STATUS_READY_FOR_PROVISIONING = 'Ready for Provisioning';
    private static final List<String> PROVISIONING_STATUS_ELIGIBLE_FOR_BUSINESS_REFERENCE_CREATION = new List<String>{
        PROVISIONING_STATUS_PROVISIONING_FAILED,
        PROVISIONING_STATUS_READY_FOR_PROVISIONING
    };
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String XREF_STATUS_INACTIVE = 'Inactive';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String SOURCE_SSMO = 'SSMO';
    private static final String AUTO_ACTIVATIONS_SUB_TYPE = 'Auto-Activations';
    private static final String NET_NEW_SUB_TYPE = 'Net-new Business';
    private static final String DRIVE_WITH_MPBZID_YES = 'Yes';
    private Set<Id> activeXrefIds;
    private Map<Id, String> accountIdToMpBzId;
    private static final String EXTERNAL_SOURCE_MDS = 'MDS';
    private Map<String, Business_Reference__c> businessIdToBusinessReference;
    // To store existing business reference id with account id
    private Map<Id, Business_Reference__c> existingBusinessReferenceByAccountId;
    private Map<String, Business_Reference__c> existingBusinessReferenceBySMB;

    // To store instance of newly created business reference record for all store account xref records
    private Map<Id, Business_Reference__c> newBusinessReferenceByAccountId;
    private Map<String, Business_Reference__c> newBusinessReferenceByBrandId;
    private Map<Id, String> storeAccountIdToBusinessId;

    // To store existing xref id with account id
    private Map<Id, Id> xrefIdByParentAccountId;
    private Set<Id> brandIds;
    private String bizRefStatus;
    private String xRefStatus;
    private Boolean isAutoCreate;
    Map<Id, Id> storeAccountIdToParentWorkOrderId;
    Set<Id> parentWorkOrderIds = new Set<Id>();

    /**
     * @description Default constructor for this class.
     */
    public XrefAndBizRefServiceImpl() {
        this.activeXrefIds = new Set<Id>();
        this.accountIdToMpBzId = new Map<Id, String>();
        this.brandIds = new Set<Id>();
        this.businessIdToBusinessReference = new Map<String, Business_Reference__c>();
        this.existingBusinessReferenceByAccountId = new Map<Id, Business_Reference__c>();
        this.existingBusinessReferenceBySMB = new Map<String, Business_Reference__c>();
        this.newBusinessReferenceByAccountId = new Map<Id, Business_Reference__c>();
        this.newBusinessReferenceByBrandId = new Map<String, Business_Reference__c>();
        this.storeAccountIdToBusinessId = new Map<Id, String>();
        this.xrefIdByParentAccountId = new Map<Id, Id>();
        this.storeAccountIdToParentWorkOrderId = new Map<Id, Id>();
        this.parentWorkOrderIds = new Set<Id>();
    }

    /**
     * @description It is used to create Xrefs and Business Refs for Accounts Provisioning using
     * the passed Mp Bz Ids.
     * @param accountIdToMpBzId
     * @param bizRefStatus
     * @param xRefStatus
     * @param isAutoCreate
     * @param isParentWorkOrder
     */
    public void createXrefsAndBusinessRefsByMpBzIds(
        Map<Id, String> accountIdToMpBzId,
        String bizRefStatus,
        String xRefStatus,
        Boolean isAutoCreate,
        Boolean isParentWorkOrder
    ) {
        if (accountIdToMpBzId == null || accountIdToMpBzId.isEmpty()) {
            return;
        }
        this.accountIdToMpBzId.putAll(accountIdToMpBzId);
        createXRefsAndBusinessRefs(
            accountIdToMpBzId.keySet(),
            bizRefStatus,
            xRefStatus,
            isAutoCreate,
            isParentWorkOrder
        );
    }

    /**
     * @description To create unique xref and business reference records
     * @param workOrderAccountIds
     * @param bizRefStatus
     * @param xRefStatus
     * @param isAutoCreate
     * @param isParentWorkOrder
     */
    public void createXRefsAndBusinessRefs(
        Set<Id> workOrderAccountIds,
        String bizRefStatus,
        String xRefStatus,
        Boolean isAutoCreate,
        Boolean isParentWorkOrder
    ) {
        this.bizRefStatus = bizRefStatus;
        this.xRefStatus = xRefStatus;
        this.isAutoCreate = isAutoCreate;

        // To store accounts where xref and business ref records will be created or updated
        List<Account> workOrderAccounts = new List<Account>();
        Set<Id> childAndParentAccountIds = new Set<Id>();

        findUniqueXrefRecords(workOrderAccountIds, workOrderAccounts, childAndParentAccountIds);
        findUniqueBusinessReferenceRecords(childAndParentAccountIds);

        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Account eachAccountObj : workOrderAccounts) {
            if (eachAccountObj.Franchise_Parent__c != null) {
                createXrefsAndBizRefsForCorporateAndFranchiseHierarchy(
                    eachAccountObj,
                    eachAccountObj.Franchise_Parent__c,
                    uow,
                    isParentWorkOrder
                );
            } else {
                createXrefsAndBizRefsForCorporateAndFranchiseHierarchy(
                    eachAccountObj,
                    eachAccountObj.ParentId,
                    uow,
                    isParentWorkOrder
                );
            }
        }
        commitWork(uow);
    }

    /**
     * @description It is used to create Xrefs and Business Refs for SMB Accounts Provisioning.
     * @param workOrderAccountIds
     * @param bizRefStatus
     * @param xRefStatus
     * @param isAutoCreate
     * @param isParentWorkOrder
     */
    public void createXrefsAndBusinessRefsForSMB(
        Set<Id> workOrderAccountIds,
        String bizRefStatus,
        String xRefStatus,
        Boolean isAutoCreate,
        Boolean isParentWorkOrder
    ) {
        this.bizRefStatus = bizRefStatus;
        this.xRefStatus = xRefStatus;
        this.isAutoCreate = isAutoCreate;
        // To store accounts where xref and business ref records will be created or updated
        Business_Vertical__c restaurantBusinessVertical;
        List<Account> workOrderAccounts = new List<Account>();
        Set<Id> childAndParentAccountIds = new Set<Id>();
        findUniqueXrefRecords(workOrderAccountIds, workOrderAccounts, childAndParentAccountIds);
        collectExistingBusinessReferencesByBusinessIdsForSMB();
        collectExistingBusinessReferencesByBrandIdsForSMB(workOrderAccountIds);
        if (!workOrderAccounts.isEmpty()) {
            List<Business_Vertical__c> businessVerticalsRx = BusinessVerticalsSelector.newInstance()
                .selectPrimaryVerticalRxRecord();
            restaurantBusinessVertical = businessVerticalsRx[0];
        }
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Account eachAccountObj : workOrderAccounts) {
            createXrefsAndBizRefsForSMB(
                eachAccountObj,
                eachAccountObj.ParentId,
                restaurantBusinessVertical,
                uow,
                isParentWorkOrder
            );
        }
        commitWork(uow);
    }

    /**
     * @description It is used to create Business Reference record based on passed details.
     * @param businessReferenceInstance
     * @param isParentWorkOrder
     * @return String
     */
    private String calculateXrefStatus(
        Business_Reference__c businessReferenceInstance,
        Boolean isParentWorkOrder
    ) {
        return businessReferenceInstance.Integration_Status__c == INTEGRATION_STATUS_SUCCESS &&
            !isParentWorkOrder
            ? INTEGRATION_STATUS_READY_FOR_INTEGRATION
            : xRefStatus;
    }

    /**
     * @description To create map of unique business reference records based on Brand Ids.
     * @param workOrderAccountIds
     */
    private void collectExistingBusinessReferencesByBrandIdsForSMB(Set<Id> workOrderAccountIds) {
        Set<String> workOrderIdsToBeQueried = new Set<String>();
        Set<Id> allAccountIds = getStoreAccountIdsByParentWorkOrder(workOrderAccountIds);
        for (Id eachWorkOrderId : parentWorkOrderIds) {
            workOrderIdsToBeQueried.add(Id.valueOf(eachWorkOrderId));
        }
        for (
            Xref__c eachXrefObj : XrefsSelector.newInstance()
                .selectMDSXrefsByAccountIdsAndParentWorkOrderIds(
                    allAccountIds,
                    workOrderIdsToBeQueried
                )
        ) {
            if (eachXrefObj.Salesforce_Account_Name__r?.Brand__c == null) {
                continue;
            }
            // Storing unique xref records
            xrefIdByParentAccountId.put(eachXrefObj.Salesforce_Account_Name__c, eachXrefObj.Id);
            if (
                eachXrefObj.Business_Reference__c != null &&
                !INELIGIBLE_BUSINESS_REFERENCE_INTEGRATION_STATUSES.contains(
                    eachXrefObj?.Business_Reference__r?.Integration_Status__c
                )
            ) {
                Business_Reference__c bizRef = new Business_Reference__c(
                    Id = eachXrefObj.Business_Reference__c,
                    Integration_Status__c = eachXrefObj.Business_Reference__r.Integration_Status__c
                );
                // Storing unique business reference records
                existingBusinessReferenceBySMB.put(
                    storeAccountIdToParentWorkOrderId.get(eachXrefObj.Salesforce_Account_Name__c) +
                        SEPARATOR +
                        eachXrefObj.Salesforce_Account_Name__r.Brand__c,
                    bizRef
                );
            }
        }
    }

    /**
     * @description It is used to get Store Accounts by Parent Work Order.
     * @param storeAccountIds
     * @return Set<Id>
     */
    private Set<Id> getStoreAccountIdsByParentWorkOrder(Set<Id> storeAccountIds) {
        Set<Id> allAccountIds = new Set<Id>();
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectBusinessReferenceCreationEligibleWorkOrdersByAccountIds(storeAccountIds)
        ) {
            if (
                PROVISIONING_STATUS_ELIGIBLE_FOR_BUSINESS_REFERENCE_CREATION.contains(
                    eachWorkOrder.ParentWorkOrder.Provisioning_Status__c
                )
            ) {
                parentWorkOrderIds.add(eachWorkOrder.ParentWorkOrderId);
            }
        }
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectByParentWorkOrderIds(parentWorkOrderIds)
        ) {
            storeAccountIdToParentWorkOrderId.put(
                eachWorkOrder.AccountId,
                eachWorkOrder.ParentWorkOrderId
            );
            allAccountIds.add(eachWorkOrder.AccountId);
        }
        return allAccountIds;
    }

    /**
     * @description To fetch existing Business Reference records
     * based on Business Ids.
     */
    private void collectExistingBusinessReferencesByBusinessIdsForSMB() {
        for (
            Business_Reference__c eachBusinessReference : BusinessReferencesSelector.newInstance()
                .selectBusRefByExternalId(new Set<String>(storeAccountIdToBusinessId.values()))
        ) {
            if (
                INELIGIBLE_BUSINESS_REFERENCE_INTEGRATION_STATUSES.contains(
                    eachBusinessReference.Integration_Status__c
                )
            ) {
                continue;
            }
            businessIdToBusinessReference.put(
                eachBusinessReference.External_ID__c,
                eachBusinessReference
            );
        }
    }

    /**
     * @description It is used to collect the parent Work Order and Xref details
     * associated to the passed store account.
     * @param storeAccount
     */
    private void collectXrefsAndWorkOrdersDetailsByAccount(Account storeAccount) {
        for (Xref__c eachXref : storeAccount.Xrefs__r) {
            if (
                eachXref.Xref_Status__c != XREF_STATUS_INACTIVE ||
                (eachXref.Xref_Status__c == XREF_STATUS_INACTIVE &&
                eachXref.Record_Source__c == SOURCE_SSMO)
            ) {
                xrefIdByParentAccountId.put(eachXref.Salesforce_Account_Name__c, eachXref.Id);
            }
            if (
                eachXref.Xref_Status__c == XREF_STATUS_ACTIVE &&
                eachXref.Integration_Status__c == INTEGRATION_STATUS_SUCCESS
            ) {
                activeXrefIds.add(eachXref.Id);
            }
        }
        for (WorkOrder eachWorkOrder : storeAccount.WorkOrders) {
            if (eachWorkOrder?.ParentWorkOrder?.Business_Id__c != null) {
                storeAccountIdToBusinessId.put(
                    storeAccount.Id,
                    eachWorkOrder?.ParentWorkOrder?.Business_Id__c
                );
            }
        }
    }

    /**
     * @description To create unique xref and business reference records for Corporate And Franchise Hierarchy
     * @param eachAccountObj
     * @param parentAccount
     * @param uow
     * @param isParentWorkOrder
     */
    private void createXrefsAndBizRefsForCorporateAndFranchiseHierarchy(
        Account eachAccountObj,
        Id parentAccount,
        fflib_ISobjectUnitOfWork uow,
        Boolean isParentWorkOrder
    ) {
        String businessName = String.isNotBlank(eachAccountObj.Brand__r.Name)
            ? eachAccountObj.Brand__r.Name
            : eachAccountObj.Legal_Business_Name__c;
        if (isEligibleForNewBusinessReferenceCreation(eachAccountObj, parentAccount)) {
            // If this account or its franchise parent does not have a business reference record tagged create new business reference and xref record.
            if (newBusinessReferenceByAccountId.get(parentAccount) == null) {
                Business_Reference__c newBusinessRef = new Business_Reference__c(
                    CurrencyIsoCode = eachAccountObj.CurrencyIsoCode,
                    External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                    Business_Name__c = businessName,
                    Integration_Status__c = bizRefStatus,
                    Auto_Create_Business_Configuration__c = isAutoCreate,
                    Brand__c = eachAccountObj.Brand__c
                );
                setDriveWithholdingFields(eachAccountObj, newBusinessRef);
                uow.registerNew(newBusinessRef);

                newBusinessReferenceByAccountId.put(parentAccount, newBusinessRef);
            }

            uow.registerNew(
                new Xref__c(
                    CurrencyIsoCode = eachAccountObj.CurrencyIsoCode,
                    External_ID_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                    Xref_Status__c = XREF_STATUS_ACTIVE,
                    Salesforce_Account_Name__c = eachAccountObj.Id,
                    Integration_Status__c = xRefStatus
                ),
                Xref__c.Business_Reference__c,
                newBusinessReferenceByAccountId.get(parentAccount)
            );
        } else {
            //If this account or its franchise parent has a business reference record tagged use existing record.
            Business_Reference__c businessReferenceRec = existingBusinessReferenceByAccountId.get(
                    eachAccountObj.Id
                ) != null
                ? existingBusinessReferenceByAccountId.get(eachAccountObj.Id)
                : existingBusinessReferenceByAccountId.get(parentAccount);

            if (
                businessReferenceRec.Integration_Status__c == INTEGRATION_STATUS_SUCCESS &&
                !isParentWorkOrder
            ) {
                xRefStatus = INTEGRATION_STATUS_READY_FOR_INTEGRATION;
            }
            Business_Reference__c businessReferenceToUpdate = new Business_Reference__c(
                Id = businessReferenceRec.Id,
                CurrencyIsoCode = eachAccountObj.CurrencyIsoCode,
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Business_Name__c = businessName,
                Auto_Create_Business_Configuration__c = isAutoCreate
            );
            setDriveWithholdingFields(eachAccountObj, businessReferenceToUpdate);
            uow.registerDirty(businessReferenceToUpdate);

            //Insert or Update existing xref record
            uow.registerUpsert(
                new Xref__c(
                    Id = xrefIdByParentAccountId.get(eachAccountObj.Id),
                    Business_Reference__c = businessReferenceRec.Id,
                    CurrencyIsoCode = eachAccountObj.CurrencyIsoCode,
                    External_ID_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                    Xref_Status__c = XREF_STATUS_ACTIVE,
                    Salesforce_Account_Name__c = eachAccountObj.Id,
                    Integration_Status__c = xRefStatus
                )
            );
        }
    }

    /**
     * @description To create unique xref and business reference records for SMB Account Segment
     * @param eachAccountObj
     * @param parentAccount
     * @param restaurantBusinessVertical
     * @param uow
     * @param isParentWorkOrder
     */
    private void createXrefsAndBizRefsForSMB(
        Account eachAccountObj,
        Id parentAccount,
        Business_Vertical__c restaurantBusinessVertical,
        fflib_ISobjectUnitOfWork uow,
        Boolean isParentWorkOrder
    ) {
        Id parentWorkOrderId = storeAccountIdToParentWorkOrderId.get(eachAccountObj.Id);
        if (
            xrefIdByParentAccountId.containsKey(eachAccountObj.Id) &&
            activeXrefIds.contains(xrefIdByParentAccountId.get(eachAccountObj.Id))
        ) {
            return;
        }
        String businessName = String.isNotBlank(eachAccountObj.Brand__r.Name)
            ? eachAccountObj.Brand__r.Name
            : '';
        Boolean createBusinessReference = isEligibleForBusinessReferenceCreation(eachAccountObj);
        Business_Reference__c businessReferenceInstance;
        if (createBusinessReference) {
            createBusinessReferenceForSMB(
                eachAccountObj,
                businessName,
                restaurantBusinessVertical,
                uow
            );
            businessReferenceInstance = newBusinessReferenceByBrandId.get(
                parentWorkOrderId + SEPARATOR + eachAccountObj.Brand__c
            );
        } else if (
            storeAccountIdToBusinessId.containsKey(eachAccountObj.Id) &&
            businessIdToBusinessReference.containsKey(
                storeAccountIdToBusinessId.get(eachAccountObj.Id)
            )
        ) {
            businessReferenceInstance = businessIdToBusinessReference.get(
                storeAccountIdToBusinessId.get(eachAccountObj.Id)
            );
        } else if (
            existingBusinessReferenceBySMB.get(
                parentWorkOrderId + SEPARATOR + eachAccountObj.Brand__c
            ) != null
        ) {
            businessReferenceInstance = existingBusinessReferenceBySMB.get(
                parentWorkOrderId + SEPARATOR + eachAccountObj.Brand__c
            );
        }
        if (!createBusinessReference) {
            Business_Reference__c businessReferenceToUpdate = new Business_Reference__c(
                Id = businessReferenceInstance.Id,
                CurrencyIsoCode = eachAccountObj.Parent.CurrencyIsoCode,
                External_Id_Source__c = EXTERNAL_SOURCE_MDS,
                Business_Name__c = businessName,
                Created_Source_Parent_Work_Order_Id__c = parentWorkOrderId
            );
            uow.registerDirty(businessReferenceToUpdate);
        }
        xRefStatus = calculateXrefStatus(businessReferenceInstance, isParentWorkOrder);
        upsertXrefsForSMB(businessReferenceInstance, eachAccountObj, uow, xRefStatus);
    }

    /**
     * @description It is used to create Business Reference record based on passed details.
     * @param accountDetails
     * @param businessName
     * @param restaurantBusinessVertical
     * @param uow
     */
    private void createBusinessReferenceForSMB(
        Account accountDetails,
        String businessName,
        Business_Vertical__c restaurantBusinessVertical,
        fflib_ISobjectUnitOfWork uow
    ) {
        if (
            newBusinessReferenceByBrandId.get(
                storeAccountIdToParentWorkOrderId.get(accountDetails.Id) +
                    SEPARATOR +
                    accountDetails.Brand__c
            ) == null
        ) {
            Business_Reference__c businessReferenceInstance = new Business_Reference__c(
                CurrencyIsoCode = accountDetails.Parent.CurrencyIsoCode,
                External_Id_Source__c = EXTERNAL_SOURCE_MDS,
                Business_Name__c = businessName,
                Integration_Status__c = bizRefStatus,
                Auto_Create_Business_Configuration__c = isAutoCreate,
                Brand__c = accountDetails.Brand__c,
                Business_Vertical__c = restaurantBusinessVertical.Id,
                Primary_Vertical__c = restaurantBusinessVertical.Primary_Vertical__c,
                Menu_UI_Type__c = restaurantBusinessVertical.Menu_UI_Type__c
            );
            if (storeAccountIdToBusinessId.containsKey(accountDetails.Id)) {
                businessReferenceInstance.External_Id__c = storeAccountIdToBusinessId.get(
                    accountDetails.Id
                );
            }
            uow.registerNew(businessReferenceInstance);
            newBusinessReferenceByBrandId.put(
                storeAccountIdToParentWorkOrderId.get(accountDetails.Id) +
                    SEPARATOR +
                    accountDetails.Brand__c,
                businessReferenceInstance
            );
        }
    }

    /**
     * @description To create map of unique xRef records.
     * @param workOrderAccountIds
     * @param workOrderAccounts
     * @param childAndParentAccountIds
     */
    private void findUniqueXrefRecords(
        Set<Id> workOrderAccountIds,
        List<Account> workOrderAccounts,
        Set<Id> childAndParentAccountIds
    ) {
        // Get work order accounts and there parent accounts
        for (
            Account eachAccountObj : AccountsSelector.newInstance()
                .selectAccountsWithBrandName(workOrderAccountIds)
        ) {
            childAndParentAccountIds.add(eachAccountObj.Id);
            if (eachAccountObj.Brand__c != null) {
                brandIds.add(eachAccountObj.Brand__c);
            }
            if (eachAccountObj.Franchise_Parent__c != null) {
                childAndParentAccountIds.add(eachAccountObj.Franchise_Parent__c);
            } else if (eachAccountObj.ParentId != null) {
                childAndParentAccountIds.add(eachAccountObj.ParentId);
            }
            workOrderAccounts.add(eachAccountObj);
            collectXrefsAndWorkOrdersDetailsByAccount(eachAccountObj);
        }
    }

    /**
     * @description To create map of unique business reference records.
     * @param childAndParentAccountIds
     */
    private void findUniqueBusinessReferenceRecords(Set<Id> childAndParentAccountIds) {
        for (
            Xref__c eachXrefObj : XrefsSelector.newInstance()
                .selectDriveDbXrefsBySalesforceAccountName(childAndParentAccountIds)
        ) {
            // Storing unique xref records
            xrefIdByParentAccountId.put(eachXrefObj.Salesforce_Account_Name__c, eachXrefObj.Id);

            if (eachXrefObj.Business_Reference__c != null) {
                Business_Reference__c bizRef = new Business_Reference__c(
                    Id = eachXrefObj.Business_Reference__c,
                    Integration_Status__c = eachXrefObj.Business_Reference__r.Integration_Status__c
                );

                // Storing unique business reference records
                existingBusinessReferenceByAccountId.put(
                    eachXrefObj.Salesforce_Account_Name__c,
                    bizRef
                );

                if (eachXrefObj.Salesforce_Account_Name__r?.Franchise_Parent__c != null) {
                    existingBusinessReferenceByAccountId.put(
                        eachXrefObj.Salesforce_Account_Name__r.Franchise_Parent__c,
                        bizRef
                    );
                } else if (
                    eachXrefObj.Account_Record_Type__c == STORE_RECORD_TYPE &&
                    eachXrefObj.Salesforce_Account_Name__r?.ParentId != null
                ) {
                    existingBusinessReferenceByAccountId.put(
                        eachXrefObj.Salesforce_Account_Name__r.ParentId,
                        bizRef
                    );
                }
            }
        }
    }

    /**
     * @description A common method to commit unit of work.
     * @param unitOfWork
     */
    private void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE_XREF,
                    LOG_DOMAIN_PROVISIONING,
                    GenericLogEntry.SeverityLevel.HIGH
                )
            );
        }
    }

    /**
     * @description It is used to determine Account's eligibility for Business Reference creation.
     * @param accountDetails
     * @return Boolean
     */
    private Boolean isEligibleForBusinessReferenceCreation(Account accountDetails) {
        return !((storeAccountIdToBusinessId.containsKey(accountDetails.Id) &&
        (businessIdToBusinessReference.containsKey(
            storeAccountIdToBusinessId.get(accountDetails.Id)
        ))) ||
        existingBusinessReferenceBySMB.get(
            storeAccountIdToParentWorkOrderId.get(accountDetails.Id) +
                SEPARATOR +
                accountDetails.Brand__c
        ) != null);
    }

    /**
     * @description It is used to determine Account's eligibility for new
     * Business Reference creation.
     * @param currentAccount
     * @param parentAccountId
     * @return Boolean
     */
    private Boolean isEligibleForNewBusinessReferenceCreation(
        Account currentAccount,
        Id parentAccountId
    ) {
        return (currentAccount.Segment__c == SEGMENT_SMB &&
            currentAccount.Record_Type_Name__c == BUSINESS_RECORD_TYPE &&
            existingBusinessReferenceByAccountId.get(currentAccount.Id) == null) ||
            (currentAccount.Segment__c != SEGMENT_SMB &&
            existingBusinessReferenceByAccountId.get(currentAccount.Id) == null &&
            existingBusinessReferenceByAccountId.get(parentAccountId) == null);
    }

    /**
     * @description It sets the "Drive Withholding" fields on the passed Business Reference record.
     * @param accountInstance
     * @param businessReferenceInstance
     */
    private void setDriveWithholdingFields(
        Account accountInstance,
        Business_Reference__c businessReferenceInstance
    ) {
        //Account exists with MP BZ Id
        if (!accountIdToMpBzId.containsKey(accountInstance.Id)) {
            return;
        }
        businessReferenceInstance.External_Id__c = accountIdToMpBzId.get(accountInstance.Id);
        businessReferenceInstance.Drive_with_Mp_Bz_Id__c = DRIVE_WITH_MPBZID_YES;
        businessReferenceInstance.Last_Completed_Step__c = null;
        businessReferenceInstance.Integration_Message__c = null;
        businessReferenceInstance.Integration_Status__c = this.bizRefStatus;
    }

    /**
     * @description It is used to create/update Xref records based on passed details.
     * @param businessReferenceInstance
     * @param storeAccount
     * @param uow
     * @param xRefStatus
     */
    private void upsertXrefsForSMB(
        Business_Reference__c businessReferenceInstance,
        Account storeAccount,
        fflib_ISobjectUnitOfWork uow,
        String xRefStatus
    ) {
        if (xrefIdByParentAccountId.get(storeAccount.Id) == null) {
            uow.registerNew(
                new Xref__c(
                    CurrencyIsoCode = storeAccount.CurrencyIsoCode,
                    External_ID_Source__c = EXTERNAL_SOURCE_MDS,
                    Xref_Status__c = XREF_STATUS_ACTIVE,
                    Salesforce_Account_Name__c = storeAccount.Id,
                    Integration_Status__c = xRefStatus
                ),
                Xref__c.Business_Reference__c,
                businessReferenceInstance
            );
        } else {
            uow.registerDirty(
                new Xref__c(
                    Id = xrefIdByParentAccountId.get(storeAccount.Id),
                    CurrencyIsoCode = storeAccount.CurrencyIsoCode,
                    External_ID_Source__c = EXTERNAL_SOURCE_MDS,
                    Xref_Status__c = XREF_STATUS_ACTIVE,
                    Salesforce_Account_Name__c = storeAccount.Id,
                    Integration_Status__c = xRefStatus
                ),
                Xref__c.Business_Reference__c,
                businessReferenceInstance
            );
        }
    }

    /**
     * @description It is used to deactivate Xrefs for the passed Store Account Ids.
     * @JIRA# LEM-23780
     * @param storeAccountIds
     * @param uow
     * @return fflib_ISObjectUnitOfWork
     */
    public fflib_ISObjectUnitOfWork deactivateChurnedMxXrefs(
        Set<Id> storeAccountIds,
        fflib_ISObjectUnitOfWork uow
    ) {
        for (
            Xref__c eachXrefToInactivateStatus : XrefsSelector.newInstance()
                .selectActiveXrefsBySalesforceAccountName(storeAccountIds)
        ) {
            eachXrefToInactivateStatus.Xref_Status__c = XREF_STATUS_INACTIVE;
            uow.registerDirty(eachXrefToInactivateStatus);
        }
        return uow;
    }
}