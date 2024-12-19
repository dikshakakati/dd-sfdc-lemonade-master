/**
 * @author Deloitte
 * @date 10/30/2023
 * @description Service class implementation for PaymentAccountFieldsValidations.
 */
public inherited sharing class PaymentAccountFieldsValidationsImpl implements IPaymentAccountFieldsValidations {
    private static final String ACCOUNT_BILLING_COUNTRY_CODE_ALIAS = 'accountBillingCountryCode';
    private static final String AUS = 'AUS';
    private static final String BREAK_CHARACTER = ' || ';
    private static final String CA = 'CA';
    private Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
    private static final String PAYMENT_ACCOUNT_ID_ALIAS = 'paymentAccountId';
    private static final Id PAYMENT_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
        .get('Payments')
        .getRecordTypeId();
    private static final String US = 'US';

    /**
     * @description Default constructor for the class
     */
    public PaymentAccountFieldsValidationsImpl() {
        collectCountryAttributes();
    }

    /**
     * @description It is used to validate the payment account field values during update.
     * @JIRA# LEM-10692
     * @param paymentAccounts
     */
    public void validatePaymentAccountFields(List<Payment_Account__c> paymentAccounts) {
        Map<Id, List<String>> paymentAccountIdWithAccountBillingCountryCodes = getPaymentAccountIdWithBillingCountryCode(
            new Map<Id, Payment_Account__c>(paymentAccounts).keySet()
        );
        if (paymentAccountIdWithAccountBillingCountryCodes.isEmpty()) {
            return;
        }
        for (Payment_Account__c eachPaymentAccount : paymentAccounts) {
            if (
                paymentAccountIdWithAccountBillingCountryCodes.containsKey(eachPaymentAccount.Id) &&
                isPaymentAccountAssociatedOnDifferentBillingCountries(
                    eachPaymentAccount.Id,
                    paymentAccountIdWithAccountBillingCountryCodes
                )
            ) {
                eachPaymentAccount.addError(
                    System.Label.Payment_Account_Duplicate_Validation_Message
                );
            } else {
                addErrorOnPaymentAccountForInvalidFieldUpdate(
                    eachPaymentAccount,
                    paymentAccountIdWithAccountBillingCountryCodes
                );
            }
        }
    }

    /**
     * @description It is used to validate the association between account to
     * payment account relation (APAR) with the payment account.
     * @JIRA# LEM-10692
     * @param accountPaymentAccountRelations
     */
    public void validateAccountToPaymentAccountRelation(
        List<Account_Payment_Account_Relation__c> accountPaymentAccountRelations
    ) {
        Map<Id, String> accountsWithBillingCountryCode = new Map<Id, String>();
        Set<Id> associatedAccountId = new Set<Id>();
        Map<Id, List<String>> paymentAccountIdWithAccountBillingCountryCodes = new Map<Id, List<String>>();
        Map<Id, Boolean> paymentAccountsWithInvalidBankAccount = new Map<Id, Boolean>();
        Set<Id> paymentAccountIds = new Set<Id>();

		for (
            Account_Payment_Account_Relation__c eachAccountPaymentAccountRelation : accountPaymentAccountRelations
        ) {
            paymentAccountIds.add(eachAccountPaymentAccountRelation.Payment_Account__c);
            associatedAccountId.add(eachAccountPaymentAccountRelation.Account__c);
        }
        accountsWithBillingCountryCode = getAccountsWithBillingCountryCodes(associatedAccountId);
        paymentAccountIdWithAccountBillingCountryCodes = getPaymentAccountIdWithBillingCountryCode(
            paymentAccountIds
        );
        if (
            paymentAccountIdWithAccountBillingCountryCodes.isEmpty() ||
            accountsWithBillingCountryCode.isEmpty()
        ) {
            return;
        }
        for (
            Payment_Account__c paymentAccount : PaymentAccountsSelector.newInstance()
                .selectById(paymentAccountIds)
        ) {
            if(!paymentAccountIdWithAccountBillingCountryCodes.isEmpty()
               && paymentAccountIdWithAccountBillingCountryCodes.containsKey(paymentAccount.Id)){
                   paymentAccountsWithInvalidBankAccount.put(
                       paymentAccount.Id,
                       validateBankAccountNumber(
                           paymentAccount,
                           paymentAccountIdWithAccountBillingCountryCodes.get(paymentAccount.Id)[0]
                       )
                   );
               }
        }
        validatePaymentAccountAndAccountAssociationOnAPAR(
            accountPaymentAccountRelations,
            paymentAccountIdWithAccountBillingCountryCodes,
            accountsWithBillingCountryCode,
            paymentAccountsWithInvalidBankAccount
        );
    }

    /**
     * @description It is used to show a validation message when an APAR record is associated with
     * a payment account having invalid bank account number.
     * @JIRA# LEM-10692
     * @param paymentAccountsWithInvalidBankAccount
     * @param eachAccountPaymentRelation
     */
    private void addErrorOnAccountPaymentAccountRelationsForInvalidAssociation(
        Map<Id, Boolean> paymentAccountsWithInvalidBankAccount,
        Account_Payment_Account_Relation__c eachAccountPaymentRelation
    ) {
        if (
            paymentAccountsWithInvalidBankAccount.containsKey(
                eachAccountPaymentRelation.Payment_Account__c
            ) &&
            paymentAccountsWithInvalidBankAccount.get(eachAccountPaymentRelation.Payment_Account__c)
        ) {
            eachAccountPaymentRelation.addError(
                System.Label.Non_Eligible_Bank_Account_Number_Validation_Message
            );
        }
    }

    /**
     * @description It is used to show a validation message when a payment account is updated with
     * an invalid field values.
     * @JIRA# LEM-10692
     * @param paymentAccount
     * @param paymentAccountIdWithAccountBillingCountryCodes
     */
    private void addErrorOnPaymentAccountForInvalidFieldUpdate(
        Payment_Account__c paymentAccount,
        Map<Id, List<String>> paymentAccountIdWithAccountBillingCountryCodes
    ) {
        if (!paymentAccountIdWithAccountBillingCountryCodes?.containsKey(paymentAccount.Id)) {
            return;
        }
        String accountBillingCountryCode = paymentAccountIdWithAccountBillingCountryCodes
            ?.get(paymentAccount.Id)[0];
        String errorMessages = '';
        if (validateBankAccountNumber(paymentAccount, accountBillingCountryCode)) {
            errorMessages +=
                System.Label.Non_Eligible_Bank_Account_Number_Validation_Message + BREAK_CHARACTER;
        }
        if (validateInstitutionNumber(paymentAccount, accountBillingCountryCode)) {
            errorMessages +=
                System.Label.Non_Eligible_Institution_Number_Validation_Message + BREAK_CHARACTER;
        }
        if (validateRoutingNumber(paymentAccount, accountBillingCountryCode)) {
            errorMessages += System.Label.Non_Eligible_Routing_Number_Validation_Message;
        }
        if (String.isNotBlank(errorMessages)) {
            paymentAccount.addError(errorMessages.removeEnd(BREAK_CHARACTER));
        }
    }

    /**
     * @description It is used to collect the country attributes mapping metadata records.
     * @JIRA# LEM-10692
     */
    private void collectCountryAttributes() {
        for (
            Country_Attributes_Mapping__mdt eachCountryAttribute : CountryAttributesMappingSelector.newInstance()
                .getAllValues()
        ) {
            this.countryToCountryAttributes.put(
                eachCountryAttribute.Country_Code__c,
                eachCountryAttribute
            );
        }
    }

    /**
     * @description It is used to fetch the associated account on the APAR with the corresponding
     * billing country code.
     * @param associatedAccountId
     * @return Map<Id, String>
     */
    private Map<Id, String> getAccountsWithBillingCountryCodes(Set<Id> associatedAccountId) {
        Map<Id, String> accountsWithBillingCountryCode = new Map<Id, String>();
        for (Account eachAccount : AccountsSelector.newInstance().selectById(associatedAccountId)) {
            accountsWithBillingCountryCode.put(eachAccount.Id, eachAccount.BillingCountryCode);
        }
        return accountsWithBillingCountryCode;
    }

    /**
     * @description It is used to get the count of the APAR object by payment account id and
     * account's billing country code.
     * @JIRA# LEM-10692
     * @param paymentAccountIds
     * @return Map<Id, List<String>>
     */
    private Map<Id, List<String>> getPaymentAccountIdWithBillingCountryCode(
        Set<Id> paymentAccountIds
    ) {
        Map<Id, List<String>> paymentAccountIdWithAccountBillingCountryCodes = new Map<Id, List<String>>();
        for (
            Aggregate eachAggregate : AccountPaymentAccountRelationsSelector.newInstance()
                .selectCountOfAccountPaymentAccountRelationsByAccountBillingCountryCode(
                    paymentAccountIds
                )
        ) {
            if (
                !paymentAccountIdWithAccountBillingCountryCodes.containsKey(
                    (Id) eachAggregate.get(PAYMENT_ACCOUNT_ID_ALIAS)
                )
            ) {
                paymentAccountIdWithAccountBillingCountryCodes.put(
                    (Id) eachAggregate.get(PAYMENT_ACCOUNT_ID_ALIAS),
                    new List<String>{}
                );
            }
            paymentAccountIdWithAccountBillingCountryCodes.get(
                    (Id) eachAggregate.get(PAYMENT_ACCOUNT_ID_ALIAS)
                )
                .add((String) eachAggregate.get(ACCOUNT_BILLING_COUNTRY_CODE_ALIAS));
        }
        return paymentAccountIdWithAccountBillingCountryCodes;
    }

    /**
     * @description It is used to get the restricted starting digits for the routing number field
     * on the payment account.
     * @param accountBillingCountryCode
     * @return Set<String>
     */
    private List<String> getRestrictedDigitsForRoutingNumber(String accountBillingCountryCode) {
        List<String> restrictedDigits = new List<String>();
        return ((String.isNotBlank(
                countryToCountryAttributes.get(accountBillingCountryCode)
                    .Routing_Number_Restricted_Starting_Digit__c
            ))
            ? restrictedDigits = (countryToCountryAttributes.get(accountBillingCountryCode)
                      .Routing_Number_Restricted_Starting_Digit__c)
                  .split(',')
            : new List<String>());
    }

    /**
     * @description It is used to check whether the payment account is associated only to the
     * accounts with the same business country codes.
     * @JIRA# LEM-10692
     * @param paymentAccountId
     * @param paymentAccountIdWithAccountBillingCountryCodes
     * @return Boolean
     */
    private Boolean isPaymentAccountAssociatedOnDifferentBillingCountries(
        Id paymentAccountId,
        Map<Id, List<String>> paymentAccountIdWithAccountBillingCountryCodes
    ) {
        return (paymentAccountIdWithAccountBillingCountryCodes.get(paymentAccountId).size() > 1);
    }

    /**
     * @description It is used to check whether the billing country code of the associated account
     * on the APAR is different.
     * @JIRA# LEM-10692
     * @param paymentAccountId
     * @param associatedAccountId
     * @param paymentAccountIdWithAccountBillingCountryCodes
     * @param accountsWithBillingCountryCode
     * @return Boolean
     */
    private Boolean isBillingCountryCodeOfAssociatedAccountsOnAPARDifferent(
        Id paymentAccountId,
        Id associatedAccountId,
        Map<Id, List<String>> paymentAccountIdWithAccountBillingCountryCodes,
        Map<Id, String> accountsWithBillingCountryCode
    ) {
        return (paymentAccountIdWithAccountBillingCountryCodes.get(paymentAccountId)[0] !=
        accountsWithBillingCountryCode.get(associatedAccountId));
    }

    /**
     * @description It is used to validate the length for routing number on the payment account
     * based on the country code.
     * @param routingNumber
     * @param accountBillingCountryCode
     * @return Boolean
     */
    private Boolean isInvalidLengthForRoutingNumber(
        String routingNumber,
        String accountBillingCountryCode
    ) {
        return (String.isNotBlank(
            countryToCountryAttributes.get(accountBillingCountryCode).Routing_Number_Total_Digits__c
        ) &&
        countryToCountryAttributes.containsKey(accountBillingCountryCode) &&
        (routingNumber.length() !=
        Integer.valueOf(
            countryToCountryAttributes.get(accountBillingCountryCode).Routing_Number_Total_Digits__c
        )));
    }

    /**
     * @description It is used to validate whether the routing number on the payment account
     * is entered with the correct starting digit.
     * @param routingNumber
     * @param accountBillingCountryCode
     * @return Boolean
     */
    private Boolean isInvalidStartingDigitForRoutingNumber(
        String routingNumber,
        String accountBillingCountryCode
    ) {
        Boolean isValidStartingDigit = false;
        List<String> restrictedDigitsForRoutingNumber = getRestrictedDigitsForRoutingNumber(
            accountBillingCountryCode
        );
        for (String eachRestrictedDigit : restrictedDigitsForRoutingNumber) {
            if (routingNumber.startsWith(eachRestrictedDigit)) {
                isValidStartingDigit = true;
                break;
            }
        }
        return isValidStartingDigit;
    }

    /**
     * @description It is used to validate the bank account number on the payment account
     * based on the country code.
     * @param paymentAccount
     * @param accountBillingCountryCode
     * @return Boolean
     */
    private Boolean validateBankAccountNumber(
        Payment_Account__c paymentAccount,
        String accountBillingCountryCode
    ) {
        return (countryToCountryAttributes.containsKey(accountBillingCountryCode) &&
        paymentAccount.RecordTypeId == PAYMENT_RECORD_TYPE_ID &&
        String.isNotBlank(paymentAccount.Bank_Account_Number__c) &&
        (String.isNotBlank(
            countryToCountryAttributes.get(accountBillingCountryCode)
                .Bank_Account_Number_Minimum_Digits__c
        ) &&
        (paymentAccount.Bank_Account_Number__c.length() <
        Integer.valueOf(
            countryToCountryAttributes.get(accountBillingCountryCode)
                .Bank_Account_Number_Minimum_Digits__c
        ))) ||
        (String.isNotBlank(
            countryToCountryAttributes.get(accountBillingCountryCode)
                .Bank_Account_Number_Maximum_Digits__c
        ) &&
        (paymentAccount.Bank_Account_Number__c.length() >
        Integer.valueOf(
            countryToCountryAttributes.get(accountBillingCountryCode)
                .Bank_Account_Number_Maximum_Digits__c
        ))));
    }

    /**
     * @description It is used to validate the institution number on the payment account
     * based on the country code.
     * @param paymentAccount
     * @param accountBillingCountryCode
     * @return Boolean
     */
    private Boolean validateInstitutionNumber(
        Payment_Account__c paymentAccount,
        String accountBillingCountryCode
    ) {
        return (String.isNotBlank(
            countryToCountryAttributes.get(accountBillingCountryCode)
                .Institution_Number_Total_Digits__c
        ) &&
        accountBillingCountryCode == CA &&
        countryToCountryAttributes.containsKey(accountBillingCountryCode) &&
        paymentAccount.RecordTypeId == PAYMENT_RECORD_TYPE_ID &&
        String.isNotBlank(paymentAccount.Institution_Number__c) &&
        (paymentAccount.Institution_Number__c.length() !=
        Integer.valueOf(
            countryToCountryAttributes.get(accountBillingCountryCode)
                .Institution_Number_Total_Digits__c
        )));
    }

    /**
     * @description It is used to validate the association of 'Payment Account' and 'Account' on
     * 'Account To Payment Account Relations' creation.
     * @param accountPaymentAccountRelations
     * @param paymentAccountIdWithAccountBillingCountryCodes
     * @param accountsWithBillingCountryCode
     * @param paymentAccountsWithInvalidBankAccount
     */
    private void validatePaymentAccountAndAccountAssociationOnAPAR(
        List<Account_Payment_Account_Relation__c> accountPaymentAccountRelations,
        Map<Id, List<String>> paymentAccountIdWithAccountBillingCountryCodes,
        Map<Id, String> accountsWithBillingCountryCode,
        Map<Id, Boolean> paymentAccountsWithInvalidBankAccount
    ) {
        for (
            Account_Payment_Account_Relation__c eachAccountPaymentRelation : accountPaymentAccountRelations
        ) {
            if (
                paymentAccountIdWithAccountBillingCountryCodes.containsKey(
                    eachAccountPaymentRelation.Payment_Account__c
                ) &&
                (isPaymentAccountAssociatedOnDifferentBillingCountries(
                    eachAccountPaymentRelation.Payment_Account__c,
                    paymentAccountIdWithAccountBillingCountryCodes
                ) ||
                isBillingCountryCodeOfAssociatedAccountsOnAPARDifferent(
                    eachAccountPaymentRelation.Payment_Account__c,
                    eachAccountPaymentRelation.Account__c,
                    paymentAccountIdWithAccountBillingCountryCodes,
                    accountsWithBillingCountryCode
                ))
            ) {
                eachAccountPaymentRelation.addError(
                    System.Label.Payment_Account_Duplicate_Validation_Message
                );
            } else {
                if (paymentAccountsWithInvalidBankAccount.isEmpty()) {
                    continue;
                }
                addErrorOnAccountPaymentAccountRelationsForInvalidAssociation(
                    paymentAccountsWithInvalidBankAccount,
                    eachAccountPaymentRelation
                );
            }
        }
    }

    /**
     * @description It is used to validate the routing number on the payment account
     * based on the country code.
     * @param paymentAccount
     * @param accountBillingCountryCode
     * @return Boolean
     */
    private Boolean validateRoutingNumber(
        Payment_Account__c paymentAccount,
        String accountBillingCountryCode
    ) {
        return (String.isNotBlank(paymentAccount.RoutingNumber__c) &&
        String.isNotBlank(
            countryToCountryAttributes.get(accountBillingCountryCode).Routing_Number_Total_Digits__c
        ) &&
        paymentAccount.RecordTypeId == PAYMENT_RECORD_TYPE_ID &&
        ((accountBillingCountryCode == US &&
        (isInvalidStartingDigitForRoutingNumber(
            paymentAccount.RoutingNumber__c,
            accountBillingCountryCode
        ) ||
        isInvalidLengthForRoutingNumber(
            paymentAccount.RoutingNumber__c,
            accountBillingCountryCode
        ))) ||
        (accountBillingCountryCode != US &&
        isInvalidLengthForRoutingNumber(
            paymentAccount.RoutingNumber__c,
            accountBillingCountryCode
        ))));
    }
}