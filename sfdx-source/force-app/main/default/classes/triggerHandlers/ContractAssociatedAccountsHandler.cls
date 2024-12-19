/**
 * @description ContractAssociatedAccounts Object Trigger Handler
 * @author BizApps
 * @date 5/2023
 */
public with sharing class ContractAssociatedAccountsHandler extends ApplicationDomainHandler {
    private static final String BATCH_PROCESS_STATUS = 'Not Started';
    private static final Boolean MANUAL_STORE_ASSOCIATION = true;
    /**
     * @description Constructor Method
     * @param sObjectList - ContractAssociatedAccounts Record List
     */
    public ContractAssociatedAccountsHandler(List<Contract_Associated_Accounts__c> sObjectList) {
        super(sObjectList);
        setContextBypass(
            Contract_Associated_Accounts__c.SObjectType,
            ContractAssociatedAccountsHandler.class
        );
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return ContractAssociatedAccountsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new ContractAssociatedAccountsHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        Map<Id, Set<String>> contractIdAssociatedAccountIdsMap = ContractAssociatedAccounts.newInstance(
                (List<Contract_Associated_Accounts__c>) getRecords()
            )
            .getNewAssociatedAccountIds();
        createAgreements(contractIdAssociatedAccountIdsMap);

        Map<Id, Set<String>> contractIdAssociatedAccountIdsMapForExisting = ContractAssociatedAccounts.newInstance(
                (List<Contract_Associated_Accounts__c>) getRecords()
            )
            .getExistingAssociatedAccountIdsFromCaa();
        updateAgreementsWithEntitlements(contractIdAssociatedAccountIdsMapForExisting);

        processAgreementsInBatch((List<Contract_Associated_Accounts__c>) getRecords());
    }

    // Removing the AfterUpdate Scenario for CAA records, as it would never occur

    /**
     * @description Calling Agreements Service to create Agreement Records
     * if BatchProcessIsEnabled call Batch class ContractsAssociatedAccountsBatch
     * @param contractIdAssociatedAccountIdsMap
     */
    public void createAgreements(Map<Id, Set<String>> contractIdAssociatedAccountIdsMap) {
        if (contractIdAssociatedAccountIdsMap.size() > 0) {
            List<Contract> contractList = ContractsSelector.newInstance()
                .selectById(contractIdAssociatedAccountIdsMap.keySet());

            Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements = ContractAssociatedAccounts.newInstance(
                    (List<Contract_Associated_Accounts__c>) getRecords()
                )
                .getNewAssociatedAccountIdWithGroupIdAndSerializedEntitlements(
                    contractIdAssociatedAccountIdsMap
                );

            AgreementsService.createAgreementsfromContractsWithGroup(
                contractList,
                contractIdAssociatedAccountIdsMap,
                associatedAccountIdGroupIdMapWithEntitlements
            );
        }
    }

    /**
     * @description Calling Agreements Service to update Agreement Records
     * if BatchProcessIsEnabled call Batch class ContractsAssociatedAccountsBatch
     * @param contractIdAssociatedAccountIdsMapForExisting
     */
    public void updateAgreementsWithEntitlements(
        Map<Id, Set<String>> contractIdAssociatedAccountIdsMapForExisting
    ) {
        if (contractIdAssociatedAccountIdsMapForExisting.size() > 0) {
            Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements = ContractAssociatedAccounts.newInstance(
                    (List<Contract_Associated_Accounts__c>) getRecords()
                )
                .getNewAssociatedAccountIdWithGroupIdAndSerializedEntitlements(
                    contractIdAssociatedAccountIdsMapForExisting
                );

            AgreementsService.updateAgreementsForExistingStoresWithGroups(
                associatedAccountIdGroupIdMapWithEntitlements
            );
        }
    }

    /**
     * @description process the records in Batch(call ContractsAssociatedAccountsBatch)
     * if satisfies the conditions( Associated AccountIDs != Null, BatchProcessEnabled = true, BatchProcessStatus = 'Not Started')
     * @param conAssociatedAccounts
     */
    public void processAgreementsInBatch(
        List<Contract_Associated_Accounts__c> conAssociatedAccounts
    ) {
        Set<Id> conAssociatedAccountIds = new Set<Id>();
        for (Contract_Associated_Accounts__c conAssociatedAccount : conAssociatedAccounts) {
            if (
                conAssociatedAccount.Associated_Account_Ids__c != null &&
                conAssociatedAccount.Batch_Process_Enabled__c &&
                conAssociatedAccount.Batch_Process_Status__c == BATCH_PROCESS_STATUS
            ) {
                conAssociatedAccountIds.add(conAssociatedAccount.Id);
            }
        }
        if (!conAssociatedAccountIds.isEmpty()) {
            Database.executeBatch(new ContractsAssociatedAccountsBatch(conAssociatedAccountIds), 1);
        }
    }
}