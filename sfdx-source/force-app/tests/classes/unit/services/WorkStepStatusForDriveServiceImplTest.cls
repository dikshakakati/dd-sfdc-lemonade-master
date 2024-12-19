/**
 * @author atg
 * @date 07/26/2022
 * @description Test class for WorkStepIntegrationStatusServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class WorkStepStatusForDriveServiceImplTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    public static final String STATUS_SUCCESS = 'Success';
    public static final String STATUS_FAILURE = 'Failure';
    private static final String XREF_STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    public static final String EXTERNAL_ID_SOURCE_DRIVE_DB = 'DriveDb';
    public static final String LAST_COMPLETED_CONFIGURATION_CREATED = 'Business Configuration Created';
    private static final String LAST_COMPLETED_WITHHOLDING = 'Drive Withholding Business Request Processed';
    private static final String ACCOUNT_PRIMARY_VERTICAL_PREMIUM = 'Grocery';
    private static final String ACCOUNT_NAME_BUSINESS = 'Business Account';
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final string ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String WORKORDER_SUBTYPE_AUTO_ACTIVATION = 'Auto-Activations';
    private static final String WORKORDER_SUBTYPE_NET_NEW_BUSINESS = 'Net-new business';
    private static final String WORKORDER_SUBTYPE_WITHHOLDING = 'Withholding';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_NAME_STORE = 'Store Account';
    private static final String ACCOUNT_ACTIVATION_STATUS_ACTIVE = 'Active';
    private static final String ACCOUNT_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final string OPPORTUNITY_NAME = 'Test Opportunity';
    private static final string OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String WORK_ORDER_PROVISIONING_COMPLETE = 'Provisioning Complete';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final String WORKPLAN_OWNER_NAME = 'O&A User';
    private static final String WORK_STEP_SETUP_STORE = 'Setup Store';
    private static final String WORKSTEP_TYPE_ACTIVATE_STORE = 'Activate Store';
    private static final String WORKSTEP_TYPE_REVIEW_AND_TRIAGE = 'Review & Triage';
    private static final String STATUS_COMPLETE = 'Complete';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_ESCALATED = 'Escalated';
    private static final String WORK_ORDER_PROVISIONING_FAILED = 'Provisioning Failed';
    private static final String AUTOMATIC = 'Automatic';

    /**
     * @description To test WorkStep updates when Business Reference is Updated.
     */
    @isTest
    private static void testWhenBusinessReferenceIsUpdatedToSuccessThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Fake parentAccountFakeInstance = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunityId,
            parentWorkPlanId,
            workStepId,
            businessReferenceId
        );
        Account parentAccount = (Account) parentAccountFakeInstance.toSObject();

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = STATUS_SUCCESS,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE_DB,
                Last_Completed_Step__c = LAST_COMPLETED_CONFIGURATION_CREATED
            )
        };
        Xref__c xref1 = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xRefId)
            .setField(Xref__c.Salesforce_Account_Name__c, parentAccount.Id)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setField(Xref__c.Integration_Status__c, STATUS_SUCCESS)
            .setParent('Salesforce_Account_Name__r', parentAccountFakeInstance)
            .toSObject();
        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            .setField(WorkStep.Type__c, 'Setup Business')
            .setField(WorkStep.WorkOrderId, parentWorkOrderId)
            .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            .setField(WorkStep.Business_Reference__c, businessReferenceId)
            .setField(WorkStep.Store_Account__c, parentAccount.Id)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
                    .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                    .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                    .setField(WorkOrder.Status, STATUS_PLANNING)
                    .setField(WorkOrder.AccountID, parentAccount.Id)
                    .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                    .setField(WorkOrder.Sub_Type__c, WORKORDER_SUBTYPE_AUTO_ACTIVATION)
            )
            .toSObject();

        Set<Id> businessReferenceIdSet = new Set<Id>{ businessReferenceId };
        Map<Id, Business_Reference__c> businessReferenceIdToStatusMap = new Map<Id, Business_Reference__c>();
        businessReferenceIdToStatusMap.put(businessReferenceId, businessReferenceList[0]);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IBusReferenceIntegrationService serviceMock = (IBusReferenceIntegrationService) mocks.mock(
            IBusReferenceIntegrationService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        mocks.startStubbing();

        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefSelector.selectAllMatchingBusinessReference(businessReferenceIdSet))
            .thenReturn(new List<XRef__c>{ xref1 });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteWorkStepRecForDriveByBusinessAccount(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(IBusReferenceIntegrationService.class, serviceMock);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);

        //parentAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepStatusForDriveService.updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
            businessReferenceIdToStatusMap
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => STATUS_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => WORK_ORDER_PROVISIONING_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => parentWorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    /**
     * @description To test Work Step on Work Order with Sub-type as 'Auto-Activaions' having
     * Withholding gets updated when Business Reference's integration status
     * is updated to 'Success'.
     */
    @isTest
    private static void testWhenDriveWithholdingBusinessReferenceUpdatedToSuccessThenUpdateAutoActivationsWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Fake parentAccountFakeInstance = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunityId,
            parentWorkPlanId,
            workStepId,
            businessReferenceId
        );
        Account parentAccount = (Account) parentAccountFakeInstance.toSObject();

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = STATUS_SUCCESS,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE_DB,
                Last_Completed_Step__c = LAST_COMPLETED_WITHHOLDING
            )
        };
        Xref__c xref1 = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xRefId)
            .setField(Xref__c.Salesforce_Account_Name__c, parentAccount.Id)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setField(Xref__c.Integration_Status__c, STATUS_SUCCESS)
            .setParent('Salesforce_Account_Name__r', parentAccountFakeInstance)
            .toSObject();
        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            .setField(WorkStep.Type__c, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.WorkOrderId, parentWorkOrderId)
            .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            .setField(WorkStep.Business_Reference__c, businessReferenceId)
            .setField(WorkStep.Store_Account__c, parentAccount.Id)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
                    .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                    .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                    .setField(WorkOrder.Status, STATUS_PLANNING)
                    .setField(WorkOrder.AccountID, parentAccount.Id)
                    .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                    .setField(WorkOrder.Sub_Type__c, WORKORDER_SUBTYPE_AUTO_ACTIVATION)
                    .setField(WorkOrder.Withholding_with_Auto_Activations__c, true)
            )
            .toSObject();

        Set<Id> businessReferenceIdSet = new Set<Id>{ businessReferenceId };
        Map<Id, Business_Reference__c> businessReferenceIdToStatusMap = new Map<Id, Business_Reference__c>();
        businessReferenceIdToStatusMap.put(businessReferenceId, businessReferenceList[0]);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IBusReferenceIntegrationService serviceMock = (IBusReferenceIntegrationService) mocks.mock(
            IBusReferenceIntegrationService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefSelector.selectAllMatchingBusinessReference(businessReferenceIdSet))
            .thenReturn(new List<XRef__c>{ xref1 });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteWorkStepRecForDriveByBusinessAccount(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(IBusReferenceIntegrationService.class, serviceMock);
        WorkStepStatusForDriveService.updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
            businessReferenceIdToStatusMap
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => STATUS_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => WORK_ORDER_PROVISIONING_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => parentWorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    /**
     * @description To test Work Step on Work Order with Sub-type as 'Withholding'
     * gets updated when Business Reference's integration status is updated to 'Success'.
     */
    @isTest
    private static void testWhenDriveWithholdingBusinessReferenceUpdatedToSuccessThenUpdateWithholdingWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Fake parentAccountFakeInstance = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunityId,
            parentWorkPlanId,
            workStepId,
            businessReferenceId
        );
        Account parentAccount = (Account) parentAccountFakeInstance.toSObject();

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = STATUS_SUCCESS,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE_DB,
                Last_Completed_Step__c = LAST_COMPLETED_WITHHOLDING
            )
        };
        Xref__c xref1 = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xRefId)
            .setField(Xref__c.Salesforce_Account_Name__c, parentAccount.Id)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setField(Xref__c.Integration_Status__c, STATUS_SUCCESS)
            .setParent('Salesforce_Account_Name__r', parentAccountFakeInstance)
            .toSObject();
        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            .setField(WorkStep.Type__c, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.WorkOrderId, parentWorkOrderId)
            .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            .setField(WorkStep.Business_Reference__c, businessReferenceId)
            .setField(WorkStep.Store_Account__c, parentAccount.Id)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
                    .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                    .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                    .setField(WorkOrder.Status, STATUS_PLANNING)
                    .setField(WorkOrder.AccountID, parentAccount.Id)
                    .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                    .setField(WorkOrder.Sub_Type__c, WORKORDER_SUBTYPE_WITHHOLDING)
            )
            .toSObject();

        Set<Id> businessReferenceIdSet = new Set<Id>{ businessReferenceId };
        Map<Id, Business_Reference__c> businessReferenceIdToStatusMap = new Map<Id, Business_Reference__c>();
        businessReferenceIdToStatusMap.put(businessReferenceId, businessReferenceList[0]);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IBusReferenceIntegrationService serviceMock = (IBusReferenceIntegrationService) mocks.mock(
            IBusReferenceIntegrationService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefSelector.selectAllMatchingBusinessReference(businessReferenceIdSet))
            .thenReturn(new List<XRef__c>{ xref1 });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteWorkStepRecForDriveByBusinessAccount(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(IBusReferenceIntegrationService.class, serviceMock);
        WorkStepStatusForDriveService.updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
            businessReferenceIdToStatusMap
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => STATUS_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => WORK_ORDER_PROVISIONING_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => parentWorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    /**
     * @description To test WorkStep updates when Business Reference is Updated.
     */
    @isTest
    private static void testWhenBusinessReferenceIsUpdatedToSuccessThenUpdateDriveNetNewBusinessWorkOrderForEscalatedWorkStep() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Fake parentAccountFakeInstance = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunityId,
            parentWorkPlanId,
            workStepId,
            businessReferenceId
        );
        Account parentAccount = (Account) parentAccountFakeInstance.toSObject();

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        List<Business_Reference__c> businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = STATUS_SUCCESS,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE_DB,
                Last_Completed_Step__c = LAST_COMPLETED_CONFIGURATION_CREATED
            )
        };
        Xref__c xrefs = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xRefId)
            .setField(Xref__c.Salesforce_Account_Name__c, parentAccount.Id)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setField(Xref__c.Integration_Status__c, STATUS_SUCCESS)
            .setParent('Salesforce_Account_Name__r', parentAccountFakeInstance)
            .toSObject();
        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.Status__c, STATUS_ESCALATED)
            .setField(WorkStep.Type__c, 'Setup Business')
            .setField(WorkStep.WorkOrderId, parentWorkOrderId)
            .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            .setField(WorkStep.Business_Reference__c, businessReferenceId)
            .setField(WorkStep.Store_Account__c, parentAccount.Id)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
                    .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                    .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                    .setField(WorkOrder.Status, STATUS_PLANNING)
                    .setField(WorkOrder.AccountID, parentAccount.Id)
                    .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                    .setField(WorkOrder.Sub_Type__c, WORKORDER_SUBTYPE_NET_NEW_BUSINESS)
                    .setField(WorkOrder.Business_to_Store_Assignment__c, AUTOMATIC)
            )
            .toSObject();

        Map<Id, Business_Reference__c> businessReferenceIdToStatusMap = new Map<Id, Business_Reference__c>();
        businessReferenceIdToStatusMap.put(businessReferenceId, businessReferences[0]);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IBusReferenceIntegrationService serviceMock = (IBusReferenceIntegrationService) mocks.mock(
            IBusReferenceIntegrationService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefSelector.selectAllMatchingBusinessReference(
                    new Set<Id>{ businessReferenceId }
                )
            )
            .thenReturn(new List<XRef__c>{ xrefs });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteWorkStepRecForDriveByBusinessAccount(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(IBusReferenceIntegrationService.class, serviceMock);

        WorkStepStatusForDriveService.updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
            businessReferenceIdToStatusMap
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => STATUS_NOT_STARTED,
                        WorkStep.Status_Reason__c => ''
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => WORK_ORDER_PROVISIONING_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => parentWorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId,
                        WorkPlan.Xref__c => xRefId
                    }
                )
            );
    }

    /**
     * @description To test WorkStep updates when Business Reference is Updated.
     */
    @isTest
    private static void testWhenBusinessReferenceIsUpdatedToSuccessThenUpdateDriveNetNewBusinessWorkOrderForNotStartedWorkStep() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Fake parentAccountFakeInstance = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunityId,
            parentWorkPlanId,
            workStepId,
            businessReferenceId
        );
        Account parentAccount = (Account) parentAccountFakeInstance.toSObject();

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        List<Business_Reference__c> businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = STATUS_SUCCESS,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE_DB,
                Last_Completed_Step__c = LAST_COMPLETED_CONFIGURATION_CREATED
            )
        };
        Xref__c xrefs = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xRefId)
            .setField(Xref__c.Salesforce_Account_Name__c, parentAccount.Id)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setField(Xref__c.Integration_Status__c, STATUS_SUCCESS)
            .setParent('Salesforce_Account_Name__r', parentAccountFakeInstance)
            .toSObject();
        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            .setField(WorkStep.Type__c, 'Setup Business')
            .setField(WorkStep.WorkOrderId, parentWorkOrderId)
            .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            .setField(WorkStep.Business_Reference__c, businessReferenceId)
            .setField(WorkStep.Store_Account__c, parentAccount.Id)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
                    .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                    .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                    .setField(WorkOrder.Status, STATUS_PLANNING)
                    .setField(WorkOrder.AccountID, parentAccount.Id)
                    .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                    .setField(WorkOrder.Sub_Type__c, WORKORDER_SUBTYPE_NET_NEW_BUSINESS)
                    .setField(WorkOrder.Business_to_Store_Assignment__c, AUTOMATIC)
            )
            .toSObject();

        Map<Id, Business_Reference__c> businessReferenceIdToStatusMap = new Map<Id, Business_Reference__c>();
        businessReferenceIdToStatusMap.put(businessReferenceId, businessReferences[0]);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IBusReferenceIntegrationService serviceMock = (IBusReferenceIntegrationService) mocks.mock(
            IBusReferenceIntegrationService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefSelector.selectAllMatchingBusinessReference(
                    new Set<Id>{ businessReferenceId }
                )
            )
            .thenReturn(new List<XRef__c>{ xrefs });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteWorkStepRecForDriveByBusinessAccount(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(IBusReferenceIntegrationService.class, serviceMock);

        WorkStepStatusForDriveService.updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
            businessReferenceIdToStatusMap
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => WORK_ORDER_PROVISIONING_COMPLETE
                    }
                )
            );
    }

    private static Fake createParentAccountFake(
        Id parentWorkOrderId,
        Id parentOpportunityId,
        Id parentWorkPlanId,
        Id workStepId,
        Id businessRefRecord
    ) {
        Fake parentAccount = new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_PREMIUM)
            .setField(Account.RecordTypeID, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setFakeId();
        return parentAccount;
    }

    /**
     * @description To test WorkStep updates when Business Reference is Updated.
     */
    @isTest
    private static void testWhenBusinessReferenceIsUpdatedToFailThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Fake parentAccountFakeInstance = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunityId,
            parentWorkPlanId,
            workStepId,
            businessReferenceId
        );
        Account parentAccount = (Account) parentAccountFakeInstance.toSObject();

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = STATUS_FAILURE,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE_DB,
                Last_Completed_Step__c = LAST_COMPLETED_CONFIGURATION_CREATED
            )
        };
        Xref__c xref1 = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xRefId)
            .setField(Xref__c.Salesforce_Account_Name__c, parentAccount.Id)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setField(Xref__c.Integration_Status__c, STATUS_SUCCESS)
            .setParent('Salesforce_Account_Name__r', parentAccountFakeInstance)
            .toSObject();
        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            .setField(WorkStep.Type__c, 'Setup Business')
            .setField(WorkStep.WorkOrderId, parentWorkOrderId)
            .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            .setField(WorkStep.Business_Reference__c, businessReferenceId)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
                    .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                    .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                    .setField(WorkOrder.Status, STATUS_PLANNING)
                    .setField(WorkOrder.AccountID, parentAccount.Id)
                    .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                    .setField(WorkOrder.Sub_Type__c, WORKORDER_SUBTYPE_AUTO_ACTIVATION)
            )
            .toSObject();

        Set<Id> businessReferenceIdSet = new Set<Id>{ businessReferenceId };
        Map<Id, Business_Reference__c> businessReferenceIdToStatusMap = new Map<Id, Business_Reference__c>();
        businessReferenceIdToStatusMap.put(businessReferenceId, businessReferenceList[0]);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefSelector.selectAllMatchingBusinessReference(businessReferenceIdSet))
            .thenReturn(new List<XRef__c>{ xref1 });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteWorkStepRecForDriveByBusinessAccount(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        WorkStepStatusForDriveService.updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
            businessReferenceIdToStatusMap
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => STATUS_ESCALATED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => WORK_ORDER_PROVISIONING_FAILED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => parentWorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    /**
     * @description It is used to test 'Drive' WorkStep's status updates when Business Reference
     * is updated to a non success integration status.
     */
    @isTest
    private static void testWhenBusinessReferenceUpdatedToNonSuccessIntegrationStatusThenUpdateDriveWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Fake parentAccountFakeInstance = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunityId,
            parentWorkPlanId,
            workStepId,
            businessReferenceId
        );
        Account parentAccount = (Account) parentAccountFakeInstance.toSObject();

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = STATUS_FAILURE,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE_DB,
                Last_Completed_Step__c = LAST_COMPLETED_CONFIGURATION_CREATED
            )
        };
        Xref__c xref1 = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xRefId)
            .setField(Xref__c.Salesforce_Account_Name__c, parentAccount.Id)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setField(Xref__c.Integration_Status__c, STATUS_SUCCESS)
            .setParent('Salesforce_Account_Name__r', parentAccountFakeInstance)
            .toSObject();
        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            .setField(WorkStep.Type__c, 'Setup Business')
            .setField(WorkStep.WorkOrderId, parentWorkOrderId)
            .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            .setField(WorkStep.Business_Reference__c, businessReferenceId)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
                    .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                    .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                    .setField(WorkOrder.Status, STATUS_PLANNING)
                    .setField(WorkOrder.AccountID, parentAccount.Id)
                    .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                    .setField(WorkOrder.Sub_Type__c, WORKORDER_SUBTYPE_AUTO_ACTIVATION)
            )
            .toSObject();

        Set<Id> businessReferenceIdSet = new Set<Id>{ businessReferenceId };
        Map<Id, Business_Reference__c> businessReferenceIdToStatusMap = new Map<Id, Business_Reference__c>();
        businessReferenceIdToStatusMap.put(businessReferenceId, businessReferenceList[0]);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefSelector.selectAllMatchingBusinessReference(businessReferenceIdSet))
            .thenReturn(new List<XRef__c>{ xref1 });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteWorkStepRecForDriveByBusinessAccount(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        //parentAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepStatusForDriveService.updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
            businessReferenceIdToStatusMap
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => STATUS_ESCALATED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => WORK_ORDER_PROVISIONING_FAILED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => parentWorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    /**
     * @description To test Work Step of Work Order with Sub-Type as 'Withholding'
     * gets updated when Business Reference's integration status is updated to 'Failure'.
     */
    @isTest
    private static void testWhenDriveWithholdingBusinessReferenceUpdatedToFailureThenUpdateWithholdingWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Fake parentAccountFakeInstance = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunityId,
            parentWorkPlanId,
            workStepId,
            businessReferenceId
        );
        Account parentAccount = (Account) parentAccountFakeInstance.toSObject();

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = STATUS_FAILURE,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE_DB,
                Last_Completed_Step__c = LAST_COMPLETED_CONFIGURATION_CREATED
            )
        };
        Xref__c xref1 = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xRefId)
            .setField(Xref__c.Salesforce_Account_Name__c, parentAccount.Id)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setField(Xref__c.Integration_Status__c, STATUS_SUCCESS)
            .setParent('Salesforce_Account_Name__r', parentAccountFakeInstance)
            .toSObject();
        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            .setField(WorkStep.Type__c, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.WorkOrderId, parentWorkOrderId)
            .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            .setField(WorkStep.Business_Reference__c, businessReferenceId)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
                    .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                    .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                    .setField(WorkOrder.Status, STATUS_PLANNING)
                    .setField(WorkOrder.AccountID, parentAccount.Id)
                    .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                    .setField(WorkOrder.Sub_Type__c, WORKORDER_SUBTYPE_WITHHOLDING)
            )
            .toSObject();

        Set<Id> businessReferenceIdSet = new Set<Id>{ businessReferenceId };
        Map<Id, Business_Reference__c> businessReferenceIdToStatusMap = new Map<Id, Business_Reference__c>();
        businessReferenceIdToStatusMap.put(businessReferenceId, businessReferenceList[0]);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefSelector.selectAllMatchingBusinessReference(businessReferenceIdSet))
            .thenReturn(new List<XRef__c>{ xref1 });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteWorkStepRecForDriveByBusinessAccount(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        //parentAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepStatusForDriveService.updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
            businessReferenceIdToStatusMap
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => STATUS_ESCALATED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => WORK_ORDER_PROVISIONING_FAILED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => parentWorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    @isTest
    private static void testWhenXrefIsUpdatedToSuccessThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        // Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_PREMIUM)
            .setField(Account.RecordTypeID, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setFakeId()
            .toSObject();

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = STATUS_SUCCESS,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE_DB,
                Last_Completed_Step__c = LAST_COMPLETED_CONFIGURATION_CREATED
            )
        };
        List<Xref__c> xref1 = new List<Xref__c>{
            new Xref__c(
                Id = xRefId,
                Salesforce_Account_Name__c = storeAccount.Id,
                Business_Reference__c = businessReferenceId,
                Integration_Status__c = STATUS_SUCCESS
            )
        };

        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.Type__c, 'Setup Business')
            .setField(WorkStep.WorkOrderId, parentWorkOrderId)
            .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            .setField(WorkStep.Business_Reference__c, businessReferenceId)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
                    .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                    .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                    .setField(WorkOrder.Status, STATUS_PLANNING)
                    .setField(WorkOrder.AccountID, storeAccount.Id)
                    .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                    .setField(WorkOrder.Sub_Type__c, WORKORDER_SUBTYPE_AUTO_ACTIVATION)
            )
            .toSObject();

        Map<Id, List<Xref__c>> busRefIdXrefRecMap = new Map<Id, List<Xref__c>>();
        busRefIdXrefRecMap.put(xref1[0].Business_Reference__c, xref1);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector mockBusSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockBusSelector.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(mockBusSelector.selectByBusRefId(busRefIdXrefRecMap.keySet()))
            .thenReturn(new List<Business_Reference__c>{ businessReferenceList[0] });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteSetupStoreWorkStepsByStoreAccountForTypeStore(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        WorkStepStatusForDriveService.updateWorkStepsStatusOnXrefStatusChangeForDrive(
            busRefIdXrefRecMap
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => STATUS_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => WORK_ORDER_PROVISIONING_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => parentWorkPlanId,
                        WorkPlan.Xref__c => xrefId
                    }
                )
            );
    }

    @isTest
    private static void testWhenXrefIsUpdatedToSuccessThenUpdateUpdateDriveNetNewBusinessWorkOrderForEscalatedWorkStep() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_PREMIUM)
            .setField(Account.RecordTypeID, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setFakeId()
            .toSObject();

        List<Business_Reference__c> businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = STATUS_SUCCESS,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE_DB,
                Last_Completed_Step__c = LAST_COMPLETED_CONFIGURATION_CREATED
            )
        };
        List<Xref__c> xrefs = new List<Xref__c>{
            new Xref__c(
                Id = xRefId,
                Salesforce_Account_Name__c = storeAccount.Id,
                Business_Reference__c = businessReferenceId,
                Integration_Status__c = STATUS_SUCCESS
            )
        };

        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.Status__c, STATUS_ESCALATED)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.Type__c, 'Setup Business')
            .setField(WorkStep.WorkOrderId, parentWorkOrderId)
            .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            .setField(WorkStep.Business_Reference__c, businessReferenceId)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
                    .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                    .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                    .setField(WorkOrder.Status, STATUS_PLANNING)
                    .setField(WorkOrder.AccountID, storeAccount.Id)
                    .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                    .setField(WorkOrder.Sub_Type__c, WORKORDER_SUBTYPE_NET_NEW_BUSINESS)
                    .setField(WorkOrder.Business_to_Store_Assignment__c, AUTOMATIC)
            )
            .toSObject();

        Map<Id, List<Xref__c>> busRefIdXrefRecMap = new Map<Id, List<Xref__c>>();
        busRefIdXrefRecMap.put(xrefs[0].Business_Reference__c, xrefs);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector mockBusSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockBusSelector.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(mockBusSelector.selectByBusRefId(busRefIdXrefRecMap.keySet()))
            .thenReturn(new List<Business_Reference__c>{ businessReferences[0] });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteSetupStoreWorkStepsByStoreAccountForTypeStore(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        WorkStepStatusForDriveService.updateWorkStepsStatusOnXrefStatusChangeForDrive(
            busRefIdXrefRecMap
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => STATUS_NOT_STARTED,
                        WorkStep.Status_Reason__c => ''
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => WORK_ORDER_PROVISIONING_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => parentWorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId,
                        WorkPlan.Xref__c => xrefId
                    }
                )
            );
    }

    @isTest
    private static void testWhenXrefIsUpdatedToSuccessThenUpdateUpdateDriveNetNewBusinessWorkOrderForNotStartedWorkStep() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_PREMIUM)
            .setField(Account.RecordTypeID, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setFakeId()
            .toSObject();

        List<Business_Reference__c> businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = STATUS_SUCCESS,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE_DB,
                Last_Completed_Step__c = LAST_COMPLETED_CONFIGURATION_CREATED
            )
        };
        List<Xref__c> xrefs = new List<Xref__c>{
            new Xref__c(
                Id = xRefId,
                Salesforce_Account_Name__c = storeAccount.Id,
                Business_Reference__c = businessReferenceId,
                Integration_Status__c = STATUS_SUCCESS
            )
        };

        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.Type__c, 'Setup Business')
            .setField(WorkStep.WorkOrderId, parentWorkOrderId)
            .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            .setField(WorkStep.Business_Reference__c, businessReferenceId)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
                    .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                    .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                    .setField(WorkOrder.Status, STATUS_PLANNING)
                    .setField(WorkOrder.AccountID, storeAccount.Id)
                    .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                    .setField(WorkOrder.Sub_Type__c, WORKORDER_SUBTYPE_NET_NEW_BUSINESS)
                    .setField(WorkOrder.Business_to_Store_Assignment__c, AUTOMATIC)
            )
            .toSObject();

        Map<Id, List<Xref__c>> busRefIdXrefRecMap = new Map<Id, List<Xref__c>>();
        busRefIdXrefRecMap.put(xrefs[0].Business_Reference__c, xrefs);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector mockBusSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockBusSelector.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(mockBusSelector.selectByBusRefId(busRefIdXrefRecMap.keySet()))
            .thenReturn(new List<Business_Reference__c>{ businessReferences[0] });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteSetupStoreWorkStepsByStoreAccountForTypeStore(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        WorkStepStatusForDriveService.updateWorkStepsStatusOnXrefStatusChangeForDrive(
            busRefIdXrefRecMap
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => WORK_ORDER_PROVISIONING_COMPLETE
                    }
                )
            );
    }

    @isTest
    private static void testWhenXrefIsUpdatedToFailureThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_PREMIUM)
            .setField(Account.RecordTypeID, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setFakeId()
            .toSObject();

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = STATUS_FAILURE,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE_DB,
                Last_Completed_Step__c = LAST_COMPLETED_CONFIGURATION_CREATED
            )
        };
        List<Xref__c> xref1 = new List<Xref__c>{
            new Xref__c(
                Id = xRefId,
                Salesforce_Account_Name__c = storeAccount.Id,
                Business_Reference__c = businessReferenceId,
                Integration_Status__c = STATUS_FAILURE
            )
        };

        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORKORDER_TYPE_DRIVE)
            .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.Type__c, 'Setup Business')
            .setField(WorkStep.WorkOrderId, parentWorkOrderId)
            .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            .setField(WorkStep.Business_Reference__c, businessReferenceId)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
                    .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                    .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                    .setField(WorkOrder.Status, STATUS_PLANNING)
                    .setField(WorkOrder.AccountID, storeAccount.Id)
                    .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                    .setField(WorkOrder.Sub_Type__c, WORKORDER_SUBTYPE_AUTO_ACTIVATION)
            )
            .toSObject();

        Map<Id, List<Xref__c>> busRefIdXrefRecMap = new Map<Id, List<Xref__c>>();
        busRefIdXrefRecMap.put(xref1[0].Business_Reference__c, xref1);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector mockBusSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockBusSelector.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(mockBusSelector.selectByBusRefId(busRefIdXrefRecMap.keySet()))
            .thenReturn(new List<Business_Reference__c>{ businessReferenceList[0] });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteSetupStoreWorkStepsByStoreAccountForTypeStore(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        WorkStepStatusForDriveService.updateWorkStepsStatusOnXrefStatusChangeForDrive(
            busRefIdXrefRecMap
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => STATUS_ESCALATED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => WORK_ORDER_PROVISIONING_FAILED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => parentWorkPlanId,
                        WorkPlan.Xref__c => xrefId
                    }
                )
            );
    }
}