/**
 * @author atg
 * @date 08/08/2022
 * @description Test class for ReattemptProvisioningServiceImpl class.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
@isTest(seeAllData=false)
private class ReattemptProvisioningServiceImplTest {
    public static final String STATUS_SUCCESS = 'Success';
    public static final String STATUS_COO_SUCCESS = 'COO Success';
    public static final String STATUS_FAILURE = 'Failure';
    private static final String STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String STATUS_READY_FOR_COO_INTEGRATION = 'Ready for COO Integration';

    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORKPLAN_NAME_ONBOARDING = 'Onboarding';
    private static final String EXTERNAL_DB_SOURCE_DRIVE = 'DriveDb';
    private static final String DEFAULT_TYPE_COO_GRAVEYARD = 'COO Graveyard';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    //private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final string XREF_EXTERNAL_ID_SOURCE_MDS = 'MDS';
    public static final String PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC = 'Automatic';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String FAILURE_INTEGRATION_MESSAGE = 'A Business Reference must be tied to the Xref before reattempting provisioning.';
    /**
     * @description To test reattemptProvisioning method from
     */
    @isTest
    private static void testWhenWorkPlanIdReceivedThenReattemptProvisioning() {
        Id businessReferenceId1 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id businessReferenceId2 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Fake busRefFailure = new Fake(Business_Reference__c.class)
        .setField(Business_Reference__c.Id, businessReferenceId1)
        .setField(Business_Reference__c.Integration_Status__c, STATUS_FAILURE);

        Fake busRefSuccess = new Fake(Business_Reference__c.class)
        .setField(Business_Reference__c.Id, businessReferenceId2)
        .setField(Business_Reference__c.Integration_Status__c, STATUS_SUCCESS);

        Fake xRef = new Fake(Xref__c.class)
        .setField(Xref__c.Id, xrefId)
        .setField(Xref__c.Integration_Status__c, STATUS_FAILURE)
        .setField(Xref__c.Business_Reference__c, businessReferenceId2)
        .setParent('Business_Reference__r', busRefSuccess);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            businessAccount.Id,
            WORKORDER_TYPE_MARKETPLACE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake parentWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
                parentWorkPlanOnboardingFakeInstance
            );

        Fake workPlanBusinessReferenceFake = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING)
            .setField(WorkPlan.Business_Reference__c, businessReferenceId1)
            .setParent('Business_Reference__r', busRefFailure);

        WorkPlan workPlanBusRefData = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
                workPlanBusinessReferenceFake
            );
        Fake workPlanXrefDataFake = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING)
            .setField(WorkPlan.Xref__c, xrefId)
            .setParent('Xref__r', xRef);

        WorkPlan workPlanXrefData = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
                workPlanXrefDataFake
            );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        WorkPlansSelector mockWorkPlansSelector = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectIntegrationInfoForWorkPlansByParentWorkPlanId( parentWorkPlan.Id)
            )
            .thenReturn(
                new List<WorkPlan>{ workPlanBusRefData, workPlanXrefData }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ReattemptProvisioningService.reattemptProvisioning(parentWorkPlan.Id);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Make sure the Business_Reference__c with correct parameters are updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId1,
                        Business_Reference__c.Integration_Status__c => STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
        //Make sure the Xref__c with correct parameters are updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }
    /**
     * @description To test reattemptProvisioning method from COO
     */
    @isTest
    private static void testWhenWorkPlanIdReceivedThenReattemptCOOProvisioning() {
        Id businessReferenceId1 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Fake busRefCOO = new Fake(Business_Reference__c.class)
        .setField(Business_Reference__c.Id, businessReferenceId1)
        .setField(Business_Reference__c.Integration_Status__c, STATUS_COO_SUCCESS)
        .setField(Business_Reference__c.Default_Type__c, DEFAULT_TYPE_COO_GRAVEYARD);

        Fake xRef = new Fake(Xref__c.class)
        .setField(Xref__c.Id, xrefId)
        .setField(Xref__c.Integration_Status__c, STATUS_FAILURE)
        .setField(Xref__c.Business_Reference__c, businessReferenceId1)
        .setParent('Business_Reference__r', busRefCOO);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            businessAccount.Id,
            WORKORDER_TYPE_MARKETPLACE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake parentWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
                parentWorkPlanOnboardingFakeInstance
            );

        Fake workPlanXrefDataFake = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING)
            .setField(WorkPlan.Xref__c, xrefId)
            .setParent('Xref__r', xRef);

        WorkPlan workPlanXrefData = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
                workPlanXrefDataFake
            );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        WorkPlansSelector mockWorkPlansSelector = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectIntegrationInfoForWorkPlansByParentWorkPlanId( parentWorkPlan.Id)
            )
            .thenReturn(
                new List<WorkPlan>{ workPlanXrefData }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ReattemptProvisioningService.reattemptProvisioning(parentWorkPlan.Id);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Make sure the Xref__c with correct parameters are updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => STATUS_READY_FOR_COO_INTEGRATION
                    }
                )
            );
    }

    /**
     * @description It is used to check when the work plan Ids are passed then Xref
     * with “Integration Status” as ‘Waiting for Business’and Business Reference with
     * “Integration Status” as ‘Success’ re-attempted for provisioning.
     */
    @isTest
    private static void testWhenWorkPlanIdReceivedThenXrefWithWaitingForBusinessAndBizRefWithSuccessIntegrationStatusReattemptedForCOOProvisioning() {

        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id externalBusinessId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id storeAccountID = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
               storeAccountID,
               WORKORDER_TYPE_MARKETPLACE,
               parentWorkOrder.Id
           );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
               childWorkOrderFakeInstance);

        Fake businessReference = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Id, externalBusinessId)
            .setField(Business_Reference__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
            .setField(Business_Reference__c.Integration_Status__c, STATUS_SUCCESS);

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountID)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Integration_Status__c, STATUS_WAITING_FOR_BUSINESS)
            .setField(Xref__c.Business_Reference__c, externalBusinessId)
            .setParent('Business_Reference__r', businessReference)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        mocks.startStubbing();

        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);

        mocks.when(
            mockWorkOrdersSelector.selectById(new Set<Id>{parentWorkOrderId}))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
            mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });

        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectActiveFailedXrefsBySalesforceAccountName(new Set<Id>{ storeAccountID }))
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ReattemptProvisioningService.reattemptProvisioningOnWorkOrder(parentWorkOrderId);
        Test.stopTest();

         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Make sure the Business_Reference__c is not updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => externalBusinessId,
                        Business_Reference__c.Integration_Status__c => STATUS_SUCCESS
                    }
                )
            );
        //Make sure the Xref__c is updated to Ready For Integration
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }

     /**
     * @description To test reattemptProvisioning method from
     */
   @isTest
    private static void testWhenDriveWorkPlanIdReceivedThenReattemptProvisioning() {

        Id businessReferenceId1 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id businessReferenceId2 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Fake busRefFailure = new Fake(Business_Reference__c.class)
        .setField(Business_Reference__c.Id, businessReferenceId1)
        .setField(Business_Reference__c.External_Id_Source__c, EXTERNAL_DB_SOURCE_DRIVE)
        .setField(Business_Reference__c.Last_Completed_Step__c, null)
        .setField(Business_Reference__c.Integration_Status__c, STATUS_FAILURE);

        Fake busRefSuccess = new Fake(Business_Reference__c.class)
        .setField(Business_Reference__c.Id, businessReferenceId2)
        .setField(Business_Reference__c.Integration_Status__c, STATUS_SUCCESS);

        Fake xRef = new Fake(Xref__c.class)
        .setField(Xref__c.Id, xrefId)
        .setField(Xref__c.Integration_Status__c, STATUS_FAILURE)
        .setField(Xref__c.External_ID_Source__c,EXTERNAL_DB_SOURCE_DRIVE)
        .setField(Xref__c.Business_Reference__c, businessReferenceId2)
        .setParent('Business_Reference__r', busRefSuccess);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            businessAccount.Id,
            WORKORDER_TYPE_MARKETPLACE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake parentWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
                parentWorkPlanOnboardingFakeInstance
            );

        Fake workPlanBusinessReferenceFake = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING)
            .setField(WorkPlan.Business_Reference__c, businessReferenceId1)
            .setParent('Business_Reference__r', busRefFailure);

        WorkPlan workPlanBusRefData = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
                workPlanBusinessReferenceFake
            );
        Fake workPlanXrefDataFake = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING)
            .setField(WorkPlan.Xref__c, xrefId)
            .setParent('Xref__r', xRef);

        WorkPlan workPlanXrefData = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
                workPlanXrefDataFake
            );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        WorkPlansSelector mockWorkPlansSelector = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectIntegrationInfoForWorkPlansByParentWorkPlanId( parentWorkPlan.Id)
            )
            .thenReturn(
                new List<WorkPlan>{ workPlanBusRefData, workPlanXrefData }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ReattemptProvisioningService.reattemptProvisioning(parentWorkPlan.Id);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Make sure the Business_Reference__c with correct parameters are updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId1,
                        Business_Reference__c.Integration_Status__c => STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
        //Make sure the Xref__c with correct parameters are updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }

    /**
     * @description To test reattemptProvisioning drive method when nothing should be updated
     */
    @isTest
    private static void testWhenDriveWorkPlanIdReceivedThenDoNotReattemptProvisioning() {
        Id businessReferenceId1 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Fake busRefSuccess = new Fake(Business_Reference__c.class)
        .setField(Business_Reference__c.Id, businessReferenceId1)
        .setField(Business_Reference__c.External_Id_Source__c, EXTERNAL_DB_SOURCE_DRIVE)
        .setField(Business_Reference__c.Last_Completed_Step__c, null)
        .setField(Business_Reference__c.Integration_Status__c, STATUS_SUCCESS);

        Fake xRef = new Fake(Xref__c.class)
        .setField(Xref__c.Id, xrefId)
        .setField(Xref__c.Integration_Status__c, STATUS_SUCCESS)
        .setField(Xref__c.External_ID_Source__c,EXTERNAL_DB_SOURCE_DRIVE)
        .setParent('Business_Reference__r', busRefSuccess);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            businessAccount.Id,
            WORKORDER_TYPE_MARKETPLACE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake parentWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
                parentWorkPlanOnboardingFakeInstance
            );

        Fake workPlanBusinessReferenceFake = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING)
            .setField(WorkPlan.Business_Reference__c, businessReferenceId1)
            .setParent('Business_Reference__r', busRefSuccess);

        WorkPlan workPlanBusRefData = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
                workPlanBusinessReferenceFake
            );
        Fake workPlanXrefDataFake = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING)
            .setField(WorkPlan.Xref__c, xrefId)
            .setParent('Xref__r', xRef);

        WorkPlan workPlanXrefData = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
                workPlanXrefDataFake
            );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        WorkPlansSelector mockWorkPlansSelector = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectIntegrationInfoForWorkPlansByParentWorkPlanId( parentWorkPlan.Id)
            )
            .thenReturn(
                new List<WorkPlan>{ workPlanBusRefData, workPlanXrefData }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ReattemptProvisioningService.reattemptProvisioning(parentWorkPlan.Id);
        Test.stopTest();
		//nothing should be updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId1,
                        Business_Reference__c.Integration_Status__c => STATUS_SUCCESS
                    }
                )
            );
        //Make sure the Xref__c with correct parameters are updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => STATUS_SUCCESS
                    }
                )
            );

    }

     /** Non Drive
     * @description To test reattemptProvisioning method from BIZRef : Success, XRef: Failure
     * no update on BizRef, xref updated to Success
     */
    @isTest
    private static void testWhenWorkOrderIdReceivedNonDriveBizRefSuccessXrefFailureThenReattemptProvisioning() {

        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id externalBusinessId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id storeAccountID = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
               storeAccountID,
               WORKORDER_TYPE_MARKETPLACE,
               parentWorkOrder.Id
           );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
               childWorkOrderFakeInstance);

        Fake businessReference = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Id, externalBusinessId)
            .setField(Business_Reference__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
            .setField(Business_Reference__c.Integration_Status__c, STATUS_SUCCESS);

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountID)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Integration_Status__c, STATUS_FAILURE)
            .setField(Xref__c.Business_Reference__c, externalBusinessId)
            .setParent('Business_Reference__r', businessReference)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        mocks.startStubbing();

        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);

        mocks.when(
            mockWorkOrdersSelector.selectById(new Set<Id>{parentWorkOrderId}))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
            mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });

        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectActiveFailedXrefsBySalesforceAccountName(new Set<Id>{ storeAccountID }))
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ReattemptProvisioningService.reattemptProvisioningOnWorkOrder(parentWorkOrderId);
        Test.stopTest();

         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Make sure the Business_Reference__c is not updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => externalBusinessId,
                        Business_Reference__c.Integration_Status__c => STATUS_SUCCESS
                    }
                )
            );
        //Make sure the Xref__c is updated to Ready For Integration
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }



    /** Non Drive
     * @description To test reattemptProvisioning method from BIZRef : Failure, XRef: Failure
     * update on BizRef ready for Integration, xref updated to Waiting for Business
     */
    @isTest
    private static void testWhenWorkOrderIdReceivedNonDriveBizRefSFailureXrefFailureThenReattemptProvisioning() {

        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id externalBusinessId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id storeAccountID = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
               storeAccountID,
               WORKORDER_TYPE_MARKETPLACE,
               parentWorkOrder.Id
           );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
               childWorkOrderFakeInstance);

        Fake businessReference = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Id, externalBusinessId)
            .setField(Business_Reference__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
            .setField(Business_Reference__c.Integration_Status__c, STATUS_FAILURE);

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountID)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Integration_Status__c, STATUS_FAILURE)
            .setField(Xref__c.Business_Reference__c, externalBusinessId)
            .setParent('Business_Reference__r', businessReference)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        mocks.startStubbing();

        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);

        mocks.when(
            mockWorkOrdersSelector.selectById(new Set<Id>{parentWorkOrderId}))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
            mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });

        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectActiveFailedXrefsBySalesforceAccountName(new Set<Id>{ storeAccountID }))
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ReattemptProvisioningService.reattemptProvisioningOnWorkOrder(parentWorkOrderId);
        Test.stopTest();

         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Make sure the Business_Reference__c is not updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => externalBusinessId,
                        Business_Reference__c.Integration_Status__c => STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
        //Make sure the Xref__c is updated to Ready For Integration
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => STATUS_WAITING_FOR_BUSINESS
                    }
                )
            );
    }

    /**
     * @description It is used to check when the work plans are passed then Xref
     * with “Integration Status” as ‘Waiting for Business’and Business Reference
     * with “Integration Status” as ‘Success’ re-attempted for provisioning.
     */
    @isTest
    private static void testWhenWorkPlansReceivedThenXrefWithWaitingForBusinessAndBizRefWithSuccessIntegrationStatusReattemptedForCOOProvisioning() {
        Id businessReferenceId1 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Fake busRefCOO = new Fake(Business_Reference__c.class)
        .setField(Business_Reference__c.Id, businessReferenceId1)
        .setField(Business_Reference__c.Integration_Status__c, STATUS_SUCCESS)
        .setField(Business_Reference__c.Default_Type__c, DEFAULT_TYPE_COO_GRAVEYARD);

        Fake xRef = new Fake(Xref__c.class)
        .setField(Xref__c.Id, xrefId)
        .setField(Xref__c.Integration_Status__c, STATUS_WAITING_FOR_BUSINESS)
        .setField(Xref__c.Business_Reference__c, businessReferenceId1)
        .setParent('Business_Reference__r', busRefCOO);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            businessAccount.Id,
            WORKORDER_TYPE_MARKETPLACE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake parentWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
                parentWorkPlanOnboardingFakeInstance
            );

        Fake workPlanXrefDataFake = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING)
            .setField(WorkPlan.Xref__c, xrefId)
            .setParent('Xref__r', xRef);

        WorkPlan workPlanXrefData = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
                workPlanXrefDataFake
            );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        WorkPlansSelector mockWorkPlansSelector = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectIntegrationInfoForWorkPlansByParentWorkPlanId( parentWorkPlan.Id)
            )
            .thenReturn(
                new List<WorkPlan>{ workPlanXrefData }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ReattemptProvisioningService.reattemptProvisioning(parentWorkPlan.Id);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Make sure the Xref__c with correct parameters are updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }

     /**
     * @description  Non Drive: To test reattemptProvisioning method from BIZRef : Null, XRef: Failure
     * expected: Xref updated to Failure with FAILURE_INTEGRATION_MESSAGE
     */
    @isTest
    private static void testWhenWorkOrderIdReceivedNonDriveBizRefNullXrefFailureThenReattemptProvisioning() {

        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id storeAccountID = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
               storeAccountID,
               WORKORDER_TYPE_MARKETPLACE,
               parentWorkOrder.Id
           );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
               childWorkOrderFakeInstance);

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountID)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Integration_Status__c, STATUS_FAILURE)
            .setField(Xref__c.Business_Reference__c, null)
            //.setParent('Business_Reference__r', null)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        mocks.startStubbing();

        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);

        mocks.when(
            mockWorkOrdersSelector.selectById(new Set<Id>{parentWorkOrderId}))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
            mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });

        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectActiveFailedXrefsBySalesforceAccountName(new Set<Id>{ storeAccountID }))
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ReattemptProvisioningService.reattemptProvisioningOnWorkOrder(parentWorkOrderId);
        Test.stopTest();

         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();

        //Make sure the Xref__c is updated to Ready For Integration
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => STATUS_FAILURE,
                        Xref__c.Integration_Message__c => FAILURE_INTEGRATION_MESSAGE
                    }
                )
            );
    }


    /**
     * @description To test reattemptProvisioning Drive WO: Both XREf and BizRef : Failure
     * Expected: Both XREf and BizRef : Updated to STATUS_READY_FOR_INTEGRATION
     */
    @isTest
    private static void testWhenWorkOrderIdReceivedThenReattemptProvisioningDriveWorkOder() {

        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id businessReferenceId1 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );


        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);

        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );


        Fake busRefFailure = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Id, businessReferenceId1)
            .setField(Business_Reference__c.External_Id_Source__c, EXTERNAL_DB_SOURCE_DRIVE)
            .setField(Business_Reference__c.Last_Completed_Step__c, null)
            .setField(Business_Reference__c.Integration_Status__c, STATUS_FAILURE);

        Business_Reference__c busRefFailureData = (Business_Reference__c) ServiceMockDataBuilder.convertToSObject( busRefFailure);

        Fake xRef = new Fake(Xref__c.class)
        .setField(Xref__c.Id, xrefId)
        .setField(Xref__c.Integration_Status__c, STATUS_FAILURE)
        .setField(Xref__c.External_ID_Source__c, EXTERNAL_DB_SOURCE_DRIVE)
        .setField(Xref__c.Business_Reference__c, businessReferenceId1)
        .setParent('Business_Reference__r', busRefFailure);

        Fake workPlanBusinessReferenceFake = ServiceMockDataBuilder.createWorkPlanFakeInstance(
            parentWorkOrderId
        )
        .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING)
        .setField(WorkPlan.WorkOrderId, parentWorkOrderId)
        .setField(WorkPlan.Business_Reference__c, busRefFailureData.Id)
        .setParent('Business_Reference__r', busRefFailure)
        .setField(WorkPlan.Xref__c, xrefId)
        .setParent('Xref__r', xRef);

        WorkPlan workPlanBusRefData = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            workPlanBusinessReferenceFake
        );

        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ workPlanBusinessReferenceFake }
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );

        mocks.startStubbing();

        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);

        mocks.when(
            mockWorkOrdersSelector.selectById(new Set<Id>{parentWorkOrderId}))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
            mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{});

        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);

        mocks.when(
                mockWorkPlansSelector.selectIntegrationInfoForWorkPlansByParentWorkOrderDriveId(parentWorkOrder.Id)
                )
                .thenReturn(new List<WorkPlan>{workPlanBusRefData});

        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ReattemptProvisioningService.reattemptProvisioningOnWorkOrder(parentWorkOrderId);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Make sure the Business_Reference__c with correct parameters are updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId1,
                        Business_Reference__c.Integration_Status__c => STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
        //Make sure the Xref__c with correct parameters are updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }
}