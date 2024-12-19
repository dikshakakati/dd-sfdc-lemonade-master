/**
 * @author Deloitte
 * @date 05/31/2023
 * @description Test class for work objects Sync class.
 */
@isTest(SeeAllData=false)
private class WorkObjectsSyncServiceImplTest {
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACTIVATE_CENTRALLY_NO = 'No';
    private static final String ACTIVATE_CENTRALLY_YES = 'Yes';
    private static final String EVENT_TOPIC_WORK_OBJECTS_SYNC = 'WORK_OBJECTS_SYNC';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String ORDER_PROTOCOL_FAX = 'Fax';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String SALES_NOTES_FOR_MENU_TEAM = 'Test Notes';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_OF_MENU_ADD_CONTENT = 'Add Content';
    private static final String TYPE_OF_MENU_REMOVE_CONTENT = 'Remove Content';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String VERTICAL = 'Rx';
    private static final Integer WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER = 1;
    private static final String WORK_PLAN_NOTES = 'Work Plan Notes';
    private static final String WORK_PLAN_NOTES_CHILD = 'Child Work Plan Notes';
    private static final String DISALLOW_OVVERRIDE_NO = 'No';
    /**
     * @description To test when any of the fields Opportunity,Contract,Order Protocol,Activated
     * Centrally (AC),Menu Setup Method,Type of Menu Update,Sales Notes for Menu Team,PDOA,PDOT
     * parent work orders modified, it triggers child work order and store account modification.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenParentWorkOrdersAreUpdatedThenChildWorkOrderAndStoreAccountGetsUpdated() {
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING);
        Opportunity opportunity = (Opportunity) ServiceMockDataBuilder.convertToSObject(
            opportunityFakeInstance
        );
        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, businessAccount.Id)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_NO)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_FAX)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 20)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(10))
            .setField(WorkOrder.Sales_Notes_for_Menu_Team__c, TYPE_OF_MENU_ADD_CONTENT)
            .setField(WorkOrder.Type_of_Menu_Update__c, TYPE_OF_MENU_ADD_CONTENT)
            .setField(WorkOrder.Opportunity__c, opportunity.Id)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setParent('Account', parentAccountFakeInstance)
            .setParent('Opportunity__r', opportunityFakeInstance)
            .setFakeId();
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.Order_Protocol__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Disallow_PDOA_Override__c, DISALLOW_OVVERRIDE_NO)
            .setField(Account.User_Sets_PDOT_Value__c, DISALLOW_OVVERRIDE_NO)
            .setField(Account.Proposed_Date_of_Tablet__c, System.today().addDays(45))
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake childWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(5))
            .setField(WorkOrder.Sales_Notes_for_Menu_Team__c, SALES_NOTES_FOR_MENU_TEAM)
            .setField(WorkOrder.Type_of_Menu_Update__c, TYPE_OF_MENU_REMOVE_CONTENT)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_EMAIL)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(40))
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setParent('Account', childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setFakeId();
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<WorkOrder> childWorkOrderRecord = new List<WorkOrder>{ childWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrdersSelector workObjectsSyncSelectorMock = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        mocks.startStubbing();
        mocks.when(workObjectsSyncSelectorMock.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workObjectsSyncSelectorMock.selectParentDetailsByChildIds(
                    new Set<Id>{ childWorkOrder.Id }
                )
            )
            .thenReturn(childWorkOrderRecord);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workObjectsSyncSelectorMock);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);
        String eventPayload = JSON.serialize(new Set<Id>{ childWorkOrder.Id });

        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_OBJECTS_SYNC
        );

        WorkObjectsSyncService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => childWorkOrder.Id,
                            WorkOrder.Activated_Centrally_AC__c => ACTIVATE_CENTRALLY_NO,
                            WorkOrder.Opportunity__c => opportunity.Id,
                            WorkOrder.Order_Protocol__c => ORDER_PROTOCOL_FAX,
                            WorkOrder.Proposed_Date_of_Activation__c => System.today().addDays(20),
                            WorkOrder.Proposed_Date_of_Tablet__c => System.today().addDays(10),
                            WorkOrder.Sales_Notes_for_Menu_Team__c => TYPE_OF_MENU_ADD_CONTENT,
                            WorkOrder.Type_of_Menu_Update__c => TYPE_OF_MENU_ADD_CONTENT
                        },
                        new Map<SObjectField, Object>{
                            Account.Id => storeAccount.Id,
                            Account.Activated_Centrally_AC__c => ACTIVATE_CENTRALLY_NO,
                            Account.Order_Protocol__c => ORDER_PROTOCOL_FAX,
                            Account.Proposed_Date_of_Activation__c => System.today().addDays(20),
                            Account.Proposed_Date_of_Tablet__c => System.today().addDays(10)
                        }
                    }
                )
            );
    }

    /**
     * @description To test when the field 'Notes' parent work plans modified, it triggers
     * child work plans modification
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenParentWorkPlanNotesChangedThenChildWorkPlanNotesChanged() {
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
        Fake parentWorkPlanFakeInstance = new Fake(WorkPlan.class)
            .setField(WorkPlan.Name, mockWorkPlanTemplate.Name)
            .setField(WorkPlan.ParentRecordId, parentWorkOrder.Id)
            .setField(WorkPlan.Work_Plan_Template__c, mockWorkPlanTemplate.Id)
            .setField(WorkPlan.Status__c, mockWorkPlanTemplate.Work_Plan_Default_Status__c)
            .setField(WorkPlan.Type__c, mockWorkPlanTemplate.Type__c)
            .setField(WorkPlan.ExecutionOrder, mockWorkPlanTemplate.RelativeExecutionOrder)
            .setField(WorkPlan.Notes__c, WORK_PLAN_NOTES)
            .setFakeId();
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );
        Fake childWorkPlanFakeInstance = new Fake(WorkPlan.class)
            .setField(WorkPlan.Name, mockWorkPlanTemplate.Name)
            .setField(WorkPlan.ParentRecordId, childWorkOrder.Id)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlan.Id)
            .setField(WorkPlan.Status__c, mockWorkPlanTemplate.Work_Plan_Default_Status__c)
            .setField(WorkPlan.Work_Plan_Template__c, mockWorkPlanTemplate.Id)
            .setField(WorkPlan.Type__c, mockWorkPlanTemplate.Type__c)
            .setField(WorkPlan.ExecutionOrder, mockWorkPlanTemplate.RelativeExecutionOrder)
            .setField(WorkPlan.Notes__c, WORK_PLAN_NOTES_CHILD)
            .setFakeId()
            .setParent(
                'Parent_Work_Plan__r',
                new Fake(WorkPlan.class)
                    .setField(WorkPlan.Id, parentWorkPlan.Id)
                    .setField(WorkPlan.Notes__c, WORK_PLAN_NOTES)
            );
        WorkPlan childWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            childWorkPlanFakeInstance
        );

        List<WorkPlan> childWorkPlanRecords = new List<WorkPlan>{ childWorkPlan };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkPlansSelector workObjectsSyncSelectorMock = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );

        mocks.startStubbing();
        mocks.when(workObjectsSyncSelectorMock.SObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workObjectsSyncSelectorMock.selectParentDetailsByChildIds(
                    new Set<Id>{ childWorkPlan.Id }
                )
            )
            .thenReturn(childWorkPlanRecords);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workObjectsSyncSelectorMock);
        String eventPayload = JSON.serialize(new Set<Id>{ childWorkPlan.Id });

        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_OBJECTS_SYNC
        );

        WorkObjectsSyncService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkPlan.Id => childWorkPlan.Id,
                            WorkPlan.Notes__c => WORK_PLAN_NOTES
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Storefront Work Order is updated then
     * do not sync the changes to child Work Order and Store Account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStorefrontParentWorkOrderUpdatedThenChildWorkOrderAndStoreAccountAreNotUpdated() {
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING);
        Opportunity opportunity = (Opportunity) ServiceMockDataBuilder.convertToSObject(
            opportunityFakeInstance
        );
        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, businessAccount.Id)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_NO)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_FAX)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 20)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(10))
            .setField(WorkOrder.Sales_Notes_for_Menu_Team__c, TYPE_OF_MENU_ADD_CONTENT)
            .setField(WorkOrder.Type_of_Menu_Update__c, TYPE_OF_MENU_ADD_CONTENT)
            .setField(WorkOrder.Opportunity__c, opportunity.Id)
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setParent('Account', parentAccountFakeInstance)
            .setParent('Opportunity__r', opportunityFakeInstance)
            .setFakeId();
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.Order_Protocol__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Disallow_PDOA_Override__c, DISALLOW_OVVERRIDE_NO)
            .setField(Account.User_Sets_PDOT_Value__c, DISALLOW_OVVERRIDE_NO)
            .setField(Account.Proposed_Date_of_Tablet__c, System.today().addDays(45))
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake childWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(5))
            .setField(WorkOrder.Sales_Notes_for_Menu_Team__c, SALES_NOTES_FOR_MENU_TEAM)
            .setField(WorkOrder.Type_of_Menu_Update__c, TYPE_OF_MENU_REMOVE_CONTENT)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_EMAIL)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(40))
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setParent('Account', childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setFakeId();
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<WorkOrder> childWorkOrderRecord = new List<WorkOrder>{ childWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrdersSelector workObjectsSyncSelectorMock = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        mocks.startStubbing();
        mocks.when(workObjectsSyncSelectorMock.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workObjectsSyncSelectorMock.selectParentDetailsByChildIds(
                    new Set<Id>{ childWorkOrder.Id }
                )
            )
            .thenReturn(childWorkOrderRecord);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workObjectsSyncSelectorMock);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);
        String eventPayload = JSON.serialize(new Set<Id>{ childWorkOrder.Id });

        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_OBJECTS_SYNC
        );

        Test.startTest();
        WorkObjectsSyncService.execute(new List<Notifier__e>{ mockNotifierEvent });
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ WorkOrder.Id => childWorkOrder.Id }
                )
            );
    }

    /**
     * @description To test when "Proposed Date of Implementation" is updated for "Storefront" Work Order
     * then sync the change to Store Account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenProposedDateofImplementationIsUpdatedOnStorefrontWorkOrderThenBackSyncPODIToStore() {
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, businessAccount.Id)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_NO)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_FAX)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 20)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(10))
            .setField(WorkOrder.Proposed_Date_of_Implementation__c, System.today().addDays(10))
            .setField(WorkOrder.Sales_Notes_for_Menu_Team__c, TYPE_OF_MENU_ADD_CONTENT)
            .setField(WorkOrder.Type_of_Menu_Update__c, TYPE_OF_MENU_ADD_CONTENT)
            .setField(WorkOrder.Opportunity__c, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setParent('Account', parentAccountFakeInstance)
            .setFakeId();
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.Order_Protocol__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Disallow_PDOA_Override__c, DISALLOW_OVVERRIDE_NO)
            .setField(Account.User_Sets_PDOT_Value__c, DISALLOW_OVVERRIDE_NO)
            .setField(Account.Proposed_Date_of_Tablet__c, System.today().addDays(45))
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake childWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(5))
            .setField(WorkOrder.Sales_Notes_for_Menu_Team__c, SALES_NOTES_FOR_MENU_TEAM)
            .setField(WorkOrder.Type_of_Menu_Update__c, TYPE_OF_MENU_REMOVE_CONTENT)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_EMAIL)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(40))
            .setField(WorkOrder.Proposed_Date_of_Implementation__c, System.today().addDays(10))
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setParent('Account', childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setFakeId();
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<WorkOrder> childWorkOrderRecord = new List<WorkOrder>{ childWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrdersSelector workObjectsSyncSelectorMock = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        mocks.startStubbing();
        mocks.when(workObjectsSyncSelectorMock.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workObjectsSyncSelectorMock.selectParentDetailsByChildIds(
                    new Set<Id>{ childWorkOrder.Id }
                )
            )
            .thenReturn(childWorkOrderRecord);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workObjectsSyncSelectorMock);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);
        String eventPayload = JSON.serialize(new Set<Id>{ childWorkOrder.Id });

        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_OBJECTS_SYNC
        );
        Test.startTest();
        WorkObjectsSyncService.execute(new List<Notifier__e>{ mockNotifierEvent });
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => childWorkOrder.Id,
                            WorkOrder.Is_Updated_By_System__c => true
                        },
                        new Map<SObjectField, Object>{
                            Account.Id => storeAccount.Id,
                            Account.Proposed_Date_of_Implementation__c => System.today().addDays(10)
                        }
                    }
                )
            );
    }
}