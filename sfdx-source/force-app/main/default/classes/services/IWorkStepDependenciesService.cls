/**
 * @author Deloitte
 * @date 10/05/2022
 * @description Interface for service class for WorkStepDependencies related logic.
 */
public interface IWorkStepDependenciesService {
    /**
     * @description It checks dependee WorkSteps's Status to enable banner message
     * and get banner message from associated WorkPlanTemplatEntry record.
     * @param sObjectId - Id of WorkPlan or WorkStep
     * @return BannerMessageWrapper
     */
    BannerMessageWrapper getBannerMessageDetails(Id sObjectId);

    /**
     * @description It collects dependent WorkStepIds for which all dependee WorkSteps have
     * Status as Complete.
     * @param sObjectIds - Set of WorkStepIds or Set of WorkPlanIds
     * @param sObjectType - Object type to identify grouping field
     * @return Map<Id, Set<String>> - Map of WorkStepId or WorkPlanId and associated Statueses
     */
    Map<Id, Set<String>> getSobjectIdToDependeeWorkStepStatuses(
        Set<Id> sObjectIds,
        Schema.SObjectType sObjectType
    );
}