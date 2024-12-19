/**
 * @author DoorDash QTC
 * @date   07/20/2022
 * @description LEM-2362 This is the service class for Opportunity Contract Role related logic
 */
public inherited sharing class OpportunityContactRoleImpl implements IOpportunityContactRoleService {
    private static final String ROLE_CONTRACT_SIGNATORY = 'Contract Signatory';
    private static final String LOG_SERVICE = 'Opportunity Contact Role Service';
    private static final String LOG_DOMAIN = 'Sales';
    private static final String YES = 'YES';
    private static final String SMB_ACCOUNT_SEGMENT = 'SMB';
    private static final String CONTRACT_SIGNATORY_ROLE = 'Contract Signatory';
    private static final Set<String> SMB_NINTEX_USE_CASES = new Set<String>{ 'MWP', 'SSMO' };

    /**
     * @description This method is used to update Quote on Opportunity Contact Role
     * @param idOpportunityMap
     */
    public void stampPrimaryQuoteOnOppContactRole(Map<Id, Opportunity> idOpportunityMap) {
        fflib_ISObjectUnitOfWork relationshipUnitOfWork = Application.UNITOFWORK.newInstance();

        if (idOpportunityMap.isEmpty()) {
            return;
        }
        for (
            OpportunityContactRole eachOppContactRole : OpportunityContactRoleSelector.newInstance()
                .selectContractSignatoryOppContactRole(idOpportunityMap.keySet())
        ) {
            if (
                idOpportunityMap.containsKey(eachOppContactRole.OpportunityId) &&
                idOpportunityMap.get(eachOppContactRole.OpportunityId).SBQQ__PrimaryQuote__c != null
            ) {
                eachOppContactRole.Quote__c = idOpportunityMap.get(eachOppContactRole.OpportunityId)
                    .SBQQ__PrimaryQuote__c;
                relationshipUnitOfWork.registerDirty(eachOppContactRole);
            }
        }

        commitWork(relationshipUnitOfWork);
    }

    /**
     * @description This method is used to update Contract Signatory Opportunity Contact Role
     * Update 'Has Signed Contract' to Yes
     * Then calls AccountContactRelationsService to check if an associated ACR is present
     * @param opportunityIds
     */
    public void updateContractSignatoryContactRole(Map<Id, Opportunity> opportunityIds) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        if (opportunityIds.isEmpty()) {
            return;
        }

        for (Id opportunityId : opportunityIds.keySet()) {
            Opportunity opportunity = opportunityIds.get(opportunityId);
            if (
                opportunity.Account_Segment__c != SMB_ACCOUNT_SEGMENT ||
                SMB_NINTEX_USE_CASES.contains(opportunity.Nintex_Use_Case__c)
            ) {
                opportunityIds.remove(opportunityId);
            }
        }
        if (opportunityIds.isEmpty()) {
            return;
        }
        Map<Id, List<Id>> accountIdsContactIds = new Map<Id, List<Id>>();
        for (
            OpportunityContactRole eachOppContactRole : OpportunityContactRoleSelector.newInstance()
                .selectContractSignatoryOppContactRole(opportunityIds.keySet())
        ) {
            Contact contact = new Contact(
                Id = eachOppContactRole.ContactId,
                Has_Signed_Contract__c = YES
            );
            Opportunity opportunity = opportunityIds.get(eachOppContactRole.OpportunityId);

            // If the account already exists in the map, add the contact to its list
            if (accountIdsContactIds.containsKey(opportunity.AccountId)) {
                accountIdsContactIds.get(opportunity.AccountId).add(eachOppContactRole.ContactId);
            } else {
                // If the account doesn't exist, create a new list, add the contact, and put it in the map
                List<Id> contactIds = new List<Id>{ eachOppContactRole.ContactId };
                accountIdsContactIds.put(opportunity.AccountId, contactIds);
            }
            uow.registerDirty(contact);
        }
        AccountContactRelationsService.validateAndCreateAcr(accountIdsContactIds, uow);

        commitWork(uow);
    }

    /**
     * @description Update the Contract Signatory Exists flag on related quotes
     * @param contactRolesToSync
     */
    public void updateRelatedQuotesContractSignatoryExists(
        List<OpportunityContactRole> contactRolesToSync
    ) {
        Set<Id> relatedOpportunityIds = new Set<Id>();

        for (OpportunityContactRole contactRole : contactRolesToSync) {
            if (contactRole.OpportunityId == null && contactRole.Role != ROLE_CONTRACT_SIGNATORY) {
                continue;
            }

            relatedOpportunityIds.add(contactRole.OpportunityId);
        }

        if (relatedOpportunityIds.isEmpty()) {
            return;
        }

        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        for (
            SBQQ__Quote__c quote : QuotesSelector.newInstance()
                .selectByOpportunity(relatedOpportunityIds)
        ) {
            if (!quote.Contract_Signatory_Exists__c) {
                uow.registerDirty(
                    new SBQQ__Quote__c(Id = quote.Id, Contract_Signatory_Exists__c = true)
                );
            }
        }
        commitWork(uow);
    }

    /**
     * @description updates the contract signatory exists flag
     * @param approvedQuoteIds quote ids to update
     */
    public void updateContractSignatoryExists(Set<Id> approvedQuoteIds) {
        Set<Id> quoteIdsToFlag = new Set<Id>();

        //lookup opp contact roles by quote id and Role = 'Contract Signatory'
        //add those quote ids to a list of quotes that have the flag.
        for (
            OpportunityContactRole contactRole : OpportunityContactRoleSelector.newInstance()
                .selectByQuoteIdAndFilterByContractSignatory(approvedQuoteIds)
        ) {
            quoteIdsToFlag.add(contactRole.Quote__c);
        }

        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        //loop through contact roles to see if the quote's flag has changed. If so update it.
        for (SBQQ__Quote__c quote : QuotesSelector.newInstance().selectById(approvedQuoteIds)) {
            if (!quote.Contract_Signatory_Exists__c) {
                uow.registerDirty(
                    new SBQQ__Quote__c(
                        Id = quote.Id,
                        Contract_Signatory_Exists__c = quoteIdsToFlag.contains(quote.Id)
                    )
                );
            }
        }
        commitWork(uow);
    }

    /**
     * @description A common method to commit unit of work.
     * @JIRA# LEM-746
     * @param unitOfWork
     */
    private void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(unitOfWorkException)
            );
        }
    }

    /**
     * @description This method creates OCR Record.
     * @param opportunityIdToContactId
     * @param isPrimary
     */
    public static void createOCR(Map<Id, Id> opportunityIdToContactId, Boolean isPrimary) {
        if (opportunityIdToContactId.isEmpty()) {
            return;
        }
        List<OpportunityContactRole> ocrRecordsToBeCreated = new List<OpportunityContactRole>();
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Id opportunityId : opportunityIdToContactId.keySet()) {
            if(opportunityIdToContactId.get(opportunityId) != null){
                OpportunityContactRole ocrRecord = new OpportunityContactRole();
                ocrRecord.OpportunityId = opportunityId;
                ocrRecord.ContactId = opportunityIdToContactId.get(opportunityId);
                ocrRecord.IsPrimary = isPrimary;
                ocrRecord.Role = CONTRACT_SIGNATORY_ROLE;
                ocrRecordsToBeCreated.add(ocrRecord);
            }
        }
        if (ocrRecordsToBeCreated != null) {
            uow.registerNew(ocrRecordsToBeCreated);
            try {
                uow.commitWork();
            } catch (Exception ex) {
                Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            }
        }
    }
}