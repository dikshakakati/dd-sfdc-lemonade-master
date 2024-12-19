/**
 * @author Deloitte
 * @date 07/03/2024
 * @description This is test class for ContentDocumentLinks class
 */
@isTest(seeAllData=false)
public class ContentDocumentLinksTest {
    /**
     * @description This is method used to test ContentDocumentLinks class
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
        ContentDocumentLinks contentDocumentLinkObj = new ContentDocumentLinks(contentDocumentLinkList);
        ContentDocumentLinks.newInstance(contentDocumentLinkList);
        System.assertNotEquals(
            ContentDocumentLinks.newInstance(contentDocumentLinkList),
            contentDocumentLinkObj,
            'Unexpected result: both objects are similar.'
        );
    }

    /**
     * @description To validate if ContentDocumentLink is inserted then BriefItemService
     * Should be called to update draft io template
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContentDocumentLinkIsInsertedThenCallBriefItemServiceToUpdateDraftIOTemplate() {
        Id contentDocLink2 = Fake.generateId(ContentDocumentLink.class);
        Id ql2 = Fake.generateId(SBQQ__Quote__c.class);
        Id contentDoc2 = Fake.generateId(ContentDocument.class);

        List<ContentDocumentLink> conDocLinkList = new List<ContentDocumentLink>{
            (ContentDocumentLink) new Fake(ContentDocumentLink.class)
                .setField(ContentDocumentLink.Id, contentDocLink2)
                .setField(ContentDocumentLink.LinkedEntityId, ql2)
                .setField(ContentDocumentLink.ContentDocumentId, contentDoc2)
                .setParent(
                    	'ContentDocument',
                    	new Fake(ContentDocument.class)
                    	.setField(ContentDocument.Id, contentDoc2)
                    	.setField(ContentDocument.Title, 'Insertion_Order_for_Q-123.pdf')
                	)
                .toSobject()
        };

        Set<Id> quoteId = new Set<Id>{ ql2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IContentDocumentLinkSelector cdlSelectorMock = (IContentDocumentLinkSelector) mocks.mock(
            IContentDocumentLinkSelector.class
        );
        IBriefItemsService mockBriefItemsService = (IBriefItemsService) mocks.mock(
            IBriefItemsService.class
        );

        mocks.startStubbing();
        mocks.when(cdlSelectorMock.sObjectType()).thenReturn(ContentDocumentLink.SObjectType);
        mocks.when(cdlSelectorMock.selectDraftIOTemplates(quoteId)).thenReturn(conDocLinkList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(cdlSelectorMock);
        Application.SERVICE.setMock(IBriefItemsService.class, mockBriefItemsService);
        //Act
        ContentDocumentLinks.newInstance(conDocLinkList).updateIOTemplateLinksOnBriefItems();
        //Assert
       ((IBriefItemsService) mocks.verify(mockBriefItemsService, 1))
            .updateDraftIoTemplateOnExistingBriefItems(new Map<Id, Id>{ ql2 => contentDoc2});
    }
}