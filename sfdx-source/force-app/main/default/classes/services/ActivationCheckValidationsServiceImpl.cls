/**
 * @author Deloitte
 * @date 04/02/2024
 * @description Service implementation class for Activation Checklist validations.
 */
@SuppressWarnings(
    'PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.TooManyFields, PMD.ExcessiveParameterList, PMD.ExcessiveClassLength'
)
public inherited sharing class ActivationCheckValidationsServiceImpl implements IActivationChecklistValidationService {
    private enum MethodTypes {
        PDOAINFUTURE,
        MERCHANTSUPPLIEDID,
        BUSINESSISACTIVE,
        SUBMARKETID,
        STARTINGPOINTID,
        BANKINGINFORMATION,
        STOREISPARTNER,
        ORDERPROTOCOL,
        BUSINESSID,
        TIERLEVEL,
        ACTIVEMENUCOUNT,
        OFFERSPICKUPDELIVERYDASHPASS,
        PRICINGPROGRAM
    }
    private static final Map<String, MethodTypes> METHODNAMETOMETHODTYPES = new Map<String, MethodTypes>{
        'validateMerchantSuppliedId' => MethodTypes.MERCHANTSUPPLIEDID,
        'validateBusinessIsActive' => MethodTypes.BUSINESSISACTIVE,
        'validateSubmarket' => MethodTypes.SUBMARKETID,
        'validateStartingPointId' => MethodTypes.STARTINGPOINTID,
        'validateTierLevel' => MethodTypes.TIERLEVEL,
        'validateBankingInformation' => MethodTypes.BANKINGINFORMATION,
        'validateStoreIsPartner' => MethodTypes.STOREISPARTNER,
        'validateOrderProtocol' => MethodTypes.ORDERPROTOCOL,
        'validateBusinessId' => MethodTypes.BUSINESSID,
        'validatePDOA' => MethodTypes.PDOAINFUTURE,
        'validateTierLevel' => MethodTypes.TIERLEVEL,
        'validateActiveMenuCount' => MethodTypes.ACTIVEMENUCOUNT,
        'validateOffersPickupDeliveryDashpass' => MethodTypes.OFFERSPICKUPDELIVERYDASHPASS,
        'validateCommissionRates' => MethodTypes.PRICINGPROGRAM
    };
    private static final String FAILURE_RESULT = 'Fail';
    private static final String LOG_SERVICE_ACTIVATION_CHECKLIST = 'Activation Checklist Validation Service';
    private static final String LOG_DOMAIN_ACTIVATION_CHECKLIST = 'Activation Checklist';
    private static final String MX_SERVICE_ACTIVE_YES = 'Yes';
    private static final String NOT_APPLICABLE = 'N/A';
    private static final String ORDER_PROTOCOL_IPAD = 'IPAD';
    private static final String ORDER_PROTOCOL_POINT_OF_SALE = 'POINT_OF_SALE';
    private static final String ORDER_PROTOCOL_POS = 'POS';
    private static final String ORDER_PROTOCOL_TABLET = 'Tablet';
    private static final String SUCCESS_RESULT = 'Pass';
    private static final String SUCCESS_STATUS_RESULT = 'Passed';
    private static final String FAILURE_STATUS_RESULT = 'Failed';
    private static final String VALIDATION_STATUS_COMPLETED = 'Completed';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_STATUS_ESCALATED = 'Escalated';
    private static final String PROPOSED_DATE_OF_ACTIVATION = 'Proposed_Date_of_Activation__c';
    private static final String STORE_ACCOUNT = 'Store Account';
    private static final String TARGET_MINT = 'MINT';
    private static final String TARGET_STORE_AND_MINT = 'MINT / Store Account';
    private static final String TARGET_BIZREF_AND_MINT = 'MINT / Business Reference';
    private static final String TARGET_MINT_SERVICES_ON_STORE = 'MINT / Services on Store';
    private static final String TARGET_WORK_ORDER = 'Work Order';
    private static final String STRING_FALSE = 'false';
    private static final String STRING_TRUE = 'true';
    private static final String STRING_HREF = 'href=';
    private static final String STRING_TARGET = 'target=';
    private static final String STRING_DOUBLE_QUOTES = '"';
    private static final String STORE_PARTNERSHIP_PRICING_PROGRAM = 'Store Partnership';
    private static final String PRODUCT_EXPERIENCE_ANY = 'ANY_EXPERIENCE';
    private static final String PRODUCT_CHANNEL_ANY = 'ANY_CHANNEL';
    private static final String PRODUCT_FULFILLMENT_TYPE_ANY = 'ANY_FULFILLMENT_TYPE';
    private static final String PRODUCT_AUDIENCE_ANY = 'ANY_AUDIENCE';
    private static final String WORKORDER_STATUS_DEAD = 'Dead';

    private List<Activation_Checklist__c> activationChecklists;
    private List<Activation_Checklist__c> activationChecklistsToBeUpdated;
    private Set<Id> completedStoreWorkPlanIds;
    private Set<Id> deadChildWorkOrderStoreIds;
    private List<Account> storeAccounts;
    private Set<String> accountsIdStrings;
    private Set<Id> passedStoreWorkStepIds;
    private Set<Id> failedStoreWorkStepIds;
    private Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts;
    private Map<Id, WorkStep> storeIdToWorkStep;
    private Map<Id, Account> idToStoreAccounts;
    private Map<Id, List<Activation_Checklist__c>> storeIdToActivationChecklists;
    private Set<Id> storeIdsToRunValidation;
    private Map<Id, String> storeIdToSubmarket;
    private Map<Id, List<Merchant_Service__c>> storeIdToServices;

    /**
     * @description Default Constructor to initialize class variables.
     */
    public ActivationCheckValidationsServiceImpl() {
        this.storeIdToSubmarket = new Map<Id, String>();
        this.activationChecklists = new List<Activation_Checklist__c>();
        this.activationChecklistsToBeUpdated = new List<Activation_Checklist__c>();
        this.completedStoreWorkPlanIds = new Set<Id>();
        this.deadChildWorkOrderStoreIds = new Set<Id>();
        this.failedStoreWorkStepIds = new Set<Id>();
        this.passedStoreWorkStepIds = new Set<Id>();
        this.storeAccounts = new List<Account>();
        this.idToStoreAccounts = new Map<Id, Account>();
        this.storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>();
        this.storeIdToWorkStep = new Map<Id, WorkStep>();
        this.storeIdToActivationChecklists = new Map<Id, List<Activation_Checklist__c>>();
        this.storeIdsToRunValidation = new Set<Id>();
        this.accountsIdStrings = new Set<String>();
        this.storeIdToServices = new Map<Id, List<Merchant_Service__c>>();
    }

    // Run validations (Store Account , Activation Checklist Wrapper for Store Account)

    // Query Store Account details & Work Plan (Activation checklist child Work Plans)

    /**
     * @description It performs readiness validations on the store Accounts
     * associated with passed Work Orders according to the rules configured in the custom metadata.
     * @JIRA# LEM-1684
     * @param storeAccounts
     * @param mintStoreAccounts
     * @param activationChecklistValidations
     */
    public void validateStoreAccount(
        List<Account> storeAccounts,
        Map<Id, ActivationChecklistWrapper> mintStoreAccounts,
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations
    ) {
        this.storeAccounts = storeAccounts;
        this.storeIdToMintStoreAccounts = mintStoreAccounts;
        this.idToStoreAccounts = new Map<Id, Account>(storeAccounts);
        getWorkStepsAndWorkPlan(storeIdToMintStoreAccounts);
        getActivationChecklists();
        getSubmarkets();
        getServices();
        runValidations(activationChecklistValidations);
        publishActivationChecklistRecords();
        WorkPlansService.updateActivationChecklistValidationStatusOnWorkPlans(
            completedStoreWorkPlanIds,
            VALIDATION_STATUS_COMPLETED
        );
        if (!passedStoreWorkStepIds.isEmpty()) {
            WorkStepsService.updateActivationChecklistWorkStepsStatus(
                passedStoreWorkStepIds,
                false,
                WORK_STEP_STATUS_COMPLETE
            );
        }
        if (!failedStoreWorkStepIds.isEmpty()) {
            WorkStepsService.updateActivationChecklistWorkStepsStatus(
                failedStoreWorkStepIds,
                false,
                WORK_STEP_STATUS_ESCALATED
            );
        }
    }

    private void getWorkStepsAndWorkPlan(
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts
    ) {
        Set<Id> workStepIds = new Set<Id>();
        for (Id eachStoreId : storeIdToMintStoreAccounts.keySet()) {
            workStepIds.add((Id) storeIdToMintStoreAccounts.get(eachStoreId)?.workStepSalesforceId);
        }
        for (WorkStep eachWorkStep : WorkStepsSelector.newInstance().selectByIds(workStepIds)) {
            if (eachWorkStep.WorkPlan.WorkOrder.Status == WORKORDER_STATUS_DEAD) {
                deadChildWorkOrderStoreIds.add(eachWorkStep.Store_Account__c);
            } else {
                storeIdToWorkStep.put(eachWorkStep.Store_Account__c, eachWorkStep);
            }
        }
    }

    private void getActivationChecklists() {
        Map<Id, Id> storeIdToWorkPlanId = new Map<Id, Id>();
        for (Account eachStoreAccount : storeAccounts) {
            if (!deadChildWorkOrderStoreIds.contains(eachStoreAccount.Id)) {
                storeIdsToRunValidation.add(eachStoreAccount.Id);
                accountsIdStrings.add((String) (eachStoreAccount.Id));
                if (!storeIdToWorkPlanId.containsKey(eachStoreAccount.Id)) {
                    storeIdToWorkPlanId.put(
                        eachStoreAccount.Id,
                        storeIdToWorkStep.get(eachStoreAccount.Id).WorkPlan.Parent_Work_Plan__c
                    );
                }
            }
        }
        for (
            Activation_Checklist__c eachActivationChecklist : ActivationChecklistsSelector.newInstance()
                .selectByStoreIds(storeIdsToRunValidation)
        ) {
            if (
                !storeIdToActivationChecklists.containsKey(eachActivationChecklist.Store_Account__c)
            ) {
                storeIdToActivationChecklists.put(
                    eachActivationChecklist.Store_Account__c,
                    new List<Activation_Checklist__c>()
                );
            }
            if (
                eachActivationChecklist.Work_Plan__c ==
                storeIdToWorkPlanId.get(eachActivationChecklist.Store_Account__c)
            ) {
                storeIdToActivationChecklists.get(eachActivationChecklist.Store_Account__c)
                    .add(eachActivationChecklist);
            }
        }
    }

    private void getSubmarkets() {
        for (
            Account eachStoreAccount : AccountsSelector.newInstance().selectById(accountsIdStrings)
        ) {
            storeIdToSubmarket.put(
                eachStoreAccount.Id,
                String.valueOf(eachStoreAccount.Submarket__r.Submarket_Id__c)
            );
        }
    }

    private void getServices() {
        for (
            Merchant_Service__c eachService : MerchantSelector.newInstance()
                .queryMerchantRecordsWithAccountIds(storeIdsToRunValidation)
        ) {
            if (!storeIdToServices.containsKey(eachService.Account__c)) {
                storeIdToServices.put(eachService.Account__c, new List<Merchant_Service__c>());
            }
            storeIdToServices.get(eachService.Account__c).add(eachService);
        }
    }

    /**
     * @description It run store readiness validations on child and parent Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidations - custom metadata records
     */
    private void runValidations(
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations
    ) {
        for (
            Activation_Checklist_Validation__mdt eachActivationChecklistValidationRule : activationChecklistValidations
        ) {
            switch on
                METHODNAMETOMETHODTYPES.get(
                    eachActivationChecklistValidationRule.Service_Method_Name__c
                ) {
                when PDOAINFUTURE {
                    validatePDOA(eachActivationChecklistValidationRule);
                }
                when MERCHANTSUPPLIEDID {
                    validateMerchantSuppliedId(eachActivationChecklistValidationRule);
                }
                when BUSINESSISACTIVE {
                    validateBusinessIsActive(eachActivationChecklistValidationRule);
                }
                when SUBMARKETID {
                    validateSubmarket(eachActivationChecklistValidationRule);
                }
                when STARTINGPOINTID {
                    validateStartingPointId(eachActivationChecklistValidationRule);
                }
                when BANKINGINFORMATION {
                    validateBankingInformation(eachActivationChecklistValidationRule);
                }
                when STOREISPARTNER {
                    validateStoreIsPartner(eachActivationChecklistValidationRule);
                }
                when ORDERPROTOCOL {
                    validateOrderProtocol(eachActivationChecklistValidationRule);
                }
                when BUSINESSID {
                    validateBusinessId(eachActivationChecklistValidationRule);
                }
                when TIERLEVEL {
                    validateTierLevel(eachActivationChecklistValidationRule);
                }
                when ACTIVEMENUCOUNT {
                    validateActiveMenuCount(eachActivationChecklistValidationRule);
                }
                when OFFERSPICKUPDELIVERYDASHPASS {
                    validateOffersPickupDeliveryDashpass(eachActivationChecklistValidationRule);
                }
                when PRICINGPROGRAM {
                    validateCommissionRates(eachActivationChecklistValidationRule);
                }
            }
        }
    }

    /**
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidationRule
     */
    private void validateBusinessIsActive(
        Activation_Checklist_Validation__mdt activationChecklistValidationRule
    ) {
        ActivationChecklistWrapper.GetBusinessDetails businessInformation;
        Activation_Checklist__c eachStoreActivationChecklist;
        Account storeAccountInformation;
        String result;
        for (Id storeAccountId : storeIdsToRunValidation) {
            if (storeIdToActivationChecklists.containsKey(storeAccountId)) {
                eachStoreActivationChecklist = getActivationChecklist(
                    storeAccountId,
                    activationChecklistValidationRule.Activation_Validation_Name__c
                );
            } else {
                eachStoreActivationChecklist = null;
            }
            storeAccountInformation = idToStoreAccounts.get(storeAccountId);
            businessInformation = storeIdToMintStoreAccounts.get(storeAccountInformation.Id)
                .businessInformation;
            if (businessInformation == null || businessInformation.active != STRING_TRUE) {
                result = FAILURE_RESULT;
            } else {
                result = SUCCESS_RESULT;
            }
            logActivationChecklistResults(
                activationChecklistValidationRule,
                storeAccountInformation,
                result,
                NOT_APPLICABLE,
                eachStoreActivationChecklist,
                TARGET_MINT,
                businessInformation?.active
            );
        }
    }

    /**
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidationRule
     */
    private void validateCommissionRates(
        Activation_Checklist_Validation__mdt activationChecklistValidationRule
    ) {
        List<ActivationChecklistWrapper.GetPricingPrograms> pricingPrograms;
        Activation_Checklist__c eachStoreActivationChecklist;
        Account storeAccountInformation;
        String result;
        for (Id storeAccountId : storeIdsToRunValidation) {
            if (storeIdToActivationChecklists.containsKey(storeAccountId)) {
                eachStoreActivationChecklist = getActivationChecklist(
                    storeAccountId,
                    activationChecklistValidationRule.Activation_Validation_Name__c
                );
            } else {
                eachStoreActivationChecklist = null;
            }
            storeAccountInformation = idToStoreAccounts.get(storeAccountId);
            pricingPrograms = storeIdToMintStoreAccounts.get(storeAccountInformation.Id)
                .pricingPrograms;
            if (pricingPrograms.size() == 0) {
                continue;
            }
            if (
                PricingProgramsService.getServiceToPricingProgramMapping(
                    storeIdToServices.get(storeAccountId),
                    pricingPrograms
                )
            ) {
                result = SUCCESS_RESULT;
            } else {
                result = FAILURE_RESULT;
            }
            logActivationChecklistResults(
                activationChecklistValidationRule,
                storeAccountInformation,
                result,
                storeAccountInformation.Services_Fees__c
                    ?.substringBetween(STRING_HREF, STRING_TARGET)
                    .trim()
                    .replace(STRING_DOUBLE_QUOTES, ''),
                eachStoreActivationChecklist,
                TARGET_MINT_SERVICES_ON_STORE,
                eachStoreActivationChecklist
                    ?.MINT_Store_Page__c
                    ?.substringBetween(STRING_HREF, STRING_TARGET)
                    .trim()
                    .replace(STRING_DOUBLE_QUOTES, '')
            );
        }
    }

    /**
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidationRule
     */
    private void validateMerchantSuppliedId(
        Activation_Checklist_Validation__mdt activationChecklistValidationRule
    ) {
        ActivationChecklistWrapper.GetStore storeInformation;
        Activation_Checklist__c eachStoreActivationChecklist;
        Account storeAccountInformation;
        String result;
        for (Id storeAccountId : storeIdsToRunValidation) {
            if (storeIdToActivationChecklists.containsKey(storeAccountId)) {
                eachStoreActivationChecklist = getActivationChecklist(
                    storeAccountId,
                    activationChecklistValidationRule.Activation_Validation_Name__c
                );
            } else {
                eachStoreActivationChecklist = null;
            }
            storeAccountInformation = idToStoreAccounts.get(storeAccountId);
            storeInformation = storeIdToMintStoreAccounts.get(storeAccountInformation.Id)
                .storeInformation;
            if (storeInformation == null) {
                continue;
            }
            Boolean validate =
                (storeAccountInformation.Merchant_Supplied_ID__c == null &&
                storeInformation.merchantSuppliedId == null) ||
                (storeAccountInformation.Merchant_Supplied_ID__c == null &&
                String.valueOf(storeInformation.merchantSuppliedId) ==
                String.valueOf(
                    storeIdToMintStoreAccounts.get(storeAccountInformation.Id).storeId
                )) ||
                (storeAccountInformation.Merchant_Supplied_ID__c ==
                storeInformation.merchantSuppliedId);
            if (validate) {
                result = SUCCESS_RESULT;
            } else {
                result = FAILURE_RESULT;
            }
            logActivationChecklistResults(
                activationChecklistValidationRule,
                storeAccountInformation,
                result,
                storeAccountInformation.Merchant_Supplied_ID__c,
                eachStoreActivationChecklist,
                TARGET_STORE_AND_MINT,
                storeInformation.merchantSuppliedId
            );
        }
    }

    /**
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidationRule
     */
    private void validateSubmarket(
        Activation_Checklist_Validation__mdt activationChecklistValidationRule
    ) {
        ActivationChecklistWrapper.GetStore storeInformation;
        Activation_Checklist__c eachStoreActivationChecklist;
        Account storeAccountInformation;
        String result;
        for (Id storeAccountId : storeIdsToRunValidation) {
            if (storeIdToActivationChecklists.containsKey(storeAccountId)) {
                eachStoreActivationChecklist = getActivationChecklist(
                    storeAccountId,
                    activationChecklistValidationRule.Activation_Validation_Name__c
                );
            } else {
                eachStoreActivationChecklist = null;
            }
            storeAccountInformation = idToStoreAccounts.get(storeAccountId);
            storeInformation = storeIdToMintStoreAccounts.get(storeAccountInformation.Id)
                .storeInformation;
            if (storeInformation == null) {
                continue;
            }
            if (
                (storeIdToSubmarket.get(storeAccountId) == storeInformation.submarketId) ||
                (storeIdToSubmarket.get(storeAccountId) == '0' &&
                storeInformation.submarketId == '0')
            ) {
                result = SUCCESS_RESULT;
            } else {
                result = FAILURE_RESULT;
            }
            logActivationChecklistResults(
                activationChecklistValidationRule,
                storeAccountInformation,
                result,
                storeIdToSubmarket.get(storeAccountId),
                eachStoreActivationChecklist,
                TARGET_STORE_AND_MINT,
                storeInformation.submarketId
            );
        }
    }

    /**
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidationRule
     */
    private void validateStartingPointId(
        Activation_Checklist_Validation__mdt activationChecklistValidationRule
    ) {
        ActivationChecklistWrapper.GetStore storeInformation;
        Activation_Checklist__c eachStoreActivationChecklist;
        Account storeAccountInformation;
        String result;
        Boolean validate;
        for (Id storeAccountId : storeIdsToRunValidation) {
            if (storeIdToActivationChecklists.containsKey(storeAccountId)) {
                eachStoreActivationChecklist = getActivationChecklist(
                    storeAccountId,
                    activationChecklistValidationRule.Activation_Validation_Name__c
                );
            } else {
                eachStoreActivationChecklist = null;
            }
            storeAccountInformation = idToStoreAccounts.get(storeAccountId);
            storeInformation = storeIdToMintStoreAccounts.get(storeAccountInformation.Id)
                .storeInformation;
            if (storeInformation == null) {
                continue;
            }
            validate = (storeAccountInformation.Starting_Point_ID__c == null ||
            storeInformation.startingPointId == null ||
            storeAccountInformation.Starting_Point_ID__c == 0 ||
            storeInformation.startingPointId == '0' ||
            (String.valueOf(storeAccountInformation.Starting_Point_ID__c) !=
            storeInformation.startingPointId));
            if (validate) {
                result = FAILURE_RESULT;
            } else {
                result = SUCCESS_RESULT;
            }
            logActivationChecklistResults(
                activationChecklistValidationRule,
                storeAccountInformation,
                result,
                String.valueOf(storeAccountInformation.Starting_Point_ID__c),
                eachStoreActivationChecklist,
                TARGET_STORE_AND_MINT,
                storeInformation.startingPointId
            );
        }
    }

    /**ß
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidationRule
     */
    private void validateBankingInformation(
        Activation_Checklist_Validation__mdt activationChecklistValidationRule
    ) {
        ActivationChecklistWrapper.GetPayment paymentInformation;
        Activation_Checklist__c eachStoreActivationChecklist;
        Account storeAccountInformation;
        String result;
        String mintValue;
        for (Id storeAccountId : storeIdsToRunValidation) {
            if (storeIdToActivationChecklists.containsKey(storeAccountId)) {
                eachStoreActivationChecklist = getActivationChecklist(
                    storeAccountId,
                    activationChecklistValidationRule.Activation_Validation_Name__c
                );
            } else {
                eachStoreActivationChecklist = null;
            }
            storeAccountInformation = idToStoreAccounts.get(storeAccountId);
            paymentInformation = storeIdToMintStoreAccounts.get(storeAccountInformation.Id)
                .paymentAccountInformation;
            if (
                paymentInformation == null ||
                paymentInformation.charges_enabled != STRING_TRUE ||
                paymentInformation.transfers_enabled != STRING_TRUE
            ) {
                result = FAILURE_RESULT;
                mintValue = STRING_FALSE;
            } else {
                result = SUCCESS_RESULT;
                mintValue = STRING_TRUE;
            }
            logActivationChecklistResults(
                activationChecklistValidationRule,
                storeAccountInformation,
                result,
                NOT_APPLICABLE,
                eachStoreActivationChecklist,
                TARGET_MINT,
                mintValue
            );
        }
    }

    /**ß
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidationRule
     */
    private void validateStoreIsPartner(
        Activation_Checklist_Validation__mdt activationChecklistValidationRule
    ) {
        List<ActivationChecklistWrapper.GetPricingPrograms> pricingPrograms;
        Activation_Checklist__c eachStoreActivationChecklist;
        Account storeAccountInformation;
        String result;
        String value;
        for (Id storeAccountId : storeIdsToRunValidation) {
            if (storeIdToActivationChecklists.containsKey(storeAccountId)) {
                eachStoreActivationChecklist = getActivationChecklist(
                    storeAccountId,
                    activationChecklistValidationRule.Activation_Validation_Name__c
                );
            } else {
                eachStoreActivationChecklist = null;
            }
            storeAccountInformation = idToStoreAccounts.get(storeAccountId);
            pricingPrograms = storeIdToMintStoreAccounts.get(storeAccountInformation.Id)
                .pricingPrograms;
            if (pricingPrograms.size() == 0) {
                continue;
            }
            for (ActivationChecklistWrapper.GetPricingPrograms eachProgram : pricingPrograms) {
                if (
                    (eachProgram.productInformation?.experience != PRODUCT_EXPERIENCE_ANY ||
                    eachProgram.productInformation?.channel != PRODUCT_CHANNEL_ANY ||
                    eachProgram.productInformation?.fulfillmentType !=
                    PRODUCT_FULFILLMENT_TYPE_ANY ||
                    eachProgram.productInformation?.audience != PRODUCT_AUDIENCE_ANY) &&
                    eachProgram.sourceId != STORE_PARTNERSHIP_PRICING_PROGRAM
                ) {
                    continue;
                }
                value = String.valueOf(eachProgram.isPartner);
                if (eachProgram.isPartner) {
                    result = SUCCESS_RESULT;
                }
            }
            if (result != SUCCESS_RESULT) {
                result = FAILURE_RESULT;
            }
            logActivationChecklistResults(
                activationChecklistValidationRule,
                storeAccountInformation,
                result,
                NOT_APPLICABLE,
                eachStoreActivationChecklist,
                TARGET_MINT,
                value
            );
            result = '';
        }
    }

    /**
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidationRule
     */
    private void validateOrderProtocol(
        Activation_Checklist_Validation__mdt activationChecklistValidationRule
    ) {
        ActivationChecklistWrapper.GetStore storeInformation;
        ActivationChecklistWrapper.GetPointOfSales posInformation;
        Activation_Checklist__c eachStoreActivationChecklist;
        Account storeAccountInformation;
        String result;
        Boolean validate;
        for (Id storeAccountId : storeIdsToRunValidation) {
            if (storeIdToActivationChecklists.containsKey(storeAccountId)) {
                eachStoreActivationChecklist = getActivationChecklist(
                    storeAccountId,
                    activationChecklistValidationRule.Activation_Validation_Name__c
                );
            } else {
                eachStoreActivationChecklist = null;
            }
            storeAccountInformation = idToStoreAccounts.get(storeAccountId);
            storeInformation = storeIdToMintStoreAccounts.get(storeAccountInformation.Id)
                .storeInformation;
            posInformation = storeIdToMintStoreAccounts.get(storeAccountInformation.Id)
                .posInformation;
            if (storeInformation == null) {
                continue;
            }
            if (storeAccountInformation.Order_Protocol__c == null) {
                validate = false;
            } else {
                validate = ((!storeAccountInformation.Order_Protocol__c.contains(
                    ORDER_PROTOCOL_POS
                ) &&
                storeAccountInformation.Order_Protocol__c.contains(ORDER_PROTOCOL_TABLET) &&
                storeInformation.orderProtocol == ORDER_PROTOCOL_IPAD) ||
                (storeAccountInformation.Order_Protocol__c
                    ?.equalsIgnoreCase(storeInformation.orderProtocol)) ||
                (storeAccountInformation.Order_Protocol__c.contains(ORDER_PROTOCOL_POS) &&
                (storeInformation.orderProtocol == ORDER_PROTOCOL_POINT_OF_SALE ||
                (posInformation != null && String.isNotBlank(posInformation.location_id)))));
            }
            if (validate) {
                result = SUCCESS_RESULT;
            } else {
                result = FAILURE_RESULT;
            }
            logActivationChecklistResults(
                activationChecklistValidationRule,
                storeAccountInformation,
                result,
                storeAccountInformation.Order_Protocol__c,
                eachStoreActivationChecklist,
                TARGET_STORE_AND_MINT,
                storeInformation.orderProtocol
            );
        }
    }

    /**
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidationRule
     */
    private void validateBusinessId( //remove query
        Activation_Checklist_Validation__mdt activationChecklistValidationRule
    ) {
        ActivationChecklistWrapper.GetStore storeInformation;
        Activation_Checklist__c eachStoreActivationChecklist;
        Account storeAccountInformation;
        String result;
        Map<String, Xref__c> storeXrefMap = new Map<String, Xref__c>();
        for (
            Xref__c xRef : XrefsSelector.newInstance()
                .selectByUltimateParentAccountsforActivationValidation(storeIdsToRunValidation)
        ) {
            if (!storeXrefMap.containsKey(xRef.Salesforce_Account_ID__c)) {
                storeXrefMap.put(xRef.Salesforce_Account_ID__c, xRef);
            }
        }
        for (Id storeAccountId : storeIdsToRunValidation) {
            if (storeIdToActivationChecklists.containsKey(storeAccountId)) {
                eachStoreActivationChecklist = getActivationChecklist(
                    storeAccountId,
                    activationChecklistValidationRule.Activation_Validation_Name__c
                );
            } else {
                eachStoreActivationChecklist = null;
            }
            storeAccountInformation = idToStoreAccounts.get(storeAccountId);
            storeInformation = storeIdToMintStoreAccounts.get(storeAccountInformation.Id)
                .storeInformation;
            if (storeInformation == null) {
                continue;
            }
            if (
                storeXrefMap.get(storeAccountInformation.Id).BusinessID__c !=
                storeInformation.businessId
            ) {
                result = FAILURE_RESULT;
            } else {
                result = SUCCESS_RESULT;
            }
            logActivationChecklistResults(
                activationChecklistValidationRule,
                storeAccountInformation,
                result,
                storeXrefMap.get(storeAccountInformation.Id)?.BusinessID__c,
                eachStoreActivationChecklist,
                TARGET_BIZREF_AND_MINT,
                storeInformation.businessId
            );
        }
    }

    /**
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidationRule
     */
    private void validateTierLevel( //remove query
        Activation_Checklist_Validation__mdt activationChecklistValidationRule
    ) {
        ActivationChecklistWrapper.GetStore storeInformation;
        Activation_Checklist__c eachStoreActivationChecklist;
        Map<String, Order> storeOrderMap = new Map<String, Order>();
        for (
            Order order : OrdersSelector.newInstance()
                .selectDraftActivationOrdersWithCxDeliverFeeOrderItemsByAccountIds(
                    storeIdsToRunValidation
                )
        ) {
            if (!storeOrderMap.containsKey(order.AccountId)) {
                storeOrderMap.put(order.AccountId, order);
            }
        }
        Account storeAccountInformation;
        String result;
        Boolean validate;
        for (Id storeAccountId : storeIdsToRunValidation) {
            if (storeIdToActivationChecklists.containsKey(storeAccountId)) {
                eachStoreActivationChecklist = getActivationChecklist(
                    storeAccountId,
                    activationChecklistValidationRule.Activation_Validation_Name__c
                );
            } else {
                eachStoreActivationChecklist = null;
            }
            storeAccountInformation = idToStoreAccounts.get(storeAccountId);
            storeInformation = storeIdToMintStoreAccounts.get(storeAccountInformation.Id)
                .storeInformation;
            if (storeInformation == null) {
                continue;
            }
            validate = (storeOrderMap?.get(storeAccountInformation.Id)?.Pricing_Tier__c == null ||
            storeInformation.tierLevel == null ||
            String.valueOf(
                Integer.valueOf(storeOrderMap?.get(storeAccountInformation.Id)?.Pricing_Tier__c)
            ) != storeInformation.tierLevel);
            if (validate) {
                result = FAILURE_RESULT;
            } else {
                result = SUCCESS_RESULT;
            }
            logActivationChecklistResults(
                activationChecklistValidationRule,
                storeAccountInformation,
                result,
                String.valueOf(
                    Integer.valueOf(storeOrderMap?.get(storeAccountInformation.Id)?.Pricing_Tier__c)
                ),
                eachStoreActivationChecklist,
                TARGET_MINT_SERVICES_ON_STORE,
                storeInformation.tierLevel
            );
        }
    }

    /**ß
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidationRule
     */
    private void validateActiveMenuCount(
        Activation_Checklist_Validation__mdt activationChecklistValidationRule
    ) {
        ActivationChecklistWrapper.GetMenu menuInformation;
        Activation_Checklist__c eachStoreActivationChecklist;
        Account storeAccountInformation;
        String result;
        for (Id storeAccountId : storeIdsToRunValidation) {
            if (storeIdToActivationChecklists.containsKey(storeAccountId)) {
                eachStoreActivationChecklist = getActivationChecklist(
                    storeAccountId,
                    activationChecklistValidationRule.Activation_Validation_Name__c
                );
            } else {
                eachStoreActivationChecklist = null;
            }
            storeAccountInformation = idToStoreAccounts.get(storeAccountId);
            menuInformation = storeIdToMintStoreAccounts.get(storeAccountInformation.Id)
                .menuInformation;
            if (menuInformation == null || menuInformation.isMenuActive != 'true') {
                result = FAILURE_RESULT;
            } else {
                result = SUCCESS_RESULT;
            }
            logActivationChecklistResults(
                activationChecklistValidationRule,
                storeAccountInformation,
                result,
                NOT_APPLICABLE,
                eachStoreActivationChecklist,
                TARGET_MINT,
                menuInformation?.isMenuActive
            );
        }
    }

    /**ß
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidationRule
     */
    private void validateOffersPickupDeliveryDashpass( //remove query
        Activation_Checklist_Validation__mdt activationChecklistValidationRule
    ) {
        ActivationChecklistWrapper.GetStore storeInformation;
        Activation_Checklist__c eachStoreActivationChecklist;
        List<Account> accountWithServices = new List<Account>();
        String result;
        String mintValue;
        accountWithServices = AccountsSelector.newInstance()
            .selectAccountsWithServices(storeIdsToRunValidation);
        for (Account eachStoreAccount : accountWithServices) {
            if (storeIdToActivationChecklists.containsKey(eachStoreAccount.Id)) {
                eachStoreActivationChecklist = getActivationChecklist(
                    eachStoreAccount.Id,
                    activationChecklistValidationRule.Activation_Validation_Name__c
                );
            } else {
                eachStoreActivationChecklist = null;
            }
            storeInformation = storeIdToMintStoreAccounts.get(eachStoreAccount.Id).storeInformation;
            if (storeInformation == null) {
                continue;
            }
            Boolean validate = false;
            mintValue = 'false'; // null value from MINT is also mapped to it.
            if (eachStoreAccount.Services__r != null) {
                for (Merchant_Service__c service : eachStoreAccount.services__r) {
                    if (service.Name == 'Pickup' && storeInformation.offersPickup == STRING_TRUE) {
                        validate = true;
                        mintValue = STRING_TRUE;
                    }
                    if (
                        service.Name == 'Delivery' &&
                        storeInformation.offersDelivery == STRING_TRUE
                    ) {
                        validate = true;
                        mintValue = STRING_TRUE;
                    }
                    if (
                        service.Name == 'Dashpass' &&
                        storeInformation.isConsumerSubscriptionEligible == STRING_TRUE
                    ) {
                        validate = true;
                        mintValue = STRING_TRUE;
                    }
                }
            }
            if (validate) {
                result = SUCCESS_RESULT;
            } else {
                result = FAILURE_RESULT;
            }
            logActivationChecklistResults(
                activationChecklistValidationRule,
                eachStoreAccount,
                result,
                NOT_APPLICABLE,
                eachStoreActivationChecklist,
                TARGET_MINT,
                mintValue
            );
        }
    }
    /**
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param activationChecklistValidationRule
     */
    private void validatePDOA(
        Activation_Checklist_Validation__mdt activationChecklistValidationRule
    ) {
        Date workOrderPDOA;
        Activation_Checklist__c eachStoreActivationChecklist;
        Account storeAccountInformation;
        String result;
        for (Id storeAccountId : storeIdsToRunValidation) {
            if (storeIdToActivationChecklists.containsKey(storeAccountId)) {
                eachStoreActivationChecklist = getActivationChecklist(
                    storeAccountId,
                    activationChecklistValidationRule.Activation_Validation_Name__c
                );
            } else {
                eachStoreActivationChecklist = null;
            }
            storeAccountInformation = idToStoreAccounts.get(storeAccountId);
            workOrderPDOA = storeIdToWorkStep
                ?.get(storeAccountInformation.Id)
                ?.WorkPlan
                ?.WorkOrder
                ?.ParentWorkOrder
                ?.Proposed_Date_of_Activation__c;
            if (workOrderPDOA > System.today()) {
                result = FAILURE_RESULT;
            } else {
                result = SUCCESS_RESULT;
            }
            logActivationChecklistResults(
                activationChecklistValidationRule,
                storeAccountInformation,
                result,
                String.valueOf(workOrderPDOA.format()),
                eachStoreActivationChecklist,
                TARGET_WORK_ORDER,
                NOT_APPLICABLE
            );
        }
    }

    private Activation_Checklist__c getActivationChecklist(Id storeAccountId, String ruleName) {
        for (
            Activation_Checklist__c eachChecklist : storeIdToActivationChecklists.get(
                storeAccountId
            )
        ) {
            if (eachChecklist.Activation_Validation_Name__c == ruleName) {
                return eachChecklist;
            }
        }
        return null;
    }

    /**
     * @description It creates 'Readiness Check Failures' records based on the passed Work Order
     * and Store Readiness Validation Rule.
     * @param activationchecklistValidationRule
     * @param storeAccount
     * @param result
     * @param sfdcValue
     * @param eachActivationChecklist
     * @param target
     * @param mintValue
     */
    private void logActivationChecklistResults(
        Activation_Checklist_Validation__mdt activationchecklistValidationRule,
        Account storeAccount,
        String result,
        String sfdcValue,
        Activation_Checklist__c eachActivationChecklist,
        String target,
        String mintValue
    ) {
        Id storeWorkStepId = (Id) storeIdToMintStoreAccounts.get(storeAccount.Id)
            ?.workStepSalesforceId;
        String mintStoreId = String.valueOf(
            storeIdToMintStoreAccounts.get(storeAccount.Id)?.storeId
        );
        if (eachActivationChecklist != null) {
            eachActivationChecklist.Status__c = (result == SUCCESS_RESULT)
                ? SUCCESS_STATUS_RESULT
                : FAILURE_STATUS_RESULT;
            eachActivationChecklist.Result__c = (result == SUCCESS_RESULT)
                ? activationchecklistValidationRule.Success_Message__c
                : activationchecklistValidationRule.Error_Message__c;
            eachActivationChecklist.SFDC_Value__c = sfdcValue;
            eachActivationChecklist.MINT_Value__c = mintValue;
            eachActivationChecklist.Store_Id__c = mintStoreId;
            eachActivationChecklist.Source__c = activationchecklistValidationRule.Source__c;
            eachActivationChecklist.Activation_Validation_Name__c = activationchecklistValidationRule.Activation_Validation_Name__c;
            activationChecklistsToBeUpdated.add(eachActivationChecklist);
        } else {
            activationChecklists.add(
                new Activation_Checklist__c(
                    Activation_Validation_Name__c = activationchecklistValidationRule.Activation_Validation_Name__c,
                    Store_Account__c = storeAccount.Id,
                    Work_Plan__c = storeIdToWorkStep.get(storeAccount.Id)
                        ?.Parent_Work_Step__r
                        ?.WorkPlanId,
                    Work_Step__c = storeIdToWorkStep.get(storeAccount.Id)?.Id,
                    Parent_Work_Step__c = storeIdToWorkStep.get(storeAccount.Id)
                        ?.Parent_Work_Step__c,
                    Result__c = (result == SUCCESS_RESULT)
                        ? activationchecklistValidationRule.Success_Message__c
                        : activationchecklistValidationRule.Error_Message__c,
                    SFDC_Value__c = sfdcValue,
                    Status__c = (result == SUCCESS_RESULT)
                        ? SUCCESS_STATUS_RESULT
                        : FAILURE_STATUS_RESULT,
                    Target__c = target,
                    MINT_Value__c = mintValue,
                    Store_Id__c = mintStoreId,
                    Source__c = activationchecklistValidationRule.Source__c
                )
            );
        }
        completedStoreWorkPlanIds.add(storeIdToWorkStep.get(storeAccount.Id)?.WorkPlanId);
        if (result == SUCCESS_RESULT) {
            if (
                !failedStoreWorkStepIds.contains(storeWorkStepId) &&
                !ActivationCheckValidationsService.failedWorkStepIdsFromPayload.contains(
                    storeWorkStepId
                )
            ) {
                passedStoreWorkStepIds.add(storeWorkStepId);
            }
        } else {
            passedStoreWorkStepIds.remove(storeWorkStepId);
            failedStoreWorkStepIds.add(storeWorkStepId);
        }
    }

    /**
     * @description It commits 'Readiness Check Failures' records in the database.
     * @JIRA# LEM-1684
     */
    private void publishActivationChecklistRecords() {
        if (activationChecklists.isEmpty() && activationChecklistsToBeUpdated.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowToInsertActivationChecklists = Application.UNITOFWORK.newInstance();
        fflib_ISObjectUnitOfWork uowToUpdateActivationChecklists = Application.UNITOFWORK.newInstance();
        try {
            uowToInsertActivationChecklists.registerNew(activationChecklists);
            uowToUpdateActivationChecklists.registerDirty(activationChecklistsToBeUpdated);
            uowToInsertActivationChecklists.commitWork();
            uowToUpdateActivationChecklists.commitWork();
        } catch (Exception activationChecklistCreationException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    activationChecklistCreationException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_ACTIVATION_CHECKLIST,
                        LOG_DOMAIN_ACTIVATION_CHECKLIST,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(activationChecklistCreationException)
            );
        }
    }
}