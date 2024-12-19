/**
 * @author Deloitte
 * @date 10/27/2022
 * @description Service implementation class for utilities related to Readiness Validation Rules.
 */
public inherited sharing class ReadinessValidationRulesServiceImpl implements IReadinessValidationRulesService {
    private static final String ACCOUNT_STORE_RECORD_TYPE_DEVELOPER_NAME = 'Store';
    private enum MethodTypes {
        COOED,
        COOEDONWEEKEND,
        PDOA,
        PDOAONWEEKEND
    }
    private static final String AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String COOED_DAYS_IN_FUTURE_LIMIT_STATIC_CONFIG = 'COOED_DAYS_IN_FUTURE_LIMIT';
    private static final String DASH_SEPARATOR = '-';
    private static final String DATETIME_DAY_OF_WEEK_SYMBOL = 'E';
    private static final String DASHER_PICK_SHOPPING_PROTOCOL = 'Dasher Pick';
    private static final Map<String, MethodTypes> METHODNAMETOMETHODTYPES = new Map<String, MethodTypes>{
        'validateCOOED' => MethodTypes.COOED,
        'validateCOOEDOnWeekend' => MethodTypes.COOEDONWEEKEND,
        'validatePDOA' => MethodTypes.PDOA,
        'validatePDOAOnWeekend' => MethodTypes.PDOAONWEEKEND
    };
    private static final String DAY_OF_WEEK_SAT = 'Sat';
    private static final String DAY_OF_WEEK_SUN = 'Sun';
    private static final String INTEGRATED_FRANCHISE = 'Integrated Franchise';
    private static final String OBJECT_NAME_ACCOUNT = 'Account';
    private static final String OBJECT_NAME_CONTRACT = 'Contract';
    private static final String OBJECT_NAME_OPPORTUNITY = 'Opportunity';
    private static final String OBJECT_NAME_WORK_ORDER = 'WorkOrder';
    private static final String PDOA_DAYS_IN_FUTURE_LIMIT_STATIC_CONFIG = 'PDOA_DAYS_IN_FUTURE_LIMIT';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String WORK_ORDER_TYPE_POST_SALES = 'Post-Sales';
    private static final String WORK_ORDER_SUB_TYPE_RATE_CHANGE = 'Rate Change';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_COO = 'COO';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String POST_SALES_RATE_CHANGE_KEY_TO_IDENTIFY =
        SEGMENT_SMB +
        DASH_SEPARATOR +
        WORK_ORDER_TYPE_POST_SALES +
        DASH_SEPARATOR +
        WORK_ORDER_SUB_TYPE_RATE_CHANGE;
    private static final String OI_MARKETPLACE_SMB_KEY_TO_IDENTIFY =
        SEGMENT_SMB +
        DASH_SEPARATOR +
        WORK_ORDER_TYPE_MARKETPLACE;
    private static final String OI_COO_SMB_KEY_TO_IDENTIFY =
        SEGMENT_SMB +
        DASH_SEPARATOR +
        WORK_ORDER_TYPE_COO;
    private static final String STOREFRONT_SMB_KEY_TO_IDENTIFY =
        SEGMENT_SMB +
        DASH_SEPARATOR +
        WORK_ORDER_TYPE_STOREFRONT;
    private static final String DRIVE_SMB_KEY_TO_IDENTIFY =
        SEGMENT_SMB +
        DASH_SEPARATOR +
        WORK_ORDER_TYPE_DRIVE;
    private static final Map<String, Set<String>> READINESS_CHECK_VALIDATIONS_TO_BYPASS = new Map<String, Set<String>>{
        POST_SALES_RATE_CHANGE_KEY_TO_IDENTIFY => new Set<String>{
            'Billing_Contact_req_on_Payment_Account',
            'Tax_ID_req_on_Account'
        },
        OI_MARKETPLACE_SMB_KEY_TO_IDENTIFY => new Set<String>{
            'Restrict_Store_PDOA_on_weekend',
            'Restrict_WO_PDOA_on_weekend',
            'Legal_Business_Name_req_on_Business'
        },
        OI_COO_SMB_KEY_TO_IDENTIFY => new Set<String>{
            'Restrict_Store_PDOA_on_weekend',
            'Restrict_WO_PDOA_on_weekend',
            'Legal_Business_Name_req_on_Business'
        },
        STOREFRONT_SMB_KEY_TO_IDENTIFY => new Set<String>{
            'Legal_Business_Name_req_on_Store',
            'Legal_Business_Name_req_on_Business'
        },
        DRIVE_SMB_KEY_TO_IDENTIFY => new Set<String>{
            'Legal_Business_Name_req_on_Store',
            'Legal_Business_Name_req_on_Business'
        }
    };
    private Map<String, Map<String, Set<String>>> readinessValidationRuleTypeSubTypes;
    private static final String SHOPPER_PICK_SHOPPING_PROTOCOL = 'Shopper Pick';
    private static final String WITHHOLDING = 'Withholding';

    /**
     * @description Default Constructor to initialize class variables.
     */
    public ReadinessValidationRulesServiceImpl() {
        readinessValidationRuleTypeSubTypes = new Map<String, Map<String, Set<String>>>();
    }

    /**
     * @description It collects mappings of Store Readiness Validation Rules
     * with Type to Sub-Type custom metadata.
     * @JIRA# LEM-3231
     * @param readinessValidationRules
     * @return Map<String, Map<String, Set<String>>>
     */
    public Map<String, Map<String, Set<String>>> collectReadinessValidationRuleMappings(
        List<Store_Readiness_Validation_Rule__mdt> readinessValidationRules
    ) {
        Map<String, Set<String>> typeToSubTypes = new Map<String, Set<String>>();
        String type;
        String subType;
        for (
            Store_Readiness_Validation_Rule__mdt eachReadinessValidation : readinessValidationRules
        ) {
            typeToSubTypes = new Map<String, Set<String>>();
            for (
                ReadinessValidation_SobjectType_Binding__mdt eachBinding : eachReadinessValidation.ReadinessValidationSobjectTypeBindings__r
            ) {
                type = eachBinding.Sobject_Type_Sub_Type_Mapping__r.Type__c;
                subType = eachBinding.Sobject_Type_Sub_Type_Mapping__r.Sub_Type__c;
                if (!typeToSubTypes.containsKey(type)) {
                    typeToSubTypes.put(type, new Set<String>());
                }
                if (String.isNotBlank(subType)) {
                    typeToSubTypes.get(type).add(subType);
                }
            }
            if (!typeToSubTypes.isEmpty()) {
                readinessValidationRuleTypeSubTypes.put(
                    eachReadinessValidation.DeveloperName,
                    typeToSubTypes
                );
            }
        }
        return readinessValidationRuleTypeSubTypes;
    }

    /**
     * @description It checks whether the store account associated with
     * the passed child work order doesn't holds shopping protocol value
     * as 'Dasher Pick' or 'Shopper Pick'
     * @JIRA# LEM-5714, LEM-6178
     * @param workOrder
     * @return Boolean
     */
    public Boolean isAccountShoppingProtocolNotDasherPickOrShopperPick(WorkOrder workOrder) {
        return workOrder.ParentWorkOrderId != null &&
            workOrder.Account_Record_Type_Name__c == ACCOUNT_STORE_RECORD_TYPE_DEVELOPER_NAME &&
            workOrder.Account.Shopping_Protocol__c != DASHER_PICK_SHOPPING_PROTOCOL &&
            workOrder.Account.Shopping_Protocol__c != SHOPPER_PICK_SHOPPING_PROTOCOL;
    }

    /**
     * @description It checks whether the store account associated with
     * the passed child work order doesn't hold shopping protocol value
     * 'Shopper Pick'or holds value as 'Dasher Pick' along with
     * Alcohol Delivery Quote Line
     * @JIRA# LEM-7996
     * @param workOrder
     * @param accountIdsToAlcoholQuoteLineMap
     * @return Boolean
     */
    public Boolean isAccountShoppingProtocolDasherPickWithAlcoholOrNotShopperPick(
        WorkOrder workOrder,
        Map<Id, List<SBQQ__QuoteLine__c>> accountIdsToAlcoholQuoteLineMap
    ) {
        Integer noOfAlcoholDeliveryQuoteLines = (workOrder.ParentWorkOrder.AccountId != null &&
            accountIdsToAlcoholQuoteLineMap.get(workOrder.ParentWorkOrder.AccountId) != null)
            ? accountIdsToAlcoholQuoteLineMap.get(workOrder.ParentWorkOrder.AccountId).size()
            : 0;
        Boolean isDasherPickWithAlcoholDelivery = (workOrder.Account.Shopping_Protocol__c ==
            DASHER_PICK_SHOPPING_PROTOCOL &&
            noOfAlcoholDeliveryQuoteLines > 0)
            ? true
            : false;
        if (
            workOrder.ParentWorkOrderId != null &&
            workOrder.Account_Record_Type_Name__c == ACCOUNT_STORE_RECORD_TYPE_DEVELOPER_NAME
        ) {
            if (isDasherPickWithAlcoholDelivery) {
                return true;
            }
            return (workOrder.Account.Shopping_Protocol__c != DASHER_PICK_SHOPPING_PROTOCOL &&
            workOrder.Account.Shopping_Protocol__c != SHOPPER_PICK_SHOPPING_PROTOCOL);
        } else {
            return false;
        }
    }

    /**
     * @description It checks whether the passed readiness check validation rule is bypassed
     * by Segment for the passed Work Order.
     * @JIRA# LEM-20927
     * @param readinessCheckValidationAPIName
     * @param workOrderToEvaluate
     * @return Boolean
     */
    public Boolean isBypassedBySegmentTypeSubType(
        String readinessCheckValidationAPIName,
        WorkOrder workOrderToEvaluate
    ) {
        String keyToIdentify =
            workOrderToEvaluate.Segment__c +
            DASH_SEPARATOR +
            workOrderToEvaluate.Type__c +
            DASH_SEPARATOR +
            workOrderToEvaluate.Sub_Type__c;
        return READINESS_CHECK_VALIDATIONS_TO_BYPASS.containsKey(keyToIdentify) &&
            READINESS_CHECK_VALIDATIONS_TO_BYPASS.get(keyToIdentify)
                .contains(readinessCheckValidationAPIName);
    }

    /**
     * @description It checks whether the passed readiness check validation rule is bypassed
     * by Segment & Type for the passed Work Order.
     * @JIRA# LEM-23627
     * @param readinessCheckValidationAPIName
     * @param workOrderToEvaluate
     * @return Boolean
     */
    public static Boolean isBypassedBySegmentType(
        String readinessCheckValidationAPIName,
        WorkOrder workOrderToEvaluate
    ) {
        String keyToIdentify =
            workOrderToEvaluate.Segment__c +
            DASH_SEPARATOR +
            workOrderToEvaluate.Type__c;
        return READINESS_CHECK_VALIDATIONS_TO_BYPASS.containsKey(keyToIdentify) &&
            READINESS_CHECK_VALIDATIONS_TO_BYPASS.get(keyToIdentify)
                .contains(readinessCheckValidationAPIName);
    }

    /**
     * @description It checks whether 'Change of Ownership Effective Date' field
     * of the store Account associated with the passed Work Order has failed readiness check.
     * @JIRA# LEM-3649
     * @param readinessValidationRuleToTypeToSubTypes
     * @param readinessValidationRule
     * @param workOrder
     * @return Store_Readiness_Validation_Rule__mdt
     */
    public Store_Readiness_Validation_Rule__mdt getChangeOfOwnershipEffectiveDateFailedReadinessCheck(
        Map<String, Map<String, Set<String>>> readinessValidationRuleToTypeToSubTypes,
        Store_Readiness_Validation_Rule__mdt readinessValidationRule,
        WorkOrder workOrder
    ) {
        Store_Readiness_Validation_Rule__mdt failedReadinessValidationRule;
        Account storeAccount = workOrder.Account;
        if (
            !hasTypeSubTypeMatchingWithWorkOrder(
                readinessValidationRuleToTypeToSubTypes,
                readinessValidationRule,
                workOrder.ParentWorkOrder
            )
        ) {
            return failedReadinessValidationRule;
        }
        switch on METHODNAMETOMETHODTYPES.get(readinessValidationRule.Service_Method_Name__c) {
            when COOED {
                if (
                    storeAccount.Change_of_Ownership_Effective_Date__c == null ||
                    storeAccount.Change_of_Ownership_Effective_Date__c >
                    storeAccount.Proposed_Date_of_Activation__c
                ) {
                    failedReadinessValidationRule = readinessValidationRule;
                }
            }
            when COOEDONWEEKEND {
                if (
                    storeAccount.Change_of_Ownership_Effective_Date__c != null &&
                    isWeekend(
                        convertDateToGMTDatetime(storeAccount.Change_of_Ownership_Effective_Date__c)
                    )
                ) {
                    failedReadinessValidationRule = readinessValidationRule;
                }
            }
        }
        return failedReadinessValidationRule;
    }

    /**
     * @description It checks whether 'Proposed Date of Activation' field
     * of the store Account or work order on basis of the passed targeSobjectType
     * associated with the passed Work Order has failed readiness check.
     * @JIRA# LEM-3649
     * @param readinessValidationRuleToTypeToSubTypes
     * @param readinessValidationRule
     * @param workOrder
     * @return Store_Readiness_Validation_Rule__mdt
     */
    public Store_Readiness_Validation_Rule__mdt getProposedDateOfActivationFailedReadinessCheck(
        Map<String, Map<String, Set<String>>> readinessValidationRuleToTypeToSubTypes,
        Store_Readiness_Validation_Rule__mdt readinessValidationRule,
        WorkOrder workOrder
    ) {
        WorkOrder parentWorkOrder;
        Date proposedDateOfActivationToValidate;
        if (readinessValidationRule.Object_Name__c == OBJECT_NAME_ACCOUNT) {
            proposedDateOfActivationToValidate = workOrder.Account.Proposed_Date_of_Activation__c;
            parentWorkOrder = workOrder.ParentWorkOrder;
        } else if (readinessValidationRule.Object_Name__c == OBJECT_NAME_WORK_ORDER) {
            proposedDateOfActivationToValidate = workOrder.Proposed_Date_of_Activation__c;
            parentWorkOrder = workOrder;
        }
        if (
            !hasTypeSubTypeMatchingWithWorkOrder(
                readinessValidationRuleToTypeToSubTypes,
                readinessValidationRule,
                parentWorkOrder
            )
        ) {
            return null;
        }
        return validateProposedDateOfActivation(
            readinessValidationRule,
            proposedDateOfActivationToValidate
        );
    }

    /**
     * @description It checks whether the passed Work Order has eligible Type and Sub-Type
     * applicable for the passed readiness validation rule.
     * @JIRA# LEM-3231
     * @param readinessValidationRuleToTypeToSubTypes
     * @param readinessValidationRule
     * @param workOrder
     * @return Boolean
     */
    public Boolean hasTypeSubTypeMatchingWithWorkOrder(
        Map<String, Map<String, Set<String>>> readinessValidationRuleToTypeToSubTypes,
        Store_Readiness_Validation_Rule__mdt readinessValidationRule,
        WorkOrder workOrder
    ) {
        Boolean isMatching = false;
        Set<String> subTypes;
        Map<String, Set<String>> typeToSubTypes;
        // Checks whether the passed "Store Readiness Validation Rule" is applicable to Work Order Type and Sub-Type mapping
        if (
            !readinessValidationRuleToTypeToSubTypes.containsKey(
                readinessValidationRule.DeveloperName
            )
        ) {
            isMatching = true;
            return isMatching;
        }
        typeToSubTypes = readinessValidationRuleToTypeToSubTypes.get(
            readinessValidationRule.DeveloperName
        );
        for (String eachType : typeToSubTypes.keySet()) {
            subTypes = new Set<String>();
            if (workOrder.Type__c != eachType) {
                continue;
            }
            if (String.isBlank(workOrder.Sub_Type__c)) {
                isMatching = true;
                break;
            }
            subTypes = typeToSubTypes.get(eachType);
            if (String.isNotBlank(workOrder.Sub_Type__c) && subTypes.isEmpty()) {
                isMatching = true;
                break;
            }
            if (!subTypes.isEmpty() && subTypes.contains(workOrder.Sub_Type__c)) {
                isMatching = true;
                break;
            }
        }
        return isMatching;
    }

    /**
     * @description It converts the passed date to datetime in GMT timezone.
     * @JIRA# LEM-3649
     * @param dateToConvert
     * @return Datetime
     */
    private Datetime convertDateToGMTDatetime(Date dateToConvert) {
        return Datetime.newInstanceGMT(
            dateToConvert.year(),
            dateToConvert.month(),
            dateToConvert.day()
        );
    }

    /**
     * @description It is used to calculate days between the passed datetime values
     * excluding weekend.
     * @JIRA# LEM-3649
     * @param startDate
     * @param endDate
     * @return Integer
     */
    private Integer daysBetweenExcludingWeekends(Datetime startDate, Datetime endDate) {
        Integer daysBetween = 0;
        while (startDate < endDate) {
            if (!isWeekend(startDate)) {
                ++daysBetween;
            }
            startDate = startDate.addDays(1);
        }
        return daysBetween;
    }

    /**
     * @description It checks whether the passed datetime is on Saturday or Sunday.
     * @JIRA# LEM-3649
     * @param dateTimeToValidate
     * @return Boolean
     */
    private Boolean isWeekend(Datetime dateTimeToValidate) {
        return dateTimeToValidate.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL) == DAY_OF_WEEK_SAT ||
            dateTimeToValidate.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL) == DAY_OF_WEEK_SUN;
    }

    /**
     * @description It validates whether the passed 'Proposed Date of Activation' date value
     * is failing any readiness check.
     * @JIRA# LEM-3649
     * @param readinessValidationRule
     * @param proposedDateOfActivationToValidate
     * @return Store_Readiness_Validation_Rule__mdt
     */
    private Store_Readiness_Validation_Rule__mdt validateProposedDateOfActivation(
        Store_Readiness_Validation_Rule__mdt readinessValidationRule,
        Date proposedDateOfActivationToValidate
    ) {
        Store_Readiness_Validation_Rule__mdt failedReadinessValidationRule;
        // current value = 4
        Integer pdoaDaysInFutureLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PDOA_DAYS_IN_FUTURE_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
        switch on METHODNAMETOMETHODTYPES.get(readinessValidationRule.Service_Method_Name__c) {
            when PDOA {
                if (
                    (proposedDateOfActivationToValidate == null &&
                    readinessValidationRule.Object_Name__c == OBJECT_NAME_ACCOUNT) ||
                    (proposedDateOfActivationToValidate != null &&
                    (daysBetweenExcludingWeekends(
                        convertDateToGMTDatetime(Date.today()),
                        convertDateToGMTDatetime(proposedDateOfActivationToValidate)
                    ) < pdoaDaysInFutureLimit))
                ) {
                    failedReadinessValidationRule = readinessValidationRule;
                }
            }
            when PDOAONWEEKEND {
                if (
                    proposedDateOfActivationToValidate != null &&
                    isWeekend(convertDateToGMTDatetime(proposedDateOfActivationToValidate))
                ) {
                    failedReadinessValidationRule = readinessValidationRule;
                }
            }
        }
        return failedReadinessValidationRule;
    }

    /**
     * @description It is used to perform validation on MP_Bz_Id__c check whether the field configured
     * in the passed custom metadata is null on Contract or Opportunity associated to the passed Work Orders.
     * @JIRA# LEM-16290
     * @param readinessValidationRuleToTypeToSubTypes
     * @param readinessValidationRule
     * @param workOrder
     * @return Store_Readiness_Validation_Rule__mdt
     */
    public Store_Readiness_Validation_Rule__mdt getMpBzIdNullReadinessCheck(
        Map<String, Map<String, Set<String>>> readinessValidationRuleToTypeToSubTypes,
        Store_Readiness_Validation_Rule__mdt readinessValidationRule,
        WorkOrder workOrder
    ) {
        Store_Readiness_Validation_Rule__mdt failedReadinessValidationRule;
        if (
            !hasTypeSubTypeMatchingWithWorkOrder(
                readinessValidationRuleToTypeToSubTypes,
                readinessValidationRule,
                workOrder
            )
        ) {
            return failedReadinessValidationRule;
        }

        if (isEligibleForMpBzIdReadinessCheck(workOrder)) {
            failedReadinessValidationRule = checkForOpportunityOrContractMpBzIdError(
                workOrder,
                readinessValidationRule
            );
        }
        return failedReadinessValidationRule;
    }

    /**
     * @description Checks if the WorkOrder of Drive Type and Withholding SubType or Drive WO with Auto-Activations subtype with Witholding is true.
     * @JIRA# LEM-16290
     * @param workOrder
     * @return Boolean
     */
    private Boolean isEligibleForMpBzIdReadinessCheck(WorkOrder workOrder) {
        return workOrder.Sub_Type__c == WITHHOLDING ||
            (workOrder.Sub_Type__c == AUTO_ACTIVATIONS &&
            workOrder.Withholding_with_Auto_Activations__c);
    }

    /**
     * @description It is used to perform validation on MP_Bz_Id__c check whether the field configured
     * in the passed custom metadata is null on Contract or Opportunity associated to the passed Work Orders.
     * @param workOrder
     * @param readinessValidationRule
     * @return Store_Readiness_Validation_Rule__mdt
     */
    private Store_Readiness_Validation_Rule__mdt checkForOpportunityOrContractMpBzIdError(
        WorkOrder workOrder,
        Store_Readiness_Validation_Rule__mdt readinessValidationRule
    ) {
        Store_Readiness_Validation_Rule__mdt readinessValidationErrorToThrow;
        if (
            isWorkOrderEligibleForOpportunityMpBzIdCheck(workOrder) &&
            readinessValidationRule.Object_Name__c == OBJECT_NAME_OPPORTUNITY
        ) {
            readinessValidationErrorToThrow = readinessValidationRule;
        } else if (
            isWorkOrderEligibleForContractMpBzIdCheck(workOrder) &&
            readinessValidationRule.Object_Name__c == OBJECT_NAME_CONTRACT
        ) {
            readinessValidationErrorToThrow = readinessValidationRule;
        }
        return readinessValidationErrorToThrow;
    }

    /**
     * @description Checks if passed WO is eligible for Opportunity Mp_Bz_Id__C check
     * @param workOrder
     * @return Boolean
     */
    private Boolean isWorkOrderEligibleForOpportunityMpBzIdCheck(WorkOrder workOrder) {
        return (workOrder.Opportunity__r != null &&
            workOrder.Opportunity__r.Nintex_Use_Case__c == INTEGRATED_FRANCHISE) &&
            workOrder.Opportunity__r.MP_Bz_Id__c == null;
    }

    /**
     * @description Checks if passed WO is eligible for Contract Mp_Bz_Id__C check
     * @param workOrder
     * @return Boolean
     */
    private Boolean isWorkOrderEligibleForContractMpBzIdCheck(WorkOrder workOrder) {
        return (workOrder.Opportunity__r == null ||
            workOrder.Opportunity__r.Nintex_Use_Case__c == null) &&
            (workOrder.Contract__r != null &&
            workOrder.Contract__r.MP_Bz_Id__c == null);
    }
}