/**
 * @author Deloitte
 * @date 04/07/2022
 * @description Service class for WorkStep rescue process related calculations logic.
 */
public inherited sharing class WorkStepsRescueCalculationService implements IHandleNotifierEvents {
    /**
     * @description It is used for getting parent Work Step Ids from the payload
     * received via platform event.
     * @JIRA# LEM-2043
     * @param events
     */
    public static void execute(List<Notifier__e> events) {
        service().handleNotifierEvents(events);
    }

    /**
     * @description It creates instance of IWorkStepsRescueCalculationService class.
     * @return IWorkStepsRescueCalculationService - instance of WorkStepsRescueCalculationServiceImpl
     */
    private static IWorkStepsRescueCalculationService service() {
        return (IWorkStepsRescueCalculationService) Application.Service.newInstance(
            IWorkStepsRescueCalculationService.class
        );
    }
}