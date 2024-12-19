/**
 * @author BizApps
 * @date 05/2023
 * @description Domain Class for ContractAssociatedAccounts Object
 */
public inherited sharing class ContractAssociatedAccounts extends fflib_SObjects implements IContractAssociatedAccounts {
    /**
     * @description This method is used to return the IContractAssociatedAccounts interface
     * @param recordList - Contract_Associated_Accounts__c record list
     * @return IContractAssociatedAccounts - Returns IContractAssociatedAccounts Interface
     */
    public static IContractAssociatedAccounts newInstance(
        List<Contract_Associated_Accounts__c> recordList
    ) {
        return (IContractAssociatedAccounts) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public ContractAssociatedAccounts(List<Contract_Associated_Accounts__c> sObjectList) {
        super(sObjectList, Schema.Contract_Associated_Accounts__c.SObjectType);
    }

    /**
     * @description Get New Associated AccountIds from Contract_Associated_Accounts
     * related
     * JIRA# LEM-6145
     * @param
     * @return Map<Id,Set<String>> contractIdAssociatedAccountIdsMap
     */
    public Map<Id, Set<String>> getNewAssociatedAccountIds() {
        Map<Id, Set<String>> contractIdAssociatedAccountIdsMap = new Map<Id, Set<String>>();
        for (
            Contract_Associated_Accounts__c eachContractAssociatedAccount : (List<Contract_Associated_Accounts__c>) getRecords()
        ) {
            Set<String> currentAssociatedId = new Set<String>();
            if (
                !String.isBlank(eachContractAssociatedAccount.Associated_Account_Ids__c) &&
                !eachContractAssociatedAccount.Batch_Process_Enabled__c &&
                !eachContractAssociatedAccount.IsProcessingExistingStores__c
            ) {
                currentAssociatedId.addAll(
                    eachContractAssociatedAccount.Associated_Account_Ids__c.split(',')
                );
                if (
                    !contractIdAssociatedAccountIdsMap.containsKey(
                        eachContractAssociatedAccount.Contract__c
                    )
                ) {
                    contractIdAssociatedAccountIdsMap.put(
                        eachContractAssociatedAccount.Contract__c,
                        new Set<String>()
                    );
                }
                contractIdAssociatedAccountIdsMap.get(eachContractAssociatedAccount.Contract__c)
                    .addAll(currentAssociatedId);
            }
        }
        return getAssociatedAccountIdsWithNoActiveAgreements(contractIdAssociatedAccountIdsMap);
    }

    /**
     * @description Get Existing Associated AccountIds from Contract_Associated_Accounts
     * related
     * JIRA# LEM-6145
     * @param
     * @return Map<Id,Set<String>> contractIdAssociatedAccountIdsMap
     */
    public Map<Id, Set<String>> getExistingAssociatedAccountIdsFromCaa() {
        Map<Id, Set<String>> contractIdAssociatedAccountIdsMap = new Map<Id, Set<String>>();
        for (
            Contract_Associated_Accounts__c eachContractAssociatedAccount : (List<Contract_Associated_Accounts__c>) getRecords()
        ) {
            Set<String> currentAssociatedId = new Set<String>();
            if (
                !String.isBlank(eachContractAssociatedAccount.Associated_Account_Ids__c) &&
                !eachContractAssociatedAccount.Batch_Process_Enabled__c &&
                eachContractAssociatedAccount.IsProcessingExistingStores__c
            ) {
                currentAssociatedId.addAll(
                    eachContractAssociatedAccount.Associated_Account_Ids__c.split(',')
                );
                if (
                    !contractIdAssociatedAccountIdsMap.containsKey(
                        eachContractAssociatedAccount.Contract__c
                    )
                ) {
                    contractIdAssociatedAccountIdsMap.put(
                        eachContractAssociatedAccount.Contract__c,
                        new Set<String>()
                    );
                }
                contractIdAssociatedAccountIdsMap.get(eachContractAssociatedAccount.Contract__c)
                    .addAll(currentAssociatedId);
            }
        }
        return contractIdAssociatedAccountIdsMap;
    }

    /**
     * @description Get New Associated AccountIds from Contract_Associated_Accounts
     * @param contractIdAssociatedAccountIdsMap
     * @return Map<AccountId,Id> associatedAccountIdGroupIdMap
     */
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
    public Map<Id, Map<Id, String>> getNewAssociatedAccountIdWithGroupIdAndSerializedEntitlements(
        Map<Id, Set<String>> contractIdAssociatedAccountIdsMap
    ) {
        Set<ID> accountIdSet = new Set<Id>();
        for (Id contractID : contractIdAssociatedAccountIdsMap.keySet()) {
            for (String associatedAccId : contractIdAssociatedAccountIdsMap.get(contractID)) {
                accountIdSet.add(Id.valueOf(associatedAccId));
            }
        }
        Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements = new Map<Id, Map<Id, String>>();

        for (
            Contract_Associated_Accounts__c eachContractAssociatedAccount : (List<Contract_Associated_Accounts__c>) getRecords()
        ) {
            if (!String.isBlank(eachContractAssociatedAccount.Associated_Account_Ids__c)) {
                Set<String> currentAssociatedIds = new Set<String>(
                    eachContractAssociatedAccount.Associated_Account_Ids__c.split(',')
                );

                for (Id accountId : accountIdSet) {
                    if (currentAssociatedIds.contains(accountId)) {
                        if (!associatedAccountIdGroupIdMapWithEntitlements.containsKey(accountId)) {
                            associatedAccountIdGroupIdMapWithEntitlements.put(
                                accountId,
                                new Map<Id, String>()
                            );
                        }
                        associatedAccountIdGroupIdMapWithEntitlements.get(accountId)
                            .put(
                                eachContractAssociatedAccount.Group__c,
                                eachContractAssociatedAccount.Serialized_Entitlements_Data__c
                            );
                    }
                }
            }
        }
        return associatedAccountIdGroupIdMapWithEntitlements;
    }

    /**
     * @description Get Contract ID by Associated AccountIds with no Active Agreements
     * remove the AccountIDs which already has an Active Agreement associated.
     * JIRA# LEM-6145
     * @param contractIdAssociatedAccountIdsMap
     * @return Map<Id,Set<String>> contractIdAssociatedAccountIdsMap
     */
    public Map<Id, Set<String>> getAssociatedAccountIdsWithNoActiveAgreements(
        Map<Id, Set<String>> contractIdAssociatedAccountIdsMap
    ) {
        Set<ID> accountIdSet = new Set<Id>();
        Map<Id, Id> agreementIDToAccoutIdMap = new Map<Id, Id>();

        for (Id contractID : contractIdAssociatedAccountIdsMap.keySet()) {
            for (String associatedAccId : contractIdAssociatedAccountIdsMap.get(contractID)) {
                accountIdSet.add(Id.valueOf(associatedAccId));
            }
        }
        List<Agreement__c> agreements = AgreementsSelector.newInstance()
            .selectAgreementsByContractAndAccount(
                contractIdAssociatedAccountIdsMap.keySet(),
                accountIdSet
            );
        if (!agreements.isEmpty()) {
            for (Agreement__c agreement : agreements) {
                agreementIDToAccoutIdMap.put(agreement.Id, agreement.Account__c);
            }
            for (Id contractID : contractIdAssociatedAccountIdsMap.keySet()) {
                for (Agreement__c agreement : agreements) {
                    if (agreementIDToAccoutIdMap.containskey(agreement.Id)) {
                        contractIdAssociatedAccountIdsMap.get(contractID)
                            .remove(agreementIDToAccoutIdMap.get(agreement.Id));
                    }
                }
            }
        }
        return contractIdAssociatedAccountIdsMap;
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
         * @return ContractAssociatedAccounts - List of ContractAssociatedAccounts
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (ContractAssociatedAccounts.constructorMock != null) {
                return (fflib_SObjects) ContractAssociatedAccounts.constructorMock.construct(
                    objectList
                );
            }
            return new ContractAssociatedAccounts((List<SObject>) objectList);
        }
    }
}