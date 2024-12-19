/**
 * @author Deloitte
 * @date 04/07/2022
 * @description Interface of service class for WorkStep rescue process related calculations logic.
 */
public interface IWorkStepsRescueCalculationService {
    /**
     * @description It gets parent WorkStep Ids from the payload received via platform event
     * and performs calculations related to number of blocked or resolved child WorkSteps.
     * @param events
     */
    void handleNotifierEvents(List<Notifier__e> events);
}