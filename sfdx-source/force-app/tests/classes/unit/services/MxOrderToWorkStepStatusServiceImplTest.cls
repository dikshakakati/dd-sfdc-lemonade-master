/**
 * @author Deloitte
 * @date 05/10/2024
 * @description Test class for MxOrderToWorkStepStatusUpdateServiceImpl class.
 */
@isTest(SeeAllData=false)
private class MxOrderToWorkStepStatusServiceImplTest {
    private static final String ASSERT_MESSAGE = 'Unexpected Result: Mismatch in Mx Order Status';
    private static final String COMPLETED = 'Completed';
    private static final String DELIVERED = 'Delivered';
    private static final String DELIVER_RETURN_LABEL = 'Deliver Return Label';
    private static final String DELIVER_TABLET = 'Deliver Tablet';
    private static final String DRAFT = 'DRAFT';
    private static final String ESCALATED = 'Escalated';
    private static final String IN_PROGRESS = 'In Progress';
    private static final String INVALID = 'Invalid';
    private static final String ORDER_CREATED = 'Order Created';
    private static final String PHOTOSHOOT = 'Photoshoot';
    private static final String PROCESS_TYPE_WORKSTEP_STATUS_UPDATE = 'Mx Order Status to WorkStep Status';
    private static final String VENDOR_PHOTOSHOOT = 'Vendor Photoshoot';
    private static final String RETURN_TYPE = 'Return';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String SHIPPED = 'Shipped';
    private static final String SHIPMENT_STATUS_DESCRIPTION = 'Return Label Shipped';
    private static final String TABLET_TYPE = 'Tablet';

