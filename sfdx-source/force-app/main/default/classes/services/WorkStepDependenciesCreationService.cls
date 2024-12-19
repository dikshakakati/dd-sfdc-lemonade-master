/**
 * @author Deloitte
 * @date 12/23/2022
 * @description Service class for WorkStepDependencies creation logic.
 */
public inherited sharing class WorkStepDependenciesCreationService implements IHandleNotifierEvents {
    /**
     * @description It is being called through NotifierEvent class and triggers creation of
     * WorkStepDependencies by handling platform events.
     * @param events
     */
    public static void execute(List<Notifier__e> events) {
        service().initiateWorkStepDependenciesCreation(events);
    }

    /**
     * @description It creates instance of WorkStepDependenciesCreationServiceImpl class.
     * @return IWorkStepDependenciesCreationService
     */
    private static IWorkStepDependenciesCreationService service() {
        return (IWorkStepDependenciesCreationService) Application.Service.newInstance(
            IWorkStepDependenciesCreationService.class
        );
    }
}