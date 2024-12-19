/**
 * @author Deloitte
 * @date 04/30/2024
 * @description Test class for ApprovalsHandler class.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class ApprovalsHandlerTest {
    private static final String APPROVAL_AQS_QUOTE = 'AQS_Quote__c';
    private static final Integer APPROVAL_STEP = 1;
    private static final String APPROVAL_STATUS_APPROVED = 'Approved';
    private static final String APPROVAL_STATUS_REQUESTED = 'Requested';
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are present in database';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
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
     * @description It is used to test when after update is triggered then advanced approval API invoked.
     */
    @isTest
    private static void testWhenApprovalsUpdatedThenThenAPICallInitiatedCalled() {
        Id approvalId = fflib_IDGenerator.generate(sbaa__Approval__c.SObjectType);
        sbaa__Approval__c[] newApprovals = new List<sbaa__Approval__c>{
            new sbaa__Approval__c(
                Id = approvalId,
                sbaa__Status__c = APPROVAL_STATUS_REQUESTED,
                sbaa__RecordField__c = APPROVAL_AQS_QUOTE,
                sbaa__ApprovalStep__c = APPROVAL_STEP,
                Approval_Status__c = APPROVAL_STATUS_APPROVED
            )
        };
        sbaa__Approval__c[] existingApprovals = new List<sbaa__Approval__c>{
            new sbaa__Approval__c(
                Id = approvalId,
                sbaa__Status__c = APPROVAL_STATUS_REQUESTED,
                sbaa__RecordField__c = APPROVAL_AQS_QUOTE,
                sbaa__ApprovalStep__c = APPROVAL_STEP,
                Approval_Status__c = APPROVAL_STATUS_REQUESTED
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IApprovals approvalsMock = (IApprovals) mocks.mock(IApprovals.class);
        mocks.startStubbing();
        mocks.when(approvalsMock.getType()).thenReturn(sbaa__Approval__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(approvalsMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newApprovals,
            new Map<Id, SObject>(existingApprovals)
        );
        fflib_SObjectDomain.triggerHandler(ApprovalsHandler.class);
        ((IApprovals) mocks.verify(approvalsMock, 1)).initiateAdvancedApprovalsAPI(newApprovals);
    }

    /**
     * @description It is used to check when values on the fields 'Approval Status' and 'Record Field'
     * are changed on slack notification then existing values stamped on approvals.
     */
    @isTest
    private static void testWhenApprovalNonRequiredFieldsUpdatedThenExistingValuesStamped() {
        Id approvalId = fflib_IDGenerator.generate(sbaa__Approval__c.SObjectType);
        sbaa__Approval__c[] newApprovals = new List<sbaa__Approval__c>{
            new sbaa__Approval__c(
                Id = approvalId,
                sbaa__Status__c = APPROVAL_STATUS_REQUESTED,
                sbaa__RecordField__c = APPROVAL_AQS_QUOTE,
                sbaa__ApprovalStep__c = APPROVAL_STEP,
                Approval_Status__c = APPROVAL_STATUS_APPROVED
            )
        };
        sbaa__Approval__c[] existingApprovals = new List<sbaa__Approval__c>{
            new sbaa__Approval__c(
                Id = approvalId,
                sbaa__Status__c = APPROVAL_STATUS_REQUESTED,
                sbaa__RecordField__c = APPROVAL_AQS_QUOTE,
                sbaa__ApprovalStep__c = APPROVAL_STEP,
                Approval_Status__c = APPROVAL_STATUS_REQUESTED
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IApprovals approvalsMock = (IApprovals) mocks.mock(IApprovals.class);
        mocks.startStubbing();
        mocks.when(approvalsMock.getType()).thenReturn(sbaa__Approval__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(approvalsMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newApprovals,
            new Map<Id, SObject>(existingApprovals)
        );
        fflib_SObjectDomain.triggerHandler(ApprovalsHandler.class);
        ((IApprovals) mocks.verify(approvalsMock, 1))
            .updateApprovalFieldsWithExistingValues(
                new Map<Id, sbaa__Approval__c>(existingApprovals)
            );
    }

    /**
     * @description It is used to check when approvals are requested the field value of 'Approval requested reason' from quote
     * is stamped onto the 'Approval requested reason' field on Approval.
     */
    @isTest
    private static void testWhenQuoteRequestedThenReasonMappedToRelatedApprovals() {
        Id approvalId = fflib_IDGenerator.generate(sbaa__Approval__c.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        sbaa__Approval__c[] newApprovals = new List<sbaa__Approval__c>{
            new sbaa__Approval__c(
                Id = approvalId,
                AQS_Quote__c = quoteId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IApprovals approvalsMock = (IApprovals) mocks.mock(IApprovals.class);
        mocks.startStubbing();
        mocks.when(approvalsMock.getType()).thenReturn(Schema.sbaa__Approval__c.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(approvalsMock);
        fflib_SObjectDomain.Test.Database.onInsert(newApprovals);
        fflib_SObjectDomain.triggerHandler(ApprovalsHandler.class);
        ((IApprovals) mocks.verify(approvalsMock, 1)).updateRequestedReasonFromQuote();
    }
}