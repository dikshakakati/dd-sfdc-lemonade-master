/**
 * @description Contract Object Trigger Handler
 * @author ATG
 * @date 2022-04-11
 */
public class ContractsHandler extends ApplicationDomainHandler {
    private static final String CONTRACT_STATUS_ACTIVATED = 'Activated';
    private static final String CONTRACT_TYPE_CORE = 'Core';
    /**
     * @description Constructor Method
     * @param sObjectList - Contract Record List
     */
    public ContractsHandler(List<Contract> sObjectList) {
        super(sObjectList);
        setContextBypass(Contract.SObjectType, ContractsHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return ContractHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new ContractsHandler(sObjectList);
        }
    }
    /**
     * @description Called to perform before insert processing
     */
    //Commented as part of LEM-13141
    /*
    public override void onBeforeInsert() {
        Contracts.newInstance(this.records).setQuotesFieldsOnContract();
    }*/

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        activateContracts();
        //LEM-3619
        ContractsService.createContractBrandAssociationOnContract(
            getOpportunityIdForNewContracts()
        );
        ContractsService.setAgencyFieldOnContract(getOpportunityIdForNewContracts());
    }
    /**
     * @description Called to perform processing during the after update phase.
     * @param existingRecords - The map of old Contract Records
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        ContractsService.setContractsOnRelatedOpportunities(
            getNewlyActivatedContractIds(existingRecords)
        );

        //LEM-2589 Create Activation Orders on Amended Contracts.
        Set<Id> amendedContractIds = getAmendedContracts(existingRecords);
        ActivationOrdersService.createActivationOrdersAndProductsOnContractAmendment(
            amendedContractIds
        );

        //Commented as part of LEM-13141
        //ContractsService.setQuotesFieldsOnContract(amendedContractIds);

        //LEM-10617
        List<Contract> changedContractRecords = new List<Contract>(
            (List<Contract>) getChangedRecords(
                new Set<SObjectField>{ Contract.SBQQ__Order__c, Contract.MP_Bz_Id__c }
            )
        );
        Contracts.newInstance(changedContractRecords)
            .publishNotifierEventsOnWithholdingAmendment((Map<Id, Contract>) existingRecords);

        List<Contract> changedContractByOrder = new List<Contract>(
            (List<Contract>) getChangedRecords(new Set<SObjectField>{ Contract.SBQQ__Order__c })
        );
        Contracts.newInstance(changedContractByOrder)
            .initiateSSMOStoreAgreementCreationOnContracts();
        Contracts.newInstance(getContractsWithChangedOrder())
            .initiateAdsAndPromoStoreAgreementsCreationOnContracts();
    }

    /**
     * @description It retrieve contracts with changed order.
     * @return List<Contract>
     */
    private List<Contract> getContractsWithChangedOrder() {
        return new List<Contract>(
            (List<Contract>) getChangedRecords(new Set<SObjectField>{ Contract.SBQQ__Order__c })
        );
    }

    /**
     * @description Get List of Contracts that have been amended.  The SBQQ__Order__c field changes on an amendment.
     * @param existingRecords
     * @return Set<Id>
     */
    private Set<Id> getAmendedContracts(Map<Id, SObject> existingRecords) {
        Set<Id> amendedContractIds = new Set<Id>();
        List<Contract> changedContracts = (List<Contract>) getChangedRecords(
            new Set<SObjectField>{ Contract.SBQQ__Order__c }
        );
        for (Contract con : changedContracts) {
            Id previousOrderId = existingRecords.containsKey(con.Id)
                ? ((Contract) existingRecords.get(con.Id)).SBQQ__Order__c
                : null;
            if (previousOrderId != null) {
                amendedContractIds.add(con.Id);
            }
        }
        return amendedContractIds;
    }

    /**
     * @description Activate Contracts after they are inserted.
     * @param
     */
    private void activateContracts() {
        List<Contract> contractsToActivate = new List<Contract>();
        for (Contract contract : (List<Contract>) getRecords()) {
            if (contract.Status != Contracts.ACTIVATED) {
                contractsToActivate.add(contract);
            }
        }
        if (!contractsToActivate.isEmpty()) {
            Contracts.newInstance(contractsToActivate).activate();
        }
    }

    /**
     * @description Get List of Contracts with
     * @param existingRecords
     * @return List<Contract>
     */
    private Set<Id> getNewlyActivatedContractIds(Map<Id, SObject> existingRecords) {
        Set<Id> newlyActivatedContractIds = new Set<Id>();
        for (
            Contract contract : new List<Contract>(
                (List<Contract>) getRecordsByFieldValue(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            )
        ) {
            if (((Contract) existingRecords.get(contract.Id)).Status != CONTRACT_STATUS_ACTIVATED) {
                newlyActivatedContractIds.add(contract.Id);
            }
        }
        return newlyActivatedContractIds;
    }
    /**
     * @description Get newly inserted Contracts With Opportunity Associated.
     * @return Map<Id, Id> Map Of Contract Id and OpportunityId
     */
    private Map<Id, Id> getOpportunityIdForNewContracts() {
        Map<Id, Id> contractOpportunityIdMap = new Map<Id, Id>();
        for (
            Contract objContract : (List<Contract>) getRecordsWithNotBlankFieldValues(
                Contract.SBQQ__Opportunity__c
            )
        ) {
            contractOpportunityIdMap.put(objContract.Id, objContract.SBQQ__Opportunity__c);
        }
        return contractOpportunityIdMap;
    }
}