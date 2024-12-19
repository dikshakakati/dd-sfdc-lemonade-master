/**
 * @author Deloitte
 * @date 10/31/2022
 * @description Test class for ReadinessValidationRulesServiceImpl class.
 */
@isTest(SeeAllData=false)
private class ReadinessValidationRulesServiceImplTest {
    private static final String ACCOUNT_OBJECT_NAME = 'Account';
    private static final String ACCOUNT_PARENT_RELATIONSHIP_NAME = 'Parent';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ALCOHOL_DELIVERY = 'Alcohol Delivery';
    private static final String ASSERT_MESSAGE_FOR_INCORRECT_RESULT_ON_WORK_ORDER_ELIGIBILITY = 'The Eligibility of the Work Order was not computed correctly';
    private static final String ASSERT_MESSAGE_TYPE_SUBTYPE_WITH_MARKETPLACE_WAS_NOT_RETRIEVED = 'The collected mappings does not contain the Marketplace mapping.';
    private static final String ASSERT_MESSAGE_TYPE_SUBTYPE_WITH_DRIVE_WAS_NOT_RETRIEVED = 'The collected mappings does not contain the Drive mapping.';
    private static final String ASSERT_MESSAGE_INCORRECT_VALIDATION_RULE_RETURNED = 'Unexpected Result: Incorrect Store Readiness Check Validation Rule returned.';
    private static final String ASSERT_MESSAGE_DASHER_PICK_WITH_ALCOHOL_DELIVERY = 'The store account associated to passed work order contains shopping protocol as Dasher Pick and Alcohol Delivery Quote Line';
    private static final String ASSERT_MESSAGE_SHOPPING_PROTOCOL_NOT_DASHER_SHOPPER_PICK = 'The store account associated to passed work order contains shopping protocol value as Shopper Pick or Dasher Pick';
    private static final String ASSERT_MESSAGE_SHOPPING_PROTOCOL_WITH_DASHER_SHOPPER_PICK = 'The store account associated to passsed work order does not contains Account with shopping protocol as Shopper Pick or Dasher Pick';
    private static final String CONTRACT_SIGNED = 'Contract Signed';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_OPPORTUNITY_REQUIRED_MPBZID = 'Please ensure associated Opportunity has MP Biz Id configured, as this is a Drive Withholding Mx';
    private static final String DASHER_PICK_SHOPPING_PROTOCOL = 'Dasher Pick';
    private static final String ERROR_MESSAGE_ACTIVATED_CENTRALLY_TYPE = 'Please ensure Activate Centrally (AC) is populated.';
    private static final String ERROR_MESSAGE_COOED = 'Please ensure Change of Ownership Effective Date is populated and not equals or greater then Proposed Date of Activation.';
    private static final String ERROR_MESSAGE_COOED_ON_WEEKEND = 'Please ensure the COO Effective Date is not on a Saturday or Sunday.';
    private static final String ERROR_MESSAGE_PDOA = 'Please ensure the PDOA do not occur in the past. The Proposed Date of Activation must be set to at least 4 business days into the future.';
    private static final String ERROR_MESSAGE_PDOA_ON_WEEKEND = 'Please ensure the Proposed Date of Activation is not on a Saturday or Sunday.';
    private static final String FIELD_LABEL_ACTIVATED_CENTRALLY = 'Activated Centrally (AC)';
    private static final String FIELD_LABEL_COOED = 'Change of Ownership Effective Date';
    private static final String FIELD_LABEL_PDOA = 'Proposed Date of Activation';
    private static final String FIELD_LABEL_MPBZID = 'MP Bz Id';
    private static final String FIELD_NAME_MPBZID = 'MP_Bz_Id__c';
    private static final String FIELD_NAME_ACTIVATED_CENTRALLY = 'Activated_Centrally_AC__c';
    private static final String FIELD_NAME_CHANGE_OWNERSHIP_DATE = 'Change_of_Ownership_Effective_Date__c';
    private static final String FIELD_NAME_PDOA = 'Proposed_Date_of_Activation__c';
    private static final String INTEGRATED_FRANCHISE = 'Integrated Franchise';
    private static final String LINK = 'Link';
    private static final String MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER = 'Account Owner';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String OPPORTUNITY_OBJECT_NAME = 'Opportunity';
    private static final String OPPORTUNITY_NAME = 'Opportunity Readiness Check';
    private static final String SERVICE_CLASS_NAME = 'IAccountValidationsService';
    private static final String SERVICE_CLASS_WORKORDER_NAME = 'IWorkOrderValidationsService';
    private static final String SERVICE_METHOD_OPPORTUNITY_MPBZID = 'validateMPBZIdOnDriveWithholding';
    private static final String SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE = 'validateNullFieldValuesOnStoreByWorkOrderType';
    private static final String SERVICE_METHOD_VALIDATE_COOED = 'validateCOOED';
    private static final String SERVICE_METHOD_VALIDATE_COOED_ON_WEEKEND = 'validateCOOEDOnWeekend';
    private static final String SERVICE_METHOD_VALIDATE_PDOA = 'validatePDOA';
    private static final String SERVICE_METHOD_VALIDATE_PDOA_ON_WEEKEND = 'validatePDOAOnWeekend';
    private static final String SUBTYPE_AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String SUBTYPE_NET_NEW_BUSINESS = ' Net-new business';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_POST_SALES = 'Post-Sales';
    private static final String VALIDATION_WITH_SOBJECT_BINDING_MARKETPLACE = 'Activated_Centrally_req_by_Type_on_WO';
    private static final String VALIDATION_RULE_WITH_NO_BINDING = 'Birthdate_is_blank_on_Contact';
    private static final String VALIDATION_WITH_SOBJECT_BINDING_DRIVE_AND_SUBTYPE_AUTOACTIVATIONS = 'Provisioning_Process_is_required_on_WO';
    private static final String VALIDATION_RULE_DEVELOPER_NAME = 'ReadinessValidationRule';
    private static final String VERTICAL = 'Rx';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME = 'Account';
    private static final String WORKORDER_SUB_TYPE_WITHHOLDING = 'Withholding';

