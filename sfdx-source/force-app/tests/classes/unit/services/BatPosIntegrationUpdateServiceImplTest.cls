/**
 * @author DoorDash
 * @date 03/21/2023
 * @description Test class for IntegrationRequests class.
 * TDD: https://docs.google.com/document/d/1uEpdSlwXHU_7_uLElwKtre6W_71GhFiCaRhhRR8wc0E/edit
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssTypeCount')
public inherited sharing class BatPosIntegrationUpdateServiceImplTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String PROVISIONING_STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_PLAN_STATUS_NOT_STARTED = 'Not Started';
    private static final String IR_UPDATE = 'UPDATE';
    private static final String EVENT_TOPIC_PROCESS_UPDATE_POS_INTEGRATION_REQUEST = 'PROCESS_UPDATE_POS_INTEGRATION_REQUEST';
    private static final String BAT_STATUS_MENU_BLOCK = 'MENU_BLOCK';
    private static final String EXCLUSION_CODE_MENU_FAILURE = 'MENU_COMPLIANCE_FAILURE';
    private static final String WORK_STEP_INGEST_MENU = 'Ingest Menu';
    private static final String WORK_STEP_QA_MENU = 'QA Menu';
    private static final String WORK_STEP_STATUS_ESCALATED = 'Escalated';
    private static final String STATUS_REASON_MENU_FAILURE = 'Menu Compliance failure';
    private static final String STATUS_REASON_POS_INGESTION_FAILURE = 'POS Ingestion failure';

    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_ACCOUNT_OWNER_EMAIL = 'test@WorkOrdersTest.com';
    private static final String TYPE_POS = 'POS';
    private static final String IR_SFDC_STATUS_PROCESSED = 'Processed';
    private static final String STORE_ID = '24680';
    private static final String DML_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String UNEXPECTED_DML_EXCEPTION_MESSAGE =
    'Unexpected Error: The Exception fired was not a TestCommitException.';

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssMethodCount')
    private static void testWhenUpdateIntegrationRequestReceivedThenUpdateTheWorkSteps() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Fake businessAccountFakeInstance = createParentAccount();
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake childAccountFakeInstance = createChildAccountInstance(businessAccount.Id, businessAccountFakeInstance);

        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );

        xref__c xref = createXrefFakeInstance(storeAccount.Id);
        Fake integrationRequestFakeInstance = createIntegrationRequestFakeInstance();
        Fake irUpdateQaMenuWorkStepFake  = createIntegrationRequestFakeInstance()
        .setField(Integration_Request__c.Action__c, IR_UPDATE)
        .setField(Integration_Request__c.Target_Status__c, BAT_STATUS_MENU_BLOCK)
        .setField(Integration_Request__c.Exclusion_Code__c, EXCLUSION_CODE_MENU_FAILURE);

        Fake irUpdateIngestMenuWorkStepFake  = createIntegrationRequestFakeInstance()
        .setField(Integration_Request__c.Action__c, IR_UPDATE)
        .setField(Integration_Request__c.Target_Status__c, BAT_STATUS_MENU_BLOCK)
        .setField(Integration_Request__c.Exclusion_Code__c, '');


        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Associated_Account_Ids__c, String.valueOf(storeAccount.Id))
            .setParent('Account', businessAccountFakeInstance);

        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED)
            .setParent('Account', childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setChildren(
                'WorkSteps',
                new List<Fake>{ new Fake(WorkStep.class).setField(WorkStep.Id, workStepId) }
            );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( childWorkOrderFakeInstance );
        //parent workplans--

        Fake parentPosWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance( parentWorkOrder.Id )
            .setField(WorkPlan.Type__c, TYPE_POS);

        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ parentPosWorkPlanFakeInstance }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( parentWorkOrderFakeInstance );
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject( parentPosWorkPlanFakeInstance );
        Integration_Request__c integrationRequestInstance = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( integrationRequestFakeInstance);

        //child pos workplans
        Fake childPosWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance( childWorkOrder.Id )
            .setField(WorkPlan.Type__c, TYPE_POS)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlan.Id)
            .setField(WorkPlan.Integration_Request__c, integrationRequestInstance.Id)
            .setParent('Integration_Request__r', integrationRequestFakeInstance);

        childWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ childPosWorkPlanFakeInstance }
        );
        childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( childWorkOrderFakeInstance );
        WorkPlan childWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject( childPosWorkPlanFakeInstance );

        List<Fake> workStepsFakeInstances = new List<Fake>();
        workStepsFakeInstances = ServiceMockDataBuilder.generatePosWorkSteps(
            childWorkPlan.Id,
            childWorkOrder.Id,
            WORK_PLAN_STATUS_NOT_STARTED,
            childPosWorkPlanFakeInstance
            );
        childPosWorkPlanFakeInstance.setChildren('WorkSteps', workStepsFakeInstances);

        List<Bat_To_WorkSteps_Status_Mapping__mdt> settingList = getBatToWorkStepMapping();

        List<WorkStep> workSteps = new List<WorkStep>();
        for(Fake eachFakeInstance: workStepsFakeInstances){
            workSteps.add((WorkStep)ServiceMockDataBuilder.convertToSObject(eachFakeInstance));
        }
        WorkPlan childPosWorkPlanInstance = (WorkPlan) ServiceMockDataBuilder.convertToSObject(childPosWorkPlanFakeInstance);
        Integration_Request__c irUpdateQaMenuWorkStep = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( irUpdateQaMenuWorkStepFake);
        Integration_Request__c irUpdateIngestMenuWorkStep = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( irUpdateIngestMenuWorkStepFake);

        Set<String> irStatus = new Set<String>{IR_SFDC_STATUS_PROCESSED};
        //--- return Lists
        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>{ integrationRequestInstance };
        List<Integration_Request__c> integrationRequestUpdateList = new List<Integration_Request__c>{ irUpdateQaMenuWorkStep, irUpdateIngestMenuWorkStep};


        List<Xref__c> xrefList = new List<Xref__c>{ xref };
        List<Account> storeAccounts = new List<Account>{ storeAccount };
        List<WorkPlan> workPlanList = new List<WorkPlan>{ childPosWorkPlanInstance };
        //-------- mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IWorkPlansSelector workPlanSelectorMock = (IWorkPlansSelector) mocks.mock(IWorkPlansSelector.class);
        IBatToWorkStepsStatusMappingSelector metaDataMappingSelector =
            (IBatToWorkStepsStatusMappingSelector) mocks.mock(BatToWorkStepsStatusMappingSelector.class);

        mocks.startStubbing();
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectXrefsByStoreIds(new Set<String>{STORE_ID})).thenReturn(xrefList);

        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{storeAccount.Id})).thenReturn(storeAccounts);

        mocks.when(integrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(integrationSelectorMock.selectById(new Set<Id>{irUpdateQaMenuWorkStep.Id, irUpdateIngestMenuWorkStep.Id}))
            .thenReturn(integrationRequestUpdateList);

        mocks.when(integrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(integrationSelectorMock.selectByOnboardingId(new Set<String>{integrationRequestInstance.Onboarding_Id__c}, irStatus))
            .thenReturn(integrationRequestList);

        mocks.when(workPlanSelectorMock.SObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(workPlanSelectorMock.selectWorkPlansByIntegrationRequestId(new Set<Id>{integrationRequestInstance.Id})).thenReturn(workPlanList);

        mocks.when(metaDataMappingSelector.SObjectType()).thenReturn(Bat_To_WorkSteps_Status_Mapping__mdt.SObjectType);
        mocks.when(metaDataMappingSelector.getAllValues()).thenReturn(settingList);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.SELECTOR.setMock(workPlanSelectorMock);
        Application.SELECTOR.setMock(metaDataMappingSelector);
        Application.UnitOfWork.setMock(mockUow);
        //---------- execute
        String eventPayload = JSON.serialize(new Set<Id>{ irUpdateQaMenuWorkStep.Id, irUpdateIngestMenuWorkStep.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_PROCESS_UPDATE_POS_INTEGRATION_REQUEST
        );
        BatPosIntegrationUpdateService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Type__c => WORK_STEP_INGEST_MENU,
                        WorkStep.Status => WORK_STEP_STATUS_ESCALATED
                    }
                )
            );
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Type__c => WORK_STEP_QA_MENU,
                        WorkStep.Status => WORK_STEP_STATUS_ESCALATED
                    }
                )
            );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssMethodCount')
    private static void testWhenIntegrationRequestReceviedThenExeptionThrown() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Fake businessAccountFakeInstance = createParentAccount();
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake childAccountFakeInstance = createChildAccountInstance(businessAccount.Id, businessAccountFakeInstance);

        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );

        xref__c xref = createXrefFakeInstance(storeAccount.Id);
        Fake integrationRequestFakeInstance = createIntegrationRequestFakeInstance();
        Fake irUpdateQaMenuWorkStepFake  = createIntegrationRequestFakeInstance()
        .setField(Integration_Request__c.Action__c, IR_UPDATE)
        .setField(Integration_Request__c.Target_Status__c, BAT_STATUS_MENU_BLOCK)
        .setField(Integration_Request__c.Exclusion_Code__c, EXCLUSION_CODE_MENU_FAILURE);

        Fake irUpdateIngestMenuWorkStepFake  = createIntegrationRequestFakeInstance()
        .setField(Integration_Request__c.Action__c, IR_UPDATE)
        .setField(Integration_Request__c.Target_Status__c, BAT_STATUS_MENU_BLOCK)
        .setField(Integration_Request__c.Exclusion_Code__c, '');


        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Associated_Account_Ids__c, String.valueOf(storeAccount.Id))
            .setParent('Account', businessAccountFakeInstance);

        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED)
            .setParent('Account', childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setChildren(
                'WorkSteps',
                new List<Fake>{ new Fake(WorkStep.class).setField(WorkStep.Id, workStepId) }
            );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( childWorkOrderFakeInstance );
        //parent workplans--

        Fake parentPosWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance( parentWorkOrder.Id )
            .setField(WorkPlan.Type__c, TYPE_POS);

        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ parentPosWorkPlanFakeInstance }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( parentWorkOrderFakeInstance );
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject( parentPosWorkPlanFakeInstance );
        Integration_Request__c integrationRequestInstance = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( integrationRequestFakeInstance);

        //child pos workplans
        Fake childPosWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance( childWorkOrder.Id )
            .setField(WorkPlan.Type__c, TYPE_POS)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlan.Id)
            .setField(WorkPlan.Integration_Request__c, integrationRequestInstance.Id)
            .setParent('Integration_Request__r', integrationRequestFakeInstance);

        childWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ childPosWorkPlanFakeInstance }
        );
        childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( childWorkOrderFakeInstance );
        WorkPlan childWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject( childPosWorkPlanFakeInstance );

        List<Fake> workStepsFakeInstances = new List<Fake>();
        workStepsFakeInstances = ServiceMockDataBuilder.generatePosWorkSteps(
            childWorkPlan.Id,
            childWorkOrder.Id,
            WORK_PLAN_STATUS_NOT_STARTED,
            childPosWorkPlanFakeInstance
            );
        childPosWorkPlanFakeInstance.setChildren('WorkSteps', workStepsFakeInstances);

        List<Bat_To_WorkSteps_Status_Mapping__mdt> settingList = getBatToWorkStepMapping();

        List<WorkStep> workSteps = new List<WorkStep>();
        for(Fake eachFakeInstance: workStepsFakeInstances){
            workSteps.add((WorkStep)ServiceMockDataBuilder.convertToSObject(eachFakeInstance));
        }
        WorkPlan childPosWorkPlanInstance = (WorkPlan) ServiceMockDataBuilder.convertToSObject(childPosWorkPlanFakeInstance);
        Integration_Request__c irUpdateQaMenuWorkStep = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( irUpdateQaMenuWorkStepFake);
        Integration_Request__c irUpdateIngestMenuWorkStep = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( irUpdateIngestMenuWorkStepFake);

        Set<String> irStatus = new Set<String>{IR_SFDC_STATUS_PROCESSED};
        //--- return Lists
        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>{ integrationRequestInstance };
        List<Integration_Request__c> integrationRequestUpdateList = new List<Integration_Request__c>{ irUpdateQaMenuWorkStep, irUpdateIngestMenuWorkStep};


        List<Xref__c> xrefList = new List<Xref__c>{ xref };
        List<Account> storeAccounts = new List<Account>{ storeAccount };
        List<WorkPlan> workPlanList = new List<WorkPlan>{ childPosWorkPlanInstance };
        //-------- mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IWorkPlansSelector workPlanSelectorMock = (IWorkPlansSelector) mocks.mock(IWorkPlansSelector.class);
        IBatToWorkStepsStatusMappingSelector metaDataMappingSelector =
            (IBatToWorkStepsStatusMappingSelector) mocks.mock(BatToWorkStepsStatusMappingSelector.class);

        mocks.startStubbing();
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectXrefsByStoreIds(new Set<String>{STORE_ID})).thenReturn(xrefList);

        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{storeAccount.Id})).thenReturn(storeAccounts);

        mocks.when(integrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(integrationSelectorMock.selectById(new Set<Id>{irUpdateQaMenuWorkStep.Id, irUpdateIngestMenuWorkStep.Id}))
            .thenReturn(integrationRequestUpdateList);

        mocks.when(integrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(integrationSelectorMock.selectByOnboardingId(new Set<String>{integrationRequestInstance.Onboarding_Id__c}, irStatus))
            .thenReturn(integrationRequestList);

        mocks.when(workPlanSelectorMock.SObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(workPlanSelectorMock.selectWorkPlansByIntegrationRequestId(new Set<Id>{integrationRequestInstance.Id})).thenReturn(workPlanList);

        mocks.when(metaDataMappingSelector.SObjectType()).thenReturn(Bat_To_WorkSteps_Status_Mapping__mdt.SObjectType);
        mocks.when(metaDataMappingSelector.getAllValues()).thenReturn(settingList);
        ((fflib_ISObjectUnitOfWork)mocks.doThrowWhen(new TestCommitException(DML_EXCEPTION_MESSAGE) , mockUOW)).commitWork();


        mocks.stopStubbing();

        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.SELECTOR.setMock(workPlanSelectorMock);
        Application.SELECTOR.setMock(metaDataMappingSelector);
        Application.UnitOfWork.setMock(mockUow);
        //---------- execute
        String eventPayload = JSON.serialize(new Set<Id>{ irUpdateQaMenuWorkStep.Id, irUpdateIngestMenuWorkStep.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_PROCESS_UPDATE_POS_INTEGRATION_REQUEST
        );

        try{
            BatPosIntegrationUpdateService.execute(new List<Notifier__e>{ mockNotifierEvent });
        }catch(Exception e){
            // veriry
            System.assertEquals(DML_EXCEPTION_MESSAGE, e.getMessage(), UNEXPECTED_DML_EXCEPTION_MESSAGE);
        }
    }

    private static Fake createIntegrationRequestFakeInstance(){
        return ServiceMockDataBuilder.createIntegrationRequestFakeInstance(STORE_ID);
    }

    private static Integration_request__c getIntegrationRequestInstance(){
        return  (Integration_request__c) ServiceMockDataBuilder.convertToSObject( createIntegrationRequestFakeInstance());
    }
    private static Xref__c createXrefFakeInstance(String storeAccountId){
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        return new Xref__c(
            Id = xrefId,
            Salesforce_Account_Name__c = storeAccountId,
            External_ID__c = STORE_ID
        );
    }

    private static Fake createParentAccount(){
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        return parentAccountFakeInstance;
    }
    private static Fake createChildAccountInstance(Id businessAccountId, Fake parentAccountFakeInstance){
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Order_Protocol__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', parentAccountFakeInstance);

        return childAccountFakeInstance ;
    }
    private static List<Bat_To_WorkSteps_Status_Mapping__mdt> getBatToWorkStepMapping(){
        return new List<Bat_To_WorkSteps_Status_Mapping__mdt>{
            new Bat_To_WorkSteps_Status_Mapping__mdt(
                Label = 'Work Plan Mapping',
                DeveloperName = 'Work_Pan_Mapping_1',
                Bat_Status__c = BAT_STATUS_MENU_BLOCK,
                Exclusion_Code__c = '',
                Status_Reason__c = STATUS_REASON_POS_INGESTION_FAILURE,
                Work_Step_Status__c = WORK_STEP_STATUS_ESCALATED,
                Work_Step_Type__c = WORK_STEP_INGEST_MENU
            ),
            new Bat_To_WorkSteps_Status_Mapping__mdt(
                Label = 'Work Plan Mapping',
                DeveloperName = 'Work_Pan_Mapping_2',
                Bat_Status__c = BAT_STATUS_MENU_BLOCK,
                Exclusion_Code__c = EXCLUSION_CODE_MENU_FAILURE,
                Status_Reason__c = STATUS_REASON_MENU_FAILURE,
                Work_Step_Status__c = WORK_STEP_STATUS_ESCALATED,
                Work_Step_Type__c = WORK_STEP_QA_MENU
            )
        };
    }
}