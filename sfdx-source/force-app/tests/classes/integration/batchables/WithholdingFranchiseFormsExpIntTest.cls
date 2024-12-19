/**
 * @author Deloitte
 * @date 09/21/2023
 * @description Integration Test class for WithholdingFranchiseFormsExpirationBatch
 */
@isTest
public class WithholdingFranchiseFormsExpIntTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_TYPE_CORPORATE = 'Corporate';
    private static final String APPROVED = 'Approved';
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected Error: The Batch has not been triggered yet';
    private static final string BUSINESS_ACCOUNT_NAME = 'Test Account for Batch';
    private static final String DRIVE_AMENDMENT = System.Label.FranchiseType_Drive_Amendment;
    private static final String WITHHOLDING_OPT_OUT = System.Label.FranchiseType_Withholding_Opt_out;

    /**
     * @description It is used to setup the relevant test data.
     */
    @testSetup
    private static void setupData() {
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            Type = ACCOUNT_TYPE_CORPORATE,
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            Withholding_Opt_out_Expiry_Date__c = Date.today() - 1,
            Segment__c ='SMB'
        );
        insert businessAccount;
    }

    /**
     * @description It is used to test when update is performed on approved Franchise Form Request record's
     * field 'Disable Mx Form Submission For This URL' to true by the batch class.
     */
    @isTest
    private static void testWhenApprovedWithholdingOptOutFranchiseFormsPassedThenFieldDisableMxFormSubmissionForThisUrlUpdatedToTrue() {
        Account retrievedBusinessAccount = [
            SELECT Id, Number_of_Days_to_Opt_out__c
            FROM Account
            LIMIT 1
        ];
        Merchant_Pop_Up_Response__c merchantPopUpResponse = new Merchant_Pop_Up_Response__c(
            Approval_Status__c = APPROVED,
            Mx_Corporate_Account__c = retrievedBusinessAccount.Id,
            Select_the_Franchise_Type__c = WITHHOLDING_OPT_OUT,
            Disable_Mx_Form_Submission_For_This_URL__c = false
        );
        insert merchantPopUpResponse;
        Test.startTest();
        WithholdingFranchiseFormsExpirationBatch batchInstance = new WithholdingFranchiseFormsExpirationBatch();
        Database.executeBatch(batchInstance);
        Test.stopTest();
        Merchant_Pop_Up_Response__c updatedResponseForm = [
            SELECT Id, Disable_Mx_Form_Submission_For_This_URL__c
            FROM Merchant_Pop_Up_Response__c
            LIMIT 1
        ];
        System.assertEquals(
            true,
            updatedResponseForm.Disable_Mx_Form_Submission_For_This_URL__c,
            BATCH_NOT_TRIGGERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to test when Franchise Form Request record's for Drive - Amendment are passed then
     * field 'Disable Mx Form Submission For This URL' is not updated to true by the batch class.
     */
    @isTest
    private static void testWhenPendingWithholdingOptOutFranchiseFormsPassedThenFieldDisableMxFormSubmissionForThisUrlNotUpdatedToTrue() {
        Account retrievedBusinessAccount = [
            SELECT Id, Number_of_Days_to_Opt_out__c
            FROM Account
            LIMIT 1
        ];
        Merchant_Pop_Up_Response__c merchantPopUpResponse = new Merchant_Pop_Up_Response__c(
            Approval_Status__c = APPROVED,
            Mx_Corporate_Account__c = retrievedBusinessAccount.Id,
            Select_the_Franchise_Type__c = DRIVE_AMENDMENT,
            Disable_Mx_Form_Submission_For_This_URL__c = false
        );
        insert merchantPopUpResponse;
        Test.startTest();
        WithholdingFranchiseFormsExpirationBatch batchInstance = new WithholdingFranchiseFormsExpirationBatch();
        Database.executeBatch(batchInstance);
        Test.stopTest();
        Merchant_Pop_Up_Response__c updatedResponseForm = [
            SELECT Id, Disable_Mx_Form_Submission_For_This_URL__c
            FROM Merchant_Pop_Up_Response__c
            LIMIT 1
        ];
        System.assertEquals(
            false,
            updatedResponseForm.Disable_Mx_Form_Submission_For_This_URL__c,
            BATCH_NOT_TRIGGERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to validate that the schedulable context execute
     * is scheduling the batch job correctly.
     */
    @isTest
    private static void testWhenBatchScheduledThenStatusUpdated() {
        String cronExpression = '0 0 0 3 9 ? *';
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Type = ACCOUNT_TYPE_CORPORATE;
        businessAccount.Withholding_Opt_out_Expiry_Date__c = Date.today() - 1;
        insert businessAccount;
        Test.startTest();
        String jobId = System.schedule(
            'TestWitholdingFranchiseFormExpirationBatchSchedule',
            cronExpression,
            new WithholdingFranchiseFormsExpirationBatch()
        );
        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        Test.stopTest();
        System.assertEquals(
            0,
            cronTriggerRecord.TimesTriggered,
            BATCH_NOT_TRIGGERED_ASSERT_MESSAGE
        );
        System.assertEquals(
            cronExpression,
            cronTriggerRecord.CronExpression,
            BATCH_NOT_TRIGGERED_ASSERT_MESSAGE
        );
    }
}