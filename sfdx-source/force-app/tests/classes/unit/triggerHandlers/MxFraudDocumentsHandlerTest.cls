/**
 * @author Deloitte
 * @date 07/06/2024
 * @description Test class for MxFraudDocumentsHandler class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class MxFraudDocumentsHandlerTest {
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';
    private static final String DOCUMENT_STATUS_APPROVED = 'Approved';
    private static final String DOCUMENT_STATUS_PENDING = 'Pending Review';

    /**
     * @description This method is used to test MxFraudDocumentsHandler TriggerHandler
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<Mx_Fraud_Document__c> newMxFraudDocuments = new List<Mx_Fraud_Document__c>();
        MxFraudDocumentsHandler mxFraudDocumentsHandlerInstance = new MxFraudDocumentsHandler(
            newMxFraudDocuments
        );
        MxFraudDocumentsHandler.Constructor handlerConstructor = new MxFraudDocumentsHandler.Constructor();
        handlerConstructor.construct(newMxFraudDocuments);
        System.assertNotEquals(
            mxFraudDocumentsHandlerInstance,
            handlerConstructor.construct(newMxFraudDocuments),
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Mx Fraud Documents outbound integration initiated
     * when Mx Fraud Documents are inserted.
     */
    @IsTest
    private static void testWhenMxFraudDocumentsInsertedThenInitiateOutboundIntegration() {
        Id mxFraudDocumentId = Fake.generateId(Mx_Fraud_Document__c.class);
        List<Mx_Fraud_Document__c> newMxFraudDocuments = new List<Mx_Fraud_Document__c>{
            new Mx_Fraud_Document__c(Id = mxFraudDocumentId)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxFraudDocumentsService mxFraudDocumentsServiceMock = (IMxFraudDocumentsService) mocks.mock(
            IMxFraudDocumentsService.class
        );
        Application.SERVICE.setMock(IMxFraudDocumentsService.class, mxFraudDocumentsServiceMock);
        fflib_SObjectDomain.Test.Database.onInsert(newMxFraudDocuments);
        fflib_SObjectDomain.triggerHandler(MxFraudDocumentsHandler.class);
        ((IMxFraudDocumentsService) mocks.verify(mxFraudDocumentsServiceMock, 1))
            .sendMxFraudDocumentDetailsForOutboundIntegration(newMxFraudDocuments);
    }

    /**
     * @description To test Mx Fraud Documents outbound integration initiated
     * when Mx Fraud Document version is updated.
     */
    @isTest
    private static void testWhenMxFraudDocumentsVersionUpdatedThenInitiateOutboundIntegration() {
        Id mxFraudDocumentId = Fake.generateId(Mx_Fraud_Document__c.class);
        Mx_Fraud_Document__c mxFraudDocument = new Mx_Fraud_Document__c(
            Id = mxFraudDocumentId,
            Document_Version__c = 1,
            Mx_Document_Verification_Status__c = DOCUMENT_STATUS_PENDING
        );
        Map<Id, Mx_Fraud_Document__c> oldMxFraudDocuments = new Map<Id, Mx_Fraud_Document__c>{
            mxFraudDocumentId => mxFraudDocument
        };
        Mx_Fraud_Document__c newMxFraudDocument = new Mx_Fraud_Document__c(
            Id = mxFraudDocumentId,
            Document_Version__c = 2,
            Mx_Document_Verification_Status__c = DOCUMENT_STATUS_PENDING
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxFraudDocumentsService mxFraudDocumentsServiceMock = (IMxFraudDocumentsService) mocks.mock(
            IMxFraudDocumentsService.class
        );
        Application.SERVICE.setMock(IMxFraudDocumentsService.class, mxFraudDocumentsServiceMock);
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<Mx_Fraud_Document__c>{ newMxFraudDocument },
            oldMxFraudDocuments
        );
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(MxFraudDocumentsHandler.class);
        ((IMxFraudDocumentsService) mocks.verify(mxFraudDocumentsServiceMock, 1))
            .sendMxFraudDocumentDetailsForOutboundIntegration(
                new List<Mx_Fraud_Document__c>{ newMxFraudDocument }
            );
    }
}