    /**
     * @description To test when Mx Order Status Updated then the corresponding Tablet
     * Work step Status is Updated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxOrderStatusUpdatedThenTabletWorkStepStatusUpdated() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        WorkStep workStepRecord = (WorkStep) new Fake(WorkStep.class)
            .setField(workStep.Id, workStepId)
            .setfield(workStep.Name, DELIVER_TABLET)
            .setfield(workStep.Status__c, STATUS_NOT_STARTED)
            .setField(workStep.Type__c, DELIVER_TABLET)
            .toSObject();
        MX_Order__c mxOrder = (MX_Order__c) new Fake(MX_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Work_Step__c, workStepId)
            .setField(MX_Order__c.Status__c, INVALID)
            .setParent(
                'Work_Step__r',
                new Fake(WorkStep.class)
                    .setField(WorkStep.Id, workStepId)
                    .setField(WorkStep.Type__c, DELIVER_TABLET)
                    .setField(WorkStep.Name, DELIVER_TABLET)
                    .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            )
            .toSObject();
        List<Cross_Object_Status_Mapping__mdt> customMetadataMocks = new List<Cross_Object_Status_Mapping__mdt>{
            new Cross_Object_Status_Mapping__mdt(
                MasterLabel = 'Tablet Order Status Invalid',
                DeveloperName = 'Tablet_Order_Status_Invalid',
                Source_Status__c = INVALID,
                Target_Status__c = ESCALATED,
                Type__c = TABLET_TYPE,
                Process__c = PROCESS_TYPE_WORKSTEP_STATUS_UPDATE,
                Active__c = true
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        ICrossObjectStatusMappingsSelector mockSelector = (ICrossObjectStatusMappingsSelector) mocks.mock(
            ICrossObjectStatusMappingsSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockSelector.SObjectType())
            .thenReturn(Cross_Object_Status_Mapping__mdt.SObjectType);
        mocks.when(
                mockSelector.selectActiveStatusMappingsByProcessName(
                    PROCESS_TYPE_WORKSTEP_STATUS_UPDATE
                )
            )
            .thenReturn(customMetadataMocks);
        mocks.when(mockWorkStepsSelector.SObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(new List<WorkStep>{ workStepRecord });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        MxOrderToWorkStepStatusUpdateService.updateWorkStepStatus(new List<MX_Order__c>{ mxOrder });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => ESCALATED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Mx Order Status Updated then the corresponding Return
     * Work Status is Updated
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxOrderStatusUpdatedThenReturnWorkStepStatusUpdated() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        WorkStep workStepRecord = (WorkStep) new Fake(WorkStep.class)
            .setField(workStep.Id, workStepId)
            .setfield(workStep.Name, DELIVER_RETURN_LABEL)
            .setfield(workStep.Status__c, STATUS_NOT_STARTED)
            .setField(workStep.Type__c, DELIVER_RETURN_LABEL)
            .toSObject();
        MX_Order__c mxOrder = (MX_Order__c) new Fake(MX_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Work_Step__c, workStepId)
            .setField(MX_Order__c.Status__c, ORDER_CREATED)
            .setParent(
                'Work_Step__r',
                new Fake(WorkStep.class)
                    .setField(WorkStep.Id, workStepId)
                    .setField(WorkStep.Type__c, DELIVER_TABLET)
                    .setField(WorkStep.Name, DELIVER_TABLET)
                    .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            )
            .toSObject();
        List<Cross_Object_Status_Mapping__mdt> customMetadataMocks = new List<Cross_Object_Status_Mapping__mdt>{
            new Cross_Object_Status_Mapping__mdt(
                MasterLabel = 'Return Order Status Order Created',
                DeveloperName = 'Return_Order_Status_Order_Created',
                Source_Status__c = ORDER_CREATED,
                Target_Status__c = IN_PROGRESS,
                Type__c = RETURN_TYPE,
                Process__c = PROCESS_TYPE_WORKSTEP_STATUS_UPDATE,
                Active__c = true
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        ICrossObjectStatusMappingsSelector mockSelector = (ICrossObjectStatusMappingsSelector) mocks.mock(
            ICrossObjectStatusMappingsSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockSelector.SObjectType())
            .thenReturn(Cross_Object_Status_Mapping__mdt.SObjectType);
        mocks.when(
                mockSelector.selectActiveStatusMappingsByProcessName(
                    PROCESS_TYPE_WORKSTEP_STATUS_UPDATE
                )
            )
            .thenReturn(customMetadataMocks);
        mocks.when(mockWorkStepsSelector.SObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(new List<WorkStep>{ workStepRecord });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        MxOrderToWorkStepStatusUpdateService.updateWorkStepStatus(new List<MX_Order__c>{ mxOrder });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => IN_PROGRESS
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Mx Order 'Shipment Status Description' is updated then the corresponding
     * Work Step 'Status Reason Details' is updated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxOrderShipmentStatusDescriptionUpdatedThenWorkStepStatusReasonDetailsUpdated() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        WorkStep workStepRecord = (WorkStep) new Fake(WorkStep.class)
            .setField(workStep.Id, workStepId)
            .setfield(workStep.Name, DELIVER_RETURN_LABEL)
            .setfield(workStep.Status__c, STATUS_NOT_STARTED)
            .setField(workStep.Type__c, DELIVER_RETURN_LABEL)
            .toSObject();
        MX_Order__c mxOrder = (MX_Order__c) new Fake(MX_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Work_Step__c, workStepId)
            .setField(MX_Order__c.Shipment_Status__c, DELIVERED)
            .setField(MX_Order__c.Shipment_Status_Description__c, SHIPMENT_STATUS_DESCRIPTION)
            .setParent(
                'Work_Step__r',
                new Fake(WorkStep.class)
                    .setField(WorkStep.Id, workStepId)
                    .setField(WorkStep.Type__c, DELIVER_RETURN_LABEL)
                    .setField(WorkStep.Name, DELIVER_RETURN_LABEL)
                    .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.SObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(new List<WorkStep>{ workStepRecord });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        MxOrderToWorkStepStatusUpdateService.updateWorkStepStatus(new List<MX_Order__c>{ mxOrder });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status_Reason_Details__c => SHIPMENT_STATUS_DESCRIPTION
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description To test when Mx Order Status Updated then the corresponding Photoshoot
     * Work Status is Updated @JIRA LEM-14542
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxOrderStatusUpdatedThenUpdatePhotoshootWorkStepStatus() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        WorkStep workStepRecord = (WorkStep) new Fake(WorkStep.class)
            .setField(workStep.Id, workStepId)
            .setfield(workStep.Name, VENDOR_PHOTOSHOOT)
            .setfield(workStep.Status__c, STATUS_NOT_STARTED)
            .setField(workStep.Type__c, VENDOR_PHOTOSHOOT)
            .toSObject();
        MX_Order__c mxOrder = (MX_Order__c) new Fake(MX_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Work_Step__c, workStepId)
            .setField(MX_Order__c.Status__c, DRAFT)
            .setParent(
                'Work_Step__r',
                new Fake(WorkStep.class)
                    .setField(WorkStep.Id, workStepId)
                    .setField(WorkStep.Type__c, VENDOR_PHOTOSHOOT)
                    .setField(WorkStep.Name, VENDOR_PHOTOSHOOT)
                    .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            )
            .toSObject();
        List<Cross_Object_Status_Mapping__mdt> customMetadataMocks = new List<Cross_Object_Status_Mapping__mdt>{
            new Cross_Object_Status_Mapping__mdt(
                MasterLabel = 'Photoshoot Order Status Draft',
                DeveloperName = 'Photoshoot_Order_Status_Draft',
                Source_Status__c = DRAFT,
                Target_Status__c = STATUS_NOT_STARTED,
                Type__c = PHOTOSHOOT,
                Process__c = PROCESS_TYPE_WORKSTEP_STATUS_UPDATE,
                Active__c = true
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        ICrossObjectStatusMappingsSelector mockSelector = (ICrossObjectStatusMappingsSelector) mocks.mock(
            ICrossObjectStatusMappingsSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockSelector.SObjectType())
            .thenReturn(Cross_Object_Status_Mapping__mdt.SObjectType);
        mocks.when(
                mockSelector.selectActiveStatusMappingsByProcessName(
                    PROCESS_TYPE_WORKSTEP_STATUS_UPDATE
                )
            )
            .thenReturn(customMetadataMocks);
        mocks.when(mockWorkStepsSelector.SObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(new List<WorkStep>{ workStepRecord });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        MxOrderToWorkStepStatusUpdateService.updateWorkStepStatus(new List<MX_Order__c>{ mxOrder });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => STATUS_NOT_STARTED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}