/**
 * @author Deloitte
 * @date 10/27/2022
 * @description Interface of service class for utilities related to Readiness Validation Rules.
 */
public interface IReadinessValidationRulesService {
    /**
     * @description It collects mappings of Readiness Validation Rules
     * with Type to Sub-Type custom metadata.
     * @param readinessValidationRules
     * @return Map<String, Map<String, Set<String>>>
     */
    Map<String, Map<String, Set<String>>> collectReadinessValidationRuleMappings(
        List<Store_Readiness_Validation_Rule__mdt> readinessValidationRules
    );

    /**
     * @description It checks whether the store account associated with
     * the passed child work order doesn't holds shopping protocol value
     * as 'Dasher Pick' or 'Shopper Pick'.
     * @param workOrder
     * @return Boolean
     */
    Boolean isAccountShoppingProtocolNotDasherPickOrShopperPick(WorkOrder workOrder);

    /**
     * @description It checks whether the store account associated with
     * the passed child work order doesn't holds shopping protocol value
     * as 'Dasher Pick' or 'Shopper Pick'or as 'Dasher Pick' along with
     * Alcohol Delivery Quote Line
     * @param workOrder
     * @param accountIdsToAlcoholQuoteLineMap
     * @return Boolean
     */
    Boolean isAccountShoppingProtocolDasherPickWithAlcoholOrNotShopperPick(
        WorkOrder workOrder,
        Map<Id, List<SBQQ__QuoteLine__c>> accountIdsToAlcoholQuoteLineMap
    );

    /**
     * @description It checks whether the passed readiness check validation rule is bypassed
     * by Segment for the passed Work Order.
     * @param readinessCheckValidationRuleAPIName
     * @param workOrderToEvaluate
     * @return Boolean
     */
    Boolean isBypassedBySegmentTypeSubType(
        String readinessCheckValidationRuleAPIName,
        WorkOrder workOrderToEvaluate
    );

    /**
     * @description It checks whether the passed readiness check validation rule is bypassed
     * by Segment & Type for the passed Work Order.
     * @param readinessCheckValidationAPIName
     * @param workOrderToEvaluate
     * @return Boolean
     */
     Boolean isBypassedBySegmentType(
        String readinessCheckValidationAPIName,
        WorkOrder workOrderToEvaluate
    );

    /**
     * @description It checks whether 'Change of Ownership Effective Date' field
     * of the store Account associated with the passed Work Order has failed readiness check.
     * @param readinessValidationRuleToTypeToSubTypes
     * @param readinessValidationRule
     * @param workOrder
     * @return Store_Readiness_Validation_Rule__mdt
     */
    Store_Readiness_Validation_Rule__mdt getChangeOfOwnershipEffectiveDateFailedReadinessCheck(
        Map<String, Map<String, Set<String>>> readinessValidationRuleToTypeToSubTypes,
        Store_Readiness_Validation_Rule__mdt readinessValidationRule,
        WorkOrder workOrder
    );

    /**
     * @description It checks whether 'Proposed Date of Activation' field
     * of the store Account or work order on basis of the passed targeSobjectType
     * associated with the passed Work Order has failed readiness check.
     * @param readinessValidationRuleToTypeToSubTypes
     * @param readinessValidationRule
     * @param workOrder
     * @return Store_Readiness_Validation_Rule__mdt
     */
    Store_Readiness_Validation_Rule__mdt getProposedDateOfActivationFailedReadinessCheck(
        Map<String, Map<String, Set<String>>> readinessValidationRuleToTypeToSubTypes,
        Store_Readiness_Validation_Rule__mdt readinessValidationRule,
        WorkOrder workOrder
    );

    /**
     * @description It checks whether the passed Work Order has eligible Type and Sub-Type applicable
     * for the passed readiness validation rule.
     * @param readinessValidationRuleToTypeToSubTypes
     * @param readinessValidationRule
     * @param workOrder
     * @return Boolean
     */
    Boolean hasTypeSubTypeMatchingWithWorkOrder(
        Map<String, Map<String, Set<String>>> readinessValidationRuleToTypeToSubTypes,
        Store_Readiness_Validation_Rule__mdt readinessValidationRule,
        WorkOrder workOrder
    );

    /**
     * @description It is used to perform validation on MP_Bz_Id__c check whether the field configured
     * in the passed custom metadata is null on Contract or Opportunity associated to the passed Work Orders.
     * @JIRA# LEM-16290
     * @param readinessValidationRuleToTypeToSubTypes
     * @param readinessValidationRule
     * @param workOrder
     * @return Store_Readiness_Validation_Rule__mdt
     */
    Store_Readiness_Validation_Rule__mdt getMpBzIdNullReadinessCheck(
        Map<String, Map<String, Set<String>>> readinessValidationRuleToTypeToSubTypes,
        Store_Readiness_Validation_Rule__mdt readinessValidationRule,
        WorkOrder workOrder
    );
}