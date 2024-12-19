/**
 * @author Deloitte
 * @date 09/01/2022
 * @description Test class for ParentWorkOrderSyncServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class ParentWorkOrderSyncServiceImplTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACTIVATE_CENTRALLY = 'Yes';
    private static final String AGGREGATE_BUNDLED_WITH_MARKETPLACE_FIELD_ALIAS = 'bundledWithMarketplace';
    private static final String AGGREGATE_DELAY_TABLET_METHOD_FIELD_ALIAS = 'delayTabletShipment';
    private static final String AGGREGATE_MENU_UI_TYPE_FIELD_ALIAS = 'menuUIType';
    private static final String AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS = 'parentWorkOrderId';
    private static final String AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS = 'posIntergrationType';
    private static final String AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS = 'tabletDeliveryMethod';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String BUNDLED_WITH_MARKETPLACE_NO = 'No';
    private static final String DELAY_TABLET_METHOD_YES = 'Yes';
    private static final String MENU_UI_TYPE_RESTAURANT = 'Restaurant';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String POS_INTEGRATION_TYPE_DOMINOS = 'dominos';
    private static final String POS_INTEGRATION_TYPE_NON_INTEGRATED_MX = 'non_integrated_mx';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String STORE_LEVEL_WORK_PLAN_INDICATOR_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: POS, Storefront Bundled & Tablet Work Plan indicator does not match';
    private static final String TABLET_DELIVERY_METHOD = 'Drop-ship';
    private static final String TABLET_DELIVERY_METHOD_LOCAL_TEAM_DROP_OFF = 'Local Team Drop-off';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String VERTICAL = 'Rx';
    private static final String WORKORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_ACCOUNT_OWNER_EMAIL = 'test@WorkOrdersTest.com';
    private static final String WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME = 'Account';
    private static final String AGGREGATE_PPROPOSED_DATE_ACTIVATION_FIELD_ALIAS = 'proposedDateOfActivaton';
    private static final String AGGREGATE_PPROPOSED_DATE_MENU_FIELD_ALIAS = 'proposedDateOfMenu';

    /**
     * @description To test that Storefront Bundled, POS, Tablet & Catalog Work Plan indicators are
     * enabled on the passed parent Work Order when:
     * a. Bundled_with_Marketplace__c is Yes
     * b. store Account's POS Integration Type is not equal to non_integrated_mx
     * c. Tablet Delivery Method is Drop-ship
     * d. Menu UI Type is Retail
     */
    @isTest
    private static void testWhenEnableStoreLevelWorkPlansIndicatorsOnParentWorkOrderCalledThenStoreLevelWorkPlansIndicatorsEnabled() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Account.Id, storeAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Id, parentWorkOrderId);
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(5))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setField(WorkOrder.Id, childWorkOrderId)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setFakeId()
            .toSObject();

        Aggregate mockAggregatePDOx = new Aggregate();
        mockAggregatePDOx.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderId
        );
        mockAggregatePDOx.put(
            AGGREGATE_PPROPOSED_DATE_ACTIVATION_FIELD_ALIAS,
            storeAccount.Proposed_Date_of_Activation__c
        );

        Aggregate mockAggregateStoreLevelWorkPlansIndicators = new Aggregate();
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_MENU_UI_TYPE_FIELD_ALIAS,
            MENU_UI_TYPE_RETAIL
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderId
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS,
            POS_INTEGRATION_TYPE_DOMINOS
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS,
            TABLET_DELIVERY_METHOD
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_BUNDLED_WITH_MARKETPLACE_FIELD_ALIAS,
            BUNDLED_WITH_MARKETPLACE_YES
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        mocks.startStubbing();
        mocks.when(
                mockWorkOrdersSelector.selectByAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder});
        mocks.when(
                    mockWorkOrdersSelector.selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
                        new Set<Id>{ parentWorkOrderId }
                    )
                )
            .thenReturn(new List<Aggregate>{ mockAggregatePDOx});
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.getCountFilteredByPassedIdsGroupedByStoreLevelWorkPlansIndicators(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregateStoreLevelWorkPlansIndicators });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IGenericLogger.class,genericLoggerService);
        ParentWorkOrderSyncService.enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder(
            new List<WorkOrder>{ childWorkOrder }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => parentWorkOrderId,
                            WorkOrder.HasCatalogWorkPlan__c => true,
                            WorkOrder.HasPOSWorkPlan__c => true,
                            WorkOrder.HasTabletWorkPlan__c => true,
                            WorkOrder.Bundled_with_Marketplace__c => BUNDLED_WITH_MARKETPLACE_YES
                        }
                    }
                )
            );
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                         new Map<SObjectField, Object>{
                            WorkOrder.Id => parentWorkOrderId,
                            WorkOrder.Is_PDOA_PDOM_Same_for_All_Stores__c => true
                          }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test that Storefront Bundled, POS, Tablet & Menu Work Plan indicators are
     * enabled on the passed parent Work Order when:
     * a. Bundled_with_Marketplace__c is No
     * b. store Account's POS Integration Type is not equal to non_integrated_mx
     * c. Tablet Delivery Method is Drop-ship
     * d. Menu UI Type is Restaurant
     */
    @isTest
    private static void testWhenEnableStoreLevelWorkPlansIndicatorsOnParentWorkOrderByStoreAccountsCalledThenStoreLevelWorkPlansIndicatorsEnabled() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RESTAURANT)
            .setField(Account.Id, storeAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Id, parentWorkOrderId);
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_NO)
            .setField(WorkOrder.Id, childWorkOrderId)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setFakeId()
            .toSObject();
        Aggregate mockAggregateStoreLevelWorkPlansIndicators = new Aggregate();
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_MENU_UI_TYPE_FIELD_ALIAS,
            MENU_UI_TYPE_RESTAURANT
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderId
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS,
            POS_INTEGRATION_TYPE_DOMINOS
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS,
            TABLET_DELIVERY_METHOD
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_BUNDLED_WITH_MARKETPLACE_FIELD_ALIAS,
            BUNDLED_WITH_MARKETPLACE_NO
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.getCountFilteredByPassedIdsGroupedByStoreLevelWorkPlansIndicators(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregateStoreLevelWorkPlansIndicators });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        ParentWorkOrderSyncService.enableStoreLevelWorkPlanIndicatorsOnParentWorkOrderByStoreAccounts(
            new Set<Id>{ storeAccountId }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => parentWorkOrderId,
                            WorkOrder.HasMenuWorkPlan__c => true,
                            WorkOrder.HasPOSWorkPlan__c => true,
                            WorkOrder.HasTabletWorkPlan__c => true,
                            WorkOrder.Bundled_with_Marketplace__c => BUNDLED_WITH_MARKETPLACE_NO
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test that Storefront Bundled, POS & Tablet Work Plan indicators are
     * enabled on the passed parent Work Order when:
     * a. Bundled_with_Marketplace__c is Yes
     * b. store Account's POS Integration Type is non_integrated_mx
     * c. Tablet Delivery Method is not equal to Drop-ship.
     */
    @isTest
    private static void testWhenEnableStoreLevelWorkPlansIndicatorsOnParentWorkOrderByStoreAccountsCalledThenStorefrontBundledWorkPlansIndicatorEnabled() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Id, parentWorkOrderId);
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setField(WorkOrder.Id, childWorkOrderId)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setFakeId()
            .toSObject();
        Aggregate mockAggregateStoreLevelWorkPlansIndicators = new Aggregate();
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderId
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS,
            POS_INTEGRATION_TYPE_NON_INTEGRATED_MX
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS,
            TABLET_DELIVERY_METHOD_LOCAL_TEAM_DROP_OFF
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_BUNDLED_WITH_MARKETPLACE_FIELD_ALIAS,
            BUNDLED_WITH_MARKETPLACE_YES
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.getCountFilteredByPassedIdsGroupedByStoreLevelWorkPlansIndicators(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregateStoreLevelWorkPlansIndicators });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        ParentWorkOrderSyncService.enableStoreLevelWorkPlanIndicatorsOnParentWorkOrderByStoreAccounts(
            new Set<Id>{ storeAccountId }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => parentWorkOrderId,
                            WorkOrder.HasTabletWorkPlan__c => false,
                            WorkOrder.HasPOSWorkPlan__c => false,
                            WorkOrder.Bundled_with_Marketplace__c => BUNDLED_WITH_MARKETPLACE_YES
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test that Storefront Bundled, POS & Tablet Work Plan indicators are
     * enabled on the passed parent Work Order when:
     * a. Bundled_with_Marketplace__c is No
     * b. store Account's POS Integration Type is not equal to non_integrated_mx
     * c. Tablet Delivery Method is not equal to Drop-ship.
     */
    @isTest
    private static void testWhenEnableStoreLevelWorkPlansIndicatorsOnParentWorkOrderCalledThenPOSWorkPlansIndicatorsEnabled() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Id, parentWorkOrderId);
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_NO)
            .setField(WorkOrder.Id, childWorkOrderId)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setFakeId()
            .toSObject();
        Aggregate mockAggregateStoreLevelWorkPlansIndicators = new Aggregate();
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderId
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS,
            POS_INTEGRATION_TYPE_DOMINOS
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS,
            TABLET_DELIVERY_METHOD_LOCAL_TEAM_DROP_OFF
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_BUNDLED_WITH_MARKETPLACE_FIELD_ALIAS,
            BUNDLED_WITH_MARKETPLACE_NO
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.getCountFilteredByPassedIdsGroupedByStoreLevelWorkPlansIndicators(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregateStoreLevelWorkPlansIndicators });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        ParentWorkOrderSyncService.enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder(
            new List<WorkOrder>{ childWorkOrder }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => parentWorkOrderId,
                            WorkOrder.HasTabletWorkPlan__c => false,
                            WorkOrder.HasPOSWorkPlan__c => true,
                            WorkOrder.Bundled_with_Marketplace__c => BUNDLED_WITH_MARKETPLACE_NO
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test that Storefront Bundled, POS & Tablet Work Plan indicators are
     * enabled on the passed parent Work Order when:
     * a. Bundled_with_Marketplace__c is No
     * b. store Account's POS Integration Type is not equal to non_integrated_mx
     * c. Tablet Delivery Method is Drop-ship.
     */
    @isTest
    private static void testWhenEnableStoreLevelWorkPlansIndicatorsOnParentWorkOrderCalledThenTabletWorkPlansIndicatorsEnabled() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Id, parentWorkOrderId);
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_NO)
            .setField(WorkOrder.Id, childWorkOrderId)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setFakeId()
            .toSObject();
        Aggregate mockAggregateStoreLevelWorkPlansIndicators = new Aggregate();
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderId
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS,
            POS_INTEGRATION_TYPE_NON_INTEGRATED_MX
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS,
            TABLET_DELIVERY_METHOD
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_BUNDLED_WITH_MARKETPLACE_FIELD_ALIAS,
            BUNDLED_WITH_MARKETPLACE_NO
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.getCountFilteredByPassedIdsGroupedByStoreLevelWorkPlansIndicators(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregateStoreLevelWorkPlansIndicators });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        ParentWorkOrderSyncService.enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder(
            new List<WorkOrder>{ childWorkOrder }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => parentWorkOrderId,
                            WorkOrder.HasTabletWorkPlan__c => true,
                            WorkOrder.HasPOSWorkPlan__c => false,
                            WorkOrder.Bundled_with_Marketplace__c => BUNDLED_WITH_MARKETPLACE_NO
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test that Catalog Work Plan indicator is enabled on the passed parent Work
     * Order when Menu UI Type is Retail for store Account associated with child Work Order.
     */
    @isTest
    private static void testWhenStoreAccountWithRetailMenuUITypeAssociatedThenCatalogIndicatorEnabledOnParentWorkOrder() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Account.Id, storeAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Id, parentWorkOrderId);
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(5))
            .setField(WorkOrder.Id, childWorkOrderId)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setFakeId()
            .toSObject();
        Aggregate mockAggregateStoreLevelWorkPlansIndicators = new Aggregate();
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_MENU_UI_TYPE_FIELD_ALIAS,
            MENU_UI_TYPE_RETAIL
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderId
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.getCountFilteredByPassedIdsGroupedByStoreLevelWorkPlansIndicators(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregateStoreLevelWorkPlansIndicators });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        ParentWorkOrderSyncService.enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder(
            new List<WorkOrder>{ childWorkOrder }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => parentWorkOrderId,
                            WorkOrder.HasCatalogWorkPlan__c => true
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when store sAccounts are merged then store level Work Plans indicators
     * are enabled on associated parent Work Orders.
     */
    @isTest
    private static void testWhenStoreAccountsMergedThenInitiateUpdateOnRelatedWorkOrders() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Id, parentWorkOrderId);
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(5))
            .setField(WorkOrder.Id, childWorkOrderId)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .toSObject();
        Aggregate mockAggregateStoreLevelWorkPlansIndicators = new Aggregate();
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_MENU_UI_TYPE_FIELD_ALIAS,
            MENU_UI_TYPE_RETAIL
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderId
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS,
            TABLET_DELIVERY_METHOD_LOCAL_TEAM_DROP_OFF
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_BUNDLED_WITH_MARKETPLACE_FIELD_ALIAS,
            BUNDLED_WITH_MARKETPLACE_NO
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.getCountFilteredByPassedIdsGroupedByStoreLevelWorkPlansIndicators(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregateStoreLevelWorkPlansIndicators });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Test.startTest();
        ParentWorkOrderSyncService.processMergedAccountsRelatedRecords(
            new List<WorkOrder>{ childWorkOrder }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => parentWorkOrderId,
                            WorkOrder.HasCatalogWorkPlan__c => true
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test that PDOT readiness check indicator is enabled on the
     * passed parent Work Order when any of the associated store Account's Delay Tablet Shipment is Yes.
     */
    @isTest
    private static void testWhenEnableStoreLevelWorkPlansIndicatorsOnParentWorkOrderInvokedThenPDOTReadinessCheckIndicatorsEnabled() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Has_Any_Store_Tablet_Shipment_Delayed__c, false)
            .setField(WorkOrder.Id, parentWorkOrderId);
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_NO)
            .setField(WorkOrder.Id, childWorkOrderId)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setFakeId()
            .toSObject();
        Aggregate mockAggregateStoreLevelWorkPlansIndicators = new Aggregate();
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderId
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS,
            POS_INTEGRATION_TYPE_NON_INTEGRATED_MX
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS,
            TABLET_DELIVERY_METHOD_LOCAL_TEAM_DROP_OFF
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_BUNDLED_WITH_MARKETPLACE_FIELD_ALIAS,
            BUNDLED_WITH_MARKETPLACE_NO
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_DELAY_TABLET_METHOD_FIELD_ALIAS,
            DELAY_TABLET_METHOD_YES
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.getCountFilteredByPassedIdsGroupedByStoreLevelWorkPlansIndicators(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregateStoreLevelWorkPlansIndicators });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        ParentWorkOrderSyncService.enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder(
            new List<WorkOrder>{ childWorkOrder }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => parentWorkOrderId,
                            WorkOrder.HasTabletWorkPlan__c => false,
                            WorkOrder.HasPOSWorkPlan__c => false,
                            WorkOrder.Bundled_with_Marketplace__c => BUNDLED_WITH_MARKETPLACE_NO,
                            WorkOrder.Has_Any_Store_Tablet_Shipment_Delayed__c => true
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when store accounts PDOx dates are same update the ParentWorkOrder PDoxField Indicator to True
     *
     */
    @isTest
    private static void testWhenPDOxDateSameInAllStoreThenUpdateTheParentWorkOrderPDOxFieldIndicatorTrue() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountIdOne = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake childAccountFakeInstanceOne = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                VERTICAL
            )
            .setField(Account.Id, storeAccountIdOne)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL);
        Account storeAccountOne = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstanceOne
        );
        Fake childWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.AccountId, storeAccountIdOne)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId);
        WorkOrder childworkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Aggregate mockAggregatePDOx = new Aggregate();
        mockAggregatePDOx.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderId
        );
        mockAggregatePDOx.put(
            AGGREGATE_PPROPOSED_DATE_ACTIVATION_FIELD_ALIAS,
            storeAccountOne.Proposed_Date_of_Activation__c
        );
        mockAggregatePDOx.put(
            AGGREGATE_PPROPOSED_DATE_MENU_FIELD_ALIAS,
            storeAccountOne.Proposed_Date_of_Menu__c
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
            mockWorkOrdersSelector.selectByAccountIds(
                new Set<Id>{ storeAccountOne.Id }
            )
        )
        .thenReturn(new List<WorkOrder>{ childWorkOrder});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregatePDOx});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Test.startTest();
        ParentWorkOrderSyncService.updateStoreLevelPDOxIndicatorOnParentWorkOrder(
            new Set<Id>{ storeAccountIdOne }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => parentWorkOrderId,
                            WorkOrder.Is_PDOA_PDOM_Same_for_All_Stores__c => true
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when store accounts PDOx dates are different update the Parent WorkOrder PDoxField Indicator to False
     */
    @isTest
    private static void testWhenPDOxDateDifferentInAllStoreThenUpdateTheParentWorkOrderPDOxFieldIndicatorFalse() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountIdOne = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountIdTwo = fflib_IDGenerator.generate(Account.SObjectType);
        Fake childAccountFakeInstanceOne = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                VERTICAL
            )
            .setField(Account.Id, storeAccountIdOne)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL);

        Fake childAccountFakeInstanceTwo = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                VERTICAL
            )
            .setField(Account.Id, storeAccountIdTwo)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today().addMonths(4))
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL);

        Account storeAccountOne = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstanceOne
        );
        Account storeAccountTwo = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstanceTwo
        );
        Fake childWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.AccountId, storeAccountIdOne)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId);

        WorkOrder childworkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Aggregate mockAggregatePDOxOne = new Aggregate();
        mockAggregatePDOxOne.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderId
        );
        mockAggregatePDOxOne.put(
            AGGREGATE_PPROPOSED_DATE_ACTIVATION_FIELD_ALIAS,
            storeAccountOne.Proposed_Date_of_Activation__c
        );
        mockAggregatePDOxOne.put(
            AGGREGATE_PPROPOSED_DATE_MENU_FIELD_ALIAS,
            storeAccountOne.Proposed_Date_of_Menu__c
        );
        Aggregate mockAggregatePDOxTwo = new Aggregate();
        mockAggregatePDOxTwo.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderId
        );
        mockAggregatePDOxTwo.put(
            AGGREGATE_PPROPOSED_DATE_ACTIVATION_FIELD_ALIAS,
            storeAccountTwo.Proposed_Date_of_Activation__c
        );
        mockAggregatePDOxTwo.put(
            AGGREGATE_PPROPOSED_DATE_MENU_FIELD_ALIAS,
            storeAccountTwo.Proposed_Date_of_Menu__c
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
            mockWorkOrdersSelector.selectByAccountIds(
                new Set<Id>{ storeAccountOne.Id }
            )
        )
        .thenReturn(new List<WorkOrder>{ childWorkOrder});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregatePDOxOne, mockAggregatePDOxTwo});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Test.startTest();
        ParentWorkOrderSyncService.updateStoreLevelPDOxIndicatorOnParentWorkOrder(
            new Set<Id>{ storeAccountIdOne }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(

                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => parentWorkOrderId,
                            WorkOrder.Is_PDOA_PDOM_Same_for_All_Stores__c => false
                        }
                    }
                )

            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}