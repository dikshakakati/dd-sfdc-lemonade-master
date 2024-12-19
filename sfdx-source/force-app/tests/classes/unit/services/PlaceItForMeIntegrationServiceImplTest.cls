/**
 * @author Deloitte
 * @date 07/09/2024
 * @description Test class for PlaceItForMeIntegrationServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class PlaceItForMeIntegrationServiceImplTest {
    private static final String ACCOUNT_EXPERIENCE_STOREFRONT = 'Storefront';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String EVENT_TOPIC_PLACEITFORME_INBOUND_INTEGRATION = 'PLACEITFORME_INBOUND_INTEGRATION';
    private static final String INTEGRATION_REQUEST_STATUS_FAILED = 'Failed';
    private static final String INTEGRATION_REQUEST_STATUS_PROCESSED = 'Processed';
    private static final String INTERFACE_TRANSACTION_CONFIG_NAME_WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION = 'WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION';
    private static final String MOCK_BUSINESS_ID = '28040568';
    private static final String SFDC_STATUS_PENDING = 'Pending';
    private static final String STATIC_RESOURCE_TEST_JSON = 'Place_It_For_Me_Mock_Payload';
    private static final String STATUS_ESCALATED = 'Escalated';
    private static final String STOREFRONT_MX_ESCALATION_QUEUE_NAME = 'Storefront - Mx Escalation';
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORKSTEP_STATUS_PIFM_LEAD = 'PIFM Lead';
    private static final String WORKSTEP_TYPE_IMPLEMENTATION_CALL = 'Implementation Call';

    /**
     * @description To test Storefront Work Plan and Work Steps are updated when event payload
     * received with 'Place It For Me' Integration Request Ids
     * Active Storefront Work Order already exists.
     *
    @isTest
    private static void testWhenIntegrationRequestIdsReceivedThenInitiateStorefrontUpdates() {
        StaticResource mockPayloadStaticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = mockPayloadStaticResource.Body;
        String payloadString = blobJSON.toString();
        Id integrationRequestId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id storefrontMxEscalationQueueId = fflib_IDGenerator.generate(Group.SObjectType);
        Integration_Request__c[] newIntegrationRequests = new List<Integration_Request__c>{
            new Integration_Request__c(
                Id = integrationRequestId,
                Business_Id__c = MOCK_BUSINESS_ID,
                Sfdc_Status__c = SFDC_STATUS_PENDING,
                Payload__c = payloadString
            )
        };
        WorkOrder newWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, workStepId)
                        .setField(WorkStep.WorkPlanId, workPlanId)
                }
            )
            .toSObject();
        Xref__c newXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(Xref__c.BusinessID__c, MOCK_BUSINESS_ID)
            .setField(Xref__c.Salesforce_Account_Name__c, businessAccountId)
            .setParent(
                'Salesforce_Account_Name__r',
                new Fake(Account.class).setField(Account.Id, businessAccountId)
            )
            .toSObject();
        Onboarding_Activation__e platformEvent = new Onboarding_Activation__e(
            Topic__c = EVENT_TOPIC_PLACEITFORME_INBOUND_INTEGRATION,
            Payload__c = JSON.serialize(new Set<Id>{ integrationRequestId })
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IGroupsSelector mockGroupsSelector = (IGroupsSelector) mocks.mock(IGroupsSelector.class);
        IIntegrationRequestsSelector mockIntegrationRequestsSelector = (IIntegrationRequestsSelector) mocks.mock(
            IIntegrationRequestsSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockGroupsSelector.sObjectType()).thenReturn(Group.SObjectType);
        mocks.when(mockGroupsSelector.selectQueueByName(STOREFRONT_MX_ESCALATION_QUEUE_NAME))
            .thenReturn(new List<Group>{ new Group(Id = storefrontMxEscalationQueueId) });
        mocks.when(mockIntegrationRequestsSelector.sObjectType())
            .thenReturn(Integration_Request__c.SObjectType);
        mocks.when(mockIntegrationRequestsSelector.selectById(new Set<Id>{ integrationRequestId }))
            .thenReturn(newIntegrationRequests);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ MOCK_BUSINESS_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ newXref });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsByAccountIdsAndTypesAndWorkStepTypes(
                    new Set<Id>{ businessAccountId },
                    new Set<String>{ WORK_ORDER_TYPE_STOREFRONT },
                    new Set<String>{ WORKSTEP_TYPE_IMPLEMENTATION_CALL }
                )
            )
            .thenReturn(new List<WorkOrder>{ newWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockGroupsSelector);
        Application.SELECTOR.setMock(mockIntegrationRequestsSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        PlaceItForMeIntegrationService.execute(new List<Onboarding_Activation__e>{ platformEvent });
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => STATUS_ESCALATED
                        },
                        new Map<SObjectField, Object>{
                            WorkPlan.Id => workPlanId,
                            WorkPlan.OwnerId => storefrontMxEscalationQueueId,
                            WorkPlan.Status__c => STATUS_ESCALATED,
                            WorkPlan.Primary_Routing_Assigned__c => true,
                            WorkPlan.Secondary_Routing_Assigned__c => true
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }*/

    /**
     * @description To test child Storefront Work Plan and child Work Steps are updated when event payload
     * received with 'Place It For Me' Integration Request Ids
     * Active child Storefront Work Order already exists.
     */
    @isTest
    private static void testWhenIntegrationRequestIdsReceivedThenInitiateChildStorefrontUpdates() {
        StaticResource mockPayloadStaticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = mockPayloadStaticResource.Body;
        String payloadString = blobJSON.toString();
        Id integrationRequestId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id storefrontMxEscalationQueueId = fflib_IDGenerator.generate(Group.SObjectType);
        Integration_Request__c[] newIntegrationRequests = new List<Integration_Request__c>{
            new Integration_Request__c(
                Id = integrationRequestId,
                Business_Id__c = MOCK_BUSINESS_ID,
                Sfdc_Status__c = SFDC_STATUS_PENDING,
                Payload__c = payloadString
            )
        };
        Xref__c newXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Xref__c.BusinessID__c, MOCK_BUSINESS_ID)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setParent(
                'Salesforce_Account_Name__r',
                new Fake(Account.class)
                    .setField(Account.Id, storeAccountId)
                    .setField(Account.ParentId, businessAccountId)
                    .setParent(
                        'Parent',
                        new Fake(Account.class).setField(Account.Id, businessAccountId)
                    )
            )
            .toSObject();
        WorkOrder newWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.ParentWorkOrderId, workOrderId)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, workStepId)
                        .setField(WorkStep.WorkPlanId, workPlanId)
                }
            )
            .toSObject();
        Onboarding_Activation__e platformEvent = new Onboarding_Activation__e(
            Topic__c = EVENT_TOPIC_PLACEITFORME_INBOUND_INTEGRATION,
            Payload__c = JSON.serialize(new Set<Id>{ integrationRequestId })
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IGroupsSelector mockGroupsSelector = (IGroupsSelector) mocks.mock(IGroupsSelector.class);
        IIntegrationRequestsSelector mockIntegrationRequestsSelector = (IIntegrationRequestsSelector) mocks.mock(
            IIntegrationRequestsSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IIntegrationRequestsService mockIntegrationRequestsService = (IIntegrationRequestsService) mocks.mock(
            IIntegrationRequestsService.class
        );
        mocks.startStubbing();
        mocks.when(mockGroupsSelector.sObjectType()).thenReturn(Group.SObjectType);
        mocks.when(mockGroupsSelector.selectQueueByName(STOREFRONT_MX_ESCALATION_QUEUE_NAME))
            .thenReturn(new List<Group>{ new Group(Id = storefrontMxEscalationQueueId) });
        mocks.when(mockIntegrationRequestsSelector.sObjectType())
            .thenReturn(Integration_Request__c.SObjectType);
        mocks.when(mockIntegrationRequestsSelector.selectById(new Set<Id>{ integrationRequestId }))
            .thenReturn(newIntegrationRequests);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ MOCK_BUSINESS_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ newXref });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsByAccountIdsAndTypesAndWorkStepTypes(
                    new Set<Id>{ businessAccountId },
                    new Set<String>{ WORK_ORDER_TYPE_STOREFRONT },
                    new Set<String>{ WORKSTEP_TYPE_IMPLEMENTATION_CALL }
                )
            )
            .thenReturn(
                new List<WorkOrder>{
                    newWorkOrder,
                    new WorkOrder(Id = workOrderId, AccountId = businessAccountId)
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockGroupsSelector);
        Application.SELECTOR.setMock(mockIntegrationRequestsSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(
            IIntegrationRequestsService.class,
            mockIntegrationRequestsService
        );
        Test.startTest();
        PlaceItForMeIntegrationService.execute(new List<Onboarding_Activation__e>{ platformEvent });
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => STATUS_ESCALATED,
                            WorkStep.Status_Reason__c => WORKSTEP_STATUS_PIFM_LEAD
                        },
                        new Map<SObjectField, Object>{
                            WorkPlan.Id => workPlanId,
                            WorkPlan.OwnerId => storefrontMxEscalationQueueId,
                            WorkPlan.Primary_Routing_Assigned__c => true,
                            WorkPlan.Secondary_Routing_Assigned__c => true
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((IIntegrationRequestsService) mocks.verify(mockIntegrationRequestsService))
            .updateIntegrationRequestsSFDCStatus(
                new Set<Id>{ integrationRequestId },
                INTEGRATION_REQUEST_STATUS_PROCESSED
            );
    }

    /**
     * @description To test Storefront Work Order creation is initiated when event payload
     * received with 'Place It For Me' Integration Request Ids.
     * Active Storefront Work Order doesnot exists.
     */
    @isTest
    private static void testWhenIntegrationRequestIdsReceivedThenInitiateStorefrontWorkOrderCreation() {
        StaticResource mockPayloadStaticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = mockPayloadStaticResource.Body;
        String payloadString = blobJSON.toString();
        Id integrationRequestId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id secondStoreAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storefrontMxEscalationQueueId = fflib_IDGenerator.generate(Group.SObjectType);
        Integration_Request__c[] newIntegrationRequests = new List<Integration_Request__c>{
            new Integration_Request__c(
                Id = integrationRequestId,
                Business_Id__c = MOCK_BUSINESS_ID,
                Sfdc_Status__c = SFDC_STATUS_PENDING,
                Payload__c = payloadString
            )
        };
        Xref__c newXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Xref__c.BusinessID__c, MOCK_BUSINESS_ID)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setParent(
                'Salesforce_Account_Name__r',
                new Fake(Account.class)
                    .setField(Account.Id, storeAccountId)
                    .setField(Account.ParentId, businessAccountId)
                    .setParent(
                        'Parent',
                        new Fake(Account.class).setField(Account.Id, businessAccountId)
                    )
            )
            .toSObject();
        Onboarding_Activation__e platformEvent = new Onboarding_Activation__e(
            Topic__c = EVENT_TOPIC_PLACEITFORME_INBOUND_INTEGRATION,
            Payload__c = JSON.serialize(new Set<Id>{ integrationRequestId })
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IGroupsSelector mockGroupsSelector = (IGroupsSelector) mocks.mock(IGroupsSelector.class);
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IIntegrationRequestsSelector mockIntegrationRequestsSelector = (IIntegrationRequestsSelector) mocks.mock(
            IIntegrationRequestsSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IIntegrationRequestsService mockIntegrationRequestsService = (IIntegrationRequestsService) mocks.mock(
            IIntegrationRequestsService.class
        );
        mocks.startStubbing();
        mocks.when(mockGroupsSelector.sObjectType()).thenReturn(Group.SObjectType);
        mocks.when(mockGroupsSelector.selectQueueByName(STOREFRONT_MX_ESCALATION_QUEUE_NAME))
            .thenReturn(new List<Group>{ new Group(Id = storefrontMxEscalationQueueId) });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByParentIdsAndExperience(
                    new Set<Id>{ businessAccountId },
                    ACCOUNT_EXPERIENCE_STOREFRONT
                )
            )
            .thenReturn(
                new List<Account>{
                    new Account(Id = storeAccountId, ParentId = businessAccountId),
                    new Account(Id = secondStoreAccountId, ParentId = businessAccountId)
                }
            );
        mocks.when(mockIntegrationRequestsSelector.sObjectType())
            .thenReturn(Integration_Request__c.SObjectType);
        mocks.when(mockIntegrationRequestsSelector.selectById(new Set<Id>{ integrationRequestId }))
            .thenReturn(newIntegrationRequests);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ MOCK_BUSINESS_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ newXref });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsByAccountIdsAndTypesAndWorkStepTypes(
                    new Set<Id>{ businessAccountId },
                    new Set<String>{ WORK_ORDER_TYPE_STOREFRONT },
                    new Set<String>{ WORKSTEP_TYPE_IMPLEMENTATION_CALL }
                )
            )
            .thenReturn(new List<WorkOrder>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockGroupsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockIntegrationRequestsSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(
            IIntegrationRequestsService.class,
            mockIntegrationRequestsService
        );
        Test.startTest();
        PlaceItForMeIntegrationService.execute(new List<Onboarding_Activation__e>{ platformEvent });
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Interface_Transaction_Configuration_Name__c => INTERFACE_TRANSACTION_CONFIG_NAME_WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION,
                            Interface_Transaction__c.Remaining_Retry_Attempts__c => 3
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((IIntegrationRequestsService) mocks.verify(mockIntegrationRequestsService))
            .updateIntegrationRequestsSFDCStatus(
                new Set<Id>{ integrationRequestId },
                INTEGRATION_REQUEST_STATUS_PROCESSED
            );
    }

    /**
     * @description To test Storefront Work Plans are updated with Notes and
     * 'Storefront - Mx Escalation' queue on creation.
     */
    @isTest
    private static void testWhenStorefrontWorkPlansReceivedThenUpdateOwnerAndNotes() {
        PlaceItForMePayloadParser newPlaceItForMePayloadParser = new PlaceItForMePayloadParser();
        StaticResource mockPayloadStaticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = mockPayloadStaticResource.Body;
        String payloadString = blobJSON.toString();
        newPlaceItForMePayloadParser = (PlaceItForMePayloadParser) JSON.deserialize(
            payloadString,
            PlaceItForMePayloadParser.class
        );
        Id integrationRequestId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id childWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id storefrontMxEscalationQueueId = fflib_IDGenerator.generate(Group.SObjectType);
        Integration_Request__c[] newIntegrationRequests = new List<Integration_Request__c>{
            new Integration_Request__c(
                Id = integrationRequestId,
                Business_Id__c = MOCK_BUSINESS_ID,
                Sfdc_Status__c = SFDC_STATUS_PENDING,
                Payload__c = payloadString
            )
        };
        List<WorkPlan> workPlans = new List<WorkPlan>{
            new WorkPlan(Id = parentWorkPlanId, WorkOrderId = workOrderId),
            new WorkPlan(Id = childWorkPlanId, Parent_Work_Plan__c = parentWorkPlanId)
        };
        WorkOrder newWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Integration_Request_Id__c, integrationRequestId)
            .toSObject();
        Xref__c newXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(Xref__c.BusinessID__c, MOCK_BUSINESS_ID)
            .setField(Xref__c.Salesforce_Account_Name__c, businessAccountId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IGroupsSelector mockGroupsSelector = (IGroupsSelector) mocks.mock(IGroupsSelector.class);
        IIntegrationRequestsSelector mockIntegrationRequestsSelector = (IIntegrationRequestsSelector) mocks.mock(
            IIntegrationRequestsSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockGroupsSelector.sObjectType()).thenReturn(Group.SObjectType);
        mocks.when(mockGroupsSelector.selectQueueByName(STOREFRONT_MX_ESCALATION_QUEUE_NAME))
            .thenReturn(new List<Group>{ new Group(Id = storefrontMxEscalationQueueId) });
        mocks.when(mockIntegrationRequestsSelector.sObjectType())
            .thenReturn(Integration_Request__c.SObjectType);
        mocks.when(mockIntegrationRequestsSelector.selectById(new Set<Id>{ integrationRequestId }))
            .thenReturn(newIntegrationRequests);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ MOCK_BUSINESS_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ newXref });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ workOrderId }))
            .thenReturn(new List<WorkOrder>{ newWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockGroupsSelector);
        Application.SELECTOR.setMock(mockIntegrationRequestsSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        PlaceItForMeIntegrationService.updatePlaceItForMeStorefrontWorkPlans(workPlans);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkPlan.Id => childWorkPlanId,
                            WorkPlan.OwnerId => storefrontMxEscalationQueueId,
                            WorkPlan.Status__c => STATUS_ESCALATED,
                            WorkPlan.Primary_Routing_Assigned__c => true,
                            WorkPlan.Secondary_Routing_Assigned__c => true
                        },
                        new Map<SObjectField, Object>{
                            WorkPlan.Id => parentWorkPlanId,
                            WorkPlan.OwnerId => storefrontMxEscalationQueueId,
                            WorkPlan.Status__c => STATUS_ESCALATED,
                            WorkPlan.Primary_Routing_Assigned__c => true,
                            WorkPlan.Secondary_Routing_Assigned__c => true
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}