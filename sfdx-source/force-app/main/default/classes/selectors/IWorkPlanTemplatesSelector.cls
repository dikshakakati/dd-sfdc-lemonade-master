/**
 * @author Deloitte
 * @date 13/04/2022
 * @description Interface to add Selector class methods
 */
public interface IWorkPlanTemplatesSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting WorkPlanTemplates based on passed set of Ids.
     * @param setIds Set of WorkPlanTemplate Ids
     * @return List<WorkPlanTemplate> - list of WorkPlanTemplate records
     */
    List<WorkPlanTemplate> selectById(Set<Id> setIds);

    /**
     * @description It is used for getting active WorkPlanTemplate records
     * based on passed WorkPlan types.
     * @param workPlanTypes
     * @return List<WorkPlanTemplate>
     */
    List<WorkPlanTemplate> selectByType(Set<String> workPlanTypes);

    /**
     * @description It queries WorkPlanTemplates with related WorkPlanTemplateEntries.
     * @param workPlanTemplateIds
     * @return List<WorkPlanTemplate>
     */
    List<WorkPlanTemplate> selectWorkPlanTemplatesWithWorkPlanTemplateEntries(
        Set<Id> workPlanTemplateIds
    );
}