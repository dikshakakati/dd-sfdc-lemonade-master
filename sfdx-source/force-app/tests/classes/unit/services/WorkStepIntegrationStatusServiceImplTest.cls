/**
 * @author atg
 * @date 07/26/2022
 * @description Test class for WorkStepIntegrationStatusServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class WorkStepIntegrationStatusServiceImplTest {
    private static final String ASSERT_MESSAGE_STATUS_NOT_UPDATED = 'Status is not Updated';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_NAME_BUSINESS = 'Business Account';
    private static final String ACCOUNT_NAME_STORE = 'Store Account';
    private static final String ACCOUNT_PRIMARY_VERTICAL_PREMIUM = 'Grocery';
    private static final String ACCOUNT_ACTIVATION_STATUS_ACTIVE = 'Active';
    private static final String ACCOUNT_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final string ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String ASSERT_MESSAGE_NO_CHILD_WORKSTEPS = 'Unexpected result: The list does not contain any child Work Steps.';
    private static final String BUSINESS_REF_STATUS_NEW = 'New';
    private static final String BUSINESS_REF_STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String CURRENT_RETRY_COUNT = 'Current Retry Count: ';
    private static final String EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_INTEGRATION = 'REINITIATE_WORK_STEPS_STATUS_INTEGRATION';
    private static final String EVENT_TOPIC_UPDATE_WORK_STEPS_INTEGRATION_STATUS = 'UPDATE_SETUP_BUSINESS_WORKSTEP_STATUS';
    private static final String EXCEEDED_MAXIMUM_RETRY_LIMIT_ERROR_MESSAGE = 'Maximum retry limit exceeded for Work Steps status integration.';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String GLOBAL_DO_NOT_ACTIVATE_INTEGRATION_MESSAGE = 'This Business ID is deactivated and it is unable to be updated. Please raise a ticket in the #ask-lemonade channel to update Business ID.';
    private static final String METADATA_CONTAINS_OPERATOR = 'contains';
    private static final String METADATA_EQUALS_OPERATOR = 'equals';
    private static final Integer METADATA_SEQUENCE = 1;
    private static final String METADATA_VALUE = '3';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final string OPPORTUNITY_NAME = 'Test Opportunity';
    private static final string OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String PIPELINE_SEPARATOR = ' || ';
    private static final string SEGMENT_SMB = 'SMB';
    private static final String WORK_STEP_STATUS_INTEGRATION_RETRY_LIMIT_STATIC_CONFIG = 'Work_Step_Status_Integration_Retry_Limit';
    private static final String STATUS_AT_RISK = 'At Risk';
    private static final String STATUS_BLOCKED = 'Blocked';
    private static final String STATUS_COMPLETE = 'Complete';
    private static final String STATUS_CONFIRMED = 'Confirmed';
    private static final String STATUS_ESCALATED = 'Escalated';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String STATUS_PAST_DUE = 'Past Due';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String STATUS_QA_COMPLETE = 'QA Complete';
    private static final String STATUS_READY_FOR_QA = 'Ready for QA';
    private static final String STATUS_REASON_INACTIVE_MENU = 'Inactive menu';
    private static final String STATUS_REASON_INVALID_ADDRESS = 'Invalid Address';
    private static final String STATUS_ONBOARDING_COMPLETE = 'Onboarding Complete';
    private static final String ULTIMATE_PARENT_WORK_ORDER_CONDITION = 'WorkOrder.ParentWorkOrder.Status NOT IN :WORK_ORDER_PRIORITY_STATUSES';
    private static final String ULTIMATE_PARENT_WORK_ORDER_GROUPBYFIELD = 'WorkOrder.ParentWorkOrderId';
    private static final String ULTIMATE_PARENT_WORK_PLAN_CONDITION = null;
    private static final String ULTIMATE_PARENT_WORK_PLAN_GROUPBYFIELD = 'WorkPlan.Parent_Work_Plan__c';
    private static final String ULTIMATE_PARENT_WORK_STEP_CONDITION = null;
    private static final String ULTIMATE_PARENT_WORK_STEP_GROUPBYFIELD = 'Parent_Work_Step__c';
    private static final Set<String> WORK_ORDER_PRIORITY_STATUSES = new Set<String>{
        STATUS_AT_RISK,
        STATUS_PAST_DUE
    };
    private static final String WORKORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String STATUS_COO_SUCCESS = 'COO Success';
    private static final String SUCCESS = 'Success';
    private static final String STATUS_FAILURE = 'Failure';

    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final String WORKPLAN_OWNER_NAME = 'O&A User';
    private static final String WORK_STEP_SETUP_STORE = 'Setup Store';
    private static final String WORKSTEP_TYPE_ACTIVATE_STORE = 'Activate Store';
    private static final String WORKSTEP_TYPE_REVIEW_AND_TRIAGE = 'Review & Triage';
    private static final String WORKSTEP_TYPE_RATE_CHANGE = 'Rate Change';
    private static final Date OPPORTUNITY_CLOSE_DATE = Date.today().addDays(15);
    private static final String WORKSTEP_BUSINESS_STATUS_REASON = 'Business Provisioning Failed - Please refer to Provisioning Errors tab';
    private static final String WORKSTEP_STORE_STATUS_REASON = 'Store Provisioning Failed - Please refer to Provisioning Errors tab';
    private static final String WORKSTEP_BUSINESS_REFERENCE_NOT_FOUND_STATUS_REASON = 'Business reference not found';
    private static final String EXTERNAL_ID = '123456';

    @isTest
    private static void testWhenXRefIsCreatedWithABusinessReferenceStatusAsFailureThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );

        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref1 = new Xref__c(
            Id = xRefId,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId
        );

        Business_Reference__c businessReference = new Business_reference__c(
            Id = businessReferenceId,
            Integration_Status__c = WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_FAILURE
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector mockBusinessReferenceSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockBusinessReferenceSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessReferenceSelector.selectBydIdAndIntegrationStatus(
                    new Set<Id>{ businessReferenceId },
                    new Set<String>{
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_SUCCESS,
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_FAILURE,
                        BUSINESS_REF_STATUS_NEW,
                        BUSINESS_REF_STATUS_READY_FOR_INTEGRATION
                    }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusinessReferenceSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateSetupBusinessWorkStepStatusOnXrefCreation(
            new List<Xref__c>{ xref1 },
            new Set<Id>{ businessReferenceId }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_ESCALATED,
                        WorkStep.Status_Reason__c => WORKSTEP_BUSINESS_STATUS_REASON,
                        WorkStep.Business_Reference__c => businessReferenceId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkOrderId,
                        WorkOrder.Provisioning_Status__c => WorkStepIntegrationStatusServiceImpl.WORK_ORDER_PROVISIONING_FAILED
                    }
                )
            );
    }

    @isTest
    private static void testWhenXRefIsCreatedWithABusinessReferenceStatusAsSuccessThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );

        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref1 = new Xref__c(
            Id = xRefId,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId
        );

        Business_Reference__c businessReference = new Business_reference__c(
            Id = businessReferenceId,
            Integration_Status__c = WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_SUCCESS
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector mockBusinessReferenceSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockBusinessReferenceSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessReferenceSelector.selectBydIdAndIntegrationStatus(
                    new Set<Id>{ businessReferenceId },
                    new Set<String>{
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_SUCCESS,
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_FAILURE,
                        BUSINESS_REF_STATUS_NEW,
                        BUSINESS_REF_STATUS_READY_FOR_INTEGRATION
                    }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusinessReferenceSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateSetupBusinessWorkStepStatusOnXrefCreation(
            new List<Xref__c>{ xref1 },
            new Set<Id>{ businessReferenceId }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_COMPLETE,
                        WorkStep.Business_Reference__c => businessReferenceId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    /**
     * @description It is used to test whether the work step's status is updated when xrefs are created
     * with business references having a non success integration status.
     */
    @isTest
    private static void testWhenXRefCreatedWithBusinessReferenceHavingNonSuccessIntegrationStatusThenUpdateSetupStoreWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );

        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref = new Xref__c(
            Id = xRefId,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId
        );

        Business_Reference__c businessReference = new Business_reference__c(
            Id = businessReferenceId,
            Integration_Status__c = BUSINESS_REF_STATUS_READY_FOR_INTEGRATION
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector mockBusinessReferenceSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockBusinessReferenceSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessReferenceSelector.selectBydIdAndIntegrationStatus(
                    new Set<Id>{ businessReferenceId },
                    new Set<String>{
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_SUCCESS,
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_FAILURE,
                        BUSINESS_REF_STATUS_NEW,
                        BUSINESS_REF_STATUS_READY_FOR_INTEGRATION
                    }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusinessReferenceSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateSetupBusinessWorkStepStatusOnXrefCreation(
            new List<Xref__c>{ xref },
            new Set<Id>{ businessReferenceId }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_ESCALATED,
                        WorkStep.Business_Reference__c => businessReferenceId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    /**
     * @description To test WorkStep updates when Business Reference is Updated.
     */
    @isTest
    private static void testWhenBusinessReferenceIsUpdatedToSuccessThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref1 = new Xref__c(
            Id = xRefId,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId
        );
        Business_Reference__c businessReference = new Business_Reference__c(
            Id = businessReferenceId,
            Integration_Status__c = 'Success'
        );
        Set<Id> businessReferenceIdSet = new Set<Id>{ businessReferenceId };
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
                mockWorkStepsSelector.getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateWorkStepsStatusOnBusinessReferenceStatusChange(
            new Map<Id, Business_Reference__c>{ businessReferenceId => businessReference }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_COMPLETE,
                        WorkStep.Business_Reference__c => businessReferenceId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    /**
     * @description To test WorkStep updates when Business Reference is Updated to COO Success.
     */
    @isTest
    private static void testWhenBusinessReferenceIsUpdatedToCOOSuccessThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref1 = new Xref__c(
            Id = xRefId,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId
        );

        Business_Reference__c businessReference = new Business_reference__c(
            Id = businessReferenceId,
            Integration_Status__c = STATUS_COO_SUCCESS,
            Integration_Message__c = SUCCESS
        );

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
        mocks.when(
                mockXrefSelector.selectAllMatchingBusinessReference(
                    new Set<Id>{ businessReferenceId }
                )
            )
            .thenReturn(new List<XRef__c>{ xref1 });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateWorkStepsStatusOnBusinessReferenceCOOStatusChange(
            new List<Business_Reference__c>{ businessReference }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_COMPLETE,
                        WorkStep.Business_Reference__c => businessReferenceId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    /**
     * @description To test WorkStep updates when Business Reference is Updated to COO Success.
     */
    @isTest
    private static void testWhenBusinessReferenceIsUpdatedToFailureForCOOThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref1 = new Xref__c(
            Id = xRefId,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId
        );
        Business_Reference__c businessReference = new Business_Reference__c(
            Id = businessReferenceId,
            Integration_Status__c = STATUS_FAILURE
        );
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
        mocks.when(
                mockXrefSelector.selectAllMatchingBusinessReference(
                    new Set<Id>{ businessReferenceId }
                )
            )
            .thenReturn(new List<XRef__c>{ xref1 });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateWorkStepsStatusOnBusinessReferenceStatusChange(
            new Map<Id, Business_Reference__c>{ businessReferenceId => businessReference }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_ESCALATED,
                        WorkStep.Status_Reason__c => WORKSTEP_BUSINESS_STATUS_REASON,
                        WorkStep.Business_Reference__c => businessReferenceId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    /**
     * @description To test WorkStep updates when Business Reference is Updated.
     */
    @isTest
    private static void testWhenBusinessReferenceIsUpdatedToFailureThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );

        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref1 = new Xref__c(
            Id = xRefId,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId
        );
        Business_Reference__c businessReference = new Business_Reference__c(
            Id = businessReferenceId,
            Integration_Status__c = STATUS_FAILURE
        );
        Set<Id> businessReferenceIdSet = new Set<Id>{ businessReferenceId };
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
                mockWorkStepsSelector.getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateWorkStepsStatusOnBusinessReferenceStatusChange(
            new Map<Id, Business_Reference__c>{ businessReferenceId => businessReference }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_ESCALATED,
                        WorkStep.Business_Reference__c => businessReferenceId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId,
                        WorkPlan.Status__c => STATUS_ESCALATED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkOrderId,
                        WorkOrder.Provisioning_Status__c => WorkStepIntegrationStatusServiceImpl.WORK_ORDER_PROVISIONING_FAILED
                    }
                )
            );
    }

    /**
     * @description To test WorkStep updates when multiple Business References are Updated.
     */
    @isTest
    private static void testWhenMultipleBusinessRefsUpdatedThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );

        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );

        Id xRefId1 = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id xRefId2 = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Id businessReferenceId1 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id businessReferenceId2 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref1 = new Xref__c(
            Id = xRefId1,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId1
        );
        Xref__c xref2 = new Xref__c(
            Id = xRefId2,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId2
        );
        Business_Reference__c businessReference1 = new Business_Reference__c(
            Id = businessReferenceId1,
            Integration_Status__c = SUCCESS
        );
        Business_Reference__c businessReference2 = new Business_Reference__c(
            Id = businessReferenceId2,
            Integration_Status__c = STATUS_FAILURE
        );
        Set<Id> businessReferenceIdSet = new Set<Id>{ businessReferenceId1, businessReferenceId2 };

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
            .thenReturn(new List<XRef__c>{ xref1, xref2 });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateWorkStepsStatusOnBusinessReferenceStatusChange(
            new Map<Id, Business_Reference__c>{
                businessReferenceId1 => businessReference1,
                businessReferenceId2 => businessReference2
            }
        );

        //Ensure the FAILED business reference is selected, so we mark the Worksteps for the Account as ESCALATED.
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_ESCALATED,
                        WorkStep.Business_Reference__c => businessReferenceId2
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId2,
                        WorkPlan.Status__c => STATUS_ESCALATED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkOrderId,
                        WorkOrder.Provisioning_Status__c => WorkStepIntegrationStatusServiceImpl.WORK_ORDER_PROVISIONING_FAILED
                    }
                )
            );
    }

    /**
     * @description To test WorkStep updates when Xref is Updated.
     */
    @isTest
    private static void testWhenXrefIsUpdatedToSuccessThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );
        storeAccount.WorkOrders[0].Type__c = 'Drive';
        storeAccount.WorkOrders[0].WorkSteps[0].Type__c = 'Setup Store';

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Xref__c xref1 = new Xref__c(
            Id = xRefId,
            External_ID__c = '123456',
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID_Source__c = WorkStepIntegrationStatusServiceImpl.XREF_EXTERNAL_SOURCE_DRIVE,
            Integration_Status__c = 'Success'
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteSetupStoreWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateWorkStepsStatusOnXrefStatusChange(
            new List<Xref__c>{ xref1 }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkPlanId,
                        WorkPlan.Xref__c => xRefId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkOrderId,
                        WorkOrder.Provisioning_Status__c => 'Provisioning Complete',
                        WorkOrder.Store_Id__c => '123456'
                    }
                )
            );
    }

    /**
     * @description To test 'Setup Store' Work Step's Status, Status Reason and
     * Status Reason Detail is updated when Xref's Integration Status fails.
     */
    @isTest
    private static void testWhenXrefFailsThenUpdateWorkStepStatusByStatusMappings() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);
        Id businessFriendlyMappingId = fflib_IDGenerator.generate(
            Business_Friendly_Mapping__mdt.SObjectType
        );

        Status_Reason_And_Details_Mapping__mdt statusReasonAndDetailsMappings = (Status_Reason_And_Details_Mapping__mdt) new Fake(
                Status_Reason_And_Details_Mapping__mdt.class
            )
            .setField(Status_Reason_And_Details_Mapping__mdt.Status__c, 'Blocked')
            .setField(Status_Reason_And_Details_Mapping__mdt.Status_Reason__c, 'Invalid Address')
            .setField(Status_Reason_And_Details_Mapping__mdt.Type__c, 'Setup Store')
            .setField(
                Status_Reason_And_Details_Mapping__mdt.Business_Friendly_Mapping__c,
                businessFriendlyMappingId
            )
            .setParent(
                'Business_Friendly_Mapping__r',
                new Fake(Business_Friendly_Mapping__mdt.class)
                    .setField(Business_Friendly_Mapping__mdt.id, businessFriendlyMappingId)
                    .setField(
                        Business_Friendly_Mapping__mdt.Integration_Key_String__c,
                        'required key [accountCurrency] not found'
                    )
                    .setField(
                        Business_Friendly_Mapping__mdt.Integration_Type__c,
                        'Xref Provisioning'
                    )
                    .setField(
                        Business_Friendly_Mapping__mdt.Message_Category__c,
                        'Missing Data - Currency'
                    )
                    .setField(Business_Friendly_Mapping__mdt.Order__c, 40)
                    .setField(Business_Friendly_Mapping__mdt.Active__c, true)
            )
            .setFakeId()
            .toSObject();

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );
        storeAccount.WorkOrders[0].Type__c = 'Marketplace';
        storeAccount.WorkOrders[0].WorkSteps[0].Name = 'Setup Store';
        storeAccount.WorkOrders[0].WorkSteps[0].Type__c = 'Setup Store';
        storeAccount.WorkOrders[0].WorkSteps[0].WorkOrder.Type__c = 'Marketplace';

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Xref__c xref1 = new Xref__c(
            Id = xRefId,
            External_ID__c = '123456',
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Integration_Status__c = 'Failure',
            Integration_Message__c = 'Currency is incorrect',
            Provisioning_Error_Category__c = 'Missing Data - Currency'
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IStatusReasonAndDetailsMappingsSelector mockStatusReasonsSelector = (IStatusReasonAndDetailsMappingsSelector) mocks.mock(
            IStatusReasonAndDetailsMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteSetupStoreWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.when(mockStatusReasonsSelector.sObjectType())
            .thenReturn(Status_Reason_And_Details_Mapping__mdt.SObjectType);
        mocks.when(mockStatusReasonsSelector.getAllMappings())
            .thenReturn(
                new List<Status_Reason_And_Details_Mapping__mdt>{ statusReasonAndDetailsMappings }
            );
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SELECTOR.setMock(mockStatusReasonsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateWorkStepsStatusOnXrefStatusChange(
            new List<Xref__c>{ xref1 }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => 'Blocked'
                    }
                )
            );
    }

    /**
     * @description To test WorkStep updates when Xref is Updated.
     */
    @isTest
    private static void testWhenXrefIsUpdatedToFailureThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );
        storeAccount.WorkOrders[0].Type__c = 'Drive';
        storeAccount.WorkOrders[0].WorkSteps[0].Type__c = 'Setup Store';

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id xRefId2 = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Xref__c xref1 = new Xref__c(
            Id = xRefId,
            External_ID__c = '123456',
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID_Source__c = WorkStepIntegrationStatusServiceImpl.XREF_EXTERNAL_SOURCE_DRIVE,
            Integration_Status__c = 'Failure'
        );
        Xref__c xref2 = new Xref__c(
            Id = xRefId2,
            External_ID__c = '123456',
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID_Source__c = WorkStepIntegrationStatusServiceImpl.XREF_EXTERNAL_SOURCE_MARKETPLACE,
            Integration_Status__c = 'Failure'
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteSetupStoreWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateWorkStepsStatusOnXrefStatusChange(
            new List<Xref__c>{ xref1, xref2 }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_ESCALATED,
                        WorkStep.Status_Reason__c => WORKSTEP_STORE_STATUS_REASON
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkPlanId,
                        WorkPlan.Xref__c => xRefId,
                        WorkPlan.Status__c => STATUS_ESCALATED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkOrderId,
                        WorkOrder.Provisioning_Status__c => WorkStepIntegrationStatusServiceImpl.WORK_ORDER_PROVISIONING_FAILED,
                        WorkOrder.Store_Id__c => '123456'
                    }
                )
            );
    }

    private static Account createParentAccountFake(
        Id parentWorkOrderId,
        Id parentOpportunityId,
        Id parentWorkPlanId
    ) {
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_PREMIUM)
            .setField(Account.RecordTypeID, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setFakeId()
            .setChildren(
                'WorkOrders',
                new List<Fake>{
                    new Fake(WorkOrder.class)
                        .setField(WorkOrder.Id, parentWorkOrderId)
                        .setField(
                            WorkOrder.Activated_Centrally_AC__c,
                            ACCOUNT_ACTIVATED_CENTRALLY_YES
                        )
                        .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                        .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                        .setField(WorkOrder.Status, STATUS_PLANNING)
                        .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                        .setChildren(
                            'WorkPlans',
                            new List<Fake>{
                                new Fake(WorkPlan.class)
                                    .setField(WorkPlan.Id, parentWorkPlanId)
                                    .setField(WorkPlan.Name, WORKORDER_TYPE_DRIVE)
                                    .setField(WorkPlan.Have_All_Stores_Activated__c, false)
                                    .setField(WorkPlan.Status__c, STATUS_NOT_WORKABLE)
                                    .setField(WorkPlan.WorkOrderId, parentWorkOrderId)
                                    .setField(
                                        WorkPlan.OwnerId,
                                        fflib_IDGenerator.generate(User.SObjectType)
                                    )
                                    .setField(WorkPlan.Owner.Name, WORKPLAN_OWNER_NAME)
                            }
                        )
                }
            )
            .toSObject();
        return parentAccount;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static Account createStoreAccountFake(
        Id parentAccountId,
        Id workOrderId,
        Id workStepId,
        Id workPlanId,
        Id parentOpportunityId,
        Id parentWorkPlanId,
        Id workPlanTemplateId,
        Id workStepTemplateId
    ) {
        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS_ACTIVE)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.RecordTypeID, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setFakeId()
            .setChildren(
                'WorkOrders',
                new List<Fake>{
                    new Fake(WorkOrder.class)
                        .setField(WorkOrder.Id, workOrderId)
                        .setField(
                            WorkOrder.Activated_Centrally_AC__c,
                            ACCOUNT_ACTIVATED_CENTRALLY_YES
                        )
                        .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                        .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                        .setField(WorkOrder.Status, STATUS_PLANNING)
                        .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                        .setChildren(
                            'WorkPlans',
                            new List<Fake>{
                                new Fake(WorkPlan.class)
                                    .setField(WorkPlan.Id, workPlanId)
                                    .setField(WorkPlan.Name, WORKORDER_TYPE_DRIVE)
                                    .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
                                    .setField(WorkPlan.Status__c, STATUS_NOT_WORKABLE)
                                    .setField(WorkPlan.WorkOrderId, workOrderId)
                                    .setField(
                                        WorkPlan.OwnerId,
                                        fflib_IDGenerator.generate(User.SObjectType)
                                    )
                                    .setField(WorkPlan.Owner.Name, WORKPLAN_OWNER_NAME)
                            }
                        )
                        .setChildren(
                            'WorkSteps',
                            new List<Fake>{
                                new Fake(WorkStep.class)
                                    .setField(WorkStep.Id, workStepId)
                                    .setField(WorkStep.Name, WORKORDER_TYPE_DRIVE)
                                    .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
                                    .setField(WorkStep.Type__c, 'Setup Business')
                                    .setField(WorkStep.WorkOrderId, workOrderId)
                                    .setField(WorkStep.WorkPlanId, workPlanId)
                                    .setParent(
                                        'WorkPlan',
                                        new Fake(WorkPlan.class)
                                            .setField(WorkPlan.Id, workPlanId)
                                            .setField(WorkPlan.Name, WORKORDER_TYPE_DRIVE)
                                            .setField(
                                                WorkPlan.Parent_Work_Plan__c,
                                                parentWorkPlanId
                                            )
                                            .setField(WorkPlan.Status__c, STATUS_NOT_WORKABLE)
                                            .setField(WorkPlan.WorkOrderId, workOrderId)
                                            .setField(
                                                WorkPlan.OwnerId,
                                                fflib_IDGenerator.generate(User.SObjectType)
                                            )
                                    )
                                    .setParent(
                                        'WorkOrder',
                                        new Fake(WorkOrder.class)
                                            .setField(WorkOrder.Id, workOrderId)
                                            .setField(
                                                WorkOrder.Activated_Centrally_AC__c,
                                                ACCOUNT_ACTIVATED_CENTRALLY_YES
                                            )
                                            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                                            .setField(
                                                WorkOrder.Proposed_Date_of_Activation__c,
                                                System.today()
                                            )
                                            .setField(WorkOrder.Status, STATUS_PLANNING)
                                            .setField(WorkOrder.Segment__c, SEGMENT_SMB)
                                            .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
                                    )
                                    .setParent(
                                        'WorkPlanTemplateEntry__r',
                                        new Fake(WorkPlanTemplateEntry.class)
                                            .setField(
                                                WorkPlanTemplateEntry.WorkPlanTemplateId,
                                                workPlanTemplateId
                                            )
                                            .setField(
                                                WorkPlanTemplateEntry.WorkStepTemplateId,
                                                workStepTemplateId
                                            )
                                            .setField(
                                                WorkPlanTemplateEntry.Work_Step_Default_Status__c,
                                                STATUS_NOT_STARTED
                                            )
                                    )
                            }
                        )
                }
            )
            .toSObject();
        return storeAccount;
    }
    /**
     * @description To test WorkOrder Status updates when Xref is Updated and do not update the workstep
     */
    @isTest
    private static void testWhenXrefIsUpdatedToSuccessThenUpdateWorkOrderStatusStoreFront() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );
        storeAccount.WorkOrders[0].Type__c = 'Storefront';
        storeAccount.WorkOrders[0].WorkSteps[0].Type__c = 'Setup Storefront Page';

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        Xref__c xref1 = new Xref__c(
            Id = xRefId,
            External_ID__c = '123456',
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID_Source__c = WorkStepIntegrationStatusServiceImpl.XREF_EXTERNAL_SOURCE_MARKETPLACE,
            Integration_Status__c = 'Success'
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteSetupStoreWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateWorkStepsStatusOnXrefStatusChange(
            new List<Xref__c>{ xref1 }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkStep updates when Business Reference is Updated to COO Success.
     */
    @isTest
    private static void testWhenBusinessReferenceIsUpdatedToStatusForCOOThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref1 = new Xref__c(
            Id = xRefId,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId
        );
        Business_Reference__c businessReference = new Business_Reference__c(
            Id = businessReferenceId,
            Integration_Status__c = SUCCESS
        );
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
        mocks.when(
                mockXrefSelector.selectAllMatchingBusinessReference(
                    new Set<Id>{ businessReferenceId }
                )
            )
            .thenReturn(new List<XRef__c>{ xref1 });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateWorkStepsStatusOnBusinessReferenceStatusChange(
            new Map<Id, Business_Reference__c>{ businessReferenceId => businessReference }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_COMPLETE,
                        WorkStep.Status_Reason__c => '',
                        WorkStep.Business_Reference__c => businessReferenceId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    /**
     * @description To test 'Setup Business' Work Step's Status, Status Reason
     * and Status Reason Detail is updated when Business Reference's Integration Status fails.
     */
    @isTest
    private static void testWhenBusinessReferenceFailsThenUpdateWorkStepStatusByStatusMappings() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);
        Id businessFriendlyMappingId = fflib_IDGenerator.generate(
            Business_Friendly_Mapping__mdt.SObjectType
        );
        Id bizRefId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Status_Reason_And_Details_Mapping__mdt statusReasonAndDetailsMappings = (Status_Reason_And_Details_Mapping__mdt) new Fake(
                Status_Reason_And_Details_Mapping__mdt.class
            )
            .setField(Status_Reason_And_Details_Mapping__mdt.Status__c, 'Blocked')
            .setField(Status_Reason_And_Details_Mapping__mdt.Status_Reason__c, 'Other')
            .setField(Status_Reason_And_Details_Mapping__mdt.Type__c, 'Setup Business')
            .setField(
                Status_Reason_And_Details_Mapping__mdt.Business_Friendly_Mapping__c,
                businessFriendlyMappingId
            )
            .setParent(
                'Business_Friendly_Mapping__r',
                new Fake(Business_Friendly_Mapping__mdt.class)
                    .setField(Business_Friendly_Mapping__mdt.id, businessFriendlyMappingId)
                    .setField(
                        Business_Friendly_Mapping__mdt.Integration_Key_String__c,
                        'in the global do not activate business id list'
                    )
                    .setField(
                        Business_Friendly_Mapping__mdt.Integration_Type__c,
                        'Business Reference Provisioning'
                    )
                    .setField(
                        Business_Friendly_Mapping__mdt.Message_Category__c,
                        'Global Do Not Activate'
                    )
                    .setField(Business_Friendly_Mapping__mdt.Order__c, 100)
                    .setField(Business_Friendly_Mapping__mdt.Active__c, true)
            )
            .setFakeId()
            .toSObject();

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );
        storeAccount.WorkOrders[0].Type__c = 'Marketplace';
        storeAccount.WorkOrders[0].WorkSteps[0].Type__c = 'Setup Business';
        Business_Reference__c businessReference = new Business_Reference__c(
            Id = bizRefId,
            External_ID__c = '123456',
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Integration_Status__c = 'Failure',
            Integration_Message__c = GLOBAL_DO_NOT_ACTIVATE_INTEGRATION_MESSAGE,
            Provisioning_Error_Category__c = 'Global Do Not Activate'
        );
        Xref__c xref = new Xref__c(
            Id = xRefId,
            Business_Reference__c = bizRefId,
            External_ID__c = '123456',
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IXrefsSelector mockXrefselector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IStatusReasonAndDetailsMappingsSelector mockStatusReasonsSelector = (IStatusReasonAndDetailsMappingsSelector) mocks.mock(
            IStatusReasonAndDetailsMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.when(mockStatusReasonsSelector.sObjectType())
            .thenReturn(Status_Reason_And_Details_Mapping__mdt.SObjectType);
        mocks.when(mockStatusReasonsSelector.getAllMappings())
            .thenReturn(
                new List<Status_Reason_And_Details_Mapping__mdt>{ statusReasonAndDetailsMappings }
            );
        mocks.when(mockXrefselector.selectAllMatchingBusinessReference(new Set<Id>{ bizRefId }))
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SELECTOR.setMock(mockStatusReasonsSelector);
        Application.SELECTOR.setMock(mockXrefselector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepIntegrationStatusService.updateWorkStepsStatusOnBusinessReferenceStatusChange(
            new Map<Id, Business_Reference__c>{ bizRefId => businessReference }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => 'Blocked',
                        WorkStep.Status_Reason_Details__c => GLOBAL_DO_NOT_ACTIVATE_INTEGRATION_MESSAGE
                    }
                )
            );
    }
    /**
     * @description To test Work Step status updates to "Ready for QA" when Segment is 'SMB' and
     * Type is 'Rate Change'.
     */
    @isTest
    private static void testWhenXrefUpdatedToSuccessThenUpdateRateChangeWorkStepStatusToReadyForQA() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);
        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );
        parentAccount.Segment__c = SEGMENT_SMB;
        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );
        storeAccount.WorkOrders[0].Type__c = WORKORDER_TYPE_DRIVE;
        storeAccount.Segment__c = SEGMENT_SMB;
        storeAccount.WorkOrders[0].WorkSteps[0].Type__c = WORKSTEP_TYPE_RATE_CHANGE;
        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Xref__c xrefInstance = new Xref__c(
            Id = xRefId,
            External_ID__c = EXTERNAL_ID,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID_Source__c = WorkStepIntegrationStatusServiceImpl.XREF_EXTERNAL_SOURCE_DRIVE,
            Integration_Status__c = SUCCESS
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteSetupStoreWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Test.startTest();
        WorkStepIntegrationStatusService.updateWorkStepsStatusOnXrefStatusChange(
            new List<Xref__c>{ xrefInstance }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_READY_FOR_QA
                    }
                )
            );
    }

    /**
     * @description To test Work Step status update initiates when Xref Ids received
     * by Onbaording Events.
     */
    @isTest
    private static void testWhenXrefIdsReceivedFromPlatformEventThenUpdateWorkStepStatus() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );

        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref = new Xref__c(
            Id = xRefId,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId
        );

        Business_Reference__c businessReference = new Business_reference__c(
            Id = businessReferenceId,
            Integration_Status__c = WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_SUCCESS
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector mockBusinessReferenceSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    WORK_STEP_STATUS_INTEGRATION_RETRY_LIMIT_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = WORK_STEP_STATUS_INTEGRATION_RETRY_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockBusinessReferenceSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessReferenceSelector.selectBydIdAndIntegrationStatus(
                    new Set<Id>{ businessReferenceId },
                    new Set<String>{
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_SUCCESS,
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_FAILURE,
                        BUSINESS_REF_STATUS_NEW,
                        BUSINESS_REF_STATUS_READY_FOR_INTEGRATION
                    }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefsSelector.selectById(new Set<Id>{ xref.Id }))
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SELECTOR.setMock(mockBusinessReferenceSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        Onboarding_Activation__e newOnboardingActivationEvent = new Onboarding_Activation__e(
            Topic__c = EVENT_TOPIC_UPDATE_WORK_STEPS_INTEGRATION_STATUS,
            Payload__c = JSON.serialize(new Set<Id>{ xref.Id })
        );
        Test.startTest();
        WorkStepIntegrationStatusService.execute(
            new List<Onboarding_Activation__e>{ newOnboardingActivationEvent }
        );
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_COMPLETE,
                        WorkStep.Business_Reference__c => businessReferenceId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    /**
     * @description To test Work Step status update retry initiates when Xref Ids received
     * by Onbaording Events for retry.
     */
    @isTest
    private static void testWhenXrefIdsReceivedFromPlatformEventThenRetryWorkStepStatusUpdate() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );

        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref = new Xref__c(
            Id = xRefId,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId
        );

        Business_Reference__c businessReference = new Business_reference__c(
            Id = businessReferenceId,
            Integration_Status__c = WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_SUCCESS
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector mockBusinessReferenceSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    WORK_STEP_STATUS_INTEGRATION_RETRY_LIMIT_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = WORK_STEP_STATUS_INTEGRATION_RETRY_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockBusinessReferenceSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessReferenceSelector.selectBydIdAndIntegrationStatus(
                    new Set<Id>{ businessReferenceId },
                    new Set<String>{
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_SUCCESS,
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_FAILURE,
                        BUSINESS_REF_STATUS_NEW,
                        BUSINESS_REF_STATUS_READY_FOR_INTEGRATION
                    }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefsSelector.selectById(new Set<Id>{ xref.Id }))
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SELECTOR.setMock(mockBusinessReferenceSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepStatusEntry workStepStatusEntryInstance = new WorkStepStatusEntry(new Set<Id>(), 1);
        workStepStatusEntryInstance.xrefIds = new Set<Id>{ xref.Id };
        Onboarding_Activation__e newOnboardingActivationEvent = new Onboarding_Activation__e(
            Topic__c = EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_INTEGRATION,
            Payload__c = JSON.serialize(workStepStatusEntryInstance)
        );
        Test.startTest();
        WorkStepIntegrationStatusService.execute(
            new List<Onboarding_Activation__e>{ newOnboardingActivationEvent }
        );
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => storeAccount.WorkOrders[0].WorkSteps[0].Id,
                        WorkStep.Status__c => STATUS_COMPLETE,
                        WorkStep.Business_Reference__c => businessReferenceId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Id => storeAccount.WorkOrders[0].WorkSteps[0].WorkPlanId,
                        WorkPlan.Business_Reference__c => businessReferenceId
                    }
                )
            );
    }

    /**
     * @description To test retry event is triggered when exception occurs
     * while Work Step status update.
     */
    @isTest
    private static void testWhenExceptionOccursThenRetryWorkStepStatusUpdate() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );

        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref = new Xref__c(
            Id = xRefId,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId
        );

        Business_Reference__c businessReference = new Business_reference__c(
            Id = businessReferenceId,
            Integration_Status__c = WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_SUCCESS
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector mockBusinessReferenceSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IOnboardingActivationsEventsService onboardingActivationsEventsServiceMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    WORK_STEP_STATUS_INTEGRATION_RETRY_LIMIT_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = WORK_STEP_STATUS_INTEGRATION_RETRY_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockBusinessReferenceSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessReferenceSelector.selectBydIdAndIntegrationStatus(
                    new Set<Id>{ businessReferenceId },
                    new Set<String>{
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_SUCCESS,
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_FAILURE,
                        BUSINESS_REF_STATUS_NEW,
                        BUSINESS_REF_STATUS_READY_FOR_INTEGRATION
                    }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefsSelector.selectById(new Set<Id>{ xref.Id }))
            .thenReturn(new List<Xref__c>{ xref });
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsServiceMock
        );
        Application.SELECTOR.setMock(mockBusinessReferenceSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepStatusEntry workStepStatusEntryInstance = new WorkStepStatusEntry(new Set<Id>(), 1);
        workStepStatusEntryInstance.xrefIds = new Set<Id>{ xref.Id };
        Onboarding_Activation__e newOnboardingActivationEvent = new Onboarding_Activation__e(
            Topic__c = EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_INTEGRATION,
            Payload__c = JSON.serialize(workStepStatusEntryInstance)
        );
        String exceptionMessage;
        Test.startTest();
        try {
            WorkStepIntegrationStatusService.execute(
                new List<Onboarding_Activation__e>{ newOnboardingActivationEvent }
            );
        } catch (Exception mockException) {
            exceptionMessage =
                mockException.getMessage() +
                PIPELINE_SEPARATOR +
                CURRENT_RETRY_COUNT +
                1;
        }
        Test.stopTest();
        workStepStatusEntryInstance.retryCount = 2;
        ((IOnboardingActivationsEventsService) mocks.verify(
                onboardingActivationsEventsServiceMock,
                1
            ))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_INTEGRATION => JSON.serialize(
                        workStepStatusEntryInstance
                    )
                }
            );
    }

    /**
     * @description To test Error Log is created when retry limit exceeds due to exception.
     */
    @isTest
    private static void testWhenRetryLimitExceedsThenCreateErrorLog() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = OPPORTUNITY_CLOSE_DATE,
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );

        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunity.Id,
            parentWorkPlanId
        );

        Account storeAccount = createStoreAccountFake(
            parentAccount.Id,
            workOrderId,
            workStepId,
            workPlanId,
            parentOpportunity.Id,
            parentWorkPlanId,
            workPlanTemplateId,
            workStepTemplateId
        );

        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref = new Xref__c(
            Id = xRefId,
            Salesforce_Account_Name__c = storeAccount.Id,
            Business_Reference__c = businessReferenceId
        );

        Business_Reference__c businessReference = new Business_reference__c(
            Id = businessReferenceId,
            Integration_Status__c = WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_SUCCESS
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector mockBusinessReferenceSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IOnboardingActivationsEventsService onboardingActivationsEventsServiceMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    WORK_STEP_STATUS_INTEGRATION_RETRY_LIMIT_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = WORK_STEP_STATUS_INTEGRATION_RETRY_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockBusinessReferenceSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessReferenceSelector.selectBydIdAndIntegrationStatus(
                    new Set<Id>{ businessReferenceId },
                    new Set<String>{
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_SUCCESS,
                        WorkStepIntegrationStatusServiceImpl.BUSINESS_REF_STATUS_FAILURE,
                        BUSINESS_REF_STATUS_NEW,
                        BUSINESS_REF_STATUS_READY_FOR_INTEGRATION
                    }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ storeAccount.WorkOrders[0].WorkSteps[0] });
        mocks.when(
                mockWorkStepsSelector.getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefsSelector.selectById(new Set<Id>{ xref.Id }))
            .thenReturn(new List<Xref__c>{ xref });
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsServiceMock
        );
        Application.SELECTOR.setMock(mockBusinessReferenceSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);

        storeAccount.WorkOrders[0].WorkSteps[0].Store_Account__c = storeAccount.Id;
        WorkStepStatusEntry workStepStatusEntryInstance = new WorkStepStatusEntry(new Set<Id>(), 3);
        workStepStatusEntryInstance.xrefIds = new Set<Id>{ xref.Id };
        Onboarding_Activation__e newOnboardingActivationEvent = new Onboarding_Activation__e(
            Topic__c = EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_INTEGRATION,
            Payload__c = JSON.serialize(workStepStatusEntryInstance)
        );
        String exceptionMessage;
        Test.startTest();
        try {
            WorkStepIntegrationStatusService.execute(
                new List<Onboarding_Activation__e>{ newOnboardingActivationEvent }
            );
        } catch (Exception mockException) {
            exceptionMessage =
                mockException.getMessage() +
                PIPELINE_SEPARATOR +
                CURRENT_RETRY_COUNT +
                3 +
                PIPELINE_SEPARATOR +
                EXCEEDED_MAXIMUM_RETRY_LIMIT_ERROR_MESSAGE;
        }
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Log__c.Detailed_Message__c => exceptionMessage }
                )
            );
        workStepStatusEntryInstance.retryCount = 4;
        ((IOnboardingActivationsEventsService) mocks.verify(
                onboardingActivationsEventsServiceMock,
                0
            ))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_INTEGRATION => JSON.serialize(
                        workStepStatusEntryInstance
                    )
                }
            );
    }
}