/**
 * @author Deloitte
 * @date 03/11/2022
 * @description Facade for System methods.
 */
public with sharing class SystemFacade {
    @TestVisible
    private static System.TriggerOperation triggerContext;

    /**
     * @description It is used to get trigger context through Trigger.OperationType or
     * triggerContext variable set by a calling class.
     * It allows mocking of trigger context in unit tests.
     * @return System.TriggerOperation
     */
    public static System.TriggerOperation getTriggerContext() {
        return triggerContext == null ? Trigger.OperationType : triggerContext;
    }
}
