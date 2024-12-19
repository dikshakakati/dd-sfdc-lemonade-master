/**
 * @author Deloitte
 * @date 17/08/2022
 * @description Trigger on Attachment object.
 */
trigger Attachments on Attachment(after insert) {
    fflib_SObjectDomain.triggerHandler(AttachmentsHandler.class);
}