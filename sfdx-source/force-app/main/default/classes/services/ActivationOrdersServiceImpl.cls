/**
 * @author atg
 * @date   05/23/2022
 * @description This is the service implementation class for Activation Orders related logic.
 *              Activation Orders and Activation OrderItems are used integrating at the store level.
 *              We don't need opportunities and quotes for the children store accounts, only the Parent Business Accounts.
 *              Multiple Jira tickets have been added to the logic here, so removing PMD CyclomaticComplexity error.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class ActivationOrdersServiceImpl implements IActivationOrdersService {
    public static final String ACTIVE = 'Active';
    public static final String ACTIVATED = 'Activated';
    private static final String XREF_EXTERNAL_SOURCE_DRIVE = 'DriveDb';
    private static final String XREF_EXTERNAL_SOURCE_MARKETPLACE = 'MDS';
    private static final String XREF_EXTERNAL_SOURCE_MARKETPLACE_CATERING = 'MDS - Catering';
    private static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    private static final String AGREED_TO_SERVICES_DRIVE = 'Drive';
    private static final string FRANCHISE_ENROLLMENT_PROCESS = 'Auto-Enroll';
    private static final String MX_AGREED_YES = 'Yes';
    private static final String MX_AGREED_NO = 'No';
    private static final String COLON = ':';
    private static final String HYPEN = '-';
    private static final String MARKETPLACE = 'Marketplace';

    /**
     * @description create Activation Orders for Store Agreements
     * @param agreements
     * @param appliedArp
     */
    public void createActivationOrdersAndProducts(
        List<Agreement__c> agreements,
        Boolean appliedArp
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        Map<String, Id> accountAgreementStringContractIdMap = new Map<String, Id>();
        Map<Id, Id> accountIdToFranchiseParentIdMap = new Map<Id, Id>();
        Map<Id, String> accountIdToAgreedToServicesMap = new Map<Id, String>();
        Set<Id> agreementIdSet = new Set<Id>();
        Map<Id, Boolean> amendedAccountIdToAutoProvisionValueMap = new Map<Id, Boolean>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id, Map<String, List<String>>> accountIdsToSelectedPckgIdToDeselectedProdListMap = getAccountIdsToSelectedPckgIdToDeselectedProdListMap(
            agreements
        );
        for (Agreement__c storeAgreement : agreements) {
            if (isStoreAgreementEligible(storeAgreement)) {
                //This function should not be called from the Before Insert context, Id will be null
                String agreementId = storeAgreement.Id == null
                    ? ''
                    : String.valueOf(storeAgreement.Id);
                String accountAgreementKey =
                    String.valueOf(storeAgreement.Account__c) +
                    HYPEN +
                    agreementId +
                    COLON +
                    String.valueOf(appliedArp).toLowercase();
                accountAgreementStringContractIdMap.put(
                    accountAgreementKey,
                    storeAgreement.Contract__c
                );
                agreementIdSet.add(storeAgreement.Id);
                accountIdToAgreedToServicesMap.put(
                    storeAgreement.Account__c,
                    storeAgreement.Agreed_To_Services__c
                );
                accountIdSet.add(storeAgreement.Account__c);
                if (storeAgreement.Activation_Order_Created__c == false && !appliedArp) {
                    Agreement__c updatedAgreement = new Agreement__c(
                        Id = storeAgreement.Id,
                        Activation_Order_Created__c = true
                    );
                    uow.registerDirty(updatedAgreement);
                } else {
                    //This is a Contract Amendment.
                    if (
                        storeAgreement.Contract__r.Franchise_Enrollment_Process__c !=
                        FRANCHISE_ENROLLMENT_PROCESS && !appliedArp
                    ) {
                        accountIdToFranchiseParentIdMap.put(
                            storeAgreement.Account__c,
                            storeAgreement.Account__r.Franchise_Parent__c
                        );
                    }
                    amendedAccountIdToAutoProvisionValueMap.putAll(
                        createAccountIdToAutoProvisionMap(storeAgreement)
                    );
                }
            }
        }

        List<Agreement__c> agreementListOppInfo = AgreementsSelector.newInstance()
            .selectOpportunityInfoByIds(agreementIdSet);
        Map<Id, Map<String, String>> accountIdToDeselectedServicesMap = createAccountIdToDeselectedServiceMap(
            agreementListOppInfo
        );

        Boolean workComitted = false;
        if (!accountAgreementStringContractIdMap.isEmpty()) {
            workComitted = ActivationOrderCreationService.createActivationOrdersForAccountContractMap(
                accountAgreementStringContractIdMap,
                accountIdToFranchiseParentIdMap,
                accountIdToDeselectedServicesMap,
                accountIdToAgreedToServicesMap,
                amendedAccountIdToAutoProvisionValueMap,
                accountIdsToSelectedPckgIdToDeselectedProdListMap,
                uow
            );
        }

        commitWork(workComitted, uow);
        AccountsService.updateFieldsOnAccount(accountIdSet);
    }

    /**
     * @description create Activation Orders and Activation Order Products on Contract Amendment LEM-2589
     * @param amendedContractIds
     */
    public void createActivationOrdersAndProductsOnContractAmendment(Set<Id> amendedContractIds) {
        if (amendedContractIds.isEmpty()) {
            return;
        }
        List<Agreement__c> activeAgreements = AgreementsSelector.newInstance()
            .selectActiveAgreementsByContractIds(amendedContractIds);

        //Create Provisioning events and publish them.
        AgreementsService.publishAgreementActivationEvents(activeAgreements, false);
    }

    /**
     * @description create Activation Orders and Activation Order Products on Integrated Franchise LEM-2673
     * @param accountIdContractIdMap
     * @param uow
     * @return Boolean uowCommitted
     */
    public boolean createActivationOrdersAndProductsForIntegratedFranchise(
        Map<String, Id> accountIdContractIdMap,
        fflib_ISObjectUnitOfWork uow
    ) {
        if (accountIdContractIdMap.isEmpty()) {
            return false;
        }

        //Send Empty map to function, so mxAgreedToProduct will always be set to Yes.
        Map<Id, Id> accountIdToFranchiseParentIdMap = new Map<Id, Id>();
        //Send empty map because there are no Deselected Services
        Map<Id, Map<String, String>> accountIdToDeselectedServicesMap = new Map<Id, Map<String, String>>();
        Map<Id, String> accountIdToAgreedToServicesMap = createAccountIdToAgreedToServicesDriveMap(
            accountIdContractIdMap
        );
        //Empty map of Amended Account Ids to amended values, amendments do not flow through this path
        Map<Id, Boolean> amendedAccountIdToAutoProvisionValueMap = new Map<Id, Boolean>();
        //Send AccontIdToEmptyMap, as services will be activated not based on selection/seselection of pckg prod
        Map<Id, Map<String, List<String>>> accountIdsToSelectedPckgIdToDeselectedProdListMap = createAccIdToEntitlementMapForIntegratedFranchise(
            accountIdContractIdMap
        );
        //Map that is passed in has AccountId-OpportunityId for the key, to ensure they are unique.
        ActivationOrderCreationService.createActivationOrdersForAccountContractMap(
            accountIdContractIdMap,
            accountIdToFranchiseParentIdMap,
            accountIdToDeselectedServicesMap,
            accountIdToAgreedToServicesMap,
            amendedAccountIdToAutoProvisionValueMap,
            accountIdsToSelectedPckgIdToDeselectedProdListMap,
            uow
        );

        return true;
    }

    /**
     * @description Activate Orders Products on Xref success
     * @param xrefList
     */
    public void activateOrderProductsOnXrefSuccess(List<Xref__c> xrefList) {
        Set<Id> marketPlaceAccountIds = new Set<Id>();
        Set<Id> driveAccountIds = new Set<Id>();
        for (Xref__c xref : xrefList) {
            if (
                (xref.External_ID_Source__c == XREF_EXTERNAL_SOURCE_MARKETPLACE) ||
                (xref.External_ID_Source__c == XREF_EXTERNAL_SOURCE_MARKETPLACE_CATERING)
            ) {
                marketPlaceAccountIds.add(xref.Salesforce_Account_Name__c);
            }
            if (xref.External_ID_Source__c == XREF_EXTERNAL_SOURCE_DRIVE) {
                driveAccountIds.add(xref.Salesforce_Account_Name__c);
            }
        }

        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        updateDraftOrderItems(marketPlaceAccountIds, true, uow);
        updateDraftOrderItems(driveAccountIds, false, uow);

        commitWork(false, uow);
    }

    /**
     * @description Activate Orders Products on Business Reference success(Drive Only)
     * @param businessReferenceList
     */
    public void activateOrderProductsOnBusinessReferenceSuccess(
        List<Business_Reference__c> businessReferenceList
    ) {
        if (businessReferenceList.isEmpty()) {
            return;
        }

        Set<Id> businessRefIds = new Set<Id>();
        for (Business_Reference__c busRef : businessReferenceList) {
            if (
                (busRef.External_ID_Source__c == XREF_EXTERNAL_SOURCE_DRIVE) &&
                (busRef.Integration_Status__c == INTEGRATION_STATUS_SUCCESS)
            ) {
                businessRefIds.add(busRef.Id);
            }
        }
        //This poorly named selector function selects xrefe that have an Account_Record_Type__c = Business
        List<Xref__c> xrefsWithBusinessAccounts = XrefsSelector.newInstance()
            .selectAllMatchingBusinessReferenceForDriveDb(businessRefIds);
        Set<Id> driveAccountIds = new Set<Id>();
        for (Xref__c xref : xrefsWithBusinessAccounts) {
            driveAccountIds.add(xref.Salesforce_Account_Name__c);
        }

        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        //Only done for Drive accounts.
        updateDraftOrderItems(driveAccountIds, false, uow);

        commitWork(false, uow);
    }

    /**
     * @description Creates a map of account Ids to Deselected Services from the Opportunity.
     * If multiple Agreements point to the same account, concatenate the deselected Services, since services are related to accounts.
     * @param agreementListOppInfo
     * @return Map<Id, Map<String, String>>
     */
    private static Map<Id, Map<String, String>> createAccountIdToDeselectedServiceMap(
        List<Agreement__c> agreementListOppInfo
    ) {
        Map<Id, Map<String, String>> returnMap = new Map<Id, Map<String, String>>();
        Map<Id, String> deSelectedServices = new Map<Id, String>();
        for (Agreement__c agreement : agreementListOppInfo) {
            Id accountId = agreement.Account__c;
            if (String.isNotBlank(agreement.Opportunity__r.Packages_with_Products__c)) {
                Map<String, String> deselectedServicesMap = returnMap.containsKey(accountId)
                    ? returnMap.get(accountId)
                    : new Map<String, String>();
                MerchantPopUpPackageWrapper wrappers = (MerchantPopUpPackageWrapper) JSON.deserialize(
                    agreement.Opportunity__r.Packages_with_Products__c,
                    MerchantPopUpPackageWrapper.class
                );
                // Parse the Packages_with_Products__c JSON string and add it to the map
                for (MerchantPopUpPackageWrapper.packageDetails wrap : wrappers.packageDetails) {
                    String deselectedMpServices;
                    if (wrap.packageName == MARKETPLACE) {
                        deselectedMpServices = deselectedServices.containsKey(accountId)
                            ? deselectedServices.get(accountId) + ';' + wrap.products
                            : wrap.products;
                    }
                    deselectedServicesMap.put(
                        wrap.packageName,
                        wrap.packageName == MARKETPLACE ? deselectedMpServices : wrap.products
                    );
                    deselectedServices.put(accountId, deselectedMpServices);
                }
                returnMap.put(accountId, deselectedServicesMap);
            } else {
                returnMap.put(accountId, new Map<String, String>());
            }
        }
        return returnMap;
    }

    /**
     * @description Gets the account Ids from the map
     * @param accountIdContractIdMap
     * @return Set<Id>
     */
    private static Map<Id, String> createAccountIdToAgreedToServicesDriveMap(
        Map<String, Id> accountIdContractIdMap
    ) {
        Map<Id, String> accountIdToAgreedToServicesMap = new Map<Id, String>();
        for (String agreementAccountString : accountIdContractIdMap.keyset()) {
            String accountIdString = agreementAccountString.substring(
                0,
                agreementAccountString.indexOf('-')
            );
            accountIdToAgreedToServicesMap.put(
                Id.valueOf(accountIdString),
                AGREED_TO_SERVICES_DRIVE
            );
        }
        return accountIdToAgreedToServicesMap;
    }

    /**
     * @description Creates a map of account ids to an empty map of selected pckg to deselected prod list
     * as for integrated franchise services should not depend on selection/deselection
     * @param accountIdContractIdMap
     * @return Map<Id, Map<String, List<String>>>
     */
    private static Map<Id, Map<String, List<String>>> createAccIdToEntitlementMapForIntegratedFranchise(
        Map<String, Id> accountIdContractIdMap
    ) {
        Map<Id, Map<String, List<String>>> accountIdToEntitlementMap = new Map<Id, Map<String, List<String>>>();
        for (String accountOppString : accountIdContractIdMap.keyset()) {
            String accountIdString = accountOppString.substring(0, accountOppString.indexOf('-'));
            accountIdToEntitlementMap.put(
                Id.valueOf(accountIdString),
                new Map<String, List<String>>{}
            );
        }
        return accountIdToEntitlementMap;
    }

    /**
     * @description Updates Draft Activation Order Products to Activated.
     * @param accountIds
     * @param marketplace
     * @param uow
     */
    private void updateDraftOrderItems(
        Set<Id> accountIds,
        Boolean marketplace,
        fflib_ISObjectUnitOfWork uow
    ) {
        if (accountIds.isEmpty()) {
            return;
        }
        List<Merchant_Service__c> draftServices = new List<Merchant_Service__c>();
        if (marketplace) {
            draftServices = MerchantSelector.newInstance()
                .queryActiveMarketplaceServicesWithDraftOrderProductsByAccountId(accountIds);
        } else {
            draftServices = MerchantSelector.newInstance()
                .queryActiveDriveServicesWithDraftOrderProductsByAccountId(accountIds);
        }

        Set<Id> orderIdSet = new Set<Id>();
        for (Merchant_Service__c service : draftServices) {
            Date serviceDate = isServiceToBeActivatedToday(service)
                ? System.today()
                : service.Account__r.Proposed_Date_of_Activation__c;

            OrderItem updatedOrderItem = new OrderItem(
                Id = service.Order_Product__c,
                SBQQ__Status__c = ACTIVATED,
                ServiceDate = serviceDate
            );
            if (
                !orderIdSet.contains(service.Order_Product__r.Order.Id) &&
                (service.Order_Product__r.Order.EffectiveDate == null ||
                serviceDate < service.Order_Product__r.Order.EffectiveDate)
            ) {
                Order updatedOrder = new Order(
                    Id = service.Order_Product__r.Order.Id,
                    EffectiveDate = serviceDate
                );
                orderIdSet.add(updatedOrder.Id);
                uow.registerDirty(updatedOrder);
            }
            uow.registerDirty(updatedOrderItem);
        }
    }

    /**
     * @description Checks if the Service to be activated today.
     * @param service
     * @return serviceToBeActivatedToday
     */
    private Boolean isServiceToBeActivatedToday(Merchant_Service__c service) {
        Boolean serviceToBeActivatedToday =
            service.Account__r.Proposed_Date_of_Activation__c == null ||
            service.Order_Product__r.Existing_Store_Processed__c ||
            (service.Subscription__r.Subscription_Rate_Change__c != null &&
            service.Active_Rates_Applied__c == true);
        return serviceToBeActivatedToday;
    }

    /**
     * @description Update Merchant Services Based on Entitlements from Agreements
     * @param agreements
     */
    public void updateMerchantServicesbasedOnEntitlements(List<Agreement__c> agreements) {
        if (agreements.isEmpty()) {
            return;
        }
        Set<Id> eligibleAccountIds = new Set<Id>();
        Map<Id, Agreement__c> accountIdToActiveAgreementsMap = new Map<Id, Agreement__c>();
        Map<Id, String> accountIdToEntitlementsStringMap = new Map<Id, String>();
        Map<Id, Map<String, List<String>>> accountIdsToSelectedPckgIdToDeselectedProdListMap = new Map<Id, Map<String, List<String>>>();
        accountIdsToSelectedPckgIdToDeselectedProdListMap = getAccountIdsToselectedPckgIdToDeselectedProdListMap(
            agreements
        );
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        accountIdToActiveAgreementsMap = createAccountIdToActiveAgreementsMap(agreements);
        accountIdToEntitlementsStringMap = createAccountToEntitlementsStringMap(agreements);
        //Filter out the eligibile accountIds from accountIdToEntitlementsStringMap based on if they have active agreements or not.
        for (Id eachAccId : accountIdToEntitlementsStringMap.keySet()) {
            if (
                accountIdToActiveAgreementsMap.containsKey(eachAccId) &&
                accountIdToActiveAgreementsMap.get(eachAccId) != null
            ) {
                eligibleAccountIds.add(eachAccId);
            }
        }
        //Query the services for all the eligible AccountIds
        List<Merchant_Service__c> existingServices = MerchantSelector.newInstance()
            .queryMerchantRecordsWithAccountIds(eligibleAccountIds);
        updateServices(accountIdsToSelectedPckgIdToDeselectedProdListMap, existingServices, uow);
        AccountsService.updateFieldsOnAccount(eligibleAccountIds);

    }

    /**
     * @description Create Map of accountIdToActiveAgreementsMap
     * @param agreements
     * @return accountIdToActiveAgreementsMap
     */
    private Map<Id, Agreement__c> createAccountIdToActiveAgreementsMap(
        List<Agreement__c> agreements
    ) {
        Map<Id, Agreement__c> accountIdToActiveAgreementsMap = new Map<Id, Agreement__c>();
        for (Agreement__c eachAgreement : agreements) {
            if (eachAgreement.Account__c != null && eachAgreement.Status__c == 'Active') {
                accountIdToActiveAgreementsMap.put(eachAgreement.Account__c, eachAgreement);
            }
        }
        return accountIdToActiveAgreementsMap;
    }

    /**
     * @description Create Map of accountIdToEntitlementsStringMap
     * @param agreements
     * @return accountIdToEntitlementsStringMap
     */
    private Map<Id, String> createAccountToEntitlementsStringMap(List<Agreement__c> agreements) {
        Map<Id, String> accountIdToEntitlementsStringMap = new Map<Id, String>();
        for (Agreement__c eachAgreement : agreements) {
            if (
                eachAgreement.Account__c != null &&
                eachAgreement.Serialized_Entitlements_Data__c != null
            ) {
                accountIdToEntitlementsStringMap.put(
                    eachAgreement.Account__c,
                    eachAgreement.Serialized_Entitlements_Data__c
                );
            }
        }
        return accountIdToEntitlementsStringMap;
    }

    private void updateServices(
        Map<Id, Map<String, List<String>>> accountIdsToSelectedPckgIdToDeselectedProdListMap,
        List<Merchant_Service__c> existingServices,
        fflib_ISObjectUnitOfWork uow
    ) {
        String serviceStatus;
        Id serviceSubRootId;
        Id serviceSubRequiredById;
        for (Merchant_Service__c mxService : existingServices) {
            if (mxService.Mx_Agreed_To_Product__c == MX_AGREED_YES) {
                continue;
            }
            serviceSubRootId = mxService.Subscription__r.SBQQ__RootId__c;
            serviceSubRequiredById = mxService.Subscription__r.SBQQ__RequiredById__c;
            if (
                serviceSubRequiredById == null &&
                accountIdsToSelectedPckgIdToDeselectedProdListMap.get(mxService.Account__c)
                    .containsKey(mxService.Subscription__c)
            ) {
                serviceStatus = MX_AGREED_YES;
            } else if (
                accountIdsToSelectedPckgIdToDeselectedProdListMap.get(mxService.Account__c)
                    .containsKey(serviceSubRootId) &&
                !accountIdsToSelectedPckgIdToDeselectedProdListMap.get(mxService.Account__c)
                    .get(serviceSubRootId)
                    .contains(mxService.Subscription__c) &&
                !accountIdsToSelectedPckgIdToDeselectedProdListMap.get(mxService.Account__c)
                    .get(serviceSubRootId)
                    .contains(serviceSubRequiredById)
            ) {
                serviceStatus = MX_AGREED_YES;
            } else {
                serviceStatus = MX_AGREED_NO;
            }
            if (mxService.Mx_Agreed_To_Product__c != serviceStatus) {
                Merchant_Service__c updatedService = new Merchant_Service__c(
                    Id = mxService.Id,
                    Mx_Agreed_to_Product__c = serviceStatus,
                    Active_Rates_Applied__c = false
                );
                OrderItem updatedOrderItem = new OrderItem(
                    Id = mxService.Order_Product__c,
                    Existing_Store_Processed__c = true
                );
                uow.registerDirty(updatedService);
                uow.registerDirty(updatedOrderItem);
            }
        }
        commitWork(false, uow);
    }

    /**
     * @description check store agreement eligibility
     * @param storeAgreement
     * @return Boolean
     */
    private Boolean isStoreAgreementEligible(Agreement__c storeAgreement) {
        if (
            (storeAgreement.Account__c != null) &&
            (storeAgreement.Contract__c != null) &&
            (storeAgreement.Status__c == ACTIVE)
        ) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @description creates accounts ids to selectedPckgIdToDeselectedProdListMap
     * @param agreements
     * @return accountIdsToselectedPckgIdToDeselectedProdListMap
     */

    private Map<Id, Map<String, List<String>>> getAccountIdsToselectedPckgIdToDeselectedProdListMap(
        List<Agreement__c> agreements
    ) {
        Map<Id, Map<String, List<String>>> accountIdsToSelectedPckgIdToDeselectedProdListMap = new Map<Id, Map<String, List<String>>>();
        Map<String, List<String>> selectedPckgIdToDeselectedProdListMap = new Map<String, List<String>>();
        String entitlementData;

        for (Agreement__c agreementItem : agreements) {
            entitlementData = agreementItem.Serialized_Entitlements_Data__c;
            if (String.isBlank(entitlementData) || agreementItem.account__c == null) {
                continue;
            }
            //deserialize using wrapper
            AssociatedAccountsWrapper.SelectedAndDeselectedEntitlements wrapper = (AssociatedAccountsWrapper.SelectedAndDeselectedEntitlements) System.JSON.deserialize(
                entitlementData,
                AssociatedAccountsWrapper.SelectedAndDeselectedEntitlements.class
            );

            for (AssociatedAccountsWrapper.DeselectedPackage item : wrapper.deselected) {
                if (
                    item.selectedPackageId != null &&
                    !selectedPckgIdToDeselectedProdListMap.containsKey(item.selectedPackageId)
                ) {
                    selectedPckgIdToDeselectedProdListMap.put(
                        item.selectedPackageId,
                        item.productDeselected
                    );
                }
            }
            accountIdsToSelectedPckgIdToDeselectedProdListMap.put(
                agreementItem.account__c,
                selectedPckgIdToDeselectedProdListMap
            );
        }
        return accountIdsToselectedPckgIdToDeselectedProdListMap;
    }

    /**
     * @description creates a map of accounts ids to auto Provision Value from latest amended Quote
     * @param storeAgreement
     * @return Map<Id, Boolean>
     */
    private Map<Id, Boolean> createAccountIdToAutoProvisionMap(Agreement__c storeAgreement) {
        Map<Id, Boolean> accountIdsToAutoProvisionMap = new Map<Id, Boolean>();
        if (
            storeAgreement.Contract__r.SBQQ__Order__r.SBQQ__Quote__r.Use_Corporate_Cherry_Picking__c ==
            true
        ) {
            accountIdsToAutoProvisionMap.put(storeAgreement.Account__c, false);
        } else {
            accountIdsToAutoProvisionMap.put(storeAgreement.Account__c, true);
        }
        return accountIdsToAutoProvisionMap;
    }

    /**
     * @description Commit method
     * @param workComitted
     * @param uow
     * @return workComitted
     */
    private boolean commitWork(Boolean workComitted, fflib_ISObjectUnitOfWork uow) {
        if (!workComitted) {
            //Turn off CPQ Triggers to avoid SBQQ__Quote__c being set.
            SBQQ.TriggerControl.disable();
            uow.commitWork();
            workComitted = true;
            SBQQ.TriggerControl.enable();
        }
        return workComitted;
    }
}