    /**
     * @description To test whether mapping of Readiness Validation Rule to Type to
     * Sub-Type for Marketplace is correctly returned when the passed Readiness Validation Rules
     * have existing bindings.
     */
    @isTest
    private static void testWhenReadinessValidationRulesWithBindingsReceivedThenReadinessValidationRuleWithMarketplaceTypeSubTypeMappingsReturned() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ACTIVATED_CENTRALLY_TYPE,
                        FIELD_LABEL_ACTIVATED_CENTRALLY,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        VALIDATION_WITH_SOBJECT_BINDING_MARKETPLACE
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ACTIVATED_CENTRALLY
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Object_Name__c,
                        ACCOUNT_OBJECT_NAME
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            )
        };
        Map<String, Map<String, Set<String>>> readinessValidationRulesToTypeToSubTypes = ReadinessValidationRulesService.collectReadinessValidationRuleMappings(
            storeReadinessValidationRules
        );
        System.assertEquals(
            true,
            readinessValidationRulesToTypeToSubTypes.get(
                    VALIDATION_WITH_SOBJECT_BINDING_MARKETPLACE
                )
                .containsKey(TYPE_MARKETPLACE),
            ASSERT_MESSAGE_TYPE_SUBTYPE_WITH_MARKETPLACE_WAS_NOT_RETRIEVED
        );
    }

    /**
     * @description To test whether mapping of Readiness Validation Rule to Type to Sub-Type
     * for Drive is correctly returned when the passed Readiness Validation Rules
     * have existing bindings.
     */
    @isTest
    private static void testWhenReadinessValidationRulesWithBindingsReceivedThenReadinessValidationRuleWithDriveTypeSubTypeMappingsReturned() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ACTIVATED_CENTRALLY_TYPE,
                        FIELD_LABEL_ACTIVATED_CENTRALLY,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ACTIVATED_CENTRALLY
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        VALIDATION_WITH_SOBJECT_BINDING_DRIVE_AND_SUBTYPE_AUTOACTIVATIONS
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_DRIVE
                                        )
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c,
                                            SUBTYPE_AUTO_ACTIVATIONS
                                        )
                                )
                        }
                    )
            )
        };
        Map<String, Map<String, Set<String>>> readinessValidationRuleToTypeToSubTypes = ReadinessValidationRulesService.collectReadinessValidationRuleMappings(
            storeReadinessValidationRules
        );
        System.assertEquals(
            true,
            readinessValidationRuleToTypeToSubTypes.get(
                    VALIDATION_WITH_SOBJECT_BINDING_DRIVE_AND_SUBTYPE_AUTOACTIVATIONS
                )
                .containsKey(TYPE_DRIVE),
            ASSERT_MESSAGE_TYPE_SUBTYPE_WITH_DRIVE_WAS_NOT_RETRIEVED
        );
    }

    /**
     * @description To test whether the passed Work Order is eligible for Readiness Validation Rule
     * execution when the Work Order with Type and no Sub-Type has valid mappings.
     */
    @isTest
    private static void testWhenReadinessValidationRuleWithMappingsAndWorkOrderWithTypeRecievedThenWorkOrderEligibilityReturnedTrue() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ACTIVATED_CENTRALLY_TYPE,
                        FIELD_LABEL_ACTIVATED_CENTRALLY,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ACTIVATED_CENTRALLY
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        VALIDATION_WITH_SOBJECT_BINDING_MARKETPLACE
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Map<String, Map<String, Set<String>>> readinessValidationToTypeToSubTypes = ReadinessValidationRulesService.collectReadinessValidationRuleMappings(
            storeReadinessValidationRules
        );
        Boolean eligibilityWithBlankSubType = ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
            readinessValidationToTypeToSubTypes,
            storeReadinessValidationRules[0],
            parentWorkOrder
        );
        System.assertEquals(
            true,
            eligibilityWithBlankSubType,
            ASSERT_MESSAGE_FOR_INCORRECT_RESULT_ON_WORK_ORDER_ELIGIBILITY
        );
    }

    /**
     * @description To test whether the passed Work Order is eligible for Readiness Validation Rule
     * execution when the Work Order with Type and Sub-Type has valid mappings.
     */
    @isTest
    private static void testWhenReadinessValidationRuleWithMappingsAndWorkOrderWithTypeAndSubTypeRecievedThenWorkOrderEligibilityReturnedTrue() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ACTIVATED_CENTRALLY_TYPE,
                        FIELD_LABEL_ACTIVATED_CENTRALLY,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ACTIVATED_CENTRALLY
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        VALIDATION_WITH_SOBJECT_BINDING_DRIVE_AND_SUBTYPE_AUTOACTIVATIONS
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_DRIVE
                                        )
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c,
                                            SUBTYPE_AUTO_ACTIVATIONS
                                        )
                                ),
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_DRIVE
                                        )
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c,
                                            SUBTYPE_NET_NEW_BUSINESS
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_DRIVE
            )
            .setField(WorkOrder.Sub_Type__c, SUBTYPE_AUTO_ACTIVATIONS)
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Map<String, Map<String, Set<String>>> readinessValidationToTypeToSubTypes = ReadinessValidationRulesService.collectReadinessValidationRuleMappings(
            storeReadinessValidationRules
        );
        Boolean eligibilityWithTypeSubTypesMappings = ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
            readinessValidationToTypeToSubTypes,
            storeReadinessValidationRules[0],
            parentWorkOrder
        );
        System.assertEquals(
            true,
            eligibilityWithTypeSubTypesMappings,
            ASSERT_MESSAGE_FOR_INCORRECT_RESULT_ON_WORK_ORDER_ELIGIBILITY
        );
    }

    /**
     * @description To test whether the passed Work Order is eligible for Readiness Validation Rule
     * execution when there are no associated mappings.
     */
    @isTest
    private static void testWhenReadinessValidationRuleWithoutMappingsReceivedThenWorkOrderEligibiltyReturnedTrue() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ACTIVATED_CENTRALLY_TYPE,
                        FIELD_LABEL_ACTIVATED_CENTRALLY,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ACTIVATED_CENTRALLY
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        VALIDATION_RULE_WITH_NO_BINDING
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_POST_SALES
            )
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Map<String, Map<String, Set<String>>> readinessValidationToTypeToSubTypes = ReadinessValidationRulesService.collectReadinessValidationRuleMappings(
            storeReadinessValidationRules
        );
        Boolean eligibilityWithoutMappings = ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
            readinessValidationToTypeToSubTypes,
            storeReadinessValidationRules[0],
            parentWorkOrder
        );
        System.assertEquals(
            true,
            eligibilityWithoutMappings,
            ASSERT_MESSAGE_FOR_INCORRECT_RESULT_ON_WORK_ORDER_ELIGIBILITY
        );
    }

    /**
     * @description To test whether the passed Work Order is ineligible for
     * Readiness Validation Rule execution when the Work Order with Type and Sub-Type
     * does not has valid mappings.
     */
    @isTest
    private static void testWhenReadinessValidationRuleWithMappingsAndWorkOrderWithNonMatchingTypeAndSubTypeRecievedThenWorkOrderEligibilityReturnedFalse() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ACTIVATED_CENTRALLY_TYPE,
                        FIELD_LABEL_ACTIVATED_CENTRALLY,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ACTIVATED_CENTRALLY
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        VALIDATION_WITH_SOBJECT_BINDING_DRIVE_AND_SUBTYPE_AUTOACTIVATIONS
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_DRIVE
                                        )
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c,
                                            SUBTYPE_AUTO_ACTIVATIONS
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_DRIVE
            )
            .setField(WorkOrder.Sub_Type__c, SUBTYPE_NET_NEW_BUSINESS)
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Map<String, Map<String, Set<String>>> readinessValidationToTypeToSubTypes = ReadinessValidationRulesService.collectReadinessValidationRuleMappings(
            storeReadinessValidationRules
        );
        Boolean eligibilityWithNonMatchingTypeSubTypes = ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
            readinessValidationToTypeToSubTypes,
            storeReadinessValidationRules[0],
            parentWorkOrder
        );
        System.assertEquals(
            false,
            eligibilityWithNonMatchingTypeSubTypes,
            ASSERT_MESSAGE_FOR_INCORRECT_RESULT_ON_WORK_ORDER_ELIGIBILITY
        );
    }

    /**
     * @description To test failed Readiness Validation Rule is returned when
     * 'Change of Ownership Effective Date' is null on store Account associated
     * to the passed Work Order.
     */
    @isTest
    private static void testWhenCOOEDNullThenFailedReadinessCheckValidationReturned() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_COOED,
                        FIELD_LABEL_COOED,
                        SERVICE_METHOD_VALIDATE_COOED,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        VALIDATION_RULE_DEVELOPER_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_CHANGE_OWNERSHIP_DATE
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        storeReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Change_of_Ownership_Effective_Date__c, null)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Store_Readiness_Validation_Rule__mdt failedReadinessValidationRule = ReadinessValidationRulesService.getChangeOfOwnershipEffectiveDateFailedReadinessCheck(
            new Map<String, Map<String, Set<String>>>{
                VALIDATION_RULE_DEVELOPER_NAME => new Map<String, Set<String>>{
                    TYPE_COO => new Set<String>{}
                }
            },
            storeReadinessValidationRules[0],
            workOrder
        );
        System.assertEquals(
            storeReadinessValidationRules[0],
            failedReadinessValidationRule,
            ASSERT_MESSAGE_INCORRECT_VALIDATION_RULE_RETURNED
        );
    }

    /**
     * @description To test failed Readiness Validation Rule is returned when
     * 'Change of Ownership Effective Date' is ahead of 'Proposed Date of Activation'
     * on store Account associated to the passed Work Order.
     */
    @isTest
    private static void testWhenCOOEDAheadOfPDOAThenFailedReadinessCheckValidationReturned() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_COOED,
                        FIELD_LABEL_COOED,
                        SERVICE_METHOD_VALIDATE_COOED,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        VALIDATION_RULE_DEVELOPER_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_CHANGE_OWNERSHIP_DATE
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        storeReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Proposed_Date_of_Activation__c, Date.newInstance(2121, 1, 1))
            .setField(Account.Change_of_Ownership_Effective_Date__c, Date.newInstance(2122, 1, 1))
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Store_Readiness_Validation_Rule__mdt failedReadinessValidationRule = ReadinessValidationRulesService.getChangeOfOwnershipEffectiveDateFailedReadinessCheck(
            new Map<String, Map<String, Set<String>>>{
                VALIDATION_RULE_DEVELOPER_NAME => new Map<String, Set<String>>{
                    TYPE_COO => new Set<String>{}
                }
            },
            storeReadinessValidationRules[0],
            workOrder
        );
        System.assertEquals(
            storeReadinessValidationRules[0],
            failedReadinessValidationRule,
            ASSERT_MESSAGE_INCORRECT_VALIDATION_RULE_RETURNED
        );
    }

    /**
     * @description To test failed Readiness Validation Rule is returned when
     * 'Change of Ownership Effective Date' on store Account associated to the passed Work Order
     *  occurs on weekend.
     */
    @isTest
    private static void testWhenCOOEDOnWeekendThenFailedReadinessCheckValidationReturned() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_COOED_ON_WEEKEND,
                        FIELD_LABEL_COOED,
                        SERVICE_METHOD_VALIDATE_COOED_ON_WEEKEND,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        VALIDATION_RULE_DEVELOPER_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_CHANGE_OWNERSHIP_DATE
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        storeReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Change_of_Ownership_Effective_Date__c, Date.newInstance(2122, 1, 4))
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Store_Readiness_Validation_Rule__mdt failedReadinessValidationRule = ReadinessValidationRulesService.getChangeOfOwnershipEffectiveDateFailedReadinessCheck(
            new Map<String, Map<String, Set<String>>>{
                VALIDATION_RULE_DEVELOPER_NAME => new Map<String, Set<String>>{
                    TYPE_COO => new Set<String>{}
                }
            },
            storeReadinessValidationRules[0],
            workOrder
        );
        System.assertEquals(
            storeReadinessValidationRules[0],
            failedReadinessValidationRule,
            ASSERT_MESSAGE_INCORRECT_VALIDATION_RULE_RETURNED
        );
    }

    /**
     * @description To test failed Readiness Validation Rule is returned when
     * 'Proposed Date of Activation' is null on store Account associated to the passed Work Order.
     */
    @isTest
    private static void testWhenPDOANullThenFailedReadinessCheckValidationReturned() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_PDOA,
                        FIELD_LABEL_PDOA,
                        SERVICE_METHOD_VALIDATE_PDOA,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        VALIDATION_RULE_DEVELOPER_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, FIELD_NAME_PDOA)
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        storeReadinessValidationRuleId
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Object_Name__c,
                        ACCOUNT_OBJECT_NAME
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Proposed_Date_of_Activation__c, null)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Store_Readiness_Validation_Rule__mdt failedReadinessValidationRule = ReadinessValidationRulesService.getProposedDateOfActivationFailedReadinessCheck(
            new Map<String, Map<String, Set<String>>>{
                VALIDATION_RULE_DEVELOPER_NAME => new Map<String, Set<String>>{
                    TYPE_COO => new Set<String>{}
                }
            },
            storeReadinessValidationRules[0],
            workOrder
        );
        System.assertEquals(
            storeReadinessValidationRules[0],
            failedReadinessValidationRule,
            ASSERT_MESSAGE_INCORRECT_VALIDATION_RULE_RETURNED
        );
    }

    /**
     * @description To test failed Readiness Validation Rule is returned when
     * 'Proposed Date of Activation' is less than the configured business days limit
     * (current value = 4) on store Account associated to the passed Work Order.
     */
    @isTest
    private static void testWhenPDOAOccursWithinConfiguredBusinessDaysThenFailedReadinessCheckValidationReturned() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_PDOA,
                        FIELD_LABEL_PDOA,
                        SERVICE_METHOD_VALIDATE_PDOA,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        VALIDATION_RULE_DEVELOPER_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, FIELD_NAME_PDOA)
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        storeReadinessValidationRuleId
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Object_Name__c,
                        ACCOUNT_OBJECT_NAME
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Proposed_Date_of_Activation__c, System.today().addDays(2))
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Store_Readiness_Validation_Rule__mdt failedReadinessValidationRule = ReadinessValidationRulesService.getProposedDateOfActivationFailedReadinessCheck(
            new Map<String, Map<String, Set<String>>>{
                VALIDATION_RULE_DEVELOPER_NAME => new Map<String, Set<String>>{
                    TYPE_COO => new Set<String>{}
                }
            },
            storeReadinessValidationRules[0],
            workOrder
        );
        System.assertEquals(
            storeReadinessValidationRules[0],
            failedReadinessValidationRule,
            ASSERT_MESSAGE_INCORRECT_VALIDATION_RULE_RETURNED
        );
    }

    /**
     * @description To test failed Readiness Validation Rule is returned when
     * 'Proposed Date of Activation' on store Account associated to the passed Work Order
     * occurs on weekend.
     */
    @isTest
    private static void testWhenPDOAOnWeekendThenFailedReadinessCheckValidationReturned() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_PDOA_ON_WEEKEND,
                        FIELD_LABEL_PDOA,
                        SERVICE_METHOD_VALIDATE_PDOA_ON_WEEKEND,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        VALIDATION_RULE_DEVELOPER_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, FIELD_NAME_PDOA)
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        storeReadinessValidationRuleId
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Object_Name__c,
                        ACCOUNT_OBJECT_NAME
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Proposed_Date_of_Activation__c, Date.newInstance(2122, 1, 4))
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Store_Readiness_Validation_Rule__mdt failedReadinessValidationRule = ReadinessValidationRulesService.getProposedDateOfActivationFailedReadinessCheck(
            new Map<String, Map<String, Set<String>>>{
                VALIDATION_RULE_DEVELOPER_NAME => new Map<String, Set<String>>{
                    TYPE_COO => new Set<String>{}
                }
            },
            storeReadinessValidationRules[0],
            workOrder
        );
        System.assertEquals(
            storeReadinessValidationRules[0],
            failedReadinessValidationRule,
            ASSERT_MESSAGE_INCORRECT_VALIDATION_RULE_RETURNED
        );
    }

    /**
     * @description To test whether the passed Work Order is eligible for readiness validation check
     * execution when shopping protocol field's value of the account associated with
     * it is not 'Shopping Pick' or 'Dasher Pick'.
     */
    @isTest
    private static void testWhenWorkOrderWithAccountNotHavingShoppingProtocolAsShopperAndDasherPickThenReturnTrue() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, fflib_IDGenerator.generate(Account.SObjectType))
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Boolean isEligible = ReadinessValidationRulesService.isAccountShoppingProtocolNotDasherPickOrShopperPick(
            childWorkOrder
        );
        System.assertEquals(
            true,
            isEligible,
            ASSERT_MESSAGE_SHOPPING_PROTOCOL_NOT_DASHER_SHOPPER_PICK
        );
    }

    /**
     * @description To test whether the passed work order is eligible for readiness validation check
     * execution when shopping protocol field's value of the account associated
     * with it is 'Dasher Pick'.
     */
    @isTest
    private static void testWhenReadinessValidationRulesWithAccountHavingShoppingProtocolAsDasherPickThenReturnFalse() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, fflib_IDGenerator.generate(Account.SObjectType))
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Shopping_Protocol__c, DASHER_PICK_SHOPPING_PROTOCOL)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Boolean isEligible = ReadinessValidationRulesService.isAccountShoppingProtocolNotDasherPickOrShopperPick(
            childWorkOrder
        );
        System.assertEquals(
            false,
            isEligible,
            ASSERT_MESSAGE_SHOPPING_PROTOCOL_WITH_DASHER_SHOPPER_PICK
        );
    }

    /**
     * @description To test whether the passed work order is eligible for readiness validation check
     * execution when shopping protocol field's value of the account associated
     * with it is 'Dasher Pick' and has Alcohol Delivery Quote Line.
     */
    @isTest
    private static void testWhenReadinessValidationRulesWithAccountHavingShoppingProtocolAsDasherPickAndAlcoholDeliveryQuoteLineThenReturnTrue() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);

        Fake productFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
            ALCOHOL_DELIVERY
        );

        Product2 alcoholDeliveryProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            productFakeInstance
        );

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);

        SBQQ__Quote__c quote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Account__c, businessAccountId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, true)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, CONTRACT_SIGNED)
            .setField(SBQQ__Quote__c.Signed_Contract_link__c, LINK)
            .setField(SBQQ__Quote__c.Contract_Signed_Date__c, System.today() - 5)
            .setChildren(
                'SBQQ__LineItems__r',
                new List<Fake>{
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setField(SBQQ__QuoteLine__c.Id, quoteLineId)
                        .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteId)
                        .setField(SBQQ__QuoteLine__c.SBQQ__Product__c, alcoholDeliveryProduct.Id)
                        .setParent(
                            'SBQQ__Quote__r',
                            new Fake(SBQQ__Quote__c.class)
                                .setField(SBQQ__Quote__c.Id, quoteId)
                                .setField(SBQQ__Quote__c.SBQQ__Account__c, businessAccountId)
                        )
                }
            )
            .toSObject();

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Shopping_Protocol__c, DASHER_PICK_SHOPPING_PROTOCOL)
            .setParent('Parent', businessAccountFakeInstance);

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccountId,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccountId,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );

        Map<Id, List<SBQQ__QuoteLine__c>> accountIdToQuoteLineMap = new Map<Id, List<SBQQ__QuoteLine__c>>{
            businessAccountId => new List<SBQQ__QuoteLine__c>{ quote.SBQQ__LineItems__r }
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
            IReadinessValidationRulesService.class
        );

        mocks.startStubbing();

        mocks.when(
                mockReadinessValidationRulesService.isAccountShoppingProtocolDasherPickWithAlcoholOrNotShopperPick(
                    childWorkOrder,
                    accountIdToQuoteLineMap
                )
            )
            .thenReturn(true);
        mocks.stopStubbing();

        Application.SERVICE.setMock(
            IReadinessValidationRulesService.class,
            mockReadinessValidationRulesService
        );

        ReadinessValidationRulesServiceImpl readinessValidationRuleServiceImplInstance = new ReadinessValidationRulesServiceImpl();
        Boolean isEligible = readinessValidationRuleServiceImplInstance.isAccountShoppingProtocolDasherPickWithAlcoholOrNotShopperPick(
            childWorkOrder,
            accountIdToQuoteLineMap
        );
        System.assertEquals(true, isEligible, ASSERT_MESSAGE_DASHER_PICK_WITH_ALCOHOL_DELIVERY);
    }

    /**
     * @description To test that Readiness Check Failures are created
     * when Opportunity Mp Bz Id is null on Work Order type as 'Drive' and Sub type as Withholding.
     */
    @isTest
    private static void testWhenOpportunityMpBzIdIsNullThenReadinessCheckFailuresCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );

        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Nintex_Use_Case__c, INTEGRATED_FRANCHISE);
        Opportunity corporateOpportunity = (Opportunity) ServiceMockDataBuilder.convertToSObject(
            opportunityFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Opportunity__c, corporateOpportunity.Id)
            .setField(WorkOrder.Sub_Type__c, WORKORDER_SUB_TYPE_WITHHOLDING)
            .setParent(
                'Opportunity__r',
                new Fake(Opportunity.class)
                    .setField(Opportunity.Id, corporateOpportunity.Id)
                    .setField(Opportunity.Nintex_Use_Case__c, INTEGRATED_FRANCHISE)
            );

        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_OPPORTUNITY_REQUIRED_MPBZID,
                    FIELD_LABEL_MPBZID,
                    SERVICE_METHOD_OPPORTUNITY_MPBZID,
                    OPPORTUNITY_OBJECT_NAME,
                    SERVICE_CLASS_WORKORDER_NAME
                )
                .setField(Store_Readiness_Validation_Rule__mdt.Id, storeReadinessValidationRuleId)
                .setField(
                    Store_Readiness_Validation_Rule__mdt.DeveloperName,
                    VALIDATION_RULE_DEVELOPER_NAME
                )
                .setChildren(
                    'ReadinessValidationSobjectTypeBindings__r',
                    new List<Fake>{
                        new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                            .setField(
                                ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                storeReadinessValidationRuleId
                            )
                            .setField(
                                ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                sobjectTypeSubTypeMappingId
                            )
                            .setParent(
                                'Sobject_Type_Sub_Type_Mapping__r',
                                new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                    .setField(
                                        Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                        WORKORDER_TYPE_DRIVE
                                    )
                                    .setField(
                                        Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c,
                                        WORKORDER_SUB_TYPE_WITHHOLDING
                                    )
                            )
                    }
                )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_MPBZID;
        storeReadinessValidationRule.Object_Name__c = OPPORTUNITY_OBJECT_NAME;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Store_Readiness_Validation_Rule__mdt failedReadinessValidationRule = ReadinessValidationRulesService.getMpBzIdNullReadinessCheck(
            new Map<String, Map<String, Set<String>>>{
                VALIDATION_RULE_DEVELOPER_NAME => new Map<String, Set<String>>{
                    WORKORDER_TYPE_DRIVE => new Set<String>{ WORKORDER_SUB_TYPE_WITHHOLDING }
                }
            },
            storeReadinessValidationRule,
            parentWorkOrder
        );
        System.assertEquals(
            storeReadinessValidationRule,
            failedReadinessValidationRule,
            ASSERT_MESSAGE_INCORRECT_VALIDATION_RULE_RETURNED
        );
    }
}