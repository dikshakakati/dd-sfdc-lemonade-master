/**
 * @author Deloitte
 * @date 17/03/2022
 * @description This is a service class for platform eventBus triggerContext
 */
public inherited sharing class EventBusTriggerContext {
    /**
     * @description To get current context
     * @return IEventBusTriggerContext
     */
    public static IEventBusTriggerContext currentContext() {
        return service();
    }

    /**
     * @description To get resume checkpoint
     * @return String
     */
    public static String getResumeCheckpoint() {
        return service().getResumeCheckpoint();
    }

    /**
     * @description To set resume checkpoint
     * @param resumeReplayId
     */
    public static void setResumeCheckpoint(String resumeReplayId) {
        service().setResumeCheckpoint(resumeReplayId);
    }

    private static IEventBusTriggerContext service() {
        return (IEventBusTriggerContext) Application.SERVICE.newInstance(
            IEventBusTriggerContext.class
        );
    }
}