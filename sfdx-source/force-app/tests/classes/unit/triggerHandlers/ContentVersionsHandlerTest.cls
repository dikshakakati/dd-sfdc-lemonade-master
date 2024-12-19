/**
 * @author Deloitte
 * @date 07/06/2024
 * @description Test class for ContentVersionsHandler class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class ContentVersionsHandlerTest {
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';

    /**
     * @description This method is used to test ContentVersionsHandler TriggerHandler
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<ContentVersion> newContentVersions = new List<ContentVersion>();
        ContentVersionsHandler contentVersionsHandlerInstance = new ContentVersionsHandler(
            newContentVersions
        );
        ContentVersionsHandler.Constructor handlerConstructor = new ContentVersionsHandler.Constructor();
        handlerConstructor.construct(newContentVersions);
        System.assertNotEquals(
            contentVersionsHandlerInstance,
            handlerConstructor.construct(newContentVersions),
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Mx Fraud Documents creation process initiated
     * when Content Version records are inserted.
     */
    @IsTest
    private static void testWhenContentVersionsInsertedThenMxFraudDocumentsCreation() {
        Id contentVersionId = Fake.generateId(ContentVersion.class);
        List<ContentVersion> newContentVersions = new List<ContentVersion>{
            new ContentVersion(Id = contentVersionId)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContentVersionsService contentVersionsServiceMock = (IContentVersionsService) mocks.mock(
            IContentVersionsService.class
        );
        Application.SERVICE.setMock(IContentVersionsService.class, contentVersionsServiceMock);
        fflib_SObjectDomain.Test.Database.onInsert(newContentVersions);
        fflib_SObjectDomain.triggerHandler(ContentVersionsHandler.class);
        ((IContentVersionsService) mocks.verify(contentVersionsServiceMock, 1))
            .organizeDocumentsInsertedFromAPIService(newContentVersions);
    }

    /**
     * @description To test Content Version field updates initiated
     * when Content Version records are inserted.
     */
    @IsTest
    private static void testWhenContentVersionsInsertedThenInitiateFieldUpdates() {
        Id contentVersionId = Fake.generateId(ContentVersion.class);
        List<ContentVersion> newContentVersions = new List<ContentVersion>{
            new ContentVersion(Id = contentVersionId)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContentVersions contentVersionsMock = (IContentVersions) mocks.mock(
            IContentVersions.class
        );
        mocks.startStubbing();
        mocks.when(contentVersionsMock.getType()).thenReturn(Schema.ContentVersion.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(contentVersionsMock);
        fflib_SObjectDomain.Test.Database.onInsert(newContentVersions);
        fflib_SObjectDomain.triggerHandler(ContentVersionsHandler.class);
        ((IContentVersions) mocks.verify(contentVersionsMock, 1)).addToMxFraudDocuments();
    }
}