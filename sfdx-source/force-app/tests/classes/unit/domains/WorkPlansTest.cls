/**
 * @author Deloitte
 * @date 15/04/2022
 * @description Test class for WorkPlans class.
 */
@isTest(seeAllData=false)
private class WorkPlansTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String CHILD_WORKPLAN_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Child_Work_Plan_Ids_Payload_Chunk_Size';
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final Integer EXECUTION_ORDER = 1;
    private static final String EMAIL_ORDER_PROTOCOL = 'Email';
    private static final String EVENT_TOPIC_WORK_OBJECTS_SYNC = 'WORK_OBJECTS_SYNC';
    private static final string FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE = 'Unexpected result: Work Plan field is not updated with expected value';
    private static final String GENERIC_WORK_ORDER_CREATION = 'WORK_ORDER_GENERATION';
    private static final String MARKETPLACE_WORK_ORDER_TYPE = 'Marketplace';
    private static final String METADATA_VALUE = '1';
    private static final String NOT_STARTED = 'Not Started';
    private static final Integer NUMBER_OF_STORES_VALIDATED_SIX = 6;
    private static final Integer NUMBER_OF_STORES_IN_PROGRESS_ONE = 1;
    private static final Integer NUMBER_OF_WORKABLE_WORKSTEPS_ONE = 1;
    private static final Integer NUMBER_OF_WORKABLE_WORKSTEPS_SIX = 6;
    private static final Integer NUMBER_OF_WORKABLE_WORKSTEPS_THREE = 3;
    private static final Integer NUMBER_OF_WORKABLE_WORKSTEPS_ZERO = 0;
    private static final String ONBOARDING_WORK_PLAN = 'Onboarding';
    private static final String PARENT_WORKABLE_COUNT_NOT_UPDATED_ASSERT_MESSAGE = 'Unexpected result: The count of workable WorkSteps was not updated on parent';
    private static final String PARENT_WORKPLAN_AGGREGATE_QUERY_COUNT_ALIAS = 'childWorkPlans';
    private static final String PARENT_WORKPLAN_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS = 'parentId';
    private static final String PARENT_WORKPLAN_AGGREGATE_QUERY_VALIDATION_STATUS_ALIAS = 'validationStatus';
    private static final String SMB_SEGMENT = 'SMB';
    private static final String STOREFRONT_WORK_PLAN = 'Storefront';
    private static final String POS_ORDER_PROTOCOL = 'POS';
    private static final String STATUS_ESCALATED = 'Escalated';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String STOREFRONT_UNDER_REVIEW_QUEUE = 'Storefront - Under Review';
    private static final String TABLET_AND_PRINTER_ORDER_PROTOCOL = 'Tablet and Printer (DoorDash Owns)';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String ULTIMATE_PARENT_WORK_STEP_CONDITION = null;
    private static final String ULTIMATE_PARENT_WORK_STEP_GROUPBYFIELD = 'Parent_Work_Step__c';
    private static final String ULTIMATE_PARENT_WORK_PLAN_GROUPBYFIELD = 'WorkPlan.Parent_Work_Plan__c';
    private static final String ULTIMATE_PARENT_WORK_ORDER_CONDITION = 'WorkOrder.ParentWorkOrder.Status NOT IN :WORK_ORDER_PRIORITY_STATUSES';
    private static final String ULTIMATE_PARENT_WORK_ORDER_GROUPBYFIELD = 'WorkOrder.ParentWorkOrderId';
    private static final String ULTIMATE_PARENT_WORK_PLAN_CONDITION = null;
    private static final String VALIDATION_STATUS_COMPLETED = 'Completed';
    private static final String VALIDATION_STATUS_IN_PROGRESS = 'In Progress';
    private static final String VALIDATION_STATUS_PENDING = 'Pending';
    private static final String VERTICAL = 'Rx';
    private static final String WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME = 'Place It For Me';
    private static final String WORK_PLAN_COMPLETE = 'Complete';
    private static final String WORK_PLAN_NAME = 'Storefront';
    private static final string WORK_PLAN_ROUTING_INDICATOR_ASSERT_MESSAGE = 'Unexpected result: Have All Stores Activated field does match on Work Plan';
    private static final String WORK_PLAN_TEMPLATE_NAME = 'Storefront';
    private static final String WORK_PLAN_TYPE_VENDOR_PHOTOSHOOT = 'Vendor Photoshoot';
    private static final Integer WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER = 1;
    private static final String WORK_STEP_TEMPLATE_NAME = 'Review & Triage';
    private static final String ACCOUNT_TYPE_VIRTUAL = 'Virtual';
    private static final String ACCOUNT_TYPE_FOOD_TRUCK = 'Food Truck';
    private static final String EXCEPTION_MESSAGE = 'Exception occurred while performing creating Mx Order';
    private static final String ASSERT_MESSAGE_ERROR_MESSAGE_MISMATCH = 'Exception message does not match';
    private static final String WORK_PLAN_TYPE_MARKETING_KIT = 'Marketing Kit';
    private static final String COUNTRY_US ='US';
    private static final String STATE_PR ='PR';
    private static final String POS_INTEGRATION_TYPE_CLOVER ='clover';
    private static final String POS_INTEGRATION_TYPE_BEVMO ='bevmo';

     /**
     * @description To test updation of POS Integration Verified flag on parent Workplan when child Workplan
     * are with verified POS Integration types and Segment is SMB.
     */
    @isTest
    private static void testWhenWPWithVerifiedPOSIntegrationTypesThenUpdatePOSIntegrationVerifiedflagParentWorkPlan() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Aggregate> workableWorkStepsCountOnWorkPlan = new List<Aggregate>{
            new Aggregate()
                .put('parentId', parentWorkPlanId)
                .put('workableWorkSteps', NUMBER_OF_WORKABLE_WORKSTEPS_THREE)
        };
        WorkPlan parentWorkPlan = new WorkPlan(Id = parentWorkPlanId,Is_POS_Integration_Verified__c = false );
        WorkPlan newChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.Parent_Work_Plan__r.Is_POS_Integration_Verified__c, false)
            .setField(WorkPlan.POS_Integration_Type__c, POS_INTEGRATION_TYPE_CLOVER)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .setField(WorkPlan.Segment__c, SMB_SEGMENT)
            .setParent(
                       'WorkOrder',
                        new Fake(WorkOrder.class)
                		.setField(WorkOrder.Id, workOrderId)
                        .setField(WorkOrder.AccountId , accountId)
                        .setField(WorkOrder.Account_Type__c, ACCOUNT_TYPE_FOOD_TRUCK)
                        .setParent(
                                    'Account',
                                     new Fake(Account.class)
                                     .setField(Account.Id, accountId)
                                     .setField(Account.Segment__c, SMB_SEGMENT)
                                     .setField(Account.BillingCountryCode, COUNTRY_US)
                                     .setField(Account.BillingStateCode, STATE_PR)
                        )
                      )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector workPlanSelectorMock = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IWorkPlans workPlanInstance = WorkPlans.newInstance(new List<WorkPlan>{ newChildWorkPlan });
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlanSelectorMock.selectWorkPlansWithWorkOrderAssociatedToVirtualStores(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(new List<WorkPlan>{});
        mocks.when(
                workPlanSelectorMock.selectWorkPlansWithVerifiedPOSIntegrationTypes(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(new List<WorkPlan>{newChildWorkPlan});
         mocks.when(
                workPlanSelectorMock.getSumOfNumberOfWorkableWorkStepsOnChildWorkPlanGroupedByParentWorkPlan(
                    new Set<Id>{ parentWorkPlanId }
                )
            )
            .thenReturn(workableWorkStepsCountOnWorkPlan);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workPlanSelectorMock);
        Test.startTest();
        workPlanInstance.onAfterInsertHandleRelatedRecords();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        system.assertEquals(parentWorkPlan.Is_POS_Integration_Verified__c, false,FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE);
        }

    /**
     * @description To negative test updation of POS Integration Verified flag on parent Workplan when child Workplan
     * are with not verified POS Integration types and Segment is SMB.
     */
    @isTest
    private static void testWhenWPWithNotVerifiedPOSIntegrationTypesThenUpdatePOSIntegrationVerifiedflagParentWorkPlan() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Aggregate> workableWorkStepsCountOnWorkPlan = new List<Aggregate>{
            new Aggregate()
                .put('parentId', parentWorkPlanId)
                .put('workableWorkSteps', NUMBER_OF_WORKABLE_WORKSTEPS_THREE)
        };
        WorkPlan parentWorkPlan = new WorkPlan(Id = parentWorkPlanId,Is_POS_Integration_Verified__c = false );
        WorkPlan newChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.Parent_Work_Plan__r.Is_POS_Integration_Verified__c, false)
            .setField(WorkPlan.POS_Integration_Type__c, POS_INTEGRATION_TYPE_BEVMO)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .setField(WorkPlan.Segment__c, SMB_SEGMENT)
            .setParent(
                       'WorkOrder',
                        new Fake(WorkOrder.class)
                		.setField(WorkOrder.Id, workOrderId)
                        .setField(WorkOrder.AccountId , accountId)
                        .setField(WorkOrder.Account_Type__c, ACCOUNT_TYPE_FOOD_TRUCK)
                        .setParent(
                                    'Account',
                                     new Fake(Account.class)
                                     .setField(Account.Id, accountId)
                                     .setField(Account.Segment__c, SMB_SEGMENT)
                                     .setField(Account.BillingCountryCode, COUNTRY_US)
                                     .setField(Account.BillingStateCode, STATE_PR)
                        )
                      )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector workPlanSelectorMock = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IWorkPlans workPlanInstance = WorkPlans.newInstance(new List<WorkPlan>{ newChildWorkPlan });
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlanSelectorMock.selectWorkPlansWithWorkOrderAssociatedToVirtualStores(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(new List<WorkPlan>{});
        mocks.when(
                workPlanSelectorMock.selectWorkPlansWithVerifiedPOSIntegrationTypes(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(new List<WorkPlan>{});
         mocks.when(
                workPlanSelectorMock.getSumOfNumberOfWorkableWorkStepsOnChildWorkPlanGroupedByParentWorkPlan(
                    new Set<Id>{ parentWorkPlanId }
                )
            )
            .thenReturn(workableWorkStepsCountOnWorkPlan);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workPlanSelectorMock);
        Test.startTest();
        workPlanInstance.onAfterInsertHandleRelatedRecords();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        system.assertEquals(parentWorkPlan.Is_POS_Integration_Verified__c, false,FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE);
        }

    /**
     * @description This method is used to test class instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<WorkPlan> workPlansList = new List<WorkPlan>();
        WorkPlans.newInstance(workPlansList);
        WorkPlans workPlansObject = new WorkPlans(workPlansList);
        WorkPlans.Constructor constructorObject = new WorkPlans.Constructor();
        constructorObject.construct(workPlansList);
        System.assertNotEquals(
            WorkPlans.newInstance(workPlansList),
            workPlansObject,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when a WorkPlan inserted then related WorkSteps are created through
     * WorkStepsCreationService class.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkPlanIsInsertedThenCreateWorkStepsOnWorkPlansIsCalled() {
        WorkPlanTemplate relatedWorkPlanTemplate = new WorkPlanTemplate(
            Id = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType),
            Name = WORK_PLAN_TEMPLATE_NAME
        );
        List<WorkPlan> mockWorkPlans = new List<WorkPlan>{
            (WorkPlan) new Fake(WorkPlan.class)
                .setField(WorkPlan.Id, fflib_IDGenerator.generate(WorkPlan.SObjectType))
                .setField(WorkPlan.Enable_Merchant_Orders_Creation__c, true)
                .setField(WorkPlan.Name, WORK_PLAN_NAME)
                .setField(WorkPlan.Status__c, NOT_STARTED)
                .setField(WorkPlan.Type__c, WORK_PLAN_TYPE_VENDOR_PHOTOSHOOT)
                .setField(WorkPlan.WorkOrderId, fflib_IDGenerator.generate(WorkOrder.SObjectType))
                .setField(WorkPlan.Work_Plan_Template__c, relatedWorkPlanTemplate.Id)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsCreationService serviceMock = (IWorkStepsCreationService) mocks.mock(
            IWorkStepsCreationService.class
        );
        IMxOrderCreationService mxOrderServiceMock = (IMxOrderCreationService) mocks.mock(
            IMxOrderCreationService.class
        );
        Application.SERVICE.setMock(IWorkStepsCreationService.class, serviceMock);
        Application.SERVICE.setMock(IMxOrderCreationService.class, mxOrderServiceMock);
        WorkPlans.newInstance(mockWorkPlans).onAfterInsertHandleRelatedRecords();
        ((IWorkStepsCreationService) mocks.verify(serviceMock, 1))
            .createWorkStepsOnWorkPlans(mockWorkPlans, new Set<Id>{ relatedWorkPlanTemplate.Id });
        ((IMxOrderCreationService) mocks.verify(mxOrderServiceMock, 1))
            .generatePhotoShootMxOrder(mockWorkPlans);
    }

    /**
     * @description To test updation of workable WorkSteps count on Parent WorkPlan
     * in after update.
     * Suppressed warnings since mock verify method is used.
     */
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    private static void testWhenOnAfterUpdateCalledThenUpdateNumberOfWorkableWorkstepsOnParentWorkPlan() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Map<Id, WorkPlan> oldWorkPlans = new Map<Id, WorkPlan>();
        List<sObject> sobjectsToUpdate = new List<sObject>();
        List<Aggregate> workableWorkStepsCountOnWorkPlan = new List<Aggregate>{
            new Aggregate()
                .put('parentId', parentWorkPlanId)
                .put('workableWorkSteps', NUMBER_OF_WORKABLE_WORKSTEPS_ONE)
        };
        WorkPlan parentWorkPlan = new WorkPlan(Id = parentWorkPlanId);
        WorkPlan oldChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_ZERO
            )
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        oldWorkPlans.put(workPlanId, oldChildWorkPlan);
        WorkPlan newChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_ONE
            )
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkPlansSelector workPlanSelectorMock = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        IWorkPlans workPlanInstance = WorkPlans.newInstance(new List<WorkPlan>{ newChildWorkPlan });
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlanSelectorMock.getSumOfNumberOfWorkableWorkStepsOnChildWorkPlanGroupedByParentWorkPlan(
                    new Set<Id>{ parentWorkPlanId }
                )
            )
            .thenReturn(workableWorkStepsCountOnWorkPlan);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workPlanSelectorMock);
        workPlanInstance.onAfterUpdateHandleRelatedRecords(oldWorkPlans);
        parentWorkPlan.Number_of_Workable_WorkSteps__c = NUMBER_OF_WORKABLE_WORKSTEPS_ONE;
        sobjectsToUpdate.addAll(new List<WorkPlan>{ parentWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test updation of workable WorkSteps count on change of roll-up field
     * in the same WorkPlan in before update.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnBeforeUpdateCalledThenUpdateTheCountOnParentWorkPlan() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Map<Id, WorkPlan> oldWorkPlans = new Map<Id, WorkPlan>();
        List<Aggregate> workableWorkStepsCountOnWorkPlan = new List<Aggregate>{
            new Aggregate()
                .put('parentId', parentWorkPlanId)
                .put('workableWorkSteps', NUMBER_OF_WORKABLE_WORKSTEPS_ONE)
        };
        WorkPlan oldChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_ZERO
            )
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        oldWorkPlans.put(workPlanId, oldChildWorkPlan);
        WorkPlan newChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_ONE
            )
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkPlansSelector workPlanSelectorMock = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        IWorkPlans workPlanInstance = WorkPlans.newInstance(new List<WorkPlan>{ newChildWorkPlan });
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlanSelectorMock.getSumOfNumberOfWorkableWorkStepsOnChildWorkPlanGroupedByParentWorkPlan(
                    new Set<Id>{ parentWorkPlanId }
                )
            )
            .thenReturn(workableWorkStepsCountOnWorkPlan);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workPlanSelectorMock);
        workPlanInstance.onBeforeUpdateValidateAndUpdateWorkPlanFields(oldWorkPlans);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test updation of workable WorkSteps count on parent WorkPlan
     * when a new child WorkPlan is created.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnAfterInsertChildWorkPlanThenUpdateTheCountOnParentWorkPlan() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<Aggregate> workableWorkStepsCountOnWorkPlan = new List<Aggregate>{
            new Aggregate()
                .put('parentId', parentWorkPlanId)
                .put('workableWorkSteps', NUMBER_OF_WORKABLE_WORKSTEPS_THREE)
        };
        WorkPlan parentWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, parentWorkPlanId)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_ZERO
            )
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        WorkPlan newChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_THREE
            )
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlan.Id)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector workPlanSelectorMock = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IMxOrderCreationService mxOrderCreationServiceMock = (IMxOrderCreationService) mocks.mock(
            IMxOrderCreationService.class
        );
        IWorkPlans workPlanInstance = WorkPlans.newInstance(new List<WorkPlan>{ newChildWorkPlan });
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlanSelectorMock.getSumOfNumberOfWorkableWorkStepsOnChildWorkPlanGroupedByParentWorkPlan(
                    new Set<Id>{ parentWorkPlanId }
                )
            )
            .thenReturn(workableWorkStepsCountOnWorkPlan);
        mocks.when(
                workPlanSelectorMock.selectWorkPlansByWorkPlanIdsAndTypes(
                    new Set<Id>{ parentWorkPlanId },
                    new Set<String>{ 'Marketing Kit' }
                )
            )
            .thenReturn(new List<WorkPlan>{ parentWorkPlan });
        mocks.when(
                workPlanSelectorMock.selectWorkPlansWithWorkOrderAssociatedToVirtualStores(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(new List<WorkPlan>{});
        mocks.when(
                workPlanSelectorMock.selectWorkPlansWithVerifiedPOSIntegrationTypes(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(new List<WorkPlan>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workPlanSelectorMock);
        Application.SERVICE.setMock(IMxOrderCreationService.class, mxOrderCreationServiceMock);
        workPlanInstance.onAfterInsertHandleRelatedRecords();
        List<sObject> sObjectsToUpdate = new List<sObject>();
        sObjectsToUpdate.add(
            new WorkPlan(
                Id = parentWorkPlanId,
                Number_of_Workable_WorkSteps__c = NUMBER_OF_WORKABLE_WORKSTEPS_THREE
            )
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test updation of workable WorkSteps count on parent WorkPlan
     * when parent WorkPlan is changed in child WorkPlan.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnUpdateParentWorkPlanFieldOnChildWorkPlanThenUpdateTheCountOnParentWorkPlan() {
        Id oldParentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id newParentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Map<Id, WorkPlan> oldWorkPlans = new Map<Id, WorkPlan>();
        List<Aggregate> workableWorkStepsCountOnWorkPlan = new List<Aggregate>{
            new Aggregate()
                .put('parentId', oldParentWorkPlanId)
                .put('workableWorkSteps', NUMBER_OF_WORKABLE_WORKSTEPS_THREE),
            new Aggregate()
                .put('parentId', newParentWorkPlanId)
                .put('workableWorkSteps', NUMBER_OF_WORKABLE_WORKSTEPS_THREE)
        };
        WorkPlan oldParentWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, oldParentWorkPlanId)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_SIX
            )
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        WorkPlan newParentWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, newParentWorkPlanId)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_ZERO
            )
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        WorkPlan oldChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_THREE
            )
            .setField(WorkPlan.Parent_Work_Plan__c, oldParentWorkPlan.Id)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        oldWorkPlans.put(workPlanId, oldChildWorkPlan);
        WorkPlan updatedChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_THREE
            )
            .setField(WorkPlan.Parent_Work_Plan__c, newParentWorkPlan.Id)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkPlansSelector workPlanSelectorMock = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        IWorkPlans workPlanInstance = WorkPlans.newInstance(
            new List<WorkPlan>{ updatedChildWorkPlan }
        );
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlanSelectorMock.getSumOfNumberOfWorkableWorkStepsOnChildWorkPlanGroupedByParentWorkPlan(
                    new Set<Id>{ oldParentWorkPlanId, newParentWorkPlanId }
                )
            )
            .thenReturn(workableWorkStepsCountOnWorkPlan);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workPlanSelectorMock);
        workPlanInstance.onAfterUpdateHandleRelatedRecords(oldWorkPlans);
        List<sObject> sObjectsToUpdate = new List<sObject>();
        sObjectsToUpdate.add(
            new WorkPlan(
                Id = oldParentWorkPlanId,
                Number_of_Workable_WorkSteps__c = NUMBER_OF_WORKABLE_WORKSTEPS_THREE
            )
        );
        sObjectsToUpdate.add(
            new WorkPlan(
                Id = newParentWorkPlanId,
                Number_of_Workable_WorkSteps__c = NUMBER_OF_WORKABLE_WORKSTEPS_THREE
            )
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when the field 'Notes' parent work plans modified, it triggers
     * child work plans modification
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenParentWorkPlanFieldsChangedThenCreateNotifierEventsWithChildWorkPlans() {
        List<WorkPlanTemplate> workPlanTemplateRecords = new List<WorkPlanTemplate>();
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                TYPE_MARKETPLACE,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_STARTED;
        workPlanTemplateRecords.add(mockWorkPlanTemplate);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkOrderFakeInstance(parentAccount.Id, TYPE_MARKETPLACE)
        );
        Fake workOrderFakeInstance = (Fake) ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Account', storeAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                parentWorkOrder.Id,
                mockWorkPlanTemplate
            )
        );
        WorkPlan childWorkPlanOne = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanFakeInstanceWithParentWorkPlanId(
                parentWorkPlan.Id,
                childWorkOrder.Id,
                mockWorkPlanTemplate
            )
        );

        WorkPlan childWorkPlanTwo = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanFakeInstanceWithParentWorkPlanId(
                parentWorkPlan.Id,
                childWorkOrder.Id,
                mockWorkPlanTemplate
            )
        );
        List<WorkPlan> parentWorkPlanRecords = new List<WorkPlan>{ parentWorkPlan };
        List<Id> childWorkOrderIdsChunk1 = new List<Id>{ childWorkPlanOne.Id };
        List<Id> childWorkOrderIdsChunk2 = new List<Id>{ childWorkPlanTwo.Id };
        List<String> payloads = new List<String>{
            JSON.serialize(childWorkOrderIdsChunk1),
            JSON.serialize(childWorkOrderIdsChunk2)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsService notifierEventServiceMock = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        WorkPlansSelector mockWorkPlansSelector = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    CHILD_WORKPLAN_IDS_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CHILD_WORKPLAN_IDS_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectByParentWorkPlanIds(new Set<Id>{ parentWorkPlan.Id })
            )
            .thenReturn(new List<WorkPlan>{ childWorkPlanOne, childWorkPlanTwo });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventServiceMock);
        WorkPlans.newInstance(parentWorkPlanRecords)
            .collectParentWorkPlansWithUpdatedInformation(parentWorkPlanRecords);
        ((INotifierEventsService) mocks.verify(notifierEventServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{ EVENT_TOPIC_WORK_OBJECTS_SYNC => payloads }
            );
    }

    /**
     * @description To test updation of validated store count on Parent WorkPlan when
     * Activation Checklist Validation status is updated to 'Completed' on Child Work Plan.
     * Suppressed warnings since mock verify method is used.
     */
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    private static void testWhenActivationChecklistValidationCompletedOnChildWPThenUpdateNumberOfStoresValidated() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Map<Id, WorkPlan> oldWorkPlans = new Map<Id, WorkPlan>();
        List<sObject> sobjectsToUpdate = new List<sObject>();
        List<Aggregate> storeValidationsCountOnWorkPlan = new List<Aggregate>{
            new Aggregate()
                .put(PARENT_WORKPLAN_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkPlanId)
                .put(PARENT_WORKPLAN_AGGREGATE_QUERY_COUNT_ALIAS, NUMBER_OF_STORES_VALIDATED_SIX)
                .put(
                    PARENT_WORKPLAN_AGGREGATE_QUERY_VALIDATION_STATUS_ALIAS,
                    VALIDATION_STATUS_COMPLETED
                ),
            new Aggregate()
                .put(PARENT_WORKPLAN_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkPlanId)
                .put(PARENT_WORKPLAN_AGGREGATE_QUERY_COUNT_ALIAS, NUMBER_OF_STORES_IN_PROGRESS_ONE)
                .put(
                    PARENT_WORKPLAN_AGGREGATE_QUERY_VALIDATION_STATUS_ALIAS,
                    VALIDATION_STATUS_IN_PROGRESS
                )
        };
        WorkPlan parentWorkPlan = new WorkPlan(Id = parentWorkPlanId);
        WorkPlan oldChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Activation_Checklist_Validation__c, VALIDATION_STATUS_IN_PROGRESS)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        oldWorkPlans.put(workPlanId, oldChildWorkPlan);
        WorkPlan newChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Activation_Checklist_Validation__c, VALIDATION_STATUS_COMPLETED)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkPlansSelector workPlanSelectorMock = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        IWorkPlans workPlanInstance = WorkPlans.newInstance(new List<WorkPlan>{ newChildWorkPlan });
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlanSelectorMock.getNumberOfActivationChecklistValidationCompletedChildWorkPlansGroupedByParentWorkPlan(
                    new Set<Id>{ parentWorkPlanId }
                )
            )
            .thenReturn(storeValidationsCountOnWorkPlan);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workPlanSelectorMock);
        workPlanInstance.onAfterUpdateHandleRelatedRecords(oldWorkPlans);
        parentWorkPlan.Number_of_Stores_Validated__c = NUMBER_OF_STORES_VALIDATED_SIX;
        sobjectsToUpdate.addAll(new List<WorkPlan>{ parentWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test updation of validated store count, Last Validated Date
     * and Activation Checklist Validation fields on Parent WorkPlan when Activation Checklist
     * Validation status is updated to 'Completed' on all Child Work Plans.
     */
    @isTest
    private static void testWhenActivationChecklistValidationCompletedOnAllChildWPThenUpdateFieldsOnParentWP() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Map<Id, WorkPlan> oldWorkPlans = new Map<Id, WorkPlan>();
        List<Aggregate> storeValidationsCountOnWorkPlan = new List<Aggregate>{
            new Aggregate()
                .put(PARENT_WORKPLAN_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkPlanId)
                .put(PARENT_WORKPLAN_AGGREGATE_QUERY_COUNT_ALIAS, NUMBER_OF_STORES_VALIDATED_SIX)
                .put(
                    PARENT_WORKPLAN_AGGREGATE_QUERY_VALIDATION_STATUS_ALIAS,
                    VALIDATION_STATUS_COMPLETED
                )
        };
        WorkPlan oldChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Activation_Checklist_Validation__c, VALIDATION_STATUS_IN_PROGRESS)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        oldWorkPlans.put(workPlanId, oldChildWorkPlan);
        WorkPlan newChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Activation_Checklist_Validation__c, VALIDATION_STATUS_COMPLETED)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkPlansSelector workPlanSelectorMock = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        IWorkPlans workPlanInstance = WorkPlans.newInstance(new List<WorkPlan>{ newChildWorkPlan });
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlanSelectorMock.getNumberOfActivationChecklistValidationCompletedChildWorkPlansGroupedByParentWorkPlan(
                    new Set<Id>{ parentWorkPlanId }
                )
            )
            .thenReturn(storeValidationsCountOnWorkPlan);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workPlanSelectorMock);
        workPlanInstance.onAfterUpdateHandleRelatedRecords(oldWorkPlans);
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            List<SObject>.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty((List<SObject>) capturedInsertUOWArguments.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        List<WorkPlan> capturedArguments = (List<WorkPlan>) capturedInsertUOWArguments.getValue();
        DateTime updatedLastValidatedDateTime = capturedArguments[0].Last_Validation_Execution__c;
        Date updatedLastValidatedDate = Date.newInstance(
            updatedLastValidatedDateTime.year(),
            updatedLastValidatedDateTime.month(),
            updatedLastValidatedDateTime.day()
        );
        System.assertEquals(
            System.today(),
            updatedLastValidatedDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            VALIDATION_STATUS_COMPLETED,
            capturedArguments[0].Activation_Checklist_Validation__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            NUMBER_OF_STORES_VALIDATED_SIX,
            capturedArguments[0].Number_of_Stores_Validated__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkPlanId,
            capturedArguments[0].Id,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test updation of Activation Checklist Validation status to 'In Progress'
     * on all Child Work Plans when parent Work Plan's validation status is updated to 'In Progress'.
     * Suppressed warnings since mock verify method is used.
     */
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    private static void testWhenParentWPsActivationChecklistValidationInProgressThenUpdateChildWPs() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Map<Id, WorkPlan> oldWorkPlans = new Map<Id, WorkPlan>();
        WorkPlan oldParentWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, parentWorkPlanId)
            .setField(WorkPlan.Activation_Checklist_Validation__c, VALIDATION_STATUS_PENDING)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_ONE
            )
            .setField(WorkPlan.WorkOrderId, parentWorkOrderId)
            .toSObject();
        oldWorkPlans.put(parentWorkPlanId, oldParentWorkPlan);
        WorkPlan newParentWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, parentWorkPlanId)
            .setField(WorkPlan.Activation_Checklist_Validation__c, VALIDATION_STATUS_IN_PROGRESS)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_ONE
            )
            .setField(WorkPlan.WorkOrderId, parentWorkOrderId)
            .toSObject();
        WorkPlan childWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Activation_Checklist_Validation__c, VALIDATION_STATUS_PENDING)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkPlansSelector workPlanSelectorMock = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkPlans workPlanInstance = WorkPlans.newInstance(
            new List<WorkPlan>{ newParentWorkPlan }
        );
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(workPlanSelectorMock.selectByParentWorkPlanIds(new Set<Id>{ parentWorkPlanId }))
            .thenReturn(new List<WorkPlan>{ childWorkPlan });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workPlanSelectorMock);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        workPlanInstance.onAfterUpdateHandleRelatedRecords(oldWorkPlans);
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_IN_PROGRESS
            );
    }

    /**
     * @description To test when a WorkPlans are updated for Order Protocol Email
     * then Marketing Kit WorkOrder creation is initiated.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkPlansAreUpdatedThenInitiateMarketingKitWorkOrderCreation() {
        List<Id> workPlanIds = new List<Id>{ fflib_IDGenerator.generate(WorkPlan.SobjectType) };
        Fake accountFakeInstance = new Fake(Account.class)
            .setField(Account.Id, fflib_IDGenerator.generate(Account.SObjectType))
            .setField(Account.Segment__c, SMB_SEGMENT);

        Fake workOrderInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, fflib_IDGenerator.generate(WorkOrder.SobjectType))
            .setField(WorkOrder.Type__c, MARKETPLACE_WORK_ORDER_TYPE)
            .setField(WorkOrder.Order_Protocol__c, EMAIL_ORDER_PROTOCOL)
            .setParent('Account', accountFakeInstance)
            .setField(WorkOrder.Segment__c, SMB_SEGMENT);

        WorkPlan mockWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanIds[0])
            .setField(WorkPlan.Enable_Merchant_Orders_Creation__c, true)
            .setField(WorkPlan.Type__c, ONBOARDING_WORK_PLAN)
            .setField(WorkPlan.Status__c, WORK_PLAN_COMPLETE)
            .setParent('WorkOrder', workOrderInstance)
            .setField(WorkPlan.Work_Order_Type__c, EMAIL_ORDER_PROTOCOL)
            .setField(WorkPlan.Segment__c, SMB_SEGMENT)
            .setField(WorkPlan.Work_Order_Type__c, MARKETPLACE_WORK_ORDER_TYPE)
            .SetField(WorkPlan.Order_Protocol__c, EMAIL_ORDER_PROTOCOL)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrderCreationTriggerService workOrderCreationTriggerServiceMock = (IWorkOrderCreationTriggerService) mocks.mock(
            IWorkOrderCreationTriggerService.class
        );
        Application.SERVICE.setMock(
            IWorkOrderCreationTriggerService.class,
            workOrderCreationTriggerServiceMock
        );
        Test.startTest();
        WorkPlans.newInstance(new List<WorkPlan>{ mockWorkPlan })
            .evaluateAndInitiateMarketingKitWorkOrderCreation();
        Test.stopTest();
        ((IWorkOrderCreationTriggerService) mocks.verify(workOrderCreationTriggerServiceMock, 1))
            .initiateWorkOrderCreation(new Set<Id>{ workPlanIds[0] }, GENERIC_WORK_ORDER_CREATION);
    }

    /**
     * @description To test when a WorkPlans are updated for Order Protocol other than Email or POS
     * then Marketing Kit WorkOrder creation is not initiated.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkPlansAreUpdatedForOrderProtocolOtherThanEmailOrPOSThenDoNotInitiateMarketingKitWorkOrderCreation() {
        List<Id> workPlanIds = new List<Id>{ fflib_IDGenerator.generate(WorkPlan.SobjectType) };
        Fake accountFakeInstance = new Fake(Account.class)
            .setField(Account.Id, fflib_IDGenerator.generate(Account.SObjectType))
            .setField(Account.Segment__c, SMB_SEGMENT);

        Fake workOrderInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, fflib_IDGenerator.generate(WorkOrder.SobjectType))
            .setField(WorkOrder.Type__c, MARKETPLACE_WORK_ORDER_TYPE)
            .setField(WorkOrder.Order_Protocol__c, TABLET_AND_PRINTER_ORDER_PROTOCOL)
            .setParent('Account', accountFakeInstance)
            .setField(WorkOrder.Segment__c, SMB_SEGMENT);

        WorkPlan mockWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanIds[0])
            .setField(WorkPlan.Enable_Merchant_Orders_Creation__c, true)
            .setField(WorkPlan.Type__c, ONBOARDING_WORK_PLAN)
            .setField(WorkPlan.Status__c, WORK_PLAN_COMPLETE)
            .setParent('WorkOrder', workOrderInstance)
            .setField(WorkPlan.Segment__c, SMB_SEGMENT)
            .setField(WorkPlan.Work_Order_Type__c, MARKETPLACE_WORK_ORDER_TYPE)
            .SetField(WorkPlan.Order_Protocol__c, TABLET_AND_PRINTER_ORDER_PROTOCOL)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrderCreationTriggerService workOrderCreationTriggerServiceMock = (IWorkOrderCreationTriggerService) mocks.mock(
            IWorkOrderCreationTriggerService.class
        );
        Application.SERVICE.setMock(
            IWorkOrderCreationTriggerService.class,
            workOrderCreationTriggerServiceMock
        );
        Test.startTest();
        WorkPlans.newInstance(new List<WorkPlan>{ mockWorkPlan })
            .evaluateAndInitiateMarketingKitWorkOrderCreation();
        Test.stopTest();
        ((IWorkOrderCreationTriggerService) mocks.verify(workOrderCreationTriggerServiceMock, 0))
            .initiateWorkOrderCreation(new Set<Id>{ workPlanIds[0] }, GENERIC_WORK_ORDER_CREATION);
    }
    /**
     * @description To test when Non-Onboarding WorkPlans are updated then
     * Marketing Kit Work Order creation is not initiated.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNonOnboradingWorkPlansAreUpdatedThenDoNotInitiateMarketingKitWorkOrder() {
        List<Id> workPlanIds = new List<Id>{ fflib_IDGenerator.generate(WorkPlan.SobjectType) };
        Fake accountFakeInstance = new Fake(Account.class)
            .setField(Account.Id, fflib_IDGenerator.generate(Account.SObjectType))
            .setField(Account.Segment__c, SMB_SEGMENT);

        Fake workOrderInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, fflib_IDGenerator.generate(WorkOrder.SobjectType))
            .setField(WorkOrder.Type__c, MARKETPLACE_WORK_ORDER_TYPE)
            .setField(WorkOrder.Order_Protocol__c, EMAIL_ORDER_PROTOCOL)
            .setParent('Account', accountFakeInstance)
            .setField(WorkOrder.Segment__c, SMB_SEGMENT);

        WorkPlan mockWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanIds[0])
            .setField(WorkPlan.Enable_Merchant_Orders_Creation__c, true)
            .setField(WorkPlan.Type__c, STOREFRONT_WORK_PLAN)
            .setField(WorkPlan.Status__c, WORK_PLAN_COMPLETE)
            .setParent('WorkOrder', workOrderInstance)
            .setField(WorkPlan.Work_Order_Type__c, EMAIL_ORDER_PROTOCOL)
            .setField(WorkPlan.Segment__c, SMB_SEGMENT)
            .setField(WorkPlan.Work_Order_Type__c, MARKETPLACE_WORK_ORDER_TYPE)
            .SetField(WorkPlan.Order_Protocol__c, EMAIL_ORDER_PROTOCOL)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrderCreationTriggerService workOrderCreationTriggerServiceMock = (IWorkOrderCreationTriggerService) mocks.mock(
            IWorkOrderCreationTriggerService.class
        );
        Application.SERVICE.setMock(
            IWorkOrderCreationTriggerService.class,
            workOrderCreationTriggerServiceMock
        );
        Test.startTest();
        WorkPlans.newInstance(new List<WorkPlan>{ mockWorkPlan })
            .evaluateAndInitiateMarketingKitWorkOrderCreation();
        Test.stopTest();
        ((IWorkOrderCreationTriggerService) mocks.verify(workOrderCreationTriggerServiceMock, 0))
            .initiateWorkOrderCreation(new Set<Id>{ workPlanIds[0] }, GENERIC_WORK_ORDER_CREATION);
    }

    /**
     * @description To test Storefront Work Plans created for Work Orders created through
     * 'Place It For Me' process are updated with notes and assigned to queue.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPlaceItForMeStorefrontWorkPlanCreatedThenInitiateFieldUpdates() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SobjectType);

        WorkPlan mockWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Type__c, STOREFRONT_WORK_PLAN)
            .setField(
                WorkPlan.Parent_Work_Order_Creation_Source__c,
                WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPlaceItForMeIntegrationService placeItForMeIntegrationServiceMock = (IPlaceItForMeIntegrationService) mocks.mock(
            IPlaceItForMeIntegrationService.class
        );
        Application.SERVICE.setMock(
            IPlaceItForMeIntegrationService.class,
            placeItForMeIntegrationServiceMock
        );
        Test.startTest();
        WorkPlans.newInstance(new List<WorkPlan>{ mockWorkPlan })
            .onAfterInsertHandleRelatedRecords();
        Test.stopTest();
        ((IPlaceItForMeIntegrationService) mocks.verify(placeItForMeIntegrationServiceMock, 1))
            .updatePlaceItForMeStorefrontWorkPlans(new List<WorkPlan>{ mockWorkPlan });
    }

    /**
     * @description To test updation of Is Virtual Store flag on parent Workplan when child Workplan
     * is assocaited to Store of type Virtual.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenVirtualStoreChildWorkPlanCreatedThenUpdateIsVirtualStoreFlagOnParentWorkPlan() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<sObject> sobjectsToUpdate = new List<sObject>();
        List<Aggregate> workableWorkStepsCountOnWorkPlan = new List<Aggregate>{
            new Aggregate()
                .put('parentId', parentWorkPlanId)
                .put('workableWorkSteps', NUMBER_OF_WORKABLE_WORKSTEPS_THREE)
        };
        WorkPlan newChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_THREE
            )
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.Parent_Work_Plan__r.Is_Virtual_Store__c, false)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .setField(WorkPlan.WorkOrder.Account.Segment__c, SMB_SEGMENT)
            .setField(WorkPlan.Segment__c, SMB_SEGMENT)
            .setParent(
                       'WorkOrder',
                        new Fake(Account.class)
                		.setField(WorkOrder.Id, workOrderId)
                        .setField(WorkOrder.Account.Segment__c, SMB_SEGMENT)
                		.setField(WorkOrder.Account_Type__c, ACCOUNT_TYPE_VIRTUAL)
                      )
            .setParent(
                       'Parent_Work_Plan__r',
                        new Fake(WorkPlan.class)
                		.setField(WorkPlan.Id, parentWorkPlanId)
                        .setField(WorkPlan.Is_Virtual_Store__c, false)
                      )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector workPlanSelectorMock = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IWorkPlans workPlanInstance = WorkPlans.newInstance(new List<WorkPlan>{ newChildWorkPlan });
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlanSelectorMock.selectWorkPlansWithWorkOrderAssociatedToVirtualStores(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(new List<WorkPlan>{newChildWorkPlan});
        mocks.when(
                workPlanSelectorMock.selectWorkPlansWithVerifiedPOSIntegrationTypes(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(new List<WorkPlan>{});
         mocks.when(
                workPlanSelectorMock.getSumOfNumberOfWorkableWorkStepsOnChildWorkPlanGroupedByParentWorkPlan(
                    new Set<Id>{ parentWorkPlanId }
                )
            )
            .thenReturn(workableWorkStepsCountOnWorkPlan);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workPlanSelectorMock);
        workPlanInstance.onAfterInsertHandleRelatedRecords();
        WorkPlan parentWorkPlanToUpdate = new WorkPlan(Id = parentWorkPlanId,Is_Virtual_Store__c = true );
        sobjectsToUpdate.addAll(new List<WorkPlan>{ parentWorkPlanToUpdate });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(sobjectsToUpdate);
    }
     /**
     * @description To test updation of Is Virtual Store flag on parent Workplan when child Workplan
     * is not assocaited to Store of type Virtual.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNonVirtualStoreChildWorkPlanCreatedThenDoNotUpdateIsVirtualStoreFlagOnParentWorkPlan() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<Aggregate> workableWorkStepsCountOnWorkPlan = new List<Aggregate>{
            new Aggregate()
                .put('parentId', parentWorkPlanId)
                .put('workableWorkSteps', NUMBER_OF_WORKABLE_WORKSTEPS_THREE)
        };
        WorkPlan parentWorkPlan = new WorkPlan(Id = parentWorkPlanId,Is_Virtual_Store__c = false );
        WorkPlan newChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(
                WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c,
                NUMBER_OF_WORKABLE_WORKSTEPS_THREE
            )
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.Parent_Work_Plan__r.Is_Virtual_Store__c, false)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .setField(WorkPlan.WorkOrder.Account.Segment__c, SMB_SEGMENT)
            .setField(WorkPlan.Segment__c, SMB_SEGMENT)
            .setParent(
                       'WorkOrder',
                        new Fake(Account.class)
                		.setField(WorkOrder.Id, workOrderId)
                        .setField(WorkOrder.Account.Segment__c, SMB_SEGMENT)
                		.setField(WorkOrder.Account_Type__c, ACCOUNT_TYPE_FOOD_TRUCK)
                      )
            .setParent(
                       'Parent_Work_Plan__r',
                        new Fake(WorkPlan.class)
                		.setField(WorkPlan.Id, parentWorkPlanId)
                        .setField(WorkPlan.Is_Virtual_Store__c, false)
                      )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector workPlanSelectorMock = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IWorkPlans workPlanInstance = WorkPlans.newInstance(new List<WorkPlan>{ newChildWorkPlan });
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlanSelectorMock.selectWorkPlansWithWorkOrderAssociatedToVirtualStores(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(new List<WorkPlan>{});
        mocks.when(
                workPlanSelectorMock.selectWorkPlansWithVerifiedPOSIntegrationTypes(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(new List<WorkPlan>{});
         mocks.when(
                workPlanSelectorMock.getSumOfNumberOfWorkableWorkStepsOnChildWorkPlanGroupedByParentWorkPlan(
                    new Set<Id>{ parentWorkPlanId }
                )
            )
            .thenReturn(workableWorkStepsCountOnWorkPlan);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workPlanSelectorMock);
        workPlanInstance.onAfterInsertHandleRelatedRecords();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        system.assertEquals(parentWorkPlan.Is_Virtual_Store__c, false,FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE);
    }


    /**
     * @description To test if exception is thrown on Photoshoot WorkPlan Insertion.
     */
    @isTest
    private static void testWhenPhotoShootWorkPlanInsertedThenExceptionThrown() {
        WorkPlanTemplate relatedWorkPlanTemplate = new WorkPlanTemplate(
            Id = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType),
            Name = WORK_PLAN_TEMPLATE_NAME
        );
        List<WorkPlan> mockWorkPlans = new List<WorkPlan>{
            (WorkPlan) new Fake(WorkPlan.class)
                .setField(WorkPlan.Id, fflib_IDGenerator.generate(WorkPlan.SObjectType))
                .setField(WorkPlan.Enable_Merchant_Orders_Creation__c, true)
                .setField(WorkPlan.Name, WORK_PLAN_NAME)
                .setField(WorkPlan.Status__c, NOT_STARTED)
                .setField(WorkPlan.Type__c, WORK_PLAN_TYPE_VENDOR_PHOTOSHOOT)
                .setField(WorkPlan.WorkOrderId, fflib_IDGenerator.generate(WorkOrder.SObjectType))
                .setField(WorkPlan.Work_Plan_Template__c, relatedWorkPlanTemplate.Id)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxOrderCreationService mxOrderServiceMock = (IMxOrderCreationService) mocks.mock(
            IMxOrderCreationService.class
        );
        Application.SERVICE.setMock(IMxOrderCreationService.class, mxOrderServiceMock);
        try {
            WorkPlans.newInstance(mockWorkPlans).onAfterInsertHandleRelatedRecords();
          } catch (Exception mockException) {
            System.assertNotEquals(
                null,
                mockException.getMessage(),
                ASSERT_MESSAGE_ERROR_MESSAGE_MISMATCH
            );
          }
        ((IMxOrderCreationService) mocks.verify(mxOrderServiceMock, 1))
            .generatePhotoShootMxOrder(mockWorkPlans);
    }

    /**
     * @description To test if exception is thrown on Marketing Kit WorkPlan Insertion.
     */
    @isTest
    private static void testWhenMarketingKitWorkPlanInsertedThenExceptionThrown() {
        WorkPlanTemplate relatedWorkPlanTemplate = new WorkPlanTemplate(
            Id = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType),
            Name = WORK_PLAN_TEMPLATE_NAME
        );
        List<WorkPlan> mockWorkPlans = new List<WorkPlan>{
            (WorkPlan) new Fake(WorkPlan.class)
                .setField(WorkPlan.Id, fflib_IDGenerator.generate(WorkPlan.SObjectType))
                .setField(WorkPlan.Enable_Merchant_Orders_Creation__c, true)
                .setField(WorkPlan.Name, WORK_PLAN_NAME)
                .setField(WorkPlan.Status__c, NOT_STARTED)
                .setField(WorkPlan.Type__c, WORK_PLAN_TYPE_MARKETING_KIT)
                .setField(WorkPlan.WorkOrderId, fflib_IDGenerator.generate(WorkOrder.SObjectType))
                .setField(WorkPlan.Work_Plan_Template__c, relatedWorkPlanTemplate.Id)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxOrderCreationService mxOrderServiceMock = (IMxOrderCreationService) mocks.mock(
            IMxOrderCreationService.class
        );
        Application.SERVICE.setMock(IMxOrderCreationService.class, mxOrderServiceMock);
        try {
            WorkPlans.newInstance(mockWorkPlans).onAfterInsertHandleRelatedRecords();
          } catch (Exception mockException) {
            System.assertNotEquals(
                null,
                mockException.getMessage(),
                ASSERT_MESSAGE_ERROR_MESSAGE_MISMATCH
            );
          }
        ((IMxOrderCreationService) mocks.verify(mxOrderServiceMock, 1))
            .generateMarketingKitMxOrders(mockWorkPlans);
    }
}