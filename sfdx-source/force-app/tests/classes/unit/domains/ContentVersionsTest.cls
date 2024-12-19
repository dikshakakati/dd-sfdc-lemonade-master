/**
 * @author Deloitte
 * @date 07/11/2024
 * @description Test class for ContentVersions Domain class.
 */
@isTest(SeeAllData=false)
private class ContentVersionsTest {
    private static final String CONTENT_VERSION_TYPE_FRAUD = 'Fraud';
    private static final String FIELD_UPDATE_ASSERT_MESSAGE = 'Unexpected Result: Field value is not updated';

    /**
     * @description To test Mx Fraud Document Id updated based on First Publish Location Id
     * when Content Versions are created.
     */
    @isTest
    private static void testWhenFraudContentVersionsCreatedThenUpdateMxFraudDocumentId() {
        Id contentVersionId = Fake.generateId(ContentVersion.class);
        Id mxFraudDocumentId = Fake.generateId(Mx_Fraud_Document__c.class);
        ContentVersion newContentVersion = (ContentVersion) new Fake(ContentVersion.class)
            .setField(ContentVersion.Id, contentVersionId)
            .setField(ContentVersion.Type__c, CONTENT_VERSION_TYPE_FRAUD)
            .setField(ContentVersion.FirstPublishLocationId, mxFraudDocumentId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        ContentVersions.newInstance(new List<ContentVersion>{ newContentVersion })
            .addToMxFraudDocuments();
        Test.stopTest();
        system.assertEquals(
            mxFraudDocumentId,
            newContentVersion.Mx_Fraud_Document__c,
            FIELD_UPDATE_ASSERT_MESSAGE
        );
    }
}