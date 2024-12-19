/**
 * @author Deloitte
 * @date 14/03/2022
 * @description Trigger on RollUpEvent Platform Event
 */
trigger RollUpEvents on RollUpEvent__e(after insert) {
    fflib_SObjectDomain.triggerHandler(RollUpEventsHandler.class);
}