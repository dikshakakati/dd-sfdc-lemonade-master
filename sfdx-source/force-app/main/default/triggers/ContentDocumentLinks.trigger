/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Trigger on ContentDocumentLink object.
 */
trigger ContentDocumentLinks on ContentDocumentLink (after insert) {
    fflib_SObjectDomain.triggerHandler(ContentDocumentLinksHandler.class);
}