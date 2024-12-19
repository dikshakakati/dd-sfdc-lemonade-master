/**
 * @description This is test class for Contract Trigger handler class
 * @author ATG
 * @date 2022-04-11
 */
@isTest(seeAllData=false)
public class ContractsHandlerTest {
    private static final String CONTRACT_TYPE_CORE = 'Core';
    private static final String CONTRACT_STATUS_DRAFT = 'Draft';
    private static final String CONTRACT_STATUS_ACTIVATED = 'Activated';

    /**
     * @description To test method call on Contract insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDraftContractInsertedThenCallActivate() {
        Id contractId = Fake.generateId(Contract.class);

        List<Contract> contractList = new List<Contract>{
            new Contract(Id = contractId, Status = 'Draft')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContracts contractsMock = (IContracts) mocks.mock(IContracts.class);
        mocks.startStubbing();
        mocks.when(contractsMock.getType()).thenReturn(Schema.Contract.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(contractsMock);

        fflib_SObjectDomain.Test.Database.onInsert(contractList);
        fflib_SObjectDomain.triggerHandler(ContractsHandler.class);

        ((IContracts) mocks.verify(contractsMock, 1)).activate();
    }
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractIsInsertedThenUpdateStatusToActivated() {
        Id contractId = Fake.generateId(Contract.class);

        List<Contract> contractList = new List<Contract>{
            new Contract(Id = contractId, Status = 'Draft')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContracts contractsMock = (IContracts) mocks.mock(IContracts.class);
        mocks.startStubbing();
        mocks.when(contractsMock.getType()).thenReturn(Schema.Contract.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(contractsMock);

        fflib_SObjectDomain.Test.Database.onInsert(contractList);
        fflib_SObjectDomain.triggerHandler(ContractsHandler.class);

        ((IContracts) mocks.verify(contractsMock, 1)).activate();
    }

    /**
     * @description To test method call on Contract insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenActiveContractInsertedThenNoCallActivate() {
        Id contractId = Fake.generateId(Contract.class);

        List<Contract> contractList = new List<Contract>{
            new Contract(Id = contractId, Status = Contracts.ACTIVATED)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContracts contractsMock = (IContracts) mocks.mock(IContracts.class);
        mocks.startStubbing();
        mocks.when(contractsMock.getType()).thenReturn(Schema.Contract.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(contractsMock);

        fflib_SObjectDomain.Test.Database.onInsert(contractList);
        fflib_SObjectDomain.triggerHandler(ContractsHandler.class);

        ((IContracts) mocks.verify(contractsMock, 0)).activate();
    }

    /**
     * @description To test method call on Contract insert
     *
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractsAreUpdatedToActivatedThenSetContractId() {
        Id contractId = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);

        List<Contract> contractList = new List<Contract>{
            new Contract(
                Id = contractId,
                SBQQ__Opportunity__c = opportunityId,
                Status = Contracts.ACTIVATED
            )
        };

        List<Contract> oldContractList = new List<Contract>{
            new Contract(Id = contractId, SBQQ__Opportunity__c = opportunityId, Status = null)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContracts contractsMock = (IContracts) mocks.mock(IContracts.class);
        IContractsService contractsServiceMock = (IContractsService) mocks.mock(
            IContractsService.class
        );

        Application.SERVICE.setMock(IContractsService.class, contractsServiceMock);

        mocks.startStubbing();
        mocks.when(contractsMock.getType()).thenReturn(Schema.Contract.SObjectType);
        mocks.when(contractsMock.getType()).thenReturn(Schema.Contract.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(contractsMock);

        fflib_SObjectDomain.Test.Database.onInsert(contractList);
        fflib_SObjectDomain.triggerHandler(ContractsHandler.class);
        fflib_SObjectDomain.Test.Database.onUpdate(
            contractList,
            new Map<Id, Contract>(oldContractList)
        );
        fflib_SObjectDomain.triggerHandler(ContractsHandler.class);

        ((IContracts) mocks.verify(contractsMock, 0)).activate();
        ((IContractsService) mocks.verify(contractsServiceMock, 1))
            .setContractsOnRelatedOpportunities(new Set<Id>{ contractId });
    }

    /**
     * @description To test method call on Contract After Update
     *
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractsAreAmendedThenCallSelector() {
        Id contractId = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id orderIdNew = Fake.generateId(Order.class);
        Id orderIdOld = Fake.generateId(Order.class);

        List<Contract> contractList = new List<Contract>{
            new Contract(
                Id = contractId,
                SBQQ__Opportunity__c = opportunityId,
                Status = Contracts.ACTIVATED,
                SBQQ__Order__c = orderIdNew
            )
        };

        List<Contract> oldContractList = new List<Contract>{
            new Contract(
                Id = contractId,
                SBQQ__Opportunity__c = opportunityId,
                Status = Contracts.ACTIVATED,
                SBQQ__Order__c = orderIdOld
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IActivationOrdersService activationOrderServiceMock = (IActivationOrdersService) mocks.mock(
            IActivationOrdersService.class
        );

        Application.SERVICE.setMock(IActivationOrdersService.class, activationOrderServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            contractList,
            new Map<Id, Contract>(oldContractList)
        );
        fflib_SObjectDomain.triggerHandler(ContractsHandler.class);

        ((IActivationOrdersService) mocks.verify(activationOrderServiceMock, 1))
            .createActivationOrdersAndProductsOnContractAmendment(new Set<Id>{ contractId });
    }

    /**
     * @description To test method call on Contract After Update
     *
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractsNotAmendedThenCallSelectorWithEmptySet() {
        Id contractId1 = Fake.generateId(Contract.class);
        Id contractId2 = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id orderIdNew = Fake.generateId(Order.class);
        Id orderIdSame = Fake.generateId(Order.class);

        List<Contract> contractList = new List<Contract>{
            new Contract(
                Id = contractId1,
                SBQQ__Opportunity__c = opportunityId,
                Status = Contracts.ACTIVATED,
                SBQQ__Order__c = orderIdNew //First time ordered.
            ),
            new Contract(
                Id = contractId2,
                SBQQ__Opportunity__c = opportunityId,
                Status = Contracts.ACTIVATED,
                SBQQ__Order__c = orderIdSame
            )
        };

        List<Contract> oldContractList = new List<Contract>{
            new Contract(
                Id = contractId1,
                SBQQ__Opportunity__c = opportunityId,
                Status = Contracts.ACTIVATED,
                SBQQ__Order__c = null
            ),
            new Contract(
                Id = contractId2,
                SBQQ__Opportunity__c = opportunityId,
                Status = Contracts.ACTIVATED,
                SBQQ__Order__c = orderIdSame
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IActivationOrdersService activationOrderServiceMock = (IActivationOrdersService) mocks.mock(
            IActivationOrdersService.class
        );

        Application.SERVICE.setMock(IActivationOrdersService.class, activationOrderServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            contractList,
            new Map<Id, Contract>(oldContractList)
        );
        fflib_SObjectDomain.triggerHandler(ContractsHandler.class);
        //None of these Contracts were Amended
        ((IActivationOrdersService) mocks.verify(activationOrderServiceMock, 1))
            .createActivationOrdersAndProductsOnContractAmendment(new Set<Id>{});
    }
    /**
     * @description To test method call on Contract insert
     *
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractsAreActivatedThenCallSetBrandAssociationAndUpdateContractName() {
        Id contractId = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);

        List<Contract> contractList = new List<Contract>{
            new Contract(
                Id = contractId,
                SBQQ__Opportunity__c = opportunityId,
                Status = Contracts.ACTIVATED
            )
        };

        List<Contract> oldContractList = new List<Contract>{
            new Contract(Id = contractId, SBQQ__Opportunity__c = opportunityId, Status = null)
        };
        Map<Id, Id> contractOppIdMap = new Map<Id, Id>{ contractId => opportunityId };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractsService contractsServiceMock = (IContractsService) mocks.mock(
            IContractsService.class
        );

        Application.SERVICE.setMock(IContractsService.class, contractsServiceMock);

        fflib_SObjectDomain.Test.Database.onInsert(contractList);
        fflib_SObjectDomain.triggerHandler(ContractsHandler.class);
        fflib_SObjectDomain.Test.Database.onUpdate(
            contractList,
            new Map<Id, Contract>(oldContractList)
        );
        fflib_SObjectDomain.triggerHandler(ContractsHandler.class);

        ((IContractsService) mocks.verify(contractsServiceMock, 1))
            .createContractBrandAssociationOnContract(contractOppIdMap);
    }
    /**
     * @description It validates if the Ads and Promo Contract with a related Opportunity (new or existing) is activated, then auto-associates stores.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAdsPromoContractActivatedThenAssociateStores() {
        Id contractId = Fake.generateId(Contract.class);
        Id orderId = Fake.generateId(Order.class);

        List<Contract> contractList = new List<Contract>{
            new Contract(Id = contractId, SBQQ__Order__c = orderId)
        };
        List<Contract> oldcontractList = new List<Contract>{
            new Contract(Id = contractId, SBQQ__Order__c = null)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContracts contractsMock = (IContracts) mocks.mock(IContracts.class);
        mocks.startStubbing();
        mocks.when(contractsMock.getType()).thenReturn(Schema.Contract.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(contractsMock);
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onUpdate(
            contractList,
            new Map<Id, Contract>(oldcontractList)
        );
        fflib_SObjectDomain.triggerHandler(ContractsHandler.class);
        Test.stopTest();
        ((IContracts) mocks.verify(contractsMock, 1))
            .initiateAdsAndPromoStoreAgreementsCreationOnContracts();
    }
}