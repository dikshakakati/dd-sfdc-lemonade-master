/**
 * @author Deloitte
 * @date 06/04/2024
 * @description Service Interface for Parent Work Orders creation related logic.
 */
public interface IWorkOrdersGeneratorService {
    /**
     * @description It is used to handle and route the published
     * OnboardingActivationsEvents.
     * @JIRA# LEM-15362
     * @param onboardingActivationsEvents
     */
    void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    );

    /**
     * @description It returns the calculated date excluding weekends based on the passed start date
     * and offset to add.
     * @param startDate
     * @param offsetToAdd
     * @return Date
     */
    Date calculateDateExcludingWeekends(Datetime startDate, Integer offsetToAdd);
}