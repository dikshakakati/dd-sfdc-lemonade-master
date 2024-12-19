/**
 * @author Deloitte
 * @date 05/02/2024
 * @description Integration Test for Approvals Domain.
 */
@isTest
private class ApprovalsIntegrationTest {
    private static final String APPROVAL_AQS_QUOTE = 'AQS_Quote__c';
    private static final Integer APPROVAL_STEP_ONE = 1;
    private static final Integer APPROVAL_STEP_TWO = 2;
    private static final String APPROVAL_STATUS_APPROVED = 'Approved';
    private static final String APPROVAL_STATUS_REQUESTED = 'Requested';
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are present in database';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';
    private static final String INVALID_ASSERTION = 'Invalid Data';
    private static final String APPROVAL_REQUESTED_REASON = 'Reason to approve the approval';

    /**
     * @description It is used to check whether the callout method is invoked or not.
     */
    @isTest
    private static void testWhenApprovalsInsertedThenStatusUpdated() {
        SBQQ__Quote__c[] quote = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Approval_Requested_Reason__c = APPROVAL_REQUESTED_REASON
            )
        };
        insert quote;
        sbaa__Approval__c[] approvals = new List<sbaa__Approval__c>{
            new sbaa__Approval__c(
                sbaa__Status__c = APPROVAL_STATUS_REQUESTED,
                sbaa__RecordField__c = APPROVAL_AQS_QUOTE,
                sbaa__ApprovalStep__c = APPROVAL_STEP_ONE,
                Approval_Status__c = APPROVAL_STATUS_APPROVED,
                AQS_Quote__c = quote[0].Id
            ),
            new sbaa__Approval__c(
                sbaa__Status__c = APPROVAL_STATUS_REQUESTED,
                sbaa__RecordField__c = APPROVAL_AQS_QUOTE,
                sbaa__ApprovalStep__c = APPROVAL_STEP_ONE,
                Approval_Status__c = APPROVAL_STATUS_APPROVED,
                AQS_Quote__c = quote[0].Id
            )
        };
        insert approvals;
        Test.startTest();
        approvals[0].sbaa__ApprovalStep__c = APPROVAL_STEP_TWO;
        update approvals;
        Test.stopTest();
        List<sbaa__Approval__c> approvalRecords = [
            SELECT Id, Name, sbaa__ApprovalStep__c
            FROM sbaa__Approval__c
            WHERE Id = :approvals[0].Id
        ];
        System.assertEquals(
            APPROVAL_STEP_ONE,
            approvalRecords[0].sbaa__ApprovalStep__c,
            INVALID_ASSERTION
        );
    }
}