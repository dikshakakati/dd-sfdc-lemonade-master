/**
 * @description Trigger on Task Object
 */
trigger Tasks on Task (
    after insert,
    after update

) {
	fflib_SObjectDomain.triggerHandler(TasksHandler.class);
}