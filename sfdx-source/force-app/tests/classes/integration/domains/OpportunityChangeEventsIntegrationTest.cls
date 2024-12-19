/**
 * @author Deloitte
 * @date06/17/2022
 * @description Integration Test for Opportunity Change Events Domain.
 */
@isTest
private class OpportunityChangeEventsIntegrationTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String NINTEX_SUBMISSION_ID = 'TestId';
    private static final String NINTEX_USE_CASE_DRIVE_FORM = 'Drive - Amendment';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String OPPORTUNITY_NAME = 'Oppportunity CDC Test';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Prospecting';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String SOURCE_NINTEX = 'Nintex';
    private static final String WORK_ORDER_NOT_CREATED_ASSERT_MESSAGE = 'Unexpected result: Work order record is not created.';
    private static final String WORK_ORDER_SUB_TYPE = 'Partnership creation/update';

    @testSetup
    static void setupData() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        Opportunity enterpriseOpportunity = new Opportunity(
            AccountId = accountList[0].Id,
            StageName = 'Pitching',
            CloseDate = Date.today(),
            Name = 'Test Opportunity',
            Pricebook2Id = pricebookId
        );
        insert enterpriseOpportunity;
    }

    @isTest
    private static void testWhenOpportunityIsChangedThenChangeDataEventIsCreated() {
        Opportunity enterpriseOpportunity = [SELECT Id, Name, AccountId FROM Opportunity][0];
        List<Account> nonParentAccount = [
            SELECT Id, Name
            FROM Account
            WHERE Id != :enterpriseOpportunity.AccountId
        ];
        Test.enableChangeDataCapture();
        Test.getEventBus().deliver();

        List<Opportunity_Account_Relationship__c> opportunityAccountRelationships = new List<Opportunity_Account_Relationship__c>{
            new Opportunity_Account_Relationship__c(Opportunity__c = enterpriseOpportunity.Id)
        };
        insert opportunityAccountRelationships;
        Test.startTest();
        enterpriseOpportunity.AccountId = nonParentAccount[0].Id;
        enterpriseOpportunity.Source__c = SOURCE_NINTEX;
        update enterpriseOpportunity;
        Test.stopTest();
        /*List<Opportunity_Account_Relationship__c> relationshipsAfterReparenting = [
            SELECT Id, Name
            FROM Opportunity_Account_Relationship__c
            WHERE Opportunity__c = :enterpriseOpportunity.Id
        ];*/

        System.assertEquals(
            nonParentAccount[0].Id,
            enterpriseOpportunity.AccountId,
            'Unexpected Error: The Opportunity was not appropriately reparented.'
        );

        /*System.assertEquals(
            true,
            relationshipsAfterReparenting.isEmpty(),
            'Unexpected Error: The related Opportunity Account Relationship records were not deleted as expected'
        );*/
    }

    @isTest
    private static void testWhenOpportunityIsChangedThenRelationshipsAreNotDeleted() {
        Opportunity enterpriseOpportunity = [SELECT Id, Name, AccountId FROM Opportunity][0];
        Test.enableChangeDataCapture();
        Test.getEventBus().deliver();

        List<Opportunity_Account_Relationship__c> opportunityAccountRelationships = new List<Opportunity_Account_Relationship__c>{
            new Opportunity_Account_Relationship__c(Opportunity__c = enterpriseOpportunity.Id)
        };
        insert opportunityAccountRelationships;

        Test.startTest();
        enterpriseOpportunity.StageName = 'Prospecting';
        update enterpriseOpportunity;
        Test.stopTest();
        List<Opportunity_Account_Relationship__c> relationshipsAfterReparenting = [
            SELECT Id, Name
            FROM Opportunity_Account_Relationship__c
            WHERE Opportunity__c = :enterpriseOpportunity.Id
        ];

        System.assertEquals(
            1,
            relationshipsAfterReparenting.size(),
            'Unexpected Error: The related Opportunity Account Relationship records were not deleted as expected.'
        );
    }

    @isTest
    private static void testWhenOpportunityIsNotReparetedThenNoRuntimeErrorOccurs() {
        Opportunity enterpriseOpportunity = [SELECT Id, Name, AccountId FROM Opportunity][0];
        List<Account> parentAccount = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :enterpriseOpportunity.AccountId
        ];
        Test.enableChangeDataCapture();
        Test.getEventBus().deliver();

        List<Opportunity_Account_Relationship__c> opportunityAccountRelationships = new List<Opportunity_Account_Relationship__c>{
            new Opportunity_Account_Relationship__c(Opportunity__c = enterpriseOpportunity.Id)
        };
        insert opportunityAccountRelationships;

        Test.startTest();
        enterpriseOpportunity.AccountId = parentAccount[0].Id;
        update enterpriseOpportunity;
        Test.stopTest();

        List<Opportunity_Account_Relationship__c> relationshipsAfterReparenting = [
            SELECT Id, Name
            FROM Opportunity_Account_Relationship__c
            WHERE Opportunity__c = :enterpriseOpportunity.Id
        ];

        System.assertEquals(
            1,
            relationshipsAfterReparenting.size(),
            'Unexpected Error: The related Opportunity Account Relationship records were deleted.'
        );
    }

    @isTest
    private static void testWhenOpportunityIsReparetedWithNoRelationsThenNoRuntimeErrorOccurs() {
        Opportunity enterpriseOpportunity = [SELECT Id, Name, AccountId FROM Opportunity][0];
        List<Account> nonParentAccount = [
            SELECT Id, Name
            FROM Account
            WHERE Id != :enterpriseOpportunity.AccountId
        ];
        Test.enableChangeDataCapture();
        Test.getEventBus().deliver();

        Test.startTest();
        enterpriseOpportunity.AccountId = nonParentAccount[0].Id;
        update enterpriseOpportunity;
        Test.stopTest();

        List<Opportunity_Account_Relationship__c> relationshipsAfterReparenting = [
            SELECT Id, Name
            FROM Opportunity_Account_Relationship__c
            WHERE Opportunity__c = :enterpriseOpportunity.Id
        ];

        System.assertEquals(
            true,
            relationshipsAfterReparenting.isEmpty(),
            'Unexpected Error: The reparenting led to a runtime issue'
        );
    }

    /**
     * @description To test initiation of parent Work Order creation
     * on Opportunity creation with Nintex Id
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityCreatedThenParentWorkOrderCreationInitiated() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Commission_Calculation_Methodology__c = 'DoorDash Platform Price';

        insert businessAccount;
        Account storeAccountWithDriveNintexId = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccountWithDriveNintexId.Activated_Centrally_AC__c = ACCOUNT_ACTIVATED_CENTRALLY_YES;
        storeAccountWithDriveNintexId.Order_Protocol__c = ORDER_PROTOCOL_EMAIL;
        storeAccountWithDriveNintexId.Proposed_Date_of_Activation__c = System.today().addDays(10);
        storeAccountWithDriveNintexId.Drive_Nintex_Id__c = NINTEX_SUBMISSION_ID;
        insert storeAccountWithDriveNintexId;

        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        WorkPlanTemplate workPlanTemplate = new WorkPlanTemplate(
            IsActive = true,
            Name = TYPE_DRIVE,
            Type__c = TYPE_DRIVE
        );
        insert workPlanTemplate;
        Work_Order_Template__c workOrderTemplate = new Work_Order_Template__c(
            Name = TYPE_DRIVE,
            Type__c = TYPE_DRIVE
        );
        insert workOrderTemplate;

        Work_Order_Template_Entry__c workOrderTemplateEntry = new Work_Order_Template_Entry__c(
            Work_Order_Template__c = workOrderTemplate.Id,
            Work_Plan_Template__c = workPlanTemplate.Id
        );
        insert workOrderTemplateEntry;
        User processAutomationUser = [SELECT Id FROM User WHERE Name = 'Process Automation User' LIMIT 1];
        System.runAs(processAutomationUser) {
            Opportunity opportunityInstance = new Opportunity(
                AccountId = businessAccount.Id,
                Name = OPPORTUNITY_NAME,
                CloseDate = System.today().addMonths(2),
                Pricebook2Id = Test.getStandardPricebookId(),
                Source__c = SOURCE_NINTEX,
                StageName = 'Closed Won',
                Drive_Nintex_Id__c = NINTEX_SUBMISSION_ID,
                Nintex_Use_Case__c = NINTEX_USE_CASE_DRIVE_FORM
            );
            Test.enableChangeDataCapture();
            Test.getEventBus().deliver();
            Test.startTest();
            insert opportunityInstance;
            Test.stopTest();
            List<WorkOrder> createdWorkOrder = [
                SELECT Id
                FROM WorkOrder
                WHERE Opportunity__c = :opportunityInstance.Id
            ];
            System.assertEquals(1, createdWorkOrder.size(), WORK_ORDER_NOT_CREATED_ASSERT_MESSAGE);
        }

    }

    /**
     * @description To test initiation of parent Work Order created
     * when Opportunity updated with Nintex Id.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNintexIdUpdatedOnOpportunityThenParentWorkOrderCreationInitiated() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Commission_Calculation_Methodology__c = 'DoorDash Platform Price';
        businessAccount.Segment__c = 'Enterprise';
        insert businessAccount;
        Account storeAccountWithDriveNintexId = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccountWithDriveNintexId.Activated_Centrally_AC__c = ACCOUNT_ACTIVATED_CENTRALLY_YES;
        storeAccountWithDriveNintexId.Order_Protocol__c = ORDER_PROTOCOL_EMAIL;
        storeAccountWithDriveNintexId.Proposed_Date_of_Activation__c = System.today().addDays(10);
        storeAccountWithDriveNintexId.Drive_Nintex_Id__c = NINTEX_SUBMISSION_ID;
        insert storeAccountWithDriveNintexId;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;

        User processAutomationUser = [
            SELECT Id
            FROM User
            WHERE Name = 'Process Automation User'
            LIMIT 1
        ];
        System.runAs(processAutomationUser) {
            Opportunity opportunityInstance = new Opportunity(
                AccountId = businessAccount.Id,
                Name = OPPORTUNITY_NAME,
                CloseDate = System.today().addMonths(2),
                Pricebook2Id = Test.getStandardPricebookId(),
                StageName = 'Closed Won',
                Nintex_Use_Case__c = NINTEX_USE_CASE_DRIVE_FORM
            );
            opportunityInstance.Name = OPPORTUNITY_NAME;
            opportunityInstance.CloseDate = System.today().addMonths(2);
            opportunityInstance.Pricebook2Id = Test.getStandardPricebookId();
            opportunityInstance.Source__c = SOURCE_NINTEX;
            opportunityInstance.StageName = 'Closed Won';
            opportunityInstance.Nintex_Use_Case__c = NINTEX_USE_CASE_DRIVE_FORM;
            insert opportunityInstance;
            WorkPlanTemplate workPlanTemplate = new WorkPlanTemplate(
                IsActive = true,
                Name = TYPE_DRIVE,
                Type__c = TYPE_DRIVE
            );
            insert workPlanTemplate;
            Work_Order_Template__c workOrderTemplate = new Work_Order_Template__c(
                Name = TYPE_DRIVE,
                Type__c = TYPE_DRIVE
            );
            insert workOrderTemplate;
            Work_Order_Template_Entry__c workOrderTemplateEntry = new Work_Order_Template_Entry__c(
                Work_Order_Template__c = workOrderTemplate.Id,
                Work_Plan_Template__c = workPlanTemplate.Id
            );
            insert workOrderTemplateEntry;
            Test.enableChangeDataCapture();
            Opportunity opportunityWithNintexId = new Opportunity(
                Id = opportunityInstance.Id,
                Drive_Nintex_Id__c = NINTEX_SUBMISSION_ID
            );
            Test.startTest();
            upsert opportunityWithNintexId;
            Test.stopTest();
            Test.getEventBus().deliver();
            List<WorkOrder> createdWorkOrder = [
                SELECT Id
                FROM WorkOrder
                WHERE Opportunity__c = :opportunityInstance.Id
            ];
            System.assertEquals(1, createdWorkOrder.size(), WORK_ORDER_NOT_CREATED_ASSERT_MESSAGE);
        }
    }
}