/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Domain Class for ContentDocumentLinks Object.
 */
public inherited sharing class ContentDocumentLinks extends fflib_SObjects implements IContentDocumentLinks {
    /**
     * @description This method is used to return the IContentDocumentLinks interface
     * @param recordList
     * @return IContentDocumentLinks
     */
    public static IContentDocumentLinks newInstance(List<ContentDocumentLink> recordList) {
        return (IContentDocumentLinks) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public ContentDocumentLinks(List<ContentDocumentLink> sObjectList) {
        super(sObjectList, Schema.ContentDocumentLink.SObjectType);
    }

    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList List<Object>
         * @return fflib_SObjects
         * Subscription - list of SBQQ__Subscription__c
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (ContentDocumentLinks.constructorMock != null) {
                return (fflib_SObjects) ContentDocumentLinks.constructorMock.construct(objectList);
            }
            return new ContentDocumentLinks((List<SObject>) objectList);
        }
    }

    /**
     * @description Calls BriefItemsService to update Draft Contract Fields when IO Templates are inserted
     * is inserted
     * @JIRA# LEM-16593
     */

    public void updateIOTemplateLinksOnBriefItems() {
        List<ContentDocumentLink> conDocLinks = (List<ContentDocumentLink>) getRecords();
        Set<Id> quoteRelatedContDocLinks = new Set<Id>();
        for(ContentDocumentLink cdl : conDocLinks){
            Schema.SobjectType objectName = cdl.LinkedEntityId.getSobjectType();
            if(objectName == SBQQ__Quote__c.SObjectType){
                quoteRelatedContDocLinks.add(cdl.LinkedEntityId);
            }
        }
        if(quoteRelatedContDocLinks.isEmpty()){
            return;
        }
        Map<Id, Id> quoteIdTempId = new Map<Id, Id>();
        for (ContentDocumentLink ioTemplate : ContentDocumentLinkSelector.newInstance().selectDraftIOTemplates(quoteRelatedContDocLinks)) {
            if(ioTemplate.ContentDocumentId != null) {
                quoteIdTempId.put(ioTemplate.LinkedEntityId, ioTemplate.ContentDocumentId);
            }
        }
        if(quoteIdTempId.isEmpty()) {
            return;
        }
        BriefItemsService.updateDraftIoTemplateOnExistingBriefItems(quoteIdTempId);
    }
}