/**
 * @author DoorDash
 * @date   10/12/2022
 * @description This is the service interface implementation for Sync with Netsuite implementation
 */
public class NetsuiteIntegratorMiddlewareServiceImpl implements INetsuiteIntegrator, INetSuiteSync {
    private static final String VALIDATION_ERROR_RECORD_TYPE = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_RECORD_TYPE;
    private static final String VALIDATION_ERROR_DOORDASH_LEGAL_ENTITY = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_DDORDASH_LEGAL_ENTITY;
    private static final String VALIDATION_ERROR_BILLING_CONTACT_EMAIL = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_BILLING_CONTACT_EMAIL;
    private static final String VALIDATION_ERROR_NET_SUITE_SYNC_PROCESSES = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_NET_SUITE_SYNC_PROCESSES;
    private static final String VALIDATION_ERROR_COUNTRY_CODE_ALPHA2 = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_COUNTRY_CODE_ALPHA2;
    private static final String VALIDATION_ERROR_ADDRESS = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_ADDRESS;
    private static final String VALIDATION_ERROR_BILL_TO_COMPANY_NAME = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_BILL_TO_COMPANY_NAME;
    private static final String VALIDATION_ERROR_BUSINESS_UNIT = System.Label.PAYMENT_ACCOUNT_VALIDATION_BUSINESS_UNIT;
    private static final String VALIDATION_ERROR_CURRENCY = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_CURRENCY;
    private static final String VALIDATION_ERROR_CURRENCY_BY_LEGAL_ENTITY = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_CURRENCY_BY_LEGAL_ENTITY;
    private static final String VALIDATION_ERROR_PENDING_STATUS = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_PENDING_STATUS;
    private static final String VALIDATION_ERROR_PAYMENT_TERMS = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_PAYMENT_TERMS;
    private static final String ALLOW_SYNC_WITH_NETSUITE = System.Label.SYNC_WITH_NETSUITE_CUSTOM_PERMISSION;
    private static final String VALIDATION_PERMISSION_ISSUE = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_PERMISSION_SET;
    private static final String SUCCESS_MESSAGE = System.Label.SYNC_WITH_MIDDLEWARE_NETSUITE_SUCCESS_MESSAGE;
    private static final String ERROR_MESSAGE = System.Label.SYNC_WITH_NETSUITE_FAILURE;
    private static final String RECORD_TYPE = 'Invoice';
    private static final String EMPTY_VALUE = '';
    private static final String ERROR_KEY = 'error';
    private static final String ID_KEY = 'id';
    private static final String SUCCESS_KEY = 'success';
    private static final String MESSAGE_KEY = 'message';
    private static final String STATUS_KEY = 'status';
    private static final String PENDING_STATUS = 'Pending';
    private static final String CONTRACT_SIGNED = 'Contract Signed';
    private static final Id STORE_RECORD_TYPE_ID;
    private static Map<String, String> legalEntityToCurrency = new Map<String, String>();

    static {
        STORE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
            .get(RECORD_TYPE)
            .getRecordTypeId();
        getLegalEntityMappings();
    }

    Map<String, Object> deserializedResponse = new Map<String, Object>();
    @TestVisible
    private List<String> validationErrors;
    /**
     * @description Call Netsuite Restlet API.
     * @param recordId
     * @return Map<String, Object>
     */
    public Map<String, Object> syncWithNetsuite(String recordId) {
        Boolean publishedEvent = PaymentAccountIntegrationsService.publishPaymentAccountIntegrationEvents(
            new Set<Id>{ recordId }
        );
        if (publishedEvent) {
            updatePaymentAccountNetSuiteSyncStatus(recordId);
            return new Map<String, Object>{
                STATUS_KEY => SUCCESS_KEY,
                MESSAGE_KEY => SUCCESS_MESSAGE
            };
        }
        return new Map<String, Object>{ STATUS_KEY => ERROR_KEY, MESSAGE_KEY => ERROR_MESSAGE };
    }

    /**
     * @description Call Netsuite Restlet API.
     * @param recordIds
     */
    public void syncWithNetsuite(Set<Id> recordIds) {
        Boolean publishedEvent = PaymentAccountIntegrationsService.publishPaymentAccountIntegrationEvents(
            recordIds
        );
        if (publishedEvent) {
            updatePaymentAccountsNetSuiteSyncStatus(recordIds);
        }
    }

