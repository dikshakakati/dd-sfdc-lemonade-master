/**
 * @author Deloitte
 * @date   04/03/2022
 * @description This is the service implementation class for Account related logic
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.ExcessiveClassLength')
public inherited sharing class AccountsServiceImpl implements IAccountsService {
    private static final String BUSINESS = 'Business';
    private static final String CORPORATE = 'Corporate';
    private static final String SMB = 'SMB';
    private static final String DATETIME_DAY_OF_WEEK_SYMBOL = 'E';
    private static final List<String> DAYS_OF_THE_WEEK = new List<String>{ 'Sat', 'Sun' };
    static final String IN_PURSUIT = 'In Pursuit';
    static final String UNVETTED = 'Unvetted';
    static final String FRANCHISEE = 'Franchisee';
    private static final String NON_DUPLICATE = 'Non-Duplicate';
    private static final String DUPLICATE = 'Duplicate';
    private static final String AGGREGATE_COUNT_FIELD_ALIAS = 'countIds';
    private static final String EVENT_TOPIC_TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS = 'TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS';
    private static final String TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Trickle_Down_Parent_Account_Fields';
    private Integer parentAccountIdsChunkSizeToTrickleDownAccountFields;
    private Integer childAccountsToTrickleDownQueryLimit;
    private static final String CHILD_ACCOUNTS_TRICKLE_DOWN_QUERY_LIMIT_STATIC_CONFIG = 'Child_Accounts_Trickle_Down_Query_Limit';
    private static final String AGGREGATE_ACCOUNT_ID_FIELD_ALIAS = 'parentId';
    private static final String EVENT_TOPIC_UPDATE_ACCOUNT_ISMERGED_FLAG = 'UPDATE_ACCOUNT_ISMERGED_FLAG';
    private static final String EVENT_TOPIC_UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_ACCOUNT = 'UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_ACCOUNT';
    private static final String EVENT_TOPIC_UPDATE_DUPLICATE_STATUS = 'UPDATE_ACCOUNT_DUPLICATE_STATUS';
    private static final String PROCESS_MERGED_ACCOUNT_BATCH_CLASS = 'ProcessMergedAccountChildRecords';
    private static final String DUPLICATE_RULE_NAME = 'Account_Low_Complexity_Duplicate_Rule';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_DEACTIVATED = 'Deactivated'; //@LEM-11258
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String PARENT_ACCOUNT_FIELDS_TRICKLE_DOWN_ERROR = 'An exception occurred while trickling down parent account fields on child accounts, check logs for more details. Parent Account Record Ids: ';
    private static final String STORE = 'Store';
    private static final Id STORE_RECORD_TYPE_ID;
    private static final Id BUSINESS_RECORD_TYPE_ID;
    private static final String WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS_STATIC_CONFIG = 'Withholding_Opt_out_Limit_in_Days';
    private Integer withholdingOptOutLimit;
    private static final String LOG_SERVICE_ACCOUNT_SERVICE = 'Account Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final String FRANCHISE_REP_ROLE = 'Franchise Representative';
    private static final String ACCOUNT_CONTROL_OF_PRICE = 'Control_of_Price__c';
    private static final String ACCOUNT_OWNER = 'OwnerId';
    private static final String ACCOUNT_DECK_RANK = 'Deck_Rank__c';
    private static final String CONTRACTUAL = 'Contractual';

    private enum FIELDS_TO_TRICKLE_DOWN {
        CONTROLOFPRICE,
        OWNER,
        DECKRANK
    }
    private static final Map<String, FIELDS_TO_TRICKLE_DOWN> FIELDS_TO_TRICKLE_DOWN_MAPPINGS = new Map<String, FIELDS_TO_TRICKLE_DOWN>{
        ACCOUNT_CONTROL_OF_PRICE => FIELDS_TO_TRICKLE_DOWN.CONTROLOFPRICE,
        ACCOUNT_OWNER => FIELDS_TO_TRICKLE_DOWN.OWNER,
        ACCOUNT_DECK_RANK => FIELDS_TO_TRICKLE_DOWN.DECKRANK
    };
    private static final Set<String> ACCOUNT_TYPES_TO_ALLOW_ACCOUNT_OWNER_AND_CONTROL_OF_PRICE_TRICKLE_DOWN = new Set<String>{
        CORPORATE
    };
    private static final Set<String> ACCOUNT_SEGMENT_TO_ALLOW_DECK_RANK_TRICKLE_DOWN = new Set<String>{
        SMB
    };
    private static final List<String> ALCOHOL_SERVICES = System.Label.ALCOHOL_SERVICES.split(',');
    private static final String ACTIVE_VALUE = 'Yes';
    private static final String PARTNERSHIP_LEVEL_EXCLUSIVE = 'Exclusive';
    private static final String PARTNERSHIP_LEVEL_PREFERRED = 'Preferred';
    /**
     * @description Default constructor for this class.
     */
    public AccountsServiceImpl() {
        collectStaticConfigurations();
    }

    static {
        STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
    }

    /**
     * @description This method is used to handle the published Notifier events.
     * @param notifierEvents list of platform events with payload
     */
    public void handleNotifierEvents(List<Notifier__e> notifierEvents) {
        Set<Id> mergedAccounts = new Set<Id>();
        Set<Id> parentAccountIdsToTrickleDownFields = new Set<Id>();
        Set<Id> recordIdsByPayload;
        List<String> payloadForFranchiseUpdate = new List<String>();
        for (Notifier__e eachEvent : notifierEvents) {
            if (
                eachEvent.Topic__c ==
                EVENT_TOPIC_UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_ACCOUNT
            ) {
                payloadForFranchiseUpdate.add(eachEvent.Payload__c);
                continue;
            }
            recordIdsByPayload = (Set<Id>) JSON.deserialize(eachEvent.Payload__c, Set<Id>.class);
            if (recordIdsByPayload == null) {
                continue;
            }
            if (eachEvent.Topic__c == EVENT_TOPIC_UPDATE_ACCOUNT_ISMERGED_FLAG) {
                mergedAccounts.addAll(recordIdsByPayload);
            } else if (eachEvent.Topic__c == EVENT_TOPIC_UPDATE_DUPLICATE_STATUS) {
                updateDuplicateStatusOnAccount(recordIdsByPayload);
            } else if (eachEvent.Topic__c == EVENT_TOPIC_TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS) {
                parentAccountIdsToTrickleDownFields.addAll(recordIdsByPayload);
            }
        }
        if (payloadForFranchiseUpdate.size() > 0) {
            updateFranchiseBusinessAndStoreAccount(payloadForFranchiseUpdate);
        }
        //JIRA# LEM-12375: Process child accounts by parent accounts to trickle down fields
        processChildAccountsByParentAccountsToTrickleDownFields(
            parentAccountIdsToTrickleDownFields
        );
        updateWinningAccountIsMergedFlag(mergedAccounts);
    }

    /**
     * @description
     * @author rishab.goyal | 03-20-2024
     * @param payload
     **/
    private void updateFranchiseBusinessAndStoreAccount(List<String> payload) {
        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            List<Account> accountsToBeUpdated = new List<Account>();
            for (String accountIdWithOwnerId : payload) {
                String accountId = accountIdWithOwnerId.split(':')[0];
                String ownerId = accountIdWithOwnerId.split(':')[1];
                accountsToBeUpdated.add(new Account(Id = accountId, OwnerId = ownerId));
            }
            uow.registerDirty(accountsToBeUpdated);
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_ACCOUNT_SERVICE,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description It is used to stamp the date after a configured number of business days
     * on "Withholding Opt-out Expiry Date" field on the passed corporate accounts.
     * @JIRA# LEM-10617
     * @param corporateAccountIds
     */
    public void stampWithholdingExpiryDateOnCorporateAccounts(Set<Id> corporateAccountIds) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Id eachCorporateAccountId : corporateAccountIds) {
            uow.registerDirty(
                new Account(
                    Id = eachCorporateAccountId,
                    Withholding_Opt_out_Expiry_Date__c = getDateAfterConfiguredBusinessDays()
                )
            );
        }
        uow.commitWork();
    }
    /**
     * @description This method is used to update duplicate status on account.
     * @param accountIds
     * @JIRA# LEM-3673
     */
    private void updateDuplicateStatusOnAccount(Set<Id> accountIds) {
        if (accountIds.isEmpty()) {
            return;
        }
        Map<Id, String> accountsWitStatusValue = new Map<Id, String>();
        List<Id> modifiedAccountIds = new List<Id>();
        modifiedAccountIds.addAll(accountIds);

        Map<Id, List<Account>> accountWithDuplicates = CheckDuplicatesService.getMapOfSObjectIdWithDuplicates(
            modifiedAccountIds,
            DUPLICATE_RULE_NAME
        );

        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Id accountId : accountWithDuplicates.keySet()) {
            List<Account> duplicateAccounts = accountWithDuplicates.get(accountId);

            registerAccountDuplicateStatus(
                accountId,
                duplicateAccounts,
                accountsWitStatusValue,
                uow
            );
        }

        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description This method is used to register duplicate status on account.
     * @param accountId
     * @param duplicateAccounts
     * @param accountsWitStatusValue
     * @param uow
     */
    private void registerAccountDuplicateStatus(
        Id accountId,
        List<Account> duplicateAccounts,
        Map<Id, String> accountsWitStatusValue,
        fflib_ISObjectUnitOfWork uow
    ) {
        if (duplicateAccounts.isEmpty()) {
            uow.registerDirty(new Account(Id = accountId, Duplicate_Status__c = NON_DUPLICATE));
            return;
        }

        for (Account eachAccount : duplicateAccounts) {
            if (
                (accountsWitStatusValue.containsKey(eachAccount.Id) &&
                accountsWitStatusValue.get(eachAccount.Id) != DUPLICATE) ||
                (!accountsWitStatusValue.containsKey(eachAccount.Id) &&
                eachAccount.Duplicate_Status__c == NON_DUPLICATE)
            ) {
                uow.registerDirty(new Account(Id = accountId, Duplicate_Status__c = DUPLICATE));
                accountsWitStatusValue.put(accountId, DUPLICATE);
                break;
            }
        }

        if (!accountsWitStatusValue.containsKey(accountId)) {
            uow.registerDirty(new Account(Id = accountId, Duplicate_Status__c = NON_DUPLICATE));
            accountsWitStatusValue.put(accountId, NON_DUPLICATE);
        }
    }

    /**
     * @description It is used to update the MDS Activation on Account to true whenever the
     * related Xref is created or updated
     * @param accountsToBeUpdated
     */
    public void updateAccountsForActivatingAndDeactivatingMDSXrefs(
        List<Account> accountsToBeUpdated
    ) {
        fflib_ISObjectUnitOfWork accountUnitOfWork = Application.UnitOfWork.newInstance();
        accountUnitOfWork.registerDirty(accountsToBeUpdated);
        accountUnitOfWork.commitWork();
    }

    /**
     * @description It is used to update the MDS Activation on Account to true whenever the
     * related Xref is created or updated
     * @param accountsToBeDeactivated
     * @return Set<Id>
     */
    public Set<Id> checkAccountsForDeactivation(Set<Id> accountsToBeDeactivated) {
        List<Xref__c> activeXrefs = XrefsSelector.newInstance()
            .selectBySalesforceAccountName(accountsToBeDeactivated);
        Set<Id> accountsWithActiveMDS = new Set<Id>();
        Boolean isActiveXref = false;
        for (Xref__c eachXref : activeXrefs) {
            isActiveXref =
                eachXref.External_ID_Source__c == EXTERNAL_ID_SOURCE_MDS &&
                eachXref.External_ID__c != null &&
                eachXref.BusinessID__c != null &&
                eachXref.Xref_Status__c == STATUS_ACTIVE;
            if (isActiveXref) {
                accountsWithActiveMDS.add(eachXref.Salesforce_Account_Name__c);
            }
        }
        accountsToBeDeactivated.removeAll(accountsWithActiveMDS);
        return accountsToBeDeactivated;
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.parentAccountIdsChunkSizeToTrickleDownAccountFields = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(
                    TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
                .Configuration_Value__c
        );
        this.childAccountsToTrickleDownQueryLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(CHILD_ACCOUNTS_TRICKLE_DOWN_QUERY_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It checks whether the Account satisfies following criteria to send the notification
     * to trickle down account ownership:
     * #1: Account's Record Type is "Business".
     * #2: Account's Type should not contains "Holding Group", "Franchisee".
     * @JIRA# LEM-11918, LEM-12375
     * @param accountInstance
     * @return Boolean
     */
    private Boolean isEligibleToTrickleDownAccountOwnershipAndControlOfPrice(
        Account accountInstance
    ) {
        return (accountInstance.Record_Type_Name__c == BUSINESS &&
            ACCOUNT_TYPES_TO_ALLOW_ACCOUNT_OWNER_AND_CONTROL_OF_PRICE_TRICKLE_DOWN.contains(
                accountInstance.Type
            )) ||
            (accountInstance.Record_Type_Name__c == STORE &&
            accountInstance.Franchise_Parent__c == null);
    }
    /**
     * @description It checks whether the child account satisfies the criteria to copy the
     * deck rank from parent account.
     * @param accountInstance
     * @return Boolean
     */
    private Boolean isEligibleToTrickleDownDeckRank(Account accountInstance) {
        return (accountInstance.Record_Type_Name__c == STORE &&
            ACCOUNT_SEGMENT_TO_ALLOW_DECK_RANK_TRICKLE_DOWN.contains(accountInstance.Segment__c)) ||
            (accountInstance.Record_Type_Name__c == BUSINESS &&
            ACCOUNT_SEGMENT_TO_ALLOW_DECK_RANK_TRICKLE_DOWN.contains(accountInstance.Segment__c));
    }

    /**
     * @description It is used to process child accounts associated with the passed parent accounts
     * which are eligible for trickle down fields.
     * @JIRA# LEM-11918, LEM-12375
     * @param parentAccountIdsToTrickleDownFields
     */
    private void processChildAccountsByParentAccountsToTrickleDownFields(
        Set<Id> parentAccountIdsToTrickleDownFields
    ) {
        Set<Id> getFieldParentAccountIdsToBeProcessedsToTrackTrickleDownEligibility = new Set<Id>();
        Integer countOfChildAccountsWithNonMatchingAccountFieldsBeforeTrickleDown = 0;
        Integer countOfChildAccountsWithNonMatchingAccountFieldsAfterTrickleDown = 0;
        //LEM-11918: Get the count of child accounts from the parent account
        for (
            Aggregate eachAggregate : AccountsSelector.newInstance()
                .selectCountOfNonMatchingParentAccountFieldsAccounts(
                    parentAccountIdsToTrickleDownFields
                )
        ) {
            getFieldParentAccountIdsToBeProcessedsToTrackTrickleDownEligibility.add(
                (Id) eachAggregate.get(AGGREGATE_ACCOUNT_ID_FIELD_ALIAS)
            );
            countOfChildAccountsWithNonMatchingAccountFieldsBeforeTrickleDown += (Integer) eachAggregate.get(
                AGGREGATE_COUNT_FIELD_ALIAS
            );
        }
        //Updates the child accounts with the parent account fields
        trickleDownParentAccountFields(parentAccountIdsToTrickleDownFields);
        for (
            Aggregate eachAggregate : AccountsSelector.newInstance()
                .selectCountOfNonMatchingParentAccountFieldsAccounts(
                    parentAccountIdsToTrickleDownFields
                )
        ) {
            getFieldParentAccountIdsToBeProcessedsToTrackTrickleDownEligibility.add(
                (Id) eachAggregate.get(AGGREGATE_ACCOUNT_ID_FIELD_ALIAS)
            );
            countOfChildAccountsWithNonMatchingAccountFieldsAfterTrickleDown += (Integer) eachAggregate.get(
                AGGREGATE_COUNT_FIELD_ALIAS
            );
        }
        if (
            !getFieldParentAccountIdsToBeProcessedsToTrackTrickleDownEligibility.isEmpty() &&
            countOfChildAccountsWithNonMatchingAccountFieldsBeforeTrickleDown !=
            countOfChildAccountsWithNonMatchingAccountFieldsAfterTrickleDown
        ) {
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        getFieldParentAccountIdsToBeProcessedsToTrackTrickleDownEligibility,
                        parentAccountIdsChunkSizeToTrickleDownAccountFields
                    )
                }
            );
        } else if (
            countOfChildAccountsWithNonMatchingAccountFieldsBeforeTrickleDown != 0 &&
            //Count didn't change after trickling down the fields
            countOfChildAccountsWithNonMatchingAccountFieldsBeforeTrickleDown ==
            countOfChildAccountsWithNonMatchingAccountFieldsAfterTrickleDown
        ) {
            Logger.publish(
                PARENT_ACCOUNT_FIELDS_TRICKLE_DOWN_ERROR +
                JSON.serialize(parentAccountIdsToTrickleDownFields),
                LogEntry.SeverityLevel.HIGH
            );
        }
    }

    /**
     * @description It trickles down the defined fields from parent Account
     * to eligible child Accounts.
     * @JIRA# LEM-11918
     * @param parentAccountIdsToTrickleDownFields
     */
    private void trickleDownParentAccountFields(Set<Id> parentAccountIdsToTrickleDownFields) {
        if (parentAccountIdsToTrickleDownFields.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (
            Account eachChildAccount : AccountsSelector.newInstance()
                .selectChildAccountsForAccountFieldsTrickleDown(
                    parentAccountIdsToTrickleDownFields,
                    childAccountsToTrickleDownQueryLimit
                )
        ) {
            applyFieldValuesByParent(
                eachChildAccount,
                eachChildAccount.Parent
            );
            uow.registerDirty(eachChildAccount);
        }
        uow.commitWork();
    }

    /**
     * @description It applies the defined field’s value on the eligible child Account from the
     * associated parent Account.
     * @JIRA# LEM-11918
     * @param childAccount
     * @param parentAccount
     */
    private void applyFieldValuesByParent(
        Account childAccount,
        Account parentAccount
    ) {
        String fieldName;
        for (
            Schema.FieldSetMember eachFieldSetMember : (SObjectType.Account.FieldSets.Parent_Fields_To_Trickle_Down)
                .getFields()
        ) {
            fieldName = String.valueOf(eachFieldSetMember.getSObjectField());
            switch on FIELDS_TO_TRICKLE_DOWN_MAPPINGS.get(fieldName) {
                when CONTROLOFPRICE {
                    if (isEligibleToTrickleDownAccountOwnershipAndControlOfPrice(childAccount)) {
                        copyFieldByParent(childAccount, parentAccount, fieldName);
                    }
                }
                when OWNER {
                    if (isEligibleToTrickleDownAccountOwnershipAndControlOfPrice(childAccount)) {
                        copyFieldByParent(childAccount, parentAccount, fieldName);
                    }
                }
                when DECKRANK {
                    if (isEligibleToTrickleDownDeckRank(childAccount)) {
                        copyFieldByParent(childAccount, parentAccount, fieldName);
                    }
                }
            }
        }
    }

    /**
     * @description  It copies the passed field's value from parent Account to child Account.
     * @JIRA# LEM-12375
     * @param childAccount
     * @param parentAccount
     * @param fieldName
     */
    private void copyFieldByParent(Account childAccount, Account parentAccount, String fieldName) {
        Boolean isNotNullValue = parentAccount.get(fieldName) instanceof String
            ? String.isNotBlank((String) parentAccount.get(fieldName))
            : parentAccount.get(fieldName) != null;
        if (isNotNullValue) {
            childAccount.put(fieldName, parentAccount.get(fieldName));
        }
    }

    /**
     * @description Set IsMerged flag to True for winning accounts.
     * @param winningAccounts
     */
    private void updateWinningAccountIsMergedFlag(Set<Id> winningAccounts) {
        if (winningAccounts.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Id eachAccountId : winningAccounts) {
            uow.registerDirty(new Account(Id = eachAccountId, Is_Merged__c = true));
        }
        uow.commitWork();
        scheduleMergedJob();
    }

    /**
     * @description To schedule ProcessMergedAccountChildRecords Batch if not already scheduled
     */
    private void scheduleMergedJob() {
        Integer currentHour;
        Integer currentMinute;
        Integer currentSecond;

        List<AsyncApexJob> scheduleMergedJob = AsyncApexJobsSelector.newInstance()
            .selectRunningAsycJobByApexClassName(PROCESS_MERGED_ACCOUNT_BATCH_CLASS);
        if (!scheduleMergedJob.isEmpty()) {
            return;
        }

        //Schedule Job After 10 min
        currentMinute = Datetime.now().minute() + 10;
        if (currentMinute > 59) {
            currentHour = Datetime.now().hour() + 1;
            currentMinute -= 60;
        } else {
            currentHour = Datetime.now().hour();
        }
        currentSecond = Datetime.now().second();

        if (currentHour > 23) {
            return;
        }

        String cronExpression = currentSecond + ' ' + currentMinute + ' ' + currentHour + ' * * ?';

        if (Test.isRunningTest()) {
            return;
        }

        System.schedule(
            PROCESS_MERGED_ACCOUNT_BATCH_CLASS,
            cronExpression,
            new ProcessMergedAccountChildRecords()
        );
    }

    /**
     * @description To process parent accounts on account merge
     * @param parentIds
     */
    public void processMergedParentAccounts(Set<Id> parentIds) {
        if (parentIds.isEmpty()) {
            return;
        }
        AccountRollupService.publishStoreRollUpEvents(parentIds);
        AccountRollupService.publishVerticalRollUpEvents(parentIds);
        AccountRollupService.publishPartnershipStatusRollUpEvents(parentIds);
        populateUltimateParentAccount(parentIds);
        disableIsMerged(parentIds);
    }

    /**
     * @description To process child accounts on account merge
     * @param childAccounts
     */
    public void processMergedAccountsRelatedRecords(List<Account> childAccounts) {
        if (childAccounts.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        updateIsParentAccountMergedOnAccounts(childAccounts, uow);
        updateFranchiseParentSubtype(childAccounts, uow);
        uow.commitWork();
        Set<Id> childAccountIds = new Map<Id, Account>(childAccounts).keySet();
    	updateFieldsOnAccount(childAccountIds);
    }

    /**
     * @description It is used to get a Date after configured number of business days.
     * @JIRA# LEM-10617
     * @return Date
     */
    private Date getDateAfterConfiguredBusinessDays() {
        Integer timer = 0;
        Datetime currentDateTime = System.now();
        this.withholdingOptOutLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS_STATIC_CONFIG)
                .Configuration_Value__c
        );
        while (timer < withholdingOptOutLimit) {
            if (
                !DAYS_OF_THE_WEEK.contains(currentDateTime.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL))
            ) {
                timer++;
            }
            currentDateTime = currentDateTime.addDays(1);
        }
        return currentDateTime.date();
    }

    /**
     * @description It sets "Is Parent Account Merged" field as true on the passed childAccounts which triggers the further processing on ParentId change on accounts.
     * @param childAccounts
     * @param uow
     */
    private void updateIsParentAccountMergedOnAccounts(
        List<Account> childAccounts,
        fflib_ISObjectUnitOfWork uow
    ) {
        for (Account eachAccount : childAccounts) {
            uow.registerDirty(new Account(Id = eachAccount.Id, Is_Parent_Account_Merged__c = true));
        }
    }

    /**
     * @description Update Type field for Franchisee parent.
     * @param childAccounts
     * @param uow
     */
    private void updateFranchiseParentSubtype(
        List<Account> childAccounts,
        fflib_ISObjectUnitOfWork uow
    ) {
        Set<Id> parentAccounts = new Set<Id>();
        // To set parentAccounts values if record type is store and franchise parent is not null
        for (Account storeAccount : childAccounts) {
            if (
                storeAccount.RecordTypeId == STORE_RECORD_TYPE_ID &&
                storeAccount.Franchise_Parent__c != null
            ) {
                parentAccounts.add(storeAccount.Franchise_Parent__c);
            }
        }
        for (
            Account franchiseAccount : AccountsSelector.newInstance()
                .selectNonFranchiseeAccountsById(parentAccounts)
        ) {
            franchiseAccount.Type = FRANCHISEE;
            uow.registerDirty(franchiseAccount, new List<SObjectField>{ Account.Type });
        }
    }

    /**
     * @description To run batch to Populate ultimate parent account
     * @param parentIds
     */
    public void populateUltimateParentAccount(Set<Id> parentIds) {
        AsyncBatchRunner.executeBatch(new UltimateParentUpdateBatchable(parentIds));
    }

    /**
     * @description It is used to update "Proposed Date of Activation"/"Proposed Date of Menu"/
     * "Proposed Date of Tablet" fields from parent Work Order on store Account where
     * "User Sets PDOA Value?"/"User Sets PDOM Value?"/"User Sets PDOT Value?" is 'No' or null.
     * @JIRA# LEM-2854, LEM-3402 & LEM-3442
     * @param storeAccountsToCopyPDOX
     */
    public void populatePDOXOnStoreAccounts(List<Account> storeAccountsToCopyPDOX) {
        if (storeAccountsToCopyPDOX.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        unitOfWorkInstance.registerDirty(storeAccountsToCopyPDOX);
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception populatePDOXOnStoreAccountsException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    populatePDOXOnStoreAccountsException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_ACCOUNT_SERVICE,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(populatePDOXOnStoreAccountsException)
            );
        }
    }

    /**
     * @description Constructor to perform before update processing\
     * @param referenceAccounts
     */
    public void updateUltimateParent(List<Account> referenceAccounts) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Account a : referenceAccounts) {
            a.Ultimate_Parent_Account__c = getUltimateParent(a);
            uow.registerDirty(a);
        }
        try {
            uow.commitWork();
        } catch (Exception changesFailedCommit) {
            Logger.publish(
                LogEntry.newExceptionLog(changesFailedCommit, LogEntry.SeverityLevel.HIGH)
            );
        }
    }

    /**
     * @description Update Accounts
     * @param accountsToUpdate
     */
    public void updateAccounts(List<Account> accountsToUpdate) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(accountsToUpdate);
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description Constructor to perform before update processing
     * @param updatedAccount
     * @return Id
     */
    private Id getUltimateParent(Account updatedAccount) {
        if (updatedAccount.Parent.Parent.Parent.ParentId != null) {
            return updatedAccount.Parent.Parent.Parent.ParentId;
        } else if (updatedAccount.Parent.Parent.ParentId != null) {
            return updatedAccount.Parent.Parent.ParentId;
        } else if (updatedAccount.Parent.ParentId != null) {
            return updatedAccount.Parent.ParentId;
        } else if (updatedAccount.ParentId != null) {
            return updatedAccount.ParentId;
        }
        return null;
    }

    /**
     * @description this method used to update Account life cycle status to In Pursuit.
     * @param accountIds passing Account ids of the related opportunitties.
     * @param accountIdsOfTheExistingOpportunities
     */
    public void updateAcountLifeCycleStatusToUnvetted(
        Set<Id> accountIds,
        Set<Id> accountIdsOfTheExistingOpportunities
    ) {
        List<Account> updateAccount = new List<Account>();
        for (
            Account account : AccountsSelector.newInstance()
                .selectInPursuitBusinessAccountsById(accountIds)
        ) {
            if (!accountIdsOfTheExistingOpportunities.contains(account.Id)) {
                account.Account_Lifecycle_Status__c = UNVETTED;
                updateAccount.add(account);
            }
        }
        updateAccounts(updateAccount);
    }

    /**
     * @description this method used to update Account life cycle status to In Pursuit.
     * @param accountIds passing Account ids of the related opportunitties.
     */
    public void updateAcountLifeCycleStatusToInPursuit(Set<Id> accountIds) {
        if(accountIds == null || accountIds.isEmpty()){
            return;
        }
        List<Account> updateAccount = new List<Account>();
        for (
            Account account : AccountsSelector.newInstance()
                .selectUnverifiedBusinessAccountsById(accountIds)
        ) {
            account.Account_Lifecycle_Status__c = IN_PURSUIT;
            updateAccount.add(account);
        }
        updateAccounts(updateAccount);
    }

    /**
     * @description this method used to update Account attributes in top down automation
     * @param accountsToBeUpdated list of accounts to be updated
     */
    public void updateAccountAttributesTopDownAutomation(List<Account> accountsToBeUpdated) {
        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            for (Account accountToUpdate : accountsToBeUpdated) {
                if (accountToUpdate.Ultimate_Parent_Account__r != null) {
                    updateAccountFieldTopDown(
                        uow,
                        accountToUpdate.Ultimate_Parent_Account__r,
                        accountToUpdate,
                        Schema.Account.Segment__c
                    );
                }
            }
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description this method used to update account attributes in top down automation
     * @param uow unit of work instance
     * @param parentRecord parent account record
     * @param childRecord child account record
     * @param fieldToBeUpdated parent field that has be to be updated
     */
    void updateAccountFieldTopDown(
        fflib_ISObjectUnitOfWork uow,
        Account parentRecord,
        Account childRecord,
        Schema.SObjectField fieldToBeUpdated
    ) {
        String parentAttribute = (String) parentRecord.get(fieldToBeUpdated);
        String childAttribute = (String) childRecord.get(fieldToBeUpdated);
        if (!String.isBlank(parentAttribute) && parentAttribute != childAttribute) {
            childRecord.put(fieldToBeUpdated, parentAttribute);
            uow.registerDirty(childRecord, new List<SObjectField>{ fieldToBeUpdated });
        }
    }

    /**
     * @description IsMerged field set to false for given accounts.
     * @param accountsToUpdate
     */
    private void disableIsMerged(Set<Id> accountsToUpdate) {
        List<Account> processedAccounts = new List<Account>();
        for (Id accountId : accountsToUpdate) {
            processedAccounts.add(new Account(Id = accountId, Is_Merged__c = false));
        }
        updateAccounts(processedAccounts);
    }
    /**
     * @description To stamp field values on Child Accounts from Parent Account
     * @JIRA# LEM-8322
     * @param parentAccounts
     * @param fieldApiName
     */
    public void stampFieldValueOnChildAccounts(List<Account> parentAccounts, String fieldApiName) {
        List<Account> accountToUpdateList = new List<Account>();
        Map<Id, Account> accountToIdMap = new Map<Id, Account>(parentAccounts);
        Set<Id> parentAccountIds = accountToIdMap.keySet();
        for (
            Account accToBeUpdated : AccountsSelector.newInstance()
                .selectChildAccounts(parentAccountIds)
        ) {
            if (accountToIdMap.containsKey(accToBeUpdated.ParentId)) {
                updateAccountFieldValue(accountToIdMap, accToBeUpdated, fieldApiName);
                accountToUpdateList.add(accToBeUpdated);
            }
        }
        if (accountToUpdateList.isEmpty()) {
            return;
        }
        updateAccounts(accountToUpdateList);
    }
    /**
     * @description Update the specified field value on the account
     * @param accountToIdMap
     * @param accToBeUpdated
     * @param fieldApiName
     */
    private void updateAccountFieldValue(
        Map<Id, Account> accountToIdMap,
        Account accToBeUpdated,
        String fieldApiName
    ) {
        Account parentAccount = accountToIdMap.get(accToBeUpdated.ParentId);
        if (parentAccount != null) {
            accToBeUpdated.put(fieldApiName, (String) parentAccount.get(fieldApiName));
        }
    }
    /**
     * @description This method is used to update Experience__c on accounts
     * @param accountIds
     */
    public void updateFieldsOnAccount(Set<Id> accountIds) {
        if (accountIds.isEmpty()) {
            return;
        }
        List<Account> accountsToUpdate = new List<Account>();
        Set<String> platformValues = new Set<String>();
        String experience;
        Boolean alcoholAddendum;

        for (
            Account acc : AccountsSelector.newInstance()
                .selectAccountsWithActiveServices(accountIds)
        ) {
            platformValues.clear();
            experience = '';
            alcoholAddendum = false;
            if (acc.Services__r == null) {
                continue;
            }
            for (Merchant_Service__c service : acc.services__r) {
                if (String.isNotBlank(service.product__r.platform__c)) {
                    platformValues.add(service.product__r.platform__c);
                }
                if (!alcoholAddendum) {
                    alcoholAddendum =
                        ALCOHOL_SERVICES.contains(service.Name) &&
                        service.Active__c == ACTIVE_VALUE;
                }
            }
            experience = String.join(new List<String>(platformValues), ';');
            if (
                acc.Experience__c == experience &&
                acc.Alcohol_Addendum_Signed__c == alcoholAddendum
            ) {
                continue;
            }
            Account accObj = new Account(
                Id = acc.Id,
                Experience__c = experience,
                Alcohol_Addendum_Signed__c = alcoholAddendum
            );
            accountsToUpdate.add(accObj);
        }
        updateAccounts(accountsToUpdate);
    }
    /**
     * @description This method is used to update Rate_Change_Request__c on accounts
     * @param storeAccounts
     * @param rateChangeRequestId
     */
    public void updateRateChangeRequestOnAccount(
        List<Account> storeAccounts,
        Id rateChangeRequestId
    ) {
        List<Account> accountsToUpdate = new List<Account>();

        if (storeAccounts.isEmpty()) {
            return;
        }

        for (Account acc : storeAccounts) {
            Account accObj = new Account(Id = acc.Id, Rate_Change_Request__c = rateChangeRequestId);
            accountsToUpdate.add(accObj);
        }
        updateAccounts(accountsToUpdate);
    }

    /** populate Franchise Rep as owner of Franchise Accounts
     * @description
     * @author rishab.goyal | 03-18-2024
     * @param franchiseAccounts
     **/
    public void fetchAndPopulateOwnerOnFranchiseAccounts(List<Account> franchiseAccounts) {
        Set<Id> parentAccountIds = new Set<Id>();
        for (Account franchiseAccount : franchiseAccounts) {
            parentAccountIds.add(franchiseAccount.ParentId);
        }

        Map<Id, Account> parentAccounts = new Map<Id, Account>(
            AccountsSelector.newInstance().selectAccountWithAccTeamMembers(parentAccountIds)
        );
        for (Account franchiseAccount : franchiseAccounts) {
            if (!parentAccounts.containsKey(franchiseAccount.ParentId)) {
                continue;
            }
            Account parentAccount = parentAccounts.get(franchiseAccount.ParentId);

            if (
                parentAccount != null &&
                parentAccount.AccountTeamMembers != null &&
                !parentAccount.AccountTeamMembers.isEmpty()
            ) {
                Boolean isFranchiseOwnerAssigned = false;
                for (AccountTeamMember teamMember : parentAccount.AccountTeamMembers) {
                    if (teamMember.TeamMemberRole == FRANCHISE_REP_ROLE) {
                        franchiseAccount.OwnerId = teamMember.UserId;
                        isFranchiseOwnerAssigned = true;
                        break;
                    }
                }
                if (!isFranchiseOwnerAssigned) {
                    franchiseAccount.OwnerId = parentAccount.OwnerId;
                }
            }
        }
    }

    /**
     * @description This method is used to commit DML transactions in this accounts service and log any errors to scalyr
     * @param uow
     * @param serviceName
     */
    public void commitDmlTransactions(fflib_ISObjectUnitOfWork uow, String serviceName) {
        try {
            uow.commitWork();
        } catch (Exception unitOfWorkException) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        serviceName,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.MEDIUM
                    )
                    .logException(unitOfWorkException)
            );
        }
    }

    /**
     * @description This method is used to update the Activation Status on store accounts based on the MDS is_Active flag updates/sync
     * @param accountIdsTobeActivated
     * @param accountIdsEligibleForDeactivation
     */
    public void processStoreAccountsMdsActivationStatus(
        Set<Id> accountIdsTobeActivated,
        Set<Id> accountIdsEligibleForDeactivation
    ) {
        if (accountIdsTobeActivated.isEmpty() && accountIdsEligibleForDeactivation.isEmpty()) {
            return;
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accountsTobeUpdated = new List<Account>();

        if (!accountIdsTobeActivated.isEmpty()) {
            for (Id accId : accountIdsTobeActivated) {
                Account acc = new Account(Id = accId, Activation_Status__c = STATUS_ACTIVE);
                accountsTobeUpdated.add(acc);
            }
        }

        if (!accountIdsEligibleForDeactivation.isEmpty()) {
            for (
                Account acc : AccountsSelector.newInstance()
                    .getStoreAccountsWithValidActiveXrefs(accountIdsEligibleForDeactivation)
            ) {
                if (acc.Xrefs__r.isEmpty()) {
                    Account newAccount = new Account(
                        Id = acc.Id,
                        Activation_Status__c = STATUS_DEACTIVATED
                    );
                    accountsTobeUpdated.add(newAccount);
                }
            }
        }

        if (!accountsTobeUpdated.isEmpty()) {
            uow.registerDirty(accountsTobeUpdated);
            string serviceName = LOG_SERVICE_ACCOUNT_SERVICE + '- Activation Status Sync';
            commitDmlTransactions(uow, serviceName);
        }
    }
    /**
     * @description It is used to update Partnership Level and Partnership expiration date
     * on the account.
     * @param mapIdToQuote
     */
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
    public void populatePartnershipLevelOnAccount(Map<Id, SBQQ__Quote__c> mapIdToQuote) {
        String serviceName = LOG_SERVICE_ACCOUNT_SERVICE;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account accountToUpdate = new Account();
        if (mapIdToQuote.isEmpty()) {
            return;
        }
        Map<String, Partnership_Level_Mapping__mdt> mapPartnershipLevelToMetadata = new Map<String, Partnership_Level_Mapping__mdt>();
        for (
            Partnership_Level_Mapping__mdt mappingRecord : PartnershipLevelMappingSelector.newInstance()
                .getAllValues()
        ) {
            mapPartnershipLevelToMetadata.put(
                mappingRecord.Custom_Partnership_Type__c,
                mappingRecord
            );
        }
        Set<Id> accountIdFromQuote = new Set<Id>();
        for (SBQQ__Quote__c eachQuote : mapIdToQuote.values()) {
            if (eachQuote.Custom_Partnership_Type__c != null) {
                accountIdFromQuote.add(eachQuote.SBQQ__Account__c);
            }
        }
        if (accountIdFromQuote.isEmpty()) {
            return;
        }
        List<SBQQ__Quote__c> latestPrimaryQuote = QuotesSelector.newInstance()
            .selectPrimaryQuotesBySalesforceAccountIds(accountIdFromQuote);
        If(latestPrimaryQuote.size()>0){
            if (mapPartnershipLevelToMetadata.get(latestPrimaryQuote[0].Custom_Partnership_Type__c) !=null) {
                accountToUpdate.Id = latestPrimaryQuote[0].SBQQ__Account__c;
                accountToUpdate.Partnership_Level__c = mapPartnershipLevelToMetadata.get(
                        latestPrimaryQuote[0].Custom_Partnership_Type__c
                    )
                    .Partnership_Level__c;
                if (accountToUpdate.Partnership_Level__c == PARTNERSHIP_LEVEL_EXCLUSIVE || accountToUpdate.Partnership_Level__c == PARTNERSHIP_LEVEL_PREFERRED) {
                    Date partnershipExpDate = latestPrimaryQuote[0]
                        .Contract_Signed_Date__c.addYears(
                            Integer.valueOf(latestPrimaryQuote[0].Initial_Term_and_Termination_Years__c)
                        );
                    accountToUpdate.Partnership_Expiration_Date__c = partnershipExpDate;
                    accountToUpdate.Exclusivity_Type__c = CONTRACTUAL;
                }
                uow.registerDirty(accountToUpdate);
            }
        }
        commitDmlTransactions(uow, serviceName);
    }

    /**
     * @description It is used to nullify Renewal Opportunity lookup on Account when
     * Partnership Expiration Date is updated on the account.
     * @param accountToUpdateRenewalOpp
     */
    public void updateRenewalOpportunityOnAccount(List<Account> accountToUpdateRenewalOpp) {
        for (Account eachAccount : accountToUpdateRenewalOpp) {
            eachAccount.Renewal_Opportunity__c = null;
        }
    }

    /**
     * @description It is used to populate Renewal Opportunity lookup on Account when
     * renewal opportunity is created using batch on the account.
     * @param accountIdToOppMap
     */
    public void updateRenewalOpportunityCreatedFromBatchLookupOnAccount(
        Map<Id, Opportunity> accountIdToOppMap
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Id eachAccountId : accountIdToOppMap.keySet()) {
            uow.registerDirty(
                new Account(
                    Id = eachAccountId,
                    Renewal_Opportunity__c = accountIdToOppMap.get(eachAccountId).Id
                )
            );
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_ACCOUNT_SERVICE,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.MEDIUM
                    )
                    .logException(ex)
            );
        }
    }
}