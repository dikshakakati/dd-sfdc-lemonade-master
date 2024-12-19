trigger IntegrationRequestProcessor on Integration_Request_Processor__e (after insert) {
	fflib_SObjectDomain.triggerHandler(NotifierEventsHandler.class);
}