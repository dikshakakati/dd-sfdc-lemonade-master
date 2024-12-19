/**
 * @author DoorDash
 * @date 03/25/2023
 * @description Test class for PosIntegrationRequestsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssTypeCount')
public class PosIntegrationRequestsServiceImplTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String PROVISIONING_STATUS_NOT_STARTED = 'Not Started';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_ACCOUNT_OWNER_EMAIL = 'test@WorkOrdersTest.com';
    private static final String EVENT_TOPIC_PROCESS_NEW_POS_INTEGRATION_REQUEST = 'PROCESS_NEW_POS_INTEGRATION_REQUEST';
    private static final String EVENT_TOPIC_MAKE_WORK_PLAN_CURRENT= 'MAKE_WORK_PLAN_CURRENT';
    private static final String TYPE_POS = 'POS';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_MARKET_PLACE = 'Marketplace';
    private static final String IR_SFDC_STATUS_PROCESSED = 'Processed';
    private static final String IR_SFDC_STATUS_PENDING = 'Pending';

    private static final String BAT_STATUS_MENU_BLOCK = 'MENU_BLOCK';
    private static final String EXCLUSION_CODE_MENU_FAILURE = 'MENU_COMPLIANCE_FAILURE';
    private static final String IR_UPDATE = 'UPDATE';
    private static final Set<String> WO_OPEN_STATUS =
        new Set<String>{'Planning', 'Confirmed', 'In Progress', 'At Risk', 'Past Due', 'Not Started'};
    public Map<String, String> orderProtocolOldVsNew = new Map<String, String>{
        'Android Tablet (Merchant Owns)' => 'POS',
        'Email' => 'POS',
        'Fax' => 'POS',
        'Other' => 'POS',
        'Tablet (DoorDash Owns)' => 'POS and and Tablet (DoorDash Owns)',
        'Tablet and Printer (DoorDash Owns)' => 'POS and and Tablet (DoorDash Owns)',
        'Tablet (Caviar Owns)'=>'POS and Tablet (Caviar Owns)'
    };
    private static final String STORE_ID = '24680';
    private static final String INTEGRATION_ID = '112223344';
    private static final String LATEST_INTEGRATION_ID = '88293923';
    private static final String DML_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String UNEXPECTED_DML_EXCEPTION_MESSAGE =
    'Unexpected Error: The Exception fired was not a TestCommitException.';
    private static final String POS_INTEGRATION_TYPE_SQUARE = 'square';
    @isTest
    private static void testWhenIntegrationRequestReceviedThenExeptionThrown() {
        //setup data
        Fake businessAccountFakeInstance = createParentAccount();
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake childAccountFakeInstance = createChildAccountInstance(businessAccount.Id, businessAccountFakeInstance);

        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        xref__c xref = createXrefFakeInstance(storeAccount.Id);
        Integration_request__c integrationRequest = getIntegrationRequestInstance();
        //return Lists
        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>{ integrationRequest };
        List<Xref__c> xrefList = new List<Xref__c>{ xref };
        List<Account> storeAccounts = new List<Account>{ storeAccount };
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);


        mocks.startStubbing();
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectXrefsByStoreIds(new Set<String>{STORE_ID})).thenReturn(xrefList);

        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{storeAccount.Id})).thenReturn(storeAccounts);

        mocks.when(integrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(integrationSelectorMock.selectById(new Set<Id>{integrationRequest.Id})).thenReturn(integrationRequestList);
        ((fflib_ISObjectUnitOfWork)mocks.doThrowWhen(new TestCommitException(DML_EXCEPTION_MESSAGE) , mockUOW)).commitWork();

        mocks.stopStubbing();

        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.UnitOfWork.setMock(mockUow);
        // execute
        String eventPayload = JSON.serialize(new Set<Id>{ integrationRequest.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_PROCESS_NEW_POS_INTEGRATION_REQUEST
        );
        try{
        PosIntegrationRequestsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        }catch(Exception e){
            // veriry
            System.assertEquals(DML_EXCEPTION_MESSAGE, e.getMessage(), UNEXPECTED_DML_EXCEPTION_MESSAGE);
        }
    }
    @isTest
    private static void testWhenIntegrationRequestReceviedThenCreatePosParentWorkOrder() {
        //setup data
        Fake businessAccountFakeInstance = createParentAccount();
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake childAccountFakeInstance = createChildAccountInstance(businessAccount.Id, businessAccountFakeInstance);

        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        xref__c xref = createXrefFakeInstance(storeAccount.Id);
        Integration_request__c integrationRequest = getIntegrationRequestInstance();
        // return Lists
        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>{ integrationRequest };
        List<Xref__c> xrefList = new List<Xref__c>{ xref };
        List<Account> storeAccounts = new List<Account>{ storeAccount };
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        mocks.startStubbing();
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectXrefsByStoreIds(new Set<String>{STORE_ID})).thenReturn(xrefList);

        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{storeAccount.Id})).thenReturn(storeAccounts);

        mocks.when(integrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(integrationSelectorMock.selectById(new Set<Id>{integrationRequest.Id})).thenReturn(integrationRequestList);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.UnitOfWork.setMock(mockUow);
        //---------- execute
        String eventPayload = JSON.serialize(new Set<Id>{ integrationRequest.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_PROCESS_NEW_POS_INTEGRATION_REQUEST
        );
        PosIntegrationRequestsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        //verify
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerUpsert(fflib_Match.sObjectsWith(
            new List<Map<SObjectField, Object>>{
                new Map<SObjectField, Object>{
                    Account.POS_Integration_ID__c => INTEGRATION_ID
                }
            }
        ));
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerUpsert(fflib_Match.sObjectsWith(
            new List<Map<SObjectField, Object>>{
                new Map<SObjectField, Object>{
                    WorkOrder.Type__c => TYPE_POS,
                    WorkOrder.Integration_Request_Ids__c =>  String.valueOf(integrationRequest.Id),
                    WorkOrder.Associated_Account_Ids__c =>  String.valueOf(storeAccount.Id)
                }
            }
        ));
    }
    @isTest
    private static void testWhenRequestReceivedUpdateParentThenChildMoWoForWpCreation() {
        //mock data
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
        Integration_request__c integrationRequest = getIntegrationRequestInstance();
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
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
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );

        //selector inputs
        Set<String> validTypes = new Set<String>{TYPE_POS, TYPE_MARKET_PLACE, TYPE_COO};
        Set<Id> accountIds = new Set<Id>{storeAccount.Id, businessAccount.Id};

        //return lists
        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>{ integrationRequest };
        List<Xref__c> xrefList = new List<Xref__c>{ xref };
        List<Account> storeAccounts = new List<Account>{ storeAccount };
        List<WorkOrder> workOrders = new List<WorkOrder>{ childWorkOrder, parentWorkOrder };

        //--- stubbing
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(IWorkOrdersSelector.class);

        mocks.startStubbing();
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectXrefsByStoreIds(new Set<String>{STORE_ID})).thenReturn(xrefList);

        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{storeAccount.Id})).thenReturn(storeAccounts);

        mocks.when(IntegrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(IntegrationSelectorMock.selectById(new Set<Id>{integrationRequest.Id})).thenReturn(integrationRequestList);

        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersAndWorkPlansByAccountIdsAndStatusAndType(accountIds, WO_OPEN_STATUS, validTypes)).thenReturn(workOrders);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UnitOfWork.setMock(mockUow);
        //----- execute
        String eventPayload = JSON.serialize(new Set<Id>{ integrationRequest.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_PROCESS_NEW_POS_INTEGRATION_REQUEST
        );
        PosIntegrationRequestsService.execute(new List<Notifier__e>{ mockNotifierEvent });

        //-- verify
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerUpsert(fflib_Match.sObjectsWith(
            new List<Map<SObjectField, Object>>{
                new Map<SObjectField, Object>{
                    Account.POS_Integration_ID__c => INTEGRATION_ID
                }
            }
        ));
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerUpsert(fflib_Match.sObjectsWith(
            new List<Map<SObjectField, Object>>{
                new Map<SObjectField, Object>{
                    WorkOrder.Id =>  childWorkOrder.Id,
                    WorkOrder.Integration_Request_Ids__c =>  String.valueOf(integrationRequest.Id)
                },
                new Map<SObjectField, Object>{
                    WorkOrder.Id =>  parentWorkOrder.Id,
                    WorkOrder.Integration_Request_Ids__c =>  String.valueOf(integrationRequest.Id)
                }
            }
        ));
    }

    @isTest
    private static void testWhenRequestReceivedThenUpdateChildWoForWpCreationAndUpdateExistingWp() {
        //mock data
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
        Fake updatedIntegrationRequestFakeInstance = createIntegrationRequestFakeInstance();
        updatedIntegrationRequestFakeInstance.setField(Integration_Request__c.Integration_Id__c, LATEST_INTEGRATION_ID);
        Integration_Request__c updatedIntegrationRequest = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( updatedIntegrationRequestFakeInstance );
        Integration_Request__c integrationRequestInstance = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( integrationRequestFakeInstance);

        // mock work orders
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
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
        //paren workplans--
        Fake parentPosWorkPlan = ServiceMockDataBuilder.createWorkPlanFakeInstance( parentWorkOrder.Id )
            .setField(WorkPlan.Type__c, TYPE_POS);
        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ parentPosWorkPlan }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( parentWorkOrderFakeInstance );
        //parent pos work plans
        Fake parentPosWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance( parentWorkOrder.Id )
            .setField(WorkPlan.Type__c, TYPE_POS);

        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ parentPosWorkPlanFakeInstance }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( parentWorkOrderFakeInstance );
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject( parentPosWorkPlanFakeInstance );

        //child workplans--
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

        //selector inputs
        Set<String> validTypes = new Set<String>{TYPE_POS, TYPE_MARKET_PLACE, TYPE_COO};
        Set<Id> accountIds = new Set<Id>{storeAccount.Id, businessAccount.Id};

        // return lists
        List<Integration_Request__c> updatedIntegrationRequestList = new List<Integration_Request__c>{ updatedIntegrationRequest };

        List<Xref__c> xrefList = new List<Xref__c>{ xref };
        List<Account> storeAccounts = new List<Account>{ storeAccount };
        List<WorkOrder> workOrders = new List<WorkOrder>{ childWorkOrder, parentWorkOrder };

        //stubbing
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IExternalNotifierEventsService externalNotifierServiceMock = (IExternalNotifierEventsService) mocks.mock(
            IExternalNotifierEventsService.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(IWorkOrdersSelector.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectXrefsByStoreIds(new Set<String>{STORE_ID})).thenReturn(xrefList);

        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{storeAccount.Id})).thenReturn(storeAccounts);

        mocks.when(IntegrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(IntegrationSelectorMock.selectById(new Set<Id>{updatedIntegrationRequest.Id})).thenReturn(updatedIntegrationRequestList);

        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersAndWorkPlansByAccountIdsAndStatusAndType(accountIds, WO_OPEN_STATUS, validTypes)).thenReturn(workOrders);

        mocks.stopStubbing();


        Application.SERVICE.setMock(
            IExternalNotifierEventsService.class,
            externalNotifierServiceMock
        );
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UnitOfWork.setMock(mockUow);
        //----- execute
        String eventPayload = JSON.serialize(new Set<Id>{ updatedIntegrationRequest.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_PROCESS_NEW_POS_INTEGRATION_REQUEST
        );
        PosIntegrationRequestsService.execute(new List<Notifier__e>{ mockNotifierEvent });

        //-- verify
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerUpsert(fflib_Match.sObjectsWith(
            new List<Map<SObjectField, Object>>{
                new Map<SObjectField, Object>{
                    Account.POS_Integration_ID__c => LATEST_INTEGRATION_ID
                }
            }
        ));

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerUpsert(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkPlan.Deprecated__c => true
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerUpsert(fflib_Match.sObjectsWith(
            new List<Map<SObjectField, Object>>{
                    new Map<SObjectField, Object>{
                        WorkOrder.Id =>  childWorkOrder.Id,
                        WorkOrder.Integration_Request_Ids__c =>  String.valueOf(updatedIntegrationRequest.Id)
                    }
                }
             ));
    }
    @isTest
    private static void testWhenWorkPlansCreatedThenMakeWorkPlanCurrent() {
        //mock data
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
        Integration_Request__c integrationRequestInstance = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( integrationRequestFakeInstance);
        Fake irUpdateQaMenuWorkStepFake  = createIntegrationRequestFakeInstance()
                .setField(Integration_Request__c.Action__c, IR_UPDATE)
                .setField(Integration_Request__c.Target_Status__c, BAT_STATUS_MENU_BLOCK)
                .setField(Integration_Request__c.Exclusion_Code__c, EXCLUSION_CODE_MENU_FAILURE);
        // mock work orders
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Integration_Request_Ids__c, String.valueOf(integrationRequestInstance.Id))
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
            .setField(WorkOrder.Integration_Request_Ids__c, String.valueOf(integrationRequestInstance.Id))
            .setParent('Account', childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setChildren(
                'WorkSteps',
                new List<Fake>{ new Fake(WorkStep.class).setField(WorkStep.Id, workStepId) }
            );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( childWorkOrderFakeInstance );
        //parent pos work plans
        Fake parentPosWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance( parentWorkOrder.Id )
            .setField(WorkPlan.Type__c, TYPE_POS);

        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ parentPosWorkPlanFakeInstance }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( parentWorkOrderFakeInstance );
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject( parentPosWorkPlanFakeInstance );

        //child pos workplans
        Fake childPosWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance( childWorkOrder.Id )
            .setField(WorkPlan.Type__c, TYPE_POS)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlan.Id);

        childWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ childPosWorkPlanFakeInstance }
        );
        childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( childWorkOrderFakeInstance );

        Set<Id> woIds = new Set<Id>{childWorkOrder.Id, parentWorkOrder.Id};
        Set<String> irStatus = new Set<String>{IR_SFDC_STATUS_PENDING};

        // -- return lists
        Integration_Request__c irUpdateQaMenuWorkStep = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( irUpdateQaMenuWorkStepFake);
        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>{ integrationRequestInstance };
        List<Integration_Request__c> integrationRequestUpdateList = new List<Integration_Request__c>{ irUpdateQaMenuWorkStep};

        List<Xref__c> xrefList = new List<Xref__c>{ xref };
        List<Account> storeAccounts = new List<Account>{ storeAccount };
        List<WorkOrder> workOrders = new List<WorkOrder>{ childWorkOrder, parentWorkOrder };

        //--- stubbing
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IExternalNotifierEventsService externalNotifierServiceMock = (IExternalNotifierEventsService) mocks.mock(
            IExternalNotifierEventsService.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(IWorkOrdersSelector.class);

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectXrefsByStoreIds(new Set<String>{STORE_ID})).thenReturn(xrefList);

        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{storeAccount.Id})).thenReturn(storeAccounts);

        mocks.when(IntegrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(IntegrationSelectorMock.selectById(new Set<Id>{integrationRequestInstance.Id})).thenReturn(integrationRequestList);
        mocks.when(IntegrationSelectorMock.selectByOnboardingId(new Set<String>{irUpdateQaMenuWorkStep.Onboarding_Id__c}, irStatus)).thenReturn(integrationRequestUpdateList);

        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersWithWorkPlansByParentWorkOrderIds(woIds)).thenReturn(workOrders);

        mocks.stopStubbing();


        Application.SERVICE.setMock(
            IExternalNotifierEventsService.class,
            externalNotifierServiceMock
        );
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UnitOfWork.setMock(mockUow);
        //----- execute
        PosIntegrationRequestsService.makePosWorkPlansCurrent(workOrders);

         //----- execute
         String eventPayload = JSON.serialize(woIds);
         Notifier__e mockNotifierEvent = new Notifier__e(
             Payload__c = eventPayload,
             Topic__c = EVENT_TOPIC_MAKE_WORK_PLAN_CURRENT
         );
         PosIntegrationRequestsService.execute(new List<Notifier__e>{ mockNotifierEvent });

        //-- verify
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
        .registerDirty(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    WorkPlan.Integration_Request__c => integrationRequestInstance.Id
                }
            )
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
        .registerDirty(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    Integration_Request__c.Sfdc_Status__c => IR_SFDC_STATUS_PROCESSED
                }
            )
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
        .registerDirty(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    WorkOrder.Id => childWorkOrder.Id,
                    WorkOrder.Integration_Request_Ids__c => ''
                }
            )
        );
    }

    @isTest
    private static void testWhenWorkPlansCreatedThenMakeWorkPlanCurrentForMultipleRecords() {
        Id integrationRequestIdTwo = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        //mock accounts
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
        Integration_Request__c integrationRequestInstance = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( integrationRequestFakeInstance);
        Fake irUpdateQaMenuWorkStepFake  = createIntegrationRequestFakeInstance()
                .setField(Integration_Request__c.Action__c, IR_UPDATE)
                .setField(Integration_Request__c.Target_Status__c, BAT_STATUS_MENU_BLOCK)
                .setField(Integration_Request__c.Exclusion_Code__c, EXCLUSION_CODE_MENU_FAILURE);
        // mock work orders
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Integration_Request_Ids__c,
                String.valueOf(integrationRequestInstance.Id)+','+String.valueOf(integrationRequestIdTwo))
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
        //parent pos work plans
        Fake parentPosWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance( parentWorkOrder.Id )
            .setField(WorkPlan.Type__c, TYPE_POS);

        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ parentPosWorkPlanFakeInstance }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( parentWorkOrderFakeInstance );
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject( parentPosWorkPlanFakeInstance );

        //child pos workplans
        Fake childPosWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance( childWorkOrder.Id )
            .setField(WorkPlan.Type__c, TYPE_POS)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlan.Id);

        childWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ childPosWorkPlanFakeInstance }
        );
        childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( childWorkOrderFakeInstance );
       //selector inputs
        Set<Id> woIds = new Set<Id>{childWorkOrder.Id, parentWorkOrder.Id};
        Set<String> irStatus = new Set<String>{IR_SFDC_STATUS_PENDING};

        // -- return lists
        Integration_Request__c irUpdateQaMenuWorkStep = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( irUpdateQaMenuWorkStepFake);
        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>{ integrationRequestInstance };
        List<Integration_Request__c> integrationRequestUpdateList = new List<Integration_Request__c>{ irUpdateQaMenuWorkStep};


        List<Xref__c> xrefList = new List<Xref__c>{ xref };
        List<Account> storeAccounts = new List<Account>{ storeAccount };
        List<WorkOrder> workOrders = new List<WorkOrder>{ childWorkOrder, parentWorkOrder };

        //--- stubbing
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IExternalNotifierEventsService externalNotifierServiceMock = (IExternalNotifierEventsService) mocks.mock(
            IExternalNotifierEventsService.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(IWorkOrdersSelector.class);

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectXrefsByStoreIds(new Set<String>{STORE_ID})).thenReturn(xrefList);

        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{storeAccount.Id})).thenReturn(storeAccounts);

        mocks.when(IntegrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(IntegrationSelectorMock.selectById(new Set<Id>{integrationRequestInstance.Id, integrationRequestIdTwo})).thenReturn(integrationRequestList);
        mocks.when(IntegrationSelectorMock.selectByOnboardingId(new Set<String>{irUpdateQaMenuWorkStep.Onboarding_Id__c}, irStatus)).thenReturn(integrationRequestUpdateList);

        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersWithWorkPlansByParentWorkOrderIds(woIds)).thenReturn(workOrders);

        mocks.stopStubbing();


        Application.SERVICE.setMock(
            IExternalNotifierEventsService.class,
            externalNotifierServiceMock
        );
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UnitOfWork.setMock(mockUow);
        //execute
        PosIntegrationRequestsService.makePosWorkPlansCurrent(workOrders);
         String eventPayload = JSON.serialize(woIds);
         Notifier__e mockNotifierEvent = new Notifier__e(
             Payload__c = eventPayload,
             Topic__c = EVENT_TOPIC_MAKE_WORK_PLAN_CURRENT
         );
         PosIntegrationRequestsService.execute(new List<Notifier__e>{ mockNotifierEvent });

        //-- verify
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
        .registerDirty(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    WorkPlan.Integration_Request__c => integrationRequestInstance.Id
                }
            )
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
        .registerDirty(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    Integration_Request__c.Sfdc_Status__c => IR_SFDC_STATUS_PROCESSED
                }
            )
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
        .registerDirty(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    WorkOrder.Id => childWorkOrder.Id,
                    WorkOrder.Integration_Request_Ids__c => ''
                }
            )
        );
    }

    @isTest
    private static void testWhenRequestReceivedIntegrationIdIsSameThenUpdateIrMessageAsDuplicate() {
        //mock data
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Fake businessAccountFakeInstance = createParentAccount();

        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake childAccountFakeInstance = createChildAccountInstance(businessAccount.Id, businessAccountFakeInstance)
        .setField(Account.POS_Integration_Type__c, POS_INTEGRATION_TYPE_SQUARE);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        xref__c xref = createXrefFakeInstance(storeAccount.Id);
        Fake integrationRequestFakeInstance = createIntegrationRequestFakeInstance();
        Fake duplicateIntRequestFakeInstance = createIntegrationRequestFakeInstance();
        Integration_Request__c duplicateIntRequest = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( duplicateIntRequestFakeInstance );
        Integration_Request__c integrationRequestInstance = (Integration_request__c) ServiceMockDataBuilder.convertToSObject( integrationRequestFakeInstance);

        // mock work orders
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
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
        //paren workplans--
        Fake parentPosWorkPlan = ServiceMockDataBuilder.createWorkPlanFakeInstance( parentWorkOrder.Id )
            .setField(WorkPlan.Type__c, TYPE_POS);
        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ parentPosWorkPlan }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( parentWorkOrderFakeInstance );
        //parent pos work plans
        Fake parentPosWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance( parentWorkOrder.Id )
            .setField(WorkPlan.Type__c, TYPE_POS);

        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ parentPosWorkPlanFakeInstance }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject( parentWorkOrderFakeInstance );
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject( parentPosWorkPlanFakeInstance );

        //child workplans--
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
        //selector inputs
        Set<String> validTypes = new Set<String>{TYPE_POS, TYPE_MARKET_PLACE, TYPE_COO};
        Set<Id> accountIds = new Set<Id>{storeAccount.Id, businessAccount.Id};

        // return lists
        List<Integration_Request__c> duplicateIntRequestRequestList = new List<Integration_Request__c>{ duplicateIntRequest };

        List<Xref__c> xrefList = new List<Xref__c>{ xref };
        List<Account> storeAccounts = new List<Account>{ storeAccount };
        List<WorkOrder> workOrders = new List<WorkOrder>{ childWorkOrder, parentWorkOrder };

        //stubbing
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IExternalNotifierEventsService externalNotifierServiceMock = (IExternalNotifierEventsService) mocks.mock(
            IExternalNotifierEventsService.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(IIntegrationRequestsSelector.class);
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(IWorkOrdersSelector.class);

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectXrefsByStoreIds(new Set<String>{STORE_ID})).thenReturn(xrefList);

        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{storeAccount.Id})).thenReturn(storeAccounts);

        mocks.when(IntegrationSelectorMock.SObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(IntegrationSelectorMock.selectById(new Set<Id>{duplicateIntRequest.Id})).thenReturn(duplicateIntRequestRequestList);

        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersAndWorkPlansByAccountIdsAndStatusAndType(accountIds, WO_OPEN_STATUS, validTypes)).thenReturn(workOrders);

        mocks.stopStubbing();


        Application.SERVICE.setMock(
            IExternalNotifierEventsService.class,
            externalNotifierServiceMock
        );
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UnitOfWork.setMock(mockUow);
        //----- execute
        String eventPayload = JSON.serialize(new Set<Id>{ duplicateIntRequest.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_PROCESS_NEW_POS_INTEGRATION_REQUEST
        );
        PosIntegrationRequestsService.execute(new List<Notifier__e>{ mockNotifierEvent });

        //-- verify Integration request updated with Processed and duplicate error message populated if
        // the new integration Id same as existing one.

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Integration_Request__c.sfdc_status__c => IR_SFDC_STATUS_PROCESSED,
                        Integration_Request__c.Error_Message__c => 'Duplicate Integration Request'
                    }
                )
            );
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

}