/**
 * @author Deloitte
 * @date 02/11/2022
 * @description Service class implementation for ContactsServiceImpl.
 */
public inherited sharing class ContactsServiceImpl implements IContactsService {
    private static final String BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG = 'DOBReadinessCheckCountriesStates';
    private static final String SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG = 'SSNReadinessCheckCountriesStates';
    private static final String COMMA_SEPARATOR = ',';
    private static final String HYPHEN_SEPARATOR = '-';
    private static Set<String> eligibleCountriesStatesToValidateBirthdate;
    private static Set<String> eligibleCountriesStatesToValidateSSN;
    private static final String LOG_SERVICE_UPDATE_CASSIE_ID_BATCH = 'UpdateCassieIdOnLegacyContactsBatch';
    private static final String LOG_DOMAIN_SALES = 'Sales';

    /**
     * @description It is used to initialize the static variables.
     */
    static {
        eligibleCountriesStatesToValidateBirthdate = new Set<String>();
        eligibleCountriesStatesToValidateSSN = new Set<String>();
        collectEligibleCountriesAndStates();
    }
    /**
     * @description This method returns the contact Id with an error message when the contact DOB/SSN values ​​are null and the store's corporate parent
     * having subscriptions to alcohol delivery or alcohol pickup and the store has eligible billing country or billing state.
     * @param accountIdToContacts
     * @return Map<Id, String>
     */
    public Map<Id, String> validateSSNAndBirthdate(Map<Id, List<Contact>> accountIdToContacts) {
        Map<Id, String> contactIdWithErrorMessage = new Map<Id, String>();
        Set<Id> parentAccountIds = new Set<Id>();

        Map<Id, Account> accountIdToStoreAccount = new Map<Id, Account>(
            AccountsSelector.newInstance()
                .getStoreAccountsWithParentCorporate(accountIdToContacts.keyset())
        );
        for (Account eachStoreAccount : accountIdToStoreAccount.values()) {
            parentAccountIds.add(eachStoreAccount.ParentId);
        }
        Set<Id> alcoholSubscribedAccountIds = new Set<Id>();
        for (
            SBQQ__Subscription__c eachSubscription : SubscriptionSelector.newInstance()
                .selectSubscriptionsWithAlcoholProductsByAccountIds(parentAccountIds)
        ) {
            alcoholSubscribedAccountIds.add(eachSubscription.SBQQ__Account__c);
        }
        Account account;
        for (Id accountId : accountIdToContacts.keySet()) {
            if (accountIdToStoreAccount.containsKey(accountId)) {
                account = accountIdToStoreAccount.get(accountId);
                if (!alcoholSubscribedAccountIds.contains(account.ParentId)) {
                    continue;
                }
                for (Contact eachContact : accountIdToContacts.get(accountId)) {
                    if (hasBirthdateValidationFailed(account, eachContact)) {
                        contactIdWithErrorMessage.put(
                            eachContact.Id,
                            System.Label.Birthdate_Error_Message
                        );
                    } else if (hasSSNValidationFailed(account, eachContact)) {
                        contactIdWithErrorMessage.put(
                            eachContact.Id,
                            System.Label.SSN_Last_4Digits_Error_Message
                        );
                    }
                }
            }
        }
        return contactIdWithErrorMessage;
    }

    /**
     * @description It checks whether the passed Account and Contact failed Birthdate null check.
     * @param accountToValidate
     * @param contactToValidate
     * @return Boolean
     */
    private Boolean hasBirthdateValidationFailed(
        Account accountToValidate,
        Contact contactToValidate
    ) {
        return isEligibleCountryAndState(
                accountToValidate,
                eligibleCountriesStatesToValidateBirthdate
            ) && contactToValidate.Birthdate == null;
    }

    /**
     * @description It checks whether the passed Account and Contact failed SSN null check.
     * @param accountToValidate
     * @param contactToValidate
     * @return Boolean
     */
    private Boolean hasSSNValidationFailed(Account accountToValidate, Contact contactToValidate) {
        return isEligibleCountryAndState(accountToValidate, eligibleCountriesStatesToValidateSSN) &&
            contactToValidate.SSN_Last_4Digits__c == null;
    }

    /**
     * @description It checks whether the passed Country and State is eligible for contact Birthdate? SSN_Last_4Digits field validations.
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
            account.BillingCountryCode +
            HYPHEN_SEPARATOR +
            account.BillingStateCode
        );
        if (!isEligible) {
            isEligible = configuredCountriesStates.contains(account.BillingCountryCode);
        }
        return isEligible;
    }
    /**
     * @description It is used to collect eligible countries and states using static configurations
     * for Contact validations.
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
     * @description It is used to to update encrypted Cassie Id fields on  migrated Contacts.
     * @JIRA# LEM-24364
     * @param contactsToUpdate
     */
    public void updateEncryptedCassieIdFieldsOnMigratedContacts(List<Contact> contactsToUpdate) {
        List<Contact> contactsToEncryptedPrimaryEmail = new List<Contact>();
        List<Contact> contactsToEncryptedSecondaryEmail = new List<Contact>();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Contact eachContact : contactsToUpdate) {
            if (eachContact.Email != null && eachContact.Email_Cassie_ID__c == null) {
                contactsToEncryptedPrimaryEmail.add(eachContact);
            }
            if (
                eachContact.Secondary_Email__c != null &&
                eachContact.Secondary_Email_Cassie_ID__c == null
            ) {
                contactsToEncryptedSecondaryEmail.add(eachContact);
            }
        }
        if (!contactsToEncryptedPrimaryEmail.isEmpty()) {
            uow.registerDirty(
                CassieIdEncryptionService.encryptCassieId(
                    contactsToEncryptedPrimaryEmail,
                    'Email',
                    'Email_Cassie_ID__c'
                )
            );
        }
        if (!contactsToEncryptedSecondaryEmail.isEmpty()) {
            uow.registerDirty(
                CassieIdEncryptionService.encryptCassieId(
                    contactsToEncryptedSecondaryEmail,
                    'Secondary_Email__c',
                    'Secondary_Email_Cassie_ID__c'
                )
            );
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE_UPDATE_CASSIE_ID_BATCH,
                        LOG_DOMAIN_SALES,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(ex)
            );
        }
    }
}