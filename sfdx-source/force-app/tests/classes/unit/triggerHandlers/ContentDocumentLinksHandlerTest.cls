/**
 * @description Handler Test Class for ContentDocumentLinksHandler
 * @date 07/03/2024
 * @author Deloitte
 */
@isTest(seeAllData=false)
public class ContentDocumentLinksHandlerTest {

    /**
     * @description SuppressWarnings are being used as the Handler is being used to perform
     * calls to Domain methods and no updates are directly performed using the
     * handler method.
     * The suppress warning used helps bypass the PMD Rule error for mandatory
     * assert statements for unit tests
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenContentDocumentLinkIsInsertedThenCallContentDocumentLinkDomain() {

        Id contentDocLink1 = Fake.generateId(ContentDocumentLink.class);
        Id qli1 = Fake.generateId(SBQQ__Quote__c.class);

        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>{
            (ContentDocumentLink) new Fake(ContentDocumentLink.class)
                .setField(ContentDocumentLink.Id, contentDocLink1)
                .setField(ContentDocumentLink.LinkedEntityId, qli1)
                .toSobject()
             };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContentDocumentLinks contentDocumentLinkMock = (IContentDocumentLinks) mocks.mock(IContentDocumentLinks.class);
        mocks.startStubbing();
        mocks.when(contentDocumentLinkMock.getType()).thenReturn(Schema.ContentDocumentLink.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(contentDocumentLinkMock);

        fflib_SObjectDomain.Test.Database.onInsert(contentDocLinkList);
        fflib_SObjectDomain.triggerHandler(ContentDocumentLinksHandler.class);
        ((IContentDocumentLinks) mocks.verify(contentDocumentLinkMock, 1)).updateIOTemplateLinksOnBriefItems();
    }
}