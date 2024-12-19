/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Service Implementation class for InstantIngestionOnboardingService.
 *
 */
@SuppressWarnings('PMD.ExcessiveClassLength,PMD.CyclomaticComplexity,PMD.NcssTypeCount')
public inherited sharing class InstantIngestionOnboardingServiceImpl implements IInstantIngestionOnboardingService {
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED = 'EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED';
    private static final String EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS = 'EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS';
    private static final String EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY = 'EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY';
    private static final String LOG_DOMAIN = 'Instant Ingestion';
    private static final String LOG_INBOUND_INGESTION_RECORDS_INSERT_FAILED = 'Creation on inbound ingestion records failed';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED_RESSMO = 'EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED_RESSMO';
    private static final String STATUS_CONTRACT_SIGNED = 'Contract Signed';
    private static final String SUCESS_STATUS = 'Success';
    private static final String FAILED_STATUS = 'Failed';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_INACTIVE = 'Inactive';
    private static final String SOURCE_SSMO = 'SSMO';
    private static final String QUOTE_DEAL_TERMS_STANDARD = 'Standard';
    private static final String SOURCE_RESSMO = 'RESSMO';
    private static final String ONBOARDING_SCENARIO_NSE = 'NSE';
    private static final String INACTIVE_REASON_SUBMITTED = 'Submitted';
    private static final String REP_COLLECTING_ON_MX_BEHALF_YES = 'Yes';
    private static final String FIELD_POS_INTEGRATION_TYPE = 'POS_Integration_Type__c';
    private static final String MENU_SETUP_METHOD = 'Create New Menu(s) using Menu Source';
    private static final String MENU_TO_BE_COMPLETED_BY = 'DoorDash Onboarding Team';
    private static final String FIELD_ORDER_PROTOCOL = 'Order_Protocol__c';
    private static final String POS_ORDER_PROTOCOL = 'POS';
    private static final String COUNTRY_CANADA = 'Canada';
    private static final String CONTACT_ROLE_CONTRACT_SIGNATORY = 'Contract Signatory';
    private static final String CONTACT_ROLES_FOR_CANADA_KYC = 'Contract Signatory;Business Owner;Business Director';
    private static final String FIELD_SALES_NOTE_FOR_MENU_TEAM = 'Sales_Notes_for_Menu_Team__c';
    Map<String, Inbound_Ingestion_Log__c> inboundIngestionLogByUUID = new Map<String, Inbound_Ingestion_Log__c>();
    private static final String MENU_UI_TYPE_RESTAURANT = 'Restaurant';
    private static final String GENERIC_LOG_DOMAIN = 'SSMO';
    private static final String LOG_SERVICE_NAME_RESSMO_FULLSERVE = 'IIL RESSMO Full Serve';
    private static final String LOG_SERVICE_NAME_RESSMO_MULTILOC = 'IIL RESSMO Multiloc';
    private static final String LOG_SERVICE_NAME_RESSMO_UPDATE_QUOTE_MXONBOARDING = 'IIL RESSMO Update Quote to Contract Signed and Mx Onboarding Link to Success';
    private static final String RESSMO_FULLSERVE_MESSAGES_UUID = 'IIL RESSMO Full Serve Message for UUID {UUIDkeyset}';
    private static final String RESSMO_MULTILOC_MESSAGES_UUID = 'IIL RESSMO Multiloc Message for UUID {UUIDkeyset}';
    private static final String RESSMO_UPDATE_QUOTE_MXONBOARDING_MESSAGES_UUID = 'IIL RESSMO Update Quote to Contract Signed and Mx Onboarding Link to Success Message for UUID {UUIDkeyset}';
    private static final String LOG_RESSMO_CATEGORY = '';
    private static final String LOG_RESSMO_LOG_LEVEL_INFO = 'INFO';

    private enum EVENT_TOPICS {
        EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED_RESSMO,
        EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD,
        EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD,
        EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD,
        EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD,
        EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD,
        EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED,
        EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS,
        EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY
    }
    Business_Vertical__c businessVerticalRx = new Business_Vertical__c();
    private static Map<String, EVENT_TOPICS> eventTopicMap = new Map<String, EVENT_TOPICS>{
        'EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED_RESSMO' => EVENT_TOPICS.EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED_RESSMO,
        'EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD' => EVENT_TOPICS.EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD,
        'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD' => EVENT_TOPICS.EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD,
        'EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD' => EVENT_TOPICS.EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD,
        'EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD' => EVENT_TOPICS.EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD,
        'EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD' => EVENT_TOPICS.EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD,
        'EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED' => EVENT_TOPICS.EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED,
        'EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS' => EVENT_TOPICS.EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS,
        'EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY' => EVENT_TOPICS.EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY
    };
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    Set<Id> recordIdsByPayload;
    Map<String, String> sourceByUUID = new Map<String, String>();
    List<Inbound_Ingestion_Log__c> inboundIngestionLogs = new List<Inbound_Ingestion_Log__c>();
    Map<Id, Opportunity> existingOpportunityByAccountId = new Map<Id, Opportunity>();
    Map<String, Account> existingAccountByBusinessId = new Map<String, Account>();
    Map<Id, SBQQ__Quote__c> quotesByOpportunityId = new Map<Id, SBQQ__Quote__c>();
    Map<String, String> integrationTypeByUUID = new Map<String, String>();
    Boolean isNonMxPortalAmendmentEvent = false;
    Savepoint savePointForRollback;
    fflib_ISObjectUnitOfWork unitOfWork;
    private static final String SELF_SERVING_ONBOARDING_SERVICE = 'selfServiceOnboardingService';
    private static final String CPQ_WS = 'CPQ';
    private static final String CLASS_NAME = 'InstantIngestionOnboardingServiceImpl';
    private static final String PAYLOAD_DISTRIBUTOR_FOR_ACCOUNTS_AND_XREF_BIZREF = 'payloadDistributorForAccountsAndXrefsBizRefs';
    private static final String PAYLOAD_DISTRIBUTOR_FOR_CONTACT_AND_ACR = 'payloadDistributorForContactsAndACRs';
    private static final String PAYLOAD_DISTRIBUTOR_FOR_OPPORTUNITIES = 'payloadDistributorForOpportunities';
    private static final String PAYLOAD_DISTRIBUTOR_FOR_QUOTES_AND_QUOTELINES = 'payloadDistributorForQuotesAndQuoteLines';
    private static final String PAYLOAD_DISTRIBUTOR_FOR_RESSMO_ACCOUNT_AND_XREF_BIZREF = 'payloadDistributorForRESSMOAccountsAndXrefsBizRefs';
    private static final String UPDATE_QUOTE_TO_CONTRACT_SIGNED_AND_MXLINK_TO_SUCCESS = 'updateQuoteToContractSignedAndMxOnboardingLinkToSuccess';
    private static final String STATUS_FAILED = 'Failed';
    private static final String STATUS_SUCCESS = 'Success';
    private static Map<String, String> payloadMethodsToStepMap = new Map<String, String>{
        PAYLOAD_DISTRIBUTOR_FOR_ACCOUNTS_AND_XREF_BIZREF => '1',
        PAYLOAD_DISTRIBUTOR_FOR_CONTACT_AND_ACR => '2',
        PAYLOAD_DISTRIBUTOR_FOR_OPPORTUNITIES => '3',
        PAYLOAD_DISTRIBUTOR_FOR_QUOTES_AND_QUOTELINES => '4',
        PAYLOAD_DISTRIBUTOR_FOR_RESSMO_ACCOUNT_AND_XREF_BIZREF => '5',
        UPDATE_QUOTE_TO_CONTRACT_SIGNED_AND_MXLINK_TO_SUCCESS => '6'
    };
    private static final String BUSINESS_ERROR_MESSAGE = 'SSMO onboarding event has been Failed';
    private static final String COMMITWORK_MESSAGE = 'Error occured during commit work';
    private static final String SUCCESS_MESSAGE = 'SSMO onboarding event has been completed successfully';
    List<Database.SaveResult> saveResultsDetails = new List<Database.SaveResult>();
    List<String> errorsList = new List<String>();
    String methodName = '';
    /**
     * @description Constructor for InstantIngestionOnboardingServiceImpl.
     */
    public InstantIngestionOnboardingServiceImpl() {
        this.businessVerticalRx = InstantIngestionRecordsGetterService.getRxBusinessVertical();
        this.recordIdsByPayload = recordIdsByPayload;
        this.existingOpportunityByAccountId = existingOpportunityByAccountId;
        this.existingAccountByBusinessId = existingAccountByBusinessId;
        this.quotesByOpportunityId = quotesByOpportunityId;
        this.sourceByUUID = sourceByUUID;
        this.methodName = methodName;
    }
    /**
     * @description It is used to subscribe to the instant ingestor platform event.
     * @JIRA# LEM-14648
     * @param events
     */
    public void handleInstantIngestorEvents(List<Instant_Ingestor__e> events) {
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID = new Map<String, InstantIngestionPayloadParser>();
        try {
            savePointForRollback = Database.setSavePoint();
            for (Instant_Ingestor__e eachEvent : events) {
                if (String.isBlank(eachEvent.Payload__c)) {
                    continue;
                }
                this.recordIdsByPayload = (Set<Id>) JSON.deserialize(
                    eachEvent.Payload__c,
                    Set<Id>.class
                );
                if (this.recordIdsByPayload.isEmpty()) {
                    return;
                }
                payLoadWrapperByIngestionLogUUID = getParsedPayloadByUniqueInboundIngestionLogs(
                    this.recordIdsByPayload
                );
                switch on eventTopicMap.get(eachEvent.Topic__c) {
                    when EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD {
                        payloadDistributorForRESSMOAccountsAndXrefsBizRefs(
                            payLoadWrapperByIngestionLogUUID
                        );
                    }
                    when EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED_RESSMO {
                        updateQuoteToContractSignedAndMxOnboardingLinkToSuccess(
                            payLoadWrapperByIngestionLogUUID
                        );
                    }
                    when EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD {
                        isNonMxPortalAmendmentEvent = true;
                        payloadDistributorForAccountsAndXrefsBizRefs(
                            payLoadWrapperByIngestionLogUUID,
                            sourceByUUID
                        );
                    }
                    when EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD {
                        isNonMxPortalAmendmentEvent = true;
                        payloadDistributorForContactsAndACRs(
                            payLoadWrapperByIngestionLogUUID,
                            sourceByUUID
                        );
                    }
                    when EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD {
                        isNonMxPortalAmendmentEvent = true;
                        payloadDistributorForOpportunities(
                            payLoadWrapperByIngestionLogUUID,
                            sourceByUUID,
                            inboundIngestionLogByUUID
                        );
                    }
                    when EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD {
                        payloadDistributorForQuotesAndQuoteLines(payLoadWrapperByIngestionLogUUID);
                    }
                    when EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED {
                        InstantIngestionQuoteAndQLIService.updateInstantIngestionQuotesToOrdered(
                            this.recordIdsByPayload
                        );
                    }
                    when EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS {
                        InstantIngestionQuoteAndQLIService.updateInstantIngestionQuotesForSlackNotifications(
                            this.recordIdsByPayload
                        );
                    }
                    when EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY {
                        InstantIngestionQuoteAndQLIService.updateInstantIngestionQuotesToPrimaryAndContractSigned(
                            this.recordIdsByPayload
                        );
                    }
                }
            }
        } catch (Exception recordsProcessingExceptions) {
            Database.rollback(savePointForRollback);
            if (errorsList.isEmpty()) {
                logUncaughtIngestionExceptionToInboundIngestionRecord(recordsProcessingExceptions);
            } else {
                logSaveResultIngestionExceptionToInboundIngestionRecord(saveResultsDetails);
            }
        }
    }

    /**
     * @description Update the Quote to Contract Signed and Mx Onboarding link to success
     * @author VenkateshDD | 08-05-2024
     * @param payLoadWrapperByIngestionLogUUID
     **/
    public void updateQuoteToContractSignedAndMxOnboardingLinkToSuccess(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        this.methodName = UPDATE_QUOTE_TO_CONTRACT_SIGNED_AND_MXLINK_TO_SUCCESS;
        savePointForRollback = Database.setSavePoint();
        unitOfWork = Application.UNITOFWORK.newInstance();

        List<Account> storeAccounts = AccountsSelector.newInstance()
            .selectAccountsByUniqueIdentifiersAndRecordType(
                payLoadWrapperByIngestionLogUUID.keyset(),
                STORE_RECORD_TYPE_ID
            );
        Map<String, Account> storesByUUId = new Map<String, Account>();
        for (Account acc : storeAccounts) {
            storesByUUId.put(acc.Unique_Identifier__c, acc);
        }

        List<SBQQ__Quote__c> quotes = QuotesSelector.newInstance()
            .selectQuotesbyUniqueIdentifiers(payLoadWrapperByIngestionLogUUID.keyset());

        fflib_ISObjectUnitOfWork unitOfWorkOpp = Application.UNITOFWORK.newInstance();
        for (SBQQ__Quote__c quote : quotes) {
            if(quote.SBQQ__Primary__c == false){
                continue;
            }
            InstantIngestionPayloadParser payload = payLoadWrapperByIngestionLogUUID.get(
                quote.Unique_Identifier__c
            );

            updateQuoteToContractSigned(
                quote,
                payload,
                storesByUUId.get(quote.Unique_Identifier__c)
            );
            updateOpportunityRESSMOLink(quote, payload, unitOfWorkOpp);
        }

        updateMxOnboardingLinkSuccess(payLoadWrapperByIngestionLogUUID);

        updateIILSuccessAndTagStoreAccount(payLoadWrapperByIngestionLogUUID);

        unitOfWork.commitWork();
        unitOfWorkOpp.commitWork();

    }

    /**
    * @description Updates the Inbound Ingestion Log to success and store
    * @author VenkateshDD | 11-06-2024
    * @param payLoadWrapperByIngestionLogUUID
    **/
    private void updateIILSuccessAndTagStoreAccount(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ){
        List<Account> storeAccounts = AccountsSelector.newInstance().selectAccountsByUniqueIdentifiersAndRecordType(payLoadWrapperByIngestionLogUUID.keySet(), STORE_RECORD_TYPE_ID);
        Map<String, Id> uuidToStoreAccountId = new Map<String, Id>();

        for(Account store : storeAccounts){
            uuidToStoreAccountId.put(store.Unique_Identifier__c, store.Id);
        }

        for(Inbound_ingestion_Log__c iil : this.inboundIngestionLogs){
            unitOfWork.registerDirty(
                new Inbound_ingestion_Log__c(Id = iil.Id, Status__c = SUCESS_STATUS, Store_Account__c = uuidToStoreAccountId.get(iil.UUID__c))
            );
        }

        String logMessage = RESSMO_UPDATE_QUOTE_MXONBOARDING_MESSAGES_UUID.replace('{UUIDkeyset}', String.join(new List<String>(payLoadWrapperByIngestionLogUUID.keyset()),','));
        GenericLoggerService.publish(
                    GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_UPDATE_QUOTE_MXONBOARDING,GENERIC_LOG_DOMAIN,GenericLogEntry.SeverityLevel.MEDIUM)
                    .logMessage(logMessage).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_INFO)
                );
    }

    /**
     * @description
     * @author VenkateshDD | 10-08-2024
     * @param quote
     * @param payload
     * @param storeAccount
     **/
    private void updateQuoteToContractSigned(
        SBQQ__Quote__c quote,
        InstantIngestionPayloadParser payload,
        Account storeAccount
    ) {
        Opportunity updateOpp = new Opportunity(Id = quote.SBQQ__Opportunity2__c,Store_Id__c = payload.store.storeId);
        quote.Integration_Source__c = SOURCE_RESSMO;
        quote.SBQQ__Status__c = STATUS_CONTRACT_SIGNED;
        quote.Deal_Terms__c = QUOTE_DEAL_TERMS_STANDARD;
        quote.SubmittedDate__c = System.today();
        quote.Contract_Signed_Date__c = Date.today();
        quote.Signed_Contract_link__c = payload.store.vendorContractRecord;
        quote.RESSMO_Payload__c = updateQuoteRESSMOPayload(quote.RESSMO_Payload__c, storeAccount);
        unitOfWork.registerDirty(updateOpp);
        unitOfWork.registerDirty(quote);
    }

    /**
     * @description This method registers for the update of RESSMO Link on Opportunity
     * @author VenkateshDD | 10-08-2024
     * @param quote
     * @param payload
     * @param unitOfWork
     **/
    private void updateOpportunityRESSMOLink(
        SBQQ__Quote__c quote,
        InstantIngestionPayloadParser payload,
        fflib_ISObjectUnitOfWork unitOfWork
    ) {
        if (
            quote.SBQQ__Opportunity2__r.RESSMO_Link__c == payload.store.merchantLink &&
            quote.SBQQ__Opportunity2__r.Accepted_Partnership_Details__c ==
            payload.store.isPartnershipDetailsAccepted &&
            payload.createdAt.date() == quote.SBQQ__Opportunity2__r.closeDate
        ) {
            return;
        }
        Boolean isPartnershipDetailsAccepted = payload.store.isPartnershipDetailsAccepted == null
            ? quote.SBQQ__Opportunity2__r.Accepted_Partnership_Details__c
            : payload.store.isPartnershipDetailsAccepted;
        String ressmoLink = String.isBlank(payload.store.merchantLink)
            ? quote.SBQQ__Opportunity2__r.RESSMO_Link__c
            : payload.store.merchantLink;
        unitOfWork.registerDirty(
            new Opportunity(
                Id = quote.SBQQ__Opportunity2__c,
                RESSMO_Link__c = ressmoLink,
                Accepted_Partnership_Details__c = isPartnershipDetailsAccepted,
                CloseDate = payload.createdAt.date()
            )
        );
    }

    /**
     * @description this method will update the posIntegrationType field value in the quote RESSMO Payload
     * @author VenkateshDD | 08-29-2024
     * @param jsonString
     * @param storeAccount
     * @return String
     **/
    private String updateQuoteRESSMOPayload(String jsonString, Account storeAccount) {
        Map<String, Object> jsonObject = new Map<String, Object>();
        if (jsonString != null && jsonString != '') {
            jsonObject = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        }
        jsonObject.put(FIELD_POS_INTEGRATION_TYPE, storeAccount.POS_Integration_Type__c);
        jsonObject.put(FIELD_SALES_NOTE_FOR_MENU_TEAM, storeAccount.Sales_Notes_for_Menu_Team__c);
        return JSON.serialize(jsonObject);
    }

    /**
     * @description This method is responsible for distributing the payload for RESSMO accounts and Xrefs BizRefs.
     * @param payLoadWrapperByIngestionLogUUID The payload to be distributed.
     */
    public void payloadDistributorForRESSMOAccountsAndXrefsBizRefs(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        this.methodName = PAYLOAD_DISTRIBUTOR_FOR_RESSMO_ACCOUNT_AND_XREF_BIZREF;
        savePointForRollback = Database.setSavePoint();
        initiateRESSMOFullServe(payLoadWrapperByIngestionLogUUID);
        initiateRESSMOMultiLoc(payLoadWrapperByIngestionLogUUID);

        InstantIngestorEventsService.publishEvents(
            new Map<String, String>{
                EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED_RESSMO => JSON.serialize(
                    this.recordIdsByPayload
                )
            }
        );
    }

    /**
     * @description will process Multiloc or New Store creation
     * @author VenkateshDD | 08-05-2024
     * @param payLoadWrapperByIngestionLogUUID
     **/
    public void initiateRESSMOMultiLoc(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        this.existingAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessAccounts(
            payLoadWrapperByIngestionLogUUID,
            new Map<String, SSOBOnboardingPayloadParser>()
        );

        Map<String, InstantIngestionPayloadParser> payloadWrapperToCreateStoreAccount = new Map<String, InstantIngestionPayloadParser>();

        for (InstantIngestionPayloadParser payload : payLoadWrapperByIngestionLogUUID.values()) {
            if (payload.store.isAdditionalStore) {
                payloadWrapperToCreateStoreAccount.put(payload.uuid, payload);
            }
        }

        if (!payloadWrapperToCreateStoreAccount.isEmpty()) {
            initiateStoreAccountsCreationByBusinessId(payloadWrapperToCreateStoreAccount);
            initiateXrefsCreationByBusinessId(payloadWrapperToCreateStoreAccount);
            initiateContactCreationByBusinessId(payloadWrapperToCreateStoreAccount);
            initiateACRCreation(payloadWrapperToCreateStoreAccount);
            createMxOnboardingLink(payloadWrapperToCreateStoreAccount);

            String logMessage = RESSMO_MULTILOC_MESSAGES_UUID.replace('{UUIDkeyset}', String.join(new List<String>(payLoadWrapperByIngestionLogUUID.keyset()),','));
            GenericLoggerService.publish(
                        GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_MULTILOC,GENERIC_LOG_DOMAIN,GenericLogEntry.SeverityLevel.MEDIUM)
                        .logMessage(logMessage).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_INFO)
                    );
        }
    }

    /**
     * @description this will create Mx onboarding link against the contract which is used to work order generation
     * @author VenkateshDD | 08-20-2024
     * @param payLoadWrapperByIngestionLogUUID
     **/
    private void createMxOnboardingLink(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        this.existingAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessAccounts(
            payLoadWrapperByIngestionLogUUID,
            new Map<String, SSOBOnboardingPayloadParser>()
        );

        Set<String> accIds = new Set<String>();
        for (Account acc : this.existingAccountByBusinessId.values()) {
            accIds.add(acc.Id);
        }
        Map<Id, Account> bizAccountsWithContract = new Map<Id, Account>(
            AccountsSelector.newInstance().getUltimateParentAccount(accIds)
        );

        Map<String, Contract> contractByContractNumber = getContractsMapByContractNumber(payLoadWrapperByIngestionLogUUID);

        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        for (InstantIngestionPayloadParser payload : payLoadWrapperByIngestionLogUUID.values()) {
            List<Contract> contracts = new List<Contract>();
            if (payload.store.contractNumber != null && payload.store.contractNumber != '') {
                contracts.add(contractByContractNumber.get(payload.store.contractNumber));
            } else {
                Account bizAcc = bizAccountsWithContract.get(
                    this.existingAccountByBusinessId.get(payload.business.businessId).Id
                );
                Contract cont;
                cont = bizAcc.contracts[0];
                contracts.addAll(bizAcc.contracts);
            }
            registerMxOnboardingLinks(payload, contracts, uow);
        }
        uow.commitWork();
    }

    /**
    * @description will return the key as contract number and value as the contract
    * @author VenkateshDD | 10-30-2024
    * @param payLoadWrapperByIngestionLogUUID
    * @return Map<String, Contract>
    **/
    private static Map<String, Contract> getContractsMapByContractNumber(Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID){
        Set<String> contractNumbers = new Set<String>();

        for (InstantIngestionPayloadParser payload : payLoadWrapperByIngestionLogUUID.values()) {
            if (String.isNotBlank(payload.store.contractNumber)) {
                contractNumbers.add(payload.store.contractNumber);
            }
        }

        Map<String, Contract> contractByContractNumber = new Map<String, Contract>();
        if(contractNumbers.isEmpty()){
            return contractByContractNumber;
        }

        for (
            Contract cont : ContractsSelector.newInstance().selectByContractNumber(contractNumbers)
        ) {
            contractByContractNumber.put(cont.ContractNumber, cont);
        }
        return contractByContractNumber;
    }

    /**
    * @description This method is respnsible for registering Mx Onboarding link based on contract
    * @author VenkateshDD | 10-30-2024
    * @param payload
    * @param contracts
    * @param uow
    **/
    private static void registerMxOnboardingLinks(InstantIngestionPayloadParser payload, List<Contract> contracts, fflib_ISObjectUnitOfWork uow){
        for(Contract cont : contracts){
            uow.registerNew(
                new Mx_Onboarding_Link__c(
                    Business_Account__c = cont.AccountId,
                    Contract__c = cont.Id,
                    Payload__c = '{}',
                    Source__c = SOURCE_RESSMO,
                    Onboarding_Scenario__c = ONBOARDING_SCENARIO_NSE,
                    Rep_Collecting_On_Mx_Behalf__c = REP_COLLECTING_ON_MX_BEHALF_YES,
                    Payment_Method__c = cont.Payment_Method__c,
                    Status__c = STATUS_ACTIVE,
                    Inactive_Reason__c = INACTIVE_REASON_SUBMITTED,
                    Record_Creation_Status__c = '',
                    UUID__C = payload.uuid
                )
            );
        }
    }

    /**
     * @description update the record creation status to success on Mx onboarding link
     * @author VenkateshDD | 08-05-2024
     * @param payloadWrapperToCreateStoreAccount
     **/
    private void updateMxOnboardingLinkSuccess(
        Map<String, InstantIngestionPayloadParser> payloadWrapperToCreateStoreAccount
    ) {
        //Set<String> uuids){
        List<Mx_Onboarding_Link__c> mxOnboardingLinks = MxOnboardingLinksSelector.newInstance()
            .selectByUUID(payloadWrapperToCreateStoreAccount.keySet());

        if (mxOnboardingLinks.isEmpty()) {
            return;
        }

        Map<String, String> storeIdsToUniqueIdentifierMap = new Map<String, String>();

        for (String uuid : payloadWrapperToCreateStoreAccount.keyset()) {
            InstantIngestionPayloadParser payload = payloadWrapperToCreateStoreAccount.get(uuid);
            storeIdsToUniqueIdentifierMap.put(payload.store.storeId, uuid);
        }
        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectActiveXrefByExternalIdsAndExternalSourceMDSAndStoreRecordType(
                storeIdsToUniqueIdentifierMap.keySet()
            );

        List<Account> stores = new List<Account>();
        for (Xref__c xref : xrefs) {
            Account storeAccount = xref.Salesforce_Account_Name__r;
            storeAccount.Mx_Onboarding_Link_Id__c = storeIdsToUniqueIdentifierMap.get(
                xref.External_ID__c
            );
            String orderProtocolValue = (String) storeAccount.get(FIELD_ORDER_PROTOCOL);
            if (orderProtocolValue == null || orderProtocolValue != POS_ORDER_PROTOCOL) {
                storeAccount.Menu_Setup_Method__c = MENU_SETUP_METHOD;
                storeAccount.Menu_to_be_Completed_By__c = MENU_TO_BE_COMPLETED_BY;
            }
            stores.add(storeAccount);
        }
        unitOfWork.registerDirty(stores);
        Map<String, Account> storesByUUID = new Map<String, Account>();
        for (Account store : stores) {
            storesByUUID.put(store.Unique_Identifier__c, store);
        }
        for (Mx_Onboarding_Link__c mxol : mxOnboardingLinks) {
            mxol.Status__c = STATUS_INACTIVE;
            mxol.Inactive_Reason__c = INACTIVE_REASON_SUBMITTED;
            mxol.Record_Creation_Status__c = SUCESS_STATUS;
            mxol.Payload__c = updatePayloadforRESSMOSuccess(
                mxol.Payload__c,
                payloadWrapperToCreateStoreAccount.get(mxol.UUID__c),
                storesByUUID.get(mxol.UUID__c)
            );
            unitOfWork.registerDirty(mxol);
        }
    }

    /**
     * @description
     * @author rishab.goyal | 08-12-2024
     * @param payloadfromMxOnbaringLink
     * @param instantIngestionPayloadParser
     * @param store
     * @return string
     **/
    private string updatePayloadforRESSMOSuccess(
        String payloadfromMxOnbaringLink,
        InstantIngestionPayloadParser instantIngestionPayloadParser,
        Account store
    ) {
        Map<String, Object> objectMap = (Map<String, Object>) JSON.deserializeUntyped(
            payloadfromMxOnbaringLink
        );
        Map<String, Object> workOrderInformationObj = new Map<String, Object>();
        workOrderInformationObj.put('Activated_Centrally_AC__c', store.Activated_Centrally_AC__c);
        workOrderInformationObj.put('Order_Protocol__c', store.Order_Protocol__c);
        workOrderInformationObj.put(
            'Sales_Notes_for_Menu_Team__c',
            store.Sales_Notes_for_Menu_Team__c
        );
        workOrderInformationObj.put(
            'Business_ID__c',
            instantIngestionPayloadParser.business.businessId
        );
        workOrderInformationObj.put(FIELD_POS_INTEGRATION_TYPE, store.POS_Integration_Type__c);
        workOrderInformationObj.put('storeAccountIds', store.Id);
        objectMap.put('workOrderInformation', workOrderInformationObj);
        return JSON.serialize(objectMap);
    }

    /**
     * @description Based on SF StoreAccountId
     * @author VenkateshDD | 08-05-2024
     * @param payLoadWrapperByIngestionLogUUID
     **/
    public void initiateRESSMOFullServe(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Set<String> fullServeUUIDs = new Set<String>();
        for (
            InstantIngestionPayloadParser eachPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            if (!eachPayload.store.isAdditionalStore) {
                fullServeUUIDs.add(eachPayload.uuid);
            }
        }
        if (fullServeUUIDs.isEmpty()) {
            return;
        }
        Map<Id, Account> storeAccountsMap = new Map<Id, Account>(
            AccountsSelector.newInstance().selectStoreAccountByUUIDWithXrefs(fullServeUUIDs)
        );
        Map<String, String> storeAccountIdToUUID = new Map<String, String>();
        Map<String, Account> storeAccountByUUID = new Map<String, Account>();

        for (Account acc : storeAccountsMap.values()) {
            storeAccountIdToUUID.put(acc.Id, acc.Unique_Identifier__c);
            storeAccountByUUID.put(acc.Unique_Identifier__c, acc);
        }

        Map<String, Business_Reference__c> uuidToBizRef = new Map<String, Business_Reference__c>();

        fetchExistingBizRefOrCreate(
            storeAccountsMap,
            storeAccountByUUID,
            storeAccountIdToUUID,
            uuidToBizRef,
            payLoadWrapperByIngestionLogUUID
        );

        updateAccountAndUpsertXref(
            uuidToBizRef,
            payLoadWrapperByIngestionLogUUID,
            storeAccountByUUID
        );

        String logMessage = RESSMO_FULLSERVE_MESSAGES_UUID.replace('{UUIDkeyset}', String.join(new List<String>(payLoadWrapperByIngestionLogUUID.keyset()),','));
        GenericLoggerService.publish(
                    GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_FULLSERVE,GENERIC_LOG_DOMAIN,GenericLogEntry.SeverityLevel.MEDIUM)
                    .logMessage(logMessage).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_INFO)
                );
    }

    /**
     * @description will update the account fields and creates if not present or updates the Xref
     * @author VenkateshDD | 08-05-2024
     * @param uuidToBizRef
     * @param payLoadWrapperByIngestionLogUUID
     * @param storeAccountByUUID
     **/
    private void updateAccountAndUpsertXref(
        Map<String, Business_Reference__c> uuidToBizRef,
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, Account> storeAccountByUUID
    ) {
        fflib_ISObjectUnitOfWork uowAccount = Application.UNITOFWORK.newInstance();
        fflib_ISObjectUnitOfWork uowXrefUpdate = Application.UNITOFWORK.newInstance();
        Map<String, InstantIngestionPayloadParser> payloadToCreateXref = new Map<String, InstantIngestionPayloadParser>();

        for (String uuid : uuidToBizRef.keyset()) {
            InstantIngestionPayloadParser payload = payLoadWrapperByIngestionLogUUID.get(uuid);
            Account storeAcc = storeAccountByUUID.get(uuid);
            String storeAccountId = storeAcc.Id;

            Account storeAccUpdate = new Account();
            storeAccUpdate.Id = storeAccountId;
            storeAccUpdate.Menu_URL__c = payload.store.menuUrls[0];
            storeAccUpdate.Hours_of_Operation__c = payload.store.hoursOfOperation;
            if (
                storeAcc.Order_Protocol__c == null ||
                storeAcc.Order_Protocol__c != POS_ORDER_PROTOCOL
            ) {
                storeAccUpdate.Menu_Setup_Method__c = MENU_SETUP_METHOD;
                storeAccUpdate.Menu_to_be_Completed_By__c = MENU_TO_BE_COMPLETED_BY;
            }
            if(String.isBlank(storeAcc.Menu_UI_Type__c)){
                storeAccUpdate.Menu_UI_Type__c = MENU_UI_TYPE_RESTAURANT;
            }
            storeAccUpdate.Tablet_User_Name__c = payload.store.ipadUserName;
            storeAccUpdate.Tablet_Password__c = payload.store.ipadPassword;
            if(String.isBlank(storeAcc.Order_Protocol__c) && String.isNotBlank(payload.store.orderProtocol)){
                storeAccUpdate.Order_Protocol__c = InstantIngestionEnumMappingsService.getOrderProtocol(
                    payload.store.orderProtocol
                );
            }
            uowAccount.registerDirty(storeAccUpdate);

            if (storeAcc.Xrefs__r.size() == 0) {
                payloadToCreateXref.put(uuid, payload);
            } else {
                uowXrefUpdate.registerDirty(
                    new Xref__c(
                        Id = storeAcc.Xrefs__r[0].Id,
                        External_ID__c = payload.store.storeId,
                        Business_Reference__c = uuidToBizRef.get(uuid).Id,
                        Xref_Status__c = STATUS_ACTIVE,
                        Integration_Status__c = SUCESS_STATUS,
                        Unique_Identifier__c = uuid
                    )
                );
            }
        }
        uowAccount.commitWork();
        uowXrefUpdate.commitWork();

        fflib_ISObjectUnitOfWork uowXrefCreation = Application.UNITOFWORK.newInstance();
        for (InstantIngestionPayloadParser payload : payloadToCreateXref.values()) {
            Account storeAccount = storeAccountByUUID.get(payload.uuid);
            uowXrefCreation.registerNew(
                InstantIngestionXrefBizRefService.createXref(
                    payload,
                    new SSOBOnboardingPayloadParser(),
                    (Account) storeAccount.getSObject('Parent'),
                    storeAccount,
                    uuidToBizRef.get(payload.uuid),
                    this.sourceByUUID.get(payload.Uuid)
                )
            );
        }
        uowXrefCreation.commitWork();
    }

    /**
     * @description this will populate uuidToBizRef and stamps the Business Id on Biz Ref
     * @author VenkateshDD | 08-05-2024
     * @param storeAccountsMap
     * @param storeAccountByUUID
     * @param storeAccountIdToUUID
     * @param uuidToBizRef
     * @param payLoadWrapperByIngestionLogUUID
     **/
    private void fetchExistingBizRefOrCreate(
        Map<Id, Account> storeAccountsMap,
        Map<String, Account> storeAccountByUUID,
        Map<String, String> storeAccountIdToUUID,
        Map<String, Business_Reference__c> uuidToBizRef,
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Set<String> parentAccountCurrencies = new Set<String>();
        Map<Id, Id> parentAccountToStoreAccountId = new Map<Id, Id>();
        for (Account acc : storeAccountsMap.values()) {
            parentAccountCurrencies.add(acc.Parent.CurrencyIsoCode);
            parentAccountToStoreAccountId.put(acc.ParentId, acc.Id);
        }
        Set<Id> brandIds = new Set<Id>();
        Map<Id, Id> brandIdToBusinessAccountId = new Map<Id, Id>();
        Map<Id, Id> bizAccIdToBrandId = new Map<Id, Id>();
        List<Brand_Association__c> brandAsscs = BrandAssociationsSelector.newInstance()
            .selectByBusinessAccountIds(parentAccountToStoreAccountId.keySet());
        for (Brand_Association__c ba : brandAsscs) {
            brandIds.add(ba.Brand_Name__c);
            brandIdToBusinessAccountId.put(ba.Brand_Name__c, ba.Business_Account_Name__c);
            bizAccIdToBrandId.put(ba.Business_Account_Name__c, ba.Brand_Name__c);
        }

        List<Business_Reference__c> existingBizRefs = BusinessReferencesSelector.newInstance()
            .selectByBusinessVerticalsBrandIdsAndCurrencyISOCodes(
                new Set<Id>{ this.businessVerticalRx.Id },
                brandIds,
                parentAccountCurrencies
            );

        populateUuidToBizRef(
            existingBizRefs,
            uuidToBizRef,
            brandIdToBusinessAccountId,
            parentAccountToStoreAccountId,
            storeAccountIdToUUID
        );

        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (String uuid : uuidToBizRef.keyset()) {
            InstantIngestionPayloadParser payload = payLoadWrapperByIngestionLogUUID.get(uuid);
            String businessGroupId;
            if(!String.isBlank(payload.businessGroup.businessGroupId)){
                businessGroupId = payload.businessGroup.businessGroupId;
            }
            Business_Reference__c bizRef = uuidToBizRef.get(uuid);
            if (
                bizRef.Integration_Status__c != SUCESS_STATUS ||
                bizRef.External_Id__c != payload.business.businessId
            ) {
                uow.registerDirty(
                    new Business_Reference__c(
                        Id = bizRef.Id,
                        Integration_Status__c = SUCESS_STATUS,
                        External_Id__c = payload.business.businessId,
                        Business_Group_Id__c = businessGroupId
                    )
                );
            }
        }
        uow.commitWork();

        List<Business_Reference__c> bizRefs = createBizRefIfNotPresentForRESSMO(
            uuidToBizRef,
            payLoadWrapperByIngestionLogUUID,
            storeAccountByUUID,
            bizAccIdToBrandId
        );

        if (bizRefs.isEmpty()) {
            return;
        }

        populateUuidToBizRef(
            bizRefs,
            uuidToBizRef,
            brandIdToBusinessAccountId,
            parentAccountToStoreAccountId,
            storeAccountIdToUUID
        );
    }

    /**
     * @description
     * @author VenkateshDD | 08-28-2024
     * @param bizRefs
     * @param uuidToBizRef
     * @param brandIdToBusinessAccountId
     * @param parentAccountToStoreAccountId
     * @param storeAccountIdToUUID
     **/
    private void populateUuidToBizRef(
        List<Business_Reference__c> bizRefs,
        Map<String, Business_Reference__c> uuidToBizRef,
        Map<Id, Id> brandIdToBusinessAccountId,
        Map<Id, Id> parentAccountToStoreAccountId,
        Map<String, String> storeAccountIdToUUID
    ) {
        for (Business_Reference__c bizRef : bizRefs) {
            Id bizAccId = brandIdToBusinessAccountId.get(bizRef.Brand__c);
            Id storeAccId = parentAccountToStoreAccountId.get(bizAccId);
            String uuid = storeAccountIdToUUID.get(storeAccId);
            uuidToBizRef.put(uuid, bizRef);
        }
    }

    /**
     * @description will check if Biz Ref is present or not and creates the business reference
     * @author VenkateshDD | 08-28-2024
     * @param uuidToBizRef
     * @param payLoadWrapperByIngestionLogUUID
     * @param storeAccountByUUID
     * @param bizAccIdToBrandId
     * @return List<Business_Reference__c>
     **/
    private List<Business_Reference__c> createBizRefIfNotPresentForRESSMO(
        Map<String, Business_Reference__c> uuidToBizRef,
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, Account> storeAccountByUUID,
        Map<Id, Id> bizAccIdToBrandId
    ) {
        Map<String, InstantIngestionPayloadParser> payloadToCreateBusinessReference = new Map<String, InstantIngestionPayloadParser>();
        for (InstantIngestionPayloadParser payload : payLoadWrapperByIngestionLogUUID.values()) {
            if (!uuidToBizRef.containsKey(payload.uuid)) {
                payloadToCreateBusinessReference.put(payload.uuid, payload);
            }
        }
        if (payloadToCreateBusinessReference.isEmpty()) {
            return new List<Business_Reference__c>();
        }
        return initiateBusinessReferencesCreationRESSMO(
            payloadToCreateBusinessReference,
            storeAccountByUUID,
            bizAccIdToBrandId
        );
    }

    /**
     * @description It is used to initiate account, xref and business reference creation.
     * @param payLoadWrapperByIngestionLogUUID
     * @param sourceByUUID
     */
    public void payloadDistributorForAccountsAndXrefsBizRefs(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, String> sourceByUUID
    ) {
        this.methodName = PAYLOAD_DISTRIBUTOR_FOR_ACCOUNTS_AND_XREF_BIZREF;
        savePointForRollback = Database.setSavePoint();
        this.sourceByUUID = sourceByUUID;
        List<Database.SaveResult> saveResultForBusinessAccountCreation = new List<Database.SaveResult>();
        List<Database.SaveResult> saveResultForBrandCreation = new List<Database.SaveResult>();
        List<Database.SaveResult> saveResultForStoreAccountCreation = new List<Database.SaveResult>();
        List<Database.SaveResult> saveResultForXrefCreation = new List<Database.SaveResult>();
        List<Database.SaveResult> saveResultForBusinessReferenceCreation = new List<Database.SaveResult>();

        this.existingAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessAccounts(
            payLoadWrapperByIngestionLogUUID,
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        saveResultForBusinessAccountCreation = initiateBusinessAccountsCreation(
            payLoadWrapperByIngestionLogUUID
        );
        saveResultForBrandCreation = initiateBrandsCreation(payLoadWrapperByIngestionLogUUID);
        saveResultForStoreAccountCreation = initiateStoreAccountsCreation(
            payLoadWrapperByIngestionLogUUID
        );
        saveResultForBusinessReferenceCreation = initiateBusinessReferencesCreation(
            payLoadWrapperByIngestionLogUUID
        );
        saveResultForXrefCreation = initiateXrefsCreation(payLoadWrapperByIngestionLogUUID);
        catchExceptionsOnGovernerLimits();
        if (isNonMxPortalAmendmentEvent) {
            publishEventsByEventTopic(
                EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
            );
        }
    }

    /**
     * @description Update Menu URL and Hours of Operation
     * @author VenkateshDD | 07-18-2024
     * @param payLoadWrapperByIngestionLogUUID
     * @param accounts
     **/
    private void initiateRESSMOStoreAccountUpdate(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        List<Account> accounts
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();

        Map<String, InstantIngestionPayloadParser> payloadToCreateXref = new Map<String, InstantIngestionPayloadParser>();
        uow.registerWork(uowUpdateHelper);
        for (Account acc : accounts) {
            InstantIngestionPayloadParser payload = payLoadWrapperByIngestionLogUUID.get(
                acc.Unique_Identifier__c
            );
            acc.Menu_URL__c = payload.store.menuUrls[0];
            acc.Hours_of_Operation__c = payload.store.hoursOfOperation;
            uowUpdateHelper.registerUpdate(acc);
            if (acc.Xrefs__r.size() == 0) {
                payloadToCreateXref.put(acc.Unique_Identifier__c, payload);
            }
            payLoadWrapperByIngestionLogUUID.remove(acc.Unique_Identifier__c);
        }
        uow.commitWork();

        if (!payloadToCreateXref.isEmpty()) {
            initiateXrefsCreationByBusinessId(payloadToCreateXref);
        }
    }

    /**
     * @description Initiates contact creation by business ID.
     *
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR - A map containing InstantIngestionPayloadParser objects
     *                                                           mapped by Ingestion Log UUID for Contact and ACR.
     * @return A list of Database.SaveResult objects representing the results of the contact creation operation.
     */
    private List<Database.SaveResult> initiateContactCreationByBusinessId(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForContactAndACR.values()
        ) {
            if (!((eachInstantIngestionPayload.store.matchedRecords.contact).isEmpty())) {
                if (eachInstantIngestionPayload.store.isAdditionalStore) {
                    uow.registerDirty(
                        new Contact(
                            Id = eachInstantIngestionPayload.store.matchedRecords.contact[0].Id,
                            Unique_Identifier__c = eachInstantIngestionPayload.uuid
                        )
                    );
                }
                continue;
            }

            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionContactACRService.createContact(
                    eachInstantIngestionPayload,
                    this.existingAccountByBusinessId.get(
                        eachInstantIngestionPayload.business.businessId
                    )
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to initiate Contact and ACR creation.
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR
     * @param sourceByUUID
     */
    public void payloadDistributorForContactsAndACRs(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR,
        Map<String, String> sourceByUUID
    ) {
        this.methodName = PAYLOAD_DISTRIBUTOR_FOR_CONTACT_AND_ACR;
        this.sourceByUUID = sourceByUUID;
        savePointForRollback = Database.setSavePoint();
        this.existingAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessAccounts(
            payLoadWrapperByIngestionLogUUIDForContactAndACR,
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        List<Database.SaveResult> saveResultForContactsCreation = new List<Database.SaveResult>();
        List<Database.SaveResult> saveResultForACRCreation = new List<Database.SaveResult>();
        saveResultForContactsCreation = initiateContactCreation(
            payLoadWrapperByIngestionLogUUIDForContactAndACR
        );
        saveResultForACRCreation = initiateACRCreation(
            payLoadWrapperByIngestionLogUUIDForContactAndACR
        );
        SSMOLeadConversionService.autoConvertLeads(
            this.recordIdsByPayload,
            payLoadWrapperByIngestionLogUUIDForContactAndACR
        );
        catchExceptionsOnGovernerLimits();
        if (isNonMxPortalAmendmentEvent) {
            publishEventsByEventTopic(
                EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
            );
        }
    }

    /**
     * @description It is used to initiate the creation of Opportunities by the received payload.
     * @param payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
     * @param sourceByUUID
     * @param inboundIngestionLogByUUID
     */
    public void payloadDistributorForOpportunities(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR,
        Map<String, String> sourceByUUID,
        Map<String, Inbound_Ingestion_Log__c> inboundIngestionLogByUUID
    ) {
        this.methodName = PAYLOAD_DISTRIBUTOR_FOR_OPPORTUNITIES;
        this.sourceByUUID = sourceByUUID;
        this.inboundIngestionLogByUUID = inboundIngestionLogByUUID;
        savePointForRollback = Database.setSavePoint();
        this.existingAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessAccounts(
            payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR,
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        this.existingOpportunityByAccountId = InstantIngestionCheckRecordsService.fetchRelatedOpportunitiesAndQuotes(
            new Map<Id, Account>(this.existingAccountByBusinessId.values()).keySet()
        );
        List<Database.SaveResult> saveResultForOpportunityCreation = new List<Database.SaveResult>();
        saveResultForOpportunityCreation = initiateOpportunityCreation(
            payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
        );
        catchExceptionsOnGovernerLimits();
        if (isNonMxPortalAmendmentEvent) {
            publishEventsByEventTopic(
                EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
            );
        }
    }

    /**
     * @description It is used to initiate the creation of Quote and Quote Lines by the received payload.
     * @param payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
     */
    public void payloadDistributorForQuotesAndQuoteLines(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    ) {
        this.methodName = PAYLOAD_DISTRIBUTOR_FOR_QUOTES_AND_QUOTELINES;
        savePointForRollback = Database.setSavePoint();
        Set<Id> quoteIdsToUpdate = new Set<Id>();
        this.existingAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessAccounts(
            payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines,
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        this.existingOpportunityByAccountId = InstantIngestionCheckRecordsService.fetchRelatedOpportunitiesAndQuotes(
            new Map<Id, Account>(this.existingAccountByBusinessId.values()).keySet()
        );
        List<Database.SaveResult> saveResultForQuoteCreation = new List<Database.SaveResult>();
        List<Database.SaveResult> saveResultForQuoteLineGroupCreation = new List<Database.SaveResult>();
        List<Database.SaveResult> saveResultForQuoteLinesCreation = new List<Database.SaveResult>();
        List<Database.SaveResult> saveResultForQuoteLineOptionsCreation = new List<Database.SaveResult>();
        SBQQ.TriggerControl.disable();
        saveResultForQuoteCreation = initiateQuoteCreation(
            payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
        );
        saveResultForQuoteLineGroupCreation = initiateQuoteLineGroupCreation(
            payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
        );
        saveResultForQuoteLinesCreation = initiateQuoteLineCreation(
            payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
        );
        saveResultForQuoteLineOptionsCreation = initiateQuoteLineOptionsCreation(
            payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
        );
        catchExceptionsOnGovernerLimits();
        SBQQ.TriggerControl.enable();
        Map<String, SBQQ__Quote__c> quotesByUUID = InstantIngestionRecordsGetterService.getQuotesByUUID(
            payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines,
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        for (SBQQ__Quote__c eachQuote : quotesByUUID.values()) {
            quoteIdsToUpdate.add(eachQuote.Id);
        }
        if(!getExistingPrimaryQuoteIds().isEmpty()){
            InstantIngestorEventsService.publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS => JSON.serialize(
                        getExistingPrimaryQuoteIds()
                    )
                }
            );
            return;
        }
        if (quoteIdsToUpdate.isEmpty()) {
            return;
        }
        InstantIngestorEventsService.publishEvents(
            new Map<String, String>{
                EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY => JSON.serialize(quoteIdsToUpdate)
            }
        );
    }

    /**
     * @description It is used to create business accounts.
     * @param payLoadWrapperByIngestionLogUUID
     * @return List<Database.SaveResult>
     */
    private List<Database.SaveResult> initiateBusinessAccountsCreation(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<String, Submarket__c> submarkets = InstantIngestionRecordsGetterService.getSubmarkets(
            payLoadWrapperByIngestionLogUUID.values()
        );
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            if (isExistingAccountFound(eachInstantIngestionPayload)) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionAccountService.createBusinessAccount(
                    eachInstantIngestionPayload,
                    submarkets.containsKey(
                            eachInstantIngestionPayload.store.addressVerificationInfo?.submarket?.id
                        )
                        ? submarkets.get(
                                  eachInstantIngestionPayload.store.addressVerificationInfo
                                      ?.submarket
                                      ?.id
                              )
                              .Id
                        : '',
                    integrationTypeByUUID.get(eachInstantIngestionPayload.uuid)
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to create brands.
     * @param payLoadWrapperByIngestionLogUUID
     * @return List<Database.SaveResult>
     */
    private List<Database.SaveResult> initiateBrandsCreation(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            if (isExistingAccountFound(eachInstantIngestionPayload)) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionAccountService.createBrand(
                    getExistingAccountForAssociation(
                        eachInstantIngestionPayload,
                        payLoadWrapperByIngestionLogUUID
                    )
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to create store accounts.
     * @param payLoadWrapperByIngestionLogUUID
     * @return List<Database.SaveResult>
     */
    private List<Database.SaveResult> initiateStoreAccountsCreation(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<String, Submarket__c> submarkets = InstantIngestionRecordsGetterService.getSubmarkets(
            payLoadWrapperByIngestionLogUUID.values()
        );
        Map<String, Account> storeAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingStoreAccounts(
            payLoadWrapperByIngestionLogUUID
        );
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            if (
                isExistingAccountFound(eachInstantIngestionPayload) &&
                !eachInstantIngestionPayload.store.isAdditionalStore
            ) {
                uow.registerDirty(
                    new Account(
                        Id = storeAccountByBusinessId.get(
                                eachInstantIngestionPayload.business.businessId
                            )
                            .Id,
                        Unique_Identifier__c = eachInstantIngestionPayload.uuid
                    )
                );
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionAccountService.createStoreAccount(
                    eachInstantIngestionPayload,
                    getExistingBrandForAssociation(
                            eachInstantIngestionPayload,
                            payLoadWrapperByIngestionLogUUID
                        )
                        .Id,
                    getExistingAccountForAssociation(
                        eachInstantIngestionPayload,
                        payLoadWrapperByIngestionLogUUID
                    ),
                    this.businessVerticalRx,
                    submarkets.containsKey(
                            eachInstantIngestionPayload.store.addressVerificationInfo?.submarket?.id
                        )
                        ? submarkets.get(
                                  eachInstantIngestionPayload.store.addressVerificationInfo
                                      ?.submarket
                                      ?.id
                              )
                              .Id
                        : ''
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to create business references.
     * @param payLoadWrapperByIngestionLogUUID
     * @return List<Database.SaveResult>
     */
    private List<Database.SaveResult> initiateBusinessReferencesCreation(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            if (isExistingAccountFound(eachInstantIngestionPayload)) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionXrefBizRefService.createBusinessReference(
                    eachInstantIngestionPayload,
                    new SSOBOnboardingPayloadParser(),
                    getExistingBrandForAssociation(
                            eachInstantIngestionPayload,
                            payLoadWrapperByIngestionLogUUID
                        )
                        .Id,
                    getExistingAccountForAssociation(
                            eachInstantIngestionPayload,
                            payLoadWrapperByIngestionLogUUID
                        )
                        .CurrencyIsoCode,
                    this.businessVerticalRx,
                    this.sourceByUUID.get(eachInstantIngestionPayload.Uuid)
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description Create Biz Ref for RESSMO for RESSMO
     * @author VenkateshDD | 08-28-2024
     * @param payLoadWrapperByIngestionLogUUID
     * @param storeAccountByUUID
     * @param bizAccIdToBrandId
     * @return List<Business_Reference__c>
     **/
    private List<Business_Reference__c> initiateBusinessReferencesCreationRESSMO(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, Account> storeAccountByUUID,
        Map<Id, Id> bizAccIdToBrandId
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        List<Business_Reference__c> bizRefs = new List<Business_Reference__c>();
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            Account storeAcc = storeAccountByUUID.get(eachInstantIngestionPayload.uuid);
            bizRefs.add(
                InstantIngestionXrefBizRefService.createBusinessReference(
                    eachInstantIngestionPayload,
                    new SSOBOnboardingPayloadParser(),
                    bizAccIdToBrandId.get(storeAcc.ParentId),
                    storeAcc.Parent.CurrencyIsoCode,
                    this.businessVerticalRx,
                    this.sourceByUUID.get(eachInstantIngestionPayload.Uuid)
                )
            );
        }
        insertUnitOfWorkHelper.registerInsert(bizRefs);
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
        return bizRefs;
    }

    /**
     * @description It is used to create xrefs.
     * @param payLoadWrapperByIngestionLogUUID
     * @return List<Database.SaveResult>
     */
    private List<Database.SaveResult> initiateXrefsCreation(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Account existingStoreAccount = new Account();
        Business_Reference__c existingBusinessReference = new Business_Reference__c();
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<String, Account> storeAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingStoreAccounts(
            payLoadWrapperByIngestionLogUUID
        );
        Map<String, Business_Reference__c> bizRefByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessReferences(
            this.existingAccountByBusinessId.keySet()
        );
        Map<String, Account> storeAccountByUUID = InstantIngestionRecordsGetterService.getStoreAccountByUUID(
            payLoadWrapperByIngestionLogUUID
        );
        Map<String, Business_Reference__c> businessReferenceByUUID = InstantIngestionRecordsGetterService.getBizRefByUUID(
            payLoadWrapperByIngestionLogUUID,
            null
        );
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            existingStoreAccount = (this.existingAccountByBusinessId.get(
                    eachInstantIngestionPayload.business.businessId
                ) == null ||
                this.sourceByUUID.get(eachInstantIngestionPayload.Uuid) == 'Mx Portal')
                ? storeAccountByUUID.get(eachInstantIngestionPayload.Uuid)
                : storeAccountByBusinessId.get(eachInstantIngestionPayload.business.businessId);
            existingBusinessReference = this.existingAccountByBusinessId.get(
                    eachInstantIngestionPayload.business.businessId
                ) == null
                ? businessReferenceByUUID.get(eachInstantIngestionPayload.Uuid)
                : bizRefByBusinessId.get(eachInstantIngestionPayload.business.businessId);

            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionXrefBizRefService.createXref(
                    eachInstantIngestionPayload,
                    new SSOBOnboardingPayloadParser(),
                    getExistingAccountForAssociation(
                        eachInstantIngestionPayload,
                        payLoadWrapperByIngestionLogUUID
                    ),
                    existingStoreAccount,
                    existingBusinessReference,
                    this.sourceByUUID.get(eachInstantIngestionPayload.Uuid)
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to create contacts.
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR
     * @return List<Database.SaveResult>
     */
    private List<Database.SaveResult> initiateContactCreation(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForContactAndACR.values()
        ) {
            if (!((eachInstantIngestionPayload.store.matchedRecords.contact).isEmpty())) {
                uow.registerDirty(
                    new Contact(
                        Id = eachInstantIngestionPayload.store.matchedRecords.contact[0].Id,
                        Unique_Identifier__c = eachInstantIngestionPayload.uuid
                    )
                );
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionContactACRService.createContact(
                    eachInstantIngestionPayload,
                    getExistingAccountForAssociation(
                        eachInstantIngestionPayload,
                        payLoadWrapperByIngestionLogUUIDForContactAndACR
                    )
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to create ACRs.
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR
     * @return List<Database.SaveResult>
     */
    private List<Database.SaveResult> initiateACRCreation(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<Id, Contact> contactsByBusinessAccountId = InstantIngestionCheckRecordsService.getExistingContactsByBusinessAccount(
            new Map<Id, Account>(this.existingAccountByBusinessId.values()).keySet()
        );
        Map<String, Account> storeAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingStoreAccounts(
            payLoadWrapperByIngestionLogUUIDForContactAndACR
        );
        Map<String, Contact> contactsByMatchedRecord = InstantIngestionRecordsGetterService.getContactsByMatchedRecord(
            payLoadWrapperByIngestionLogUUIDForContactAndACR
        );
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForContactAndACR.values()
        ) {
            if (
                storeAccountByBusinessId.get(eachInstantIngestionPayload.business.businessId) !=
                null
            ) {
                insertUnitOfWorkHelper.registerInsert(
                    InstantIngestionContactACRService.createACR(
                        storeAccountByBusinessId.get(
                            eachInstantIngestionPayload.business.businessId
                        ),
                        !contactsByMatchedRecord.isEmpty()
                            ? this.existingAccountByBusinessId.get(
                                  eachInstantIngestionPayload.business.businessId
                              )
                            : null,
                        !contactsByMatchedRecord.isEmpty()
                            ? contactsByMatchedRecord.get(eachInstantIngestionPayload.uuid)
                            : contactsByBusinessAccountId.get(
                                  getExistingAccountForAssociation(
                                          eachInstantIngestionPayload,
                                          payLoadWrapperByIngestionLogUUIDForContactAndACR
                                      )
                                      .Id
                              ),
                        getContactRole(eachInstantIngestionPayload)
                    )
                );
            }
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description will assign the Account Contact Relationship roles based on the country as per the KYC compliance
     * @author VenkateshDD | 09-24-2024
     * @param inboundPayload
     * @return String
     **/
    private String getContactRole(InstantIngestionPayloadParser inboundPayload) {
        if (inboundPayload.onboardingSource != SOURCE_RESSMO) {
            return System.Label.ACR_Role_Decision_Maker;
        }
        if (
            inboundPayload?.store?.addressVerificationInfo?.validatedAddress?.country ==
            COUNTRY_CANADA
        ) {
            return CONTACT_ROLES_FOR_CANADA_KYC;
        }
        return CONTACT_ROLE_CONTRACT_SIGNATORY;
    }

    /**
     * @description It is used to initiate the opportunity creations.
     * @param payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
     * @return List<Database.SaveResult>
     */
    private List<Database.SaveResult> initiateOpportunityCreation(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<Id, Contact> contactsByBusinessAccountId = InstantIngestionCheckRecordsService.getExistingContactsByBusinessAccount(
            new Map<Id, Account>(this.existingAccountByBusinessId.values()).keySet()
        );
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR.values()
        ) {
            if (
                isOpportunityWithPrimaryQuoteExist(
                    eachInstantIngestionPayload.business.businessId
                ) != null && !eachInstantIngestionPayload.store.isAdditionalStore
            ) {
                uow.registerDirty(
                    new Opportunity(
                        Id = isOpportunityWithPrimaryQuoteExist(
                                eachInstantIngestionPayload.business.businessId
                            )
                            .Id,
                        Source__c = SOURCE_SSMO,
                        Unique_Identifier__c = eachInstantIngestionPayload.uuid
                    )
                );
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionOpportunityService.createOpportunity(
                    eachInstantIngestionPayload,
                    new SSOBOnboardingPayloadParser(),
                    getExistingAccountForAssociation(
                        eachInstantIngestionPayload,
                        payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
                    ),
                    contactsByBusinessAccountId.get(
                        getExistingAccountForAssociation(
                                eachInstantIngestionPayload,
                                payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
                            )
                            .Id
                    ),
                    this.sourceByUUID.get(eachInstantIngestionPayload.Uuid),
                    inboundIngestionLogByUUID.get(eachInstantIngestionPayload.Uuid).Id
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to initiate the quote creations.
     * @param payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
     * @return List<Database.SaveResult>
     */
    private List<Database.SaveResult> initiateQuoteCreation(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        PriceBook2 pricebook = PricebookSelector.newInstance().selectStandardPricebook();
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines.values()
        ) {
            if (
                isOpportunityWithPrimaryQuoteExist(eachInstantIngestionPayload.business.businessId)
                    .SBQQ__PrimaryQuote__c != null &&
                !eachInstantIngestionPayload.store.isAdditionalStore
            ) {
                uow.registerDirty(
                    new SBQQ__Quote__c(
                        Id = isOpportunityWithPrimaryQuoteExist(
                                eachInstantIngestionPayload.business.businessId
                            )
                            .SBQQ__PrimaryQuote__c,
                        Unique_Identifier__c = eachInstantIngestionPayload.uuid
                    )
                );
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createQuote(
                    eachInstantIngestionPayload,
                    this.existingOpportunityByAccountId.get(
                        getExistingAccountForAssociation(
                                eachInstantIngestionPayload,
                                payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
                            )
                            .Id
                    ),
                    getExistingAccountForAssociation(
                        eachInstantIngestionPayload,
                        payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
                    ),
                    pricebook.Id,
                    this.sourceByUUID.get(eachInstantIngestionPayload.Uuid)
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to initiate the quote creations.
     * @param payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
     * @return List<Database.SaveResult>
     */
    private List<Database.SaveResult> initiateQuoteLineGroupCreation(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        this.quotesByOpportunityId = InstantIngestionCheckRecordsService.getExistingQuotesByAccountIds(
            new Map<Id, Opportunity>(this.existingOpportunityByAccountId.values()).keySet()
        );
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines.values()
        ) {
            if (
                isOpportunityWithPrimaryQuoteExist(eachInstantIngestionPayload.business.businessId)
                    .SBQQ__PrimaryQuote__c != null &&
                !eachInstantIngestionPayload.store.isAdditionalStore
            ) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createQuoteLineGroup(
                    this.existingOpportunityByAccountId.get(
                        getExistingAccountForAssociation(
                                eachInstantIngestionPayload,
                                payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
                            )
                            .Id
                    ),
                    this.quotesByOpportunityId.get(
                        getExistingAccountForAssociation(
                                eachInstantIngestionPayload,
                                payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
                            )
                            .Id
                    )
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to initiate the quote lines creations.
     * @param payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
     * @return List<Database.SaveResult>
     */
    private List<Database.SaveResult> initiateQuoteLineCreation(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    ) {
        Map<Id, SBQQ__QuoteLineGroup__c> quotesLineGroupsByQuoteId = new Map<Id, SBQQ__QuoteLineGroup__c>();
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        this.quotesByOpportunityId = InstantIngestionCheckRecordsService.getExistingQuotesByAccountIds(
            new Map<Id, Opportunity>(this.existingOpportunityByAccountId.values()).keySet()
        );
        quotesLineGroupsByQuoteId = InstantIngestionCheckRecordsService.getQuoteLineGroupsByAccountIds(
            new Map<Id, SBQQ__Quote__c>(this.quotesByOpportunityId.values()).keySet()
        );
        PriceBook2 pricebook = PricebookSelector.newInstance().selectStandardPricebook();
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines.values()
        ) {
            if (
                (isOpportunityWithPrimaryQuoteExist(
                        eachInstantIngestionPayload.business.businessId
                    ))
                    .SBQQ__PrimaryQuote__c != null &&
                !eachInstantIngestionPayload.store.isAdditionalStore
            ) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createBundleAndStandaloneQuoteLinesForInstantIngestionPayload(
                    eachInstantIngestionPayload,
                    this.quotesByOpportunityId.get(
                        getExistingAccountForAssociation(
                                eachInstantIngestionPayload,
                                payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
                            )
                            .Id
                    ),
                    pricebook,
                    quotesLineGroupsByQuoteId.get(
                            getExistingAccountForAssociation(
                                    eachInstantIngestionPayload,
                                    payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
                                )
                                .Id
                        )
                        .Id,
                    this.sourceByUUID.get(eachInstantIngestionPayload.Uuid)
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to initiate the quote line options creations.
     * @param payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
     * @return List<Database.SaveResult>
     */
    private List<Database.SaveResult> initiateQuoteLineOptionsCreation(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<String, SBQQ__QuoteLine__c> quoteLinesWithProductNameByUUID = InstantIngestionRecordsGetterService.getQuoteLinesByUUID(
            payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines,
            null
        );
        PriceBook2 pricebook = PricebookSelector.newInstance().selectStandardPricebook();
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines.values()
        ) {
            if (
                (isOpportunityWithPrimaryQuoteExist(
                        eachInstantIngestionPayload.business.businessId
                    ))
                    .SBQQ__PrimaryQuote__c != null &&
                !eachInstantIngestionPayload.store.isAdditionalStore
            ) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createQuoteLineOptionsByParentForInstantIngestionPayload(
                    eachInstantIngestionPayload,
                    quoteLinesWithProductNameByUUID,
                    this.quotesByOpportunityId.get(
                        getExistingAccountForAssociation(
                                eachInstantIngestionPayload,
                                payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
                            )
                            .Id
                    ),
                    pricebook
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to commit the changes to database.
     * @param uow
     * @param insertUnitOfWorkHelper
     * @return List<Database.SaveResult>
     */
    private List<Database.SaveResult> commitUnitOfWork(
        fflib_ISObjectUnitOfWork uow,
        InsertUnitOfWorkHelper insertUnitOfWorkHelper
    ) {
        List<Database.SaveResult> saveResultData = new List<Database.SaveResult>();
        List<String> errorMessages = new List<String>();
        uow.registerWork(insertUnitOfWorkHelper);
        uow.commitWork();
        saveResultData = insertUnitOfWorkHelper.saveResults != null
            ? insertUnitOfWorkHelper.saveResults
            : new List<Database.SaveResult>();
        for (Database.SaveResult eachSaveResultsDetail : saveResultData) {
            for (Database.Error eachSaveResultError : eachSaveResultsDetail.getErrors()) {
                errorMessages.add(
                    eachSaveResultError.getStatusCode() +
                        ': ' +
                        eachSaveResultError.getMessage() +
                        ': ' +
                        eachSaveResultError.getFields()
                );
            }
        }
        if (!errorMessages.isEmpty()) {
            saveResultsDetails.addAll(saveResultData);
            errorsList.addAll(errorMessages);
            throw new DmlException(COMMITWORK_MESSAGE + ' ' + errorMessages);
        }
        return saveResultData;
    }
    /**
     * @description It is used to catch Governor Limit Exceptions when the payload inserted for the Onboarding Event.
     */
    private void catchExceptionsOnGovernerLimits() {
        String govLimitsException = InboundIngestionLoggerService.errorOnGovtLimitsExceeded();
        if (String.isNotBlank(govLimitsException)) {
            IinboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
                SELF_SERVING_ONBOARDING_SERVICE,
                CPQ_WS,
                inboundIngestionLogs[0].Id,
                inboundIngestionLogs[0].UUID__c,
                ''
            );
            InboundIngestionLoggerService.logGovLimitsException(
                loggerEntry,
                govLimitsException,
                payloadMethodsToStepMap.get(this.methodName),
                CLASS_NAME,
                this.methodName
            );
        }
    }

    /**
     * @description It is used to update the save result exception on Inbound Ingestion log record.
     * @param savedIngestionResults
     */
    private void logSaveResultIngestionExceptionToInboundIngestionRecord(
        List<Database.SaveResult> savedIngestionResults
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uow.registerWork(uowUpdateHelper);
        String traceString = '';
        String exceptionMessage = '';
        for (Integer i = 0; i < savedIngestionResults.size(); i++) {
            if (savedIngestionResults[i].isSuccess()) {
                continue;
            }
            for (Database.Error err : savedIngestionResults[i].getErrors()) {
                traceString = new DmlException().getStackTraceString().substringAfter('\n');
                exceptionMessage += err.getMessage();
            }
            Inbound_ingestion_Log__c ingestionRecord = new Inbound_ingestion_Log__c(
                Id = inboundIngestionLogs[i].Id,
                Status__c = STATUS_FAILED,
                Business_Error_Message__c = BUSINESS_ERROR_MESSAGE,
                Failure_Step__c = this.methodName == ''
                    ? 1
                    : Decimal.valueof(payloadMethodsToStepMap.get(this.methodName)),
                Stack_Trace__c = traceString,
                Exception_Message__c = exceptionMessage
            );
            uowUpdateHelper.registerUpdate(ingestionRecord);
        }
        uow.commitWork();

        logIngestionExceptionToScaler(null);
    }

    /**
     * @description It is used to update the uncaught exception on Inbound Ingestion log record.
     * @param recordsProcessingExceptions
     */
    private void logUncaughtIngestionExceptionToInboundIngestionRecord(
        Exception recordsProcessingExceptions
    ) {
        fflib_ISObjectUnitOfWork uowForFailureIngestionUpdate = Application.UNITOFWORK.newInstance();
        uowForFailureIngestionUpdate.registerDirty(
            new Inbound_ingestion_Log__c(
                Id = inboundIngestionLogs[0].Id,
                Status__c = STATUS_FAILED,
                Business_Error_Message__c = BUSINESS_ERROR_MESSAGE,
                Failure_Step__c = this.methodName == ''
                    ? 1
                    : Decimal.valueof(payloadMethodsToStepMap.get(this.methodName)),
                Stack_Trace__c = recordsProcessingExceptions.getStackTraceString(),
                Exception_Message__c = recordsProcessingExceptions.getMessage()
            )
        );
        uowForFailureIngestionUpdate.commitWork();
        logIngestionExceptionToScaler(recordsProcessingExceptions);
    }

    /**
     * @description It is used to log the ingestion exceptions to scaler
     * @param recordsProcessingExceptions
     */
    private void logIngestionExceptionToScaler(Exception recordsProcessingExceptions) {
        IinboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
            SELF_SERVING_ONBOARDING_SERVICE,
            CPQ_WS,
            inboundIngestionLogs[0].Id,
            inboundIngestionLogs[0].UUID__c,
            ''
        );
        InboundIngestionLoggerService.logException(
            loggerEntry,
            recordsProcessingExceptions != null
                ? recordsProcessingExceptions
                : new dmlexception(COMMITWORK_MESSAGE),
            BUSINESS_ERROR_MESSAGE,
            this.methodName != '' ? payloadMethodsToStepMap.get(this.methodName) : '',
            new Set<String>{ inboundIngestionLogs[0].Id },
            recordsProcessingExceptions != null ? recordsProcessingExceptions.getTypeName() : ''
        );
    }
    /**
     * @description It is used to check whether an existing Opportunity with a Primary Quote existing or not.
     * @param businessIdFromPayload
     * @return Opportunity
     */
    private Opportunity isOpportunityWithPrimaryQuoteExist(String businessIdFromPayload) {
        Opportunity existingOpportunity;
        if (!this.existingOpportunityByAccountId.isEmpty()) {
            existingOpportunity = this.existingOpportunityByAccountId.get(
                this.existingAccountByBusinessId.get(businessIdFromPayload).Id
            );
        }
        return existingOpportunity;
    }

    /**
     * @description It is used to check whether an existing account found or not.
     * @param eachInstantIngestionPayload
     * @return Boolean
     */
    private Boolean isExistingAccountFound(
        InstantIngestionPayloadParser eachInstantIngestionPayload
    ) {
        return (!this.existingAccountByBusinessId.isEmpty() &&
        this.existingAccountByBusinessId.containsKey(
            eachInstantIngestionPayload.business.businessId
        ));
    }

    /**
     * @description It is used to get the parsed payload by the passed inbound ingestion log ids.
     * @param inboundIngestionLogIds
     * @return Map<String, InstantIngestionPayloadParser>
     */
    private Map<String, InstantIngestionPayloadParser> getParsedPayloadByUniqueInboundIngestionLogs(
        Set<Id> inboundIngestionLogIds
    ) {
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID = new Map<String, InstantIngestionPayloadParser>();
        for (
            Inbound_Ingestion_Log__c eachInboundIngestionLog : InboundIngestionLogsSelector.newInstance()
                .selectById(inboundIngestionLogIds)
        ) {
            payLoadWrapperByIngestionLogUUID.put(
                eachInboundIngestionLog.UUID__c,
                (InstantIngestionPayloadParser) System.JSON.deserialize(
                    eachInboundIngestionLog.Payload__c,
                    InstantIngestionPayloadParser.class
                )
            );
            this.sourceByUUID.put(
                eachInboundIngestionLog.UUID__c,
                eachInboundIngestionLog.Source__c
            );
            integrationTypeByUUID.put(
                eachInboundIngestionLog.UUID__c,
                eachInboundIngestionLog.Integration_Type__c
            );
            inboundIngestionLogs.add(eachInboundIngestionLog);
            inboundIngestionLogByUUID.put(eachInboundIngestionLog.UUID__c, eachInboundIngestionLog);
        }
        return payLoadWrapperByIngestionLogUUID;
    }

    /**
     * @description It is used to publish the instant ingestor events by the received event topic.
     * @param eventTopic
     */
    private void publishEventsByEventTopic(String eventTopic) {
        InstantIngestorEventsService.publishEvents(
            new Map<String, String>{ eventTopic => JSON.serialize(this.recordIdsByPayload) }
        );
    }

    /**
     * @description It is used to get the existing account Ids.
     * @return Set<Id>
     */
    private Set<Id> getExistingAccountIds() {
        Set<Id> existingAccountIds = new Set<Id>();
        for (Account eachExistingAccount : this.existingAccountByBusinessId.values()) {
            existingAccountIds.add(eachExistingAccount.Id);
        }
        return existingAccountIds;
    }

    /**
     * @description It is used to get the existing primary quote ids.
     * @return Set<Id>
     */
    private Set<Id> getExistingPrimaryQuoteIds() {
        Set<Id> existingPrimaryQuoteIds = new Set<Id>();
        for (Opportunity eachExistingOpportunity : this.existingOpportunityByAccountId.values()) {
            if(eachExistingOpportunity?.SBQQ__PrimaryQuote__c != null){
                existingPrimaryQuoteIds.add(eachExistingOpportunity.SBQQ__PrimaryQuote__c);
            }
        }
        return existingPrimaryQuoteIds;
    }

    /**
     * @description It is used to get the existing accounts by business id or unique identifiers.
     * @param eachInstantIngestionPayload
     * @param payLoadWrapperByIngestionLogUUID
     * @return Account
     */
    private Account getExistingAccountForAssociation(
        InstantIngestionPayloadParser eachInstantIngestionPayload,
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Map<String, Account> businessAccountByUUID = InstantIngestionRecordsGetterService.getBusinessAccountByUUID(
            payLoadWrapperByIngestionLogUUID,
            null
        );
        Account existingAccount = this.existingAccountByBusinessId.get(
                eachInstantIngestionPayload.business.businessId
            ) == null
            ? businessAccountByUUID.get(eachInstantIngestionPayload.Uuid)
            : this.existingAccountByBusinessId.get(eachInstantIngestionPayload.business.businessId);
        return existingAccount;
    }

    /**
     * @description It is used to get the existing brands by business id or unique identifiers.
     * @param eachInstantIngestionPayload
     * @param payLoadWrapperByIngestionLogUUID
     * @return Account
     */
    private Brand__c getExistingBrandForAssociation(
        InstantIngestionPayloadParser eachInstantIngestionPayload,
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Map<Id, Brand__c> existingBrandByAccountId = InstantIngestionCheckRecordsService.getExistingBrands(
            new Map<Id, Account>(this.existingAccountByBusinessId.values()).keySet()
        );
        Map<String, Brand__c> brandsByUUID = InstantIngestionRecordsGetterService.getBrandByUUID(
            payLoadWrapperByIngestionLogUUID,
            null
        );
        Brand__c existingBrand = this.existingAccountByBusinessId.get(
                eachInstantIngestionPayload.business.businessId
            ) == null
            ? brandsByUUID.get(eachInstantIngestionPayload.Uuid)
            : existingBrandByAccountId.get(
                  getExistingAccountForAssociation(
                          eachInstantIngestionPayload,
                          payLoadWrapperByIngestionLogUUID
                      )
                      .Id
              );
        return existingBrand;
    }

    /**
     * @description : Initiates the creation of store accounts by business ID.
     *
     * @param payLoadWrapperByIngestionLogUUID A map containing the InstantIngestionPayloadParser objects
     *                                         mapped by the ingestion log UUID.
     * @return A list of Database.SaveResult objects representing the results of the store account creation.
     */
    private List<Database.SaveResult> initiateStoreAccountsCreationByBusinessId(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<String, Submarket__c> submarkets = InstantIngestionRecordsGetterService.getSubmarkets(
            payLoadWrapperByIngestionLogUUID.values()
        );
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionAccountService.createStoreAccount(
                    eachInstantIngestionPayload,
                    null,
                    this.existingAccountByBusinessId.get(
                        eachInstantIngestionPayload.business.businessId
                    ),
                    this.businessVerticalRx,
                    submarkets.containsKey(
                            eachInstantIngestionPayload.store.addressVerificationInfo?.submarket?.id
                        )
                        ? submarkets.get(
                                  eachInstantIngestionPayload.store.addressVerificationInfo
                                      ?.submarket
                                      ?.id
                              )
                              .Id
                        : ''
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description : Initiates the creation of cross-references (Xrefs) by business ID.
     *
     * @param payLoadWrapperByIngestionLogUUID A map containing the InstantIngestionPayloadParser objects
     *                                         mapped by the ingestion log UUID.
     * @return A list of Database.SaveResult objects representing the results of the Xref creation.
     */
    private List<Database.SaveResult> initiateXrefsCreationByBusinessId(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<String, Account> storeAccountByUUID = InstantIngestionRecordsGetterService.getStoreAccountByUUID(
            payLoadWrapperByIngestionLogUUID
        );
        Map<String, Business_Reference__c> bizRefByBusinessId = getBizRefByBusinessId(
            payLoadWrapperByIngestionLogUUID
        );
        for (
            InstantIngestionPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionXrefBizRefService.createXref(
                    eachInstantIngestionPayload,
                    null,
                    this.existingAccountByBusinessId.get(
                        eachInstantIngestionPayload.business.businessId
                    ),
                    storeAccountByUUID.get(eachInstantIngestionPayload.Uuid),
                    bizRefByBusinessId.get(eachInstantIngestionPayload.business.businessId),
                    sourceByUUID.get(eachInstantIngestionPayload.Uuid)
                )
            );
        }
        return commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description returns external Id of Biz Ref with respective Biz Ref
     * @author VenkateshDD | 07-18-2024
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, Business_Reference__c>
     **/
    private Map<String, Business_Reference__c> getBizRefByBusinessId(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Set<String> bizIds = new Set<String>();
        for (
            InstantIngestionPayloadParser eachPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            bizIds.add(eachPayload.business.businessId);
        }
        return InstantIngestionCheckRecordsService.getExistingBusinessReferences(bizIds);
    }
}