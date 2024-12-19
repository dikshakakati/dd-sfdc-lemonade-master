/**
 * @description Trigger on EmailMessages Object
 */
trigger EmailMessages on EmailMessage (   
    after insert
) {
    fflib_SObjectDomain.triggerHandler(EmailMessagesHandler.class);
}