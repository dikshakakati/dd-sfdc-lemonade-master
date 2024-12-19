/**
 * @author Deloitte
 * @date   05/17/2024
 * @description This is the service implementation class to create Store account,
 * Business Reference and Xreference for contact object creation from SSMO Payload.
 */

public inherited sharing class SSMOCreateStoreBizRefXrefServiceImpl implements ISSMOCreateStoreBizRefXrefService {
    private static final String TYPE_BRICK_AND_MORTAR = 'Brick and Mortar';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String INACTIVE_STATUS = 'Inactive';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String CORPORATE = 'Corporate';
    private static final String RESTAURANT = 'Restaurant';
    private static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    private static final String INTEGRATION_STATUS_NEW = 'New';
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final String BUSINESS = 'Business';
    private static final String STORE = 'Store';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String BUSINESS_ERROR_MESSAGE_STORE_ACCOUNT_BIZREF_CREATION = 'Store Account, Business Refernce creation for Contact failed.';
    private static final String BUSINESS_ERROR_MESSAGE_XREF_CREATION = 'XRef creation for Contact failed.';
    private static final string FAILED = 'Failed';
    String methodName = '';
    Contact contactRecord = new Contact();
    private static final String LOG_SELF_SERVING_FALLOUT_SERVICE = 'selfserviceFalloutService';
    private static final String SALES_WS = 'Sales';
    private static final String SOURCE_SSMO = 'SSMO';
    private static final String CLASS_NAME = 'SSMOCreateStoreBizRefXrefServiceImpl';
    private static final String CREATE_STORE_ACCOUNT_BIZREF_XREF_FOR_SSMO_CONTACTS = 'createStoreAccountBusinessReferenceAndXReferenceForSSMOContacts';
    private static final String PROCESS_STORE_ACCOUNT_BIZREF_XREF_RECORDS = 'processStoreAccountBizRefXrefRecords';
    private static final String COMMIT_WORK = 'commitWork';
    private static Map<String, String> methodsToStepMap = new Map<String, String>{
        CREATE_STORE_ACCOUNT_BIZREF_XREF_FOR_SSMO_CONTACTS => '1',
        PROCESS_STORE_ACCOUNT_BIZREF_XREF_RECORDS => '2',
        COMMIT_WORK => '3'
    };
    private static final Map<String, String> COUNTRY_TO_CURRENCY_ISOCODE = new Map<String, String>{
        'AU' => 'AUD',
        'NZ' => 'NZD',
        'US' => 'USD',
        'CA' => 'CAD'
    };

    /**
     * @description It is used to create store account, BizRef and XRef for SSMO Contacts.
     * @param contactsWhereInboundInjestionLogFieldUpdated
     */
    public void createStoreAccountBusinessReferenceAndXReferenceForSSMOContacts(
        List<Contact> contactsWhereInboundInjestionLogFieldUpdated
    ) {
        this.methodName = CREATE_STORE_ACCOUNT_BIZREF_XREF_FOR_SSMO_CONTACTS;
        ContactProcessingContext contactContext = prepareContactsData(
            contactsWhereInboundInjestionLogFieldUpdated
        );
        if (
            contactContext.contactsToProcess == null || contactContext.contactsToProcess.isEmpty()
        ) {
            SSMOFalloutContactsService.createRelatedRecordsBasedOnSSMOPayload(
                contactsWhereInboundInjestionLogFieldUpdated
            );
            return;
        }
        contactRecord = contactContext.contactsToProcess[0];
        AccountsProcessingContext accountsContext = processAccountsData(contactContext);
        Map<Id, Business_Reference__c> contactIdToBusinessRef = new Map<Id, Business_Reference__c>();
        try {
            for (
                Account eachAccount : AccountsSelector.newInstance()
                    .selectById(accountsContext.matchingAccountIdToContactId.keySet())
            ) {
                if (eachAccount.Record_Type_Name__c == BUSINESS) {
                    accountsContext.contactIdsToCreateStoreAccount.add(
                        accountsContext.matchingAccountIdToContactId.get(eachAccount.Id)
                    );
                } else if (eachAccount.Record_Type_Name__c == STORE) {
                    accountsContext.contactIdToStoreAccount.put(
                        accountsContext.matchingAccountIdToContactId.get(eachAccount.Id),
                        eachAccount
                    );
                }
            }
            for (
                Business_Reference__c eachBusinessReference : BusinessReferencesSelector.newInstance()
                    .selectByDefaultTypeAndExternalIdSource(
                        contactContext.businessIdToContact.keySet(),
                        new Set<String>{ CORPORATE },
                        new Set<String>{ EXTERNAL_ID_SOURCE_MDS }
                    )
            ) {
                contactIdToBusinessRef.put(
                    contactContext.businessIdToContact.get(eachBusinessReference.External_Id__c)
                        ?.Id,
                    eachBusinessReference
                );
            }
            catchExceptionsOnGovernerLimits();
            processStoreAccountBizRefXrefRecords(
                contactContext,
                accountsContext,
                contactIdToBusinessRef,
                contactsWhereInboundInjestionLogFieldUpdated
            );
        } catch (Exception ex) {
            InboundIngestionLogs.updateIngestionLogsWithSucessOrFailureStatus(
                accountsContext.inboundIngestionLogIds,
                FAILED,
                ex.getMessage(),
                ex.getStackTraceString(),
                BUSINESS_ERROR_MESSAGE_STORE_ACCOUNT_BIZREF_CREATION
            );
            IInboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
                LOG_SELF_SERVING_FALLOUT_SERVICE,
                SALES_WS,
                contactRecord?.Inbound_Ingestion_Log__c,
                contactRecord?.Unique_Identifier__c,
                contactRecord?.Unique_Id__c
            );
            InboundIngestionLoggerService.logException(
                loggerEntry,
                ex,
                BUSINESS_ERROR_MESSAGE_STORE_ACCOUNT_BIZREF_CREATION,
                '',
                new Set<String>{},
                ex.getTypeName()
            );
        }
    }
    /**
     * @description It is used to process store account, BizRef and XRef creation.
     * @param contactContext
     * @param accountsContext
     * @param contactIdToBusinessRef
     * @param contactsWhereInboundInjestionLogFieldUpdated
     */
    private void processStoreAccountBizRefXrefRecords(
        ContactProcessingContext contactContext,
        AccountsProcessingContext accountsContext,
        Map<Id, Business_Reference__c> contactIdToBusinessRef,
        List<Contact> contactsWhereInboundInjestionLogFieldUpdated
    ) {
        this.methodName = PROCESS_STORE_ACCOUNT_BIZREF_XREF_RECORDS;
        fflib_ISobjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
        Map<Id, Xref__c> contactIdToXRefs = new Map<Id, Xref__c>();
        try {
            for (Contact eachContact : contactContext.contactsToProcess) {
                Id brandId = (accountsContext.parentAccountIdToBrandId.containsKey(
                        eachContact.AccountId
                    ))
                    ? accountsContext.parentAccountIdToBrandId.get(eachContact.AccountId)
                    : null;
                if (accountsContext.contactIdsToCreateStoreAccount.contains(eachContact.Id)) {
                    Account newStoreAccount = createStoreAccount(
                        eachContact,
                        brandId,
                        accountsContext.businessVerticalRestuarant[0].Id,
                        accountsContext.contactIdToParentAccount.get(eachContact.Id)
                    );
                    accountsContext.contactIdToStoreAccount.put(eachContact.Id, newStoreAccount);
                    unitOfWork.registerNew(newStoreAccount);
                }
                if (contactIdToBusinessRef.containsKey(eachContact.Id)) {
                    continue;
                }
                Business_Reference__c newbusinessReference = createBusinessReference(
                    eachContact,
                    brandId,
                    accountsContext.businessVerticalRestuarant[0].Id,
                    accountsContext.contactIdToParentAccount.get(eachContact.Id)
                );
                contactIdToBusinessRef.put(eachContact.Id, newbusinessReference);
                unitOfWork.registerNew(newbusinessReference);
            }
            unitOfWork.commitWork();
            catchExceptionsOnGovernerLimits();
            fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            for (
                Xref__c eachXRef : XrefsSelector.newInstance()
                    .selectXrefByExternalIdsAndExternalSourceMDS(
                        contactContext.storeIdToContact.keySet()
                    )
            ) {
                contactIdToXRefs.put(
                    contactContext.storeIdToContact.get(eachXRef.External_Id__c)?.Id,
                    eachXRef
                );
            }
            for (Contact eachContact : contactContext.contactsToProcess) {
                if (contactIdToXRefs.containsKey(eachContact.Id)) {
                    continue;
                }
                uow.registerNew(
                    createXReference(
                        eachContact,
                        contactIdToBusinessRef.get(eachContact.Id),
                        accountsContext.contactIdToStoreAccount.get(eachContact.Id)
                    )
                );
            }
            commitWork(uow, accountsContext);
            SSMOFalloutContactsService.createRelatedRecordsBasedOnSSMOPayload(
                contactsWhereInboundInjestionLogFieldUpdated
            );
        } catch (Exception ex) {
            InboundIngestionLogs.updateIngestionLogsWithSucessOrFailureStatus(
                accountsContext.inboundIngestionLogIds,
                FAILED,
                ex.getMessage(),
                ex.getStackTraceString(),
                BUSINESS_ERROR_MESSAGE_STORE_ACCOUNT_BIZREF_CREATION
            );
            IInboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
                LOG_SELF_SERVING_FALLOUT_SERVICE,
                SALES_WS,
                contactRecord?.Inbound_Ingestion_Log__c,
                contactRecord?.Unique_Identifier__c,
                contactRecord?.Unique_Id__c
            );
            InboundIngestionLoggerService.logException(
                loggerEntry,
                ex,
                BUSINESS_ERROR_MESSAGE_STORE_ACCOUNT_BIZREF_CREATION,
                '',
                new Set<String>{},
                ex.getTypeName()
            );
        }
    }

    /**
     * @description It is used to create store account by passes Contact, Brand and Business vertical details.
     * @param currentContact
     * @param brandId
     * @param businessVerticalId
     * @param parentAccount
     * @return Account
     */
    private Account createStoreAccount(
        Contact currentContact,
        Id brandId,
        Id businessVerticalId,
        Account parentAccount
    ) {
        Account newStoreAccount = new Account();
        newStoreAccount.RecordTypeId = STORE_RECORD_TYPE_ID;
        newStoreAccount.ParentId = (parentAccount.Record_Type_Name__c == BUSINESS)
            ? parentAccount.Id
            : parentAccount.ParentId;
        newStoreAccount.Type = TYPE_BRICK_AND_MORTAR;
        newStoreAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        newStoreAccount.Activation_Status__c = INACTIVE_STATUS;
        newStoreAccount.BillingCity = currentContact.MailingCity;
        newStoreAccount.BillingCountry = currentContact.MailingCountry;
        newStoreAccount.BillingCountryCode = currentContact.MailingCountryCode;
        newStoreAccount.BillingPostalCode = currentContact.MailingPostalCode;
        newStoreAccount.BillingStateCode = currentContact.MailingStateCode;
        newStoreAccount.BillingStreet = currentContact.MailingStreet;
        newStoreAccount.Brand__c = (brandId != null) ? brandId : null;
        newStoreAccount.Business_Vertical__c = (businessVerticalId != null)
            ? businessVerticalId
            : null;
        return newStoreAccount;
    }
    /**
     * @description It is used to create Business Reference by passes Contact, Brand, Business vertical and Parent Account details.
     * @param currentContact
     * @param brandId
     * @param businessVerticalId
     * @param parentAccount
     * @return Business_Reference__c
     */
    private Business_Reference__c createBusinessReference(
        Contact currentContact,
        Id brandId,
        Id businessVerticalId,
        Account parentAccount
    ) {
        Business_Reference__c newBusinessReference = new Business_Reference__c();
        newBusinessReference.External_Id__c = currentContact.Business_Id__c;
        newBusinessReference.External_Id_Source__c = EXTERNAL_ID_SOURCE_MDS;
        newBusinessReference.Default_Type__c = CORPORATE;
        newBusinessReference.Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL;
        newBusinessReference.Menu_UI_Type__c = RESTAURANT;
        newBusinessReference.CurrencyIsoCode = COUNTRY_TO_CURRENCY_ISOCODE.get(
            parentAccount.BillingCountryCode
        );
        newBusinessReference.Integration_Status__c = INTEGRATION_STATUS_SUCCESS;
        newBusinessReference.Brand__c = (brandId != null) ? brandId : null;
        newBusinessReference.Business_Name__c = parentAccount.Name;
        newBusinessReference.Business_Vertical__c = (businessVerticalId != null)
            ? businessVerticalId
            : null;
        newBusinessReference.Is_Created_By_SSMO__c = true;
        return newBusinessReference;
    }
    /**
     * @description It is used to create X Reference by passed Contact, BizRef and Store Account details.
     * @param currentContact
     * @param bizRef
     * @param storeAccount
     * @return Xref__c
     */
    private Xref__c createXReference(
        Contact currentContact,
        Business_Reference__c bizRef,
        Account storeAccount
    ) {
        Xref__c newXRef = new Xref__c();
        newXRef.Xref_Status__c = INACTIVE_STATUS;
        newXRef.Integration_Status__c = INTEGRATION_STATUS_NEW;
        newXRef.External_ID__c = currentContact.Store_Id__c;
        newXRef.External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS;
        newXRef.Record_Source__c = SOURCE_SSMO;
        newXRef.Salesforce_Account_Name__c = storeAccount.Id;
        newXRef.Business_Reference__c = bizRef.Id;
        return newXRef;
    }
    /**
     * @description It is used to prepare the Maps with contact details for further creation of Store Account,
     * BizRef and Xref.
     * @param contactsWhereInboundInjestionLogFieldUpdated
     * @return ContactProcessingContext
     */
    private ContactProcessingContext prepareContactsData(
        List<Contact> contactsWhereInboundInjestionLogFieldUpdated
    ) {
        ContactProcessingContext contactContext = new ContactProcessingContext();

        for (Contact eachContact : contactsWhereInboundInjestionLogFieldUpdated) {
            if (
                eachContact.Business_Id__c != null &&
                eachContact.Store_Id__c != null &&
                eachContact.Unique_Identifier__c != null
            ) {
                contactContext.businessIdToContact.put(eachContact.Business_Id__c, eachContact);
                contactContext.storeIdToContact.put(eachContact.Store_Id__c, eachContact);
                contactContext.parentAccountIdToContactId.put(
                    eachContact.AccountId,
                    eachContact.Id
                );
                contactContext.contactsToProcess.add(eachContact);
            }
        }
        return contactContext;
    }
    /**
     * @description It is used to prepare the Maps with Account details for further creation of Store Account,
     * BizRef and Xref.
     * @param contactContext
     * @return AccountsProcessingContext
     */
    private AccountsProcessingContext processAccountsData(ContactProcessingContext contactContext) {
        AccountsProcessingContext accountContext = new AccountsProcessingContext();
        accountContext.businessVerticalRestuarant = BusinessVerticalsSelector.newInstance()
            .selectBusinessVerticalByName(RESTAURANT);
        for (Contact eachContact : contactContext.contactsToProcess) {
            if (
                eachContact.Inbound_Ingestion_Log__c != null &&
                eachContact.SSMO_Matching_Account_Id__c != null
            ) {
                accountContext.matchingAccountIdToContactId.put(
                    eachContact.SSMO_Matching_Account_Id__c,
                    eachContact.Id
                );
                accountContext.inboundIngestionLogIds.add(eachContact.Inbound_Ingestion_Log__c);
            }
        }
        List<Account> accounts = AccountsSelector.newInstance()
            .getAccountsWithBrandAssociationsbyAccountIds(
                contactContext.parentAccountIdToContactId.keySet()
            );
        for (Account eachAccount : accounts) {
            if (eachAccount.Brand_Associations__r.size() == 1) {
                accountContext.parentAccountIdToBrandId.put(
                    eachAccount.Id,
                    eachAccount.Brand_Associations__r[0].Brand_Name__c
                );
            }
            accountContext.contactIdToParentAccount.put(
                contactContext.parentAccountIdToContactId.get(eachAccount.Id),
                eachAccount
            );
        }
        return accountContext;
    }

    /**
     * @description It is wrapper class to store all the maps related to contacts for creation of Store Account,
     * BizRef and Xref.
     * @param contactContext
     * @return AccountsProcessingContext
     */
    private class ContactProcessingContext {
        Map<String, Contact> businessIdToContact = new Map<String, Contact>();
        Map<String, Contact> storeIdToContact = new Map<String, Contact>();
        Map<Id, Id> parentAccountIdToContactId = new Map<Id, Id>();
        List<Contact> contactsToProcess = new List<Contact>();
    }

    /**
     * @description It is wrapper class to store all the maps related to accounts for creation of Store Account,
     * BizRef and Xref.
     * @param contactContext
     * @return AccountsProcessingContext
     */
    private class AccountsProcessingContext {
        Map<Id, Id> matchingAccountIdToContactId = new Map<Id, Id>();
        Set<Id> contactIdsToCreateStoreAccount = new Set<Id>();
        Map<Id, Account> contactIdToParentAccount = new Map<Id, Account>();
        Map<Id, Account> contactIdToStoreAccount = new Map<Id, Account>();
        Map<Id, Id> parentAccountIdToBrandId = new Map<Id, Id>();
        List<Business_Vertical__c> businessVerticalRestuarant = new List<Business_Vertical__c>();
        Set<Id> inboundIngestionLogIds = new Set<Id>();
    }

    /**
     * @description A common method to commit unit of work.
     * @param uow
     * @param accountsContext
     */
    private void commitWork(
        fflib_ISObjectUnitOfWork uow,
        AccountsProcessingContext accountsContext
    ) {
        this.methodName = COMMIT_WORK;
        try {
            uow.commitWork();
            catchExceptionsOnGovernerLimits();
        } catch (Exception ex) {
            InboundIngestionLogs.updateIngestionLogsWithSucessOrFailureStatus(
                accountsContext.inboundIngestionLogIds,
                FAILED,
                ex.getMessage(),
                ex.getStackTraceString(),
                BUSINESS_ERROR_MESSAGE_XREF_CREATION
            );
            IInboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
                LOG_SELF_SERVING_FALLOUT_SERVICE,
                SALES_WS,
                contactRecord?.Inbound_Ingestion_Log__c,
                contactRecord?.Unique_Identifier__c,
                contactRecord?.Unique_Id__c
            );
            InboundIngestionLoggerService.logException(
                loggerEntry,
                ex,
                BUSINESS_ERROR_MESSAGE_XREF_CREATION,
                '',
                new Set<String>{},
                ex.getTypeName()
            );
            throw ex;
        }
    }

    /**
     * @description It is used to catch Governor Limit Exceptions when the payload inserted for the fallout Event.
     */
    private void catchExceptionsOnGovernerLimits() {
        String govLimitsException = InboundIngestionLoggerService.errorOnGovtLimitsExceeded();
        if (String.isNotBlank(govLimitsException)) {
            IInboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
                LOG_SELF_SERVING_FALLOUT_SERVICE,
                SALES_WS,
                contactRecord?.Inbound_Ingestion_Log__c,
                contactRecord?.Unique_Identifier__c,
                contactRecord?.Unique_Id__c
            );
            InboundIngestionLoggerService.logGovLimitsException(
                loggerEntry,
                govLimitsException,
                methodsToStepMap.get(this.methodName),
                CLASS_NAME,
                this.methodName
            );
        }
    }
}