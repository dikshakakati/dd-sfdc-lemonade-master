/**
 * @author Deloitte
 * @date 09/09/2024
 * @description Integration Test class for MxTagAssociationsBatch.
 */
@isTest
public class MxTagAssociationsBatchIntegrationTest {
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected Error: The Batch has not been triggered yet';
    private static final String ASSERT_MESSAGE_MISMATCH_CONCATENATED_MX_TAGS = 'Unexpected Result: Mismatch for Mx Tag Associations Concatenated Value';
    private static final String ACCOUNT_NAME = 'Account Test';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String MX_TAG_NAME_TIER = 'Tier 100';
    private static final String MX_TAG_NAME_TOP = 'Top 100';
    private static final String MX_TAG_NAME_MARKET_MAKER = 'Market Maker';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STAGE_PITCHING = 'Pitching';
    private static final String OPPORTUNITY_NAME_TEST = 'Test 1';
    private static final String OPPORTUNITY_NAME_TEST_2 = 'Test 2';
    private static final String CONCATENATED_MX_TAGS= 'Tier 100; Top 100';
    /**
     * @description To test if the service method is called when the batch runs.
     */
    @isTest
    private static void testWhenMxTagAssociationCreatedThenConcatenateActiveMxTagsOnOpportunities() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        List<Account> accounts = new List<Account>{
            new Account(Name = ACCOUNT_NAME , RecordTypeId = accRecordTypeBusiness, Segment__c = ACCOUNT_SEGMENT_SMB)
        };
        insert accounts;

        List<MxTag__c > mxTags  = new List<MxTag__c  >{
            new MxTag__c (Name = MX_TAG_NAME_TIER, Status__c = STATUS_ACTIVE),
            new MxTag__c ( Name = MX_TAG_NAME_TOP, Status__c = STATUS_ACTIVE)
        };
        insert mxTags;

        List<Mx_Tag_Association__c > mxTagAssociations  = new List<Mx_Tag_Association__c >{
            new Mx_Tag_Association__c(
                Account__c  = accounts[0].Id,
                MxTag__c = mxTags[0].Id
            ),
            new Mx_Tag_Association__c(
                Account__c  = accounts[0].Id,
                MxTag__c = mxTags[1].Id
            )
        };
	insert mxTagAssociations;

	List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = OPPORTUNITY_NAME_TEST,
                StageName = STAGE_PITCHING,
                CloseDate = system.today().addDays(25),
                AccountId = accounts[0].Id,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = OPPORTUNITY_NAME_TEST_2,
                StageName = STAGE_PITCHING,
                CloseDate = system.today().addDays(25),
                AccountId = accounts[0].Id,
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunities;
        Test.startTest();
        MxTagAssociationsBatch batchObject = new MxTagAssociationsBatch();
        Database.executeBatch(batchObject);
        Test.stopTest();

        List<Opportunity> updatedOpportunities = new List<Opportunity>();
        updatedOpportunities = [SELECT Id, Mx_Tag_Associations_Concatenated__c FROM Opportunity];

        System.assertEquals(updatedOpportunities[0].Mx_Tag_Associations_Concatenated__c, 'Tier 100; Top 100', ASSERT_MESSAGE_MISMATCH_CONCATENATED_MX_TAGS);
    }

    @isTest
    private static void testWhenMxTagAssociationCreatedThenConcatenateActiveMxTagsOnOpportunitiesWithFieldNotBlank() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        List<Account> accounts = new List<Account>{
            new Account(Name = ACCOUNT_NAME , RecordTypeId = accRecordTypeBusiness, Segment__c = ACCOUNT_SEGMENT_SMB)
        };
        insert accounts;

        List<MxTag__c > mxTags  = new List<MxTag__c  >{
            new MxTag__c (Name = MX_TAG_NAME_TIER, Status__c = STATUS_ACTIVE),
            new MxTag__c ( Name = MX_TAG_NAME_TOP, Status__c = STATUS_ACTIVE)
        };
        insert mxTags;

        List<Mx_Tag_Association__c > mxTagAssociations  = new List<Mx_Tag_Association__c >{
            new Mx_Tag_Association__c(
                Account__c  = accounts[0].Id,
                MxTag__c = mxTags[0].Id
            ),
            new Mx_Tag_Association__c(
                Account__c  = accounts[0].Id,
                MxTag__c = mxTags[1].Id
            )
        };
	insert mxTagAssociations;

	List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = OPPORTUNITY_NAME_TEST,
                StageName = STAGE_PITCHING,
                CloseDate = system.today().addDays(25),
                AccountId = accounts[0].Id,
                Estimated_Number_of_Stores__c = 1,
                Mx_Tag_Associations_Concatenated__c = MX_TAG_NAME_MARKET_MAKER
            )
        };
        insert opportunities;
        Test.startTest();
        MxTagAssociationsBatch batchObject = new MxTagAssociationsBatch();
        Database.executeBatch(batchObject);
        Test.stopTest();

        List<Opportunity> updatedOpportunities = new List<Opportunity>();
        updatedOpportunities = [SELECT Id, Mx_Tag_Associations_Concatenated__c FROM Opportunity];

        System.assertEquals(updatedOpportunities[0].Mx_Tag_Associations_Concatenated__c, CONCATENATED_MX_TAGS, ASSERT_MESSAGE_MISMATCH_CONCATENATED_MX_TAGS);
    }
    /**
    * @description It is used to validate that the schedulable context execute
    * is scheduling the batch job correctly.
    */
    @isTest
    private static void testWhenBatchIsScheduledThenConcatenateActiveMxTagsOnOpportunities() {
        String cronExp = '0 0 1 * * ?';
        Test.startTest();
        String jobId = System.schedule(
            MxTagAssociationsBatchIntegrationTest.class.getName(),
            cronExp,
            new MxTagAssociationsBatch()
        );
        Test.stopTest();
        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(
            Time.newInstance(1, 0, 0, 0),
            cronTriggerRecord.NextFireTime.time(),
            BATCH_NOT_TRIGGERED_ASSERT_MESSAGE
        );
    }
}