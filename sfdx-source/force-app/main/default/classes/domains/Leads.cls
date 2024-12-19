/**
 * @author Deloitte
 * @date 05/07/2022
 * @description Domain Class for Lead Object.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class Leads extends fflib_SObjects implements ILeads {
    private static final String BUSINESS_VERTICAL = 'Business_Vertical__c';
    private static final String COMMA = ',';
    private static final String FORWARDSLASH_R = '\r';
    private static final String FORWARDSLASH_N = '\n';
    private static final String FORWARDSLASH_R_N = '\r\n';
    private static final String LEAD_CONVERSION_TYPE_MANUAL = 'Manual';
    private static final String HOURS_OF_OPERATION_LEAD = 'HoursOfOperation__c';
    private static final String LEAD_SOBJECT_TYPE = 'Lead';
    private static final String LOG_UPDATE_OPPORTUNITY_AND_ACCOUNT_SOURCE = 'Update Account and Opportunity Source from Lead Conversion Failed';
    private static final String LOG_CREATE_UPDATE_STORE_ACCOUNT = 'Creation/Updation of Store account failed from Lead Conversion';
    private static final String LOG_FIELD_MAPPING_ERROR = 'Lead to Store Account conversion field mapping is empty.';
    private static final String LOG_DOMAIN = 'Sales';
    private static final String LEAD_SOURCE = 'Lead';
    private static final String PROSPECTING = 'Prospecting';
    private static final String PREFERRED_LANGUAGE_LEAD = 'PreferredLanguage__c';
    private static final String RECORD_TYPE_BUSINESS = 'Business';
    private static final String RECORD_TYPE_STORE = 'Store';
    private static final String RECORD_TYPE_CHANNEL_PARTNER = 'Channel Partner';
    private static final String RECORD_TYPE_ID_STORE = 'RecordTypeId';
    private static final String SEGMENT = 'Segment__c';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SUB_TYPE_NET_NEW = 'Net-new';
    private static final String TYPE_NEW = 'New';
    private static final String UNVERIFIED = 'Unverified';
    private static final String LEAD_STATUS_NOT_INTERESTED_COOL_DOWN = 'Not Interested - Cool Down';
    private static final String LEAD_STATUS_UNQUALIFIED = 'Unqualified';
    private static final String LEAD_STATUS_UNTOUCHED = 'Untouched';
    private static final String COMPLETED = 'Completed';
    private static final String BYPASS_LEAD_ADDRESS_UPDATE_FUNCTIONALITY = 'Bypass_Lead_Address_Update_Functionality';
    private static final String AUTOMATED_PROCESS_USER = 'Automated Process';

    private static final Schema.SObjectType SOBJECTTYPE = ((SObject) Type.forName(LEAD_SOBJECT_TYPE)
            .newInstance())
        .getSObjectType()
        .getDescribe()
        .getSObjectType();
    private static final Map<String, Schema.SObjectField> SOBJECTFIELDS = SOBJECTTYPE.getDescribe()
        .fields.getMap();
    private Map<Id, Account> leadToNewStoreAccount = new Map<Id, Account>();
    private static List<StaticResource> leadToStoreConversionFieldMappingStaticResource;
    private static List<StaticResource> leadSObjectsConversionFieldMappingStaticResource;

    static {
        leadToStoreConversionFieldMappingStaticResource = StaticResourcesSelector.newInstance()
            .selectByName(System.Label.FieldMapping);
        leadSObjectsConversionFieldMappingStaticResource = StaticResourcesSelector.newInstance()
            .selectByName(System.Label.LeadConversionSObjectsMapping);
    }
    Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    Business_Reference__c businessReferenceCreatedFromLeadConversion;
    fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
    /**
     * @description This method is used to return the ILeads interface
     * @param recordList - Leads record list
     * @return ILeads - Returns ILeads Interface
     */
    public static ILeads newInstance(List<Lead> recordList) {
        return (ILeads) Application.Domain.newInstance(recordList);
    }
    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public Leads(List<Lead> sObjectList) {
        super(sObjectList, Schema.Lead.SObjectType);
        this.leadToNewStoreAccount = new Map<Id, Account>();
    }

    /**
     * @description It is used to update the last status change date when there is an update on status.
     * @JIRA# LEM-21484
     */
    public void updateLastStatusChangeDate() {
        for (Lead eachLead : (List<Lead>) getRecords()) {
            eachLead.Last_Status_Change_Date__C = Date.today();
        }
    }

    /**
     * @description It is used to reset attributes on Leads related to address.
     */
    public void resetAddressAttributes() {
        if (
            FeatureManagement.checkPermission(BYPASS_LEAD_ADDRESS_UPDATE_FUNCTIONALITY) ||
            UserInfo.getName() == AUTOMATED_PROCESS_USER
        ) {
            return;
        }
        for (Lead eachLead : (List<Lead>) getRecords()) {
            eachLead.Address_Verification_Status__c = UNVERIFIED;
            eachLead.Alcohol_Eligibility__c = null;
            eachLead.Coverage__c = null;
            eachLead.Starting_Point__c = null;
            eachLead.Starting_Point_ID__c = null;
            eachLead.Submarket__c = null;
            eachLead.Time_Zone_Backend__c = null;
        }
    }

    /**
     * @description It is used to process Leads on conversion.
     */
    public void processLeadsOnConversion() {
        Map<Id, Lead> convertedAccountIdToLead = new Map<Id, Lead>();
        Set<Id> convertedContactIds = new Set<Id>();
        Set<Id> convertedOpportunityIds = new Set<Id>();
        Map<String, Lead> storeIdToLead = new Map<String, Lead>();
        List<String> secondaryPhoneValues = new List<String>();
        Set<Id> campaignIds = new Set<Id>();
        Set<Id> manuallyConvertedLeadIds = new Set<Id>();
        for (Lead eachLead : (List<Lead>) getRecords()) {
            convertedAccountIdToLead.put(eachLead.ConvertedAccountId, eachLead);
            convertedContactIds.add(eachLead.ConvertedContactId);
            convertedOpportunityIds.add(eachLead.ConvertedOpportunityId);
            storeIdToLead.put(eachLead.Store_ID__c, eachLead);
            secondaryPhoneValues.add(eachLead.SecondaryPhone__c);
            campaignIds.add(eachLead.Primary_Campaign_Source__c);
            if (eachLead.Lead_Conversion_Type__c == LEAD_CONVERSION_TYPE_MANUAL) {
                manuallyConvertedLeadIds.add(eachLead.Id);
            }
        }
        if (manuallyConvertedLeadIds.isEmpty()) {
            return;
        }
        restrictConversionToSMBAccountsOnly(convertedAccountIdToLead);
        createStoreAccountsByCriteria(storeIdToLead);
        setSourceAsLead(
            convertedAccountIdToLead.keySet(),
            convertedContactIds,
            convertedOpportunityIds,
            secondaryPhoneValues,
            campaignIds
        );
        LeadConversionService.initiateSObjectsCreationOnManualLeadConversion(
            manuallyConvertedLeadIds,
            leadToNewStoreAccount
        );
    }

    /**
     * @description It is used to set certain field values before Lead conversion.
     */
    public void setDefaultValuesBeforeConversion() {
        for (Lead eachLead : (List<Lead>) getRecords()) {
            eachLead.Type__c = TYPE_NEW;
            eachLead.Segment__c = SEGMENT_SMB;
            eachLead.Stage__c = PROSPECTING;
            eachLead.Sub_Type__c = SUB_TYPE_NET_NEW;
        }
    }

    /**
     * @description It checks whether store Account and Lead address matches.
     * @param convertedLead
     * @param storeAccount
     * @return Boolean
     */
    private Boolean addressMatches(Lead convertedLead, Account storeAccount) {
        return ((storeAccount.BillingStreet == convertedLead.Street) &&
        (storeAccount.BillingCity == convertedLead.City) &&
        (storeAccount.BillingStateCode == convertedLead.StateCode) &&
        (storeAccount.BillingCountryCode == convertedLead.CountryCode) &&
        (storeAccount.BillingPostalCode == convertedLead.PostalCode));
    }

    /**
     * @description It checks for the related XREF for the given Store Accounts.
     * @param storeIdsToSearch
     * @return Map<String, Account>
     */
    private Map<String, Account> searchStoresByStoreId(Set<String> storeIdsToSearch) {
        Map<String, Account> storeIdToStoreAccount = new Map<String, Account>();
        if (storeIdsToSearch.isEmpty()) {
            return storeIdToStoreAccount;
        }
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectXrefByExternalId(new List<String>(storeIdsToSearch))
        ) {
            storeIdToStoreAccount.put(eachXref.External_ID__c, eachXref.Salesforce_Account_Name__r);
        }
        return storeIdToStoreAccount;
    }

    /**
     * @description It creates or updates store account based on matching criteria.
     * @param storeIdToLead
     */
    private void createStoreAccountsByCriteria(Map<String, Lead> storeIdToLead) {
        Map<String, String> accountFieldToValue = new Map<String, String>();
        Map<Lead, Set<Account>> leadToStoreAccounts = new Map<Lead, Set<Account>>();
        if ((storeIdToLead.keySet()).size() == 0) {
            return;
        }
        Map<String, Account> storeIdToStoreAccount = searchStoresByStoreId(storeIdToLead.keySet());
        Lead currentLead = new Lead();
        Account currentStoreAccount = new Account();
        String businessVerticalToStamp;
        List<Business_Vertical__c> businessVerticalsRx = BusinessVerticalsSelector.newInstance()
            .selectPrimaryVerticalRxRecord();
        businessVerticalToStamp = businessVerticalsRx[0].Id;
        for (String eachStoreId : storeIdToLead.keySet()) {
            currentLead = storeIdToLead.get(eachStoreId);
            currentStoreAccount = storeIdToStoreAccount.get(eachStoreId);
            if (
                !(currentStoreAccount != null &&
                currentStoreAccount.Name.contains(currentLead.Company) &&
                addressMatches(currentLead, currentStoreAccount))
            ) {
                currentStoreAccount = new Account();
            }
            if (!leadToStoreAccounts.containsKey(currentLead)) {
                leadToStoreAccounts.put(currentLead, new Set<Account>());
            }
            leadToStoreAccounts.get(currentLead).add(currentStoreAccount);
        }
        accountFieldToValue = LeadConversionMappingService.collectFieldValueMappings(
            LeadConversionMappingService.collectFields(
                leadToStoreConversionFieldMappingStaticResource[0].Body
            ),
            'Account'
        );
        if (accountFieldToValue.isEmpty()) {
            return;
        }
        createOrUpdateStoreAccounts(
            leadToStoreAccounts,
            accountFieldToValue,
            businessVerticalToStamp,
            unitOfWork
        );
    }

    /**
     * @description It updates or creates the store based on conditions.
     * @param leadToStoreAccounts
     * @param accountFieldToValue
     * @param businessVerticalToStamp
     * @param unitOfWork
     */
    private void createOrUpdateStoreAccounts(
        Map<Lead, Set<Account>> leadToStoreAccounts,
        Map<String, String> accountFieldToValue,
        String businessVerticalToStamp,
        fflib_ISObjectUnitOfWork unitOfWork
    ) {
        for (Lead eachLead : leadToStoreAccounts.keySet()) {
            for (Account eachAccount : leadToStoreAccounts.get(eachLead)) {
                createOrUpdateStoreAccountsBasedOnCSV(
                    eachAccount,
                    eachLead,
                    businessVerticalToStamp,
                    accountFieldToValue,
                    unitOfWork
                );
                leadToNewStoreAccount.put(eachLead.Id, eachAccount);
            }
        }
        try {
            unitOfWork.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_CREATE_UPDATE_STORE_ACCOUNT,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description It updates or creates the store based on CSV file inputs.
     * @param eachAccount
     * @param eachLead
     * @param businessVerticalToStamp
     * @param accountFieldToValue
     * @param unitOfWork
     */
    private void createOrUpdateStoreAccountsBasedOnCSV(
        Account eachAccount,
        Lead eachLead,
        String businessVerticalToStamp,
        Map<String, String> accountFieldToValue,
        fflib_ISObjectUnitOfWork unitOfWork
    ) {
        String valueToApply;
        for (String eachAccountField : accountFieldToValue.keySet()) {
            valueToApply = accountFieldToValue.get(eachAccountField);
            if (String.isBlank(eachAccount.Id)) {
                eachAccount.put(
                    eachAccountField,
                    SOBJECTFIELDS.containsKey(valueToApply)
                        ? eachLead.get(ValueToApply)
                        : valueToApply
                );
                eachAccount.put(BUSINESS_VERTICAL, businessVerticalToStamp);
            } else {
                if (checkForUpdateFieldsOnStoreAccount(valueToApply, eachAccount)) {
                    eachAccount.put(
                        eachAccountField,
                        SOBJECTFIELDS.containsKey(valueToApply)
                            ? eachLead.get(ValueToApply)
                            : valueToApply
                    );
                }
            }
        }
        eachAccount.put(RECORD_TYPE_ID_STORE, storeRecordTypeId);
        unitOfWork.registerUpsert(eachAccount);
    }

    /**
     * @description It restricts conversion of Leads to only SMB Accounts.
     * @param valueToApply
     * @param eachAccount
     * @return Boolean
     */
    private Boolean checkForUpdateFieldsOnStoreAccount(String valueToApply, Account eachAccount) {
        Boolean updateFieldsOnStoreAccount = false;
        if (
            (valueToApply == HOURS_OF_OPERATION_LEAD &&
            String.isBlank(eachAccount.Hours_of_Operation__c)) ||
            (valueToApply == PREFERRED_LANGUAGE_LEAD &&
            String.isBlank(eachAccount.Preferred_Language__c))
        ) {
            updateFieldsOnStoreAccount = true;
        }
        return updateFieldsOnStoreAccount;
    }
    /**
     * @description It restricts conversion of Leads to only SMB Accounts.
     * @param convertedAccountIdToLead
     */
    private void restrictConversionToSMBAccountsOnly(Map<Id, Lead> convertedAccountIdToLead) {
        if (convertedAccountIdToLead == null || convertedAccountIdToLead.isEmpty()) {
            return;
        }
        for (
            Account eachConvertedAccount : AccountsSelector.newInstance()
                .selectById(convertedAccountIdToLead.keySet())
        ) {
            if (
                eachConvertedAccount.Record_Type_Name__c == RECORD_TYPE_STORE ||
                eachConvertedAccount.Record_Type_Name__c == RECORD_TYPE_CHANNEL_PARTNER ||
                (eachConvertedAccount.Record_Type_Name__c == RECORD_TYPE_BUSINESS &&
                eachConvertedAccount.Segment__c != SEGMENT_SMB)
            ) {
                convertedAccountIdToLead.get(eachConvertedAccount.Id)
                    .addError(System.Label.LeadConversionError);
            }
        }
    }

    /**
     * @description Set source to Lead on Account,Contact and Opportunity converted records.
     * @param convertedAccountIds
     * @param convertedContactIds
     * @param convertedOpportunityIds
     * @param secondaryPhoneValues
     * @param campaignIds
     */
    private void setSourceAsLead(
        Set<Id> convertedAccountIds,
        Set<Id> convertedContactIds,
        Set<Id> convertedOpportunityIds,
        List<String> secondaryPhoneValues,
        Set<Id> campaignIds
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        setAccountSource(convertedAccountIds, uow);
        setContactSource(convertedContactIds, secondaryPhoneValues, uow);
        setOpportunitySource(convertedOpportunityIds, campaignIds, uow);
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_UPDATE_OPPORTUNITY_AND_ACCOUNT_SOURCE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description It is used to set Source to Lead on Account.
     * @param convertedAccountIds
     * @param uow
     */
    private void setAccountSource(Set<Id> convertedAccountIds, fflib_ISObjectUnitOfWork uow) {
        if (convertedAccountIds.isEmpty()) {
            return;
        }
        for (Id eachAccountId : convertedAccountIds) {
            uow.registerDirty(
                new Account(
                    Id = eachAccountId,
                    Creation_Source__c = LEAD_SOURCE,
                    Managed_Status__c = null
                )
            );
        }
    }

    /**
     * @description It is used to set Source to Lead on Contact.
     * @param convertedContactIds
     * @param secondaryPhoneValues
     * @param uow
     */
    private void setContactSource(
        Set<Id> convertedContactIds,
        List<String> secondaryPhoneValues,
        fflib_ISObjectUnitOfWork uow
    ) {
        if (convertedContactIds.isEmpty() || secondaryPhoneValues.isEmpty()) {
            return;
        }
        for (String secondaryPhone : secondaryPhoneValues) {
            for (Id eachContactId : convertedContactIds) {
                Contact contactToUpdate = new Contact(
                    Id = eachContactId,
                    Contact_Source__c = LEAD_SOURCE,
                    OtherPhone = secondaryPhone,
                    OwnerId = UserInfo.getUserId()
                );
                uow.registerDirty(contactToUpdate);
            }
        }
    }

    /**
     * @description It is used to set Source to Lead on Opportunity.
     * @param convertedOpportunityIds
     * @param campaignIds
     * @param uow
     */
    private void setOpportunitySource(
        Set<Id> convertedOpportunityIds,
        Set<Id> campaignIds,
        fflib_ISObjectUnitOfWork uow
    ) {
        if (convertedOpportunityIds.contains(null)) {
            convertedOpportunityIds.remove(null);
        }
        if (convertedOpportunityIds.isEmpty() || campaignIds.isEmpty()) {
            return;
        }
        for (Id eachcampaignId : campaignIds) {
            for (Id eachOpportunityId : convertedOpportunityIds) {
                Opportunity opportunityToUpdate = new Opportunity(
                    Id = eachOpportunityId,
                    Source__c = LEAD_SOURCE,
                    CampaignId = eachcampaignId
                );
                OpportunitiesHandler.isUpdateRestricted = true;
                uow.registerDirty(opportunityToUpdate);
            }
        }
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
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return Leads - List of Leads
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (Leads.constructorMock != null) {
                return (fflib_SObjects) Leads.constructorMock.construct(objectList);
            }
            return new Leads((List<SObject>) objectList);
        }
    }

    /**
     * @description It is used to update Last Inbound Date/Time for Lead.
     */
    public void updateLastInboundDateTime() {
        for (Lead eachLead : (List<Lead>) getRecords()) {
            if (eachLead.Primary_Campaign_Source__c != null) {
                eachLead.Last_Inbound_Date_Time__c = System.now();
            }
        }
    }
    /**
     * @description It is to update the inbound ingestion logs to completed status on lead creation.
     */
    public void updateInboundIngestionLogsToCompletedStatusOnSSMOLeadCreation() {
        Set<Id> inboundInjestionLogIds = new Set<Id>();
        for (Lead eachLead : (List<Lead>) getRecords()) {
            if (eachLead.Inbound_Ingestion_Log__c != null && eachLead.SSMO_UUID__c != null) {
                inboundInjestionLogIds.add(eachLead.Inbound_Ingestion_Log__c);
            }
        }
        if (!inboundInjestionLogIds.isEmpty()) {
            InboundIngestionLogs.updateIngestionLogsWithSucessOrFailureStatus(
                inboundInjestionLogIds,
                'Completed',
                '',
                '',
                ''
            );
        }
    }
}