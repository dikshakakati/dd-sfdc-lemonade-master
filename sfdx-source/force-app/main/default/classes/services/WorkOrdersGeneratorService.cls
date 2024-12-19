/**
 * @author Deloitte
 * @date 06/04/2024
 * @description Service class for Parent Work Orders creation related logic.
 */
public inherited sharing class WorkOrdersGeneratorService implements IHandleOnboardingActivationsEvents {
    /**
     * @description It allows NotifierEvents handler to pass events to the service class
     * corresponding to a topic.
     * @param onboardingActivationsEvents
     */
    public static void execute(List<Onboarding_Activation__e> onboardingActivationsEvents) {
        service().handleOnboardingActivationsEvents(onboardingActivationsEvents);
    }

    /**
     * @description It returns the calculated date excluding weekends based on the passed start date
     * and offset to add.
     * @param startDate
     * @param offsetToAdd
     * @return Date
     */
    public static Date calculateDateExcludingWeekends(Datetime startDate, Integer offsetToAdd) {
        return service().calculateDateExcludingWeekends(startDate, offsetToAdd);
    }

    /**
     * @description calling newInstance for service class.
     * @return IWorkOrdersGeneratorService - returning interface.
     */
    private static IWorkOrdersGeneratorService service() {
        return (IWorkOrdersGeneratorService) Application.SERVICE.newInstance(
            IWorkOrdersGeneratorService.class
        );
    }
}