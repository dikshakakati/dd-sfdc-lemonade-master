/**
 * @author deloitte
 * @date 08/09/2023
 * @description Class to get data for Select Entitlement Step
 */
public with sharing class BulkCorporateOnboardingEntitlementCtrl {
    private static final String CCP_READONLY_SELECTED_PACKAGES = 'CCP_Readonly_Selected_Packages';
    private static final String MARKETPLACE_PACKAGE = 'Marketplace';
    private static final String STOREFRONT_PACKAGE = 'Storefront';
    private static final String PICKUP_PRODUCT = 'Pickup';
    private static final String REQUEST_STAGE_BUSINES_PAYMENT_ACCOUNT = 'Payment Account';
    private static final String REQUEST_STAGE_DECISION_MAKER = 'Decision Maker';
    private static final String REQUEST_STAGE_FINAL_ERROR_CHECK = 'Final Error Check';
    private static final List<String> PRODUCT_LIST = new List<String>{
        'Dashpass',
        'Delivery',
        'Pickup'
    };

    /**
     * @description Get existing Subscriptions with Group
     * @param contractId
     * @param flowRequestId
     * @return List<ManageEntitlementsSelectionWrapper>
     */
    @AuraEnabled(cacheable=true)
    public static List<ManageEntitlementsSelectionWrapper> selectExistingSubscriptionsWithGroup(
        Id contractId,
        Id flowRequestId
    ) {
        List<Id> storeIds = new List<Id>();
        List<ManageEntitlementsSelectionWrapper> groupWrapperList = new List<ManageEntitlementsSelectionWrapper>();
        Map<String, List<SBQQ__Subscription__c>> mapGroupSubscription = new Map<String, List<SBQQ__Subscription__c>>();
        Map<String, List<Id>> mapGroupIdAccountIds = new Map<String, List<Id>>();
        Id groupId = getGroupIdbyContract(contractId);

        List<Process_Flow_Request__c> requests = ProcessFlowRequestsSelector.newInstance()
            .selectById(new Set<Id>{ flowRequestId });
        if (requests.isEmpty()) {
            return null;
        }

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            requests[0].Id,
            requests[0].Serialized_Object_Data__c
        );

        for (BulkCorporateOnboardingWrappers.StoreInfo thisStoreInfo : storeInfos) {
            storeIds.add(thisStoreInfo.storeId);
        }

        mapGroupIdAccountIds.put(groupId, storeIds);
        List<SBQQ__Subscription__c> subListsByGroup = getSubscriptionRecordsByGroup(
            new List<Id>{ groupId }
        );

        for (SBQQ__Subscription__c subs : subListsByGroup) {
            String subsGroup = subs.Quote_Line_Group__c;
            if (!mapGroupSubscription.containsKey(subsGroup)) {
                mapGroupSubscription.put(subsGroup, new List<SBQQ__Subscription__c>{ subs });
            } else {
                mapGroupSubscription.get(subsGroup).add(subs);
            }
        }

        // create ManageEntitlementsSelectionWrapper wrapper list
        groupWrapperList = createGroupWrapperList(mapGroupSubscription, mapGroupIdAccountIds);
        groupWrapperList = sortPackageList(groupWrapperList);
        return groupWrapperList;
    }

    /**
     * @description Get group Id from subscription on contract
     * @param mapGroupSubscription
     * @param mapGroupIdAccountIds
     * @return List<ManageEntitlementsSelectionWrapper>
     */
    @AuraEnabled
    public static List<ManageEntitlementsSelectionWrapper> createGroupWrapperList(
        Map<String, List<SBQQ__Subscription__c>> mapGroupSubscription,
        Map<String, List<Id>> mapGroupIdAccountIds
    ) {
        List<ManageEntitlementsSelectionWrapper> groupWrapperList = new List<ManageEntitlementsSelectionWrapper>();
        Map<Id, List<SBQQ__Subscription__c>> mapPackageSubscription = new Map<Id, List<SBQQ__Subscription__c>>();
        Map<Id, SBQQ__Subscription__c> mapPackageIdDetail = new Map<Id, SBQQ__Subscription__c>();
        List<ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper> packageWrapperList = new List<ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper>();

        for (String groups : mapGroupSubscription.keyset()) {
            for (SBQQ__Subscription__c groupSubs : mapGroupSubscription.get(groups)) {
                if (groupSubs.Quote_Line_Group__c != groups) {
                    continue;
                }
                if (groupSubs.SBQQ__RequiredById__c == null && groupSubs.SBQQ__Product__r.Package_Eligible_For_Entitlement__c) {
                    if (!mapPackageSubscription.containsKey(groupSubs.Id)) {
                        mapPackageSubscription.put(groupSubs.Id, new List<SBQQ__Subscription__c>());
                    }
                    mapPackageIdDetail.put(groupSubs.Id, groupSubs);
                } else if (
                    groupSubs.SBQQ__ProductOption__r.Product_Eligible_For_Entitlement__c == true
                ) {
                    if (mapPackageSubscription.containsKey(groupSubs.SBQQ__RequiredById__c)) {
                        mapPackageSubscription.get(groupSubs.SBQQ__RequiredById__c).add(groupSubs);
                    } else {
                        mapPackageSubscription.put(
                            groupSubs.SBQQ__RequiredById__c,
                            new List<SBQQ__Subscription__c>{ groupSubs }
                        );
                    }
                }
            }

            packageWrapperList = createPackageWrapperList(
                mapPackageSubscription,
                mapPackageIdDetail
            );

            groupWrapperList.add(
                new ManageEntitlementsSelectionWrapper(
                    groups,
                    mapGroupIdAccountIds.get(groups),
                    packageWrapperList
                )
            );
        }
        return groupWrapperList;
    }

    /**
     * @description Get group Id from subscription on contract
     * @param mapPackageSubscription
     * @param mapPackageIdDetail
     * @return List<ManageEntitlementsSelectionWrapper>
     */
    @AuraEnabled
    public static List<ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper> createPackageWrapperList(
        Map<Id, List<SBQQ__Subscription__c>> mapPackageSubscription,
        Map<Id, SBQQ__Subscription__c> mapPackageIdDetail
    ) {
        List<ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper> packageWrapperList = new List<ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper>();

        if (mapPackageSubscription.keyset() != null) {
            for (Id packageId : mapPackageSubscription.keyset()) {
                Static_Configurations__mdt ccpReadonlyPackages = Static_Configurations__mdt.getInstance(
                    CCP_READONLY_SELECTED_PACKAGES
                );
                Boolean checkDrivePackage = ccpReadonlyPackages.Configuration_Value__c.contains(
                        mapPackageIdDetail.get(packageId).SBQQ__Product__r.Family
                    )
                    ? true
                    : false;
                packageWrapperList.add(
                    new ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper(
                        packageId,
                        mapPackageIdDetail.get(packageId).SBQQ__ProductName__c,
                        mapPackageIdDetail.get(packageId)
                            .SBQQ__Product__r.Package_Eligible_For_Entitlement__c,
                        mapPackageSubscription.get(packageId),
                        checkDrivePackage
                    )
                );
            }
        }
        return packageWrapperList;
    }

    /**
     * @description Get group Id from subscription on contract
     * @param wrapperList
     * @return List<ManageEntitlementsSelectionWrapper>
     */
    private static List<ManageEntitlementsSelectionWrapper> sortPackageList(
        List<ManageEntitlementsSelectionWrapper> wrapperList
    ) {
        for (ManageEntitlementsSelectionWrapper wrapper : wrapperList) {
            bubbleSort(wrapper.packageList);
        }
        return wrapperList;
    }

    /**
     * @description Get group Id from subscription on contract
     * @param packageList
     */
    private static void bubbleSort(
        List<ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper> packageList
    ) {
        Integer n = packageList.size();

        for (Integer i = 0; i < n - 1; i++) {
            for (Integer j = 0; j < n - i - 1; j++) {
                ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper a = packageList[
                    j
                ];
                ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper b = packageList[
                    j + 1
                ];

                // Compare based on custom criteria
                if (compare(a, b) > 0) {
                    // swap elements
                    packageList[j] = b;
                    packageList[j + 1] = a;
                }
            }
        }
    }

    /**
     * @description Get group Id from subscription on contract
     * @param a
     * @param b
     * @return Integer
     */
    private static Integer compare(
        ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper a,
        ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper b
    ) {
        // Compare based on the existence of subsList and the count of elements in subsList
        Boolean hasSubsA = hasSubsList(a);
        Boolean hasSubsB = hasSubsList(b);

        // Ensure products with packages come first
        if (hasSubsA && !hasSubsB) {
            return -1;
        } else if (!hasSubsA && hasSubsB) {
            return 1;
        }

        Integer numSubsA = hasSubsA ? getNumSubsListElements(a) : 0;
        Integer numSubsB = hasSubsB ? getNumSubsListElements(b) : 0;

        return numSubsB - numSubsA;
    }

    private static Boolean hasSubsList(
        ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper pkg
    ) {
        return pkg.subsList != null && !pkg.subsList.isEmpty();
    }

    private static Integer getNumSubsListElements(
        ManageEntitlementsSelectionWrapper.ManageEntitlementsPackageSelectionWrapper pkg
    ) {
        return pkg.subsList != null ? pkg.subsList.size() : 0;
    }

    /**
     * @description Get list of susbscriptions using group id
     * @param groupIdList
     * @return List<SBQQ__Subscription__c>
     */
    public static List<SBQQ__Subscription__c> getSubscriptionRecordsByGroup(List<Id> groupIdList) {
        List<SBQQ__Subscription__c> returnList = new List<SBQQ__Subscription__c>();
        try {
            returnList = SubscriptionSelector.newInstance()
                .selectSubscriptionRecordsByGroup(groupIdList);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }

        return returnList;
    }

    /**
     * @description Get group Id from subscription on contract
     * @param contractId
     * @return Id
     */
    public static Id getGroupIdbyContract(Id contractId) {
        Id groupId;
        try {
            groupId = SubscriptionSelector.newInstance()
                .selectQuoteLineGroupOnSubscription(contractId);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }

        return groupId;
    }

    /**
     * @description Save Selection/Deselection Data
     * @param mapofSelectDeselect
     * @param flowRequestId
     * @param contractId
     * @param isManagePackageSelected
     * @param ccpApplied
     * @return Process_Flow_Request__c
     */
    @AuraEnabled
    public static Process_Flow_Request__c saveEntitlementsSelectionDeselection(
        String mapofSelectDeselect,
        Id flowRequestId,
        Id contractId,
        Boolean isManagePackageSelected,
        Boolean ccpApplied
    ) {
        Id groupId = getGroupIdbyContract(contractId);

        List<Process_Flow_Request__c> requests = ProcessFlowRequestsSelector.newInstance()
            .selectById(new Set<Id>{ flowRequestId });
        if (requests.isEmpty()) {
            return null;
        }
        Boolean goToPaymentAccountStep = false;
        Boolean goToDecisionMakerStep = false;
        String stageToUse;
        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            requests[0].Id,
            requests[0].Serialized_Object_Data__c
        );

        for (BulkCorporateOnboardingWrappers.StoreInfo eachStore : storeInfos) {
            if (eachStore.paymentAccountId == null) {
                goToPaymentAccountStep = true;
            }

            if (eachStore.decisionMakerId == null) {
                goToDecisionMakerStep = true;
            }

            if (goToPaymentAccountStep && goToDecisionMakerStep) {
                break; // No need to evaluate further stores
            }
        }
        if (goToPaymentAccountStep) {
            stageToUse = REQUEST_STAGE_BUSINES_PAYMENT_ACCOUNT;
        } else if (goToDecisionMakerStep) {
            stageToUse = REQUEST_STAGE_DECISION_MAKER;
        } else {
            stageToUse = REQUEST_STAGE_FINAL_ERROR_CHECK;
        }
        requests[0].Serialized_Entitlements_Data__c = mapofSelectDeselect;
        requests[0].Group__c = groupId;
        requests[0].CCP_ANSO_flow__c = isManagePackageSelected;
        requests[0].Stage__c = stageToUse;
        requests[0].CCP_Applied__c = ccpApplied;
        requests[0] = BulkCorporateOnboardingRequestCtrl.commitProcessFlowRequestUpdates(
            requests[0]
        );
        return requests[0];
    }

    /**
     * @description Save Selection/Deselection Data
     * @param contractId
     * @return List<SBQQ__Subscription__c>
     */
    @AuraEnabled
    public static List<SBQQ__Subscription__c> getAllSubscriptionFromContract(Id contractId) {
        Id groupId = getGroupIdbyContract(contractId);
        List<SBQQ__Subscription__c> returnList = getSubscriptionRecordsByGroup(
            new List<Id>{ groupId }
        );
        return returnList;
    }
}