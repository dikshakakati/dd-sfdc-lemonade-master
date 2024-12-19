/**
 * @author Deloitte
 * @date 27/05/2022
 * @description Test class for TabletCasePayloadGenerationServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class TabletCasePayloadGenerationSrvcImplTest {
    private static final String EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC = 'TABLET_CASE_INSERT';
    private static final String EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_UPDATE_TOPIC = 'TABLET_CASE_UPDATE';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_STEP_TYPE_DELIVER_TABLET = 'Deliver Tablet';
    private static final String WORK_STEP_STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_STEP_STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String PROVISIONING_STATUS_PROVISIONING_COMPLETE = 'Provisioning Complete';
    private static final String TABLET_USERNAME = 'AccountsTest Username';
    private static final String TABLET_PASSWORD = 'AccountsTest Password';
    private static final String ORDER_PROTOCOL = 'Android Tablet (Merchant Owns)';
    private static final String EMAIL_ORDER_PROTOCOL = 'Email';

    /**
     * @description To test when Deliver Tablet Work Step is present for Store Account then publish
     * External and Internal Notifier event with Tablet Case insert topic and corresponding payload.
     */
    @isTest
    private static void testWhenDeliverTabletWorkStepsExistsForGivenStoreAccountIdsThenExternalNotifierEventPublishedWithPayload() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccountId,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Status, STATUS_IN_PROGRESS)
            .setParent('Account', new Fake(Account.class)
                        .setField(Account.Id, storeAccountId)
                       	.setField(Account.Tablet_User_Name__c, TABLET_USERNAME)
                        .setField(Account.Tablet_Password__c, TABLET_PASSWORD)
                      );
        WorkOrder workOrderInstance = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        Fake newWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_NOT_STARTED
            )
            .setField(WorkStep.Name, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Work_Order_Type__c, TYPE_MARKETPLACE);
        WorkStep deliverTabletWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            newWorkStepFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IExternalNotifierEventsService externalNotifierServiceMock = (IExternalNotifierEventsService) mocks.mock(
            IExternalNotifierEventsService.class
        );
        INotifierEventsService mockNotifierEventsService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectByAccountIds(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<WorkOrder>{ workOrderInstance });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getDeliverTabletWorkStepsDetailsByStoreAccount(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<WorkStep>{ deliverTabletWorkStep });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(
            IExternalNotifierEventsService.class,
            externalNotifierServiceMock
        );
        Application.SERVICE.setMock(INotifierEventsService.class, mockNotifierEventsService);
        TabletCaseEntry mockTabletCaseEntry = new TabletCaseEntry(
            deliverTabletWorkStep.Id,
            deliverTabletWorkStep.WorkOrderId
        );
        String eventPayload = JSON.serialize(new Set<TabletCaseEntry>{ mockTabletCaseEntry });
        TabletCasePayloadGenerationService.generatePayloadUsingStoreAccountIds(
            new Set<Id>{ storeAccountId },
            EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC
        );
        ((IExternalNotifierEventsService) mocks.verify(externalNotifierServiceMock, 1))
            .publishEvents(
                new Map<String, String>{
                    EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC => eventPayload
                }
            );
    }

    /**
     * @description To test when updated Deliver Tablet Work Step is passed then publish
     * External Notifier event with Tablet Case update topic and corresponding payload.
     */
    @isTest
    private static void testWhenUpdatedDeliverTabletWorkStepsThenExternalNotifierEventPublishedWithPayload() {
        Fake newWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_IN_PROGRESS
            )
            .setField(WorkStep.Name, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Work_Order_Type__c, TYPE_MARKETPLACE);
        WorkStep deliverTabletWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            newWorkStepFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IExternalNotifierEventsService externalNotifierServiceMock = (IExternalNotifierEventsService) mocks.mock(
            IExternalNotifierEventsService.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(
            IExternalNotifierEventsService.class,
            externalNotifierServiceMock
        );
        TabletCaseEntry mockTabletCaseEntry = new TabletCaseEntry(
            deliverTabletWorkStep.Id,
            deliverTabletWorkStep.WorkOrderId
        );
        String eventPayload = JSON.serialize(new Set<TabletCaseEntry>{ mockTabletCaseEntry });
        TabletCasePayloadGenerationService.generatePayloadUsingWorkSteps(
            new List<WorkStep>{ deliverTabletWorkStep },
            EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_UPDATE_TOPIC
        );
        ((IExternalNotifierEventsService) mocks.verify(externalNotifierServiceMock, 1))
            .publishEvents(
                new Map<String, String>{
                    EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_UPDATE_TOPIC => eventPayload
                }
            );
    }

    /**
     * @description To test when Deliver Tablet Work Step is present on Work Order Type 'COO' for
     * Store Account then publish External Notifier event with Tablet Case insert topic and corresponding payload.
     */
    @isTest
    private static void testWhenDeliverTabletWorkStepsExistsForGivenStoreAccountIdsOnWorkOrderTypeCOOThenExternalNotifierEventPublishedWithPayload() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake newWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_NOT_STARTED
            )
            .setField(WorkStep.Name, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Work_Order_Type__c, TYPE_COO);
        WorkStep deliverTabletWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            newWorkStepFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IExternalNotifierEventsService externalNotifierServiceMock = (IExternalNotifierEventsService) mocks.mock(
            IExternalNotifierEventsService.class
        );
        INotifierEventsService mockNotifierEventsService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectByAccountIds(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getDeliverTabletWorkStepsDetailsByStoreAccount(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<WorkStep>{ deliverTabletWorkStep });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(
            IExternalNotifierEventsService.class,
            externalNotifierServiceMock
        );
        Application.SERVICE.setMock(INotifierEventsService.class, mockNotifierEventsService);
        TabletCaseEntry mockTabletCaseEntry = new TabletCaseEntry(
            deliverTabletWorkStep.Id,
            deliverTabletWorkStep.WorkOrderId
        );
        String eventPayload = JSON.serialize(new Set<TabletCaseEntry>{ mockTabletCaseEntry });
        TabletCasePayloadGenerationService.generatePayloadUsingStoreAccountIds(
            new Set<Id>{ storeAccountId },
            EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC
        );
        ((IExternalNotifierEventsService) mocks.verify(externalNotifierServiceMock, 1))
            .publishEvents(
                new Map<String, String>{
                    EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC => eventPayload
                }
            );
        ((INotifierEventsService) mocks.verify(mockNotifierEventsService, 0))
            .publishEvents(new Map<String, String>{});
    }