    /**
     * @description returns Map of Payment Record Id with Readiness Message for netSuiteIntegration
     * with synchronous call.
     * @param paymentAccountIds
     * @return Map<Id, List<String>>
     */
    public Map<Id, List<String>> performReadinessCheckValidationsOnMultiplePaymentAccounts(
        Set<Id> paymentAccountIds
    ) {
        Map<Id, List<String>> paymentAccountToValidationErrors = new Map<Id, List<String>>();
        List<Payment_Account__c> paymentAccounts = PaymentAccountsSelector.newInstance()
            .selectById(paymentAccountIds);
        for (Payment_Account__c eachPaymentAccount : paymentAccounts) {
            paymentAccountToValidationErrors.put(
                eachPaymentAccount.Id,
                readinessCheckValidationMessage(eachPaymentAccount)
            );
        }
        return paymentAccountToValidationErrors;
    }

    /**
     * @description returns Map of Payment Record Id with Readiness Message for netSuiteIntegration with synchronous call.
     * @param paymentAccountId
     * @return List<String>
     */
    public List<String> performReadinessCheckValidations(Id paymentAccountId) {
        Payment_Account__c paymentAccount = PaymentAccountsSelector.newInstance()
            .selectById(new Set<Id>{ paymentAccountId })
            .get(0);
        return readinessCheckValidationMessage(paymentAccount);
    }

    /**
     * @description returns list of rediness failure messages.
     * @param paymentAccount
     * @return List<String>
     */
    private List<String> readinessCheckValidationMessage(Payment_Account__c paymentAccount) {
        validationErrors = new List<String>();
        if (!FeatureManagementService.newInstance().checkPermission(ALLOW_SYNC_WITH_NETSUITE)) {
            validationErrors.add(VALIDATION_PERMISSION_ISSUE);
            return validationErrors;
        }
        if (paymentAccount?.recordTypeId != STORE_RECORD_TYPE_ID) {
            validationErrors.add(VALIDATION_ERROR_RECORD_TYPE);
            return validationErrors;
        }
        if (paymentAccount?.NetSuite_Sync_Status__c == PENDING_STATUS) {
            validationErrors.add(VALIDATION_ERROR_PENDING_STATUS);
            return validationErrors;
        }
        validateDoorDashPaymentTerms(paymentAccount);
        validateDoorDashLegalEntity(paymentAccount);
        validateBillingContactEmail(paymentAccount);
        validateBillToCompanyName(paymentAccount);
        validateBusinessUnit(paymentAccount);
        validateCurrency(paymentAccount);
        validateCurrencyByDoorDashLegalEntity(paymentAccount);
        validateAddress(paymentAccount);
        validateCountryAlpha2(paymentAccount);
        return validationErrors;
    }

    /**
     * @description validate Payment Terms field in Payment_Account__c object.
     * @param paymentAccount
     */
    @TestVisible
    private void validateDoorDashPaymentTerms(Payment_Account__c paymentAccount) {
        if (String.isBlank(paymentAccount?.Payment_Terms__c)) {
            validationErrors.add(VALIDATION_ERROR_PAYMENT_TERMS);
        }
    }

    /**
     * @description validate DoorDash legal Entity field in Payment_Account__c object.
     * @param paymentAccount
     */
    @TestVisible
    private void validateDoorDashLegalEntity(Payment_Account__c paymentAccount) {
        if (String.isBlank(paymentAccount?.DoorDash_Legal_Entity__c)) {
            validationErrors.add(VALIDATION_ERROR_DOORDASH_LEGAL_ENTITY);
        }
    }

    /**
     * @description validate Billing Contact Email field in Payment_Account__c object.
     * @param paymentAccount
     */
    @TestVisible
    private void validateBillingContactEmail(Payment_Account__c paymentAccount) {
        if (String.isBlank(paymentAccount?.Billing_Contact_Email__c)) {
            validationErrors.add(VALIDATION_ERROR_BILLING_CONTACT_EMAIL);
        }
    }

    /**
     * @description validate Billing Company Name field in Payment_Account__c object.
     * @param paymentAccount
     */
    @TestVisible
    private void validateBillToCompanyName(Payment_Account__c paymentAccount) {
        if (String.isBlank(paymentAccount?.Bill_To_Company_Name__c)) {
            validationErrors.add(VALIDATION_ERROR_BILL_TO_COMPANY_NAME);
        }
    }

