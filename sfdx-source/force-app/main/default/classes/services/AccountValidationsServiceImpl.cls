/**
 * @author Deloitte
 * @date 07/11/2022
 * @description Service implementation class for Account's readiness validations related logic.
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessiveClassLength')
public inherited sharing class AccountValidationsServiceImpl implements IAccountValidationsService, IHandleStoreReadinessValidations {
    private enum MethodTypes {
        ACTIVATECENTRALLY,
        CHANGEOWNERSHIPEFFECTIVEDATE,
        DUPLICATESTATUSONBUSINESS,
        DUPLICATESTATUSONSTORE,
        MATCHPARENTWORKORDERCORRESPONDINGFIELDS,
        MERCHANTSUPPLIEDID,
        MINPREPTIME,
        NULLVALUES,
        NULLVALUESBYWOTYPE,
        PARENTNULLVALUES,
        PARENTNULLVALUESBYWOTYPE,
        PROPOSEDDATEOFACTIVATION,
        PROPOSEDDATEOFTABLET,
        POSINTEGRATION,
        SHOPPINGPROTOCOL,
        SHOPPINGPROTOCOLONRETAILMENUUITYPE,
        SHOPPINGPROTOCOLONRXMENUUITYPE,
        TAXIDBYSHOPPINGPROTOCOLTYPE,
        BIZREFEXISTSONSTORE,
        ACCESSIBILITIES,
        ORDERPROTOCOLFORPRINTER,
        ACCOUNTMENUURLPOPULATEDWHENORDERPROTOCOLNOTPOSFORSMBACCOUNT,
        STOREACCOUNTSTOREFRONTWEBSITEISPOPULATEDWHENSTOREFRONTMXHASWEBSITEISYESFORSMBACCOUNT
    }
    private static final Map<String, MethodTypes> METHODNAMETOMETHODTYPES = new Map<String, MethodTypes>{
        'validateActivateCentrally' => MethodTypes.ACTIVATECENTRALLY,
        'validateCOOED' => MethodTypes.CHANGEOWNERSHIPEFFECTIVEDATE,
        'validateCOOEDOnWeekend' => MethodTypes.CHANGEOWNERSHIPEFFECTIVEDATE,
        'validateDuplicateStatusOnBusiness' => MethodTypes.DUPLICATESTATUSONBUSINESS,
        'validateDuplicateStatusOnStore' => MethodTypes.DUPLICATESTATUSONSTORE,
        'validateMerchantSuppliedId' => MethodTypes.MERCHANTSUPPLIEDID,
        'validateMinimumPrepTime' => MethodTypes.MINPREPTIME,
        'validateNullFieldValuesOnStore' => MethodTypes.NULLVALUES,
        'validateNullFieldValuesOnStoreByWorkOrderType' => MethodTypes.NULLVALUESBYWOTYPE,
        'validateNullFieldValuesOnBusiness' => MethodTypes.PARENTNULLVALUES,
        'validateNullFieldValuesOnBusinessByWorkOrderType' => MethodTypes.PARENTNULLVALUESBYWOTYPE,
        'validatePOSIntegrationFields' => MethodTypes.POSINTEGRATION,
        'validatePDOA' => MethodTypes.PROPOSEDDATEOFACTIVATION,
        'validatePDOAOnWeekend' => MethodTypes.PROPOSEDDATEOFACTIVATION,
        'validateProposedDateOfTablet' => MethodTypes.PROPOSEDDATEOFTABLET,
        'validateShoppingProtocol' => MethodTypes.SHOPPINGPROTOCOL,
        'validateShoppingProtocolMandatoryOnRetailMenuUIType' => MethodTypes.SHOPPINGPROTOCOLONRETAILMENUUITYPE,
        'validateStoreAccountFieldValueMatchWithParentWorkOrderFieldValue' => MethodTypes.MATCHPARENTWORKORDERCORRESPONDINGFIELDS,
        'validateShoppingProtocolBlankOnRxMenuUIType' => MethodTypes.SHOPPINGPROTOCOLONRXMENUUITYPE,
        'validateTaxIdByShoppingProtocol' => MethodTypes.TAXIDBYSHOPPINGPROTOCOLTYPE,
        'validateMatchingBusinessReferenceExists' => MethodTypes.BIZREFEXISTSONSTORE,
        'validateAccessibilities' => MethodTypes.ACCESSIBILITIES,
        'validateOrderProtocolForPrinter' => MethodTypes.ORDERPROTOCOLFORPRINTER,
        'validateStoreAccountMenuUrlPopulatedWhenOrderProtocolNotPosForSmbAccount' => MethodTypes.ACCOUNTMENUURLPOPULATEDWHENORDERPROTOCOLNOTPOSFORSMBACCOUNT,
        'validateStoreAccountStorefrontWebsiteIsPopulatedWhenStorefrontMxhasWebsiteIsYesForSmbAccount' => MethodTypes.STOREACCOUNTSTOREFRONTWEBSITEISPOPULATEDWHENSTOREFRONTMXHASWEBSITEISYESFORSMBACCOUNT
    };
    private static final String ACCOUNT_BILLING_COUNTRY_CODE_CA = 'CA';
    private static final String ACTIVATE_CENTRALLY_NO = 'No';
    private static final String CLASS_NAME = 'AccountValidationsServiceImpl';
    private static final String DASHER_PICK_SHOPPING_PROTOCOL = 'Dasher Pick';
    private static final String DELAY_TABLET_SHIPMENT_YES = 'Yes';
    private static final String MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER = 'Account Owner';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String MENU_UI_TYPE_RESTAURANT = 'Restaurant';
    private static final String NON_DUPLICATE_STATUS = 'Non-Duplicate';
    private static final String ORDER_PROTOCOL_CONTAINS_POS = 'POS';
    private static final String ORDER_PROTOCOL_CONTAINS_PRINTER = 'Printer';
    private static final String PDOA_DAYS_IN_FUTURE_LIMIT_STATIC_CONFIG = 'PDOA_DAYS_IN_FUTURE_LIMIT';
    private static final String POS_INTEGRATION_TYPE_NON_INTEGRATED_MX = 'non_integrated_mx';
    private static final String POS_INTEGRATION_TYPE_LOCAL_GROCERY = 'local_grocery';
    private static final String PRIMARY_VERTICAL_FLORAL = 'Floral';
    private static final String SHOPPER_PICK_SHOPPING_PROTOCOL = 'Shopper Pick';
    private static final String WORK_ORDER_SUB_TYPE_MENU_UPDATES = 'Store';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String LOG_SERVICE_READINESS_CHECK = 'Readiness Check';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final String SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String SEGMENT_MID_MARKET = 'Mid-Market';
    private static final String SEGMENT_SMB = 'SMB';

    private static final Set<String> ELIGIBLE_DECK_RANKS = new Set<String>{
        'Ace',
        'King',
        'King of Spades',
        'Ace of Spades'
    };
    private static final String MARKETPLACE_TYPE = 'Marketplace';
    private static final String COO_TYPE = 'COO';
    private static final String TABLET_TYPE = 'Tablet';
    private static final String ENTERPRISE_SEGMENT = 'Enterprise';
    private static final String CAVIAR_EXPERIENCE = 'Caviar';
    private static final String STOREFRONT_MX_HAS_WEBSITE_YES = 'Yes';

    private List<WorkOrder> childWorkOrders;
    private Map<Id, WorkOrder> parentWorkOrders;
    private List<Readiness_Check_Failure__c> readinessValidationFailures;
    private Map<String, Map<String, Set<String>>> readinessValidationToTypeToSubTypes;
    private List<Readiness_Check_Failure__c> existingReadinessValidationFailuresRecords; //* @jira LEM-13963
    private String readinessObjectName; //* @jira LEM-13963

    /**
     * @description Default Constructor to initialize class variables.
     */
    public AccountValidationsServiceImpl() {
        this.childWorkOrders = new List<WorkOrder>();
        this.parentWorkOrders = new Map<Id, WorkOrder>();
        this.readinessValidationFailures = new List<Readiness_Check_Failure__c>();
        this.readinessValidationToTypeToSubTypes = new Map<String, Map<String, Set<String>>>();
        this.existingReadinessValidationFailuresRecords = new List<Readiness_Check_Failure__c>(); //* @jira LEM-13963
    }

    /**
     * @description It performs readiness validations on the store Accounts
     * associated with passed Work Orders according to the rules configured in the custom metadata.
     * @JIRA# LEM-1684 @jira LEM-13963
     * @param childWorkOrders
     * @param parentWorkOrders
     * @param storeReadinessValidations
     * @param existingReadinessCheckFailures
     * @param objectName
     */
    public void validate(
        List<WorkOrder> childWorkOrders,
        List<WorkOrder> parentWorkOrders,
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidations,
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures,
        String objectName
    ) {
        this.childWorkOrders.addAll(childWorkOrders);
        this.parentWorkOrders = new Map<Id, WorkOrder>(parentWorkOrders);
        this.readinessValidationToTypeToSubTypes = ReadinessValidationRulesService.collectReadinessValidationRuleMappings(
            storeReadinessValidations
        );
        this.existingReadinessValidationFailuresRecords.addAll(existingReadinessCheckFailures); //* @jira LEM-13963
        this.readinessObjectName = objectName; //* @jira LEM-13963
        runValidations(storeReadinessValidations);
        publishReadinessCheckFailures();
    }

    /**
     * @description It checks whether the passed field value is null on the passed sObjectInstance.
     * @JIRA# LEM-1684
     * @param sObjectInstance
     * @param fieldName
     * @return Boolean
     */
    private Boolean isFieldValueNull(SObject sObjectInstance, String fieldName) {
        return sObjectInstance.get(fieldName) == null;
    }

    /**
     * @description It checks whether the passed field value is matches on the passed Account
     * and Work Order.
     * @JIRA# LEM-1684
     * @param account
     * @param fieldName
     * @param workOrder
     * @return Boolean
     */
    private Boolean isFieldValueMatching(Account account, String fieldName, WorkOrder workOrder) {
        return account.get(fieldName) == workOrder.get(fieldName);
    }

    /**
     * @description It checks whether the Shopping Protocol validation criteria is satisfied:
     * a. If Shopping Protocol is populated then it should be either 'Shopper Pick' or 'Dasher Pick'
     * when store Account’s Menu UI Type is Retail and Order Protocol contains POS. OR
     * b. If Shopping Protocol is populated when store Account’s Menu UI Type is Restaurant.
     * @JIRA# LEM-2658, LEM-3007, LEM-3447
     * @param storeAccount
     * @return Boolean
     */
    private Boolean isShoppingProtocolValidationCriteriaSatisfied(Account storeAccount) {
        return String.isNotBlank(storeAccount.Order_Protocol__c) &&
            String.valueOf(storeAccount.Order_Protocol__c).contains(ORDER_PROTOCOL_CONTAINS_POS) &&
            storeAccount.Menu_UI_Type__c == MENU_UI_TYPE_RETAIL &&
            String.isNotBlank(storeAccount.Shopping_Protocol__c) &&
            storeAccount.Shopping_Protocol__c != DASHER_PICK_SHOPPING_PROTOCOL &&
            storeAccount.Shopping_Protocol__c != SHOPPER_PICK_SHOPPING_PROTOCOL;
    }
    /**
     * @description It is an overloaded method and creates 'Readiness Check Failures' records based on the passed Work Order
     * and Store Readiness Validation Rule.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrder
     */
    private void logReadinessCheckFailure(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        WorkOrder workOrder
    ) {
        logReadinessCheckFailure(storeReadinessValidationRule, workOrder, '');
    }
    /**
     * @description It creates 'Readiness Check Failures' records based on the passed Work Order
     * and Store Readiness Validation Rule.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrder
     * @param errorMessage
     */
    private void logReadinessCheckFailure(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        WorkOrder workOrder,
        String errorMessage
    ) {
        readinessValidationFailures.add(
            new Readiness_Check_Failure__c(
                Account_Name__c = workOrder.AccountId,
                Child_Work_Order__c = workOrder.Id,
                Error_Message__c = String.isNotBlank(errorMessage)
                    ? errorMessage
                    : storeReadinessValidationRule.Error_Message__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId == null
                    ? workOrder.Id
                    : workOrder.ParentWorkOrderId
            )
        );
    }

    /**
     * @description It commits 'Readiness Check Failures' records in the database.
     * @JIRA# LEM-1684 // @jira LEM-13963
     */
    private void publishReadinessCheckFailures() {
        StoreReadinessModificationService.processReadinessCheckFailures(
            existingReadinessValidationFailuresRecords,
            readinessValidationFailures,
            readinessObjectName,
            CLASS_NAME
        );
    }

    /**
     * @description It run store readiness validations on child and parent Work Orders.
     * @JIRA# LEM-1684
     * @param storeReadinessValidations - custom metadata records
     */
    private void runValidations(
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidations
    ) {
        for (
            Store_Readiness_Validation_Rule__mdt eachStoreReadinessValidationRule : storeReadinessValidations
        ) {
            switch on
                METHODNAMETOMETHODTYPES.get(
                    eachStoreReadinessValidationRule.Service_Method_Name__c
                ) {
                when ACTIVATECENTRALLY {
                    validateActivateCentrally(eachStoreReadinessValidationRule, childWorkOrders);
                }
                when CHANGEOWNERSHIPEFFECTIVEDATE {
                    validateChangeOfOwnershipEffectiveDate(
                        eachStoreReadinessValidationRule,
                        childWorkOrders
                    );
                }
                when DUPLICATESTATUSONBUSINESS {
                    validateDuplicateStatus(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when DUPLICATESTATUSONSTORE {
                    validateDuplicateStatus(eachStoreReadinessValidationRule, childWorkOrders);
                }
                when MATCHPARENTWORKORDERCORRESPONDINGFIELDS {
                    validateStoreAccountFieldValueMatchWithParentWorkOrderFieldValue(
                        eachStoreReadinessValidationRule,
                        childWorkOrders
                    );
                }
                when MERCHANTSUPPLIEDID {
                    validateMerchantSuppliedId(eachStoreReadinessValidationRule, childWorkOrders);
                }
                when MINPREPTIME {
                    validateMinimumPrepTime(eachStoreReadinessValidationRule, childWorkOrders);
                }
                when NULLVALUES {
                    validateNullFieldValuesOnAccount(
                        eachStoreReadinessValidationRule,
                        childWorkOrders
                    );
                }
                when NULLVALUESBYWOTYPE {
                    validateNullFieldValuesOnAccountByWorkOrderType(
                        eachStoreReadinessValidationRule,
                        childWorkOrders
                    );
                }
                when PARENTNULLVALUES {
                    validateNullFieldValuesOnAccount(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when PARENTNULLVALUESBYWOTYPE {
                    validateNullFieldValuesOnAccountByWorkOrderType(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when POSINTEGRATION {
                    validatePOSIntegrationFields(eachStoreReadinessValidationRule, childWorkOrders);
                }
                when PROPOSEDDATEOFACTIVATION {
                    validateProposedDateOfActivation(
                        eachStoreReadinessValidationRule,
                        childWorkOrders
                    );
                }
                when PROPOSEDDATEOFTABLET {
                    validateProposedDateOfTablet(eachStoreReadinessValidationRule, childWorkOrders);
                }
                when SHOPPINGPROTOCOL {
                    validateShoppingProtocol(eachStoreReadinessValidationRule, childWorkOrders);
                }
                when SHOPPINGPROTOCOLONRETAILMENUUITYPE {
                    validateShoppingProtocolMandatoryOnRetailMenuUIType(
                        eachStoreReadinessValidationRule,
                        childWorkOrders
                    );
                }
                when SHOPPINGPROTOCOLONRXMENUUITYPE {
                    validateShoppingProtocolBlankOnRxMenuUIType(
                        eachStoreReadinessValidationRule,
                        childWorkOrders
                    );
                }
                when TAXIDBYSHOPPINGPROTOCOLTYPE {
                    validateTaxIdByShoppingProtocol(
                        eachStoreReadinessValidationRule,
                        childWorkOrders
                    );
                }
                when BIZREFEXISTSONSTORE {
                    validateMatchingBusinessReferenceExists(
                        eachStoreReadinessValidationRule,
                        childWorkOrders
                    );
                }
                when ACCESSIBILITIES {
                    validateAccessibilities(eachStoreReadinessValidationRule, childWorkOrders);
                }
                when ORDERPROTOCOLFORPRINTER {
                    validateOrderProtocolForPrinter(
                        eachStoreReadinessValidationRule,
                        childWorkOrders
                    );
                }
                when ACCOUNTMENUURLPOPULATEDWHENORDERPROTOCOLNOTPOSFORSMBACCOUNT {
                    validateStoreAccountMenuUrlPopulatedWhenOrderProtocolNotPosForSmbAccount(
                        eachStoreReadinessValidationRule,
                        childWorkOrders
                    );
                }
                when STOREACCOUNTSTOREFRONTWEBSITEISPOPULATEDWHENSTOREFRONTMXHASWEBSITEISYESFORSMBACCOUNT {
                    validateStoreAccountStorefrontWebsiteIsPopulatedWhenStorefrontMxhasWebsiteIsYesForSmbAccount(
                        eachStoreReadinessValidationRule,
                        childWorkOrders
                    );
                }
            }
        }
    }

    /**
     * @description It is used to perform validation 'Activated Centrally' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateActivateCentrally(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account storeAccount;
        for (WorkOrder eachWorkOrder : workOrders) {
            storeAccount = eachWorkOrder.Account;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                (storeAccount.Menu_to_be_Completed_By__c == MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER &&
                storeAccount.Activated_Centrally_AC__c != ACTIVATE_CENTRALLY_NO)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation on 'Change of Ownership Effective Date' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateChangeOfOwnershipEffectiveDate(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidate;
        for (WorkOrder eachWorkOrder : workOrders) {
            storeReadinessValidationRuleToValidate = ReadinessValidationRulesService.getChangeOfOwnershipEffectiveDateFailedReadinessCheck(
                readinessValidationToTypeToSubTypes,
                storeReadinessValidationRule,
                eachWorkOrder
            );
            if (storeReadinessValidationRuleToValidate != null) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation on 'Duplicate Status' field of
     * the business/store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-3621
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateDuplicateStatus(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account accountToValidate;
        for (WorkOrder eachWorkOrder : workOrders) {
            accountToValidate = eachWorkOrder.Account;
            if (accountToValidate.Duplicate_Status__c != NON_DUPLICATE_STATUS) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation on 'Merchant Supllied Id' field
     * of the store Accounts associated with the passed Work Orders that it matches with
     * POS Integration Id when:
     * 1. Work Order Type is Marketplace or COO
     * 2. Menu UI Type is Retail
     * 3. POS Integration Type is not non_integrated_mx or local_grocery
     * @JIRA# LEM-4729
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateMerchantSuppliedId(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account accountToValidate;
        for (WorkOrder eachWorkOrder : workOrders) {
            accountToValidate = eachWorkOrder.Account;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder.ParentWorkOrder
                ) &&
                accountToValidate.Menu_UI_Type__c == MENU_UI_TYPE_RETAIL &&
                String.isNotBlank(accountToValidate.POS_Integration_Type__c) &&
                accountToValidate.POS_Integration_Type__c !=
                POS_INTEGRATION_TYPE_NON_INTEGRATED_MX &&
                accountToValidate.POS_Integration_Type__c != POS_INTEGRATION_TYPE_LOCAL_GROCERY &&
                accountToValidate.Merchant_Supplied_ID__c != accountToValidate.POS_Integration_ID__c
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation on 'Minimum prep Time' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateMinimumPrepTime(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account storeAccount;
        for (WorkOrder eachWorkOrder : workOrders) {
            storeAccount = eachWorkOrder.Account;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                storeAccount.Primary_Vertical__c == PRIMARY_VERTICAL_FLORAL &&
                isFieldValueNull(storeAccount, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation to check whether the field configured
     * in the passed custom metadata is null on the business/store Accounts associated
     * with the passed Work Orders.
     * It corresponds to validateNullFieldValuesOnBusiness & validateNullFieldValuesOnStore
     * configured in validation rules.
     * @JIRA# LEM-1684 & LEM-2696
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateNullFieldValuesOnAccount(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account accountToValidate;
        for (WorkOrder eachWorkOrder : workOrders) {
            accountToValidate = eachWorkOrder.Account;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) && isFieldValueNull(accountToValidate, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation to check whether the field configured
     * in the passed custom metadata is null on the business/store Accounts associated
     * with the passed Work Orders applicable to configured Type & Sub-Type mapping.
     * @JIRA# LEM-3717
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateNullFieldValuesOnAccountByWorkOrderType(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account accountToValidate;
        WorkOrder workOrderToCompare;
        for (WorkOrder eachWorkOrder : workOrders) {
            accountToValidate = eachWorkOrder.Account;
            workOrderToCompare = eachWorkOrder.ParentWorkOrderId == null
                ? eachWorkOrder
                : eachWorkOrder.ParentWorkOrder;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    workOrderToCompare
                ) &&
                isFieldValueNull(accountToValidate, storeReadinessValidationRule.Field_Name__c) &&
                !ReadinessValidationRulesService.isBypassedBySegmentType(
                    storeReadinessValidationRule.DeveloperName,
                    eachWorkOrder
                )
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation on POS Integration Id and Integration Type
     * fields of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validatePOSIntegrationFields(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account storeAccount;
        for (WorkOrder eachWorkOrder : workOrders) {
            storeAccount = eachWorkOrder.Account;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                String.isNotBlank(storeAccount.Order_Protocol__c) &&
                String.valueOf(storeAccount.Order_Protocol__c)
                    .contains(ORDER_PROTOCOL_CONTAINS_POS) &&
                isFieldValueNull(storeAccount, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation on 'Proposed Date of Activation' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateProposedDateOfActivation(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidate;
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                !ReadinessValidationRulesService.isBypassedBySegmentType(
                    storeReadinessValidationRule.DeveloperName,
                    eachWorkOrder
                )
            ) {
                storeReadinessValidationRuleToValidate = ReadinessValidationRulesService.getProposedDateOfActivationFailedReadinessCheck(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                );
                if (storeReadinessValidationRuleToValidate != null) {
                    logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
                }
            }
        }
    }

    /**
     * @description It validates that 'Proposed Date of Tablet' is populated
     * when Delay_Tablet_Shipment__c is 'Yes'.
     * @JIRA# LEM-3494
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateProposedDateOfTablet(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account storeAccount;
        for (WorkOrder eachWorkOrder : workOrders) {
            storeAccount = eachWorkOrder.Account;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                storeAccount.Delay_Tablet_Shipment__c == DELAY_TABLET_SHIPMENT_YES &&
                isFieldValueNull(storeAccount, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation on 'Shopping Protocol' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-1684 & LEM-2658
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateShoppingProtocol(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account storeAccount;
        for (WorkOrder eachWorkOrder : workOrders) {
            storeAccount = eachWorkOrder.Account;
            if (isShoppingProtocolValidationCriteriaSatisfied(storeAccount)) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to validate that 'Shopping Protocol' field is populated
     * on the store Accounts associated with the passed Work Orders when Menu_UI_Type__c on
     * business Account is 'Retail'.
     * @JIRA# LEM-2658
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateShoppingProtocolMandatoryOnRetailMenuUIType(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account storeAccount;
        for (WorkOrder eachWorkOrder : workOrders) {
            storeAccount = eachWorkOrder.Account;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                storeAccount.Menu_UI_Type__c == MENU_UI_TYPE_RETAIL &&
                isFieldValueNull(storeAccount, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to validate that 'Shopping Protocol' field is blank
     * on the store Accounts associated with the passed Work Orders when Menu_UI_Type__c on
     * is 'Restaurant'.
     * @JIRA# LEM-3447
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateShoppingProtocolBlankOnRxMenuUIType(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account storeAccount;
        for (WorkOrder eachWorkOrder : workOrders) {
            storeAccount = eachWorkOrder.Account;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                (storeAccount.Menu_UI_Type__c == MENU_UI_TYPE_RESTAURANT) &&
                !isFieldValueNull(storeAccount, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation on store Account corresponding fields
     * associated with the passed Work Orders.
     * @JIRA# LEM-2947
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateStoreAccountFieldValueMatchWithParentWorkOrderFieldValue(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account storeAccount;
        for (WorkOrder eachWorkOrder : workOrders) {
            storeAccount = eachWorkOrder.Account;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder.ParentWorkOrder
                ) &&
                !isFieldValueMatching(
                    storeAccount,
                    storeReadinessValidationRule.Field_Name__c,
                    eachWorkOrder.ParentWorkOrder
                )
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation on 'Tax ID' field of store account
     * associated to passed child work orders
     * where associated store account's shopping protocol field's
     * value is not as 'Dasher Pick' or 'Shopper Pick'.
     * @JIRA# LEM-6178
     * @JIRA# LEM-23067
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateTaxIdByShoppingProtocol(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account accountToValidate;
        Set<Id> workOrderIdsProcessed = new Set<Id>();
        for (WorkOrder eachWorkOrder : workOrders) {
            if (eachWorkOrder.Segment__c == SEGMENT_SMB) {
                accountToValidate = eachWorkOrder.Account;
            } else {
                accountToValidate = eachWorkOrder.ParentWorkOrder.Account;
            }
            if (
                (eachWorkOrder.Segment__c == SEGMENT_SMB &&
                workOrderIdsProcessed.contains(eachWorkOrder.Id)) ||
                (eachWorkOrder.Segment__c != SEGMENT_SMB &&
                workOrderIdsProcessed.contains(eachWorkOrder.ParentWorkOrderId))
            ) {
                continue;
            }
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder.ParentWorkOrder
                ) &&
                isFieldValueNull(accountToValidate, storeReadinessValidationRule.Field_Name__c) &&
                ReadinessValidationRulesService.isAccountShoppingProtocolNotDasherPickOrShopperPick(
                    eachWorkOrder
                ) &&
                !ReadinessValidationRulesService.isBypassedBySegmentTypeSubType(
                    storeReadinessValidationRule.DeveloperName,
                    eachWorkOrder
                )
            ) {
                if (eachWorkOrder.Segment__c == SEGMENT_SMB) {
                    workOrderIdsProcessed.add(eachWorkOrder.Id);
                    logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
                } else {
                    workOrderIdsProcessed.add(eachWorkOrder.ParentWorkOrderId);
                    logReadinessCheckFailure(
                        storeReadinessValidationRule,
                        eachWorkOrder.ParentWorkOrder
                    );
                }
            }
        }
    }
    /**
     * @description validation method to perform the business reference exists. @JIRA# LEM-12595
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateMatchingBusinessReferenceExists(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Set<String> accountIds = new Set<String>();
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) && eachWorkOrder.Account.Segment__c != SEGMENT_SMB
            ) {
                accountIds.add(eachWorkOrder.AccountId);
            }
        }
        Map<Id, String> accountIdToErrorMessage = XrefAndBizRefMatchingService.findMatchingBizRefForReadinesCheck(
            AccountsSelector.newInstance().selectById(accountIds)
        );
        for (WorkOrder eachWorkOrder : workOrders) {
            Id accountId = eachWorkOrder.AccountId;
            if (accountIdToErrorMessage.containsKey(accountId)) {
                logReadinessCheckFailure(
                    storeReadinessValidationRule,
                    eachWorkOrder,
                    accountIdToErrorMessage.get(accountId)
                );
            }
        }
    }
    /**
     * @description It is used to perform validation 'Accessibilities' field
     * of the store Accounts associated with the passed Work Orders.
     * @JIRA# LEM-12938
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateAccessibilities(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account storeAccount;
        String seattleZipCodesString = System.Label.Seattle_Zipcodes;
        List<String> seattleZipCodes = seattleZipCodesString.split(',');
        for (WorkOrder eachWorkOrder : workOrders) {
            storeAccount = eachWorkOrder.Account;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                (isFieldValueNull(storeAccount, storeReadinessValidationRule.Field_Name__c)) &&
                (String.isNotBlank(storeAccount.BillingPostalCode) &&
                seattleZipCodes.contains(storeAccount.BillingPostalCode.trim()))
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to handle the validations related to Account for Readiness check.
     * @JIRA# LEM-14284
     * @param storeReadinessValidationRule
     * @param workOrders
     *
     */
    private void validateOrderProtocolForPrinter(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> setAcc = new Set<Id>();
        List<Account> acclist = new List<Account>();
        List<WorkOrder> workOrderFilterList = new List<WorkOrder>();
        List<Mx_Tag_Association__c> mxTagAssocList = new List<Mx_Tag_Association__c>();
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                eachWorkOrder.Type__c == MARKETPLACE_TYPE ||
                eachWorkOrder.Type__c == COO_TYPE ||
                eachWorkOrder.Type__c == TABLET_TYPE
            ) {
                accountIds.add(eachWorkOrder.ParentWorkOrder.AccountId);
                workOrderFilterList.add(eachWorkOrder);
            }
        }
        acclist = AccountsSelector.newInstance().selectAccountsWithMxTagAssociation(accountIds);
        for (Account acc : acclist) {
            mxTagAssocList = acc.Mx_Tags_Association__r;
            if (mxTagAssocList.size() > 0) {
                setAcc.add(acc.Id);
            }
        }
        for (WorkOrder eachWorkOrder : workOrderFilterList) {
            Boolean validationCriteria = isEligibleForPrinter(
                setAcc,
                storeReadinessValidationRule,
                eachWorkOrder
            );

            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) && validationCriteria
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to validate whether the store is eligible for 'Printer'.
     * @JIRA# LEM-16570
     * @param businessAccountIdsWithTopMX
     * @param storeReadinessValidationRule
     * @param workOrderToValidate
     * @return Boolean
     */
    private Boolean isEligibleForPrinter(
        Set<Id> businessAccountIdsWithTopMX,
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        WorkOrder workOrderToValidate
    ) {
        Account storeAccount = workOrderToValidate.Account;
        Account businessAccountToValidate = workOrderToValidate.ParentWorkOrder.Account;
        String storeAccountSegment = storeAccount?.Segment__c == SEGMENT_MID_MARKET
            ? SEGMENT_ENTERPRISE
            : storeAccount.Segment__c;
        return !isFieldValueNull(storeAccount, storeReadinessValidationRule.Field_Name__c) &&
            String.valueOf(storeAccount?.Order_Protocol__c)
                .contains(ORDER_PROTOCOL_CONTAINS_PRINTER) &&
            !(storeAccountSegment == ENTERPRISE_SEGMENT ||
            ELIGIBLE_DECK_RANKS.contains(storeAccount?.Deck_Rank__c) ||
            (storeAccount.Experience__c != null &&
            storeAccount?.Experience__c?.contains(CAVIAR_EXPERIENCE)) ||
            businessAccountIdsWithTopMX.contains(businessAccountToValidate?.Id));
    }
    /**
     * @description It validates the Menu URL on Store Account
     * when WorkOrder Type is 'Marketplace' or 'COO', Order protocol is not POS and segment is SMB.
     * @JIRA# LEM-16577
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateStoreAccountMenuUrlPopulatedWhenOrderProtocolNotPosForSmbAccount(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account accountToValidate;
        for (WorkOrder eachWorkOrder : workOrders) {
            accountToValidate = eachWorkOrder.Account;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                isAccountSegmentSMB(accountToValidate) &&
                isFieldValueNull(accountToValidate, storeReadinessValidationRule.Field_Name__c) &&
                !String.valueOf(accountToValidate.Order_Protocol__c)
                    .contains(ORDER_PROTOCOL_CONTAINS_POS)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It validates the Storefront wensite on Store Account
     * when workorder Type is 'Storefront' and Storefront Mx Has Website is Yes.
     * @JIRA# LEM-16577
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateStoreAccountStorefrontWebsiteIsPopulatedWhenStorefrontMxhasWebsiteIsYesForSmbAccount(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Account accountToValidate;
        for (WorkOrder eachWorkOrder : workOrders) {
            accountToValidate = eachWorkOrder.Account;
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                isAccountSegmentSMB(accountToValidate) &&
                accountToValidate.Storefront_Mx_Has_Website__c == STOREFRONT_MX_HAS_WEBSITE_YES &&
                isFieldValueNull(accountToValidate, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }
    /**
     * @description It is used to validate whether the Account segment is 'SMB'.
     * @JIRA# LEM-16577
     * @param accountToCompare
     * @return Boolean
     */
    private Boolean isAccountSegmentSMB(Account accountToCompare) {
        return accountToCompare.Segment__c == SEGMENT_SMB;
    }
}