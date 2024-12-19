/**
 * @author Deloitte
 * @date 10/05/2022
 * @description Service class for WorkStepDependencies related logic.
 */
public inherited sharing class WorkStepDependenciesService {
    /**
     * @description It checks dependee WorkSteps's Status to enable banner message
     * and get banner message from associated WorkPlanTemplatEntry record.
     * @JIRA# LEM-1217
     * @param sObjectId - Id of WorkPlan or WorkStep
     * @return BannerMessageWrapper
     */
    public static BannerMessageWrapper getBannerMessageDetails(Id sObjectId) {
        return service().getBannerMessageDetails(sObjectId);
    }

    /**
     * @description It collects dependent WorkStepIds for which all dependee WorkSteps have
     * Status as Complete.
     * @JIRA# LEM-1142
     * @JIRA# LEM-1217 - Moved to service class
     * @param sObjectIds - Set of WorkStepIds or Set of WorkPlanIds
     * @param sObjectType - Object type to identify grouping field
     * @return Map<Id, Set<String>> - Map of WorkStepId or WorkPlanId and associated Statueses
     */
    public static Map<Id, Set<String>> getSobjectIdToDependeeWorkStepStatuses(
        Set<Id> sObjectIds,
        Schema.SObjectType sObjectType
    ) {
        return service().getSobjectIdToDependeeWorkStepStatuses(sObjectIds, sObjectType);
    }

    /**
     * @description It creates instance of WorkStepDependenciesServiceImpl class.
     * @return IWorkStepDependenciesService - return instance of IWorkStepDependenciesService
     */
    private static IWorkStepDependenciesService service() {
        return (IWorkStepDependenciesService) Application.Service.newInstance(
            IWorkStepDependenciesService.class
        );
    }
}