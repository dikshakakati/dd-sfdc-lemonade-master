/**
 * @author Deloitte
 * @date 04/04/2024
 * @description Service Class to handle Onboarding & Activation Events Service.
 */
public inherited sharing class OnboardingActivationsEventsService {
    /**
     * @description It creates multiple events of type Onboarding_Activation__e using the passed topic
     * and corresponding payload in a single transaction.
     * @param payloadsByTopic - map of topic to payloads to be passed
     */
    public static void publishBulkEvents(Map<String, List<String>> payloadsByTopic) {
        service().publishBulkEvents(payloadsByTopic);
    }

    /**
     * @description It creates events of type Onboarding_Activation__e using the passed topic
     * and corresponding payload and publishes the events.
     * @param payloadsByTopic - map of topic to payload
     */
    public static void publishEvents(Map<String, String> payloadsByTopic) {
        service().publishEvents(payloadsByTopic);
    }

    /**
     * @description It creates events of type Onboarding_Activation__e using the passed topic
     * and corresponding payload. It combines publish of the events with other records commit
     * in a single transaction.
     * @param payloadsByTopic - map of topic to payload
     * @param uow - instance of UnitOfWork
     */
    public static void publishEvents(
        Map<String, String> payloadsByTopic,
        fflib_ISObjectUnitOfWork uow
    ) {
        service().publishEvents(payloadsByTopic, uow);
    }

    /**
     * @description It creates instance of OnboardingActivaitonsEventsServiceImpl class.
     * @return IOnboardingActivationsEventsService - return instance of OnboardingActivaitonsEventsServiceImpl
     */
    private static IOnboardingActivationsEventsService service() {
        return (IOnboardingActivationsEventsService) Application.Service.newInstance(
            IOnboardingActivationsEventsService.class
        );
    }
}