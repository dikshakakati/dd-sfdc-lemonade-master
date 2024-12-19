/**
 * @author Deloitte
 * @date 07/12/2022
 * @description Service implementation class for Contact's readiness validations related logic.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class ContactValidationsServiceImpl implements IContactValidationsService, IHandleStoreReadinessValidations {
    private static final Set<String> ACCOUNT_ORDER_PROTOCOL_MERCHANT_OWNS = new Set<String>{
        'Android Tablet (Merchant Owns)',
        'POS and Tablet (Merchant Owns)'
    };
    private static final String ACCOUNT_RECORD_TYPE_STORE = 'Store';
    private static final String BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG = 'DOBReadinessCheckCountriesStates';
    private static final String CONTACT_ROLE_DECISION_MAKER = 'Decision Maker';
    private static final String CONTACT_ROLE_BUSINESS_OWNER = 'Business Owner';
    private static final String CONTACT_ROLE_BUSINESS_DIRECTOR = 'Business Director';
    private static final String COMMA_SEPARATOR = ',';
    private static final String HYPHEN_SEPARATOR = '-';
    private static final String WORK_ORDER_TYPE_POST_SALES = 'Post-Sales';
    private static final String WORK_ORDER_SUBTYPE_RATE_CHANGE = 'Rate Change';
    private enum MethodTypes {
        VALIDATEBIRTHDATE,
        VALIDATEDECISIONMAKER,
        VALIDATEDECISIONMAKERWITHTABLETORDERPROTOCOL,
        VALIDATEDECISIONMAKERPHONE,
        VALIDATESSN,
        VALIDATECANADIANROLES,
        VALIDATECANADIANBIZREPDETAILS,
        VALIDATECANADIANBIZDIRECTORDETAILS,
        VALIDATECANADIANBIZOWNERDETAILS
    }
    private static final Map<String, MethodTypes> METHODNAMETOMETHODTYPES = new Map<String, MethodTypes>{
        'validateBirthdate' => MethodTypes.VALIDATEBIRTHDATE,
        'validateDecisionMakerContact' => MethodTypes.VALIDATEDECISIONMAKER,
        'validateDecisionMakerContactWithTabletOrderProtocol' => MethodTypes.VALIDATEDECISIONMAKERWITHTABLETORDERPROTOCOL,
        'validateDecisionMakerContactPhoneWithTabletOrderProtocol' => MethodTypes.VALIDATEDECISIONMAKERPHONE,
        'validateSSN' => MethodTypes.VALIDATESSN,
        'validateExistenceOfCanadianContactRoles' => MethodTypes.VALIDATECANADIANROLES,
        'validateBusinessDirectorDetails' => MethodTypes.VALIDATECANADIANBIZDIRECTORDETAILS,
        'validateBusinessOwnerDetails' => MethodTypes.VALIDATECANADIANBIZOWNERDETAILS
    };
    private static final String PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE = 'Invoice';
    private static final String PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS = 'Payments';
    private static final String SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG = 'SSNReadinessCheckCountriesStates';
    private static final String ORDER_PROTOCOL_VALUE_TABLET = 'Tablet';
    private static final String WORK_ORDER_TYPE_COO = 'COO';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';

    private List<WorkOrder> childWorkOrders;
    private Map<Id, List<WorkOrder>> childWorkOrdersByParentWorkOrders;
    private static Set<String> eligibleCountriesStatesToValidateBirthdate;
    private static Set<String> eligibleCountriesStatesToValidateSSN;
    private Map<Id, WorkOrder> parentWorkOrders;
    private String paymentAccountRecordType;
    private List<Readiness_Check_Failure__c> readinessValidationFailures;
    private Map<String, Map<String, Set<String>>> readinessValidationToTypeToSubTypes;
    private Map<Id, List<Contact>> accountIdToDecisionMakerContacts;
    private Map<Id, Map<String, AccountContactRelation>> allContactRolesByAccountId;
    private Set<Id> idsOfBizAccountsInCanada;
    private Map<Id, List<Contact>> workOrderIdToContacts;
    private List<WorkOrder> workOrdersToValidate;
    private List<Readiness_Check_Failure__c> existingReadinessValidationFailuresRecords; //* @jira LEM-13963
    private String readinessObjectName; //* @jira LEM-13963
    private static final String CLASS_NAME = 'ContactValidationsServiceImpl'; //* @jira LEM-13963

    /**
     * @description It is used to initialize the static variables.
     * @JIRA# LEM-3406
     */
    static {
        eligibleCountriesStatesToValidateBirthdate = new Set<String>();
        eligibleCountriesStatesToValidateSSN = new Set<String>();
        collectEligibleCountriesAndStates();
    }

    /**
     * @description Default Constructor to initialize class variables.
     */
    public ContactValidationsServiceImpl() {
        this.childWorkOrders = new List<WorkOrder>();
        this.parentWorkOrders = new Map<Id, WorkOrder>();
        this.childWorkOrdersByParentWorkOrders = new Map<Id, List<WorkOrder>>();
        this.paymentAccountRecordType = PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS;
        this.readinessValidationFailures = new List<Readiness_Check_Failure__c>();
        this.readinessValidationToTypeToSubTypes = new Map<String, Map<String, Set<String>>>();
        this.accountIdToDecisionMakerContacts = new Map<Id, List<Contact>>();
        this.allContactRolesByAccountId = new Map<Id, Map<String, AccountContactRelation>>();
        this.workOrderIdToContacts = new Map<Id, List<Contact>>();
        this.workOrdersToValidate = new List<WorkOrder>();
        this.existingReadinessValidationFailuresRecords = new List<Readiness_Check_Failure__c>(); //* @jira LEM-13963
    }

    /**
     * @description It performs readiness validations on the Contacts
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
        collectChildWorkOrdersWithParents();
        collectContactsByWorkOrders();
        collectDecisionMakerContactsByAccounts();
        collectRequiredCanadianBusinessContactDetails();
        runValidations(storeReadinessValidations);
        publishReadinessCheckFailures();
    }

    /**
     * @description Accumulates the Child Work Orders by their parents
     **/
    private void collectChildWorkOrdersWithParents() {
        for (Id thisParentId : parentWorkOrders.keySet()) {
            childWorkOrdersByParentWorkOrders.put(thisParentId, new List<WorkOrder>());
        }

        for (WorkOrder thisChild : childWorkOrders) {
            if (childWorkOrdersByParentWorkOrders.containsKey(thisChild.ParentWorkOrderId)) {
                childWorkOrdersByParentWorkOrders.get(thisChild.ParentWorkOrderId).add(thisChild);
            }
        }
    }

    /**
     * @description It is used to collect Account Ids from Merchant Services associated with Products
     * having name as Alcohol Delivery or Alcohol Pickup.
     * @param accountIdToWorkOrder
     * @return Map<Id, WorkOrder>
     */
    private Map<Id, WorkOrder> collectAccountsWithAlcoholRelatedProducts(
        Map<Id, WorkOrder> accountIdToWorkOrder
    ) {
        if (accountIdToWorkOrder.isEmpty()) {
            return accountIdToWorkOrder;
        }
        Map<Id, WorkOrder> accountIdToWorkOrderWithAlcoholProducts = new Map<Id, WorkOrder>();
        for (
            Merchant_Service__c eachMerchantService : MerchantSelector.newInstance()
                .selectServicesWithAlcoholProductsByAccountIds(accountIdToWorkOrder.keySet())
        ) {
            if (
                accountIdToWorkOrder.containsKey(eachMerchantService.Account__c) &&
                !accountIdToWorkOrderWithAlcoholProducts.containsKey(eachMerchantService.Account__c)
            ) {
                accountIdToWorkOrderWithAlcoholProducts.put(
                    eachMerchantService.Account__c,
                    accountIdToWorkOrder.get(eachMerchantService.Account__c)
                );
            }
        }
        return accountIdToWorkOrderWithAlcoholProducts;
    }

    /**
     * @description It is used to collect Contacts associated with Accounts of
     * the Work Orders.
     * @JIRA# LEM-2696 & LEM-3406 & LEM-3941
     */
    private void collectContactsByWorkOrders() {
        Map<Id, WorkOrder> accountIdToWorkOrder = new Map<Id, WorkOrder>();

        for (WorkOrder eachParentWorkOrder : parentWorkOrders.values()) {
            if (eachParentWorkOrder.Type__c == WORK_ORDER_TYPE_MARKETPLACE ||
                eachParentWorkOrder.Type__c == WORK_ORDER_TYPE_COO) {
                workOrdersToValidate.addAll(childWorkOrders);
                paymentAccountRecordType = PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS;
            } else if (eachParentWorkOrder.Type__c == WORK_ORDER_TYPE_DRIVE) {
                workOrdersToValidate.addAll(parentWorkOrders.values());
                paymentAccountRecordType = PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE;
            } else if (
                eachParentWorkOrder.Type__c == WORK_ORDER_TYPE_POST_SALES &&
                eachParentWorkOrder.Sub_Type__c == WORK_ORDER_SUBTYPE_RATE_CHANGE
            ) {
                workOrdersToValidate.addAll(childWorkOrders);
            }
        }

        for (WorkOrder eachWorkOrder : workOrdersToValidate) {
            accountIdToWorkOrder.put(eachWorkOrder.AccountId, eachWorkOrder);
        }
        accountIdToWorkOrder = collectAccountsWithAlcoholRelatedProducts(accountIdToWorkOrder);
        workOrderIdToContacts = collectContactsRelatedToPaymentAccounts(accountIdToWorkOrder);
    }

    /**
     * @description It is used to collect Contacts from related Payment Accounts
     * of the passed Accounts.
     * @param accountIdToWorkOrder
     * @return Map<Id, List<Contact>>
     */
    private Map<Id, List<Contact>> collectContactsRelatedToPaymentAccounts(
        Map<Id, WorkOrder> accountIdToWorkOrder
    ) {
        Set<Id> accountIdsToCompare = new Set<Id>();
        Id workOrderId;
        if (accountIdToWorkOrder.isEmpty()) {
            return workOrderIdToContacts;
        }
        for (
            Account_Payment_Account_Relation__c eachAPAR : AccountPaymentAccountRelationsSelector.newInstance()
                .selectByAccountIdsAndPaymentAccountRecordTypes(
                    accountIdToWorkOrder.keySet(),
                    new Set<String>{ paymentAccountRecordType }
                )
        ) {
            if (accountIdsToCompare.contains(eachAPAR.Account__c)) {
                continue;
            }
            accountIdsToCompare.add(eachAPAR.Account__c);
            workOrderId = accountIdToWorkOrder.get(eachAPAR.Account__c).Id;
            if (String.isBlank(eachAPAR.Payment_Account__r.Billing_Contact_Name__c)) {
                continue;
            }
            if (!workOrderIdToContacts.containsKey(workOrderId)) {
                workOrderIdToContacts.put(workOrderId, new List<Contact>());
            }
            workOrderIdToContacts.get(workOrderId)
                .add(eachAPAR.Payment_Account__r?.Billing_Contact_Name__r);
        }
        return workOrderIdToContacts;
    }

    /**
     * @description It is used to collect Contacts with role as 'Decision Maker' on store or
     * business Accounts associated with the Work Orders.
     * @JIRA# LEM-5297
     */
    private void collectDecisionMakerContactsByAccounts() {
        Set<Id> accountIds = new Set<Id>();
        for (WorkOrder eachChildWorkOrder : workOrdersToValidate) {
            accountIds.add(eachChildWorkOrder.AccountId);
        }
        if (accountIds.isEmpty()) {
            return;
        }
        for (
            AccountContactRelation eachAccountContactRelation : AccountContactRelationsSelector.newInstance()
                .selectByAccountIds(accountIds)
        ) {
            if (
                !accountIdToDecisionMakerContacts.containsKey(eachAccountContactRelation.AccountId)
            ) {
                accountIdToDecisionMakerContacts.put(
                    eachAccountContactRelation.AccountId,
                    new List<Contact>{}
                );
            }
            accountIdToDecisionMakerContacts.get(eachAccountContactRelation.AccountId)
                .add(eachAccountContactRelation.Contact);
        }
    }

    /**
     * @description Retrieves the contact details required for Canadian Mx so we can validate them.
     *              This runs in the following parts:
     *                  1. Collect all the Parent/Child WorkOrder combinations
                        2. Determine if those Parents have a presence in Canada 🇨🇦
                            2a. IF ANY are in Canada, then query the Contacts
                            2b. IF NONE are in Canada, then return
     **/
    private void collectRequiredCanadianBusinessContactDetails() {
        // Collect all the Parent/Child WorkOrder combinations - we use these to determine Canadian presence
        Map<Id, Set<Id>> workOrderIdsByParent = getWorkOrderIdsByParents();
        Map<Id, Boolean> workOrdersInCanadaMap = JurisdictionService.checkParentAndChildrenInJurisdiction(
            workOrderIdsByParent,
            JurisdictionService.Jurisdiction.CANADA
        );

        setCanadianBusinessAccountIds(workOrdersInCanadaMap);

        // Do not query Contact Role data or run the checks if we do not have Canadian Mx
        if (idsOfBizAccountsInCanada.isEmpty()) {
            return;
        }

        List<AccountContactRelation> acrs = AccountContactRelationsSelector.newInstance()
            .selectActiveAcrByAccountIds(idsOfBizAccountsInCanada);
        allContactRolesByAccountId = AccountContactRelationsService.sortRolesByAccountIdAndRoleName(
            acrs
        );
    }

    /**
     * @description It is used to collect eligible countries and states using static configurations
     * for Contact readiness check validations.
     */
    private static void collectEligibleCountriesAndStates() {
        eligibleCountriesStatesToValidateBirthdate
            .addAll(
                StaticConfigurationsSelector.newInstance()
                    .getInstanceValue(BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG)
                    .Configuration_Value__c.split(COMMA_SEPARATOR)
            );
        eligibleCountriesStatesToValidateSSN.addAll(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG)
                .Configuration_Value__c.split(COMMA_SEPARATOR)
        );
    }

    /**
     * @description It checks whether the store Account associated with the passed Work Order has
     * eligible Order Protocol values for Tablet Work Plan/Case creation.
     * @JIRA# LEM-5568
     * @param workOrder
     * @return Boolean
     */
    private Boolean hasEligibleTabletOrderProtocol(WorkOrder workOrder) {
        return workOrder.Account.Order_Protocol__c != null &&
            workOrder.Account.Order_Protocol__c.contains(ORDER_PROTOCOL_VALUE_TABLET) &&
            !ACCOUNT_ORDER_PROTOCOL_MERCHANT_OWNS.contains(workOrder.Account.Order_Protocol__c);
    }

    /**
     * @description It checks whether the passed Country and State is eligible for
     * readiness check validation.
     * @JIRA# LEM-3406
     * @param account
     * @param configuredCountriesStates
     * @return Boolean
     */
    private Boolean isEligibleCountryAndState(
        Account account,
        Set<String> configuredCountriesStates
    ) {
        Boolean isEligible = false;
        //removing null value in case there is no static configuration value found
        configuredCountriesStates.remove(null);
        if (configuredCountriesStates.isEmpty()) {
            return isEligible;
        }
        isEligible = configuredCountriesStates.contains(
            account.BillingCountryCode + HYPHEN_SEPARATOR + account.BillingStateCode
        );
        if (!isEligible) {
            isEligible = configuredCountriesStates.contains(account.BillingCountryCode);
        }
        return isEligible;
    }

    /**
     * @description It creates 'Readiness Check Failures' records based on the passed Work Order
     * and Store Readiness Validation Rule.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrder
     */
    private void logReadinessCheckFailure(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        WorkOrder workOrder
    ) {
        readinessValidationFailures.add(
            new Readiness_Check_Failure__c(
                Account_Name__c = workOrder.AccountId,
                Contact_Name__c = workOrder.ContactId,
                Child_Work_Order__c = workOrder.Id,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
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
     * @JIRA# LEM-2696
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
                when VALIDATEBIRTHDATE {
                    validateBirthdate(eachStoreReadinessValidationRule);
                }
                when VALIDATEDECISIONMAKER {
                    validateDecisionMakerContact(eachStoreReadinessValidationRule);
                }
                when VALIDATEDECISIONMAKERWITHTABLETORDERPROTOCOL {
                    validateDecisionMakerContactWithTabletOrderProtocol(
                        eachStoreReadinessValidationRule
                    );
                }
                when VALIDATEDECISIONMAKERPHONE {
                    validateDecisionMakerContactPhoneWithTabletOrderProtocol(
                        eachStoreReadinessValidationRule
                    );
                }
                when VALIDATESSN {
                    validateSSN(eachStoreReadinessValidationRule);
                }
                when VALIDATECANADIANROLES {
                    validateExistenceOfCanadianContactRoles(eachStoreReadinessValidationRule);
                }
                when VALIDATECANADIANBIZDIRECTORDETAILS {
                    validateBusinessDirectorDetails(eachStoreReadinessValidationRule);
                }
                when VALIDATECANADIANBIZOWNERDETAILS {
                    validateBusinessOwnerDetails(eachStoreReadinessValidationRule);
                }
            }
        }
    }

    /**
     * @description It validates that Contacts associated with Payment Accounts of Accounts related
     * to the Work Orders has 'Birthdate' populated.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     */
    private void validateBirthdate(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule
    ) {
        for (WorkOrder eachWorkOrder : workOrdersToValidate) {
            if (
                workOrderIdToContacts.containsKey(eachWorkOrder.Id) &&
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                )
            ) {
                for (Contact eachContact : workOrderIdToContacts.get(eachWorkOrder.Id)) {
                    eachWorkOrder.ContactId = eachContact.Id;
                    if (
                        isEligibleCountryAndState(
                            eachWorkOrder.Account,
                            eligibleCountriesStatesToValidateBirthdate
                        ) && eachContact.BirthDate == null
                    ) {
                        logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
                    }
                }
            }
        }
    }

    /**
     * @description It validates whether a Contact with 'Decision Maker' role on store Accounts
     * associated with "Marketplace" child Work Orders or business Acconuts for "Drive" parent
     * Work Orders.
     * @JIRA# LEM-5297, LEM-11079
     * @param storeReadinessValidationRule
     */
    private void validateDecisionMakerContact(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule
    ) {
        for (WorkOrder eachWorkOrder : workOrdersToValidate) {
            if (
                !accountIdToDecisionMakerContacts.containsKey(eachWorkOrder.AccountId) &&
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                )
            ) {
                eachWorkOrder.ContactId = null;
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It validates the following conditions on a Contact with 'Decision Maker' role
     * associated with store Account of the child Work Orders:
     * a. Primary Account as Store
     * b. Store Account's Order Protocol contains 'Tablet'(excluding 'Merchant Owns' values).
     * @JIRA# LEM-5568, LEM-5700
     * @param storeReadinessValidationRule
     */
    private void validateDecisionMakerContactWithTabletOrderProtocol(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule
    ) {
        for (WorkOrder eachWorkOrder : childWorkOrders) {
            if (
                accountIdToDecisionMakerContacts.containsKey(eachWorkOrder.AccountId) &&
                hasEligibleTabletOrderProtocol(eachWorkOrder) &&
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                )
            ) {
                for (
                    Contact eachContact : accountIdToDecisionMakerContacts.get(
                        eachWorkOrder.AccountId
                    )
                ) {
                    if (eachContact.Account.Record_Type_Name__c != ACCOUNT_RECORD_TYPE_STORE) {
                        eachWorkOrder.ContactId = eachContact.Id;
                        logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
                    }
                    break;
                }
            }
        }
    }

    /**
     * @description It validates whether a Contact with 'Decision Maker' role on store Accounts
     * associated with the child Work Orders having applicable Order Protocol value has Phone
     * field populated.
     * @JIRA# LEM-5568, LEM-5700
     * @param storeReadinessValidationRule
     */
    private void validateDecisionMakerContactPhoneWithTabletOrderProtocol(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule
    ) {
        for (WorkOrder eachWorkOrder : childWorkOrders) {
            if (
                accountIdToDecisionMakerContacts.containsKey(eachWorkOrder.AccountId) &&
                hasEligibleTabletOrderProtocol(eachWorkOrder) &&
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                )
            ) {
                for (
                    Contact eachContact : accountIdToDecisionMakerContacts.get(
                        eachWorkOrder.AccountId
                    )
                ) {
                    eachWorkOrder.ContactId = eachContact.Id;
                    if (eachContact.Phone == null) {
                        logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
                    }
                    break;
                }
            }
        }
    }

    /**
     * @description It validates that Contacts associated with Payment Accounts of Accounts related
     * to the Work Orders has 'SSN' populated.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     */
    private void validateSSN(Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule) {
        for (WorkOrder eachWorkOrder : workOrdersToValidate) {
            if (
                workOrderIdToContacts.containsKey(eachWorkOrder.Id) &&
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                )
            ) {
                for (Contact eachContact : workOrderIdToContacts.get(eachWorkOrder.Id)) {
                    eachWorkOrder.ContactId = eachContact.Id;
                    if (
                        isEligibleCountryAndState(
                            eachWorkOrder.Account,
                            eligibleCountriesStatesToValidateSSN
                        ) && eachContact.SSN_Last_4Digits__c == null
                    ) {
                        logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
                    }
                }
            }
        }
    }

    /**
     * @description Valides that Canadian Mx have the required Business Contacts populated
     * @param storeReadinessValidationRule
     **/
    private void validateExistenceOfCanadianContactRoles(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule
    ) {
        for (Id thisParentWorkOrderId : parentWorkOrders.keySet()) {
            WorkOrder thisParentWorkOrder = parentWorkOrders.get(thisParentWorkOrderId);

            if (ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    thisParentWorkOrder
                ) &&
                idsOfBizAccountsInCanada.contains(thisParentWorkOrder.AccountId) &&
                !AccountContactRelationsService.hasRequiredCanadianContactRoles(
                    allContactRolesByAccountId.get(thisParentWorkOrder.AccountId)
                ) &&
                !ReadinessValidationRulesService.isBypassedBySegmentTypeSubType(
                    storeReadinessValidationRule.DeveloperName,
                    thisParentWorkOrder
                )
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, thisParentWorkOrder);
            }
        }
    }

    /**
     * @description Valides required fields on the `Business Director` Contact are populated.
     *              Note that "required" here means required by the Stripe API / Canadian regulations
     *              for successful provisioning. It does NOT refer to fields required in SFDC.
     * @param storeReadinessValidationRule
     **/
    private void validateBusinessDirectorDetails(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule
    ) {
        for (Id thisParentWorkOrderId : parentWorkOrders.keySet()) {
            WorkOrder thisParentWorkOrder = parentWorkOrders.get(thisParentWorkOrderId);

            Boolean isCanadian = idsOfBizAccountsInCanada.contains(thisParentWorkOrder.AccountId);

            if (!isCanadian) {
                continue;
            }

            Map<String, AccountContactRelation> rolesMap = allContactRolesByAccountId.get(
                thisParentWorkOrder.AccountId
            );

            Boolean hasBizRep =
                rolesMap != null &&
                rolesMap.get(CONTACT_ROLE_BUSINESS_DIRECTOR) != null;

            // If we are missing the Business Representative Role, the main RC will flag it
            // This validation is specifically for missing details, like Email, Phone, etc.
            if (ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    thisParentWorkOrder
                ) &&
                hasBizRep &&
                !hasRequiredBusinessDirectorDetails(rolesMap.get(CONTACT_ROLE_BUSINESS_DIRECTOR))
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, thisParentWorkOrder);
            }
        }
    }

    /**
     * @description Valides required fields on the `Business Owner` Contact are populated.
     *              Note that "required" here means required by the Stripe API / Canadian regulations
     *              for successful provisioning. It does NOT refer to fields required in SFDC.
     * @param storeReadinessValidationRule
     **/
    private void validateBusinessOwnerDetails(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule
    ) {
        for (Id thisParentWorkOrderId : parentWorkOrders.keySet()) {
            WorkOrder thisParentWorkOrder = parentWorkOrders.get(thisParentWorkOrderId);

            Boolean isCanadian = idsOfBizAccountsInCanada.contains(thisParentWorkOrder.AccountId);

            if (!isCanadian) {
                continue;
            }

            Map<String, AccountContactRelation> rolesMap = allContactRolesByAccountId.get(
                thisParentWorkOrder.AccountId
            );

            Boolean hasBizRep =
                rolesMap != null &&
                rolesMap.get(CONTACT_ROLE_BUSINESS_OWNER) != null;

            // If we are missing the Business Representative Role, the main RC will flag it
            // This validation is specifically for missing details, like Birthdate, Address
            if (ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    thisParentWorkOrder
                ) &&
                hasBizRep &&
                !hasRequiredBusinessOwnerDetails(rolesMap.get(CONTACT_ROLE_BUSINESS_OWNER))
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, thisParentWorkOrder);
            }
        }
    }

    /**
     * @description Returns a Map<Id, Set<Id>> with Sets of Child Work Order IDs sorted by their parent IDs
     * @return Map<Id, Set<Id>>
     **/
    private Map<Id, Set<Id>> getWorkOrderIdsByParents() {
        Map<Id, Set<Id>> workOrderIdsByParent = new Map<Id, Set<Id>>();

        // Convert our Map of WorkOrder records into a Set for the Canada check
        for (Id thisParentId : childWorkOrdersByParentWorkOrders.keySet()) {
            workOrderIdsByParent.put(thisParentId, new Set<Id>());

            if (
                childWorkOrdersByParentWorkOrders.containsKey(thisParentId) &&
                childWorkOrdersByParentWorkOrders.get(thisParentId) != null
            ) {
                // Get the List<WorkOrder> and convert it to a Set<Id>
                workOrderIdsByParent.get(thisParentId)
                    .addAll(
                        new Map<Id, WorkOrder>(childWorkOrdersByParentWorkOrders.get(thisParentId))
                            .keySet()
                    );
            }
        }

        return workOrderIdsByParent;
    }

    /**
     * @description Returns true if the Canadian Contact Role requirements are met for the
     *              Business Director Role
     * @param acr
     * @return Boolean
     **/
    private Boolean hasRequiredBusinessDirectorDetails(AccountContactRelation acr) {
        // If any of the following are missing, the contact is invalid: Email
        if (acr == null || acr.ContactId == null || String.isBlank(acr.Contact.Email)) {
            return false;
        }

        return true;
    }

    /**
     * @description Returns true if the Canadian Contact Role requirements are met for the
     *              Business Owner Role
     * @param acr
     * @return Boolean
     **/
    private Boolean hasRequiredBusinessOwnerDetails(AccountContactRelation acr) {
        // If any of the following are missing, the contact is invalid: Birthdate, Address
        if (
            acr == null ||
            acr.ContactId == null ||
            acr.Contact.Birthdate == null ||
            String.isBlank(acr.Contact.MailingStreet) ||
            String.isBlank(acr.Contact.MailingCity) ||
            String.isBlank(acr.Contact.MailingState) ||
            String.isBlank(acr.Contact.MailingPostalCode) ||
            String.isBlank(acr.Contact.MailingCountry)
        ) {
            return false;
        }

        return true;
    }

    /**
     * @description Returns a Set<Id> with Business Account IDs that have ties to Canada
     * @param workOrdersInCanadaMap
     **/
    private void setCanadianBusinessAccountIds(Map<Id, Boolean> workOrdersInCanadaMap) {
        idsOfBizAccountsInCanada = new Set<Id>();

        for (Id thisParentId : workOrdersInCanadaMap.keySet()) {
            if (
                workOrdersInCanadaMap.get(thisParentId) == true &&
                childWorkOrdersByParentWorkOrders.containsKey(thisParentId)
            ) {
                idsOfBizAccountsInCanada.add(parentWorkOrders.get(thisParentId).AccountId);
            }
        }
    }
}
