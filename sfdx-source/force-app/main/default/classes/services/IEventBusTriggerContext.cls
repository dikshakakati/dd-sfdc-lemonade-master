/**
 * @author Deloitte
 * @date   04/03/2022
 * @description This is the service interface for platform eventBus triggerContext
 */
public interface IEventBusTriggerContext {
    /**
     * @description To get resume checkpoint
     * @return String
     */
    String getResumeCheckpoint();

    /**
     * @description To set resume checkpoint
     * @param resumeReplayId
     */
    void setResumeCheckpoint(String resumeReplayId);
}