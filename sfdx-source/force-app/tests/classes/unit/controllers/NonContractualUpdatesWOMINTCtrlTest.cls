/**
 * @author Aethereus
 * @date 03/07/2024
 * @description Test class for NonContractualUpdatesWorkOrderMINTCtrl class.
 */
@isTest(SeeAllData=false)
public class NonContractualUpdatesWOMINTCtrlTest {
    private static final String ACCOUNT_NAME = 'Test McDonald Account';
    private static final String ACCOUNT_NAME_STORE = 'Store Account';
    private static final String ACCOUNT_ACTIVATION_STATUS_DEACTIVATED = 'Deactivated';
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final string ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_POS_INTEGRATION_TYPE = 'non_integrated_mx';
    private static final String ACCOUNT_TABLET_DELIVERY_METHOD = 'Drop-ship';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String AGGREGATE_BUNDLED_WITH_MARKETPLACE_FIELD_ALIAS = 'bundledWithMarketplace';
    private static final String AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS = 'parentWorkOrderId';
    private static final String AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS = 'childWorkOrderCount';
    private static final String AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS = 'provisioningStatus';
    private static final String AGGREGATE_UNIQUE_STORE_COUNT_ALIAS = 'uniqueStoreCount';
    private static final String AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS = 'posIntergrationType';
    private static final String AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS = 'tabletDeliveryMethod';
    private static final String ASSERT_MESSAGE_DEAD_WORK_ORDER_RETURNED = 'Unexpected result: Dead Work Order is retrieved in query';
    private static final String ASSERT_MESSAGE_WORK_ORDER_ID = 'Unexpected result: Work Order Id is not matching';
    private static final String ASSERT_MESSAGE_WORK_ORDER_EMAIL_REFERENCE_ID = 'Unexpected result: Work Order Email Reference Id is not matching';
    private static final String ASSERT_MESSAGE_WORK_ORDER_COO_BATCH_DATE = 'Unexpected result: Work Order COO Batch Run Date is not matching';
    private static final String BUNDLED_WITH_MARKETPLACE_NO = 'No';
    private static final Id BUSINESS_RECORD_TYPE_ID;
    private static final String DATETIME_DAY_OF_WEEK_SYMBOL = 'EEEE';
    private static final String DAY_OF_WEEK_SATURDAY = 'Saturday';
    private static final String DAY_OF_WEEK_SUNDAY = 'Sunday';
    private static final String EMAIL_REFERENCE_ID_END_KEYWORD = ':ref';
    private static final String EMAIL_REFERENCE_ID_START_KEYWORD = 'ref:';
    private static final String FULL_STOP_SEPARATOR = '.';
    private static final String WORKORDER_BUSINESS_TO_STORE_ASSIGNMENT_MANUAL = 'Manual';
    private static final String CONTRACT_STATUS = 'Draft';
    private static final String DEAD_STATUS_ERROR_ASSERT_MESSAGE = 'Unexpected result: WorkOrder Status update to Dead did not throw an error message';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of Records returned does not match the expected outcome';
    private static final String INCORRECT_NUMBER_OF_STORES_ASSERT_MESSAGE = 'Unexpected result: Number of Stores is not equal the expected value';
    private static final String MENU_TO_BE_COMPLETED_BY_MERCHANT = 'Merchant';
    private static final Integer NUMBER_OF_STORES = 2;
    private static final Integer NUMBER_OF_WORKORDERS_RETURNED = 1;
    private static final Integer NUMBER_OF_ACTIVE_AND_DEAD_WORKORDERS_RETURNED = 2;
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final Schema.Fieldset FIELDS_TO_QUERY = SObjectType.WorkOrder.FieldSets.Store_Readiness_Check_Fields;
    private static final Schema.Fieldset FIELDS_TO_QUERY_BANKING_INFORMATION = SObjectType.WorkOrder.FieldSets.Banking_Information;
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Work Order';
    private static final String ONBOARDING_WORK_PLAN_TEMPLATE = 'Onboarding';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String OPPORTUNITY_MARKETPLACE_NINTEX_ID = 'WorkOrderSelectorTestMarketplaceNintexId';
    private static final String OPPORTUNITY_NAME = 'McDonald Test';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String PARENT_ACCOUNT_NAME = 'Parent Account';
    private static final String PROVISIONING_STATUS_PROVISIONING_COMPLETE = 'Provisioning Complete';
    private static final String PROVISIONING_STATUS_PROVISIONING_FAILED = 'Provisioning Failed';
    private static final String PROVISIONING_STATUS_READY_FOR_PROVISIONING = 'Ready for Provisioning';
    private static final String QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE = 'Unexpected result: The query does not return any WorkOrders';
    private static final String QUERY_RETURN_INCORRECT_COUNT_OF_CHILD_WORKORDER_ASSERT_MESSAGE = 'Unexpected result: The query does not return expected number of child WorkOrders';
    private static final String QUERY_RETURN_NO_CHILD_WORK_STEPS_ASSERT_MESSAGE = 'Unexpected result: The query does not return any child WorkSteps';
    private static final String QUERY_RETURN_NO_CHILD_WORK_PLANS_ASSERT_MESSAGE = 'Unexpected result: The query does not return any child WorkPlans';
    private static final String QUERY_RETURN_NO_CHILD_WORK_ORDERS_MATCHING_STORE_ID_ASSERT_MESSAGE = 'Unexpected result: The query does not return any child Work Orders with store account ids.';
    private static final String QUERY_RETURN_NO_PARENT_WORK_ORDERS_MATCHING_BUSINESS_TO_STORE_ASSIGNMENT_ASSERT_MESSAGE = 'Unexpected result: The query does not return any parent Work Orders with Business to Store Assignment.';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_BLOCKED = 'Blocked';
    private static final String STATUS_DEAD = 'Dead';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String STATUS_CONFIRMED = 'Confirmed';
    private static final String STORE_ACCOUNT_LEGAL_BUSINESS_NAME = 'Store Legal Business Name';
    private static final String TEST_USER_ALIAS = 'MockUser';
    private static final String TEST_USER_EMAIL_ID = 'mockUser@ParentWorkOrdersCreationSrvcImplTest.com';
    private static final String TEST_USER_NAME = 'mockUser@ParentWorkOrdersCreationSrvcImplTest.com.test';
    private static final String USER_ENCODING = 'UTF-8';
    private static final String USER_LAST_NAME = 'Mock User';
    private static final String USER_LOCALE = 'en_US';
    private static final String USER_TIMEZONE = 'GMT';
    private static final String WORK_ORDER_AC = 'Yes';
    private static final String WORK_ORDER_COO_BATCH_RUN_DATE_FIELD = 'COO_Batch_Run_Date__c';
    private static final String WORK_ORDER_MENU_TO_BE_COMPLETED_BY = 'Merchant';
    private static final String WORK_ORDER_SUBTYPE_WITHHOLDING = 'Withholding';
    private static final String WORK_ORDER_STATUS = 'Planning';
    private static final String WORK_ORDER_TYPE = 'COO';
    private static final String WORK_PLAN_NAME = 'COO Test';
    private static final String WORK_STEP_NAME_SETUP_BUSINESS = 'Setup Business';
    private static final String WORK_STEP_NAME_SETUP_MENU = 'Setup Menu';
    private static final String WORK_ORDER_SOURCE_SYSTEM = 'System';
    private static final String WORK_ORDER_TEMPLATE_ENTRY = 'Onboarding Marketplace';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_POSTSALES = 'Post-Sales';
    private static final String WORKORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final String WORKORDER_SOURCE_SALES = 'Sales';
    private static final String WORK_ORDER_SUBTYPE_RATE_CHANGE = 'Rate Change';
    private static final String WORK_ORDER_SUBTYPE_AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String WORK_ORDER_SUBTYPE_PARTNERSHIP_C_U = 'Partnership creation/update';
    private static final String WORKPLAN_NAME_GRANT_PORTAL_ACCESS = 'Grant Portal Access';
    private static final String WORKPLAN_NAME_MENU = 'Menu';
    private static final String WORKPLAN_NAME_ONBOARDING = 'Onboarding';
    private static final String WORKORDER_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String WORK_STEP_TEMPLATE_NAME = 'Review & Triage';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final Id STORE_RECORD_TYPE_ID;
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String TYPE_POS = 'POS';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String VERTICAL = 'Rx';
    private static final String PROVISIONING_STATUS_READINESS_CHECK_COMPLETE = 'Readiness Check Complete';
    private static final String CHILD_WORK_ORDER_ASSERT = 'Unexpected result: Child Work Order is not returned';





    /**
     * @description To test the Non-Contractual Updates by MINT USER.
     */
        @isTest
        private static void testWhenGetNonContractualUpdatesByMINTThenReturnData() {
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
                .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
                .setParent('Account', storeAccountFakeInstance);
            WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
                workOrderFakeInstance.setField(
                    WorkOrder.Provisioning_Status__c,
                    PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
                )
            );

            fflib_ApexMocks mocks = new fflib_ApexMocks();
            WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
                WorkOrdersSelector.class
            );


            mocks.startStubbing();
            mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
            mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByParentId(parentWorkOrder.Id)
            )
            .thenReturn( new List<WorkOrder>{childWorkOrder} );

            mocks.stopStubbing();


            Application.SELECTOR.setMock(mockWorkOrdersSelector);


        Test.startTest();
        NonContractualUpdatesWorkOrderMINTCtrl.MINTDataWrapper result = NonContractualUpdatesWorkOrderMINTCtrl.getNonContractualDataByMINT(parentWorkOrder.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'The result should not be null');


    }

}