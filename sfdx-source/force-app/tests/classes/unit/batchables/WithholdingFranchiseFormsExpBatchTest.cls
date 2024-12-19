/**
 * @author Deloitte
 * @date 09/15/2023
 * @description Test class for WithholdingFranchiseFormsExpirationBatch class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class WithholdingFranchiseFormsExpBatchTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String APPROVED = 'Approved';
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected Error: The Batch has not been triggered yet';
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String SCHEDULED_JOB_NAME = WithholdingFranchiseFormsExpirationBatch.class
        .getName();
    private static final String WITHHOLDING_OPT_OUT = System.Label.FranchiseType_Withholding_Opt_out;

    /**
     * @description It is used to test if the Franchise Form Request records to be expired
     * for Withholding Opt-out are retrieved.
     */
    @isTest
    private static void testWhenStartMethodCalledThenWithholdingOptOutFranchiseFormsToExpireRetrieved() {
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        parentBusinessAccount.Withholding_Opt_out_Expiry_Date__c = Date.today() - 1;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFranchiseFormRequestsSelector mockFranchiseFormRequestsSelector = (IFranchiseFormRequestsSelector) mocks.mock(
            IFranchiseFormRequestsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockFranchiseFormRequestsSelector.sObjectType())
            .thenReturn(Merchant_Pop_Up_Response__c.SObjectType);
        mocks.when(
                mockFranchiseFormRequestsSelector.selectApprovedWithholdingOptOutFranchiseFormsToExpire()
            )
            .thenReturn(null);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockFranchiseFormRequestsSelector);
        WithholdingFranchiseFormsExpirationBatch batchInstance = new WithholdingFranchiseFormsExpirationBatch();
        Test.startTest();
        batchInstance.start(null);
        Test.stopTest();
        ((IFranchiseFormRequestsSelector) mocks.verify(mockFranchiseFormRequestsSelector, 1))
            .selectApprovedWithholdingOptOutFranchiseFormsToExpire();
    }

    /**
     * @description It is used to test when update is performed on approved Franchise Form Request record's
     * field 'Disable Mx Form Submission For This URL' to true in execute method.
     */
    @isTest
    private static void testWhenWithholdingOptOutFranchiseFormsToExpirePassedToExecuteThenFieldDisableMxFormSubmissionForThisUrlUpdatedToTrue() {
        Id merchantPopUpResponseID = fflib_IDGenerator.generate(
            Merchant_Pop_Up_Response__c.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        parentBusinessAccount.Withholding_Opt_out_Expiry_Date__c = Date.today() - 1;
        Fake merchantPopUpResponseFakeInstance = new Fake(Merchant_Pop_Up_Response__c.class)
            .setField(Merchant_Pop_Up_Response__c.Id, merchantPopUpResponseID)
            .setField(Merchant_Pop_Up_Response__c.Approval_Status__c, APPROVED)
            .setField(Merchant_Pop_Up_Response__c.Mx_Corporate_Account__c, parentBusinessAccount.Id)
            .setField(Merchant_Pop_Up_Response__c.Select_the_Franchise_Type__c, WITHHOLDING_OPT_OUT)
            .setField(
                Merchant_Pop_Up_Response__c.Disable_Mx_Form_Submission_For_This_URL__c,
                false
            );
        Merchant_Pop_Up_Response__c testMerchantPopUpResponse = (Merchant_Pop_Up_Response__c) merchantPopUpResponseFakeInstance.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFranchiseFormRequestsSelector mockFranchiseFormRequestsSelector = (IFranchiseFormRequestsSelector) mocks.mock(
            IFranchiseFormRequestsSelector.class
        );
        IFranchiseFormRequestsService franchiseFormRequestsServiceMock = (IFranchiseFormRequestsService) mocks.mock(
            IFranchiseFormRequestsService.class
        );
        mocks.startStubbing();
        mocks.when(mockFranchiseFormRequestsSelector.sObjectType())
            .thenReturn(Merchant_Pop_Up_Response__c.SObjectType);
        mocks.when(
                mockFranchiseFormRequestsSelector.selectApprovedWithholdingOptOutFranchiseFormsToExpire()
            )
            .thenReturn(null);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockFranchiseFormRequestsSelector);
        Application.SERVICE.setMock(
            IFranchiseFormRequestsService.class,
            franchiseFormRequestsServiceMock
        );
        WithholdingFranchiseFormsExpirationBatch batchInstance = new WithholdingFranchiseFormsExpirationBatch();
        Test.startTest();
        batchInstance.execute(
            null,
            new List<Merchant_Pop_Up_Response__c>{ testMerchantPopUpResponse }
        );
        batchInstance.finish(null);
        Test.stopTest();
        ((IFranchiseFormRequestsService) mocks.verify(franchiseFormRequestsServiceMock, 1))
            .expireWithholdingOptOutFranchiseForms(
                new List<Merchant_Pop_Up_Response__c>{ testMerchantPopUpResponse }
            );
    }

    /**
     * @description It is used to validate that schedulable context execute
     * is scheduling the batch job correctly.
     **/
    @isTest
    private static void testWhenBatchIsScheduledThenBatchExecutedOnScheduledTime() {
        Test.startTest();
        String jobId = System.schedule(
            SCHEDULED_JOB_NAME,
            CRON_EXPRESSION,
            new WithholdingFranchiseFormsExpirationBatch()
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