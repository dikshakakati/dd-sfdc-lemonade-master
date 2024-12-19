/**
 * @author DoorDash
 * @date 03/21/2023
 * @description Test class for IntegrationRequestsSelector class.
 */
@isTest(seeAllData=false)
private class IntegrationRequestsSelectorTest {
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE = 'Business';
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_BUSINESS_RECORD_TYPE)
        .getRecordTypeId();
    private static final String ACCOUNT_NAME = 'Test KFC';
    private static final String STORE_ID = '24680';
    private static final string ONBOARDING_ID = '222-8888-999-4444';
    private static final String INCORRECT_NUMBER_OF_IR_ASSERT_MESSAGE = 'Unexpected result: Number of Integration Requests is not equal the expected value';
    private static final string INTEGRATION_TYPE_TABLET = 'Tablet Case Sync';
    private static final String STORE_ID_MISMATCH = 'Unexpected result: Store Id not matching';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String OPPORTUNITY_NAME = 'McDonald Test';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Work Order';
    private static final string SFDC_ORG_LEMONADE = 'Lemonade';
    private static final string INTEGRATION_TYPE_POS = 'POS Requests';
    private static final String STATUS_PROCESSED = 'Processed';
    private static final String STATUS_PENDING = 'Pending';
    private static final String BATCH_ID = 'B001';
    private static Integer integrationRequestDeleteOlderThanNMonths = 6; // @jira LEM-10464
    private static Set<String> integrationRequestDeleteTypes = new Set<String>{
        'POS Requests',
        'Tablet Case Sync'
    }; // @jira LEM-10464
    private static final Set<String> SFDC_STATUS = new Set<String>{ 'Pending' };
    private static final Set<String> SFDC_ORG = new Set<String>{ 'Lemonade' };
    private static Integer integrationRequestQueryLostNDays = 3;
    private static final Datetime TWO_DAYS_AGO = Datetime.now().addDays(-2);
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_AC = 'Yes';
    private static final String WORK_ORDER_STATUS = 'Planning';
    private static final String WORK_PLAN_NAME_STOREFRONT = 'Storefront';
    private static final String WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE = 'Review & Triage';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_STEP_TEMPLATE_NAME_DELIVER_TABLET = 'Deliver Tablet';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        IntegrationRequestsSelector integrationRequestInstance = new IntegrationRequestsSelector();
        Schema.SObjectType typeOfObject = integrationRequestInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = integrationRequestInstance.getSObjectFieldList();
        IntegrationRequestsSelector.newInstance();
        System.assertEquals(
            Schema.Integration_Request__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Integration_Request__c.Id,
                Integration_Request__c.Action__c,
                Integration_Request__c.Activation_Date__c,
                Integration_Request__c.Business_Id__c,
                Integration_Request__c.Store_Id__c,
                Integration_Request__c.Provider_Account_Owner_Email__c,
                Integration_Request__c.Onboarding_Type__c,
                Integration_Request__c.Onboarding_Id__c,
                Integration_Request__c.Notes__c,
                Integration_Request__c.Sfdc_Status__c,
                Integration_Request__c.Decision_Maker_Email__c,
                Integration_Request__c.Integration_Id__c,
                Integration_Request__c.Integration_Provider__c,
                Integration_Request__c.Target_Status__c,
                Integration_Request__c.Exclusion_Code__c,
                Integration_Request__c.Batch_Id__c,
                Integration_Request__c.payload__c,
                Integration_Request__c.Account__c,
                Integration_Request__c.Integration_Type__c,
                Integration_Request__c.Product_Status__c,
                Integration_Request__c.Stage__c,
                Integration_Request__c.Stage_Status__c,
                Integration_Request__c.Store_Update_Event_Received_Date_Time__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
    /**
     * @description To validate the Integration Requests selection based on onboarding Ids.
     **/
    @isTest
    private static void testWhenSelectByOnboardingIdThenReturnIntegrationRequests() {
        Integration_Request__c irRequest = ServiceIntegrationDataBuilder.createIntegrationRequestInstance(
            STORE_ID
        );
        irRequest.Onboarding_Id__c = ONBOARDING_ID;
        irRequest.SFDC_Org__c = SFDC_ORG_LEMONADE;
        irRequest.Integration_Type__c = INTEGRATION_TYPE_POS;
        irRequest.Sfdc_Status__c = STATUS_PROCESSED;
        insert irRequest;
        List<Integration_Request__c> irResultByOnboardingId = IntegrationRequestsSelector.newInstance()
            .selectByOnboardingId(
                new Set<String>{ ONBOARDING_ID },
                new Set<String>{ STATUS_PROCESSED }
            );
        System.assertEquals(
            1,
            irResultByOnboardingId.size(),
            INCORRECT_NUMBER_OF_IR_ASSERT_MESSAGE
        );
        List<Integration_Request__c> irResultByStoreId = IntegrationRequestsSelector.newInstance()
            .selectById(new Set<Id>{ irRequest.id });
        System.assertEquals(1, irResultByStoreId.size(), INCORRECT_NUMBER_OF_IR_ASSERT_MESSAGE);
        System.assertEquals(STORE_ID, irResultByStoreId[0].Store_Id__c, STORE_ID_MISMATCH);
    }
    /**
     * @description To return integration request related to the matching batch Ids.
     **/
    @isTest
    private static void testWhenSelectByBatchIdThenReturnIntegrationRequests() {
        Integration_Request__c irRequest = ServiceIntegrationDataBuilder.createIntegrationRequestInstance(
            STORE_ID
        );
        irRequest.Onboarding_Id__c = ONBOARDING_ID;
        irRequest.SFDC_Org__c = SFDC_ORG_LEMONADE;
        irRequest.Integration_Type__c = INTEGRATION_TYPE_POS;
        irRequest.Sfdc_Status__c = STATUS_PROCESSED;
        irRequest.Batch_Id__c = BATCH_ID;
        insert irRequest;
        List<Integration_Request__c> irResultByBatchId = IntegrationRequestsSelector.newInstance()
            .selectByBatchId(new Set<String>{ BATCH_ID });
        System.assertEquals(1, irResultByBatchId.size(), INCORRECT_NUMBER_OF_IR_ASSERT_MESSAGE);
        System.assertEquals(STORE_ID, irResultByBatchId[0].Store_Id__c, STORE_ID_MISMATCH);
    }

    /**
     * @description To return integration request related to the integration types and created date.
     **/
    @isTest
    private static void testWhenSelectIntegrationRequestsByIntegrationTypeThenReturnIntegrationRequests() {
        Integration_Request__c irRequest = ServiceIntegrationDataBuilder.createIntegrationRequestInstance(
            STORE_ID
        );
        irRequest.Onboarding_Id__c = ONBOARDING_ID;
        irRequest.SFDC_Org__c = SFDC_ORG_LEMONADE;
        irRequest.Integration_Type__c = INTEGRATION_TYPE_POS;
        irRequest.Sfdc_Status__c = STATUS_PROCESSED;
        irRequest.Batch_Id__c = BATCH_ID;
        irRequest.createdDate = System.now().addMonths(-8);

        Integration_Request__c irRequest1 = ServiceIntegrationDataBuilder.createIntegrationRequestInstance(
            STORE_ID
        );
        irRequest1.Onboarding_Id__c = ONBOARDING_ID;
        irRequest1.SFDC_Org__c = SFDC_ORG_LEMONADE;
        irRequest1.Sfdc_Status__c = STATUS_PROCESSED;
        irRequest1.Batch_Id__c = BATCH_ID;
        irRequest1.createdDate = System.now().addMonths(-9);

        List<Integration_Request__c> intRequests = new List<Integration_Request__c>{
            irRequest,
            irRequest1
        };
        insert intRequests;
        DateTime integrationRequestDeleteOlderThanNMonthDate = System.now()
            .addMonths(-integrationRequestDeleteOlderThanNMonths);
        List<Integration_Request__c> irResultByTypeAndDate = IntegrationRequestsSelector.newInstance()
            .selectIntegrationRequestsByIntegrationType(
                integrationRequestDeleteTypes,
                integrationRequestDeleteOlderThanNMonthDate
            );
        System.assertEquals(1, irResultByTypeAndDate.size(), INCORRECT_NUMBER_OF_IR_ASSERT_MESSAGE);
    }

    /**
     * @description To return integration request related to the integration types and created date.
     **/
    @isTest
    private static void testWhenSelectIntegrationRequestsByStatusAndOrgThenReturnIntegrationRequests() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = 'Enterprise',
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            AccountId = businessAccount.Id
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_PLAN_NAME_STOREFRONT
        );
        insert parentWorkOrder;
        WorkPlan parentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            Status__c = STATUS_NOT_STARTED,
            Type__c = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            WorkPlanId = parentWorkPlan.Id
        );
        insert parentWorkStep;

        Integration_Request__c irRequest = ServiceIntegrationDataBuilder.createIntegrationRequestInstance(
            STORE_ID
        );
        irRequest.Onboarding_Id__c = parentWorkStep.Id;
        irRequest.SFDC_Org__c = SFDC_ORG_LEMONADE;
        irRequest.Integration_Type__c = INTEGRATION_TYPE_TABLET;
        irRequest.Sfdc_Status__c = STATUS_PENDING;
        irRequest.Batch_Id__c = BATCH_ID;
        //irRequest.createdDate = System.now().addMonths(-8);
        irRequest.createdDate = TWO_DAYS_AGO;
        //irRequest.systemmodstamp = SEVEN_DAYS_AGO;

        Integration_Request__c irRequest1 = ServiceIntegrationDataBuilder.createIntegrationRequestInstance(
            STORE_ID
        );
        irRequest1.Onboarding_Id__c = ONBOARDING_ID;
        irRequest1.SFDC_Org__c = SFDC_ORG_LEMONADE;
        irRequest1.Sfdc_Status__c = STATUS_PENDING;
        irRequest1.Batch_Id__c = BATCH_ID;
        irRequest1.createdDate = System.now().addMonths(-9);

        List<Integration_Request__c> intRequests = new List<Integration_Request__c>{
            irRequest,
            irRequest1
        };

        insert intRequests;
        List<Integration_Request__c> irResultByTypeAndDate = IntegrationRequestsSelector.newInstance()
            .selectIntegrationRequestsByStatusAndOrg(
                SFDC_STATUS,
                SFDC_ORG,
                integrationRequestQueryLostNDays
            );

        System.assertEquals(2, irResultByTypeAndDate.size(), INCORRECT_NUMBER_OF_IR_ASSERT_MESSAGE);
    }

    /**
     * @description To validate the Integration Requests selection based on onboarding Ids.
     **/
    @isTest
    private static void testWhenOnboardingIdIsPassedThenReturnIntegrationRequests() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = 'Enterprise',
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            AccountId = businessAccount.Id
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_PLAN_NAME_STOREFRONT
        );
        insert parentWorkOrder;
        WorkPlan parentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WORK_STEP_TEMPLATE_NAME_DELIVER_TABLET,
            Status__c = STATUS_NOT_STARTED,
            Type__c = WORK_STEP_TEMPLATE_NAME_DELIVER_TABLET,
            WorkPlanId = parentWorkPlan.Id
        );
        insert parentWorkStep;
        Integration_Request__c irRequest = ServiceIntegrationDataBuilder.createIntegrationRequestInstance(
            STORE_ID
        );
        irRequest.Onboarding_Id__c = String.valueOf(parentWorkStep.Id);
        irRequest.SFDC_Org__c = SFDC_ORG_LEMONADE;
        irRequest.Integration_Type__c = INTEGRATION_TYPE_TABLET;
        irRequest.Sfdc_Status__c = STATUS_PENDING;
        irRequest.Parent_Integration_Request__c = null;
        insert irRequest;

        List<Integration_Request__c> irResultByOnboardingId = IntegrationRequestsSelector.newInstance()
            .selectIntegrationRequestsByOnboardingId(new Set<Id>{ parentWorkStep.Id });
        System.assertEquals(
            1,
            irResultByOnboardingId.size(),
            INCORRECT_NUMBER_OF_IR_ASSERT_MESSAGE
        );
    }

    /**
     * @description This method is to test selectFailedIntegrationRequestsForMdsStoreSync
     */
    @isTest
    private static void testWhenIntegrationRequestFailedThenReturnInBatchModeQuery() {
        Integration_Request__c ir1 = new Integration_Request__c(
            sfdc_status__c = 'Pending',
            Integration_Type__c = 'MDS Store Sync',
            createddate = Datetime.now().addMinutes(-20)
        );
        Integration_Request__c ir2 = new Integration_Request__c(
            sfdc_status__c = 'Processed',
            Integration_Type__c = 'MDS Store Sync'
        );
        Integration_Request__c ir3 = new Integration_Request__c(
            sfdc_status__c = 'Failed',
            Integration_Type__c = 'MDS Store Sync',
            createddate = Datetime.now().addDays(-10),
            lastmodifieddate = Datetime.now().addDays(-8)
        );
        Integration_Request__c ir4 = new Integration_Request__c(
            sfdc_status__c = 'Failed',
            Integration_Type__c = 'MDS Store Sync',
            createddate = Datetime.now().addMinutes(-5),
            error_message__c = 'OP received from MDS is not defined'
        );
        Integration_Request__c ir5 = new Integration_Request__c(
            sfdc_status__c = 'Failed',
            Integration_Type__c = 'MDS Store Sync',
            createddate = Datetime.now().addDays(-10),
            lastmodifieddate = Datetime.now().addDays(-8),
            error_message__c = 'Business Reference not found in DDMx'
        );
        Integration_Request__c ir6 = new Integration_Request__c(
            sfdc_status__c = 'Failed',
            Integration_Type__c = 'MDS Store Sync',
            createddate = Datetime.now().addMinutes(-20)
        );
        fflib_SObjectDomain.getTriggerEvent(IntegrationRequestsHandler.class).disableAll();
        insert new List<Integration_Request__c>{ ir1, ir2, ir3, ir4, ir5, ir6 };
        fflib_SObjectDomain.getTriggerEvent(IntegrationRequestsHandler.class).enableAll();

        Test.startTest();
        Database.QueryLocator queryLocator = IntegrationRequestsSelector.newInstance()
            .selectFailedIntegrationRequestsForMdsStoreSync();
        List<Integration_Request__c> irsList = Database.query(queryLocator.getQuery());
        Test.stopTest();
        Map<Id, Integration_Request__c> resultForBatchMode = new Map<Id, Integration_Request__c>(
            irsList
        );
        Assert.isTrue(
            resultForBatchMode.containsKey(ir1.Id),
            'Batch result should contain this failed xref'
        );
        Assert.isTrue(
            resultForBatchMode.containsKey(ir5.Id),
            'Batch result should contain this failed xref'
        );
        Assert.isFalse(
            resultForBatchMode.containsKey(ir2.Id),
            'Batch result shouldnot contain this processed xref'
        );
        Assert.isTrue(
            resultForBatchMode.containsKey(ir3.Id),
            'Batch result should contain this Failed xref irrespective of createddate time'
        );
        Assert.isFalse(
            resultForBatchMode.containsKey(ir4.Id),
            'Batch result shouldnot contain this failed xref'
        );
        Assert.isFalse(
            resultForBatchMode.containsKey(ir6.Id),
            'Batch result shouldnot contain this failed xref'
        );
    }
}