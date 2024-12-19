/**
 * @author Deloitte
 * @date 17/03/2022
 * @description This is a service implementation class for platform eventBus triggerContext
 */
public inherited sharing class EventBusTriggerContextImpl implements IEventBusTriggerContext {
    private EventBus.TriggerContext context;

    /**
     * @description To get last error
     */
    public String lastError {
        get {
            return context.lastError;
        }
        private set;
    }

    /**
     * @description To get retries
     */
    public Integer retries {
        get {
            return context.retries;
        }
        private set;
    }

    /**
     * @description Constructor of class
     */
    public EventBusTriggerContextImpl() {
        this.context = EventBus.TriggerContext.currentContext();
    }

    /**
     * @description To get resume checkpoint
     * @return String
     */
    public String getResumeCheckpoint() {
        return context.getResumeCheckpoint();
    }

    /**
     * @description To set resume checkpoint
     * @param resumeReplayId
     */
    public void setResumeCheckpoint(String resumeReplayId) {
        context.setResumeCheckpoint(resumeReplayId);
    }
}