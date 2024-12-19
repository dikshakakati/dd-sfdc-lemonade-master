/**
 * @author Deloitte
 * @date 04/22/2024
 * @description Interface of service class for product bundle selections for tablet worksteps.
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessiveClassLength')
public inherited sharing class MxOrderCreationServiceImpl implements IMxOrderCreationService {
    private static final String DECK_RANK_ACE_SPADES = 'Ace of Spades';
    private static final String DECK_RANK_KING = 'King';
    private static final String DECK_RANK_ACE = 'Ace';
    private static final String GUIDED_FLOW = 'Guided Flow';
    private static final String LOG_CREATE_MX_ORDERS_FAILED = 'Creation of Mx Orders Failed';
    private static final String LOG_DOMAIN = 'Onboarding';
    private static final String ONE_AND_HALF_HOUR = '1.5 hour';
    private static final String VENDOR_OVERTURE = 'Overture';
    private static final String PHOTOSHOOT_ROLE = 'Photoshoot Contact';
    private static final String SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String SEGMENT_MID_MARKET = 'Mid-Market';
    private static final String SHIPPING_TYPE_EXPEDITED = 'Expedited';
    private static final String SHIPPING_TYPE_STANDARD = 'Standard';
    private static final String STATUS_DRAFT = 'Draft';
    private static final String STATUS_INVALID = 'Invalid';
    private static final String TABLET_BUNDLE_AUS = 'Tablet Bundle (AUS)';
    private static final String TABLET_BUNDLE_US = 'Tablet Bundle (US)';
    private static final String TABLET_BUNDLE_CAN = 'Tablet Bundle (CAN)';
    private static final String TABLET_BUNDLE_NZ = 'Tablet Bundle (NZ)';
    private static final String TABLET_AND_PRINTER_BUNDLE_AUS = 'Tablet & Printer Bundle (AUS)';
    private static final String TABLET_AND_PRINTER_BUNDLE_US = 'Tablet & Printer Bundle (US)';
    private static final String TABLET_AND_PRINTER_BUNDLE_CAN = 'Tablet & Printer Bundle (CAN)';
    private static final String TABLET_AND_PRINTER_BUNDLE_NZ = 'Tablet & Printer Bundle (NZ)';
    private static final String TEWNTY_ITEMS_PLUS_HEADER = '20 items + header';
    private static final String TYPE_NET_NEW = 'Net-New';
    private static final String TYPE_REPLACEMENT = 'Replacement';
    private static final String TYPE_RETURN = 'Return';
    private static final String TYPE_TABLET = 'Tablet';
    private static final String TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String TYPE_MARKETING_KIT = 'Marketing Kit';
    private static final String WORK_STEP_TYPE_TABLET = 'Deliver Tablet';
    private static final String WORK_STEP_TYPE_RETURN = 'Deliver Return Label';
    private static final String RETURN_LABEL_BUNDLE = 'Return Label';
    private static final String CREATION_SOURCE = 'Bulk Request';

    private static final List<String> EXPEDITED_DECK_RANK = new List<String>{
        DECK_RANK_ACE,
        DECK_RANK_ACE_SPADES,
        DECK_RANK_KING,
        DECK_RANK_ACE
    };
    private static final List<String> PRODUCT_BUNDLE_NAMES = new List<String>{
        TABLET_BUNDLE_AUS,
        TABLET_BUNDLE_US,
        TABLET_BUNDLE_CAN,
        TABLET_BUNDLE_NZ,
        TABLET_AND_PRINTER_BUNDLE_AUS,
        TABLET_AND_PRINTER_BUNDLE_US,
        TABLET_AND_PRINTER_BUNDLE_CAN,
        TABLET_AND_PRINTER_BUNDLE_NZ
    };
    private static final List<String> PHOTOSHOOT_PRODUCT_BUNDLE_NAMES = new List<String>{
        TEWNTY_ITEMS_PLUS_HEADER,
        ONE_AND_HALF_HOUR
    };
    private static final String TWO_TABLETS_ORDER_PROTOCOL = '2 Tablets (Caviar and DoorDash Own)';
    private static final String POS_AND_TWO_TABLETS_CAVIAR_ORDER_PROTOCOL = 'POS and 2 Tablets (Caviar POS, DoorDash and Caviar Tablets)';
    private static final String POS_AND_TWO_TABLETS_DOORDASH_ORDER_PROTOCOL = 'POS and 2 Tablets (DoorDash POS, DoorDash and Caviar Tablets)';
    private static final String POS_AND_TABLET_CAVIAR_ORDER_PROTOCOL = 'POS and Tablet (Caviar Owns)';
    private static final String POS_AND_TABLET_DD_ORDER_PROTOCOL = 'POS and Tablet (DoorDash Owns)';
    private static final String TABLET_DOORDASH_OWNS_ORDER_PROTOCOL = 'Tablet (DoorDash Owns)';
    private static final String TABLET_CAVIAR_OWNS_ORDER_PROTOCOL = 'Tablet (Caviar Owns)';
    private static final String TABLET_AND_PRINTER_ORDER_PROTOCOL = 'Tablet and Printer (DoorDash Owns)';
    private static final Set<String> ORDER_PROTOCOLS_WITH_NO_PRINTER = new Set<String>{
        TWO_TABLETS_ORDER_PROTOCOL,
        POS_AND_TWO_TABLETS_CAVIAR_ORDER_PROTOCOL,
        POS_AND_TWO_TABLETS_DOORDASH_ORDER_PROTOCOL,
        POS_AND_TABLET_CAVIAR_ORDER_PROTOCOL,
        POS_AND_TABLET_DD_ORDER_PROTOCOL,
        TABLET_DOORDASH_OWNS_ORDER_PROTOCOL,
        TABLET_CAVIAR_OWNS_ORDER_PROTOCOL
    };
    private static final Set<String> ORDER_PROTOCOLS_WITH_TABLET_AND_PRINTER = new Set<String>{
        TABLET_AND_PRINTER_ORDER_PROTOCOL
    };
    private static final String BILLING_COUNTRY_CODE_AUS = 'AU';
    private static final String BILLING_COUNTRY_CODE_CAN = 'CA';
    private static final String BILLING_COUNTRY_CODE_US = 'US';
    private static final String BILLING_COUNTRY_CODE_NZ = 'NZ';
    private enum BILLING_COUNTRY_CODES {
        BILLING_COUNTRY_CODE_AUS,
        BILLING_COUNTRY_CODE_CAN,
        BILLING_COUNTRY_CODE_US,
        BILLING_COUNTRY_CODE_NZ
    }
    private static final Map<String, BILLING_COUNTRY_CODES> BILLING_COUNTRY_CODES_TO_NAME = new Map<String, BILLING_COUNTRY_CODES>{
        BILLING_COUNTRY_CODE_AUS => BILLING_COUNTRY_CODES.BILLING_COUNTRY_CODE_AUS,
        BILLING_COUNTRY_CODE_CAN => BILLING_COUNTRY_CODES.BILLING_COUNTRY_CODE_CAN,
        BILLING_COUNTRY_CODE_US => BILLING_COUNTRY_CODES.BILLING_COUNTRY_CODE_US,
        BILLING_COUNTRY_CODE_NZ => BILLING_COUNTRY_CODES.BILLING_COUNTRY_CODE_NZ
    };
    private enum SubTypes {
        SUB_TYPE_NET_NEW,
        SUB_TYPE_REPLACEMENT,
        SUB_TYPE_RETURN,
        MARKETING_KIT
    }
    private static final Map<String, SubTypes> WORK_STEP_SUB_TYPE_MAPPINGS = new Map<String, SubTypes>{
        TYPE_NET_NEW => SubTypes.SUB_TYPE_NET_NEW,
        TYPE_REPLACEMENT => SubTypes.SUB_TYPE_REPLACEMENT,
        TYPE_RETURN => SubTypes.SUB_TYPE_RETURN,
        TYPE_MARKETING_KIT => SubTypes.MARKETING_KIT
    };

    /**
     * @description It is used for generating product bundles for tablet worksteps
     * @param workSteps
     */
    public void generateMxOrderAndSelectProduct(List<WorkStep> workSteps) {
        Map<String, Id> productBundleNameToRecordId = new Map<String, Id>();
        Map<Id, WorkStep> storeIdToWorkStep = new Map<Id, WorkStep>();
        if (workSteps.isEmpty()) {
            return;
        }
        for (WorkStep eachWorkStep : workSteps) {
            if (eachWorkStep.Store_Account__c != null) {
                storeIdToWorkStep.put(eachWorkStep.Store_Account__c, eachWorkStep);
            }
        }
        for (
            Mx_Order_Product_Bundle__c eachMxProductBundle : ProductBundlesSelector.newInstance()
                .selectByName(PRODUCT_BUNDLE_NAMES)
        ) {
            productBundleNameToRecordId.put(eachMxProductBundle.Name, eachMxProductBundle.Id);
        }
        try {
            createMxOrder(storeIdToWorkStep, productBundleNameToRecordId);
        } catch (Exception ex) {
            createLogEntries(ex);
        }
    }

    /**
     * @description It is used for generating photoshoot mxOrders
     * @param workplans
     */
    public void generatePhotoShootMxOrder(List<WorkPlan> workplans) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Map<Id, Id> storeAccountIdToWorkPlanId = new Map<Id, Id>();
        Map<Id, Id> workPlanIdToContactId = new Map<Id, Id>();
        String menuSource;
        Set<Id> workPlanIds = new Map<Id, WorkPlan>(workplans).keySet();
        List<WorkPlan> retrievedWorkPlans = WorkPlansSelector.newInstance()
            .selectWorkPlansWithWorkOrderAndPhotoshootStoreLocationDetails(workPlanIds);
        if (retrievedWorkPlans == null || retrievedWorkPlans.isEmpty()) {
            return;
        }
        for (WorkPlan eachWorkPlan : retrievedWorkPlans) {
            storeAccountIdToWorkPlanId.put(
                eachWorkPlan.WorkOrder.Store_Location_for_Photoshoot__c,
                eachWorkPlan.Id
            );
        }
        workPlanIdToContactId = getWorkPlanIdtoContactId(storeAccountIdToWorkPlanId);
        MX_Order__c mxOrder;
        for (WorkPlan eachWorkPlan : retrievedWorkPlans) {
            mxOrder = new MX_Order__c();
            mxOrder.Account__c = eachWorkPlan.WorkOrder.Store_Location_for_Photoshoot__c;
            mxOrder.Work_Order__c = eachWorkPlan.WorkOrderID;
            mxOrder.Type__c = TYPE_PHOTOSHOOT;
            mxOrder.Status__c = STATUS_DRAFT;
            mxOrder = updateMxOrderAddress(mxOrder, eachWorkPlan.WorkOrder);
            menuSource = getMenuSourceForMxOrder(eachWorkPlan);
            if (String.isNotBlank(menuSource)) {
                mxOrder.Menu_Source_for_Photoshoot__c = menuSource;
            } else {
                mxOrder.Status__c = STATUS_INVALID;
            }
            mxOrder.Reason_for_Additional_Photoshoot__c = eachWorkPlan.WorkOrder.Reason_for_Additional_Photoshoot__c;
            mxOrder.Photoshoot_Review_Notes_Tags__c = eachWorkPlan.WorkOrder.Photoshoot_Review_Notes_and_Tags__c;
            mxOrder.Vendor__c = eachWorkPlan.WorkOrder.Photoshoot_Vendor__c;
            mxOrder.Reason_if_Other__c = eachWorkPlan.WorkOrder.Reason_if_Other__c;
            mxOrder.Work_Plan__c = eachWorkPlan.Id;
            mxOrder.Vendor_PhotoShoot_Date__c  = eachWorkPlan.WorkOrder.Photoshoot_Date__c;
            mxOrder.Vendor_PhotoShoot_Time__c  = eachWorkPlan.WorkOrder.Photoshoot_Time__c;
            Id contactId = getContactIdForMxOrder(eachWorkPlan, workPlanIdToContactId);
            if (contactId != null) {
                mxOrder.Contact__c = contactId;
            }
            uow.registerNew(mxOrder);
        }
        uow.commitWork();
    }

    /**
     * @description It is used for generating "Marketing Kit" MxOrders.
     * @JIRA# LEM-15318
     * @param workplans
     */
    public void generateMarketingKitMxOrders(List<WorkPlan> workplans) {
        Map<Id, Id> workPlanIdToContactId = new Map<Id, Id>();
        Map<Id, Id> storeAccountIdToWorkPlanId = new Map<Id, Id>();
        Map<String, Id> productBundleNameToId = new Map<String, Id>();
        Map<Id, Id> workPlanIdToWorkStepId = new Map<Id, Id>();
        Set<Id> workPlanIds = new Map<Id, WorkPlan>(workplans).keySet();
        Set<Id> preSalesStores = new Set<Id>();
        List<WorkPlan> retrievedWorkPlans = new List<WorkPlan>();
        for (
            WorkPlan eachWorkPlan : WorkPlansSelector.newInstance()
                .selectWorkPlansByWorkPlanIdsAndTypes(
                    workPlanIds,
                    new Set<String>{ TYPE_MARKETING_KIT }
                )
        ) {
            if (eachWorkPlan.Parent_Work_Plan__c != null) {
                storeAccountIdToWorkPlanId.put(eachWorkPlan.WorkOrder.AccountId, eachWorkPlan.Id);
                retrievedWorkPlans.add(eachWorkPlan);
            }
            if (
                eachWorkPlan.WorkOrder.ParentWorkOrder.Creation_Source__c == GUIDED_FLOW ||
                eachWorkPlan.WorkOrder.ParentWorkOrder.Creation_Source__c == CREATION_SOURCE
            ) {
                productBundleNameToId.put(
                    eachWorkPlan?.WorkOrder?.ParentWorkOrder?.Product_Bundle__c,
                    null
                );
            } else {
                preSalesStores.add(eachWorkPlan.WorkOrder.AccountId);
            }
        }
        for (
            WorkStep eachWorkStep : WorkStepsSelector.newInstance()
                .selectByWorkPlanIds(new Map<Id, WorkPlan>(retrievedWorkPlans).keySet())
        ) {
            workPlanIdToWorkStepId.put(eachWorkStep.WorkPlanId, eachWorkStep.Id);
        }
        getProductBundle(productBundleNameToId);
        if (!storeAccountIdToWorkPlanId.isEmpty()) {
            workPlanIdToContactId = getAccountContactRelations(
                preSalesStores,
                storeAccountIdToWorkPlanId
            );
            createMxOrders(
                productBundleNameToId,
                retrievedWorkPlans,
                workPlanIdToContactId,
                workPlanIdToWorkStepId
            );
        }
    }

    /**
     * @description It is used for getting the Contact Id for Mx Order.
     * @param workPlan
     * @param workPlanIdToContactId
     * @return Id
     */
    private Id getContactIdForMxOrder(WorkPlan workPlan, Map<Id, Id> workPlanIdToContactId) {
        Id contactId;
        if (
            workPlan.WorkOrder.Creation_Source__c == GUIDED_FLOW ||
            workPlan.WorkOrder.Creation_Source__c == CREATION_SOURCE
        ) {
            contactId = workPlan.WorkOrder.ContactId;
        } else if (!workPlanIdToContactId.isEmpty()) {
            contactId = workPlanIdToContactId.get(workPlan.Id);
        }
        return contactId;
    }

    /**
     * @description It is used for getting the Contact Id for Mx Order based on parent Work Order.
     * @param workPlan
     * @param workPlanIdToContactId
     * @return Id
     */
    private Id getContactIdFromParentWorkOrder(
        WorkPlan workPlan,
        Map<Id, Id> workPlanIdToContactId
    ) {
        Id contactId;
        if (workPlan.WorkOrder.ParentWorkOrder.Creation_Source__c == GUIDED_FLOW) {
            contactId = workPlan.WorkOrder.ParentWorkOrder.ContactId;
        } else if (workPlan.WorkOrder.Creation_Source__c == CREATION_SOURCE) {
            contactId = workPlan.WorkOrder.ContactId;
        } else if (!workPlanIdToContactId.isEmpty()) {
            contactId = workPlanIdToContactId.get(workPlan.Id);
        }
        return contactId;
    }

    /**
     * @description It is used for getting the Contact Id for Mx Order.
     * @param workPlan
     * @return String
     */
    private String getMenuSourceForMxOrder(WorkPlan workPlan) {
        String menuSource;
        if (
            workPlan.WorkOrder.Creation_Source__c == GUIDED_FLOW ||
            workPlan.WorkOrder.Creation_Source__c == CREATION_SOURCE
        ) {
            menuSource = workPlan.WorkOrder.Menu_Preview_Link__c;
        } else {
            menuSource = workPlan.WorkOrder.Store_Location_for_Photoshoot__r.Menu_URL__c;
        }
        return menuSource;
    }

    /**
     * @description It is used for getting WorkPlanId To Contact Id map.
     * @param storeAccountIdToWorkPlan
     * @return Map<Id, Id>
     */
    private Map<Id, Id> getWorkPlanIdtoContactId(Map<Id, Id> storeAccountIdToWorkPlan) {
        Map<Id, Id> workPlanIdToContactId = new Map<Id, Id>();
        Map<Id, Id> storeAccountIdToPhotoshootContactId = new Map<Id, Id>();
        Map<Id, Id> storeAccountIdToDecisionMakerContactId = new Map<Id, Id>();
        List<AccountContactRelation> accountContactRelations = AccountContactRelationsSelector.newInstance()
            .selectPhotoshootContactRolesByAccountIds(storeAccountIdToWorkPlan.keySet());
        for (AccountContactRelation eachAccountContactRelation : accountContactRelations) {
            if (eachAccountContactRelation.Roles.contains(PHOTOSHOOT_ROLE)) {
                if (
                    !storeAccountIdToPhotoshootContactId.containsKey(
                        eachAccountContactRelation.AccountId
                    )
                ) {
                    storeAccountIdToPhotoshootContactId.put(
                        eachAccountContactRelation.AccountId,
                        eachAccountContactRelation.ContactId
                    );
                }
            } else {
                if (
                    !storeAccountIdToDecisionMakerContactId.containsKey(
                        eachAccountContactRelation.AccountId
                    )
                ) {
                    storeAccountIdToDecisionMakerContactId.put(
                        eachAccountContactRelation.AccountId,
                        eachAccountContactRelation.ContactId
                    );
                }
            }
        }
        for (Id eachStoreAccountId : storeAccountIdToWorkPlan.keySet()) {
            if (storeAccountIdToPhotoshootContactId.containsKey(eachStoreAccountId)) {
                workPlanIdToContactId.put(
                    storeAccountIdToWorkPlan.get(eachStoreAccountId),
                    storeAccountIdToPhotoshootContactId.get(eachStoreAccountId)
                );
            } else if (storeAccountIdToDecisionMakerContactId.containsKey(eachStoreAccountId)) {
                workPlanIdToContactId.put(
                    storeAccountIdToWorkPlan.get(eachStoreAccountId),
                    storeAccountIdToDecisionMakerContactId.get(eachStoreAccountId)
                );
            }
        }
        return workPlanIdToContactId;
    }

    /**
     * @description It is used for generating Mx Order records for Tablet Work Steps of Sub Type Net New
     * @param flowInput
     * @param isNetNew
     */
    public void generateMerchantOrder(GuidedFlowInputs flowInput, Boolean isNetNew) {
        try{
            MX_Order__c newMxOrder = new MX_Order__c();
            fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            Account storeAccount = AccountsSelector.newInstance()
                .selectById(new Set<Id>{ flowInput.accountId })[0];
            newMxOrder.Account__c = flowInput.accountId;
            newMxOrder.Store_Order_Protocol__c = storeAccount.Order_Protocol__c;
            newMxOrder.Shipping_Carrier__c = shippingCarrier(flowInput.shippingCountryCode);
            newMxOrder.Shipping_Type__c = expeditedAccount(storeAccount)
                ? SHIPPING_TYPE_EXPEDITED
                : SHIPPING_TYPE_STANDARD;
            newMxOrder.Contact__c = flowInput.contactId;
            newMxOrder.Work_Order__c = flowInput.workOrderId;
            newMxOrder.Merchant_Address__CountryCode__s = flowInput.shippingCountryCode;
            newMxOrder.Merchant_Address__City__s = flowInput.shippingCity;
            newMxOrder.Merchant_Address__Street__s = flowInput.shippingStreet;
            newMxOrder.Merchant_Address__StateCode__s = flowInput.shippingStateCode;
            newMxOrder.Merchant_Address__PostalCode__s = flowInput.shippingPostalCode;
            newMxOrder.Status__c = STATUS_DRAFT;
            collectWorkStepDetails(isNetNew, newMxOrder, flowInput.workOrderId);
            setValuesByTypeOfRequest(flowInput, isNetNew, newMxOrder);
            if (String.isNotBlank(flowInput.productBundleName)) {
                String bundleName = TYPE_RETURN != newMxOrder.Type_Of_Request__c
                    ? flowInput.productBundleName
                    : RETURN_LABEL_BUNDLE;
                List<Mx_Order_Product_Bundle__c> productBundles = ProductBundlesSelector.newInstance()
                    .selectByName(new List<String>{ bundleName });
                newMxOrder.Product_Bundle__c = !productBundles.isempty() ? productBundles[0].Id : null;
            }
            uow.registerNew(newMxOrder);
            uow.commitWork();
        } catch (Exception ex) {
            createLogEntries(ex);
        }
    }

    /**
     * @description It is used for collecting Work Step details based on Work Order Id.
     * @param isNetNew
     * @param mxOrderInstance
     * @param workOrderId
     */
    private void collectWorkStepDetails(
        Boolean isNetNew,
        Mx_Order__c mxOrderInstance,
        Id workOrderId
    ) {
        List<WorkStep> workStepsDetails = new List<WorkStep>();
        String workStepType = isNetNew ? WORK_STEP_TYPE_TABLET : WORK_STEP_TYPE_RETURN;
        workStepsDetails.addAll(
            WorkStepsSelector.newInstance()
                .selectReturnLabelWorkStepsByWorkOrderIdsAndType(
                    new Set<Id>{ workOrderId },
                    new Set<String>{ workStepType }
                )
        );
        if (!workStepsDetails.isEmpty()) {
            mxOrderInstance.Work_Step__c = workStepsDetails[0].Id;
            mxOrderInstance.Work_Plan__c = workStepsDetails[0].WorkPlanId;
            mxOrderInstance.Parent_Work_Plan__c = workStepsDetails[0].WorkPlan.Parent_Work_Plan__c;
        }
    }

    /**
     * @description It is used for creating Mx Orders.
     * @param storeIdToWorkStep
     * @param productBundleNameToRecordId
     */
    private void createMxOrder(
        Map<Id, WorkStep> storeIdToWorkStep,
        Map<String, Id> productBundleNameToRecordId
    ) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        MX_Order__c newMxOrder;
        Map<Id, Id> storeIdToContact = AccountContactRelationsService.mapStoreIdToContactId(
            storeIdToWorkStep.keySet()
        );
        for (
            Account eachStoreAccount : AccountsSelector.newInstance()
                .selectById(storeIdToWorkStep.keySet())
        ) {
            newMxOrder = new MX_Order__c();
            if (
                ORDER_PROTOCOLS_WITH_NO_PRINTER.contains(eachStoreAccount.Order_Protocol__c) &&
                eachStoreAccount.BillingCountryCode != null
            ) {
                switch on BILLING_COUNTRY_CODES_TO_NAME.get(eachStoreAccount.BillingCountryCode) {
                    when BILLING_COUNTRY_CODE_AUS {
                        newMxOrder.Product_Bundle__c = productBundleNameToRecordId.get(
                            TABLET_BUNDLE_AUS
                        );
                    }
                    when BILLING_COUNTRY_CODE_US {
                        newMxOrder.Product_Bundle__c = productBundleNameToRecordId.get(
                            TABLET_BUNDLE_US
                        );
                    }
                    when BILLING_COUNTRY_CODE_CAN {
                        newMxOrder.Product_Bundle__c = productBundleNameToRecordId.get(
                            TABLET_BUNDLE_CAN
                        );
                    }
                    when BILLING_COUNTRY_CODE_NZ {
                        newMxOrder.Product_Bundle__c = productBundleNameToRecordId.get(
                            TABLET_BUNDLE_NZ
                        );
                    }
                }
            } else if (
                ORDER_PROTOCOLS_WITH_TABLET_AND_PRINTER.contains(eachStoreAccount.Order_Protocol__c)
            ) {
                switch on BILLING_COUNTRY_CODES_TO_NAME.get(eachStoreAccount.BillingCountryCode) {
                    when BILLING_COUNTRY_CODE_AUS {
                        newMxOrder.Product_Bundle__c = productBundleNameToRecordId.get(
                            TABLET_AND_PRINTER_BUNDLE_AUS
                        );
                    }
                    when BILLING_COUNTRY_CODE_US {
                        newMxOrder.Product_Bundle__c = productBundleNameToRecordId.get(
                            TABLET_AND_PRINTER_BUNDLE_US
                        );
                    }
                    when BILLING_COUNTRY_CODE_CAN {
                        newMxOrder.Product_Bundle__c = productBundleNameToRecordId.get(
                            TABLET_AND_PRINTER_BUNDLE_CAN
                        );
                    }
                    when BILLING_COUNTRY_CODE_NZ {
                        newMxOrder.Product_Bundle__c = productBundleNameToRecordId.get(
                            TABLET_AND_PRINTER_BUNDLE_NZ
                        );
                    }
                }
            }

            newMxOrder.Work_Step__c = storeIdToWorkStep.get(eachStoreAccount.Id).Id;
            newMxOrder.Work_Plan__c = storeIdToWorkStep.get(eachStoreAccount.Id).WorkPlanId;
            newMxOrder.Parent_Work_Plan__c = storeIdToWorkStep.get(eachStoreAccount.Id)
                .Parent_Work_Plan__c;
            newMxOrder.Work_Order__c = storeIdToWorkStep.get(eachStoreAccount.Id).WorkOrderId;
            newMxOrder.Account__c = eachStoreAccount.Id;
            newMxOrder.Store_Order_Protocol__c = eachStoreAccount.Order_Protocol__c;
            newMxOrder.Shipping_Carrier__c = shippingCarrier(eachStoreAccount.BillingCountryCode);
            newMxOrder.Shipping_Type__c = expeditedAccount(eachStoreAccount)
                ? SHIPPING_TYPE_EXPEDITED
                : SHIPPING_TYPE_STANDARD;
            newMxOrder.Contact__c = storeIdToContact.get(eachStoreAccount.Id);
            newMxOrder.Type__c = TYPE_TABLET;
            newMxOrder.Status__c = STATUS_DRAFT;
            newMxOrder.Type_Of_Request__c = TYPE_NET_NEW;
            newMxOrder.Order_Status_Modified_Date__c = System.today();
            newMxOrder.Merchant_Address__CountryCode__s = eachStoreAccount.BillingCountryCode;
            newMxOrder.Merchant_Address__StateCode__s = eachStoreAccount.BillingStateCode;
            newMxOrder.Merchant_Address__City__s = eachStoreAccount.BillingCity;
            newMxOrder.Merchant_Address__Street__s = eachStoreAccount.BillingStreet;
            newMxOrder.Merchant_Address__PostalCode__s = eachStoreAccount.BillingPostalCode;
            uow.registerNew(newMxOrder);
        }
        uow.commitWork();
    }

    /**
     * @description It creates Mx Orders for Marketing Kit Work Orders.
     * @JIRA# LEM-15318
     * @param productBundleNameToId
     * @param workPlans
     * @param workPlanIdToContactId
     * @param workPlanIdToWorkStepId
     */
    private void createMxOrders(
        Map<String, Id> productBundleNameToId,
        List<WorkPlan> workPlans,
        Map<Id, Id> workPlanIdToContactId,
        Map<Id, Id> workPlanIdToWorkStepId
    ) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        MX_Order__c mxOrder;
        Id contactId;
        String selectedProductBundleName;
        for (WorkPlan eachWorkPlan : workPlans) {
            mxOrder = new MX_Order__c();
            mxOrder.Account__c = eachWorkPlan.WorkOrder.AccountId;
            mxOrder.Work_Order__c = eachWorkPlan.WorkOrderId;
            mxOrder.Type__c = TYPE_MARKETING_KIT;
            mxOrder.Type_Of_Request__c = TYPE_MARKETING_KIT;
            mxOrder.Status__c = STATUS_DRAFT;
            mxOrder.Vendor__c = VENDOR_OVERTURE;
            selectedProductBundleName = eachWorkPlan?.WorkOrder?.ParentWorkOrder?.Product_Bundle__c;
            if (selectedProductBundleName != null) {
                mxOrder.Product_Bundle__c = productBundleNameToId.containsKey(
                        selectedProductBundleName
                    )
                    ? productBundleNameToId.get(selectedProductBundleName)
                    : null;
            }
            mxOrder = setMxOrderAddressOnMarketingKitMxOrder(mxOrder, eachWorkPlan.WorkOrder);
            mxOrder.Parent_Work_Plan__c = eachWorkPlan.Parent_Work_Plan__c;
            mxOrder.Work_Plan__c = eachWorkPlan.Id;
            mxOrder.Work_Step__c = workPlanIdToWorkStepId.get(eachWorkPlan.Id);
            mxOrder.Shipping_Type__c = expeditedAccount(eachWorkPlan.WorkOrder.Account)
                ? SHIPPING_TYPE_EXPEDITED
                : SHIPPING_TYPE_STANDARD;
            if (eachWorkPlan.WorkOrder.ParentWorkOrder.Creation_Source__c != CREATION_SOURCE) {
                mxOrder.Store_Order_Protocol__c = eachWorkPlan.WorkOrder.Account.Order_Protocol__c;
            } else {
                mxOrder.Store_Order_Protocol__c = eachWorkPlan.WorkOrder.Order_Protocol__c;
            }
            contactId = getContactIdFromParentWorkOrder(eachWorkPlan, workPlanIdToContactId);
            if (contactId != null) {
                mxOrder.Contact__c = contactId;
            }
            uow.registerNew(mxOrder);
        }
        uow.commitWork();
    }

    /**
     * @description It is used to check for fetching Product Bundle Id for Mx Order creation.
     * @param productBundleNameToId
     */
    private void getProductBundle(Map<String, Id> productBundleNameToId) {
        for (
            Mx_Order_Product_Bundle__c eachProductBundle : ProductBundlesSelector.newInstance()
                .selectByName(new List<String>(productBundleNameToId.keySet()))
        ) {
            productBundleNameToId.put(eachProductBundle.Name, eachProductBundle.Id);
        }
    }
    private String shippingCarrier(String country) {
        return (country == 'US' ||
            country == 'CA')
            ? 'FedEx'
            : country == 'AU' ? 'StarTrack' : country == 'NZ' ? 'DHLExpress' : 'FedEx';
    }
    /**
     * @description It is used to check for Expedited Accounts
     * @param storeAccount
     * @return Boolean
     */
    private Boolean expeditedAccount(Account storeAccount) {
        String storeAccountSegment = storeAccount.Segment__c == SEGMENT_MID_MARKET
            ? SEGMENT_ENTERPRISE
            : storeAccount.Segment__c;
        if (
            storeAccountSegment == SEGMENT_ENTERPRISE ||
            EXPEDITED_DECK_RANK.contains(storeAccount.Deck_Rank__c)
        ) {
            return true;
        }
        return false;
    }

    /**
     * @description It retrieves Account Contact Relations for the passed Account Ids.
     * @JIRA# LEM-15318
     * @param accountIds
     * @param storeAccountIdToWorkPlanId
     * @return Map<Id,Id>
     */
    private Map<Id, Id> getAccountContactRelations(
        Set<Id> accountIds,
        Map<Id, Id> storeAccountIdToWorkPlanId
    ) {
        Id workPlanId;
        Map<Id, Id> workPlanIdToContactId = new Map<Id, Id>();
        for (
            AccountContactRelation eachRelation : AccountContactRelationsSelector.newInstance()
                .selectByAccountIds(accountIds)
        ) {
            workPlanId = storeAccountIdToWorkPlanId.get(eachRelation.AccountId);
            if (!workPlanIdToContactId.containsKey(workPlanId)) {
                workPlanIdToContactId.put(workPlanId, eachRelation.ContactId);
            }
        }
        return workPlanIdToContactId;
    }

    /**
     * @description It updates Mx Order Address for Marketing Kit based on Work Order Creation Source.
     * @JIRA# LEM-15318
     * @param mxOrder
     * @param parentWorkOrder
     * @return MX_Order__c
     */
    private MX_Order__c setMxOrderAddressOnMarketingKitMxOrder(
        MX_Order__c mxOrder,
        WorkOrder parentWorkOrder
    ) {
        if (parentWorkOrder.ParentWorkOrder.Creation_Source__c == GUIDED_FLOW) {
            mxOrder.Merchant_Address__CountryCode__s = parentWorkOrder.ParentWorkOrder.Photoshoot_Address__CountryCode__s;
            mxOrder.Merchant_Address__City__s = parentWorkOrder.ParentWorkOrder.Photoshoot_Address__City__s;
            mxOrder.Merchant_Address__Street__s = parentWorkOrder.ParentWorkOrder.Photoshoot_Address__Street__s;
            mxOrder.Merchant_Address__StateCode__s = parentWorkOrder.ParentWorkOrder.Photoshoot_Address__StateCode__s;
            mxOrder.Merchant_Address__PostalCode__s = parentWorkOrder.ParentWorkOrder.Photoshoot_Address__PostalCode__s;
        } else {
            mxOrder.Merchant_Address__CountryCode__s = parentWorkOrder.Account.BillingCountryCode;
            mxOrder.Merchant_Address__City__s = parentWorkOrder.Account.BillingCity;
            mxOrder.Merchant_Address__Street__s = parentWorkOrder.Account.BillingStreet;
            mxOrder.Merchant_Address__StateCode__s = parentWorkOrder.Account.BillingStateCode;
            mxOrder.Merchant_Address__PostalCode__s = parentWorkOrder.Account.BillingPostalCode;
        }
        return mxOrder;
    }

    /**
     * @description It updates Mx Order field values on the basis of Type of Request.
     * @JIRA# LEM-14124
     * @param flowInput
     * @param isNetNew
     * @param newMxOrder
     */
    private void setValuesByTypeOfRequest(
        GuidedFlowInputs flowInput,
        Boolean isNetNew,
        Mx_Order__c newMxOrder
    ) {
        switch on WORK_STEP_SUB_TYPE_MAPPINGS.get(flowInput.typeOfRequest) {
            when SUB_TYPE_NET_NEW {
                newMxOrder.Type__c = TYPE_TABLET;
                newMxOrder.Type_Of_Request__c = flowInput.typeOfRequest;
            }
            when SUB_TYPE_REPLACEMENT {
                newMxOrder.Type_Of_Request__c = isNetNew ? flowInput.typeOfRequest : TYPE_RETURN;
                updateReturnAndReplacementDetails(flowInput, newMxOrder);
            }
            when SUB_TYPE_RETURN {
                newMxOrder.Type_Of_Request__c = TYPE_RETURN;
                updateReturnAndReplacementDetails(flowInput, newMxOrder);
            }
        }
    }

    /**
     * @description It updates Mx Order Address field values on the basis of parent Work Order.
     * @JIRA# LEM-13595
     * @param mxOrder
     * @param parentWorkOrder
     * @return MX_Order__c
     */
    private MX_Order__c updateMxOrderAddress(MX_Order__c mxOrder, WorkOrder parentWorkOrder) {
        if (parentWorkOrder.Creation_Source__c == GUIDED_FLOW) {
            mxOrder.Merchant_Address__CountryCode__s = parentWorkOrder.Photoshoot_Address__CountryCode__s;
            mxOrder.Merchant_Address__City__s = parentWorkOrder.Photoshoot_Address__City__s;
            mxOrder.Merchant_Address__Street__s = parentWorkOrder.Photoshoot_Address__Street__s;
            mxOrder.Merchant_Address__StateCode__s = parentWorkOrder.Photoshoot_Address__StateCode__s;
            mxOrder.Merchant_Address__PostalCode__s = parentWorkOrder.Photoshoot_Address__PostalCode__s;
        } else {
            mxOrder.Merchant_Address__CountryCode__s = parentWorkOrder.Store_Location_for_Photoshoot__r.BillingCountryCode;
            mxOrder.Merchant_Address__City__s = parentWorkOrder.Store_Location_for_Photoshoot__r.BillingCity;
            mxOrder.Merchant_Address__Street__s = parentWorkOrder.Store_Location_for_Photoshoot__r.BillingStreet;
            mxOrder.Merchant_Address__StateCode__s = parentWorkOrder.Store_Location_for_Photoshoot__r.BillingStateCode;
            mxOrder.Merchant_Address__PostalCode__s = parentWorkOrder.Store_Location_for_Photoshoot__r.BillingPostalCode;
        }
        return mxOrder;
    }

    /**
     * @description It updates Mx Order Address field values on the basis of parent Work Order.
     * @JIRA# LEM-13595
     * @param flowInput
     * @param mxOrder
     */
    private void updateReturnAndReplacementDetails(
        GuidedFlowInputs flowInput,
        MX_Order__c mxOrder
    ) {
        mxOrder.Reason_for_Replacement__c = flowInput.replacementReason;
        mxOrder.Replacement_Reason_Other__c = flowInput.reasonForReturn;
        mxOrder.Type__c = TYPE_TABLET;
        if (String.isNotBlank(flowInput?.tabletIMEI)) {
            mxOrder.Tablet_IMEI__c = flowInput?.tabletIMEI;
        }
        if (String.isNotBlank(flowInput?.printerIMEI)) {
            mxOrder.Printer_IMEI__c = flowInput?.printerIMEI;
        }
    }

    /**
     * @description It is used for generating Merchant Orders for tablet worksteps
     * @JIRA# LEM-15978
     * @param workSteps
     * @param childWOToStagingRequest
     */
    public void generateMxOrderForTabletBulkRequest(
        Map<Id, WorkStep> workSteps,
        Map<Id, Staging_Bulk_Upload_Request__c> childWOToStagingRequest
    ) {
        Map<String, Id> productBundleNameToId = new Map<String, Id>();
        Map<Id, WorkStep> storeIdToWorkStep = new Map<Id, WorkStep>();
        if (workSteps.isEmpty()) {
            return;
        }
        for (WorkStep eachWorkStep : workSteps.values()) {
            if (eachWorkStep.Store_Account__c != null) {
                storeIdToWorkStep.put(eachWorkStep.Store_Account__c, eachWorkStep);
                productBundleNameToId.put(
                    childWOToStagingRequest.get(eachWorkStep.WorkOrderId)?.Product_Bundle__c,
                    null
                );
            }
        }
        getProductBundle(productBundleNameToId);
        createBulkMxOrders(
            storeIdToWorkStep,
            workSteps,
            childWOToStagingRequest,
            productBundleNameToId
        );
    }

    /**
     * @description It is used to create Bulk Merchant Orders
     * @JIRA# LEM-15978
     * @param storeIdToWorkStep
     * @param workStepIdToWorkStep
     * @param childWOToStagingRequest
     * @param productBundleNameToId
     */
    private void createBulkMxOrders(
        Map<Id, WorkStep> storeIdToWorkStep,
        Map<Id, WorkStep> workStepIdToWorkStep,
        Map<Id, Staging_Bulk_Upload_Request__c> childWOToStagingRequest,
        Map<String, Id> productBundleNameToId
    ) {
        String selectedProductBundleName;
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Map<Id, Account> storeIdToStoreAccount = new Map<id, Account>(
            AccountsSelector.newInstance().selectById(storeIdToWorkStep.keySet())
        );
        for (WorkStep eachWorkStep : workStepIdToWorkStep.values()) {
            Staging_Bulk_Upload_Request__c currentStagingRecord = childWOToStagingRequest.get(
                eachWorkStep.WorkOrderId
            );
            MX_Order__c newMxOrder = new MX_Order__c();
            selectedProductBundleName = currentStagingRecord?.Product_Bundle__c;
            if (String.isNotBlank(selectedProductBundleName)) {
                newMxOrder.Product_Bundle__c = productBundleNameToId.containsKey(
                        selectedProductBundleName
                    )
                    ? productBundleNameToId.get(selectedProductBundleName)
                    : null;
            }
            newMxOrder.Work_Step__c = eachWorkStep.Id;
            newMxOrder.Work_Plan__c = eachWorkStep.WorkPlanId;
            newMxOrder.Work_Order__c = eachWorkStep.WorkOrderId;
            newMxOrder.Account__c = eachWorkStep.Store_Account__c;
            newMxOrder.Store_Order_Protocol__c = currentStagingRecord?.Order_Protocol__c;
            newMxOrder.Shipping_Carrier__c = shippingCarrier(
                storeIdToStoreAccount.get(eachWorkStep.Store_Account__c).BillingCountryCode
            );
            newMxOrder.Shipping_Type__c = currentStagingRecord?.Shipping_Type__c;
            newMxOrder.Contact__c = currentStagingRecord?.Contact_Id__c;
            newMxOrder.Type__c = currentStagingRecord?.Type__c;
            newMxOrder.Status__c = STATUS_DRAFT;
            newMxOrder.Type_Of_Request__c = eachWorkStep.Type__c == WORK_STEP_TYPE_RETURN
                ? TYPE_RETURN
                : currentStagingRecord?.Request_Type__c;
            newMxOrder.Order_Status_Modified_Date__c = System.today();
            newMxOrder.Merchant_Address__CountryCode__s = storeIdToStoreAccount.get(
                    eachWorkStep.Store_Account__c
                )
                .BillingCountryCode;
            newMxOrder.Merchant_Address__StateCode__s = storeIdToStoreAccount.get(
                    eachWorkStep.Store_Account__c
                )
                .BillingStateCode;
            newMxOrder.Merchant_Address__City__s = storeIdToStoreAccount.get(
                    eachWorkStep.Store_Account__c
                )
                .BillingCity;
            newMxOrder.Merchant_Address__Street__s = storeIdToStoreAccount.get(
                    eachWorkStep.Store_Account__c
                )
                .BillingStreet;
            newMxOrder.Merchant_Address__PostalCode__s = storeIdToStoreAccount.get(
                    eachWorkStep.Store_Account__c
                )
                .BillingPostalCode;
            if (
                currentStagingRecord?.Request_Type__c == TYPE_RETURN ||
                currentStagingRecord?.Request_Type__c == TYPE_REPLACEMENT
            ) {
                newMxOrder.Reason_for_Replacement__c = currentStagingRecord?.Replacement_Reason__c;
                newMxOrder.Replacement_Reason_Other__c = currentStagingRecord
                    ?.Replacement_Reason_if_Other__c;
                if (String.isNotBlank(currentStagingRecord?.Defective_Tablet_IMEI__c)) {
                    newMxOrder.Tablet_IMEI__c = currentStagingRecord.Defective_Tablet_IMEI__c;
                }
                if (String.isNotBlank(currentStagingRecord?.Defective_Printer_IMEI__c)) {
                    newMxOrder.Printer_IMEI__c = currentStagingRecord.Defective_Printer_IMEI__c;
                }
            }
            uow.registerNew(newMxOrder);
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            createLogEntries(ex);
        }
    }

    /**
     * @description It is used to create Log Entries.
     * @param mxOrderCreationException
     */
    public void createLogEntries(Exception mxOrderCreationException) {
        Logger.publish(LogEntry.newExceptionLog(mxOrderCreationException, LogEntry.SeverityLevel.LOW));
        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                    LOG_CREATE_MX_ORDERS_FAILED,
                    LOG_DOMAIN,
                    GenericLogEntry.SeverityLevel.LOW
                )
                .logException(mxOrderCreationException)
                );
    }
}