/**
     * @description To test when the Tablet Username and Tablet Password on the Store Account are not null
     * and the order protocol is either 'Android Tablet (Merchant Owns)' or'POS and Tablet (Merchant Owns)'
     * then do not publish External Notifier event with Tablet Case insert topic and corresponding payload.
     */
    @isTest
    private static void testWhenTabletCredentialsGeneratedAndNotEligibleOrderProtocolThenExternalNotifierEventNotPublishedWithPayload() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake newWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_IN_PROGRESS
            )
            .setField(WorkStep.Name, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Work_Order_Type__c, TYPE_MARKETPLACE)
            .setField(WorkStep.Store_Account__c,storeAccountId);
        WorkStep newWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            newWorkStepFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccountId,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Status, STATUS_IN_PROGRESS)
            .setParent('Account', new Fake(Account.class)
                        .setField(Account.Id, storeAccountId)
                        .setField(Account.Tablet_User_Name__c, TABLET_USERNAME)
                        .setField(Account.Tablet_Password__c, TABLET_PASSWORD)
                        .setField(Account.Order_Protocol__c,ORDER_PROTOCOL)
                      );
        WorkOrder workOrderInstance = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IExternalNotifierEventsService externalNotifierServiceMock = (IExternalNotifierEventsService) mocks.mock(
            IExternalNotifierEventsService.class
        );
        INotifierEventsService mockNotifierEventsService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectByAccountIds(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<WorkOrder>{ workOrderInstance });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                    mockWorkStepsSelector.getDeliverTabletWorkStepsDetailsByStoreAccount(
                        new Set<Id>{ storeAccountId }
                    )
                )
                .thenReturn(new List<WorkStep>{ newWorkStep });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(
            IExternalNotifierEventsService.class,
            externalNotifierServiceMock
        );
        Application.SERVICE.setMock(INotifierEventsService.class, mockNotifierEventsService);
        TabletCaseEntry mockTabletCaseEntry = new TabletCaseEntry(
            newWorkStep.Id,
            newWorkStep.WorkOrderId
        );
        String eventPayload = JSON.serialize(new Set<TabletCaseEntry>{ mockTabletCaseEntry });
        TabletCasePayloadGenerationService.generatePayloadUsingStoreAccountIds(
            new Set<Id>{ storeAccountId },
            EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC
        );
        ((IExternalNotifierEventsService) mocks.verify(externalNotifierServiceMock, 0))
            .publishEvents(
                new Map<String, String>{
                    EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC => eventPayload
                }
            );
    }

    /**
     * @description To test when the Tablet Username and Tablet Password on the Store Account are not null
     * and the order protocol is not 'Android Tablet (Merchant Owns)' or'POS and Tablet (Merchant Owns)'
     * then publish External Notifier event with Tablet Case insert topic and corresponding payload.
     */
    @isTest
    private static void testWhenTabletCredentialsGeneratedAndEligibleOrderProtocolThenExternalNotifierEventPublishedWithPayload() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake newWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_IN_PROGRESS
            )
            .setField(WorkStep.Name, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Work_Order_Type__c, TYPE_MARKETPLACE)
            .setField(WorkStep.Store_Account__c,storeAccountId);
        WorkStep newWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            newWorkStepFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccountId,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Status, STATUS_IN_PROGRESS)
            .setParent('Account', new Fake(Account.class)
                        .setField(Account.Id, storeAccountId)
                        .setField(Account.Tablet_User_Name__c, TABLET_USERNAME)
                        .setField(Account.Tablet_Password__c, TABLET_PASSWORD)
                        .setField(Account.Order_Protocol__c,EMAIL_ORDER_PROTOCOL)
                      );
        WorkOrder workOrderInstance = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IExternalNotifierEventsService externalNotifierServiceMock = (IExternalNotifierEventsService) mocks.mock(
            IExternalNotifierEventsService.class
        );
        INotifierEventsService mockNotifierEventsService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectByAccountIds(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<WorkOrder>{ workOrderInstance });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                    mockWorkStepsSelector.getDeliverTabletWorkStepsDetailsByStoreAccount(
                        new Set<Id>{ storeAccountId }
                    )
                )
                .thenReturn(new List<WorkStep>{ newWorkStep });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(
            IExternalNotifierEventsService.class,
            externalNotifierServiceMock
        );
        Application.SERVICE.setMock(INotifierEventsService.class, mockNotifierEventsService);
        TabletCaseEntry mockTabletCaseEntry = new TabletCaseEntry(
            newWorkStep.Id,
            newWorkStep.WorkOrderId
        );
        String eventPayload = JSON.serialize(new Set<TabletCaseEntry>{ mockTabletCaseEntry });
        TabletCasePayloadGenerationService.generatePayloadUsingStoreAccountIds(
            new Set<Id>{ storeAccountId },
            EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC
        );
        ((IExternalNotifierEventsService) mocks.verify(externalNotifierServiceMock, 1))
            .publishEvents(
                new Map<String, String>{
                    EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC => eventPayload
                }
            );
    }


    /**
     * @description To test when the Tablet Username and Tablet Password on the Store Account are null
     * or the order protocol is not 'Android Tablet (Merchant Owns)' or'POS and Tablet (Merchant Owns)'
     * then publish External Notifier event with Tablet Case insert topic and corresponding payload.
     */
    @isTest
    private static void testWhenTabletCredentialsNotGeneratedAndEligibleOrderProtocolThenExternalNotifierEventPublishedWithPayload() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake newWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_IN_PROGRESS
            )
            .setField(WorkStep.Name, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Work_Order_Type__c, TYPE_MARKETPLACE)
            .setField(WorkStep.Store_Account__c,storeAccountId);
        WorkStep newWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            newWorkStepFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccountId,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Status, STATUS_IN_PROGRESS)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_PROVISIONING_COMPLETE)
            .setParent('Account', new Fake(Account.class)
                        .setField(Account.Id, storeAccountId)
                       	.setField(Account.Tablet_User_Name__c, null)
                        .setField(Account.Tablet_Password__c, null)
                      );
        WorkOrder workOrderInstance = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IExternalNotifierEventsService externalNotifierServiceMock = (IExternalNotifierEventsService) mocks.mock(
            IExternalNotifierEventsService.class
        );
        INotifierEventsService mockNotifierEventsService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectByAccountIds(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<WorkOrder>{ workOrderInstance });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                    mockWorkStepsSelector.getDeliverTabletWorkStepsDetailsByStoreAccount(
                        new Set<Id>{ storeAccountId }
                    )
                )
                .thenReturn(new List<WorkStep>{ newWorkStep });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(
            IExternalNotifierEventsService.class,
            externalNotifierServiceMock
        );
        Application.SERVICE.setMock(INotifierEventsService.class, mockNotifierEventsService);
        TabletCaseEntry mockTabletCaseEntry = new TabletCaseEntry(
            newWorkStep.Id,
            newWorkStep.WorkOrderId
        );
        String eventPayload = JSON.serialize(new Set<TabletCaseEntry>{ mockTabletCaseEntry });
        TabletCasePayloadGenerationService.generatePayloadUsingStoreAccountIds(
            new Set<Id>{ storeAccountId },
            EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC
        );
        ((IExternalNotifierEventsService) mocks.verify(externalNotifierServiceMock, 0))
            .publishEvents(
                new Map<String, String>{
                    EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC => eventPayload
                }
            );
    }
}