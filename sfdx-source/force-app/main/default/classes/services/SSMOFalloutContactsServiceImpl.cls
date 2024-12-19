/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Service implementation class for inbound ingestion log update on contact object.
 */
public with sharing class SSMOFalloutContactsServiceImpl implements ISSMOFalloutContactsService {
    private static final String FORMER_PARTNER = 'Former Partner';
    private static final String PROSPECTIVE_PARTNER = 'Prospective Partner';
    private static final String NET_NEW_PARTNER = 'Net New Partner';
    private static final String EXISTING = 'Existing';
    private static final String EXISTING_PARTNER = 'Existing Partner';
    private static final String NEW_VALUE = 'New';
    private static final String STANDARD = 'Standard';
    private static final String NEW_STORE_EXPANSION = 'New Store Expansion';
    private static final String PROSPECTING = 'Prospecting';
    private static final String COMPLETED = 'Completed';
    private static final String FAILED = 'Failed';
    private static final String INFLUENCER = 'Influencer';
    private static final String SSMO_DROP_OFF = 'SSMO Drop Off';
    private static final Date TOMORROW = System.today().addDays(1);
    private static final Date AFTERTHIRTYDAYS = System.today().addDays(30);
    private static final String OPPORTUNITY_SUBSTAGE_UNTOUCHED = 'Untouched';
    private static final String BUSINESS_ERROR_MESSAGE_FOR_OPPORTUNITY = 'Opportunity Creation for Contact is failed.';
    private static final String BUSINESS_ERROR_MESSAGE = 'ACR, OCR, Task creation for Contact is failed.';
    String methodName = '';
    Contact contactRecord = new Contact();
    private static final String LOG_SELF_SERVING_FALLOUT_SERVICE = 'selfserviceFalloutService';
    private static final String SALES_WS = 'Sales';
    private static final String CLASS_NAME = 'SSMOFalloutContactsServiceImpl';
    private static final String CREATE_RELATED_RECORDS_BASED_ON_SSMO_PAYLOAD = 'createRelatedRecordsBasedOnSSMOPayload';
    private static final String CREATE_OPPORTUNITY_ACR_OCR_RECORDS_BY_SSMO_PAYLOAD = 'createOpportunityACROCRRecordsBySSMOPayload';
    private static final String CREATE_OPPORTUNITIES_AND_GET_OPPORTUNITY_IDS = 'createOpportunitiesAndGetOpportunityIds';
    private static final String CREATE_ACR_FOR_MATCHED_ACCOUNTS = 'createACRForMatchedAccounts';
    private static final String CHECK_ACCOUNTS_WITH_ASSOICATED_PARENT_ACCOUNTS = 'checkAccountsWithAssociatedParentAccounts';
    private static final String CHECK_ACCOUNTS_WITH_ASSOICATED_CHILD_ACCOUNTS = 'checkAccountsWithAssociatedChildAccounts';
    private static final String VALIDATE_IF_NO_ACR_THEN_CREATE_ACR = 'validateIfNoACRThenCreateACR';
    private static final String CREATE_OCR_USING_OPPORTUNITY_AND_CONTACT_DETAILS = 'createOCRUsingOpportunityAndContactDetails';
    private static Map<String, String> methodsToStepMap = new Map<String, String>{
        CREATE_RELATED_RECORDS_BASED_ON_SSMO_PAYLOAD => '1',
        CREATE_OPPORTUNITY_ACR_OCR_RECORDS_BY_SSMO_PAYLOAD => '2',
        CREATE_OPPORTUNITIES_AND_GET_OPPORTUNITY_IDS => '3',
        CREATE_ACR_FOR_MATCHED_ACCOUNTS => '4',
        CHECK_ACCOUNTS_WITH_ASSOICATED_PARENT_ACCOUNTS => '5',
        CHECK_ACCOUNTS_WITH_ASSOICATED_CHILD_ACCOUNTS => '6',
        VALIDATE_IF_NO_ACR_THEN_CREATE_ACR => '7',
        CREATE_OCR_USING_OPPORTUNITY_AND_CONTACT_DETAILS => '8'
    };
    private Map<Id, Contact> recordIdToContact = new Map<Id, Contact>();
    private static final String SSMO = 'SSMO';

    /**
     * @description  It is used to get the Injestion Inbound log Ids from the contact and
     * process creation of related records based on SSMO payload.
     * @param contactsWhereInboundInjestionLogFieldUpdated
     */
    public void createRelatedRecordsBasedOnSSMOPayload(
        List<Contact> contactsWhereInboundInjestionLogFieldUpdated
    ) {
        this.methodName = CREATE_RELATED_RECORDS_BASED_ON_SSMO_PAYLOAD;
        Set<Id> inboundIngestionLogIds = new Set<id>();
        Map<Id, Id> matchedAccountToMatchedContactMap = new Map<Id, Id>();
        for (Contact contact : contactsWhereInboundInjestionLogFieldUpdated) {
            recordIdToContact.put(contact.Id,contact);
            if (contact.Inbound_Ingestion_Log__c != null &&
              contact.SSMO_Business_Account_Id__c != null) {
                inboundIngestionLogIds.add(contact.Inbound_Ingestion_Log__c);
                contactRecord = contact;
                matchedAccountToMatchedContactMap.put(
                    contact.SSMO_Business_Account_Id__c,
                    contact.Id
                );
            }
        }
        if (!matchedAccountToMatchedContactMap.isEmpty() && !inboundIngestionLogIds.isEmpty()) {
            catchExceptionsOnGovernerLimits();
            createOpportunityACROCRRecordsBySSMOPayload(
                inboundIngestionLogIds,
                matchedAccountToMatchedContactMap
            );
        }
    }

    /**
     * @description It is used to create Opportunities, ACRs and OCRs based on the SSMO payload data.
     *  @param inboundIngestionLogIds
     *  @param matchedAccountToMatchedContactMap
     */
    private void createOpportunityACROCRRecordsBySSMOPayload(
        Set<Id> inboundIngestionLogIds,
        Map<Id, Id> matchedAccountToMatchedContactMap
    ) {
        this.methodName = CREATE_OPPORTUNITY_ACR_OCR_RECORDS_BY_SSMO_PAYLOAD;
        fflib_ISobjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        Map<Id, Contract> accountsIdsToChildContracts = new Map<Id, Contract>();
        Set<Id> opportunityIds = new Set<Id>();
        Opportunity associatedOpportunity;
        OpportunityContactRole opportunityContactRole;
        try{
            accountsIdsToChildContracts = ContractsService.setContractOnParentAccount(
                matchedAccountToMatchedContactMap.keySet()
            );
            List<User> holdingUsers = UsersSelector.newInstance()
                .selectUserByName(System.Label.Holding_User_Name);
            for (
                Account eachAccount : AccountsSelector.newInstance()
                    .selectAccountAndRelatedOpportunitiesByAccountIds(
                        matchedAccountToMatchedContactMap.keySet()
                    )
            ) {
                Contact matchedContact = recordIdToContact.get(
                    matchedAccountToMatchedContactMap.get(eachAccount.Id));
                if (eachAccount.Opportunities != null && !eachAccount.Opportunities.isEmpty()) {
                    associatedOpportunity = eachAccount.Opportunities[0];
                    associatedOpportunity.Last_Inbound_Date_Time__c = matchedContact.Last_Inbound_Date_Time__c;
                    opportunityIds.add(associatedOpportunity.Id);
                    unitOfWork.registerNew(createTaskOnOpportunity(associatedOpportunity));
                    unitOfWork.registerDirty(associatedOpportunity);
                } else {
                    opportunitiesToInsert.add(
                        createOpportunityUsingAccountDetails(
                            eachAccount,
                            holdingUsers[0],
                            accountsIdsToChildContracts.containsKey(eachAccount.Id),
                            matchedContact
                        )
                    );
                }
            }
            opportunityIds = createOpportunitiesAndGetOpportunityIds(
                opportunitiesToInsert,
                opportunityIds
            );
        } catch (Exception ex) {
            InboundIngestionLogs.updateIngestionLogsWithSucessOrFailureStatus(
                inboundIngestionLogIds,
                FAILED,
                ex.getMessage(),
                ex.getStackTraceString(),
                BUSINESS_ERROR_MESSAGE_FOR_OPPORTUNITY
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
                BUSINESS_ERROR_MESSAGE_FOR_OPPORTUNITY,
                '',
                new Set<String>{},
                ex.getTypeName()
            );
            return;
        }

        //ACR Logic.
        try{
            List<AccountContactRelation> accountContactRelationsTobeCreated = createACRForMatchedAccounts(
                matchedAccountToMatchedContactMap
            );
            if (!accountContactRelationsTobeCreated.isEmpty()) {
                unitOfWork.registerNew(accountContactRelationsTobeCreated);
            }
            //OCR Logic
            for (
                Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                    .selectOpportunitiesAndOpportunityContactRolesByIds(
                        opportunityIds,
                        matchedAccountToMatchedContactMap.values()
                    )
            ) {
                opportunityContactRole = createOCRUsingOpportunityAndContactDetails(
                    eachOpportunity,
                    matchedAccountToMatchedContactMap.get(eachOpportunity.AccountId)
                );
                if (opportunityContactRole != null) {
                    unitOfWork.registerNew(opportunityContactRole);
                }
            }
            unitOfWork.commitWork();
            catchExceptionsOnGovernerLimits();
            InboundIngestionLogs.updateIngestionLogsWithSucessOrFailureStatus(
                inboundIngestionLogIds,
                COMPLETED,
                '',
                '',
                ''
            );
        } catch (Exception ex) {
            InboundIngestionLogs.updateIngestionLogsWithSucessOrFailureStatus(
                inboundIngestionLogIds,
                FAILED,
                ex.getMessage(),
                ex.getStackTraceString(),
                BUSINESS_ERROR_MESSAGE
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
                BUSINESS_ERROR_MESSAGE,
                '',
                new Set<String>{},
                ex.getTypeName()
            );
        }
    }

    /**
     * @description It is used to create opportunity record using Account details.
     * @param eachAccount
     * @param holdingUser
     * @param accountHasActiveContract
     * @param matchedContact
     * @return Opportunity
     */
    private Opportunity createOpportunityUsingAccountDetails(
        Account eachAccount,
        User holdingUser,
        Boolean accountHasActiveContract,
        Contact matchedContact
    ) {
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.AccountId = eachAccount.Id;
        newOpportunity.StageName = PROSPECTING;
        newOpportunity = setTypeAndSubTypeOnOpportunity(
            accountHasActiveContract,
            newOpportunity,
            eachAccount
        );
        newOpportunity.Estimated_Number_of_Stores__c = 1;
        if (newOpportunity.Opportunity_Sub_Type__c != null) {
            newOpportunity.Deal_Type__c = STANDARD;
        }
        newOpportunity.Substage__c = OPPORTUNITY_SUBSTAGE_UNTOUCHED;
        newOpportunity.CloseDate = AFTERTHIRTYDAYS;
        newOpportunity.OwnerID = eachAccount.Owner.IsActive ? eachAccount.OwnerID : holdingUser.Id;
        newOpportunity.Name = SSMO_DROP_OFF;
        newOpportunity.Last_Inbound_Date_Time__c = matchedContact.Last_Inbound_Date_Time__c;
        newOpportunity.Source__c = SSMO;
        return newOpportunity;
    }

    /**
     * @description It is used to check if there is assocaited accounts for the matched account.
     * @param accountHasActiveContract
     * @param newOpportunity
     * @param eachAccount
     * @return Opportunity
     */
    private Opportunity setTypeAndSubTypeOnOpportunity(
        Boolean accountHasActiveContract,
        Opportunity newOpportunity,
        Account eachAccount
    ) {
        if (accountHasActiveContract) {
            newOpportunity.Type = EXISTING;
            newOpportunity.Opportunity_Sub_Type__c = NEW_STORE_EXPANSION;
        } else if (
            eachAccount.Partnership_Status__c != null &&
            eachAccount.Partnership_Status__c == EXISTING_PARTNER
        ) {
            newOpportunity.Type = EXISTING;
            newOpportunity.Opportunity_Sub_Type__c = NEW_STORE_EXPANSION;
        } else if (
            eachAccount.Partnership_Status__c != null &&
            eachAccount.Partnership_Status__c == FORMER_PARTNER
        ) {
            newOpportunity.Type = NEW_VALUE;
            newOpportunity.Opportunity_Sub_Type__c = FORMER_PARTNER;
        } else if (
            eachAccount.Partnership_Status__c != null &&
            eachAccount.Partnership_Status__c == PROSPECTIVE_PARTNER
        ) {
            newOpportunity.Type = NEW_VALUE;
            newOpportunity.Opportunity_Sub_Type__c = NET_NEW_PARTNER;
        }
        return newOpportunity;
    }

    /**
     * @description It is used to insert the newly created Opportunities and return the Ids.
     * @param opportunitiesToInsert
     * @param opportunityIds
     * @return Set<Id>
     */
    private Set<Id> createOpportunitiesAndGetOpportunityIds(
        List<Opportunity> opportunitiesToInsert,
        Set<Id> opportunityIds
    ) {
        this.methodName = CREATE_OPPORTUNITIES_AND_GET_OPPORTUNITY_IDS;
        if (!opportunitiesToInsert.isEmpty()) {
            InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
            fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.optAllOrNone = true;
            insertUnitOfWorkHelper.setDmlOptions(dmlOptions);
            unitOfWorkInstance.registerWork(insertUnitOfWorkHelper);
            insertUnitOfWorkHelper.registerInsert(opportunitiesToInsert);
            unitOfWorkInstance.commitWork();
            catchExceptionsOnGovernerLimits();
            List<Database.SaveResult> results = insertUnitOfWorkHelper.saveResults;
            for (Database.SaveResult eachResult : results) {
                if (eachResult.isSuccess()) {
                    opportunityIds.add(eachResult.getId());
                }
            }
        }
        return opportunityIds;
    }
    /**
     * @description It is used to create task record using Opportunity details.
     * @param associatedOpportunity
     * @return Task
     */
    public Task createTaskOnOpportunity(Opportunity associatedOpportunity) {
        Task task = new Task(
            WhatId = associatedOpportunity.Id,
            Subject = SSMO_DROP_OFF,
            Type = SSMO_DROP_OFF,
            ActivityDate = TOMORROW,
            OwnerID = associatedOpportunity.OwnerID
        );
        return task;
    }

    /**
     * @description It is used to create Opportunity Contact roles record using Opportunity and contact details.
     * @param eachOpportunity
     * @param contactId
     * @return OpportunityContactRole
     */
    private OpportunityContactRole createOCRUsingOpportunityAndContactDetails(
        Opportunity eachOpportunity,
        Id contactId
    ) {
        this.methodName = CREATE_OCR_USING_OPPORTUNITY_AND_CONTACT_DETAILS;
        Boolean contactRoleExists = false;
        OpportunityContactRole opportunityContactRole;
        if (
            eachOpportunity.OpportunityContactRoles != null ||
            !eachOpportunity.OpportunityContactRoles.isEmpty()
        ) {
            for (
                OpportunityContactRole eachOpportunityConatctRole : eachOpportunity.OpportunityContactRoles
            ) {
                if (eachOpportunityConatctRole.ContactId == contactId) {
                    contactRoleExists = true;
                    break;
                }
            }
            if (!contactRoleExists) {
                opportunityContactRole = new OpportunityContactRole(
                    OpportunityId = eachOpportunity.Id,
                    ContactId = contactId,
                    Role = INFLUENCER,
                    IsPrimary = false
                );
            }
        } else {
            opportunityContactRole = new OpportunityContactRole(
                OpportunityId = eachOpportunity.Id,
                ContactId = contactId,
                Role = INFLUENCER,
                IsPrimary = false
            );
        }
        catchExceptionsOnGovernerLimits();
        return opportunityContactRole;
    }

    /**
     * @description It is used to check if there is assocaited accounts for the matched account.
     * @param matchedAccountToMatchedContactMap
     * @return List<AccountContactRelation>
     */
    private List<AccountContactRelation> createACRForMatchedAccounts(
        Map<Id, Id> matchedAccountToMatchedContactMap
    ) {
        this.methodName = CREATE_ACR_FOR_MATCHED_ACCOUNTS;
        List<AccountContactRelation> accountContactRelationToBeCreated = new List<AccountContactRelation>();
        Set<Id> ultimateParentAccountIds = new Set<Id>();
        Set<Id> accountsIdsWithoutUltimateParentAccount = new Set<Id>();
        List<Account> matchedAccounts = AccountsSelector.newInstance()
            .selectAccountAndRelatedContactRelationsByAccountAndContactIds(
                matchedAccountToMatchedContactMap.keySet(),
                matchedAccountToMatchedContactMap.values()
            );

        for (Account eachAccount : matchedAccounts) {
            if (eachAccount.Ultimate_Parent_Account__c != null) {
                ultimateParentAccountIds.add(eachAccount.Ultimate_Parent_Account__c);
            } else {
                accountsIdsWithoutUltimateParentAccount.add(eachAccount.Id);
            }
        }
        if (!ultimateParentAccountIds.isEmpty()) {
            accountContactRelationToBeCreated = checkAccountsWithAssociatedParentAccounts(
                ultimateParentAccountIds,
                matchedAccountToMatchedContactMap,
                matchedAccounts,
                accountContactRelationToBeCreated
            );
        }
        if (!accountsIdsWithoutUltimateParentAccount.isEmpty()) {
            accountContactRelationToBeCreated = checkAccountsWithAssociatedChildAccounts(
                accountsIdsWithoutUltimateParentAccount,
                matchedAccountToMatchedContactMap,
                matchedAccounts,
                accountContactRelationToBeCreated
            );
        }
        catchExceptionsOnGovernerLimits();
        return accountContactRelationToBeCreated;
    }
    /**
     * @description It is used to check if there is existing ACR in business hierarchy for the matching contact.
     * @param ultimateParentAccountIds
     * @param matchedAccountToMatchedContactMap
     * @param matchedAccounts
     * @param accountContactRelationToBeCreated
     * @return List<AccountContactRelation>
     */
    private List<AccountContactRelation> checkAccountsWithAssociatedParentAccounts(
        Set<Id> ultimateParentAccountIds,
        Map<Id, Id> matchedAccountToMatchedContactMap,
        List<Account> matchedAccounts,
        List<AccountContactRelation> accountContactRelationToBeCreated
    ) {
        this.methodName = CHECK_ACCOUNTS_WITH_ASSOICATED_PARENT_ACCOUNTS;
        Map<Id, Set<Id>> ultimateParentWithChildAccounts = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> accountsWithAssociatedAccounts = new Map<Id, Set<Id>>();
        Map<Id, List<AccountContactRelation>> accountACRMap = new Map<Id, List<AccountContactRelation>>();

        for (
            Account eachAccount : AccountsSelector.newInstance()
                .selectAccountAndRelatedContactRelationsByAccountAndContactIds(
                    ultimateParentAccountIds,
                    matchedAccountToMatchedContactMap.values()
                )
        ) {
            accountACRMap.put(eachAccount.Id, eachAccount.AccountContactRelations);
        }
        List<Account> allAssociatedAccounts = AccountsSelector.newInstance()
            .selectAccountsByUltimateParentAccountIds(
                ultimateParentAccountIds,
                matchedAccountToMatchedContactMap.values()
            );
        for (Account eachAccount : allAssociatedAccounts) {
            accountACRMap.put(eachAccount.Id, eachAccount.AccountContactRelations);
            if (
                !ultimateParentWithChildAccounts.containsKey(eachAccount.Ultimate_Parent_Account__c)
            ) {
                Set<Id> childAccountIds = new Set<Id>{ eachAccount.Id };
                ultimateParentWithChildAccounts.put(
                    eachAccount.Ultimate_Parent_Account__c,
                    childAccountIds
                );
            } else {
                ultimateParentWithChildAccounts.get(eachAccount.Ultimate_Parent_Account__c)
                    .add(eachAccount.Id);
            }
        }
        for (Account eachAccount : matchedAccounts) {
            if (eachAccount.Ultimate_Parent_Account__c != null) {
                accountsWithAssociatedAccounts.put(
                    eachAccount.Id,
                    ultimateParentWithChildAccounts.get(eachAccount.Ultimate_Parent_Account__c)
                );
                accountsWithAssociatedAccounts.get(eachAccount.Id)
                    .add(eachAccount.Ultimate_Parent_Account__c);
            }
        }
        catchExceptionsOnGovernerLimits();
        accountContactRelationToBeCreated = validateIfNoACRThenCreateACR(
            matchedAccountToMatchedContactMap,
            matchedAccounts,
            accountsWithAssociatedAccounts,
            accountACRMap,
            accountContactRelationToBeCreated
        );
        return accountContactRelationToBeCreated;
    }
    /**
     * @description It is used to Check if there is existing ACR if not create ACR.
     * @param matchedAccountToMatchedContactMap
     * @param matchedAccounts
     * @param accountsWithAssociatedAccounts
     * @param accountACRMap
     * @param accountContactRelationToBeCreated
     * @return List<AccountContactRelation>
     */
    private List<AccountContactRelation> validateIfNoACRThenCreateACR(
        Map<Id, Id> matchedAccountToMatchedContactMap,
        List<Account> matchedAccounts,
        Map<Id, Set<Id>> accountsWithAssociatedAccounts,
        Map<Id, List<AccountContactRelation>> accountACRMap,
        List<AccountContactRelation> accountContactRelationToBeCreated
    ) {
        this.methodName = VALIDATE_IF_NO_ACR_THEN_CREATE_ACR;
        Boolean accountContactRelationExists;
        AccountContactRelation accountContactRelation;
        for (Account eachAccount : matchedAccounts) {
            if (accountsWithAssociatedAccounts.containsKey(eachAccount.Id)) {
                accountContactRelationExists = false;
                for (
                    Id eachAssociatedAccountId : accountsWithAssociatedAccounts.get(eachAccount.Id)
                ) {
                    for (
                        AccountContactRelation eachAccountContactRelation : accountACRMap.get(
                            eachAssociatedAccountId
                        )
                    ) {
                        if (
                            eachAccountContactRelation.ContactId ==
                            matchedAccountToMatchedContactMap.get(eachAccount.Id)
                        ) {
                            accountContactRelationExists = true;
                            break;
                        }
                    }
                    if (accountContactRelationExists) {
                        break;
                    }
                }
                if (accountContactRelationExists) {
                    continue;
                } else {
                    accountContactRelation = new AccountContactRelation(
                        AccountId = eachAccount.Id,
                        ContactId = matchedAccountToMatchedContactMap.get(eachAccount.Id),
                        Roles = INFLUENCER
                    );
                    accountContactRelationToBeCreated.add(accountContactRelation);
                }
            }
        }
        catchExceptionsOnGovernerLimits();
        return accountContactRelationToBeCreated;
    }
    /**
     * @description It is used to check if there is existing ACR in business hierarchy for the matching contact.
     * @param accountsIdsWithoutUltimateParentAccount
     * @param matchedAccountToMatchedContactMap
     * @param matchedAccounts
     * @param accountContactRelationToBeCreated
     * @return List<AccountContactRelation>
     */
    private List<AccountContactRelation> checkAccountsWithAssociatedChildAccounts(
        Set<Id> accountsIdsWithoutUltimateParentAccount,
        Map<Id, Id> matchedAccountToMatchedContactMap,
        List<Account> matchedAccounts,
        List<AccountContactRelation> accountContactRelationToBeCreated
    ) {
        this.methodName = CHECK_ACCOUNTS_WITH_ASSOICATED_CHILD_ACCOUNTS;
        Map<Id, Set<Id>> ultimateParentWithChildAccounts = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> accountsWithAssociatedAccounts = new Map<Id, Set<Id>>();
        Map<Id, List<AccountContactRelation>> accountACRMap = new Map<Id, List<AccountContactRelation>>();
        List<Account> allAssociatedAccounts = AccountsSelector.newInstance()
            .selectAccountsByUltimateParentAccountIds(
                accountsIdsWithoutUltimateParentAccount,
                matchedAccountToMatchedContactMap.values()
            );
        for (Account eachAccount : allAssociatedAccounts) {
            accountACRMap.put(eachAccount.Id, eachAccount.AccountContactRelations);
            if (
                !ultimateParentWithChildAccounts.containsKey(eachAccount.Ultimate_Parent_Account__c)
            ) {
                Set<Id> childAccountIds = new Set<Id>{ eachAccount.Id };
                ultimateParentWithChildAccounts.put(
                    eachAccount.Ultimate_Parent_Account__c,
                    childAccountIds
                );
            } else {
                ultimateParentWithChildAccounts.get(eachAccount.Ultimate_Parent_Account__c)
                    .add(eachAccount.Id);
            }
        }
        for (Account eachAccount : matchedAccounts) {
            if (eachAccount.Ultimate_Parent_Account__c == null) {
                accountACRMap.put(eachAccount.Id, eachAccount.AccountContactRelations);
                if (!ultimateParentWithChildAccounts.containsKey(eachAccount.Id)) {
                    Set<Id> associatedAccountIds = new Set<Id>{ eachAccount.Id };
                    accountsWithAssociatedAccounts.put(eachAccount.Id, associatedAccountIds);
                } else {
                    accountsWithAssociatedAccounts.put(
                        eachAccount.Id,
                        ultimateParentWithChildAccounts.get(eachAccount.Id)
                    );
                    accountsWithAssociatedAccounts.get(eachAccount.Id).add(eachAccount.Id);
                }
            }
        }
        catchExceptionsOnGovernerLimits();
        accountContactRelationToBeCreated = validateIfNoACRThenCreateACR(
            matchedAccountToMatchedContactMap,
            matchedAccounts,
            accountsWithAssociatedAccounts,
            accountACRMap,
            accountContactRelationToBeCreated
        );
        return accountContactRelationToBeCreated;
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