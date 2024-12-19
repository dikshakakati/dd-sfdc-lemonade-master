/**
 * @author Deloitte
 * @date 05/02/2024
 * @description Test class for Approvals class.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.MethodNamingConventions')
private class ApprovalsTest {
    private static final String APPROVAL_AQS_QUOTE = 'AQS_Quote__c';
    private static final Integer APPROVAL_STEP = 1;
    private static final Integer EXISTING_APPROVAL_STEP = 2;
    private static final String APPROVAL_STATUS_APPROVED = 'Approved';
    private static final String APPROVAL_STATUS_REJECTED = 'Rejected';
    private static final String API_ENDPOINT =
        URL.getOrgDomainURL().toExternalForm() + '/services/apexrest/sbaa/ServiceRouter';
    private static final String IDENTIFIER_REPLACE_ID = 'replaceId';
    private static final String IDENTIFIER_REPLACE_SAVER = 'replaceSaver';
    private static final String IDENTIFIER_REPLACE_COMMENTS = 'replaceComments';
    private static final String INVALID_FIELD_UPDATE_MESSAGE = 'The folllowing fields cannot be changed: Record Field, Approval Step.';
    private static final String INVALID_APPROVAL_UPDATE_MESSAGE = 'This approval is already ';
    private static final String INVALID_APPROVAL_UPDATE_BY = ' by ';
    private static final String REQUEST_JSON_BODY = '{"model":"{\\"approvalId\\":\\"replaceId\\", \\"comments\\":\\"replaceComments\\"}","saver":"SBAA.ApprovalRestApiProvider.replaceSaver"}';
    private static final String SAVER_APPROVE = 'Approve';
    private static final String SAVER_REJECT = 'Reject';
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String APPROVAL_REQUESTED_REASON = 'Reason to approve the approval';
    //private static final String APPROVAL_STATUS_APPROVED = 'Requested';
    private static final String APPROVAL_STATUS_REQUESTED = 'Requested';
    private static final String MOCK_RESPONSE = '{Mock_Response}';
    private static final Integer STATUS_CODE_SUCCESS = 200;
    private static final Integer STATUS_CODE_FAILURE = 503;

    /**
     * @description It is used to test if domain class is instantiated correctly.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenClassInstantiatesThenRun() {
        List<sbaa__Approval__c> approvalsList = new List<sbaa__Approval__c>();
        Approvals.newInstance(approvalsList);
        Approvals approvalsObject = new Approvals(approvalsList);
        Approvals.Constructor constructorObject = new Approvals.Constructor();
        constructorObject.construct(approvalsList);
        System.assertNotEquals(
            Approvals.newInstance(approvalsList),
            approvalsObject,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to test if the approval is approved by the user, a validation
     * is thrown on change of the status.
     */
    @isTest
    private static void testWhenApprovalStatusApprovedThenStatusChangeRestricted() {
        Id approvalId = fflib_IDGenerator.generate(sbaa__Approval__c.SObjectType);
        Id changedApprovedById = fflib_IDGenerator.generate(User.SObjectType);
        Id existingApprovedById = fflib_IDGenerator.generate(User.SObjectType);
        sbaa__Approval__c[] newApprovals = new List<sbaa__Approval__c>{
            new sbaa__Approval__c(
                Id = approvalId,
                sbaa__Status__c = APPROVAL_STATUS_APPROVED,
                Approval_Status__c = APPROVAL_STATUS_APPROVED,
                sbaa__ApprovedBy__c = changedApprovedById
            )
        };
        sbaa__Approval__c[] existingApprovals = new List<sbaa__Approval__c>{
            new sbaa__Approval__c(
                Id = approvalId,
                sbaa__Status__c = APPROVAL_STATUS_APPROVED,
                Approval_Status__c = APPROVAL_STATUS_REQUESTED,
                sbaa__ApprovedBy__c = existingApprovedById
            )
        };
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Approvals.newInstance(existingApprovals).initiateAdvancedApprovalsAPI(newApprovals);
        System.assertEquals(1, ApexPages.getMessages().size(), INVALID_FIELD_UPDATE_MESSAGE);
    }

    /**
     * @description It is used to test if the approval is rejected by the user, a validation
     * is thrown on change of the status.
     */
    @isTest
    private static void testWhenApprovalStatusRejectedThenStatusChangeRestricted() {
        Id approvalId = fflib_IDGenerator.generate(sbaa__Approval__c.SObjectType);
        Id changedRejectedById = fflib_IDGenerator.generate(User.SObjectType);
        Id existingRejectedById = fflib_IDGenerator.generate(User.SObjectType);
        sbaa__Approval__c[] newApprovals = new List<sbaa__Approval__c>{
            new sbaa__Approval__c(
                Id = approvalId,
                sbaa__Status__c = APPROVAL_STATUS_REJECTED,
                Approval_Status__c = APPROVAL_STATUS_REJECTED,
                sbaa__RejectedBy__c = changedRejectedById
            )
        };
        sbaa__Approval__c[] existingApprovals = new List<sbaa__Approval__c>{
            new sbaa__Approval__c(
                Id = approvalId,
                sbaa__Status__c = APPROVAL_STATUS_REJECTED,
                Approval_Status__c = APPROVAL_STATUS_REQUESTED,
                sbaa__RejectedBy__c = existingRejectedById
            )
        };
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Approvals.newInstance(existingApprovals).initiateAdvancedApprovalsAPI(newApprovals);
        System.assertEquals(1, ApexPages.getMessages().size(), INVALID_FIELD_UPDATE_MESSAGE);
    }

    /**
     * @description It is used to check when values on the fields 'Approval Status' and 'Record Field'
     * are changed on slack notification then existing values stamped on approvals.
     */
    @isTest
    private static void testWhenNonRequiredApprovalFieldsChangedThenExistingValuesStamped() {
        Id approvalId = fflib_IDGenerator.generate(sbaa__Approval__c.SObjectType);
        Id changedRejectedById = fflib_IDGenerator.generate(User.SObjectType);
        Id existingRejectedById = fflib_IDGenerator.generate(User.SObjectType);
        sbaa__Approval__c[] newApprovals = new List<sbaa__Approval__c>{
            new sbaa__Approval__c(
                Id = approvalId,
                sbaa__Status__c = APPROVAL_STATUS_REJECTED,
                sbaa__ApprovalStep__c = APPROVAL_STEP,
                sbaa__RejectedBy__c = changedRejectedById
            )
        };
        sbaa__Approval__c[] existingApprovals = new List<sbaa__Approval__c>{
            new sbaa__Approval__c(
                Id = approvalId,
                sbaa__Status__c = APPROVAL_STATUS_REJECTED,
                sbaa__ApprovalStep__c = EXISTING_APPROVAL_STEP,
                sbaa__RejectedBy__c = existingRejectedById
            )
        };
        Approvals.newInstance(newApprovals)
            .updateApprovalFieldsWithExistingValues(
                new Map<Id, sbaa__Approval__c>(existingApprovals)
            );
        System.assertEquals(
            EXISTING_APPROVAL_STEP,
            existingApprovals[0].sbaa__ApprovalStep__c,
            INVALID_FIELD_UPDATE_MESSAGE
        );
    }

    /**
     * @description It is used to check when approvals are requested the field value of 'Approval requested reason' from quote
     * is stamped onto the 'Approval requested reason' field on Approval.
     */
    @IsTest
    private static void testQuoteRequestedReasonMappedToRelatedApprovals() {
        Id approvalId = fflib_IDGenerator.generate(sbaa__Approval__c.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        SBQQ__Quote__c[] newQuote = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = quoteId,
                Approval_Requested_Reason__c = APPROVAL_REQUESTED_REASON
            )
        };
        sbaa__Approval__c[] newApprovals = new List<sbaa__Approval__c>{
            new sbaa__Approval__c(
                Id = approvalId,
                AQS_Quote__c = quoteId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
    	IQuotesSelector quotesSelectorMock = (IQuotesSelector)mocks.mock(IQuotesSelector.class);
    	mocks.startStubbing();
        mocks.when(quotesSelectorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
    	mocks.when(quotesSelectorMock.selectById(new Set<Id>{quoteId})).thenReturn(newQuote);
    	mocks.stopStubbing();
        Application.SELECTOR.setMock(quotesSelectorMock);
        Approvals.newInstance(newApprovals)
            .updateRequestedReasonFromQuote();
        System.assertEquals(
            APPROVAL_REQUESTED_REASON,
            newApprovals[0].Approval_Requested_Reason__c,
            INVALID_FIELD_UPDATE_MESSAGE
        );
    }
}