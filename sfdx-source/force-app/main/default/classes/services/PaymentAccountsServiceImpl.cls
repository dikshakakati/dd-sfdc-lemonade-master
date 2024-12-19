/**
 * @author Deloitte
 * @date 10/07/2022
 * @description This is the service class implementation for Payment Account related functionality.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class PaymentAccountsServiceImpl implements IPaymentAccountsService {
    private static final String BANK_ACCOUNT_NUMBER_FIELD_API_NAME = 'Bank_Account_Number__c';
    private static final String DRIVE = 'Drive';
    private static final String LOG_SERVICE_PAYMENT_ACCOUNT = 'Payment Accounts Service';
    private static final String LOG_DOMAIN_PAYMENT_ACCOUNTS_CREATION = 'Payment Accounts Creation';
    private static final String MARKETPLACE_PRODUCT = 'Marketplace';
    private static final String ONBOARDING_SCENARIO_PRODUCT_ADDITION = 'Product Addition';
    private static final String PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE = 'Invoice';
    private static final String PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE = 'Payments';
    private static final String PAYMENT_METHOD_INVOICING = 'Invoicing';
    private static final String PLUS_KEY = '+';
    private static final String PLUS_SPLIT = '\\+';
    private static final String SEMICOLON_KEY = ';';
    private static final String SEMICOLON_SPLIT = '\\;';
    private static final String SEPARATOR = System.Label.Separator;
    private static final Id PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID;
    private static final Id PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID;
    private static Set<String> bankAccountNumbers;
    private static Set<Id> businessAccountIds;
    private static Map<Id, List<Business_Onboarding_Detail__c>> driveInvoiceMxs;
    Map<Id, List<Business_Onboarding_Detail__c>> driveWithholdingMxs;
    private static Map<Id, List<Store_Detail__c>> marketplaceMxs;
    private static Map<Id, BusinessAccountWrapper> mxBusinessAccountDetails;
    private static Set<String> mxOnboardingLinkIds;
    private static Map<Id, StoreDetailsWrapper> mxStoreAccountDetails;

    static {
        PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
            .get(PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE)
            .getRecordTypeId();
        PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
            .get(PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE)
            .getRecordTypeId();
    }

    /**
     * @description Default Constructor to initialize class variables.
     */
    public PaymentAccountsServiceImpl() {
        bankAccountNumbers = new Set<String>();
        businessAccountIds = new Set<Id>();
        driveInvoiceMxs = new Map<Id, List<Business_Onboarding_Detail__c>>();
        driveWithholdingMxs = new Map<Id, List<Business_Onboarding_Detail__c>>();
        marketplaceMxs = new Map<Id, List<Store_Detail__c>>();
        mxBusinessAccountDetails = new Map<Id, BusinessAccountWrapper>();
        mxOnboardingLinkIds = new Set<String>();
        mxStoreAccountDetails = new Map<Id, StoreDetailsWrapper>();
    }

    /**
     * @description It creates Payment Accounts for the Business/Store Accounts received
     * with Mx Onboarding details.
     * @JIRA# LEM-15113
     * @param mxOnboardingLinks
     * @param mxBusinessAccountWrappers
     * @param mxStoreAccountWrappers
     */
    public void createPaymentAccountsByMxOnboardingLinks(
        List<Mx_Onboarding_Link__c> mxOnboardingLinks,
        Map<Id, BusinessAccountWrapper> mxBusinessAccountWrappers,
        Map<Id, StoreDetailsWrapper> mxStoreAccountWrappers
    ) {
        if (mxOnboardingLinks.isEmpty()) {
            return;
        }
        mxBusinessAccountDetails = mxBusinessAccountWrappers;
        mxStoreAccountDetails = mxStoreAccountWrappers;
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        Map<String, Payment_Account__c> existingPaymentAccounts = new Map<String, Payment_Account__c>();
        Map<String, Payment_Account__c> existingInvoicePaymentAccounts = new Map<String, Payment_Account__c>();
        Map<String, Account> storeAccountsByAddress = new Map<String, Account>();
        Map<String, Contact> contactsByEmailId = new Map<String, Contact>();
        collectOnboardingDetailsByOnboardingScenarioAndProducts(mxOnboardingLinks);
        existingPaymentAccounts = collectExistingPaymentAccounts(bankAccountNumbers);
        existingInvoicePaymentAccounts = collectExistingInvoicePaymentAccounts(
            driveInvoiceMxs.keySet()
        );
        storeAccountsByAddress = collectStoreAccounts(mxOnboardingLinkIds);
        contactsByEmailId = collectBillingContacts(businessAccountIds);
        createPaymentAccountsForMarketplaceMxs(
            contactsByEmailId,
            existingPaymentAccounts,
            marketplaceMxs,
            storeAccountsByAddress,
            unitOfWork
        );
        createPaymentAccountsForDriveWithholdingMxs(
            contactsByEmailId,
            existingPaymentAccounts,
            driveWithholdingMxs,
            unitOfWork
        );
        createPaymentAccountsForDriveInvoiceMxs(
            contactsByEmailId,
            existingInvoicePaymentAccounts,
            driveInvoiceMxs,
            unitOfWork
        );
        unitOfWork.commitWork();
    }

    /**
     * @description To process merged account child records
     * @param paymentAccounts
     */
    public void processMergedAccountsRelatedRecords(List<Payment_Account__c> paymentAccounts) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Payment_Account__c eachPaymentAccount : paymentAccounts) {
            eachPaymentAccount.Is_Parent_Account_Merged__c = true;
            uow.registerDirty(eachPaymentAccount);
        }
        commitWork(uow);
    }

    /**
     * @description Update Payment Account record for selected record Id.
     * @param paymentAccountRecord - Payment Account RecordId
     */
    public void updatePaymentAccountWithSyncWithNetsuiteResponse(
        Payment_Account__c paymentAccountRecord
    ) {
        fflib_ISObjectUnitOfWork paymentAccountUOW = Application.UNITOFWORK.newInstance();
        paymentAccountUOW.registerDirty(paymentAccountRecord);
        commitWork(paymentAccountUOW);
    }

    /**
     * @description It collects the Bank Account Numbers to check Payment Accounts exists already
     * based on passed Business/Store Onboarding Details.
     * @JIRA# LEM-15113
     * @param onboardingDetails
     * @return Set<String>
     */
    private Set<String> collectBankAccountNumbersFromOnboardingDetails(
        List<SObject> onboardingDetails
    ) {
        Set<String> bankAccountNumbers = new Set<String>();
        if (onboardingDetails.isEmpty()) {
            return bankAccountNumbers;
        }
        for (SObject eachOnboardingDetail : onboardingDetails) {
            if (!isNullOrBlank(eachOnboardingDetail.get(BANK_ACCOUNT_NUMBER_FIELD_API_NAME))) {
                bankAccountNumbers.add(
                    (String) eachOnboardingDetail.get(BANK_ACCOUNT_NUMBER_FIELD_API_NAME)
                );
            }
        }
        return bankAccountNumbers;
    }

    /**
     * @description It collects the existing Contacts based on Business Account Ids.
     * @JIRA# LEM-15113
     * @param businessAccountIds
     * @return Map<String, Contact>
     */
    private Map<String, Contact> collectBillingContacts(Set<Id> businessAccountIds) {
        Map<String, Contact> existingContacts = new Map<String, Contact>();
        Set<String> contactFirstNames = new Set<String>();
        Set<String> contactLastNames = new Set<String>();
        Set<String> contactEmails = new Set<String>();
        collectContactDetailsForMarketplaceMxs(contactFirstNames, contactLastNames, contactEmails);
        collectContactDetailsForDriveWithholdingsMxs(
            contactFirstNames,
            contactLastNames,
            contactEmails
        );
        collectContactDetailsForDriveInvoiceMxs(contactFirstNames, contactLastNames, contactEmails);
        String key;
        for (
            Contact eachContact : ContactsSelector.newInstance()
                .selectContactByEmailFirstNameLastName(
                    contactFirstNames,
                    contactLastNames,
                    contactEmails
                )
        ) {
            key =
                String.valueOf(eachContact.Email) +
                SEPARATOR +
                (isNullOrBlank(eachContact.FirstName)
                    ? eachContact.FirstName
                    : eachContact.FirstName.toLowerCase()) +
                SEPARATOR +
                (isNullOrBlank(eachContact.LastName)
                    ? eachContact.LastName
                    : eachContact.LastName.toLowerCase());
            existingContacts.put(key, eachContact);
        }
        return existingContacts;
    }

    /**
     * @description It is used to collect Contact details to be queried for Marketplace Mxs.
     * @JIRA# LEM-15113
     * @param contactFirstNames
     * @param contactLastNames
     * @param contactEmails
     */
    private void collectContactDetailsForMarketplaceMxs(
        Set<String> contactFirstNames,
        Set<String> contactLastNames,
        Set<String> contactEmails
    ) {
        StoreDetailsWrapper newStoreAccountDetails;
        for (Id eachBusinessAccountId : marketplaceMxs.keySet()) {
            for (Store_Detail__c eachStoreDetail : marketplaceMxs.get(eachBusinessAccountId)) {
                if (mxStoreAccountDetails.containsKey(eachStoreDetail.Id)) {
                    newStoreAccountDetails = mxStoreAccountDetails.get(eachStoreDetail.Id);
                    if (!isNullOrBlank(newStoreAccountDetails.representativeFirstName)) {
                        contactFirstNames.add(newStoreAccountDetails.representativeFirstName);
                    }
                    if (!isNullOrBlank(newStoreAccountDetails.representativeLastName)) {
                        contactLastNames.add(newStoreAccountDetails.representativeLastName);
                    }
                    if (!isNullOrBlank(newStoreAccountDetails.representativeEmail)) {
                        contactEmails.add(newStoreAccountDetails.representativeEmail);
                    }
                }
            }
        }
    }

    /**
     * @description It is used to collect Contact details to be queried for Drive Witholding Mxs.
     * @JIRA# LEM-15113
     * @param contactFirstNames
     * @param contactLastNames
     * @param contactEmails
     */
    private void collectContactDetailsForDriveWithholdingsMxs(
        Set<String> contactFirstNames,
        Set<String> contactLastNames,
        Set<String> contactEmails
    ) {
        BusinessAccountWrapper newBusinessAccountDetails;
        for (Id eachBusinessAccountId : driveWithholdingMxs.keySet()) {
            for (
                Business_Onboarding_Detail__c eachBusinessOnboardingDetail : driveWithholdingMxs.get(
                    eachBusinessAccountId
                )
            ) {
                if (mxBusinessAccountDetails.containsKey(eachBusinessOnboardingDetail.Id)) {
                    newBusinessAccountDetails = mxBusinessAccountDetails.get(
                        eachBusinessOnboardingDetail.Id
                    );
                    if (!isNullOrBlank(newBusinessAccountDetails.representativeFirstName)) {
                        contactFirstNames.add(newBusinessAccountDetails.representativeFirstName);
                    }
                    if (!isNullOrBlank(newBusinessAccountDetails.representativeLastName)) {
                        contactLastNames.add(newBusinessAccountDetails.representativeLastName);
                    }
                    if (!isNullOrBlank(newBusinessAccountDetails.representativeEmail)) {
                        contactEmails.add(newBusinessAccountDetails.representativeEmail);
                    }
                }
            }
        }
    }

    /**
     * @description It is used to collect Contact details to be queried for Drive Invoicing Mxs.
     * @JIRA# LEM-15113
     * @param contactFirstNames
     * @param contactLastNames
     * @param contactEmails
     */
    private void collectContactDetailsForDriveInvoiceMxs(
        Set<String> contactFirstNames,
        Set<String> contactLastNames,
        Set<String> contactEmails
    ) {
        BusinessAccountWrapper newBusinessAccountDetails;
        for (Id eachBusinessAccountId : driveInvoiceMxs.keySet()) {
            for (
                Business_Onboarding_Detail__c eachBusinessOnboardingDetail : driveInvoiceMxs.get(
                    eachBusinessAccountId
                )
            ) {
                if (mxBusinessAccountDetails.containsKey(eachBusinessOnboardingDetail.Id)) {
                    newBusinessAccountDetails = mxBusinessAccountDetails.get(
                        eachBusinessOnboardingDetail.Id
                    );
                    if (!isNullOrBlank(newBusinessAccountDetails.billingContactFirstName)) {
                        contactFirstNames.add(newBusinessAccountDetails.billingContactFirstName);
                    }
                    if (!isNullOrBlank(newBusinessAccountDetails.billingContactLastName)) {
                        contactLastNames.add(newBusinessAccountDetails.billingContactLastName);
                    }
                    if (!isNullOrBlank(newBusinessAccountDetails.billingContactEmail)) {
                        contactEmails.add(newBusinessAccountDetails.billingContactEmail);
                    }
                }
            }
        }
    }

    /**
     * @description It collects Business Onboarding Details based on Drive Products
     * added to the Contract.
     * @JIRA# LEM-15113
     * @param mxOnboardingLink
     * @param paymentMethodOnContract
     */
    private void collectDriveScenarioDetails(
        Mx_Onboarding_Link__c mxOnboardingLink,
        String paymentMethodOnContract
    ) {
        if (paymentMethodOnContract == PAYMENT_METHOD_INVOICING) {
            driveInvoiceMxs.put(
                mxOnboardingLink.Business_Account__c,
                mxOnboardingLink.Business_Onboarding_Details__r
            );
        } else {
            driveWithholdingMxs.put(
                mxOnboardingLink.Business_Account__c,
                mxOnboardingLink.Business_Onboarding_Details__r
            );
        }
        bankAccountNumbers.addAll(
            collectBankAccountNumbersFromOnboardingDetails(
                mxOnboardingLink.Business_Onboarding_Details__r
            )
        );
    }

    /**
     * @description It collects the existing Invoice Payment Accounts based on Business Account Ids.
     * @JIRA# LEM-15113
     * @param businessAccountIds
     * @return Map<String, Payment_Account__c>
     */
    private Map<String, Payment_Account__c> collectExistingInvoicePaymentAccounts(
        Set<Id> businessAccountIds
    ) {
        Map<String, Payment_Account__c> existingPaymentAccounts = new Map<String, Payment_Account__c>();
        for (
            Payment_Account__c eachPaymentAccount : PaymentAccountsSelector.newInstance()
                .selectRelatedBusinessAccounts(businessAccountIds)
        ) {
            existingPaymentAccounts.put(
                String.valueOf(eachPaymentAccount.Address_Line_1__c) +
                    SEPARATOR +
                    String.valueOf(eachPaymentAccount.City__c) +
                    SEPARATOR +
                    String.valueOf(eachPaymentAccount.State__c) +
                    SEPARATOR +
                    String.valueOf(eachPaymentAccount.Postal_Code__c) +
                    SEPARATOR +
                    String.valueOf(eachPaymentAccount.Country__c),
                eachPaymentAccount
            );
        }
        return existingPaymentAccounts;
    }

    /**
     * @description It collects the existing Payment Accounts based on Bank Account Numbers.
     * @JIRA# LEM-15113
     * @param bankAccountNumbers
     * @return Map<String, Payment_Account__c>
     */
    private Map<String, Payment_Account__c> collectExistingPaymentAccounts(
        Set<String> bankAccountNumbers
    ) {
        Map<String, Payment_Account__c> existingPaymentAccounts = new Map<String, Payment_Account__c>();
        /*for (
            Payment_Account__c eachPaymentAccount : PaymentAccountsSelector.newInstance()
                .selectByBankAccountNumbers(bankAccountNumbers)
        ) {
            existingPaymentAccounts.put(
                String.valueOf(eachPaymentAccount.Bank_Account_Number__c) +
                    SEPARATOR +
                    String.valueOf(eachPaymentAccount.RoutingNumber__c),
                eachPaymentAccount
            );
        }*/
        return existingPaymentAccounts;
    }

    /**
     * @description It collects Store Onboarding Details based on Marketplace Products
     * added to the Contract.
     * @JIRA# LEM-15113
     * @param mxOnboardingLink
     */
    private void collectMarketplaceScenarioDetails(Mx_Onboarding_Link__c mxOnboardingLink) {
        if (!marketplaceMxs.containsKey(mxOnboardingLink.Business_Account__c)) {
            marketplaceMxs.put(mxOnboardingLink.Business_Account__c, new List<Store_Detail__c>());
        }
        marketplaceMxs.get(mxOnboardingLink.Business_Account__c)
            .addAll(mxOnboardingLink.Store_Details__r);
        bankAccountNumbers.addAll(
            collectBankAccountNumbersFromOnboardingDetails(mxOnboardingLink.Store_Details__r)
        );
    }

    /**
     * @description It collects Business/Store Onboarding Details based on Onboarding Scenario
     * and Products added to the Contract.
     * @JIRA# LEM-15113
     * @param mxOnboardingLinks
     */
    private void collectOnboardingDetailsByOnboardingScenarioAndProducts(
        List<Mx_Onboarding_Link__c> mxOnboardingLinks
    ) {
        String onboardingScenario = '';
        String paymentMethodOnContract = '';
        String productOnContract = '';
        OIFormPayloadWrapper newOIFormPayloadDetails;
        List<String> productsOnContract = new List<String>();
        for (Mx_Onboarding_Link__c eachMxOnboardingLink : mxOnboardingLinks) {
            if (
                isNullOrBlank(eachMxOnboardingLink.Onboarding_Scenario__c) ||
                isNullOrBlank(eachMxOnboardingLink.Product_on_Contract__c)
            ) {
                continue;
            }
            businessAccountIds.add(eachMxOnboardingLink.Business_Account__c);
            mxOnboardingLinkIds.add(eachMxOnboardingLink.UUID__c);
            onboardingScenario = eachMxOnboardingLink.Onboarding_Scenario__c;
            productOnContract = eachMxOnboardingLink.Product_on_Contract__c;
            newOIFormPayloadDetails = (OIFormPayloadWrapper) JSON.deserialize(
                eachMxOnboardingLink.Payload__c,
                OIFormPayloadWrapper.class
            );
            paymentMethodOnContract = newOIFormPayloadDetails.paymentMethod;
            productOnContract = productOnContract.deleteWhitespace();
            if (productOnContract.contains(PLUS_KEY)) {
                productsOnContract = productOnContract.split(PLUS_SPLIT);
            } else if (productOnContract.contains(SEMICOLON_KEY)) {
                productsOnContract = productOnContract.split(SEMICOLON_SPLIT);
            } else {
                productsOnContract = new List<String>{ productOnContract };
            }
            if (productsOnContract.contains(MARKETPLACE_PRODUCT)) {
                collectMarketplaceScenarioDetails(eachMxOnboardingLink);
            }
            if (productsOnContract.contains(DRIVE)) {
                collectDriveScenarioDetails(eachMxOnboardingLink, paymentMethodOnContract);
            }
        }
    }

    /**
     * @description It collects the existing Store Accounts based on Mx Onboarding Link Ids.
     * @JIRA# LEM-15113
     * @param mxOnboardingLinkIds
     * @return Map<String, Account>
     */
    private Map<String, Account> collectStoreAccounts(Set<String> mxOnboardingLinkIds) {
        Map<String, Account> existingAccounts = new Map<String, Account>();
        for (
            Account eachAccount : AccountsSelector.newInstance()
                .selectAccountsByMxOnboardingLinkIds(mxOnboardingLinkIds)
        ) {
            existingAccounts.put(String.valueOf(eachAccount.Store_Details__c), eachAccount);
        }
        return existingAccounts;
    }

    /**
     * @description A common method to commit unit of work.
     * @param unitOfWork
     */
    private static void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_PAYMENT_ACCOUNT,
                        LOG_DOMAIN_PAYMENT_ACCOUNTS_CREATION,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(unitOfWorkException)
            );
        }
    }

    /**
     * @description It creates Payment Accounts and Account to Payment Account Relation
     * for Drive Invoice Mxs.
     * @JIRA# LEM-15113
     * @param contactsByEmailId
     * @param existingPaymentAccounts
     * @param driveInvoiceMxs
     * @param unitOfWork
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    private void createPaymentAccountsForDriveInvoiceMxs(
        Map<String, Contact> contactsByEmailId,
        Map<String, Payment_Account__c> existingPaymentAccounts,
        Map<Id, List<Business_Onboarding_Detail__c>> driveInvoiceMxs,
        fflib_ISObjectUnitOfWork unitOfWork
    ) {
        if (driveInvoiceMxs.isEmpty()) {
            return;
        }
        Id billingContactId;
        String paymentAccountUniqueKey = '';
        Payment_Account__c newPaymentAccount;
        BusinessAccountWrapper newBusinessAccountDetails;
        Map<String, Payment_Account__c> newPaymentAccounts = new Map<String, Payment_Account__c>();
        Set<Id> processedBusinessAccountIds = new Set<Id>();
        for (Id eachBusinessAccountId : driveInvoiceMxs.keySet()) {
            for (
                Business_Onboarding_Detail__c eachBusinessOnboardingDetail : driveInvoiceMxs.get(
                    eachBusinessAccountId
                )
            ) {
                if (
                    !mxBusinessAccountDetails.containsKey(eachBusinessOnboardingDetail.Id) ||
                    processedBusinessAccountIds.contains(eachBusinessAccountId)
                ) {
                    continue;
                }
                newBusinessAccountDetails = mxBusinessAccountDetails.get(
                    eachBusinessOnboardingDetail.Id
                );
                if (validateBusinessDetailsAddress(newBusinessAccountDetails)) {
                    continue;
                }
                String key = generateContactKeyByBusinessDetailsBillingContact(
                    newBusinessAccountDetails
                );
                if (contactsByEmailId.containsKey(key)) {
                    billingContactId = contactsByEmailId.get(key).Id;
                }
                newPaymentAccount = new Payment_Account__c();
                paymentAccountUniqueKey =
                    String.valueOf(newBusinessAccountDetails.paymentStreet) +
                    SEPARATOR +
                    String.valueOf(newBusinessAccountDetails.paymentCity) +
                    SEPARATOR +
                    String.valueOf(newBusinessAccountDetails.paymentStateCode) +
                    SEPARATOR +
                    String.valueOf(newBusinessAccountDetails.paymentZipPostalCode) +
                    SEPARATOR +
                    String.valueOf(newBusinessAccountDetails.paymentCountry);
                if (existingPaymentAccounts.containsKey(paymentAccountUniqueKey)) {
                    unitOfWork.registerNew(
                        new Account_Payment_Account_Relation__c(
                            Account__c = eachBusinessAccountId,
                            Payment_Account__c = existingPaymentAccounts.get(
                                    paymentAccountUniqueKey
                                )
                                .Id
                        )
                    );
                    processedBusinessAccountIds.add(eachBusinessAccountId);
                } else if (
                    newPaymentAccounts.containsKey(
                        String.valueOf(eachBusinessAccountId) + SEPARATOR + paymentAccountUniqueKey
                    )
                ) {
                    unitOfWork.registerNew(
                        new Account_Payment_Account_Relation__c(Account__c = eachBusinessAccountId),
                        Account_Payment_Account_Relation__c.Payment_Account__c,
                        newPaymentAccounts.get(
                            String.valueOf(eachBusinessAccountId) +
                                SEPARATOR +
                                paymentAccountUniqueKey
                        )
                    );
                    processedBusinessAccountIds.add(eachBusinessAccountId);
                } else {
                    newPaymentAccount = new Payment_Account__c(
                        Address_Line_1__c = newBusinessAccountDetails.paymentStreet,
                        Bill_To_Company_Name__c = newBusinessAccountDetails.Name,
                        Business_Account__c = eachBusinessAccountId,
                        Business_Unit__c = DRIVE,
                        City__c = newBusinessAccountDetails.paymentCity,
                        Country__c = newBusinessAccountDetails.paymentCountry,
                        Postal_Code__c = newBusinessAccountDetails.paymentZipPostalCode,
                        State__c = newBusinessAccountDetails.paymentStateCode,
                        Billing_Contact_Name__c = billingContactId,
                        RecordTypeId = PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID
                    );
                    unitOfWork.registerNew(newPaymentAccount);
                    unitOfWork.registerNew(
                        new Account_Payment_Account_Relation__c(Account__c = eachBusinessAccountId),
                        Account_Payment_Account_Relation__c.Payment_Account__c,
                        newPaymentAccount
                    );
                    newPaymentAccounts.put(
                        String.valueOf(eachBusinessAccountId) + SEPARATOR + paymentAccountUniqueKey,
                        newPaymentAccount
                    );
                    processedBusinessAccountIds.add(eachBusinessAccountId);
                }
                billingContactId = null;
                paymentAccountUniqueKey = '';
            }
        }
    }

    /**
     * @description It creates Payment Accounts and Account to Payment Account Relation
     * for Drive Withholding Mxs.
     * @JIRA# LEM-15113
     * @param contactsByEmailId
     * @param existingPaymentAccounts
     * @param driveWithholdingMxs
     * @param unitOfWork
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    private void createPaymentAccountsForDriveWithholdingMxs(
        Map<String, Contact> contactsByEmailId,
        Map<String, Payment_Account__c> existingPaymentAccounts,
        Map<Id, List<Business_Onboarding_Detail__c>> driveWithholdingMxs,
        fflib_ISObjectUnitOfWork unitOfWork
    ) {
        if (driveWithholdingMxs.isEmpty()) {
            return;
        }
        Id billingContactId;
        String paymentAccountUniqueKey = '';
        Payment_Account__c newPaymentAccount;
        BusinessAccountWrapper newBusinessAccountDetails;
        Set<Id> processedBusinessAccountIds = new Set<Id>();
        Map<String, Payment_Account__c> newPaymentAccounts = new Map<String, Payment_Account__c>();
        for (Id eachBusinessAccountId : driveWithholdingMxs.keySet()) {
            for (
                Business_Onboarding_Detail__c eachBusinessOnboardingDetail : driveWithholdingMxs.get(
                    eachBusinessAccountId
                )
            ) {
                if (
                    !mxBusinessAccountDetails.containsKey(eachBusinessOnboardingDetail.Id) ||
                    processedBusinessAccountIds.contains(eachBusinessAccountId)
                ) {
                    continue;
                }
                newBusinessAccountDetails = mxBusinessAccountDetails.get(
                    eachBusinessOnboardingDetail.Id
                );
                if (validatePaymentDetailsOnBusinessDetails(newBusinessAccountDetails)) {
                    continue;
                }
                String key = generateContactKeyByBusinessDetailsRepContact(
                    newBusinessAccountDetails
                );
                if (contactsByEmailId.containsKey(key)) {
                    billingContactId = contactsByEmailId.get(key).Id;
                }
                newPaymentAccount = new Payment_Account__c();
                paymentAccountUniqueKey =
                    String.valueOf(newBusinessAccountDetails.bankAccountNumber) +
                    SEPARATOR +
                    String.valueOf(newBusinessAccountDetails.routingNumber);
                if (existingPaymentAccounts.containsKey(paymentAccountUniqueKey)) {
                    unitOfWork.registerNew(
                        new Account_Payment_Account_Relation__c(
                            Account__c = eachBusinessAccountId,
                            Payment_Account__c = existingPaymentAccounts.get(
                                    paymentAccountUniqueKey
                                )
                                .Id
                        )
                    );
                    processedBusinessAccountIds.add(eachBusinessAccountId);
                } else if (
                    newPaymentAccounts.containsKey(
                        String.valueOf(eachBusinessAccountId) + SEPARATOR + paymentAccountUniqueKey
                    )
                ) {
                    unitOfWork.registerNew(
                        new Account_Payment_Account_Relation__c(Account__c = eachBusinessAccountId),
                        Account_Payment_Account_Relation__c.Payment_Account__c,
                        newPaymentAccounts.get(
                            String.valueOf(eachBusinessAccountId) +
                                SEPARATOR +
                                paymentAccountUniqueKey
                        )
                    );
                    processedBusinessAccountIds.add(eachBusinessAccountId);
                } else {
                    newPaymentAccount = new Payment_Account__c(
                        RoutingNumber__c = newBusinessAccountDetails.routingNumber,
                        Bank_Account_Number__c = newBusinessAccountDetails.bankAccountNumber,
                        Institution_Number__c = newBusinessAccountDetails.institutionNumber,
                        Payment_Descriptor__c = newBusinessAccountDetails.paymentDescriptor,
                        Billing_Contact_Name__c = billingContactId,
                        RecordTypeId = PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
                    );
                    unitOfWork.registerNew(newPaymentAccount);
                    unitOfWork.registerNew(
                        new Account_Payment_Account_Relation__c(Account__c = eachBusinessAccountId),
                        Account_Payment_Account_Relation__c.Payment_Account__c,
                        newPaymentAccount
                    );
                    newPaymentAccounts.put(
                        String.valueOf(eachBusinessAccountId) + SEPARATOR + paymentAccountUniqueKey,
                        newPaymentAccount
                    );
                    processedBusinessAccountIds.add(eachBusinessAccountId);
                }
                billingContactId = null;
                paymentAccountUniqueKey = '';
            }
        }
    }

    /**
     * @description It creates Payment Accounts and Account to Payment Account Relation.
     * for Marketplace Mxs.
     * @JIRA# LEM-15113
     * @param contactsByEmailId
     * @param existingPaymentAccounts
     * @param marketplaceMxs
     * @param storeAccountsByAddress
     * @param unitOfWork
     */
    private void createPaymentAccountsForMarketplaceMxs(
        Map<String, Contact> contactsByEmailId,
        Map<String, Payment_Account__c> existingPaymentAccounts,
        Map<Id, List<Store_Detail__c>> marketplaceMxs,
        Map<String, Account> storeAccountsByAddress,
        fflib_ISObjectUnitOfWork unitOfWork
    ) {
        if (marketplaceMxs.isEmpty()) {
            return;
        }
        Map<String, Payment_Account__c> newPaymentAccounts = new Map<String, Payment_Account__c>();
        Id billingContactId;
        Id storeAccountId;
        String paymentAccountUniqueKey = '';
        Payment_Account__c newPaymentAccount;
        StoreDetailsWrapper newStoreAccountDetails;
        Set<Id> processedStoreAccountIds = new Set<Id>();
        for (Id eachBusinessAccountId : marketplaceMxs.keySet()) {
            for (Store_Detail__c eachStoreDetail : marketplaceMxs.get(eachBusinessAccountId)) {
                if (
                    mxStoreAccountDetails.containsKey(eachStoreDetail.Id) &&
                    storeAccountsByAddress.containsKey(eachStoreDetail.Id)
                ) {
                    newStoreAccountDetails = mxStoreAccountDetails.get(eachStoreDetail.Id);
                    storeAccountId = storeAccountsByAddress.get(eachStoreDetail.Id).Id;
                    if (processedStoreAccountIds.contains(storeAccountId)) {
                        continue;
                    }
                    String key = generateContactKeyStoreDetailsRepContact(newStoreAccountDetails);
                    if (contactsByEmailId.containsKey(key)) {
                        billingContactId = contactsByEmailId.get(key).Id;
                    }
                    newPaymentAccount = new Payment_Account__c();
                    paymentAccountUniqueKey =
                        String.valueOf(newStoreAccountDetails.bankAccountNumber) +
                        SEPARATOR +
                        String.valueOf(newStoreAccountDetails.routingNumber);
                    if (existingPaymentAccounts.containsKey(paymentAccountUniqueKey)) {
                        unitOfWork.registerNew(
                            new Account_Payment_Account_Relation__c(
                                Account__c = storeAccountId,
                                Payment_Account__c = existingPaymentAccounts.get(
                                        paymentAccountUniqueKey
                                    )
                                    .Id
                            )
                        );
                        processedStoreAccountIds.add(storeAccountId);
                    } else if (newPaymentAccounts.containsKey(paymentAccountUniqueKey)) {
                        unitOfWork.registerNew(
                            new Account_Payment_Account_Relation__c(Account__c = storeAccountId),
                            Account_Payment_Account_Relation__c.Payment_Account__c,
                            newPaymentAccounts.get(paymentAccountUniqueKey)
                        );
                        processedStoreAccountIds.add(storeAccountId);
                    } else {
                        newPaymentAccount = new Payment_Account__c(
                            RoutingNumber__c = newStoreAccountDetails.routingNumber,
                            Bank_Account_Number__c = newStoreAccountDetails.bankAccountNumber,
                            Institution_Number__c = newStoreAccountDetails.institutionNumber,
                            Payment_Descriptor__c = newStoreAccountDetails.paymentDescriptor,
                            Billing_Contact_Name__c = billingContactId,
                            RecordTypeId = PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
                        );
                        unitOfWork.registerNew(newPaymentAccount);
                        unitOfWork.registerNew(
                            new Account_Payment_Account_Relation__c(Account__c = storeAccountId),
                            Account_Payment_Account_Relation__c.Payment_Account__c,
                            newPaymentAccount
                        );
                        newPaymentAccounts.put(paymentAccountUniqueKey, newPaymentAccount);
                        processedStoreAccountIds.add(storeAccountId);
                    }
                    billingContactId = null;
                    paymentAccountUniqueKey = '';
                    storeAccountId = null;
                }
            }
        }
    }

    /**
     * @description It generates the unique Contact key based on Billing Contact's First name, Last name and Email.
     * @JIRA# LEM-23959
     * @param newBusinessAccountDetails
     * @return String
     */
    private String generateContactKeyByBusinessDetailsBillingContact(
        BusinessAccountWrapper newBusinessAccountDetails
    ) {
        return newBusinessAccountDetails.billingContactEmail +
            SEPARATOR +
            (isNullOrBlank(newBusinessAccountDetails.billingContactFirstName)
                ? newBusinessAccountDetails.billingContactFirstName
                : newBusinessAccountDetails.billingContactFirstName.toLowerCase()) +
            SEPARATOR +
            (isNullOrBlank(newBusinessAccountDetails.billingContactLastName)
                ? newBusinessAccountDetails.billingContactLastName
                : newBusinessAccountDetails.billingContactLastName.toLowerCase());
    }

    /**
     * @description It generates the unique Contact key based on Representative Contact's First name, Last name and Email.
     * @JIRA# LEM-23959
     * @param newBusinessAccountDetails
     * @return String
     */
    private String generateContactKeyByBusinessDetailsRepContact(
        BusinessAccountWrapper newBusinessAccountDetails
    ) {
        return newBusinessAccountDetails.representativeEmail +
            SEPARATOR +
            (isNullOrBlank(newBusinessAccountDetails.representativeFirstName)
                ? newBusinessAccountDetails.representativeFirstName
                : newBusinessAccountDetails.representativeFirstName.toLowerCase()) +
            SEPARATOR +
            (isNullOrBlank(newBusinessAccountDetails.representativeLastName)
                ? newBusinessAccountDetails.representativeLastName
                : newBusinessAccountDetails.representativeLastName.toLowerCase());
    }

    /**
     * @description It generates the unique Contact key based on Representative Contact's First name, Last name and Email.
     * @JIRA# LEM-23959
     * @param newStoreAccountDetails
     * @return String
     */
    private String generateContactKeyStoreDetailsRepContact(
        StoreDetailsWrapper newStoreAccountDetails
    ) {
        return newStoreAccountDetails.representativeEmail +
            SEPARATOR +
            (isNullOrBlank(newStoreAccountDetails.representativeFirstName)
                ? newStoreAccountDetails.representativeFirstName
                : newStoreAccountDetails.representativeFirstName.toLowerCase()) +
            SEPARATOR +
            (isNullOrBlank(newStoreAccountDetails.representativeLastName)
                ? newStoreAccountDetails.representativeLastName
                : newStoreAccountDetails.representativeLastName.toLowerCase());
    }

    /**
     * @description It evaluates whether the received value is Null or Blank.
     * @JIRA# LEM-15113
     * @param valueToEvaluate
     * @return Boolean
     */
    private Boolean isNullOrBlank(Object valueToEvaluate) {
        return valueToEvaluate == null || String.isBlank(String.valueOf(valueToEvaluate));
    }

    /**
     * @description It evaluates whether the Address Street and City are populated
     * on Business Details.
     * @JIRA# LEM-15113
     * @param newBusinessAccountDetails
     * @return Boolean
     */
    private Boolean validateBusinessDetailsAddress(
        BusinessAccountWrapper newBusinessAccountDetails
    ) {
        return isNullOrBlank(newBusinessAccountDetails.paymentStreet) ||
            isNullOrBlank(newBusinessAccountDetails.paymentCity);
    }

    /**
     * @description It evaluates whether the Bank Account Number and Routing Number are populated
     * on Business Details.
     * @JIRA# LEM-15113
     * @param newBusinessAccountDetails
     * @return Boolean
     */
    private Boolean validatePaymentDetailsOnBusinessDetails(
        BusinessAccountWrapper newBusinessAccountDetails
    ) {
        return isNullOrBlank(newBusinessAccountDetails.bankAccountNumber) ||
            isNullOrBlank(newBusinessAccountDetails.routingNumber);
    }
}