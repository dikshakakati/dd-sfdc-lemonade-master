/**
 * @author Deloitte
 * @date 10/27/2022
 * @description Service class for utilities related to Readiness Validation Rules.
 */
public inherited sharing class ReadinessValidationRulesService {
    /**
     * @description It collects mappings of Readiness Validation Rules
     * with Type to Sub-Type custom metadata.
     * @JIRA# LEM-3231
     * @param readinessValidationRules
     * @return Map<String, Map<String, Set<String>>>
     */
    public static Map<String, Map<String, Set<String>>> collectReadinessValidationRuleMappings(
        List<Store_Readiness_Validation_Rule__mdt> readinessValidationRules
    ) {
        return service().collectReadinessValidationRuleMappings(readinessValidationRules);
    }

    /**
     * @description It checks whether the store account associated with
     * the passed child work order doesn't holds shopping protocol value
     * as 'Dasher Pick' or 'Shopper Pick'
     * Alcohol Delivery Quote Line
     * @JIRA# LEM-5714, LEM-6178
     * @param workOrder
     * @return Boolean
     */
    public static Boolean isAccountShoppingProtocolNotDasherPickOrShopperPick(WorkOrder workOrder) {
        return service().isAccountShoppingProtocolNotDasherPickOrShopperPick(workOrder);
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
    public static Boolean isAccountShoppingProtocolDasherPickWithAlcoholOrNotShopperPick(
        WorkOrder workOrder,
        Map<Id, List<SBQQ__QuoteLine__c>> accountIdsToAlcoholQuoteLineMap
    ) {
        return service()
            .isAccountShoppingProtocolDasherPickWithAlcoholOrNotShopperPick(
                workOrder,
                accountIdsToAlcoholQuoteLineMap
            );
    }

    /**
     * @description It checks whether the passed readiness check validation rule is bypassed
     * by Segment for the passed Work Order.
     * @JIRA# LEM-20927
     * @param readinessCheckValidationAPIName
     * @param workOrderToEvaluate
     * @return Boolean
     */
    public static Boolean isBypassedBySegmentTypeSubType(
        String readinessCheckValidationAPIName,
        WorkOrder workOrderToEvaluate
    ) {
        return service()
            .isBypassedBySegmentTypeSubType(
                readinessCheckValidationAPIName,
                workOrderToEvaluate
            );
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
        return service()
            .isBypassedBySegmentType(
                readinessCheckValidationAPIName,
                workOrderToEvaluate
            );
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
    public static Store_Readiness_Validation_Rule__mdt getChangeOfOwnershipEffectiveDateFailedReadinessCheck(
        Map<String, Map<String, Set<String>>> readinessValidationRuleToTypeToSubTypes,
        Store_Readiness_Validation_Rule__mdt readinessValidationRule,
        WorkOrder workOrder
    ) {
        return service()
            .getChangeOfOwnershipEffectiveDateFailedReadinessCheck(
                readinessValidationRuleToTypeToSubTypes,
                readinessValidationRule,
                workOrder
            );
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
    public static Store_Readiness_Validation_Rule__mdt getProposedDateOfActivationFailedReadinessCheck(
        Map<String, Map<String, Set<String>>> readinessValidationRuleToTypeToSubTypes,
        Store_Readiness_Validation_Rule__mdt readinessValidationRule,
        WorkOrder workOrder
    ) {
        return service()
            .getProposedDateOfActivationFailedReadinessCheck(
                readinessValidationRuleToTypeToSubTypes,
                readinessValidationRule,
                workOrder
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
    public static Boolean hasTypeSubTypeMatchingWithWorkOrder(
        Map<String, Map<String, Set<String>>> readinessValidationRuleToTypeToSubTypes,
        Store_Readiness_Validation_Rule__mdt readinessValidationRule,
        WorkOrder workOrder
    ) {
        return service()
            .hasTypeSubTypeMatchingWithWorkOrder(
                readinessValidationRuleToTypeToSubTypes,
                readinessValidationRule,
                workOrder
            );
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
    public static Store_Readiness_Validation_Rule__mdt getMpBzIdNullReadinessCheck(
        Map<String, Map<String, Set<String>>> readinessValidationRuleToTypeToSubTypes,
        Store_Readiness_Validation_Rule__mdt readinessValidationRule,
        WorkOrder workOrder
    ) {
        return service()
            .getMpBzIdNullReadinessCheck(
                readinessValidationRuleToTypeToSubTypes,
                readinessValidationRule,
                workOrder
            );
    }

    /**
     * @description It creates instance of ReadinessValidationRulesService class.
     * @return IReadinessValidationRulesService - instance of ReadinessValidationRulesServiceImpl
     */
    private static IReadinessValidationRulesService service() {
        return (IReadinessValidationRulesService) Application.Service.newInstance(
            IReadinessValidationRulesService.class
        );
    }
}