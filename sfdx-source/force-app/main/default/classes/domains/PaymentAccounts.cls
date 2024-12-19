/**
 * @author Deloitte
 * @date 10/12/2022
 * @description Domain Class for Payment Account Object
 */
public inherited sharing class PaymentAccounts extends fflib_SObjects implements IPaymentAccounts {
    private static final string PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
        .get('Invoice')
        .getRecordTypeId();
    private static final string PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
        .get('Payments')
        .getRecordTypeId();
    private static final String ENTITY_TYPE_COMPANY = 'Company';
    private static final String NETSUITE_SYNC_STATUS_FAIL = 'Fail';
    private static final String DELIMITER_QUOTES = ',';

    /**
     * @description This method is to return the IPaymentAccounts interface
     * @param recordList - Payment Accounts record list
     * @return IPaymentAccounts - Returns IPaymentAccounts Interface
     */
    public static IPaymentAccounts newInstance(List<Payment_Account__c> recordList) {
        return (IPaymentAccounts) Application.Domain.newInstance(recordList);
    }

    /**
     * @description default constructor for the class
     * @param sObjectList
     */
    public PaymentAccounts(List<Payment_Account__c> sObjectList) {
        super(sObjectList, Schema.Payment_Account__c.SObjectType);
    }

    /**
     * @description This method is used for populating the currency from the Business Account tied to Payment Account
     * @JIRA# LEM-3121
     */
    public void populateCurrencyByBusinessAccount() {
        Map<Id, List<Payment_Account__c>> businessAccountIdWithPaymentAccounts = new Map<Id, List<Payment_Account__c>>();
        for (Payment_Account__c paymentAccount : (List<Payment_Account__c>) getRecords()) {
            if (String.isBlank(paymentAccount.DoorDash_Legal_Entity__c)) {
                paymentAccount.DoorDash_Legal_Entity__c = String.valueOf(
                    paymentAccount.Business_DoorDash_Legal_Entity__c
                );
            }
            if (
                !businessAccountIdWithPaymentAccounts.containsKey(
                    paymentAccount.Business_Account__c
                )
            ) {
                businessAccountIdWithPaymentAccounts.put(
                    paymentAccount.Business_Account__c,
                    new List<Payment_Account__c>()
                );
            }
            businessAccountIdWithPaymentAccounts.get(paymentAccount.Business_Account__c)
                .add(paymentAccount);
        }
        Map<Id, String> mapOfAccountIdToCurrency = new Map<Id, String>();
        for (
            Account account : AccountsSelector.newInstance()
                .selectById(businessAccountIdWithPaymentAccounts.keySet())
        ) {
            mapOfAccountIdToCurrency.put(account.Id, account.CurrencyIsoCode);
        }
        for (Payment_Account__c paymentAccount : (List<Payment_Account__c>) getRecords()) {
            if (
                mapOfAccountIdToCurrency.containsKey(paymentAccount.Business_Account__c) &&
                paymentAccount.RecordTypeId == PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID
            ) {
                paymentAccount.CurrencyIsoCode = mapOfAccountIdToCurrency.get(
                    paymentAccount.Business_Account__c
                );
            }
            paymentAccount.Is_Parent_Account_Merged__c = false;
        }
    }

    /**
     * @description This method is used to auto-sync Invoice Payment Account with NetSuite.
     */
    public void syncWithNetSuite() {
        Set<Id> invoicePaymentAccountIds = getAllEligiblePaymentAccounts(
            (List<Payment_Account__c>) getRecords()
        );
        fflib_ISObjectUnitOfWork uowPaymentAccount = Application.UNITOFWORK.newInstance();
        Map<Id, List<String>> paymentAccountsIdsToErrors = new Map<Id, List<String>>();
        INetSuiteSync nsIntegrator = new NetsuiteIntegratorMiddlewareServiceImpl();
        paymentAccountsIdsToErrors = nsIntegrator.performReadinessCheckValidationsOnMultiplePaymentAccounts(
            invoicePaymentAccountIds
        );
        Set<Id> paymentAccountIdsForSuccess = new Set<Id>(invoicePaymentAccountIds);
        for (Id eachPaymentAccountId : paymentAccountsIdsToErrors.keySet()) {
            if (!paymentAccountsIdsToErrors.get(eachPaymentAccountId).isEmpty()) {
                uowPaymentAccount.registerDirty(
                    new Payment_Account__c(
                        Id = eachPaymentAccountId,
                        NetSuite_Sync_Status__c = NETSUITE_SYNC_STATUS_FAIL,
                        NetSuite_Sync_Response__c = String.join(
                            paymentAccountsIdsToErrors.get(eachPaymentAccountId),
                            DELIMITER_QUOTES
                        )
                    )
                );
                paymentAccountIdsForSuccess.remove(eachPaymentAccountId);
            }
        }
        nsIntegrator.syncWithNetsuite(paymentAccountIdsForSuccess);
        try {
            uowPaymentAccount.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description It is used to fetch all Invoice Payment Accounts by users with auto-sync
     * permission.
     * @param paymentAccounts
     * @return Set<Id>
     */
    private Set<Id> getAllEligiblePaymentAccounts(List<Payment_Account__c> paymentAccounts) {
        Set<Id> paymentAccountIds = new Set<Id>();
        for (Payment_Account__c eachPaymentAccount : paymentAccounts) {
            if (eachPaymentAccount.RecordTypeId == PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID) {
                paymentAccountIds.add(eachPaymentAccount.Id);
            }
        }
        return paymentAccountIds;
    }

    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This method is for implementing constructor in fflib_IDomainConstructor class
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description constructor menthod implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return PaymentAccounts - List of Payment Accounts
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (PaymentAccounts.constructorMock != null) {
                return (fflib_SObjects) PaymentAccounts.constructorMock.construct(objectList);
            }
            return new PaymentAccounts((List<SObject>) objectList);
        }
    }
    /**
     * @description It is used to default Entity type as 'Company' for Payment Record type, if not present.
     * @JIRA# LEM-25466
     */
    public void setEntityTypeForPaymentsRecordType() {
        for (Payment_Account__c eachPaymentAccount : (List<Payment_Account__c>) getRecords()) {
            if (eachPaymentAccount.RecordTypeId == PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID &&
                String.isBlank(eachPaymentAccount.Entity_Type__c)) {
                eachPaymentAccount.Entity_Type__c = ENTITY_TYPE_COMPANY;
            }
        }
    }
}
