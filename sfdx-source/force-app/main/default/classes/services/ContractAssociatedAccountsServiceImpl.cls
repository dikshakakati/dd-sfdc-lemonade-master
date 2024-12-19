/**
 * @author
 * @date
 * @description Service class implementation for ContractAssociatedAccount
 */
public inherited sharing class ContractAssociatedAccountsServiceImpl implements IContractAssociatedAccountsService {
    public static final Integer MAX_IDS_PER_RECORD = 6000; // Long text area field length is 131,072. IDs are 18 chars, including a comma makes 19.
    public static final Integer AGREEMENT_BATCH_LIMIT = 200;

    @TestVisible
    private Id contractId;
    private Integer currentOrderPosition; // The Order__c number on which to begin creating Associations (1 if they do not exist already)
    private Integer openSlotsOnExistingRecord; // The Order__c number on which to begin creating Associations (1 if they do not exist already)

    @TestVisible
    private List<Contract_Associated_Accounts__c> associationsToUpsert {
        get {
            if (associationsToUpsert == null) {
                associationsToUpsert = new List<Contract_Associated_Accounts__c>();
            }

            return associationsToUpsert;
        }
        set;
    }

    /**
     * @description A common method to commit unit of work.
     * @param uow
     */
    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception e) {
            Logger.publish(e, LogEntry.SeverityLevel.HIGH);
        }
    }

    /**
     * @description Takes a list of existing Contract_Associated_Accounts__c, grabs the values from the
     *              Associated_Account_Ids__c fields, merges them and converts the string values to a Set<Id>.
     * @param associations
     * @return Set<Id>
     **/
    public static Set<Id> convertAssociationRecordsToAccountIds(
        List<Contract_Associated_Accounts__c> associations
    ) {
        Set<Id> idsOnExistingRecords = new Set<Id>();

        if (associations != null) {
            for (Contract_Associated_Accounts__c thisAssociation : associations) {
                if (String.isNotBlank(thisAssociation.Associated_Account_Ids__c)) {
                    List<Id> tempIdsList = thisAssociation.Associated_Account_Ids__c.split(',');
                    idsOnExistingRecords.addAll(tempIdsList);
                }
            }
        }

        return idsOnExistingRecords;
    }

    /**
     * @description No sublist() implementation in Apex so use this to return a subset of list items
     * @param inputList - List<Id> to make a sublist from
     * @param startRange - Beginning of sublist range (inclusive)
     * @param endRange - End of sublist range (exclusive)
     * @return List<Id>
     **/
    @TestVisible
    private static List<Id> getSublist(List<Id> inputList, Integer startRange, Integer endRange) {
        List<Id> resultList = new List<Id>();

        Integer n = startRange;

        while (n < endRange && n < inputList.size()) {
            resultList.add(inputList[n]);
            n++;
        }

        return resultList;
    }

    /**
     * @description Takes Contract ID and retrieves every related Account ID
     * @param contractId
     * @return Set<Id>
     **/
    public static Set<Id> getAssociatedAccountIdsForContract(Id contractId) {
        return convertAssociationRecordsToAccountIds(
            ContractAssociatedAccountsSelector.newInstance().selectByContractId(contractId)
        );
    }

    /**
     * @description Compares a Set<Id> of new IDs and a Set<Id> of old and determines if there is a
     * greater number of new unique IDs than we can handle when creating Agreements.
     * @param newIds
     * @return Boolean
     **/
    @TestVisible
    private static Boolean getIsBatchAgreementCreationNeeded(Set<Id> newIds) {
        // If newIds is empty/null or less than the threshold, return false
        if (newIds.isEmpty()) {
            return false;
        }
        Set<Id> newUniqueIds;
        if (!newIds.isEmpty()) {
            newUniqueIds = new Set<Id>(newIds);
        } else {
            newUniqueIds = new Set<Id>();
        }
        if (
            newUniqueIds == null ||
            newUniqueIds.isEmpty() ||
            newUniqueIds.size() < AGREEMENT_BATCH_LIMIT
        ) {
            return false;
        }

        return newUniqueIds.size() >= AGREEMENT_BATCH_LIMIT;
    }

    /**
     * @description Public method to call and reset/generate the Contract_Associated_Accounts__c for the passed list of Existing stores
     * @param associatedAccountsWrapperList
     * @param ccpApplied
     * @param ccpAnsoFlow
     **/
    public void generateContractAssociationsWithGroupForExistingAndNewStores(
        List<AssociatedAccountsWrapper> associatedAccountsWrapperList, Boolean ccpApplied, String ccpAnsoFlow
    ) {
        if (associatedAccountsWrapperList == null) {
            return;
        }

        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();

        //loop each group record and create CAA
        for (
            AssociatedAccountsWrapper associatedAccountsWrapperItem : associatedAccountsWrapperList
        ) {
            createContractAssociationsWithGroupForExistingAndNewStores(
                associatedAccountsWrapperItem, ccpApplied, ccpAnsoFlow
            );
        }

        if (!associationsToUpsert.isEmpty()) {
            unitOfWorkInstance.registerUpsert(associationsToUpsert);
        }

        commitWork(unitOfWorkInstance);
    }

    /**
     * @description Generate the appropriate number of Contract_Associated_Accounts__c for the list of existing stores
     * @param associatedAccountsWrapperItem - Set<Id> to register with the Contract
     * @param ccpApplied
     * @param ccpAnsoFlow
     **/
    @TestVisible
    private void createContractAssociationsWithGroupForExistingAndNewStores(
        associatedAccountsWrapper associatedAccountsWrapperItem, Boolean ccpApplied, String ccpAnsoFlow
    ) {
        if (associatedAccountsWrapperItem == null) {
            return;
        }

        List<Id> newAccountIdsList = associatedAccountsWrapperItem.accounts.split(',');
        Set<Id> newAccountIdsSet = new Set<Id>(newAccountIdsList);

        Boolean batchAgreementCreationNeeded = getIsBatchAgreementCreationNeeded(newAccountIdsSet);

        currentOrderPosition = 1;
        openSlotsOnExistingRecord = 0;

        Integer countOfTotalIds = newAccountIdsList.size() - openSlotsOnExistingRecord;
        Integer numberOfAssociationsNeeded =
            (countOfTotalIds + MAX_IDS_PER_RECORD - 1) / MAX_IDS_PER_RECORD;

        for (Integer i = 0; i < numberOfAssociationsNeeded; i++) {
            Integer startRange = openSlotsOnExistingRecord + (i * MAX_IDS_PER_RECORD);
            Integer endRange = Math.min(
                startRange + MAX_IDS_PER_RECORD,
                openSlotsOnExistingRecord + countOfTotalIds
            );
            List<Id> idsForCurrentRecord = (List<Id>) getSublist(
                newAccountIdsList,
                startRange,
                endRange
            );
            String idsString = String.join(idsForCurrentRecord, ',');

            Contract_Associated_Accounts__c association = new Contract_Associated_Accounts__c(
                Associated_Account_Ids__c = idsString,
                Contract__c = associatedAccountsWrapperItem.contractId,
                Order__c = currentOrderPosition,
                Group__c = associatedAccountsWrapperItem.groupId,
                Serialized_Entitlements_Data__c = JSON.serialize(
                    associatedAccountsWrapperItem.selectedAndDeselectedEntitlements
                ),
                Batch_Process_Enabled__c = batchAgreementCreationNeeded,
                Batch_Process_Status__c = batchAgreementCreationNeeded ? 'Not Started' : null,
                IsProcessingExistingStores__c = associatedAccountsWrapperItem.IsProcessingExistingStores,
                CCP_Applied__c = ccpApplied,
                CCP_ANSO_flow__c = ccpAnsoFlow
            );
            associationsToUpsert.add(association);

            currentOrderPosition++;
        }
    }
}