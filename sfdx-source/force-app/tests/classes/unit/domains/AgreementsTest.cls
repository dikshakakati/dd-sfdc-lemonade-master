/**
 * @description Test Class for Agreements Domain class
 * @author DoorDash
 * @date 06/02/2022
 */
@isTest(seeAllData=false)
public class AgreementsTest {
    private static final String AGREEMENT_NAME = 'Test business agreement';
    private static final String AGREEMENT_STATUS_ACTIVE = 'Active';
    private static final String AGREEMENT_TYPE_BUSINESS_AGREEMENT = 'Business Agreement';
    private static final String EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS = 'READINESS_CHECK_ON_PARENT_WORK_ORDERS';
    private static final String PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Parent_WorkOrders_Payload_Chunk_Size';
    private static final String WORK_ORDER_STATUS_PLANNING = 'Planning';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_SUB_TYPE_WITHHOLDING = 'Withholding';
    private static final String STATUS_CANCELLED = 'Cancelled'; //@JIRA #LEM-15980
    /**
     * @description this method is to test Nintex selectors.
     */
    @isTest
    private static void testWhenAgreementsCallsThenReturnRecords() {
        List<Agreement__c> agreementRecords = new List<Agreement__c>{
            new Agreement__c(
                Id = fflib_IDGenerator.generate(Agreement__c.SObjectType),
                Name = 'Test 1 Store Agreement',
                Account__c = fflib_IDGenerator.generate(Account.SObjectType),
                Start_Date__c = System.today(),
                Deactivation_Date__c = System.today() + 10
            ),
            new Agreement__c(
                Id = fflib_IDGenerator.generate(Agreement__c.SObjectType),
                Name = 'Test 1 Store Agreement',
                Account__c = fflib_IDGenerator.generate(Account.SObjectType),
                Start_Date__c = System.today() + 5,
                Deactivation_Date__c = System.today() + 20
            )
        };
        Set<Id> accountSet = Agreements.newInstance(agreementRecords).getAccountIds();
        System.assertEquals(2, accountSet.size(), 'Call returned the incorrect number of rows');
    }

    /**
     * @description To test Notifier event published when onAfterInsertHandleRelatedRecords called
     * on creation of Business Agreements.
     * Suppressing Warning as mock.verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnAfterInsertHandleRelatedRecordsCalledThenNotifierEventPublished() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Agreement__c businessAgreement = new Agreement__c(
            Id = fflib_IDGenerator.generate(Agreement__c.SObjectType),
            Name = AGREEMENT_NAME,
            Account__c = fflib_IDGenerator.generate(Account.SObjectType),
            Contract__c = contractId,
            Start_Date__c = System.today(),
            Deactivation_Date__c = System.today() + 10,
            Status__c = AGREEMENT_STATUS_ACTIVE,
            Type__c = AGREEMENT_TYPE_BUSINESS_AGREEMENT
        );
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_WITHHOLDING)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Status, WORK_ORDER_STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = '1'
                )
            );
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Test.startTest();
        Agreements.newInstance(new List<Agreement__c>{ businessAgreement })
            .onAfterInsertHandleRelatedRecords(new List<Agreement__c>{ businessAgreement });
        Test.stopTest();
        List<Id> parentWorkOrderIds = new List<Id>{ parentWorkOrder.Id };
        ((INotifierEventsService) mocks.verify(notifierEventService, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS => new List<String>{
                        JSON.serialize(parentWorkOrderIds)
                    }
                }
            );
    }

       /**
     * @description To test updated agreements
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAgreementUpdatedThenUpdateStatus() {
        Id agreementId1 = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        Id agreementId2 = fflib_IDGenerator.generate(Agreement__c.SObjectType);

        List<Agreement__c> agreementsList = new List<Agreement__c>{
            new Agreement__c(
                Id = agreementId1,
                Status__c = AGREEMENT_STATUS_ACTIVE,
                Deactivation_Date__c = System.today()
            ),
            new Agreement__c(Id = agreementId2, Status__c = STATUS_CANCELLED)
        };
        // Call the method
        Agreements.newInstance(agreementsList).updateDeactivationDateOrStatus(agreementsList);
        // Assert the results
        System.assertEquals(
            System.today(),
            agreementsList[0].Deactivation_Date__c,
            'Deactivation should be todays date'
        );
        System.assertEquals(
            STATUS_CANCELLED,
            agreementsList[1].Status__c,
            'Status Should be cancelled'
        );
    }
}