/**
 * @author Deloitte
 * @date 12/23/2022
 * @description Interface for service class of WorkStepDependencies creation logic.
 */
public interface IWorkStepDependenciesCreationService {
    /**
     * @description It is being called through NotifierEvent class and triggers creation of
     * WorkStepDependencies by handling platform events.
     * @param events
     */
    void initiateWorkStepDependenciesCreation(List<Notifier__e> events);
}