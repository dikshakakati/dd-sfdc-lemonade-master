/**
 * @author Deloitte
 * @date 07/14/2022
 * @description Test class for ReevaluateWorkPlansOnWorkOrderSrvcImpl class.
 */
@isTest(seeAllData=false)
private class ReevaluateWorkPlansOnWOSrvcImplTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_TABLET_DELIVERY_METHOD = 'Drop-ship';
    private static final String ASSERT_MESSAGE_EXCEPTION_MESSAGE = 'Unexpected result: exception message is not matching';
    private static final String ASSERT_MESSAGE_WORK_PLAN_TYPE = 'Unexpected result: Work Order Id to Work Plan types map is not matching';
    private static final String ASSERT_MESSAGE_WORK_ORDER = 'Unexpected result: Work Orders list is not matching';
    private static final String DML_ALLOWED_LIMIT_STATIC_CONFIG = 'DML_Allowed_Limit';
    private static final String LOG_RECORD_METHOD_NAME = 'reevaluateWorkPlans';
    private static final String LIMIT_EXCEEDS_EXCEPTION_MESSAGE = 'Unexpected error occured: one or more governor limit exceeded';
    private static final String NO_WORKPLAN_TO_REEVALUATEMESSAGE = 'Script-thrown exception';
    private static final String QUERIES_ALLOWED_LIMIT_STATIC_CONFIG = 'Queries_Allowed_Limit';
    private static final String QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG = 'Query_Rows_Allowed_Limit';
    private static final String STORE_LEVEL_WORK_PLAN_TYPES_STATIC_CONFIG = 'Store_Level_Work_Plan_Types';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORKPLAN_NAME_CENTRAL_ACTIVATIONS = 'Central Activations';
    private static final String WORKPLAN_NAME_GRANT_PORTAL_ACCESS = 'Grant Portal Access';
    private static final String WORKPLAN_NAME_MENU = 'Menu';
    private static final String WORKPLAN_NAME_ONBOARDING = 'Onboarding';
    private static final String WORKPLAN_NAME_SETUP_BANKING = 'Setup Banking';
    private static final String WORKPLAN_NAME_TABLET = 'Tablet';
    private static final String WORKORDER_ACTIVATED_CENTRALLY_YES = 'Yes';

    /**
     * @description To test createWorkPlansOnWorkOrdersByReevaluatingCriteria method from
     * WorkPlanTemplatesService class is called in chunks when map of Work Order Id and
     * Work Plan Types to be created is passed and number of Work Orders exceeds the chunk size.
     */
    @isTest
    private static void testWhenWorkOrderIdReceivedThenExpectedServiceCalledSuccessfullyInChunks() {
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake storeCAFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        Account storeCA = (Account) ServiceMockDataBuilder.convertToSObject(storeCAFakeInstance);
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            businessAccount.Id,
            WORKORDER_TYPE_MARKETPLACE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.HasWorkPlansGenerated__c, true);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake childWorkOrderStoreCAFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeCA.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.HasWorkPlansGenerated__c, true);
        WorkOrder childWorkOrderStoreCA = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderStoreCAFakeInstance
        );
        Fake parentWorkPlanGrantPortalAccessFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_GRANT_PORTAL_ACCESS);
        Fake parentWorkPlanMenuFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_MENU);
        Fake parentWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        Fake childWorkPlanMenuFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                childWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_MENU);
        Fake childStoreWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                childWorkOrderStoreCA.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{
                parentWorkPlanGrantPortalAccessFakeInstance,
                parentWorkPlanMenuFakeInstance,
                parentWorkPlanOnboardingFakeInstance
            }
        );
        childWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ childWorkPlanMenuFakeInstance }
        );
        childWorkOrderStoreCAFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ childStoreWorkPlanOnboardingFakeInstance }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkPlansMapperService mockWorkPlanMapperService = (IWorkPlansMapperService) mocks.mock(
            IWorkPlansMapperService.class
        );
        IWorkPlanTemplatesService mockWorkPlanTemplateService = (IWorkPlanTemplatesService) mocks.mock(
            IWorkPlanTemplatesService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithWorkPlansByParentWorkOrderIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(
                new List<WorkOrder>{ parentWorkOrder, childWorkOrder, childWorkOrderStoreCA }
            );
        mocks.when(
                mockWorkPlanMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{
                        parentWorkOrder.Id,
                        childWorkOrder.Id,
                        childWorkOrderStoreCA.Id
                    }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    parentWorkOrder.Id => new Set<String>{ WORKPLAN_NAME_SETUP_BANKING },
                    childWorkOrder.Id => new Set<String>{
                        WORKPLAN_NAME_GRANT_PORTAL_ACCESS,
                        WORKPLAN_NAME_ONBOARDING,
                        WORKPLAN_NAME_SETUP_BANKING
                    },
                    childWorkOrderStoreCA.Id => new Set<String>{
                        WORKPLAN_NAME_GRANT_PORTAL_ACCESS,
                        WORKPLAN_NAME_MENU,
                        WORKPLAN_NAME_SETUP_BANKING
                    }
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkPlansMapperService.class, mockWorkPlanMapperService);
        Application.SERVICE.setMock(IWorkPlanTemplatesService.class, mockWorkPlanTemplateService);
        Test.startTest();
        ReevaluateWorkPlansOnWorkOrderService.reevaluateWorkPlans(parentWorkOrder.Id);
        Test.stopTest();
        fflib_ArgumentCaptor captureWOIdToWPTypeArguments = fflib_ArgumentCaptor.forClass(
            Map<String, Set<String>>.class
        );
        fflib_ArgumentCaptor captureWorkOrderArguments = fflib_ArgumentCaptor.forClass(
            List<WorkOrder>.class
        );
        ((IWorkPlanTemplatesService) mocks.verify(mockWorkPlanTemplateService, 3))
            .createWorkPlansOnWorkOrdersByReevaluatingCriteria(
                (List<WorkOrder>) captureWorkOrderArguments.capture(),
                (Map<Id, Set<String>>) captureWOIdToWPTypeArguments.capture()
            );
        List<WorkOrder> workOrders = ((List<WorkOrder>) captureWorkOrderArguments.getValue());
        Map<Id, Set<String>> workOrderIdToWorkPlanTypes = ((Map<Id, Set<String>>) captureWOIdToWPTypeArguments.getValue());
        System.assertEquals(
            new Map<Id, Set<String>>{
                childWorkOrderStoreCA.Id => new Set<String>{
                    WORKPLAN_NAME_GRANT_PORTAL_ACCESS,
                    WORKPLAN_NAME_MENU,
                    WORKPLAN_NAME_SETUP_BANKING
                }
            },
            workOrderIdToWorkPlanTypes,
            ASSERT_MESSAGE_WORK_PLAN_TYPE
        );
        System.assertEquals(
            new List<WorkOrder>{ childWorkOrder, childWorkOrderStoreCA },
            workOrders,
            ASSERT_MESSAGE_WORK_ORDER
        );
    }

    /**
     * @description To test createWorkPlansOnWorkOrdersByReevaluatingCriteria method from
     * WorkPlanTemplatesService class is called when map of WorkOrder Id and
     * Work Plan Types to be created is passed within the chunk size.
     */
    @isTest
    private static void testWhenWorkOrderIdReceivedThenExpectedServiceCalledSuccessfully() {
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            businessAccount.Id,
            WORKORDER_TYPE_MARKETPLACE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.HasWorkPlansGenerated__c, true);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake parentWorkPlanGrantPortalAccessFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_GRANT_PORTAL_ACCESS);
        Fake parentWorkPlanMenuFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_MENU);
        Fake parentWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        Fake childWorkPlanMenuFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                childWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_MENU);
        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{
                parentWorkPlanGrantPortalAccessFakeInstance,
                parentWorkPlanMenuFakeInstance,
                parentWorkPlanOnboardingFakeInstance
            }
        );
        childWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ childWorkPlanMenuFakeInstance }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkPlansMapperService mockWorkPlanMapperService = (IWorkPlansMapperService) mocks.mock(
            IWorkPlansMapperService.class
        );
        IWorkPlanTemplatesService mockWorkPlanTemplateService = (IWorkPlanTemplatesService) mocks.mock(
            IWorkPlanTemplatesService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithWorkPlansByParentWorkOrderIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder, childWorkOrder });
        mocks.when(
                mockWorkPlanMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ parentWorkOrder.Id, childWorkOrder.Id }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    parentWorkOrder.Id => new Set<String>{ WORKPLAN_NAME_SETUP_BANKING },
                    childWorkOrder.Id => new Set<String>{
                        WORKPLAN_NAME_GRANT_PORTAL_ACCESS,
                        WORKPLAN_NAME_ONBOARDING,
                        WORKPLAN_NAME_SETUP_BANKING
                    }
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkPlansMapperService.class, mockWorkPlanMapperService);
        Application.SERVICE.setMock(IWorkPlanTemplatesService.class, mockWorkPlanTemplateService);
        Test.startTest();
        ReevaluateWorkPlansOnWorkOrderService.reevaluateWorkPlans(parentWorkOrder.Id);
        Test.stopTest();
        fflib_ArgumentCaptor captureWOIdToWPTypeArguments = fflib_ArgumentCaptor.forClass(
            Map<String, Set<String>>.class
        );
        fflib_ArgumentCaptor captureWorkOrderArguments = fflib_ArgumentCaptor.forClass(
            List<WorkOrder>.class
        );
        ((IWorkPlanTemplatesService) mocks.verify(mockWorkPlanTemplateService, 2))
            .createWorkPlansOnWorkOrdersByReevaluatingCriteria(
                (List<WorkOrder>) captureWorkOrderArguments.capture(),
                (Map<Id, Set<String>>) captureWOIdToWPTypeArguments.capture()
            );
        List<WorkOrder> workOrders = ((List<WorkOrder>) captureWorkOrderArguments.getValue());
        Map<Id, Set<String>> workOrderIdToWorkPlanTypes = ((Map<Id, Set<String>>) captureWOIdToWPTypeArguments.getValue());
        System.assertEquals(
            new Map<Id, Set<String>>{
                childWorkOrder.Id => new Set<String>{
                    WORKPLAN_NAME_GRANT_PORTAL_ACCESS,
                    WORKPLAN_NAME_ONBOARDING,
                    WORKPLAN_NAME_SETUP_BANKING
                }
            },
            workOrderIdToWorkPlanTypes,
            ASSERT_MESSAGE_WORK_PLAN_TYPE
        );
        System.assertEquals(
            new List<WorkOrder>{ childWorkOrder },
            workOrders,
            ASSERT_MESSAGE_WORK_ORDER
        );
    }

    /**
     * @description To test custom exception is thrown
     * when WorkPlan types to be created is null.
     */
    @isTest
    private static void testWhenWorkPlanTypesAreNullThenExceptionThrownSuccessfully() {
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
        Fake parentWorkPlanGrantPortalAccessFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_GRANT_PORTAL_ACCESS);
        Fake parentWorkPlanMenuFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_MENU);
        Fake parentWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        Fake parentWorkPlanSetupBankingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_SETUP_BANKING);
        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{
                parentWorkPlanGrantPortalAccessFakeInstance,
                parentWorkPlanMenuFakeInstance,
                parentWorkPlanOnboardingFakeInstance,
                parentWorkPlanSetupBankingFakeInstance
            }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkPlansMapperService mockWorkPlanMapperService = (IWorkPlansMapperService) mocks.mock(
            IWorkPlansMapperService.class
        );
        IWorkPlanTemplatesService mockWorkPlanTemplateService = (IWorkPlanTemplatesService) mocks.mock(
            IWorkPlanTemplatesService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithWorkPlansByParentWorkOrderIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
                mockWorkPlanMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(new Map<Id, Set<String>>{ parentWorkOrder.Id => new Set<String>() });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkPlansMapperService.class, mockWorkPlanMapperService);
        Application.SERVICE.setMock(IWorkPlanTemplatesService.class, mockWorkPlanTemplateService);
        String noWorkPlanTypesexceptionMessage;
        Test.startTest();
        try {
            ReevaluateWorkPlansOnWorkOrderService.reevaluateWorkPlans(parentWorkOrder.Id);
        } catch (AuraHandledException exceptionMessage) {
            noWorkPlanTypesexceptionMessage = exceptionMessage.getMessage();
        }
        Test.stopTest();
        System.assertEquals(
            NO_WORKPLAN_TO_REEVALUATEMESSAGE,
            noWorkPlanTypesexceptionMessage,
            ASSERT_MESSAGE_EXCEPTION_MESSAGE
        );
    }

    /**
     * @description To test exception log (Log__c) record is created when query limit is exceeded
     * as per the Queries Allowed Limit Static Configuration custom metadata value.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQueryLimitExceededThenLogCreated() {
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake storeCAFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        Account storeCA = (Account) ServiceMockDataBuilder.convertToSObject(storeCAFakeInstance);
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            businessAccount.Id,
            WORKORDER_TYPE_MARKETPLACE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.HasWorkPlansGenerated__c, true);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake childWorkOrderStoreCAFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeCA.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.HasWorkPlansGenerated__c, true);
        WorkOrder childWorkOrderStoreCA = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderStoreCAFakeInstance
        );
        Fake parentWorkPlanGrantPortalAccessFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_GRANT_PORTAL_ACCESS);
        Fake parentWorkPlanMenuFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_MENU);
        Fake parentWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        Fake childWorkPlanMenuFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                childWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_MENU);
        Fake childStoreWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                childWorkOrderStoreCA.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{
                parentWorkPlanGrantPortalAccessFakeInstance,
                parentWorkPlanMenuFakeInstance,
                parentWorkPlanOnboardingFakeInstance
            }
        );
        childWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ childWorkPlanMenuFakeInstance }
        );
        childWorkOrderStoreCAFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ childStoreWorkPlanOnboardingFakeInstance }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkPlansMapperService mockWorkPlanMapperService = (IWorkPlansMapperService) mocks.mock(
            IWorkPlansMapperService.class
        );
        IWorkPlanTemplatesService mockWorkPlanTemplateService = (IWorkPlanTemplatesService) mocks.mock(
            IWorkPlanTemplatesService.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithWorkPlansByParentWorkOrderIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(
                new List<WorkOrder>{ parentWorkOrder, childWorkOrder, childWorkOrderStoreCA }
            );
        mocks.when(
                mockWorkPlanMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{
                        parentWorkOrder.Id,
                        childWorkOrder.Id,
                        childWorkOrderStoreCA.Id
                    }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    parentWorkOrder.Id => new Set<String>{ WORKPLAN_NAME_SETUP_BANKING },
                    childWorkOrder.Id => new Set<String>{
                        WORKPLAN_NAME_GRANT_PORTAL_ACCESS,
                        WORKPLAN_NAME_ONBOARDING,
                        WORKPLAN_NAME_SETUP_BANKING
                    },
                    childWorkOrderStoreCA.Id => new Set<String>{
                        WORKPLAN_NAME_GRANT_PORTAL_ACCESS,
                        WORKPLAN_NAME_MENU,
                        WORKPLAN_NAME_SETUP_BANKING
                    }
                }
            );
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(DML_ALLOWED_LIMIT_STATIC_CONFIG)
            )
            .thenReturn(new Static_Configurations__mdt(Configuration_Value__c = '5'));
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    STORE_LEVEL_WORK_PLAN_TYPES_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Configuration_Value__c = 'Catalog#~#Menu#~#POS#~#Tablet'
                )
            );
        /* Setting the query limit static configuration value as '200'
         to create an exception scenario for validating exception logging.*/
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    QUERIES_ALLOWED_LIMIT_STATIC_CONFIG
                )
            )
            .thenReturn(new Static_Configurations__mdt(Configuration_Value__c = '200'));
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG
                )
            )
            .thenReturn(new Static_Configurations__mdt(Configuration_Value__c = '5'));
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkPlansMapperService.class, mockWorkPlanMapperService);
        Application.SERVICE.setMock(IWorkPlanTemplatesService.class, mockWorkPlanTemplateService);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        ReevaluateWorkPlansOnWorkOrderService.reevaluateWorkPlans(parentWorkOrder.Id);
        Test.stopTest();
        fflib_ArgumentCaptor captureWOIdToWPTypeArguments = fflib_ArgumentCaptor.forClass(
            Map<String, Set<String>>.class
        );
        fflib_ArgumentCaptor captureWorkOrderArguments = fflib_ArgumentCaptor.forClass(
            List<WorkOrder>.class
        );
        ((IWorkPlanTemplatesService) mocks.verify(mockWorkPlanTemplateService, 1))
            .createWorkPlansOnWorkOrdersByReevaluatingCriteria(
                (List<WorkOrder>) captureWorkOrderArguments.capture(),
                (Map<Id, Set<String>>) captureWOIdToWPTypeArguments.capture()
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registernew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Class_Name__c => ReevaluateWorkPlansOnWorkOrderSrvcImpl.class
                            .getName(),
                        Log__c.Class_Method_Name__c => LOG_RECORD_METHOD_NAME,
                        Log__c.Detailed_Message__c => LIMIT_EXCEEDS_EXCEPTION_MESSAGE
                    }
                )
            );
    }

    /**
     * @description To test 'Tablet' Work Plan generated only on parent and child Work Order
     * when 'Tablet Delivery Method' is 'Drop-ship' on associated store Account.
     */
    @isTest
    private static void testWhenWorkOrderIdReceivedThenStoreLevelWorkPlansGeneratedOnWorkOrders() {
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake tabletStoreAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Tablet_Delivery_Method__c, ACCOUNT_TABLET_DELIVERY_METHOD);
        Account tabletStoreAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            tabletStoreAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            businessAccount.Id,
            WORKORDER_TYPE_MARKETPLACE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.HasWorkPlansGenerated__c, true);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake tabletChildWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                tabletStoreAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.HasWorkPlansGenerated__c, true);
        WorkOrder tabletChildWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            tabletChildWorkOrderFakeInstance
        );
        Fake parentWorkPlanGrantPortalAccessFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_GRANT_PORTAL_ACCESS);
        Fake parentWorkPlanMenuFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_MENU);
        Fake parentWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        Fake childWorkPlanMenuFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                childWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_MENU);
        Fake childWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                tabletChildWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{
                parentWorkPlanGrantPortalAccessFakeInstance,
                parentWorkPlanMenuFakeInstance,
                parentWorkPlanOnboardingFakeInstance
            }
        );
        childWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ childWorkPlanMenuFakeInstance }
        );
        tabletChildWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{ childWorkPlanOnboardingFakeInstance }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        tabletChildWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            tabletChildWorkOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkPlansMapperService mockWorkPlanMapperService = (IWorkPlansMapperService) mocks.mock(
            IWorkPlansMapperService.class
        );
        IWorkPlanTemplatesService mockWorkPlanTemplateService = (IWorkPlanTemplatesService) mocks.mock(
            IWorkPlanTemplatesService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithWorkPlansByParentWorkOrderIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(
                new List<WorkOrder>{ parentWorkOrder, childWorkOrder, tabletChildWorkOrder }
            );
        mocks.when(
                mockWorkPlanMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{
                        parentWorkOrder.Id,
                        childWorkOrder.Id,
                        tabletChildWorkOrder.Id
                    }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    parentWorkOrder.Id => new Set<String>{
                        WORKPLAN_NAME_ONBOARDING,
                        WORKPLAN_NAME_SETUP_BANKING,
                        WORKPLAN_NAME_TABLET
                    },
                    childWorkOrder.Id => new Set<String>{
                        WORKPLAN_NAME_GRANT_PORTAL_ACCESS,
                        WORKPLAN_NAME_ONBOARDING
                    },
                    tabletChildWorkOrder.Id => new Set<String>{
                        WORKPLAN_NAME_GRANT_PORTAL_ACCESS,
                        WORKPLAN_NAME_ONBOARDING,
                        WORKPLAN_NAME_SETUP_BANKING,
                        WORKPLAN_NAME_TABLET
                    }
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkPlansMapperService.class, mockWorkPlanMapperService);
        Application.SERVICE.setMock(IWorkPlanTemplatesService.class, mockWorkPlanTemplateService);
        Test.startTest();
        ReevaluateWorkPlansOnWorkOrderService.reevaluateWorkPlans(parentWorkOrder.Id);
        Test.stopTest();
        fflib_ArgumentCaptor captureWOIdToWPTypeArguments = fflib_ArgumentCaptor.forClass(
            Map<String, Set<String>>.class
        );
        fflib_ArgumentCaptor captureWorkOrderArguments = fflib_ArgumentCaptor.forClass(
            List<WorkOrder>.class
        );
        ((IWorkPlanTemplatesService) mocks.verify(mockWorkPlanTemplateService, 3))
            .createWorkPlansOnWorkOrdersByReevaluatingCriteria(
                (List<WorkOrder>) captureWorkOrderArguments.capture(),
                (Map<Id, Set<String>>) captureWOIdToWPTypeArguments.capture()
            );
        List<WorkOrder> workOrders = ((List<WorkOrder>) captureWorkOrderArguments.getValue());
        Map<Id, Set<String>> workOrderIdToWorkPlanTypes = ((Map<Id, Set<String>>) captureWOIdToWPTypeArguments.getValue());
        System.assertEquals(
            new Map<Id, Set<String>>{
                tabletChildWorkOrder.Id => new Set<String>{
                    WORKPLAN_NAME_GRANT_PORTAL_ACCESS,
                    WORKPLAN_NAME_ONBOARDING,
                    WORKPLAN_NAME_SETUP_BANKING,
                    WORKPLAN_NAME_TABLET
                }
            },
            workOrderIdToWorkPlanTypes,
            ASSERT_MESSAGE_WORK_PLAN_TYPE
        );
        System.assertEquals(
            new List<WorkOrder>{ childWorkOrder, tabletChildWorkOrder },
            workOrders,
            ASSERT_MESSAGE_WORK_ORDER
        );
    }

    /**
     * @description To test 'Central Activations' Work Plan generated on child Work Orders when
     * 'Central Activations' Work Plan generated on parent Work Order after re-evaluation.
     */
    @isTest
    private static void testWhenCentralActivationsWorkPlanGeneratedOnParentWorkOrderThenCentralActivationsWorkPlansGeneratedOnChildWorkOrder() {
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Activated_Centrally_AC__c, WORKORDER_ACTIVATED_CENTRALLY_YES);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.HasWorkPlansGenerated__c, true);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        // parent Work Order's Work Plans
        Fake parentWorkPlanGrantPortalAccessFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_GRANT_PORTAL_ACCESS);
        Fake parentWorkPlanMenuFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_MENU);
        Fake parentWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        Fake parentWorkPlanSetupBankingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                parentWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_SETUP_BANKING);
        // parent Work Order's Work Plans
        Fake childWorkPlanOnboardingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                childWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_ONBOARDING);
        Fake childWorkPlanMenuFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                childWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_MENU);
        Fake childWorkPlanSetupBankingFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                childWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_SETUP_BANKING);
        Fake childWorkPlanGrantPortalAccessFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstance(
                childWorkOrder.Id
            )
            .setField(WorkPlan.Name, WORKPLAN_NAME_GRANT_PORTAL_ACCESS);
        parentWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{
                parentWorkPlanGrantPortalAccessFakeInstance,
                parentWorkPlanMenuFakeInstance,
                parentWorkPlanOnboardingFakeInstance,
                parentWorkPlanSetupBankingFakeInstance
            }
        );
        childWorkOrderFakeInstance.setChildren(
            'WorkPlans',
            new List<Fake>{
                childWorkPlanOnboardingFakeInstance,
                childWorkPlanMenuFakeInstance,
                childWorkPlanGrantPortalAccessFakeInstance,
                childWorkPlanSetupBankingFakeInstance
            }
        );
        parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkPlansMapperService mockWorkPlanMapperService = (IWorkPlansMapperService) mocks.mock(
            IWorkPlansMapperService.class
        );
        IWorkPlanTemplatesService mockWorkPlanTemplateService = (IWorkPlanTemplatesService) mocks.mock(
            IWorkPlanTemplatesService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithWorkPlansByParentWorkOrderIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder, childWorkOrder });
        mocks.when(
                mockWorkPlanMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ parentWorkOrder.Id, childWorkOrder.Id }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    parentWorkOrder.Id => new Set<String>{ WORKPLAN_NAME_CENTRAL_ACTIVATIONS },
                    childWorkOrder.Id => new Set<String>{}
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkPlansMapperService.class, mockWorkPlanMapperService);
        Application.SERVICE.setMock(IWorkPlanTemplatesService.class, mockWorkPlanTemplateService);
        Test.startTest();
        ReevaluateWorkPlansOnWorkOrderService.reevaluateWorkPlans(parentWorkOrder.Id);
        Test.stopTest();
        fflib_ArgumentCaptor captureWOIdToWPTypeArguments = fflib_ArgumentCaptor.forClass(
            Map<String, Set<String>>.class
        );
        fflib_ArgumentCaptor captureWorkOrderArguments = fflib_ArgumentCaptor.forClass(
            List<WorkOrder>.class
        );
        ((IWorkPlanTemplatesService) mocks.verify(mockWorkPlanTemplateService, 2))
            .createWorkPlansOnWorkOrdersByReevaluatingCriteria(
                (List<WorkOrder>) captureWorkOrderArguments.capture(),
                (Map<Id, Set<String>>) captureWOIdToWPTypeArguments.capture()
            );
        List<WorkOrder> workOrders = ((List<WorkOrder>) captureWorkOrderArguments.getValue());
        Map<Id, Set<String>> workOrderIdToWorkPlanTypes = ((Map<Id, Set<String>>) captureWOIdToWPTypeArguments.getValue());
        System.assertEquals(
            new Map<Id, Set<String>>{
                childWorkOrder.Id => new Set<String>{ WORKPLAN_NAME_CENTRAL_ACTIVATIONS }
            },
            workOrderIdToWorkPlanTypes,
            ASSERT_MESSAGE_WORK_PLAN_TYPE
        );
        System.assertEquals(
            new List<WorkOrder>{ childWorkOrder },
            workOrders,
            ASSERT_MESSAGE_WORK_ORDER
        );
    }
}