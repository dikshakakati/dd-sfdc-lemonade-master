/**
 * @author Deloitte
 * @date 04/12/2024
 * @description Integration Test class for UpdateTrialDurationOnQuoteLineBatch
 */
@isTest
private class UpdateTrialDurationOnQuoteLineBatchTest {
    private static final String ASSERTION_FAILED = 'Unexpected Result: Batch did not execute successfully';
    private static final String ONBOARDING_EVENT = 'Onboarding Event';
    private static final String SSMO = 'SSMO';
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String SUCCESS = 'Success';
    private static final String UNIQUE_IDENTIFER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String QUOTE = 'Quote';
    private static final String DASHPASS = 'dashpass';
    private static final String DELIVERY = 'Delivery';

    /**
     * @description To setup relevant test data.
     */
    @testSetup
    private static void setupQuoteLineDataForTrialPeriodUpdate() {
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT,
            Status__c = SUCCESS,
            Source__c = SSMO
        );
        insert inboundIngestionLog;

        Account testAccount = TestDataFactory.createAccount(false);
        testAccount.Segment__c = SEGMENT_SMB;
        insert testAccount;

        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User processAutomationUser = new User(
            Alias = 'pauto',
            Email = 'biz-apps-integrations+ddmx@testorg.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Process',
            LastName = 'Automation User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = systemAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'processautomation.user@dd.com'
        );
        SBQQ.TriggerControl.disable();
        Product2 product1 = CPQTestDataFactory.createProduct(false);
        product1.ProductCode = '10017';
        product1.Name = 'Premier Package';
        Product2 product2 = CPQTestDataFactory.createProduct(false);
        product2.ProductCode = '10061';
        product2.Name = 'Delivery';
        Product2 product3 = CPQTestDataFactory.createProduct(false);
        product3.ProductCode = '10046';
        product3.Name = 'Dashpass';
        insert new List<Product2>{ product1, product2, product3 };
        SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c(
            SBQQ__Number__c = 55,
            SBQQ__ConfiguredSKU__c = product1.Id,
            SBQQ__OptionalSKU__c = product2.Id
        );
        insert productOption;
        Opportunity testOppRec = CPQTestDataFactory.createOpportunity(testAccount.Id, false);
        testOppRec.Estimated_Number_of_Stores__c = 1;
        testOppRec.Source__c = 'SSMO';
        insert testOppRec;
        SBQQ__Quote__c newQuote = CPQTestDataFactory.createQuote(
            testOppRec,
            testAccount,
            null,
            false
        );
        newQuote.SBQQ__Type__c = QUOTE;
        insert newQuote;
        SBQQ__QuoteLine__c newQuoteLine = CPQTestDataFactory.createQuoteLine(
            product1,
            newQuote,
            false
        );
        newQuoteLine.Segment__c = SEGMENT_SMB;
        newQuoteLine.SBQQ__Product__c = product2.Id;
        newQuoteLine.Unique_Identifier__c = UNIQUE_IDENTIFER;
        newQuoteLine.SBQQ__ProductOption__c = productOption.Id;
        SBQQ__QuoteLine__c newQuoteLine2 = CPQTestDataFactory.createQuoteLine(
            product1,
            newQuote,
            false
        );
        newQuoteLine2.Segment__c = SEGMENT_SMB;
        newQuoteLine2.SBQQ__Product__c = product3.Id;
        newQuoteLine2.Unique_Identifier__c = UNIQUE_IDENTIFER;
        newQuoteLine2.SBQQ__ProductOption__c = productOption.Id;
        System.runAs(processAutomationUser) {
            insert new List<SBQQ__QuoteLine__c>{ newQuoteLine, newQuoteLine2 };
        }
        SBQQ.TriggerControl.enable();
    }
    /**
     * @description It is used to test the batch is updating the quote lines trial period or not.
     */
    @isTest
    private static void testWhenQuoteLinesWithoutTrialPeriodExecutedByBatchThenTrialPeriodUpdatedOnQuoteLines() {
        Test.startTest();
        Database.executeBatch(new UpdateTrialDurationOnQuoteLineBatch());
        Test.stopTest();
        SBQQ__QuoteLine__c quoteLinesWithTrialPeriod = [
            SELECT Id, Trial_Period__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Product__r.name = :DELIVERY
            LIMIT 1
        ];
        System.assertEquals(
            true,
            String.isNotBlank(quoteLinesWithTrialPeriod.Trial_Period__c),
            ASSERTION_FAILED
        );
    }
    /**
     * @description It is used to test the batch is updating the dashpass quote lines trial period or not.
     */
    @isTest
    private static void testWhenQuoteLinesWithDifferentPackageExecutedByBatchThenNoTrialPeriodUpdatedOnQuoteLines() {
        Test.startTest();
        Database.executeBatch(new UpdateTrialDurationOnQuoteLineBatch());
        Test.stopTest();
        SBQQ__QuoteLine__c quoteLinesWithTrialPeriod = [
            SELECT Id, Trial_Period__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Product__r.name = :DASHPASS
            LIMIT 1
        ];
        System.assertEquals(
            true,
            String.isBlank(quoteLinesWithTrialPeriod.Trial_Period__c),
            ASSERTION_FAILED
        );
    }
}