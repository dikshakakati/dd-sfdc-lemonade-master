/**
 * @author atg
 * @date   06/30/2022
 * @description This is the service implementation class for Business_Reference__c integration.
 */
public inherited sharing class BusReferenceIntegrationServiceImpl implements IBusReferenceIntegrationService {
    private static final String AGGREGATE_ACCOUNTID_FIELD_ALIAS = 'accountId';
    private static final String CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_PROCESS_DRIVE_WITHHOLDING_STATIC_CONFIG = 'Corp_Acc_Size_To_ProcessDriveWithholding';
    private static final String EVENT_TOPIC_PROCESS_DRIVE_WITHHOLDING = 'PROCESS_DRIVE_WITHHOLDING';
    private static final String FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT_STATIC_CONFIG = 'Franchise_Acc_Withholding_Query_Limit';
    private Map<Id, String> corporateAccountIdToMPBzId;
    private Integer corporateAccountIdsChunkSizeToProcessDriveWithholding;
    private Set<Id> corporateAccountIdsWithWithholdingFranchiseAccount;
    private Map<Id, Id> franchiseAccountIdToCorporateAccountId;
    private Integer franchiseAccountWithholdingQueryLimit;
    private Set<String> mpBzIds;
    private enum EventTopics {
        EVENTTOPIC_PROCESS_DRIVE_WITHHOLDING
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_PROCESS_DRIVE_WITHHOLDING => EventTopics.EVENTTOPIC_PROCESS_DRIVE_WITHHOLDING
    };

    /**
     * @description Default constructor for this class.
     */
    public BusReferenceIntegrationServiceImpl() {
        corporateAccountIdToMPBzId = new Map<Id, String>();
        corporateAccountIdsWithWithholdingFranchiseAccount = new Set<Id>();
        franchiseAccountIdToCorporateAccountId = new Map<Id, Id>();
        mpBzIds = new Set<String>();
        collectStaticConfigurations();
    }

    /**
     * @description create platform Events to integrate Business_Reference__c objects
     * @param businessReferenceList
     * @param topic
     */
    public void createIntegrationPlatformEvents(
        List<Business_Reference__c> businessReferenceList,
        String topic
    ) {
        //LEM-4502 Don't call commit work for each platform event.
        List<String> payloadsList = new List<String>();
        for (Business_Reference__c businessReference : businessReferenceList) {
            payloadsList.add(
                JSON.serialize(
                    new List<BusinessReferenceIntegration>{
                        new BusinessReferenceIntegration(businessReference)
                    }
                )
            );
        }
        ExternalNotifierEventsService.publishEventsFromList(topic, payloadsList);
    }

    /**
     * @description It is used to handle Notifier Events to further process
     * Franchise Form Request Ids from the received payload.
     * @JIRA# LEM-9551
     * @param events
     */
    public void handleNotifierEvents(List<Notifier__e> events) {
        Set<Id> corporateAccountIds = new Set<Id>();
        Set<Id> recordIdsByPayload;
        for (Notifier__e eachEvent : events) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENTTOPIC_PROCESS_DRIVE_WITHHOLDING {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    corporateAccountIds.addAll(recordIdsByPayload);
                }
            }
        }
        initiateExternalIdUpdateOnBusinessReference(corporateAccountIds);
    }

    /**
     * @description It initiates drive withholding process on the passed corporateAccountIds.
     * @JIRA# LEM-9551
     * @param corporateAccountIds
     */
    public void processDriveWithholding(List<Id> corporateAccountIds) {
        Set<Id> accountIds = new Set<Id>();
        accountIds.addAll(corporateAccountIds);
        initiateExternalIdUpdateOnBusinessReference(accountIds);
    }

    /**
     * @description It initiates External Id field update on business reference associated with DriveDB Xrefs
     * having 'Active' Franchise Agreements with Contracts having Payment Method as 'Withholding'
     * using the passed Corporate Account Ids.
     * @JIRA# LEM-9551
     * @param corporateAccountIds
     */
    private void initiateExternalIdUpdateOnBusinessReference(Set<Id> corporateAccountIds) {
        collectMpBzIds(corporateAccountIds);
        if (mpBzIds.isEmpty()) {
            return;
        }
        toggleDriveWithholdingBannerMessageIndicator(corporateAccountIds);
        collectFranchiseAccountIds(corporateAccountIds);
        updateExternalIdOnDriveDBBusinessReference();
        collectCorporateAccountIdsWithWithholdingFranchiseAccount();
        // Removed unprocessed corporate account Ids
        corporateAccountIds.removeAll(corporateAccountIdsWithWithholdingFranchiseAccount);
        // Update drive Withholding banner message indicator
        if (!corporateAccountIds.isEmpty()) {
            toggleDriveWithholdingBannerMessageIndicator(corporateAccountIds);
        }
    }

    /**
     * @description A common method to commit unit of work.
     * @param unitOfWork
     */
    private void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
        }
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.corporateAccountIdsChunkSizeToProcessDriveWithholding = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(
                    CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_PROCESS_DRIVE_WITHHOLDING_STATIC_CONFIG
                )
                .Configuration_Value__c
        );
        this.franchiseAccountWithholdingQueryLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It is used to collect Contract's MP Bz Ids using the passed corporateAccountIds.
     * @JIRA# LEM-9551
     * @param corporateAccountIds
     */
    private void collectMpBzIds(Set<Id> corporateAccountIds) {
        for (
            Contract eachContract : ContractsSelector.newInstance()
                .selectActivatedWithholdingContractsByAccountIds(corporateAccountIds)
        ) {
            if (String.isBlank(eachContract.MP_Bz_Id__c)) {
                continue;
            }
            corporateAccountIdToMPBzId.put(eachContract.AccountId, eachContract.MP_Bz_Id__c);
            mpBzIds.add(eachContract.MP_Bz_Id__c);
        }
    }

    /**
     * @description It is used to collect corporate account Ids having Withholding
     * franchise Accounts.
     * @JIRA# LEM-9551, LEM-10356
     */
    private void collectCorporateAccountIdsWithWithholdingFranchiseAccount() {
        for (
            Aggregate eachAggregate : XrefsSelector.newInstance()
                .selectCountOfDriveDBXrefsBySalesforceAccountNameAndExternalId(
                    franchiseAccountIdToCorporateAccountId.keySet(),
                    mpBzIds
                )
        ) {
            corporateAccountIdsWithWithholdingFranchiseAccount.add(
                (Id) eachAggregate.get(AGGREGATE_ACCOUNTID_FIELD_ALIAS)
            );
        }
        if (!corporateAccountIdsWithWithholdingFranchiseAccount.isEmpty()) {
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_PROCESS_DRIVE_WITHHOLDING => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        corporateAccountIdsWithWithholdingFranchiseAccount,
                        corporateAccountIdsChunkSizeToProcessDriveWithholding
                    )
                }
            );
        }
    }

    /**
     * @description It collects franchise Account Ids associated with Withholding Contracts.
     * @JIRA# LEM-9551, LEM-10356
     * @param corporateAccountIds
     */
    private void collectFranchiseAccountIds(Set<Id> corporateAccountIds) {
        for (
            Agreement__c eachAgreement : AgreementsSelector.newInstance()
                .selectWithholdingCorporateAccountsByActiveAgreements(
                    corporateAccountIds,
                    franchiseAccountWithholdingQueryLimit
                )
        ) {
            franchiseAccountIdToCorporateAccountId.put(
                eachAgreement.Account__c,
                eachAgreement.Contract__r.AccountId
            );
        }
    }

    /**
     * @description It toggles MP Bz Id update banner indicator on the passed corporate Accounts.
     * @JIRA# LEM-9551
     * @param corporateAccountIds
     */
    private void toggleDriveWithholdingBannerMessageIndicator(Set<Id> corporateAccountIds) {
        fflib_ISObjectUnitOfWork uowToUpdateCorporateAccount = Application.UNITOFWORK.newInstance();
        for (Account eachAccount : AccountsSelector.newInstance().selectById(corporateAccountIds)) {
            uowToUpdateCorporateAccount.registerDirty(
                new Account(
                    Id = eachAccount.Id,
                    Show_MP_Bz_Id_Update_Banner__c = !eachAccount.Show_MP_Bz_Id_Update_Banner__c
                )
            );
        }
        commitWork(uowToUpdateCorporateAccount);
    }

    /**
     * @description It is used to update External Id field on DriveDB Business Reference
     * with the MP Bz Id value populated on Contract using the franchiseAccountIdToCorporateAccountId.
     * @JIRA# LEM-9551, LEM-10356
     */
    private void updateExternalIdOnDriveDBBusinessReference() {
        fflib_ISObjectUnitOfWork uowToUpdateBusinessReference = Application.UNITOFWORK.newInstance();
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectDriveDBXrefsBySalesforceAccountNameAndExternalId(
                    franchiseAccountIdToCorporateAccountId.keySet(),
                    mpBzIds,
                    franchiseAccountWithholdingQueryLimit
                )
        ) {
            if (
                franchiseAccountIdToCorporateAccountId.containsKey(
                    eachXref.Salesforce_Account_Name__c
                )
            ) {
                uowToUpdateBusinessReference.registerDirty(
                    new Business_Reference__c(
                        Id = eachXref.Business_Reference__c,
                        External_Id__c = corporateAccountIdToMPBzId.get(
                            franchiseAccountIdToCorporateAccountId
                                .get(eachXref.Salesforce_Account_Name__c)
                        )
                    )
                );
            }
        }
        commitWork(uowToUpdateBusinessReference);
    }
}