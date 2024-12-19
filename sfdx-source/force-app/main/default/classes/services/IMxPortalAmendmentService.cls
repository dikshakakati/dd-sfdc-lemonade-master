/**
 * @author Deloitte
 * @date 07/01/2024
 * @description Interface class for MxPortalAmendmentService.
 */
public interface IMxPortalAmendmentService {
    /**
     * @description It is used to handle the published Instant Ingestor events for Mx Portal Integration.
     * @param events
     */
    void handleMxPortalEvents(List<Instant_Ingestor__e> events);
}