    /**
     * @description validate Country Alpha2 field in Payment_Account__c object.
     * @param paymentAccount
     */
    @TestVisible
    private void validateCountryAlpha2(Payment_Account__c paymentAccount) {
        if (String.isBlank(paymentAccount?.Country_Code_Alpha_2__c)) {
            validationErrors.add(VALIDATION_ERROR_COUNTRY_CODE_ALPHA2);
        }
    }

    /**
     * @description validate Address(Address_Line_1, State, City, Postal code) field in Payment_Account__c object.
     * @param paymentAccount
     */
    @TestVisible
    private void validateAddress(Payment_Account__c paymentAccount) {
        if (
            String.isBlank(paymentAccount?.Address_Line_1__c) ||
            String.isBlank(paymentAccount.State__c) ||
            String.isBlank(paymentAccount.City__c) ||
            String.isBlank(paymentAccount.Postal_Code__c)
        ) {
            validationErrors.add(VALIDATION_ERROR_ADDRESS);
        }
    }

    /**
     * @description validate Brand field in Payment_Account__c object.
     * @param paymentAccount
     */
    @TestVisible
    private void validateBusinessUnit(Payment_Account__c paymentAccount) {
        if (String.isBlank(paymentAccount?.Business_Unit__c)) {
            validationErrors.add(VALIDATION_ERROR_BUSINESS_UNIT);
        }
    }

    /**
     * @description validate Currency field in Payment_Account__c object.
     * @param paymentAccount
     */
    @TestVisible
    private void validateCurrency(Payment_Account__c paymentAccount) {
        if (String.isBlank(paymentAccount?.CurrencyIsoCode)) {
            validationErrors.add(VALIDATION_ERROR_CURRENCY);
        }
    }

    /**
     * @description Validate Currency Code based on DoorDash Legal Entity
     * of Payment_Account__c object.
     * @param paymentAccount
     */
    @TestVisible
    private void validateCurrencyByDoorDashLegalEntity(Payment_Account__c paymentAccount) {
        if (
            paymentAccount.CurrencyIsoCode !=
            legalEntityToCurrency.get(paymentAccount.DoorDash_Legal_Entity__c)
        ) {
            validationErrors.add(VALIDATION_ERROR_CURRENCY_BY_LEGAL_ENTITY);
        }
    }

    /**
     * @description Update NetSuite Sync Status With Pending on post
     * successfully published platform event.
     * @param paymentAccountId - Payment Account RecordId
     */
    @TestVisible
    private void updatePaymentAccountNetSuiteSyncStatus(Id paymentAccountId) {
        fflib_ISobjectUnitOfWork uow;
        if (paymentAccountId != null) {
            uow = Application.UnitOfWork.newInstance();
            uow.registerDirty(
                new Payment_Account__c(
                    Id = paymentAccountId,
                    NetSuite_Sync_Status__c = PENDING_STATUS,
                    Netsuite_Sync_Initiator__c = UserInfo.getUserId(),
                    NetSuite_Sync_Response__c = EMPTY_VALUE
                )
            );
            try {
                uow.commitWork();
            } catch (Exception ex) {
                Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            }
        }
    }

    /**
     * @description Update NetSuite Sync Status With Pending on post
     * successfully published platform event.
     * @param paymentAccountIds - Payment Account RecordId
     */
    @TestVisible
    private void updatePaymentAccountsNetSuiteSyncStatus(Set<Id> paymentAccountIds) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Id eachPaymentAccountId : paymentAccountIds) {
            if (eachPaymentAccountId != null) {
                uow.registerDirty(
                    new Payment_Account__c(
                        Id = eachPaymentAccountId,
                        NetSuite_Sync_Status__c = PENDING_STATUS,
                        Netsuite_Sync_Initiator__c = UserInfo.getUserId(),
                        NetSuite_Sync_Response__c = EMPTY_VALUE
                    )
                );
            }
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description To get map of Currency ISO Code to Legal Entity Name.
     */
    private static void getLegalEntityMappings() {
        for (
            Legal_Entity_Mapping__mdt eachLegalEntityMapping : LegalEntityMappingSelector.newInstance()
                .getAllValues()
        ) {
            legalEntityToCurrency.put(
                eachLegalEntityMapping.Legal_Entity_Name__c,
                eachLegalEntityMapping.Currency_ISO_Code__c
            );
        }
    }
}