/**
 * @author Deloitte
 * @date 07/02/2024
 * @description
 *
 */
public inherited sharing class MxPortalAmendmentService implements IHandleInstantIngestorEvents {
    /**
     * @description It is used to handle the published Instant Ingestor events for Mx Portal Integration.
     * @param instantIngestorEvents list of platform events with payload
     */
    public static void execute(List<Instant_Ingestor__e> instantIngestorEvents) {
        service().handleMxPortalEvents(instantIngestorEvents);
    }

    /**
     * @description It is used to create an instance of MxPortalAmendmentService class.
     * @return IMxPortalAmendmentService - return instance of MxPortalAmendmentServiceImpl
     */
    private static IMxPortalAmendmentService service() {
        return (IMxPortalAmendmentService) Application.Service.newInstance(
            IMxPortalAmendmentService.class
        );
    }
}